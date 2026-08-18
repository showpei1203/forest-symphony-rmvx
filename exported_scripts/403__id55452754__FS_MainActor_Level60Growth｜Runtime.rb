#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：MainActor_Level60Growth_v1_0
# 【用途】Forest Symphony 六名主角 Lv60 成長 Runtime；將主角能力成長延伸至等級上限 60。
# 【主要機制】主要定義／擴充 Game_Actor、FS_MAIN_ACTOR_LEVEL60_GROWTH；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Actor、FS_MAIN_ACTOR_LEVEL60_GROWTH
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAX_LEVEL、CURVES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】屬 Runtime 規則，不是 AutoSetup Data；不可與 Enemy Growth 或 MasterSetup Class Data 混為同一責任。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】RUNTIME PROVIDER / ACTOR GROWTH
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
# ■ FS_MainActor_Level60Growth_v1_1
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 【用途】
# Actor 1～6 使用 Forest Symphony 指定的 Lv1～60 裸裝能力曲線。
#
# 【v1.1 修正】
# v1.0 錯把 base_xxx_KGC_PassiveSkill 當成「被動加值」。
# 實際上該方法是 KGC 載入時保存的舊 base_xxx，會包含資料庫基礎值，
# 攻防精敏還可能再次包含裝備值，造成基礎能力與裝備被重複計算。
#
# v1.1 改為：
#   指定曲線 × 裝備百分比
#   ＋裝備固定值
#   ＋KGC 被動固定值
#   ×KGC 被動百分比
#   →KGC PassiveSkill 擴張的加減乘除效果
#
# 【安裝位置】
# 放在所有能力、裝備與被動腳本之下：
# - KGC PassiveSkill
# - KGC PassiveSkill 擴張
# - YEM Equipment Overhaul
# - Albert_RMVX_ActorEnemyGrowth
# - Albert_RMVX_HPMP_Scale_Growth_v2
# - FS_BattleMechanic_AuditFix_v2_2
#
# 並放在 FS_DB_AutoSetup_11_FieldWeather 與 Main 之前。
#
# 【正確測試值】
# Actor 1 喬伊 Lv1，無 State／被動／額外加值：
#   裸裝：[210, 55, 24, 22, 24, 25]
#   巨鼠爪 ATK+5／SPI+5：
#         [210, 55, 29, 22, 29, 25]
#==============================================================================

module FS_MAIN_ACTOR_LEVEL60_GROWTH
  MAX_LEVEL = 60

  # [MaxHP, MaxMP, ATK, DEF, SPI, AGI]
  CURVES = {
    1 => {
       1 => [ 210,  55,  24,  22,  24,  25],
      10 => [ 489,  74,  36,  32,  36,  38],
      20 => [ 812, 105,  54,  50,  55,  58],
      30 => [1148, 145,  78,  74,  80,  85],
      40 => [1484, 185, 104,  97, 109, 114],
      50 => [1820, 225, 130, 120, 138, 142],
      60 => [2156, 265, 156, 144, 167, 171]
    },
    2 => {
       1 => [ 175,  75, 17,  20,  30,  22],
      10 => [ 410, 114, 24,  28,  48,  34],
      20 => [ 677, 168, 35,  41,  75,  52],
      30 => [ 950, 235, 50,  60, 110,  75],
      40 => [1225, 302, 66,  79, 145,  98],
      50 => [1500, 370, 82,  98, 180, 120],
      60 => [1775, 435, 98, 119, 215, 145]
    },
    3 => {
       1 => [ 195,  55,  28,  20,  22,  32],
      10 => [ 455,  78,  42,  30,  34,  49],
      20 => [ 753, 112,  65,  45,  52,  76],
      30 => [1060, 155,  95,  65,  75, 112],
      40 => [1370, 200, 128,  85, 100, 148],
      50 => [1680, 245, 160, 105, 125, 185],
      60 => [1988, 288, 192, 128, 150, 220]
    },
    4 => {
       1 => [ 185,  65,  18,  21,  28,  28],
      10 => [ 432, 100,  26,  29,  45,  42],
      20 => [ 717, 150,  38,  44,  70,  65],
      30 => [1010, 210,  55,  63, 102,  95],
      40 => [1305, 270,  72,  84, 135, 126],
      50 => [1600, 330,  90, 105, 168, 158],
      60 => [1900, 390, 110, 128, 202, 189]
    },
    5 => {
       1 => [ 255,  40,  26,  34,  20,  18],
      10 => [ 592,  56,  40,  52,  30,  27],
      20 => [1000,  80,  62,  81,  47,  41],
      30 => [1440, 110,  90, 118,  68,  58],
      40 => [1875, 142, 120, 158,  89,  76],
      50 => [2310, 175, 150, 198, 110,  95],
      60 => [2755, 208, 180, 239, 132, 114]
    },
    6 => {
       1 => [ 220,  45,  34,  27,  18,  26],
      10 => [ 516,  64,  52,  40,  27,  38],
      20 => [ 853,  92,  81,  61,  41,  57],
      30 => [1200, 125, 118,  88,  58,  82],
      40 => [1550, 165, 154, 116,  78, 111],
      50 => [1900, 205, 190, 145,  98, 140],
      60 => [2260, 242, 230, 175, 118, 169]
    }
  }

  def self.actor?(actor_id)
    return CURVES.has_key?(actor_id)
  end

  def self.value(actor_id, param_id, level)
    data = CURVES[actor_id]
    return nil if data == nil

    lv = [[level.to_i, 1].max, MAX_LEVEL].min
    return data[lv][param_id] if data.has_key?(lv)

    levels = data.keys.sort
    lower = levels[0]
    upper = levels[-1]

    for point in levels
      lower = point if point <= lv
      if point >= lv
        upper = point
        break
      end
    end

    return data[lower][param_id] if lower == upper

    a = data[lower][param_id].to_f
    b = data[upper][param_id].to_f
    rate = (lv - lower).to_f / (upper - lower).to_f
    return (a + (b - a) * rate).round
  end
