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
a=FakeBattler.new('A',true); b=FakeBattler.new('B',true)
scene=Scene_Battle.new([a,b])
scene.set_fixture([a,b])
$game_troop.forcing_battler=a
scene.prepare_forcing_atb
raise 'troop promotion mismatch' unless scene.forcing.map(&:id)==['B','A'] && scene.ordinary.map(&:id)==['B'] && scene.cleanup==['A'] && $game_troop.forcing_battler.nil?
force_schedule={event_order:['A','B'],troop_order:scene.forcing.map(&:id),ordinary:scene.ordinary.map(&:id),cleanup:scene.cleanup}
puts "CRAFT_FORCE_TROOP_ORACLE_PASS; Order=B,A; Cleanup=A"
# Actual #21 conditions and page selection, with explicit source-shaped stubs.
s21=pinned('exported_scripts/021__id96014404__Game_Troop.rb','d576e3f55071ff875e74a8e0db30cb6dbbcd0e03')
OracleCondition=Struct.new(:turn_ending,:turn_valid,:enemy_valid,:actor_valid,:switch_valid,:enemy_index,:enemy_hp,:switch_id)
OraclePage=Struct.new(:condition,:span,:list)
OracleEnemy=Struct.new(:hp,:maxhp)
class OracleInterpreter
  attr_reader :selected
  def running?; false; end
  def setup(list); @selected=list; end
  def clear; @selected=nil; end
end
class OracleTroop
  attr_reader :members,:interpreter,:event_flags
  def initialize(pages)
    @members=[OracleEnemy.new(100,100)]
    @troop=Struct.new(:pages).new(pages)
    @interpreter=OracleInterpreter.new
    @event_flags={}
  end
  def troop; @troop; end
end
OracleTroop.class_eval(excerpt(s21,153,186),'#21 conditions',153)
OracleTroop.class_eval(excerpt(s21,190,206),'#21 page setup',190)
$game_temp=Struct.new(:common_event_id).new(0)
$game_switches=Hash.new(false)
p0=OraclePage.new(OracleCondition.new(false,false,true,false,true,0,50,7),0,[0])
p1=OraclePage.new(OracleCondition.new(false,false,true,false,false,0,50,7),0,[1])
$game_troop=OracleTroop.new([p0,p1])
page_steps=[[60,false],[50,false],[50,true],[10,true]].map do |hp,sw|
  $game_troop.members[0].hp=hp
  $game_switches[7]=sw
  $game_troop.interpreter.clear
  $game_troop.setup_battle_event
  selected=$game_troop.interpreter.selected
  {hp:hp,switch:sw,selected:selected.nil? ? -1 : selected.first}
end
raise 'source troop pages mismatch' unless page_steps.map{|x|x[:selected]}==[-1,1,0,-1]
puts "CRAFT_TROOP_PAGE_ORACLE_PASS; Steps=4; Selected=-1,1,0,-1"
# Original #210 exact deterministic RNG and #372 final weighted target
# selection, with explicit targetability/weight stubs (not live aliases).
s210=pinned('exported_scripts/210__id99918659__FS_AI_DeterministicRandom_v1.0.rb','81211c685361ec328968cd587d88539553d3b6bf')
s372=pinned('exported_scripts/372__id96885223__FS_RandomTarget_Authority_v1.2｜TargetPriority___Provoke.rb','5115a1ab2d6ddb81cfa0beb38c61b1fffd3f8cd2')
$TEST=true
eval(s210.join,TOPLEVEL_BINDING,'#210 exact RNG',1)
eval(excerpt(s372,490,635),TOPLEVEL_BINDING,'#372 random helpers',490)
class Game_Unit
  def initialize(members); @members=members; end
  def existing_members; @members.select{|m|m.exist?}; end
end
Game_Unit.class_eval(excerpt(s372,641,689),'#372 final random_target',641)
class OracleRandomMember
  attr_reader :index
  def initialize(index,row); @index=index; @row=row; end
  def exist?; @row[:hp]>0 && !@row[:hidden]; end
  def actor?; @row[:actor]; end
  def enemy; Struct.new(:note).new(@row[:note]); end
  def albert_provoke?; @row[:provoke]; end
  def albert_targetable_unit?
    exist? && !@row[:disappear] && !ALBERT_RANDOM_TARGET_INTEGRATION.hard_excluded?(self)
  end
  def albert_target_weight; @row[:odds]; end
end
def target_row(odds=1,overrides={})
  {hp:100,hidden:false,actor:false,note:'',provoke:false,disappear:false,odds:odds}.merge(overrides)
