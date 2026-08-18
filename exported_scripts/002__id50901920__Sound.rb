#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Sound
# 【用途】VX 內建系統音效包裝模組，統一播放游標、決定、取消、戰鬥、商店等 System SE。
# 【主要機制】直接讀取 $data_system.sounds 對應槽位並播放；若修改槽位意義，會影響整個 UI／戰鬥操作音效。
# 【主要影響】Sound
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
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
# ** Sound
#------------------------------------------------------------------------------
#  這個模組用來播放音效。
#  它從資料庫裡的 $data_system 欄位獲取指定的音效資訊並播放指定SE。
#==============================================================================

module Sound

  # 游標
  def self.play_cursor
    $data_system.sounds[0].play
  end

  # 確定
  def self.play_decision
    $data_system.sounds[1].play
  end

  # 取消
  def self.play_cancel
    $data_system.sounds[2].play
  end

  # 無效
  def self.play_buzzer
    $data_system.sounds[3].play
  end

  # 裝備更換
  def self.play_equip
    $data_system.sounds[4].play
  end

  # 存檔
  def self.play_save
    $data_system.sounds[5].play
  end

  # 讀檔
  def self.play_load
    $data_system.sounds[6].play
  end

  # 開始戰鬥
  def self.play_battle_start
    $data_system.sounds[7].play
  end

  # 從戰場撤退
  def self.play_escape
    $data_system.sounds[8].play
  end

  # 敵人攻擊
  def self.play_enemy_attack
    $data_system.sounds[9].play
  end

  # 敵人受傷
  def self.play_enemy_damage
    $data_system.sounds[10].play
  end

  # 敵人死亡
  def self.play_enemy_collapse
    $data_system.sounds[11].play
  end

  # 主角傷害
  def self.play_actor_damage
    $data_system.sounds[12].play
  end

  # 主角瀕死
  def self.play_actor_collapse
    $data_system.sounds[13].play
  end

  # 使用藥品
  def self.play_recovery
    $data_system.sounds[14].play
  end

  # 落空
  def self.play_miss
    $data_system.sounds[15].play
  end

  # 躲避攻擊
  def self.play_evasion
    $data_system.sounds[16].play
  end

  # 交易結算
  def self.play_shop
    $data_system.sounds[17].play
  end

  # 使用物品
  def self.play_use_item
    $data_system.sounds[18].play
  end

  # 使用技能
  def self.play_use_skill
    $data_system.sounds[19].play
  end

end
