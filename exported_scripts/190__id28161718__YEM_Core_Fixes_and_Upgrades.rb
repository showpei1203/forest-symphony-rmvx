#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：YEM Core Fixes and Upgrades
# 【用途】Yanfly Engine Melody 的 RGSS2 核心修正集合，修補 VX 基礎 Bug 並提供 YEM 後續腳本共用行為。
# 【版本】Last Date Updated: 2010.05.04；Level: Easy。
# 【載入順序】原作者建議放在自訂腳本區較前方；本 FS 專案維持目前已驗證順序，不自行搬動。
# 【主要修正】
#   1. Animation Overlay Fix：全畫面動畫只播放一次，避免圖像／聲音疊加與卡頓。
#   2. Bitmap Error Fix：Selectable Window 超過 RGSS2 8192px Bitmap 上限時避免因大量列數直接崩潰。
#   3. Disposed Window Debug：測試模式協助指出已 dispose 但仍被使用的 Window 變數。
#   4. Enemy Reappear Fix：死亡敵人狀態自然解除時不再錯誤重新顯示 Sprite。
#   5. Game Interpreter Fix：修正英文 VX 的 Control Variables 事件指令問題。
#   6. Help Window Codes：Help Window 支援 \n[x]、\v[x]；\n[0] 取使用者／主角名稱。
#   7. Interface Fix/Upgrade：修正 MaxHP/MaxMP 與 Gauge、提供耗竭色、Gauge／文字色設定與 contents 重建後字色重設。
#   8. Menu Actor Switch Fix：Skill／Equip 用 L/R 換 Actor 後，返回選單仍鎖定正確 Actor。
#   9. Message Window Actor Fix：\n[0] 回傳隊首名稱；\f[0] 使用隊首臉圖。
#  10. Outlined Text/Gauge：可用 OUTLINE 將陰影文字改為描邊，Gauge 同樣增加外框。
#  11. Prevent Skill Scene Actor Switch：技能數量需要 L/R 捲動時，避免 L/R 同時切 Actor；門檻由 SKILL_LIST_SIZE 控制。
#  12. Shown States Fix：Icon index=0 的 State 不顯示；可選擇顯示狀態剩餘回合。
#  13. State Resist Fix：依成功率正確判定敵人是否抗性；死亡 State 例外。
#  14. Turn Order Fix：預設回合制每個 Action 後重新計算速度順序，使當回合速度變化立即反映。
#  15. Usable Item Fix：戰鬥 Item Window 只列可在戰鬥使用的道具；亦考量 KGC Usable Equipment。
#  16. Wait for Animation Fix：修正等待動畫方法在動畫真正載入前就結束的問題。
#  17. Variance Fix：分開處理傷害與治療的 variance，避免治療被當成傷害公式。
# 【主要設定】
#   MIN_STATE_RESIST：成功率低於此百分比時視為抗性；目前 20。
#   ANIMATION_RATE：戰鬥動畫更新 rate；目前 3，原說明對應較平滑的 60fps 動畫節奏。
#   SKILL_LIST_SIZE：技能清單超過此數量時保留 L/R 給捲動；目前 22。
#   OUTLINE：true 啟用描邊文字／Gauge 外框。
#   HELP_WINDOW_0：無可用主角時 \n[0] 的替代文字。
#   COLOURS：常用 UI 顏色索引，包括 normal/system/crisis/lowmp/knockout/gaugeback/exhaust/HP/MP/power_up/power_dn。
#   CRISIS_HP / CRISIS_MP：危急色門檻百分比；目前 25/25。
#   GAUGE_HEIGHT：HP/MP Gauge 高度。
#   DRAW_STATE_TURNS、STATE_TURN_COLOUR、STATE_TURN_F_SIZE、STATE_TURN_BOLD：狀態剩餘回合文字顯示。
# 【State Notetag】<turn colour n>：指定回合數文字顏色；<hide state>：隱藏該 State 的顯示。
# 【範例】Help/Message 文字可使用 \n[0] 顯示隊首／使用者名稱、\v[10] 顯示變數 10；Message Window 的 \f[0] 取隊首臉圖。
# 【相關素材】未發現固定 Graphics/Audio 檔名；主要作用在引擎 Bitmap、Window、Battler、Interpreter 與動畫流程。
# 【來源】Yanfly Engine Melody；作者／原始版本資訊依原腳本保留於 Phase 16 Archive。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本頁所有維護說明集中於腳本最前方；下方程式識別字、Notetag、Action Key、方法名不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；完整翻譯前原稿另存 Phase 16 Archive。
# 3. 範例只使用原文件已明示的 API／Notetag，或由既有方法簽章可直接證實的呼叫方式。
# 4. 本輪只改註解／說明，不改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
$imported = {} if $imported == nil
$imported["CoreFixesUpgradesMelody"] = true

