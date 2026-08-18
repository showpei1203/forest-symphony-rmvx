#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_ATB_DynamicResistance v1.0.0
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_ATB_DynamicResistance v1.0.0」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Enemy、Game_Battler、Scene_Battle、Window_AlbertBattleStateDetail、ALBERT_ATB_DYNAMIC_RESIST
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：DEFAULT_START、DEFAULT_MAX、DEFAULT_FLOOR、DEFAULT_RECOVER、RESIST_RATES、SMALL_LIMIT、MEDIUM_LIMIT、SMALL_GAIN。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意；登記 $imported：AlbertATBDynamicResistance；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】<atb_dynamic_resist>
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
# -*- coding: utf-8 -*-

#===============================================================================

# ■ Albert_RMVX_ATB_DynamicResistance_v1_0_0

#-------------------------------------------------------------------------------

#  RPG Maker VX / RGSS2

#  專案：Forest Symphony 森之交響曲

#-------------------------------------------------------------------------------

#  功能：

#    1. 指定 Enemy 可擁有動態 ATB 延遲抗性。

#    2. 僅攔截 ComboCore 的直接 ATB 改變 <atb_shift:-x>。

#    3. ATB 削減會依 Boss 目前抗性倍率遞減。

#    4. 成功造成至少 1% 實際 ATB 削減時，依「抗性計算前的理論削減量」

#       累積抗性。

#    5. Boss 每完成一次有效戰鬥行動後，抗性下降指定等級。

#    6. 可設定 ATB 最低保護線。

#    7. 若安裝 BattleStateHUD_Core，會在詳細狀態視窗額外顯示：

#         ATB延遲抗性 Lv2/4　承受45%　下限10%

#       此資訊不是資料庫 State，不占 State 數量與圖示欄位。

#-------------------------------------------------------------------------------

#  建議安裝位置：

#    放在以下腳本之後、Main 之前：

#      1. Albert_RMVX_ComboCore_AllInOne

#      2. Albert Character Core（艾卓 OD 計算）

#      3. BattleStateHUD_Core

#

#  Enemy Note 用法：

#

#    <atb_dynamic_resist>

#

#    可選參數：

#    <atb_resist_start:0>    # 初始抗性等級，預設 0

#    <atb_resist_max:4>      # 最大抗性等級，預設 4

#    <atb_resist_floor:10>   # ATB 最低保護線%，預設 10

#    <atb_resist_recover:1>  # 每完成一次有效行動恢復幾級，預設 1

#

#  預設抗性倍率：

#    Lv0 = 100%

#    Lv1 =  70%

#    Lv2 =  45%

#    Lv3 =  25%

#    Lv4 =  10%

#

#  預設抗性累積：

#    理論削減  1%～15%  => +0

#    理論削減 16%～30%  => +1

#    理論削減 31%以上   => +2

#

#  注意：

#    - 必須實際削減至少 1% ATB，才會增加抗性。

#    - 「理論削減」是技能條件加成完成後、Boss 抗性套用前的數值。

#    - 本版刻意不處理 Tankentai 原生 State Note 的 <atb damage: -x%>。

#      這樣避免同一個 State ATB 效果同時走原生與 ComboCore 兩條管線，

#      造成只有部分削減吃到抗性的半套結果。

#===============================================================================



$imported = {} if $imported == nil

$imported["AlbertATBDynamicResistance"] = true



#===============================================================================

# ■ ALBERT_ATB_DYNAMIC_RESIST

#===============================================================================

