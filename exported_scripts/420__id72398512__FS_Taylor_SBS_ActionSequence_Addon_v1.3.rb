#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_Taylor_SBS_ActionSequence_Addon v1.3
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_Taylor_SBS_ActionSequence_Addon v1.3」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RPG::Skill、N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：FST_BATTLER_ANIME、FST_ACTION_SEQUENCES、FST_SKILL_ACTIONS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS_Taylor_SBS_ActionSequence_Addon；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_Taylor_SBS_ActionSequence_Addon v1.3
#------------------------------------------------------------------------------
# Forest Symphony / RPG Maker VX / RGSS2
# Tankentai Sideview Battle System - Action Sequence Addon
#------------------------------------------------------------------------------
# 【v1.3 接敵與集氣節奏重製】
#   ・所有會攻擊敵人的主動技能，統一先執行：
#       大跳接近 → 小跳修正落點 → 停在目標前約 84px
#       → 集氣姿勢 → 集氣動畫 165 → 正式拳腳。
#   ・84px 約等於本專案戰鬥畫面中的 5～6 個短步距離。
#   ・每段拳腳仍維持 v1.1 的重新貼近與逐擊動畫。
#   ・Skill 155 是自身強化，不會跳到敵人面前，但仍保留集氣。
#
# 【v1.2 Cast／施放動畫整合】
#   ・Skill 150、151、153、157 補回舊泰勒「集氣動畫」節奏。
#   ・Skill 154、155、158、159 原有集氣／空中集氣動畫完整保留。
#   ・每段拳腳的 ANIM 與最後 DAMAGE_ANIM_WAIT 仍負責施放／命中效果。
#   ・Cast 動畫不結算傷害，正式技能效果仍只執行一次。
#
# 【v1.1 打擊感修正】
#   ・每次切換拳腳姿勢，都先短暫收身，再重新接近目標一次。
#   ・每一段可見拳腳都播放一次 ANIM／DAMAGE_ANIM_WAIT。
#   ・前段只播放動畫，最後一段才結算正式技能效果，避免多段演出
#     直接把資料庫傷害與 Break 倍率重複套用。
#   ・連段節奏統一為：貼近 → 攻擊動畫 → 停頓 → 收身 → 下一擊。
#
# 【用途】
#   為泰勒（Actor 6）建立獨立 SBS 技能動作，直接依技能 ID 接管
#   RPG::Skill#base_action，不需要在技能 Note 另外填寫 <action: ...>。
#
#   本腳本只處理：
#     ・泰勒的人物姿勢
#     ・接近、追擊、跳躍、後撤與歸位
#     ・資料庫技能動畫的播放時機
#     ・技能效果／傷害的結算時機
#
#   本腳本不改寫：
#     ・技能傷害公式、屬性、Break、OD、ATB、狀態與冷卻
#     ・破勢層數、崩防判定與額外傷害規則
#     ・資料庫技能範圍與命中率
#
# 【安裝位置】
#   必須放在以下腳本的下方，並放在 Main 的正上方：
#     1. Tankentai SBS／SBS Battler Configuration
#     2. 所有原始 Action Sequence Addon
#     3. Skill Action／Skill Activation／Notetag 類擴充腳本
#     4. Make skill action
#     5. FS_Joey_SBS_Action_Addon
#     6. FS_Aizhuo_SBS_ActionSequence_Addon
#     7. FS_Ivy_SBS_ActionSequence_Addon
#
#   專案內有多層 RPG::Skill#base_action，本腳本必須排在後段以 alias
#   串接，才能保證 Skill 150～159 的指定動作不被後續腳本覆蓋。
#
# 【必要圖檔】
#   請放入 Graphics/Characters：
#     $Actor40.png
#     $Actor40_1.png
#     $Actor40_2.png
#     $Actor40_3.png
#     $Actor40_4.png
#     $Actor40_5.png
#     $Actor40_6.png
#     $Actor40_7.png
#     $Actor40_8.png
#
#   角色資料庫 character_name 維持「$Actor40」。
#   附件若名為「$Actor40_1(1).png」，必須改名成「$Actor40_1.png」。
#   Tankentai 的 FileNo 只會讀取 _1、_2、_3……，不會把「(1)」理解成
#   人類檔案管理史上又一次無害的小創意。
#
# 【未使用的 $Actor40w 系列】
#   $Actor40w、$Actor40w_1、$Actor40w_2 是 64×64、人物與武器已合成的
#   舊「武器大師」動作圖。泰勒目前正式技能 150～159 使用破城拳甲，
#   並依全腳本既有方式採用「無獨立 Weapon Sprite」的人物動作，因此
#   本腳本不載入 w 系列，也不建立 Weapon Sprite 動作。
#
# 【素材格位與動作語言】
#   FileNo 0：$Actor40.png       基礎待機／方向
#   FileNo 1：$Actor40_1.png     戰鬥待機／移動與低位姿勢
#   FileNo 2：$Actor40_2.png     翻滾／跳躍／倒地
#   FileNo 3：$Actor40_3.png     拳擊、踢擊、火焰聚能
#   FileNo 4：$Actor40_4.png     突進拳、飛踢、重心壓低
#   FileNo 5：$Actor40_5.png     連續拳、聚能、終結姿勢
#   FileNo 6：$Actor40_6.png     空翻與空中攻擊
#   FileNo 7：$Actor40_7.png     追擊移動與銜接姿勢
#   FileNo 8：$Actor40_8.png     升龍／終結用固定影格
#
# 【技能綁定】
#   150 震拳       → FST_SKILL_150
#   151 破甲連擊   → FST_SKILL_151
#   153 乘隙追打   → FST_SKILL_153
#   154 破陣震波   → FST_SKILL_154
#   155 破勢超載   → FST_SKILL_155
#   157 崩防追獵   → FST_SKILL_157
#   158 斷城終結   → FST_SKILL_158
#   159 地裂終章   → FST_SKILL_159
#
#   152「鬥志打磨」與 156「破城者」為被動技能，不配置主動 SBS 動作。
#
# 【設計原則】
#   1. 泰勒的視覺核心是「先讀取破綻，再以拳腳把崩防窗口擴大」。
#   2. 基礎技短促直接；高階技才加入聚能、空中動作、暗幕與震屏。
#   3. 每次切換拳腳姿勢都必須重新貼近目標，並播放一次攻擊動畫；
#      只有最後一擊結算正式技能效果，避免動畫重複套用傷害與 Break。
#   4. 每個 Afterimage ON 都有對應的 Afterimage OFF。
#   5. Can Collapse 一律放在技能效果結算之後。
#   6. 使用暗幕的技能必定執行 NORMAL_SCREEN_COLOR。
#   7. 每條移動型序列最後執行 FST_RESET，避免座標殘留。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS_Taylor_SBS_ActionSequence_Addon"] = "1.3"

