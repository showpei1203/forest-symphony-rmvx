#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_09_BossRuntime
# 【用途】Setup Runtime 的 Boss Provider；提供 Boss 成長、階段召喚、核心群組與 Weather 等執行規則。
# 【主要機制】本專案 MasterSetup 會在後方覆寫／補齊正式資料；AutoSetup 各頁順序不可任意交換。
# 【主要影響】FS_DB_AutoSetup_ContextEnemy、Game_Enemy、Game_Troop、Scene_Battle、FS_DB_AUTOSET_BOSS_RUNTIME、FS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：START_SUMMONS、CORE_GROUPS、CONTEXT_ACTIONS、PHASE_WEATHER、MAX_ENEMIES、ALLY_GROWTH_HP_SCALE、DEFAULT_ENEMY_HP_SCALE、GROWTH_MP_SCALE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】其設定常數最終由 FS_MasterSetup 15 Runtime Boss Weather 經 18 Apply 注入；方法本體留在此 Runtime Provider。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】RUNTIME PROVIDER / BOSS
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
# 【Phase 23】Boss 初始召喚的隨機物種／隨機雙核心抽選已改走 FS_AI_RANDOM，供 Battle Regression 固定 Boss fixture。
# 【Phase47A1｜2026-08-17 實機修正】Enemy524 進入 HP<=70% 的 State151 後，實機未保證
#   第一律 State140 同步建立。Phase Runtime 現只在 State151 存在且 140..143 全部不存在時，
#   呼叫既有 albert_ant_initialize_law_cycle 做一次 convergence；已有法則時絕不重置 action count。
#==============================================================================
#==============================================================================
# ■ FS_DB_AutoSetup_09_BossRuntime v1.4.1
#------------------------------------------------------------------------------
# 【安裝位置】所有戰鬥、EAC、Enemy Summon Safe Position、Boss 機制補丁之下，Main 之上。
#
# 功能：
# 1. Enemy 500-565 使用手冊中的固定最終能力，不再被 Pokémon 種族值公式二次換算。
# 2. 自動補齊菁英／Boss 初始護衛、HP 門檻召喚、核心暴露與指定 Phase State。
# 3. 依目前 Boss 過濾共用核心 551-560 的 AI 行動，並將天候祭司核心連結到場域天氣。
# 4. 已在 Troop 編輯器放好的敵人不會重複召喚；Troop Event 仍可繼續使用。
#==============================================================================
$imported = {} if $imported == nil
$imported["FS DB AutoSetup Boss Runtime"] = "1.4.1"
module FS_DB_AUTOSET_BOSS_RUNTIME
  START_SUMMONS = {500 => [[600, 2, 100]], 501 => [[659, 2, 100]], 502 => [[664, 2, 100]], 503 => [[503, 2, 100]], 504 => [[708, 2, 100]], 505 => [[671, 2, 100]], 506 => [[742, 1, 100]], 507 => [[551, 2, 100]], 508 => [[552, 1, 100]], 509 => [[553, 2, 100]], 521 => [[558, 2, 100]], 522 => [[559, 2, 100]], 523 => [[560, 2, 100]], 530 => [[561, 2, 100]], 531 => [[562, 1, 100], [563, 1, 100], [564, 1, 100], [565, 1, 100]], 540 => [[551, 2, 100]], 541 => [[552, 2, 100]], 542 => [[553, 2, 100]], 543 => [[554, 2, 100]], 544 => [[555, 2, 100]], 545 => [[556, 2, 100]], 546 => [[557, 3, 100]], 548 => [[558, 2, 100]], 549 => [[559, 2, 100]], 550 => [[560, 2, 100]]}
  CORE_GROUPS = {540 => [551], 541 => [552], 542 => [553], 543 => [554], 544 => [555], 545 => [556], 546 => [557], 547 => [558], 548 => [558], 549 => [559], 550 => [560], 530 => [561], 531 => [562, 563, 564, 565], 520 => [557]}
  CONTEXT_ACTIONS = {551 => {507 => [[1, 316, 7], [1, 317, 9]], 540 => [[1, 300, 7], [1, 302, 8]]}, 552 => {508 => [[1, 318, 7], [1, 319, 9]], 541 => [[1, 312, 8]]}, 553 => {509 => [[1, 306, 7], [1, 307, 8]], 542 => [[0, 0, 5], [1, 304, 8]]}, 554 => {510 => [[0, 0, 5], [1, 320, 8]], 543 => [[1, 406, 8]]}, 555 => {510 => [[0, 0, 5], [1, 320, 8]], 544 => [[1, 308, 7], [1, 408, 9]]}, 556 => {510 => [[0, 0, 5], [1, 320, 8]], 545 => [[0, 0, 5], [1, 410, 9]]}, 557 => {520 => [[1, 330, 8]], 546 => [[1, 413, 9]]}, 558 => {521 => [[1, 333, 7], [1, 334, 9]], 547 => [[1, 414, 9]], 548 => [[1, 404, 9]]}, 559 => {522 => [[1, 336, 9]], 549 => [[1, 408, 9]]}, 560 => {523 => [[1, 338, 8], [1, 339, 9]], 550 => [[1, 410, 9]]}, 561 => {530 => [[1, 350, 8]]}, 562 => {531 => [[0, 0, 5], [1, 353, 9]]}, 563 => {531 => [[1, 350, 8]]}, 564 => {531 => [[1, 355, 9]]}, 565 => {531 => [[1, 308, 7], [1, 352, 9]]}}
  PHASE_WEATHER = {548 => [122,125,153,156], 549 => [123,126,154,157], 550 => [124,127,155,158]}
  MAX_ENEMIES = 8

  # 成長模式只在這裡計算一次，不再依賴 YERD／HPMP Scale 的 alias 鏈。
  # 這可避免同一倍率被其他重複腳本再次套用。
  ALLY_GROWTH_HP_SCALE = 14.0
  DEFAULT_ENEMY_HP_SCALE = 6.5
  GROWTH_MP_SCALE = 2.2

  def self.safe_level(enemy)
    lv = enemy.respond_to?(:level) ? enemy.level.to_i : 1
    return [[lv, 1].max, 60].min
  end

  def self.enemy_hp_scale(enemy_data)
    return DEFAULT_ENEMY_HP_SCALE if enemy_data == nil
    if enemy_data.note.to_s =~ /<fs_hp_scale\s*:\s*([-\d.]+)>/i
      return [$1.to_f, 0.1].max
    end
    return DEFAULT_ENEMY_HP_SCALE
  end

  def self.growth_hp(base_value, level, enemy_data = nil)
    raw = ((2 * base_value.to_i + 31) * level.to_i / 100.0) + level.to_i + 10
    return Integer(raw * enemy_hp_scale(enemy_data))
  end

  def self.growth_mp(base_value, level)
    raw = ((2 * base_value.to_i + 31) * level.to_i / 100.0) + level.to_i + 10
    return Integer(raw * GROWTH_MP_SCALE)
  end

  def self.growth_param(base_value, level)
    return Integer(((2 * base_value.to_i + 31) * level.to_i / 100.0) +
                   level.to_i + 5)
  end

  def self.fixed_stats?(enemy_data)
    return enemy_data != nil &&
      enemy_data.note.to_s =~ /<\s*fs_fixed_enemy_stats\s*>/i ? true : false
  end

  def self.growth_stats?(enemy_data, enemy_id = nil)
    return false if enemy_data == nil
    return true if enemy_data.note.to_s =~ /<\s*fs_growth_enemy_stats\s*>/i
    return true if enemy_data.note.to_s =~ /<\s*fs_growth_source\s*>/i
    return true if enemy_id != nil && enemy_id.to_i >= 590 && enemy_id.to_i <= 745
    return false
  end

  # :fixed    = AutoSetup 菁英／Boss，資料庫值就是最終值
  # :growth   = 映體／Robot 成長源與 Pokémon，走等級公式＋HPMP Scale
  # :database = 其他舊 Enemy，保留資料庫最終值，不套 Pokémon 公式
  def self.stat_mode(enemy_data, enemy_id = nil)
    return :fixed if fixed_stats?(enemy_data)
    return :growth if growth_stats?(enemy_data, enemy_id)
    return :database
  end

  def self.current_enemy_rows
    rows = []
    return rows if $game_troop == nil
    members = $game_troop.members
    members = [] unless members.is_a?(Array)
    members.each do |enemy|
      next if enemy == nil
      data = enemy.enemy
      mode = stat_mode(data, enemy.enemy_id)
      rows.push({
        :index => enemy.index,
        :enemy_id => enemy.enemy_id,
        :name => enemy.name,
        :mode => mode,
        :level => safe_level(enemy),
        :db_hp => data.maxhp,
        :db_mp => data.maxmp,
        :db_atk => data.atk,
        :db_def => data.def,
        :db_spi => data.spi,
        :db_agi => data.agi,
        :base_hp => enemy.base_maxhp,
        :base_mp => enemy.base_maxmp,
        :base_atk => enemy.base_atk,
        :base_def => enemy.base_def,
        :base_spi => enemy.base_spi,
        :base_agi => enemy.base_agi,
        :hp => enemy.hp,
        :maxhp => enemy.maxhp,
        :mp => enemy.mp,
        :maxmp => enemy.maxmp,
        :atk => enemy.atk,
        :def => enemy.def,
        :spi => enemy.spi,
        :agi => enemy.agi,
        :hit => enemy.hit,
        :eva => enemy.eva,
        :cri => enemy.cri
      })
    end
    return rows
  end

  def self.write_current_enemy_stats(filename = "FS_CurrentEnemyStats.txt")
    lines = []
    lines.push("Forest Symphony current enemy stats")
    lines.push("growth scale: enemy HP reads <fs_hp_scale>; " +"summon Actor HP remains x#{ALLY_GROWTH_HP_SCALE}; MP x#{GROWTH_MP_SCALE}")
    lines.push("")
    current_enemy_rows.each do |row|
      lines.push("--------------------------------------------------")
      lines.push("index=#{row[:index]} ID=#{row[:enemy_id]} name=#{row[:name]}")
      lines.push("mode=#{row[:mode]} Lv=#{row[:level]}")
      lines.push("DB   HP=#{row[:db_hp]} MP=#{row[:db_mp]} ATK=#{row[:db_atk]} DEF=#{row[:db_def]} SPI=#{row[:db_spi]} AGI=#{row[:db_agi]}")
      lines.push("BASE HP=#{row[:base_hp]} MP=#{row[:base_mp]} ATK=#{row[:base_atk]} DEF=#{row[:base_def]} SPI=#{row[:base_spi]} AGI=#{row[:base_agi]}")
      lines.push("FINAL HP=#{row[:hp]}/#{row[:maxhp]} MP=#{row[:mp]}/#{row[:maxmp]} ATK=#{row[:atk]} DEF=#{row[:def]} SPI=#{row[:spi]} AGI=#{row[:agi]}")
      lines.push("HIT=#{row[:hit]} EVA=#{row[:eva]} CRI=#{row[:cri]}")
    end
    text = "\xEF\xBB\xBF" + lines.join("\r\n")
    File.open(filename, "wb") { |file| file.write(text) }
    return filename
  end

  def self.print_current_enemy_stats
    current_enemy_rows.each { |row| p row }
  end

  def self.context_action_specs(core_id)
    table = CONTEXT_ACTIONS[core_id]
    return nil if table == nil || $game_troop == nil
    for boss_id in table.keys.sort
      found = false
      for member in $game_troop.members
        next if member == nil
        found = true if member.enemy_id == boss_id
      end
      return table[boss_id] if found
    end
    return nil
  end