module ALBERT_ATB_DYNAMIC_RESIST

  VERSION = "1.0.0"



  #--------------------------------------------------------------------------

  # ● 預設值

  #--------------------------------------------------------------------------

  DEFAULT_START   = 0

  DEFAULT_MAX     = 4

  DEFAULT_FLOOR   = 10

  DEFAULT_RECOVER = 1



  #--------------------------------------------------------------------------

  # ● 各抗性等級的 ATB 削減承受倍率（%）

  #--------------------------------------------------------------------------

  RESIST_RATES = [100, 70, 45, 25, 10]



  #--------------------------------------------------------------------------

  # ● 依「抗性計算前的理論 ATB 削減量」決定抗性增加量

  #--------------------------------------------------------------------------

  SMALL_LIMIT  = 15

  MEDIUM_LIMIT = 30



  SMALL_GAIN   = 0

  MEDIUM_GAIN  = 1

  LARGE_GAIN   = 2



  #--------------------------------------------------------------------------

  # ● 至少實際削減多少 ATB 才增加抗性

  #    Tankentai ATB：1000 = 100%，因此 10 = 1%。

  #--------------------------------------------------------------------------

  MIN_ACTUAL_REDUCTION_FOR_GAIN = 10



  #--------------------------------------------------------------------------

  # ● BattleStateHUD 詳細視窗

  #--------------------------------------------------------------------------

  HUD_SHOW       = true

  HUD_HEIGHT_ADD = 24

  HUD_LABEL      = "ATB延遲抗性"



  #--------------------------------------------------------------------------

  # ● 讀取 Note

  #--------------------------------------------------------------------------

  def self.note(obj)

    return "" if obj == nil

    return obj.note.to_s if obj.respond_to?(:note)

    return ""

  end



  #--------------------------------------------------------------------------

  # ● Note 是否包含指定標籤

  #--------------------------------------------------------------------------

  def self.note_has?(obj, regexp)

    return !!(note(obj) =~ regexp)

  end



  #--------------------------------------------------------------------------

  # ● 讀取整數 Note

  #--------------------------------------------------------------------------

  def self.note_number(obj, key, default_value)

    text = note(obj)

    if text =~ /<#{key}\s*:\s*(-?\d+)\s*>/i

      return $1.to_i

    end

    return default_value

  end



  #--------------------------------------------------------------------------

  # ● 夾值

  #--------------------------------------------------------------------------

  def self.clamp(value, min_value, max_value)

    return [[value.to_i, min_value.to_i].max, max_value.to_i].min

  end



  #--------------------------------------------------------------------------

  # ● 最大可用抗性等級

  #--------------------------------------------------------------------------

  def self.rate_max_level

    return [RESIST_RATES.size - 1, 0].max

  end



  #--------------------------------------------------------------------------

  # ● 取得指定抗性等級倍率

  #--------------------------------------------------------------------------

  def self.rate_for(level)

    index = clamp(level, 0, rate_max_level)

    return RESIST_RATES[index].to_i

  end



  #--------------------------------------------------------------------------

  # ● 依理論 ATB 削減量決定抗性增加量

  #    delta 單位：1000 = 100% ATB。

  #--------------------------------------------------------------------------

  def self.gain_for_theoretical_delta(delta)

    percent = delta.to_i.abs / 10.0

    return SMALL_GAIN if percent <= SMALL_LIMIT

    return MEDIUM_GAIN if percent <= MEDIUM_LIMIT

    return LARGE_GAIN

  end

end



#===============================================================================

# ■ Game_Enemy

#===============================================================================

