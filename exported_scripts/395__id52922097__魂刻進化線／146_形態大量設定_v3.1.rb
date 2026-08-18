#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：魂刻進化線／146 形態大量設定 v3.1
# 【用途】保留的 Runtime 元件「魂刻進化線／146 形態大量設定 v3.1」。
# 【主要機制】主要定義／擴充 Game_Actor、Game_Interpreter、FS_PKMN66、ALBERT_ACTOR_PROFILE；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Actor、Game_Interpreter、FS_PKMN66、ALBERT_ACTOR_PROFILE、ALBERT_ACTOR_ENEMY_GROWTH、ElementalSettings、ArmorMapping
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：AI_STATE_IDS、POKEMON_ACTOR_IDS、BASE_MAPPING、DEFAULT_AI、CLASS_LEARNINGS、ACTOR_ELEMENT_TABLE、DATA。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS_Pokemon66Evolution146_v3_1。
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
# Forest Symphony - Pokemon 66 魂刻進化線／146 形態大量設定 v3.1
#------------------------------------------------------------------------------
# 適用：RPG Maker VX / RGSS2
#
# 【本檔範圍】
#   66 條魂刻進化線、146 個 Actor／Enemy 形態。
#   每條進化線共用 1 個 Class ID 與 1 個魂刻 Armor ID。
#   Actor 100-245 / Class 100-165 / Enemy 600-745 / Armor 600-665。
#
# 【安裝位置】
#   放在下列腳本全部之下、Main 之上：
#   ArmorMapping／EvolutionTable／ElementalSettings／ActorEnemyGrowth／
#   ActorProfile／AutoBattleAI 與其修正／SummonTemporaryBattle／
#   SummonTemporaryBattle_DatabaseSync Safe。
#
# 【替換舊版】
#   1. 移除舊 66 隻 v1.x／v2.x 大量設定頁。
#   2. 本檔會完整取代 EvolutionTable::DATA，舊進化表不要並存。
#   3. Actor ID 架構已重排，正式測試強烈建議使用新存檔。
#
# 【資料庫必做】
#   1. 依 PDF／ClassLearning CSV，把同一進化線全部 Actor 指向同一 Class。
#   2. 依 ClassLearning CSV 手動輸入 Class Learnings；本檔中的
#      CLASS_LEARNINGS 只是核對表，不會改寫編輯器內的 Classes.rvdata。
#   3. Actor 初始等級一律設 1；六項能力繼續讀對應 Enemy 資料庫。
#   4. Class Learning 設在進化等級時，進化完成後會立刻補學該技能。
#
# 【事件腳本短指令】（事件欄位很窄，故只提供短名稱）
#   pkm_reset   把 66 枚魂刻映射重設為各進化線第一形態。
#               只重設 ArmorMapping，不清除等級、EXP、JP 或技能等級。
#   pkm_sync    補齊目前映射 Actor 在現等級應會的 Class 技能與屬性。
#
# 【固定分支】
#   走路花 → 霸王花；捨棄美麗花。
#   蚊香君 → 蚊香泳士；捨棄蚊香蛙皇。
#   雪童子 → 雪妖女；捨棄冰鬼護。
#   本版沒有分支選擇指令，也沒有建立被捨棄形態。
#
# 【技能學習與進化】
#   技能由資料庫 Class Learnings 管理。進化後會重新掃描目前 Class／Level，
#   補入應學而未學的技能；舊形態已學技能與技能等級會保留。
#   同一條進化線共用 Class ID，因此 JP 使用同一 class_jp[class_id]。
#
# 【屬性與能力】
#   同一 Class 內可能因進化改變屬性，所以本檔提供 Actor ID 優先屬性表。
#   Enemy 依 Enemy ID；HP／MP／ATK／DEF／SPI／AGI 仍由 Enemy 種族值計算。
#
# 【AI 與未來專屬裝備】
#   本檔不會替 Actor 附加預設 AI State，只在現有 AI State 查不到結果時，
#   回傳該形態的預設 AI package。未來專屬裝備若附加 State
#   17／18／22／23／25，既有 AI State 會優先，預設 package 自動退居 fallback。
#   本檔不修改 RANDOM_SWING 或 BALANCED_RANDOM_RATE，原有隨機性完整保留。
#
# 【Note 與欄位寬度】
#   本檔沒有新增 Note Tag。PDF 內每個 Note Tag 都應各占一行。
#   往後新增事件指令與 Tag 必須維持短名稱，所有用法都寫在腳本開頭。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS_Pokemon66Evolution146_v3_1"] = true

