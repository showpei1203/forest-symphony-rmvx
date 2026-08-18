#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 07 States
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 07 States」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、STATES
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：DATA、PRESERVE_IDS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / STATES
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

# ■ FS_MasterSetup 07 States

#------------------------------------------------------------------------------

# RPG Maker VX / RGSS2

# 載入順序：07 / 20

# 分類用途：全部狀態資料與保留 ID

#

# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。

# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。

#==============================================================================



module FS_MASTER_SETUP

  module STATES

    DATA = {

    

        1 => {

    

          :priority => 100,

    

          :restriction => 4,

    

          :hold_turn => 0,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => false,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "",

    

        },

    

        6 => {

    

          :name => "暈厥",

    

          :priority => 330,

    

          :restriction => 4,

    

          :hold_turn => 1,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<control_state>\n<hud_priority:330>\n<hud_show_turns>",

    

        },

    

        13 => {

    

          :name => "消失",

    

          :priority => 999,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_hide>",

    

        },

    

        14 => {

    

          :name => "挑釁",

    

          :priority => 260,

    

          :restriction => 0,

    

          :hold_turn => 2,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:260>\n<hud_show_turns>\n<hud_detail_text:敵方單體技能優先選擇挑釁者>",

    

        },

    

        17 => {

    

          :name => "Wild AI",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_hide>",

    

        },

    

        18 => {

    

          :name => "Healy AI",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_hide>",

    

        },

    

        22 => {

    

          :name => "Protect AI",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_hide>",

    

        },

    

        23 => {

    

          :name => "Support AI",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_hide>",

    

        },

    

        25 => {

    

          :name => "Balanced AI",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_hide>",

    

        },

    

        30 => {

    

          :name => "護衛座標",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 1,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_hide>",

    

        },

    

        31 => {

    

          :name => "中毒",

    

          :priority => 180,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<max stack 5>\n<slip: hp, 0, 1%>\n<capture_bonus: 5>\n<hud_priority:180>\n<hud_detail>",

    

        },

    

        32 => {

    

          :name => "濕潤",

    

          :priority => 150,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<capture_bonus: 3>\n<hud_priority:150>\n<hud_detail_text:雷、麻痺與ATB技能可利用濕潤>",

    

        },

    

        33 => {

    

          :name => "麻痺",

    

          :priority => 300,

    

          :restriction => 4,

    

          :hold_turn => 1,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<control_state>\n<capture_bonus: 10>\n<hud_priority:300>\n<hud_show_turns>",

    

        },

    

        34 => {

    

          :name => "灼燒",

    

          :priority => 170,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 96,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<max stack 3>\n<slip: hp, 0, 1%>\n<capture_bonus: 5>\n<hud_priority:170>\n<hud_detail>",

    

        },

    

        35 => {

    

          :name => "寄生",

    

          :priority => 190,

    

          :restriction => 0,

    

          :hold_turn => 5,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<close effect: 寄生種子>\n<capture_bonus: 5>\n<hud_priority:190>\n<hud_show_turns>\n<hud_detail_text:每次結算吸取MaxHP的1/8，施術者回復>",

    

        },

    

        37 => {

    

          :name => "腐蝕",

    

          :priority => 200,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 92,

    

          :spi_rate => 95,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<max stack 3>\n<capture_bonus: 4>\n<hud_priority:200>\n<hud_detail>",

    

        },

    

        38 => {

    

          :name => "遲緩",

    

          :priority => 170,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 85,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<capture_bonus: 5>\n<hud_priority:170>\n<hud_show_turns>",

    

        },

    

        39 => {

    

          :name => "脆弱",

    

          :priority => 190,

    

          :restriction => 0,

    

          :hold_turn => 2,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<capture_bonus: 5>\n<hud_priority:190>\n<hud_show_turns>",

    

        },

    

        40 => {

    

          :name => "共鳴標記",

    

          :priority => 205,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:205>\n<hud_show_turns>\n<hud_detail_text:喬伊與召喚追擊可利用共鳴標記>",

    

        },

    

        41 => {

    

          :name => "魔力層",

    

          :priority => 240,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<max stack 5>\n<hud_priority:240>\n<hud_detail>\n<hud_detail_text:每層強化米亞部分魔法；部分技能會消耗>",

    

        },

    

        42 => {

    

          :name => "超載",

    

          :priority => 210,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 90,

    

          :spi_rate => 100,

    

          :agi_rate => 120,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:210>\n<hud_show_turns>",

    

        },

    

        44 => {

    

          :name => "根縛",

    

          :priority => 250,

    

          :restriction => 0,

    

          :hold_turn => 2,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 65,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<control_state>\n<capture_bonus: 8>\n<hud_priority:250>\n<hud_show_turns>",

    

        },

    

        45 => {

    

          :name => "封鎖網",

    

          :priority => 270,

    

          :restriction => 4,

    

          :hold_turn => 1,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<control_state>\n<hud_priority:270>\n<hud_show_turns>",

    

        },

    

        46 => {

    

          :name => "睡眠",

    

          :priority => 300,

    

          :restriction => 4,

    

          :hold_turn => 2,

    

          :auto_release_prob => 100,

    

          :release_by_damage => true,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<control_state>\n<capture_bonus: 12>\n<hud_priority:300>\n<hud_show_turns>",

    

        },

    

        47 => {

    

          :name => "冰凍",

    

          :priority => 310,

    

          :restriction => 4,

    

          :hold_turn => 1,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<control_state>\n<capture_bonus: 12>\n<hud_priority:310>\n<hud_show_turns>",

    

        },

    

        48 => {

    

          :name => "盲目",

    

          :priority => 180,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hit -25>\n<hud_priority:180>\n<hud_show_turns>",

    

        },

    

        49 => {

    

          :name => "暈眩",

    

          :priority => 330,

    

          :restriction => 4,

    

          :hold_turn => 1,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<control_state>\n<capture_bonus: 10>\n<hud_priority:330>\n<hud_show_turns>",

    

        },

    

        50 => {

    

          :name => "破勢",

    

          :priority => 280,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<max stack 15>\n<hud_priority:280>\n<hud_detail>",

    

        },

    

        51 => {

    

          :name => "崩防",

    

          :priority => 350,

    

          :restriction => 0,

    

          :hold_turn => 2,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 75,

    

          :spi_rate => 80,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<capture_bonus: 8>\n<hud_priority:350>\n<hud_show_turns>",

    

        },

    

        52 => {

    

          :name => "魔法盾",

    

          :priority => 260,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<mana_shield 500:50>\n<hud_priority:260>\n<hud_detail>",

    

        },

    

        53 => {

    

          :name => "生命共同體",

    

          :priority => 260,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<react effect: 生命共同體>\n<hud_priority:260>\n<hud_show_turns>",

    

        },

    

        54 => {

    

          :name => "攻擊提升",

    

          :priority => 100,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 120,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => true,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [58],

    

          :note => "",

    

        },

    

        55 => {

    

          :name => "防禦提升",

    

          :priority => 100,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 120,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => true,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [59],

    

          :note => "",

    

        },

    

        56 => {

    

          :name => "精神提升",

    

          :priority => 100,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 120,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => true,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [60],

    

          :note => "",

    

        },

    

        57 => {

    

          :name => "速度提升",

    

          :priority => 100,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 120,

    

          :nonresistance => false,

    

          :offset_by_opposite => true,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [61],

    

          :note => "",

    

        },

    

        58 => {

    

          :name => "攻擊降低",

    

          :priority => 100,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 80,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => true,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [54],

    

          :note => "",

    

        },

    

        59 => {

    

          :name => "防禦降低",

    

          :priority => 100,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 80,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => true,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [55],

    

          :note => "",

    

        },

    

        60 => {

    

          :name => "精神降低",

    

          :priority => 100,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 80,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => true,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [56],

    

          :note => "",

    

        },

    

        61 => {

    

          :name => "速度降低",

    

          :priority => 100,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 80,

    

          :nonresistance => false,

    

          :offset_by_opposite => true,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [57],

    

          :note => "",

    

        },

    

        62 => {

    

          :name => "會心提升",

    

          :priority => 150,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<cri +10>",

    

        },

    

        64 => {

    

          :name => "再生",

    

          :priority => 150,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<slip: hp, 0, -5%>",

    

        },

    

        65 => {

    

          :name => "魔力再生",

    

          :priority => 150,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<slip: mp, 0, -4%>",

    

        },

    

        67 => {

    

          :name => "恐懼",

    

          :priority => 180,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 85,

    

          :def_rate => 100,

    

          :spi_rate => 90,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:180>\n<hud_show_turns>",

    

        },

    

        69 => {

    

          :name => "弱點暴露",

    

          :priority => 210,

    

          :restriction => 0,

    

          :hold_turn => 2,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 88,

    

          :spi_rate => 88,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:210>\n<hud_show_turns>",

    

        },

    

        70 => {

    

          :name => "狂暴",

    

          :priority => 260,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 125,

    

          :def_rate => 90,

    

          :spi_rate => 100,

    

          :agi_rate => 110,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:260>\n<hud_show_turns>",

    

        },

    

        71 => {

    

          :name => "混亂",

    

          :priority => 280,

    

          :restriction => 3,

    

          :hold_turn => 2,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<control_state>\n<hud_priority:280>\n<hud_show_turns>",

    

        },

    

        72 => {

    

          :name => "守住",

    

          :priority => 400,

    

          :restriction => 0,

    

          :hold_turn => 1,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:400>\n<hud_show_turns>\n<hud_detail_text:本次行動週期阻擋敵方效果>",

    

        },

    

        74 => {

    

          :name => "召喚獵殺標記",

    

          :priority => 220,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:220>\n<hud_show_turns>\n<hud_detail_text:敵方會優先獵殺被標記的召喚物>",

    

        },

    

        75 => {

    

          :name => "蓄力預告",

    

          :priority => 500,

    

          :restriction => 0,

    

          :hold_turn => 2,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:500>\n<hud_show_turns>\n<hud_detail_text:Boss 正在準備高威力技能；可用 ATB 打斷>",

    

        },

    

        76 => {

    

          :name => "狂怒階段",

    

          :priority => 450,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 125,

    

          :def_rate => 100,

    

          :spi_rate => 120,

    

          :agi_rate => 110,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:450>\n<hud_detail>\n<hud_detail_text:Boss進入狂怒階段>",

    

        },

    

        77 => {

    

          :name => "相位護盾",

    

          :priority => 420,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<mana_shield 3000:60>\n<hud_priority:420>\n<hud_detail>\n<hud_detail_text:先破壞護盾或指定核心>",

    

        },

    

        82 => {

    

          :name => "疲憊",

    

          :priority => 180,

    

          :restriction => 0,

    

          :hold_turn => 2,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 85,

    

          :def_rate => 100,

    

          :spi_rate => 85,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:180>\n<hud_show_turns>",

    

        },

    

        84 => {

    

          :name => "庇護顯示",

    

          :priority => 300,

    

          :restriction => 0,

    

          :hold_turn => 2,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:300>\n<hud_show_turns>",

    

        },

    

        85 => {

    

          :name => "痛苦熔爐",

    

          :priority => 290,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<store_cover_damage:150>\n<cover_store_cap_percent:300>\n<hud_priority:290>\n<hud_detail>",

    

        },

    

        86 => {

    

          :name => "毒華專精",

    

          :priority => 120,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 110,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<cc_od_state_stack:60>\n<hud_priority:120>",

    

        },

    

        87 => {

    

          :name => "療癒共振",

    

          :priority => 120,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<cc_od_overheal_percent:4>\n<hud_priority:120>",

    

        },

    

        88 => {

    

          :name => "靜電場",

    

          :priority => 120,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<cc_od_atb_per_10:40>\n<hud_priority:120>",

    

        },

    

        89 => {

    

          :name => "共鳴和聲",

    

          :priority => 120,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<cc_od_summon_action:80>\n<hud_priority:120>",

    

        },

    

        90 => {

    

          :name => "裂甲",

    

          :priority => 215,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 88,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:215>\n<hud_show_turns>\n<hud_detail_text:映體泰勒可利用並終結裂甲>",

    

        },

    

        91 => {

    

          :name => "映體不穩定",

    

          :priority => 230,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 95,

    

          :def_rate => 100,

    

          :spi_rate => 95,

    

          :agi_rate => 95,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<max stack 3>\n<hud_priority:230>\n<hud_detail>\n<hud_detail_text:每層降低ATK/SPI/AGI約5%>",

    

        },

    

        120 => {

    

          :name => "觀律累積",

    

          :priority => 380,

    

          :restriction => 0,

    

          :hold_turn => 5,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<max stack 5>\n<hud_priority:380>\n<hud_detail>\n<hud_detail_text:重複同技能或同屬性會累積；高層可能觸發觀律處刑>",

    

        },

    

        121 => {

    

          :name => "雙弦標記",

    

          :priority => 430,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:430>\n<hud_show_turns>\n<hud_detail>\n<hud_detail_text:與另一名雙弦對象連結；一方HP損失會按比例傳給另一方>",

    

        },

    

        122 => {

    

          :name => "烈日核心",

    

          :priority => 410,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:410>\n<hud_detail>\n<hud_detail_text:烈日運行；固拉多將使用地面與火焰強化行動>",

    

        },

    

        123 => {

    

          :name => "暴雨核心",

    

          :priority => 410,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:410>\n<hud_detail>\n<hud_detail_text:暴雨運行；蓋歐卡將使用水流與雷擊強化行動>",

    

        },

    

        124 => {

    

          :name => "亂流核心",

    

          :priority => 420,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:420>\n<hud_detail>\n<hud_detail_text:天空亂流；烈空座的速度與追擊壓力提高>",

    

        },

    

        125 => {

    

          :name => "原始陸地",

    

          :priority => 520,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 110,

    

          :def_rate => 115,

    

          :spi_rate => 100,

    

          :agi_rate => 105,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:520>\n<hud_detail>\n<hud_detail_text:固拉多進入原始陸地階段>",

    

        },

    

        126 => {

    

          :name => "始源之海",

    

          :priority => 520,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 110,

    

          :spi_rate => 110,

    

          :agi_rate => 105,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:520>\n<hud_detail>\n<hud_detail_text:蓋歐卡進入始源之海階段>",

    

        },

    

        127 => {

    

          :name => "德爾塔氣流",

    

          :priority => 540,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 105,

    

          :def_rate => 100,

    

          :spi_rate => 105,

    

          :agi_rate => 115,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:540>\n<hud_detail>\n<hud_detail_text:烈空座進入德爾塔氣流階段>",

    

        },

    

        128 => {

    

          :name => "機械過熱",

    

          :priority => 460,

    

          :restriction => 0,

    

          :hold_turn => 4,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 120,

    

          :def_rate => 90,

    

          :spi_rate => 120,

    

          :agi_rate => 115,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:460>\n<hud_show_turns>\n<hud_detail_text:輸出提高但核心防禦下降>",

    

        },

    

        129 => {

    

          :name => "核心暴露",

    

          :priority => 560,

    

          :restriction => 0,

    

          :hold_turn => 2,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 70,

    

          :spi_rate => 70,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:560>\n<hud_show_turns>\n<hud_detail_text:核心暴露；優先集中輸出>",

    

        },

    

        130 => {

    

          :name => "孤譜・喬伊改譜",

    

          :priority => 320,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 90,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:320>\n<hud_show_turns>\n<hud_detail_text:孤譜・喬伊改譜生效>\n<MAXMP 85%>",

    

        },

    

        131 => {

    

          :name => "逆憶・米亞改譜",

    

          :priority => 320,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 80,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<slip: mp, 0, 3%>\n<hud_priority:320>\n<hud_show_turns>\n<hud_detail_text:逆憶・米亞改譜生效>",

    

        },

    

        132 => {

    

          :name => "遲頻・艾卓改譜",

    

          :priority => 320,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 75,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:320>\n<hud_show_turns>\n<hud_detail_text:遲頻・艾卓改譜生效>",

    

        },

    

        133 => {

    

          :name => "淨白・維娜改譜",

    

          :priority => 320,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 85,

    

          :agi_rate => 90,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:320>\n<hud_show_turns>\n<hud_detail_text:淨白・維娜改譜生效>",

    

        },

    

        134 => {

    

          :name => "裂甲・艾薇改譜",

    

          :priority => 340,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 80,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:340>\n<hud_show_turns>\n<hud_detail_text:裂甲・艾薇改譜生效>\n<MAXHP 90%>",

    

        },

    

        135 => {

    

          :name => "鈍裂・泰勒改譜",

    

          :priority => 320,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 80,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<cri -5>\n<hud_priority:320>\n<hud_show_turns>\n<hud_detail_text:鈍裂・泰勒改譜生效>",

    

        },

    

        139 => {

    

          :name => "空白改譜",

    

          :priority => 260,

    

          :restriction => 0,

    

          :hold_turn => 3,

    

          :auto_release_prob => 100,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 92,

    

          :def_rate => 92,

    

          :spi_rate => 92,

    

          :agi_rate => 92,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:260>\n<hud_show_turns>\n<hud_detail_text:未被個別識別的存在遭到統一改譜>",

    

        },

    

        140 => {

    

          :name => "第一律・觀測律",

    

          :priority => 500,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:500>\n<hud_detail>\n<hud_detail_text:第一律：觀律與偏差處刑優先>",

    

        },

    

        141 => {

    

          :name => "第二律・鎮壓律",

    

          :priority => 500,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:500>\n<hud_detail>\n<hud_detail_text:第二律：雙弦、ATB與召喚壓制優先>",

    

        },

    

        142 => {

    

          :name => "第三律・改譜律",

    

          :priority => 500,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:500>\n<hud_detail>\n<hud_detail_text:第三律：改譜與角色專屬弱化優先>",

    

        },

    

        143 => {

    

          :name => "第四律・歸一律",

    

          :priority => 520,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:520>\n<hud_detail>\n<hud_detail_text:第四律：全體高壓與終結技能優先>",

    

        },

    

        150 => {

    

          :name => "全知儀",

    

          :priority => 600,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:600>\n<hud_detail>\n<hud_detail_text:全知儀啟動；主要角色重複技能與屬性會被觀測>",

    

        },

    

        151 => {

    

          :name => "大諧律",

    

          :priority => 650,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:650>\n<hud_detail>\n<hud_detail_text:Boss每若干有效行動切換法則>",

    

        },

    

        152 => {

    

          :name => "失奏",

    

          :priority => 700,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 115,

    

          :def_rate => 100,

    

          :spi_rate => 115,

    

          :agi_rate => 115,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<hud_priority:700>\n<hud_detail>\n<hud_detail_text:大諧律崩解；賽勒斯進入失奏階段>",

    

        },

    

        153 => {

    

          :name => "烈日場域",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<field_weather>\n<field_priority:10>\n<field_damage 13:+25>\n<field_damage 14:-25>\n<hud_hide>",

    

        },

    

        154 => {

    

          :name => "暴雨場域",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<field_weather>\n<field_priority:10>\n<field_damage 14:+25>\n<field_damage 13:-25>\n<hud_hide>",

    

        },

    

        155 => {

    

          :name => "亂流場域",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<field_weather>\n<field_priority:10>\n<field_damage 6:+15>\n<field_damage 19:+15>\n<hud_hide>",

    

        },

    

        156 => {

    

          :name => "原始陸地場域",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<field_weather>\n<field_priority:20>\n<field_damage 8:+35>\n<field_damage 13:+35>\n<field_damage 14:-60>\n<hud_hide>",

    

        },

    

        157 => {

    

          :name => "始源之海場域",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<field_weather>\n<field_priority:20>\n<field_damage 14:+35>\n<field_damage 16:+20>\n<field_damage 13:-60>\n<hud_hide>",

    

        },

    

        158 => {

    

          :name => "德爾塔氣流場域",

    

          :priority => 0,

    

          :restriction => 0,

    

          :hold_turn => 99,

    

          :auto_release_prob => 0,

    

          :release_by_damage => false,

    

          :battle_only => true,

    

          :atk_rate => 100,

    

          :def_rate => 100,

    

          :spi_rate => 100,

    

          :agi_rate => 100,

    

          :nonresistance => false,

    

          :offset_by_opposite => false,

    

          :reduce_hit_ratio => false,

    

          :slip_damage => false,

    

          :state_set => [],

    

          :note => "<field_weather>\n<field_priority:20>\n<field_damage 6:+30>\n<field_damage 19:+30>\n<field_target_type_damage 9,flying:-25>\n<field_target_type_damage 16,flying:-25>\n<field_target_type_damage 18,flying:-25>\n<hud_hide>",

    

        },

    

      }



    PRESERVE_IDS = [2, 3, 36]



  end

end



