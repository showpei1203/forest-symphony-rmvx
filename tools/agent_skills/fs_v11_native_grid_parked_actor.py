"""V10 exhaustive read-only native RGSS2 40x29 tile + directed-edge passability audit."""
from pathlib import Path
from rubymarshal.reader import loads
from rubymarshal.writer import writes
import hashlib,json,subprocess,time,shutil,zlib,re
ROOT=Path(r"E:\FS_AGENT_SKILLS_PILOT_20261106\validation_v8")
ROOT.mkdir(exist_ok=True,parents=True)
SRC=Path(r"E:\FS_AI_STUDIO_PILOT_20261104_R2\VX_NATIVE_SWITCH203_TEST")
SCENE=Path(r"E:\FS_STAGE16_A36F_ELF_FOREST_REWORK_20261103\A36F_SCENE_MANIFEST.json")
DEST=ROOT/"VX_NATIVE_40x29_COLLISION_GRID_PROBE"
if DEST.exists():raise RuntimeError("REFUSED: preexisting isolated clone")
manifest=json.loads(SCENE.read_text(encoding="utf8"))
blocked=manifest["collision_map_29x40"]
assert len(blocked)==29 and all(len(row)==40 for row in blocked)
assert blocked[6][3]==1, "Parking tile must be blocked in manifest"
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
protected=["Data/Scripts.rvdata","Data/Map050.rvdata","Overlays/Par50.png","Overlays/ground50.png"]
baseline={n:sha(SRC/n) for n in protected}
shutil.copytree(SRC,DEST)
scriptfile=DEST/"Data/Scripts.rvdata"
scripts=loads(scriptfile.read_bytes())
ruby=zlib.decompress(scripts[483][2]).decode("utf8")
assert ruby.count("slot=(@a36f_frame-1)/frame_step")==1
ruby=ruby.replace("slot=(@a36f_frame-1)/frame_step","slot=999")
line="    @a36f_frame+=1"
assert ruby.count(line)==1
probe='''    if @a36f_frame==10
      # Park the tester in a known blocked cell so self-collision cannot
      # mislabel its originally passable spawn tile (20,14) as blocked.
      $game_player.moveto(3,6)
      $game_player.transparent=true
      A36G_MAP.log("V11_PROBE_PARKED_IN_BLOCKED_TILE=3,6")
      A36G_MAP.log("V11_BEGIN map="+$game_map.map_id.to_s+" width="+$game_map.width.to_s+" height="+$game_map.height.to_s)
      (0...29).each do |ty|
        tile_row=""
        edge_row=""
        (0...40).each do |tx|
          begin
            tile_row += ($game_player.passable?(tx,ty) ? "1" : "0")
            [[0,1],[-1,0],[1,0],[0,-1]].each do |vec|
              ux=tx+vec[0]
              uy=ty+vec[1]
              if ux<0 || ux>=40 || uy<0 || uy>=29
                edge_row += "X"
              else
                edge_row += ($game_player.move_passable?(tx,ty,ux,uy) ? "1" : "0")
              end
            end
          rescue => e
            A36G_MAP.log("V11_ERROR tile="+tx.to_s+","+ty.to_s+" reason="+e.class.to_s+":"+e.message.to_s)
            tile_row += "?"
            edge_row += "????"
          end
        end
        A36G_MAP.log("V11_TILE row="+ty.to_s+" value="+tile_row)
        A36G_MAP.log("V11_EDGE row="+ty.to_s+" value="+edge_row)
      end
      A36G_MAP.log("V11_DONE")
    end
'''
ruby=ruby.replace(line,line+"\n"+probe)
scripts[483][2]=zlib.compress(ruby.encode("utf8"))
scriptfile.write_bytes(writes(scripts))
assert all(sha(DEST/n)==baseline[n] for n in protected if n!="Data/Scripts.rvdata")
log=DEST/"A36G_VX_ACTUAL_FULL_MAP.log"
if log.exists():log.unlink()
proc=None;complete=False;modal=False
try:
 proc=subprocess.Popen([str(DEST/"Game.exe")],cwd=str(DEST))
 begin=time.monotonic()
 while time.monotonic()-begin < 35:
  time.sleep(.17)
  if log.exists():
   txt=log.read_text(encoding="utf8",errors="replace")
   if "V11_DONE" in txt:
    complete=True
    break
  if proc.poll() is not None:break
