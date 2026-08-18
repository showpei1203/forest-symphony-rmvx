#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_Ivy_SBS_ActionSequence_Addon v1.3
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_Ivy_SBS_ActionSequence_Addon v1.3」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RPG::Skill、N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：FSI_WEAPON_ANIME_V13、FSI_BATTLER_ANIME_V13、FSI_ACTION_SEQUENCES_V13、FSI_SKILL_ACTIONS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS_Ivy_SBS_ActionSequence_Addon；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_Ivy_SBS_ActionSequence_Addon v1.3
#------------------------------------------------------------------------------
# Forest Symphony / RPG Maker VX / RGSS2
# Tankentai Sideview Battle System - Action Sequence Addon
#------------------------------------------------------------------------------
# 【v1.3 重斧局部影格時序】
#   ・不修改 Graphics.frame_rate，也不降低整場戰鬥 FPS。
#   ・改用 SBS 的移動時間與 Wait 影格建立局部 Hit Stop：
#       蓄力稍慢 → 落斧加速 → 命中固定影格停格 → 慢速回收。
#   ・不同技能使用 3／5／6／7／8 Frames 的命中停格，
#     讓怒斧、復仇斷斧、城牆斷斧與怒海歸斧有不同重量層級。
#
# 【v1.2 Cast／施放動畫整合】
#   ・恢復舊腳本「艾薇技能發動」動畫 122，改為 FSI_CAST_EFFECT。
#   ・Cast 特效只在無武器姿勢播放，延續 v1.1 不讓斧頭浮空的修正。
#   ・真正施放仍由 DAMAGE_ANIM_WAIT 播放資料庫技能動畫並結算一次效果。
#
# 【v1.1 修正重點】
#
#   1. 修正 Cast 姿勢期間 Weapon Sprite 浮在半空中的問題。
#      $Actor6_3.png 最後一列是閉眼、雙手於胸前交疊的施法動作，
#      此時人物並未持斧，因此該姿勢的 WeaponKey 必須為空字串。
#
#   2. 將人物姿勢明確拆成：
#        ・無武器姿勢：施法、忍痛、情緒、挑釁、受傷。
#        ・持斧姿勢：待機、防禦、舉斧、揮斧、落斧、終結。
#
#   3. 怒斧的蓄怒 Cast 改為固定使用單一影格。
#      不再循環播放整列三格，避免人物連續做 Cast 動作而斧頭停在原處。
#
#   4. 攻擊姿勢改回全腳本原有艾薇配置所使用的格位：
#        ・$Actor6_2.png Row 2：舉斧與出招固定影格。
#        ・$Actor6_4.png Row 2：強攻與尾招固定影格。
#
#   5. 移動、後撤期間暫時隱藏武器，接入持斧姿勢時才重新顯示。
#      這與原全腳本「艾薇跑步姿勢／受傷姿勢不綁武器」的做法一致。
#
# 【功能範圍】
#   只處理艾薇 Skill 140～149 的人物姿勢、Weapon Sprite、移動、
#   動畫等待與效果結算時點。
#
#   不改寫：
#     ・技能傷害公式
#     ・怒氣／OD
#     ・蓄痛
#     ・護衛
#     ・挑釁
#     ・Cover 減傷
#     ・狀態與 ATB
#
# 【安裝位置】
#   放在以下腳本下方，Main 正上方：
#     1. Tankentai SBS／SBS Battler Configuration
#     2. 所有原始 Action Sequence Addon
#     3. Skill Action／Skill Activation／Notetag
#     4. Make skill action
#     5. 喬伊、艾卓等角色的專屬 SBS Addon
#
#   請以本 v1.1 完整取代 v1.0，不要兩版同時保留。
#
# 【必要圖檔｜Graphics/Characters】
#     $Actor6.png
#     $Actor6_1.png
#     $Actor6_2.png
#     $Actor6_3.png
#     $Actor6_4.png
#
#   角色資料庫 character_name 維持「$Actor6」。
#
# 【技能綁定】
#   140 斧背震撞
#   141 荊棘護陣
#   143 怒斧
#   144 根網挑釁
#   145 痛苦熔爐
#   147 復仇斷斧
#   148 城牆斷斧
#   149 怒海歸斧
#
#   Skill 142、146 為被動技能，不配置主動 SBS 動作。
#
# 【重要流程規則】
#   ・每個技能只執行一次 DAMAGE 或 DAMAGE_ANIM_WAIT。
#   ・Cast／情緒／受傷姿勢的 WeaponKey 必須為空字串。
#   ・每個 Afterimage ON 都有對應的 Afterimage OFF。
#   ・畫面染黑後必定執行 NORMAL_SCREEN_COLOR。
#   ・效果結算後執行 Can Collapse。
#   ・每條序列最後執行 FLEE_RESET。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS_Ivy_SBS_ActionSequence_Addon"] = "1.3"

