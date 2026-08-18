#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_Aizhuo_SBS_ActionSequence_Addon v1.3
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_Aizhuo_SBS_ActionSequence_Addon v1.3」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RPG::Skill、N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：AIZHUO_SBS_ANIME_V13、AIZHUO_SBS_ACTION_V13、FSA_AIZHUO_SKILL_ACTIONS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS-Aizhuo-SBS-ActionSequence-Addon；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_Aizhuo_SBS_ActionSequence_Addon v1.3
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# Tankentai Sideview Battle System - Action Sequence Addon
#
# 【v1.3 三連刺重建】
#   ・v1.2 主要使用單次長突刺，沒有完整保留舊三連刺的節奏。
#   ・新增三個刺槍接觸影格、收槍回彈及三段重新壓進位移。
#   ・Skill 123「雷鎖」完整使用三連刺：
#       第一刺 → 收槍 → 第二刺 → 收槍 → 第三刺正式結算。
#   ・Skill 128「零時封鎖」使用三連刺鎖定後，再追加最終貫穿。
#   ・截流槍、鏈式放電、終端超頻仍保留橫掃，維持招式差異。
#
# 【v1.2 Cast／施放動畫整合】
#   依舊腳本完整保留艾卓三階段：
#     1. AZ_CAST_FLASH：動畫 68，固定技能前置閃光。
#     2. AZ_CAST_CHARGE：動畫 73，槍尖蓄能。
#     3. AZ_RELEASE_*：動畫 74／76／79，實際施放特效。
#   所有自訂 m_a 動畫只負責演出，正式效果仍只結算一次。
#
# 【用途】
#   為 Forest Symphony 的艾卓（Actor 3）建立獨立 SBS 技能動作。
#   本腳本沿用現有艾卓人物動作格位與長槍 Weapon Sprite 動畫名稱，
#   不改寫 Tankentai 核心，也不處理技能傷害、ATB、OD 或狀態公式。
#
# 【設計原則】
#   1. 所有主動技能保留艾卓固定前置：
#      進入戰位／架槍 → 技能台詞 → 艾卓光效 → 第二段架槍。
#   2. 傷害只在 DAMAGE／DAMAGE_ANIM 系列指令發生，
#      其餘人物動作與動畫皆為演出，不重複結算技能。
#   3. 每個序列完整收尾：
#      Can Collapse → Afterimage OFF → FLEE_RESET。
#   4. 有使用畫面染色的技能，必定在結束前呼叫 NORMAL_SCREEN_COLOR。
#   5. Weapon Sprite 沿用既有名稱，例如：
#      突刺武器開始、突刺武器開始2、突刺武器開始3、
#      突刺武器1、突刺武器2、追月一段2、追月二段、追月三段。
#
# 【安裝位置】
#   放在：
#     Tankentai Sideview Battle System 本體
#     Tankentai Notetag Add-on
#     原有艾卓／長槍 Weapon Sprite 動作定義
#   的下方，Main 的上方。
#
# 【技能動作綁定】
#   本版比照 FS_Joey_SBS_Action_Addon 的 FSJ_SKILL_ACTIONS，
#   直接依技能 ID 指定 Action Sequence，不需要在資料庫 Note 填寫
#   <action: ...>。
#
#   Skill 120 電鋒突刺 → 艾卓_電鋒突刺
#   Skill 121 截流槍   → 艾卓_截流槍
#   Skill 123 雷鎖     → 艾卓_雷鎖
#   Skill 124 超載迴路 → 艾卓_超載迴路
#   Skill 125 時間斷層 → 艾卓_時間斷層
#   Skill 127 鏈式放電 → 艾卓_鏈式放電
#   Skill 128 零時封鎖 → 艾卓_零時封鎖
#   Skill 129 終端超頻 → 艾卓_終端超頻
#
#   Skill 122 靜電回收、Skill 126 超頻神經為被動技能，
#   不指定戰鬥 Action Sequence。
#
# 【人物素材微調位置】
#   若日後更換艾卓人物動作圖，只需調整 AIZHUO_SBS_ANIME_V13 中
#   AZ_READY_1 ～ AZ_SWEEP_END 的人物格位參數；
#   最後一項 Weapon Sprite 名稱可保持不變。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS-Aizhuo-SBS-ActionSequence-Addon"] = "1.3"