class Game_Enemy < Game_Battler

  #--------------------------------------------------------------------------

  # ● 是否啟用動態 ATB 抗性

  #--------------------------------------------------------------------------

  def albert_atb_dynamic_resist?

    return false if self.enemy == nil

    return ALBERT_ATB_DYNAMIC_RESIST.note_has?(

      self.enemy,

      /<\s*atb_dynamic_resist\s*>/i

    )

  end



  #--------------------------------------------------------------------------

  # ● 最大抗性等級

  #--------------------------------------------------------------------------

  def albert_atb_resist_max

    value = ALBERT_ATB_DYNAMIC_RESIST.note_number(

      self.enemy,

      "atb_resist_max",

      ALBERT_ATB_DYNAMIC_RESIST::DEFAULT_MAX

    )

    return ALBERT_ATB_DYNAMIC_RESIST.clamp(

      value,

      0,

      ALBERT_ATB_DYNAMIC_RESIST.rate_max_level

    )

  end



  #--------------------------------------------------------------------------

  # ● 初始抗性等級

  #--------------------------------------------------------------------------

  def albert_atb_resist_start

    value = ALBERT_ATB_DYNAMIC_RESIST.note_number(

      self.enemy,

      "atb_resist_start",

      ALBERT_ATB_DYNAMIC_RESIST::DEFAULT_START

    )

    return ALBERT_ATB_DYNAMIC_RESIST.clamp(

      value,

      0,

      albert_atb_resist_max

    )

  end



  #--------------------------------------------------------------------------

  # ● ATB 最低保護線（%）

  #--------------------------------------------------------------------------

  def albert_atb_resist_floor_percent

    value = ALBERT_ATB_DYNAMIC_RESIST.note_number(

      self.enemy,

      "atb_resist_floor",

      ALBERT_ATB_DYNAMIC_RESIST::DEFAULT_FLOOR

    )

    return ALBERT_ATB_DYNAMIC_RESIST.clamp(value, 0, 100)

  end



  #--------------------------------------------------------------------------

  # ● 每次完成有效行動後恢復幾級

  #--------------------------------------------------------------------------

  def albert_atb_resist_recover

    value = ALBERT_ATB_DYNAMIC_RESIST.note_number(

      self.enemy,

      "atb_resist_recover",

      ALBERT_ATB_DYNAMIC_RESIST::DEFAULT_RECOVER

    )

    return ALBERT_ATB_DYNAMIC_RESIST.clamp(

      value,

      0,

      albert_atb_resist_max

    )

  end



  #--------------------------------------------------------------------------

  # ● 目前抗性等級

  #    採延遲初始化，戰鬥中第一次讀取時才建立。

  #--------------------------------------------------------------------------

  def albert_atb_resist_level

    if @albert_atb_resist_level == nil

      @albert_atb_resist_level = albert_atb_resist_start

    end

    @albert_atb_resist_level = ALBERT_ATB_DYNAMIC_RESIST.clamp(

      @albert_atb_resist_level,

      0,

      albert_atb_resist_max

    )

    return @albert_atb_resist_level

  end



  #--------------------------------------------------------------------------

  # ● 設定目前抗性等級

  #--------------------------------------------------------------------------

  def albert_atb_resist_level=(value)

    @albert_atb_resist_level = ALBERT_ATB_DYNAMIC_RESIST.clamp(

      value,

      0,

      albert_atb_resist_max

    )

  end



  #--------------------------------------------------------------------------

  # ● 目前 ATB 削減承受倍率（%）

  #--------------------------------------------------------------------------

  def albert_atb_resist_rate

    return 100 unless albert_atb_dynamic_resist?

    return ALBERT_ATB_DYNAMIC_RESIST.rate_for(albert_atb_resist_level)

  end



  #--------------------------------------------------------------------------

  # ● ATB 最低保護值

  #--------------------------------------------------------------------------

  def albert_atb_resist_floor_value

    return (1000 * albert_atb_resist_floor_percent / 100.0).to_i

  end



  #--------------------------------------------------------------------------

  # ● 增加抗性等級

  #    回傳實際增加量。

  #--------------------------------------------------------------------------

  def albert_atb_resist_add(amount)

    return 0 unless albert_atb_dynamic_resist?

    old_level = albert_atb_resist_level

    self.albert_atb_resist_level = old_level + amount.to_i

    return albert_atb_resist_level - old_level

  end



  #--------------------------------------------------------------------------

  # ● 完成一次有效行動後，降低抗性

  #    回傳實際下降量。

  #--------------------------------------------------------------------------

  def albert_atb_resist_recover_after_action

    return 0 unless albert_atb_dynamic_resist?

    old_level = albert_atb_resist_level

    self.albert_atb_resist_level = old_level - albert_atb_resist_recover

    return old_level - albert_atb_resist_level

  end

end



#===============================================================================

# ■ Game_Battler

#-------------------------------------------------------------------------------

#  掛接 ComboCore 的 ATB 實際修改入口。

#

#  只處理：

#    - 目標是 Game_Enemy

#    - Enemy 有 <atb_dynamic_resist>

#    - delta < 0

#    - state == nil

#

#  ComboCore 的 <atb_shift> 呼叫時 state 為 nil；

#  原生 State ATB damage 的額外倍率則會把 state 傳進來。

#  因此可藉此避免第一版混用兩套 ATB 管線。

#===============================================================================