unless defined?(N01::ANIME) && defined?(N01::ACTION)
  raise "FS_Ivy_SBS_ActionSequence_Addon 必須放在 Tankentai SBS 下方。"
end

module N01

  #============================================================================
  # ● 艾薇專用 Weapon Sprite
  #----------------------------------------------------------------------------
  # 格式：
  # [X偏移, Y偏移, 反轉, 起始角度, 結束角度, 原點, 鏡像,
  #  X縮放, Y縮放, X軸心偏移, Y軸心偏移, 第二武器]
  #
  # 數值沿用全腳本既有艾薇持斧設定。
  #============================================================================
  FSI_WEAPON_ANIME_V13 = {
    # 待機持斧。
    "FSI_WPN_READY" =>
      [0, -2, false, 245, 245, 0, false, 1, 1, 10, 0, false],

    # 防禦／護陣持斧。
    "FSI_WPN_GUARD" =>
      [0, -2, true, 245, 245, 0, false, 1, 1, 10, 0, false],

    # 舉斧預備。
    "FSI_WPN_RAISE" =>
      [0, -2, true, -55, -55, 0, false, 1, 1, -15, -15, false],

    # 正向重斬。
    "FSI_WPN_SLASH_A" =>
      [0, -2, true, 65, 65, 0, false, 1, 1, -15, 10, false],

    # 斧背震撞。
    "FSI_WPN_BACK_HIT" =>
      [0, -2, true, 65, 65, 0, false, 1, 1, -15, 10, false],

    # 反向橫掃。
    "FSI_WPN_SLASH_B" =>
      [0, -2, false, -65, -65, 0, true, 1, 1, 15, 10, false],

    # 終結落斧。
    "FSI_WPN_FINISH" =>
      [0, -4, true, -80, -80, 0, false, 1, 1, -14, -16, false]
  }

  #============================================================================
  # ● 艾薇人物姿勢
  #----------------------------------------------------------------------------
  # 格式：
  # [FileNo, Row, Speed, Loop, LoopWait, FixedFrame, Z, Shadow, WeaponKey]
  #
  # WeaponKey 規則：
  #   "" 代表此姿勢不顯示 Weapon Sprite。
  #============================================================================
  FSI_BATTLER_ANIME_V13 = {

    #--------------------------------------------------------------------------
    # ■ 無武器姿勢
    #--------------------------------------------------------------------------

    # 移動時不顯示武器，避免斧頭沿固定軸心漂在人物身旁。
    "FSI_MOVE_IN" =>
      [0, 1, 10, 0, 0, -1, 0, true, ""],

    "FSI_MOVE_OUT" =>
      [0, 2, 10, 0, 0, -1, 0, true, ""],

    "FSI_TURN_BACK" =>
      [0, 3, 10, 0, 0, -1, 0, true, ""],

    # $Actor6_1 Row 0：一般起手／手勢。
    "FSI_GESTURE" =>
      [1, 0, 5, 2, 0, -1, 2, true, ""],

    # $Actor6_1 Row 1：受傷／忍痛。
    "FSI_HURT" =>
      [1, 1, 5, 2, 0, -1, 2, true, ""],

    # $Actor6_1 Row 2：憤怒／情緒反應。
    "FSI_RAGE_EMOTE" =>
      [1, 2, 5, 2, 0, -1, 2, true, ""],

    # $Actor6_1 Row 3：集中／平復。
    "FSI_FOCUS" =>
      [1, 3, 8, 2, 0, -1, 2, true, ""],

    # $Actor6_3 Row 1：挑釁／指向。
    "FSI_CHALLENGE" =>
      [3, 1, 5, 2, 0, -1, 2, true, ""],

    # $Actor6_3 Row 3：完整 Cast 動畫，但不顯示武器。
    # 適合痛苦熔爐等較長的自身術式。
    "FSI_CAST_LOOP" =>
      [3, 3, 6, 2, 0, -1, 2, true, ""],

    # $Actor6_3 Row 3 的中間固定影格。
    # 怒斧使用單一蓄怒姿勢，避免整列循環造成「好幾個 Cast 動作」。
    "FSI_CAST_HOLD" =>
      [3, 3, 15, 0, 0, 1, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 持斧姿勢
    #--------------------------------------------------------------------------

    # 原全腳本艾薇待機姿勢使用 FileNo 4 Row 0。
    "FSI_IDLE" =>
      [4, 0, 15, 0, 0, -1, 0, true, "FSI_WPN_READY"],

    # 原全腳本艾薇防禦姿勢使用 FileNo 4 Row 1。
    "FSI_GUARD" =>
      [4, 1, 15, 0, 0, -1, 0, true, "FSI_WPN_GUARD"],

    # FileNo 4 Row 2，固定第 0 格：發動／強攻起手。
    "FSI_AXE_BRACE" =>
      [4, 2, 15, 0, 0, 0, 2, true, "FSI_WPN_GUARD"],

    # FileNo 4 Row 2，固定第 1 格：強攻壓進。
    "FSI_POWER_STRIKE" =>
      [4, 2, 15, 0, 0, 1, 2, true, "FSI_WPN_SLASH_A"],

    # FileNo 4 Row 2，固定第 2 格：尾招／落斧。
    "FSI_FINISH_SLASH" =>
      [4, 2, 15, 0, 0, 2, 2, true, "FSI_WPN_FINISH"],

    # 原全腳本艾薇出招姿勢2：
    # FileNo 2 Row 2，固定第 1 格，配合舉斧 Weapon Sprite。
    "FSI_AXE_RAISE" =>
      [2, 2, 15, 0, 0, 1, 2, true, "FSI_WPN_RAISE"],

    # 原全腳本艾薇出招姿勢1：
    # FileNo 2 Row 2，固定第 2 格，配合正向重斬。
    "FSI_AXE_SLASH" =>
      [2, 2, 15, 0, 0, 2, 2, true, "FSI_WPN_SLASH_A"],

    # 同一人物攻擊格，改配斧背撞擊 Weapon Sprite。
    "FSI_BACK_SMASH" =>
      [2, 2, 15, 0, 0, 2, 2, true, "FSI_WPN_BACK_HIT"],

    # 反向橫掃。
    "FSI_REVERSE_SWEEP" =>
      [2, 2, 15, 0, 0, 1, 2, true, "FSI_WPN_SLASH_B"],

    #------------------------- v1.3 命中停格姿勢 ----------------------------
    # 斧背命中的固定接觸影格。
    "FSI_BACK_IMPACT_HOLD" =>
      [2, 2, 15, 0, 0, 2, 2, true, "FSI_WPN_BACK_HIT"],

    # 一般重斧命中的固定接觸影格。
    "FSI_HEAVY_IMPACT_HOLD" =>
      [2, 2, 15, 0, 0, 2, 2, true, "FSI_WPN_SLASH_A"],

    # 終結落斧的固定接觸影格。
    "FSI_FINISH_IMPACT_HOLD" =>
      [4, 2, 15, 0, 0, 2, 2, true, "FSI_WPN_FINISH"],

    # 命中後的慢速回收／Follow-through。
    "FSI_AXE_RECOVERY" =>
      [4, 2, 15, 0, 0, 1, 2, true, "FSI_WPN_SLASH_A"],

    # 倒地姿勢不顯示武器。
    "FSI_COLLAPSE" =>
      [2, 3, 12, 0, 0, 1, 0, false, ""],

    #--------------------------------------------------------------------------
    # ■ Cast 特效
    #--------------------------------------------------------------------------
    # 沿用舊腳本「艾薇技能發動」動畫 122。
    # 必須搭配無武器姿勢使用，否則斧頭又會懸空表演自主意識。
    "FSI_CAST_EFFECT" =>
      ["m_a", 122, 4, 0, 52, 0, 0, 0, 2, true, ""],

    #--------------------------------------------------------------------------
    # ■ 位移
    #--------------------------------------------------------------------------

    # 先以無武器跑步姿勢接近，下一個持斧姿勢才顯示斧頭。
    "FSI_TO_TARGET" =>
      [5, 44, -10, 8, -1, -3, "FSI_MOVE_IN"],

    # 斧背撞入。
    "FSI_SMASH_IN" =>
      [5, 34, -5, 3, -1, -4, "FSI_BACK_SMASH"],

    # 一般重斧壓進。
    "FSI_HEAVY_IN" =>
      [0, -45, 0, 3, -1, -2, "FSI_AXE_SLASH"],

    # 強攻壓進。
    "FSI_POWER_IN" =>
      [0, -45, 0, 3, -1, -2, "FSI_POWER_STRIKE"],

    # 終結落斧。
    "FSI_FINISH_IN" =>
      [0, -52, -4, 3, -1, -5, "FSI_FINISH_SLASH"],

    # 後跳時先隱藏武器，回到待機姿勢才重新顯示。
    "FSI_BACKSTEP_1" =>
      [0, 35, 0, 8, -1, -3, "FSI_MOVE_OUT"],

    "FSI_BACKSTEP_2" =>
      [0, 15, 0, 8, -1, -2, "FSI_IDLE"]
  }

  ANIME.merge!(FSI_WEAPON_ANIME_V13)
  ANIME.merge!(FSI_BATTLER_ANIME_V13)

  #============================================================================
  # ● 艾薇主動技能 Action Sequences
  #============================================================================
  FSI_ACTION_SEQUENCES_V13 = {

    #--------------------------------------------------------------------------
    # Skill 140：斧背震撞
    # 無武器移動 → 架斧 → 斧背撞入 → 一次效果結算 → 後跳。
    #--------------------------------------------------------------------------
    "FSI_SKILL_140" => [
      "Afterimage ON",
      "pop text_skill",
      "FSI_GESTURE",
      "FSI_CAST_EFFECT",
      "12",
      "FSI_TO_TARGET",
      "FSI_AXE_BRACE",
      "6",
      "FSI_SMASH_IN",
      "ANIM",
      "DAMAGE",
      "SHAKE_SCREEN2",
      "FSI_BACK_IMPACT_HOLD",
      "3",
      "FSI_AXE_RECOVERY",
      "6",
      "FSI_BACKSTEP_1",
      "FSI_BACKSTEP_2",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ],

    #--------------------------------------------------------------------------
    # Skill 141：荊棘護陣
    # 集中時隱藏武器，真正進入護陣姿勢時才顯示斧頭。
    #--------------------------------------------------------------------------
    "FSI_SKILL_141" => [
      "pop text_skill",
      "FSI_FOCUS",
      "FSI_CAST_EFFECT",
      "16",
      "FSI_GUARD",
      "8",
      "DAMAGE_ANIM_WAIT",
      "20",
      "Can Collapse",
      "FLEE_RESET"

    ],

    #--------------------------------------------------------------------------
    # Skill 143：怒斧
    #
    # v1.1：
    #   ・只使用一次固定 Cast 影格。
    #   ・Cast 時 Weapon Sprite 完全隱藏。
    #   ・接敵後才顯示舉斧與重斬。
    #--------------------------------------------------------------------------
    "FSI_SKILL_143" => [
      "Afterimage ON",
      "pop text_skill",
      "FSI_CAST_HOLD",
      "FSI_CAST_EFFECT",
      "18",
      "FSI_TO_TARGET",
      "FSI_AXE_RAISE",
      "8",
      "FSI_HEAVY_IN",
      "ANIM",
      "DAMAGE",
      "SHAKE_SCREEN2",
      "FSI_HEAVY_IMPACT_HOLD",
      "5",
      "FSI_AXE_RECOVERY",
      "8",
      "FSI_BACKSTEP_1",
      "FSI_BACKSTEP_2",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ],

    #--------------------------------------------------------------------------
    # Skill 144：根網挑釁
    # 挑釁與憤怒表情都不持斧，避免武器懸空。
    #--------------------------------------------------------------------------
    "FSI_SKILL_144" => [
      "pop text_skill",
      "FSI_CHALLENGE",
      "FSI_CAST_EFFECT",
      "16",
      "FSI_RAGE_EMOTE",
      "8",
      "DAMAGE_ANIM_WAIT",
      "20",
      "Can Collapse",
      "FLEE_RESET"

    ],

    #--------------------------------------------------------------------------
    # Skill 145：痛苦熔爐
    # 忍痛 → 無武器 Cast → 怒意反應 → 自身效果結算。
    #--------------------------------------------------------------------------
    "FSI_SKILL_145" => [
      "pop text_skill",
      "FSI_HURT",
      "10",
      "FSI_CAST_LOOP",
      "FSI_CAST_EFFECT",
      "20",
      "FSI_RAGE_EMOTE",
      "8",
      "DAMAGE_ANIM_WAIT",
      "24",
      "Can Collapse",
      "FLEE_RESET"

    ],

    #--------------------------------------------------------------------------
    # Skill 147：復仇斷斧
    # 蓄痛階段不顯示武器，接敵舉斧時才讓武器重新出現。
    #--------------------------------------------------------------------------
    "FSI_SKILL_147" => [
      "Afterimage ON",
      "pop text_skill",
      "FSI_HURT",
      "8",
      "FSI_CAST_HOLD",
      "FSI_CAST_EFFECT",
      "18",
      "FSI_RAGE_EMOTE",
      "8",
      "FSI_TO_TARGET",
      "FSI_AXE_RAISE",
      "9",
      "FSI_HEAVY_IN",
      "ANIM",
      "DAMAGE",
      "SHAKE_SCREEN2",
      "FSI_HEAVY_IMPACT_HOLD",
      "6",
      "FSI_AXE_RECOVERY",
      "10",
      "FSI_BACKSTEP_1",
      "FSI_BACKSTEP_2",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ],

    #--------------------------------------------------------------------------
    # Skill 148：城牆斷斧
    # 持斧守勢 → 強攻架勢 → 接敵 → 重斧壓進。
    #--------------------------------------------------------------------------
    "FSI_SKILL_148" => [
      "Afterimage ON",
      "pop text_skill",
      "FSI_GESTURE",
      "FSI_CAST_EFFECT",
      "14",
      "FSI_GUARD",
      "12",
      "FSI_AXE_BRACE",
      "6",
      "FSI_TO_TARGET",
      "FSI_AXE_RAISE",
      "10",
      "FSI_POWER_IN",
      "ANIM",
      "DAMAGE",
      "SHAKE_SCREEN2",
      "FSI_HEAVY_IMPACT_HOLD",
      "7",
      "FSI_AXE_RECOVERY",
      "10",
      "FSI_BACKSTEP_1",
      "FSI_BACKSTEP_2",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ],

    #--------------------------------------------------------------------------
    # Skill 149：怒海歸斧
    # 無武器蓄怒 → 暗幕 → 無武器收束 → 接敵後連續持斧攻擊 → 終結。
    #--------------------------------------------------------------------------
    "FSI_SKILL_149" => [
      "Afterimage ON",
      "pop text_skill",
      "FSI_CAST_HOLD",
      "FSI_CAST_EFFECT",
      "20",
      "TINT_SCREEN_BLACK",
      "16",
      "FSI_CAST_LOOP",
      "FSI_CAST_EFFECT",
      "20",
      "FSI_TO_TARGET",
      "FSI_AXE_SLASH",
      "5",
      "FSI_REVERSE_SWEEP",
      "5",
      "FSI_AXE_RAISE",
      "12",
      "FSI_FINISH_IN",
      "ANIM",
      "DAMAGE",
      "SHAKE_SCREEN2",
      "FSI_FINISH_IMPACT_HOLD",
      "8",
      "FSI_AXE_RECOVERY",
      "12",
      "NORMAL_SCREEN_COLOR",
      "FSI_BACKSTEP_1",
      "FSI_BACKSTEP_2",
      "Can Collapse",
      "Afterimage OFF",
      "FLEE_RESET"

    ]
  }

  ACTION.merge!(FSI_ACTION_SEQUENCES_V13)

  #--------------------------------------------------------------------------
  # ● Skill ID → 艾薇專屬 Action Sequence
  #--------------------------------------------------------------------------
  FSI_SKILL_ACTIONS = {
    140 => "FSI_SKILL_140",
    141 => "FSI_SKILL_141",
    143 => "FSI_SKILL_143",
    144 => "FSI_SKILL_144",
    145 => "FSI_SKILL_145",
    147 => "FSI_SKILL_147",
    148 => "FSI_SKILL_148",
    149 => "FSI_SKILL_149"
  }
end

#==============================================================================
# ■ RPG::Skill
#------------------------------------------------------------------------------
#  最終技能動作路由層。
#==============================================================================
class RPG::Skill
  unless method_defined?(:fsi_ivy_sbs_base_action)
    alias fsi_ivy_sbs_base_action base_action
  end

  def base_action
    action_key = N01::FSI_SKILL_ACTIONS[@id]
    return action_key unless action_key == nil
    return fsi_ivy_sbs_base_action
  end
end
