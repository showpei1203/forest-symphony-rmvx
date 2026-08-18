#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Provoke & Disappear State System v1.2.3 
# 【用途】保留的 Runtime 元件「Provoke & Disappear State System v1.2.3 」。
# 【主要機制】主要定義／擴充 Game_Unit、Scene_Battle、SNF；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Unit、Scene_Battle、SNF
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：DISAPPEAR_STATE_ID、PROVOKE_STATE_ID。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
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
module SNF
  DISAPPEAR_STATE_ID = 13   # 設定「消失 (Disappear)」狀態 ID
  PROVOKE_STATE_ID = 14     # 設定「挑釁 (Provoke)」狀態 ID
end

class Game_Unit
  # 取得隨機目標，考慮 `Provoke` 和 `Disappear`
  def random_target
    provoke_targets = []
    normal_targets = []
    disappear = false

    # 確保 `existing_members` 是有效的
    return nil if existing_members.nil? || existing_members.empty?

    # 先分類目標
    existing_members.each do |member|
      next unless member.exist?  # 只選擇存活的角色
      if member.state?(SNF::PROVOKE_STATE_ID)
        provoke_targets << member
      elsif member.state?(SNF::DISAPPEAR_STATE_ID)
        disappear = true
      else
        normal_targets << member
      end
    end

    # **優先攻擊 `Provoke` 角色**
    return provoke_targets[rand(provoke_targets.size)] unless provoke_targets.empty?

    # **如果沒有 `Provoke` 角色，則攻擊一般角色**
    return normal_targets[rand(normal_targets.size)] unless normal_targets.empty?

    # **如果所有角色都 `Disappear`，則選擇仍存活的角色**
    return existing_members[rand(existing_members.size)] if disappear

    return nil # 沒有可用目標
  end
end

class Scene_Battle
  alias original_make_obj_targets make_obj_targets rescue nil
  alias original_make_attack_targets make_attack_targets rescue nil

  # 影響敵人技能的目標選擇，優先挑釁，排除消失
  def make_obj_targets(user, obj)
    return original_make_obj_targets(user, obj) if original_make_obj_targets

    targets = original_make_obj_targets(user, obj)
    provoke_targets = []
    normal_targets = []

    # 將目標分類
    targets.each do |t|
      if t.state?(SNF::PROVOKE_STATE_ID)
        provoke_targets << t
      elsif !t.state?(SNF::DISAPPEAR_STATE_ID)
        normal_targets << t
      end
    end

    return provoke_targets unless provoke_targets.empty?
    return normal_targets unless normal_targets.empty?
    return targets # 若全部目標都為 Disappear，仍需返回
  end

  # 影響敵人普通攻擊的目標選擇，優先挑釁，排除消失
  def make_attack_targets(attacker)
    return original_make_attack_targets(attacker) if original_make_attack_targets

    targets = original_make_attack_targets(attacker)
    provoke_targets = []
    normal_targets = []

    # 將目標分類
    targets.each do |t|
      if t.state?(SNF::PROVOKE_STATE_ID)
        provoke_targets << t
      elsif !t.state?(SNF::DISAPPEAR_STATE_ID)
        normal_targets << t
      end
    end

    return provoke_targets unless provoke_targets.empty?
    return normal_targets unless normal_targets.empty?
    return targets # 若全部目標都為 Disappear，仍需返回
  end
end
