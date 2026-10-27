#!/usr/bin/env python3
"""Test-only R4 real VX Game_Event + Game_Player parallax depth. Never change FS formal files."""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
import zlib,shutil,hashlib,json,re
ROOT=Path(__file__).resolve().parent; R3=ROOT/"R3_NATIVE_VX"; R4=ROOT/"R4_NATIVE_VX"
assert (R3/"R3_BUILD_REPORT.json").exists()
states=[("PLAYER_FRONT_NPC_BEHIND",[4,5],[4,3]),
        ("PLAYER_BEHIND_NPC_FRONT",[4,3],[4,5]),
        ("BOTH_FRONT",[4,5],[5,5]),
        ("BOTH_BEHIND",[4,3],[5,3]),
        ("CLEAR",[8,9],[9,9])]
assert len(states)==5
spec=json.dumps(states,separators=(",",":"))
recs=[]
for mode in ["STATIC","DEPTH"]:
 source=R3/mode; work=R4/mode
 if work.exists():shutil.rmtree(work)
 shutil.copytree(source,work)
 # Isolated B1 sample relies on RTP and has no bundled Graphics/Characters.
 # Copy ONLY the NPC actor sheet from the sealed source into this private test build.
 chars=work/"Graphics"/"Characters";chars.mkdir(parents=True,exist_ok=True)
 private=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE\Graphics\Characters")
 shutil.copy2(private/"$002.png",chars/"$002.png")
 (work/"ENABLE_R3_PROBE.flag").unlink(missing_ok=True)
 (work/"ENABLE_R4_PROBE.flag").write_text("isolated native R4")
 path=work/"Data"/"Scripts.rvdata"
 with path.open("rb") as f: arr=load(f)
 ix=next(i for i,x in enumerate(arr) if x[1]==b"B1 OWNER NATIVE V3")
 rb=zlib.decompress(arr[ix][2]).decode("ascii")
 target='      $game_map.setup(1)\n      $game_player.moveto'
 assert target in rb, "Need native event injection before Spriteset_Map constructed"
 creation='''      $game_map.setup(1)
      r4event=RPG::Event.new(4,3)
      r4event.id=1
      r4event.name="R4_NPC_REAL_GAME_EVENT"
      r4page=r4event.pages[0]
      r4page.graphic.character_name="$002"
      r4page.graphic.character_index=0
      r4page.graphic.direction=2
      r4page.priority_type=1
      r4page.through=true
      $game_map.events[1]=Game_Event.new(1,r4event)
      FSRich.log("R4_REAL_GAME_EVENT_CREATED class="+$game_map.events[1].class.to_s)
      $game_player.moveto'''
 rb=rb.replace(target,creation,1)
 rb+='''
class Sprite_Character
  alias r4_actual_actor_previous_update update
  def update
    r4_actual_actor_previous_update
    if @character.is_a?(Game_Event) && @character.instance_variable_get(:@id)==1
      self.z = @character.y*32+32
    end
  end
end
class Spriteset_Map
  alias r4_real_npc_previous_update update
  def update
    r4_real_npc_previous_update
    return unless @fs_objects && File.exist?("ENABLE_R4_PROBE.flag")
    @r4_frame ||=0
    @r4_frame+=1
    states = __R4_STATES__
    states.each_with_index do |row,i|
      tag,player_xy,npc_xy=row
      if @r4_frame==85+i*75
        npc=$game_map.events[1]
        $game_player.moveto(player_xy[0],player_xy[1]);$game_player.refresh
        npc.moveto(npc_xy[0],npc_xy[1]);npc.refresh
        $game_map.set_display_pos(0,0)
        FSRich.log("R4_POSITION "+tag+" player="+player_xy.inspect+" npc="+npc_xy.inspect)
      elsif @r4_frame==119+i*75
        npc=$game_map.events[1]
        actors=@character_sprites.select{|s| s.instance_variable_get(:@character).is_a?(Game_Event)}
        pz=@character_sprites.select{|s| s.instance_variable_get(:@character).equal?($game_player)}[0]
        FSRich.log("R4_CAPTURE "+tag+" playerFoot="+(($game_player.y+1)*32).to_s+
         " npcFoot="+((npc.y+1)*32).to_s+" npcCount="+actors.size.to_s+
         " playerSpriteZ="+(pz ? pz.z.to_s : "MISSING")+" npcSpriteZ="+(actors[0] ? actors[0].z.to_s : "MISSING"))
      end
    end
    if @r4_frame==119+states.size*75
      FSRich.log("R4_MULTI_ACTOR_CAPTURE_DONE")
    end
  end
end
'''
 rb=rb.replace("__R4_STATES__",spec)
 assert "R4_REAL_GAME_EVENT_CREATED" in rb
 assert rb.count("r4_actual_actor_previous_update")==2 # alias and method usage
 arr[ix][2]=zlib.compress(rb.encode("ascii"))
 with path.open("wb") as f:write(f,arr)
 assert zlib.decompress(load(path.open("rb"))[ix][2]).decode("ascii")==rb
 ini=work/"Game.ini"
 ini.write_text(re.sub(r"(?m)^Title=.*$",f"Title=FS_R4_NPC_{mode}_20261027",ini.read_text(errors="replace")),encoding="ascii")
 (work/"FS_RICH_VX_LOG.txt").write_text("R4_BUILD_READY\n",encoding="ascii")
 recs.append({"mode":mode,"game_exe":str(work/"Game.exe"),"script_source":"R3 TEST-ONLY","event_class":"Game_Event","states":states,
              "Scripts.rvdata_sha256":hashlib.sha256(path.read_bytes()).hexdigest()})
R4.mkdir(exist_ok=True)
(R4/"R4_BUILD_MANIFEST.json").write_text(json.dumps({"status":"BUILT_NOT_TESTED","cases":recs},indent=2),encoding="utf8")
print("R4_BUILT_NATIVE_EVENT",len(recs),len(states),flush=True)