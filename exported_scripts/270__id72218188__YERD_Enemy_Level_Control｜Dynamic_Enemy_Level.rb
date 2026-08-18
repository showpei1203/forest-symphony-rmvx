#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：YERD Enemy Level Control｜Dynamic Enemy Level
# 【來源】Yanfly Engine RD，Enemy Level Control，2009-06-13。
# 【用途】讓 Enemy 依隊伍最低／平均／最高等級取得動態 level，並依 level 成長 HP/MP/ATK/DEF/SPI/AGI、EXP、Gold、Trait 與 Auto State；Enemy Action 的 Party Level 條件也改以 Enemy 自身 level 判斷。
# 【全域設定】MAX_LEVEL=99；LEVEL_MATCH：0最低、1平均、2最高；GROWTH_HP/MP/ATK/DEF/SPI/AGI 為未寫 Note 時每級百分比成長；GROWTH_EXP/GOLD 控制報酬成長。
# 【Enemy Notetag】`<match highest level>` / average / lowest；`<level max x>`、`<level min x>`、`<level set x>`、`<level mod +x>`、`<level lock>`。
# 【能力成長】`<growth maxhp +x>` 或 `<growth maxhp +x%>`，stat 可用 maxhp/maxmp/atk/def/spi/agi/exp/gold；固定值與百分比可同時存在。
# 【Trait/Auto State】`<super guard level x>`、`<fast attack level x>`、`<dual attack level x>`、`<prevent cri level x>`、`<half mp level x>`；`<auto state lv x:y>` 或 `<auto state lv x:y,y>`。
# 【Skill Notetag】`<change enemy level +x>`／負值調整目標 Enemy level；`<reset level>` 回到依隊伍重新計算的基準；`<level lock>` Enemy 不受 Skill 改級。
# 【範例】Enemy Note：`<match highest level>` + `<level mod +3>` + `<level max 60>` + `<growth atk +4%>`；Skill Note：`<change enemy level -2>`。
# 【Load Order】會包裝 Game_Battler#skill_effect、Game_Enemy base stats/conditions，並覆寫 state?；後方 FS ActorEnemyGrowth/Database/Battle Formula 仍可能讀 level API，不能當成單獨數值插件隨意移動。
# 【素材】無固定 Graphics／Audio。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#===============================================================================
# 
# Last Date Updated: 2009.06.13
# 難度：Normal / Hard
# 
# 
# 
#===============================================================================
# Updates:
# ----------------------------------------------------------------------------
#===============================================================================
# 使用說明
#===============================================================================
# 
#
# <match highest level>, <match average level>, <match lowest level>
# By the script's default setting, it will be adjusted to meet the party'
# 
# <level max x> <level min x>
# 
# <level set x>
# 
# <level mod +x> or <level mod -x>
# 
# <growth stat +x> or <growth stat +x%>
# 
# <super guard level x>, <fast attack level x>, <dual attack level x>,
# <prevent cri level x>, <half mp level x>
#
# <auto state lv x:y> or <auto state lv x:y,y>
# 
# ----------------------------------------------------------------------------
# 
# 
# <change enemy level +x>
# 
# <reset level>
# 
#===============================================================================
#
#
#===============================================================================

$imported = {} if $imported == nil
$imported["EnemyLevelControl"] = true

module YE
  module BATTLE
    module ENEMY
      
      MAX_LEVEL = 99
      
      LEVEL_MATCH = 1
      
      #這是%數
      GROWTH_HP  = 20
      GROWTH_MP  = 10
      GROWTH_ATK = 5
      GROWTH_DEF = 5
      GROWTH_SPI = 5
      GROWTH_AGI = 3
      
      GROWTH_EXP  = 0
      GROWTH_GOLD = 0
      
      SCANNED_ENEMY_LEVEL = "Lv%s %s"
      
    end # 詳見頁首繁中說明
  end # 詳見頁首繁中說明
end # YE

#===============================================================================
#===============================================================================

module YE
module REGEXP
module BASEITEM
  
  CHANGE_LEVEL = /<(?:CHANGE_ENEMY_LEVEL|change enemy level)[ ]*([\+\-]\d+)>/i
  RESET_LEVEL  = /<(?:RESET_ENEMY_LEVEL|reset enemy level)[ ]*([\+\-]\d+)>/i
  
