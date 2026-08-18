#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_Mia_SBS_ActionSequence_Addon v1.0 繁體中
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_Mia_SBS_ActionSequence_Addon v1.0 繁體中」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RPG::Skill、N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：FSM_ANIME_KEYS_V13、FSM_ACTION_SEQUENCES_V13、FSM_SKILL_ACTIONS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS_Mia_SBS_ActionSequence_Addon；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ** FS_Mia_SBS_ActionSequence_Addon v1.3 繁體中文版
#------------------------------------------------------------------------------
#  Forest Symphony／RPG Maker VX／RGSS2
#  米亞專屬 Tankentai SBS Action Sequence Addon
#------------------------------------------------------------------------------
# 【v1.3 角色動作特色重製】
#
#  米亞的動作語言統一為：
#
#    祈禱收束 → 呼吸停頓 → 光芒展開 → 技能落下 → 保留餘韻
#
#  本版不再讓所有治療技能只重複同一列祈禱，而是依照附件圖格拆分：
#
#    $Actor5_1 Row 1：低位／坐姿祈禱，只用於生命回響。
#    $Actor5_1 Row 2：異常狀態，任何主動技能都不得使用。
#    $Actor5_2 Row 0：胸前收光、接收溢光。
#    $Actor5_2 Row 1：雙手向外展開，作為護幕姿勢。
#    $Actor5_3 Row 0：單手收束、伸手釋放。
#    $Actor5_3 Row 1：魔法弓架弓與拉弦。
#    $Actor5_3 Row 2：魔法弓放箭與攻擊收束。
#    $Actor5_3 Row 3：正式 Cast／Pray 三拍祈禱。
#
#  這些格位完全依照使用者提供的角色動作圖編排。
#
# 【功能範圍】
#  只處理米亞 Skill 110～119 的人物姿勢、魔法弓 Weapon Sprite、
#  使用者動畫、資料庫目標動畫、等待節奏與效果結算時點。
#
#  不改寫：
#    ・治療與傷害公式
#    ・溢療轉魔力層
#    ・護盾容量
#    ・復活規則
#    ・OD、ATB、冷卻、技能消耗與狀態判定
#
# 【安裝位置】
#  放在以下腳本下方、Main 上方：
#    1. Tankentai SBS／SBS Battler Configuration
#    2. Bubs' Bow Add-on (K)
#    3. Skill Action／Skill Activation／Notetag／Make skill action
#    4. 其他角色專屬 SBS Addon
#
#  請用 v1.3 完整取代米亞 v1.0～v1.2，不要同時保留。
#
# 【必要圖檔｜Graphics/Characters】
#    $Actor5.png
#    $Actor5_1.png
#    $Actor5_2.png
#    $Actor5_3.png
#
#  角色資料庫 character_name 維持「$Actor5」。
#
# 【技能直接綁定】
#   110 療癒弦光
#   111 溢光弦
#   113 護幕弦音
#   114 群體禱歌
#   115 魔力彈
#   117 星輝爆發
#   118 生命回響
#   119 大地頌歌
#
#  Skill 112「溢光回路」與 116「大地祝福」為被動技能。
#
# 【效果安全規則】
#   ・每個主動技能只執行一次 DAMAGE 或 DAMAGE_ANIM_WAIT。
#   ・自訂 m_a 動畫只負責使用者演出，不直接結算技能效果。
#   ・目標動畫使用技能資料庫 Animation。
#   ・每個 Afterimage ON 都有對應的 Afterimage OFF。
#   ・效果完成後執行 Can Collapse。
#   ・法術使用 FSM_RESET_SOFT，弓技使用 FSM_RESET。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS_Mia_SBS_ActionSequence_Addon"] = "1.3"

unless defined?(N01::ANIME) && defined?(N01::ACTION)
  raise "FS_Mia_SBS_ActionSequence_Addon 必須放在 Tankentai SBS 下方。"
end

