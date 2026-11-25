# Executes only selected original methods against explicit synthetic stubs.
# This is NOT RPG Maker VX runtime or the full effective alias chain.
require 'json'
require 'digest'

def pinned(path, blob)
  bytes=File.binread(path)
  raise "blob mismatch #{path}" unless Digest::SHA1.hexdigest("blob #{bytes.bytesize}\0"+bytes)==blob
  bytes.force_encoding('UTF-8').lines
end
def excerpt(lines,first,last)
  lines[(first-1)..(last-1)].join
end
s377=pinned('exported_scripts/377__id65670378__FS_ATB_DynamicResistance_v1.0.0.rb','d14c274006d00f793017e9910d1e390ec5f9aeef')
s374=pinned('exported_scripts/374__id21601036__FS_ComboCore_v1.1.1_OD.rb','f48fb90e6fa2b6a98953d888f9a3a5115671f137')
s462=pinned('exported_scripts/462__id68170006__FS_ForceAction_Bridge.rb','12659af67fa778134cb6b5d91e1519db126ad08d')
s406=pinned('exported_scripts/406__id23791037__FS_EnemyActionDistribution_FinalAuthority_v1.1.rb','06408e5ae0049fedc52289ff83f30ba091b0e1ef')
module ALBERT_ATB_DYNAMIC_RESIST; end
ALBERT_ATB_DYNAMIC_RESIST.module_eval(excerpt(s377,155,203),'#377 constants',155)
ALBERT_ATB_DYNAMIC_RESIST.module_eval(excerpt(s377,327,337),'#377 gain',327)
class Game_Battler
  attr_accessor :at_count,:act_count,:act_active,:at_active,:atb_count_up,:level,:floor,:max,:recover,:enabled,:user
  def albert_combo_effect_user; @user; end
end
class Game_Enemy < Game_Battler
  def albert_atb_dynamic_resist?; @enabled; end
  def albert_atb_resist_rate; ALBERT_ATB_DYNAMIC_RESIST::RESIST_RATES[@level]; end
  def albert_atb_resist_floor_value; @floor*10; end
  def albert_atb_resist_level; @level; end
  def albert_atb_resist_level=(v); @level=[[v,0].max,@max].min; end
  def albert_atb_resist_add(gain); self.albert_atb_resist_level=@level+gain; end
  def albert_atb_resist_recover; @recover; end
end
Game_Battler.class_eval(excerpt(s374,2603,2647),'#374 baseline',2603)
Game_Battler.class_eval { alias_method :albert_atb_resist_old_apply_atb_delta,:albert_combo_apply_atb_delta }
Game_Battler.class_eval(excerpt(s377,665,779),'#377 shift',665)
Game_Enemy.class_eval(excerpt(s377,607,617),'#377 recovery',607)
State=Struct.new(:atb_minus_damage)
cases=[]
def make_case(cases,id,before,delta,level,floor=10,pierce=0,state=0,negative=false,actor=false,enabled=true)
  b=(actor ? Game_Battler : Game_Enemy).new
  b.at_count=before;b.act_count=73;b.act_active=true;b.at_active=false;b.atb_count_up=false
  b.level=level;b.floor=floor;b.max=4;b.recover=1;b.enabled=enabled
  b.user=Object.new
  b.user.instance_variable_set(:@albert_od_aizhuo_overload_pierce,pierce)
  b.albert_combo_apply_atb_delta(delta,state==0 ? nil : State.new(negative))
  snapshot=[b.at_count,b.level,b.act_count,b.act_active,b.at_active,b.atb_count_up]
  recovered=actor ? 0 : b.albert_atb_resist_recover_after_action
  cases<<{id:id,before:before,delta:delta,level:level,floor:floor,pierce:pierce,state:state,allow_negative:negative,actor:actor,enabled:enabled,expected:snapshot,recovered:recovered,level_after_recovery:b.level}
end
[0,1,2,3,4].each do |lv|
  [-150,-151,-300,-301].each { |d| make_case(cases,"level#{lv}_delta#{d}",800,d,lv) }