module YEM
  module FIXES
    
    MIN_STATE_RESIST = 20
    
    ANIMATION_RATE = 3
    
    SKILL_LIST_SIZE = 22
    
  end
  module UPGRADE
    
    OUTLINE = false
    
    HELP_WINDOW_0 = "User"
    
    COLOURS ={
      :normal    =>  0,
      :system    =>  4,
      :crisis    => 17,
      :lowmp     => 17,
      :knockout  => 18,
      :gaugeback => 19,
      :exhaust   => 18,
      :hp_back   => 19,
      :hp_gauge1 => 20,
      :hp_gauge2 => 21,
      :mp_back   => 19,
      :mp_gauge1 => 22,
      :mp_gauge2 => 23,
      :power_up  => 24,
      :power_dn  => 25,
    }
    
    CRISIS_HP = 25
    CRISIS_MP = 25
    
    GAUGE_HEIGHT = 7
    
    # 僅當 State 具有回合計數，且初始解除機率符合條件時顯示。
    DRAW_STATE_TURNS  = false
    STATE_TURN_COLOUR = 0
    STATE_TURN_F_SIZE = 18
    STATE_TURN_BOLD   = false
    
  end
end

#===============================================================================
#===============================================================================

module YEM
  module REGEXP
  module STATE
      
    TURN_COLOUR = /<(?:TURN_COLOUR|turn colour|turn color):[ ]*(\d+)>/i
    HIDE_STATE  = /<(?:HIDE_STATE|hide state)>/i
      
  end
  end
end

#===============================================================================
# RPG::State
#===============================================================================

class RPG::State
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :turn_colour
  attr_accessor :hide_state
  
  #--------------------------------------------------------------------------
  # 共用快取：yem_cache_state_cfu
  #--------------------------------------------------------------------------
  def yem_cache_state_cfu
    @turn_colour = YEM::UPGRADE::STATE_TURN_COLOUR; @hide_state = false
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YEM::REGEXP::STATE::TURN_COLOUR
        @turn_colour = $1.to_i
      when YEM::REGEXP::STATE::HIDE_STATE
        @hide_state = $1.to_i
      end
    } # end self.note.split
  end
  
end # RPG::State

#===============================================================================
# Scene_Title
#===============================================================================

class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------
  # 新增方法：load_bt_database
  #--------------------------------------------------------------------------
  alias load_bt_database_cfu load_bt_database unless $@
  def load_bt_database
    load_bt_database_cfu
    load_cfu_cache
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：load_database
  #--------------------------------------------------------------------------
  alias load_database_cfu load_database unless $@
  def load_database
    load_database_cfu
    load_cfu_cache
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：load_cfu_cache
  #--------------------------------------------------------------------------
  def load_cfu_cache
    groups = [$data_states]
    for group in groups
      for obj in group
        obj.yem_cache_state_cfu if obj.is_a?(RPG::State)
      end
    end
  end
  
end # Scene_Title

#===============================================================================
#===============================================================================

class Bitmap

  #--------------------------------------------------------------------------
  # alias 方法：draw_text
  #--------------------------------------------------------------------------
  if YEM::UPGRADE::OUTLINE
  alias draw_text_cfu draw_text unless $@
  def draw_text(*args)
    unless self.font.shadow
      draw_text_cfu(*args)
      return
    end
    case args.size
    when 2, 3
      dx, dy, dw, dh, text, align =
      args[0].x, args[0].y, args[0].width, args[0].height, args[1],
      args[2].nil? ? 0 : args[2]
    else
      dx, dy, dw, dh, text, align =
      args[0], args[1], args[2], args[3], args[4],
      args[5].nil? ? 0 : args[5]
    end
    original_colour = self.font.color.clone
    self.font.shadow = false
    alpha = self.font.color.alpha
    self.font.color = Color.new(0, 0, 0, alpha)
    draw_text_cfu(dx-1, dy-1, dw, dh, text, align)
    draw_text_cfu(dx+1, dy-1, dw, dh, text, align)
    draw_text_cfu(dx-1, dy+1, dw, dh, text, align)
    draw_text_cfu(dx+1, dy+1, dw, dh, text, align)
    self.font.color = original_colour
    draw_text_cfu(dx, dy, dw, dh, text, align)
    self.font.shadow = true
  end
  end # YEM::UPGRADE::OUTLINE
  
