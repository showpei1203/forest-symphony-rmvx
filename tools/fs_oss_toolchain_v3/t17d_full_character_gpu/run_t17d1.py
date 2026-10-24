# -*- coding: utf-8 -*-
"""T17D1 licensed head/hair integration onto 64->128 sword, isolated tool validation."""
from pathlib import Path
import urllib.request, hashlib, csv, io, json, sys
from PIL import Image
ROOT=Path(__file__).resolve().parent
IN=ROOT/"inputs"; OUT=ROOT/"outputs";OUT.mkdir(exist_ok=True)
REV="9bf06be193b053db256b2536824af426de046aa2"
BASE="https://raw.githubusercontent.com/LiberatedPixelCup/Universal-LPC-Spritesheet-Character-Generator/"+REV+"/"
FILENAMES={
"head_male_slash.png":"spritesheets/head/heads/human/male/slash.png",
"hair_buzzcut_slash.png":"spritesheets/hair/buzzcut/adult/slash.png",
}
sha=lambda b:hashlib.sha256(b).hexdigest()
for name,path in FILENAMES.items():
    local=IN/name
    if not local.exists():
        with urllib.request.urlopen(urllib.request.Request(BASE+path,headers={"User-Agent":"FS-T17D-SourceAudit"}),timeout=20) as resp:
            local.write_bytes(resp.read())
credits_rows=list(csv.DictReader(io.StringIO((IN/"CREDITS.csv").read_text(encoding="utf-8-sig"))))
target_keys=["body/bodies/male/slash.png","head/heads/human/male/slash.png","hair/buzzcut/adult/slash.png",
             "weapon/sword/arming/attack_slash/bg/slash_128.png","weapon/sword/arming/attack_slash/fg/slash_128.png"]
recs=[]
for key in target_keys:
    matches=[r for r in credits_rows if r["filename"]==key]
    assert len(matches)==1,(key,len(matches))
    rec=matches[0]
    assert "OGA-BY 3.0" in rec["licenses"],key
    recs.append(rec)
(IN/"SOURCE_AUTHOR_ATTRIBUTION.json").write_text(json.dumps({"repo_commit":REV,"rows":recs,"chosen_license":"OGA-BY 3.0, authors must be credited"},ensure_ascii=False,indent=2),encoding="utf-8")
B=Image.open(IN/"body_slash_64.png").convert("RGBA")
H=Image.open(IN/"head_male_slash.png").convert("RGBA")
HAIR=Image.open(IN/"hair_buzzcut_slash.png").convert("RGBA")
BG=Image.open(IN/"steel_behind_128.png").convert("RGBA")
FG=Image.open(IN/"steel_front_128.png").convert("RGBA")
assert B.size==H.size==HAIR.size==(384,256)
assert BG.size==FG.size==(768,512)
# Character native pixels composited before embedding into larger action frame
body_head=Image.alpha_composite(B,H)
character=Image.alpha_composite(body_head,HAIR)
character.save(OUT/"T17D1_CHARACTER_BODY_HEAD_HAIR_64.png")
shift_test=Image.new("RGBA",H.size)
shift_test.paste(H,(1,0))
wrong_head=Image.alpha_composite(Image.alpha_composite(B,shift_test),HAIR)
diff=lambda a,b:sum(x!=y for x,y in zip(a.get_flattened_data(),b.get_flattened_data()))
head_shift_diff=diff(character,wrong_head)
assert head_shift_diff>0
swap=HAIR.copy()
swap.paste(HAIR.crop((0,64,384,128)),(0,128))
swap.paste(HAIR.crop((0,128,384,192)),(0,64))
hair_dir_swap_diff=diff(character,Image.alpha_composite(body_head,swap))
assert hair_dir_swap_diff>0
hair_missing_diff=diff(character,body_head)
assert hair_missing_diff>0
def embed(char,offset=(32,32)):
    x,y=offset
    atlas=Image.new("RGBA",(768,512))
    for dr in range(4):
        for fr in range(6):
            pix=char.crop((fr*64,dr*64,(fr+1)*64,(dr+1)*64))
            atlas.alpha_composite(pix,(fr*128+x,dr*128+y))
    return atlas
