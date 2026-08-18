#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Skill Activation Core
# 【用途】技能系統元件「Skill Activation Core」。
# 【主要機制】可能影響技能資料、可用條件、消耗、熟練、選單或戰鬥執行。
# 【主要影響】UsableItem、Skill、Game_Battler、Window_Activation、Scene_Battle、Sprite_Battler、N01
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Audio/SE/、Graphics/System/、Graphics/Pictures/Black Screen。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】CrimsonSeas。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#===============================================================================
#Skill Activation Core Script v1.2
#  Script by CrimsonSeas
#===============================================================================
#Don't touch anything beyond this point unless you know what you're doing
#===============================================================================


module N01
  ANIME.merge!({"Activation" => ["Activation"]})
end

module RPG
  class UsableItem
    def damage_multiplier
      return 1.0
    end
  end
  class Skill
    def damage_multiplier=(damage_multiplier)
      @damage_multiplier = damage_multiplier
    end
    
    def damage_multiplier
      if @damage_multiplier == nil
        @damage_multiplier = 1.0
      end
      return @damage_multiplier
    end  
    
    def hit_number
      if @hit_number == nil
        @hit_number = 0
      end
      return @hit_number
    end
    
    def hit_number=(hit_number)
      @hit_number = hit_number
    end
    
    def success
      @success = false if @success == nil
      return @success
    end
    
    def success=(success)
      @success = success
    end
    
    def reset_skill
      @damage_multiplier = 1.0
      @hit_number = 0
      @success = false
    end
    
  end
end

#Ok I'm too lazy to rewrite these so I just copy pasted from Game_Battler
class Game_Battler
  alias crmsn_make_obj_damage_value make_obj_damage_value
  def make_obj_damage_value(user, obj)
    crmsn_make_obj_damage_value(user, obj)
    if @hp_damage != 0 && obj.is_a?(RPG::Skill)
      @hp_damage *= obj.damage_multiplier if $game_temp.in_battle
      @hp_damage = @hp_damage.to_i
    elsif @mp_damage != 0 && obj.is_a?(RPG::Skill)
      @mp_damage *= obj.damage_multiplier if $game_temp.in_battle
      @mp_damage = @mp_damage.to_i
    end
  end
end

