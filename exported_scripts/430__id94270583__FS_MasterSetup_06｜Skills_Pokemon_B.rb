#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 06 Skills Pokemon B
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 06 Skills Pokemon B」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、SKILLS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：BALANCE_OVERRIDES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / SKILLS POKEMON B
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
# ■ FS_MasterSetup 06 Skills Pokemon B
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：06 / 20
# 分類用途：一般寶可夢技能後半（ID 675～771）與技能平衡覆寫
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP
  module SKILLS
    DATA.merge!({
        676 => {
    
          :name => "聚氣",
    
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
    
          :plus_state_set => [62],
    
          :minus_state_set => [],
    
          :note => "<cannot level>",
    
        },
    

        677 => {
    
          :name => "十字劈",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 240,
    
          :variance => 15,
    
          :atk_f => 210,
    
          :spi_f => 0,
    
          :mp_cost => 13,
    
          :hit => 80,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [5],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<break_power:2>\n<break_state:50>\n<broken_state:51>\n<crit_rate:10>\n<max level 2>\n<level dmg all:+12%>\n<level 1 jp cost:3000>\n<level 2 jp cost:8000>",
    
        },
    

        678 => {
    
          :name => "大鬧一番",
    
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
    

        679 => {
    
          :name => "神速",
    
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
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        680 => {
    
          :name => "催眠術",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 70,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 46:35>\n<cannot level>",
    
        },
    

        681 => {
    
          :name => "冰凍之風",
    
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
    
          :element_set => [18],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 38:35>\n<atb_shift:-8>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        682 => {
    
          :name => "預知未來",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 320,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 250,
    
          :mp_cost => 15,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<atb_shift:-10>\n<bonus_if_target_atb_above 70:30>\n<ricarica turni:3>\n<max level 2>\n<level dmg all:+10%>\n<level 1 jp cost:5000>\n<level 2 jp cost:12000>",
    
        },
    

        683 => {
    
          :name => "幻象光線",
    
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
    
          :element_set => [17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<atb_shift:-8>\n<state_chance 71:10>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        684 => {
    
          :name => "自我再生",
    
          :scope => 11,
    
          :occasion => 1,
    
          :base_damage => -240,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 220,
    
          :mp_cost => 12,
    
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
    

        685 => {
    
          :name => "冥想",
    
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
    
          :element_set => [17],
    
          :plus_state_set => [56, 65],
    
          :minus_state_set => [],
    
          :note => "<cannot level>",
    
        },
    

        686 => {
    
          :name => "精神強念",
    
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
    
          :element_set => [17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<atb_shift:-10>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        687 => {
    
          :name => "健美",
    
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
    
          :element_set => [5],
    
          :plus_state_set => [54, 55],
    
          :minus_state_set => [],
    
          :note => "<cannot level>",
    
        },
    

        688 => {
    
          :name => "爆裂拳",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 240,
    
          :variance => 15,
    
          :atk_f => 210,
    
          :spi_f => 0,
    
          :mp_cost => 13,
    
          :hit => 50,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [5],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<break_power:2>\n<break_state:50>\n<broken_state:51>\n<state_chance 71:35>\n<max level 2>\n<level dmg all:+12%>\n<level 1 jp cost:3000>\n<level 2 jp cost:8000>",
    
        },
    

        690 => {
    
          :name => "超音波",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 70,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 71:30>\n<cannot level>",
    
        },
    

        691 => {
    
          :name => "落石",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 140,
    
          :variance => 15,
    
          :atk_f => 165,
    
          :spi_f => 0,
    
          :mp_cost => 8,
    
          :hit => 90,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [9],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        693 => {
    
          :name => "震級",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 60,
    
          :variance => 15,
    
          :atk_f => 120,
    
          :spi_f => 0,
    
          :mp_cost => 3,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [8],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        695 => {
    
          :name => "踩踏",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 170,
    
          :variance => 15,
    
          :atk_f => 178,
    
          :spi_f => 0,
    
          :mp_cost => 9,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 49:20>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        697 => {
    
          :name => "電擊",
    
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
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 33:22>\n<state_chance_vs_state 33,32:25>\n<ai_bonus_vs_state 32:50>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        698 => {
    
          :name => "金屬爪",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 140,
    
          :variance => 15,
    
          :atk_f => 165,
    
          :spi_f => 0,
    
          :mp_cost => 8,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        700 => {
    
          :name => "溶化",
    
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
    
          :element_set => [7],
    
          :plus_state_set => [55],
    
          :minus_state_set => [],
    
          :note => "<cannot level>",
    
        },
    

        701 => {
    
          :name => "暗影球",
    
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
    
          :element_set => [11],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 39:20>\n<bonus_per_target_state:8>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        702 => {
    
          :name => "舌舔",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 100,
    
          :variance => 15,
    
          :atk_f => 147,
    
          :spi_f => 0,
    
          :mp_cost => 6,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [11],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 39:15>\n<state_chance 33:20>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        704 => {
    
          :name => "刺耳聲",
    
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
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 59:55>\n<state_chance 39:20>\n<cannot level>",
    
        },
    

        705 => {
    
          :name => "光牆",
    
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
    
          :element_set => [17],
    
          :plus_state_set => [56],
    
          :minus_state_set => [],
    
          :note => "<cannot level>",
    
        },
    

        706 => {
    
          :name => "頭錘",
    
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
    
          :note => "<state_chance 49:20>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        707 => {
    
          :name => "骨頭回力鏢",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 140,
    
          :variance => 15,
    
          :atk_f => 165,
    
          :spi_f => 0,
    
          :mp_cost => 8,
    
          :hit => 90,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [8],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        709 => {
    
          :name => "岩崩",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 190,
    
          :variance => 15,
    
          :atk_f => 188,
    
          :spi_f => 0,
    
          :mp_cost => 11,
    
          :hit => 90,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [9],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<break_power:1>\n<break_state:50>\n<broken_state:51>\n<state_chance 49:20>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        710 => {
    
          :name => "生蛋",
    
          :scope => 7,
    
          :occasion => 1,
    
          :base_damage => -240,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 220,
    
          :mp_cost => 12,
    
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
    

        715 => {
    
          :name => "原始之力",
    
          :scope => 1,
    
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
    
          :element_set => [9],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        718 => {
    
          :name => "龍息",
    
          :scope => 1,
    
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
    
          :element_set => [19],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 33:30>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        720 => {
    
          :name => "變身",
    
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
    
          :plus_state_set => [54, 56, 57],
    
          :minus_state_set => [],
    
          :note => "<ricarica turni:4>\n<cannot level>",
    
        },
    

        722 => {
    
          :name => "幫助",
    
          :scope => 7,
    
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
    
          :plus_state_set => [54, 56],
    
          :minus_state_set => [],
    
          :note => "<cannot level>",
    
        },
    

        724 => {
    
          :name => "巨聲",
    
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
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        725 => {
    
          :name => "起風",
    
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
    
          :element_set => [6],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        726 => {
    
          :name => "蛛網",
    
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
    
          :element_set => [10],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 44:60>\n<cannot level>",
    
        },
    

        728 => {
    
          :name => "暗影拳",
    
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
    
          :element_set => [11],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 39:20>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        729 => {
    
          :name => "撒菱",
    
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
    
          :element_set => [8],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 39:35>\n<cannot level>",
    
        },
    

        730 => {
    
          :name => "鋼翼",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 180,
    
          :variance => 15,
    
          :atk_f => 183,
    
          :spi_f => 0,
    
          :mp_cost => 10,
    
          :hit => 90,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<break_power:1>\n<break_state:50>\n<broken_state:51>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        731 => {
    
          :name => "大爆炸",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 520,
    
          :variance => 15,
    
          :atk_f => 300,
    
          :spi_f => 0,
    
          :mp_cost => 28,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<bonus_vs_state 51:35>\n<ai_bonus_vs_state 51:50>\n<max level 2>\n<level dmg all:+10%>\n<level 1 jp cost:5000>\n<level 2 jp cost:12000>\n<fs_user_add_state:82>",
    
        },
    

        732 => {
    
          :name => "鐵尾",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 240,
    
          :variance => 15,
    
          :atk_f => 210,
    
          :spi_f => 0,
    
          :mp_cost => 13,
    
          :hit => 75,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<break_power:2>\n<break_state:50>\n<broken_state:51>\n<max level 2>\n<level dmg all:+12%>\n<level 1 jp cost:3000>\n<level 2 jp cost:8000>",
    
        },
    

        735 => {
    
          :name => "細雪",
    
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
    
          :element_set => [18],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 47:8>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        736 => {
    
          :name => "吼叫",
    
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
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<atb_shift:-15>\n<state_chance 67:25>\n<cannot level>",
    
        },
    

        740 => {
    
          :name => "拍擊",
    
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
    

        741 => {
    
          :name => "吸取",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 80,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 138,
    
          :mp_cost => 5,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => true,
    
          :ignore_defense => false,
    
          :element_set => [15],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<bonus_vs_state 35:25>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        748 => {
    
          :name => "濁流",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 220,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 201,
    
          :mp_cost => 12,
    
          :hit => 85,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [14],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 32:30>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        749 => {
    
          :name => "猛推",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 70,
    
          :variance => 15,
    
          :atk_f => 134,
    
          :spi_f => 0,
    
          :mp_cost => 5,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [5],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        750 => {
    
          :name => "拍落",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 170,
    
          :variance => 15,
    
          :atk_f => 178,
    
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
    
          :note => "<bonus_vs_state 54:30>\n<state_chance 67:18>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        751 => {
    
          :name => "鐵壁",
    
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
    
          :element_set => [12],
    
          :plus_state_set => [55],
    
          :minus_state_set => [],
    
          :note => "<cannot level>",
    
        },
    

        752 => {
    
          :name => "水之波動",
    
          :scope => 1,
    
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
    
          :element_set => [14],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 32:25>\n<state_chance 71:15>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        753 => {
    
          :name => "劍舞",
    
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
    
          :plus_state_set => [54],
    
          :minus_state_set => [],
    
          :note => "<cannot level>",
    
        },
    

        755 => {
    
          :name => "彗星拳",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 220,
    
          :variance => 15,
    
          :atk_f => 201,
    
          :spi_f => 0,
    
          :mp_cost => 12,
    
          :hit => 90,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<break_power:1>\n<break_state:50>\n<broken_state:51>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        764 => {
    
          :name => "金屬音",
    
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
    
          :element_set => [12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 60:55>\n<state_chance 39:20>\n<cannot level>",
    
        },
    

        765 => {
    
          :name => "空氣斬",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 190,
    
          :variance => 10,
    
          :atk_f => 0,
    
          :spi_f => 188,
    
          :mp_cost => 11,
    
          :hit => 95,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [6],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<crit_rate:5>\n<state_chance 49:20>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:700>\n<level 2 jp cost:2000>\n<level 3 jp cost:4500>",
    
        },
    

        767 => {
    
          :name => "雙針",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 150,
    
          :variance => 10,
    
          :atk_f => 175,
    
          :spi_f => 0,
    
          :mp_cost => 8,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [10],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 31:20>\n<crit_rate:5>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        768 => {
    
          :name => "吐絲",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 5,
    
          :hit => 90,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [10],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 38:35>\n<AI評 :10>\n<cannot level>",
    
        },
    

        769 => {
    
          :name => "變硬",
    
          :scope => 11,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 4,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [55],
    
          :minus_state_set => [],
    
          :note => "<cannot level>",
    
        },
    

        770 => {
    
          :name => "毒針",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 90,
    
          :variance => 15,
    
          :atk_f => 130,
    
          :spi_f => 0,
    
          :mp_cost => 3,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<state_chance 31:20>\n<ai_prefer_stack_below 31:5>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:400>\n<level 2 jp cost:1200>\n<level 3 jp cost:3000>",
    
        },
    

        771 => {
    
          :name => "躍起",
    
          :scope => 11,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 3,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [57],
    
          :minus_state_set => [],
    
          :note => "<AI評 :-10>\n<cannot level>",
    
        },
    

      })

    BALANCE_OVERRIDES = {
    
        110 => {:base_damage=>-20, :atk_f=>0, :spi_f=>50},
    
        111 => {:base_damage=>-35, :atk_f=>0, :spi_f=>70},
    
        113 => {:base_damage=>-40, :atk_f=>0, :spi_f=>70},
    
        114 => {:base_damage=>-25, :atk_f=>0, :spi_f=>45},
    
        118 => {:base_damage=>-10, :atk_f=>0, :spi_f=>35},
    
        119 => {:base_damage=>-80, :atk_f=>0, :spi_f=>110},
    
        172 => {:base_damage=>-25, :atk_f=>0, :spi_f=>55},
    
        173 => {:base_damage=>-20, :atk_f=>0, :spi_f=>40},
    
        174 => {:base_damage=>-60, :atk_f=>0, :spi_f=>90},
    
        189 => {:base_damage=>-20, :atk_f=>0, :spi_f=>45},
    
        300 => {:base_damage=>75, :atk_f=>0, :spi_f=>105},
    
        301 => {:base_damage=>130, :atk_f=>0, :spi_f=>115},
    
        303 => {:base_damage=>115, :atk_f=>115, :spi_f=>0},
    
        305 => {:base_damage=>160, :atk_f=>130, :spi_f=>0},
    
        306 => {:base_damage=>100, :atk_f=>35, :spi_f=>105},
    
        307 => {:base_damage=>65, :atk_f=>0, :spi_f=>95},
    
        308 => {:base_damage=>-25, :atk_f=>0, :spi_f=>45},
    
        310 => {:base_damage=>150, :atk_f=>140, :spi_f=>0},
    
        311 => {:base_damage=>105, :atk_f=>105, :spi_f=>0},
    
        312 => {:base_damage=>75, :atk_f=>0, :spi_f=>80},
    
        313 => {:base_damage=>170, :atk_f=>0, :spi_f=>140},
    
        314 => {:base_damage=>210, :atk_f=>185, :spi_f=>0},
    
        316 => {:base_damage=>115, :atk_f=>0, :spi_f=>135},
    
        317 => {:base_damage=>150, :atk_f=>0, :spi_f=>125},
    
        318 => {:base_damage=>215, :atk_f=>125, :spi_f=>125},
    
        319 => {:base_damage=>310, :atk_f=>0, :spi_f=>230},
    
        322 => {:base_damage=>190, :atk_f=>120, :spi_f=>120},
    
        330 => {:base_damage=>65, :atk_f=>0, :spi_f=>80},
    
        331 => {:base_damage=>160, :atk_f=>135, :spi_f=>0},
    
        332 => {:base_damage=>195, :atk_f=>105, :spi_f=>105},
    
        333 => {:base_damage=>80, :atk_f=>0, :spi_f=>120},
    
        334 => {:base_damage=>150, :atk_f=>0, :spi_f=>130},
    
        335 => {:base_damage=>170, :atk_f=>85, :spi_f=>100},
    
        336 => {:base_damage=>100, :atk_f=>0, :spi_f=>140},
    
        337 => {:base_damage=>140, :atk_f=>0, :spi_f=>120},
    
        339 => {:base_damage=>250, :atk_f=>0, :spi_f=>190},
    
        340 => {:base_damage=>200, :atk_f=>0, :spi_f=>155},
    
        343 => {:base_damage=>255, :atk_f=>140, :spi_f=>160},
    
        344 => {:base_damage=>290, :atk_f=>140, :spi_f=>155},
    
        351 => {:base_damage=>135, :atk_f=>110, :spi_f=>0},
    
        353 => {:base_damage=>260, :atk_f=>145, :spi_f=>115},
    
        354 => {:base_damage=>310, :atk_f=>170, :spi_f=>0},
    
        355 => {:base_damage=>155, :atk_f=>45, :spi_f=>120},
    
        357 => {:base_damage=>400, :atk_f=>0, :spi_f=>255},
    
        358 => {:base_damage=>280, :atk_f=>135, :spi_f=>135},
    
        400 => {:base_damage=>90, :atk_f=>0, :spi_f=>85},
    
        401 => {:base_damage=>220, :atk_f=>0, :spi_f=>140},
    
        402 => {:base_damage=>165, :atk_f=>0, :spi_f=>140},
    
        403 => {:base_damage=>185, :atk_f=>0, :spi_f=>135},
    
        404 => {:base_damage=>155, :atk_f=>120, :spi_f=>0},
    
        405 => {:base_damage=>350, :atk_f=>220, :spi_f=>0},
    
        406 => {:base_damage=>100, :atk_f=>0, :spi_f=>140},
    
        407 => {:base_damage=>405, :atk_f=>250, :spi_f=>0},
    
        409 => {:base_damage=>220, :atk_f=>0, :spi_f=>160},
    
        410 => {:base_damage=>225, :atk_f=>160, :spi_f=>0},
    
        411 => {:base_damage=>510, :atk_f=>300, :spi_f=>0},
    
        413 => {:base_damage=>265, :atk_f=>0, :spi_f=>200},
    
        414 => {:base_damage=>295, :atk_f=>0, :spi_f=>205},
    
        415 => {:base_damage=>690, :atk_f=>0, :spi_f=>380},
    
        450 => {:base_damage=>415, :atk_f=>280, :spi_f=>0},
    
        451 => {:base_damage=>500, :atk_f=>245, :spi_f=>210},
    
        453 => {:base_damage=>455, :atk_f=>0, :spi_f=>310},
    
        454 => {:base_damage=>680, :atk_f=>0, :spi_f=>415},
    
        456 => {:base_damage=>705, :atk_f=>380, :spi_f=>0},
    
        457 => {:base_damage=>295, :atk_f=>150, :spi_f=>165},
    
        659 => {:base_damage=>-25, :atk_f=>0, :spi_f=>55},
    
        684 => {:base_damage=>-35, :atk_f=>0, :spi_f=>65},
    
        710 => {:base_damage=>-35, :atk_f=>0, :spi_f=>65},
    
      }
  end
end
