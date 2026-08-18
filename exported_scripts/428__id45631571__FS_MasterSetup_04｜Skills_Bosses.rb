#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 04 Skills Bosses
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 04 Skills Bosses」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、SKILLS
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / SKILLS BOSSES
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
# ■ FS_MasterSetup 04 Skills Bosses
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：04 / 20
# 分類用途：寶可夢型 Boss 與始源級技能（ID 400～458）
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP
  module SKILLS
    DATA.merge!({
        400 => {
    
          :name => "花園支配",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 260,
    
          :variance => 6,
    
          :atk_f => 0,
    
          :spi_f => 245,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [15, 7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<state_chance 31:65>\n<cannot level>\n<state_chance 35:35>",
    
        },
    

        401 => {
    
          :name => "日光終束",
    
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
    
          :element_set => [15],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 51:50>\n<cannot level>",
    
        },
    

        402 => {
    
          :name => "影縫",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 300,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 255,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [11],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<state_chance 45:35>\n<cannot level>",
    
        },
    

        403 => {
    
          :name => "夢魘盛宴",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 390,
    
          :variance => 5,
    
          :atk_f => 0,
    
          :spi_f => 290,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [11, 17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<bonus_vs_state 46:70>\n<cannot level>\n<state_chance 71:20>",
    
        },
    

        404 => {
    
          :name => "沙暴碾壓",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 380,
    
          :variance => 8,
    
          :atk_f => 300,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [9, 20],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<break_power:1>\n<cannot level>",
    
        },
    

        405 => {
    
          :name => "暴君咬碎",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 560,
    
          :variance => 5,
    
          :atk_f => 350,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [20],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 51:60>\n<cannot level>",
    
        },
    

        406 => {
    
          :name => "磁場鎖定",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 100,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 140,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12, 16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<atb_shift:-12>\n<cannot level>\n<state_chance 38:45>",
    
        },
    

        407 => {
    
          :name => "彗星重擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 620,
    
          :variance => 4,
    
          :atk_f => 380,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12, 17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<break_power:2>\n<cannot level>\n<bonus_vs_state 51:40>",
    
        },
    

        408 => {
    
          :name => "潮汐再生",
    
          :scope => 11,
    
          :occasion => 1,
    
          :base_damage => -1200,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 260,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [14],
    
          :plus_state_set => [64],
    
          :minus_state_set => [],
    
          :note => "<回復技能>\n<cannot level>",
    
        },
    

        409 => {
    
          :name => "鏡水裁決",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 420,
    
          :variance => 5,
    
          :atk_f => 0,
    
          :spi_f => 310,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [14, 17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<state_chance 32:70>\n<cannot level>",
    
        },
    

        410 => {
    
          :name => "龍翼暴風",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 460,
    
          :variance => 8,
    
          :atk_f => 330,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [19, 6],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<atb_shift:-10>\n<cannot level>",
    
        },
    

        411 => {
    
          :name => "逆鱗終擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 700,
    
          :variance => 4,
    
          :atk_f => 410,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [19],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<cannot level>",
    
        },
    

        412 => {
    
          :name => "夢幻變奏",
    
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
    
          :element_set => [17],
    
          :plus_state_set => [54, 56, 57],
    
          :minus_state_set => [],
    
          :note => "<狀態技能>\n<cannot level>",
    
        },
    

        413 => {
    
          :name => "萬象波",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 430,
    
          :variance => 5,
    
          :atk_f => 0,
    
          :spi_f => 320,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<state_chance 39:35>\n<cannot level>",
    
        },
    

        414 => {
    
          :name => "精神壓制",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 500,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 350,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<atb_shift:-15>\n<cannot level>\n<state_chance 60:40>",
    
        },
    

        415 => {
    
          :name => "基因崩解",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 820,
    
          :variance => 2,
    
          :atk_f => 0,
    
          :spi_f => 450,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 51:60>\n<cannot level>",
    
        },
    

        450 => {
    
          :name => "斷崖之劍",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 620,
    
          :variance => 8,
    
          :atk_f => 420,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [8],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<break_power:2>\n<cannot level>\n<state_chance 34:35>",
    
        },
    

        451 => {
    
          :name => "熔岩裂界",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 720,
    
          :variance => 4,
    
          :atk_f => 350,
    
          :spi_f => 300,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [8, 13],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 51:45>\n<cannot level>",
    
        },
    

        452 => {
    
          :name => "原始陸地啟動",
    
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
    
          :element_set => [8],
    
          :plus_state_set => [125],
    
          :minus_state_set => [122],
    
          :note => "<狀態技能>\n<cannot level>\n<field effect: 156>",
    
        },
    

        453 => {
    
          :name => "根源波動",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 620,
    
          :variance => 8,
    
          :atk_f => 0,
    
          :spi_f => 420,
    
          :mp_cost => 0,
    
          :hit => 95,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [14],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<state_chance 32:80>\n<cannot level>",
    
        },
    

        454 => {
    
          :name => "雷雨滅流",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 700,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 430,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [14, 16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_vs_state 32:55>\n<cannot level>\n<state_chance 33:25>",
    
        },
    

        455 => {
    
          :name => "始源之海啟動",
    
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
    
          :element_set => [14],
    
          :plus_state_set => [126],
    
          :minus_state_set => [123],
    
          :note => "<狀態技能>\n<cannot level>\n<field effect: 157>",
    
        },
    

        456 => {
    
          :name => "畫龍點睛",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 840,
    
          :variance => 3,
    
          :atk_f => 450,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [19, 6],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<單體攻擊技能>\n<bonus_if_target_atb_above 70:30>\n<cannot level>",
    
        },
    

        457 => {
    
          :name => "天穹亂流",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 650,
    
          :variance => 5,
    
          :atk_f => 330,
    
          :spi_f => 360,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [19, 6],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<全體攻擊技能>\n<atb_shift:-18>\n<cannot level>",
    
        },
    

        458 => {
    
          :name => "德爾塔氣流啟動",
    
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
    
          :element_set => [6],
    
          :plus_state_set => [127],
    
          :minus_state_set => [124],
    
          :note => "<狀態技能>\n<cannot level>\n<field effect: 158>",
    
        },
    

      })
  end
end