module FS_PKMN66
  AI_STATE_IDS = [17, 18, 22, 23, 25]
  POKEMON_ACTOR_IDS = [
    100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111,
    112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123,
    124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135,
    136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147,
    148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159,
    160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171,
    172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183,
    184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195,
    196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207,
    208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219,
    220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231,
    232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243,
    244, 245
  ]
  BASE_MAPPING = {
    600 => 100,
    601 => 103,
    602 => 106,
    603 => 109,
    604 => 112,
    605 => 115,
    606 => 118,
    607 => 120,
    608 => 122,
    609 => 124,
    610 => 126,
    611 => 128,
    612 => 130,
    613 => 132,
    614 => 135,
    615 => 138,
    616 => 140,
    617 => 142,
    618 => 144,
    619 => 146,
    620 => 148,
    621 => 151,
    622 => 154,
    623 => 157,
    624 => 159,
    625 => 162,
    626 => 164,
    627 => 167,
    628 => 169,
    629 => 171,
    630 => 174,
    631 => 176,
    632 => 178,
    633 => 180,
    634 => 182,
    635 => 184,
    636 => 185,
    637 => 186,
    638 => 188,
    639 => 190,
    640 => 193,
    641 => 195,
    642 => 197,
    643 => 198,
    644 => 199,
    645 => 200,
    646 => 203,
    647 => 206,
    648 => 208,
    649 => 210,
    650 => 211,
    651 => 214,
    652 => 216,
    653 => 218,
    654 => 221,
    655 => 222,
    656 => 225,
    657 => 228,
    658 => 230,
    659 => 232,
    660 => 234,
    661 => 236,
    662 => 239,
    663 => 240,
    664 => 242,
    665 => 243,
  }
  DEFAULT_AI = {
    100 => 23, # 妙蛙種子
    101 => 23, # 妙蛙草
    102 => 23, # 妙蛙花
    103 => 25, # 小火龍
    104 => 25, # 火恐龍
    105 => 25, # 噴火龍
    106 => 22, # 水躍魚
    107 => 22, # 沼躍魚
    108 => 22, # 巨沼怪
    109 => 23, # 綠毛蟲
    110 => 23, # 鐵甲蛹
    111 => 23, # 巴大蝶
    112 => 23, # 獨角蟲
    113 => 23, # 鐵殼蛹
    114 => 23, # 大針蜂
    115 => 22, # 波波
    116 => 22, # 比比鳥
    117 => 22, # 比雕
    118 => 17, # 小拉達
    119 => 17, # 拉達
    120 => 17, # 烈雀
    121 => 17, # 大嘴雀
    122 => 23, # 阿柏蛇
    123 => 23, # 阿柏怪
    124 => 23, # 皮卡丘
    125 => 23, # 雷丘
    126 => 17, # 穿山鼠
    127 => 17, # 穿山王
    128 => 23, # 六尾
    129 => 23, # 九尾
    130 => 18, # 胖丁
    131 => 18, # 胖可丁
    132 => 17, # 超音蝠
    133 => 17, # 大嘴蝠
    134 => 17, # 叉字蝠
    135 => 23, # 走路草
    136 => 23, # 走路花
    137 => 23, # 霸王花
    138 => 23, # 派拉斯
    139 => 23, # 派拉斯特
    140 => 23, # 毛球
    141 => 23, # 摩魯蛾
    142 => 23, # 可達鴨
    143 => 23, # 哥達鴨
    144 => 17, # 猴怪
    145 => 17, # 火爆猴
    146 => 22, # 卡蒂狗
    147 => 22, # 風速狗
    148 => 23, # 蚊香蝌蚪
    149 => 23, # 蚊香君
    150 => 23, # 蚊香泳士
    151 => 23, # 凱西
    152 => 23, # 勇基拉
    153 => 23, # 胡地
    154 => 17, # 腕力
    155 => 17, # 豪力
    156 => 17, # 怪力
    157 => 23, # 瑪瑙水母
    158 => 23, # 毒刺水母
    159 => 22, # 小拳石
    160 => 22, # 隆隆石
    161 => 22, # 隆隆岩
    162 => 23, # 小火馬
    163 => 23, # 烈焰馬
    164 => 22, # 小磁怪
    165 => 22, # 三合一磁怪
    166 => 22, # 自爆磁怪
    167 => 17, # 嘟嘟
    168 => 17, # 嘟嘟利
    169 => 22, # 臭泥
    170 => 22, # 臭臭泥
    171 => 23, # 鬼斯
    172 => 23, # 鬼斯通
    173 => 23, # 耿鬼
    174 => 23, # 催眠貘
    175 => 23, # 引夢貘人
    176 => 23, # 霹靂電球
    177 => 23, # 頑皮雷彈
    178 => 17, # 卡拉卡拉
    179 => 17, # 嘎啦嘎啦
    180 => 22, # 菊石獸
    181 => 22, # 多刺菊石獸
    182 => 17, # 化石盔
    183 => 17, # 鐮刀盔
    184 => 23, # 超夢
    185 => 17, # 夢幻
    186 => 17, # 尾立
    187 => 17, # 大尾立
    188 => 23, # 圓絲蛛
    189 => 23, # 阿利多斯
    190 => 18, # 波克比
    191 => 18, # 波克基古
    192 => 18, # 波克基斯
    193 => 23, # 夢妖
    194 => 23, # 夢妖魔
    195 => 18, # 小福蛋
    196 => 18, # 幸福蛋
    197 => 23, # 雷公
    198 => 17, # 炎帝
    199 => 22, # 水君
    200 => 22, # 幼基拉斯
    201 => 22, # 沙基拉斯
    202 => 22, # 班基拉斯
    203 => 18, # 蓮葉童子
    204 => 18, # 蓮帽小童
    205 => 18, # 樂天河童
    206 => 22, # 長翅鷗
    207 => 22, # 大嘴鷗
    208 => 22, # 幕下力士
    209 => 22, # 鐵掌力士
    210 => 22, # 大嘴娃
    211 => 22, # 可可多拉
    212 => 22, # 可多拉
    213 => 22, # 波士可多拉
    214 => 17, # 利牙魚
    215 => 17, # 巨牙鯊
    216 => 18, # 醜醜魚
    217 => 18, # 美納斯
    218 => 22, # 夜巡靈
    219 => 22, # 彷徨夜靈
    220 => 22, # 黑夜魔靈
    221 => 17, # 阿勃梭魯
    222 => 17, # 寶貝龍
    223 => 17, # 甲殼龍
    224 => 17, # 暴飛龍
    225 => 22, # 鐵啞鈴
    226 => 22, # 金屬怪
    227 => 22, # 巨金怪
    228 => 17, # 雪童子
    229 => 17, # 雪妖女
    230 => 23, # 鯉魚王
    231 => 23, # 暴鯉龍
    232 => 18, # 燈籠魚
    233 => 18, # 電燈怪
    234 => 22, # 榛果球
    235 => 22, # 佛烈托斯
    236 => 25, # 圓陸鯊
    237 => 25, # 尖牙陸鯊
    238 => 25, # 烈咬陸鯊
    239 => 17, # 赫拉克羅斯
    240 => 17, # 戴魯比
    241 => 17, # 黑魯加
    242 => 22, # 盔甲鳥
    243 => 18, # 拉魯拉絲
    244 => 18, # 奇魯莉安
    245 => 18, # 沙奈朵
  }
  CLASS_LEARNINGS = {
    100 => [[1, 600], [8, 601], [16, 602], [32, 606]], # PKM01 妙蛙種子系
    101 => [[1, 607], [8, 608], [16, 612], [36, 613]], # PKM02 小火龍系
    102 => [[1, 617], [8, 653], [16, 618], [36, 748]], # PKM03 水躍魚系
    103 => [[1, 768], [7, 769], [10, 670], [12, 604]], # PKM04 綠毛蟲系
    104 => [[1, 770], [7, 769], [10, 767], [12, 676]], # PKM05 獨角蟲系
    105 => [[1, 725], [8, 639], [18, 613], [36, 637]], # PKM06 波波系
    106 => [[1, 639], [8, 619], [14, 641], [20, 642]], # PKM07 小拉達系
    107 => [[1, 634], [8, 639], [14, 636], [20, 643]], # PKM08 烈雀系
    108 => [[1, 644], [8, 619], [22, 646], [30, 645]], # PKM09 阿柏蛇系
    109 => [[1, 697], [8, 639], [20, 649], [30, 651]], # PKM10 皮卡丘系
    110 => [[1, 607], [8, 656], [22, 610], [32, 655]], # PKM11 穿山鼠系
    111 => [[1, 608], [8, 639], [24, 663], [30, 615]], # PKM12 六尾系
    112 => [[1, 740], [8, 666], [24, 659], [30, 667]], # PKM13 胖丁系
    113 => [[1, 633], [8, 690], [22, 613], [40, 631]], # PKM14 超音蝠系
    114 => [[1, 741], [8, 601], [21, 604], [36, 605]], # PKM15 走路草系
    115 => [[1, 633], [8, 602], [24, 669], [30, 605]], # PKM16 派拉斯系
    116 => [[1, 670], [8, 601], [31, 604], [36, 625]], # PKM17 毛球系
    117 => [[1, 617], [8, 670], [27, 671], [33, 621]], # PKM18 可達鴨系
    118 => [[1, 674], [8, 676], [28, 677], [36, 678]], # PKM19 猴怪系
    119 => [[1, 619], [8, 608], [24, 662], [32, 679]], # PKM20 卡蒂狗系
    120 => [[1, 620], [8, 680], [25, 673], [36, 654]], # PKM21 蚊香蝌蚪系
    121 => [[1, 670], [8, 705], [16, 685], [36, 686]], # PKM22 凱西系
    122 => [[1, 674], [8, 687], [28, 677], [40, 688]], # PKM23 腕力系
    123 => [[1, 617], [8, 644], [20, 690], [30, 645]], # PKM24 瑪瑙水母系
    124 => [[1, 691], [8, 693], [25, 618], [40, 655]], # PKM25 小拳石系
    125 => [[1, 608], [8, 695], [24, 662], [40, 615]], # PKM26 小火馬系
    126 => [[1, 697], [8, 764], [30, 649], [45, 651]], # PKM27 小磁怪系
    127 => [[1, 634], [8, 639], [31, 661], [36, 643]], # PKM28 嘟嘟系
    128 => [[1, 658], [8, 700], [30, 632], [38, 645]], # PKM29 臭泥系
    129 => [[1, 702], [8, 665], [25, 680], [40, 701]], # PKM30 鬼斯系
    130 => [[1, 670], [8, 680], [20, 671], [26, 686]], # PKM31 催眠貘系
    131 => [[1, 697], [8, 704], [24, 649], [30, 731]], # PKM32 霹靂電球系
    132 => [[1, 652], [8, 706], [22, 707], [28, 655]], # PKM33 卡拉卡拉系
    133 => [[1, 617], [8, 691], [30, 715], [40, 623]], # PKM34 菊石獸系
    134 => [[1, 607], [8, 617], [30, 610], [40, 709]], # PKM35 化石盔系
    135 => [[1, 670], [15, 684], [30, 685], [45, 682]], # PKM36 超夢系
    136 => [[1, 740], [15, 626], [30, 686], [45, 720]], # PKM37 夢幻系
    137 => [[1, 616], [8, 639], [10, 722], [15, 724]], # PKM38 尾立系
    138 => [[1, 770], [8, 768], [16, 726], [22, 628]], # PKM39 圓絲蛛系
    139 => [[1, 626], [8, 660], [20, 659], [40, 765]], # PKM40 波克比系
    140 => [[1, 702], [8, 665], [30, 683], [38, 701]], # PKM41 夢妖系
    141 => [[1, 740], [8, 660], [24, 705], [30, 710]], # PKM42 小福蛋系
    142 => [[1, 697], [15, 649], [30, 685], [45, 650]], # PKM43 雷公系
    143 => [[1, 608], [15, 736], [30, 695], [45, 615]], # PKM44 炎帝系
    144 => [[1, 752], [15, 681], [30, 685], [45, 623]], # PKM45 水君系
    145 => [[1, 619], [8, 691], [30, 657], [55, 640]], # PKM46 幼基拉斯系
    146 => [[1, 617], [8, 741], [14, 673], [36, 605]], # PKM47 蓮葉童子系
    147 => [[1, 617], [8, 725], [19, 690], [25, 765]], # PKM48 長翅鷗系
    148 => [[1, 749], [8, 687], [18, 750], [24, 688]], # PKM49 幕下力士系
    149 => [[1, 619], [15, 751], [30, 640], [45, 732]], # PKM50 大嘴娃系
    150 => [[1, 616], [8, 698], [32, 751], [48, 709]], # PKM51 可可多拉系
    151 => [[1, 619], [8, 611], [24, 640], [30, 672]], # PKM52 利牙魚系
    152 => [[1, 771], [8, 616], [29, 752], [35, 684]], # PKM53 醜醜魚系
    153 => [[1, 702], [8, 663], [37, 728], [50, 701]], # PKM54 夜巡靈系
    154 => [[1, 639], [15, 753], [30, 610], [45, 640]], # PKM55 阿勃梭魯系
    155 => [[1, 619], [8, 706], [30, 718], [50, 614]], # PKM56 寶貝龍系
    156 => [[1, 616], [8, 698], [20, 686], [45, 755]], # PKM57 鐵啞鈴系
    157 => [[1, 735], [8, 681], [30, 665], [42, 622]], # PKM58 雪童子系
    158 => [[1, 771], [8, 616], [20, 619], [24, 672]], # PKM59 鯉魚王系
    159 => [[1, 617], [8, 697], [21, 649], [27, 621]], # PKM60 燈籠魚系
    160 => [[1, 616], [8, 618], [25, 729], [31, 731]], # PKM61 榛果球系
    161 => [[1, 616], [8, 653], [24, 718], [48, 655]], # PKM62 圓陸鯊系
    162 => [[1, 624], [15, 654], [30, 687], [45, 627]], # PKM63 赫拉克羅斯系
    163 => [[1, 608], [8, 619], [18, 663], [24, 612]], # PKM64 戴魯比系
    164 => [[1, 634], [15, 730], [30, 729], [45, 751]], # PKM65 盔甲鳥系
    165 => [[1, 670], [8, 685], [20, 659], [40, 686]], # PKM66 拉魯拉絲系
  }

  def self.sync_class_skills(actor)
    return if actor == nil || actor.class == nil
    actor.class.learnings.each do |learning|
      actor.learn_skill(learning.skill_id) if learning.level <= actor.level
    end
  end

  def self.default_ai_package(actor)
    return nil if actor == nil
    return nil unless POKEMON_ACTOR_IDS.include?(actor.id)
    sid = DEFAULT_AI[actor.id] || 25
    return nil unless defined?(AutoBattleAI)
    return nil unless AutoBattleAI.const_defined?(:STATE_AI_MAPPING)
    return AutoBattleAI::STATE_AI_MAPPING[sid]
  end
