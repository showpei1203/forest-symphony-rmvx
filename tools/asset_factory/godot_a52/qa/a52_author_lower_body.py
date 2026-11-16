from pathlib import Path
from PIL import Image,ImageDraw
import glob,json,math,hashlib
root=Path(glob.glob("G:/*/FS_AI_ASSET_FACTORY_Restricted_Binaries")[0])
src=root/"FS_A50_TRUE_PIXELLAB_SWORD_CONTACT_R3_20261116"
p=root/"FS_A52_LEG_WEIGHT_TRANSFER_REAL_PIXELLAB_20261116"
p.mkdir(exist_ok=True)
source=src/"head_lock_R4/A50_R4_IDENTITY_LOCK_REAL_PIXELLAB_REQUEST_NO_TOKEN.json"
template=json.loads(source.read_text(encoding="utf8"))
assert len(template["keypoints"])==10
# Strong deliberately visible lower-body changes in 64x64:
# F01 ~ F10 per-frame offsets in exact px relative to proven R4 skeleton.
# keypoints list each delta (x,y) for left/right hips knees feet.
stages=[
 ("ready",        (0,0),    (0,0),    (0,0),   (0,0),    (0,0),  (0,0)),
 ("compress",     (-.6,.9), (.4,.9), (-1.0,.8),(.5,.5),   (0,0),  (0,0)),
 ("coil",         (-1.0,1.3),(.7,1.0),(-1.7,1.1),(1.1,.8),(-.4,.1),(.1,0)),
 ("deep_coil",    (-1.2,1.5),(.8,1.2),(-2.1,1.3),(1.6,.8),(-.5,0),(.2,0)),
 ("load_and_hold",(-1.0,1.3),(.7,1.1),(-1.8,1.0),(1.5,.6),(-.3,0),(.3,0)),
 ("push_off",     ( .8,.5),(-.6,.2),(1.2,.3), (-1.0,-.2),(1.0,.3),(-.8,-.4)),
 ("contact_lunge",(1.6,.5),(-.9,.1),(2.0,.9), (-1.4,-.3),(2.1,.7),(-1.5,-.8)),
 ("follow_through",(1.4,.7),(-.5,.2),(1.6,1.0),(-.8,.1),(1.8,.8),(-1.0,-.5)),
 ("recovery",     (.7,.4),(-.3,.3),(.8,.6), (-.5,.3),(.8,.4),(-.5,-.2)),
 ("reset",        (.2,.1),(-.1,.1),(.3,.2),(-.2,.1),(.2,.1),(-.1,0))
]
names=["LEFT HIP","RIGHT HIP","LEFT KNEE","RIGHT KNEE","LEFT LEG","RIGHT LEG"]
report=[]
for index,(label,*deltas) in enumerate(stages):
 f=template["keypoints"][index]
 orig={x["label"]:dict(x) for x in f}
 by={x["label"]:x for x in f}
 for name,(dx,dy) in zip(names,deltas):
  v=by[name]
  v["x"]=round(orig[name]["x"]+dx/64,6)
  v["y"]=round(orig[name]["y"]+dy/64,6)
 for face_or_upper in ["NOSE","NECK","LEFT EYE","RIGHT EYE","LEFT EAR","RIGHT EAR","LEFT SHOULDER","RIGHT SHOULDER","LEFT ELBOW","RIGHT ELBOW","LEFT ARM","RIGHT ARM"]:
  assert by[face_or_upper]==orig[face_or_upper],(index,face_or_upper)
 for name in names:
  assert 0<by[name]["x"]<1 and 0<by[name]["y"]<1
 for a,b in [("LEFT HIP","LEFT KNEE"),("RIGHT HIP","RIGHT KNEE"),("LEFT KNEE","LEFT LEG"),("RIGHT KNEE","RIGHT LEG")]:
  d=64*math.dist((by[a]["x"],by[a]["y"]),(by[b]["x"],by[b]["y"]))
  assert 1.0<d<6.5,(index,a,b,d)
 report.append({"f":index+1,"phase":label,"absolute_keypoints_px":{k:[round(by[k]["x"]*64,2),round(by[k]["y"]*64,2)] for k in names},
                "delta_keypoints_px":{k:list(delta) for k,delta in zip(names,deltas)}})
