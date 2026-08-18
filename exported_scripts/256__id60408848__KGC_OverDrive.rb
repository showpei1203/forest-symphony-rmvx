#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：KGC_OverDrive
# 系統：OverDrive System｜KGC｜VX｜最後更新 2008-08-28
# 原翻譯：Touchfuzzy｜擴充翻譯／更新：Mr. Anonymous
#
# 【用途】
# 提供 OD／OverDrive 量表。戰鬥者依攻擊、受傷、勝利、逃跑、孤軍、行動、瀕死、
# 防禦等行為取得 OP；量表達到條件後可使用標記為 OverDrive 的技能。
# Forest Symphony 後方仍有 STR11+og_KGC Overdrive、OD UI 與 FS Battle 整合，
# 因此本頁是正式底層，不可只看年代就刪除。
#
# 【技能 Notetag】
# <overdrive>            # 把技能標記為 OverDrive；未達 OD 成本時不可使用
# <overdrive 500>        # 原正規表示式亦允許指定 OD 成本
# <OD_gain 200%>         # 此技能造成 OD 增加時乘以 200%
# 量表增加倍率計算核心概念：基礎 Gain × n / 100。
#
# 【事件 Script Call】
# gain_actor_od_gauge(actor_id, value)
# gain_enemy_od_gauge(enemy_index, value)
# set_actor_drive_type(actor_id, [types])
# set_enemy_drive_type(enemy_index, [types])
# get_actor_od_gauge(actor_id, variable_id=0)
# get_enemy_od_gauge(enemy_index, variable_id=0)
# set_actor_od_gauge_number(actor_id, number)
# set_enemy_od_gauge_number(enemy_index, number)
# actor_od_gauge_max?(actor_id)
# enemy_od_gauge_max?(enemy_index)
# actor_id / enemy_index 使用 -1 時代表全體；value 可用負數扣除 OD。
# set_*_drive_type 的 types 省略時會回到預設 Drive Type。
#
# 【主要設定】
# GAUGE_MAX：單格 OD 量表最大值，現為 1000。
# GAIN_RATE：8 種增加來源：
#   0 ATTACK  攻擊；1 DAMAGE 受傷；2 VICTORY 擊倒敵人／勝利類；3 ESCAPE 逃跑；
#   4 ALONE 孤軍；5 ACTION 行動；6 FATAL 低 HP 生存；7 GUARD 防禦。
# DAMAGE 是依「受到相當於 MaxHP 100% 的傷害」換算，因此數值 500 代表約承受兩倍
# MaxHP 累積傷害可填滿 GAUGE_MAX=1000。
# DEFAULT_GAUGE_NUMBER：可累積的量表格數；畫面仍以一條連續量表顯示。
# DEFAULT_ACTOR_DRIVE_TYPE / DEFAULT_ENEMY_DRIVE_TYPE：預設啟用哪些 Gain Type。
# GAUGE_NORMAL_START_COLOR / END_COLOR：一般量表漸層色。
# GAUGE_MAX_START_COLOR / END_COLOR：滿格量表漸層色。
# GAUGE_OFFSET_Y：OD 量表 Y 偏移；-8 可與 HP／MP 量表接近同一深度。
# GAUGE_VALUE_STYLE：0不顯示、1直接值、2百分比、3一位小數、4兩位小數、5滿格次數。
# GAUGE_VALUE_FONT_SIZE：數值字體大小。
# EMPTY_ON_DEAD：死亡後是否把 OD 歸零。
# HIDE_GAUGE_ACTOR：永久隱藏指定 Actor ID 的 OD。
# HIDE_GAUGE_NOT_IN_BATTLE：非戰鬥 Menu 是否隱藏。
# HIDE_GAUGE_NO_OD_SKILLS：沒有 OD 技能時是否隱藏。
# NOT_GAIN_GAUGE_HIDING：若因沒有 OD 技能而隱藏，是否同時禁止取得 OP。
# HIDE_SKILL_LACK_OF_GAUGE：OD 不足時是否直接把技能從 Skill Window 隱藏。
# USE_IMAGE_GAUGE：true 使用 Graphics/System 內自訂量表圖片。
# GAUGE_IMAGE：圖片基礎名稱；目前 "gauge_od"。
# GAUGE_POSITION / GAUGE_LENGTH：Menu 量表位置／長度。
# GAUGE_POSITION_BATTLE / GAUGE_LENGTH_BATTLE：Battle 量表位置／長度。
# ODMAX_SOUND：量表滿格時 SE，目前 Flash2。
#
# NONE=0、IMMEDIATE=1、RATE=2、RATE_DETAIL1=3、RATE_DETAIL2=4、NUMBER=5。
#
# 【修改原則】
# 1. Notetag、KGC::Commands 方法名與 Type 常數是其他腳本可能直接引用的 API，不可翻名。
# 2. FS 後續腳本會再處理 OD 顯示／戰鬥結果；搬動前查 LoadOrder Guide。
# 3. 若只要調平衡，優先改 GAUGE_MAX / GAIN_RATE / Drive Type，不要改底層 alias。
#
# 【素材】
# USE_IMAGE_GAUGE=true 時會使用 Graphics/System/gauge_od 系列圖片；ODMAX_SOUND 使用
# Audio/SE/Flash2。刪除前需反查 STR11+og 與 FS OD 擴充。
#==============================================================================
#=============================================================================#
#=============================================================================#