finally:
 if proc and proc.poll() is None:
  proc.terminate()
  try:proc.wait(timeout=5)
  except subprocess.TimeoutExpired:proc.kill()
raw=log.read_text(encoding="utf8",errors="replace") if log.exists() else ""
tiles={};edges={};errs=[]
for line in raw.splitlines():
 m=re.search(r"V11_(TILE|EDGE) row=(\d+) value=([01X?]+)",line)
 if m:
  kind,y,flags=m.groups()
  (tiles if kind=="TILE" else edges)[int(y)]=flags
 if "V11_ERROR" in line:errs.append(line)
deltas=[];ediff=[];counts={"tile_checked":0,"tile_runtime_passable":0,"edge_checked":0,"edge_runtime_passable":0,
"blocked_cells_manifest":sum(sum(row) for row in blocked)}
moves=[(0,1),(-1,0),(1,0),(0,-1)]
for y in range(29):
 if y not in tiles or y not in edges:continue
 if len(tiles[y])!=40 or len(edges[y])!=160:raise RuntimeError("bad runtime record length")
 for x in range(40):
  got=tiles[y][x]=="1"
  expected=not bool(blocked[y][x])
  counts["tile_checked"]+=1;counts["tile_runtime_passable"]+=int(got)
  if got!=expected:deltas.append({"x":x,"y":y,"manifest_passable":expected,"engine_passable":got})
  for k,(dx,dy) in enumerate(moves):
   tx,ty=x+dx,y+dy
   if not (0<=tx<40 and 0<=ty<29):continue
   # manifest binary target only; single-direction source tile rules can still diverge.
   if blocked[y][x]:continue
   flag=edges[y][x*4+k]
   if flag not in "01":continue
   result=flag=="1"
   expect=not bool(blocked[ty][tx])
   counts["edge_checked"]+=1;counts["edge_runtime_passable"]+=int(result)
   if result!=expect:
    ediff.append({"from":[x,y],"to":[tx,ty],"direction":[2,4,6,8][k],
                  "manifest_expect_move":expect,"engine_move_passable":result})
untouched=all(sha(SRC/n)==baseline[n] for n in protected)
report={"stage":"FS_AGENT_SKILLS_V11_NATIVE_COLLISION_GRID",
 "source_map":"A36F_R1_collision_manifest_40x29",
 "actual_engine":"RPG Maker VX Game.exe RGSS2 + ISS - ParaPassa",
 "runtime_completed":complete,"source_files_unchanged":untouched,
 "runtime_row_counts":{"tiles":len(tiles),"edges":len(edges)},"counts":counts,
 "tile_mismatch_count":len(deltas),"tile_mismatches":deltas,
 "edge_mismatch_count":len(ediff),"edge_mismatches":ediff,
 "runtime_errors":errs,"manifest_free_cells":manifest["free_cells"],
 "manifest_blocked_cells":manifest["blocked_cells"],
 "art_approval":"UNVERIFIED","formal_seal":"NO"}
report["tile_gate"]="PASS" if complete and untouched and len(tiles)==29 and not errs and not deltas else "FAIL"
report["directional_gate"]="PASS" if complete and untouched and len(edges)==29 and not errs and not ediff else "FAIL"
(ROOT/"FS_V11_NATIVE_COLLISION_GRID_QA.json").write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding="utf8")
print("V11_RESULT",json.dumps({"complete":complete,"tile_gate":report["tile_gate"],"directional_gate":report["directional_gate"],
"tile_mismatch_count":len(deltas),"edge_mismatch_count":len(ediff),"counts":counts,
"tile_examples":deltas[:8],"edge_examples":ediff[:8],"source_unchanged":untouched,"errors":errs[:3]},ensure_ascii=False),flush=True)