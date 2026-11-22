from pathlib import Path
from PIL import Image,ImageDraw
import hashlib,json,zipfile
R=Path(r'E:\LPC_Original_20261121')
D=R/'FS_R18_ACTOR01_HANDDRAWN_BOXING_45';N=D/'native_godot472_60Hz'
m=json.loads((D/'R18_MANIFEST.json').read_text(encoding='utf8'))
n=json.loads((N/'R18_NATIVE_QA.json').read_text(encoding='utf8'))
assert n['frames']==73 and n['visited']==list(range(12)) and n['contact_events']==1
assert n['engine']['major']==4 and n['engine']['minor']==7 and n['engine']['patch']==2
src=Image.open(D/'R18_ACTOR01_BODY_12X64.png').convert('RGBA')
for name in ('WEAPON','FX'):
 assert Image.open(D/f'R18_ACTOR01_{name}_ALPHA_ZERO.png').convert('RGBA').getbbox() is None
starts={}
for t in n['timeline']:starts.setdefault(t['frame'],t['tick'])
poses=[];mism=[]
for i in range(12):
 p=Image.open(N/f'{starts[i]:03d}.png').convert('RGBA')
 s=src.crop((i%4*64,i//4*64,(i%4+1)*64,(i//4+1)*64))
 mism.append(sum(a!=b for a,b in zip(p.tobytes(),s.tobytes())))
 poses.append(p)
assert mism==[0]*12,mism
old=Image.open(R/'FS_R17_ACTOR01_EIGHTDIR_TWO_JOINT_UNARMED_45'/'R17_ACTOR01_8DIR_TWO_JOINT_UNARMED_BODY.png').convert('RGBA')
board=Image.new('RGBA',(2048,840),(18,22,26,255));dr=ImageDraw.Draw(board)
for i,p in enumerate(poses):
 x=i%4*512;y=i//4*280
 o=old.crop((i%4*64,i//4*64,(i%4+1)*64,(i//4+1)*64))
 board.alpha_composite(o.resize((256,256),Image.Resampling.NEAREST),(x,y+18))
 board.alpha_composite(p.resize((256,256),Image.Resampling.NEAREST),(x+256,y+18))
 dr.text((x+2,y+2),f'F{i:02d} R17 REJECTED',fill=(243,243,243))
 dr.text((x+258,y+2),'R18B REJECTED',fill=(243,243,243))
board.convert('RGB').save(D/'R17_VS_R18B_12POSES_4X.png')
anim=[]
for i in range(73):
 p=Image.open(N/f'{i:03d}.png').convert('RGBA').resize((256,256),Image.Resampling.NEAREST)
 b=Image.new('RGBA',(256,256),(18,22,26,255));b.alpha_composite(p);anim.append(b.convert('RGB'))
anim[0].save(D/'R18B_GODOT_NATIVE_73FRAMES_60HZ.gif',save_all=True,append_images=anim[1:],duration=17,loop=0,optimize=True)
qa={'status':'ENGINE_PASS_ART_REJECTED','native_frames':73,'fps':60,'source_gpu_mismatch':mism,'F7_visual_event_once':True,'body_sha':m['body_sha256'],'full_fs_battle':'NOT_RUN','art_objections':['R18 legs/boots simplified and stiff','F7 upper arm elongated and lacks shoulder chest torque','Full-body motion and native 1x expression do not pass'] }
(D/'R18B_FINAL_QA_ART_REJECTED.json').write_text(json.dumps(qa,indent=2),encoding='utf8')
(D/'README_R18B_REJECTED.md').write_text('R18B actual redraw and Godot original native capture, but ART REJECTED. Retained exact A62 face pixels. Source-only editor QA != art accept. R18A F0/F11 foot-index seam failure repaired. Second R18B diagonal arm route still fails natural boxing silhouette. No full live FSBattle, no paid PixelLab. Do not ship.\n',encoding='utf8')
incl=['R18_ACTOR01_BODY_12X64.png','R18_ACTOR01_WEAPON_ALPHA_ZERO.png','R18_ACTOR01_FX_ALPHA_ZERO.png','R18_MANIFEST.json','R18B_FINAL_QA_ART_REJECTED.json','R18_NATIVE_KEYPOSES_1X.png','R18_NATIVE_KEYPOSES_4X.png','R17_VS_R18B_12POSES_4X.png','R18_KEYPOSE_PREVIEW.gif','R18B_GODOT_NATIVE_73FRAMES_60HZ.gif','R18A_REJECTED_4X.png','R18A_REJECTED_BODY.png','README_R18B_REJECTED.md','capture_r18_native.gd','native_godot472_60Hz/R18_NATIVE_QA.json','native_godot472_60Hz/godot_log.txt','godot_project/project.godot','godot_project/tests/capture_r18_native.gd']
zp=D/'FS_TA_R18B_ART_REJECTED_FULL_QA_20261122.zip'
with zipfile.ZipFile(zp,'w',zipfile.ZIP_DEFLATED) as z:
 for p in incl:z.write(D/p,p)
 for i in range(73):z.write(N/f'{i:03d}.png',f'native/{i:03d}.png')
 z.write(R/'FS_R18_ACTOR01_KEYPOSE_REDRAW.py','source/FS_R18_ACTOR01_KEYPOSE_REDRAW.py')
with zipfile.ZipFile(zp) as z:
 assert z.testzip() is None
 count=len(z.namelist())
assert count==92,count
print(json.dumps({'zip_size':zp.stat().st_size,'zip_sha':hashlib.sha256(zp.read_bytes()).hexdigest(),'members':count,'status':qa['status']},ensure_ascii=True))
