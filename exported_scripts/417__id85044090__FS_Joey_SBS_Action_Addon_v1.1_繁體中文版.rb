#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_Joey_SBS_Action_Addon v1.1 繁體中文版
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_Joey_SBS_Action_Addon v1.1 繁體中文版」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RPG::Skill、N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：FSJ_WEAPON_ANIME_V13、FSJ_BATTLER_ANIME_V15、FSJ_ACTION_SEQUENCES_V15、FSJ_SKILL_ACTIONS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS_Joey_SBS_Action_Addon；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ** FS_Joey_SBS_Action_Addon v1.5 繁體中文版
#------------------------------------------------------------------------------
#  Forest Symphony／RPG Maker VX／RGSS2
#  喬伊專屬 Tankentai SBS Action Sequence Addon
#------------------------------------------------------------------------------
# 【v1.5 完全停用 $actor01 與命中時序修正】
#
#  1. 本腳本的所有 SBS 人物姿勢完全不再使用 FileNo 0（$actor01.png）。
#     待機、移動、聆聽、轉身、起手、命中與收尾，全部改用
#     $actor01_1～$actor01_5 或舊爪擊專用姿勢。
#
#  2. 近戰技能統一修正為：
#
#       快速到敵人前方定位
#       → 再前衝完成爪擊
#       → 當下播放動畫並結算傷害
#       → 定格在舊「喬伊發動姿勢」
#       → 使用舊「喬伊狼後跳」彈離
#       → FLEE_RESET 回到原位
#
#     正式效果絕不再放在後跳之後。
#
#  3. 重新檢查全部主動技能：
#     ・所有效果都在對應的施放／命中姿勢發生。
#     ・效果完成後只保留結果姿勢與歸位，不再補播遲到的傷害動畫。
#     ・所有非近戰技能也不再使用 $actor01 作中途轉場。
#
# 【v1.4 起手／收尾規則與舊爪擊收尾恢復】
#
#  1. $actor01.png（FileNo 0）在 v1.5 中完全停用，不再出現在任何 SBS 人物姿勢。
#
#  2. 近戰技能使用舊爪擊姿勢與後跳，但修正效果順序：
#
#       敵前定位
#       → 喬伊狼普攻
#       → 爪擊動畫與正式效果
#       → FORCE_KNOCKBACK
#       → 喬伊發動姿勢定格
#       → 喬伊狼後跳
#       → FLEE_RESET
#
#  3. 本腳本直接重用全腳本既有鍵：
#       「喬伊狼普攻」
#       「喬伊狼後跳」
#       「爪擊動畫」
#       「喬伊發動姿勢」
#
#     其中舊「喬伊狼後跳」為：
#       [5, 96, -10, 5, -1, -1, "喬伊發動姿勢"]
#
#     舊「喬伊發動姿勢」為：
#       [7, 0, 3, 2, 0, -1, 2, true, ""]
#
#     這段不是一般後退，而是從目標前方順勢彈離並以專用姿勢收尾。
#
# 【v1.3 角色動作特色重製】
#
#  喬伊的專屬動作語言，正式調整為：
#
#    聆聽殘響 → 標記節拍 → 自己打出第一聲 → 把舞台交給下一名演奏者
#
#  這使他與其他五人的定位徹底分開：
#    ・不像泰勒那樣靠連續拳腳衝擊。
#    ・不像艾薇那樣靠單次重斧重量。
#    ・不像艾卓那樣靠打斷與刺槍節奏。
#    ・不像米亞那樣以祈禱與弦光展開。
#    ・不像維娜那樣以觀察與實驗流程推進。
#
#  喬伊的戰鬥表演，核心是「先感知，再導引，再發出第一拍，最後交棒」。
#
# 【本版圖格編排】
#  依照使用者新提供的六張角色動作圖，統一整理為：
#
#    $actor01.png
#      Row 0：基礎待機／前向穩定姿勢
#      Row 1：背向／轉身過門
#      Row 2：低頭傾聽、感知殘響
#      Row 3：移動與低重心前進
#
#    $actor01_1.png
#      Row 0：披風展開、鳴刻啟動
#      Row 1：側身召令／轉體過門
#      Row 2：高位踏步與切入準備
#      Row 3：聚勢收束
#
#    $actor01_2.png
#      Row 0：橙色共鳴聚集
#      Row 1：藍色殘響聆聽
#      Row 2：藍橙混合節拍聚能
#      Row 3：穩定收束／準備進入指揮
#
#    $actor01_3.png
#      Row 0：橙色聚能前推
#      Row 1：藍色指向／標記
#      Row 2：混合共鳴轉奏
#      Row 3：導向下一位演奏者的手勢
#
#    $actor01_4.png
#      Row 0：低位切入／短衝
#      Row 1：第一斬／反手斬的交錯素材
#      Row 2：穿越與連擊位移姿勢
#      Row 3：倒地／Collapse
#
#    $actor01_5.png
#      Row 0：穩定待命／指揮前的站姿
#      Row 1：橙色節拍宣告
#      Row 2：藍色節拍宣告
#      Row 3：三拍連鎖與終奏指揮
#
# 【功能範圍】
#  只處理喬伊 Skill 82／100／101／103／104／105／107／108／109
#  的人物姿勢、武器 Sprite、Cast 光效、位移節奏與技能效果結算時點。
#
#  不改寫：
#    ・傷害公式
#    ・召喚追擊
#    ・三聲連鎖邏輯
#    ・魂刻擷取成功判定
#    ・OD、ATB、冷卻、狀態與隊友接棒規則
#
# 【安裝位置】
#  放在以下腳本下方，Main 上方：
#    1. Tankentai SBS／SBS Battler Configuration
#    2. 其他 Action Sequence Addon
#    3. Skill Action／Skill Activation／Notetag 類腳本
#    4. Make skill action
#
#  並以本腳本完整取代 FS_Joey_SBS_Action_Addon v1.2。
#
# 【必要圖檔｜Graphics/Characters】
#    $actor01.png
#    $actor01_1.png
#    $actor01_2.png
#    $actor01_3.png
#    $actor01_4.png
#    $actor01_5.png
#
#  角色資料庫中的 character_name 維持「$actor01」。
#
# 【技能對應】
#    82  魂刻汲取
#   100  森芽斬
#   101  共鳴標記
#   103  藤脈牽引
#   104  鳴刻指令
#   105  龍森交錯
#   107  共鳴轉奏
#   108  三聲連鎖
#   109  森之交響
#
#  技能 102「共鳴感知」與 106「和聲領袖」為被動技能，不配置 SBS 動作。
#
# 【效果安全規則】
#    ・每個主動技能只執行一次 DAMAGE 或 DAMAGE_ANIM_WAIT。
#    ・ANIM／ANIM_WAIT 只播放資料庫動畫，不重複套用效果。
#    ・擷取技能 82 不呼叫 DAMAGE，由既有擷取系統自行處理。
#    ・每個 Afterimage ON 都有對應的 Afterimage OFF。
#    ・每條序列最後都執行 FSJ_RESET。
#    ・需要倒地判定時，在正式效果後執行 Can Collapse。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS_Joey_SBS_Action_Addon"] = "1.5"

