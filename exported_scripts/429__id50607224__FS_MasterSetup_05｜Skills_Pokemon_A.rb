#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 05 Skills Pokemon A
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 05 Skills Pokemon A」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、SKILLS
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / SKILLS POKEMON A
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
# ■ FS_MasterSetup 05 Skills Pokemon A
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：05 / 20
# 分類用途：一般寶可夢技能前半（ID 600～674）
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP
  module SKILLS
    DATA.merge!({
        600 => {
    
          :name => "藤鞭",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 130,
    
          :variance => 15,
    
          :atk_f => 160,
    
          :spi_f => 0,
    
          :mp_cost => 7,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [15],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        601 => {
    
          :name => "毒粉",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 75,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 31:40>\n<ai_prefer_stack_below 31:5>\n<cannot level>",
    
        },
    

        602 => {
    
          :name => "寄生種子",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 90,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [15],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 35:40>\n<cannot level>",
    
        },
    

        604 => {
    
          :name => "催眠粉",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 80,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [15],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 46:35>\n<cannot level>",
    
        },
    

        605 => {
    
          :name => "終極吸取",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 190,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 188,
    
          :mp_cost => 11,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => true,
    
          :ignore_defense => false,
    
          :element_set => [15],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<bonus_vs_state 35:25>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        606 => {
    
          :name => "日光束",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 280,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 228,
    
          :mp_cost => 15,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [15],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<bonus_vs_state 51:35>\n<ai_bonus_vs_state 51:50>\n<ricarica turni:2>\n<max level 2>\n<level dmg all:+12%>\n<level 1 jp cost:3000>\n<level 2 jp cost:8000>",
    
        },
    

        607 => {
    
          :name => "抓",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 120,
    
          :variance => 15,
    
          :atk_f => 156,
    
          :spi_f => 0,
    
          :mp_cost => 7,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        608 => {
    
          :name => "火花",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 120,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 156,
    
          :mp_cost => 7,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [13],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 34:18>\n<ai_prefer_stack_below 34:3>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        610 => {
    
          :name => "劈開",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 180,
    
          :variance => 15,
    
          :atk_f => 183,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<crit_rate:10>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        611 => {
    
          :name => "鬼面",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 61:55>\n<atb_shift:-10>\n<cannot level>",
    
        },
    

        612 => {
    
          :name => "噴射火焰",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 220,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 201,
    
          :mp_cost => 12,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [13],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 34:20>\n<ai_prefer_stack_below 34:3>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        613 => {
    
          :name => "翅膀攻擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 160,
    
          :variance => 15,
    
          :atk_f => 174,
    
          :spi_f => 0,
    
          :mp_cost => 9,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [6],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<crit_rate:5>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        614 => {
    
          :name => "龍爪",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 200,
    
          :variance => 15,
    
          :atk_f => 192,
    
          :spi_f => 0,
    
          :mp_cost => 11,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [19],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        615 => {
    
          :name => "大字爆炎",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 260,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 219,
    
          :mp_cost => 14,
    
          :hit => 85,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [13],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 34:25>\n<ai_prefer_stack_below 34:3>\n<max level 2>\n<level dmg all:+12%>\n<level 1 jp cost:3000>\n<level 2 jp cost:8000>",
    
        },
    

        616 => {
    
          :name => "撞擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 120,
    
          :variance => 15,
    
          :atk_f => 156,
    
          :spi_f => 0,
    
          :mp_cost => 7,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        617 => {
    
          :name => "水槍",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 120,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 156,
    
          :mp_cost => 7,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [14],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 32:20>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        618 => {
    
          :name => "守住",
    
          :scope => 11,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [72],
    
          :minus_state_set => [],
    
          :note => "<ricarica turni:3>\n<cannot level>",
    
        },
    

        619 => {
    
          :name => "咬住",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 160,
    
          :variance => 15,
    
          :atk_f => 174,
    
          :spi_f => 0,
    
          :mp_cost => 9,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [20],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 67:18>\n<state_chance 49:30>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        620 => {
    
          :name => "泡沫光線",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 170,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 178,
    
          :mp_cost => 9,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [14],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 32:25>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        621 => {
    
          :name => "衝浪",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 220,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 201,
    
          :mp_cost => 12,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [14],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 32:25>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        622 => {
    
          :name => "冰凍光束",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 220,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 201,
    
          :mp_cost => 12,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [18],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 47:8>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        623 => {
    
          :name => "水炮",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 260,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 219,
    
          :mp_cost => 14,
    
          :hit => 80,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [14],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 32:30>\n<max level 2>\n<level dmg all:+12%>\n<level 1 jp cost:3000>\n<level 2 jp cost:8000>",
    
        },
    

        624 => {
    
          :name => "連斬",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 120,
    
          :variance => 15,
    
          :atk_f => 156,
    
          :spi_f => 0,
    
          :mp_cost => 7,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [10],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        625 => {
    
          :name => "銀色旋風",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 160,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 174,
    
          :mp_cost => 9,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [10],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        626 => {
    
          :name => "揮指",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 180,
    
          :variance => 20,
    
          :atk_f => 100,
    
          :spi_f => 100,
    
          :mp_cost => 14,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<bonus_per_target_state:10>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        627 => {
    
          :name => "超級角擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 280,
    
          :variance => 15,
    
          :atk_f => 228,
    
          :spi_f => 0,
    
          :mp_cost => 15,
    
          :hit => 85,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [10],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<bonus_vs_state 51:35>\n<ai_bonus_vs_state 51:50>\n<max level 2>\n<level dmg all:+12%>\n<level 1 jp cost:3000>\n<level 2 jp cost:8000>",
    
        },
    

        628 => {
    
          :name => "信號光束",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 190,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 188,
    
          :mp_cost => 11,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [10],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 71:10>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        631 => {
    
          :name => "劇毒牙",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 140,
    
          :variance => 15,
    
          :atk_f => 165,
    
          :spi_f => 0,
    
          :mp_cost => 8,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 31:30>\n<ai_prefer_stack_below 31:5>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        632 => {
    
          :name => "劇毒",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 90,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 31:55>\n<ai_prefer_stack_below 31:5>\n<cannot level>",
    
        },
    

        633 => {
    
          :name => "吸血",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 200,
    
          :variance => 15,
    
          :atk_f => 192,
    
          :spi_f => 0,
    
          :mp_cost => 11,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => true,
    
          :ignore_defense => false,
    
          :element_set => [10],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        634 => {
    
          :name => "啄",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 110,
    
          :variance => 15,
    
          :atk_f => 152,
    
          :spi_f => 0,
    
          :mp_cost => 7,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [6],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        636 => {
    
          :name => "燕返",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 160,
    
          :variance => 15,
    
          :atk_f => 174,
    
          :spi_f => 0,
    
          :mp_cost => 9,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [6],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<crit_rate:5>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        637 => {
    
          :name => "羽毛舞",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [6],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 58:60>\n<cannot level>",
    
        },
    

        639 => {
    
          :name => "電光一閃",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 120,
    
          :variance => 15,
    
          :atk_f => 156,
    
          :spi_f => 0,
    
          :mp_cost => 7,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        640 => {
    
          :name => "咬碎",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 200,
    
          :variance => 15,
    
          :atk_f => 192,
    
          :spi_f => 0,
    
          :mp_cost => 11,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [20],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 67:18>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        641 => {
    
          :name => "憤怒門牙",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 180,
    
          :variance => 15,
    
          :atk_f => 150,
    
          :spi_f => 0,
    
          :mp_cost => 3,
    
          :hit => 90,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pen_rate:35>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        642 => {
    
          :name => "捨身衝撞",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 280,
    
          :variance => 15,
    
          :atk_f => 228,
    
          :spi_f => 0,
    
          :mp_cost => 15,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<bonus_vs_state 51:35>\n<ai_bonus_vs_state 51:50>\n<max level 2>\n<level dmg all:+12%>\n<level 1 jp cost:3000>\n<level 2 jp cost:8000>",
    
        },
    

        643 => {
    
          :name => "啄鑽",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 200,
    
          :variance => 15,
    
          :atk_f => 192,
    
          :spi_f => 0,
    
          :mp_cost => 11,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [6],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<crit_rate:5>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        644 => {
    
          :name => "溶解液",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 120,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 156,
    
          :mp_cost => 7,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 31:20>\n<state_chance 37:25>\n<ai_bonus_vs_state 31:35>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        645 => {
    
          :name => "污泥炸彈",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 220,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 201,
    
          :mp_cost => 12,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 31:30>\n<state_chance 37:20>\n<ai_bonus_vs_state 31:40>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        646 => {
    
          :name => "大蛇瞪眼",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 33:45>\n<cannot level>",
    
        },
    

        649 => {
    
          :name => "電磁波",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 95,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 33:45>\n<cannot level>",
    
        },
    

        650 => {
    
          :name => "打雷",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 260,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 219,
    
          :mp_cost => 14,
    
          :hit => 70,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 33:30>\n<state_chance_vs_state 33,32:30>\n<ai_bonus_vs_state 32:60>\n<max level 2>\n<level dmg all:+12%>\n<level 1 jp cost:3000>\n<level 2 jp cost:8000>",
    
        },
    

        651 => {
    
          :name => "十萬伏特",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 220,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 201,
    
          :mp_cost => 12,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 33:20>\n<state_chance_vs_state 33,32:25>\n<ai_bonus_vs_state 32:50>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        652 => {
    
          :name => "骨棒",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 170,
    
          :variance => 15,
    
          :atk_f => 178,
    
          :spi_f => 0,
    
          :mp_cost => 9,
    
          :hit => 85,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [8],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<break_power:1>\n<break_state:50>\n<broken_state:51>\n<state_chance 49:10>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        653 => {
    
          :name => "泥巴射擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 150,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 170,
    
          :mp_cost => 9,
    
          :hit => 95,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [8],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        654 => {
    
          :name => "劈瓦",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 190,
    
          :variance => 15,
    
          :atk_f => 188,
    
          :spi_f => 0,
    
          :mp_cost => 11,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [5],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<break_power:1>\n<break_state:50>\n<broken_state:51>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        655 => {
    
          :name => "地震",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 240,
    
          :variance => 15,
    
          :atk_f => 210,
    
          :spi_f => 0,
    
          :mp_cost => 13,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [8],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<break_power:2>\n<break_state:50>\n<broken_state:51>\n<max level 2>\n<level dmg all:+12%>\n<level 1 jp cost:3000>\n<level 2 jp cost:8000>",
    
        },
    

        656 => {
    
          :name => "挖洞",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 200,
    
          :variance => 15,
    
          :atk_f => 192,
    
          :spi_f => 0,
    
          :mp_cost => 11,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [8],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<break_power:1>\n<break_state:50>\n<broken_state:51>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        657 => {
    
          :name => "沙暴",
    
          :scope => 8,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [9],
    
          :plus_state_set => [55],
    
          :minus_state_set => [],
    
          :note => "<cannot level>",
    
        },
    

        658 => {
    
          :name => "污泥攻擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 170,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 178,
    
          :mp_cost => 9,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 31:30>\n<ai_prefer_stack_below 31:5>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        659 => {
    
          :name => "祈願",
    
          :scope => 7,
    
          :occasion => 1,
    
          :base_damage => -220,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 200,
    
          :mp_cost => 14,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<cannot level>",
    
        },
    

        660 => {
    
          :name => "撒嬌",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [21],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 58:60>\n<cannot level>",
    
        },
    

        661 => {
    
          :name => "三重攻擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 200,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 192,
    
          :mp_cost => 11,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        662 => {
    
          :name => "火焰輪",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 160,
    
          :variance => 15,
    
          :atk_f => 174,
    
          :spi_f => 0,
    
          :mp_cost => 9,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [13],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 34:22>\n<ai_prefer_stack_below 34:3>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        663 => {
    
          :name => "鬼火",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 85,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [13],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 34:50>\n<ai_prefer_stack_below 34:3>\n<cannot level>",
    
        },
    

        665 => {
    
          :name => "奇異之光",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [11],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 71:35>\n<cannot level>",
    
        },
    

        666 => {
    
          :name => "唱歌",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 65,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 46:30>\n<cannot level>",
    
        },
    

        667 => {
    
          :name => "泰山壓頂",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 210,
    
          :variance => 15,
    
          :atk_f => 196,
    
          :spi_f => 0,
    
          :mp_cost => 11,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 33:25>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        669 => {
    
          :name => "蘑菇孢子",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [15],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 46:50>\n<cannot level>",
    
        },
    

        670 => {
    
          :name => "念力",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 140,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 165,
    
          :mp_cost => 8,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<atb_shift:-6>\n<state_chance 71:8>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        671 => {
    
          :name => "定身法",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 45:50>\n<cannot level>",
    
        },
    

        672 => {
    
          :name => "攀瀑",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 200,
    
          :variance => 15,
    
          :atk_f => 192,
    
          :spi_f => 0,
    
          :mp_cost => 11,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [14],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 32:25>\n<state_chance 49:15>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        673 => {
    
          :name => "求雨",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [14],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 32:35>\n<cannot level>",
    
        },
    

        674 => {
    
          :name => "空手劈",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 140,
    
          :variance => 15,
    
          :atk_f => 165,
    
          :spi_f => 0,
    
          :mp_cost => 8,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [5],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<crit_rate:10>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

      })
  end
end
