"""FS V3 isolated real Game.exe RGSS2 native map+actor test.
Copies an existing authenticated VX test harness, then injects NEW Master-first Ground/Par
and an ACTUAL Map050.rvdata tile-table generated from V3 draft collision JSON.
Never modifies source project. Run on user's authorized Windows test machine.
"""
from pathlib import Path
import json,hashlib,shutil,struct,zlib,subprocess,time,re,ctypes,ctypes.wintypes as wint
import numpy as np
from PIL import Image,ImageGrab,ImageChops,ImageDraw
from rubymarshal.reader import loads
from rubymarshal.writer import writes

D=Path('G:/我的雲端硬碟/FS_MASTER_FIRST_V3_NATIVE_20261107')
P=Path(r'E:\FS_AGENT_SKILLS_PILOT_20261106')
SRC=Path(r'E:\FS_AI_STUDIO_PILOT_20261104_R2\VX_NATIVE_SWITCH203_TEST')
OUT=P/'FS_MASTER_FIRST_V3_NATIVE_R1_20261107'
CLONE=OUT/'VX_NATIVE_MASTER_FIRST_V3'
if OUT.exists():raise SystemExit('FAIL-CLOSED V3 destination already exists')
OUT.mkdir(parents=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
sourcefiles=['Data/Scripts.rvdata','Data/Map050.rvdata','Overlays/ground50.png','Overlays/Par50.png']
original={s:sha(SRC/s) for s in sourcefiles}
master=D/'VX_RUNTIME_FULL_GROUND_MASTER_1280x928.png'
par=D/'VX_RUNTIME_4OBJECT_PAR_C2_SOURCE_RGB_UNVERIFIED.png'
q=json.loads((D/'FS_MASTER_FIRST_V3_PROBE_PLAN_QA.json').read_text('utf8'))
grid=json.loads((D/'FS_MASTER_FIRST_V3_COLLISION_GRID_29x40.json').read_text('utf8'))
blocked=grid['blocked']
assert len(blocked)==29 and all(len(row)==40 for row in blocked)
assert sum(map(sum,blocked))==370
assert sha(master)==q['source_master_sha256']
M=np.asarray(Image.open(master).convert('RGB')); A=np.asarray(Image.open(par).convert('RGBA'))
assert M.shape==(928,1280,3) and A.shape==(928,1280,4)
assert np.array_equal(M[A[:,:,3]>0],A[A[:,:,3]>0,:3])
shutil.copytree(SRC,CLONE)
shutil.copy2(master,CLONE/'Overlays/ground50.png')
shutil.copy2(par,CLONE/'Overlays/Par50.png')
assert sha(CLONE/'Overlays/ground50.png')==sha(master)
assert sha(CLONE/'Overlays/Par50.png')==sha(par)
# Real VX map Table serialization in cloned Map050, not monkey-patched engine passability.
mfile=CLONE/'Data/Map050.rvdata'
mo=loads(mfile.read_bytes());tab=mo.attributes['@data'];raw=tab._private_data
dims=struct.unpack('<5I',raw[:20]);assert dims==(3,40,29,3,3480),dims
vals=list(struct.unpack('<3480H',raw[20:]))
assert set(vals[2320:])=={768,769} and all(v==0 for v in vals[:2320])
changed=0
for y in range(29):
 for x in range(40):
  i=2320+x+y*40
  tile=768 if blocked[y][x] else 769
  changed+=int(vals[i]!=tile);vals[i]=tile
tab._private_data=struct.pack('<5I',*dims)+struct.pack('<3480H',*vals)
mfile.write_bytes(writes(mo))
new=struct.unpack('<3480H',loads(mfile.read_bytes()).attributes['@data']._private_data[20:]);assert tuple(vals)==new
print('MAP050_NATIVE_DATA_WRITTEN: cells=1160, changed_from_old',changed,flush=True)

# Actor plans checked against draft collision; roof probes intentionally blocked/no gameplay validity.
dyn=[('LEFT_TREE_EXIT',10,16,2,'WALKABLE_POSITIVE'),('LOWER_RIGHT_TREE_EXIT',33,24,4,'WALKABLE_POSITIVE'),
     ('CLEAR_NEGATIVE',20,15,2,'WALKABLE_NEGATIVE'),('LEFT_HOUSE_ROOF_GEOMETRY_ONLY',6,5,0,'BLOCKED_ENGINE_ONLY'),
     ('RIGHT_HOUSE_ROOF_GEOMETRY_ONLY',27,5,0,'BLOCKED_ENGINE_ONLY')]
for label,x,y,d,kind in dyn:
 if d:
  nx=x+(d==6)-(d==4);ny=y+(d==2)-(d==8)
  assert blocked[y][x]==0 and blocked[ny][nx]==0,(label,'invalid move candidate')
 else:assert blocked[y][x]==1,(label,'roof test position must be BLOCKED')

scripts=loads((CLONE/'Data/Scripts.rvdata').read_bytes())
ruby=zlib.decompress(scripts[483][2]).decode('utf8')
assert ruby.count('slot=(@a36f_frame-1)/frame_step')==1
assert ruby.count('    @a36f_frame+=1')==1
ruby=ruby.replace('slot=(@a36f_frame-1)/frame_step','slot=999')
case_lit='['+', '.join('["%s",%d,%d,%d]'%(name,x,y,d) for name,x,y,d,_ in dyn)+']'
script=f'''
    # FS Master-first V3 actual native 40x29 collision + switch203 integration.
    if @a36f_frame==18
      $game_player.moveto(0,21)
      $game_player.transparent=true
      A36G_MAP.log("M3_BEGIN_GRID map="+$game_map.map_id.to_s+" width="+$game_map.width.to_s+" height="+$game_map.height.to_s)
      (0...29).each do |ty|
        tile_row=""; edge_row=""
        (0...40).each do |tx|
          begin
            tile_row += ($game_player.passable?(tx,ty) ? "1" : "0")
            [[0,1],[-1,0],[1,0],[0,-1]].each do |vec|
              ux=tx+vec[0];uy=ty+vec[1]
              if ux<0 || ux>=40 || uy<0 || uy>=29
                edge_row+="X"
              else
                edge_row+=($game_player.move_passable?(tx,ty,ux,uy) ? "1" : "0")
              end
            end
          rescue => e
            tile_row+="?";edge_row+="????"
            A36G_MAP.log("M3_ERROR_GRID at="+tx.to_s+","+ty.to_s+" msg="+e.message.to_s)
          end
        end
        A36G_MAP.log("M3_GRID_TILE row="+ty.to_s+" value="+tile_row)
        A36G_MAP.log("M3_GRID_EDGE row="+ty.to_s+" value="+edge_row)
      end
      A36G_MAP.log("M3_END_GRID")
    end
    fs_cases={case_lit}
    fs_age=(@a36f_frame-1)-300
    fs_span=210
    fs_idx=fs_age/fs_span
    fs_phase=fs_age%fs_span
    if fs_age>=0 && fs_idx<fs_cases.size
      label,xx,yy,dd=fs_cases[fs_idx]
      if fs_phase==0
        $game_switches[203]=false
        $game_player.moveto(xx,yy)
        $game_player.transparent=false
        A36G_MAP.log("M3_BEGIN case="+label+" tile="+xx.to_s+","+yy.to_s)
      elsif fs_phase==35 || fs_phase==90 || fs_phase==150 || fs_phase==183
        sp=$OverlayMap.instance_variable_get(:@par)
        ss=(fs_phase==35 ? "OFF" : fs_phase==90 ? "ON" : fs_phase==150 ? "END_OFF" : "END_ON")
        A36G_MAP.log("M3_SHOT case="+label+" state="+ss+" pos="+$game_player.x.to_s+","+$game_player.y.to_s+" display="+$game_map.display_x.to_s+","+$game_map.display_y.to_s+" sprite="+(!sp.nil?).to_s+" par_visible="+(sp && sp.visible).to_s)
      elsif fs_phase==52 || fs_phase==169
        $game_switches[203]=true
      elsif fs_phase==117
        bx=$game_player.x;by=$game_player.y
        if dd!=0
          dx=bx+(dd==6 ? 1 : dd==4 ? -1 : 0)
          dy=by+(dd==2 ? 1 : dd==8 ? -1 : 0)
          legal=$game_player.move_passable?(bx,by,dx,dy)
          case dd
          when 2;$game_player.move_down
          when 4;$game_player.move_left
          when 6;$game_player.move_right
          when 8;$game_player.move_up
          end
          A36G_MAP.log("M3_MOVE case="+label+" before="+bx.to_s+","+by.to_s+" after="+$game_player.x.to_s+","+$game_player.y.to_s+" passable="+legal.to_s)
        else
          A36G_MAP.log("M3_NO_MOVE case="+label+" roof_tile_blocked_engine_only")
        end
      elsif fs_phase==126
        $game_switches[203]=false
      end
    elsif fs_age>=0 && fs_idx==fs_cases.size && fs_phase==0
      A36G_MAP.log("M3_ALL_DONE")
    end
'''
ruby=ruby.replace('    @a36f_frame+=1','    @a36f_frame+=1\n'+script)
scripts[483][2]=zlib.compress(ruby.encode('utf8'))
(CLONE/'Data/Scripts.rvdata').write_bytes(writes(scripts))
log=CLONE/'A36G_VX_ACTUAL_FULL_MAP.log'
if log.exists():log.unlink()
# Capture only real RGSS Player window, never composite simulator.
u=ctypes.windll.user32
CB=ctypes.WINFUNCTYPE(wint.BOOL,wint.HWND,wint.LPARAM)
def windows(pid):
 out=[]
 def cb(h,lp):
  p=wint.DWORD();u.GetWindowThreadProcessId(h,ctypes.byref(p))
  if p.value==pid and u.IsWindowVisible(h):
   n=ctypes.create_unicode_buffer(100);u.GetClassNameW(h,n,99);out.append((int(h),n.value))
  return True
 u.EnumWindows(CB(cb),0)
 return out
screens={};events=[];modal=[];completed=False;done_grid=False;running=None
try:
 running=subprocess.Popen([str(CLONE/'Game.exe')],cwd=str(CLONE))
 start=time.monotonic();seen=0
 while time.monotonic()-start<125:
  time.sleep(.13)
  ws=windows(running.pid)
  if any(cls=='#32770' for h,cls in ws):
   modal=ws;print('MODAL',ws,flush=True);break
  if running.poll() is not None:
   print('VX_EXIT',running.returncode,flush=True);break
  if not log.exists():continue
  lines=log.read_text('utf8',errors='replace').splitlines()
  new=lines[seen:];seen=len(lines)
  for line in new:
   if not line.startswith('M3_'):continue
   events.append(line)
   if line.startswith('M3_END_GRID'):done_grid=True
   if line.startswith('M3_ALL_DONE'):completed=True
   mt=re.search(r'M3_SHOT case=(\S+) state=(OFF|ON|END_OFF|END_ON) pos=(\d+),(\d+) display=(\d+),(\d+) sprite=(\w+) par_visible=(\w+)',line)
   if mt:
    name,state,ax,ay,cx,cy,sp,v=mt.groups()
    info={'actor_tile':[int(ax),int(ay)],'display_raw':[int(cx),int(cy)],'par_visible':v=='true','sprite_present':sp=='true','capture_ok':False}
    hwnd=next((h for h,cls in ws if cls=='RGSS Player'),None)
    if hwnd:
     image=ImageGrab.grab(window=hwnd).convert('RGB')
     if image.size==(544,416):
      dest=OUT/(f'M3_{name}_{state}.png');image.save(dest)
      info.update({'capture_ok':True,'file':dest.name,'sha256':sha(dest)})
    screens.setdefault(name,{})[state]=info
    print('NATIVE_SHOT',name,state,'pos',ax,ay,'captured',info['capture_ok'],'par_visible',info['par_visible'],flush=True)
   if line.startswith('M3_MOVE '):print('NATIVE_MOVE',line,flush=True)
  if completed and done_grid and all(len(screens.get(n,{}))==4 for n,*_ in dyn):break
finally:
 if running and running.poll() is None:
  running.terminate()
  try:running.wait(timeout=5)
  except subprocess.TimeoutExpired:running.kill()
changed_original={k:sha(SRC/k)==v for k,v in original.items()}
raw='\n'.join(events)
# Independent runtime audit (not trusting generated collision spec): parse engine emitted tile+directed-edge outputs.
tile_rows={};edge_rows={};moves={}
for line in events:
 t=re.search(r'M3_GRID_(TILE|EDGE) row=(\d+) value=([01X?]+)',line)
 if t:
  (tile_rows if t.group(1)=='TILE' else edge_rows)[int(t.group(2))]=t.group(3)
 m=re.search(r'M3_MOVE case=(\S+) before=(\d+),(\d+) after=(\d+),(\d+) passable=(\w+)',line)
 if m:
  name,bx,by,ax,ay,passing=m.groups()
  moves[name]={'before':[int(bx),int(by)],'after':[int(ax),int(ay)],'passable':passing=='true'}
errors=[];edgecheck=0;cellcheck=0;miss=[]
vectors=[(0,1),(-1,0),(1,0),(0,-1)]
for y in range(29):
 if y not in tile_rows or y not in edge_rows:continue
 if len(tile_rows[y])!=40 or len(edge_rows[y])!=160:
  errors.append(f'rowlength_{y}');continue
 for x in range(40):
  expected=not bool(blocked[y][x]);got=tile_rows[y][x]=='1'
  cellcheck+=1
  if got!=expected:miss.append(['cell',x,y,expected,got])
  for k,(dx,dy) in enumerate(vectors):
   nx,ny=x+dx,y+dy
   if not 0<=nx<40 or not 0<=ny<29:continue
   expected_edge=not blocked[y][x] and not blocked[ny][nx]
   actual=edge_rows[y][x*4+k]=='1'
   edgecheck+=1
   if actual!=expected_edge:miss.append(['edge',x,y,dx,dy,expected_edge,actual])
# Native screenshots: unaltered in-game render for OFF+ON, fail closed on camera drift or misplaced actor.
results={};sheet=Image.new('RGB',(1088,len(dyn)*450),(25,26,30));draw=ImageDraw.Draw(sheet)
for i,(name,x,y,dr,kind) in enumerate(dyn):
 s=screens.get(name,{})
 n=[];recomposed={}
 for a,bstate in [('OFF','ON'),('END_OFF','END_ON')]:
  aa,bb=s.get(a,{}),s.get(bstate,{})
  detail={'screens_ok':aa.get('capture_ok') and bb.get('capture_ok'),'camera_fixed':aa.get('display_raw')==bb.get('display_raw') if aa and bb else False,
          'actual_actor_same':aa.get('actor_tile')==bb.get('actor_tile') if aa and bb else False,
          'switch_real':aa.get('par_visible') is False and bb.get('par_visible') is True if aa and bb else False}
  if detail['screens_ok']:
   p1=Image.open(OUT/aa['file']).convert('RGB');p2=Image.open(OUT/bb['file']).convert('RGB')
   delta=ImageChops.difference(p1,p2)
   bbox=delta.getbbox();count=int(np.any(np.asarray(delta)!=0,axis=2).sum())
   detail.update({'changed_pixels':count,'bbox':list(bbox) if bbox else None,'actor_local_bbox':bbox is None or (bbox[2]-bbox[0]<=64 and bbox[3]-bbox[1]<=64)})
   if a=='OFF':
    sheet.paste(p1,(0,i*450+32));sheet.paste(p2,(544,i*450+32))
   recomposed[a]=detail
  else:detail.update({'changed_pixels':None,'bbox':None,'actor_local_bbox':False})
  n.append(detail)
 move=moves.get(name)
 expected_end=([x+(dr==6)-(dr==4),y+(dr==2)-(dr==8)] if dr else [x,y])
 movement_correct=(move is not None and move['before']==[x,y] and move['after']==expected_end and move['passable']) if dr else move is None
 # Tests on house rooftops are geometric, cannot be a positive gameplay gate.
 detail={'kind':kind,'tile':[x,y],'end_tile':expected_end,'overlap_before_after':None,
         'native_move':move,'native_movement_valid':movement_correct,
         'start_off_on':n[0],'end_off_on':n[1]}
 render_pass=all(z['screens_ok'] and z['camera_fixed'] and z['actual_actor_same'] and z['switch_real'] and z['actor_local_bbox'] for z in n)
 if kind=='WALKABLE_POSITIVE':
  changed0=n[0]['changed_pixels'];changed1=n[1]['changed_pixels']
  detail['gate']='PASS' if render_pass and movement_correct and changed0 is not None and changed0>=120 and changed1 is not None and changed1<changed0*.45 else 'FAIL'
 elif kind=='WALKABLE_NEGATIVE':
  detail['gate']='PASS' if render_pass and movement_correct and n[0]['changed_pixels']==0 and n[1]['changed_pixels']==0 else 'FAIL'
 else:detail['gate']='ENGINE_ONLY' if render_pass and (n[0]['changed_pixels'] or 0)>80 else 'ENGINE_FAIL'
 results[name]=detail
 draw.text((10,i*450+10),f'{name} {detail["gate"]}',fill='white')
 print('NATIVE_RESULT',name,detail['gate'],n[0]['changed_pixels'],n[1]['changed_pixels'],flush=True)
sheet.save(OUT/'M3_NATIVE_5_CASES_OFF_ON_544x416_CONTACT.png')
report={'stage':'FS_MASTER_FIRST_V3_TRUE_NATIVE_RGSS2',
 'authoritative_master_sha':sha(master), 'authoritative_par_sha':sha(par),
 'original_test_engine_file_shas_unchanged':changed_original,
 'isolated_clone':str(CLONE),'native_map050_rebuilt_from_v3_collision':True,
 'native_map50_real_tile_id_map':{'blocked':768,'free':769},
 'native_grid_checked_tiles':cellcheck, 'native_grid_checked_edges':edgecheck,
 'native_grid_mismatches':miss[:80], 'native_grid_error_count':len(miss)+len(errors),
 'native_grid_GATE':'PASS' if done_grid and cellcheck==1160 and edgecheck==((40-1)*29*2+(29-1)*40*2) and not miss and not errors else 'FAIL',
 'completed_all_cases':completed, 'modal_errors':modal, 'cases':results,
 'native_canopy_dynamic_GATE':'PASS' if all(results[n]['gate']=='PASS' for n in ['LEFT_TREE_EXIT','LOWER_RIGHT_TREE_EXIT','CLEAR_NEGATIVE']) else 'FAIL',
 'roof_collision_semantics':'BLOCKED; roof 203 is engine-only, no walking pass',
 'full_collision_art_semantics':'UNVERIFIED', 'individual_pixel_silhouette':'UNVERIFIED',
 'full_scene_completePAR':'NOT COMPLETE', 'formal_seal':'NO',
 'events':events}
(OUT/'M3_NATIVE_QA_REPORT.json').write_text(json.dumps(report,indent=2,ensure_ascii=False),encoding='utf8')
print('FINAL_NATIVE',json.dumps({k:report[k] for k in ['native_grid_GATE','native_grid_checked_tiles','native_grid_checked_edges','native_grid_error_count','native_canopy_dynamic_GATE','completed_all_cases','formal_seal']},ensure_ascii=False),flush=True)