module KGC
  module OverDrive
  GAUGE_MAX = 1000

  GAIN_RATE = [
     10,
    500,
    200,
    100 ,
    160,
     40,
    160,
     50,
  ]

  DEFAULT_GAUGE_NUMBER = 1

  DEFAULT_ACTOR_DRIVE_TYPE = [0,1,2,6]
  
  DEFAULT_ENEMY_DRIVE_TYPE = [0, 1, 4, 5, 6]

  GAUGE_NORMAL_START_COLOR = 14
  GAUGE_NORMAL_END_COLOR   = 6
  GAUGE_MAX_START_COLOR    = 10
  GAUGE_MAX_END_COLOR      = 2

  GAUGE_OFFSET_Y = -8
  
  GAUGE_VALUE_STYLE = 2
  
  GAUGE_VALUE_FONT_SIZE = 13

  EMPTY_ON_DEAD = false 

  HIDE_GAUGE_ACTOR = []
  
  #   true＝隱藏量表。
  #   false＝即使在 Menu 中仍持續顯示量表。
  HIDE_GAUGE_NOT_IN_BATTLE = true

  #  true＝隱藏量表。
  #  false＝不隱藏量表。
  HIDE_GAUGE_NO_OD_SKILLS  = true

  NOT_GAIN_GAUGE_HIDING    = true
  
  #  true＝隱藏 OD 不足的技能。
  #  false＝仍顯示 OD 不足的技能。
  HIDE_SKILL_LACK_OF_GAUGE = false
  
  USE_IMAGE_GAUGE = true
  GAUGE_IMAGE  = "gauge_od"
  
  GAUGE_POSITION = [-32, -8]
  GAUGE_LENGTH   = 52
  
  GAUGE_POSITION_BATTLE = [-32, -8]
  
  GAUGE_LENGTH_BATTLE   = 52
  
  ODMAX_SOUND = RPG::SE.new("Flash2",     100,    150)
  end
end

#=============================================================================#
#=============================================================================#

#=================================================#
#=================================================#

$imported = {} if $imported == nil
$imported["OverDrive"] = true

#=================================================#

module KGC::OverDrive
  # OD 增加類型模組
  module Type
    ATTACK  = 0  # 攻擊
    DAMAGE  = 1  # 受傷
    VICTORY = 2  # 勝利
    ESCAPE  = 3  # 逃跑
    ALONE   = 4  # 孤軍
    ACTION  = 5  # 行動
    FATAL   = 6  # 瀕死
    GUARD   = 7  # 防禦
  end

#=================================================#  
  
  # OD 量表數值顯示模式
  module ValueStyle
    NONE         = 0  # 不顯示
    IMMEDIATE    = 1  # 直接數值
    RATE         = 2  # 比例 1
    RATE_DETAIL1 = 3  # 比例 2
    RATE_DETAIL2 = 4  # 比例 3
    NUMBER       = 5  # 量表滿格次數
  end

#==============================================================================
#==============================================================================
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
# * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * #
  
  # 正規表示式模組
  module Regexp
    # 技能模組
    module Skill
      # OverDrive Notetag 正規表示式
      OVER_DRIVE = /<(?:OVER_DRIVE|overdrive)\s*(\d+)?>/i
      # OD 增加率 Notetag 正規表示式
      OD_GAIN_RATE = /<(?:OD_GAIN_RATE|OD_gain)\s*(\d+)[%％]?>/i
    end
  end
