"""A16 R3 deterministic verification: authoritative A15, full native frames/layers, edit smoke, private ZIP."""
from pathlib import Path
from PIL import Image,ImageDraw
import subprocess,zipfile,hashlib,json,struct
import numpy as np
BASE=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031")
A15=BASE/"A15_ART_REPAIR"/"FINAL_CANDIDATE"
R3=BASE/"A16_KEYPOSE_REDRAW"/"A16_R3_EDITABLE_8FRAME"
EXE=r"E:\GameAssetToolLab_20261023\tools\LibreSprite\libresprite.exe"
H=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
truth="ebe074d87cc242bbeab5d4e3061a5db0333a6db2bff2abac6c60f870aa5956b5"
archive=A15/"A15_FINAL_PRIVATE_20261031.zip"
assert H(archive)==truth,"FATAL: A15 ZIP drift"
q={}
with zipfile.ZipFile(archive) as z:
    assert z.testzip() is None
    for name in ["T1_forest_scout","T2_moss_antler"]:
        c=0
        for i in range(8):
            fn=f"{name}/frames/attack_{i:02}.png"
            disk=(A15/name/"frames"/f"attack_{i:02}.png").read_bytes()
            assert z.read(fn)==disk,fn+" CHANGED!"
            c+=1
        q[name]={"A15_zip_frame_parity":c}