end

class Game_Actor < Game_Battler
  unless method_defined?(:fs_lv60_original_base_maxhp)
    alias fs_lv60_original_base_maxhp base_maxhp
    alias fs_lv60_original_base_maxmp base_maxmp
    alias fs_lv60_original_base_atk   base_atk
    alias fs_lv60_original_base_def   base_def
    alias fs_lv60_original_base_spi   base_spi
    alias fs_lv60_original_base_agi   base_agi
  end

  def fs_lv60_main_actor?
    return FS_MAIN_ACTOR_LEVEL60_GROWTH.actor?(@actor_id)
  end

  def fs_lv60_equip_percent(sym)
    percent = 100
    for item in equips.compact
      next unless item.respond_to?(:stat_per)
      value = item.stat_per[sym] rescue 0
      value = 0 if value == nil
      percent += aptitude(value, sym)
    end
    return percent
  end

  def fs_lv60_equip_flat(sym)
    total = 0
    for item in equips.compact
      value = 0
      case sym
      when :hp
        value = item.maxhp
      when :mp
        value = item.maxmp
      when :atk
        value = item.atk
      when :def
        value = item.def
      when :spi
        value = item.spi
      when :agi
        value = item.agi
      end
      value = 0 if value == nil
      total += aptitude(value, sym)
    end
    return total
  end

  # KGC PassiveSkill 的純固定加值。
  # 不可呼叫 base_xxx_KGC_PassiveSkill，那是舊基礎值，不是被動值。
  def fs_lv60_passive_flat(key)
    return 0 unless respond_to?(:passive_params)
    params = passive_params
    return 0 if params == nil || params[key] == nil
    return params[key]
  end

  def fs_lv60_passive_rate(key)
    return 100 unless respond_to?(:passive_params_rate)
    rates = passive_params_rate
    return 100 if rates == nil || rates[key] == nil
    return rates[key]
  end

  # KGC_PassiveSkill 擴張版的後置加減乘除。
  def fs_lv60_apply_alvd(value, param_id)
    return value unless respond_to?(:alvd_make)

    alvd_make if @alvd_flag == false || @alvd_flag == nil
    plus  = (@alvd1 && @alvd1[param_id]) ? @alvd1[param_id] : 0
    minus = (@alvd2 && @alvd2[param_id]) ? @alvd2[param_id] : 0
    mult  = (@alvd3 && @alvd3[param_id]) ? @alvd3[param_id] : 0
    div   = (@alvd4 && @alvd4[param_id]) ? @alvd4[param_id] : 0

    value += plus  if plus  != 0
    value -= minus if minus != 0
    value *= mult  if mult  != 0
    value /= div   if div   != 0
    return value
  end

  def fs_lv60_final_value(raw, equip_sym, passive_key, param_id)
    n = raw.to_f
    n *= fs_lv60_equip_percent(equip_sym) / 100.0
    n += fs_lv60_equip_flat(equip_sym)
    n += fs_lv60_passive_flat(passive_key)
    n *= fs_lv60_passive_rate(passive_key) / 100.0
    n = fs_lv60_apply_alvd(n, param_id)
    return Integer(n)
  end

  def base_maxhp
    return fs_lv60_original_base_maxhp unless fs_lv60_main_actor?
    raw = FS_MAIN_ACTOR_LEVEL60_GROWTH.value(@actor_id, 0, @level)
    return fs_lv60_final_value(raw, :hp, :maxhp, 0)
  end

  def base_maxmp
    return fs_lv60_original_base_maxmp unless fs_lv60_main_actor?
    raw = FS_MAIN_ACTOR_LEVEL60_GROWTH.value(@actor_id, 1, @level)
    return fs_lv60_final_value(raw, :mp, :maxmp, 1)
  end

  def base_atk
    return fs_lv60_original_base_atk unless fs_lv60_main_actor?
    raw = FS_MAIN_ACTOR_LEVEL60_GROWTH.value(@actor_id, 2, @level)
    return fs_lv60_final_value(raw, :atk, :atk, 2)
  end

  def base_def
    return fs_lv60_original_base_def unless fs_lv60_main_actor?
    raw = FS_MAIN_ACTOR_LEVEL60_GROWTH.value(@actor_id, 3, @level)
    return fs_lv60_final_value(raw, :def, :def, 3)
  end

  def base_spi
    return fs_lv60_original_base_spi unless fs_lv60_main_actor?
    raw = FS_MAIN_ACTOR_LEVEL60_GROWTH.value(@actor_id, 4, @level)
    return fs_lv60_final_value(raw, :spi, :spi, 4)
  end

  def base_agi
    return fs_lv60_original_base_agi unless fs_lv60_main_actor?
    raw = FS_MAIN_ACTOR_LEVEL60_GROWTH.value(@actor_id, 5, @level)
    return fs_lv60_final_value(raw, :agi, :agi, 5)
  end
end