end

#=================================================#

#==============================================================================
#==============================================================================

module KGC
  module Commands
    module_function
  #--------------------------------------------------------------------------
  #     actor_id：Actor ID（-1 = 全隊）
  #     value：增加量（可用負數扣除）
  #--------------------------------------------------------------------------
    def gain_actor_od_gauge(actor_id, value)
      if actor_id == -1
        $game_party.existing_members.each { |actor|
          actor.overdrive += value
        }
      else
        actor = $game_actors[actor_id]
        actor.overdrive += value if actor != nil && actor.exist?
      end
    end
  #--------------------------------------------------------------------------
  #     enemy_index：敵方索引（-1 = 全敵）
  #     value：增加量（可用負數扣除）
  #--------------------------------------------------------------------------
    def gain_enemy_od_gauge(enemy_index, value)
      if enemy_index == -1
        $game_troop.existing_members.each { |enemy|
          enemy.overdrive += value
        }
      else
        enemy = $game_troop.members[enemy_index]
        enemy.overdrive += value if enemy != nil && enemy.exist?
      end
    end
  #--------------------------------------------------------------------------
  #     actor_id：Actor ID（-1 = 全隊）
  #     variable_id：Variable ID
  #--------------------------------------------------------------------------
    def get_actor_od_gauge(actor_id, variable_id = 0)
      actor = $game_actors[actor_id]
      n = (actor != nil ? actor.overdrive : 0)
      if variable_id > 0
        $game_variables[variable_id] = n
      end
      return n
    end
  #--------------------------------------------------------------------------
  #     enemy_index：敵方索引（-1 = 全敵）
  #     variable_id：Variable ID
  #--------------------------------------------------------------------------
    def get_enemy_od_gauge(enemy_index, variable_id = 0)
      enemy = $game_troop.members[enemy_index]
      n = (enemy != nil ? enemy.overdrive : 0)
      if variable_id > 0
        $game_variables[variable_id] = n
      end
      return n
    end
  #--------------------------------------------------------------------------
  #     actor_id：Actor ID（-1 = 全隊）
  #     number：量表格數陣列
  #--------------------------------------------------------------------------
    def set_actor_od_gauge_number(actor_id, number)
      if actor_id == -1
        $game_party.members.each { |actor|
          actor.drive_gauge_number = number
        }
      else
        actor = $game_actors[actor_id]
        actor.drive_gauge_number = number if actor != nil
      end
    end
  #--------------------------------------------------------------------------
  #     enemy_index：Enemy ID
  #     number：量表格數陣列
  #--------------------------------------------------------------------------
    def set_enemy_od_gauge_number(enemy_index, number)
      if enemy_index == -1
        $game_troop.members.each { |enemy|
          enemy.drive_gauge_number = number
        }
      else
        enemy = $game_troop.members[enemy_index]
        enemy.drive_gauge_number = number if enemy != nil
      end
    end
  #--------------------------------------------------------------------------
  #     actor_id：Actor ID
  #--------------------------------------------------------------------------
  def actor_od_gauge_max?(actor_id)
    actor = $game_actors[actor_id]
    return false if actor == nil
    return actor.overdrive == actor.max_overdrive
  end
   #--------------------------------------------------------------------------
  #     enemy_index：敵方索引
  #--------------------------------------------------------------------------
  def enemy_od_gauge_max?(enemy_index)
    enemy = $game_troop.members[enemy_index]
    return false if enemy == nil
    return enemy.overdrive == enemy.max_overdrive
  end
  #--------------------------------------------------------------------------
  #     actor_id：Actor ID（-1 = 全隊）
  #     types：Drive Type 陣列（省略時恢復預設）
  #--------------------------------------------------------------------------
  def set_actor_drive_type(actor_id, types = nil)
    if actor_id == -1
      $game_party.members.each { |actor|
        actor.drive_type = types
      }
    else
      actor = $game_actors[actor_id]
      actor.drive_type = types if actor != nil
    end
  end
  #--------------------------------------------------------------------------
  #     types：Drive Type 陣列（省略時恢復預設）
  #--------------------------------------------------------------------------
  def set_enemy_drive_type(enemy_index, types = nil)
    if enemy_index == -1
      $game_troop.members.each { |enemy|
        enemy.drive_type = types
      }
    else
      enemy = $game_troop.members[enemy_index]
      enemy.drive_type = types if enemy != nil
    end
  end