end
module ENEMY
  
  LEVEL_SET = /<(?:LEVEL_SET|level set)[ ]*(\d+)>/i
  LEVEL_MAX = /<(?:LEVEL_MAX|level max)[ ]*(\d+)>/i
  LEVEL_MIN = /<(?:LEVEL_MIN|level min)[ ]*(\d+)>/i
  LEVEL_MOD = /<(?:LEVEL_MOD|level mod)[ ]*([\+\-]\d+)>/i
  LEVEL_LOCK = /<(?:LEVEL_LOCK|level lock)>/i
  MATCH_HIGH = /<(?:MATCH_HIGHEST_LEVEL|match highest level)>/i
  MATCH_AVG  = /<(?:MATCH_AVERAGE_LEVEL|match average level)>/i
  MATCH_LOW  = /<(?:MATCH_LOWEST_LEVEL|match lowest level)>/i
  
  GROWTH = /^<(?:GROWTH|stat)[ ]*(.*)[ ]([\+\-]\d+)>/i
  GROWTHP = /^<(?:GROWTH|stat)[ ]*(.*)[ ]([\+\-]\d+)([%％])>/i
  
  TRAIT_SGUARD  = /<(?:SUPER_GUARD_LEVEL|super guard level)[ ]*(\d+)>/i
  TRAIT_FASTATK = /<(?:FAST_ATTACK_LEVEL|fast attack level)[ ]*(\d+)>/i
  TRAIT_DUALATK = /<(?:DUAL_ATTACK_LEVEL|dual attack level)[ ]*(\d+)>/i
  TRAIT_PRECRIT = /<(?:PREVENT_CRI_LEVEL|prevent cri level)[ ]*(\d+)>/i
  TRAIT_HALFMP  = /<(?:HALF_MP_LEVEL|half mp level)[ ]*(\d+)>/i
  TRAIT_AUTOSTATE =
  /<(?:AUTO_STATE_LV|auto state lv|auto state level)[ ]*(\d+):(\d+(?:\s*,\s*\d+)*)>/i
      
end
end
end

#===============================================================================
# RPG::BaseItem
#===============================================================================

class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def yanfly_cache_baseitem_elc
    @change_level = 0; @reset_level = false
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YE::REGEXP::BASEITEM::CHANGE_LEVEL
        @change_level = $1.to_i
      when YE::REGEXP::BASEITEM::RESET_LEVEL
        @reset_level = $1.to_i
      end
    }
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def change_level
    yanfly_cache_baseitem_elc if @change_level == nil
    return @change_level
  end
  def reset_level
    yanfly_cache_baseitem_elc if @reset_level == nil
    return @reset_level
  end
  
end

#===============================================================================
# RPG::Enemy
#===============================================================================

