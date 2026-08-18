#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 12 Enemies Clones Robots
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 12 Enemies Clones Robots」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、ENEMIES
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / ENEMIES CLONES & ROBOTS
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
# ■ FS_MasterSetup 12 Enemies Clones Robots
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：12 / 20
# 分類用途：映體與五類機器人（ID 590～599）
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP
  module ENEMIES
    DATA.merge!({
        590 => {
    
          :name => "映體艾卓",
    
          :maxhp => 44,
    
          :maxmp => 40,
    
          :atk => 82,
    
          :def => 42,
    
          :spi => 52,
    
          :agi => 110,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<fs_growth_source>\n<hud_hide>",
    
        },
    

        591 => {
    
          :name => "映體艾薇",
    
          :maxhp => 74,
    
          :maxmp => 25,
    
          :atk => 64,
    
          :def => 100,
    
          :spi => 36,
    
          :agi => 38,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<fs_growth_source>\n<hud_hide>",
    
        },
    

        592 => {
    
          :name => "映體米亞",
    
          :maxhp => 38,
    
          :maxmp => 70,
    
          :atk => 32,
    
          :def => 38,
    
          :spi => 105,
    
          :agi => 65,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<fs_growth_source>\n<hud_hide>",
    
        },
    

        593 => {
    
          :name => "映體維娜",
    
          :maxhp => 42,
    
          :maxmp => 60,
    
          :atk => 34,
    
          :def => 42,
    
          :spi => 95,
    
          :agi => 82,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<fs_growth_source>\n<hud_hide>",
    
        },
    

        594 => {
    
          :name => "映體泰勒",
    
          :maxhp => 60,
    
          :maxmp => 30,
    
          :atk => 105,
    
          :def => 72,
    
          :spi => 28,
    
          :agi => 75,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<fs_growth_source>\n<hud_hide>",
    
        },
    

        595 => {
    
          :name => "壁壘機",
    
          :maxhp => 95,
    
          :maxmp => 1,
    
          :atk => 72,
    
          :def => 120,
    
          :spi => 55,
    
          :agi => 32,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<fs_growth_source>\n<hud_hide>",
    
        },
    

        596 => {
    
          :name => "雷序機",
    
          :maxhp => 55,
    
          :maxmp => 1,
    
          :atk => 80,
    
          :def => 52,
    
          :spi => 88,
    
          :agi => 105,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<fs_growth_source>\n<hud_hide>",
    
        },
    

        597 => {
    
          :name => "腐蝕機",
    
          :maxhp => 60,
    
          :maxmp => 1,
    
          :atk => 68,
    
          :def => 65,
    
          :spi => 110,
    
          :agi => 65,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<fs_growth_source>\n<hud_hide>",
    
        },
    

        598 => {
    
          :name => "破城機",
    
          :maxhp => 85,
    
          :maxmp => 1,
    
          :atk => 118,
    
          :def => 88,
    
          :spi => 24,
    
          :agi => 45,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<fs_growth_source>\n<hud_hide>",
    
        },
    

        599 => {
    
          :name => "淨化機",
    
          :maxhp => 70,
    
          :maxmp => 1,
    
          :atk => 62,
    
          :def => 70,
    
          :spi => 115,
    
          :agi => 58,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 0,
    
          :gold => 0,
    
          :drop1 => nil,
    
          :drop2 => nil,
    
          :actions => [{:kind => 0, :basic => 0, :skill_id => 0, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<fs_growth_source>\n<hud_hide>",
    
        },
    

      })
  end
end
