#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 11 Enemies Antagonists Bosses
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 11 Enemies Antagonists Bosses」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、ENEMIES
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：COMMON_VISUAL_NOTE、DATA。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / ENEMIES ANTAGONISTS & BOSSES
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
# ■ FS_MasterSetup 11 Enemies Antagonists Bosses
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：11 / 20
# 分類用途：一般反派、主要反派、機械與寶可夢 Boss／核心（ID 500～565）
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP
  module ENEMIES
    # 【敵人物品掉落率】
    # denominator 是「分母」：4 = 25%、3 = 33.3%、2 = 50%。
    # 基礎型／中階型／最終型依序使用 4／3／2，保留進化階段獎勵差異。
    COMMON_VISUAL_NOTE = "<animated>\n<mirror>\n<shadow: off>"

    DATA = {}

    DATA.merge!({
        500 => {
    
          :name => "毒霧培養師",
    
          :maxhp => 2400,
    
          :maxmp => 220,
    
          :atk => 65,
    
          :def => 58,
    
          :spi => 82,
    
          :agi => 68,
    
          :hit => 98,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 75,
    
          :gold => 180,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 300, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 301, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 302, :rating => 8, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 45}],
    
          :note => "<level set 10>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        501 => {
    
          :name => "棘甲守衛",
    
          :maxhp => 4200,
    
          :maxmp => 160,
    
          :atk => 92,
    
          :def => 115,
    
          :spi => 55,
    
          :agi => 50,
    
          :hit => 98,
    
          :eva => 3,
    
          :has_critical => true,
    
          :exp => 75,
    
          :gold => 230,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 303, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 304, :rating => 8, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 60}, {:kind => 1, :basic => 0, :skill_id => 305, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 14>\n<break_threshold:6>\n<break_resist:17>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        502 => {
    
          :name => "雷序追兵",
    
          :maxhp => 5200,
    
          :maxmp => 260,
    
          :atk => 105,
    
          :def => 82,
    
          :spi => 125,
    
          :agi => 135,
    
          :hit => 98,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 75,
    
          :gold => 275,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 307, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 306, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 323, :rating => 8, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 40}],
    
          :note => "<level set 18>\n<break_threshold:6>\n<break_resist:19>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        503 => {
    
          :name => "雙生療癒師",
    
          :maxhp => 6800,
    
          :maxmp => 420,
    
          :atk => 80,
    
          :def => 95,
    
          :spi => 165,
    
          :agi => 92,
    
          :hit => 98,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 75,
    
          :gold => 325,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 300, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 308, :rating => 8, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 65}, {:kind => 1, :basic => 0, :skill_id => 309, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 22>\n<break_threshold:6>\n<break_resist:21>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        504 => {
    
          :name => "裂地拳士",
    
          :maxhp => 8500,
    
          :maxmp => 200,
    
          :atk => 190,
    
          :def => 135,
    
          :spi => 70,
    
          :agi => 110,
    
          :hit => 98,
    
          :eva => 9,
    
          :has_critical => true,
    
          :exp => 75,
    
          :gold => 370,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 321, :rating => 7, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 50}, {:kind => 1, :basic => 0, :skill_id => 311, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 310, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 26>\n<break_threshold:7>\n<break_resist:23>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        505 => {
    
          :name => "夢魘術士",
    
          :maxhp => 9800,
    
          :maxmp => 520,
    
          :atk => 85,
    
          :def => 105,
    
          :spi => 225,
    
          :agi => 145,
    
          :hit => 98,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 75,
    
          :gold => 420,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 312, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 323, :rating => 8, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 35}, {:kind => 1, :basic => 0, :skill_id => 313, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 30>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        506 => {
    
          :name => "鋼翼哨兵",
    
          :maxhp => 13500,
    
          :maxmp => 280,
    
          :atk => 235,
    
          :def => 260,
    
          :spi => 100,
    
          :agi => 155,
    
          :hit => 98,
    
          :eva => 10,
    
          :has_critical => true,
    
          :exp => 75,
    
          :gold => 470,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 304, :rating => 7, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 55}, {:kind => 1, :basic => 0, :skill_id => 315, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 314, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 34>\n<break_threshold:7>\n<break_resist:27>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        507 => {
    
          :name => "腐蝕工兵",
    
          :maxhp => 15500,
    
          :maxmp => 560,
    
          :atk => 160,
    
          :def => 180,
    
          :spi => 270,
    
          :agi => 145,
    
          :hit => 98,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 75,
    
          :gold => 515,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 301, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 316, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 317, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 38>\n<break_threshold:7>\n<break_resist:29>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        508 => {
    
          :name => "共鳴獵手",
    
          :maxhp => 19000,
    
          :maxmp => 480,
    
          :atk => 285,
    
          :def => 210,
    
          :spi => 255,
    
          :agi => 210,
    
          :hit => 98,
    
          :eva => 10,
    
          :has_critical => true,
    
          :exp => 75,
    
          :gold => 565,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 339, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 338, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 318, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 42>\n<break_threshold:7>\n<break_resist:31>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        509 => {
    
          :name => "時律審判官",
    
          :maxhp => 23500,
    
          :maxmp => 620,
    
          :atk => 250,
    
          :def => 250,
    
          :spi => 340,
    
          :agi => 255,
    
          :hit => 98,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 75,
    
          :gold => 610,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 330, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 306, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 319, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 46>\n<break_threshold:7>\n<break_resist:33>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        510 => {
    
          :name => "天候祭司",
    
          :maxhp => 28000,
    
          :maxmp => 820,
    
          :atk => 220,
    
          :def => 265,
    
          :spi => 390,
    
          :agi => 225,
    
          :hit => 98,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 75,
    
          :gold => 660,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 308, :rating => 8, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 45}, {:kind => 1, :basic => 0, :skill_id => 322, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 320, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 50>\n<break_threshold:7>\n<break_resist:35>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        511 => {
    
          :name => "失序指揮官",
    
          :maxhp => 36000,
    
          :maxmp => 900,
    
          :atk => 390,
    
          :def => 320,
    
          :spi => 390,
    
          :agi => 275,
    
          :hit => 98,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 75,
    
          :gold => 720,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 323, :rating => 8, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 35}, {:kind => 1, :basic => 0, :skill_id => 321, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 322, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 55>\n<break_threshold:7>\n<break_resist:37>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        520 => {
    
          :name => "莉瑟・觀律者",
    
          :maxhp => 15000,
    
          :maxmp => 900,
    
          :atk => 150,
    
          :def => 155,
    
          :spi => 190,
    
          :agi => 150,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 300,
    
          :gold => 900,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 330, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 331, :rating => 9, :condition_type => 4, :condition_param1 => 120, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 332, :rating => 10, :condition_type => 4, :condition_param1 => 120, :condition_param2 => 0}],
    
          :note => "<level set 20>\n<break_threshold:7>\n<break_resist:18>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<observe_repeat_state:120>\n<observe_same_skill:1>\n<observe_same_element:1>\n<observe_main_actors_only>\n<fs_fixed_enemy_stats>",
    
        },
    

        521 => {
    
          :name => "赫薩・雙弦",
    
          :maxhp => 33000,
    
          :maxmp => 1200,
    
          :atk => 260,
    
          :def => 220,
    
          :spi => 300,
    
          :agi => 210,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 300,
    
          :gold => 1200,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 334, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 333, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 335, :rating => 10, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 35}],
    
          :note => "<level set 30>\n<break_threshold:8>\n<break_resist:24>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        522 => {
    
          :name => "諾維亞・改譜師",
    
          :maxhp => 62000,
    
          :maxmp => 1800,
    
          :atk => 320,
    
          :def => 300,
    
          :spi => 470,
    
          :agi => 280,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 300,
    
          :gold => 1500,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 334, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 337, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 336, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 40>\n<break_threshold:9>\n<break_resist:30>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<fs_fixed_enemy_stats>",
    
        },
    

        523 => {
    
          :name => "赫克托・召喚獵手",
    
          :maxhp => 92000,
    
          :maxmp => 1400,
    
          :atk => 560,
    
          :def => 420,
    
          :spi => 410,
    
          :agi => 380,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => true,
    
          :exp => 300,
    
          :gold => 1770,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 311, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 339, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 338, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 318, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 49>\n<break_threshold:9>\n<break_resist:34>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<殘酷>\n<fs_fixed_enemy_stats>",
    
        },
    

        524 => {
    
          :name => "賽勒斯・大諧律",
    
          :maxhp => 210000,
    
          :maxmp => 5000,
    
          :atk => 820,
    
          :def => 700,
    
          :spi => 900,
    
          :agi => 620,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 300,
    
          :gold => 2100,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 330, :rating => 7, :condition_type => 4, :condition_param1 => 150, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 333, :rating => 9, :condition_type => 4, :condition_param1 => 141, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 336, :rating => 9, :condition_type => 4, :condition_param1 => 142, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 340, :rating => 9, :condition_type => 4, :condition_param1 => 140, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 332, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 343, :rating => 10, :condition_type => 4, :condition_param1 => 143, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 344, :rating => 10, :condition_type => 4, :condition_param1 => 152, :condition_param2 => 0}],
    
          :note => "<level set 60>\n<break_threshold:10>\n<break_resist:40>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<狡詐>\n<observe_repeat_state:120>\n<observe_same_skill:1>\n<observe_same_element:1>\n<observe_main_actors_only>\n<observe_if_state:150>\n<law_cycle_states:140,141,142,143>\n<law_cycle_interval:3>\n<law_cycle_if_state:151>\n<fs_fixed_enemy_stats>",
    
        },
    

        530 => {
    
          :name => "城塞主機 BASTION-Ω",
    
          :maxhp => 68000,
    
          :maxmp => 1,
    
          :atk => 430,
    
          :def => 620,
    
          :spi => 280,
    
          :agi => 160,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => true,
    
          :exp => 450,
    
          :gold => 1760,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 351, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 352, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 350, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 353, :rating => 10, :condition_type => 4, :condition_param1 => 128, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 354, :rating => 10, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 30}],
    
          :note => "<level set 36>\n<break_threshold:9>\n<break_resist:32>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        531 => {
    
          :name => "諧律殲滅機 ORCHESTRA-0",
    
          :maxhp => 145000,
    
          :maxmp => 1,
    
          :atk => 690,
    
          :def => 620,
    
          :spi => 720,
    
          :agi => 470,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 450,
    
          :gold => 2355,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 356, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 350, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 355, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 357, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 358, :rating => 10, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 25}],
    
          :note => "<level set 53>\n<break_threshold:10>\n<break_resist:38>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        540 => {
    
          :name => "妙蛙花・古樹主",
    
          :maxhp => 12000,
    
          :maxmp => 700,
    
          :atk => 140,
    
          :def => 170,
    
          :spi => 210,
    
          :agi => 120,
    
          :hit => 100,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 500,
    
          :gold => 1160,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 300, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 400, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 401, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 14>\n<break_threshold:8>\n<break_resist:29>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        541 => {
    
          :name => "耿鬼・夢魘鐘",
    
          :maxhp => 22000,
    
          :maxmp => 1100,
    
          :atk => 120,
    
          :def => 160,
    
          :spi => 300,
    
          :agi => 240,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 500,
    
          :gold => 1480,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 312, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 402, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 403, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 313, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 22>\n<break_threshold:8>\n<break_resist:32>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        542 => {
    
          :name => "班基拉斯・沙海暴君",
    
          :maxhp => 45000,
    
          :maxmp => 900,
    
          :atk => 380,
    
          :def => 330,
    
          :spi => 180,
    
          :agi => 160,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => true,
    
          :exp => 500,
    
          :gold => 1800,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 310, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 404, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 405, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 30>\n<break_threshold:8>\n<break_resist:35>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        543 => {
    
          :name => "巨金怪・磁星核心",
    
          :maxhp => 72000,
    
          :maxmp => 1300,
    
          :atk => 440,
    
          :def => 430,
    
          :spi => 360,
    
          :agi => 240,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => true,
    
          :exp => 500,
    
          :gold => 2120,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 306, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 406, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 350, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 407, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 38>\n<break_threshold:10>\n<break_resist:37>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        544 => {
    
          :name => "美納斯・鏡潮祭主",
    
          :maxhp => 82000,
    
          :maxmp => 2200,
    
          :atk => 260,
    
          :def => 330,
    
          :spi => 520,
    
          :agi => 300,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 500,
    
          :gold => 2320,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 308, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 306, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 409, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 408, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 43>\n<break_threshold:10>\n<break_resist:39>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        545 => {
    
          :name => "暴飛龍・蒼翼災禍",
    
          :maxhp => 105000,
    
          :maxmp => 1200,
    
          :atk => 610,
    
          :def => 420,
    
          :spi => 350,
    
          :agi => 480,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => true,
    
          :exp => 500,
    
          :gold => 2520,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 321, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 410, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 411, :rating => 10, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 45}],
    
          :note => "<level set 48>\n<break_threshold:10>\n<break_resist:41>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        546 => {
    
          :name => "夢幻・萬象原型",
    
          :maxhp => 118000,
    
          :maxmp => 3000,
    
          :atk => 480,
    
          :def => 500,
    
          :spi => 600,
    
          :agi => 520,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 500,
    
          :gold => 2680,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 330, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 336, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 412, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 413, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 52>\n<break_threshold:10>\n<break_resist:42>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        547 => {
    
          :name => "超夢・基因王座",
    
          :maxhp => 155000,
    
          :maxmp => 4200,
    
          :atk => 560,
    
          :def => 550,
    
          :spi => 780,
    
          :agi => 560,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 500,
    
          :gold => 2840,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 340, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 414, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 332, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 415, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 56>\n<break_threshold:10>\n<break_resist:43>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        548 => {
    
          :name => "固拉多・原始陸地",
    
          :maxhp => 175000,
    
          :maxmp => 1800,
    
          :atk => 850,
    
          :def => 700,
    
          :spi => 300,
    
          :agi => 330,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => true,
    
          :exp => 500,
    
          :gold => 2920,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 404, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 450, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 451, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 452, :rating => 10, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 55}],
    
          :note => "<level set 58>\n<break_threshold:10>\n<break_resist:44>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        549 => {
    
          :name => "蓋歐卡・始源之海",
    
          :maxhp => 168000,
    
          :maxmp => 3600,
    
          :atk => 420,
    
          :def => 620,
    
          :spi => 900,
    
          :agi => 390,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 500,
    
          :gold => 2920,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 408, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 453, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 454, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 455, :rating => 10, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 55}],
    
          :note => "<level set 58>\n<break_threshold:10>\n<break_resist:44>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        550 => {
    
          :name => "烈空座・德爾塔天穹",
    
          :maxhp => 160000,
    
          :maxmp => 3000,
    
          :atk => 760,
    
          :def => 500,
    
          :spi => 600,
    
          :agi => 520,
    
          :hit => 100,
    
          :eva => 10,
    
          :has_critical => true,
    
          :exp => 500,
    
          :gold => 3000,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 410, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 456, :rating => 10, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 457, :rating => 9, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 458, :rating => 10, :condition_type => 2, :condition_param1 => 0, :condition_param2 => 55}],
    
          :note => "<level set 60>\n<break_threshold:10>\n<break_resist:45>\n<break_recover:1>\n<atb_dynamic_resist>\n<atb_resist_start:0>\n<atb_resist_max:4>\n<atb_resist_floor:10>\n<atb_resist_recover:1>\n<state_dynamic_resist>\n<state_dynamic_resist_states:33,44,45,46,47,49>\n<state_resist_step:25>\n<state_resist_min:10>\n<state_resist_recover:1>\n<自動技能候補>\n<戰狂>\n<target priority:1>\n<fs_fixed_enemy_stats>",
    
        },
    

        551 => {
    
          :name => "共鳴毒芽",
    
          :maxhp => 1800,
    
          :maxmp => 120,
    
          :atk => 55,
    
          :def => 70,
    
          :spi => 90,
    
          :agi => 45,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 300, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 302, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 12>\n<exp at level 12>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:2>\n<fs_fixed_enemy_stats>",
    
        },
    

        552 => {
    
          :name => "影核",
    
          :maxhp => 2600,
    
          :maxmp => 180,
    
          :atk => 60,
    
          :def => 80,
    
          :spi => 135,
    
          :agi => 110,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 312, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 22>\n<exp at level 22>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:2>\n<fs_fixed_enemy_stats>",
    
        },
    

        553 => {
    
          :name => "沙鎧碎片",
    
          :maxhp => 5200,
    
          :maxmp => 1,
    
          :atk => 150,
    
          :def => 220,
    
          :spi => 40,
    
          :agi => 65,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 304, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 30>\n<exp at level 30>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:3>\n<fs_fixed_enemy_stats>",
    
        },
    

        554 => {
    
          :name => "磁力核心",
    
          :maxhp => 7000,
    
          :maxmp => 1,
    
          :atk => 140,
    
          :def => 260,
    
          :spi => 190,
    
          :agi => 90,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 406, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 38>\n<exp at level 38>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:3>\n<fs_fixed_enemy_stats>",
    
        },
    

        555 => {
    
          :name => "潮汐珠",
    
          :maxhp => 6800,
    
          :maxmp => 500,
    
          :atk => 70,
    
          :def => 150,
    
          :spi => 260,
    
          :agi => 115,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 308, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 408, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 43>\n<exp at level 43>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:3>\n<fs_fixed_enemy_stats>",
    
        },
    

        556 => {
    
          :name => "龍翼殘影",
    
          :maxhp => 7200,
    
          :maxmp => 1,
    
          :atk => 250,
    
          :def => 140,
    
          :spi => 120,
    
          :agi => 270,
    
          :hit => 95,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 410, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 48>\n<exp at level 48>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:2>\n<fs_fixed_enemy_stats>",
    
        },
    

        557 => {
    
          :name => "觀測鏡／夢境碎片",
    
          :maxhp => 8000,
    
          :maxmp => 300,
    
          :atk => 120,
    
          :def => 170,
    
          :spi => 230,
    
          :agi => 180,
    
          :hit => 95,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 330, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 413, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 52>\n<exp at level 52>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:2>\n<fs_fixed_enemy_stats>",
    
        },
    

        558 => {
    
          :name => "日核／基因殘像",
    
          :maxhp => 11000,
    
          :maxmp => 500,
    
          :atk => 290,
    
          :def => 240,
    
          :spi => 220,
    
          :agi => 190,
    
          :hit => 95,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 404, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 414, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 58>\n<exp at level 58>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:3>\n<fs_fixed_enemy_stats>",
    
        },
    

        559 => {
    
          :name => "雨核／空白譜頁",
    
          :maxhp => 10500,
    
          :maxmp => 700,
    
          :atk => 120,
    
          :def => 220,
    
          :spi => 310,
    
          :agi => 180,
    
          :hit => 95,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 408, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 336, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 58>\n<exp at level 58>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:3>\n<fs_fixed_enemy_stats>",
    
        },
    

        560 => {
    
          :name => "亂流核／獵殺機犬",
    
          :maxhp => 12000,
    
          :maxmp => 1,
    
          :atk => 330,
    
          :def => 230,
    
          :spi => 180,
    
          :agi => 310,
    
          :hit => 95,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 410, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 338, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 339, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 60>\n<exp at level 60>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:3>\n<fs_fixed_enemy_stats>",
    
        },
    

        561 => {
    
          :name => "防衛核心",
    
          :maxhp => 9000,
    
          :maxmp => 1,
    
          :atk => 150,
    
          :def => 350,
    
          :spi => 120,
    
          :agi => 80,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 350, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 36>\n<exp at level 36>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:3>\n<fs_fixed_enemy_stats>",
    
        },
    

        562 => {
    
          :name => "攻擊模組",
    
          :maxhp => 12500,
    
          :maxmp => 1,
    
          :atk => 360,
    
          :def => 220,
    
          :spi => 180,
    
          :agi => 200,
    
          :hit => 95,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 353, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 53>\n<exp at level 53>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:2>\n<fs_fixed_enemy_stats>",
    
        },
    

        563 => {
    
          :name => "防禦模組",
    
          :maxhp => 14500,
    
          :maxmp => 1,
    
          :atk => 170,
    
          :def => 400,
    
          :spi => 180,
    
          :agi => 120,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 350, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 53>\n<exp at level 53>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:3>\n<fs_fixed_enemy_stats>",
    
        },
    

        564 => {
    
          :name => "干擾模組",
    
          :maxhp => 11000,
    
          :maxmp => 1,
    
          :atk => 130,
    
          :def => 230,
    
          :spi => 330,
    
          :agi => 260,
    
          :hit => 95,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 355, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 53>\n<exp at level 53>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:2>\n<fs_fixed_enemy_stats>",
    
        },
    

        565 => {
    
          :name => "修復模組",
    
          :maxhp => 10500,
    
          :maxmp => 1,
    
          :atk => 100,
    
          :def => 220,
    
          :spi => 350,
    
          :agi => 150,
    
          :hit => 95,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 308, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 352, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 53>\n<exp at level 53>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<target priority:3>\n<fs_fixed_enemy_stats>",
    
        },
    

      })
  end
end