end
end

#=================================================#

#==============================================================================
#==============================================================================

class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_overdrive_cache
    @__is_overdrive = false
    @__od_cost = KGC::OverDrive::GAUGE_MAX
    @__od_gain_rate = 100

    self.note.split(/[\r\n]+/).each { |line|
      case line
      when KGC::OverDrive::Regexp::Skill::OVER_DRIVE
        # OverDrive 判定
        @__is_overdrive = true
        @__od_cost = $1.to_i if $1 != nil
      when KGC::OverDrive::Regexp::Skill::OD_GAIN_RATE
        # 量表增加率
        @__od_gain_rate = $1.to_i
      end
    }

    unless @__is_overdrive
      @__od_cost = 0
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def overdrive?
    create_overdrive_cache if @__is_overdrive == nil
    return @__is_overdrive
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def od_cost
    create_overdrive_cache if @__od_cost == nil
    return @__od_cost
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def od_gain_rate
    create_overdrive_cache if @__od_gain_rate == nil
    return @__od_gain_rate
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開實例變數
  #--------------------------------------------------------------------------
  attr_writer   :drive_type
  attr_writer   :odmax_sound_played
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def overdrive
    @overdrive = 0 if @overdrive == nil
    return @overdrive
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def overdrive=(value)
    @overdrive = [[value, max_overdrive].min, 0].max
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def max_overdrive
    return KGC::OverDrive::GAUGE_MAX * drive_gauge_number
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_gauge_number
    if @drive_gauge_number == nil
      @drive_gauge_number = KGC::OverDrive::DEFAULT_GAUGE_NUMBER
    end
    return @drive_gauge_number
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_gauge_number=(value)
    @drive_gauge_number = [value, 1].max
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_type
    return []
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def overdrive_skill_learned?
    return true
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def od_gauge_visible?
    return false
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def can_gain_overdrive?
    return true
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def odmax_sound
    return KGC::OverDrive::ODMAX_SOUND
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def odmax_sound_played
   # return true
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_attack?
    return drive_type.include?(KGC::OverDrive::Type::ATTACK)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_damage?
    return drive_type.include?(KGC::OverDrive::Type::DAMAGE)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_victory?
    return drive_type.include?(KGC::OverDrive::Type::VICTORY)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_escape?
    return drive_type.include?(KGC::OverDrive::Type::ESCAPE)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_alone?
    return drive_type.include?(KGC::OverDrive::Type::ALONE)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_action?
    return drive_type.include?(KGC::OverDrive::Type::ACTION)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_fatal?
    return drive_type.include?(KGC::OverDrive::Type::FATAL)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_guard?
    return drive_type.include?(KGC::OverDrive::Type::GUARD)
  end
  #--------------------------------------------------------------------------
  #     state_id：State ID
  #--------------------------------------------------------------------------
  alias add_state_KGC_OverDrive add_state
  def add_state(state_id)
    add_state_KGC_OverDrive(state_id)

    reset_overdrive_on_dead if dead?
  end
  #--------------------------------------------------------------------------
  #     skill：Skill 物件
  #--------------------------------------------------------------------------
  def calc_od_cost(skill)
    return 0 unless skill.is_a?(RPG::Skill)

    return skill.od_cost
  end
  #--------------------------------------------------------------------------
  #     skill：Skill 物件
  #--------------------------------------------------------------------------
  alias skill_can_use_KGC_OverDrive? skill_can_use?
  def skill_can_use?(skill)
    return false unless skill_can_use_KGC_OverDrive?(skill)

    return false if calc_od_cost(skill) > overdrive
    return true
  end
  #--------------------------------------------------------------------------
  #     user：Skill／Item 使用者
  #--------------------------------------------------------------------------
  alias execute_damage_KGC_OverDrive execute_damage
  def execute_damage(user)
    execute_damage_KGC_OverDrive(user)

    increase_overdrive(user)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def reset_overdrive_on_dead
    return unless KGC::OverDrive::EMPTY_ON_DEAD

    self.overdrive = 0
  end
  #--------------------------------------------------------------------------
  #     attacker：攻擊者
  #--------------------------------------------------------------------------
  def increase_overdrive(attacker = nil)
    return unless attacker.is_a?(Game_Battler)
    return if self.class == attacker.class
    return if hp_damage == 0 && mp_damage == 0
    # 若該戰鬥者目前允許取得 OverDrive……
    if can_gain_overdrive?
      increase_attacker_overdrive(attacker)
      increase_defender_overdrive(attacker)
    end
    reset_overdrive_on_dead if dead?
  end
  #--------------------------------------------------------------------------
  #     attacker：攻擊者
  #--------------------------------------------------------------------------
  def increase_attacker_overdrive(attacker)
    return unless attacker.drive_attack?

    od_gain = KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::ATTACK]
    if attacker.action.kind == 1
      rate = attacker.action.skill.od_gain_rate
      od_gain = od_gain * rate / 100
      if rate > 0
        od_gain = [od_gain, 1].max
      elsif rate < 0
        od_gain = [od_gain, -1].min
      end
    end
    attacker.overdrive += od_gain
    #----------------------------------------------------------------
    #  Mr. Anonymous 於 2008-08-19 新增
    #----------------------------------------------------------------
    if attacker.overdrive < KGC::OverDrive::GAUGE_MAX
      attacker.odmax_sound_played = false
    end
    if attacker.odmax_sound_played == false 
      if attacker.overdrive == KGC::OverDrive::GAUGE_MAX
        odmax_sound.play
        attacker.odmax_sound_played = true
      end
    end
    #----------------------------------------------------------------
    #----------------------------------------------------------------
  end
  #--------------------------------------------------------------------------
  #     attacker：攻擊者
  #--------------------------------------------------------------------------
  def increase_defender_overdrive(attacker)
    return unless self.drive_damage?

    rate = KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::DAMAGE]
    od_gain = 0
    od_gain += hp_damage * rate / maxhp if hp_damage > 0
    od_gain += mp_damage * rate / maxmp if mp_damage > 0 && maxmp > 0
    if rate > 0
      od_gain = [od_gain, 1].max
    elsif rate < 0
      od_gain = [od_gain, -1].min
    end
    self.overdrive += od_gain
    #----------------------------------------------------------------
    #  Mr. Anonymous 於 2008-08-19 新增
    #----------------------------------------------------------------
    if self.overdrive < KGC::OverDrive::GAUGE_MAX
      self.odmax_sound_played = false
    end
    if self.odmax_sound_played == false 
      if self.overdrive == KGC::OverDrive::GAUGE_MAX
        odmax_sound.play
        self.odmax_sound_played = true
      end
    end
    #----------------------------------------------------------------
    #----------------------------------------------------------------
  end
  #--------------------------------------------------------------------------
  #     user：使用者
  #     skill：Skill 物件
  #--------------------------------------------------------------------------
  alias skill_effect_KGC_OverDrive skill_effect
  def skill_effect(user, skill)
    skill_effect_KGC_OverDrive(user, skill)

    # 若已匯入 KGC_ReproduceFunctions，且 Item 帶有執行 Skill 的標記，避免重複處理 OD。
    if $imported["ReproduceFunctions"] && $game_temp.exec_skill_on_item
      return
    end
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  #     actor_id：Actor ID
  #--------------------------------------------------------------------------
  alias setup_KGC_OverDrive setup
  def setup(actor_id)
    setup_KGC_OverDrive(actor_id)

    @overdrive = 0
    @drive_type = nil
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_type
    unless @drive_type.is_a?(Array)
      return KGC::OverDrive::DEFAULT_ACTOR_DRIVE_TYPE
    end
    return @drive_type
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def overdrive_skill_learned?
    result = false
    # 暫時取消戰鬥旗標
    last_in_battle = $game_temp.in_battle
    $game_temp.in_battle = false

    self.skills.each { |skill|
      if skill.overdrive?
        result = true
        break
      end
    }
    $game_temp.in_battle = last_in_battle
    return result
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def can_gain_overdrive?
    if KGC::OverDrive::NOT_GAIN_GAUGE_HIDING
      # 隱藏
      return false if KGC::OverDrive::HIDE_GAUGE_ACTOR.include?(self.id)
    end
    if KGC::OverDrive::HIDE_GAUGE_NO_OD_SKILLS
      # 尚未學會
      return false unless overdrive_skill_learned?
    end

    return true
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def od_gauge_visible?
    # 戰鬥中隱藏量表
    if KGC::OverDrive::HIDE_GAUGE_NOT_IN_BATTLE && !$game_temp.in_battle
      return false
    end
    # 隱藏量表
    return false if KGC::OverDrive::HIDE_GAUGE_ACTOR.include?(self.id)
    return false unless can_gain_overdrive?

    return true
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 物件初始化
  #     index：敵群索引
  #     enemy_id：Enemy ID
  #--------------------------------------------------------------------------
  alias initialize_KGC_OverDrive initialize
  def initialize(index, enemy_id)
    initialize_KGC_OverDrive(index, enemy_id)

    @overdrive = 0
    @drive_type = nil
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def drive_type
    unless @drive_type.is_a?(Array)
      return KGC::OverDrive::DEFAULT_ENEMY_DRIVE_TYPE
    end
    return @drive_type
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Window_Base < Window
  #----------------------------------------------------------------------
  # 判定量表圖片模式
  # - Mr. Anonymous 於 2008-08-19 新增
  #----------------------------------------------------------------------
  if KGC::OverDrive::USE_IMAGE_GAUGE = false
    #--------------------------------------------------------------------------
    #--------------------------------------------------------------------------
    def od_gauge_normal_color1
      color = KGC::OverDrive::GAUGE_NORMAL_START_COLOR
      return (color.is_a?(Integer) ? text_color(color) : color)
    end
    #--------------------------------------------------------------------------
    #--------------------------------------------------------------------------
    def od_gauge_normal_color2
      color = KGC::OverDrive::GAUGE_NORMAL_END_COLOR
      return (color.is_a?(Integer) ? text_color(color) : color)
    end
    #--------------------------------------------------------------------------
    #--------------------------------------------------------------------------
    def od_gauge_max_color1
      color = KGC::OverDrive::GAUGE_MAX_START_COLOR
      return (color.is_a?(Integer) ? text_color(color) : color)
    end
    #--------------------------------------------------------------------------
    #--------------------------------------------------------------------------
    def od_gauge_max_color2
      color = KGC::OverDrive::GAUGE_MAX_END_COLOR
      return (color.is_a?(Integer) ? text_color(color) : color)
    end
  end
  #--------------------------------------------------------------------------
  #     actor：Actor
  #     x：X 座標
  #     y：Y 座標
  #--------------------------------------------------------------------------
  alias draw_actor_name_KGC_OverDrive draw_actor_name
  def draw_actor_name(actor, x, y)
    draw_actor_od_gauge(actor, x, y, 108)
    draw_actor_name_KGC_OverDrive(actor, x, y)
  end
  #----------------------------------------------------------------------
  # 判定量表圖片模式
  # - Mr. Anonymous 於 2008-08-19 新增
  #----------------------------------------------------------------------
  if KGC::OverDrive::USE_IMAGE_GAUGE = false
    #--------------------------------------------------------------------------
    #     actor：Actor
    #     x：X 座標
    #     y：Y 座標
    #     width：寬度
    #--------------------------------------------------------------------------
    def draw_actor_od_gauge(actor, x, y, width = 120)
      return unless actor.od_gauge_visible?

      n = actor.overdrive % KGC::OverDrive::GAUGE_MAX
      n = KGC::OverDrive::GAUGE_MAX if actor.overdrive == actor.max_overdrive
      gw = width * n / KGC::OverDrive::GAUGE_MAX
      gc1 = (gw == width ? od_gauge_max_color1 : od_gauge_normal_color1)
      gc2 = (gw == width ? od_gauge_max_color2 : od_gauge_normal_color2)
      self.contents.fill_rect(x, y + WLH + KGC::OverDrive::GAUGE_OFFSET_Y,
        width, 6, gauge_back_color)
      self.contents.gradient_fill_rect(
        x, y + WLH + KGC::OverDrive::GAUGE_OFFSET_Y, gw, 6, gc1, gc2)

      draw_actor_od_gauge_value(actor, x, y, width)
    end
  #----------------------------------------------------------------------
  # 判定量表圖片模式
  # - Mr. Anonymous 於 2008-08-19 新增
  #----------------------------------------------------------------------
  else 
    #--------------------------------------------------------------------------
    #     actor：Actor
    #     x：X 座標
    #     y：Y 座標
    #     in_width：內部寬度
    #--------------------------------------------------------------------------
    def draw_actor_od_gauge(actor, x, y, in_width)
      return unless actor.od_gauge_visible?
      
      bitmap = self.contents 
      gauge = Bitmap.new("Graphics/System/" + KGC::OverDrive::GAUGE_IMAGE)
      nx = x
      ny = y
      nw = in_width
      if $game_temp.in_battle
        nx += KGC::OverDrive::GAUGE_POSITION_BATTLE[0]
        ny += KGC::OverDrive::GAUGE_POSITION_BATTLE[1]
        nw += KGC::OverDrive::GAUGE_LENGTH_BATTLE
      else
        nx += KGC::OverDrive::GAUGE_POSITION[0]
        ny += KGC::OverDrive::GAUGE_POSITION[1]
        nw += KGC::OverDrive::GAUGE_LENGTH
      end
      gauge_width = calc_od_gauge_width(actor, nw)
      full = (gauge_width == nw - 64)
      draw_od_gauge_back(bitmap, gauge, nx, ny, nw)
      draw_od_gauge_inside(bitmap, gauge, nx, ny, nw, gauge_width, full)
      draw_od_gauge_fore(bitmap, gauge, nx, ny, nw)
      draw_actor_od_gauge_value(actor, x, y, width)
    end
    #--------------------------------------------------------------------------
    #     image：量表圖片
    #     in_width：量表內部寬度
    #--------------------------------------------------------------------------
    def draw_od_gauge_back(bitmap, image, x, y, in_width)
      src_rect = Rect.new(0, 0, 32, 32)
      bitmap.blt(x, y, image, src_rect)
      src_rect.set(32, 0, 96, 32)
      dest_rect = Rect.new(x + 32, y, in_width - 64, 32)
      bitmap.stretch_blt(dest_rect, image, src_rect)
      src_rect.set(128, 0, 32, 32)
      bitmap.blt(x + in_width - 32, y, image, src_rect)
    end
    #--------------------------------------------------------------------------
    #     image：量表圖片
    #     in_width：量表內部寬度
    #     gauge_width：量表外部寬度
    #     full：是否滿格
    #--------------------------------------------------------------------------
    def draw_od_gauge_inside(bitmap, image, x, y, in_width, gauge_width, full)
      src_rect = Rect.new(0, (full ? 64 : 32), 0, 32)
      src_rect.width = gauge_width * 96 / (in_width - 64)
      dest_rect = Rect.new(x + 32, y, gauge_width, 32)
      bitmap.stretch_blt(dest_rect, image, src_rect)
    end
    #--------------------------------------------------------------------------
    #     image：量表圖片
    #     in_width：量表內部寬度
    #--------------------------------------------------------------------------
    def draw_od_gauge_fore(bitmap, image, x, y, in_width)
      src_rect = Rect.new(160, 0, 32, 32)
      bitmap.blt(x, y, image, src_rect)
      src_rect.set(192, 0, 96, 32)
      dest_rect = Rect.new(x + 32, y, in_width - 64, 32)
      bitmap.stretch_blt(dest_rect, image, src_rect)
      src_rect.set(288, 0, 32, 32)
      bitmap.blt(x + in_width - 32, y, image, src_rect)
    end
    #--------------------------------------------------------------------------
    #--------------------------------------------------------------------------
    def calc_od_gauge_width(actor, in_width)
      gw = actor.overdrive * (in_width - 64) / KGC::OverDrive::GAUGE_MAX
      return [[gw, 0].max, in_width - 64].min
    end
  #----------------------------------------------------------------------
  # 結束量表圖片模式判定
  # 結束 KGC::OverDrive::USE_IMAGE_GAUGE 條件分支
  #----------------------------------------------------------------------  
  end 
  #--------------------------------------------------------------------------
  #     actor：Actor
  #     x：X 座標
  #     y：Y 座標
  #     width：寬度
  #--------------------------------------------------------------------------
  def draw_actor_od_gauge_value(actor, x, y, width = 120)
    text = ""
    text2 = "怒"
    value = actor.overdrive * 100.0 / KGC::OverDrive::GAUGE_MAX
    case KGC::OverDrive::GAUGE_VALUE_STYLE
    when KGC::OverDrive::ValueStyle::IMMEDIATE
      text = actor.overdrive.to_s
    when KGC::OverDrive::ValueStyle::RATE
      text = sprintf("%d%%", actor.overdrive * 100 / KGC::OverDrive::GAUGE_MAX)
    when KGC::OverDrive::ValueStyle::RATE_DETAIL1
      text = sprintf("%0.1f%%", value)
    when KGC::OverDrive::ValueStyle::RATE_DETAIL2
      text = sprintf("%0.2f%%", value)
    when KGC::OverDrive::ValueStyle::NUMBER
      text = "#{actor.overdrive / KGC::OverDrive::GAUGE_MAX}"
    else
      return
    end

    last_font_size = self.contents.font.size
    new_font_size = KGC::OverDrive::GAUGE_VALUE_FONT_SIZE
    self.contents.font.size = new_font_size
    self.contents.font.color = system_color
    self.contents.font.bold = false
    self.contents.draw_text(
      x, y + WLH + KGC::OverDrive::GAUGE_OFFSET_Y - new_font_size / 2,
      width, new_font_size, text, 2)
    self.contents.font.size = last_font_size
  end
