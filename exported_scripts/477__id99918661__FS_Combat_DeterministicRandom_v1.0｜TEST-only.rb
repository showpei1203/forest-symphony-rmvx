#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_Combat_DeterministicRandom v1.0｜TEST-only
# 【用途】提供 Forest Symphony 戰鬥回歸測試專用的 Combat RNG。它只處理命中、迴避、
#         Critical、Damage Variance、State Chance 等「戰鬥結果亂數」；AI 決策仍由
#         FS_AI_RANDOM 獨立管理，避免兩類亂數互相吃掉序列。
# 【主要機制】正式遊戲不改 Kernel.rand。只有 $TEST=true 時，本頁才在 Kernel#rand
#         外加一層 TEST-only wrapper；FS_COMBAT_RANDOM disabled 時完整委派原 rand，
#         enabled 時改用固定 LCG，並保存每次輸入、結果與呼叫位置 Trace。
# 【相容性】專案前段「魔劍工舖 - 內部函數擴充」擴張 rand，可接受 Range／Array／Hash／
#         String／Boolean。本頁 deterministic 路徑同步支援這些輸入，避免測試模式與正式
#         Runtime 的 rand API 不一致。
# 【呼叫方式／範例】只允許 Test Play：
#         FS_COMBAT_RANDOM.enable(149)
#         value = rand(100)
#         p FS_COMBAT_RANDOM.trace_lines
#         FS_COMBAT_RANDOM.disable
# 【設定／可調參數】DEFAULT_SEED、TRACE_LIMIT。
# 【依賴／載入順序】應放在所有正式 Runtime 之後、FS_AutoRegression_Harness 之前；這樣
#         TEST-only Kernel wrapper 會包住專案最終 rand 擴張，但正式遊戲不載入 wrapper。
# 【安全規則】enable 僅允許 $TEST=true；Harness 必須以 ensure 關閉 deterministic mode。
#         禁止用此模組固定正式遊戲亂數。
# 【相關素材】無。
# 【來源／授權】Forest Symphony 專案自製測試基礎設施；RGSS2 / Ruby 1.8 相容。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Combat Deterministic Random"] = "1.0"

module FS_COMBAT_RANDOM
  VERSION = "1.0"
  DEFAULT_SEED = 149
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
      raise RuntimeError, "FS_COMBAT_RANDOM deterministic mode is TEST-only."
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

  def self.trace
    @trace = [] if @trace == nil
    return @trace.collect { |entry| entry.dup }
  end

  def self.trace_lines
    return trace.collect do |entry|
      sprintf("%04d input=%s result=%s source=%s",
              entry[0].to_i, entry[1].to_s, entry[2].inspect, entry[3].to_s)
    end
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

  def self.source_label
    begin
      line = caller(3)[0]
      return line.to_s if line != nil
    rescue
    end
    return "unknown"
  end

  def self.input_label(value)
    case value
    when Range
      return "Range(#{value.begin}#{value.exclude_end? ? '...' : '..'}#{value.end})"
    when Array
      return "Array(size=#{value.size})"
    when Hash
      return "Hash(size=#{value.size})"
    when String
      return "String(size=#{value.size})"
    else
      return value.inspect
    end
  end

  def self.record(input, result)
    @trace = [] if @trace == nil
    @trace.push([count, input_label(input), result, source_label])
    @trace.shift while @trace.size > TRACE_LIMIT
  end

  #--------------------------------------------------------------------------
  # ● Sword Kernel#rand 相容 deterministic 路徑
  #--------------------------------------------------------------------------
  def self.rand(max = false)
    raise RuntimeError, "FS_COMBAT_RANDOM is not enabled." unless enabled?
    raw = next_raw
    result = nil
    case max
    when TrueClass, FalseClass
      result = (raw % 2) == 0
    when Range
      values = max.to_a
      raise ArgumentError, "empty Range for deterministic rand" if values.empty?
      result = values[raw % values.size]
    when Array
      raise ArgumentError, "empty Array for deterministic rand" if max.empty?
      result = max[raw % max.size]
    when Hash
      keys = max.keys
      raise ArgumentError, "empty Hash for deterministic rand" if keys.empty?
      key = keys[raw % keys.size]
      result = [key, max[key]]
    when String
      chars = max.scan(/./)
      raise ArgumentError, "empty String for deterministic rand" if chars.empty?
      result = chars[raw % chars.size]
    else
      if max == nil
        result = raw.to_f / 2147483648.0
      else
        limit = max.to_i.abs
        if limit == 0
          result = raw.to_f / 2147483648.0
        else
          result = raw % limit
        end
      end
    end
    record(max, result)
    return result
  end

  #--------------------------------------------------------------------------
  # ● 不觸碰全域 Kernel RNG 的自我測試
  #--------------------------------------------------------------------------
  def self.self_test
    state = normalize_seed(DEFAULT_SEED)
    values = []
    for max in [100, 100, 2, 101, 101]
      state = next_state(state)
      values.push(state % max)
    end
    return values == [2, 95, 0, 22, 63]
  end
end

# Test Play 最後 rand wrapper。disabled 時完全委派前方專案既有 rand。
if (defined?($TEST) != nil && $TEST == true)
  module Kernel
    unless method_defined?(:fs_combat_rng_original_rand)
      alias fs_combat_rng_original_rand rand
    end
    def rand(max = false)
      if defined?(FS_COMBAT_RANDOM) && FS_COMBAT_RANDOM.enabled?
        return FS_COMBAT_RANDOM.rand(max)
      end
      return fs_combat_rng_original_rand(max)
    end
  end
end