class Window_Activation < Window_Base
  attr_accessor :time
  attr_accessor :pointer_x
  attr_reader   :time_comp
  def initialize(skill)
    super(0,164, 33, 56)
    @minus = 1
    @before_start = CRMSN::DELAY
    @skill = skill
    @time = @skill.activation_time
    @type = @skill.activation_type
    @effect = @skill.activation_effect
    @logo = Bitmap.new("Graphics/System/" + CRMSN::LOGO)
    case @type
    when "TIMING"
      type_bitmap = Bitmap.new("Graphics/System/" + CRMSN::TIMING_LOGO)
    when "SEQUENCE"
      type_bitmap = Bitmap.new("Graphics/System/" + CRMSN::SEQUENCE_LOGO)
    when "MASH"
      type_bitmap = Bitmap.new("Graphics/System/" + CRMSN::MASH_LOGO)
    end
    setup_window(@type)
    create_contents
    @viewport2 = Viewport.new(0, 0, 544, 416)
    @viewport2.visible = true
    @viewport2.z = 7000
    @activate_sprite = Sprite.new(@viewport2)
    @activate_sprite.bitmap = @logo
    @activate_sprite.x = self.x + 472
    @activate_sprite.y = self.y - 4
    @activate_sprite.opacity = 15
    @viewport3 = Viewport.new((self.x + self.width - 568), self.y + 36, 96,24)
    @viewport3.visible = true
    @viewport3.z = 7000
    @type_sprite = Sprite.new(@viewport2)
    @type_sprite.bitmap = type_bitmap
    @type_sprite.x = (self.x + self.width - 568)
    @type_sprite.y = self.y + 36
    @type_sprite.opacity = 15
    self.windowskin = Cache.system(CRMSN::SKIN) if CRMSN::USE_SKIN
    if CRMSN::DARK
      @screen = Sprite.new
      @screen.bitmap = Bitmap.new("Graphics/Pictures/Black Screen")
      @screen.z = 3000
      @screen.opacity = 0
    end
    self.z = 5000
    @pointer_x = @pointer_start_x
    refresh    
  end
  
  def setup_window(type)
    if @type == "TIMING" || @type == "MASH"
      @bar = Bitmap.new("Graphics/System/" + CRMSN::BAR)
      @pointer = Bitmap.new("Graphics/System/" + CRMSN::POINTER)
      @pointer_start_x = (@bar.width - @pointer.width - CRMSN::POINTER_RANGE)/ 2
      @pointer_end_x = @bar.width - @pointer_start_x - @pointer.width
      @hit_start_x = (@bar.width - @pointer.width - @skill.hit_range) / 2
      @hit_end_x = @bar.width - @pointer.width - @hit_start_x
      bitmap = Bitmap.new("Graphics/System/" + CRMSN::HIT_IMAGE)
      @hit_area = Bitmap.new(@skill.hit_range, bitmap.height)
      rect = Rect.new(0, 0, 8, bitmap.height)
      @hit_area.blt(0, 0, bitmap, rect)
      rect.x += 8
      dest = Rect.new(8, 0, @skill.hit_range-16, bitmap.height)
      @hit_area.stretch_blt(dest, bitmap, rect)
      rect.x += 8
      @hit_area.blt(@skill.hit_range-8, 0, bitmap, rect)
      @hit_area_y = (24- bitmap.height)/2
      @bar_y = (24 - @bar.height) / 2
      @pointer_y = (24 - @pointer.height) / 2
      @pointer_x = @pointer_start_x
      self.width = @bar.width + 90
      self.x = (544 - self.width) / 2
      @time_comp = (@hit_start_x - @pointer_start_x) / CRMSN::SPEED
    end
    if @type == "SEQUENCE"
      @sequence = @skill.sequence[0] if @skill.sequence.size == 1
      if @skill.sequence.size > 1
        @sequence = @skill.sequence[rand(@skill.sequence.size)] 
      end
      @keys = Bitmap.new("Graphics/System/" + CRMSN::KEYS)
      @length = (@keys.width+44) * @sequence.size / 11
      self.width = @length + 96
      self.x = (544-self.width)/2
      @index = 0
      @time_comp = @sequence.size*6
    end
  end
  
  def refresh
    self.contents.clear
    if @type == "TIMING" || @type == "MASH"
      refresh_timing
    end
    if @type == "SEQUENCE"
      refresh_sequence
    end
    x = self.width - 92
    draw_time(x, 2)
  end
  
  def draw_time(x, y)
    digits = []
    digits.push ((@time / 60) / 10)
    digits.push ((@time / 60) % 10)
    digits.push 10
    digits.push (((@time % 60) / 6))
    digits.push (((@time % 60) % 6) * 10 /6)
    @number_img = Bitmap.new("Graphics/System/" + CRMSN::TIME_IMAGE)
    for digit in digits
      src_rect = Rect.new(12*digit, 0, 12, 20)
      dest_rect = Rect.new(x, y, 12, 20)
      self.contents.stretch_blt(dest_rect, @number_img, src_rect)
      x += 12
    end
  end
#===============================================================================
#Methods for Timing
#===============================================================================
  def on_hit
    return @pointer_x >= @hit_start_x && @pointer_x <= @hit_end_x
  end
  
  def reset_pointer
    @pointer_x = @pointer_start_x
    @minus = 1
  end
  
  def refresh_timing
    src_rect = Rect.new(0, 0, @bar.width, @bar.height)
    dest_rect = Rect.new (4, @bar_y, @bar.width, @bar.height)
    self.contents.stretch_blt(dest_rect, @bar, src_rect)
    src_rect = Rect.new(0, 0, @pointer.width, @pointer.height)
    #dest_rect = Rect.new(@pointer_x + 4, @pointer_y, @pointer.width, @pointer.height)
    self.contents.blt(@pointer_x +4, @pointer_y, @pointer, src_rect)
    src_rect = Rect.new(0, 0, @hit_area.width, @hit_area.height)
    self.contents.blt(@hit_start_x+4, @hit_area_y, @hit_area, src_rect)
  end
  
  def update_timing
    @pointer_x += CRMSN::SPEED * @minus
    if @pointer_x <= @pointer_start_x
      @minus = 1
    elsif @pointer_x >= @pointer_end_x
      @minus = -1
    end
  end
    
  
  