P=embed(character)
composite=Image.alpha_composite(Image.alpha_composite(BG,P),FG)
composite.save(OUT/"T17D1_ARMING_SWORD_HEAD_HAIR_128.png")
reconstruct=Image.new("RGBA",composite.size)
recover=Image.new("RGBA",character.size)
directions=["up","left","down","right"]
frame_info=[]
for d in range(4):
    for f in range(6):
        r=(f*128,d*128,(f+1)*128,(d+1)*128)
        pieces=[i.crop(r) for i in (BG,P,FG)]
        frame=Image.alpha_composite(Image.alpha_composite(pieces[0],pieces[1]),pieces[2])
        reconstruct.paste(frame,(f*128,d*128))
        pix=P.crop((f*128+32,d*128+32,f*128+96,d*128+96))
        recover.paste(pix,(f*64,d*64))
        native=character.crop((f*64,d*64,(f+1)*64,(d+1)*64))
        # geometry-only feet line, no engine pivot certification; report visible bottommost native row.
        bbox=native.getchannel("A").getbbox()
        head_visible=H.crop((f*64,d*64,(f+1)*64,(d+1)*64)).getchannel("A").getbbox() is not None
        hair_visible=HAIR.crop((f*64,d*64,(f+1)*64,(d+1)*64)).getchannel("A").getbbox() is not None
        swordvisible=Image.alpha_composite(pieces[0],pieces[2]).getchannel("A").getbbox() is not None
        frame_info.append({"direction":directions[d],"index":f,"bbox":list(bbox) if bbox else None,
                           "bottommost_character_pixel_y":bbox[3]-1 if bbox else None,"head_visible":head_visible,
                           "hair_visible":hair_visible,"sword_visible":swordvisible})
    composite.crop((0,d*128,768,(d+1)*128)).save(OUT/("T17D1_"+directions[d]+".png"))
assert reconstruct.tobytes()==composite.tobytes(),"per-cell mismatch"
assert recover.tobytes()==character.tobytes(),"embedded native 64px altered"
assert all(x["head_visible"] and x["hair_visible"] and x["sword_visible"] for x in frame_info),"source head/hair missing cell"
# Extended z tests (head and hair ordering is intentional)
wrong_z=Image.alpha_composite(Image.alpha_composite(FG,P),BG)
z_diff=diff(composite,wrong_z);assert z_diff>0
wrong_body_offset=Image.alpha_composite(Image.alpha_composite(BG,embed(character,(33,32))),FG)
offset_diff=diff(composite,wrong_body_offset);assert offset_diff>0
preview=Image.new("RGBA",composite.size,(35,41,51,255));preview.alpha_composite(composite)
preview.save(OUT/"T17D1_HUMAN_CONTACT_SHEET.png")
manifest={
 "status":"T17D1_MODULAR_HEAD_HAIR_WEAPON_24FRAME_STRUCTURAL_PASS_HUMAN_RUNTIME_PENDING",
 "source_commit":REV,"source_credits":recs,
 "source_hashes":{p.name:sha(p.read_bytes()) for p in IN.iterdir() if p.is_file()},
 "canvas":[768,512],"weapon_cell":[128,128],"character_cell":[64,64],"offset":[32,32],
 "directions":directions,"total_frames":24,"frame_metadata":frame_info,
 "all_24_head_hair_weapon_nonempty":True,
 "native_64_character_recover_rgba_exact":True,"per_cell_composite_exact":True,
 "negative_mutation_diffs":{"head_x_plus1":head_shift_diff,"hair_direction_swap":hair_dir_swap_diff,
   "hair_missing":hair_missing_diff,"z_reverse":z_diff,"body_embed_x_plus1":offset_diff},
 "pivot_gate":"FOOT_PIXEL_BOUNDS_ONLY_ENGINE_PIVOT_NOT_TESTED",
 "SBS_gate":"PENDING: requires existing VX/SBS binary and real hit frame / weapon actor timing",
 "art_gate":"HUMAN_PENDING: pixels structurally aligned, head skin/hair and grip aesthetically unapproved",
 "not_changed":["Forest Symphony N5 map","505 SEALED RMVX scripts","D32A3a/v0.5/v0.6 Tankentai SBS baselines"]
}
(ROOT/"T17D1_MODULAR_CHAR_WEAPON_RESULT.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
print(json.dumps({"status":manifest["status"],"all_24_head_hair_weapon_nonempty":True,
  "native_recovery":True,"per_cell_exact":True,"negative_tests":manifest["negative_mutation_diffs"],
  "bottom_row_range":[min(x["bottommost_character_pixel_y"] for x in frame_info),max(x["bottommost_character_pixel_y"] for x in frame_info)]},ensure_ascii=False,indent=2))
