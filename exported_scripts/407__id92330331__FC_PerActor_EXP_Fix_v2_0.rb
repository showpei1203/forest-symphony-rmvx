#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FC_PerActor_EXP_Fix_v2_0
# 【用途】保留的 Runtime 元件「FC_PerActor_EXP_Fix_v2_0」。
# 【主要機制】主要定義／擴充 Game_Temp、Game_Enemy、Game_Troop、Scene_Battle；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Temp、Game_Enemy、Game_Troop、Scene_Battle、Game_Actor、Window_ResultNextExp、Window_ResultNextExp2
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MIN_MULTIPLIER、MAX_MULTIPLIER、DEBUG。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 8 個 alias／方法包裝，載入順序具有語意；登記 $imported：LargeParty、VariableExpGold、Albert_FC_PerActor_EXP_Fix。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
# Albert_FC_PerActor_EXP_Fix_v2_0.rb
# RPG Maker VX / RGSS2
#------------------------------------------------------------------------------
# 【用途】
# 修正 FC EXP Controller 以「隊伍平均／最高／最低等級」先算出一份共同 EXP，
# 再把同一數值發給所有角色，導致低等召喚物沒有追趕經驗加成的問題。
#
# 【原本問題】
# FC 的 SET Method 先以 SET_LEVEL_TYPE 決定一個隊伍代表等級：
#   敵人 EXP = 資料庫 EXP × <exp at level> ÷ 隊伍代表等級
# 之後戰果腳本把同一份 EXP 傳給所有參戰角色。
# 因為目前 SET_NEED = 100，每一級需求都相同，所以 Lv1 與 Lv14 收到相同 EXP
# 時，經驗條增加比例也幾乎相同。
#
# 【修正後】
# 在戰果開始時，先凍結每位角色的個別 EXP：
#   個別 EXP = 原共同 EXP × 隊伍代表等級 ÷ 該角色戰果前等級
#
# 這等同把 FC 原本公式中的「隊伍代表等級」改成「實際領取者等級」，但不去
# 改寫敵人資料、Auto Setup、掉落、獎勵加成或 FC 的基礎 EXP 池。
#
# 例：Lv14 主角與 Lv1 召喚物面對以 Lv14 為基準的敵人：
#   主角依 Lv14 分母取得正常值；召喚物依 Lv1 分母取得追趕值。
#   兩者不再得到近似的經驗條比例。
#
# 【安裝位置】
# 放在以下腳本之後、Main 之前：
#   1. Auto Enemy / Auto Setup
#   2. FC EXP Controller
#   3. KGC LargeParty
#   4. BBL 戰果畫面／Window_ResultNextExp／Window_ResultNextExp2
#   5. VariableExpGold、召喚物 gain_exp 相關補丁
#
# 【重要】
# 1. 請移除 Albert_Summon_EXP_Consistency_Fix_v1_1.rb。
#    該補丁針對的是 setup／回滾，不是這次確認的戰果公式問題。
# 2. 本補丁不修改 setup，也不重建召喚物。
# 3. 戰果畫面與真正入帳會使用同一份凍結數值，避免動畫升級後等級改變，
#    導致最後入帳再次重算而不一致。
#
# 【可調整】
# MIN_MULTIPLIER：高於隊伍代表等級時，最低仍可取得多少倍率。
# MAX_MULTIPLIER：低等追趕的最高倍率。設為 nil 可取消上限。
#==============================================================================

