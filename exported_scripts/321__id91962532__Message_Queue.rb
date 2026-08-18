#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Message Queue v1.0
# 【用途】在地圖上方顯示「非關鍵提示 Banner」，訊息採 FIFO 先進先出佇列；一次顯示一則，後續訊息等待前一則淡出後依序顯示。
# 【作者／授權】Marc（Fall From Eden）；Creative Commons BY-SA 3.0。原作者／授權資訊保留於翻譯前 Archive。
# 【直接呼叫範例】事件 Script：$game_map.queue.push("Your message here.")。若字串先存在 m，也可 $game_map.queue.push(m)。Queue 實體就是 $game_map 的 @queue Array。
# 【主要設定】SWITCH=控制整套 Banner 的 Switch（nil 表示不綁 Switch）；ENABLED=新遊戲時是否預設啟用；ALIGNMENT 0/1/2=左／中／右；FONT=字型候選；BACKGROUND=Color；FADE_STEP=每幀淡入淡出量；WAIT=完全顯示後停留幀數；REMOVE_DUPLICATES=是否移除重複訊息。
# 【自動提示開關】MSG_MAP、MSG_GOLD、MSG_ITEM、MSG_PARTY、MSG_HP、MSG_MP、MSG_STATE、MSG_RECOVER、MSG_EXP、MSG_LEVEL、MSG_PARAMETERS、MSG_SKILLS、MSG_EQUIPMENT、MSG_NAME、MSG_CLASS。false 時保留原方法但不自動推 Banner。
# 【Map Name 規則】Map 名稱中 [ ... ] 內文字不顯示，且若去除括號內容後與上一張地圖同名，就不重複提示。可用來做 Inn[1F]／Inn[2F] 但 Banner 只顯示 Inn 一次。
# 【Duplicate 規則】是否刪除重複 Queue 項目由 REMOVE_DUPLICATES 控制；目前專案設定為 false，因此相同訊息可以依序重複顯示。
# 【相關素材】沒有固定圖片素材；Banner 背景由 Color.new 建立，Font 目前優先「微軟正黑體」。
# 【載入順序】會 alias Game_Map、Game_Party、Game_Interpreter、Game_Switches 等事件常用方法；維持目前位置。要新增自動訊息請沿用 push，而不是再建立另一套 Banner。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 維護說明集中於腳本最前方；程式識別字、Notetag、Script Call、Action Key 不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；翻譯前 byte-exact 原稿另存 Phase 17 Archive。
# 3. 範例只列原文件或既有程式能直接證實的入口，不捏造 API。
# 4. 本輪除註解／說明外不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
# ============================================================================ #
# Message Queue v1.0 by Marc (of Fall From Eden)                               #
# ============================================================================ #
# ---------------------------------------------------------------------------- #
# ============================================================================ #
# ---------------------------------------------------------------------------- #
#                                                                              #
# By default, the add-ons included in this script are automatic. There is no   #
#                                                                              #
#                                                                              #
# if that is not desired.                                                      #
#                                                                              #
#                                                                              #
#     $game_map.queue.push("Your message here.")                               #
#                                                                              #
#                                                                              #
#     $game_map.queue.push(m)                                                  #
#                                                                              #
#                                                                              #
# ============================================================================ #

module Marc
  module Queue
    SWITCH = nil
    ENABLED = true
   
    ALIGNMENT = 0
    # FONT = Font.default_name
    FONT = ["微軟正黑體", "Georgia", "Verdana"]
    BACKGROUND = Color.new(0, 0, 0, 128)
    FADE_STEP = 64
    WAIT = 90
    REMOVE_DUPLICATES = false
   
    MSG_MAP = false
    MSG_GOLD = false
    MSG_ITEM = false
    MSG_PARTY = false
    MSG_HP = false
    MSG_MP = false
    MSG_STATE = false
    MSG_RECOVER = false
    MSG_EXP = false
    MSG_LEVEL = false
    MSG_PARAMETERS = false
    MSG_SKILLS = false
    MSG_EQUIPMENT = false
    MSG_NAME = false
    MSG_CLASS = false
  end
end # module Marc::Queue

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! #

$imported = {} if $imported == nil
$imported["Marc_Message_Queue"] = true

# ============================================================================ #
# ---------------------------------------------------------------------------- #
# alias 方法：initialize                                                   #
# ============================================================================ #
if Marc::Queue::MSG_MAP
  class Game_Temp
    attr_accessor :old_map_name
   
    alias marc_queue_addons_initialize initialize
    def initialize
      @old_map_name = nil
      marc_queue_addons_initialize
    end
  end # class Game_Temp
