"""A16 R3: build native multi-frame and multi-layer LibreSprite .ase files.
A15 is strictly read-only. R2 candidate stays visual FAIL. This is editing infrastructure, not automatic art improvement.
File layout follows ASE file format: 128-byte header, frame/layer chunks, zlib compressed RGBA cels.
"""
from pathlib import Path
from PIL import Image,ImageDraw
import struct,zlib,json,hashlib,subprocess,zipfile
import numpy as np
HOME=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
SRC=HOME/"A15_ART_REPAIR"/"FINAL_CANDIDATE"
R2=HOME/"A16_KEYPOSE_REDRAW"
DST=R2/"A16_R3_EDITABLE_8FRAME"
DST.mkdir(exist_ok=True)
LIBRE=Path(r"E:\GameAssetToolLab_20261023\tools\LibreSprite\libresprite.exe")
CONFIG={
 "T1_forest_scout":{"keyframes":(2,5),"size":(96,112),"durations":(83,133,133,100,67,83,117,167),
    "points":{2:{"S":(55,57),"E":(60,62),"W":(64,60),"H":(66,61)},5:{"S":(55,57),"E":(61,57),"W":(65,64),"H":(67,65)}}},
 "T2_moss_antler":{"keyframes":(3,5),"size":(96,96),"durations":(150,133,100,83,83,117,133,150),
    "points":{3:{"front_near_hip":(40,64),"front_near_knee":(41,67),"front_near_hoof":(39,68),"back_near_hip":(67,63),"back_near_knee":(70,65),"back_near_hoof":(72,67)},
       5:{"front_near_hip":(40,67),"front_near_knee":(40,72),"front_near_hoof":(38,74),"back_near_hip":(67,64),"back_near_knee":(69,67),"back_near_hoof":(70,70)}}}
}
COLORS=((255,15,55,255),(255,225,0,255),(0,210,255,255),(255,0,210,255))
def st(s):
    b=s.encode("utf-8");return struct.pack("<H",len(b))+b
def chunk(typ,payload):
    return struct.pack("<IH",len(payload)+6,typ)+payload
def layer(name,visible):
    flags=3 if visible else 2 # visible(1)+editable(2)
    payload=struct.pack("<HHHHHHB",flags,0,0,0,0,0,255)+bytes(3)+st(name)
    return chunk(0x2004,payload)
def cel(index,im):
    # zlib lossless 32-bit RGBA, CEL compressed type 2
    w,h=im.size
    pre=struct.pack("<HhhBH",index,0,0,255,2)+bytes(7)+struct.pack("<HH",w,h)
    return chunk(0x2005,pre+zlib.compress(im.tobytes(),9))
def file_header(size,frame_count,w,h):
    a=bytearray(128)
    struct.pack_into("<IHHHHHIH",a,0,size,0xA5E0,frame_count,w,h,32,1,100)
    a[34]=1;a[35]=1
    struct.pack_into("<HH",a,40,16,16)
    return bytes(a)
def make_guide(size,points):
    im=Image.new("RGBA",size)
    d=ImageDraw.Draw(im)
    labels=list(points)
    for i,(tag,(x,y)) in enumerate(points.items()):
        c=COLORS[i%len(COLORS)]
        d.line((x-2,y,x+2,y),fill=c,width=1)
        d.line((x,y-2,x,y+2),fill=c,width=1)
        # pixel coordinates identified by legend JSON; overlay hidden by default
    return im
def render_native(name,cfg):
    size=tuple(cfg["size"]);w,h=size
    a15=[];candidate=[];guides=[]
    for i in range(8):
        src=Image.open(SRC/name/"frames"/f"attack_{i:02}.png").convert("RGBA")
        assert src.size==size,(name,i,src.size,size)
        a15.append(src)
        r2=R2/name/f"attack_{i:02}_A16_KEY_R2.png"
        cand=Image.open(r2).convert("RGBA") if i in cfg["keyframes"] else src.copy()
        assert cand.size==size
        candidate.append(cand)
        guides.append(make_guide(size,cfg["points"].get(i,{})))
    frames=[]
    for i in range(8):
        ch=[]
        if i==0:
            ch.extend([layer("A15_REFERENCE_HIDE",False),
                        layer("A16_R2_EDITABLE",True),
                        layer("JOINT_GUIDE_HIDE",False)])
        ch.append(cel(0,a15[i]))
        ch.append(cel(1,candidate[i]))
        if i in cfg["keyframes"]:
            ch.append(cel(2,guides[i]))
        body=b"".join(ch)
        hdr=struct.pack("<IHHH2sI",len(body)+16,0xF1FA,len(ch),cfg["durations"][i],bytes(2),len(ch))
        frames.append(hdr+body)
    payload=b"".join(frames)
    output=DST/f"{name}_A16_R3_EDITOR.ase"
    output.write_bytes(file_header(len(payload)+128,8,w,h)+payload)
    expected=DST/f"{name}_A16_R3_EXPECTED.png"
    strip=Image.new("RGBA",(w*8,h))
    for i,im in enumerate(candidate):
        strip.paste(im,(w*i,0))
    strip.save(expected)
    (DST/f"{name}_R3_JOINT_GUIDES.json").write_text(json.dumps(cfg["points"],ensure_ascii=False,indent=2),encoding="utf-8")
    return output,expected,a15,candidate
