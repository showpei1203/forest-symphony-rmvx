from pathlib import Path
from PIL import Image
import argparse,json,sys

def evaluate(frame, reference, tolerance=3):
    flagged=[]
    for y in range(42,48):
        data=[frame.getpixel((x,y)) for x in range(29,43)]
        base=[reference.getpixel((x,y)) for x in range(29,43)]
        def longest_same_palette(row):
            colors=[color for color in set(row) if color[3]>0]
            return max([row.count(color) for color in colors],default=0)
        dominant=longest_same_palette(data)
        expected=longest_same_palette(base)
        if dominant>expected+tolerance:
            flagged.append({'row':y,'candidate_dominant_color_px':dominant,
                            'approved_A62_reference_px':expected,'excess':dominant-expected})
    return flagged

def candidate_frame(img,i):
    if img.size==(64,64):return img
    assert img.size==(256,192),img.size
    x=i%4*64;y=i//4*64
    return img.crop((x,y,x+64,y+64))

def check(candidate,reference,source_name):
    n=1 if candidate.size==(64,64) else 12
    rows={}
    for i in range(n):
        problems=evaluate(candidate_frame(candidate,i),reference)
        rows['F%02d'%i]=problems
    return {'candidate':source_name,'checked_frames':n,
            'failing_frames':[k for k,v in rows.items() if v],
            'seam_risk_by_frame':rows}

def main():
    parser=argparse.ArgumentParser(description='Blocking reference-based Actor01 45-degree waist visual seam gate')
    parser.add_argument('--candidate',required=True,help='RGBA 64x64 or 256x192 Body atlas')
    parser.add_argument('--reference',required=True,help='approved A62 64x64 sprite')
    parser.add_argument('--native-dir',help='optional actual Godot GPU snapshots F00..F11 for cross-check')
    parser.add_argument('--report',help='optional path to write JSON report')
    args=parser.parse_args()
    src=Image.open(args.reference).convert('RGBA')
    assert src.size==(64,64)
    cand=Image.open(args.candidate).convert('RGBA')
    check_result=check(cand,src,args.candidate)
    if args.native_dir:
        images=[]
        for i in range(12):
            # Versions A45+ may emit native screenshots with their own stage prefix.
            # Prefer A46 for this run; retain A45 for known-bad regression checks.
            file=Path(args.native_dir)/('A48_NATIVE_F%02d.png'%i)
            if not file.exists():
                file=Path(args.native_dir)/('A45_NATIVE_F%02d.png'%i)
            assert file.exists(),file
            images.append(Image.open(file).convert('RGBA'))
        n_data={}
        for i,img in enumerate(images):n_data['F%02d'%i]=evaluate(img,src)
        check_result['native_gpu_crosscheck']={
            'fail_frames':[k for k,v in n_data.items() if v],
            'fail_by_frame':n_data,
            'source':'actual independent Godot rendered native PNGs'}
    check_result['gate']='FAIL' if check_result['failing_frames'] else 'PASS'
    check_result['warning']='This detector flags known horizontal waist palette discontinuity, not every anatomical or artistic flaw; must combine with contact sheet visual review.'
    if args.report:Path(args.report).write_text(json.dumps(check_result,indent=2,ensure_ascii=False),encoding='utf8')
    print('A48_WAIST_GATE',check_result['gate'],
          'FRAMES',','.join(check_result['failing_frames']) if check_result['failing_frames'] else 'none')
    if 'native_gpu_crosscheck' in check_result:print('A46_NATIVE_CROSSCHECK_FAIL_FRAMES',check_result['native_gpu_crosscheck']['fail_frames'])
    return 1 if check_result['gate']=='FAIL' else 0

if __name__=='__main__':sys.exit(main())
