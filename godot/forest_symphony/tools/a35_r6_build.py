#!/usr/bin/env python3
"""A35 R6: make reversible Godot scene with 3 conifer refinements, no old data loss."""
import argparse,hashlib,io,json,zipfile
from pathlib import Path
from PIL import Image,ImageDraw
from a35_r6_conifer_art import refine,KINDS

ROOT="private_assets/independent_par/"
BASE_SCENE="scenes/a35_r5_botanical_forest_hd2d_scene.tscn"
NEW_SCENE="scenes/a35_r6_conifer_hd2d_scene.tscn"
BASE_MAN="data/a35_r5_botanical_forest_manifest.json"
NEW_MAN="data/a35_r6_conifer_manifest.json"
GROUND="private_assets/ground_only.png"
GROUND_SHA="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"

def sha(b):return hashlib.sha256(b).hexdigest()
def png(i):
    buffer=io.BytesIO();i.save(buffer,"PNG",optimize=True);return buffer.getvalue()

def build(input_zip:Path,output_zip:Path,work:Path,art_script:Path):
    work.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(input_zip) as z:
        if z.testzip() is not None:raise ValueError("R5 input CRC failed")
        files={p:z.read(p) for p in z.namelist()}
    if sha(files[GROUND])!=GROUND_SHA:raise ValueError("Sealed Ground checksum changed")
    originals={p:files[p] for p in [
        GROUND,"scenes/a35_r2_new_species_scene.tscn",
        "scenes/a35_r3_hd2d_layered_scene.tscn",
        "scenes/a35_r4_organic_groves_hd2d_scene.tscn",BASE_SCENE]}
    document=json.loads(files[BASE_MAN])
    if len(document["objects"])!=187 or sum(obj["semantic"]=="tree" for obj in document["objects"])!=175:
        raise ValueError("R5 base not the sealed 187/175 scene")
    scene=files[BASE_SCENE].decode()
    before={o["id"]:dict(o) for o in document["objects"]}
    modified=[]
    metrics={}
    gallery=Image.new("RGBA",(3*228,2*213),(65,75,67,255))
    drawer=ImageDraw.Draw(gallery)
    for ix,kind in enumerate(KINDS):
        older="a35r5_"+kind
        newer="a35r6_"+kind
        meta=document["assets"][older]
        source=Image.open(io.BytesIO(files[meta["file"]])).convert("RGBA")
        refined=refine(kind,source)
        if refined.size!=source.size:raise ValueError("R6 alpha canvas changes: "+kind)
        if source.getbbox() is None:raise ValueError("Empty original "+kind)
        # Top can grow by a few needles but both footpoint and asset canvas are fixed.
        bbox_old=source.getbbox()
        bbox_new=refined.getbbox()
        if bbox_new[3]!=bbox_old[3] or bbox_new[1]<bbox_old[1]-5:
            raise ValueError("R6 tree vertical bounds drift: "+kind)
        file=ROOT+newer+".png"
        binary=png(refined)
        files[file]=binary
        digest=sha(binary)
        document["assets"][newer]={
            "id":newer,"file":file,"size":list(refined.size),"sha256":digest,
            "species":kind,"semantic":"tree","method":"R6 native-pixel interior volume + botanical 1px needles, no re-scaling",
            "source_asset":older,"alpha_bbox":list(bbox_new),"art":"HOLD"
        }
        before_path='source_file = "res://'+meta["file"]+'"'
        before_hash='source_sha256 = "'+meta["sha256"]+'"'
        if before_path not in scene or before_hash not in scene:
            raise ValueError("R5 conifer path/sha not found: "+kind)
        scene=scene.replace(before_path,'source_file = "res://'+file+'"')
        scene=scene.replace(before_hash,'source_sha256 = "'+digest+'"')
        count=0
        for obj in document["objects"]:
            if obj["asset_id"]==older:
                obj["asset_id"]=newer
                obj["source_sha256"]=digest
                obj["previous_R5_asset"]=older
                modified.append(obj["id"])
                count+=1
        metrics[kind]={
            "R5_alpha_bbox":list(bbox_old),"R6_alpha_bbox":list(bbox_new),
            "owner_instances":count,"source_sha256":meta["sha256"],"candidate_sha256":digest
        }
        x=ix*228+(228-source.width)//2
        gallery.alpha_composite(source,(x,5))
        gallery.alpha_composite(refined,(x,213+4))
        drawer.text((ix*228+7,191),kind+" / R5 original",fill="white")
        drawer.text((ix*228+7,404),kind+" / R6 native pixel",fill="white")
    if len(modified)!=13 or len(set(modified))!=13:raise ValueError("Expected exactly 13 R6 conifer owners: "+str(len(modified)))
    for obj in document["objects"]:
        old=before[obj["id"]]
        for key in ("x","y","w","h","foot","semantic"):
            if obj.get(key)!=old.get(key):raise ValueError("Owner geometry changed "+str((obj["id"],key)))
        if obj["id"] not in modified and obj["source_sha256"]!=old["source_sha256"]:
            raise ValueError("Non-conifer source modified: "+obj["id"])
    # Preserve original scene and all parallel/historical content byte-for-byte.
    new_scene=scene.replace("FS_A35_R5_BotanicalForestHD2D","FS_A35_R6_ConiferDetailHD2D",1)
    if new_scene==scene:raise ValueError("R5 root identity not found")
    files[NEW_SCENE]=new_scene.encode()
    document.update(schema="fs-a35-r6-conifer-native/v1",
        r6_modified_object_ids=sorted(modified),
        r6_original_R5_scene_sha256=sha(files[BASE_SCENE]),
        r6_original_Ground_sha256=GROUND_SHA,
        r6_native="NOT_RUN",r6_art="HOLD")
    files[NEW_MAN]=(json.dumps(document,ensure_ascii=False,indent=2)+"\n").encode()
    files["project.godot"]=files["project.godot"].replace(
        ("res://"+BASE_SCENE).encode(),("res://"+NEW_SCENE).encode())
    if ("res://"+NEW_SCENE).encode() not in files["project.godot"]:raise ValueError("New Godot main scene not selected")

    nat=files["tests/test_a35_r5_native.gd"].decode()
    nat=nat.replace('const OLD := "res://scenes/a35_r4_organic_groves_hd2d_scene.tscn"',
                    'const OLD := "res://'+BASE_SCENE+'"')
    nat=nat.replace('const NEW := "res://'+BASE_SCENE+'"',
                    'const NEW := "res://'+NEW_SCENE+'"')
    nat=nat.replace('const MAN := "res://'+BASE_MAN+'"',
                    'const MAN := "res://'+NEW_MAN+'"')
    nat=nat.replace('changed!=32 or retained!=155','changed!=13 or retained!=174')
    nat=nat.replace("R5","R6")
    nat=nat.replace("32 replaced, 155 retained","13 replaced, 174 retained")
    # Ensure old R5 path wasn't accidentally renamed by blanket version replacement.
    nat=nat.replace("scenes/a35_r6_botanical_forest_hd2d_scene.tscn",
                    BASE_SCENE)
    if 'const OLD := "res://'+BASE_SCENE+'"' not in nat or 'const NEW := "res://'+NEW_SCENE+'"' not in nat:
        raise ValueError("R6 native base/current paths incorrect")
    files["tests/test_a35_r6_native.gd"]=nat.encode()
    nav=files["tests/test_a35_r5_navigation.gd"].decode()
    nav=nav.replace("res://"+BASE_SCENE,"res://"+NEW_SCENE)
    nav=nav.replace("A35 R5","A35 R6")
    files["tests/test_a35_r6_navigation.gd"]=nav.encode()
    cap=files["tests/capture_a35_r5_native.gd"].decode()
    cap=cap.replace("res://"+BASE_SCENE,"res://"+NEW_SCENE)
    cap=cap.replace("A35_R5_BOTANY_","A35_R6_CANOPY_").replace("A35 R5","A35 R6")
    files["tests/capture_a35_r6_native.gd"]=cap.encode()
    ab=files["tests/capture_a35_r5_ab_actor_native.gd"].decode()
    ab=ab.replace('const OLD := "res://scenes/a35_r4_organic_groves_hd2d_scene.tscn"',
                  'const OLD := "res://'+BASE_SCENE+'"')
    ab=ab.replace('const NEW := "res://'+BASE_SCENE+'"','const NEW := "res://'+NEW_SCENE+'"')
    ab=ab.replace("A35_R5_","A35_R6_")
    ab=ab.replace("A35_R6_R4_BASELINE_NATIVE.png","A35_R6_R5_BASELINE_NATIVE.png")
    ab=ab.replace("A35 R5","A35 R6")
    files["tests/capture_a35_r6_ab_actor_native.gd"]=ab.encode()
    files["tools/a35_r6_conifer_art.py"]=art_script.read_bytes()
    files["tools/a35_r6_build.py"]=Path(__file__).read_bytes()
    output_art=png(gallery)
    files["qa_a35/A35_R6_SOURCE_AB_SOFTWARE_ONLY.png"]=output_art
    (work/"A35_R6_SOURCE_AB_SOFTWARE_ONLY.png").write_bytes(output_art)
    source_report={
        "phase":"A35 R6 source / actual Godot not yet tested",
        "base_sha256":sha(input_zip.read_bytes()),"changed":13,"retained":174,
        "tree_total":175,"PAR_total":187,"Ground_sha256":GROUND_SHA,"metrics":metrics,
        "source_integrity":"PASS","native":"NOT_RUN","art":"HOLD"
    }
    files["qa_a35/A35_R6_SOURCE_QA.json"]=(json.dumps(source_report,ensure_ascii=False,indent=2)+"\n").encode()
    files["docs/A35_R6_HANDOFF.md"]=(
        "# FS A35 R6 source construction\n"
        "- The 3 R5 conifer sprites are refined at their native existing pixel canvas (NO further scale-up). All 13 instances use updated path and SHA, 174 other PAR untouched.\n"
        "- 1px botanical needle strokes on actual leaf silhouettes; root/bottom 19px guaranteed byte-identical to R5 artwork.\n"
        "- Source tree sprite A/B collage is software-generated, NOT an original Godot capture. ART HOLD until real Godot native screenshots and visual inspection.\n"
    ).encode()
    files["docs/A35_R6_FAILURE_LOG.md"]=(
        "# FS A35 R6 failure register\n"
        "- R5 three enlarged conifers have excessively square green pixels. R6 cleans interior square-color islands and paints micro-needles, not simply resizing again.\n"
        "- Avoid flattening canopy into opaque dark triangular mask (rejected R4 test). Keep natural alpha and real root zone.\n"
        "- Must run native Godot source/nav/physical/actor and pixel ROI plus real GPU 7 captures before promising PASS.\n"
    ).encode()
    output_zip.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(output_zip,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as z:
        for file,data in files.items():z.writestr(file,data)
    with zipfile.ZipFile(output_zip) as z:
        if z.testzip() is not None:raise ValueError("R6 packaged CRC failed")
        if any(z.read(k)!=v for k,v in originals.items()):raise ValueError("R6 old Ground/scene was mutated")
    print(json.dumps({
        "output":str(output_zip),"bytes":output_zip.stat().st_size,
        "members":len(files),"sha256":sha(output_zip.read_bytes()),"qa":source_report
    },ensure_ascii=False,indent=2))

if __name__=="__main__":
    p=argparse.ArgumentParser()
    p.add_argument("--base",required=True)
    p.add_argument("--output",required=True)
    p.add_argument("--work",required=True)
    p.add_argument("--art",required=True)
    a=p.parse_args()
    build(Path(a.base),Path(a.output),Path(a.work),Path(a.art))
