#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 02 Skills Clones Robots
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 02 Skills Clones Robots」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、SKILLS
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / SKILLS CLONES & ROBOTS
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
# ■ FS_MasterSetup 02 Skills Clones Robots
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：02 / 20
# 分類用途：五名映體、機器人與三段追擊技能（ID 160～192）
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP
  module SKILLS
    DATA.merge!({
        160 => {
    
          :name => "電弧針",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 120,
    
          :variance => 6,
    
          :atk_f => 145,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 97,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 4%, 0>\n<recharge:25%>\n<clone_stability_cost:10>\n<atb_shift:-8>\n<al:ATB>\n<cannot level>",
    
        },
    

        161 => {
    
          :name => "斷訊脈衝",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 200,
    
          :variance => 6,
    
          :atk_f => 90,
    
          :spi_f => 120,
    
          :mp_cost => 0,
    
          :hit => 97,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 8%, 0>\n<recharge:15%>\n<clone_stability_cost:22>\n<atb_shift:-20>\n<cab:50,80>\n<al:ATB>\n<cannot level>",
    
        },
    

        162 => {
    
          :name => "追頻爆裂",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 260,
    
          :variance => 8,
    
          :atk_f => 0,
    
          :spi_f => 210,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 12%, 0>\n<recharge:10%>\n<clone_stability_cost:26>\n<cad:30,40>\n<cannot level>",
    
        },
    

        163 => {
    
          :name => "頻率校準",
    
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
    
          :note => "<charge: 4, 8%, 0>\n<recharge:20%>\n<ricarica turni:2>\n<clone_stability_cost:0>\n<clone_stability_recover:30>\n<mpu:校準完成>\n<cannot level>",
    
        },
    

        164 => {
    
          :name => "零頻封鎖",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 430,
    
          :variance => 4,
    
          :atk_f => 180,
    
          :spi_f => 180,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12, 16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 24%, 0>\n<recharge:0%>\n<ricarica turni:3>\n<clone_stability_cost:48>\n<atb_shift:-30>\n<cab:60,85>\n<clone_stability_allow_overdraw>\n<bonus_if_clone_unstable:35>\n<cannot level>",
    
        },
    

        165 => {
    
          :name => "根網牽引",
    
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
    
          :element_set => [15],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 0%, 0>\n<recharge:25%>\n<clone_stability_cost:8>\n<cit:300,15,1>\n<mpu:根網牽引！>\n<cannot level>",
    
        },
    

        166 => {
    
          :name => "壁身撞",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 180,
    
          :variance => 10,
    
          :atk_f => 170,
    
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
    
          :note => "<charge: 4, 6%, 0>\n<recharge:18%>\n<clone_stability_cost:14>\n<ctb:90,10>\n<cannot level>",
    
        },
    

        167 => {
    
          :name => "返棘重擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 300,
    
          :variance => 8,
    
          :atk_f => 220,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [15, 12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 12%, 0>\n<recharge:10%>\n<clone_stability_cost:24>\n<cir:50>\n<mpu:返棘！>\n<cannot level>",
    
        },
    

        168 => {
    
          :name => "根壁校準",
    
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
    
          :note => "<charge: 4, 8%, 0>\n<recharge:20%>\n<ricarica turni:2>\n<clone_stability_cost:0>\n<clone_stability_recover:25>\n<cannot level>",
    
        },
    

        169 => {
    
          :name => "斷根壁壘",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 420,
    
          :variance => 6,
    
          :atk_f => 230,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [15, 12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 26%, 0>\n<recharge:0%>\n<ricarica turni:3>\n<clone_stability_cost:48>\n<cir:70>\n<clone_stability_allow_overdraw>\n<bonus_if_clone_unstable:30>\n<cannot level>",
    
        },
    

        170 => {
    
          :name => "輝羽",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 130,
    
          :variance => 6,
    
          :atk_f => 0,
    
          :spi_f => 160,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [21],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 5%, 0>\n<recharge:22%>\n<clone_stability_cost:10>\n<cma>\n<cannot level>",
    
        },
    

        171 => {
    
          :name => "星屑",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 150,
    
          :variance => 8,
    
          :atk_f => 0,
    
          :spi_f => 155,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [21],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 10%, 0>\n<recharge:12%>\n<clone_stability_cost:16>\n<cma>\n<cannot level>",
    
        },
    

        172 => {
    
          :name => "微光修復",
    
          :scope => 7,
    
          :occasion => 1,
    
          :base_damage => -220,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 200,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [21],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<cma>\n<charge: 4, 8%, 0>\n<recharge:15%>\n<clone_stability_cost:20>\n<cmh>\n<cmb:30>\n<cannot level>",
    
        },
    

        173 => {
    
          :name => "群體修復",
    
          :scope => 8,
    
          :occasion => 1,
    
          :base_damage => -170,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 170,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [21],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 16%, 0>\n<recharge:5%>\n<clone_stability_cost:28>\n<cmh>\n<cmb:30>\n<cannot level>",
    
        },
    

        174 => {
    
          :name => "迴路重整",
    
          :scope => 8,
    
          :occasion => 1,
    
          :base_damage => -240,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 220,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [21],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 24%, 0>\n<recharge:0%>\n<ricarica turni:3>\n<clone_stability_cost:48>\n<cmh>\n<cmb:35>\n<clone_stability_allow_overdraw>\n<clone_stability_recover:20>\n<cannot level>",
    
        },
    

        175 => {
    
          :name => "冷毒注射",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 90,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 145,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [31],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 5%, 0>\n<recharge:22%>\n<clone_stability_cost:10>\n<cvb:15>\n<cannot level>",
    
        },
    

        176 => {
    
          :name => "神經霧",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 100,
    
          :variance => 6,
    
          :atk_f => 0,
    
          :spi_f => 145,
    
          :mp_cost => 0,
    
          :hit => 95,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [38],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 10%, 0>\n<recharge:12%>\n<clone_stability_cost:18>\n<cvb:15>\n<cannot level>",
    
        },
    

        177 => {
    
          :name => "反應收束",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 240,
    
          :variance => 6,
    
          :atk_f => 0,
    
          :spi_f => 210,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 12%, 0>\n<recharge:10%>\n<clone_stability_cost:22>\n<cvd:20,2>\n<mpt:反應收束！>\n<cannot level>",
    
        },
    

        178 => {
    
          :name => "腐蝕針",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 210,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 200,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [37],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 12%, 0>\n<recharge:8%>\n<clone_stability_cost:26>\n<cvb:15>\n<cvd:15,2>\n<cannot level>",
    
        },
    

        179 => {
    
          :name => "病灶校正",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 360,
    
          :variance => 4,
    
          :atk_f => 0,
    
          :spi_f => 250,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7, 17],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 24%, 0>\n<recharge:0%>\n<ricarica turni:3>\n<clone_stability_cost:48>\n<cvd:20,3>\n<clone_stability_allow_overdraw>\n<bonus_if_clone_unstable:30>\n<cannot level>",
    
        },
    

        180 => {
    
          :name => "破殼擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 160,
    
          :variance => 8,
    
          :atk_f => 180,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [5],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 5%, 0>\n<recharge:22%>\n<clone_stability_cost:10>\n<ctc:90>\n<mpt:裂甲！>\n<cannot level>",
    
        },
    

        181 => {
    
          :name => "裂甲連打",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 220,
    
          :variance => 10,
    
          :atk_f => 210,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [5],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 8%, 0>\n<recharge:15%>\n<clone_stability_cost:18>\n<ctb:90,25>\n<cannot level>",
    
        },
    

        182 => {
    
          :name => "震芯拳",
    
          :scope => 2,
    
          :occasion => 1,
    
          :base_damage => 190,
    
          :variance => 10,
    
          :atk_f => 170,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 95,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [5],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 14%, 0>\n<recharge:8%>\n<ricarica turni:1>\n<clone_stability_cost:24>\n<ctc:90>\n<cannot level>",
    
        },
    

        183 => {
    
          :name => "戰意校準",
    
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
    
          :note => "<charge: 4, 8%, 0>\n<recharge:20%>\n<ricarica turni:2>\n<clone_stability_cost:0>\n<clone_stability_recover:30>\n<cannot level>",
    
        },
    

        184 => {
    
          :name => "爆芯衝",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 500,
    
          :variance => 4,
    
          :atk_f => 300,
    
          :spi_f => 0,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => true,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [13, 5],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 28%, 0>\n<recharge:0%>\n<ricarica turni:3>\n<clone_stability_cost:52>\n<ctf:90,70>\n<clone_stability_allow_overdraw>\n<bonus_if_clone_unstable:30>\n<mpt:裂甲粉碎！>\n<cannot level>",
    
        },
    

        185 => {
    
          :name => "防衛協議",
    
          :scope => 8,
    
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
    
          :plus_state_set => [55],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 12%, 0>\n<recharge:8%>\n<cannot level>",
    
        },
    

        186 => {
    
          :name => "雷序截流",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 170,
    
          :variance => 6,
    
          :atk_f => 60,
    
          :spi_f => 175,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [16],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 8%, 0>\n<recharge:15%>\n<atb_shift:-20>\n<cab:30,75>\n<cannot level>",
    
        },
    

        187 => {
    
          :name => "腐蝕催化",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 155,
    
          :variance => 8,
    
          :atk_f => 45,
    
          :spi_f => 185,
    
          :mp_cost => 0,
    
          :hit => 95,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [7],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<charge: 4, 10%, 0>\n<recharge:12%>\n<state_chance 37:55>\n<bonus_vs_state 31:35>\n<cannot level>",
    
        },
    

        188 => {
    
          :name => "破城重鑿",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 255,
    
          :variance => 10,
    
          :atk_f => 235,
    
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
    
          :note => "<charge: 4, 14%, 0>\n<recharge:8%>\n<break_power:2>\n<bonus_vs_state 51:30>\n<cannot level>",
    
        },
    

        189 => {
    
          :name => "修復循環",
    
          :scope => 8,
    
          :occasion => 1,
    
          :base_damage => -95,
    
          :variance => 0,
    
          :atk_f => 0,
    
          :spi_f => 135,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [21],
    
          :plus_state_set => [],
    
          :minus_state_set => [31, 34, 37, 38, 48],
    
          :note => "<charge: 4, 12%, 0>\n<recharge:10%>\n<mana_engine_mp:8>\n<cannot level>",
    
        },
    

        190 => {
    
          :name => "魂刻追擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 180,
    
          :variance => 8,
    
          :atk_f => 120,
    
          :spi_f => 120,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<cannot level>\n<hide>\n<action: 喬伊普攻>",
    
        },
    

        191 => {
    
          :name => "機核追擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 210,
    
          :variance => 6,
    
          :atk_f => 140,
    
          :spi_f => 100,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [12],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<cannot level>\n<hide>",
    
        },
    

        192 => {
    
          :name => "映體追擊",
    
          :scope => 1,
    
          :occasion => 1,
    
          :base_damage => 230,
    
          :variance => 6,
    
          :atk_f => 130,
    
          :spi_f => 130,
    
          :mp_cost => 0,
    
          :hit => 100,
    
          :physical_attack => false,
    
          :damage_to_mp => false,
    
          :absorb_damage => false,
    
          :ignore_defense => false,
    
          :element_set => [],
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<clone_stability_cost:20>\n<cannot level>\n<hide>",
    
        },
    

      })
  end
end