class RPG::Enemy

  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def yanfly_cache_enemy_elc
    @max_level = YE::BATTLE::ENEMY::MAX_LEVEL; @min_level = 1; @level_mod = 0
    @stat_growth ={ 
      :maxhp => 0, :maxmp => 0, :atk   => 0, :def   => 0, :spi   => 0,
      :agi   => 0, :exp   => 0, :gold  => 0, }
    @stat_growthp ={ 
      :maxhp => YE::BATTLE::ENEMY::GROWTH_HP,
      :maxmp => YE::BATTLE::ENEMY::GROWTH_MP,
      :atk   => YE::BATTLE::ENEMY::GROWTH_ATK,
      :def   => YE::BATTLE::ENEMY::GROWTH_DEF,
      :spi   => YE::BATTLE::ENEMY::GROWTH_SPI,
      :agi   => YE::BATTLE::ENEMY::GROWTH_AGI,
      :exp   => YE::BATTLE::ENEMY::GROWTH_EXP,
      :gold  => YE::BATTLE::ENEMY::GROWTH_GOLD, }
    @level_traits ={
      :sguard  => @max_level + 1,
      :fastatk => @max_level + 1,
      :dualatk => @max_level + 1,
      :precrit => @max_level + 1,
      :halfmp  => @max_level + 1, }
    @level_lock = false; @level_match = YE::BATTLE::ENEMY::LEVEL_MATCH
    @auto_state_level = {}
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YE::REGEXP::ENEMY::LEVEL_SET
        @max_level = $1.to_i
        @min_level = $1.to_i
      when YE::REGEXP::ENEMY::LEVEL_MAX
        @max_level = $1.to_i
      when YE::REGEXP::ENEMY::LEVEL_MIN
        @min_level = $1.to_i
      when YE::REGEXP::ENEMY::LEVEL_MOD
        @level_mod = $1.to_i
      when YE::REGEXP::ENEMY::LEVEL_LOCK
        @level_lock = true
      when YE::REGEXP::ENEMY::MATCH_HIGH
        @level_match = 2
      when YE::REGEXP::ENEMY::MATCH_AVG
        @level_match = 1
      when YE::REGEXP::ENEMY::MATCH_LOW
        @level_match = 0
      when YE::REGEXP::ENEMY::GROWTH
        case $1.to_s
        when "maxhp","MAXHP"; @stat_growth[:maxhp] = $2.to_i
        when "maxmp","MAXMP"; @stat_growth[:maxmp] = $2.to_i
        when "atk","ATK";     @stat_growth[:atk]   = $2.to_i
        when "def","DEF";     @stat_growth[:def]   = $2.to_i
        when "spi","SPI";     @stat_growth[:spi]   = $2.to_i
        when "agi","AGI";     @stat_growth[:agi]   = $2.to_i
        when "exp","EXP";     @stat_growth[:exp]   = $2.to_i
        when "gold","GOLD";   @stat_growth[:gold]  = $2.to_i
        end
      when YE::REGEXP::ENEMY::GROWTHP
        case $1.to_s
        when "maxhp","MAXHP"; @stat_growthp[:maxhp] = $2.to_i
        when "maxmp","MAXMP"; @stat_growthp[:maxmp] = $2.to_i
        when "atk","ATK";     @stat_growthp[:atk]   = $2.to_i
        when "def","DEF";     @stat_growthp[:def]   = $2.to_i
        when "spi","SPI";     @stat_growthp[:spi]   = $2.to_i
        when "agi","AGI";     @stat_growthp[:agi]   = $2.to_i
        when "exp","EXP";     @stat_growthp[:exp]   = $2.to_i
        when "gold","GOLD";   @stat_growthp[:gold]  = $2.to_i
        end
      when YE::REGEXP::ENEMY::TRAIT_SGUARD
        @level_traits[:sguard] = $1.to_i
      when YE::REGEXP::ENEMY::TRAIT_FASTATK
        @level_traits[:fastatk] = $1.to_i
      when YE::REGEXP::ENEMY::TRAIT_DUALATK
        @level_traits[:dualatk] = $1.to_i
      when YE::REGEXP::ENEMY::TRAIT_PRECRIT
        @level_traits[:precrit] = $1.to_i
      when YE::REGEXP::ENEMY::TRAIT_HALFMP
        @level_traits[:halfmp] = $1.to_i
      when YE::REGEXP::ENEMY::TRAIT_AUTOSTATE
        i = $1.to_i
        @auto_state_level[i] = [] if @auto_state_level[i] == nil
        $2.scan(/\d+/).each { |num| 
        @auto_state_level[i] += [num.to_i] }
      end
    }
    
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def max_level
    yanfly_cache_enemy_elc if @max_level == nil
    return @max_level
  end
  def min_level
    yanfly_cache_enemy_elc if @min_level == nil
    return @min_level
  end
  def level_mod
    yanfly_cache_enemy_elc if @level_mod == nil
    return @level_mod
  end
  def level_lock
    yanfly_cache_enemy_elc if @level_lock == nil
    return @level_lock
  end
  def level_match
    yanfly_cache_enemy_elc if @level_match == nil
    return @level_match
  end
  def stat_growth
    yanfly_cache_enemy_elc if @stat_growth == nil
    return @stat_growth
  end
  def stat_growthp
    yanfly_cache_enemy_elc if @stat_growthp == nil
    return @stat_growthp
  end
  def level_traits
    yanfly_cache_enemy_elc if @level_traits == nil
    return @level_traits
  end
  def auto_state_level
    yanfly_cache_enemy_elc if @auto_state_level == nil
    return @auto_state_level
  end
  
end # 詳見頁首繁中說明

#===============================================================================
#===============================================================================

