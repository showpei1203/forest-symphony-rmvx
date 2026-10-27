#!/usr/bin/env python3
"""Inject a one-page test-only adapter BEFORE Main into ISOLATED CLONE of actual 505 FS scripts.
Preserves the sealed 505 original page byte tuples, never changes official source.
"""
from pathlib import Path
from rubymarshal.reader import load
from rubymarshal.writer import write
from PIL import Image
import struct,zlib,hashlib,json,shutil,re,sys
ROOT=Path(__file__).resolve().parent
FORMAL=Path(r"E:\GameAssetToolLab_20261023\FS_FORMAL_RUNTIME_B0_ISOLATED_20261024\clone_project\K4_BASELINE")
DEST=ROOT/"R5_FORMAL_ADAPTER_ISOLATED"/"FULL505"
SRC=ROOT/"SCENE21_GUIDED_SAM2_CANDIDATE"
MODE=(sys.argv[1].upper() if len(sys.argv)>1 else "HK_STATIC")
assert MODE in ("HK_STATIC","DYNAMIC_ADAPTER"),MODE
assert DEST.is_dir()
SOURCE_SCRIPTS=FORMAL/"Data"/"Scripts.rvdata";DEST_SCRIPTS=DEST/"Data"/"Scripts.rvdata"
a=load(SOURCE_SCRIPTS.open("rb")); assert len(a)==505
base_names={145:"HK - Ultimate Overlay Mapping",146:"Animated Parallax v2.1",342:"ISS - ParaPassa"}
for k,v in base_names.items():
 assert (a[k][1].decode("utf8","replace") if isinstance(a[k][1],bytes) else str(a[k][1]))==v,(k,v)
# Source never modified. Output format: always R5_SCENE21 master + derived Per Object masks.
master=Image.open(ROOT/"MASTER_OPAQUE_BLACK_MATTE.png").convert("RGBA")
assert master.size==(544,416)
parallax=DEST/"Graphics"/"Parallaxes";parallax.mkdir(parents=True,exist_ok=True)
master.save(parallax/"R5_SCENE21.png")
occluders=[
 ("house",SRC/"house_SAM2_RAW.png",196,214),
 ("left_tree",SRC/"left_tree_SAM2_RAW.png",187,190),
 ("right_tree",SRC/"right_tree_prompt_v2_variant1.png",217,237)
]
from PIL import ImageDraw
pic=DEST/"Graphics"/"Pictures";pic.mkdir(parents=True,exist_ok=True)
r5overlay=Image.new("RGBA",master.size,(0,0,0,0))
for i,(name,file,cutoff,foot) in enumerate(occluders):
 assert file.is_file()
 m=Image.open(file).convert("L").point(lambda p:255 if p>=128 else 0)
 ImageDraw.Draw(m).rectangle((0,cutoff,544,416),fill=0)
 img=master.copy();img.putalpha(m)
 img.save(pic/("R5_OC_"+name+".png"))
 r5overlay.alpha_composite(img)
over=DEST/"Overlays";over.mkdir(exist_ok=True)
r5overlay.save(over/"Par1.png")
# Clone map data, preserve its actual 30x25 layout, but only replace third invisible passability layer
map_src=FORMAL/"Data"/"Map001.rvdata";map_obj=load(map_src.open("rb"))
assert map_obj.attributes["@width"]==30 and map_obj.attributes["@height"]==25
table=map_obj.attributes["@data"];data=table._private_data
dim,w,h,d,sz=struct.unpack_from("<5i",data,0)
assert (dim,w,h,d,sz)==(3,30,25,3,2250)
arr=list(struct.unpack_from("<2250H",data,20))
old_layer=arr[w*h*2:]
for ty in range(h):
 for tx in range(w):
  arr[tx+ty*w+2*w*h]=769 # all-pass (R5 test only) except3 blocked
for tx,ty in [(5,6),(10,7),(14,8)]:
 arr[tx+ty*w+2*w*h]=768
