#!/usr/bin/env python3
"""A35 R5: build eight botanical species in a reversible Godot 4.7.2 village scene.

Input: sealed private A35 R4 native ZIP. Output: new owner-only candidate ZIP.
Never modifies any original scene/Ground/other branch or uploads PNGs to GitHub.
"""
import argparse,hashlib,io,json,zipfile
from pathlib import Path
from PIL import Image,ImageDraw
from a35_r5_botanical_sprites import SPECIES,render

OLD_SCENE="scenes/a35_r4_organic_groves_hd2d_scene.tscn"
NEW_SCENE="scenes/a35_r5_botanical_forest_hd2d_scene.tscn"
OLD_MAN="data/a35_r4_organic_groves_manifest.json"
NEW_MAN="data/a35_r5_botanical_forest_manifest.json"
GROUND="private_assets/ground_only.png"
GROUND_SHA="3348d4d30f7bea64d6e4a8ea349d3ed868a1a04660671dd93c1787d6418b0000"

def sha(b):return hashlib.sha256(b).hexdigest()
def png(i):
    f=io.BytesIO();i.save(f,"PNG",optimize=True);return f.getvalue()

def build(base:Path,out:Path,workspace:Path,artcode:Path):
    workspace.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(base) as zipped:
        if zipped.testzip() is not None:raise ValueError("Source ZIP CRC fail")
        files={n:zipped.read(n) for n in zipped.namelist()}
    if sha(files[GROUND])!=GROUND_SHA:raise ValueError("R4 original Ground mutated")
    initial_scene=files[OLD_SCENE]
    scene=initial_scene.decode()
    doc=json.loads(files[OLD_MAN])
    if len(doc["objects"])!=187 or len([a for a in doc["objects"] if a["semantic"]=="tree"])!=175:
        raise ValueError("Not 187 PAR / 175 trees baseline")
    expected_ids=set(doc["r4_modified_object_ids"])
    if len(expected_ids)!=32:raise ValueError("Original 32 replacements changed")
    original_positions={ob["id"]:(ob["x"],ob["y"],ob["foot"],ob.get("w"),ob.get("h")) for ob in doc["objects"]}
    replaced=[]
    original_assets=doc["assets"]
    catalog={}
    atlas=Image.new("RGB",(4*240,2*228),"#626e5b")
    pen=ImageDraw.Draw(atlas)
    metrics={}
    for i,(species,(source,size,scale)) in enumerate(SPECIES.items()):
        prior="a35r4_"+species
        current="a35r5_"+species
        old=doc["assets"][prior]
        item=render(species,original_assets,files)
        if item.size!=tuple(old["size"]):raise ValueError("Owned 1x pixel box changed "+species)
        if item.getbbox() is None:raise ValueError("Empty tree "+species)
        path="private_assets/independent_par/"+current+".png"
        binary=png(item)
        files[path]=binary
        new_sha=sha(binary)
        catalog[current]={
           "id":current,"file":path,"size":list(item.size),"sha256":new_sha,
           "semantic":"tree","species":species,"native_source":source,
           "technique":"one-piece FS source-art tree; 3 conifers enlarge with NEAREST + pixel needle reconstruction; other 5 are 1x",
           "alpha_bbox":list(item.getbbox()),"art":"CANDIDATE"
        }
        # Original R4 path binding occurs once per species, repeated in 32 instances.
        oldfile='source_file = "res://'+old["file"]+'"'
        oldhash='source_sha256 = "'+old["sha256"]+'"'
        if oldfile not in scene or oldhash not in scene:raise ValueError("Old binding missing "+prior)
        scene=scene.replace(oldfile,'source_file = "res://'+path+'"')
        scene=scene.replace(oldhash,'source_sha256 = "'+new_sha+'"')
        for ob in doc["objects"]:
            if ob["asset_id"]==prior:
                if ob["id"] not in expected_ids:raise ValueError("Replaced non-R4 owner: "+ob["id"])
                ob["asset_id"]=current
                ob["source_sha256"]=new_sha
                ob["previous_R4_asset"]=prior
                replaced.append(ob["id"])
        bbox=item.getbbox()
        metrics[species]={"bbox":list(bbox),"actual_height_px":bbox[3]-bbox[1],
                          "actual_width_px":bbox[2]-bbox[0],
                          "source_asset":source,"enlargement_xy":list(scale)}
        x=(i%4)*240+(240-item.width)//2
        y=(i//4)*228+3
        atlas.paste(item,(x,y),item)
        pen.text(((i%4)*240+10,(i//4)*228+202),species,fill="white")
    if set(replaced)!=expected_ids or len(replaced)!=32:raise ValueError("Not exactly original R4 32 replacements")
    # scene must not mutate any other existing owner position, collision or source.
    for ob in doc["objects"]:
        now=ob["x"],ob["y"],ob["foot"],ob.get("w"),ob.get("h")
        if now!=original_positions[ob["id"]]:raise ValueError("Foot/asset pixel bounds drift "+ob["id"])
    doc["assets"].update(catalog)
    doc.update(schema="fs-a35-r5-native-botany/v1",r5_modified_object_ids=sorted(replaced),
               r5_original_scene_sha256=sha(initial_scene),r5_original_ground_sha256=GROUND_SHA,
               r5_expected_par=187,r5_expected_trees=175,r5_art="HOLD",r5_native="NOT_RUN")
    new=scene.replace("FS_A35_R4_OrganicGrovesHD2D","FS_A35_R5_BotanicalForestHD2D",1)
    if new==scene:raise ValueError("R4 scene root name changed, refuse write")
    files[NEW_SCENE]=new.encode()
    files[NEW_MAN]=(json.dumps(doc,ensure_ascii=False,indent=2)+"\n").encode()
    files["project.godot"]=files["project.godot"].replace(("res://"+OLD_SCENE).encode(),("res://"+NEW_SCENE).encode())
    if ("res://"+NEW_SCENE).encode() not in files["project.godot"]:raise ValueError("Main scene not switched")
    files["tools/a35_r5_botanical_sprites.py"]=artcode.read_bytes()
    files["tools/a35_r5_build.py"]=Path(__file__).read_bytes()
    # Reuse vetted R4 native contract, nav and native GPU capture with R5 names.
    test=files["tests/test_a35_r4_native.gd"].decode()
    test=test.replace("scenes/a35_r3_hd2d_layered_scene.tscn",OLD_SCENE)
    test=test.replace(OLD_SCENE+"\"\\nconst NEW := \"res://"+OLD_SCENE, OLD_SCENE+"\"\\nconst NEW := \"res://"+NEW_SCENE)
    # Straight, explicit bindings avoid accidental replacement of OLD and NEW.
    test=files["tests/test_a35_r4_native.gd"].decode()
    test=test.replace('const OLD := "res://scenes/a35_r3_hd2d_layered_scene.tscn"',
                      'const OLD := "res://'+OLD_SCENE+'"')
    test=test.replace('const NEW := "res://'+OLD_SCENE+'"',
                      'const NEW := "res://'+NEW_SCENE+'"')
    test=test.replace('const MAN := "res://'+OLD_MAN+'"',
                      'const MAN := "res://'+NEW_MAN+'"')
    test=test.replace("R4","R5")
    files["tests/test_a35_r5_native.gd"]=test.encode()
    nav=files["tests/test_a35_r4_navigation.gd"].decode()
    nav=nav.replace('res://'+OLD_SCENE,'res://'+NEW_SCENE)
    nav=nav.replace('res://'+OLD_MAN,'res://'+NEW_MAN)
    nav=nav.replace("A35 R4","A35 R5")
    files["tests/test_a35_r5_navigation.gd"]=nav.encode()
    capture=files["tests/capture_a35_r4_native.gd"].decode()
    capture=capture.replace('res://'+OLD_SCENE,'res://'+NEW_SCENE)
    capture=capture.replace("A35_R4_ORGANIC_","A35_R5_BOTANY_")
    capture=capture.replace("A35 R3","A35 R5")
    files["tests/capture_a35_r5_native.gd"]=capture.encode()
    ab=files["tests/capture_a35_r4_ab_actor_native.gd"].decode()
    ab=ab.replace('const OLD := "res://scenes/a35_r3_hd2d_layered_scene.tscn"',
                  'const OLD := "res://'+OLD_SCENE+'"')
    ab=ab.replace('const NEW := "res://'+OLD_SCENE+'"',
                  'const NEW := "res://'+NEW_SCENE+'"')
    ab=ab.replace("A35_R4_","A35_R5_")
    ab=ab.replace("A35_R5_R3_BASELINE_NATIVE.png","A35_R5_R4_BASELINE_NATIVE.png")
    ab=ab.replace("A35 R4","A35 R5")
    files["tests/capture_a35_r5_ab_actor_native.gd"]=ab.encode()
    files["qa_a35/A35_R5_SOURCE_GALLERY_NOT_NATIVE.png"]=png(atlas)
    (workspace/"A35_R5_SOURCE_GALLERY_NOT_NATIVE.png").write_bytes(png(atlas))
    data={"phase":"A35_R5","original_R4_native_SHA":sha(base.read_bytes()),
        "original_scene_sha256":sha(initial_scene),"original_Ground_sha256":GROUND_SHA,
        "changed_original_ids":sorted(replaced),"actual_art_dimensions":metrics,
        "R4_scene_immutable":True,"Godot_native":"NOT_RUN","art":"HOLD"}
    files["qa_a35/A35_R5_SOURCE_QA.json"]=(json.dumps(data,ensure_ascii=False,indent=2)+"\n").encode()
    files["docs/A35_R5_HANDOFF.md"]=(
        "# FS A35 R5 / Botanical sprites Source Candidate\n"
        "- Eight coherent original-FS-source tree species with botany-specific microdetails and three real conifer size repairs.\n"
        "- Keeps exact 32 R4 changed tree IDs, 155 other PAR assets, 187 object anchor/collision definitions, original Ground and R4 scene.\n"
        "- Three conifers use NEAREST whole-image enlargement + 1px needle reconstruction. This *does* resample their original images; avoid false no-resampling claims.\n"
        "- Native renderer, R5 physics/nav and A/B actor depth: NOT RUN at source build. ART HOLD until real native QA and 1:1 image inspection.\n"
        "- GitHub text-only, private binary art on owner-only Drive.\n"
    ).encode()
    files["docs/A35_R5_FAILURE_LOG.md"]=(
        "# FS A35 R5 / Failure Log\n"
        "- Initial composite-crown attempt rejected for ghost leafy blobs, clipping at image top and unnatural flat conifer triangles; no source candidate packaged from it.\n"
        "- Reworked to whole painted source trees, with only documented nearest-neighbor enlargement for 3 undersized conifers.\n"
        "- Numeric alpha bbox size and file integrity don't establish beauty. ART HOLD awaiting 1:1 Godot original screenshots.\n"
        "- Preserve R4/R3/R2/A36C, no overwrite or public binary art.\n"
    ).encode()
    out.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(out,"w",zipfile.ZIP_DEFLATED,compresslevel=6) as zipped:
        for n,b in files.items():zipped.writestr(n,b)
    with zipfile.ZipFile(out) as test_zip:
        if test_zip.testzip() is not None:raise ValueError("R5 CRC fail")
        if sha(test_zip.read(GROUND))!=GROUND_SHA or test_zip.read(OLD_SCENE)!=initial_scene:
            raise ValueError("Source preservation failed")
    print(json.dumps({"output":str(out),"members":len(files),"bytes":out.stat().st_size,
         "sha256":sha(out.read_bytes()),"changed":len(replaced),"tree_metrics":metrics},indent=2))

if __name__=="__main__":
    parser=argparse.ArgumentParser()
    parser.add_argument("--base",required=True)
    parser.add_argument("--output",required=True)
    parser.add_argument("--work",required=True)
    parser.add_argument("--art",required=True)
    args=parser.parse_args()
    build(Path(args.base),Path(args.output),Path(args.work),Path(args.art))
