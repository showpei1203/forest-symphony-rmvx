#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Vocab
# 【用途】VX 內建用語模組，集中提供選單、戰鬥、存讀檔等介面文字。
# 【主要機制】由各 Window／Scene 透過 Vocab 常數或方法取得顯示文字；資料庫 System Terms 仍是部分詞彙來源。
# 【主要影響】Vocab
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
# ** Vocab
#------------------------------------------------------------------------------
#  這個模組定義了介面用語和互動消息的顯示內容。
#  它將一些資訊定義為常量，而資料庫裡的用語資料讀取自 $data_system 欄位。
#==============================================================================

module Vocab

  # 交易介面
  ShopBuy         = "購入"
  ShopSell        = "售出"
  ShopCancel      = "放棄"
  Possession      = "已擁有數量"

  # 狀態介面
  ExpTotal        = "當前經驗值"
  ExpNext         = "exp"

  # 進度檔案管理介面
  SaveMessage     = "請問您要把進度保存到第幾個檔位？"
  LoadMessage     = "請問您要從第幾個檔位元讀取進度？"
  File            = "檔位"

  # 在隊伍裡有多人時顯示的訊息
  PartyName       = "%s一行人"

  # 基本戰鬥訊息
  Emerge          = "%s現身。"
  Preemptive      = "%s佔據上風。"
  Surprise        = "%s被偷襲。"
  EscapeStart     = "%s準備撤退。"
  EscapeFailure   = "然而，撤退是徒勞的。"

  # 戰鬥結束訊息
  Victory         = "%s得勝。"
  Defeat          = "%s戰敗。"
  ObtainExp       = "獲得%s點EXP。"
  ObtainGold      = "%s%s已獲得。"
  ObtainItem      = "%s被發現。"
  LevelUp         = "%s%s提升為%s。"
  ObtainSkill     = "%s已經習得。"

  # 戰鬥指令
  DoAttack        = "%s發動攻擊。"
  DoGuard         = "%s防禦中。"
  DoEscape        = "%s撤退了。"
  DoWait          = "%s等待中。"
  UseItem         = "%s使用了%s。"

  # 暴擊
  CriticalToEnemy = "狂暴攻擊！！"
  CriticalToActor = "熱血痛擊！！"

  # 主角的行動結果
    # 友情提示： %1$s 代表主角[下一段這個標幟表示為敵人角色]
    #            %2$s 代表HP/MP
    #            %3$s 代表點數，也就是HP/MP的值
  ActorDamage     = "%s受到了%s點傷害。"
  ActorLoss       = "%1$s失去了%3$s點%2$s。"
  ActorDrain      = "%1$s被吸走了%3$s點%2$s。"
  ActorNoDamage   = "%s沒有受到任何傷害。"
  ActorNoHit      = "落空！%s沒有受到任何傷害。"
  ActorEvasion    = "%s躲過了攻擊。"
  ActorRecovery   = "%1$s恢復了%3$s點%2$s。"

  # 敵人角色的行動結果
  EnemyDamage     = "%s受到了%s點傷害。"
  EnemyLoss       = "%1$s失去了%3$s點%2$s。"
  EnemyDrain      = "%1$s被吸走了%3$s點%2$s。"
  EnemyNoDamage   = "%s沒有受到任何傷害。"
  EnemyNoHit      = "落空！%s沒有受到任何傷害。"
  EnemyEvasion    = "%s躲過了攻擊。"
  EnemyRecovery   = "%1$s恢復了%3$s點%2$s。"

  # 物品和非實體攻擊類技能使用無效
  ActionFailure   = "%s沒有受到任何影響。"

  # 等級
  def self.level
    return $data_system.terms.level
  end

  # 等級 （縮寫）
  def self.level_a
    return $data_system.terms.level_a
  end

  # HP
  def self.hp
    return $data_system.terms.hp
  end

  # HP （縮寫）
  def self.hp_a
    return $data_system.terms.hp_a
  end

  # MP
  def self.mp
    return $data_system.terms.mp
  end

  # MP （縮寫）
  def self.mp_a
    return $data_system.terms.mp_a
  end

  # 攻擊力
  def self.atk
    return $data_system.terms.atk
  end

  # 防禦力
  def self.def
    return $data_system.terms.def
  end

  # 意志力
  def self.spi
    return $data_system.terms.spi
  end

  # 敏捷力
  def self.agi
    return $data_system.terms.agi
  end

  # 武器
  def self.weapon
    return $data_system.terms.weapon
  end

  # 盾
  def self.armor1
    return $data_system.terms.armor1
  end

  # 頭戴
  def self.armor2
    return $data_system.terms.armor2
  end

  # 身穿
  def self.armor3
    return $data_system.terms.armor3
  end

  # 佩戴
  def self.armor4
    return $data_system.terms.armor4
  end

  # 左手
  def self.weapon1
    return $data_system.terms.weapon1
  end

  # 右手
  def self.weapon2
    return $data_system.terms.weapon2
  end

  # 攻擊
  def self.attack
    return $data_system.terms.attack
  end

  # 技能
  def self.skill
    return $data_system.terms.skill
  end

  # 防禦
  def self.guard
    return $data_system.terms.guard
  end

  # 用品
  def self.item
    return $data_system.terms.item
  end

  # 整備
  def self.equip
    return $data_system.terms.equip
  end

  # 狀態
  def self.status
    return $data_system.terms.status
  end

  # 存檔
  def self.save
    return $data_system.terms.save
  end

  # 結束遊戲
  def self.game_end
    return $data_system.terms.game_end
  end

  # 戰鬥
  def self.fight
    return $data_system.terms.fight
  end

  # 撤退
  def self.escape
    return $data_system.terms.escape
  end

  # 新的劇情
  def self.new_game
    return $data_system.terms.new_game
  end

  # 讀取存檔
  def self.continue
    return $data_system.terms.continue
  end

  # 退出遊戲
  def self.shutdown
    return $data_system.terms.shutdown
  end

  # 返回標題畫面
  def self.to_title
    return $data_system.terms.to_title
  end

  # 取消
  def self.cancel
    return $data_system.terms.cancel
  end

  # G （貨幣單位）
  def self.gold
    return $data_system.terms.gold
  end

end