end


#==============================================================================
# ■ 超短事件指令
#------------------------------------------------------------------------------
# 腳本欄只要輸入：
#   FS.es   # 寫出 FS_CurrentEnemyStats.txt
#   FS.ep   # 逐隻用 p 顯示
#==============================================================================
module FS
  def self.es
    return FS_DB_AUTOSET_BOSS_RUNTIME.write_current_enemy_stats
  end

  def self.ep
    return FS_DB_AUTOSET_BOSS_RUNTIME.print_current_enemy_stats
  end
end

class FS_DB_AutoSetup_ContextEnemy
  attr_reader :actions
  attr_reader :note
  def initialize(base_enemy, specs)
    @note = base_enemy.note
    @actions = []
    (specs || []).each do |spec|
      action = RPG::Enemy::Action.new
      action.kind = spec[0].to_i
      action.basic = 0
      action.skill_id = spec[1].to_i
      action.rating = spec[2].to_i
      action.condition_type = 0
      action.condition_param1 = 0
      action.condition_param2 = 0
      action.conditions_arrays = [] if action.respond_to?(:conditions_arrays=)
      @actions.push(action)
    end
  end
end

class Game_Enemy < Game_Battler
  attr_accessor :fs_boss_runtime_scale
  unless method_defined?(:fs_db_autoset_runtime_candidate_actions_enemy)
    alias fs_db_autoset_runtime_candidate_actions_enemy candidate_actions_enemy
    def candidate_actions_enemy
      base = fs_db_autoset_runtime_candidate_actions_enemy
      specs = FS_DB_AUTOSET_BOSS_RUNTIME.context_action_specs(enemy_id)
      return base if specs == nil || base == nil
      return FS_DB_AutoSetup_ContextEnemy.new(base, specs)
    end
  end

  def fs_db_autoset_scale_value(value, minimum = 0)
    rate = @fs_boss_runtime_scale == nil ? 100 : @fs_boss_runtime_scale.to_i
    result = value.to_i * rate / 100
    return [result, minimum].max
  end
  unless method_defined?(:fs_db_autoset_runtime_base_maxhp)
    alias fs_db_autoset_runtime_base_maxhp base_maxhp
    def base_maxhp
      mode = FS_DB_AUTOSET_BOSS_RUNTIME.stat_mode(enemy, enemy_id)
      value = if mode == :growth
        FS_DB_AUTOSET_BOSS_RUNTIME.growth_hp(enemy.maxhp, FS_DB_AUTOSET_BOSS_RUNTIME.safe_level(self), enemy)
      else
        enemy.maxhp
      end
      return fs_db_autoset_scale_value(value, 1)
    end
  end
  unless method_defined?(:fs_db_autoset_runtime_base_maxmp)
    alias fs_db_autoset_runtime_base_maxmp base_maxmp
    def base_maxmp
      mode = FS_DB_AUTOSET_BOSS_RUNTIME.stat_mode(enemy, enemy_id)
      value = if mode == :growth
        FS_DB_AUTOSET_BOSS_RUNTIME.growth_mp(enemy.maxmp, FS_DB_AUTOSET_BOSS_RUNTIME.safe_level(self))
      else
        enemy.maxmp
      end
      return fs_db_autoset_scale_value(value, 0)
    end
  end
  unless method_defined?(:fs_db_autoset_runtime_base_atk)
    alias fs_db_autoset_runtime_base_atk base_atk
    def base_atk
      mode = FS_DB_AUTOSET_BOSS_RUNTIME.stat_mode(enemy, enemy_id)
      value = if mode == :growth
        FS_DB_AUTOSET_BOSS_RUNTIME.growth_param(enemy.atk, FS_DB_AUTOSET_BOSS_RUNTIME.safe_level(self))
      else
        enemy.atk
      end
      return fs_db_autoset_scale_value(value, 1)
    end
  end
  unless method_defined?(:fs_db_autoset_runtime_base_def)
    alias fs_db_autoset_runtime_base_def base_def
    def base_def
      mode = FS_DB_AUTOSET_BOSS_RUNTIME.stat_mode(enemy, enemy_id)
      value = if mode == :growth
        FS_DB_AUTOSET_BOSS_RUNTIME.growth_param(enemy.def, FS_DB_AUTOSET_BOSS_RUNTIME.safe_level(self))
      else
        enemy.def
      end
      return fs_db_autoset_scale_value(value, 1)
    end
  end
  unless method_defined?(:fs_db_autoset_runtime_base_spi)
    alias fs_db_autoset_runtime_base_spi base_spi
    def base_spi
      mode = FS_DB_AUTOSET_BOSS_RUNTIME.stat_mode(enemy, enemy_id)
      value = if mode == :growth
        FS_DB_AUTOSET_BOSS_RUNTIME.growth_param(enemy.spi, FS_DB_AUTOSET_BOSS_RUNTIME.safe_level(self))
      else
        enemy.spi
      end
      return fs_db_autoset_scale_value(value, 1)
    end
  end
  unless method_defined?(:fs_db_autoset_runtime_base_agi)
    alias fs_db_autoset_runtime_base_agi base_agi
    def base_agi
      mode = FS_DB_AUTOSET_BOSS_RUNTIME.stat_mode(enemy, enemy_id)
      value = if mode == :growth
        FS_DB_AUTOSET_BOSS_RUNTIME.growth_param(enemy.agi, FS_DB_AUTOSET_BOSS_RUNTIME.safe_level(self))
      else
        enemy.agi
      end
      return fs_db_autoset_scale_value(value, 1)
    end
  end
  unless method_defined?(:fs_db_autoset_runtime_exp)
    alias fs_db_autoset_runtime_exp exp
    def exp
      return fs_db_autoset_scale_value(fs_db_autoset_runtime_exp, 0)
    end
  end
  unless method_defined?(:fs_db_autoset_runtime_gold)
    alias fs_db_autoset_runtime_gold gold
    def gold
      return fs_db_autoset_scale_value(fs_db_autoset_runtime_gold, 0)
    end
  end