end
make_case(cases,'floor_zero',100,-800,1)
make_case(cases,'floor_nine',109,-800,1)
make_case(cases,'floor_ten',110,-800,1)
make_case(cases,'pierce_half',900,-200,2,10,50)
make_case(cases,'pierce_full',900,-200,4,10,100)
make_case(cases,'positive',990,80,2)
make_case(cases,'zero',800,0,2)
make_case(cases,'normal_enemy',500,-350,0,10,0,0,false,false,false)
make_case(cases,'actor',500,-350,0,10,0,0,false,true,true)
make_case(cases,'state_normal',50,-140,2,10,0,4)
make_case(cases,'state_negative',50,-140,2,10,0,4,true)
make_case(cases,'zero_negative_plain',-90,0,0,10,0,0,false,false,false)
make_case(cases,'zero_negative_state',-90,0,2,10,0,4,true)
make_case(cases,'positive_negative_state',-90,40,2,10,0,4,true)
make_case(cases,'positive_negative_plain',-90,40,0,10,0,0,false,false,false)
make_case(cases,'floor_blocked_negative',-90,-200,2)
make_case(cases,'actor_state_negative',50,-140,0,10,0,4,true,true)
make_case(cases,'state_upper_cap',990,80,2,10,0,4,true)


# Exact event queue drain method with minimal environment. No game execution.
class Scene_Battle
  attr_accessor :forcing
  def initialize(queued); @forcing_battlers=queued; @forcing=queued; end
end
Scene_Battle.class_eval(excerpt(s462,178,190),'#462 drain',178)
FakeBattler=Struct.new(:id,:present) { def exist?; present; end }
Temp=Struct.new(:in_battle); Troop=Struct.new(:fs_force_action_queue)
a=FakeBattler.new('A',true); b=FakeBattler.new('B',true); dead=FakeBattler.new('dead',false)
$game_temp=Temp.new(true); $game_troop=Troop.new([nil,dead,a,b,b])
scene=Scene_Battle.new([a]);scene.fs_drain_force_action_queue
raise 'source force queue unexpected' unless scene.forcing.map(&:id)==['A','B'] && $game_troop.fs_force_action_queue.empty?
$game_temp.in_battle=false;$game_troop.fs_force_action_queue=[b];scene.fs_drain_force_action_queue
raise 'outside battle changed queue' unless $game_troop.fs_force_action_queue==[b]
# Actual #406 urgent predicate, separate from the other AI machinery.
module FS_ENEMY_ACTION_DIST; end
FS_ENEMY_ACTION_DIST.module_eval(excerpt(s406,193,201),'#406 urgent',193)
Skill=Struct.new(:scope,:base_damage,:minus_state_set) do
  def for_dead_friend?; [9,10].include?(scope); end
  def for_friend?; (7..11).include?(scope); end
end
urgent=[['damage',1,20,[]],['heal',7,-20,[]],['revive',9,0,[]],['cleanse',7,0,[4]],['enemy_remove',1,20,[4]]].map do |id,scope,damage,states|
  {id:id,scope:scope,damage:damage,minus:states,urgent:FS_ENEMY_ACTION_DIST.urgent_friend_skill?(Skill.new(scope,damage,states))}
end
# Execute the actual later #234 override and its #230 fallback.
s230=pinned('exported_scripts/230__id55188000__ATB_Configurations.rb','3fe73b99012548f9f3e1d3ed3ec76a337be4713d')
s234=pinned('exported_scripts/234__id12422743__Tankentai_Notetags_Add-on_v1.1.rb','b5f8b92bcd5343948fc65061ab43af29b8aba819')
s231=pinned('exported_scripts/231__id21262629__ATB_(1.2c)-0627.rb','4065ea4be1bc6fa5c5154034c89d626bc30d29fa')
class OriginalStateNote
  attr_reader :note
  def initialize(note); @note=note; end