end

module ALBERT_ACTOR_PROFILE
  ACTORS.merge!({
    100 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter"],
      :tags => []
    }, # 妙蛙種子
    101 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter", "parasite_starter"],
      :tags => []
    }, # 妙蛙草
    102 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter", "parasite_starter", "state_spreader"],
      :tags => []
    }, # 妙蛙花
    103 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_finisher"],
      :tags => []
    }, # 小火龍
    104 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_finisher", "resonance_fast"],
      :tags => []
    }, # 火恐龍
    105 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_finisher", "resonance_fast", "finisher"],
      :tags => []
    }, # 噴火龍
    106 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter"],
      :tags => []
    }, # 水躍魚
    107 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "breaker"],
      :tags => []
    }, # 沼躍魚
    108 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "breaker", "tank"],
      :tags => []
    }, # 巨沼怪
    109 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["sleep_controller"],
      :tags => []
    }, # 綠毛蟲
    110 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["sleep_controller", "state_spreader"],
      :tags => []
    }, # 鐵甲蛹
    111 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["sleep_controller", "state_spreader"],
      :tags => []
    }, # 巴大蝶
    112 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter"],
      :tags => []
    }, # 獨角蟲
    113 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter", "crit_hunter"],
      :tags => []
    }, # 鐵殼蛹
    114 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter", "crit_hunter"],
      :tags => []
    }, # 大針蜂
    115 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast"],
      :tags => []
    }, # 波波
    116 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast", "protector"],
      :tags => []
    }, # 比比鳥
    117 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast", "protector"],
      :tags => []
    }, # 比雕
    118 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["crit_hunter"],
      :tags => []
    }, # 小拉達
    119 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["crit_hunter", "low_hp_finisher"],
      :tags => []
    }, # 拉達
    120 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["crit_hunter"],
      :tags => []
    }, # 烈雀
    121 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["crit_hunter", "fast_breaker"],
      :tags => []
    }, # 大嘴雀
    122 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter"],
      :tags => []
    }, # 阿柏蛇
    123 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter", "corrosion_engine"],
      :tags => []
    }, # 阿柏怪
    124 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["paralysis_engine"],
      :tags => []
    }, # 皮卡丘
    125 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["paralysis_engine", "atb_controller"],
      :tags => []
    }, # 雷丘
    126 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker"],
      :tags => []
    }, # 穿山鼠
    127 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker", "ground_finisher"],
      :tags => []
    }, # 穿山王
    128 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_starter"],
      :tags => []
    }, # 六尾
    129 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_starter", "fragile_engine"],
      :tags => []
    }, # 九尾
    130 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["healer"],
      :tags => []
    }, # 胖丁
    131 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["healer", "sleep_controller"],
      :tags => []
    }, # 胖可丁
    132 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast"],
      :tags => []
    }, # 超音蝠
    133 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast", "poison_spreader"],
      :tags => []
    }, # 大嘴蝠
    134 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast", "poison_spreader"],
      :tags => []
    }, # 叉字蝠
    135 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter"],
      :tags => []
    }, # 走路草
    136 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter", "sleep_controller"],
      :tags => []
    }, # 走路花
    137 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter", "sleep_controller"],
      :tags => []
    }, # 霸王花
    138 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["parasite_starter"],
      :tags => []
    }, # 派拉斯
    139 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["parasite_starter", "root_controller"],
      :tags => []
    }, # 派拉斯特
    140 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["state_spreader"],
      :tags => []
    }, # 毛球
    141 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["state_spreader", "sleep_controller"],
      :tags => []
    }, # 摩魯蛾
    142 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter"],
      :tags => []
    }, # 可達鴨
    143 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "atb_controller"],
      :tags => []
    }, # 哥達鴨
    144 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker"],
      :tags => []
    }, # 猴怪
    145 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker", "rage_dps"],
      :tags => []
    }, # 火爆猴
    146 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_finisher"],
      :tags => []
    }, # 卡蒂狗
    147 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_finisher", "protector"],
      :tags => []
    }, # 風速狗
    148 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter"],
      :tags => []
    }, # 蚊香蝌蚪
    149 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "breaker"],
      :tags => []
    }, # 蚊香君
    150 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "breaker"],
      :tags => []
    }, # 蚊香泳士
    151 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["atb_controller"],
      :tags => []
    }, # 凱西
    152 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["atb_controller", "state_dps"],
      :tags => []
    }, # 勇基拉
    153 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["atb_controller", "state_dps"],
      :tags => []
    }, # 胡地
    154 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["heavy_breaker"],
      :tags => []
    }, # 腕力
    155 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["heavy_breaker", "finisher"],
      :tags => []
    }, # 豪力
    156 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["heavy_breaker", "finisher"],
      :tags => []
    }, # 怪力
    157 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter"],
      :tags => []
    }, # 瑪瑙水母
    158 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "poison_starter"],
      :tags => []
    }, # 毒刺水母
    159 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank"],
      :tags => []
    }, # 小拳石
    160 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank", "breaker"],
      :tags => []
    }, # 隆隆石
    161 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank", "breaker"],
      :tags => []
    }, # 隆隆岩
    162 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_starter"],
      :tags => []
    }, # 小火馬
    163 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_starter", "resonance_fast"],
      :tags => []
    }, # 烈焰馬
    164 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["paralysis_engine"],
      :tags => []
    }, # 小磁怪
    165 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["paralysis_engine", "atb_controller"],
      :tags => []
    }, # 三合一磁怪
    166 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["paralysis_engine", "atb_controller", "protector"],
      :tags => []
    }, # 自爆磁怪
    167 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast"],
      :tags => []
    }, # 嘟嘟
    168 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast", "crit_hunter"],
      :tags => []
    }, # 嘟嘟利
    169 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["corrosion_engine"],
      :tags => []
    }, # 臭泥
    170 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["corrosion_engine", "poison_tank"],
      :tags => []
    }, # 臭臭泥
    171 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["state_controller"],
      :tags => []
    }, # 鬼斯
    172 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["state_controller", "state_hunter"],
      :tags => []
    }, # 鬼斯通
    173 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["state_controller", "state_hunter"],
      :tags => []
    }, # 耿鬼
    174 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["sleep_controller"],
      :tags => []
    }, # 催眠貘
    175 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["sleep_controller", "atb_controller"],
      :tags => []
    }, # 引夢貘人
    176 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast"],
      :tags => []
    }, # 霹靂電球
    177 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast", "atb_controller"],
      :tags => []
    }, # 頑皮雷彈
    178 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker"],
      :tags => []
    }, # 卡拉卡拉
    179 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker", "low_hp_finisher"],
      :tags => []
    }, # 嘎啦嘎啦
    180 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter"],
      :tags => []
    }, # 菊石獸
    181 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "tank"],
      :tags => []
    }, # 多刺菊石獸
    182 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker"],
      :tags => []
    }, # 化石盔
    183 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker", "finisher"],
      :tags => []
    }, # 鐮刀盔
    184 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["legendary_finisher", "atb_controller"],
      :tags => []
    }, # 超夢
    185 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["adaptive_allrounder", "state_support"],
      :tags => []
    }, # 夢幻
    186 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast"],
      :tags => []
    }, # 尾立
    187 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["resonance_fast", "support"],
      :tags => []
    }, # 大尾立
    188 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter"],
      :tags => []
    }, # 圓絲蛛
    189 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["poison_starter", "root_controller"],
      :tags => []
    }, # 阿利多斯
    190 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["healer"],
      :tags => []
    }, # 波克比
    191 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["healer", "shield_support"],
      :tags => []
    }, # 波克基古
    192 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["healer", "shield_support", "state_controller"],
      :tags => []
    }, # 波克基斯
    193 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["state_controller"],
      :tags => []
    }, # 夢妖
    194 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["state_controller", "fragile_engine"],
      :tags => []
    }, # 夢妖魔
    195 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["healer"],
      :tags => []
    }, # 小福蛋
    196 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["healer", "mana_support"],
      :tags => []
    }, # 幸福蛋
    197 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["paralysis_engine", "resonance_fast"],
      :tags => []
    }, # 雷公
    198 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_finisher", "breaker"],
      :tags => []
    }, # 炎帝
    199 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "shield_support", "atb_controller"],
      :tags => []
    }, # 水君
    200 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank"],
      :tags => []
    }, # 幼基拉斯
    201 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank", "breaker"],
      :tags => []
    }, # 沙基拉斯
    202 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank", "breaker", "finisher"],
      :tags => []
    }, # 班基拉斯
    203 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter"],
      :tags => []
    }, # 蓮葉童子
    204 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "healer"],
      :tags => []
    }, # 蓮帽小童
    205 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "healer", "mana_support"],
      :tags => []
    }, # 樂天河童
    206 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter"],
      :tags => []
    }, # 長翅鷗
    207 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "protector"],
      :tags => []
    }, # 大嘴鷗
    208 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["heavy_breaker"],
      :tags => []
    }, # 幕下力士
    209 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["heavy_breaker", "tank"],
      :tags => []
    }, # 鐵掌力士
    210 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["fragile_engine", "protector", "finisher"],
      :tags => []
    }, # 大嘴娃
    211 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank"],
      :tags => []
    }, # 可可多拉
    212 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank", "breaker"],
      :tags => []
    }, # 可多拉
    213 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank", "breaker", "protector"],
      :tags => []
    }, # 波士可多拉
    214 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_finisher"],
      :tags => []
    }, # 利牙魚
    215 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_finisher", "crit_hunter"],
      :tags => []
    }, # 巨牙鯊
    216 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["healer"],
      :tags => []
    }, # 醜醜魚
    217 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["healer", "shield_support", "wet_starter"],
      :tags => []
    }, # 美納斯
    218 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank"],
      :tags => []
    }, # 夜巡靈
    219 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank", "state_controller"],
      :tags => []
    }, # 彷徨夜靈
    220 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank", "state_controller"],
      :tags => []
    }, # 黑夜魔靈
    221 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["crit_hunter", "finisher"],
      :tags => []
    }, # 阿勃梭魯
    222 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["finisher"],
      :tags => []
    }, # 寶貝龍
    223 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["finisher", "resonance_fast"],
      :tags => []
    }, # 甲殼龍
    224 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["finisher", "resonance_fast"],
      :tags => []
    }, # 暴飛龍
    225 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker"],
      :tags => []
    }, # 鐵啞鈴
    226 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker", "atb_controller"],
      :tags => []
    }, # 金屬怪
    227 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker", "atb_controller", "tank"],
      :tags => []
    }, # 巨金怪
    228 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["freeze_controller"],
      :tags => []
    }, # 雪童子
    229 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["freeze_controller", "resonance_fast"],
      :tags => []
    }, # 雪妖女
    230 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter"],
      :tags => []
    }, # 鯉魚王
    231 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_starter", "rage_dps", "breaker"],
      :tags => []
    }, # 暴鯉龍
    232 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_paralysis"],
      :tags => []
    }, # 燈籠魚
    233 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["wet_paralysis", "mana_support"],
      :tags => []
    }, # 電燈怪
    234 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank"],
      :tags => []
    }, # 榛果球
    235 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["tank", "state_spreader", "protector"],
      :tags => []
    }, # 佛烈托斯
    236 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker"],
      :tags => []
    }, # 圓陸鯊
    237 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker", "finisher"],
      :tags => []
    }, # 尖牙陸鯊
    238 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker", "finisher", "resonance_fast"],
      :tags => []
    }, # 烈咬陸鯊
    239 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["breaker", "finisher"],
      :tags => []
    }, # 赫拉克羅斯
    240 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_finisher"],
      :tags => []
    }, # 戴魯比
    241 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["burn_finisher", "state_dps"],
      :tags => []
    }, # 黑魯加
    242 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["protector", "tank"],
      :tags => []
    }, # 盔甲鳥
    243 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["mana_support"],
      :tags => []
    }, # 拉魯拉絲
    244 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["mana_support", "healer"],
      :tags => []
    }, # 奇魯莉安
    245 => {
      :summon => true,
      :type => :pokemon,
      :groups => ["summon", "pokemon"],
      :roles => ["mana_support", "healer", "state_controller"],
      :tags => []
    }, # 沙奈朵
  })