end

#===============================================================================
# Game_Battler
#===============================================================================

class Game_Battler
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :pseudo_ani_id
  attr_accessor :state_turns
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def maxmp
    return [[base_maxmp + @maxmp_plus, 0].max, maxmp_limit].min
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：maxmp_limit
  #--------------------------------------------------------------------------
  def maxmp_limit
    return 9999
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：clear_sprite_effects
  #--------------------------------------------------------------------------
  alias clear_sprite_effects_cfu clear_sprite_effects unless $@
  def clear_sprite_effects
    clear_sprite_effects_cfu
    @pseudo_ani_id = 0
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：remove_states_auto
  #--------------------------------------------------------------------------
  alias remove_states_auto_cfu remove_states_auto unless $@
  def remove_states_auto
    return if self.dead?
    remove_states_auto_cfu
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def state_resist?(state_id)
    return false if state_id == 1
    return false if state_probability(state_id) > YEM::FIXES::MIN_STATE_RESIST
    return true
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def apply_variance(damage, variance)
    amp = [damage.abs * variance / 100, 0].max
    if damage > 0
      damage += rand(amp+1) + rand(amp+1)
      damage -= amp
    elsif damage < 0
      damage -= rand(amp+1) + rand(amp+1)
      damage += amp
    end
    return damage
  end
  
end # Game_Battler

#==============================================================================
# Game_Interpreter
#==============================================================================

class Game_Interpreter
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def command_122
    value = 0
    case @params[3]
    when 0
      value = @params[4]
    when 1
      value = $game_variables[@params[4]]
    when 2
      value = @params[4] + rand(@params[5] - @params[4] + 1)
    when 3
      value = $game_party.item_number($data_items[@params[4]])
    when 4
      actor = $game_actors[@params[4]]
      if actor != nil
        case @params[5]
        when 0
          value = actor.level
        when 1
          value = actor.exp
        when 2  # HP
          value = actor.hp
        when 3  # MP
          value = actor.mp
        when 4
          value = actor.maxhp
        when 5
          value = actor.maxmp
        when 6
          value = actor.atk
        when 7
          value = actor.def
        when 8
          value = actor.spi
        when 9
          value = actor.agi
        end
      end
    when 5
      enemy = $game_troop.members[@params[4]]
      if enemy != nil
        case @params[5]
        when 0  # HP
          value = enemy.hp
        when 1  # MP
          value = enemy.mp
        when 2
          value = enemy.maxhp
        when 3
          value = enemy.maxmp
        when 4
          value = enemy.atk
        when 5
          value = enemy.def
        when 6
          value = enemy.spi
        when 7
          value = enemy.agi
        end
      end
    when 6
      character = get_character(@params[4])
      if character != nil
        case @params[5]
        when 0
          value = character.x
        when 1
          value = character.y
        when 2
          value = character.direction
        when 3
          value = character.screen_x
        when 4
          value = character.screen_y
        end
      end
    when 7
      case @params[4]
      when 0
        value = $game_map.map_id
      when 1
        value = $game_party.members.size
      when 2
        value = $game_party.gold
      when 3
        value = $game_party.steps
      when 4
        value = Graphics.frame_count / Graphics.frame_rate
      when 5
        value = $game_system.timer / Graphics.frame_rate
      when 6
        value = $game_system.save_count
      end
    end
    for i in @params[0] .. @params[1]
      case @params[2]
      when 0
        $game_variables[i] = value
      when 1
        $game_variables[i] += value
      when 2
        $game_variables[i] -= value
      when 3
        $game_variables[i] *= value
      when 4
        $game_variables[i] /= value if value != 0
      when 5
        $game_variables[i] %= value if value != 0
      end
      if $game_variables[i] > 99999999
        $game_variables[i] = 99999999
      end
      if $game_variables[i] < -99999999
        $game_variables[i] = -99999999
      end
    end
    $game_map.need_refresh = true
    return true
  end
  