table._private_data=struct.pack("<5i",dim,w,h,d,sz)+struct.pack("<2250H",*arr)
map_obj.attributes["@parallax_name"]=b"R5_SCENE21"
map_obj.attributes["@parallax_show"]=True
map_obj.attributes["@parallax_loop_x"]=False
map_obj.attributes["@parallax_loop_y"]=False
map_obj.attributes["@parallax_sx"]=0
map_obj.attributes["@parallax_sy"]=0
with (DEST/"Data"/"Map001.rvdata").open("wb") as f:write(f,map_obj)
roundtrip=load((DEST/"Data"/"Map001.rvdata").open("rb"))
assert roundtrip.attributes["@parallax_name"]==b"R5_SCENE21"
arr2=struct.unpack_from("<2250H",roundtrip.attributes["@data"]._private_data,20)
assert arr2[2*w*h+4+5*w]==769 and arr2[2*w*h+5+6*w]==768
# Scene title skips story and launches direct isolated map, leveraging real FS HK and ISS hooks.
pre=StringAdapter=r'''# R5 TEST-ONLY: SEALED FS original 505 pages preserved. Do not cherry-pick into formal.
module FSR5
 MODE = "__MODE__"
 POS = [["PLAYER_FRONT_NPC_BEHIND",[4,5],[4,3]],
        ["PLAYER_BEHIND_NPC_FRONT",[4,3],[4,5]],
        ["BOTH_FRONT",[4,5],[5,5]],
        ["BOTH_BEHIND",[4,3],[5,3]],
        ["CLEAR",[8,9],[9,9]]]
 def self.log(str)
   File.open("R5_FULL505_RUNTIME.log","a"){|f| f.puts(str)}
 end
end
FSR5.log("R5_ADDON_LOAD mode="+FSR5::MODE)
class Scene_Title
  alias r5_test_previous_update update
  def update
    unless @r5_direct_start
      @r5_direct_start=true
      FSR5.log("R5_TITLE_DIRECT_START")
      $game_party.setup_starting_members
      $game_map.setup(1)
      $game_map.events.clear
      e=RPG::Event.new(4,3)
      e.id=900
      e.name="R5_TEST_NPC_EVENT"
      pg=e.pages[0]
      pg.graphic.character_name="$002"
      pg.graphic.character_index=0
      pg.graphic.direction=2
      pg.priority_type=1
      pg.through=true
      $game_map.events[900]=Game_Event.new(1,e)
      $game_player.moveto(8,9)
      $game_player.refresh
      $game_map.set_display_pos(0,0)
      $game_switches[201]=false;$game_switches[202]=false
      $game_switches[203]=(FSR5::MODE=="HK_STATIC")
      $game_switches[204]=false;$game_switches[205]=false
      FSR5.log("R5_CORE_FLAGS parapassa="+($game_parapassa ? $game_parapassa.class.to_s : "MISSING")+
        " map1p="+$game_map.data[4,5,2].to_s+" blocked="+$game_map.data[5,6,2].to_s+
        " parallax="+$game_map.parallax_name.to_s+" size="+$game_map.width.to_s+"x"+$game_map.height.to_s)
      FSR5.log("R5_REAL_NPC_CLASS "+$game_map.events[900].class.to_s)
      $scene=Scene_Map.new
      return
    end
    r5_test_previous_update
  end
end
class Sprite_Character
 alias r5_test_old_update update
 def update
   r5_test_old_update
   if @character.equal?($game_player) || (@character.is_a?(Game_Event) && @character.instance_variable_get(:@id)==900)
     self.z = @character.y*32+32
   end
 end
end
class Spriteset_Map
 alias r5_test_previous_initialize initialize
 alias r5_test_previous_update update
 alias r5_test_previous_dispose dispose
 def initialize
   r5_test_previous_initialize
   @r5_depth_objects=[]
   if FSR5::MODE=="DYNAMIC_ADAPTER"
     [["house",214],["left_tree",190],["right_tree",237]].each do |pair|
       sp=Sprite.new(@viewport1)
       sp.bitmap=Cache.picture("R5_OC_"+pair[0])
       sp.z=pair[1]
       @r5_depth_objects.push(sp)
     end
   end
   FSR5.log("R5_NATIVE_SPRITE_INIT depth_objects="+@r5_depth_objects.size.to_s)
 end
 def update
   r5_test_previous_update
   if @r5_depth_objects
     offx=$game_map.display_x/8
     offy=$game_map.display_y/8
     @r5_depth_objects.each {|sp|sp.x=-offx;sp.y=-offy}
   end
 end
 def dispose
   if @r5_depth_objects
     @r5_depth_objects.each {|sp|sp.dispose unless sp.disposed?}
     @r5_depth_objects=nil
   end
   r5_test_previous_dispose
 end
end
class Scene_Map
 alias r5_test_previous_update update
 def update
   r5_test_previous_update
   return unless FileTest.exist?("R5_ENABLE_AUTO_PROBE.flag")
   @r5_fr ||= 0
   @r5_fr+=1
   if @r5_fr==30
     begin
       px1=$game_map.passable?(4,5)
       px0=$game_map.passable?(5,6)
       $game_player.moveto(4,6)
       $game_player.move_up
       move_ok=($game_player.y==5)
       $game_player.moveto(5,7)
       $game_player.move_up
       move_block=($game_player.y==7)
       $game_player.moveto(8,9)
       $game_map.set_display_pos(0,0)
       ov=$OverlayMap
       par=ov ? ov.instance_variable_get(:@par) : nil
       pov=ov ? ov.instance_variable_get(:@par_viewport) : nil
       viewport=@spriteset.instance_variable_get(:@viewport1)
       FSR5.log("R5_TRUE_PASSPASSA_GATE mapPass769="+px1.to_s+" mapBlock768="+(!px0).to_s+
        " playerMovePass="+move_ok.to_s+" playerMoveBlocked="+move_block.to_s)
       FSR5.log("R5_HK_VIEWPORT_GATE parPresent="+(!par.nil?).to_s+
        " parVisible="+(par ? par.visible.to_s : "NONE")+" parVZ="+(pov ? pov.z.to_s : "NONE")+
        " actorVZ="+(viewport ? viewport.z.to_s : "NONE"))
     rescue Exception => e
       FSR5.log("R5_PASSPASSA_OR_VIEWPORT_GATE_EXCEPTION "+e.class.to_s+" "+e.message.to_s)
     end
   end
   FSR5::POS.each_with_index do |spec,i|
     tag,p,n=spec
     if @r5_fr==85+i*78
       $game_player.moveto(p[0],p[1]);$game_player.refresh
       npc=$game_map.events[900];npc.moveto(n[0],n[1]);npc.refresh
       $game_map.set_display_pos(0,0)
       FSR5.log("R5_POSITION "+tag+" player="+p.inspect+" npc="+n.inspect)
     elsif @r5_fr==119+i*78
       npc=$game_map.events[900]
       chars=@spriteset.instance_variable_get(:@character_sprites) rescue []
       FSR5.log("R5_CAPTURE "+tag+" playerFoot="+(($game_player.y+1)*32).to_s+
        " npcFoot="+((npc.y+1)*32).to_s+" npcSprites="+
        (chars ? chars.select{|z|z.instance_variable_get(:@character).equal?(npc)}.size.to_s : "NONE")+
        " parSwitch="+$game_switches[203].to_s+
        " overlay="+($OverlayMap ? $OverlayMap.class.to_s : "NONE"))
     end
   end
   if @r5_fr==119+FSR5::POS.size*78
      FSR5.log("R5_FULL505_CAPTURE_DONE")
   end
 end
end
'''
pre=pre.replace("__MODE__",MODE)
script_entry=[9999999,b"FS_R5_TEST_ADAPTER_ONLY",zlib.compress(pre.encode("ascii"))]
a.insert(482,script_entry) # insert before Main. Existing 505 pages remain untouched in their original order/bytes
assert len(a)==506 and a[483][1]==b"Main"
output=DEST/"Data"/"Scripts.rvdata"
with output.open("wb") as f:write(f,a)
reloaded=load(output.open("rb"));assert len(reloaded)==506
assert [x for i,x in enumerate(reloaded) if i!=482]==load(SOURCE_SCRIPTS.open("rb")),"ORIGINAL_SCRIPT_BYTES_CHANGED"
# create private source sprite file: source may already exist copied full clone
assert (DEST/"Graphics"/"Characters"/"$002.png").exists()
ini=DEST/"Game.ini"
original=ini.read_text(encoding="latin1")
ini.write_text(re.sub(r"(?m)^Title=.*$",f"Title=FS_R5_505_{MODE}",original),encoding="latin1")
(DEST/"R5_ENABLE_AUTO_PROBE.flag").write_text("TEST ONLY")
(DEST/"R5_FULL505_RUNTIME.log").write_text("R5_TEST_START\n",encoding="ascii")
manifest={"status":"R5_505_ISOLATED_BUILT_NOT_RUNTIME_TESTED","mode":MODE,
 "formal_script_sha256":hashlib.sha256(SOURCE_SCRIPTS.read_bytes()).hexdigest(),
 "isolated_script_sha256":hashlib.sha256(output.read_bytes()).hexdigest(),
 "original_script_pages_intact":True,"script_count":506,"original_count":505,
 "map_original_sha256":hashlib.sha256(map_src.read_bytes()).hexdigest(),
 "map_r5_3rd_layer_769_passable":True,"map_r5_3rd_layer_768_blocked":True,
 "occlusion_par":"Overlays/Par1.png","original_master":"SCENE21 544x416 matte copy test output",
 "test_only":True}
(ROOT/"R5_FORMAL_ADAPTER_ISOLATED"/f"R5_BUILD_{MODE}.json").write_text(json.dumps(manifest,ensure_ascii=False,indent=2),encoding="utf8")
print("R5_505_BUILT",json.dumps(manifest,ensure_ascii=False),flush=True)