end

module ALBERT_ACTOR_ENEMY_GROWTH
  ACTOR_TO_ENEMY.merge!({
    100 => 600, # 妙蛙種子
    101 => 601, # 妙蛙草
    102 => 602, # 妙蛙花
    103 => 603, # 小火龍
    104 => 604, # 火恐龍
    105 => 605, # 噴火龍
    106 => 606, # 水躍魚
    107 => 607, # 沼躍魚
    108 => 608, # 巨沼怪
    109 => 609, # 綠毛蟲
    110 => 610, # 鐵甲蛹
    111 => 611, # 巴大蝶
    112 => 612, # 獨角蟲
    113 => 613, # 鐵殼蛹
    114 => 614, # 大針蜂
    115 => 615, # 波波
    116 => 616, # 比比鳥
    117 => 617, # 比雕
    118 => 618, # 小拉達
    119 => 619, # 拉達
    120 => 620, # 烈雀
    121 => 621, # 大嘴雀
    122 => 622, # 阿柏蛇
    123 => 623, # 阿柏怪
    124 => 624, # 皮卡丘
    125 => 625, # 雷丘
    126 => 626, # 穿山鼠
    127 => 627, # 穿山王
    128 => 628, # 六尾
    129 => 629, # 九尾
    130 => 630, # 胖丁
    131 => 631, # 胖可丁
    132 => 632, # 超音蝠
    133 => 633, # 大嘴蝠
    134 => 634, # 叉字蝠
    135 => 635, # 走路草
    136 => 636, # 走路花
    137 => 637, # 霸王花
    138 => 638, # 派拉斯
    139 => 639, # 派拉斯特
    140 => 640, # 毛球
    141 => 641, # 摩魯蛾
    142 => 642, # 可達鴨
    143 => 643, # 哥達鴨
    144 => 644, # 猴怪
    145 => 645, # 火爆猴
    146 => 646, # 卡蒂狗
    147 => 647, # 風速狗
    148 => 648, # 蚊香蝌蚪
    149 => 649, # 蚊香君
    150 => 650, # 蚊香泳士
    151 => 651, # 凱西
    152 => 652, # 勇基拉
    153 => 653, # 胡地
    154 => 654, # 腕力
    155 => 655, # 豪力
    156 => 656, # 怪力
    157 => 657, # 瑪瑙水母
    158 => 658, # 毒刺水母
    159 => 659, # 小拳石
    160 => 660, # 隆隆石
    161 => 661, # 隆隆岩
    162 => 662, # 小火馬
    163 => 663, # 烈焰馬
    164 => 664, # 小磁怪
    165 => 665, # 三合一磁怪
    166 => 666, # 自爆磁怪
    167 => 667, # 嘟嘟
    168 => 668, # 嘟嘟利
    169 => 669, # 臭泥
    170 => 670, # 臭臭泥
    171 => 671, # 鬼斯
    172 => 672, # 鬼斯通
    173 => 673, # 耿鬼
    174 => 674, # 催眠貘
    175 => 675, # 引夢貘人
    176 => 676, # 霹靂電球
    177 => 677, # 頑皮雷彈
    178 => 678, # 卡拉卡拉
    179 => 679, # 嘎啦嘎啦
    180 => 680, # 菊石獸
    181 => 681, # 多刺菊石獸
    182 => 682, # 化石盔
    183 => 683, # 鐮刀盔
    184 => 684, # 超夢
    185 => 685, # 夢幻
    186 => 686, # 尾立
    187 => 687, # 大尾立
    188 => 688, # 圓絲蛛
    189 => 689, # 阿利多斯
    190 => 690, # 波克比
    191 => 691, # 波克基古
    192 => 692, # 波克基斯
    193 => 693, # 夢妖
    194 => 694, # 夢妖魔
    195 => 695, # 小福蛋
    196 => 696, # 幸福蛋
    197 => 697, # 雷公
    198 => 698, # 炎帝
    199 => 699, # 水君
    200 => 700, # 幼基拉斯
    201 => 701, # 沙基拉斯
    202 => 702, # 班基拉斯
    203 => 703, # 蓮葉童子
    204 => 704, # 蓮帽小童
    205 => 705, # 樂天河童
    206 => 706, # 長翅鷗
    207 => 707, # 大嘴鷗
    208 => 708, # 幕下力士
    209 => 709, # 鐵掌力士
    210 => 710, # 大嘴娃
    211 => 711, # 可可多拉
    212 => 712, # 可多拉
    213 => 713, # 波士可多拉
    214 => 714, # 利牙魚
    215 => 715, # 巨牙鯊
    216 => 716, # 醜醜魚
    217 => 717, # 美納斯
    218 => 718, # 夜巡靈
    219 => 719, # 彷徨夜靈
    220 => 720, # 黑夜魔靈
    221 => 721, # 阿勃梭魯
    222 => 722, # 寶貝龍
    223 => 723, # 甲殼龍
    224 => 724, # 暴飛龍
    225 => 725, # 鐵啞鈴
    226 => 726, # 金屬怪
    227 => 727, # 巨金怪
    228 => 728, # 雪童子
    229 => 729, # 雪妖女
    230 => 730, # 鯉魚王
    231 => 731, # 暴鯉龍
    232 => 732, # 燈籠魚
    233 => 733, # 電燈怪
    234 => 734, # 榛果球
    235 => 735, # 佛烈托斯
    236 => 736, # 圓陸鯊
    237 => 737, # 尖牙陸鯊
    238 => 738, # 烈咬陸鯊
    239 => 739, # 赫拉克羅斯
    240 => 740, # 戴魯比
    241 => 741, # 黑魯加
    242 => 742, # 盔甲鳥
    243 => 743, # 拉魯拉絲
    244 => 744, # 奇魯莉安
    245 => 745, # 沙奈朵
  })