end # Game_Interpreter

#==============================================================================
# Sprite_Base
#==============================================================================

class Sprite_Base < Sprite
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  RATE = YEM::FIXES::ANIMATION_RATE
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    update_animation if @animation != nil
    @@animations.clear
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start_animation(animation, mirror = false)
    dispose_animation
    @animation = animation
    return if @animation == nil
    @animation_mirror = mirror
    @animation_duration = @animation.frame_max * RATE + 1
    load_animation_bitmap
    @animation_sprites = []
    if @animation.position != 3 or not @@animations.include?(animation)
      if @use_sprite
        for i in 0..15
          sprite = ::Sprite.new(self.viewport)
          sprite.visible = false
          @animation_sprites.push(sprite)
        end
        @@animations.push(animation) unless @@animations.include?(animation)
      end
    end
    if @animation.position == 3
      if viewport == nil
        @animation_ox = Graphics.width / 2
        @animation_oy = Graphics.height / 2
      else
        @animation_ox = viewport.rect.width / 2
        @animation_oy = viewport.rect.height / 2
      end
    else
      @animation_ox = x - ox + width / 2
      @animation_oy = y - oy + height / 2
      if @animation.position == 0
        @animation_oy -= height / 2
      elsif @animation.position == 2
        @animation_oy += height / 2
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：start_pseudo_ani
  #--------------------------------------------------------------------------
  def start_pseudo_ani(animation, mirror = false)
    dispose_animation
    @animation = animation
    return if @animation == nil
    @animation_mirror = mirror
    @animation_duration = @animation.frame_max * RATE + 1
    @animation_sprites = []
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_animation
    @animation_duration -= 1
    return unless @animation_duration % RATE == 0
    if @animation_duration > 0
      frame_index = @animation.frame_max
      frame_index -= (@animation_duration+RATE-1)/RATE
      animation_set_sprites(@animation.frames[frame_index])
      for timing in @animation.timings
        next unless timing.frame == frame_index
        animation_process_timing(timing)
      end
      return
    end
    dispose_animation
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def animation_process_timing(timing)
    timing.se.play
    case timing.flash_scope
    when 1
      self.flash(timing.flash_color, timing.flash_duration * RATE)
    when 2
      if viewport != nil
        viewport.flash(timing.flash_color, timing.flash_duration * RATE)
      end
    when 3
      self.flash(nil, timing.flash_duration * RATE)
    end
  end
  
end # Sprite_Base

#==============================================================================
# Sprite_Battler
#==============================================================================

class Sprite_Battler < Sprite_Base
  
  #--------------------------------------------------------------------------
  # alias 方法：setup_new_effect
  #--------------------------------------------------------------------------
  alias setup_new_effect_cfu setup_new_effect unless $@
  def setup_new_effect
    setup_new_effect_cfu
    if @battler.pseudo_ani_id != 0 and @battler.pseudo_ani_id != nil
      animation = $data_animations[@battler.pseudo_ani_id]
      start_pseudo_ani(animation)
      @battler.pseudo_ani_id = 0
    end
  end
  
end # Sprite_Battler

#===============================================================================
# Scene_Status
#===============================================================================

class Scene_Status < Scene_Base
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :actor
  
  #--------------------------------------------------------------------------
  # alias 方法：start
  #--------------------------------------------------------------------------
  alias start_scene_status_cfu start unless $@
  def start
    start_scene_status_cfu
    $game_party.last_actor_index = @actor_index
  end
  
end # Scene_Skill

#===============================================================================
# Scene_Skill
#===============================================================================

class Scene_Skill < Scene_Base
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :actor
  
  #--------------------------------------------------------------------------
  # alias 方法：start
  #--------------------------------------------------------------------------
  alias start_scene_skill_cfu start unless $@
  def start
    start_scene_skill_cfu
    $game_party.last_actor_index = @actor_index
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：update_skill_selection
  #--------------------------------------------------------------------------
  alias update_skill_selection_cfu update_skill_selection unless $@
  def update_skill_selection
    if (Input.trigger?(Input::L) or Input.trigger?(Input::R)) and
    @actor.skills.size > YEM::FIXES::SKILL_LIST_SIZE
      return
    end
    update_skill_selection_cfu
  end
  
