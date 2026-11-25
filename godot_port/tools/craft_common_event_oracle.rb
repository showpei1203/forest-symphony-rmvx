# Pinned actual source methods, bounded synthetic or owner-private data.
# Never execute source-provided script strings or full VX.
require 'json'
require 'digest'
path='exported_scripts/028__id89128017__Game_Interpreter.rb'
raw=File.binread(path)
raise 'source blob mismatch' unless Digest::SHA1.hexdigest("blob #{raw.bytesize}\0"+raw)=='d508227e2e1fff1ab42db94f888f72ae687a5100'
lines=raw.force_encoding('UTF-8').lines
class SourceEventProbe
  Cmd=Struct.new(:code,:indent,:parameters)
  Actor=Struct.new(:armors)
  Action=Struct.new(:kind,:basic,:skill_id,:target_index,:forcing)
  Battler=Struct.new(:action) do
    def exist?; true; end
  end
  class Switches < Hash
    def initialize(trace); @trace=trace; end
    def []=(id,value); @trace<<{'kind'=>'switch','id'=>id,'value'=>value}; super; end
  end
  def initialize(commands,actors,party)
    @list=commands.map{|c| Cmd.new(c.fetch('code'),c.fetch('indent'),c.fetch('parameters'))}
    @branch={}; @index=0; @trace=[]
    $game_actors=actors.transform_keys(&:to_i).transform_values{|a| a.fetch('exists') ? Actor.new(a.fetch('armors')) : nil}
    $game_party=Struct.new(:members).new(party.map{|id|$game_actors[id]})
    $data_armors=Hash.new{|_,id|id}
    $game_switches=Switches.new(@trace)
    $game_map=Struct.new(:need_refresh).new(false)
    $game_troop=Struct.new(:forcing_battler).new
  end
  def iterate_battler(side,index)
    # Existence and settlement deliberately stubbed, no effect simulation.
    yield Battler.new(Action.new)
  end
  def run
    while @index<@list.size-1
      c=@list.fetch(@index); @params=c.parameters; @indent=c.indent
      case c.code
      when 111
        raise 'unsupported condition' unless @params[0]==4 && [0,4].include?(@params[2])
        command_111
      when 411
        command_411
      when 121
        command_121
      when 339
        raise 'unsupported target' if @params[4]<0
        command_339
        a=$game_troop.forcing_battler.action
        @trace<<{'kind'=>'force','params'=>[@params[0],@params[1],a.kind,a.kind==0 ? a.basic : a.skill_id,a.target_index]}
        $game_troop.forcing_battler=nil
        next # original command_339 already advanced the index
      when 0,108,408,412
        # source execute_command treats unhandled terminators as no-op;
        # comments have no gameplay effects.
      else
        raise 'unsupported command'
      end
      @index+=1
    end
    @trace
  end
end
[[428,432],[566,668],[672,678],[749,755],[1631,1653]].each do |a,b|
  SourceEventProbe.class_eval(lines[(a-1)..(b-1)].join,'#28',a)
end
input=JSON.parse(File.read(ARGV.fetch(0)))
cases=input.fetch('cases').map do |c|
  trace=SourceEventProbe.new(input.fetch('commands'),c.fetch('actors'),c.fetch('party')).run
  c.merge('expected'=>trace)
end
File.write(ARGV.fetch(1),JSON.generate(input.merge('cases'=>cases)))
puts "CRAFT_COMMON_EVENT_ORACLE_PASS; Cases=#{cases.size}; FullVXRuntime=False; ForcedEffectsExecuted=False"