end

module ElementalSettings
  ACTOR_ELEMENT_TABLE = {} unless const_defined?(:ACTOR_ELEMENT_TABLE)
  ACTOR_ELEMENT_TABLE.merge!({
    100 => [:grass, :poison], # 妙蛙種子
    101 => [:grass, :poison], # 妙蛙草
    102 => [:grass, :poison], # 妙蛙花
    103 => [:fire, nil], # 小火龍
    104 => [:fire, nil], # 火恐龍
    105 => [:fire, :flying], # 噴火龍
    106 => [:water, nil], # 水躍魚
    107 => [:water, :ground], # 沼躍魚
    108 => [:water, :ground], # 巨沼怪
    109 => [:bug, nil], # 綠毛蟲
    110 => [:bug, nil], # 鐵甲蛹
    111 => [:bug, :flying], # 巴大蝶
    112 => [:bug, :poison], # 獨角蟲
    113 => [:bug, :poison], # 鐵殼蛹
    114 => [:bug, :poison], # 大針蜂
    115 => [:normal, :flying], # 波波
    116 => [:normal, :flying], # 比比鳥
    117 => [:normal, :flying], # 比雕
    118 => [:normal, nil], # 小拉達
    119 => [:normal, nil], # 拉達
    120 => [:normal, :flying], # 烈雀
    121 => [:normal, :flying], # 大嘴雀
    122 => [:poison, nil], # 阿柏蛇
    123 => [:poison, nil], # 阿柏怪
    124 => [:electric, nil], # 皮卡丘
    125 => [:electric, nil], # 雷丘
    126 => [:ground, nil], # 穿山鼠
    127 => [:ground, nil], # 穿山王
    128 => [:fire, nil], # 六尾
    129 => [:fire, nil], # 九尾
    130 => [:normal, :fairy], # 胖丁
    131 => [:normal, :fairy], # 胖可丁
    132 => [:poison, :flying], # 超音蝠
    133 => [:poison, :flying], # 大嘴蝠
    134 => [:poison, :flying], # 叉字蝠
    135 => [:grass, :poison], # 走路草
    136 => [:grass, :poison], # 走路花
    137 => [:grass, :poison], # 霸王花
    138 => [:bug, :grass], # 派拉斯
    139 => [:bug, :grass], # 派拉斯特
    140 => [:bug, :poison], # 毛球
    141 => [:bug, :poison], # 摩魯蛾
    142 => [:water, nil], # 可達鴨
    143 => [:water, nil], # 哥達鴨
    144 => [:fighting, nil], # 猴怪
    145 => [:fighting, nil], # 火爆猴
    146 => [:fire, nil], # 卡蒂狗
    147 => [:fire, nil], # 風速狗
    148 => [:water, nil], # 蚊香蝌蚪
    149 => [:water, nil], # 蚊香君
    150 => [:water, :fighting], # 蚊香泳士
    151 => [:psychic, nil], # 凱西
    152 => [:psychic, nil], # 勇基拉
    153 => [:psychic, nil], # 胡地
    154 => [:fighting, nil], # 腕力
    155 => [:fighting, nil], # 豪力
    156 => [:fighting, nil], # 怪力
    157 => [:water, :poison], # 瑪瑙水母
    158 => [:water, :poison], # 毒刺水母
    159 => [:rock, :ground], # 小拳石
    160 => [:rock, :ground], # 隆隆石
    161 => [:rock, :ground], # 隆隆岩
    162 => [:fire, nil], # 小火馬
    163 => [:fire, nil], # 烈焰馬
    164 => [:electric, :steel], # 小磁怪
    165 => [:electric, :steel], # 三合一磁怪
    166 => [:electric, :steel], # 自爆磁怪
    167 => [:normal, :flying], # 嘟嘟
    168 => [:normal, :flying], # 嘟嘟利
    169 => [:poison, nil], # 臭泥
    170 => [:poison, nil], # 臭臭泥
    171 => [:ghost, :poison], # 鬼斯
    172 => [:ghost, :poison], # 鬼斯通
    173 => [:ghost, :poison], # 耿鬼
    174 => [:psychic, nil], # 催眠貘
    175 => [:psychic, nil], # 引夢貘人
    176 => [:electric, nil], # 霹靂電球
    177 => [:electric, nil], # 頑皮雷彈
    178 => [:ground, nil], # 卡拉卡拉
    179 => [:ground, nil], # 嘎啦嘎啦
    180 => [:rock, :water], # 菊石獸
    181 => [:rock, :water], # 多刺菊石獸
    182 => [:rock, :water], # 化石盔
    183 => [:rock, :water], # 鐮刀盔
    184 => [:psychic, nil], # 超夢
    185 => [:psychic, nil], # 夢幻
    186 => [:normal, nil], # 尾立
    187 => [:normal, nil], # 大尾立
    188 => [:bug, :poison], # 圓絲蛛
    189 => [:bug, :poison], # 阿利多斯
    190 => [:fairy, nil], # 波克比
    191 => [:fairy, :flying], # 波克基古
    192 => [:fairy, :flying], # 波克基斯
    193 => [:ghost, nil], # 夢妖
    194 => [:ghost, nil], # 夢妖魔
    195 => [:normal, nil], # 小福蛋
    196 => [:normal, nil], # 幸福蛋
    197 => [:electric, nil], # 雷公
    198 => [:fire, nil], # 炎帝
    199 => [:water, nil], # 水君
    200 => [:rock, :ground], # 幼基拉斯
    201 => [:rock, :ground], # 沙基拉斯
    202 => [:rock, :dark], # 班基拉斯
    203 => [:water, :grass], # 蓮葉童子
    204 => [:water, :grass], # 蓮帽小童
    205 => [:water, :grass], # 樂天河童
    206 => [:water, :flying], # 長翅鷗
    207 => [:water, :flying], # 大嘴鷗
    208 => [:fighting, nil], # 幕下力士
    209 => [:fighting, nil], # 鐵掌力士
    210 => [:steel, :fairy], # 大嘴娃
    211 => [:steel, :rock], # 可可多拉
    212 => [:steel, :rock], # 可多拉
    213 => [:steel, :rock], # 波士可多拉
    214 => [:water, :dark], # 利牙魚
    215 => [:water, :dark], # 巨牙鯊
    216 => [:water, nil], # 醜醜魚
    217 => [:water, nil], # 美納斯
    218 => [:ghost, nil], # 夜巡靈
    219 => [:ghost, nil], # 彷徨夜靈
    220 => [:ghost, nil], # 黑夜魔靈
    221 => [:dark, nil], # 阿勃梭魯
    222 => [:dragon, nil], # 寶貝龍
    223 => [:dragon, nil], # 甲殼龍
    224 => [:dragon, :flying], # 暴飛龍
    225 => [:steel, :psychic], # 鐵啞鈴
    226 => [:steel, :psychic], # 金屬怪
    227 => [:steel, :psychic], # 巨金怪
    228 => [:ice, nil], # 雪童子
    229 => [:ice, :ghost], # 雪妖女
    230 => [:water, nil], # 鯉魚王
    231 => [:water, :flying], # 暴鯉龍
    232 => [:water, :electric], # 燈籠魚
    233 => [:water, :electric], # 電燈怪
    234 => [:bug, nil], # 榛果球
    235 => [:bug, :steel], # 佛烈托斯
    236 => [:dragon, :ground], # 圓陸鯊
    237 => [:dragon, :ground], # 尖牙陸鯊
    238 => [:dragon, :ground], # 烈咬陸鯊
    239 => [:bug, :fighting], # 赫拉克羅斯
    240 => [:dark, :fire], # 戴魯比
    241 => [:dark, :fire], # 黑魯加
    242 => [:steel, :flying], # 盔甲鳥
    243 => [:psychic, :fairy], # 拉魯拉絲
    244 => [:psychic, :fairy], # 奇魯莉安
    245 => [:psychic, :fairy], # 沙奈朵
  })
  ENEMY_ELEMENT_TABLE.merge!({
    600 => [:grass, :poison], # 妙蛙種子
    601 => [:grass, :poison], # 妙蛙草
    602 => [:grass, :poison], # 妙蛙花
    603 => [:fire, nil], # 小火龍
    604 => [:fire, nil], # 火恐龍
    605 => [:fire, :flying], # 噴火龍
    606 => [:water, nil], # 水躍魚
    607 => [:water, :ground], # 沼躍魚
    608 => [:water, :ground], # 巨沼怪
    609 => [:bug, nil], # 綠毛蟲
    610 => [:bug, nil], # 鐵甲蛹
    611 => [:bug, :flying], # 巴大蝶
    612 => [:bug, :poison], # 獨角蟲
    613 => [:bug, :poison], # 鐵殼蛹
    614 => [:bug, :poison], # 大針蜂
    615 => [:normal, :flying], # 波波
    616 => [:normal, :flying], # 比比鳥
    617 => [:normal, :flying], # 比雕
    618 => [:normal, nil], # 小拉達
    619 => [:normal, nil], # 拉達
    620 => [:normal, :flying], # 烈雀
    621 => [:normal, :flying], # 大嘴雀
    622 => [:poison, nil], # 阿柏蛇
    623 => [:poison, nil], # 阿柏怪
    624 => [:electric, nil], # 皮卡丘
    625 => [:electric, nil], # 雷丘
    626 => [:ground, nil], # 穿山鼠
    627 => [:ground, nil], # 穿山王
    628 => [:fire, nil], # 六尾
    629 => [:fire, nil], # 九尾
    630 => [:normal, :fairy], # 胖丁
    631 => [:normal, :fairy], # 胖可丁
    632 => [:poison, :flying], # 超音蝠
    633 => [:poison, :flying], # 大嘴蝠
    634 => [:poison, :flying], # 叉字蝠
    635 => [:grass, :poison], # 走路草
    636 => [:grass, :poison], # 走路花
    637 => [:grass, :poison], # 霸王花
    638 => [:bug, :grass], # 派拉斯
    639 => [:bug, :grass], # 派拉斯特
    640 => [:bug, :poison], # 毛球
    641 => [:bug, :poison], # 摩魯蛾
    642 => [:water, nil], # 可達鴨
    643 => [:water, nil], # 哥達鴨
    644 => [:fighting, nil], # 猴怪
    645 => [:fighting, nil], # 火爆猴
    646 => [:fire, nil], # 卡蒂狗
    647 => [:fire, nil], # 風速狗
    648 => [:water, nil], # 蚊香蝌蚪
    649 => [:water, nil], # 蚊香君
    650 => [:water, :fighting], # 蚊香泳士
    651 => [:psychic, nil], # 凱西
    652 => [:psychic, nil], # 勇基拉
    653 => [:psychic, nil], # 胡地
    654 => [:fighting, nil], # 腕力
    655 => [:fighting, nil], # 豪力
    656 => [:fighting, nil], # 怪力
    657 => [:water, :poison], # 瑪瑙水母
    658 => [:water, :poison], # 毒刺水母
    659 => [:rock, :ground], # 小拳石
    660 => [:rock, :ground], # 隆隆石
    661 => [:rock, :ground], # 隆隆岩
    662 => [:fire, nil], # 小火馬
    663 => [:fire, nil], # 烈焰馬
    664 => [:electric, :steel], # 小磁怪
    665 => [:electric, :steel], # 三合一磁怪
    666 => [:electric, :steel], # 自爆磁怪
    667 => [:normal, :flying], # 嘟嘟
    668 => [:normal, :flying], # 嘟嘟利
    669 => [:poison, nil], # 臭泥
    670 => [:poison, nil], # 臭臭泥
    671 => [:ghost, :poison], # 鬼斯
    672 => [:ghost, :poison], # 鬼斯通
    673 => [:ghost, :poison], # 耿鬼
    674 => [:psychic, nil], # 催眠貘
    675 => [:psychic, nil], # 引夢貘人
    676 => [:electric, nil], # 霹靂電球
    677 => [:electric, nil], # 頑皮雷彈
    678 => [:ground, nil], # 卡拉卡拉
    679 => [:ground, nil], # 嘎啦嘎啦
    680 => [:rock, :water], # 菊石獸
    681 => [:rock, :water], # 多刺菊石獸
    682 => [:rock, :water], # 化石盔
    683 => [:rock, :water], # 鐮刀盔
    684 => [:psychic, nil], # 超夢
    685 => [:psychic, nil], # 夢幻
    686 => [:normal, nil], # 尾立
    687 => [:normal, nil], # 大尾立
    688 => [:bug, :poison], # 圓絲蛛
    689 => [:bug, :poison], # 阿利多斯
    690 => [:fairy, nil], # 波克比
    691 => [:fairy, :flying], # 波克基古
    692 => [:fairy, :flying], # 波克基斯
    693 => [:ghost, nil], # 夢妖
    694 => [:ghost, nil], # 夢妖魔
    695 => [:normal, nil], # 小福蛋
    696 => [:normal, nil], # 幸福蛋
    697 => [:electric, nil], # 雷公
    698 => [:fire, nil], # 炎帝
    699 => [:water, nil], # 水君
    700 => [:rock, :ground], # 幼基拉斯
    701 => [:rock, :ground], # 沙基拉斯
    702 => [:rock, :dark], # 班基拉斯
    703 => [:water, :grass], # 蓮葉童子
    704 => [:water, :grass], # 蓮帽小童
    705 => [:water, :grass], # 樂天河童
    706 => [:water, :flying], # 長翅鷗
    707 => [:water, :flying], # 大嘴鷗
    708 => [:fighting, nil], # 幕下力士
    709 => [:fighting, nil], # 鐵掌力士
    710 => [:steel, :fairy], # 大嘴娃
    711 => [:steel, :rock], # 可可多拉
    712 => [:steel, :rock], # 可多拉
    713 => [:steel, :rock], # 波士可多拉
    714 => [:water, :dark], # 利牙魚
    715 => [:water, :dark], # 巨牙鯊
    716 => [:water, nil], # 醜醜魚
    717 => [:water, nil], # 美納斯
    718 => [:ghost, nil], # 夜巡靈
    719 => [:ghost, nil], # 彷徨夜靈
    720 => [:ghost, nil], # 黑夜魔靈
    721 => [:dark, nil], # 阿勃梭魯
    722 => [:dragon, nil], # 寶貝龍
    723 => [:dragon, nil], # 甲殼龍
    724 => [:dragon, :flying], # 暴飛龍
    725 => [:steel, :psychic], # 鐵啞鈴
    726 => [:steel, :psychic], # 金屬怪
    727 => [:steel, :psychic], # 巨金怪
    728 => [:ice, nil], # 雪童子
    729 => [:ice, :ghost], # 雪妖女
    730 => [:water, nil], # 鯉魚王
    731 => [:water, :flying], # 暴鯉龍
    732 => [:water, :electric], # 燈籠魚
    733 => [:water, :electric], # 電燈怪
    734 => [:bug, nil], # 榛果球
    735 => [:bug, :steel], # 佛烈托斯
    736 => [:dragon, :ground], # 圓陸鯊
    737 => [:dragon, :ground], # 尖牙陸鯊
    738 => [:dragon, :ground], # 烈咬陸鯊
    739 => [:bug, :fighting], # 赫拉克羅斯
    740 => [:dark, :fire], # 戴魯比
    741 => [:dark, :fire], # 黑魯加
    742 => [:steel, :flying], # 盔甲鳥
    743 => [:psychic, :fairy], # 拉魯拉絲
    744 => [:psychic, :fairy], # 奇魯莉安
    745 => [:psychic, :fairy], # 沙奈朵
  })
  CLASS_ELEMENT_TABLE.merge!({
    100 => [:grass, :poison], # 妙蛙種子系 fallback
    101 => [:fire, nil], # 小火龍系 fallback
    102 => [:water, nil], # 水躍魚系 fallback
    103 => [:bug, nil], # 綠毛蟲系 fallback
    104 => [:bug, :poison], # 獨角蟲系 fallback
    105 => [:normal, :flying], # 波波系 fallback
    106 => [:normal, nil], # 小拉達系 fallback
    107 => [:normal, :flying], # 烈雀系 fallback
    108 => [:poison, nil], # 阿柏蛇系 fallback
    109 => [:electric, nil], # 皮卡丘系 fallback
    110 => [:ground, nil], # 穿山鼠系 fallback
    111 => [:fire, nil], # 六尾系 fallback
    112 => [:normal, :fairy], # 胖丁系 fallback
    113 => [:poison, :flying], # 超音蝠系 fallback
    114 => [:grass, :poison], # 走路草系 fallback
    115 => [:bug, :grass], # 派拉斯系 fallback
    116 => [:bug, :poison], # 毛球系 fallback
    117 => [:water, nil], # 可達鴨系 fallback
    118 => [:fighting, nil], # 猴怪系 fallback
    119 => [:fire, nil], # 卡蒂狗系 fallback
    120 => [:water, nil], # 蚊香蝌蚪系 fallback
    121 => [:psychic, nil], # 凱西系 fallback
    122 => [:fighting, nil], # 腕力系 fallback
    123 => [:water, :poison], # 瑪瑙水母系 fallback
    124 => [:rock, :ground], # 小拳石系 fallback
    125 => [:fire, nil], # 小火馬系 fallback
    126 => [:electric, :steel], # 小磁怪系 fallback
    127 => [:normal, :flying], # 嘟嘟系 fallback
    128 => [:poison, nil], # 臭泥系 fallback
    129 => [:ghost, :poison], # 鬼斯系 fallback
    130 => [:psychic, nil], # 催眠貘系 fallback
    131 => [:electric, nil], # 霹靂電球系 fallback
    132 => [:ground, nil], # 卡拉卡拉系 fallback
    133 => [:rock, :water], # 菊石獸系 fallback
    134 => [:rock, :water], # 化石盔系 fallback
    135 => [:psychic, nil], # 超夢系 fallback
    136 => [:psychic, nil], # 夢幻系 fallback
    137 => [:normal, nil], # 尾立系 fallback
    138 => [:bug, :poison], # 圓絲蛛系 fallback
    139 => [:fairy, nil], # 波克比系 fallback
    140 => [:ghost, nil], # 夢妖系 fallback
    141 => [:normal, nil], # 小福蛋系 fallback
    142 => [:electric, nil], # 雷公系 fallback
    143 => [:fire, nil], # 炎帝系 fallback
    144 => [:water, nil], # 水君系 fallback
    145 => [:rock, :ground], # 幼基拉斯系 fallback
    146 => [:water, :grass], # 蓮葉童子系 fallback
    147 => [:water, :flying], # 長翅鷗系 fallback
    148 => [:fighting, nil], # 幕下力士系 fallback
    149 => [:steel, :fairy], # 大嘴娃系 fallback
    150 => [:steel, :rock], # 可可多拉系 fallback
    151 => [:water, :dark], # 利牙魚系 fallback
    152 => [:water, nil], # 醜醜魚系 fallback
    153 => [:ghost, nil], # 夜巡靈系 fallback
    154 => [:dark, nil], # 阿勃梭魯系 fallback
    155 => [:dragon, nil], # 寶貝龍系 fallback
    156 => [:steel, :psychic], # 鐵啞鈴系 fallback
    157 => [:ice, nil], # 雪童子系 fallback
    158 => [:water, nil], # 鯉魚王系 fallback
    159 => [:water, :electric], # 燈籠魚系 fallback
    160 => [:bug, nil], # 榛果球系 fallback
    161 => [:dragon, :ground], # 圓陸鯊系 fallback
    162 => [:bug, :fighting], # 赫拉克羅斯系 fallback
    163 => [:dark, :fire], # 戴魯比系 fallback
    164 => [:steel, :flying], # 盔甲鳥系 fallback
    165 => [:psychic, :fairy], # 拉魯拉絲系 fallback
  })