end # Scene_Skill

#===============================================================================
# Scene_Equip
#===============================================================================

class Scene_Equip < Scene_Base
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :actor
  
  #--------------------------------------------------------------------------
  # alias 方法：start
  #--------------------------------------------------------------------------
  alias start_scene_equip_cfu start unless $@
  def start
    start_scene_equip_cfu
    $game_party.last_actor_index = @actor_index
  end
  
end # Scene_Equip

#===============================================================================
# Scene_Battle
#===============================================================================

class Scene_Battle < Scene_Base
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :active_battler
  
  #--------------------------------------------------------------------------
  # alias 方法：terminate
  #--------------------------------------------------------------------------
  alias terminate_cfu terminate unless $@
  def terminate
    terminate_cfu
    if $disposable_battle_windows != nil
      for window in $disposable_battle_windows
        window.dispose unless window.disposed?
      end
      $disposable_battle_windows = []
    end
  end

  #--------------------------------------------------------------------------
  # alias 方法：start_main
  #--------------------------------------------------------------------------
  alias start_main_cfu start_main unless $@
  def start_main
    @performed_actors = []
    start_main_cfu
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def set_next_active_battler
    @performed_actors = [] if @performed_actors == nil
    loop do
      if $game_troop.forcing_battler != nil
        @active_battler = $game_troop.forcing_battler
        @action_battlers.delete(@active_battler)
        $game_troop.forcing_battler = nil
      else
        make_action_orders
        @action_battlers -= @performed_actors
        @active_battler = @action_battlers.shift
      end
      @performed_actors.push(@active_battler) unless @active_battler == nil
      return if @active_battler == nil
      return if @active_battler.index != nil
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def wait_for_animation
    update_basic
    update_basic while @spriteset.animation?
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def display_normal_animation(targets, animation_id, mirror = false)
    animation = $data_animations[animation_id]
    if animation != nil
      to_screen = (animation.position == 3)
      ani_check = false
      for target in targets.uniq
        if ani_check
          target.pseudo_ani_id = animation_id
        else
          target.animation_id = animation_id
          target.animation_mirror = mirror
        end
        ani_check = true if to_screen
        wait(20, true) unless to_screen
      end
      wait(20, true) if to_screen
    end
  end
  
end # Scene_Battle

#===============================================================================
# Window_Base
#===============================================================================