module N01

  #============================================================================
  # ● 米亞姿勢、魔法弓、演出動畫與位移
  #============================================================================
  FSM_ANIME_KEYS_V13 = {

    #--------------------------------------------------------------------------
    # ■ Weapon Sprite
    #--------------------------------------------------------------------------
    # 沿用 Bubs Bow Add-on「伸出」的魔法弓方法。
    "FSM_WPN_DRAW" =>
      [3, 0, true, 45, 45, 4, false, 0, 0, 8, -6, false],

    #--------------------------------------------------------------------------
    # ■ 移動
    #--------------------------------------------------------------------------

    # $Actor5_1 Row 3：移動用，不作 Cast／Pray。
    "FSM_STEP_POSE" =>
      [1, 3, 15, 0, 0, -1, 0, true, ""],

    #--------------------------------------------------------------------------
    # ■ 正式祈禱：$Actor5_3 Row 3
    #--------------------------------------------------------------------------

    "FSM_PRAY_START" =>
      [3, 3, 15, 0, 0, 0, 2, true, ""],

    "FSM_PRAY_HOLD" =>
      [3, 3, 15, 0, 0, 1, 2, true, ""],

    "FSM_PRAY_RELEASE" =>
      [3, 3, 15, 0, 0, 2, 2, true, ""],

    "FSM_PRAY_LOOP" =>
      [3, 3, 5, 2, 0, -1, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 單手收束／釋放：$Actor5_3 Row 0
    #--------------------------------------------------------------------------

    "FSM_HAND_GATHER" =>
      [3, 3, 15, 0, 0, 0, 2, true, ""],

    "FSM_HAND_RETURN" =>
      [3, 3, 15, 0, 0, 1, 2, true, ""],

    "FSM_HAND_EXTEND" =>
      [3, 3, 15, 0, 0, 2, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 胸前收光／接收溢光：$Actor5_2 Row 0
    #--------------------------------------------------------------------------

    "FSM_CHEST_GATHER" =>
      [2, 0, 15, 0, 0, 0, 2, true, ""],

    "FSM_CHEST_RECEIVE" =>
      [2, 0, 15, 0, 0, 1, 2, true, ""],

    "FSM_CHEST_SEAL" =>
      [2, 0, 15, 0, 0, 2, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 護幕展開：$Actor5_2 Row 1
    #--------------------------------------------------------------------------

    "FSM_BARRIER_START" =>
      [2, 1, 15, 0, 0, 0, 2, true, ""],

    "FSM_BARRIER_HOLD" =>
      [2, 1, 15, 0, 0, 1, 2, true, ""],

    "FSM_BARRIER_RELEASE" =>
      [2, 1, 15, 0, 0, 2, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 低位／坐姿復活祈禱：$Actor5_1 Row 1
    #--------------------------------------------------------------------------
    # 注意：$Actor5_1 Row 2 才是異常狀態，本腳本永不使用 Row 2。

    "FSM_LOW_PRAY_START" =>
      [1, 1, 15, 0, 0, 0, 1, true, ""],

    "FSM_LOW_PRAY_HOLD" =>
      [1, 1, 15, 0, 0, 1, 1, true, ""],

    "FSM_LOW_PRAY_RELEASE" =>
      [1, 1, 15, 0, 0, 2, 1, true, ""],

    "FSM_LOW_PRAY_LOOP" =>
      [1, 1, 6, 2, 0, -1, 1, true, ""],

    #--------------------------------------------------------------------------
    # ■ 魔法弓：$Actor5_3 Row 1／Row 2
    #--------------------------------------------------------------------------

    "FSM_BOW_READY" =>
      [3, 1, 15, 0, 0, 0, 1, true, "FSM_WPN_DRAW"],

    "FSM_BOW_DRAW" =>
      [3, 1, 15, 0, 0, 1, 1, true, "FSM_WPN_DRAW"],

    "FSM_BOW_FULL_DRAW" =>
      [3, 1, 15, 0, 0, 2, 1, true, "FSM_WPN_DRAW"],

    "FSM_BOW_RELEASE" =>
      [3, 2, 15, 0, 0, 2, 2, true, "FSM_WPN_DRAW"],

    "FSM_STAR_CAST" =>
      [3, 2, 4, 2, 0, -1, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 使用者演出動畫
    #--------------------------------------------------------------------------
    # 下列動畫目前先使用專案已存在的 Animation 34／84／83。
    # 每一鍵旁都標註未來專用動畫需求；製作新動畫後只需替換 ID，
    # 不必修改任何技能 Action Sequence。
    #--------------------------------------------------------------------------

    # 現用：Animation 34「召喚上升」。
    # 【未來專用動畫需求】
    # 柔和金綠色光從腳下向胸前上升，範圍窄、亮度不刺眼，
    # 用來表現米亞吸氣並收束魔力，不應像爆炸或召喚陣。
    "FSM_CAST_LIGHT" =>
      ["m_a", 262, 4, 0, 52, 0, 0, 0, 2, true, ""],

    # 現用：Animation 34 作為替代。
    # 【未來專用動畫需求】
    # 一束細緻弦光由米亞手心向外展開；真正落在目標身上的動畫
    # 仍由技能資料庫 Animation 負責。
    "FSM_HEAL_RELEASE_LIGHT" =>
      ["m_a", 228, 4, 0, 25, 0, 0, 0, 0, true, ""],

    # 現用：Animation 34 作為替代。
    # 【未來專用動畫需求】
    # 數個小型光點從畫面前方向米亞胸口回流並縮成一顆光核，
    # 用來清楚表現「溢療回收為魔力層」。
    "FSM_OVERFLOW_RETURN_LIGHT" =>
      ["m_a", 184, 4, 0, 52, 0, 0, 0, 2, true, ""],

    # 現用：Animation 34 作為替代。
    # 【未來專用動畫需求】
    # 半透明圓弧由米亞胸前向左右水平展開，像拉開一層弦幕；
    # 不需要攻擊火花，重點是空間被撐開。
    "FSM_BARRIER_SPREAD_LIGHT" =>
      ["m_a", 62, 4, 0, 25, 0, 0, 0, 0, true, ""],

    # 現用：Animation 34 作為替代。
    # 【未來專用動畫需求】
    # 地面出現一圈柔和金綠色光紋，先沉入地面再向外擴散；
    # 用來表現大地頌歌，而非一般向上 Cast。
    "FSM_EARTH_PULSE_LIGHT" =>
      ["m_a", 59, 4, 0, 25, 0, 0, 0, 0, true, ""],

    # 現用：Animation 34 作為替代。
    # 【未來專用動畫需求】
    # 米亞抬手時出現一條向上的細光柱；目標真正被拉起的光柱
    # 應設定在 Skill 118 的資料庫 Animation。
    "FSM_REVIVE_LIFT_LIGHT" =>
      ["m_a", 34, 4, 0, 52, 0, 0, 0, 2, true, ""],

    # 現用：Animation 84。
    # 【未來專用動畫需求】
    # 魔法弓弦與箭尖出現第一次壓縮光，不要遮住人物手部。
    "FSM_BOW_LIGHT_A" =>
      ["m_a", 84, 4, 0, 25, 0, 0, 0, 0, true, ""],

    # 現用：Animation 83。
    # 【未來專用動畫需求】
    # 放箭瞬間形成細長光線與弦震，不要變成大範圍爆炸。
    "FSM_BOW_LIGHT_B" =>
      ["m_a", 83, 4, 0, 52, 0, 0, 0, 2, true, ""],

    # 現用：Animation 84 作為替代。
    # 【未來專用動畫需求】
    # 星光粒子逐步被壓縮到箭尖，亮度先慢後快增加，
    # 用於星輝爆發的長拉弦停頓。
    "FSM_STAR_TENSION_LIGHT" =>
      ["m_a", 84, 4, 0, 52, 0, 0, 0, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 位移與歸位
    #--------------------------------------------------------------------------

    "FSM_CAST_STEP" =>
      [3, -24, 0, 12, -1, 0, "FSM_STEP_POSE"],

    "FSM_BOW_STEP" =>
      [3, -32, 0, 18, -1, 0, "FSM_STEP_POSE"],

    "FSM_RESET" =>
      ["reset", 16, 0, 0, "FSM_STEP_POSE"],

    # 法術結束保留較長呼吸與餘韻。
    "FSM_RESET_SOFT" =>
      ["reset", 22, 0, 0, "FSM_STEP_POSE"]
  }

  ANIME.merge!(FSM_ANIME_KEYS_V13)

  #============================================================================
  # ● 米亞技能 Action Sequences
  #============================================================================
  FSM_ACTION_SEQUENCES_V13 = {

    #--------------------------------------------------------------------------
    # Skill 110：療癒弦光
    # 基礎治療：短祈禱 → 單手推出弦光 → 保留短暫伸手餘韻。
    #--------------------------------------------------------------------------
    "FSM_SKILL_110" => [
      "pop text_skill",
      "FSM_CAST_STEP",
      "FSM_PRAY_START",
      "FSM_CAST_LIGHT",
      "12",
      "FSM_HAND_GATHER",
      "4",
      "FSM_HAND_EXTEND",
      "FSM_HEAL_RELEASE_LIGHT",
      "DAMAGE_ANIM_WAIT",
      "8",
      "FSM_HAND_RETURN",
      "6",
      "Can Collapse",
      "FSM_RESET_SOFT"
    ],

    #--------------------------------------------------------------------------
    # Skill 111：溢光弦
    # 治療後將多餘光芒收回胸前，視覺化魔力層形成。
    #--------------------------------------------------------------------------
    "FSM_SKILL_111" => [
      "pop text_skill",
      "FSM_CAST_STEP",
      "FSM_PRAY_START",
      "FSM_CAST_LIGHT",
      "14",
      "FSM_PRAY_HOLD",
      "8",
      "FSM_HAND_EXTEND",
      "FSM_HEAL_RELEASE_LIGHT",
      "DAMAGE_ANIM_WAIT",
      "8",
      "FSM_CHEST_RECEIVE",
      "FSM_OVERFLOW_RETURN_LIGHT",
      "10",
      "FSM_CHEST_SEAL",
      "8",
      "Can Collapse",
      "FSM_RESET_SOFT"
    ],

    #--------------------------------------------------------------------------
    # Skill 113：護幕弦音
    # 雙手橫向展開，把空間撐成護幕，而不是再做一次普通祈禱。
    #--------------------------------------------------------------------------
    "FSM_SKILL_113" => [
      "pop text_skill",
      "FSM_CAST_STEP",
      "FSM_PRAY_START",
      "FSM_CAST_LIGHT",
      "14",
      "FSM_BARRIER_START",
      "5",
      "FSM_BARRIER_HOLD",
      "FSM_BARRIER_SPREAD_LIGHT",
      "10",
      "FSM_BARRIER_RELEASE",
      "DAMAGE_ANIM_WAIT",
      "10",
      "FSM_BARRIER_HOLD",
      "8",
      "Can Collapse",
      "FSM_RESET_SOFT"
    ],

    #--------------------------------------------------------------------------
    # Skill 114：群體禱歌
    # 完整祈禱循環 → 雙手展開 → 資料庫全體動畫 → 全體效果。
    #--------------------------------------------------------------------------
    "FSM_SKILL_114" => [
      "pop text_skill",
      "FSM_CAST_STEP",
      "FSM_PRAY_LOOP",
      "FSM_CAST_LIGHT",
      "20",
      "FSM_PRAY_RELEASE",
      "6",
      "FSM_HAND_EXTEND",
      "FSM_HEAL_RELEASE_LIGHT",
      "ANIM_WAIT",
      "6",
      "DAMAGE",
      "10",
      "FSM_HAND_RETURN",
      "8",
      "Can Collapse",
      "FSM_RESET_SOFT"
    ],

    #--------------------------------------------------------------------------
    # Skill 115：魔力彈
    # 快速四段拉弓：架弓 → 拉弦 → 滿弦 → 放箭。
    #--------------------------------------------------------------------------
    "FSM_SKILL_115" => [
      "Afterimage ON",
      "pop text_skill",
      "FSM_BOW_STEP",
      "FSM_HAND_GATHER",
      "FSM_CAST_LIGHT",
      "10",
      "DRAW_BOW2",
      "FSM_BOW_READY",
      "3",
      "FSM_BOW_DRAW",
      "FSM_BOW_LIGHT_A",
      "8",
      "FSM_BOW_FULL_DRAW",
      "FSM_BOW_LIGHT_B",
      "5",
      "FSM_BOW_RELEASE",
      "DAMAGE_ANIM_WAIT",
      "10",
      "Afterimage OFF",
      "Can Collapse",
      "FSM_RESET"
    ],

    #--------------------------------------------------------------------------
    # Skill 117：星輝爆發
    # 長拉弦：星光聚能 → 架弓 → 慢拉滿弦 → 壓縮停頓 → 快速放箭。
    #--------------------------------------------------------------------------
    "FSM_SKILL_117" => [
      "Afterimage ON",
      "pop text_skill",
      "FSM_BOW_STEP",
      "FSM_STAR_CAST",
      "FSM_CAST_LIGHT",
      "18",
      "DRAW_BOW2",
      "FSM_BOW_READY",
      "4",
      "FSM_BOW_DRAW",
      "FSM_BOW_LIGHT_A",
      "8",
      "FSM_BOW_FULL_DRAW",
      "FSM_STAR_TENSION_LIGHT",
      "12",
      "FSM_BOW_LIGHT_B",
      "4",
      "FSM_BOW_RELEASE",
      "DAMAGE_ANIM_WAIT",
      "14",
      "Afterimage OFF",
      "Can Collapse",
      "FSM_RESET"
    ],

    #--------------------------------------------------------------------------
    # Skill 118：生命回響
    # 低位祈禱 → 長停頓 → 抬手牽引生命 → 資料庫復活動畫與效果。
    #--------------------------------------------------------------------------
    "FSM_SKILL_118" => [
      "pop text_skill",
      "FSM_CAST_STEP",
      "FSM_LOW_PRAY_START",
      "FSM_CAST_LIGHT",
      "18",
      "FSM_LOW_PRAY_LOOP",
      "12",
      "FSM_LOW_PRAY_HOLD",
      "10",
      "FSM_LOW_PRAY_RELEASE",
      "FSM_REVIVE_LIFT_LIGHT",
      "8",
      "FSM_HAND_EXTEND",
      "DAMAGE_ANIM_WAIT",
      "14",
      "FSM_HAND_RETURN",
      "10",
      "Can Collapse",
      "FSM_RESET_SOFT"
    ],

    #--------------------------------------------------------------------------
    # Skill 119：大地頌歌
    # 胸前收光 → 光沉入地面 → 完整祈禱 → 地表向全隊回升。
    #--------------------------------------------------------------------------
    "FSM_SKILL_119" => [
      "Afterimage ON",
      "pop text_skill",
      "FSM_CAST_STEP",
      "FSM_PRAY_START",
      "FSM_CAST_LIGHT",
      "22",
      "FSM_CHEST_GATHER",
      "6",
      "FSM_CHEST_SEAL",
      "FSM_EARTH_PULSE_LIGHT",
      "14",
      "FSM_PRAY_LOOP",
      "12",
      "FSM_PRAY_RELEASE",
      "ANIM_WAIT",
      "8",
      "DAMAGE",
      "14",
      "FSM_CHEST_RECEIVE",
      "8",
      "Afterimage OFF",
      "Can Collapse",
      "FSM_RESET_SOFT"
    ]
  }

  ACTION.merge!(FSM_ACTION_SEQUENCES_V13)

  #--------------------------------------------------------------------------
  # ● Skill ID → 米亞專屬 Action Sequence
  #--------------------------------------------------------------------------
  FSM_SKILL_ACTIONS = {
    110 => "FSM_SKILL_110",
    111 => "FSM_SKILL_111",
    113 => "FSM_SKILL_113",
    114 => "FSM_SKILL_114",
    115 => "FSM_SKILL_115",
    117 => "FSM_SKILL_117",
    118 => "FSM_SKILL_118",
    119 => "FSM_SKILL_119"
  }
end

#==============================================================================
# ** RPG::Skill
#==============================================================================
class RPG::Skill
  unless method_defined?(:fsm_mia_sbs_base_action)
    alias fsm_mia_sbs_base_action base_action
  end

  def base_action
    action_key = N01::FSM_SKILL_ACTIONS[@id]
    return action_key unless action_key == nil
    return fsm_mia_sbs_base_action
  end
end
