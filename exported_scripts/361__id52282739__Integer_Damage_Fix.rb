#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Integer Damage Fix
# 【用途】保留的 Runtime 元件「Integer Damage Fix」。
# 【主要機制】主要定義／擴充 Game_Battler、Sprite_Damage；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Battler、Sprite_Damage
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意。
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
# ■ Integer Damage Fix
#------------------------------------------------------------------------------
# 目的：
# 1. 防止普攻、技能、物品傷害變成 Float
# 2. 防止 HP/MP 實際扣血變成小數
# 3. 防止圖片傷害數字切圖時遇到小數
#------------------------------------------------------------------------------
# 建議位置：所有戰鬥公式、屬性倍率、Sideview、Cover、Protect 腳本之下，
#          Main 之上。
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ● 傷害整數化
  #--------------------------------------------------------------------------
  def albert_normalize_damage_integer
    @hp_damage = @hp_damage.to_i if @hp_damage.is_a?(Numeric)
    @mp_damage = @mp_damage.to_i if @mp_damage.is_a?(Numeric)
  end

  #--------------------------------------------------------------------------
  # ● 分散度前後都整數化
  #    防止 Float 傷害進入 rand(amp + 1) 後繼續產生小數
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_int_damage_apply_variance)
    alias albert_int_damage_apply_variance apply_variance
  end

  def apply_variance(damage, variance)
    damage = damage.to_i if damage.is_a?(Numeric)
    result = albert_int_damage_apply_variance(damage, variance)
    result = result.to_i if result.is_a?(Numeric)
    return result
  end

  #--------------------------------------------------------------------------
  # ● 普攻傷害計算後整數化
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_int_damage_make_attack_damage_value)
    alias albert_int_damage_make_attack_damage_value make_attack_damage_value
  end

  def make_attack_damage_value(attacker)
    albert_int_damage_make_attack_damage_value(attacker)
    albert_normalize_damage_integer
  end

  #--------------------------------------------------------------------------
  # ● 技能／物品傷害計算後整數化
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_int_damage_make_obj_damage_value)
    alias albert_int_damage_make_obj_damage_value make_obj_damage_value
  end

  def make_obj_damage_value(user, obj)
    albert_int_damage_make_obj_damage_value(user, obj)
    albert_normalize_damage_integer
  end

  #--------------------------------------------------------------------------
  # ● 實際扣血前再保險一次
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_int_damage_execute_damage)
    alias albert_int_damage_execute_damage execute_damage
  end

  def execute_damage(user)
    albert_normalize_damage_integer
    albert_int_damage_execute_damage(user)
  end
end


#==============================================================================
# ■ Sprite_Damage Safety Fix
#------------------------------------------------------------------------------
# 顯示圖片傷害數字前，再保險轉整數。
# 這層是為了防止其他腳本直接呼叫 damage_pop(num) 丟入 Float。
#==============================================================================

class Sprite_Damage < Sprite_Base
  unless method_defined?(:albert_int_damage_pop)
    alias albert_int_damage_pop damage_pop
  end

  def damage_pop(num = nil)
    if @battler
      if @battler.hp_damage.is_a?(Numeric)
        @battler.instance_variable_set(:@hp_damage, @battler.hp_damage.to_i)
      end

      if @battler.mp_damage.is_a?(Numeric)
        @battler.instance_variable_set(:@mp_damage, @battler.mp_damage.to_i)
      end
    end

    num = num.to_i if num.is_a?(Numeric)
    albert_int_damage_pop(num)
  end
end