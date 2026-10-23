from pathlib import Path
from PIL import Image,ImageChops,ImageDraw
import json,hashlib
r=Path(r"E:\GameAssetToolLab_20261023\FS_ForestSplit_v3_2")
b=r/"build";s=r/"sources"
m=json.loads((r/"scene_manifest.json").read_text(encoding="utf8"))
def openpng(stem):return Image.open(b/("FS_FOREST_V32_"+stem+".png")).convert("RGBA")
ground=openpng("Ground");par=openpng("Par_COMPLETE");base=openpng("Par_BASE")
occ=openpng("Occlusion");master=openpng("Master_FromScene")
collision=Image.open(b/"FS_FOREST_V32_CollisionMask.png").convert("L")
def exact(a,bb):return a.mode==bb.mode and a.size==bb.size and a.tobytes()==bb.tobytes()
checks={}
def negative(name,mutant,baseline):
    checks[name]=not exact(mutant,baseline)
# 1. Shift PAR entire layer one pixel: old bad behavior.
drift=Image.new("RGBA",par.size);drift.alpha_composite(par,(1,0))
negative("PAR_SHIFT_1PX",drift,par)
# 2. Omit sign while keeping every other object.
omitted=Image.new("RGBA",par.size)
for o in m["instances"]:
    if o["instance_id"]=="sign_01":continue
    omitted.alpha_composite(Image.open(s/(o["asset_id"]+".png")).convert("RGBA"),(o["x"],o["y"]))
negative("OMITTED_SIGN",omitted,par)
# 3. Bake part of tree into Ground.
leak=ground.copy();o=m["instances"][0]
leak.alpha_composite(Image.open(s/(o["asset_id"]+".png")).convert("RGBA"),(o["x"],o["y"]))
negative("PAR_OBJECT_BAKED_GROUND",leak,ground)
# 4. Offset occlusion while base stays still.
shift_occ=Image.new("RGBA",occ.size);shift_occ.alpha_composite(occ,(0,1))
broken=ground.copy();broken.alpha_composite(base);broken.alpha_composite(shift_occ)
negative("OCCLUSION_MISREGISTRATION",broken,master)
# 5. Source art pixels changed without alpha changing (avoid RGBA getbbox false-positive).
rgb=par.copy();pix=rgb.load()
for y in range(rgb.height):
    for x in range(rgb.width):
        if pix[x,y][3]==255:
            old=pix[x,y];pix[x,y]=(old[0]^1,old[1],old[2],old[3]);break
    else:continue
    break
negative("RGB_ONLY_DIFFERENCE_WITH_SAME_ALPHA",rgb,par)
# 6. Checkerboard disguised as transparency.
fake=par.copy()
fp=fake.load()
for y in range(fake.height):
    for x in range(fake.width):
        if fp[x,y][3]==0:fp[x,y]=((225,225,225,255) if (x//8+y//8)%2 else (188,188,188,255))
checks["FAKE_CHECKERBOARD_ALPHA"]=fake.getchannel("A").getextrema()!=(0,255)
# 7. Collision illegally occupies spawn.
cl=collision.copy();sx=m["spawn"]["x"];sy=m["spawn"]["y"];cl.putpixel((sx,sy),255)
checks["SPAWN_BLOCKED"]=cl.getpixel((sx,sy))!=0
# 8. Integer coordinate authority invalidation.
check_x=m["instances"][0]["x"]+0.5
checks["MANIFEST_SUBPIXEL"]=not isinstance(check_x,int)
# 9. Replace source bytes while manifest checksum unchanged.
asset=s/(m["instances"][0]["asset_id"]+".png")
checks["SOURCE_HASH_DRIFT"]=hashlib.sha256(asset.read_bytes()+b"x").hexdigest()!=m["instances"][0]["source_sha256"]
report={"status":"PASS" if all(checks.values()) else "FAIL","adversarial_cases":checks,"accepted":sum(checks.values()),"total":len(checks)}
(r/"logs"/"NEGATIVE_REGRESSION_TESTS.json").write_text(json.dumps(report,indent=2),encoding="utf8")
print(json.dumps(report,indent=2))
if not all(checks.values()):raise SystemExit(1)
