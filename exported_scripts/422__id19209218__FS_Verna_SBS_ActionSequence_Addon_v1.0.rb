#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_Verna_SBS_ActionSequence_Addon v1.0
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_Verna_SBS_ActionSequence_Addon v1.0」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RPG::Skill、N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：FSV_WEAPON_ANIME_V11、FSV_BATTLER_ANIME_V11、FSV_ACTION_SEQUENCES_V11、FSV_SKILL_ACTIONS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS_Verna_SBS_ActionSequence_Addon；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# -*- coding: utf-8 -*-
#==============================================================================
# ** FS_Verna_SBS_ActionSequence_Addon v1.1 繁體中文版
#------------------------------------------------------------------------------
#  Forest Symphony／RPG Maker VX／RGSS2
#  維娜專屬 Tankentai SBS Action Sequence Addon
#------------------------------------------------------------------------------
# 【v1.1 角色動作特色重製】
#
#  維娜的所有技能統一遵守「實驗流程」：
#
#    Observe 觀察
#    → Analyze／Cast 210 分析
#    → Mix／Operate 調製或操作病灶
#    → Release 211 投放
#    → Database Animation 目標反應
#    → Inspect 確認實驗結果
#
#  她不是傳統站樁法師，也不是平時持刀的刺客。
#  小刀只在 Skill 130、138 接近敵人後顯示。
#
# 【角色圖格依據】
#
#    $Verna_1 Row 0：準備／防護起手。
#    $Verna_1 Row 1：觀察、比較、確認結果。
#    $Verna_1 Row 2：異常狀態，正式技能不得使用。
#    $Verna_1 Row 3：無武器待機。
#
#    $Verna_2 Row 0：遮面、取樣、投放前的防護動作。
#    $Verna_2 Row 1：正面收手姿勢。
#    $Verna_2 Row 3：倒地。
#
#    $Verna_3 Row 0：接近小刀攻擊姿勢。
#    $Verna_3 Row 1：只有獨立物件圖格，不是人物姿勢，本腳本不使用。
#    $Verna_3 Row 2：蹲下調製／培養。
#    $Verna_3 Row 3：病灶操作／施放。
#
#  以上完全依照使用者提供的維娜角色動作圖編排。
#
# 【功能範圍】
#  只處理維娜 Skill 130～139 的人物姿勢、少量小刀 Weapon Sprite、
#  Cast 210、Release 211、目標資料庫動畫與正式效果結算時點。
#
#  不改寫：
#    ・毒、寄生、腐蝕與病灶公式
#    ・State 31 疊層
#    ・狀態擴散、轉移、保留與引爆
#    ・Boss 動態抗性
#    ・OD、ATB、冷卻、技能消耗與詠唱
#
# 【安裝位置】
#  放在 Tankentai、Action Sequence、Skill Action／Notetag／Make skill action
#  與其他角色專屬 SBS Addon 下方，Main 正上方。
#
#  請用 v1.1 完整取代維娜 v1.0，不要兩版並存。
#
# 【必要圖檔｜Graphics/Characters】
#    $Verna.png
#    $Verna_1.png
#    $Verna_2.png
#    $Verna_3.png
#
#  角色資料庫 character_name 維持「$Verna」。
#
# 【技能直接綁定】
#   130 毒音刺
#   131 毒音培養
#   133 霧笛擴散
#   134 寄生轉調
#   135 腐蝕變奏
#   137 百病和鳴
#   138 毒音處刑
#   139 萬毒交響
#
#  Skill 132「毒理學」與 136「病灶連鎖」為被動技能。
#
# 【效果安全規則】
#   ・每個主動技能只執行一次 DAMAGE 或 DAMAGE_ANIM_WAIT。
#   ・Animation 210／211 與其他 m_a 鍵只負責使用者演出。
#   ・目標動畫使用技能資料庫 Animation。
#   ・只有 Skill 130、138 顯示 Weapon Sprite。
#   ・待機、移動、觀察、Cast、調製與結果確認一律無武器。
#   ・暗幕技能必定恢復 NORMAL_SCREEN_COLOR。
#   ・每個 Afterimage ON 都有對應的 Afterimage OFF。
#   ・效果完成後執行 Can Collapse。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS_Verna_SBS_ActionSequence_Addon"] = "1.1"