module ALBERT_FC_PER_ACTOR_EXP
  MIN_MULTIPLIER = 0.25
  MAX_MULTIPLIER = 12.0
  DEBUG = false

  #--------------------------------------------------------------------------
  # ● 是否正在執行戰果個別 EXP 流程
  #--------------------------------------------------------------------------
  def self.active?
    return false if $game_temp == nil
    return $game_temp.albert_fc_personal_exp_active == true
  end

  #--------------------------------------------------------------------------
  # ● FC Set Method 是否啟用
  #--------------------------------------------------------------------------
  def self.fc_set_method?
    begin
      return false unless defined?(FC::EXPC_CUSTOM)
      return FC::EXPC_CUSTOM::EXP_METHOD == 1
    rescue
      return false
    end
  end

  #--------------------------------------------------------------------------
  # ● 取得 FC 原本使用的隊伍代表等級
  #    必須完全仿照 FC 的整數平均，才能把共同 EXP 正確還原成個別 EXP。
  #--------------------------------------------------------------------------
  def self.reference_level
    members = []
    begin
      members = $game_party.members
    rescue
      members = []
    end

    levels = []
    for actor in members
      next if actor == nil
      level = actor.level.to_i
      level = 1 if level < 1
      levels.push(level)
    end
    return 1 if levels.empty?

    type = 1
    begin
      type = FC::EXPC_CUSTOM::SET_LEVEL_TYPE if defined?(FC::EXPC_CUSTOM)
    rescue
      type = 1
    end

    case type
    when 2
      result = levels.max
    when 3
      result = levels.min
    else
      total = 0
      for level in levels
        total += level
      end
      result = total / levels.size
    end

    result = 1 if result == nil || result < 1
    return result
  end

  #--------------------------------------------------------------------------
  # ● 取得需要建立快取的成員
  #--------------------------------------------------------------------------
  def self.result_members
    begin
      if $imported != nil && $imported["LargeParty"]
        return $game_party.all_members
      end
    rescue
    end
    begin
      return $game_party.members
    rescue
      return []
    end
  end

  #--------------------------------------------------------------------------
  # ● 是否為待命成員
  #--------------------------------------------------------------------------
  def self.stand_by_member?(actor)
    begin
      return false unless $imported != nil && $imported["LargeParty"]
      return false unless actor.respond_to?(:battle_member?)
      return !actor.battle_member?
    rescue
      return false
    end
  end

  #--------------------------------------------------------------------------
  # ● 待命 EXP 比例
  #--------------------------------------------------------------------------
  def self.stand_by_rate
    begin
      return KGC::LargeParty::STAND_BY_EXP_RATE.to_i
    rescue
      return 1000
    end
  end

  #--------------------------------------------------------------------------
  # ● 限制追趕倍率
  #--------------------------------------------------------------------------
  def self.clamp_multiplier(value)
    value = MIN_MULTIPLIER if value < MIN_MULTIPLIER
    if MAX_MULTIPLIER != nil && value > MAX_MULTIPLIER
      value = MAX_MULTIPLIER
    end
    return value
  end

  #--------------------------------------------------------------------------
  # ● 準備戰果快取
  #    在任何戰果動畫改變 actor.level 之前，把每人的 EXP 固定下來。
  #--------------------------------------------------------------------------
  def self.prepare
    return if $game_temp == nil || $game_troop == nil

    base_total = 0
    begin
      base_total = $game_troop.albert_fc_personal_exp_raw_total.to_i
    rescue
      begin
        base_total = $game_troop.exp_total.to_i
      rescue
        base_total = 0
      end
    end

    reference = reference_level
    cache = {}
    raw_cache = {}
    level_cache = {}
    rate_cache = {}

    for actor in result_members
      next if actor == nil

      actor_level = actor.level.to_i
      actor_level = 1 if actor_level < 1
      multiplier = 1.0

      if fc_set_method?
        multiplier = reference.to_f / actor_level.to_f
        multiplier = clamp_multiplier(multiplier)
      end

      personal_raw = (base_total.to_f * multiplier).to_i
      personal_award = personal_raw

      if stand_by_member?(actor)
        personal_award = personal_award * stand_by_rate / 1000
      end

      cache[actor.id] = personal_award.to_i
      raw_cache[actor.id] = personal_raw.to_i
      level_cache[actor.id] = actor_level
      rate_cache[actor.id] = multiplier
    end

    $game_temp.albert_fc_personal_exp_base_total = base_total
    $game_temp.albert_fc_personal_exp_reference = reference
    $game_temp.albert_fc_personal_exp_cache = cache
    $game_temp.albert_fc_personal_exp_raw_cache = raw_cache
    $game_temp.albert_fc_personal_exp_level_cache = level_cache
    $game_temp.albert_fc_personal_exp_rate_cache = rate_cache
    $game_temp.albert_fc_personal_exp_window_total_override = nil
    $game_temp.albert_fc_personal_exp_active = true

    write_log if DEBUG
  end

  #--------------------------------------------------------------------------
  # ● 清除暫存
  #--------------------------------------------------------------------------
  def self.finish
    return if $game_temp == nil
    $game_temp.albert_fc_personal_exp_active = false
    $game_temp.albert_fc_personal_exp_window_total_override = nil
    $game_temp.albert_fc_personal_exp_base_total = nil
    $game_temp.albert_fc_personal_exp_reference = nil
    $game_temp.albert_fc_personal_exp_cache = nil
    $game_temp.albert_fc_personal_exp_raw_cache = nil
    $game_temp.albert_fc_personal_exp_level_cache = nil
    $game_temp.albert_fc_personal_exp_rate_cache = nil
  end

  #--------------------------------------------------------------------------
  # ● 角色真正要傳入 gain_exp 的基礎值
  #--------------------------------------------------------------------------
  def self.award_for(actor)
    return 0 if actor == nil
    begin
      cache = $game_temp.albert_fc_personal_exp_cache
      return cache[actor.id].to_i if cache != nil && cache.has_key?(actor.id)
    rescue
    end
    return 0
  end

  #--------------------------------------------------------------------------
  # ● 角色在套用待命比例前的個別 EXP
  #--------------------------------------------------------------------------
  def self.raw_award_for(actor)
    return 0 if actor == nil
    begin
      cache = $game_temp.albert_fc_personal_exp_raw_cache
      return cache[actor.id].to_i if cache != nil && cache.has_key?(actor.id)
    rescue
    end
    return award_for(actor)
  end

  #--------------------------------------------------------------------------
  # ● 戰果視窗應顯示的 EXP
  #    仿照原 Window_ResultNextExp 的順序：VariableExpGold 會覆蓋雙倍 EXP 顯示。
  #--------------------------------------------------------------------------
  def self.display_award_for(actor)
    base = award_for(actor)
    value = base

    begin
      value = base * 2 if actor.double_exp_gain
    rescue
    end

    begin
      if $imported != nil && $imported["VariableExpGold"] &&
          actor.respond_to?(:exp_gain_rate)
        value = base * actor.exp_gain_rate / 100
      end
    rescue
    end

    return value.to_i
  end

  #--------------------------------------------------------------------------
  # ● 讓原戰果視窗的待命判定也取得同一份個別 EXP
  #    原視窗會自行做：exp_total × STAND_BY_EXP_RATE / 1000。
  #--------------------------------------------------------------------------
  def self.begin_window_actor(actor)
    return if $game_temp == nil
    $game_temp.albert_fc_personal_exp_window_total_override = nil
    return unless stand_by_member?(actor)

    rate = stand_by_rate
    return if rate <= 0
    display_value = display_award_for(actor)
    override = display_value * 1000 / rate
    $game_temp.albert_fc_personal_exp_window_total_override = override.to_i
  end

  def self.end_window_actor
    return if $game_temp == nil
    $game_temp.albert_fc_personal_exp_window_total_override = nil
  end

  #--------------------------------------------------------------------------
  # ● 測試記錄
  #--------------------------------------------------------------------------
  def self.write_log
    begin
      file = File.open("Albert_FC_PerActor_EXP_Log.txt", "a")
      file.write("--- battle result ---\n")
      file.write("base_total=" + $game_temp.albert_fc_personal_exp_base_total.to_s)
      file.write(" reference=" + $game_temp.albert_fc_personal_exp_reference.to_s + "\n")
      for actor in result_members
        next if actor == nil
        level = $game_temp.albert_fc_personal_exp_level_cache[actor.id]
        rate = $game_temp.albert_fc_personal_exp_rate_cache[actor.id]
        exp = $game_temp.albert_fc_personal_exp_cache[actor.id]
        file.write("actor=" + actor.id.to_s + " " + actor.name.to_s)
        file.write(" level=" + level.to_s)
        file.write(" rate=" + rate.to_s)
        file.write(" exp=" + exp.to_s + "\n")
      end
      file.close
    rescue
    end
  end