#===============================================================================
#Methods for Sequence
#===============================================================================
  def refresh_sequence
    for i in 0...@sequence.size
      next if @index > i
      break if check_finish
      icon_pos = CRMSN::KEYS_ARRAY.index(@sequence[i])
      src_rect = Rect.new(icon_pos * 24, 0, 24, 24)
      self.contents.blt(4+ 28 * i, 0, @keys, src_rect)
    end
    src_rect = Rect.new(10 * 24, 0, 24, 24)
    self.contents.blt(4 + 28 * @index, 0, @keys, src_rect) if @index < @sequence.size
  end
  
  def read_input
    return @sequence[@index]
  end
  
  def next_input
    @index += 1
  end
  
  def check_finish
    return true if @index == @sequence.size
    return false
  end
  
  def reset
    @index = 0
  end
    
#===============================================================================
#Methods for Mash
#===============================================================================
  def update_mash
    speed = CRMSN::SPEED/4
    speed = 1 if speed == 0
    @pointer_x -= speed  unless @pointer_x <=@pointer_start_x
    @pointer_x == @pointer_start_x if @pointer_x < @pointer_start_x
  end
  
  def add_mash
    @pointer_x += CRMSN::SPEED * 3
  end
  
  def get_accuracy_value
    accuracy = (@pointer_x - @hit_start_x) * 200 / CRMSN::HIT_RANGE
    if accuracy > 100
      accuracy = 200 - accuracy
    end
    return accuracy
  end

#-------------------------------------------------------------------------------
  
  def moving?
    return true if @before_start == 0
    return false
  end
  
  def show_result(success)
    refresh
    if success
      text = CRMSN::SUCCESS_LOGO
    else
      text = CRMSN::FAIL_LOGO
    end
    bitmap = Bitmap.new("Graphics/System/" + text)
    @result_sprite = Sprite.new(@viewport2)
    @result_sprite.bitmap = bitmap
    @result_sprite.x = 212
    @result_sprite.y = 180
    @result_sprite.opacity = 15
    update
  end
  
  def dispose
    super
    @activate_sprite.dispose
    @activate_sprite = nil
    @screen.dispose
    @screen = nil
    @type_sprite.dispose
    @type_sprite = nil
    @result_sprite.dispose
    @result_sprite = nil
  end
  
  def update
    super
    if @before_start == 0 && @result_sprite == nil
      Audio.se_play("Audio/SE/" + CRMSN::SEC_SOUND, 80,  100) if @time % 60 == 0
      update_timing if @type == "TIMING"
      update_mash if (@type == "MASH" && @effect != "ADDNUM")
      @time -= 1
      refresh
    else
      @before_start-= 1
      @screen.opacity += 9
      @activate_sprite.x -= 480 / CRMSN::DELAY
      @activate_sprite.opacity += 240 / CRMSN::DELAY
      @type_sprite.x += 480 / CRMSN::DELAY
      @type_sprite.opacity += 240 / CRMSN::DELAY
    end    
    if @result_sprite != nil
      @result_sprite.opacity += 320 / CRMSN::DELAY unless @result_sprite.opacity = 255
    end
  end
end
    