end
random_specs=[
  ['weighted_1',1,[target_row(1),target_row(4),target_row(2)]],
  ['weighted_47',47,[target_row(1),target_row(4),target_row(2)]],
  ['provoke_over_disappear',2,[target_row(10),target_row(1,{provoke:true,disappear:true})]],
  ['hard_exclusion',3,[target_row(50,{note:'<no_random_target>',provoke:true}),target_row(1)]],
  ['all_disappear_fallback',4,[target_row(2,{disappear:true}),target_row(1,{disappear:true})]],
  ['all_hard_excluded',5,[target_row(1,{note:'対象不可',disappear:true}),target_row(1,{note:'<no_random_target>'})]],
  ['zero_weights',6,[target_row(0),target_row(0),target_row(-1)]],
  ['hidden_dead',7,[target_row(99,{hidden:true}),target_row(99,{hp:0}),target_row(1)]],
  ['actor_provoke',8,[target_row(2,{actor:true}),target_row(1,{actor:true,provoke:true})]],
  ['actor_weights',9,[target_row(1,{actor:true}),target_row(3,{actor:true})]]
]
random_cases=random_specs.map do |id,seed,rows|
  FS_AI_RANDOM.enable(seed)
  members=rows.each_with_index.map{|row,i|OracleRandomMember.new(i,row)}
  selected=Game_Unit.new(members).random_target
  trace=FS_AI_RANDOM.trace.map{|e|{count:e[0],tag:e[1].to_s,maximum:e[2],value:e[3]}}
  {id:id,seed:seed,members:rows,selected:selected.nil? ? -1 : selected.index,trace:trace}
end
FS_AI_RANDOM.disable
puts "CRAFT_RANDOM_ORACLE_PASS; Cases=#{random_cases.length}; SourceMethods=210,372; FullVXRuntime=False"

# #230 mode-2 turn_end: exact selected method and Sprite_ATB#refill.
# Recharge for normal guard is a deliberately bounded stub; existing Godot
# ordinary recharge tests remain independent. No complete VX aliases executed.
turn_config=pinned('exported_scripts/230__id55188000__ATB_Configurations.rb','3fe73b99012548f9f3e1d3ed3ec76a337be4713d')
turn_source=pinned('exported_scripts/231__id21262629__ATB_(1.2c)-0627.rb','4065ea4be1bc6fa5c5154034c89d626bc30d29fa')
module N02; end
[196,200,279,280].each { |n| N02.module_eval(excerpt(turn_config,n,n),'#230 exact',n) }
module Cache
  def self.system(_name); nil; end
end
TurnAction=Struct.new(:forcing,:target_index) do
  def guard?; true; end
  def clear; raise 'guard unexpectedly cleared'; end
end
TurnMember=Struct.new(:at_count,:act_count,:act_active,:at_active,:atb_count_up,:action) do
  def actor?; true; end
  def index; 0; end
end
class TurnGauge
  def initialize(member); @battler=member; @gauge=Struct.new(:bitmap).new; end
  def gauge_refill(*); refill; end
end
TurnGauge.class_eval(excerpt(turn_source,2274,2281),'#231 refill',2274)
class TurnTroop
  attr_accessor :turn_ending
  attr_reader :turn_count,:members
  def initialize; @turn_count=0; @turn_ending=false; @members=[]; end
  def increase_turn; @turn_count+=1; end
end
class TurnScene
  attr_reader :events,:end_member
  def initialize(member)
    @active_battler=member; @spriteset=TurnGauge.new(member)
    @end_member=0; @events=[]; @slip_all_damage=false
    @status_window=Object.new
    def @status_window.refresh; end
  end
  def process_battle_event
    @events << [$game_troop.turn_count,$game_troop.turn_ending,@end_member]
  end
  def recharge_action(member)
    member.at_count=0; member.act_count=0; member.act_active=false
    member.at_active=false; member.atb_count_up=true
  end