end

#==============================================================================
# ■ Game_Temp
#==============================================================================
class Game_Temp
  attr_accessor :albert_fc_personal_exp_active
  attr_accessor :albert_fc_personal_exp_base_total
  attr_accessor :albert_fc_personal_exp_reference
  attr_accessor :albert_fc_personal_exp_cache
  attr_accessor :albert_fc_personal_exp_raw_cache
  attr_accessor :albert_fc_personal_exp_level_cache
  attr_accessor :albert_fc_personal_exp_rate_cache
  attr_accessor :albert_fc_personal_exp_window_total_override
end


#==============================================================================
# ■ Game_Enemy
#    Auto Setup 原腳本的「exp =* ...」會把數值變成 Array，之後再加 rand 時
#    可能引發 TypeError。平常若被 FC 後續覆寫就不會出現；此處只在該錯誤
#    真正發生且敵人為 auto_setup 時，才用正確乘法重算，避免改動正常 FC 結果。
#==============================================================================
class Game_Enemy < Game_Battler
  unless method_defined?(:albert_fc_personal_exp_safe_enemy_exp)
    alias albert_fc_personal_exp_safe_enemy_exp exp
  end

  def exp
    begin
      return albert_fc_personal_exp_safe_enemy_exp
    rescue TypeError
      begin
        if enemy.respond_to?(:auto_setup?) && enemy.auto_setup?
          value = ($game_party.avg_exp_needed * Auto_Enemy::EXPERIENCE).to_i
          boss_rate = enemy.type == 6 ? Auto_Enemy::BOSS_EXP : 1
          value *= boss_rate
          value += rand(10)
          return value.to_i
        end
      rescue
      end
      raise
    end
  end
end