class Window_Base < Window
  
  #--------------------------------------------------------------------------
  # alias 方法：initialize
  #--------------------------------------------------------------------------
  alias initialize_window_base initialize unless $@
  def initialize(x, y, width, height)
    initialize_window_base(x, y, width, height)
    self.contents.font.color = normal_color
    if $game_temp.in_battle
      $disposable_battle_windows = [] if $disposable_battle_windows == nil
      $disposable_battle_windows.push(self)
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def dispose
    if $game_temp.in_battle
      $disposable_battle_windows = [] if $disposable_battle_windows == nil
      $disposable_battle_windows.delete(self)
    end
    if self.disposed?
      if $TEST or $BTEST
        p "Failure to dispose Nil window."
        p self
      end
    else
      self.contents.dispose
    end
    super
  end
  
  #--------------------------------------------------------------------------
  # alias 方法：create_contents
  #--------------------------------------------------------------------------
  alias create_contents_base_cfu create_contents unless $@
  def create_contents
    create_contents_base_cfu
    self.contents.font.color = normal_color
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def normal_color; return text_color(YEM::UPGRADE::COLOURS[:normal]); end
  def system_color; return text_color(YEM::UPGRADE::COLOURS[:system]); end
  def crisis_color; return text_color(YEM::UPGRADE::COLOURS[:crisis]); end
  def lowmp_color; return text_color(YEM::UPGRADE::COLOURS[:lowmp]); end
  def knockout_color; return text_color(YEM::UPGRADE::COLOURS[:knockout]); end
  def gauge_back_color; return text_color(YEM::UPGRADE::COLOURS[:gaugeback]); end
  def exhaust_color; return text_color(YEM::UPGRADE::COLOURS[:exhaust]); end
  def hp_back_color; return text_color(YEM::UPGRADE::COLOURS[:hp_back]); end
  def hp_gauge_color1; return text_color(YEM::UPGRADE::COLOURS[:hp_gauge1]); end
  def hp_gauge_color2; return text_color(YEM::UPGRADE::COLOURS[:hp_gauge2]); end
  def mp_back_color; return text_color(YEM::UPGRADE::COLOURS[:mp_back]); end
  def mp_gauge_color1; return text_color(YEM::UPGRADE::COLOURS[:mp_gauge1]); end
  def mp_gauge_color2; return text_color(YEM::UPGRADE::COLOURS[:mp_gauge2]); end
  def power_up_color; return text_color(YEM::UPGRADE::COLOURS[:power_up]); end
  def power_down_color; return text_color(YEM::UPGRADE::COLOURS[:power_dn]); end
    
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def hp_color(actor)
    return knockout_color if actor.hp == 0
    return crisis_color if actor.hp < (actor.maxhp*YEM::UPGRADE::CRISIS_HP/100)
    return normal_color
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def mp_color(actor)
    return lowmp_color if actor.mp < (actor.maxmp*YEM::UPGRADE::CRISIS_MP/100)
    return normal_color
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_hp_gauge(actor, x, y, width = 120)
    actor.hp = [actor.hp, actor.maxhp].min
    gc0 = hp_back_color
    gc1 = hp_gauge_color1
    gc2 = hp_gauge_color2
    gh = YEM::UPGRADE::GAUGE_HEIGHT
    gh += 2 if YEM::UPGRADE::OUTLINE
    gy = y + WLH - 8 - (gh - 6)
    self.contents.fill_rect(x, gy, width, gh, gc0)
    gy += 1 if YEM::UPGRADE::OUTLINE
    gh -= 2 if YEM::UPGRADE::OUTLINE
    width -= 2 if YEM::UPGRADE::OUTLINE
    maxhp = [[actor.maxhp, actor.base_maxhp, 1].max, actor.maxhp_limit].min
    gbw = width * actor.hp / maxhp
    x += 1 if YEM::UPGRADE::OUTLINE
    self.contents.gradient_fill_rect(x, gy, gbw, gh, gc1, gc2)
    return unless maxhp > actor.maxhp
    dw = width * (actor.base_maxhp - actor.maxhp) / actor.base_maxhp
    dx = x + width - dw
    self.contents.fill_rect(dx, gy, dw, gh, exhaust_color)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_mp_gauge(actor, x, y, width = 120, height = nil)
    actor.mp = [actor.mp, actor.maxmp].min
    gc0 = mp_back_color
    gc1 = mp_gauge_color1
    gc2 = mp_gauge_color2
    gh = YEM::UPGRADE::GAUGE_HEIGHT
    gh += 2 if YEM::UPGRADE::OUTLINE
    gy = y + WLH - 8 - (gh - 6)
    self.contents.fill_rect(x, gy, width, gh, gc0)
    gy += 1 if YEM::UPGRADE::OUTLINE
    gh -= 2 if YEM::UPGRADE::OUTLINE
    width -= 2 if YEM::UPGRADE::OUTLINE
    maxmp = [[actor.maxmp, actor.base_maxmp, 1].max, actor.maxmp_limit].min
    gbw = width * actor.mp / maxmp
    x += 1 if YEM::UPGRADE::OUTLINE
    self.contents.gradient_fill_rect(x, gy, gbw, gh, gc1, gc2)
    return unless maxmp > actor.maxmp
    dw = width * (actor.base_maxmp - actor.maxmp) / [actor.base_maxmp, 1].max
    dx = x + width - dw
    self.contents.fill_rect(dx, gy, dw, gh, exhaust_color)
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：draw_actor_rage_gauge
  #--------------------------------------------------------------------------
  def draw_actor_rage_gauge(actor, x, y, width = 120, height = nil)
    gc0 = gauge_back_color
    gc1 = text_color(YEM::BATTLE_ENGINE::RAGE[:rage_gauge1])
    gc2 = text_color(YEM::BATTLE_ENGINE::RAGE[:rage_gauge2])
    gh = YEM::UPGRADE::GAUGE_HEIGHT
    gh += 2 if YEM::UPGRADE::OUTLINE
    gy = y + WLH - 8 - (gh - 6)
    self.contents.fill_rect(x, gy, width, gh, gc0)
    gy += 1 if YEM::UPGRADE::OUTLINE
    gh -= 2 if YEM::UPGRADE::OUTLINE
    width -= 2 if YEM::UPGRADE::OUTLINE
    gw = [[width * actor.rage / actor.max_rage, width].min, 0].max
    x += 1 if YEM::UPGRADE::OUTLINE
    self.contents.gradient_fill_rect(x, gy, gw, gh, gc1, gc2)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_actor_state(actor, x, y, width = 96)
    count = 0
    for state in actor.states
      next if state.icon_index == 0
      next if state.hide_state
      draw_icon(state.icon_index, x + 24 * count, y)
      draw_state_turns(x + 24 * count, y, state, actor)
      count += 1
      break if (24 * count > width - 24)
    end
    self.contents.font.color = normal_color
    self.contents.font.bold = Font.default_bold
    self.contents.font.size = Font.default_size
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：draw_state_turns
  #--------------------------------------------------------------------------
  def draw_state_turns(x, y, state, actor)
    return unless YEM::UPGRADE::DRAW_STATE_TURNS
    return if state == nil
    return unless actor.state_turns.include?(state.id)
    dy = y - (YEM::UPGRADE::STATE_TURN_F_SIZE - 10)
    duration = actor.state_turns[state.id] 
    if state.auto_release_prob > 0 and duration >= 0
      self.contents.font.color = text_color(state.turn_colour)
      self.contents.font.size = YEM::UPGRADE::STATE_TURN_F_SIZE
      self.contents.font.bold = YEM::UPGRADE::STATE_TURN_BOLD
      self.contents.draw_text(x, dy, 24, WLH, duration, 2)
    end
  end
  