class Scene_Battle  
  def playing_action
    skill = @active_battler.action.skill
    loop do
      break if @judge
      if $cmd_disabled || $atb_disabled
        update_patched
      else
        update_basic
      end
      action = @active_battler.play
      @cursor.visible = false if @cursor !=nil###
      next if action == 0
      @active_battler.play = 0
      if action[0] == "Individual"
        individual
      elsif action == "Activation" && @active_battler.actor?
        start_activation
        while $activation
          update_activation_window
        end
      elsif action == "Can Collapse"
        unimmortaling
      elsif action == "Cancel Action"
        break action_end
      elsif action == "End"
        break action_end
      elsif action[0] == "OBJ_ANIM"
        damage_action(action[1])
      end 
    end
    if skill != nil
      @active_battler.derivation = skill.link_to if skill.link_to != nil
      skill.reset_skill
    end
  end
  
 
  
  def start_activation
    @activation_window = Window_Activation.new(@active_battler.action.skill)
    $activation = true
    @cursor.visible = false if @cursor !=nil
    @skill_window.visible = false if @skill_window != nil
    @item_window.visible = false if @item_window != nil
    Audio.se_play("Audio/SE/" + CRMSN::START_SOUND, 80,  100)
  end
  
  
  
  def update_activation_window(basic = false)
    if !basic
      Graphics.update
      Input.update
      $game_system.update
      $game_troop.update
    end
    @activation_window.update
    skill = @active_battler.action.skill
    update_activation_timing(skill) if skill.activation_type == "TIMING"
    update_activation_sequence(skill) if skill.activation_type == "SEQUENCE"
    update_activation_mash(skill) if skill.activation_type == "MASH"
  end
  
  def update_activation_mash(obj)
    skill = obj
    if Input.trigger?(Input::Y) && @activation_window.moving?
      @activation_window.add_mash
    end
    if @activation_window.time == 0
      if @activation_window.on_hit
        max = (skill.max_power_up - skill.min_power_up)/100.0
        min = (skill.min_power_up/100.0)+1
        multiplier = ((@activation_window.get_accuracy_value) * (max / 100)) + min
        skill.damage_multiplier = multiplier
        Audio.se_play("Audio/SE/" + CRMSN::SUCCESS_SOUND, 80,  100)
        @activation_window.show_result(true)
        end_activation_process
      else 
        skill.damage_multiplier = 1.0
        Audio.se_play("Audio/SE/" + CRMSN::FAIL_SOUND, 80,  100)
        @activation_window.show_result(false)
        end_activation_process
      end
    end
  end
      
        
  
  def update_activation_sequence(obj)
    skill = obj
    if @activation_window.moving?