#==============================================================================
# ■ Game_Troop
#    凍結同一場戰果的基礎 EXP，避免 Auto Setup 中的 rand 或其他腳本重算。
#==============================================================================
class Game_Troop < Game_Unit
  unless method_defined?(:albert_fc_personal_exp_raw_total)
    alias albert_fc_personal_exp_raw_total exp_total
  end

  def exp_total
    if ALBERT_FC_PER_ACTOR_EXP.active?
      begin
        override = $game_temp.albert_fc_personal_exp_window_total_override
        return override.to_i if override != nil

        base = $game_temp.albert_fc_personal_exp_base_total
        return base.to_i if base != nil
      rescue
      end
    end
    return albert_fc_personal_exp_raw_total
  end
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  unless method_defined?(:albert_fc_personal_exp_display_result)
    alias albert_fc_personal_exp_display_result display_result
  end

  def display_result
    ALBERT_FC_PER_ACTOR_EXP.prepare
    begin
      albert_fc_personal_exp_display_result
    ensure
      ALBERT_FC_PER_ACTOR_EXP.finish
    end
  end
end

#==============================================================================
# ■ Game_Actor
#    戰果最後真正入帳時，改用戰果開始前已凍結的個別 EXP。
#==============================================================================
class Game_Actor < Game_Battler
  unless method_defined?(:albert_fc_personal_exp_gain_exp)
    alias albert_fc_personal_exp_gain_exp gain_exp
  end

  def gain_exp(exp, show)
    if ALBERT_FC_PER_ACTOR_EXP.active?
      personal = ALBERT_FC_PER_ACTOR_EXP.award_for(self)
      exp = personal if personal != nil
    end
    albert_fc_personal_exp_gain_exp(exp, show)
  end
end

#==============================================================================
# ■ Window_ResultNextExp
#    主角戰果視窗使用個別 EXP；保留原本的動畫、升級、技能顯示與版面。
#==============================================================================
if defined?(Window_ResultNextExp)
  class Window_ResultNextExp < Window_Base
    unless method_defined?(:albert_fc_personal_exp_update_actor_nextexp)
      alias albert_fc_personal_exp_update_actor_nextexp update_actor_nextexp
    end

    def update_actor_nextexp(actor, x, y, exp, count, width = 120)
      personal = ALBERT_FC_PER_ACTOR_EXP.display_award_for(actor)
      ALBERT_FC_PER_ACTOR_EXP.begin_window_actor(actor)
      begin
        albert_fc_personal_exp_update_actor_nextexp(
          actor, x, y, personal, count, width)
      ensure
        ALBERT_FC_PER_ACTOR_EXP.end_window_actor
      end
    end

    unless method_defined?(:albert_fc_personal_exp_update_actor_exp_gauge)
      alias albert_fc_personal_exp_update_actor_exp_gauge update_actor_exp_gauge
    end

    def update_actor_exp_gauge(actor, x, y, exp, count, width = 120)
      personal = ALBERT_FC_PER_ACTOR_EXP.display_award_for(actor)
      ALBERT_FC_PER_ACTOR_EXP.begin_window_actor(actor)
      begin
        albert_fc_personal_exp_update_actor_exp_gauge(
          actor, x, y, personal, count, width)
      ensure
        ALBERT_FC_PER_ACTOR_EXP.end_window_actor
      end
    end
  end
end

#==============================================================================
# ■ Window_ResultNextExp2
#    召喚物戰果視窗使用同一份個別 EXP。
#==============================================================================
if defined?(Window_ResultNextExp2)
  class Window_ResultNextExp2 < Window_Base
    unless method_defined?(:albert_fc_personal_exp2_update_actor_nextexp)
      alias albert_fc_personal_exp2_update_actor_nextexp update_actor_nextexp
    end

    def update_actor_nextexp(actor, x, y, exp, count, width = 120)
      personal = ALBERT_FC_PER_ACTOR_EXP.display_award_for(actor)
      ALBERT_FC_PER_ACTOR_EXP.begin_window_actor(actor)
      begin
        albert_fc_personal_exp2_update_actor_nextexp(
          actor, x, y, personal, count, width)
      ensure
        ALBERT_FC_PER_ACTOR_EXP.end_window_actor
      end
    end

    unless method_defined?(:albert_fc_personal_exp2_update_actor_exp_gauge)
      alias albert_fc_personal_exp2_update_actor_exp_gauge update_actor_exp_gauge
    end

    def update_actor_exp_gauge(actor, x, y, exp, count, width = 30)
      personal = ALBERT_FC_PER_ACTOR_EXP.display_award_for(actor)
      ALBERT_FC_PER_ACTOR_EXP.begin_window_actor(actor)
      begin
        albert_fc_personal_exp2_update_actor_exp_gauge(
          actor, x, y, personal, count, width)
      ensure
        ALBERT_FC_PER_ACTOR_EXP.end_window_actor
      end
    end
  end
end

$imported = {} if $imported == nil
$imported["Albert_FC_PerActor_EXP_Fix"] = true