module N01

  #--------------------------------------------------------------------------
  # ● 艾卓專用單步動作
  #--------------------------------------------------------------------------
  # 格式完全沿用目前 Tankentai ANIME 設定。
  # 人物格位取自既有艾卓「突刺／追月」動作，武器圖層沿用原名稱。
  #--------------------------------------------------------------------------
  AIZHUO_SBS_ANIME_V13 = {

    # === 固定架槍前置 ===
    "AZ_READY_1" => [4, 1, 16, 0, 0, 0, 2, true, "突刺武器開始"],
    "AZ_READY_2" => [4, 1, 16, 0, 0, 1, 2, true, "突刺武器開始2"],
    "AZ_READY_3" => [4, 3, 16, 0, 0, 2, 2, true, "突刺武器開始3"],

    # === 突刺與收槍 ===
    "AZ_THRUST"  => [2, 1,  2, 2, 0, 2, 2, true, "突刺武器1"],
    "AZ_RECOVER" => [1, 0,  2, 2, 0, 2, 2, true, "突刺武器2"],

    # v1.3 三連刺固定影格。
    "AZ_THRUST_1" =>
      [2, 1, 16, 0, 0, 0, 2, true, "突刺武器開始3"],

    "AZ_THRUST_2" =>
      [2, 1, 16, 0, 0, 1, 2, true, "突刺武器1"],

    "AZ_THRUST_3" =>
      [2, 1, 16, 0, 0, 2, 2, true, "突刺武器1"],

    "AZ_THRUST_RECOIL" =>
      [1, 0, 16, 0, 0, 2, 2, true, "突刺武器2"],

    # === 橫掃／放電 ===
    "AZ_SWEEP_READY" => [4, 1,  8, 0, 0, 1, 2, true, "追月一段2"],
    "AZ_SWEEP"       => [3, 2,  8, 0, 0, 2, 2, true, "追月二段"],
    "AZ_SWEEP_END"   => [4, 0, 16, 0, 0, 0, 2, true, "追月三段"],

    # === Cast／施放動畫：完整沿用舊腳本參數 ===
    "AZ_CAST_FLASH" =>
      ["m_a", 68, 4, 0, 25, 0, 0, 0, 0, true, ""],

    "AZ_CAST_CHARGE" =>
      ["m_a", 73, 4, 0, 52, 0, 0, 0, 2, true, ""],

    "AZ_RELEASE_SWEEP" =>
      ["m_a", 74, 4, 0, 52, 0, 0, 0, 2, true, ""],

    "AZ_RELEASE_THRUST" =>
      ["m_a", 76, 4, 0, 52, 0, 0, 0, 2, true, ""],

    "AZ_RELEASE_CRASH" =>
      ["m_a", 79, 4, 0, 52, 0, 0, 0, 2, true, ""],

    # === 位移：數值沿用原艾卓有效動作的方向與座標系 ===
    "AZ_DASH_IN"       => [5,  70, -10, 4, -1,  0, "ATTACK_MOVE_POSE2"],
    "AZ_THRUST_SHORT"  => [0, -36,   2, 4, -1,  0, "AZ_THRUST"],

    # v1.3 三連刺：每刺都先壓進，命中後再回彈收槍。
    "AZ_JAB_1_IN" =>
      [0, -28, 2, 3, -1, 0, "AZ_THRUST_1"],

    "AZ_JAB_RECOIL" =>
      [0, 18, 0, 3, -1, 0, "AZ_THRUST_RECOIL"],

    "AZ_JAB_2_IN" =>
      [0, -34, 1, 3, -1, 0, "AZ_THRUST_2"],

    "AZ_JAB_3_IN" =>
      [0, -42, 2, 3, -1, 0, "AZ_THRUST_3"],

    # 三連刺鎖定後的最終貫穿。
    "AZ_JAB_BREAK_IN" =>
      [0, -78, 3, 3, -1, 0, "END_SPEAR_THRUST"],

    "AZ_THRUST_MEDIUM" => [0, -80,   3, 4, -1,  0, "END_SPEAR_THRUST"],
    "AZ_THRUST_HEAVY"  => [0,-130,   3, 3, -1,  0, "END_SPEAR_THRUST"],
    "AZ_THRUST_BREAK"  => [0,-170,   3, 3, -1,  0, "END_SPEAR_THRUST"],
    "AZ_RECOVER_STEP"  => [0,  24,   0, 6, -1,  0, "AZ_RECOVER"],
    "AZ_SWEEP_LEFT"    => [0, -12,   0, 5, -1, -4, "AZ_SWEEP"],
    "AZ_SWEEP_RIGHT"   => [0,  16,   0, 8, -1, -3, "AZ_SWEEP_END"],
    "AZ_JUMP_STRIKE"   => [0, -35,   5, 8, -1, -4, "AZ_SWEEP"]
  }

  #--------------------------------------------------------------------------
  # ● 艾卓主動技能 Action Sequences
  #--------------------------------------------------------------------------
  AIZHUO_SBS_ACTION_V13 = {

    #========================================================================
    # Skill 120：電鋒突刺
    # 快速接近，以短距離電槍突刺完成一次傷害與 ATB 削減。
    #========================================================================
    "艾卓_電鋒突刺" => [
      "Afterimage ON",
      "AZ_DASH_IN",
      "8",
      "AZ_READY_1",
      "pop text_skill",
      "AZ_CAST_FLASH",
      "24",
      "AZ_READY_2",
      "AZ_CAST_CHARGE",
      "12",
      "AZ_READY_3",
      "AZ_RELEASE_THRUST",
      "4",
      "AZ_THRUST_SHORT",
      "DAMAGE_ANIM_WAIT",
      "AZ_RECOVER_STEP",
      "12",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ],

    #========================================================================
    # Skill 121：截流槍
    # 槍身橫掃切斷敵方行動流；只結算一次技能傷害。
    #========================================================================
    "艾卓_截流槍" => [
      "Afterimage ON",
      "AZ_DASH_IN",
      "8",
      "AZ_READY_1",
      "pop text_skill",
      "AZ_CAST_FLASH",
      "24",
      "AZ_SWEEP_READY",
      "AZ_CAST_CHARGE",
      "12",
      "AZ_SWEEP_LEFT",
      "AZ_RELEASE_SWEEP",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "AZ_SWEEP_RIGHT",
      "12",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ],

    #========================================================================
    # Skill 123：雷鎖
    # 固定前置後充電，將雷能集中於槍尖再貫穿目標。
    #========================================================================
    "艾卓_雷鎖" => [
      "Afterimage ON",
      "AZ_DASH_IN",
      "8",
      "AZ_READY_1",
      "pop text_skill",
      "AZ_CAST_FLASH",
      "28",
      "AZ_READY_2",
      "AZ_CAST_CHARGE",
      "24",
      "AZ_READY_3",
      "4",

      # 第一刺：壓進、槍光、目標動畫、收槍。
      "AZ_JAB_1_IN",
      "AZ_RELEASE_THRUST",
      "ANIM",
      "3",
      "AZ_JAB_RECOIL",

      # 第二刺。
      "AZ_JAB_2_IN",
      "AZ_RELEASE_THRUST",
      "ANIM",
      "3",
      "AZ_JAB_RECOIL",

      # 第三刺正式結算雷鎖效果。
      "AZ_JAB_3_IN",
      "AZ_RELEASE_THRUST",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "AZ_RECOVER_STEP",
      "12",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ],

    #========================================================================
    # Skill 124：超載迴路
    # 自身支援技能，不接近敵人；CAST_ANIMATION 顯示資料庫技能動畫，
    # DAMAGE 負責套用技能狀態／效果，沒有多餘傷害判定。
    #========================================================================
    "艾卓_超載迴路" => [
      "Afterimage ON",
      "原地前進",
      "8",
      "AZ_READY_1",
      "pop text_skill",
      "AZ_CAST_FLASH",
      "28",
      "AZ_READY_2",
      "AZ_CAST_CHARGE",
      "24",
      "CAST_ANIMATION",
      "ANIM_WAIT",
      "4",
      "DAMAGE",
      "16",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ],

    #========================================================================
    # Skill 125：時間斷層
    # 蓄力後以重突刺切開行動時間軸；高 ATB 打斷判定仍由技能腳本處理。
    #========================================================================
    "艾卓_時間斷層" => [
      "Afterimage ON",
      "AZ_DASH_IN",
      "8",
      "AZ_READY_1",
      "pop text_skill",
      "AZ_CAST_FLASH",
      "28",
      "AZ_READY_2",
      "AZ_CAST_CHARGE",
      "24",
      "AZ_READY_3",
      "4",
      "AZ_RELEASE_CRASH",
      "AZ_THRUST_HEAVY",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "AZ_RECOVER_STEP",
      "16",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ],

    #========================================================================
    # Skill 127：鏈式放電
    # 全體技能。艾卓留在原位，以長槍橫掃導出連鎖電流。
    #========================================================================
    "艾卓_鏈式放電" => [
      "Afterimage ON",
      "原地前進",
      "8",
      "AZ_READY_1",
      "pop text_skill",
      "AZ_CAST_FLASH",
      "28",
      "AZ_SWEEP_READY",
      "AZ_CAST_CHARGE",
      "20",
      "AZ_SWEEP_LEFT",
      "AZ_RELEASE_SWEEP",
      "4",
      "AZ_SWEEP_RIGHT",
      "AZ_RELEASE_THRUST",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "16",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ],

    #========================================================================
    # Skill 128：零時封鎖
    # 單體大招。暗幕只服務演出，最終仍只進行一次技能傷害判定。
    #========================================================================
    "艾卓_零時封鎖" => [
      "Afterimage ON",
      "AZ_DASH_IN",
      "8",
      "AZ_READY_1",
      "pop text_skill",
      "AZ_CAST_FLASH",
      "32",
      "AZ_READY_2",
      "TINT_SCREEN_BLACK",
      "16",
      "AZ_CAST_CHARGE",
      "32",
      "AZ_READY_3",
      "4",

      # 三連刺先封鎖目標動作。
      "AZ_JAB_1_IN",
      "AZ_RELEASE_THRUST",
      "ANIM",
      "3",
      "AZ_JAB_RECOIL",

      "AZ_JAB_2_IN",
      "AZ_RELEASE_THRUST",
      "ANIM",
      "3",
      "AZ_JAB_RECOIL",

      "AZ_JAB_3_IN",
      "AZ_RELEASE_THRUST",
      "ANIM",
      "4",
      "AZ_JAB_RECOIL",

      # 最終長距離貫穿才正式結算。
      "AZ_RELEASE_CRASH",
      "AZ_JAB_BREAK_IN",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "16",
      "NORMAL_SCREEN_COLOR",
      "AZ_RECOVER_STEP",
      "12",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ],

    #========================================================================
    # Skill 129：終端超頻
    # 全體終極技。三段人物演出後，最後一次性結算全體技能效果。
    #========================================================================
    "艾卓_終端超頻" => [
      "Afterimage ON",
      "原地前進",
      "8",
      "AZ_READY_1",
      "pop text_skill",
      "AZ_CAST_FLASH",
      "32",
      "AZ_READY_2",
      "TINT_SCREEN_BLACK",
      "16",
      "AZ_CAST_CHARGE",
      "32",
      "AZ_SWEEP_READY",
      "4",
      "AZ_SWEEP_LEFT",
      "AZ_RELEASE_SWEEP",
      "4",
      "AZ_SWEEP_RIGHT",
      "AZ_RELEASE_THRUST",
      "8",
      "AZ_JUMP_STRIKE",
      "AZ_RELEASE_CRASH",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "16",
      "NORMAL_SCREEN_COLOR",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ]
  }

  #--------------------------------------------------------------------------
  # ● 合併到 Tankentai
  #--------------------------------------------------------------------------
  # 若在這裡報 NameError，表示本腳本放在 Tankentai 本體上方。
  #--------------------------------------------------------------------------
  ANIME.merge!(AIZHUO_SBS_ANIME_V13)
  ACTION.merge!(AIZHUO_SBS_ACTION_V13)

  #--------------------------------------------------------------------------
  # ● 技能 ID → Action Sequence 鍵
  #--------------------------------------------------------------------------
  # 比照 FSJ_SKILL_ACTIONS：技能使用時直接由 ID 取得動作名稱，
  # 不需要在技能 Note 中另外填寫 <action: ...>。
  #--------------------------------------------------------------------------
  FSA_AIZHUO_SKILL_ACTIONS = {
    120 => "艾卓_電鋒突刺",
    121 => "艾卓_截流槍",
    123 => "艾卓_雷鎖",
    124 => "艾卓_超載迴路",
    125 => "艾卓_時間斷層",
    127 => "艾卓_鏈式放電",
    128 => "艾卓_零時封鎖",
    129 => "艾卓_終端超頻"
  }
end

#==============================================================================
# ** RPG::Skill
#------------------------------------------------------------------------------
#  最終技能動作路由層。
#------------------------------------------------------------------------------
#  只有列在 FSA_AIZHUO_SKILL_ACTIONS 的技能會被本腳本接管；
#  其他技能仍呼叫前一層 base_action，因此可與喬伊及其他角色的
#  技能動作綁定腳本串接，不會把其他技能的設定吃掉。
#==============================================================================

class RPG::Skill
  unless method_defined?(:fsa_aizhuo_sbs_base_action)
    alias fsa_aizhuo_sbs_base_action base_action
  end

  def base_action
    action_key = N01::FSA_AIZHUO_SKILL_ACTIONS[@id]
    return action_key unless action_key == nil
    return fsa_aizhuo_sbs_base_action
  end
end