unless defined?(N01::ANIME) && defined?(N01::ACTION)
  raise "FS_Taylor_SBS_ActionSequence_Addon 必須放在 Tankentai SBS 下方。"
end

module N01

  #============================================================================
  # ● 泰勒人物姿勢、動畫與位移
  #----------------------------------------------------------------------------
  # 姿勢格式：
  # [FileNo, Row, Speed, Loop, LoopWait, FixedFrame, Z, Shadow, WeaponKey]
  #
  # 位移格式：
  # [Origin, X, Y, Time, Accel, Jump, PoseKey]
  #
  # 泰勒目前不使用獨立 Weapon Sprite，因此所有姿勢的 WeaponKey 均為 ""。
  #============================================================================
  FST_BATTLER_ANIME = {
    #------------------------------- 基本姿勢 -------------------------------
    # $Actor40_1 Row 0：沿用全腳本原泰勒待機格位，但不顯示舊待機武器。
    "FST_IDLE" =>
      [1, 0, 15, 0, 0, -1, 0, true, ""],

    # $Actor40_7 Row 1：短距離追擊與接敵銜接。
    "FST_DASH" =>
      [7, 1, 4, 1, 0, -1, 0, true, ""],

    # $Actor40_3 Row 1：雙拳架勢。
    "FST_READY" =>
      [3, 1, 5, 2, 0, -1, 1, true, ""],

    #------------------------------- 聚能姿勢 -------------------------------
    # $Actor40_5 Row 0：沿用全腳本原「泰勒集氣」格位。
    "FST_CHARGE" =>
      [5, 0, 2, 0, 0, -1, 2, true, ""],

    # $Actor40_3 Row 3：橙色火焰集中於拳前。
    "FST_OVERLOAD" =>
      [3, 3, 4, 0, 4, -1, 2, true, ""],

    #------------------------------- 近戰姿勢 -------------------------------
    # 以下四組格位沿用全腳本原「泰勒連續攻擊姿勢1～4」。
    "FST_STRIKE_A" =>
      [4, 0, 4, 2, 0, -1, 2, true, ""],

    "FST_STRIKE_B" =>
      [5, 2, 4, 2, 0, -1, 2, true, ""],

    "FST_STRIKE_C" =>
      [5, 3, 4, 2, 0, -1, 2, true, ""],

    "FST_STRIKE_D" =>
      [4, 1, 4, 2, 0, -1, 2, true, ""],

    # $Actor40_4 Row 2：低重心重拳／地面壓擊。
    "FST_GROUND_PUNCH" =>
      [4, 2, 3, 2, 0, -1, 2, true, ""],

    #------------------------------- 空中姿勢 -------------------------------
    # 以下格位沿用全腳本原跳躍、空中氣功與停止姿勢。
    "FST_JUMP" =>
      [6, 1, 3, 2, 0, -1, 2, true, ""],

    "FST_AIR_STRIKE" =>
      [4, 0, 3, 2, 0, -1, 3, true, ""],

    "FST_AIR_HOLD" =>
      [7, 3, 1, 2, 0, -1, 3, true, ""],

    #------------------------------- 升龍終結 -------------------------------
    # $Actor40_8 Row 0：沿用全腳本原升龍與尾招格位。
    "FST_UPPERCUT" =>
      [8, 0, 5, 2, 0, -1, 3, true, ""],

    "FST_UPPERCUT_1" =>
      [8, 0, 5, 2, 0, 0, 3, true, ""],

    "FST_UPPERCUT_2" =>
      [8, 0, 5, 2, 0, 2, 3, true, ""],

    "FST_UPPERCUT_3" =>
      [8, 0, 5, 2, 0, 1, 3, true, ""],

    #------------------------------- DB 動畫 --------------------------------
    # ID 165／168／161／167 皆沿用全腳本原泰勒動畫資料。
    "FST_CHARGE_ANIM" =>
      ["anime", 165, 0, false, false, false],

    "FST_AIR_CHARGE_ANIM" =>
      ["anime", 168, 0, false, false, false],

    "FST_UPPERCUT_ANIM" =>
      ["anime", 161, 1, false, false, false],

    "FST_FINISH_ANIM" =>
      ["anime", 167, 1, false, false, false],

    #-------------------------------- 位移 -----------------------------------
    # 施放原地型技能前小幅踏步，不接近目標。
    "FST_CAST_STEP" =>
      [3, -14, 0, 6, -1, 0, "FST_DASH"],

    # v1.3 第一段：大跳到敵人前方的遠端準備區。
    # Origin 5 以主要目標為基準；112px 先保留足夠的落地距離。
    "FST_APPROACH_BIG_JUMP" =>
      [5, 112, -12, 14, -1, -16, "FST_JUMP"],

    # v1.3 第二段：小跳修正落點，停在敵前約 84px。
    # 這個距離約對應畫面中的 5～6 個短步，接著才原地集氣。
    "FST_APPROACH_SMALL_HOP" =>
      [5, 84, -6, 7, -1, -5, "FST_JUMP"],

    # 標準接敵距離。保留供舊流程或個別後續動作使用。
    "FST_TO_TARGET" =>
      [5, 54, -8, 8, -1, -3, "FST_DASH"],

    # 追擊技使用的高速接敵。
    "FST_TO_TARGET_FAST" =>
      [5, 42, -6, 6, -1, -3, "FST_DASH"],

    # 第一拳壓進目標位置。
    "FST_STRIKE_IN" =>
      [5, 12, -4, 4, -1, -2, "FST_STRIKE_A"],
      
    "FSM_HIT_LIGHT" =>
      ["m_a", 36, 4, 0, 25, 0, 0, 0, 0, true, ""],

    #------------------------- v1.1 連段接近／收身 --------------------------
    # 每一種拳腳都有自己的目標偏移。兩擊之間先以 FST_COMBO_RECOIL
    # 短暫收身，再重新以目標座標接近，確保畫面真的有第二次撞擊。
    "FST_HIT_A_IN" =>
      [5, 18, -4, 3, -1, -2, "FST_STRIKE_A"],

    "FST_HIT_B_IN" =>
      [5, 10, -7, 3, -1, -2, "FST_STRIKE_B"],

    "FST_HIT_C_IN" =>
      [5, 16, -2, 3, -1, -1, "FST_STRIKE_C"],

    "FST_HIT_D_IN" =>
      [5, 8, -5, 3, -1, -2, "FST_STRIKE_D"],

    # 每段命中後向後收身 14px，下一段才重新貼近。
    "FST_COMBO_RECOIL" =>
      [0, 14, 0, 3, -1, 0, "FST_READY"],

    # 穿越至目標另一側的攻擊。
    "FST_PASS_HIT" =>
      [5, -14, -6, 5, -1, -2, "FST_STRIKE_D"],

    # 位於目標另一側時的收身與再接近。
    "FST_REAR_RECOIL" =>
      [0, -14, 0, 3, -1, 0, "FST_READY"],

    "FST_REAR_HIT_B_IN" =>
      [5, -8, -5, 3, -1, -2, "FST_STRIKE_B"],

    # 空中拳腳也先以目標為基準接近，不再只在原座標換姿勢。
    "FST_AIR_HIT_IN" =>
      [5, 10, -24, 4, -1, -3, "FST_AIR_STRIKE"],

    "FST_AIR_RECOIL" =>
      [0, 14, -6, 3, -1, 0, "FST_AIR_HOLD"],

    "FST_AIR_FINISH_IN" =>
      [5, 6, -4, 4, -1, -4, "FST_AIR_STRIKE"],

    # 升龍前先貼近目標下盤，再進入上衝。
    "FST_UPPERCUT_CONTACT" =>
      [5, 10, -4, 3, -1, -2, "FST_UPPERCUT_1"],

    # 地面拳以目標位置為基準壓進。
    "FST_GROUND_HIT_IN" =>
      [5, 12, -2, 4, -1, -2, "FST_GROUND_PUNCH"],

    # 穿越目標，形成乘隙追擊的繞背感。
    "FST_PASS_TARGET" =>
      [5, -14, -6, 6, -1, -2, "FST_STRIKE_D"],

    # 升龍上衝。跳躍值沿用舊「泰勒升龍1」的負向高度概念。
    "FST_UPPERCUT_RISE" =>
      [0, 36, 0, 12, -1, -5, "FST_UPPERCUT"],

    # 原地跳空與落回，沿用舊泰勒空中動作的 Y／Jump 節奏。
    "FST_JUMP_UP" =>
      [0, 5, -30, 4, -1, -1, "FST_JUMP"],

    "FST_AIR_DRIVE" =>
      [0, 5, 3, 6, -1, -1, "FST_AIR_STRIKE"],

    "FST_LAND" =>
      [0, 15, 21, 4, -1, -1, "FST_JUMP"],

    # 後跳拉開，之後由 FST_RESET 回到原始戰鬥座標。
    "FST_BACKSTEP" =>
      [0, 40, 0, 8, -1, -3, "FST_DASH"],

    # Tankentai 原生 reset 移動。所有移動型技能最後必須執行。
    "FST_RESET" =>
      ["reset", 16, 0, 0, "FST_DASH"]
  }

  ANIME.merge!(FST_BATTLER_ANIME)

  #============================================================================
  # ● 泰勒主動技能 Action Sequences
  #----------------------------------------------------------------------------
  # 共通規則：
  #   ・pop text_skill：顯示技能名稱／技能台詞。
  #   ・ANIM／ANIM_WAIT：只播放資料庫技能動畫，不額外結算第二次傷害。
  #   ・DAMAGE／DAMAGE_ANIM_WAIT：技能效果只結算一次。
  #   ・Can Collapse：效果完成後才允許 0 HP 目標倒下。
  #============================================================================
  FST_ACTION_SEQUENCES = {

    #========================================================================
    # Skill 150：震拳
    #
    # 角色定位：泰勒的基礎破勢拳。動作乾淨，直接把震動送進目標防線。
    # 流程：接敵 → 架拳 → 壓進重拳 → 動畫與傷害 → 後跳 → 歸位。
    #========================================================================
    "FST_SKILL_150" => [
      "Afterimage ON",
      "pop text_skill",
      "FST_APPROACH_BIG_JUMP",
      "4",
      "FST_APPROACH_SMALL_HOP",
      "FST_READY",
      "4",
      "FST_CHARGE",
      "FST_CHARGE_ANIM",
      "12",
      "FST_HIT_A_IN",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "8",
      "FST_BACKSTEP",
      "Can Collapse",
      "Afterimage OFF",
      "FST_RESET"

    ],

    #========================================================================
    # Skill 151：破甲連擊
    #
    # 角色定位：以數次不同角度拳腳拆解護甲。前三段是視覺連擊，最後
    # 才一次結算技能效果，避免自行把資料庫技能膨脹成四倍傷害。
    # 流程：接敵 → 直拳 → 側拳 → 低位追拳 → 終結拳 → 結算 → 歸位。
    #========================================================================
    "FST_SKILL_151" => [
      "Afterimage ON",
      "pop text_skill",
      "FST_APPROACH_BIG_JUMP",
      "4",
      "FST_APPROACH_SMALL_HOP",
      "FST_READY",
      "4",
      "FST_CHARGE",
      "FST_CHARGE_ANIM",
      "14",

      # 第一擊：貼近 → 動畫 → 收身
      "FST_HIT_A_IN",
      "ANIM",
      "4",
      "FST_COMBO_RECOIL",

      # 第二擊：再次貼近 → 動畫 → 收身
      "FST_HIT_B_IN",
      "ANIM",
      "4",
      "FST_COMBO_RECOIL",

      # 第三擊：再次貼近 → 動畫 → 收身
      "FST_HIT_C_IN",
      "ANIM",
      "4",
      "FST_COMBO_RECOIL",

      # 最終擊：再次貼近並正式結算一次技能效果
      "FST_HIT_D_IN",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "10",
      "FST_BACKSTEP",
      "Can Collapse",
      "Afterimage OFF",
      "FST_RESET"

    ],

    #========================================================================
    # Skill 153：乘隙追打
    #
    # 角色定位：看見崩防窗口後快速繞過正面，從目標另一側補上重拳。
    # 流程：架勢 → 高速接敵 → 第一拳逼迫防守 → 穿越 → 追打結算。
    #========================================================================
    "FST_SKILL_153" => [
      "Afterimage ON",
      "pop text_skill",
      "FST_APPROACH_BIG_JUMP",
      "4",
      "FST_APPROACH_SMALL_HOP",
      "FST_READY",
      "4",
      "FST_CHARGE",
      "FST_CHARGE_ANIM",
      "14",

      # 正面第一拳
      "FST_HIT_A_IN",
      "ANIM",
      "4",
      "FST_COMBO_RECOIL",

      # 穿越攻擊
      "FST_PASS_HIT",
      "ANIM",
      "4",
      "FST_REAR_RECOIL",

      # 背面追打
      "FST_REAR_HIT_B_IN",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "10",
      "FST_BACKSTEP",
      "Can Collapse",
      "Afterimage OFF",
      "FST_RESET"

    ],

    #========================================================================
    # Skill 154：破陣震波
    #
    # 角色定位：將拳勁打入地面，震波向敵陣擴散。這是範圍破陣技，
    # 泰勒不必跑到某一名敵人身前，否則全體攻擊看起來會像排隊點名。
    # 流程：踏步 → 集氣 → 地面壓拳 → 全體動畫 → 效果結算 → 歸位。
    #========================================================================
    "FST_SKILL_154" => [
      "Afterimage ON",
      "pop text_skill",
      "FST_APPROACH_BIG_JUMP",
      "4",
      "FST_APPROACH_SMALL_HOP",
      "FST_READY",
      "4",
      "FST_CHARGE",
      "FST_CHARGE_ANIM",
      "18",
      "FST_GROUND_HIT_IN",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "16",
      "Can Collapse",
      "Afterimage OFF",
      "FST_RESET"

    ],

    #========================================================================
    # Skill 155：破勢超載
    #
    # 角色定位：把已累積的破勢節奏壓進雙拳，啟動自身強化／機制效果。
    # 流程：踏步 → 架拳 → 集氣 → 火焰超載 → 動畫與效果一次結算。
    #========================================================================
    "FST_SKILL_155" => [
      "pop text_skill",
      "FST_CAST_STEP",
      "FST_READY",
      "6",
      "FST_CHARGE",
      "FST_CHARGE_ANIM",
      "14",
      "FST_OVERLOAD",
      "DAMAGE_ANIM_WAIT",
      "16",
      "FST_RESET"
    ],

    #========================================================================
    # Skill 157：崩防追獵
    #
    # 角色定位：對崩防目標展開高速追獵。以拳腳交錯逼退目標，最後用
    # 空中踢擊收束；所有人物段落仍只服務一次正式技能效果。
    #========================================================================
    "FST_SKILL_157" => [
      "Afterimage ON",
      "pop text_skill",
      "FST_APPROACH_BIG_JUMP",
      "4",
      "FST_APPROACH_SMALL_HOP",
      "FST_READY",
      "4",
      "FST_CHARGE",
      "FST_CHARGE_ANIM",
      "18",

      # 地面第一拳
      "FST_HIT_A_IN",
      "ANIM",
      "3",
      "FST_COMBO_RECOIL",

      # 地面第二拳
      "FST_HIT_B_IN",
      "ANIM",
      "3",
      "FST_COMBO_RECOIL",

      # 空中第一擊
      "FST_JUMP_UP",
      "FST_AIR_HIT_IN",
      "ANIM",
      "4",
      "FST_AIR_RECOIL",

      # 空中終擊
      "FST_AIR_FINISH_IN",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "8",
      "FST_LAND",
      "FST_BACKSTEP",
      "Can Collapse",
      "Afterimage OFF",
      "FST_RESET"

    ],

    #========================================================================
    # Skill 158：斷城終結
    #
    # 角色定位：單體高階終結技。先聚能，再以短連段迫使目標失去架勢，
    # 最後以升龍拳把整個崩防窗口一次打穿。
    # 流程：暗幕 → 集氣 → 接敵連拳 → 升龍三格 → 終結動畫 → 結算。
    #========================================================================
    "FST_SKILL_158" => [
      "Afterimage ON",
      "pop text_skill",
      "FST_APPROACH_BIG_JUMP",
      "4",
      "FST_APPROACH_SMALL_HOP",
      "TINT_SCREEN_BLACK",
      "FST_READY",
      "4",
      "FST_CHARGE",
      "FST_CHARGE_ANIM",
      "22",

      # 第一拳
      "FST_HIT_A_IN",
      "ANIM",
      "4",
      "FST_COMBO_RECOIL",

      # 第二拳
      "FST_HIT_B_IN",
      "ANIM",
      "4",
      "FST_COMBO_RECOIL",

      # 升龍前重新貼近目標
      "FST_UPPERCUT_CONTACT",
      "FST_UPPERCUT_ANIM",
      "4",
      "FST_UPPERCUT_2",
      "3",
      "FST_UPPERCUT_3",
      "3",
      "FST_UPPERCUT_RISE",
      "8",
      "FST_FINISH_ANIM",
      "8",
      "DAMAGE",
      "SHAKE_SCREEN2",
      "20",
      "NORMAL_SCREEN_COLOR",
      "FST_BACKSTEP",
      "Can Collapse",
      "Afterimage OFF",
      "FST_RESET"

    ],

    #========================================================================
    # Skill 159：地裂終章
    #
    # 角色定位：泰勒目前最高位階的敵全體終結技。力量由雙拳集中，
    # 跳起後把衝擊壓入地面，再由資料庫全體動畫將裂地效果傳遍戰場。
    # 流程：暗幕 → 超載集氣 → 起跳 → 空中壓落 → 地拳 → 全體結算。
    #========================================================================
    "FST_SKILL_159" => [
      "Afterimage ON",
      "pop text_skill",
      "FST_APPROACH_BIG_JUMP",
      "4",
      "FST_APPROACH_SMALL_HOP",
      "TINT_SCREEN_BLACK",
      "FST_READY",
      "4",
      "FST_CHARGE",
      "FST_CHARGE_ANIM",
      "26",
      "FST_OVERLOAD",
      "8",
      "FST_JUMP_UP",
      "FST_AIR_CHARGE_ANIM",
      "10",

      # 空中第一擊
      "FST_AIR_HIT_IN",
      "ANIM",
      "6",
      "FST_AIR_RECOIL",

      # 空中壓落
      "FST_AIR_FINISH_IN",
      "ANIM",
      "6",
      "FST_LAND",

      # 落地地裂拳
      "FST_GROUND_HIT_IN",
      "DAMAGE_ANIM_WAIT",
      "SHAKE_SCREEN2",
      "24",
      "NORMAL_SCREEN_COLOR",
      "Can Collapse",
      "Afterimage OFF",
      "FST_RESET"

    ]
  }

  ACTION.merge!(FST_ACTION_SEQUENCES)

  #--------------------------------------------------------------------------
  # ● Skill ID → 泰勒專屬 Action Sequence
  #--------------------------------------------------------------------------
  # 比照喬伊、艾卓與艾薇腳本，技能直接由 ID 取得動作鍵。
  # 152、156 為被動技能，因此刻意不列入。
  #--------------------------------------------------------------------------
  FST_SKILL_ACTIONS = {
    150 => "FST_SKILL_150",
    151 => "FST_SKILL_151",
    153 => "FST_SKILL_153",
    154 => "FST_SKILL_154",
    155 => "FST_SKILL_155",
    157 => "FST_SKILL_157",
    158 => "FST_SKILL_158",
    159 => "FST_SKILL_159"
  }
end

#==============================================================================
# ■ RPG::Skill
#------------------------------------------------------------------------------
#  最終技能動作路由層。
#  只有 FST_SKILL_ACTIONS 列出的技能會由本腳本接管；其他技能沿用前一層
#  base_action，因此可與喬伊、艾卓、艾薇及其他 Action Addon 串接。
#==============================================================================
class RPG::Skill
  unless method_defined?(:fst_taylor_sbs_base_action)
    alias fst_taylor_sbs_base_action base_action
  end

  def base_action
    action_key = N01::FST_SKILL_ACTIONS[@id]
    return action_key unless action_key == nil
    return fst_taylor_sbs_base_action
  end
end