end

#=================================================#

#==============================================================================
#==============================================================================

if KGC::OverDrive::HIDE_SKILL_LACK_OF_GAUGE

  class Window_Skill < Window_Selectable
    #--------------------------------------------------------------------------
    #     skill：Skill 物件
    #--------------------------------------------------------------------------
    unless $@
      alias include_KGC_OverDrive? include? if method_defined?(:include?)
    end
    def include?(skill)
      return false if skill == nil

      if defined?(include_KGC_OverDrive?)
        return false unless include_KGC_OverDrive?(skill)
      end

      if skill.overdrive?
        return (@actor.calc_od_cost(skill) <= @actor.overdrive)
      else
        return true
      end
    end

    if method_defined?(:include_KGC_OverDrive?)
      #--------------------------------------------------------------------------
      # ● 重新整理
      #--------------------------------------------------------------------------
      def refresh
        @data = []
        for skill in @actor.skills
          next unless include?(skill)
          @data.push(skill)
          if skill.id == @actor.last_skill_id
            self.index = @data.size - 1
          end
        end
        @item_max = @data.size
        create_contents
        for i in 0...@item_max
          draw_item(i)
        end
      end
    end
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Scene_Skill < Scene_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias use_skill_nontarget_KGC_OverDrive use_skill_nontarget
  def use_skill_nontarget
    consume_od_gauge

    use_skill_nontarget_KGC_OverDrive
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def consume_od_gauge
    @actor.overdrive -= @actor.calc_od_cost(@skill)
  end