end

# ============================================================================ #
# ---------------------------------------------------------------------------- #
# alias 方法：initialize                                                  #
# ============================================================================ #
if Marc::Queue::ENABLED
  class Game_Switches
    alias marc_queue_initialize initialize
    def initialize
      marc_queue_initialize
    end
  end # class Game_Switches
end # if Marc::Queue::ENABLED

# ============================================================================ #
# ---------------------------------------------------------------------------- #
# alias 方法：initialize, setup                                           #
# 新增方法：map_name                                                         #
# ============================================================================ #
class Game_Map
  attr_accessor :queue
   
  alias marc_queue_initialize initialize
  def initialize
    @queue = []
    marc_queue_initialize
  end
   
  if Marc::Queue::MSG_MAP
    alias marc_queue_addons_setup setup
    def setup(map_id)
      marc_queue_addons_setup(map_id)
      if $game_temp.old_map_name != map_name
        $game_temp.old_map_name = map_name
        unless map_name == ""
            @queue.push("You have entered #{map_name}.")
        end
      end
    end
       
    def map_name
      data = load_data("Data/MapInfos.rvdata")
      return data[@map_id].name.gsub(/\[.*?\]/, "").strip
    end
  end
end # class Game_Map

# ============================================================================ #
# ---------------------------------------------------------------------------- #
# alias 方法：gain_gold, gain_item                                        #
# ============================================================================ #
if Marc::Queue::MSG_GOLD or Marc::Queue::MSG_ITEM
  class Game_Party < Game_Unit
    if Marc::Queue::MSG_GOLD
      alias marc_queue_addons_gain_gold gain_gold
      def gain_gold(n)
        marc_queue_addons_gain_gold(n)
        return if not $scene.is_a?(Scene_Map)
        # return if not $game_switches[Marc::Queue::SWITCH]
        if n > 0
          if n == 1
            $game_map.queue.push("Found a #{Vocab::gold}.")
          else
            $game_map.queue.push("Found #{n} #{Vocab::gold}s.")
          end
        else
          if n == -1
            $game_map.queue.push("Lost a #{Vocab::gold}.")
          else
            $game_map.queue.push("Lost #{n.abs} #{Vocab::gold}s.")
          end
        end
      end
    end
   
    if Marc::Queue::MSG_ITEM
      alias marc_queue_addons_gain_item gain_item
      def gain_item(item, n, include_equip = false)
        queue_item = item.name.to_s unless item.nil?
        marc_queue_addons_gain_item(item, n, include_equip = false)
        return if not $scene.is_a?(Scene_Map)
        # return if not $game_switches[Marc::Queue::SWITCH]
        unless item.nil?
          if n > 0
            if n == 1
              if queue_item =~ /^[aeiou]/i
                $game_map.queue.push("Found an #{queue_item}.")
              else
                $game_map.queue.push("Found a #{queue_item}.")
              end
            else
              $game_map.queue.push("Found #{n} #{queue_item}s.")
            end
          else
            if n == -1
              if queue_item =~ /^[aeiou]/i
                $game_map.queue.push("Lost an #{queue_item}.")
              else
                $game_map.queue.push("Lost a #{queue_item}.")
              end
            else
              $game_map.queue.push("Lost #{n} #{queue_item}s.")
            end
          end
        end
      end
    end
  end # class Game_Party
end

