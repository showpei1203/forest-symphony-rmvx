#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 13 Enemies Pokemon A
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 13 Enemies Pokemon A」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、ENEMIES
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / ENEMIES POKEMON A
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
# ■ FS_MasterSetup 13 Enemies Pokemon A
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：13 / 20
# 分類用途：一般寶可夢敵人前半（ID 600～674）
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP
  module ENEMIES
    DATA.merge!({
        600 => {
    
          :name => "妙蛙種子",
    
          :maxhp => 45,
    
          :maxmp => 46,
    
          :atk => 49,
    
          :def => 49,
    
          :spi => 65,
    
          :agi => 45,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 50,
    
          :drop1 => {:kind => 1, :item_id => 600, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 600, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 601, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 14>\n<exp at level 14>\n<steal A:600 16%>\n<break_threshold:6>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:200>\n<capture_recipe A:220>\n<自動技能候補>\n<狡詐>",
    
        },
    

        601 => {
    
          :name => "妙蛙草",
    
          :maxhp => 60,
    
          :maxmp => 56,
    
          :atk => 62,
    
          :def => 63,
    
          :spi => 80,
    
          :agi => 60,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 110,
    
          :drop1 => {:kind => 1, :item_id => 600, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 600, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 601, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 602, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 30>\n<exp at level 30>\n<steal A:600 10%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:200>\n<capture_recipe A:220>\n<自動技能候補>\n<狡詐>",
    
        },
    

        602 => {
    
          :name => "妙蛙花",
    
          :maxhp => 80,
    
          :maxmp => 70,
    
          :atk => 82,
    
          :def => 83,
    
          :spi => 100,
    
          :agi => 80,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 42,
    
          :gold => 175,
    
          :drop1 => {:kind => 1, :item_id => 600, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 600, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 601, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 602, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 606, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 48>\n<exp at level 48>\n<steal A:600 4%>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<capture_repeat I:200>\n<capture_recipe A:220>\n<自動技能候補>\n<狡詐>",
    
        },
    

        603 => {
    
          :name => "小火龍",
    
          :maxhp => 39,
    
          :maxmp => 39,
    
          :atk => 52,
    
          :def => 43,
    
          :spi => 55,
    
          :agi => 65,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 50,
    
          :drop1 => {:kind => 1, :item_id => 601, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 607, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 608, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 14>\n<exp at level 14>\n<steal A:601 16%>\n<break_threshold:6>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:201>\n<capture_recipe A:221>\n<自動技能候補>",
    
        },
    

        604 => {
    
          :name => "火恐龍",
    
          :maxhp => 58,
    
          :maxmp => 52,
    
          :atk => 64,
    
          :def => 58,
    
          :spi => 72,
    
          :agi => 80,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 120,
    
          :drop1 => {:kind => 1, :item_id => 601, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 607, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 608, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 612, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 34>\n<exp at level 34>\n<steal A:601 10%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:201>\n<capture_recipe A:221>\n<自動技能候補>",
    
        },
    

        605 => {
    
          :name => "噴火龍",
    
          :maxhp => 78,
    
          :maxmp => 70,
    
          :atk => 84,
    
          :def => 78,
    
          :spi => 97,
    
          :agi => 100,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 42,
    
          :gold => 175,
    
          :drop1 => {:kind => 1, :item_id => 601, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 607, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 608, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 612, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 613, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 49>\n<exp at level 49>\n<steal A:601 4%>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<capture_repeat I:201>\n<capture_recipe A:221>\n<自動技能候補>",
    
        },
    

        606 => {
    
          :name => "水躍魚",
    
          :maxhp => 50,
    
          :maxmp => 35,
    
          :atk => 70,
    
          :def => 50,
    
          :spi => 50,
    
          :agi => 40,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 50,
    
          :drop1 => {:kind => 1, :item_id => 602, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 653, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 14>\n<exp at level 14>\n<steal A:602 16%>\n<break_threshold:6>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:202>\n<capture_recipe A:222>\n<自動技能候補>\n<狡詐>",
    
        },
    

        607 => {
    
          :name => "沼躍魚",
    
          :maxhp => 70,
    
          :maxmp => 45,
    
          :atk => 85,
    
          :def => 70,
    
          :spi => 65,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 120,
    
          :drop1 => {:kind => 1, :item_id => 602, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 653, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 618, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 34>\n<exp at level 34>\n<steal A:602 10%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:202>\n<capture_recipe A:222>\n<自動技能候補>\n<狡詐>",
    
        },
    

        608 => {
    
          :name => "巨沼怪",
    
          :maxhp => 100,
    
          :maxmp => 61,
    
          :atk => 110,
    
          :def => 90,
    
          :spi => 88,
    
          :agi => 60,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 180,
    
          :drop1 => {:kind => 1, :item_id => 602, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 653, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 618, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 748, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 50>\n<exp at level 50>\n<steal A:602 4%>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<capture_repeat I:202>\n<capture_recipe A:222>\n<自動技能候補>\n<狡詐>",
    
        },
    

        609 => {
    
          :name => "綠毛蟲",
    
          :maxhp => 45,
    
          :maxmp => 14,
    
          :atk => 30,
    
          :def => 35,
    
          :spi => 20,
    
          :agi => 45,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 25,
    
          :drop1 => {:kind => 1, :item_id => 603, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 768, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 5>\n<exp at level 5>\n<steal A:603 30%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:203>\n<capture_recipe A:223>\n<自動技能候補>\n<狡詐>",
    
        },
    

        610 => {
    
          :name => "鐵甲蛹",
    
          :maxhp => 50,
    
          :maxmp => 18,
    
          :atk => 20,
    
          :def => 55,
    
          :spi => 25,
    
          :agi => 30,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 45,
    
          :drop1 => {:kind => 1, :item_id => 603, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 768, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 769, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 9>\n<exp at level 9>\n<steal A:603 24%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:203>\n<capture_recipe A:223>\n<自動技能候補>\n<狡詐>",
    
        },
    

        611 => {
    
          :name => "巴大蝶",
    
          :maxhp => 60,
    
          :maxmp => 60,
    
          :atk => 45,
    
          :def => 50,
    
          :spi => 85,
    
          :agi => 70,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 42,
    
          :gold => 70,
    
          :drop1 => {:kind => 1, :item_id => 603, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 768, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 769, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 670, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 604, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 13>\n<exp at level 13>\n<steal A:603 18%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:203>\n<capture_recipe A:223>\n<自動技能候補>\n<狡詐>",
    
        },
    

        612 => {
    
          :name => "獨角蟲",
    
          :maxhp => 40,
    
          :maxmp => 14,
    
          :atk => 35,
    
          :def => 30,
    
          :spi => 20,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 25,
    
          :drop1 => {:kind => 1, :item_id => 604, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 770, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 5>\n<exp at level 5>\n<steal A:604 30%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:204>\n<capture_recipe A:224>\n<自動技能候補>\n<狡詐>",
    
        },
    

        613 => {
    
          :name => "鐵殼蛹",
    
          :maxhp => 45,
    
          :maxmp => 18,
    
          :atk => 25,
    
          :def => 50,
    
          :spi => 25,
    
          :agi => 35,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 45,
    
          :drop1 => {:kind => 1, :item_id => 604, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 770, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 769, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 9>\n<exp at level 9>\n<steal A:604 24%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:204>\n<capture_recipe A:224>\n<自動技能候補>\n<狡詐>",
    
        },
    

        614 => {
    
          :name => "大針蜂",
    
          :maxhp => 65,
    
          :maxmp => 41,
    
          :atk => 90,
    
          :def => 40,
    
          :spi => 62,
    
          :agi => 75,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 65,
    
          :drop1 => {:kind => 1, :item_id => 604, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 770, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 769, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 767, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 676, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 12>\n<exp at level 12>\n<steal A:604 18%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:204>\n<capture_recipe A:224>\n<自動技能候補>\n<狡詐>",
    
        },
    

        615 => {
    
          :name => "波波",
    
          :maxhp => 40,
    
          :maxmp => 24,
    
          :atk => 45,
    
          :def => 40,
    
          :spi => 35,
    
          :agi => 56,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 605, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 725, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 8>\n<exp at level 8>\n<steal A:605 32%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:205>\n<capture_recipe A:225>\n<自動技能候補>\n<狡詐>",
    
        },
    

        616 => {
    
          :name => "比比鳥",
    
          :maxhp => 63,
    
          :maxmp => 35,
    
          :atk => 60,
    
          :def => 55,
    
          :spi => 50,
    
          :agi => 71,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 80,
    
          :drop1 => {:kind => 1, :item_id => 605, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 725, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 613, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 20>\n<exp at level 20>\n<steal A:605 25%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:205>\n<capture_recipe A:225>\n<自動技能候補>\n<狡詐>",
    
        },
    

        617 => {
    
          :name => "比雕",
    
          :maxhp => 83,
    
          :maxmp => 49,
    
          :atk => 80,
    
          :def => 75,
    
          :spi => 70,
    
          :agi => 101,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 140,
    
          :drop1 => {:kind => 1, :item_id => 605, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 725, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 613, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 637, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 36>\n<exp at level 36>\n<steal A:605 20%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:205>\n<capture_recipe A:225>\n<自動技能候補>\n<狡詐>",
    
        },
    

        618 => {
    
          :name => "小拉達",
    
          :maxhp => 30,
    
          :maxmp => 20,
    
          :atk => 56,
    
          :def => 35,
    
          :spi => 30,
    
          :agi => 72,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => true,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 606, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 639, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 619, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 8>\n<exp at level 8>\n<steal A:606 32%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:206>\n<capture_recipe A:226>\n<自動技能候補>\n<殘酷>",
    
        },
    

        619 => {
    
          :name => "拉達",
    
          :maxhp => 55,
    
          :maxmp => 41,
    
          :atk => 81,
    
          :def => 60,
    
          :spi => 60,
    
          :agi => 97,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 80,
    
          :drop1 => {:kind => 1, :item_id => 606, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 639, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 619, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 641, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 642, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 20>\n<exp at level 20>\n<steal A:606 20%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:206>\n<capture_recipe A:226>\n<自動技能候補>\n<殘酷>",
    
        },
    

        620 => {
    
          :name => "烈雀",
    
          :maxhp => 40,
    
          :maxmp => 22,
    
          :atk => 60,
    
          :def => 30,
    
          :spi => 31,
    
          :agi => 70,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => true,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 607, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 634, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 8>\n<exp at level 8>\n<steal A:607 32%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:207>\n<capture_recipe A:227>\n<自動技能候補>\n<殘酷>",
    
        },
    

        621 => {
    
          :name => "大嘴雀",
    
          :maxhp => 65,
    
          :maxmp => 43,
    
          :atk => 90,
    
          :def => 65,
    
          :spi => 61,
    
          :agi => 100,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 80,
    
          :drop1 => {:kind => 1, :item_id => 607, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 634, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 636, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 643, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 20>\n<exp at level 20>\n<steal A:607 20%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:207>\n<capture_recipe A:227>\n<自動技能候補>\n<殘酷>",
    
        },
    

        622 => {
    
          :name => "阿柏蛇",
    
          :maxhp => 35,
    
          :maxmp => 32,
    
          :atk => 60,
    
          :def => 44,
    
          :spi => 47,
    
          :agi => 55,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 608, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 644, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 619, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 8>\n<exp at level 8>\n<steal A:608 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:208>\n<capture_recipe A:228>\n<自動技能候補>\n<狡詐>",
    
        },
    

        623 => {
    
          :name => "阿柏怪",
    
          :maxhp => 60,
    
          :maxmp => 49,
    
          :atk => 95,
    
          :def => 69,
    
          :spi => 72,
    
          :agi => 80,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 85,
    
          :drop1 => {:kind => 1, :item_id => 608, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 644, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 619, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 646, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 22>\n<exp at level 22>\n<steal A:608 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:208>\n<capture_recipe A:228>\n<自動技能候補>\n<狡詐>",
    
        },
    

        624 => {
    
          :name => "皮卡丘",
    
          :maxhp => 35,
    
          :maxmp => 35,
    
          :atk => 55,
    
          :def => 40,
    
          :spi => 50,
    
          :agi => 90,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 609, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 697, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 9>\n<exp at level 9>\n<steal A:609 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:209>\n<capture_recipe A:229>\n<自動技能候補>\n<狡詐>",
    
        },
    

        625 => {
    
          :name => "雷丘",
    
          :maxhp => 60,
    
          :maxmp => 60,
    
          :atk => 90,
    
          :def => 55,
    
          :spi => 85,
    
          :agi => 110,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 110,
    
          :drop1 => {:kind => 1, :item_id => 609, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 697, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 649, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 651, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 30>\n<exp at level 30>\n<steal A:609 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:209>\n<capture_recipe A:229>\n<自動技能候補>\n<狡詐>",
    
        },
    

        626 => {
    
          :name => "穿山鼠",
    
          :maxhp => 50,
    
          :maxmp => 17,
    
          :atk => 75,
    
          :def => 85,
    
          :spi => 25,
    
          :agi => 40,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 610, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 607, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 656, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 8>\n<exp at level 8>\n<steal A:610 32%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:210>\n<capture_recipe A:230>\n<自動技能候補>\n<殘酷>",
    
        },
    

        627 => {
    
          :name => "穿山王",
    
          :maxhp => 75,
    
          :maxmp => 34,
    
          :atk => 100,
    
          :def => 110,
    
          :spi => 50,
    
          :agi => 65,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 85,
    
          :drop1 => {:kind => 1, :item_id => 610, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 607, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 656, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 610, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 22>\n<exp at level 22>\n<steal A:610 20%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:210>\n<capture_recipe A:230>\n<自動技能候補>\n<殘酷>",
    
        },
    

        628 => {
    
          :name => "六尾",
    
          :maxhp => 38,
    
          :maxmp => 39,
    
          :atk => 41,
    
          :def => 40,
    
          :spi => 58,
    
          :agi => 65,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 40,
    
          :drop1 => {:kind => 1, :item_id => 611, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 608, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 10>\n<exp at level 10>\n<steal A:611 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:211>\n<capture_recipe A:231>\n<自動技能候補>\n<狡詐>",
    
        },
    

        629 => {
    
          :name => "九尾",
    
          :maxhp => 73,
    
          :maxmp => 62,
    
          :atk => 76,
    
          :def => 75,
    
          :spi => 90,
    
          :agi => 100,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 110,
    
          :drop1 => {:kind => 1, :item_id => 611, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 608, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 663, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 615, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 30>\n<exp at level 30>\n<steal A:611 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:211>\n<capture_recipe A:231>\n<自動技能候補>\n<狡詐>",
    
        },
    

        630 => {
    
          :name => "胖丁",
    
          :maxhp => 115,
    
          :maxmp => 26,
    
          :atk => 45,
    
          :def => 20,
    
          :spi => 35,
    
          :agi => 20,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 45,
    
          :drop1 => {:kind => 1, :item_id => 612, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 740, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 666, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 11>\n<exp at level 11>\n<steal A:612 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:212>\n<capture_recipe A:232>\n<自動技能候補>\n<治癒>",
    
        },
    

        631 => {
    
          :name => "胖可丁",
    
          :maxhp => 140,
    
          :maxmp => 50,
    
          :atk => 70,
    
          :def => 45,
    
          :spi => 68,
    
          :agi => 45,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 110,
    
          :drop1 => {:kind => 1, :item_id => 612, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 740, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 666, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 659, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 667, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 30>\n<exp at level 30>\n<steal A:612 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:212>\n<capture_recipe A:232>\n<自動技能候補>\n<治癒>",
    
        },
    

        632 => {
    
          :name => "超音蝠",
    
          :maxhp => 40,
    
          :maxmp => 24,
    
          :atk => 45,
    
          :def => 35,
    
          :spi => 35,
    
          :agi => 55,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 70,
    
          :drop1 => {:kind => 1, :item_id => 613, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 633, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 690, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 20>\n<exp at level 20>\n<steal A:613 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:213>\n<capture_recipe A:233>\n<自動技能候補>\n<殘酷>",
    
        },
    

        633 => {
    
          :name => "大嘴蝠",
    
          :maxhp => 75,
    
          :maxmp => 48,
    
          :atk => 80,
    
          :def => 70,
    
          :spi => 70,
    
          :agi => 90,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 100,
    
          :drop1 => {:kind => 1, :item_id => 613, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 633, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 690, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 613, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 26>\n<exp at level 26>\n<steal A:613 16%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:213>\n<capture_recipe A:233>\n<自動技能候補>\n<殘酷>",
    
        },
    

        634 => {
    
          :name => "叉字蝠",
    
          :maxhp => 85,
    
          :maxmp => 52,
    
          :atk => 90,
    
          :def => 80,
    
          :spi => 75,
    
          :agi => 130,
    
          :hit => 95,
    
          :eva => 10,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 150,
    
          :drop1 => {:kind => 1, :item_id => 613, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 633, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 690, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 613, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 631, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 40>\n<exp at level 40>\n<steal A:613 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:213>\n<capture_recipe A:233>\n<自動技能候補>\n<殘酷>",
    
        },
    

        635 => {
    
          :name => "走路草",
    
          :maxhp => 45,
    
          :maxmp => 50,
    
          :atk => 50,
    
          :def => 55,
    
          :spi => 70,
    
          :agi => 30,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 45,
    
          :drop1 => {:kind => 1, :item_id => 614, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 741, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 601, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 12>\n<exp at level 12>\n<steal A:614 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:214>\n<capture_recipe A:234>\n<自動技能候補>\n<狡詐>",
    
        },
    

        636 => {
    
          :name => "走路花",
    
          :maxhp => 60,
    
          :maxmp => 57,
    
          :atk => 65,
    
          :def => 70,
    
          :spi => 80,
    
          :agi => 40,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 90,
    
          :drop1 => {:kind => 1, :item_id => 614, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 741, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 601, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 604, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 23>\n<exp at level 23>\n<steal A:614 21%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:214>\n<capture_recipe A:234>\n<自動技能候補>\n<狡詐>",
    
        },
    

        637 => {
    
          :name => "霸王花",
    
          :maxhp => 75,
    
          :maxmp => 71,
    
          :atk => 80,
    
          :def => 85,
    
          :spi => 100,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 42,
    
          :gold => 140,
    
          :drop1 => {:kind => 1, :item_id => 614, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 741, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 601, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 604, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 605, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 36>\n<exp at level 36>\n<steal A:614 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:214>\n<capture_recipe A:234>\n<自動技能候補>\n<狡詐>",
    
        },
    

        638 => {
    
          :name => "派拉斯",
    
          :maxhp => 35,
    
          :maxmp => 34,
    
          :atk => 70,
    
          :def => 55,
    
          :spi => 50,
    
          :agi => 25,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 50,
    
          :drop1 => {:kind => 1, :item_id => 615, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 633, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 602, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 13>\n<exp at level 13>\n<steal A:615 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:215>\n<capture_recipe A:235>\n<自動技能候補>\n<狡詐>",
    
        },
    

        639 => {
    
          :name => "派拉斯特",
    
          :maxhp => 60,
    
          :maxmp => 48,
    
          :atk => 95,
    
          :def => 80,
    
          :spi => 70,
    
          :agi => 30,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 95,
    
          :drop1 => {:kind => 1, :item_id => 615, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 633, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 602, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 669, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 25>\n<exp at level 25>\n<steal A:615 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:215>\n<capture_recipe A:235>\n<自動技能候補>\n<狡詐>",
    
        },
    

        640 => {
    
          :name => "毛球",
    
          :maxhp => 60,
    
          :maxmp => 32,
    
          :atk => 55,
    
          :def => 50,
    
          :spi => 48,
    
          :agi => 45,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 50,
    
          :drop1 => {:kind => 1, :item_id => 616, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 670, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 601, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 14>\n<exp at level 14>\n<steal A:616 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:216>\n<capture_recipe A:236>\n<自動技能候補>\n<狡詐>",
    
        },
    

        641 => {
    
          :name => "摩魯蛾",
    
          :maxhp => 70,
    
          :maxmp => 59,
    
          :atk => 65,
    
          :def => 60,
    
          :spi => 82,
    
          :agi => 90,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 115,
    
          :drop1 => {:kind => 1, :item_id => 616, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 670, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 601, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 604, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 31>\n<exp at level 31>\n<steal A:616 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:216>\n<capture_recipe A:236>\n<自動技能候補>\n<狡詐>",
    
        },
    

        642 => {
    
          :name => "可達鴨",
    
          :maxhp => 50,
    
          :maxmp => 41,
    
          :atk => 52,
    
          :def => 48,
    
          :spi => 58,
    
          :agi => 55,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 617, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 670, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 8>\n<exp at level 8>\n<steal A:617 34%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:217>\n<capture_recipe A:237>\n<自動技能候補>\n<狡詐>",
    
        },
    

        643 => {
    
          :name => "哥達鴨",
    
          :maxhp => 80,
    
          :maxmp => 62,
    
          :atk => 82,
    
          :def => 78,
    
          :spi => 88,
    
          :agi => 85,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 120,
    
          :drop1 => {:kind => 1, :item_id => 617, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 670, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 671, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 621, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 33>\n<exp at level 33>\n<steal A:617 22%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:217>\n<capture_recipe A:237>\n<自動技能候補>\n<狡詐>",
    
        },
    

        644 => {
    
          :name => "猴怪",
    
          :maxhp => 40,
    
          :maxmp => 27,
    
          :atk => 80,
    
          :def => 35,
    
          :spi => 40,
    
          :agi => 70,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 55,
    
          :drop1 => {:kind => 1, :item_id => 618, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 674, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 676, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 15>\n<exp at level 15>\n<steal A:618 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:218>\n<capture_recipe A:238>\n<自動技能候補>\n<殘酷>",
    
        },
    

        645 => {
    
          :name => "火爆猴",
    
          :maxhp => 65,
    
          :maxmp => 45,
    
          :atk => 105,
    
          :def => 60,
    
          :spi => 65,
    
          :agi => 95,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 105,
    
          :drop1 => {:kind => 1, :item_id => 618, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 674, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 676, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 677, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 28>\n<exp at level 28>\n<steal A:618 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:218>\n<capture_recipe A:238>\n<自動技能候補>\n<殘酷>",
    
        },
    

        646 => {
    
          :name => "卡蒂狗",
    
          :maxhp => 55,
    
          :maxmp => 43,
    
          :atk => 70,
    
          :def => 45,
    
          :spi => 60,
    
          :agi => 60,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 75,
    
          :drop1 => {:kind => 1, :item_id => 619, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 619, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 608, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 21>\n<exp at level 21>\n<steal A:619 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:219>\n<capture_recipe A:239>\n<自動技能候補>\n<狡詐>",
    
        },
    

        647 => {
    
          :name => "風速狗",
    
          :maxhp => 90,
    
          :maxmp => 64,
    
          :atk => 110,
    
          :def => 80,
    
          :spi => 90,
    
          :agi => 95,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 120,
    
          :drop1 => {:kind => 1, :item_id => 619, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 619, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 608, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 662, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 679, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 33>\n<exp at level 33>\n<steal A:619 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:219>\n<capture_recipe A:239>\n<自動技能候補>\n<狡詐>",
    
        },
    

        648 => {
    
          :name => "蚊香蝌蚪",
    
          :maxhp => 40,
    
          :maxmp => 28,
    
          :atk => 50,
    
          :def => 40,
    
          :spi => 40,
    
          :agi => 90,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 60,
    
          :drop1 => {:kind => 1, :item_id => 620, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 620, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 680, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 16>\n<exp at level 16>\n<steal A:620 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:220>\n<capture_recipe A:240>\n<自動技能候補>\n<狡詐>",
    
        },
    

        649 => {
    
          :name => "蚊香君",
    
          :maxhp => 65,
    
          :maxmp => 35,
    
          :atk => 65,
    
          :def => 65,
    
          :spi => 50,
    
          :agi => 90,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 100,
    
          :drop1 => {:kind => 1, :item_id => 620, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 620, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 680, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 673, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 27>\n<exp at level 27>\n<steal A:620 21%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:220>\n<capture_recipe A:240>\n<自動技能候補>\n<狡詐>",
    
        },
    

        650 => {
    
          :name => "蚊香泳士",
    
          :maxhp => 90,
    
          :maxmp => 55,
    
          :atk => 95,
    
          :def => 95,
    
          :spi => 80,
    
          :agi => 70,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 140,
    
          :drop1 => {:kind => 1, :item_id => 620, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 620, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 680, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 673, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 654, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 36>\n<exp at level 36>\n<steal A:620 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:220>\n<capture_recipe A:240>\n<自動技能候補>\n<狡詐>",
    
        },
    

        651 => {
    
          :name => "凱西",
    
          :maxhp => 25,
    
          :maxmp => 59,
    
          :atk => 20,
    
          :def => 15,
    
          :spi => 80,
    
          :agi => 90,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 50,
    
          :drop1 => {:kind => 1, :item_id => 621, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 670, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 705, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 14>\n<exp at level 14>\n<steal A:621 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:221>\n<capture_recipe A:241>\n<自動技能候補>\n<狡詐>",
    
        },
    

        652 => {
    
          :name => "勇基拉",
    
          :maxhp => 40,
    
          :maxmp => 70,
    
          :atk => 35,
    
          :def => 30,
    
          :spi => 95,
    
          :agi => 105,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 105,
    
          :drop1 => {:kind => 1, :item_id => 621, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 670, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 705, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 685, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 28>\n<exp at level 28>\n<steal A:621 16%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:221>\n<capture_recipe A:241>\n<自動技能候補>\n<狡詐>",
    
        },
    

        653 => {
    
          :name => "胡地",
    
          :maxhp => 55,
    
          :maxmp => 83,
    
          :atk => 50,
    
          :def => 45,
    
          :spi => 115,
    
          :agi => 120,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 42,
    
          :gold => 140,
    
          :drop1 => {:kind => 1, :item_id => 621, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 670, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 705, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 685, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 686, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 36>\n<exp at level 36>\n<steal A:621 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:221>\n<capture_recipe A:241>\n<自動技能候補>\n<狡詐>",
    
        },
    

        654 => {
    
          :name => "腕力",
    
          :maxhp => 70,
    
          :maxmp => 24,
    
          :atk => 80,
    
          :def => 50,
    
          :spi => 35,
    
          :agi => 35,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 80,
    
          :drop1 => {:kind => 1, :item_id => 622, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 674, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 687, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 23>\n<exp at level 23>\n<steal A:622 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:222>\n<capture_recipe A:242>\n<自動技能候補>\n<殘酷>",
    
        },
    

        655 => {
    
          :name => "豪力",
    
          :maxhp => 80,
    
          :maxmp => 38,
    
          :atk => 100,
    
          :def => 70,
    
          :spi => 55,
    
          :agi => 45,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 110,
    
          :drop1 => {:kind => 1, :item_id => 622, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 674, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 687, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 677, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 30>\n<exp at level 30>\n<steal A:622 16%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:222>\n<capture_recipe A:242>\n<自動技能候補>\n<殘酷>",
    
        },
    

        656 => {
    
          :name => "怪力",
    
          :maxhp => 90,
    
          :maxmp => 51,
    
          :atk => 130,
    
          :def => 80,
    
          :spi => 75,
    
          :agi => 55,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 150,
    
          :drop1 => {:kind => 1, :item_id => 622, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 674, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 687, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 677, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 688, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 40>\n<exp at level 40>\n<steal A:622 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:222>\n<capture_recipe A:242>\n<自動技能候補>\n<殘酷>",
    
        },
    

        657 => {
    
          :name => "瑪瑙水母",
    
          :maxhp => 40,
    
          :maxmp => 49,
    
          :atk => 40,
    
          :def => 35,
    
          :spi => 75,
    
          :agi => 70,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 623, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 644, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 8>\n<exp at level 8>\n<steal A:623 34%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:223>\n<capture_recipe A:243>\n<自動技能候補>\n<狡詐>",
    
        },
    

        658 => {
    
          :name => "毒刺水母",
    
          :maxhp => 80,
    
          :maxmp => 67,
    
          :atk => 70,
    
          :def => 65,
    
          :spi => 100,
    
          :agi => 100,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 110,
    
          :drop1 => {:kind => 1, :item_id => 623, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 644, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 690, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 645, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 30>\n<exp at level 30>\n<steal A:623 22%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:223>\n<capture_recipe A:243>\n<自動技能候補>\n<狡詐>",
    
        },
    

        659 => {
    
          :name => "小拳石",
    
          :maxhp => 40,
    
          :maxmp => 21,
    
          :atk => 80,
    
          :def => 100,
    
          :spi => 30,
    
          :agi => 20,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 60,
    
          :drop1 => {:kind => 1, :item_id => 624, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 691, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 693, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 17>\n<exp at level 17>\n<steal A:624 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:224>\n<capture_recipe A:244>\n<自動技能候補>\n<狡詐>",
    
        },
    

        660 => {
    
          :name => "隆隆石",
    
          :maxhp => 55,
    
          :maxmp => 31,
    
          :atk => 95,
    
          :def => 115,
    
          :spi => 45,
    
          :agi => 35,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 100,
    
          :drop1 => {:kind => 1, :item_id => 624, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 691, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 693, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 618, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 27>\n<exp at level 27>\n<steal A:624 21%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:224>\n<capture_recipe A:244>\n<自動技能候補>\n<狡詐>",
    
        },
    

        661 => {
    
          :name => "隆隆岩",
    
          :maxhp => 80,
    
          :maxmp => 41,
    
          :atk => 120,
    
          :def => 130,
    
          :spi => 60,
    
          :agi => 45,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 150,
    
          :drop1 => {:kind => 1, :item_id => 624, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 691, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 693, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 618, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 655, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 40>\n<exp at level 40>\n<steal A:624 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:224>\n<capture_recipe A:244>\n<自動技能候補>\n<狡詐>",
    
        },
    

        662 => {
    
          :name => "小火馬",
    
          :maxhp => 50,
    
          :maxmp => 46,
    
          :atk => 85,
    
          :def => 55,
    
          :spi => 65,
    
          :agi => 90,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 65,
    
          :drop1 => {:kind => 1, :item_id => 625, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 608, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 695, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 18>\n<exp at level 18>\n<steal A:625 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:225>\n<capture_recipe A:245>\n<自動技能候補>\n<狡詐>",
    
        },
    

        663 => {
    
          :name => "烈焰馬",
    
          :maxhp => 65,
    
          :maxmp => 56,
    
          :atk => 100,
    
          :def => 70,
    
          :spi => 80,
    
          :agi => 105,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 140,
    
          :drop1 => {:kind => 1, :item_id => 625, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 608, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 695, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 662, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 615, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 40>\n<exp at level 40>\n<steal A:625 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:225>\n<capture_recipe A:245>\n<自動技能候補>\n<狡詐>",
    
        },
    

        664 => {
    
          :name => "小磁怪",
    
          :maxhp => 25,
    
          :maxmp => 55,
    
          :atk => 35,
    
          :def => 70,
    
          :spi => 75,
    
          :agi => 45,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 95,
    
          :drop1 => {:kind => 1, :item_id => 626, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 697, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 764, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 28>\n<exp at level 28>\n<steal A:626 19%>\n<break_threshold:5>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:226>\n<capture_recipe A:246>\n<自動技能候補>\n<狡詐>",
    
        },
    

        665 => {
    
          :name => "三合一磁怪",
    
          :maxhp => 50,
    
          :maxmp => 70,
    
          :atk => 60,
    
          :def => 95,
    
          :spi => 95,
    
          :agi => 70,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 135,
    
          :drop1 => {:kind => 1, :item_id => 626, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 697, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 764, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 649, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 38>\n<exp at level 38>\n<steal A:626 13%>\n<break_threshold:5>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:226>\n<capture_recipe A:246>\n<自動技能候補>\n<狡詐>",
    
        },
    

        666 => {
    
          :name => "自爆磁怪",
    
          :maxhp => 70,
    
          :maxmp => 80,
    
          :atk => 70,
    
          :def => 115,
    
          :spi => 110,
    
          :agi => 60,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 42,
    
          :gold => 165,
    
          :drop1 => {:kind => 1, :item_id => 626, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 697, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 764, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 649, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 651, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 45>\n<exp at level 45>\n<steal A:626 7%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:226>\n<capture_recipe A:246>\n<自動技能候補>\n<狡詐>",
    
        },
    

        667 => {
    
          :name => "嘟嘟",
    
          :maxhp => 35,
    
          :maxmp => 24,
    
          :atk => 85,
    
          :def => 45,
    
          :spi => 35,
    
          :agi => 75,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 627, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 634, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 8>\n<exp at level 8>\n<steal A:627 32%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:227>\n<capture_recipe A:247>\n<自動技能候補>\n<殘酷>",
    
        },
    

        668 => {
    
          :name => "嘟嘟利",
    
          :maxhp => 60,
    
          :maxmp => 42,
    
          :atk => 110,
    
          :def => 70,
    
          :spi => 60,
    
          :agi => 110,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 115,
    
          :drop1 => {:kind => 1, :item_id => 627, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 634, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 661, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 31>\n<exp at level 31>\n<steal A:627 20%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:227>\n<capture_recipe A:247>\n<自動技能候補>\n<殘酷>",
    
        },
    

        669 => {
    
          :name => "臭泥",
    
          :maxhp => 80,
    
          :maxmp => 31,
    
          :atk => 80,
    
          :def => 50,
    
          :spi => 45,
    
          :agi => 25,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 80,
    
          :drop1 => {:kind => 1, :item_id => 628, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 658, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 700, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 24>\n<exp at level 24>\n<steal A:628 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:228>\n<capture_recipe A:248>\n<自動技能候補>\n<狡詐>",
    
        },
    

        670 => {
    
          :name => "臭臭泥",
    
          :maxhp => 105,
    
          :maxmp => 55,
    
          :atk => 105,
    
          :def => 75,
    
          :spi => 82,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 135,
    
          :drop1 => {:kind => 1, :item_id => 628, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 658, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 700, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 632, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 645, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 38>\n<exp at level 38>\n<steal A:628 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:228>\n<capture_recipe A:248>\n<自動技能候補>\n<狡詐>",
    
        },
    

        671 => {
    
          :name => "鬼斯",
    
          :maxhp => 30,
    
          :maxmp => 52,
    
          :atk => 35,
    
          :def => 30,
    
          :spi => 68,
    
          :agi => 80,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 80,
    
          :drop1 => {:kind => 1, :item_id => 629, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 702, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 665, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 23>\n<exp at level 23>\n<steal A:629 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:229>\n<capture_recipe A:249>\n<自動技能候補>\n<狡詐>",
    
        },
    

        672 => {
    
          :name => "鬼斯通",
    
          :maxhp => 45,
    
          :maxmp => 64,
    
          :atk => 50,
    
          :def => 45,
    
          :spi => 85,
    
          :agi => 95,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 115,
    
          :drop1 => {:kind => 1, :item_id => 629, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 702, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 665, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 680, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 31>\n<exp at level 31>\n<steal A:629 16%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:229>\n<capture_recipe A:249>\n<自動技能候補>\n<狡詐>",
    
        },
    

        673 => {
    
          :name => "耿鬼",
    
          :maxhp => 60,
    
          :maxmp => 76,
    
          :atk => 65,
    
          :def => 60,
    
          :spi => 102,
    
          :agi => 110,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 42,
    
          :gold => 150,
    
          :drop1 => {:kind => 1, :item_id => 629, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 702, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 665, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 680, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 701, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 40>\n<exp at level 40>\n<steal A:629 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:229>\n<capture_recipe A:249>\n<自動技能候補>\n<狡詐>",
    
        },
    

        674 => {
    
          :name => "催眠貘",
    
          :maxhp => 60,
    
          :maxmp => 43,
    
          :atk => 48,
    
          :def => 45,
    
          :spi => 66,
    
          :agi => 42,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 80,
    
          :drop1 => {:kind => 1, :item_id => 630, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 670, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 680, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 671, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 24>\n<exp at level 24>\n<steal A:630 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:230>\n<capture_recipe A:250>\n<自動技能候補>\n<狡詐>",
    
        },
    

      })
  end
end