end

#=================================================#

#==============================================================================
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  #     result：結果（0=勝利、1=逃跑、2=敗北）
  #--------------------------------------------------------------------------
  alias battle_end_KGC_OverDrive battle_end
  def battle_end(result)
    increase_overdrive_on_battle_end(result)

    battle_end_KGC_OverDrive(result)
  end
  #--------------------------------------------------------------------------
  #     result：結果（0=勝利、1=逃跑、2=敗北）
  #--------------------------------------------------------------------------
  def increase_overdrive_on_battle_end(result)
    case result
    when 0  # 勝利
      od_gain = KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::VICTORY]
      $game_party.existing_members.each { |actor|
        actor.overdrive += od_gain if actor.drive_victory?
      }
    when 1  # 逃跑
      od_gain = KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::ESCAPE]
      $game_party.existing_members.each { |actor|
        actor.overdrive += od_gain if actor.drive_escape?
      }
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias execute_action_KGC_OverDrive execute_action
  def execute_action
    increase_overdrive_on_action

    execute_action_KGC_OverDrive
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def increase_overdrive_on_action
    battler = @active_battler
    od_gain = 0
    unit = (battler.actor? ? $game_party : $game_troop)

    # 孤軍
    if battler.drive_alone? && unit.existing_members.size == 1
      od_gain += KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::ALONE]
    end
    # 行動
    if battler.drive_action?
      od_gain += KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::ACTION]
    end
    # 瀕死
    if battler.drive_fatal? && battler.hp < battler.maxhp / 4
      od_gain += KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::FATAL]
    end
    # 防禦
    if battler.drive_guard? && battler.action.kind == 0 &&
        battler.action.basic == 1
      od_gain += KGC::OverDrive::GAIN_RATE[KGC::OverDrive::Type::GUARD]
    end
    battler.overdrive += od_gain
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias execute_action_skill_KGC_OverDrive execute_action_skill
  def execute_action_skill
    execute_action_skill_KGC_OverDrive

    consume_od_gauge
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def consume_od_gauge
    skill = @active_battler.action.skill
    @active_battler.overdrive -= @active_battler.calc_od_cost(skill)
  end
end