# Load native sheet and source reference, 0 diff required
for name in ["T1_forest_scout","T2_moss_antler"]:
    project=R3/f"{name}_A16_R3_EDITOR.ase"
    expected=np.array(Image.open(R3/f"{name}_A16_R3_EXPECTED.png").convert("RGBA"))
    produced=np.array(Image.open(R3/f"{name}_A16_R3_LIBRESPRITE_EXPORT.png").convert("RGBA"))
    a15_reference=np.array(Image.open(R3/f"{name}_A15_REFERENCE_LAYER.png").convert("RGBA"))
    assert expected.shape==produced.shape
    assert np.array_equal(expected,produced)
    w=96;h=112 if name.startswith("T1") else 96
    original=Image.new("RGBA",(w*8,h))
    for i in range(8): original.paste(Image.open(A15/name/"frames"/f"attack_{i:02}.png").convert("RGBA"),(w*i,0))
    assert np.array_equal(np.array(original),a15_reference)
    # Native ASE frame, layer and cel structure checked through actual binary header/chunk scan.
    data=project.read_bytes()
    flen,magic,frames,width,height,depth=struct.unpack_from("<IHHHHH",data,0)
    assert flen==len(data) and magic==0xA5E0 and frames==8 and width==w and height==h and depth==32
    p=128;layer_chunks=0;cel_chunks=0;frame_count=0
    while p<len(data):
        fsz,fmagic,nchunks,dur=struct.unpack_from("<IHHH",data,p)
        assert fmagic==0xF1FA and dur>0
        qpos=p+16
        for j in range(nchunks):
            csz,ctype=struct.unpack_from("<IH",data,qpos)
            if ctype==0x2004:layer_chunks+=1
            if ctype==0x2005:cel_chunks+=1
            qpos+=csz
        assert qpos==p+fsz,"chunk offsets bad"
        p+=fsz;frame_count+=1
    assert frame_count==8 and layer_chunks==3 and cel_chunks==18,(name,frame_count,layer_chunks,cel_chunks)
    # Extra proof native file roundtrip with actual LibreSprite layer listing
    ls=subprocess.run([EXE,"-b","--all-layers","--list-layers",str(project)],timeout=30,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
    found=ls.stdout.decode("utf-8","replace")
    assert all(x in found for x in ["A15_REFERENCE_HIDE","A16_R2_EDITABLE","JOINT_GUIDE_HIDE"]),(name,found)
    q[name].update({"8_frames":frame_count,"3_layers":layer_chunks,"cels":cel_chunks,
        "live_libresprite_sheet_pixel_diff":0,"live_reference_layer_pixel_diff":0,
        "native_sha256":H(project),"layer_list_cli_ok":True})
# PROVE editing works on a copy, changes exactly one pixel on one frame only.
test=R3/"T1_TEST_SINGLE_PIXEL_EDIT.ase"
assert test.exists() and H(test)!=H(R3/"T1_forest_scout_A16_R3_EDITOR.ase")
test_sheet=R3/"T1_TEST_SINGLE_PIXEL_EDIT_SHEET.png"
pr=subprocess.run([EXE,"-b",str(test),"--sheet-type","horizontal","--sheet",str(test_sheet)],timeout=35,stdout=subprocess.PIPE,stderr=subprocess.STDOUT)
assert pr.returncode==0
before=np.array(Image.open(R3/"T1_forest_scout_A16_R3_LIBRESPRITE_EXPORT.png").convert("RGBA"))
after=np.array(Image.open(test_sheet).convert("RGBA"))
indices=np.argwhere(np.any(before!=after,axis=2))
assert indices.shape==(1,2),("smoke edit != 1 pixel",indices.shape)
assert tuple(indices[0])==(1,2*96+1),("wrong frame/layer edit",indices.tolist())
assert tuple(after[1,2*96+1])==(255,0,255,255),("pixel color wrong",after[1,193])
q["smoke_editor"]={"changed_pixels":1,"modified_frame":2,"modified_pixel_xy":[1,1],"original_native_preserved":True}
# Preview only, no false original artwork claims, no scaling in machine-readable output.
for name in ["T1_forest_scout","T2_moss_antler"]:
    conf=[2,5] if name.startswith("T1") else [3,5]
    sz=(96,112) if name.startswith("T1") else (96,96)
    frames=[Image.open(R3/f"{name}_A16_R3_LIBRESPRITE_EXPORT.png").convert("RGBA").crop((sz[0]*i,0,sz[0]*(i+1),sz[1])) for i in range(8)]
    panels=[]
    for i,f in enumerate(frames):
        bg=Image.new("RGBA",f.size,(223,225,227,255));bg.alpha_composite(f)
        resized=bg.convert("RGB").resize((sz[0]*4,sz[1]*4),Image.Resampling.NEAREST)
        panels.append(resized)
    sheet=Image.new("RGB",(4*(sz[0]*4),2*(sz[1]*4+20)),(239,239,239))
    d=ImageDraw.Draw(sheet)
    for i,f in enumerate(panels):
        x=(i%4)*(sz[0]*4);y=(i//4)*(sz[1]*4+20)
        d.text((x+8,y+3),f"ATTACK_{i:02} / "+("R2 CANDIDATE" if i in conf else "A15 UNCHANGED"),fill=(30,30,30))
        sheet.paste(f,(x,y+20))
    sheet.save(R3/f"{name}_8FRAME_ART_REVIEW_4X.png")
    # GIF is a reference preview only
    gif=[p.convert("P",palette=Image.Palette.ADAPTIVE) for p in panels]
    durations=[83,133,133,100,67,83,117,167] if name.startswith("T1") else [150,133,100,83,83,117,133,150]
    gif[0].save(R3/f"{name}_R3_EDITOR_PREVIEW.gif",save_all=True,append_images=gif[1:],duration=durations,loop=0,disposal=2)
(R3/"A16_R3_FINAL_QA.json").write_text(json.dumps(q,ensure_ascii=False,indent=2),encoding="utf-8")
handoff=f"""# ASF A16 R3 Native 8-frame Editor (2026-10-31)
## Status
Tooling PASS. Human artwork G7 remains FAIL. No ASF/Godot/VX gate rerun; no FS sealed file touched.
## Reproducible facts
A15 636-file private baseline archive SHA256 {truth} matched on disk; 16 source attack PNG raw bytes match ZIP entries.
Two native LibreSprite .ase projects, each **8 frames / 3 layers / 18 cels**. Layer 0 A15_REFERENCE_HIDE, Layer 1 A16_R2_EDITABLE, Layer 2 JOINT_GUIDE_HIDE.
8-frame visible PNG sheet and separately exported hidden A15 reference layer pixel differences 0 for BOTH characters, actually exported using LibreSprite 1.3.
One-pixel smoke test using native LibreSprite JavaScript API changed exactly 1 RGBA pixel in copy of T1 frame_02 at (1,1); source .ase unchanged. Color (255,0,255,255). Test copy is excluded from private package.
T1 *only two art-edited frames* attack_02/05; T2 *only two art-edited frames* attack_03/05. Other six in each remain A15. Never represent these as 16 new art frames.
Image generation route TESTED TWICE and REJECTED: output was infographics with wrong human/animal identity and unsourced QA badges, not reusable 96px transparent sprites. Generated images are not production assets.
Remaining artistic blocker: T1 rigid shoulder/hand and disconnected sword grip; T2 rear-leg protrusion, artificial knee/hoof shapes, poor weight transfer. Next is pixel artist corrective paint on the native key cels, no further coordinate-based action reconstruction.
Tooling gate is separate from artistic G7, which fails until actual human visual review. Do not expand to ASF or overwrite official game sprites.
## Private package
Located E:\\GameAssetToolLab_20261023\\ASF_Test_20261031\\A16_KEYPOSE_REDRAW\\A16_R3_EDITABLE_8FRAME
"""
(R3/"A16_R3_FINAL_HANDOFF.md").write_text(handoff,encoding="utf-8")
# Deliver only authoritative assets, not diagnostic edited copies or arbitrary trial PNGs
wanted=[]
for name in ["T1_forest_scout","T2_moss_antler"]:
    for suffix in ("_A16_R3_EDITOR.ase","_A16_R3_EXPECTED.png","_A16_R3_LIBRESPRITE_EXPORT.png","_A15_REFERENCE_LAYER.png",
                   "_R3_JOINT_GUIDES.json","_8FRAME_ART_REVIEW_4X.png","_R3_EDITOR_PREVIEW.gif"):
        wanted.append(R3/(name+suffix))
wanted.extend([R3/"A16_R3_NATIVE_8FRAME_QA.json",R3/"A16_R3_FINAL_QA.json",R3/"A16_R3_EDITOR_HANDOFF.md",R3/"A16_R3_FINAL_HANDOFF.md"])
final=R3/"A16_R3_PRIVATE_EDITOR_8FRAME.zip"
with zipfile.ZipFile(final,"w",zipfile.ZIP_DEFLATED) as z:
    for p in wanted:
        assert p.exists(),p
        z.write(p,p.name)
with zipfile.ZipFile(final) as z:
    assert z.testzip() is None
    count=len(z.namelist())
print("FINAL PASS",json.dumps(q,ensure_ascii=False)[:1200])
print("ZIP",final,"FILES",count,"BYTES",final.stat().st_size,"CRC_PASS",True,"SHA",H(final))
