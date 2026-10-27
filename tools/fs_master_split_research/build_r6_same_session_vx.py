#!/usr/bin/env python3
"""R6 single native FS Game.exe session: static/dynamic/static same scene, all actors fixed.
Derived exclusively from the isolated R5 clone, without touching sealed K4 or R5 outputs.
Source 504 original pages preserved byte-exact; original page 480 held out as boot blocker.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import hashlib,zlib,subprocess,shutil,json
ROOT=Path(__file__).resolve().parent
BASE=ROOT/"R5_FORMAL_ADAPTER_ISOLATED"/"FULL505"
DST=ROOT/"R6_SAME_SESSION_ISOLATED"/"FULL505"
DST.parent.mkdir(exist_ok=True)
assert (BASE/"Data"/"Scripts.rvdata").is_file()
assert (BASE/"Graphics"/"Pictures"/"R5_OC_left_tree.png").is_file()
# Deliberately do not clone huge backlogs; use robocopy to preserve full VX game.
r=subprocess.run(["robocopy",str(BASE),str(DST),"/E","/R:0","/W:0","/XF","*.log","*.txt"],capture_output=True,text=True,errors="replace")
assert r.returncode<8,(r.returncode,r.stdout[-1400:])
orig=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Data\Scripts.rvdata")
assert hashlib.sha256(orig.read_bytes()).hexdigest()=="5a728530764e61d22d8c6927367d983c14e36ee37e777508d154a04a2ee7acaa"
base=load(orig.open("rb"));a=load((DST/"Data"/"Scripts.rvdata").open("rb"))
assert len(a)==506
assert all(a[j if j<482 else j+1]==base[j] for j in range(505) if j!=480)
assert zlib.decompress(a[480][2]).startswith(b"# R5 isolation only")
assert b"FS_R5_TEST_ADAPTER_ONLY" in a[482][1]
old=zlib.decompress(a[482][2]).decode("ascii")
# R5 initial mode DYNAMIC_ADAPTER; the single-session run toggles both without any rebuild.
assert 'MODE = "DYNAMIC_ADAPTER"' in old
assert "R5_ENABLE_AUTO_PROBE.flag" in old
extension=r'''
# R6 isolated tester, appended AFTER unchanged R5 test-only adapter; no original FS page touched.
module FSR6
 CASES = [["PLAYER_FRONT_NPC_BEHIND",[4,5],[4,3]],
          ["PLAYER_BEHIND_NPC_FRONT",[4,3],[4,5]],
          ["BOTH_FRONT",[4,5],[5,5]],
          ["BOTH_BEHIND",[4,3],[5,3]],
          ["CLEAR",[8,9],[9,9]]]
 # Events: begin sample after a settling period. 60-frame position spacing per triple.
 def self.log(str)
   File.open("R6_A_B_A_NATIVE.log","a"){|f|f.puts(str)}
 end
 def self.set_mode(spriteset,mode)
   use_hk=(mode=="A_STATIC")
   $game_switches[203]=use_hk
   hud=$OverlayMap
   if hud
     par=hud.instance_variable_get(:@par)
     par.visible=use_hk if par
   end
   objects=spriteset.instance_variable_get(:@r5_depth_objects)
   objects.each{|sp|sp.visible=!use_hk} if objects
 end
end
class Scene_Map
 alias r6_same_session_before_update update
 def update
   unless FileTest.exist?("ENABLE_R6_SAME_SESSION.flag")
     r6_same_session_before_update
     return
   end
   @r6_frame ||= 0
   @r6_frame+=1
   # R6 frozen rendering: allow full scene updates at boot and once after each pose.
   # While A/B/A images are acquired, do not update full map, overlay, weather,
   # tone, scrolling or animated effects. Graphics.update still draws visibility changes.
   normal_update=(@r6_frame<=43)
   FSR6::CASES.each_with_index {|row,i| normal_update=true if @r6_frame==71+i*155}
   r6_same_session_before_update if normal_update
   if @r6_frame==44
     FSR6.log("R6_FROZEN_RENDER_GATES_ON")
   end
   # Test optical walk + HK UOM consistency in this same process.
   if @r6_frame==30
      par=$OverlayMap.instance_variable_get(:@par)
      v=$OverlayMap.instance_variable_get(:@par_viewport)
      objs=@spriteset.instance_variable_get(:@r5_depth_objects)
      FSR6.log("R6_NATIVE_BASELINE hkViewportZ="+(v ? v.z.to_s : "NONE")+
       " hkParPresent="+(!par.nil?).to_s+
       " depthObjects="+(objs ? objs.size.to_s : "NONE")+
       " parapassa="+$game_parapassa.class.to_s+
       " mapPass="+$game_map.passable?(4,5).to_s+
       " mapBlock="+$game_map.passable?(5,6).to_s)
   end
   FSR6::CASES.each_with_index do |row,i|
      tag,p,n=row
      start=70+i*155
      if @r6_frame==start
        $game_player.moveto(p[0],p[1]);$game_player.refresh
        npc=$game_map.events[900];npc.moveto(n[0],n[1]);npc.refresh
        $game_map.set_display_pos(0,0)
        FSR6.log("R6_POSE "+tag+" player="+p.inspect+" npc="+n.inspect)
      end
      [["A1","A_STATIC",24],["B","B_DYNAMIC",64],["A2","A_STATIC",104]].each do |pair|
        code,mode,delta=pair
        if @r6_frame==start+delta
          FSR6.set_mode(@spriteset,mode)
          FSR6.log("R6_MODE "+tag+" "+code+" "+mode)
        elsif @r6_frame==start+delta+20
          npc=$game_map.events[900]
          FSR6.log("R6_SHOT "+tag+" "+code+" "+mode+
            " playerFoot="+(($game_player.y+1)*32).to_s+
            " npcFoot="+((npc.y+1)*32).to_s+
            " hkSwitch="+$game_switches[203].to_s+
            " frame="+@r6_frame.to_s)
        end
      end
   end
   if @r6_frame==70+FSR6::CASES.size*155
     FSR6.log("R6_SAME_SESSION_A_B_A_COMPLETE")
   end
 end
end
'''
a[482][2]=zlib.compress((old+extension).encode("ascii"))
path=DST/"Data"/"Scripts.rvdata"
with path.open("wb") as f:write(f,a)
verify=load(path.open("rb"))
assert len(verify)==506 and all(verify[j if j<482 else j+1]==base[j] for j in range(505) if j!=480)
ini=DST/"Game.ini";s=ini.read_bytes();s=s.replace(b"Title=FS_R5_505_DYNAMIC_ADAPTER",b"Title=FS_R6_VX_SAME_SESSION")
ini.write_bytes(s)
(DST/"R5_ENABLE_AUTO_PROBE.flag").unlink(missing_ok=True)
(DST/"ENABLE_R6_SAME_SESSION.flag").write_text("R6_TEST_ONLY",encoding="ascii")
(DST/"R6_A_B_A_NATIVE.log").write_text("R6_NATIVE_START\n",encoding="ascii")
report={"status":"R6_SINGLE_VX_SESSION_BUILD_PASS_RUNTIME_UNTESTED","source_pages":505,"original_byte_identical":504,
 "original_regression_disabled":480,"test_adapter_index":482,"native_modes":["A_STATIC","B_DYNAMIC","A_STATIC"],
 "cases":5,"expected_shots":15,"source_fs_sha256":hashlib.sha256(orig.read_bytes()).hexdigest(),
 "source_K4_untouched":True}
(ROOT/"R6_SAME_SESSION_ISOLATED"/"R6_BUILD_GATE.json").write_text(json.dumps(report,ensure_ascii=False,indent=2))
print(json.dumps(report,ensure_ascii=False),flush=True)