# ============================================================================ #
# ---------------------------------------------------------------------------- #
# alias 方法：command_129, command_311, command_312, command_313,         #
# ============================================================================ #
class Game_Interpreter
  if Marc::Queue::MSG_PARTY
    alias marc_queue_addons_command_129 command_129
    def command_129
      marc_queue_addons_command_129
      if $scene.is_a?(Scene_Map)
        actor = $game_actors[@params[0]]
        if actor != nil and @params[1] == 0
          $game_map.queue.push("#{actor.name} has joined #{$game_party.name}.")
        elsif actor != nil and @params[1] != 0
          $game_map.queue.push("#{actor.name} has left #{$game_party.name}.")
        end
      end
    end
  end
 
  if Marc::Queue::MSG_HP
    alias marc_queue_addons_command_311 command_311
    def command_311
      marc_queue_addons_command_311
      if $scene.is_a?(Scene_Map)
        value = operate_value(@params[1], @params[2], @params[3])
        actor = $game_actors[@params[0]] unless @params[0] == 0
        @params[0] == 0 ? name = $game_party.name : name = actor.name
        if value > 0
          $game_map.queue.push("#{name} recovered #{value} #{Vocab::hp}.")
        elsif value < 0
          $game_map.queue.push("#{name} lost #{value.abs} #{Vocab::hp}.")
        end
      end
    end
  end

  if Marc::Queue::MSG_MP
    alias marc_queue_addons_command_312 command_312
    def command_312
      marc_queue_addons_command_312
      if $scene.is_a?(Scene_Map)
        value = operate_value(@params[1], @params[2], @params[3])
        actor = $game_actors[@params[0]] unless @params[0] == 0
        @params[0] == 0 ? name = $game_party.name : name = actor.name
        if value > 0
          $game_map.queue.push("#{name} recovered #{value} #{Vocab::mp}.")
        elsif value < 0
          $game_map.queue.push("#{name} lost #{value.abs} #{Vocab::mp}.")
        end
      end
    end
  end
 
  if Marc::Queue::MSG_STATE
    alias marc_queue_addons_command_313 command_313
    def command_313
      marc_queue_addons_command_313
      if $scene.is_a?(Scene_Map)
        state = $data_states[@params[2]]
        actor = $game_actors[@params[0]] unless @params[0] == 0
        @params[0] == 0 ? name = $game_party.name : name = actor.name
        if @params[1] == 0
          $game_map.queue.push("#{name}#{state.message1}")
        else
          $game_map.queue.push("#{name}#{state.message4}")
        end
      end
    end
  end
 
  if Marc::Queue::MSG_RECOVER
    alias marc_queue_addons_command_314 command_314
    def command_314
      marc_queue_addons_command_314
      if $scene.is_a?(Scene_Map)
        actor = $game_actors[@params[0]] unless @params[0] == 0
        @params[0] == 0 ? name = $game_party.name : name = actor.name
        $game_map.queue.push("#{name} has been fully recovered.")
      end
    end
  end
 
  if Marc::Queue::MSG_EXP
    alias marc_queue_addons_command_315 command_315
    def command_315
      marc_queue_addons_command_315
      if $scene.is_a?(Scene_Map)
        value = operate_value(@params[1], @params[2], @params[3])
        actor = $game_actors[@params[0]] unless @params[0] == 0
        @params[0] == 0 ? name = $game_party.name : name = actor.name
        if value > 0
          $game_map.queue.push("#{name} gained #{value} experience.")
        elsif value < 0
          $game_map.queue.push("#{name} lost #{value.abs} experience.")
        end
      end
    end
  end
 
  if Marc::Queue::MSG_LEVEL
    alias marc_queue_addons_command_316 command_316
    def command_316
      marc_queue_addons_command_316
      if $scene.is_a?(Scene_Map)
        value = operate_value(@params[1], @params[2], @params[3])
        actor = $game_actors[@params[0]] unless @params[0] == 0
        @params[0] == 0 ? name = $game_party.name : name = actor.name
        if @params[0] == 0
          if value > 0
            if value == 1
              $game_map.queue.push("#{name} gained a #{Vocab::level}.")
            else
              $game_map.queue.push("#{name} gained #{value} #{Vocab::level}s.")
            end
          elsif value < 0
            if value == -1
              $game_map.queue.push("#{name} lost a #{Vocab::level}.")
            else
              $game_map.queue.push
              ("#{name} lost #{value.abs} #{Vocab::level}s.")
            end
          end
        else
          $game_map.queue.push
          ("#{name} is now #{Vocab::level} #{actor.level + value}.")
        end
      end
    end
  end

  if Marc::Queue::MSG_PARAMETERS
    alias marc_queue_addons_command_317 command_317
    def command_317
      marc_queue_addons_command_317
      if $scene.is_a?(Scene_Map)
        value = operate_value(@params[2], @params[3], @params[4])
        actor = $game_actors[@params[0]]
        name = actor.name
        if actor != nil and value != 0
          case @params[1]
          when 0
            $game_map.queue.push
            ("#{name}'s maximum #{Vocab::hp} is now #{actor.maxhp}.")
          when 1
            $game_map.queue.push
            ("#{name}'s maximum #{Vocab::mp} is now #{actor.maxmp}.")
          when 2
            $game_map.queue.push("#{name}'s #{Vocab::atk} is now #{actor.atk}.")
          when 3
            $game_map.queue.push("#{name}'s #{Vocab::def} is now #{actor.def}.")
          when 4
            $game_map.queue.push("#{name}'s #{Vocab::spi} is now #{actor.spi}.")
          when 5
            $game_map.queue.push("#{name}'s #{Vocab::agi} is now #{actor.agi}.")
          end
        end
      end
    end
  end
 
  if Marc::Queue::MSG_SKILLS
    alias marc_queue_addons_command_318 command_318
    def command_318
      marc_queue_addons_command_318
      if $scene.is_a?(Scene_Map)
        actor = $game_actors[@params[0]]
        if actor != nil
          name = actor.name
          skill = $data_skills[@params[2]]
          if @params[1] == 0
            $game_map.queue.push("#{name} learned #{skill.name}.")
          else
            $game_map.queue.push("#{name} forgot #{skill.name}.")
          end
        end
      end
    end
  end

  if Marc::Queue::MSG_EQUIPMENT
    alias marc_queue_addons_command_319 command_319
    def command_319
      marc_queue_addons_command_319
      if $scene.is_a?(Scene_Map)
        actor = $game_actors[@params[0]]
        if actor != nil
          name = actor.name
          if @params[1] == 0 or (@params[1] == 1 and actor.two_swords_style)
            equipment = $data_weapons[@params[2]]
          else
            equipment = $data_armors[@params[2]]
          end
          unless equipment.nil?
            $game_map.queue.push("#{name} has equipped #{equipment.name}.")
          else
            case @params[1]
            when 0
              $game_map.queue.push("#{name} has unequipped a weapon.")
            when 1
              $game_map.queue.push("#{name} has unequipped their shield.")
            when 2
              $game_map.queue.push("#{name} has unequipped their headgear.")
            when 3
              $game_map.queue.push("#{name} has unequipped their armor.")
            when 4
              $game_map.queue.push("#{name} has unequipped their accessory.")
            end
          end
        end
      end
    end
  end
 
  if Marc::Queue::MSG_NAME
    alias marc_queue_addons_command_320 command_320
    def command_320
      if $scene.is_a?(Scene_Map)
        actor = $game_actors[@params[0]]
        if actor != nil
          $game_map.queue.push("#{actor.name} is now known as #{@params[1]}.")
        end
      end
      marc_queue_addons_command_320
    end
  end
 
  if Marc::Queue::MSG_CLASS
    alias marc_queue_addons_command_321 command_321
    def command_321
      marc_queue_addons_command_321
      if $scene.is_a?(Scene_Map)
        actor = $game_actors[@params[0]]
        new_class = $data_classes[@params[1]]
        if actor != nil and new_class != nil
          if new_class.name =~ /^[aeiou]/i
            $game_map.queue.push("#{actor.name} is now an #{new_class.name}.")
          else
            $game_map.queue.push("#{actor.name} is now a #{new_class.name}.")
          end
        end
      end
    end
  end