end
OriginalStateNote.class_eval(excerpt(s230,380,383),'#230 damage',380)
OriginalStateNote.class_eval(excerpt(s230,389,391),'#230 lower bound',389)
OriginalStateNote.class_eval(excerpt(s234,211,212),'#234 regex',211)
OriginalStateNote.class_eval(excerpt(s234,230,236),'#234 note methods',230)
OriginalStateNote.class_eval(excerpt(s234,1001,1024),'#234 overrides',1001)
notes=['','<ATB DAMAGE:-14%>','<ATBDAMAGE+5>','<ATB DAMAGE : -14>','<-negative atb>','<+ATB MINUS DAMAGE>','<-ATBMINUSDAMAGE>','<negative atb>','<-negative atb><+negative atb>','<ATB DAMAGE:-14><ATB DAMAGE:5>','<ATB  DAMAGE:-14>','<atb damage: -14%><-negative atb>']
note_cases=notes.map do |note|
  state=OriginalStateNote.new(note)
  {note:note,damage:state.atb_damage,allows_negative:state.atb_minus_damage}
end
# Scoped actual add_state alias chain: base attachment/shield behavior stubbed,
# source #231 gauge effect and #374 bonus method are executed unchanged.
class Game_Battler
  attr_accessor :bonus
  def add_state(id); end
  def state?(id); true; end
  def albert_setup_mana_shield(id); end
  def albert_combo_atb_bonus_percent; @bonus; end
end
Game_Battler.class_eval(excerpt(s231,1844,1859),'#231 base State',1844)
Game_Battler.class_eval(excerpt(s374,2271,2311),'#374 State bonus',2271)
pipelines=[
  ['debt','<ATB DAMAGE:-14>',50,0],
  ['floor','<ATB DAMAGE:-14><-negative atb>',50,0],
  ['base_and_bonus','<ATB DAMAGE:-14>',50,50],
  ['floor_and_bonus','<ATB DAMAGE:-14><-negative atb>',50,50],
  ['positive_cap','<ATB DAMAGE:+8>',980,50],
  ['zero_noop','',-90,50],
  ['bonus_truncate','<ATB DAMAGE:-7>',500,33],
  ['negative_bonus','<ATB DAMAGE:-14>',50,-50]
].map do |id,note,before,bonus|
  $data_states=[nil,nil,nil,nil,OriginalStateNote.new(note)]
  b=Game_Enemy.new
  b.at_count=before;b.act_count=73;b.act_active=true;b.at_active=false;b.atb_count_up=false
  b.level=2;b.floor=10;b.max=4;b.recover=1;b.enabled=true;b.bonus=bonus
  b.add_state(4)
  {id:id,note:note,before:before,bonus:bonus,expected:[b.at_count,b.level,b.act_count,b.act_active,b.at_active,b.atb_count_up]}
end
# Execute the actual troop-slot promotion, not a hand-written duplicate.
class Scene_Battle
  attr_accessor :ordinary,:cleanup
  def set_fixture(ordinary); @action_battlers=ordinary; @ordinary=ordinary; @cleanup=[]; end
  def force_action_cleanup(member); @cleanup << member.id; end
end
Scene_Battle.class_eval(excerpt(s231,679,689),'#231 prepare troop slot',679)
Troop.class_eval { attr_accessor :forcing_battler }
$game_temp.in_battle=true
scene=Scene_Battle.new([a,b])
scene.set_fixture([a,b])
$game_troop.forcing_battler=a
scene.prepare_forcing_atb
raise 'troop promotion mismatch' unless scene.forcing.map(&:id)==['B','A'] && scene.ordinary.map(&:id)==['B'] && scene.cleanup==['A'] && $game_troop.forcing_battler.nil?
force_schedule={event_order:['A','B'],troop_order:scene.forcing.map(&:id),ordinary:scene.ordinary.map(&:id),cleanup:scene.cleanup}
puts "CRAFT_FORCE_TROOP_ORACLE_PASS; Order=B,A; Cleanup=A"
File.write(ARGV.fetch(0),JSON.pretty_generate({cases:cases,force:{order:['A','B'],outside_battle_unchanged:true},force_schedule:force_schedule,urgent:urgent,notes:note_cases,pipelines:pipelines}))
puts "CRAFT_NOTE_ORACLE_PASS; Notes=#{note_cases.length}; StatePipelines=#{pipelines.length}; FullVXRuntime=False"
puts "CRAFT_ORACLE_PASS; Cases=#{cases.length}; Force=2; Urgent=#{urgent.length}; OriginalVXRuntime=False"
