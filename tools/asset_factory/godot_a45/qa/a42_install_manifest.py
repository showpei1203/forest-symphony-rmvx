from pathlib import Path
import json, hashlib
root=Path(__file__).resolve().parent.parent
manifest=root/"assets"/"actor01_animation_manifest.json"
data=json.loads(manifest.read_text("utf-8"))
profile=data["animation_profiles"]["attack_weighted"]
assert profile["sprite_sheet"] in ("res://assets/actor01_attack_weighted_sword_12frames.png","res://assets/actor01_a42_body_12frames.png")
profile["sprite_sheet"]="res://assets/actor01_a42_body_12frames.png"
profile["art_gate"]="HOLD: A42 independently editable A41-exact body, weapon, FX with 0 source pixel changes"
profile["provenance"]="A41 source pose split into Body/Weapon/FX; Godot one-clock 12-frame animation and 70ms hitstop"
data["default_profiles"]["attack"]="attack_weighted"
data["layering"]={"body":"res://assets/actor01_a42_body_12frames.png","weapon":"res://assets/actor01_a42_weapon_12frames.png","fx":"res://assets/actor01_a42_fx_12frames.png","fps":12,"contact_second":0.55,"hitstop_seconds":0.07,"animation_authority":"one Godot AnimationPlayer clock"}
manifest.write_text(json.dumps(data,ensure_ascii=False,indent=2)+"\n","utf-8")
config=root/"project.godot"
text=config.read_text("utf-8")
text=text.replace("FS A41 Weighted 12-Frame Sword Attack","FS A42 Separated Body Sword FX / Hitstop")
config.write_text(text,"utf-8")
print("A42_MANIFEST_3_LAYERS",list(data["layering"].keys()),"attack",data["default_profiles"]["attack"])