end # class Game_Interpreter

# ============================================================================ #
# ---------------------------------------------------------------------------- #
# alias 方法：initialize, update, dispose                                 #
# ============================================================================ #
class Spriteset_Map
  alias marc_queue_initialize initialize
  def initialize
    marc_queue_initialize
    @queue = Marc_Queue.new(@viewport3) # if $game_switches[Marc::Queue::SWITCH]
  end
 
  alias marc_queue_update update
  def update
    # if $game_switches[Marc::Queue::SWITCH]
      @queue.update unless @queue.nil?
    # else
      # $game_map.queue.clear if $game_map.queue != nil
    # end
    marc_queue_update
  end
 
  alias marc_queue_dispose dispose
  def dispose
    @queue.dispose unless @queue.nil?
    marc_queue_dispose
  end
end # class Spriteset_Map

# ============================================================================ #
# ---------------------------------------------------------------------------- #
# ============================================================================ #
class Marc_Queue < Sprite_Base
  def initialize(viewport)
    super(viewport)
    @counter = 0
    self.opacity = 0
  end
 
  def update
    return if $game_map.queue.empty?
    $game_map.queue.uniq! if Marc::Queue::REMOVE_DUPLICATES
    if self.bitmap.nil? and @counter == 0
      self.bitmap = Bitmap.new(Graphics.width, 32)
      self.bitmap.fill_rect(4, 4, Graphics.width-16, 32, Marc::Queue::BACKGROUND)
      self.bitmap.font.name = Marc::Queue::FONT
      self.bitmap.draw_text(12, 6, Graphics.width - 4, 24,
        $game_map.queue[0].to_s, Marc::Queue::ALIGNMENT)
      self.z = 500
    end
    if self.opacity < 255 and @counter < Marc::Queue::WAIT
      self.opacity += Marc::Queue::FADE_STEP
    end
    if @counter < Marc::Queue::WAIT
      @counter += 1
    else
      self.opacity -= Marc::Queue::FADE_STEP if self.opacity > 0
      if self.opacity <= 0
        $game_map.queue.shift
        self.bitmap = nil
        @counter = 0
      end
    end
  end
end # class Marc_Queue