end

class Game_Actor < Game_Battler
  def setup_elements
    table = ElementalSettings::ACTOR_ELEMENT_TABLE
    elements = table[@actor_id]
    elements = ElementalSettings::CLASS_ELEMENT_TABLE[@class_id] if elements == nil
    elements = [:normal, nil] if elements == nil
    @primary_element, @secondary_element = elements
  end

  def primary_element
    setup_elements if FS_PKMN66::POKEMON_ACTOR_IDS.include?(id)
    return @primary_element
  end

  def secondary_element
    setup_elements if FS_PKMN66::POKEMON_ACTOR_IDS.include?(id)
    return @secondary_element
  end
end

module ArmorMapping
  class << self
    unless method_defined?(:fs_pkm66_mapping_v3)
      alias fs_pkm66_mapping_v3 mapping
    end
    def mapping
      result = fs_pkm66_mapping_v3
      FS_PKMN66::BASE_MAPPING.each do |armor_id, actor_id|
        result[armor_id] = actor_id unless result.has_key?(armor_id)
      end
      return result
    end
  end
end

module EvolutionTable
  remove_const(:DATA) if const_defined?(:DATA)
  DATA = {
    100 => { :level => 16, :next_id => 101 },
    101 => { :level => 32, :next_id => 102 },
    103 => { :level => 16, :next_id => 104 },
    104 => { :level => 36, :next_id => 105 },
    106 => { :level => 16, :next_id => 107 },
    107 => { :level => 36, :next_id => 108 },
    109 => { :level => 7, :next_id => 110 },
    110 => { :level => 10, :next_id => 111 },
    112 => { :level => 7, :next_id => 113 },
    113 => { :level => 10, :next_id => 114 },
    115 => { :level => 18, :next_id => 116 },
    116 => { :level => 36, :next_id => 117 },
    118 => { :level => 20, :next_id => 119 },
    120 => { :level => 20, :next_id => 121 },
    122 => { :level => 22, :next_id => 123 },
    124 => { :level => 30, :next_id => 125 },
    126 => { :level => 22, :next_id => 127 },
    128 => { :level => 30, :next_id => 129 },
    130 => { :level => 30, :next_id => 131 },
    132 => { :level => 22, :next_id => 133 },
    133 => { :level => 40, :next_id => 134 },
    135 => { :level => 21, :next_id => 136 },
    136 => { :level => 36, :next_id => 137 },
    138 => { :level => 24, :next_id => 139 },
    140 => { :level => 31, :next_id => 141 },
    142 => { :level => 33, :next_id => 143 },
    144 => { :level => 28, :next_id => 145 },
    146 => { :level => 32, :next_id => 147 },
    148 => { :level => 25, :next_id => 149 },
    149 => { :level => 36, :next_id => 150 },
    151 => { :level => 16, :next_id => 152 },
    152 => { :level => 36, :next_id => 153 },
    154 => { :level => 28, :next_id => 155 },
    155 => { :level => 40, :next_id => 156 },
    157 => { :level => 30, :next_id => 158 },
    159 => { :level => 25, :next_id => 160 },
    160 => { :level => 40, :next_id => 161 },
    162 => { :level => 40, :next_id => 163 },
    164 => { :level => 30, :next_id => 165 },
    165 => { :level => 45, :next_id => 166 },
    167 => { :level => 31, :next_id => 168 },
    169 => { :level => 38, :next_id => 170 },
    171 => { :level => 25, :next_id => 172 },
    172 => { :level => 40, :next_id => 173 },
    174 => { :level => 26, :next_id => 175 },
    176 => { :level => 30, :next_id => 177 },
    178 => { :level => 28, :next_id => 179 },
    180 => { :level => 40, :next_id => 181 },
    182 => { :level => 40, :next_id => 183 },
    186 => { :level => 15, :next_id => 187 },
    188 => { :level => 22, :next_id => 189 },
    190 => { :level => 20, :next_id => 191 },
    191 => { :level => 40, :next_id => 192 },
    193 => { :level => 38, :next_id => 194 },
    195 => { :level => 30, :next_id => 196 },
    200 => { :level => 30, :next_id => 201 },
    201 => { :level => 55, :next_id => 202 },
    203 => { :level => 14, :next_id => 204 },
    204 => { :level => 36, :next_id => 205 },
    206 => { :level => 25, :next_id => 207 },
    208 => { :level => 24, :next_id => 209 },
    211 => { :level => 32, :next_id => 212 },
    212 => { :level => 48, :next_id => 213 },
    214 => { :level => 30, :next_id => 215 },
    216 => { :level => 35, :next_id => 217 },
    218 => { :level => 37, :next_id => 219 },
    219 => { :level => 50, :next_id => 220 },
    222 => { :level => 30, :next_id => 223 },
    223 => { :level => 50, :next_id => 224 },
    225 => { :level => 20, :next_id => 226 },
    226 => { :level => 45, :next_id => 227 },
    228 => { :level => 42, :next_id => 229 },
    230 => { :level => 20, :next_id => 231 },
    232 => { :level => 27, :next_id => 233 },
    234 => { :level => 31, :next_id => 235 },
    236 => { :level => 24, :next_id => 237 },
    237 => { :level => 48, :next_id => 238 },
    240 => { :level => 24, :next_id => 241 },
    243 => { :level => 20, :next_id => 244 },
    244 => { :level => 40, :next_id => 245 },
  }

  def self.evolve?(actor_id, level, armor_id = nil)
    spec = DATA[actor_id]
    return nil if spec == nil || level < spec[:level]
    return spec[:next_id]
  end