end

class Game_Troop < Game_Unit
  unless method_defined?(:fs_db_autoset_runtime_setup)
    alias fs_db_autoset_runtime_setup setup
    def setup(troop_id)
      fs_db_autoset_runtime_setup(troop_id)
      @fs_db_autoset_boss_flags = {}
    end
  end

  def fs_db_autoset_flags
    @fs_db_autoset_boss_flags = {} if @fs_db_autoset_boss_flags == nil
    return @fs_db_autoset_boss_flags
  end

  def fs_db_autoset_member(enemy_id, alive_only = false)
    for member in (members || [])
      next if member == nil || member.enemy_id != enemy_id
      next if alive_only && member.dead?
      return member
    end
    return nil
  end

  def fs_db_autoset_count(enemy_id)
    n = 0
    (members || []).each { |member| n += 1 if member != nil && member.enemy_id == enemy_id }
    return n
  end

  def fs_db_autoset_core_alive?(ids)
    (ids || []).each do |id|
      return true if fs_db_autoset_member(id, true) != nil
    end
    return false
  end

  def fs_db_autoset_summon(source, enemy_id, count, spriteset, scale = 100)
    return if source == nil || source.dead?
    missing = count.to_i - fs_db_autoset_count(enemy_id)
    missing.times do
      break if members.size >= FS_DB_AUTOSET_BOSS_RUNTIME::MAX_ENEMIES
      enemy = ma_call_ally(source, enemy_id, 0, 0)
      enemy.fs_boss_runtime_scale = scale.to_i
      enemy.hp = enemy.maxhp
      enemy.mp = enemy.maxmp
      spriteset.ma_call_enemy(enemy) if spriteset != nil && spriteset.respond_to?(:ma_call_enemy)
    end
  end

  def fs_db_autoset_initial_summons(spriteset)
    FS_DB_AUTOSET_BOSS_RUNTIME::START_SUMMONS.keys.sort.each do |boss_id|
      source = fs_db_autoset_member(boss_id, true)
      next if source == nil
      key = [:start, boss_id]
      next if fs_db_autoset_flags[key]
      (FS_DB_AUTOSET_BOSS_RUNTIME::START_SUMMONS[boss_id] || []).each do |spec|
        fs_db_autoset_summon(source, spec[0], spec[1], spriteset, spec[2])
      end
      fs_db_autoset_flags[key] = true
    end
    source = fs_db_autoset_member(510, true)
    if source != nil && !fs_db_autoset_flags[[:altar,510]]
      chosen = [554,555,556][FS_AI_RANDOM.rand(3, :boss_altar_pick)]
      fs_db_autoset_summon(source, chosen, 1, spriteset, 100)
      fs_db_autoset_flags[[:altar,510]] = chosen
    end
    source = fs_db_autoset_member(511, true)
    if source != nil && !fs_db_autoset_flags[[:elite_pair,511]]
      pool = (500..510).to_a
      first = pool.delete_at(FS_AI_RANDOM.rand(pool.size, :boss_pair_first))
      second = pool.delete_at(FS_AI_RANDOM.rand(pool.size, :boss_pair_second))
      fs_db_autoset_summon(source, first, 1, spriteset, 72)
      fs_db_autoset_summon(source, second, 1, spriteset, 72)
      fs_db_autoset_flags[[:elite_pair,511]] = [first, second]
    end
  end

  def fs_db_autoset_threshold_summons(spriteset)
    boss = fs_db_autoset_member(520, true)
    if boss != nil && boss.hp * 100 <= boss.maxhp * 70 && !fs_db_autoset_flags[[:threshold,520]]
      fs_db_autoset_summon(boss, 557, 1, spriteset, 100)
      fs_db_autoset_flags[[:threshold,520]] = true
    end
    boss = fs_db_autoset_member(547, true)
    if boss != nil && boss.hp * 100 <= boss.maxhp * 60 && !fs_db_autoset_flags[[:threshold,547]]
      fs_db_autoset_summon(boss, 558, 2, spriteset, 100)
      fs_db_autoset_flags[[:threshold,547]] = true
    end
  end

  def fs_db_autoset_phase_states
    boss = fs_db_autoset_member(524, true)
    if boss != nil
      boss.add_state(150) unless boss.state?(150) || boss.state?(151) || boss.state?(152)
      if boss.hp * 100 <= boss.maxhp * 35
        boss.remove_state(150); boss.remove_state(151)
        for sid in 140..143; boss.remove_state(sid); end
        boss.add_state(152) unless boss.state?(152)
      elsif boss.hp * 100 <= boss.maxhp * 70
        boss.remove_state(150)
        boss.add_state(151) unless boss.state?(151)

        # Phase47A1：State151 是大諧律啟動 Authority。
        # 實機證明 alias 鏈下可能出現 151 已成立、第一律卻尚未建立的狀態。
        # 只在 140..143 全空時補做一次初始化，避免每幀重置既有輪替計數。
        if boss.state?(151) &&
           boss.respond_to?(:albert_ant_law_states) &&
           boss.respond_to?(:albert_ant_initialize_law_cycle)
          law_active = false
          for law_state_id in boss.albert_ant_law_states
            if boss.state?(law_state_id)
              law_active = true
              break
            end
          end
          boss.albert_ant_initialize_law_cycle unless law_active
        end
      end
    end
    (FS_DB_AUTOSET_BOSS_RUNTIME::PHASE_WEATHER || {}).each do |boss_id, states|
      boss = fs_db_autoset_member(boss_id, true)
      next if boss == nil
      if boss.hp * 100 <= boss.maxhp * 55
        boss.remove_state(states[0])
        boss.add_state(states[1]) unless boss.state?(states[1])
        FS_FIELD_WEATHER.set_field(states[3], boss, true) if defined?(FS_FIELD_WEATHER)
      else
        boss.add_state(states[0]) unless boss.state?(states[0]) || boss.state?(states[1])
        FS_FIELD_WEATHER.set_field(states[2], boss, true) if defined?(FS_FIELD_WEATHER)
      end
    end
    [530,531].each do |boss_id|
      boss = fs_db_autoset_member(boss_id, true)
      next if boss == nil
      ids = FS_DB_AUTOSET_BOSS_RUNTIME::CORE_GROUPS[boss_id]
      if fs_db_autoset_core_alive?(ids)
        boss.add_state(77) unless boss.state?(77)
      else
        boss.remove_state(77)
      end
      boss.add_state(128) if boss.hp * 100 <= boss.maxhp * 45 && !boss.state?(128)
    end
  end

  def fs_db_autoset_core_exposure
    (FS_DB_AUTOSET_BOSS_RUNTIME::CORE_GROUPS || {}).each do |boss_id, ids|
      boss = fs_db_autoset_member(boss_id, true)
      next if boss == nil
      key = [:exposed, boss_id]
      next if fs_db_autoset_flags[key]
      started = fs_db_autoset_flags[[:start,boss_id]] || fs_db_autoset_flags[[:threshold,boss_id]]
      next unless started
      unless fs_db_autoset_core_alive?(ids)
        boss.add_state(129)
        fs_db_autoset_flags[key] = true
      end
    end
  end

  def fs_db_autoset_boss_update(spriteset)
    fs_db_autoset_initial_summons(spriteset)
    fs_db_autoset_threshold_summons(spriteset)
    fs_db_autoset_phase_states
    fs_db_autoset_core_exposure
  end
end

class Scene_Battle < Scene_Base
  unless method_defined?(:fs_db_autoset_boss_runtime_update)
    alias fs_db_autoset_boss_runtime_update update
    def update
      fs_db_autoset_boss_runtime_update
      $game_troop.fs_db_autoset_boss_update(@spriteset) if $game_troop != nil
    end
  end
end