#Damn this part is very very very long, I got confused looking at this
    if Input.trigger?(Input::C) && @activation_window.read_input == "Z"
      Sound.play_decision
      @activation_window.next_input
      $data_skills[skill.link_to].hit_number += 1 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::C) && @activation_window.read_input != "Z"
      Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
      @activation_window.reset
      $data_skills[skill.link_to].hit_number = 0 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::B) && @activation_window.read_input == "X"
      Sound.play_decision
      @activation_window.next_input
      $data_skills[skill.link_to].hit_number += 1 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::B) && @activation_window.read_input != "X"
      Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
      @activation_window.reset
      $data_skills[skill.link_to].hit_number = 0 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::X) && @activation_window.read_input == "A"
      Sound.play_decision
      @activation_window.next_input
      $data_skills[skill.link_to].hit_number += 1 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::X) && @activation_window.read_input != "A"
      Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
      @activation_window.reset
      $data_skills[skill.link_to].hit_number = 0 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::Y) && @activation_window.read_input == "S"
      Sound.play_decision
      @activation_window.next_input
      $data_skills[skill.link_to].hit_number += 1 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::Y) && @activation_window.read_input != "S"
      Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
      @activation_window.reset
      $data_skills[skill.link_to].hit_number = 0 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::L) && @activation_window.read_input == "Q"
      Sound.play_decision
      @activation_window.next_input
      $data_skills[skill.link_to].hit_number += 1 if skill.activation_effect == "ADDNUM"
      elsif Input.trigger?(Input::L) && @activation_window.read_input != "Q"
      Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
      @activation_window.reset
      $data_skills[skill.link_to].hit_number = 0 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::R) && @activation_window.read_input == "W"
      Sound.play_decision
      @activation_window.next_input
      $data_skills[skill.link_to].hit_number += 1 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::R) && @activation_window.read_input != "W"
      Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
      @activation_window.reset
      $data_skills[skill.link_to].hit_number = 0 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::B) && @activation_window.read_input == "X"
      Sound.play_decision
      @activation_window.next_input
      $data_skills[skill.link_to].hit_number += 1 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::B) && @activation_window.read_input != "X"
      Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
      @activation_window.reset
      $data_skills[skill.link_to].hit_number = 0 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::UP) && @activation_window.read_input == "UP"
      Sound.play_decision
      @activation_window.next_input
      $data_skills[skill.link_to].hit_number += 1 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::UP) && @activation_window.read_input != "UP"
      Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
      @activation_window.reset
      $data_skills[skill.link_to].hit_number = 0 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::LEFT) && @activation_window.read_input == "LEFT"
      Sound.play_decision
      @activation_window.next_input
      $data_skills[skill.link_to].hit_number += 1 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::LEFT) && @activation_window.read_input != "LEFT"
      Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
      @activation_window.reset
      $data_skills[skill.link_to].hit_number = 0 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::DOWN) && @activation_window.read_input == "DOWN"
      Sound.play_decision
      @activation_window.next_input
      $data_skills[skill.link_to].hit_number += 1 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::DOWN) && @activation_window.read_input != "DOWN"
      Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
      @activation_window.reset
      $data_skills[skill.link_to].hit_number = 0 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::RIGHT) && @activation_window.read_input == "RIGHT"
      Sound.play_decision
      @activation_window.next_input
      $data_skills[skill.link_to].hit_number += 1 if skill.activation_effect == "ADDNUM"
    elsif Input.trigger?(Input::RIGHT) && @activation_window.read_input != "RIGHT"
      Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
      @activation_window.reset
      $data_skills[skill.link_to].hit_number = 0 if skill.activation_effect == "ADDNUM"
    end
    if @activation_window.time == 0 && skill.activation_effect != "ADDNUM"
      skill.damage_multiplier = 1.0
      $data_skills[skill.link_to].success = false if skill.activation_effect == "CONTINUE"
      Audio.se_play("Audio/SE/" + CRMSN::FAIL_SOUND, 80,  100)
      @activation_window.show_result(false)
      end_activation_process
      return
    elsif @activation_window.time == 0 && skill.activation_effect == "ADDNUM"
      if $data_skills[skill.link_to].hit_number == 0
        Audio.se_play("Audio/SE/" + CRMSN::FAIL_SOUND, 80,  100)
        @activation_window.show_result(false)
        end_activation_process
        return
      else
        Audio.se_play("Audio/SE/" + CRMSN::SUCCESS_SOUND, 80,  100)
        @activation_window.show_result(true)
        end_activation_process
        return
      end    
    elsif @activation_window.time == 0 && skill.activation_effect != "ADDNUM"
      skill.damage_multiplier = 1.0
      $data_skills[skill.link_to].success = false if skill.activation_effect = "CONTINUE"
      Audio.se_play("Audio/SE/" + CRMSN::FAIL_SOUND, 80,  100)
      @activation_window.show_result(false)
      end_activation_process
      return
    end
    if @activation_window.check_finish
      if skill.activation_effect == "DMGUP"
        time_comp = @activation_window.time_comp
        max = (skill.max_power_up - skill.min_power_up)/100.0
        min = (skill.min_power_up/100.0)+1
        multiplier = ((@activation_window.time + time_comp) * (max / (180 - time_comp))) + min
        skill.damage_multiplier = multiplier
      end
      $data_skills[skill.link_to].success = true if skill.activation_effect == "CONTINUE"
      Audio.se_play("Audio/SE/" + CRMSN::SUCCESS_SOUND, 80,  100)
      @activation_window.show_result(true)
      end_activation_process
      return
    end
    end
  end
      
  def update_activation_timing(obj)
    skill = obj
    if Input.trigger?(Input::Y) && @activation_window.moving?
      if @activation_window.on_hit && skill.activation_effect == "DMGUP"
        time_comp = @activation_window.time_comp
        max = (skill.max_power_up - skill.min_power_up)/100.0
        min = (skill.min_power_up/100.0)+1
        multiplier = ((@activation_window.time + time_comp) * (max / (180 - time_comp))) + min
        skill.damage_multiplier = multiplier
        Audio.se_play("Audio/SE/" + CRMSN::SUCCESS_SOUND, 80,  100)
        @activation_window.show_result(true)
        end_activation_process
        return
      elsif @activation_window.on_hit && skill.activation_effect == "CONTINUE"
        $data_skills[skill.link_to].success = true
        Audio.se_play("Audio/SE/" + CRMSN::SUCCESS_SOUND, 80,  100)
        @activation_window.show_result(true)
        end_activation_process
        return
      elsif @activation_window.on_hit && skill.activation_effect == "ADDNUM"
        $data_skills[skill.link_to].hit_number += 1
        Audio.se_play("Audio/SE/" + CRMSN::SUCCESS_SOUND, 80,  100)
        @activation_window.reset_pointer
      elsif !@activation_window.on_hit
        Audio.se_play("Audio/SE/" + CRMSN::MISS_SOUND, 80,  100)
        @activation_window.reset_pointer
      end
    end
    if @activation_window.time == 0
      if skill.activation_effect != "ADDNUM"
        skill.damage_multiplier = 1.0
        $data_skills[skill.link_to].success = false if skill.activation_effect == "CONTINUE"
        Audio.se_play("Audio/SE/" + CRMSN::FAIL_SOUND, 80,  100)
        @activation_window.show_result(false)
        end_activation_process
        return
      elsif skill.activation_effect == "ADDNUM"
        if $data_skills[skill.link_to].hit_number == 0
          Audio.se_play("Audio/SE/" + CRMSN::FAIL_SOUND, 80,  100)
          @activation_window.show_result(false)
          end_activation_process
          return
        else
          Audio.se_play("Audio/SE/" + CRMSN::SUCCESS_SOUND, 80,  100)
          @activation_window.show_result(true)
          end_activation_process
          return
        end
      end
    end
  end
    
  def end_activation_process
    for i in 1..60
      Graphics.update
      Input.update
      @activation_window.update
      break if Input.trigger?(Input::C)
    end
    $activation = false
    @activation_window.dispose
    @activation_window = nil
    @cursor.visible = true if @cursor != nil
    @skill_window.visible = true if @skill_window != nil
    @item_window.visible = true if @item_window != nil
  end