end

module AlbertSummonTemporaryBattle
  class << self
    unless method_defined?(:fs_pkm66_transfer_v3)
      alias fs_pkm66_transfer_v3 transfer_evolution_progress
    end
    def transfer_evolution_progress(old_actor, new_actor)
      hp_rate = old_actor.hp.to_f / [old_actor.maxhp, 1].max
      mp_rate = old_actor.mp.to_f / [old_actor.maxmp, 1].max
      fs_pkm66_transfer_v3(old_actor, new_actor)
      FS_PKMN66.sync_class_skills(new_actor)
      new_actor.setup_elements if new_actor.respond_to?(:setup_elements)
      new_actor.hp = old_actor.hp <= 0 ? 0 : [(new_actor.maxhp * hp_rate).round, 1].max
      new_actor.mp = [(new_actor.maxmp * mp_rate).round, 0].max
    end

    def process_evolution
      return unless defined?(EvolutionTable) && defined?(ArmorMapping)
      return if @summon_entries == nil || @summon_entries.empty?
      updated = ArmorMapping.mapping.dup
      evolved = []
      @summon_entries.each do |entry|
        armor_id, actor_id = entry[0], entry[1]
        next if evolved.include?(actor_id)
        actor = $game_actors[actor_id]
        next if actor == nil
        new_id = EvolutionTable.evolve?(actor_id, actor.level, armor_id)
        next if new_id == nil
        new_actor = $game_actors[new_id]
        next if new_actor == nil
        before_ids = new_actor.skills.compact.map { |s| s.id }
        transfer_evolution_progress(actor, new_actor)
        learned = new_actor.skills.compact.reject { |s| before_ids.include?(s.id) }
        updated[armor_id] = new_id
        evolved << actor_id
        $game_message.texts.push("#{actor.name} 進化成 #{new_actor.name}！")
        learned.each do |skill|
          $game_message.texts.push("#{new_actor.name} 學會 #{skill.name}！")
        end
      end
      ArmorMapping.set_mapping(updated)
    end
  end