end
TurnScene.class_eval(excerpt(turn_source,559,602),'#231 turn_end',559)
turn_alias=pinned('exported_scripts/313__id96846647__H87_SkillDelay_v1.1.rb','d29308d209e9058b886bb0eb0685f43c03d1998a')
eval(excerpt(turn_config,148,149),TOPLEVEL_BINDING,'#230 imported flag',148)
TurnScene.class_eval(excerpt(turn_alias,321,325),'#313 turn_end wrapper',321)
raise 'TankentaiATB import missing' unless $imported['TankentaiATB']
turn_cases=[
  ['partial',350,0,false,false,true,true],
  ['negative',-90,0,false,false,true,true],
  ['ready',1000,0,false,true,false,true],
  ['charging',0,73,false,false,false,true],
  ['charged',0,1000,true,false,false,true],
  ['normal_guard',0,1000,true,false,false,false]
].map do |id,at,act,ac,ready,up,forced|
  member=TurnMember.new(at,act,ac,ready,up,TurnAction.new(forced,0))
  $game_party=Struct.new(:members).new([member])
  $game_troop=TurnTroop.new
  scene=TurnScene.new(member)
  scene.turn_end(member)
  raise 'mode 2 turn passage lost' unless $game_troop.turn_count==1 && scene.events==[[0,false,0],[1,true,0]]
  {id:id,input:[at,act,ac,ready,up],forced:forced,expected:[member.at_count,member.act_count,member.act_active,member.at_active,member.atb_count_up],events:scene.events,turn:$game_troop.turn_count,end_member:scene.end_member}
end
puts "CRAFT_TURN_END_ORACLE_PASS; Cases=#{turn_cases.size}; FullVXRuntime=False"


# Join actual #21 conditions/setup/increase_turn with #231 action-end
# windows and #313 wrapper. Interpreter only records selected lists.
TurnPageCondition=Struct.new(:turn_ending,:turn_valid,:enemy_valid,:actor_valid,:switch_valid,:turn_a,:turn_b,:enemy_index,:enemy_hp,:switch_id)
OracleTroop.class_eval { attr_accessor :turn_count,:turn_ending }
OracleTroop.class_eval(excerpt(s21,210,217),'#21 increase_turn',210)
class TurnPageScene < TurnScene
  attr_reader :window
  def process_battle_event
    super
    $game_troop.interpreter.clear
    $game_troop.setup_battle_event
    if $game_troop.interpreter.selected && @window.nil?
      @window={turn:$game_troop.turn_count,turn_ending:$game_troop.turn_ending,phase: @startup ? 'startup' : ($game_troop.turn_ending ? 'after_increment' : 'before_increment')}
    end
  end
  def startup
    @startup=true; process_battle_event; @startup=false
  end
end
window_specs=[
  ['exact_end_2',2,0,true,false,[false,false,false]],
  ['periodic_2_3',2,3,true,false,[false,false,false]],
  ['exact_start_0',0,0,false,false,[false]],
  ['switch_before_increment',1,0,false,true,[false,false,true]],
  ['period_never_zero',0,2,false,false,[false,false,false]],
  ['switch_off_no_trigger',1,0,true,true,[false,false,false]]
]
window_cases=window_specs.map do |id,a,b,ending,sw,steps|
  condition=TurnPageCondition.new(ending,true,false,false,sw,a,b,0,100,7)
  page=OraclePage.new(condition,0,[339])
  $game_troop=OracleTroop.new([page]);$game_troop.turn_count=0;$game_troop.turn_ending=false
  member=TurnMember.new(0,1000,true,false,false,TurnAction.new(false,0))
  $game_party=Struct.new(:members).new([member])
  scene=TurnPageScene.new(member)
  $game_switches[7]=steps.first
  scene.startup
  trigger_step=scene.window ? 0 : -1
  steps.drop(1).each_with_index do |value,i|
    break if scene.window
    $game_switches[7]=value
    member.act_active=true
    scene.turn_end(member)
    trigger_step=i+1 if scene.window
  end
  {id:id,a:a,b:b,ending:ending,switch:sw,steps:steps,selected:scene.window,trigger_step:trigger_step}
end
raise 'unexpected source windows' unless window_cases.map{|c|c[:trigger_step]}==[2,2,0,2,2,-1]
puts "CRAFT_TURN_WINDOW_ORACLE_PASS; Cases=#{window_cases.size}; OriginalInterpreterCommandsExecuted=False"

File.write(ARGV.fetch(0),JSON.pretty_generate({cases:cases,force:{order:['A','B'],outside_battle_unchanged:true},force_schedule:force_schedule,urgent:urgent,notes:note_cases,pipelines:pipelines,page_steps:page_steps,random_cases:random_cases,turn_cases:turn_cases,window_cases:window_cases}))
puts "CRAFT_NOTE_ORACLE_PASS; Notes=#{note_cases.length}; StatePipelines=#{pipelines.length}; FullVXRuntime=False"
puts "CRAFT_ORACLE_PASS; Cases=#{cases.length}; Force=2; Urgent=#{urgent.length}; OriginalVXRuntime=False"