class Game_Battler

  if method_defined?(:albert_combo_apply_atb_delta) &&

     !method_defined?(:albert_atb_resist_old_apply_atb_delta)



    alias albert_atb_resist_old_apply_atb_delta albert_combo_apply_atb_delta



    def albert_combo_apply_atb_delta(delta, state = nil)

      dynamic_target = self.is_a?(Game_Enemy) &&

                       self.respond_to?(:albert_atb_dynamic_resist?) &&

                       self.albert_atb_dynamic_resist?



      unless dynamic_target && delta.to_i < 0 && state == nil

        return albert_atb_resist_old_apply_atb_delta(delta, state)

      end



      return albert_atb_resist_old_apply_atb_delta(delta, state) unless respond_to?(:at_count)

      return albert_atb_resist_old_apply_atb_delta(delta, state) if @at_count == nil



      before = at_count.to_i

      theoretical_delta = delta.to_i



      # 1. 先套用目前 Boss 的 ATB 削減承受倍率。

      rate = albert_atb_resist_rate



      # 艾卓「超載迴路」可在下一次 ATB 削減時穿透一部分抗性。

      # pierce 不是直接把 Boss 抗性清零，而是取回被抵抗部分的指定比例：

      #   最終倍率 = 原倍率 + (100 - 原倍率) * pierce%

      user = respond_to?(:albert_combo_effect_user) ? albert_combo_effect_user : nil

      if user != nil

        pierce = user.instance_variable_get(:@albert_od_aizhuo_overload_pierce).to_f

        if pierce > 0.0

          pierce = 100.0 if pierce > 100.0

          rate = rate.to_f + (100.0 - rate.to_f) * pierce / 100.0

          rate = 100.0 if rate > 100.0

        end

      end



      resisted_amount = (theoretical_delta.abs * rate / 100.0).to_i



      # 2. 套用 ATB 最低保護線。

      floor_value = albert_atb_resist_floor_value

      max_reducible = before - floor_value

      max_reducible = 0 if max_reducible < 0



      effective_amount = [resisted_amount, max_reducible].min

      effective_delta = -effective_amount



      # 3. 交回原本 alias 鏈。

      #    因為本補丁應放在 Character Core 之後，艾卓 OD 會依這裡傳入的

      #    最終 effective_delta，再以 before/after 算真正實際削減量。

      albert_atb_resist_old_apply_atb_delta(effective_delta, state)



      # 4. 只有實際削減至少 1% ATB 才累積抗性。

      after = at_count.to_i

      actual_reduction = before - after

      minimum = ALBERT_ATB_DYNAMIC_RESIST::MIN_ACTUAL_REDUCTION_FOR_GAIN



      if actual_reduction >= minimum

        gain = ALBERT_ATB_DYNAMIC_RESIST.gain_for_theoretical_delta(

          theoretical_delta

        )

        albert_atb_resist_add(gain) if gain > 0

      end

    end

  end

end



#===============================================================================

# ■ Scene_Battle

#-------------------------------------------------------------------------------

#  Boss 每真正執行完成一次有效行動後，降低 ATB 抗性。

#

#  掛 execute_action 而不是 turn_end 的理由：

#    Tankentai ATB 的多次行動敵人可能在 enemy_order 時提早返回，

#    不一定每個單次行動都立刻進入 turn_end。

#    execute_action 更符合「每完成一次行動，抗性恢復一次」的規則。

#===============================================================================

class Scene_Battle < Scene_Base

  unless method_defined?(:albert_atb_resist_old_execute_action)

    alias albert_atb_resist_old_execute_action execute_action

  end



  def execute_action(*args)

    battler = @active_battler

    valid_before = false



    begin

      valid_before = battler != nil &&

                     battler.action != nil &&

                     battler.action.valid?

    rescue

      valid_before = battler != nil

    end



    result = albert_atb_resist_old_execute_action(*args)



    if valid_before && battler.is_a?(Game_Enemy) &&

       battler.respond_to?(:albert_atb_resist_recover_after_action)

      battler.albert_atb_resist_recover_after_action

    end



    return result

  end

end



#===============================================================================

# ■ BattleStateHUD 詳細視窗整合

#-------------------------------------------------------------------------------

#  ATB 抗性不是 State，因此：

#    - 不加入 visible_states

#    - 不占圖示欄位

#    - 不占 DETAIL_MAX_STATES

#    - 直接作為「戰鬥資訊列」顯示於詳細狀態視窗

#

#  同時把抗性等級、倍率、下限加入 detail_signature，確保數值變動時

#  詳細視窗會立即重畫。

#===============================================================================