unless defined?(N01::ANIME) && defined?(N01::ACTION)
  raise "FS_Verna_SBS_ActionSequence_Addon 必須放在 Tankentai SBS 下方。"
end

module N01

  #============================================================================
  # ● 維娜小刀 Weapon Sprite
  #============================================================================
  FSV_WEAPON_ANIME_V11 = {

    "FSV_WPN_DAGGER_READY" =>
      [0, 0, true, 45, 45, 4, false, 1, 1, -5, -2, false],

    "FSV_WPN_DAGGER_STAB" =>
      [-5, 1, true, 0, 0, 4, false, 1, 1, -10, 0, false],

    "FSV_WPN_DAGGER_SLASH" =>
      [-5, 2, true, -100, 75, 4, false, 1, 1, -6, 0, false],

    "FSV_WPN_DAGGER_FINISH" =>
      [-4, 0, true, -75, 20, 4, false, 1, 1, -8, -3, false]
  }

  #============================================================================
  # ● 維娜人物姿勢、演出動畫與位移
  #============================================================================
  FSV_BATTLER_ANIME_V11 = {

    #--------------------------------------------------------------------------
    # ■ 無武器待機與移動
    #--------------------------------------------------------------------------

    "FSV_IDLE" =>
      [1, 3, 15, 0, 0, -1, 0, true, ""],

    "FSV_STEP_IN" =>
      [0, 1, 10, 0, 0, -1, 0, true, ""],

    "FSV_STEP_OUT" =>
      [0, 2, 10, 0, 0, -1, 0, true, ""],

    #--------------------------------------------------------------------------
    # ■ 觀察與結果確認：$Verna_1 Row 1
    #--------------------------------------------------------------------------

    "FSV_OBSERVE_START" =>
      [1, 1, 15, 0, 0, 0, 2, true, ""],

    "FSV_OBSERVE_HOLD" =>
      [1, 1, 15, 0, 0, 1, 2, true, ""],

    "FSV_OBSERVE_POINT" =>
      [1, 1, 15, 0, 0, 2, 2, true, ""],

    "FSV_OBSERVE_LOOP" =>
      [1, 1, 5, 2, 0, -1, 2, true, ""],

    # 技能結束後固定觀察反應，建立維娜的招牌收尾。
    "FSV_INSPECT_RESULT" =>
      [1, 1, 15, 0, 0, 1, 2, true, ""],

    "FSV_INSPECT_CONFIRM" =>
      [1, 1, 15, 0, 0, 2, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 準備與防護：$Verna_1 Row 0
    #--------------------------------------------------------------------------

    "FSV_PREPARE_START" =>
      [1, 0, 15, 0, 0, 0, 2, true, ""],

    "FSV_PREPARE_HOLD" =>
      [1, 0, 15, 0, 0, 1, 2, true, ""],

    "FSV_PREPARE_RELEASE" =>
      [1, 0, 15, 0, 0, 2, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 遮面／取樣：$Verna_2 Row 0
    #--------------------------------------------------------------------------

    "FSV_MASK_START" =>
      [2, 0, 15, 0, 0, 0, 2, true, ""],

    "FSV_MASK_HOLD" =>
      [2, 0, 15, 0, 0, 1, 2, true, ""],

    "FSV_MASK_RELEASE" =>
      [2, 0, 15, 0, 0, 2, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 調製／培養：$Verna_3 Row 2
    #--------------------------------------------------------------------------

    "FSV_MIX_START" =>
      [3, 2, 15, 0, 0, 0, 2, true, ""],

    "FSV_MIX_HOLD" =>
      [3, 2, 15, 0, 0, 1, 2, true, ""],

    "FSV_MIX_RELEASE" =>
      [3, 2, 15, 0, 0, 2, 2, true, ""],

    "FSV_MIX_LOOP" =>
      [3, 2, 5, 2, 0, -1, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 病灶操作／施放：$Verna_3 Row 3
    #--------------------------------------------------------------------------

    "FSV_CAST_START" =>
      [3, 3, 15, 0, 0, 0, 2, true, ""],

    "FSV_CAST_HOLD" =>
      [3, 3, 15, 0, 0, 1, 2, true, ""],

    "FSV_CAST_RELEASE" =>
      [3, 3, 15, 0, 0, 2, 2, true, ""],

    "FSV_CAST_LOOP" =>
      [3, 3, 5, 2, 0, -1, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 小刀攻擊：$Verna_3 Row 0
    #--------------------------------------------------------------------------

    "FSV_DAGGER_READY" =>
      [3, 0, 15, 0, 0, 0, 2, true, "FSV_WPN_DAGGER_READY"],

    "FSV_DAGGER_STAB" =>
      [3, 0, 15, 0, 0, 1, 2, true, "FSV_WPN_DAGGER_STAB"],

    "FSV_DAGGER_SLASH" =>
      [3, 0, 15, 0, 0, 2, 2, true, "FSV_WPN_DAGGER_SLASH"],

    "FSV_DAGGER_FINISH" =>
      [3, 0, 15, 0, 0, 2, 3, true, "FSV_WPN_DAGGER_FINISH"],

    #--------------------------------------------------------------------------
    # ■ 倒地：$Verna_2 Row 3
    #--------------------------------------------------------------------------

    "FSV_COLLAPSE" =>
      [2, 3, 12, 0, 0, 1, 0, false, ""],

    #--------------------------------------------------------------------------
    # ■ 使用者演出動畫
    #--------------------------------------------------------------------------
    # 目前全部使用使用者指定的 Animation 210／211。
    # 各鍵旁標註未來專用動畫需求；日後只需替換 ID。
    #--------------------------------------------------------------------------

    # 現用：Animation 210。
    # 【未來專用動畫需求】
    # 細窄紫藍掃描線由下往上掃過維娜，周圍出現少量檢測刻度；
    # 代表診斷與鎖定，不要像一般魔法蓄力。
    "FSV_SCAN_EFFECT" =>
      ["m_a", 210, 4, 0, 52, 0, 0, 0, 2, true, ""],

    # 現用：Animation 210。
    # 【未來專用動畫需求】
    # 手邊出現小型氣泡、液滴或培養皿反應，範圍限制在腰部以下；
    # 用來表現調製，而非全身光柱。
    "FSV_MIX_EFFECT" =>
      ["m_a", 210, 4, 0, 25, 0, 0, 0, 0, true, ""],

    # 現用：Animation 211。
    # 【未來專用動畫需求】
    # 毒霧由維娜腳邊貼地向外擴散，她本人應保持清晰；
    # 真正落到敵人的毒霧動畫仍由 Skill 133 資料庫 Animation 負責。
    "FSV_RELEASE_MIST" =>
      ["m_a", 211, 4, 0, 25, 0, 0, 0, 0, true, ""],

    # 現用：Animation 211。
    # 【未來專用動畫需求】
    # 一條細紫色病灶線由一側抽出，再朝另一側轉向；
    # 目標之間真正的轉移連線需由 Skill 134 資料庫 Animation 表現。
    "FSV_RELEASE_TRANSFER" =>
      ["m_a", 211, 4, 0, 52, 0, 0, 0, 2, true, ""],

    # 現用：Animation 211。
    # 【未來專用動畫需求】
    # 樣本由紫色轉成深綠或黑色並快速收縮，表示毒轉化為腐蝕；
    # 目標破防與腐蝕動畫仍交給 Skill 135 資料庫 Animation。
    "FSV_RELEASE_CORROSION" =>
      ["m_a", 211, 4, 0, 25, 0, 0, 0, 0, true, ""],

    # 現用：Animation 211。
    # 【未來專用動畫需求】
    # 刀尖出現短促注射脈衝，光效只持續數 Frames；
    # 不要做成巨大斬擊，維娜的小刀重點是精準注入。
    "FSV_RELEASE_INJECTION" =>
      ["m_a", 211, 4, 0, 52, 0, 0, 0, 2, true, ""],

    # 現用：Animation 211。
    # 【未來專用動畫需求】
    # 多個病灶符號按順序點亮，最後同時共鳴；
    # 目標身上的多狀態閃爍需由 Skill 137 資料庫 Animation 表現。
    "FSV_RELEASE_SYMPTOM" =>
      ["m_a", 211, 4, 0, 52, 0, 0, 0, 2, true, ""],

    # 現用：Animation 211。
    # 【未來專用動畫需求】
    # 紫黑反應物短暫失控膨脹，維娜向後退一步後才釋放；
    # 全場毒霧與病灶爆發由 Skill 139 資料庫 Animation 負責。
    "FSV_RELEASE_GRAND" =>
      ["m_a", 211, 4, 0, 52, 0, 0, 0, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 位移
    #--------------------------------------------------------------------------

    "FSV_CAST_STEP" =>
      [3, -16, 0, 8, -1, 0, "FSV_STEP_IN"],

    "FSV_TO_TARGET" =>
      [5, 36, -8, 8, -1, -3, "FSV_STEP_IN"],

    "FSV_STAB_IN" =>
      [5, 12, -5, 4, -1, -2, "FSV_DAGGER_STAB"],

    "FSV_SLASH_PASS" =>
      [5, -12, -5, 6, -1, -2, "FSV_DAGGER_SLASH"],

    "FSV_REAR_RECOIL" =>
      [0, -14, 0, 4, -1, 0, "FSV_DAGGER_READY"],

    "FSV_REAR_FINISH" =>
      [5, -8, -4, 4, -1, -2, "FSV_DAGGER_FINISH"],

    # 萬毒交響中反應物失控，維娜下意識向後退。
    "FSV_REACTION_BACKSTEP" =>
      [0, 18, 0, 6, -1, 0, "FSV_STEP_OUT"],

    "FSV_BACKSTEP" =>
      [0, 36, 0, 8, -1, -3, "FSV_STEP_OUT"],

    "FSV_RESET" =>
      ["reset", 16, 0, 0, "FSV_STEP_OUT"],

    # 結果確認後較慢歸位。
    "FSV_RESET_INSPECT" =>
      ["reset", 20, 0, 0, "FSV_STEP_OUT"]
  }

  ANIME.merge!(FSV_WEAPON_ANIME_V11)
  ANIME.merge!(FSV_BATTLER_ANIME_V11)

  #============================================================================
  # ● 維娜技能 Action Sequences
  #============================================================================
  FSV_ACTION_SEQUENCES_V11 = {

    #--------------------------------------------------------------------------
    # Skill 130：毒音刺
    # 診斷 → 接近 → 小刀注入 → 後撤觀察反應。
    #--------------------------------------------------------------------------
    "FSV_SKILL_130" => [
      "Afterimage ON",
      "pop text_skill",
      "FSV_CAST_STEP",
      "FSV_OBSERVE_POINT",
      "FSV_SCAN_EFFECT",
      "12",
      "FSV_TO_TARGET",
      "FSV_DAGGER_READY",
      "3",
      "FSV_STAB_IN",
      "FSV_RELEASE_INJECTION",
      "3",
      "DAMAGE_ANIM_WAIT",
      "3",
      "FSV_BACKSTEP",
      "FSV_INSPECT_RESULT",
      "6",
      "FSV_INSPECT_CONFIRM",
      "4",
      "Can Collapse",
      "Afterimage OFF",
      "FSV_RESET_INSPECT"
    ],

    #--------------------------------------------------------------------------
    # Skill 131：毒音培養
    # 觀察 → 分析 → 蹲下培養 → 投放 → 確認毒素是否增殖。
    #--------------------------------------------------------------------------
    "FSV_SKILL_131" => [
      "pop text_skill",
      "FSV_CAST_STEP",
      "FSV_OBSERVE_START",
      "4",
      "FSV_OBSERVE_HOLD",
      "FSV_SCAN_EFFECT",
      "14",
      "FSV_MIX_START",
      "FSV_MIX_EFFECT",
      "6",
      "FSV_MIX_HOLD",
      "10",
      "FSV_MIX_RELEASE",
      "FSV_RELEASE_CORROSION",
      "6",
      "DAMAGE_ANIM_WAIT",
      "10",
      "FSV_INSPECT_RESULT",
      "6",
      "FSV_INSPECT_CONFIRM",
      "4",
      "Can Collapse",
      "FSV_RESET_INSPECT"
    ],

    #--------------------------------------------------------------------------
    # Skill 133：霧笛擴散
    # 遮住口鼻 → 投入藥劑 → 毒霧貼地擴散 → 觀察全場反應。
    #--------------------------------------------------------------------------
    "FSV_SKILL_133" => [
      "pop text_skill",
      "FSV_CAST_STEP",
      "FSV_MASK_START",
      "FSV_SCAN_EFFECT",
      "14",
      "FSV_MASK_HOLD",
      "8",
      "FSV_MASK_RELEASE",
      "FSV_RELEASE_MIST",
      "8",
      "ANIM_WAIT",
      "6",
      "DAMAGE",
      "10",
      "FSV_INSPECT_RESULT",
      "6",
      "Can Collapse",
      "FSV_RESET_INSPECT"
    ],

    #--------------------------------------------------------------------------
    # Skill 134：寄生轉調
    # 指向原病灶 → 分析 → 手勢轉向 → 重新附著 → 確認新宿主。
    #--------------------------------------------------------------------------
    "FSV_SKILL_134" => [
      "pop text_skill",
      "FSV_CAST_STEP",
      "FSV_OBSERVE_POINT",
      "FSV_SCAN_EFFECT",
      "16",
      "FSV_CAST_START",
      "5",
      "FSV_CAST_HOLD",
      "8",
      "FSV_CAST_RELEASE",
      "FSV_RELEASE_TRANSFER",
      "8",
      "DAMAGE_ANIM_WAIT",
      "10",
      "FSV_INSPECT_RESULT",
      "6",
      "FSV_INSPECT_CONFIRM",
      "5",
      "Can Collapse",
      "FSV_RESET_INSPECT"
    ],

    #--------------------------------------------------------------------------
    # Skill 135：腐蝕變奏
    # 取樣 → 反應物變質 → 投放腐蝕 → 確認防線是否破裂。
    #--------------------------------------------------------------------------
    "FSV_SKILL_135" => [
      "pop text_skill",
      "FSV_CAST_STEP",
      "FSV_MASK_START",
      "FSV_SCAN_EFFECT",
      "14",
      "FSV_MIX_START",
      "FSV_MIX_EFFECT",
      "6",
      "FSV_MIX_HOLD",
      "12",
      "FSV_MIX_RELEASE",
      "FSV_RELEASE_CORROSION",
      "8",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "10",
      "FSV_INSPECT_RESULT",
      "7",
      "Can Collapse",
      "FSV_RESET_INSPECT"
    ],

    #--------------------------------------------------------------------------
    # Skill 137：百病和鳴
    # 三格觀察掃描不同症狀 → 同時共鳴 → 確認結果。
    #--------------------------------------------------------------------------
    "FSV_SKILL_137" => [
      "pop text_skill",
      "FSV_CAST_STEP",
      "FSV_OBSERVE_START",
      "4",
      "FSV_OBSERVE_HOLD",
      "FSV_SCAN_EFFECT",
      "8",
      "FSV_OBSERVE_POINT",
      "8",
      "FSV_CAST_LOOP",
      "10",
      "FSV_CAST_RELEASE",
      "FSV_RELEASE_SYMPTOM",
      "8",
      "DAMAGE_ANIM_WAIT",
      "12",
      "FSV_INSPECT_RESULT",
      "8",
      "FSV_INSPECT_CONFIRM",
      "5",
      "Can Collapse",
      "FSV_RESET_INSPECT"
    ],

    #--------------------------------------------------------------------------
    # Skill 138：毒音處刑
    # 三段刀擊各有目的：打開病灶 → 切斷抗性 → 注入引爆劑。
    #--------------------------------------------------------------------------
    "FSV_SKILL_138" => [
      "Afterimage ON",
      "pop text_skill",
      "FSV_CAST_STEP",
      "FSV_OBSERVE_POINT",
      "FSV_SCAN_EFFECT",
      "18",
      "TINT_SCREEN_BLACK",
      "12",
      "FSV_TO_TARGET",
      "FSV_DAGGER_READY",
      "3",
      "FSV_STAB_IN",
      "3",
      "FSV_SLASH_PASS",
      "4",
      "FSV_REAR_RECOIL",
      "3",
      "FSV_REAR_FINISH",
      "FSV_RELEASE_INJECTION",
      "3",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "12",
      "NORMAL_SCREEN_COLOR",
      "FSV_BACKSTEP",
      "FSV_INSPECT_RESULT",
      "6",
      "FSV_INSPECT_CONFIRM",
      "4",
      "Can Collapse",
      "Afterimage OFF",
      "FSV_RESET_INSPECT"
    ],

    #--------------------------------------------------------------------------
    # Skill 139：萬毒交響
    # 長時間實驗 → 反應失控 → 後退 → 全場投放 → 冷靜確認結果。
    #--------------------------------------------------------------------------
    "FSV_SKILL_139" => [
      "Afterimage ON",
      "pop text_skill",
      "FSV_CAST_STEP",
      "FSV_PREPARE_START",
      "FSV_SCAN_EFFECT",
      "20",
      "TINT_SCREEN_BLACK",
      "14",
      "FSV_CAST_LOOP",
      "10",
      "FSV_MIX_LOOP",
      "FSV_MIX_EFFECT",
      "14",
      "FSV_REACTION_BACKSTEP",
      "6",
      "FSV_CAST_RELEASE",
      "FSV_RELEASE_GRAND",
      "10",
      "ANIM_WAIT",
      "8",
      "DAMAGE",
      "SHAKE_SCREEN2",
      "18",
      "NORMAL_SCREEN_COLOR",
      "FSV_INSPECT_RESULT",
      "8",
      "FSV_INSPECT_CONFIRM",
      "6",
      "Afterimage OFF",
      "Can Collapse",
      "FSV_RESET_INSPECT"
    ]
  }

  ACTION.merge!(FSV_ACTION_SEQUENCES_V11)

  #--------------------------------------------------------------------------
  # ● Skill ID → 維娜專屬 Action Sequence
  #--------------------------------------------------------------------------
  FSV_SKILL_ACTIONS = {
    130 => "FSV_SKILL_130",
    131 => "FSV_SKILL_131",
    133 => "FSV_SKILL_133",
    134 => "FSV_SKILL_134",
    135 => "FSV_SKILL_135",
    137 => "FSV_SKILL_137",
    138 => "FSV_SKILL_138",
    139 => "FSV_SKILL_139"
  }
end

#==============================================================================
# ** RPG::Skill
#==============================================================================
class RPG::Skill
  unless method_defined?(:fsv_verna_sbs_base_action)
    alias fsv_verna_sbs_base_action base_action
  end

  def base_action
    action_key = N01::FSV_SKILL_ACTIONS[@id]
    return action_key unless action_key == nil
    return fsv_verna_sbs_base_action
  end
end
