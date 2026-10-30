from pathlib import Path
import json, copy
from xml.etree import ElementTree as ET

base=Path(r"E:\GameAssetToolLab_20261023\ASF_SkillRegistry_20261030\codeart2d\examples")
out=Path(r"E:\GameAssetToolLab_20261023\ASF_Test_20261031\source")
out.mkdir(parents=True, exist_ok=True)

# One canonical SVG body and weapon hierarchy for ALL six action sets.
ET.register_namespace("","http://www.w3.org/2000/svg")
ns="{http://www.w3.org/2000/svg}"
tree=ET.parse(base/"hero.rig.svg")
root=tree.getroot()
fore=root.find(".//*[@id='fore_f']")
assert fore is not None, "Missing canonical arm bone"
weapon=ET.SubElement(fore,ns+"g",{"id":"weapon","data-pivot":"35 39","data-z":"70"})
ET.SubElement(weapon,ns+"rect",{"x":"34","y":"37","width":"5","height":"5","rx":"0.6","fill":"#75502b","stroke":"#1a1c2c","stroke-width":"0.8"})
ET.SubElement(weapon,ns+"polygon",{"points":"37,38 46,32 49,32 47,35 39,40","fill":"#c7d7dd","stroke":"#1a1c2c","stroke-width":"0.7"})
tree.write(out/"hero-six.rig.svg",encoding="utf-8",xml_declaration=True)

data=json.loads((base/"hero.anim.json").read_text(encoding="utf-8"))
data["rig"]="hero-six.rig.svg"
data["states"]={"idle":"idle","moving":"walk","running":"run","attacking":"attack","jumping":"jump","hurt":"hurt"}
clips=data["clips"]
# start from the same rig/tracks to preserve identity and weapon connection
run=copy.deepcopy(clips["walk"])
run["frames"]=8
run["duration_ms"]=75
run["tracks"]["torso"]={"rotate":[[0,13],[0.5,9],[1,13]]}
run["tracks"]["head"]={"rotate":[[0,-6],[0.5,-1],[1,-6]],"ease":"sine"}
run["tracks"]["arm_f"]={"rotate":[[0,38],[0.5,-43],[1,38]],"ease":"sine"}
run["tracks"]["arm_b"]={"rotate":[[0,-40],[0.5,39],[1,-40]],"ease":"sine"}
run["tracks"]["fore_f"]={"rotate":[[0,-16],[0.5,-28],[1,-16]],"ease":"sine"}
run["tracks"]["fore_b"]={"rotate":[[0,-33],[0.5,-13],[1,-33]],"ease":"sine"}
run["events"]=[{"t":0,"name":"step_r"},{"t":0.5,"name":"step_l"}]
clips["run"]=run

stand=copy.deepcopy(clips["idle"]["ik"])
clips["attack"]={
  "frames":7, "loop":False, "duration_ms":[110,75,70,75,90,120,140],
  "events":[{"t":0.42,"name":"hit"}],
  "tracks":{
    "torso":{"rotate":[[0,0],[0.18,-12],[0.42,15],[0.7,5],[1,0]],"translate":[[0,[0,0]],[0.25,[-1,0]],[0.45,[2,0]],[1,[0,0]]]},
    "head":{"rotate":[[0,0],[0.4,-8],[0.7,3],[1,0]]},
    "arm_f":{"rotate":[[0,0],[0.2,-85],[0.46,68],[0.7,24],[1,0]]},
    "fore_f":{"rotate":[[0,0],[0.2,-20],[0.46,55],[0.7,13],[1,0]]},
    "arm_b":{"rotate":[[0,0],[0.3,-25],[0.6,12],[1,0]]}
  }, "ik":copy.deepcopy(stand)
}
clips["jump"]={
  "frames":9, "loop":False, "grounded":False,"duration_ms":[80,80,90,95,100,100,90,85,100],
  "events":[{"t":0.10,"name":"custom:takeoff"},{"t":0.78,"name":"custom:landing"}],
  "tracks":{
    "hips":{"translate":[[0,[0,0]],[0.125,[0,1]],[0.3,[0,-6]],[0.5,[0,-8]],[0.65,[0,-8]],[0.88,[0,-1]],[1,[0,0]]]},
    "torso":{"rotate":[[0,0],[0.2,-7],[0.5,0],[0.8,5],[1,0]]},
    "arm_f":{"rotate":[[0,0],[0.2,-25],[0.5,-55],[0.8,10],[1,0]]},
    "arm_b":{"rotate":[[0,0],[0.2,23],[0.5,45],[1,0]]},
    "thigh_f":{"rotate":[[0,0],[0.3,30],[0.65,25],[1,0]]},
    "thigh_b":{"rotate":[[0,0],[0.3,-27],[0.65,-18],[1,0]]},
    "shin_f":{"rotate":[[0,0],[0.35,-36],[0.7,-18],[1,0]]},
    "shin_b":{"rotate":[[0,0],[0.35,35],[0.7,10],[1,0]]}
  }
}
clips["hurt"]={
  "frames":6, "loop":False,"duration_ms":[100,65,90,110,110,125],
  "tracks":{
    "torso":{"rotate":[[0,0],[0.2,-17],[0.5,-11],[1,0]],"translate":[[0,[0,0]],[0.25,[-2,0]],[0.6,[-1,0]],[1,[0,0]]]},
    "head":{"rotate":[[0,0],[0.28,12],[0.65,6],[1,0]]},
    "arm_f":{"rotate":[[0,0],[0.25,-37],[0.7,-15],[1,0]]},
    "arm_b":{"rotate":[[0,0],[0.25,26],[0.7,12],[1,0]]}
  }, "ik":copy.deepcopy(stand)
}
(out/"six-actions.anim.json").write_text(json.dumps(data,ensure_ascii=False,indent=2)+"\n",encoding="utf-8")
print("CREATED",out/"hero-six.rig.svg",out/"six-actions.anim.json","CLIPS",list(data["clips"]))