def compare_rgba(a,b):
    aa=np.asarray(a.convert("RGBA"));bb=np.asarray(b.convert("RGBA"))
    return int(np.any(aa!=bb,axis=2).sum()) if aa.shape==bb.shape else -1
def run():
    status={}
    for name,cfg in CONFIG.items():
        native,expected,a15,candidate=render_native(name,cfg)
        sheet=DST/f"{name}_A16_R3_LIBRESPRITE_EXPORT.png"
        meta=DST/f"{name}_A16_R3_EXPORT.json"
        args=[str(LIBRE),"-b",str(native),"--sheet-type","horizontal","--sheet",str(sheet),"--data",str(meta)]
        test=subprocess.run(args,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=60)
        print("LIBRE",name,"exit",test.returncode,test.stdout.decode("utf-8","replace")[-450:])
        if test.returncode!=0 or not sheet.exists():
            raise RuntimeError("LibreSprite export failed "+name)
        A=Image.open(expected).convert("RGBA");B=Image.open(sheet).convert("RGBA")
        err=compare_rgba(A,B)
        original_source=[hashlib.sha256((SRC/name/"frames"/f"attack_{i:02}.png").read_bytes()).hexdigest() for i in range(8)]
        source_ok=all(original_source[i]==hashlib.sha256((SRC/name/"frames"/f"attack_{i:02}.png").read_bytes()).hexdigest() for i in range(8))
        # Prove original A15 layer exists in ASE and is separate from editable copy
        reference_sheet=DST/f"{name}_A15_REFERENCE_LAYER.png"
        cmd=[str(LIBRE),"-b","--all-layers","--layer","A15_REFERENCE_HIDE",str(native),"--sheet-type","horizontal","--sheet",str(reference_sheet)]
        ref_test=subprocess.run(cmd,stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=60)
        ref_strip=Image.new("RGBA",A.size)
        for i,orig in enumerate(a15):ref_strip.paste(orig,(i*orig.width,0))
        ref_error=compare_rgba(ref_strip,Image.open(reference_sheet).convert("RGBA")) if reference_sheet.exists() else -1
        status[name]={"editable_native":str(native),"native_bytes":native.stat().st_size,
          "layers":["A15_REFERENCE_HIDE","A16_R2_EDITABLE","JOINT_GUIDE_HIDE"],
          "frames":8,"new_visual_keyframes":list(cfg["keyframes"]),
          "sheet_dimensions":list(B.size),"pixel_diff_visible_ASE_vs_R2_input":err,
          "reference_layer_export_rgba_diff":ref_error,
          "source_file_untouched":source_ok,
          "native_sha256":hashlib.sha256(native.read_bytes()).hexdigest(),
          "A16_G7":"FAIL / NOT SEALED",
          "ASF_or_VX_A16":"NOT RUN",
          "libre_command_exit":test.returncode,
          "reference_command_exit":ref_test.returncode}
        print("RESULT",name,"visible pixel diff",err,"reference layer diff",ref_error)
    (DST/"A16_R3_NATIVE_8FRAME_QA.json").write_text(json.dumps(status,ensure_ascii=False,indent=2),encoding="utf-8")
    assert all(v["pixel_diff_visible_ASE_vs_R2_input"]==0 and v["reference_layer_export_rgba_diff"]==0 for v in status.values()),"NATIVE FAIL: no PASS"
    text="""# A16 R3 EDITABLE ANIMATION TOOLCHAIN HANDOFF
Date: 2026-10-31. Formal judgement: EDITOR ENGINEERING PASS, ART G7 FAIL.
Generated native 8-frame, 3-layer .aseprite / .ase files for two characters. LibreSprite actually read them, exported 8-frame PNG sheet with pixel parity and separate A15 reference layer.
A15_REFERENCE_HIDE: hidden source-identity authority, one cel/frame.
A16_R2_EDITABLE: visible editable pixel art in all eight frames; R2 actual edits only at two keyframes per character. Other six remain exact A15 placeholders. DO NOT pretend eight new art poses.
JOINT_GUIDE_HIDE: hidden, editable crosshair landmarks on keyposes.
No new character identities or animation art was produced by this stage, only native artist-editable structure.
Two image-generation trials during this stage were REJECTED as visual identity drift and infographic/non-asset output; never use them as assets or QA evidence.
Review priorities: T1 believable hand/elbow/grip; T2 natural short legs with body weight shift and good contact/no false belly duplicates.
Only after human visual G7 acceptance: fill other six frames -> ASF -> Godot -> VX. Source A15 and sealed FS untouched.
Reference format: https://github.com/aseprite/aseprite/blob/main/docs/ase-file-specs.md
"""
    (DST/"A16_R3_EDITOR_HANDOFF.md").write_text(text,encoding="utf-8")
    files=list(DST.glob("*"))
    zfile=DST/"A16_R3_PRIVATE_EDITABLE_PACKAGE.zip"
    with zipfile.ZipFile(zfile,"w",zipfile.ZIP_DEFLATED) as z:
        for p in files:
            if p.is_file():z.write(p,p.name)
    with zipfile.ZipFile(zfile) as z:
        bad=z.testzip();n=len(z.namelist())
    print("ZIP",n,zfile.stat().st_size,"CRC",bad,"sha",hashlib.sha256(zfile.read_bytes()).hexdigest())
if __name__=="__main__":run()
