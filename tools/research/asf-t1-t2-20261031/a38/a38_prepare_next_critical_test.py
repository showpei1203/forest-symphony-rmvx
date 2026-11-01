from pathlib import Path
B=Path(r"E:\GameAssetToolLab_20261023")
src=B/"A38_DAMAGE_F1_NATIVE_45_IMAGE_EDIT_20261101"/"a38_native_battle_damage_f1_edit.py"
dst=B/"A39_CRITICAL_DAMAGE_NATIVE45_20261101"
dst.mkdir(parents=True,exist_ok=True)
s=src.read_text(encoding="utf8")
s=s.replace("A38_DAMAGE_F1_NATIVE_45_IMAGE_EDIT_20261101","A39_CRITICAL_DAMAGE_NATIVE45_20261101")
s=s.replace("A38","A39").replace('"DAMAGE"','"CRITICAL_DAMAGE"')
s=s.replace("38110101","39110106")
a=s.index("txt=(");b=s.index('\n(R/"A39_DAMAGE_F1_EDIT_PROMPT.txt")',a)
prompt="""txt=("ONE SINGULAR SEVERE CRITICAL DAMAGE HIT FRAME, use the PROVIDED genuine Forest Symphony "
"white-haired 1:1 chibi 45-degree SE three-quarter battle-facing sprite as the exact design authority. "
"Show a dramatically stronger whole-body stagger than ordinary Damage: knees collapse much deeper, "
"hips sink, torso recoils backward diagonally and curls, both EMPTY hands rise defensively around chest, "
"head tilts BACK while retaining BOTH visible eye and face planes in the SAME 45 degree camera, "
"eyes tightly shut and mouth open in pain. Keep the character centered and boots near the original "
"ground line; no sideways translation or magical floating. This is the MOMENT OF HEAVY IMPACT. "
"Same detailed white spiky hair, same dark teal gold-accent armor, small 1:1 body, leg/shoulder "
"proportions, no new body parts. Explicitly forbid pure SIDE profile, no 90-degree single-eye face; "
"shoulders, chest and hips must stay aligned to diagonal camera. No sword, hilt, sheath, shield, "
"bow, projectile, glow, spell effect or text. ONE transparent native 40x40 pixel-art character, "
"crisp grid and coherent anatomy. Do not pose as Idle, Walking or Dodging.")"""
s=s[:a]+prompt+s[b:]
s=s.replace('comparison":"A37 C F1 side-facing FAIL, must NOT use as source"','comparison":"A37 C F1 90deg FAIL; A38 normal Damage reference, critical should be stronger"')
file=dst/"a39_critical_damage_native_image_edit.py"
file.write_text(s,encoding="utf8")
assert "CRITICAL_DAMAGE" in s and "A39" in s
print(file,len(s))