if defined?(Window_AlbertBattleStateDetail)

  class Window_AlbertBattleStateDetail < Window_Base

    #--------------------------------------------------------------------------

    # ● 原初始化

    #--------------------------------------------------------------------------

    unless method_defined?(:albert_atb_resist_old_detail_initialize)

      alias albert_atb_resist_old_detail_initialize initialize

    end



    def initialize

      albert_atb_resist_old_detail_initialize



      extra = ALBERT_ATB_DYNAMIC_RESIST::HUD_HEIGHT_ADD.to_i

      if ALBERT_ATB_DYNAMIC_RESIST::HUD_SHOW && extra > 0

        self.height = self.height + extra



        # Window_Base#create_contents 本身會先 dispose 舊 contents，

        # 因此這裡不要手動重複 dispose。

        self.create_contents

      end

    end



    #--------------------------------------------------------------------------

    # ● 是否顯示 ATB 動態抗性資訊

    #--------------------------------------------------------------------------

    def albert_atb_resist_hud_target?

      return false unless ALBERT_ATB_DYNAMIC_RESIST::HUD_SHOW

      return false if @battler == nil

      return false unless @battler.respond_to?(:albert_atb_dynamic_resist?)

      return @battler.albert_atb_dynamic_resist?

    end



    #--------------------------------------------------------------------------

    # ● 原詳細簽章

    #--------------------------------------------------------------------------

    unless method_defined?(:albert_atb_resist_old_detail_signature)

      alias albert_atb_resist_old_detail_signature detail_signature

    end



    def detail_signature(states)

      base = albert_atb_resist_old_detail_signature(states)

      return base unless albert_atb_resist_hud_target?



      values = [base]

      values << @battler.albert_atb_resist_level

      values << @battler.albert_atb_resist_max

      values << @battler.albert_atb_resist_rate

      values << @battler.albert_atb_resist_floor_percent

      return values.join(":")

    end



    #--------------------------------------------------------------------------

    # ● 原重畫

    #--------------------------------------------------------------------------

    unless method_defined?(:albert_atb_resist_old_detail_refresh)

      alias albert_atb_resist_old_detail_refresh refresh

    end



    def refresh(states)

      # 一般敵人／角色仍沿用原本 BattleStateHUD 畫法。

      return albert_atb_resist_old_detail_refresh(states) unless albert_atb_resist_hud_target?



      self.contents.clear



      old_size  = self.contents.font.size

      old_bold  = self.contents.font.bold

      old_color = self.contents.font.color



      #-----------------------------------------------------------------------

      # 標題列

      #-----------------------------------------------------------------------

      self.contents.font.size = 16

      self.contents.font.bold = true

      self.contents.font.color = normal_color

      self.contents.draw_text(

        0, 0, self.contents.width, 20,

        "#{@battler.name}　狀態", 0

      )



      #-----------------------------------------------------------------------

      # ATB 動態抗性資訊列

      #-----------------------------------------------------------------------

      self.contents.font.size = 14

      self.contents.font.bold = false



      label = ALBERT_ATB_DYNAMIC_RESIST::HUD_LABEL

      level = @battler.albert_atb_resist_level

      max_level = @battler.albert_atb_resist_max

      rate = @battler.albert_atb_resist_rate

      floor = @battler.albert_atb_resist_floor_percent



      label_width = self.contents.text_size(label).width + 8

      self.contents.font.color = system_color

      self.contents.draw_text(0, 20, label_width, 20, label, 0)



      self.contents.font.color = normal_color

      info = "Lv#{level}/#{max_level}　承受#{rate}%　下限#{floor}%"

      self.contents.draw_text(

        label_width, 20,

        self.contents.width - label_width, 20,

        info, 0

      )



      #-----------------------------------------------------------------------

      # State 列

      #-----------------------------------------------------------------------

      x = 0

      y = 40

      drawn = 0



      states.each do |state|

        break if drawn >= AlbertBattleStateHUD::DETAIL_MAX_STATES



        stack = AlbertBattleStateHUD.state_stack(@battler, state)

        name = AlbertBattleStateHUD.hud_name(state)

        text = stack > 1 ? "#{name}×#{stack}" : name



        icon_index = AlbertBattleStateHUD.hud_icon(state)

        if icon_index > 0

          draw_icon(icon_index, x, y)

          x += 24

        end



        width = self.contents.text_size(text).width + 10

        break if x + width > self.contents.width



        self.contents.draw_text(x, y, width, 24, text)

        x += width

        drawn += 1

      end



      if states.empty?

        base_color = normal_color

        self.contents.font.color = Color.new(

          base_color.red,

          base_color.green,

          base_color.blue,

          128

        )

        self.contents.draw_text(0, y, self.contents.width, 24, "無")

        self.contents.font.color = normal_color

      elsif states.size > drawn

        text = "+#{states.size - drawn}"

        self.contents.draw_text(x, y, 48, 24, text)

      end



      self.contents.font.size = old_size

      self.contents.font.bold = old_bold

      self.contents.font.color = old_color

    end

  end

end