unless defined?(N01::ANIME) && defined?(N01::ACTION)
  raise "FS_Joey_SBS_Action_Addon 必須放在 Tankentai SBS 下方。"
end

unless N01::ANIME.has_key?("喬伊狼普攻") &&
       N01::ANIME.has_key?("喬伊狼後跳") &&
       N01::ANIME.has_key?("爪擊動畫") &&
       N01::ANIME.has_key?("喬伊發動姿勢")
  raise "FS_Joey_SBS v1.5 必須放在舊喬伊／血狼 Action 定義下方。"
end

module N01
  #----------------------------------------------------------------------------
  # ● 喬伊武器、姿勢與位移
  #----------------------------------------------------------------------------
  FSJ_WEAPON_ANIME_V13 = {
    # 待機持武器。沿用喬伊既有裝備武器 Sprite 方法，維持系統一致性。
    "FSJ_WPN_READY" =>
      [3, 3, false, 65, 65, 0, false, 1, 1, -18, 2, false],

    # 第一斬：較乾淨的低位切入。
    "FSJ_WPN_SLASH_A" =>
      [-7, 2, true, -205, 205, 4, false, 1, 1, -1, 0, false],

    # 反向穿越斬：用於龍森交錯與藤脈牽引。
    "FSJ_WPN_SLASH_B" =>
      [7, -2, false, 205, 10, 4, true, 1, 1, -1, 0, false],

    # 鳴刻前的抬武器預備式。
    "FSJ_WPN_RAISE" =>
      [6, -4, false, 90, -45, 4, false, 1, 1, -4, -6, false]
  }

  FSJ_BATTLER_ANIME_V15 = {
    #------------------------------ 待機與移動 -------------------------------
    # v1.5 所有姿勢均使用 FileNo 1～5；FileNo 0 完全停用。

    # $actor01_5 Row 0：正式待命／收束站姿。
    "FSJ_IDLE" =>
      [5, 0, 15, 0, 0, 1, 0, true, "FSJ_WPN_READY"],

    # $actor01_1 Row 2：側向踏步與位移過程。
    "FSJ_MOVE" =>
      [1, 2, 12, 0, 0, -1, 0, true, ""],

    # $actor01_1 Row 1：披風轉向，只作非 FileNo 0 的過門。
    "FSJ_TURN" =>
      [1, 1, 15, 0, 0, 1, 0, true, ""],

    #------------------------------ 聆聽與聚能 -------------------------------
    # $actor01_2 Row 1：藍色殘響聆聽三階段。
    "FSJ_LISTEN_START" =>
      [2, 1, 15, 0, 0, 0, 2, true, ""],

    "FSJ_LISTEN_HOLD" =>
      [2, 1, 15, 0, 0, 1, 2, true, ""],

    "FSJ_LISTEN_RELEASE" =>
      [2, 1, 15, 0, 0, 2, 2, true, ""],

    "FSJ_RESONANCE_BLUE" =>
      [2, 1, 15, 0, 0, 1, 2, true, ""],

    "FSJ_RESONANCE_ORANGE" =>
      [2, 0, 15, 0, 0, 1, 2, true, ""],

    "FSJ_RESONANCE_MIX" =>
      [2, 2, 15, 0, 0, 1, 2, true, ""],

    "FSJ_GATHER_HOLD" =>
      [1, 3, 15, 0, 0, 1, 2, true, ""],

    #------------------------------ 指揮與召令 -------------------------------
    "FSJ_SUMMON_CLOAK" =>
      [1, 0, 15, 0, 0, 1, 2, true, ""],

    "FSJ_SUMMON_TURN" =>
      [1, 1, 15, 0, 0, 1, 2, true, ""],

    "FSJ_MARK_POINT" =>
      [3, 1, 15, 0, 0, 1, 2, true, ""],

    "FSJ_RELAY_POINT" =>
      [3, 3, 15, 0, 0, 1, 2, true, ""],

    "FSJ_CONDUCT_FINISH" =>
      [5, 3, 15, 0, 0, 1, 2, true, ""],

    "FSJ_BEAT_ORANGE" =>
      [5, 1, 15, 0, 0, 1, 2, true, ""],

    "FSJ_BEAT_BLUE" =>
      [5, 2, 15, 0, 0, 1, 2, true, ""],

    #------------------------------ 近戰斬擊 -------------------------------
    "FSJ_CUT_IN" =>
      [4, 0, 15, 0, 0, 1, 2, true, "FSJ_WPN_READY"],

    "FSJ_SLASH_A" =>
      [4, 1, 4, 2, 0, -1, 2, true, "FSJ_WPN_SLASH_A"],

    "FSJ_SLASH_B" =>
      [4, 2, 4, 2, 0, -1, 2, true, "FSJ_WPN_SLASH_B"],

    "FSJ_COLLAPSE" =>
      [4, 3, 12, 0, 0, 1, 0, false, ""],

    #------------------------------ 使用者光效 -------------------------------
    # 暫用 Animation 34。
    # 【未來需求】藍色殘響波紋由魂刻收束至胸口。
    "FSJ_HEAR_LIGHT" =>
      ["m_a", 34, 4, 0, 52, 0, 0, 0, 2, true, ""],

    # 暫用 Animation 34。
    # 【未來需求】橙色短促節拍在手邊點亮。
    "FSJ_BEAT_LIGHT" =>
      ["m_a", 34, 4, 0, 25, 0, 0, 0, 0, true, ""],

    # 暫用 Animation 34。
    # 【未來需求】藍橙流線由喬伊手勢導向下一名演奏者。
    "FSJ_RELAY_LIGHT" =>
      ["m_a", 34, 4, 0, 52, 0, 0, 0, 2, true, ""],

    #------------------------------ 位移 -------------------------------
    # 指令與共鳴技能的小幅前踏。
    "FSJ_CAST_STEP" =>
      [3, -12, 0, 6, -1, 0, "FSJ_MOVE"],

    # 近戰第一階段：迅速停在敵人前方 62px。
    # 此時只完成定位，尚未爪擊。
    "FSJ_MELEE_POSITION" =>
      [5, 62, -10, 5, -1, -2, "FSJ_CUT_IN"],

    # 保留給少量自訂穿越斬。
    "FSJ_CROSS_PASS" =>
      [5, -10, -10, 6, -1, -2, "FSJ_SLASH_B"],

    # 非近戰與一般指令技能使用的歸位。
    "FSJ_RESET" =>
      ["reset", 16, 0, 0, "FSJ_MOVE"]
  }

  ANIME.merge!(FSJ_WEAPON_ANIME_V13)
  ANIME.merge!(FSJ_BATTLER_ANIME_V15)

  #----------------------------------------------------------------------------
  # ● 喬伊技能 Action Sequence
  #----------------------------------------------------------------------------
  FSJ_ACTION_SEQUENCES_V15 = {
    # 技能 82：魂刻汲取
    # 聆聽 → 鎖定 → 回收。只播放汲取演出，不由本腳本強制結算成功失敗。
    "FSJ_SKILL_082" => [
      "pop text_skill",
      "FSJ_RESONANCE_BLUE",
      "FSJ_HEAR_LIGHT",
      "8",
      "FSJ_LISTEN_HOLD",
      "6",
      "FSJ_RESONANCE_MIX",
      "8",
      "FSJ_RELAY_POINT",
      "FSJ_RELAY_LIGHT",
      "ANIM_WAIT",
      "12",
      "FSJ_GATHER_HOLD",
      "6",
      "FSJ_RESET"

    ],

    # 技能 100：森芽斬
    # 聆聽短起手 → 快速切入 → 一記乾淨斬擊 → 後撤。
    "FSJ_SKILL_100" => [
      "Afterimage ON",
      "pop text_skill",

      # 先迅速到敵人前方定位。
      "FSJ_MELEE_POSITION",
      "3",

      # 再前衝爪擊，並在接觸當下播放動畫與正式傷害。
      "喬伊狼普攻",
      "爪擊動畫",
      "DAMAGE_ANIM_WAIT",

      # 命中後先定格在舊漂亮收尾姿勢，再彈離敵人。
      "FORCE_KNOCKBACK",
      "喬伊發動姿勢",
      "6",
      "喬伊狼後跳",
      "8",

      "Afterimage OFF",
      "Can Collapse",
      "FLEE_RESET"

    ],

    # 技能 101：共鳴標記
    # 聆聽 → 整理節拍 → 指向鎖定。
    "FSJ_SKILL_101" => [
      "pop text_skill",
      "FSJ_RESONANCE_BLUE",
      "FSJ_HEAR_LIGHT",
      "8",
      "FSJ_LISTEN_RELEASE",
      "4",
      "FSJ_BEAT_ORANGE",
      "FSJ_BEAT_LIGHT",
      "6",
      "FSJ_MARK_POINT",
      "DAMAGE_ANIM_WAIT",
      "8",
      "FSJ_MARK_POINT",
      "5",
      "Can Collapse",
      "FSJ_RESET"

    ],

    # 技能 103：藤脈牽引
    # 聆聽藤脈 → 先出現藤脈動畫 → 切入並穿越 → 再結算一次正式效果。
    "FSJ_SKILL_103" => [
      "Afterimage ON",
      "pop text_skill",

      # 先喚起藤脈資料庫動畫。
      "FSJ_RESONANCE_BLUE",
      "FSJ_HEAR_LIGHT",
      "8",
      "ANIM",
      "8",

      # 定位後再前衝爪擊，傷害在爪擊命中當下結算。
      "FSJ_MELEE_POSITION",
      "3",
      "喬伊狼普攻",
      "爪擊動畫",
      "DAMAGE",

      "FORCE_KNOCKBACK",
      "喬伊發動姿勢",
      "6",
      "喬伊狼後跳",
      "8",

      "Afterimage OFF",
      "Can Collapse",
      "FLEE_RESET"

    ],

    # 技能 104：鳴刻指令
    # 披風展開鳴刻 → 指向命令 → 喬伊交棒給召喚側系統。
    "FSJ_SKILL_104" => [
      "pop text_skill",
      "FSJ_SUMMON_CLOAK",
      "FSJ_BEAT_LIGHT",
      "8",
      "FSJ_SUMMON_TURN",
      "4",
      "FSJ_MARK_POINT",
      "ANIM_WAIT",
      #"DAMAGE_ANIM_WAIT",
      "8",
      "FSJ_RELAY_POINT",
      "6",
      "Can Collapse",
      "FSJ_RESET"

    ],

    # 技能 105：龍森交錯
    # 聆聽 → 混合聚能 → 第一斬 → 反向穿越斬 → 正式效果一次結算。
    "FSJ_SKILL_105" => [
      "Afterimage ON",
      "pop text_skill",
      "FSJ_RESONANCE_MIX",
      "FSJ_HEAR_LIGHT",
      "10",

      # 快速定位，第一段前衝爪擊。
      "FSJ_MELEE_POSITION",
      "3",
      "喬伊狼普攻",
      "爪擊動畫",
      "4",

      # 第二段反向穿越斬是正式命中點。
      "FSJ_CROSS_PASS",
      "DAMAGE_ANIM_WAIT",
      "FORCE_KNOCKBACK",

      # 使用原本漂亮的爪擊收尾姿勢定格，再後跳回位。
      "喬伊發動姿勢",
      "7",
      "喬伊狼後跳",
      "8",

      "Afterimage OFF",
      "Can Collapse",
      "FLEE_RESET"

    ],

    # 技能 107：共鳴轉奏
    # 聆聽 → 混合節拍 → 導向下一位演奏者。
    "FSJ_SKILL_107" => [
      "pop text_skill",
      "FSJ_RESONANCE_BLUE",
      "FSJ_HEAR_LIGHT",
      "8",
      "FSJ_RESONANCE_MIX",
      "FSJ_BEAT_LIGHT",
      "8",
      "FSJ_RELAY_POINT",
      "FSJ_RELAY_LIGHT",
      "DAMAGE_ANIM_WAIT",
      "8",
      "FSJ_RELAY_POINT",
      "6",
      "Can Collapse",
      "FSJ_RESET"

    ],

    # 技能 108：三聲連鎖
    # 第一拍橙節拍 → 第二拍藍節拍 → 第三拍混合聚能 → 正式發令。
    "FSJ_SKILL_108" => [
      "pop text_skill",
      "FSJ_BEAT_ORANGE",
      "FSJ_BEAT_LIGHT",
      "6",
      "FSJ_BEAT_BLUE",
      "FSJ_HEAR_LIGHT",
      "6",
      "FSJ_RESONANCE_MIX",
      "FSJ_RELAY_LIGHT",
      "8",
      "FSJ_CONDUCT_FINISH",
      "DAMAGE_ANIM_WAIT",
      "10",
      "FSJ_CONDUCT_FINISH",
      "6",
      "Can Collapse",
      "FSJ_RESET"

    ],

    # 技能 109：森之交響
    # 聆聽森林 → 橙色聚集 → 導演奏方向 → 終奏指揮 → 全體效果落下。
    "FSJ_SKILL_109" => [
      "Afterimage ON",
      "pop text_skill",
      "FSJ_SUMMON_CLOAK",
      "FSJ_HEAR_LIGHT",
      "8",
      "FSJ_RESONANCE_BLUE",
      "8",
      "FSJ_RESONANCE_ORANGE",
      "FSJ_BEAT_LIGHT",
      "8",
      "FSJ_RELAY_POINT",
      "6",
      "FSJ_CONDUCT_FINISH",

      # 全體資料庫動畫先完整播放，效果在終奏姿勢中結算。
      "ANIM_WAIT",
      "DAMAGE",
      "10",
      "FSJ_CONDUCT_FINISH",
      "8",

      "Afterimage OFF",
      "Can Collapse",
      "FSJ_RESET"

    ]
  }

  ACTION.merge!(FSJ_ACTION_SEQUENCES_V15)

  FSJ_SKILL_ACTIONS = {
     82 => "FSJ_SKILL_082",
    100 => "FSJ_SKILL_100",
    101 => "FSJ_SKILL_101",
    103 => "FSJ_SKILL_103",
    104 => "FSJ_SKILL_104",
    105 => "FSJ_SKILL_105",
    107 => "FSJ_SKILL_107",
    108 => "FSJ_SKILL_108",
    109 => "FSJ_SKILL_109"
  }
end

#==============================================================================
# ** RPG::Skill
#==============================================================================
class RPG::Skill
  unless method_defined?(:fsj_joey_sbs_base_action)
    alias fsj_joey_sbs_base_action base_action
  end

  def base_action
    action_key = N01::FSJ_SKILL_ACTIONS[@id]
    return action_key unless action_key == nil
    return fsj_joey_sbs_base_action
  end
end
