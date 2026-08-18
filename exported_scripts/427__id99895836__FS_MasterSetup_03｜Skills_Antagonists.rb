#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 03 Skills Antagonists
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 03 Skills Antagonists」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、SKILLS
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / SKILLS ANTAGONISTS
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
# ■ FS_MasterSetup 03 Skills Antagonists
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：03 / 20
# 分類用途：一般反派、主要反派與機械 Boss 技能（ID 300～358）
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP
  module SKILLS
    DATA.merge!({
        300 => {
    
          :name => "毒霧針",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 120,
    
          :variance => 6,
    
          :atk_f => 0,
    
          :spi_f => 165,
    
          :mp_cost => 8,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<state_chance 31:75>\n<cannot level>\n<ai_prefer_stack_below 31:5>",
    
        },
    

        301 => {
    
          :name => "培養爆裂",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 230,
    
          :variance => 8,
    
          :atk_f => 0,
    
          :spi_f => 205,
    
          :mp_cost => 14,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 31:45>\n<cannot level>\n<state_chance 37:35>",
    
        },
    

        302 => {
    
          :name => "再生胞子",
    
          :scope => 11,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 12,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [15],
    
          :plus_state_set => [64],
    
          :minus_state_set => [],
    
          :note => "<回復技能>\n<cannot level>",
    
        },
    

        303 => {
    
          :name => "棘甲撞擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 190,
    
          :variance => 10,
    
          :atk_f => 190,
    
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
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 44:25>\n<cannot level>",
    
        },
    

        304 => {
    
          :name => "根牆",
    
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
    
          :element_set => [15],
    
          :plus_state_set => [55],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<cannot level>",
    
        },
    

        305 => {
    
          :name => "反棘",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 270,
    
          :variance => 8,
    
          :atk_f => 225,
    
          :spi_f => 0,
    
          :mp_cost => 14,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [15, 12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<state_chance 44:30>\n<cannot level>",
    
        },
    

        306 => {
    
          :name => "雷序截流",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 170,
    
          :variance => 6,
    
          :atk_f => 60,
    
          :spi_f => 175,
    
          :mp_cost => 10,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<atb_shift:-20>\n<cannot level>\n<atb_bonus_if_target_atb_above 75:35>",
    
        },
    

        307 => {
    
          :name => "靜電網",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 90,
    
          :variance => 5,
    
          :atk_f => 0,
    
          :spi_f => 130,
    
          :mp_cost => 16,
    
          :hit => 95,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<state_chance 38:45>\n<cannot level>\n<atb_shift:-8>",
    
        },
    

        308 => {
    
          :name => "雙生回復",
    
          :scope => 8,
    
          :occasion => 1,
    
          :base_damage => -170,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 175,
    
          :mp_cost => 18,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [21],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<回復技能>\n<cannot level>",
    
        },
    

        309 => {
    
          :name => "生命連結",
    
          :scope => 8,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 14,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [53],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<cannot level>",
    
        },
    

        310 => {
    
          :name => "裂地拳",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 250,
    
          :variance => 10,
    
          :atk_f => 230,
    
          :spi_f => 0,
    
          :mp_cost => 12,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [5],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<break_power:2>\n<cannot level>\n<break_state:50>\n<broken_state:51>",
    
        },
    

        311 => {
    
          :name => "破陣波",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 180,
    
          :variance => 10,
    
          :atk_f => 175,
    
          :spi_f => 0,
    
          :mp_cost => 18,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [8],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<break_power:1>\n<cannot level>\n<break_state:50>\n<broken_state:51>",
    
        },
    

        312 => {
    
          :name => "夢魘波",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 180,
    
          :variance => 8,
    
          :atk_f => 0,
    
          :spi_f => 190,
    
          :mp_cost => 18,
    
          :hit => 95,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [11],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<state_chance 46:25>\n<cannot level>\n<state_chance 71:20>",
    
        },
    

        313 => {
    
          :name => "食夢",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 280,
    
          :variance => 6,
    
          :atk_f => 0,
    
          :spi_f => 230,
    
          :mp_cost => 14,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => true,
    
          :ignore_defense => false,
    
          :element_set => [17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 46:80>\n<cannot level>",
    
        },
    

        314 => {
    
          :name => "鋼翼俯衝",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 270,
    
          :variance => 10,
    
          :atk_f => 235,
    
          :spi_f => 0,
    
          :mp_cost => 14,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12, 6],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<state_chance 69:35>\n<cannot level>",
    
        },
    

        315 => {
    
          :name => "撒菱封路",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 16,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [8],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<state_chance 38:55>\n<cannot level>",
    
        },
    

        316 => {
    
          :name => "腐蝕地雷",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 160,
    
          :variance => 8,
    
          :atk_f => 0,
    
          :spi_f => 185,
    
          :mp_cost => 18,
    
          :hit => 95,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<state_chance 37:45>\n<cannot level>",
    
        },
    

        317 => {
    
          :name => "引爆地雷",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 260,
    
          :variance => 6,
    
          :atk_f => 0,
    
          :spi_f => 220,
    
          :mp_cost => 22,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [13, 7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<bonus_vs_state 37:60>\n<cannot level>",
    
        },
    

        318 => {
    
          :name => "共鳴獵殺",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 300,
    
          :variance => 6,
    
          :atk_f => 175,
    
          :spi_f => 175,
    
          :mp_cost => 18,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 40:70>\n<cannot level>\n<target_group: summon>",
    
        },
    

        319 => {
    
          :name => "偏差處刑",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 340,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 250,
    
          :mp_cost => 20,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 120:120>\n<cannot level>\n<ai_require_state:120>",
    
        },
    

        320 => {
    
          :name => "天候祈請",
    
          :scope => 11,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 16,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<cannot level>\n<field_context_weather>",
    
        },
    

        321 => {
    
          :name => "失序號令",
    
          :scope => 8,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 20,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [57],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<cannot level>",
    
        },
    

        322 => {
    
          :name => "歸一砲擊",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 340,
    
          :variance => 6,
    
          :atk_f => 210,
    
          :spi_f => 210,
    
          :mp_cost => 24,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<bonus_if_target_atb_above 70:25>\n<cannot level>",
    
        },
    

        323 => {
    
          :name => "緊急校準",
    
          :scope => 11,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [38, 59, 60, 61],
    
          :note => "<回復技能>\n<cannot level>",
    
        },
    

        330 => {
    
          :name => "觀律掃描",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 150,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 175,
    
          :mp_cost => 12,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<ai_bonus_vs_state 120:100>\n<cannot level>",
    
        },
    

        331 => {
    
          :name => "偏差切割",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 280,
    
          :variance => 6,
    
          :atk_f => 235,
    
          :spi_f => 0,
    
          :mp_cost => 16,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 120:70>\n<cannot level>",
    
        },
    

        332 => {
    
          :name => "觀律處刑",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 430,
    
          :variance => 4,
    
          :atk_f => 230,
    
          :spi_f => 230,
    
          :mp_cost => 28,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 120:150>\n<cannot level>\n<ai_require_state:120>",
    
        },
    

        333 => {
    
          :name => "雙弦刻印",
    
          :scope => 4,
    
          :occasion => 1,
    
          :base_damage => 80,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 120,
    
          :mp_cost => 16,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<double_thread:121,40>\n<cannot level>\n<double_thread_animation:45>",
    
        },
    

        334 => {
    
          :name => "共振割裂",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 260,
    
          :variance => 6,
    
          :atk_f => 0,
    
          :spi_f => 225,
    
          :mp_cost => 20,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<bonus_vs_state 121:55>\n<cannot level>",
    
        },
    

        335 => {
    
          :name => "斷弦終止",
    
          :scope => 4,
    
          :occasion => 1,
    
          :base_damage => 420,
    
          :variance => 4,
    
          :atk_f => 210,
    
          :spi_f => 250,
    
          :mp_cost => 32,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<double_thread:121,55>\n<cannot level>\n<double_thread_lethal>",
    
        },
    

        336 => {
    
          :name => "改譜針",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 100,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 140,
    
          :mp_cost => 14,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<rewrite_actor 1:130>\n<cannot level>\n<rewrite_actor 2:131>\n<rewrite_actor 3:132>\n<rewrite_actor 4:133>\n<rewrite_actor 5:134>\n<rewrite_actor 6:135>\n<rewrite_default_state:139>",
    
        },
    

        337 => {
    
          :name => "白譜震盪",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 280,
    
          :variance => 6,
    
          :atk_f => 0,
    
          :spi_f => 235,
    
          :mp_cost => 22,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<bonus_vs_state 130:35>\n<cannot level>\n<bonus_vs_state 131:35>\n<bonus_vs_state 132:35>\n<bonus_vs_state 133:35>\n<bonus_vs_state 134:35>\n<bonus_vs_state 135:35>",
    
        },
    

        338 => {
    
          :name => "召喚獵印",
    
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
    
          :element_set => [],
    
          :plus_state_set => [74],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<target_group: summon>\n<cannot level>",
    
        },
    

        339 => {
    
          :name => "靈鐲斷路",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 310,
    
          :variance => 6,
    
          :atk_f => 0,
    
          :spi_f => 235,
    
          :mp_cost => 18,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<target_group: summon>\n<cannot level>\n<atb_shift:-25>",
    
        },
    

        340 => {
    
          :name => "全知射線",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 340,
    
          :variance => 5,
    
          :atk_f => 0,
    
          :spi_f => 260,
    
          :mp_cost => 26,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [21],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<bonus_vs_state 120:55>\n<cannot level>",
    
        },
    

        341 => {
    
          :name => "鎮壓律令",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 120,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 150,
    
          :mp_cost => 18,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<atb_shift:-15>\n<cannot level>\n<state_chance 38:55>",
    
        },
    

        342 => {
    
          :name => "改譜律令",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 80,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 120,
    
          :mp_cost => 20,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<rewrite_actor 1:130>\n<cannot level>\n<rewrite_actor 2:131>\n<rewrite_actor 3:132>\n<rewrite_actor 4:133>\n<rewrite_actor 5:134>\n<rewrite_actor 6:135>\n<rewrite_default_state:139>",
    
        },
    

        343 => {
    
          :name => "歸一律令",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 420,
    
          :variance => 4,
    
          :atk_f => 230,
    
          :spi_f => 260,
    
          :mp_cost => 32,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<cannot level>",
    
        },
    

        344 => {
    
          :name => "失奏終曲",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 620,
    
          :variance => 3,
    
          :atk_f => 300,
    
          :spi_f => 330,
    
          :mp_cost => 50,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<bonus_vs_state 120:35>\n<cannot level>",
    
        },
    

        350 => {
    
          :name => "城塞護盾",
    
          :scope => 11,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12],
    
          :plus_state_set => [77],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<cannot level>",
    
        },
    

        351 => {
    
          :name => "震盪砲",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 300,
    
          :variance => 8,
    
          :atk_f => 245,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<atb_shift:-10>\n<cannot level>",
    
        },
    

        352 => {
    
          :name => "核心回收",
    
          :scope => 11,
    
          :occasion => 1,
    
          :base_damage => -800,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 160,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12],
    
          :plus_state_set => [],
    
          :minus_state_set => [129],
    
          :note => "<回復技能>\n<cannot level>",
    
        },
    

        353 => {
    
          :name => "過熱衝擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 480,
    
          :variance => 5,
    
          :atk_f => 270,
    
          :spi_f => 210,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [13, 12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_if_user_state 128:40>\n<cannot level>",
    
        },
    

        354 => {
    
          :name => "堡壘清場",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 560,
    
          :variance => 4,
    
          :atk_f => 310,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<ignore target priority>\n<cannot level>",
    
        },
    

        355 => {
    
          :name => "諧律掃射",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 340,
    
          :variance => 6,
    
          :atk_f => 100,
    
          :spi_f => 260,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16, 4],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<atb_shift:-12>\n<cannot level>",
    
        },
    

        356 => {
    
          :name => "模組輪替",
    
          :scope => 11,
    
          :occasion => 1,
    
          :base_damage => 0,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<cannot level>",
    
        },
    

        357 => {
    
          :name => "破譜雷射",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 520,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 330,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 40:60>\n<cannot level>",
    
        },
    

        358 => {
    
          :name => "終止協議",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 720,
    
          :variance => 3,
    
          :atk_f => 350,
    
          :spi_f => 350,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<ignore target priority>\n<cannot level>",
    
        },
    

      })
  end
end