end

module AutoBattleAI
  class << self
    unless method_defined?(:fs_pkm66_get_actor_ai_v3)
      alias fs_pkm66_get_actor_ai_v3 get_actor_ai
    end
    def get_actor_ai(actor)
      result = fs_pkm66_get_actor_ai_v3(actor)
      return result unless result == nil
      return FS_PKMN66.default_ai_package(actor)
    end
  end
end

if defined?(BattleFormula_TargetFix)
  ids = BattleFormula_TargetFix::SUMMON_ACTOR_IDS rescue []
  ids = (ids + FS_PKMN66::POKEMON_ACTOR_IDS).uniq
  BattleFormula_TargetFix.send(:remove_const, :SUMMON_ACTOR_IDS) rescue nil
  BattleFormula_TargetFix.const_set(:SUMMON_ACTOR_IDS, ids)
end
if defined?(BattleUtility_IntegrationFix)
  ids = BattleUtility_IntegrationFix::LIFE_LINK_SUMMON_ACTOR_IDS rescue []
  ids = (ids + FS_PKMN66::POKEMON_ACTOR_IDS).uniq
  BattleUtility_IntegrationFix.send(:remove_const, :LIFE_LINK_SUMMON_ACTOR_IDS) rescue nil
  BattleUtility_IntegrationFix.const_set(:LIFE_LINK_SUMMON_ACTOR_IDS, ids)
end
if defined?(SummonGuard) && SummonGuard.const_defined?(:SUMMON_GROUPS)
  groups = SummonGuard::SUMMON_GROUPS
  other = (groups[3] || []) + (groups[4] || [])
  groups[2] = FS_PKMN66::POKEMON_ACTOR_IDS.dup
  groups[1] = (FS_PKMN66::POKEMON_ACTOR_IDS + other).uniq
end

class Game_Interpreter
  def pkm_reset
    FS_PKMN66::BASE_MAPPING.each { |a, id| ArmorMapping.mapping[a] = id }
  end
  def pkm_sync
    ArmorMapping.mapping.each_value do |actor_id|
      actor = $game_actors[actor_id]
      FS_PKMN66.sync_class_skills(actor)
      actor.setup_elements if actor && actor.respond_to?(:setup_elements)
    end
  end
end

#==============================================================================
# END
#==============================================================================