# Prompt addresses clearly readable leg action and preserves actor identity.
template["action"]="fantasy swordsman grounded lunge attack: hips drop into squat on anticipation, left knee bends visibly, rear right leg pushes off the ground, front left boot steps forward at impact, rear boot pivots, then both legs recover to neutral; torso upper body held stable, no sword in image"
template["description"]="identical approved white spiky-haired chibi swordsman, dark teal armor with golden shoulder trim, original stable face and original upper-body pose; clearly visible distinct dark boots and two bending legs, 45 degree southeast view, dramatic but natural lower-body weight transfer with pelvis dropping and feet stepping; full continuous anatomically attached pixel-art silhouette, transparent background, EMPTY HANDS with invisible sword, absolutely NO drawn swords or weapons"
template["seed"]=171120
assert template["direction"]=="south-east" and template["view"]=="low top-down"
path=p/"A52_LOWER_BODY_ANIMATION_V3_REQUEST_NO_TOKEN.json"
path.write_text(json.dumps(template,ensure_ascii=False,indent=2),encoding="utf8")
img=Image.open(src/"R2_ORIGINAL_PIXEL_LAB_PROVENANCE/A49_ACTOR01_A62_CANONICAL_F0_64.png").convert("RGBA")
preview=Image.new("RGB",(5*320,2*320),(35,39,43))
drawer=ImageDraw.Draw(preview)
edges=[("LEFT HIP","LEFT KNEE"),("RIGHT HIP","RIGHT KNEE"),("LEFT KNEE","LEFT LEG"),("RIGHT KNEE","RIGHT LEG"),("LEFT HIP","RIGHT HIP"),("LEFT SHOULDER","LEFT HIP"),("RIGHT SHOULDER","RIGHT HIP")]
for i,f in enumerate(template["keypoints"]):
 bx=(i%5)*320;by=(i//5)*320
 bg=Image.new("RGBA",(64,64),(35,39,43,255));bg.alpha_composite(img)
 preview.paste(bg.convert("RGB").resize((320,320),Image.Resampling.NEAREST),(bx,by))
 pts={j["label"]:(round(bx+j["x"]*320),round(by+j["y"]*320)) for j in f}
 for a,b in edges:drawer.line((pts[a],pts[b]),fill=(255,181,40) if "LEFT" in a else (71,211,234),width=3)
 for leg in ["LEFT LEG","RIGHT LEG"]:
  x,y=pts[leg];drawer.ellipse((x-5,y-5,x+5,y+5),fill=(250,229,94) if leg.startswith("LEFT") else (84,225,246))
 drawer.rectangle((bx,by,bx+319,by+22),fill=(22,27,30))
 drawer.text((bx+5,by+5),"F%02d %s"%(i+1,stages[i][0]),fill=(255,255,255))
preview.save(p/"A52_TRUE_18_JOINT_LEG_TRAJECTORY_5X.png")
qa={"source":"Approved A50 R4 exact 18-joint provider request","new_phase_count":10,
 "upper_body_12_joint_values_exactly_frozen":True,"lower_body_modified_six_joint_values":True,
 "visible_front_foot_step_contact_px":stages[6][5][0],"visible_rear_foot_push_px":stages[6][6][0],
 "native_engine":"PENDING","provider_usage":"PENDING","request_SHA256":hashlib.sha256(path.read_bytes()).hexdigest(),
 "details":report}
(p/"A52_18_JOINT_AUTHORING_PREFLIGHT_QA.json").write_text(json.dumps(qa,ensure_ascii=False,indent=2),encoding="utf8")
print("A52_TRUE_18_JOINT_LOWER_BODY_READY",qa["request_SHA256"],"front-step",stages[6][5],"back-pivot",stages[6][6],flush=True)