end # Window_Base

#===============================================================================
# Window_Selectable
#===============================================================================

class Window_Selectable < Window_Base

  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_contents
    self.contents.dispose
    maxbitmap = 8192
    dw = [width - 32, maxbitmap].min
    dh = [[height - 32, row_max * WLH].max, maxbitmap].min
    bitmap = Bitmap.new(dw, dh)
    self.contents = bitmap
    self.contents.font.color = normal_color
  end
  
end # Window_Selectable

#===============================================================================
# Window_Help
#===============================================================================

class Window_Help < Window_Base
  
  #--------------------------------------------------------------------------
  # alias 方法：set_text
  #--------------------------------------------------------------------------
  alias set_text_cfu set_text unless $@
  def set_text(text, align = 0)
    text = text.clone
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    text.gsub!(/\\N\[0\]/i)        { current_actor }
    text.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    set_text_cfu(text, align)
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：current_actor
  #--------------------------------------------------------------------------
  def current_actor
    if $scene.is_a?(Scene_Skill) or $scene.is_a?(Scene_Equip)
      return $scene.actor.name
    elsif $scene.is_a?(Scene_Battle) and $scene.active_battler != nil
      return $scene.active_battler.name
    else
      return YEM::UPGRADE::HELP_WINDOW_0
    end
  end
  
end # Window_Help

#==============================================================================
# Window_Item
#==============================================================================

class Window_Item < Window_Selectable

  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    return false if $game_temp.in_battle and !$game_party.item_can_use?(item)
    return true
  end
  
end # Window_Item

#===============================================================================
# Window_Message
#===============================================================================

class Window_Message < Window_Selectable
  
  #--------------------------------------------------------------------------
  # alias 方法：convert_special_characters
  #--------------------------------------------------------------------------
  alias convert_special_characters_cfu convert_special_characters unless $@
  def convert_special_characters
    @text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    @text.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    @text.gsub!(/\\N\[0\]/i)        { $game_party.members[0].name }
    @text.gsub!(/\\F\[0\]/i)        { leader_face_art }
    convert_special_characters_cfu
  end
  
  #--------------------------------------------------------------------------
  # 新增方法：leader_face_art
  #--------------------------------------------------------------------------
  def leader_face_art
    $game_message.face_name  = $game_party.members[0].face_name
    $game_message.face_index = $game_party.members[0].face_index
    return ""
  end
  
end # Window_Message

#===============================================================================
# 
# 
#===============================================================================