class Game_Battler
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias skill_effect_elc skill_effect unless $@
  def skill_effect(user, skill)
    skill_effect_elc(user, skill)
    if !self.actor? and !self.enemy.level_lock
      unless @missed or @evaded
        self.reset_level if skill.reset_level
        self.set_level += skill.change_level if skill.change_level != 0
      end
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias remove_state_elc remove_state unless $@
  def remove_state(state_id)
    return if !self.actor? and self.level_auto_states.include?(state_id)
    remove_state_elc(state_id)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def state?(state_id)
    return states.include?($data_states[state_id])
  end
  
end # 詳見頁首繁中說明

#===============================================================================
#===============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_accessor :set_level
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def level
    reset_level if @set_level == nil
    given_level = [[@set_level, enemy.max_level].min, enemy.min_level].max
    return given_level
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def reset_level
    case enemy.level_match
    when 0 # 詳見頁首繁中說明
      @set_level = YE::BATTLE::ENEMY::MAX_LEVEL
      for actor in $game_party.members
        @set_level = actor.level if @set_level > actor.level
      end
    when 1 # 詳見頁首繁中說明
      @set_level = 0
      for actor in $game_party.members
        @set_level += actor.level
      end
      @set_level /= $game_party.members.size
    else # 詳見頁首繁中說明
      @set_level = $game_actors[1].level # 詳見頁首繁中說明
    end
    @set_level += enemy.level_mod
  end
  
  # 計算最終 HP
  def base_maxhp
    base_value = $data_enemies[self.enemy_id].maxhp # 直接讀取種族值
    return Integer(((2 * base_value + 31) / 100.0 * level) + level + 10)
  end

  # 計算最終 MP
  def base_maxmp
    base_value = $data_enemies[self.enemy_id].maxmp
    return Integer(((2 * base_value + 31) / 100.0 * level) + level + 10)
  end

  # 計算最終攻擊力
  def base_atk
    base_value = $data_enemies[self.enemy_id].atk
    return Integer(((2 * base_value + 31) / 100.0 * level) + level + 5)
  end

  # 計算最終防禦力
  def base_def
    base_value = $data_enemies[self.enemy_id].def
    return Integer(((2 * base_value + 31) / 100.0 * level) + level + 5)
  end

  # 計算最終精神（特攻）
  def base_spi
    base_value = $data_enemies[self.enemy_id].spi
    return Integer(((2 * base_value + 31) / 100.0 * level) + level + 5)
  end

  # 計算最終敏捷（速度）
  def base_agi
    base_value = $data_enemies[self.enemy_id].agi
    return Integer(((2 * base_value + 31) / 100.0 * level) + level + 5)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias exp_elc exp unless $@
  def exp
    n = exp_elc
    n *= (100 + ((level - 1) * enemy.stat_growthp[:exp])) / 100.0
    n += ((level - 1) * enemy.stat_growth[:exp])
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias gold_elc gold unless $@
  def gold
    n = gold_elc
    n *= (100 + ((level - 1) * enemy.stat_growthp[:gold])) / 100.0
    n += ((level - 1) * enemy.stat_growth[:gold])
    return Integer(n)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def super_guard
    return true if (level - 1) > enemy.level_traits[:sguard]
    return super
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def fast_attack
    return true if (level - 1) > enemy.level_traits[:fastatk]
    return super
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def dual_attack
    return true if (level - 1) > enemy.level_traits[:dualatk]
    return super
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def prevent_critical
    return true if (level - 1) > enemy.level_traits[:precrit]
    return super
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def half_mp_cost
    return true if (level - 1) > enemy.level_traits[:halfmp]
    return super
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def states
    result = super
    for id in level_auto_states
      result.push($data_states[id]) unless result.include?($data_states[id])
    end
    result.sort! { |a, b| b.priority <=> a.priority }
    return result
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def level_auto_states
    state_ids = []
    for key in enemy.auto_state_level
      if self.level >= key[0]
        state_ids += key[1]
      end
    end
    return state_ids
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias conditions_met_elc conditions_met? unless $@
  def conditions_met?(action)
    case action.condition_type == 5
    when 5 # 詳見頁首繁中說明
      if (level - 1) < action.condition_param1
        return false
      else
        return true
      end
    else
      return conditions_met_elc(action)
    end
  end
  
end # 詳見頁首繁中說明

#===============================================================================
#
#
#===============================================================================