end

class Sprite_Battler
  def action
    return if @active_action == nil
    action = @active_action[0]
    # 反転の場合
    return mirroring if action == "Invert"
    # 回転の場合  
    return angling if action == "angle"
    # 拡大縮小の場合  
    return zooming if action == "zoom"
    # 残像ONの場合
    return mirage_on if action == "Afterimage ON"
    # 残像OFFの場合
    return mirage_off if action == "Afterimage OFF"
    # ピクチャ表示の場合
    return picture if action == "pic"
    # ピクチャ消去の場合
    return @picture.visible = false && @picture_time = 0 if action == "Clear image" 
    # グラフィックファイル変更の場合  
    return graphics_change if action == "change"
    # 戦闘アニメ表示の場合  
    return battle_anime if action == "anime"
    # ふきだしアニメ表示の場合  
    return balloon_anime if action == "balloon"
    # BGM/BGS/SE演奏の場合  
    return sound if action == "sound"
    # ゲームスイッチ操作の場合  
    return $game_switches[@active_action[1]] = @active_action[2] if action == "switch"
    # ゲーム変数操作の場合  
    return variable if action == "variable"
    # 二刀限定の場合
    return two_swords if action == "Two Wpn Only"
    # 非二刀限定の場合
    return non_two_swords if action == "One Wpn Only"
    # アクション条件の場合
    return necessary if action == "nece"
    # スキル派生の場合  
    return derivating if action == "der"
    # 個別処理開始の場合
    return individual_action if action == "Process Skill"
    # 個別処理終了の場合
    return individual_action_end if action == "Process Skill End"
    # 待機に移行しない場合
    return non_repeat if action == "Don't Wait"
    # 初期位置変更の場合
    return @battler.change_base_position(self.x, self.y) if action == "Start Pos Change"
    # 初期位置変更解除の場合
    return @battler.base_position if action == "Start Pos Return"
    # ターゲット変更の場合  
    return change_target if action == "target"
    # ターゲットのコラプス許可
    return send_action(action) if action == "Can Collapse"
    # アクティブ解除
    return send_action(action) if action == "Cancel Action"
    # ステート付与の場合  
    return state_on if action == "sta+"
    # ステート解除の場合  
    return state_off if action == "sta-"
    # ゲーム全体のスピード変更の場合
    return Graphics.frame_rate = @active_action[1] if action == "fps"
    # 浮遊の場合  
    return floating if action == "float"
    # スクリプト操作の場合   
    return eval(@active_action[1]) if action == "script"
    # 強制アクションの場合  
    return force_action if @active_action.size == 4
    # 座標リセットの場合  
    return reseting if @active_action.size == 5
    # 移動の場合
    return moving if @active_action.size == 7
    # バトラーアニメの場合
    return battler_anime if @active_action.size == 9
    # アニメ飛ばしの場合
    return moving_anime if @active_action.size == 11
    # 終了の場合 
    return anime_finish if action == "End"
    return send_action(action) if action == "Activation"
  end
  
end