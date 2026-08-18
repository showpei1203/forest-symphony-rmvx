#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_AI_DeterministicRandom v1.0
# 【用途】集中 Forest Symphony 的「AI 決策亂數」入口，讓正常遊戲維持原 Kernel.rand，
#         同時讓 $TEST 下的自動回歸測試可以用固定 seed 重現相同 AI 決策。
# 【主要機制】預設 disabled；FS_AI_RANDOM.rand(max, tag) 在 disabled 時只呼叫
#         Kernel.rand(max)。測試模式 enable(seed) 後改用固定 LCG，並記錄每次 tag、
#         max、result，供日後 Battle Regression LOG 使用。
# 【主要影響】Enemy Action roulette、DynamicThreat、Actor AutoBattle、Final RandomTarget、
#         Robot Protocol 目標、Boss 隨機召喚、EnemyActionDistribution。
# 【設定／可調參數】DEFAULT_SEED、TRACE_LIMIT。正式遊戲不得把 deterministic mode 預設打開。
# 【依賴／載入順序】必須放在 BATTLE｜AI 區最前方，且位於任何呼叫 FS_AI_RANDOM 的
#         EnemyActionPattern／DynamicThreat／AutoBattleAI／Boss Runtime 之前。
# 【呼叫方式／範例】僅測試模式：
#         FS_AI_RANDOM.enable(12345)
#         value = FS_AI_RANDOM.rand(100, :example)
#         p FS_AI_RANDOM.trace_lines
#         FS_AI_RANDOM.disable
# 【相關素材】無 Graphics／Audio 素材。
# 【測試規則】enable 只允許在 $TEST=true；正常遊戲若誤呼叫會直接 RuntimeError，避免
#         固定亂數不小心流入正式遊戲。self_test 不改外部 RNG 狀態，可供 Validation 使用。
# 【來源／授權】Forest Symphony 專案自製測試基礎設施；RGSS2 / Ruby 1.8 相容寫法。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本頁只管理 AI Decision RNG；命中、傷害 variance、State 機率等 Combat RNG 不在此頁。
# 2. 新增 AI 隨機點時必須傳入可辨識 tag，方便回歸 LOG 對照。
# 3. 正常路徑必須維持「一次呼叫對應一次 Kernel.rand」，不可偷偷多吃亂數。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS AI Deterministic Random"] = "1.0"

module FS_AI_RANDOM
  VERSION = "1.0"
  DEFAULT_SEED = 12345
  TRACE_LIMIT = 2000

  @enabled = false
  @seed = DEFAULT_SEED
  @state = DEFAULT_SEED
  @count = 0
  @trace = []

  def self.test_environment?
    return (defined?($TEST) != nil && $TEST == true)
  end

  def self.enabled?
    return @enabled == true
  end

  def self.seed
    return @seed
  end

  def self.count
    return @count || 0
  end

  def self.enable(seed = DEFAULT_SEED)
    unless test_environment?
      raise RuntimeError, "FS_AI_RANDOM deterministic mode is TEST-only."
    end
    @enabled = true
    @seed = normalize_seed(seed)
    @state = @seed
    @count = 0
    @trace = []
    return @seed
  end

  def self.disable
    @enabled = false
    @count = 0
    @trace = []
    return true
  end

  def self.reset(seed = nil)
    seed = @seed if seed == nil
    @seed = normalize_seed(seed)
    @state = @seed
    @count = 0
    @trace = []
    return @seed
  end

  def self.clear_trace
    @trace = []
  end

  def self.trace
    @trace = [] if @trace == nil
    return @trace.collect { |entry| entry.dup }
  end

  def self.trace_lines
    return trace.collect do |entry|
      sprintf("%04d tag=%s max=%s result=%s",
              entry[0].to_i, entry[1].to_s, entry[2].to_s, entry[3].to_s)
    end
  end

  #--------------------------------------------------------------------------
  # ● 統一 AI rand 入口
  #--------------------------------------------------------------------------
  def self.rand(max = nil, tag = nil)
    unless enabled?
      return max == nil ? Kernel.rand : Kernel.rand(max)
    end

    raw = next_raw
    value = nil
    if max == nil
      value = raw.to_f / 2147483648.0
    else
      limit = max.to_i
      # 現有 AI 呼叫點都保證 limit > 0；若日後誤傳非法值，不替呼叫者吞錯。
      raise ArgumentError, "FS_AI_RANDOM max must be > 0" if limit <= 0
      value = raw % limit
    end
    record(tag, max, value)
    return value
  end

  #--------------------------------------------------------------------------
  # ● 不改動全域 RNG 的 deterministic 自我測試
  #--------------------------------------------------------------------------
  def self.self_test
    values = preview(12345, [100, 10, 7, 1000])
    return values == [6, 5, 3, 573]
  end

  def self.preview(seed, max_list)
    state = normalize_seed(seed)
    result = []
    for max in max_list
      state = next_state(state)
      limit = max.to_i
      return [] if limit <= 0
      result.push(state % limit)
    end
    return result
  end

  def self.normalize_seed(value)
    seed = value.to_i & 0x7fffffff
    seed = 1 if seed == 0
    return seed
  end

  def self.next_state(state)
    return (1103515245 * state.to_i + 12345) & 0x7fffffff
  end

  def self.next_raw
    @state = next_state(@state)
    @count = count + 1
    return @state
  end

  def self.record(tag, max, value)
    @trace = [] if @trace == nil
    @trace.push([count, tag == nil ? :untagged : tag, max, value])
    @trace.shift while @trace.size > TRACE_LIMIT
  end
end
