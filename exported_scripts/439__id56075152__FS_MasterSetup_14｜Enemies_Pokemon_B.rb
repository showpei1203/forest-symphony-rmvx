#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 14 Enemies Pokemon B
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 14 Enemies Pokemon B」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、ENEMIES
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：FIXED_BALANCE_OVERRIDES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / ENEMIES POKEMON B
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
# ■ FS_MasterSetup 14 Enemies Pokemon B
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：14 / 20
# 分類用途：一般寶可夢敵人後半（ID 675～745）與敵人平衡覆寫
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP
  module ENEMIES
    DATA.merge!({
        675 => {
    
          :name => "引夢貘人",
    
          :maxhp => 85,
    
          :maxmp => 63,
    
          :atk => 73,
    
          :def => 70,
    
          :spi => 94,
    
          :agi => 67,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 135,
    
          :drop1 => {:kind => 1, :item_id => 630, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 670, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 680, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 671, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 686, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 38>\n<exp at level 38>\n<steal A:630 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:230>\n<capture_recipe A:250>\n<自動技能候補>\n<狡詐>",
    
        },
    

        676 => {
    
          :name => "霹靂電球",
    
          :maxhp => 40,
    
          :maxmp => 38,
    
          :atk => 30,
    
          :def => 50,
    
          :spi => 55,
    
          :agi => 100,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 631, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 697, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 704, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 8>\n<exp at level 8>\n<steal A:631 32%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:231>\n<capture_recipe A:251>\n<自動技能候補>\n<狡詐>",
    
        },
    

        677 => {
    
          :name => "頑皮雷彈",
    
          :maxhp => 60,
    
          :maxmp => 56,
    
          :atk => 50,
    
          :def => 70,
    
          :spi => 80,
    
          :agi => 150,
    
          :hit => 95,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 110,
    
          :drop1 => {:kind => 1, :item_id => 631, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 697, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 704, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 649, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 731, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 30>\n<exp at level 30>\n<steal A:631 20%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:231>\n<capture_recipe A:251>\n<自動技能候補>\n<狡詐>",
    
        },
    

        678 => {
    
          :name => "卡拉卡拉",
    
          :maxhp => 50,
    
          :maxmp => 31,
    
          :atk => 50,
    
          :def => 95,
    
          :spi => 45,
    
          :agi => 35,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 90,
    
          :drop1 => {:kind => 1, :item_id => 632, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 652, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 706, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 707, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 26>\n<exp at level 26>\n<steal A:632 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:232>\n<capture_recipe A:252>\n<自動技能候補>\n<殘酷>",
    
        },
    

        679 => {
    
          :name => "嘎啦嘎啦",
    
          :maxhp => 60,
    
          :maxmp => 43,
    
          :atk => 80,
    
          :def => 110,
    
          :spi => 65,
    
          :agi => 45,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 135,
    
          :drop1 => {:kind => 1, :item_id => 632, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 652, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 706, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 707, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 655, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 39>\n<exp at level 39>\n<steal A:632 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:232>\n<capture_recipe A:252>\n<自動技能候補>\n<殘酷>",
    
        },
    

        680 => {
    
          :name => "菊石獸",
    
          :maxhp => 35,
    
          :maxmp => 53,
    
          :atk => 40,
    
          :def => 100,
    
          :spi => 72,
    
          :agi => 35,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 95,
    
          :drop1 => {:kind => 1, :item_id => 633, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 691, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 28>\n<exp at level 28>\n<steal A:633 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:233>\n<capture_recipe A:253>\n<自動技能候補>\n<狡詐>",
    
        },
    

        681 => {
    
          :name => "多刺菊石獸",
    
          :maxhp => 70,
    
          :maxmp => 68,
    
          :atk => 60,
    
          :def => 125,
    
          :spi => 92,
    
          :agi => 55,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 140,
    
          :drop1 => {:kind => 1, :item_id => 633, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 691, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 715, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 623, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 40>\n<exp at level 40>\n<steal A:633 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:233>\n<capture_recipe A:253>\n<自動技能候補>\n<狡詐>",
    
        },
    

        682 => {
    
          :name => "化石盔",
    
          :maxhp => 30,
    
          :maxmp => 36,
    
          :atk => 80,
    
          :def => 90,
    
          :spi => 50,
    
          :agi => 55,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 95,
    
          :drop1 => {:kind => 1, :item_id => 634, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 607, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 617, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 29>\n<exp at level 29>\n<steal A:634 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:234>\n<capture_recipe A:254>\n<自動技能候補>\n<殘酷>",
    
        },
    

        683 => {
    
          :name => "鐮刀盔",
    
          :maxhp => 60,
    
          :maxmp => 47,
    
          :atk => 115,
    
          :def => 105,
    
          :spi => 68,
    
          :agi => 80,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 145,
    
          :drop1 => {:kind => 1, :item_id => 634, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 607, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 617, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 610, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 709, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 41>\n<exp at level 41>\n<steal A:634 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:234>\n<capture_recipe A:254>\n<自動技能候補>\n<殘酷>",
    
        },
    

        684 => {
    
          :name => "超夢",
    
          :maxhp => 106,
    
          :maxmp => 90,
    
          :atk => 110,
    
          :def => 90,
    
          :spi => 122,
    
          :agi => 130,
    
          :hit => 95,
    
          :eva => 10,
    
          :has_critical => false,
    
          :exp => 60,
    
          :gold => 230,
    
          :drop1 => {:kind => 1, :item_id => 635, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 670, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 684, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 685, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 682, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 56>\n<exp at level 56>\n<steal A:635 1%>\n<break_threshold:12>\n<break_resist:60>\n<break_recover:1>\n<capture_repeat I:235>\n<capture_recipe A:255>\n<自動技能候補>\n<狡詐>",
    
        },
    

        685 => {
    
          :name => "夢幻",
    
          :maxhp => 100,
    
          :maxmp => 70,
    
          :atk => 100,
    
          :def => 100,
    
          :spi => 100,
    
          :agi => 100,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 60,
    
          :gold => 230,
    
          :drop1 => {:kind => 1, :item_id => 636, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 740, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 626, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 686, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 720, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 57>\n<exp at level 57>\n<steal A:636 1%>\n<break_threshold:10>\n<break_resist:50>\n<break_recover:1>\n<capture_repeat I:236>\n<capture_recipe A:256>\n<自動技能候補>\n<殘酷>",
    
        },
    

        686 => {
    
          :name => "尾立",
    
          :maxhp => 35,
    
          :maxmp => 27,
    
          :atk => 46,
    
          :def => 34,
    
          :spi => 40,
    
          :agi => 20,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 637, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 8>\n<exp at level 8>\n<steal A:637 32%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:237>\n<capture_recipe A:257>\n<自動技能候補>\n<殘酷>",
    
        },
    

        687 => {
    
          :name => "大尾立",
    
          :maxhp => 85,
    
          :maxmp => 34,
    
          :atk => 76,
    
          :def => 64,
    
          :spi => 50,
    
          :agi => 90,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 65,
    
          :drop1 => {:kind => 1, :item_id => 637, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 639, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 722, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 724, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 15>\n<exp at level 15>\n<steal A:637 20%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:237>\n<capture_recipe A:257>\n<自動技能候補>\n<殘酷>",
    
        },
    

        688 => {
    
          :name => "圓絲蛛",
    
          :maxhp => 40,
    
          :maxmp => 28,
    
          :atk => 60,
    
          :def => 40,
    
          :spi => 40,
    
          :agi => 30,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 35,
    
          :drop1 => {:kind => 1, :item_id => 638, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 770, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 768, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 8>\n<exp at level 8>\n<steal A:638 32%>\n<break_threshold:2>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:238>\n<capture_recipe A:258>\n<自動技能候補>\n<狡詐>",
    
        },
    

        689 => {
    
          :name => "阿利多斯",
    
          :maxhp => 70,
    
          :maxmp => 45,
    
          :atk => 90,
    
          :def => 70,
    
          :spi => 65,
    
          :agi => 40,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 85,
    
          :drop1 => {:kind => 1, :item_id => 638, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 770, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 768, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 726, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 628, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 22>\n<exp at level 22>\n<steal A:638 20%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:238>\n<capture_recipe A:258>\n<自動技能候補>\n<狡詐>",
    
        },
    

        690 => {
    
          :name => "波克比",
    
          :maxhp => 35,
    
          :maxmp => 35,
    
          :atk => 20,
    
          :def => 65,
    
          :spi => 52,
    
          :agi => 20,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 65,
    
          :drop1 => {:kind => 1, :item_id => 639, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 626, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 660, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 18>\n<exp at level 18>\n<steal A:639 19%>\n<break_threshold:5>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:239>\n<capture_recipe A:259>\n<自動技能候補>\n<治癒>",
    
        },
    

        691 => {
    
          :name => "波克基古",
    
          :maxhp => 55,
    
          :maxmp => 63,
    
          :atk => 40,
    
          :def => 85,
    
          :spi => 92,
    
          :agi => 40,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 135,
    
          :drop1 => {:kind => 1, :item_id => 639, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 626, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 660, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 659, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 38>\n<exp at level 38>\n<steal A:639 13%>\n<break_threshold:5>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:239>\n<capture_recipe A:259>\n<自動技能候補>\n<治癒>",
    
        },
    

        692 => {
    
          :name => "波克基斯",
    
          :maxhp => 85,
    
          :maxmp => 83,
    
          :atk => 50,
    
          :def => 95,
    
          :spi => 118,
    
          :agi => 80,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 42,
    
          :gold => 165,
    
          :drop1 => {:kind => 1, :item_id => 639, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 626, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 660, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 659, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 765, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 45>\n<exp at level 45>\n<steal A:639 7%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:239>\n<capture_recipe A:259>\n<自動技能候補>\n<治癒>",
    
        },
    

        693 => {
    
          :name => "夢妖",
    
          :maxhp => 60,
    
          :maxmp => 59,
    
          :atk => 60,
    
          :def => 60,
    
          :spi => 85,
    
          :agi => 85,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 110,
    
          :drop1 => {:kind => 1, :item_id => 640, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 702, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 665, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 683, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 34>\n<exp at level 34>\n<steal A:640 19%>\n<break_threshold:5>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:240>\n<capture_recipe A:260>\n<自動技能候補>\n<狡詐>",
    
        },
    

        694 => {
    
          :name => "夢妖魔",
    
          :maxhp => 60,
    
          :maxmp => 74,
    
          :atk => 60,
    
          :def => 60,
    
          :spi => 105,
    
          :agi => 105,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 160,
    
          :drop1 => {:kind => 1, :item_id => 640, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 702, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 665, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 683, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 701, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 46>\n<exp at level 46>\n<steal A:640 7%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:240>\n<capture_recipe A:260>\n<自動技能候補>\n<狡詐>",
    
        },
    

        695 => {
    
          :name => "小福蛋",
    
          :maxhp => 100,
    
          :maxmp => 24,
    
          :atk => 5,
    
          :def => 5,
    
          :spi => 40,
    
          :agi => 30,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 95,
    
          :drop1 => {:kind => 1, :item_id => 641, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 740, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 660, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 705, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 28>\n<exp at level 28>\n<steal A:641 18%>\n<break_threshold:5>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:241>\n<capture_recipe A:261>\n<自動技能候補>\n<治癒>",
    
        },
    

        696 => {
    
          :name => "幸福蛋",
    
          :maxhp => 255,
    
          :maxmp => 69,
    
          :atk => 10,
    
          :def => 10,
    
          :spi => 105,
    
          :agi => 55,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 160,
    
          :drop1 => {:kind => 1, :item_id => 641, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 740, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 660, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 705, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 710, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 47>\n<exp at level 47>\n<steal A:641 6%>\n<break_threshold:6>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:241>\n<capture_recipe A:261>\n<自動技能候補>\n<治癒>",
    
        },
    

        697 => {
    
          :name => "雷公",
    
          :maxhp => 90,
    
          :maxmp => 76,
    
          :atk => 85,
    
          :def => 75,
    
          :spi => 108,
    
          :agi => 115,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 60,
    
          :gold => 235,
    
          :drop1 => {:kind => 1, :item_id => 642, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 697, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 649, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 685, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 650, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 58>\n<exp at level 58>\n<steal A:642 1%>\n<break_threshold:10>\n<break_resist:50>\n<break_recover:1>\n<capture_repeat I:242>\n<capture_recipe A:262>\n<自動技能候補>\n<狡詐>",
    
        },
    

        698 => {
    
          :name => "炎帝",
    
          :maxhp => 115,
    
          :maxmp => 59,
    
          :atk => 115,
    
          :def => 85,
    
          :spi => 82,
    
          :agi => 100,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => true,
    
          :exp => 60,
    
          :gold => 235,
    
          :drop1 => {:kind => 1, :item_id => 643, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 608, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 736, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 695, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 615, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 59>\n<exp at level 59>\n<steal A:643 1%>\n<break_threshold:10>\n<break_resist:50>\n<break_recover:1>\n<capture_repeat I:243>\n<capture_recipe A:263>\n<自動技能候補>\n<殘酷>",
    
        },
    

        699 => {
    
          :name => "水君",
    
          :maxhp => 100,
    
          :maxmp => 70,
    
          :atk => 75,
    
          :def => 115,
    
          :spi => 102,
    
          :agi => 85,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 60,
    
          :gold => 240,
    
          :drop1 => {:kind => 1, :item_id => 644, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 752, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 681, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 685, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 623, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 60>\n<exp at level 60>\n<steal A:644 1%>\n<break_threshold:10>\n<break_resist:50>\n<break_recover:1>\n<capture_repeat I:244>\n<capture_recipe A:264>\n<自動技能候補>\n<狡詐>",
    
        },
    

        700 => {
    
          :name => "幼基拉斯",
    
          :maxhp => 50,
    
          :maxmp => 33,
    
          :atk => 64,
    
          :def => 50,
    
          :spi => 48,
    
          :agi => 41,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 95,
    
          :drop1 => {:kind => 1, :item_id => 645, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 619, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 691, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 28>\n<exp at level 28>\n<steal A:645 15%>\n<break_threshold:7>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:245>\n<capture_recipe A:265>\n<自動技能候補>\n<狡詐>",
    
        },
    

        701 => {
    
          :name => "沙基拉斯",
    
          :maxhp => 70,
    
          :maxmp => 47,
    
          :atk => 84,
    
          :def => 70,
    
          :spi => 68,
    
          :agi => 51,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 155,
    
          :drop1 => {:kind => 1, :item_id => 645, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 619, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 691, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 657, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 45>\n<exp at level 45>\n<steal A:645 9%>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<capture_repeat I:245>\n<capture_recipe A:265>\n<自動技能候補>\n<狡詐>",
    
        },
    

        702 => {
    
          :name => "班基拉斯",
    
          :maxhp => 100,
    
          :maxmp => 68,
    
          :atk => 134,
    
          :def => 110,
    
          :spi => 98,
    
          :agi => 61,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 195,
    
          :drop1 => {:kind => 1, :item_id => 645, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 619, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 691, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 657, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 640, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 55>\n<exp at level 55>\n<steal A:645 3%>\n<break_threshold:8>\n<break_resist:35>\n<break_recover:1>\n<capture_repeat I:245>\n<capture_recipe A:265>\n<自動技能候補>\n<狡詐>",
    
        },
    

        703 => {
    
          :name => "蓮葉童子",
    
          :maxhp => 40,
    
          :maxmp => 31,
    
          :atk => 30,
    
          :def => 30,
    
          :spi => 45,
    
          :agi => 30,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 45,
    
          :drop1 => {:kind => 1, :item_id => 646, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 741, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 12>\n<exp at level 12>\n<steal A:646 19%>\n<break_threshold:5>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:246>\n<capture_recipe A:266>\n<自動技能候補>\n<治癒>",
    
        },
    

        704 => {
    
          :name => "蓮帽小童",
    
          :maxhp => 60,
    
          :maxmp => 45,
    
          :atk => 50,
    
          :def => 50,
    
          :spi => 65,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 120,
    
          :drop1 => {:kind => 1, :item_id => 646, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 741, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 673, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 34>\n<exp at level 34>\n<steal A:646 13%>\n<break_threshold:5>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:246>\n<capture_recipe A:266>\n<自動技能候補>\n<治癒>",
    
        },
    

        705 => {
    
          :name => "樂天河童",
    
          :maxhp => 80,
    
          :maxmp => 66,
    
          :atk => 70,
    
          :def => 70,
    
          :spi => 95,
    
          :agi => 70,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 42,
    
          :gold => 175,
    
          :drop1 => {:kind => 1, :item_id => 646, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 741, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 673, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 605, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 48>\n<exp at level 48>\n<steal A:646 7%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:246>\n<capture_recipe A:266>\n<自動技能候補>\n<治癒>",
    
        },
    

        706 => {
    
          :name => "長翅鷗",
    
          :maxhp => 40,
    
          :maxmp => 31,
    
          :atk => 30,
    
          :def => 30,
    
          :spi => 42,
    
          :agi => 85,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 65,
    
          :drop1 => {:kind => 1, :item_id => 647, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 725, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 690, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 19>\n<exp at level 19>\n<steal A:647 27%>\n<break_threshold:3>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:247>\n<capture_recipe A:267>\n<自動技能候補>\n<狡詐>",
    
        },
    

        707 => {
    
          :name => "大嘴鷗",
    
          :maxhp => 60,
    
          :maxmp => 59,
    
          :atk => 50,
    
          :def => 100,
    
          :spi => 82,
    
          :agi => 65,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 115,
    
          :drop1 => {:kind => 1, :item_id => 647, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 725, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 690, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 765, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 31>\n<exp at level 31>\n<steal A:647 15%>\n<break_threshold:4>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:247>\n<capture_recipe A:267>\n<自動技能候補>\n<狡詐>",
    
        },
    

        708 => {
    
          :name => "幕下力士",
    
          :maxhp => 72,
    
          :maxmp => 17,
    
          :atk => 60,
    
          :def => 30,
    
          :spi => 25,
    
          :agi => 25,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 75,
    
          :drop1 => {:kind => 1, :item_id => 648, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 749, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 687, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 750, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 22>\n<exp at level 22>\n<steal A:648 19%>\n<break_threshold:5>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:248>\n<capture_recipe A:268>\n<自動技能候補>\n<狡詐>",
    
        },
    

        709 => {
    
          :name => "鐵掌力士",
    
          :maxhp => 144,
    
          :maxmp => 34,
    
          :atk => 120,
    
          :def => 60,
    
          :spi => 50,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 165,
    
          :drop1 => {:kind => 1, :item_id => 648, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 749, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 687, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 750, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 688, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 49>\n<exp at level 49>\n<steal A:648 7%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:248>\n<capture_recipe A:268>\n<自動技能候補>\n<狡詐>",
    
        },
    

        710 => {
    
          :name => "大嘴娃",
    
          :maxhp => 50,
    
          :maxmp => 38,
    
          :atk => 85,
    
          :def => 85,
    
          :spi => 55,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => true,
    
          :exp => 36,
    
          :gold => 180,
    
          :drop1 => {:kind => 1, :item_id => 649, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 619, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 751, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 640, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 732, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 50>\n<exp at level 50>\n<steal A:649 7%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:249>\n<capture_recipe A:269>\n<自動技能候補>\n<狡詐>",
    
        },
    

        711 => {
    
          :name => "可可多拉",
    
          :maxhp => 50,
    
          :maxmp => 28,
    
          :atk => 70,
    
          :def => 100,
    
          :spi => 40,
    
          :agi => 30,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 100,
    
          :drop1 => {:kind => 1, :item_id => 650, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 698, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 30>\n<exp at level 30>\n<steal A:650 19%>\n<break_threshold:5>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:250>\n<capture_recipe A:270>\n<自動技能候補>\n<狡詐>",
    
        },
    

        712 => {
    
          :name => "可多拉",
    
          :maxhp => 60,
    
          :maxmp => 35,
    
          :atk => 90,
    
          :def => 140,
    
          :spi => 50,
    
          :agi => 40,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 155,
    
          :drop1 => {:kind => 1, :item_id => 650, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 698, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 751, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 45>\n<exp at level 45>\n<steal A:650 13%>\n<break_threshold:5>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:250>\n<capture_recipe A:270>\n<自動技能候補>\n<狡詐>",
    
        },
    

        713 => {
    
          :name => "波士可多拉",
    
          :maxhp => 70,
    
          :maxmp => 42,
    
          :atk => 110,
    
          :def => 180,
    
          :spi => 60,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 185,
    
          :drop1 => {:kind => 1, :item_id => 650, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 698, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 751, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 709, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 51>\n<exp at level 51>\n<steal A:650 7%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:250>\n<capture_recipe A:270>\n<自動技能候補>\n<狡詐>",
    
        },
    

        714 => {
    
          :name => "利牙魚",
    
          :maxhp => 45,
    
          :maxmp => 33,
    
          :atk => 90,
    
          :def => 20,
    
          :spi => 42,
    
          :agi => 65,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 95,
    
          :drop1 => {:kind => 1, :item_id => 651, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 619, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 611, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 640, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 28>\n<exp at level 28>\n<steal A:651 19%>\n<break_threshold:5>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:251>\n<capture_recipe A:271>\n<自動技能候補>\n<殘酷>",
    
        },
    

        715 => {
    
          :name => "巨牙鯊",
    
          :maxhp => 70,
    
          :maxmp => 51,
    
          :atk => 120,
    
          :def => 40,
    
          :spi => 68,
    
          :agi => 95,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 175,
    
          :drop1 => {:kind => 1, :item_id => 651, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 619, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 611, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 640, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 672, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 52>\n<exp at level 52>\n<steal A:651 7%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:251>\n<capture_recipe A:271>\n<自動技能候補>\n<殘酷>",
    
        },
    

        716 => {
    
          :name => "醜醜魚",
    
          :maxhp => 20,
    
          :maxmp => 20,
    
          :atk => 15,
    
          :def => 20,
    
          :spi => 32,
    
          :agi => 80,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 110,
    
          :drop1 => {:kind => 1, :item_id => 652, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 771, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 616, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 752, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 33>\n<exp at level 33>\n<steal A:652 19%>\n<break_threshold:5>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:252>\n<capture_recipe A:272>\n<自動技能候補>\n<治癒>",
    
        },
    

        717 => {
    
          :name => "美納斯",
    
          :maxhp => 95,
    
          :maxmp => 77,
    
          :atk => 60,
    
          :def => 79,
    
          :spi => 112,
    
          :agi => 81,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 180,
    
          :drop1 => {:kind => 1, :item_id => 652, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 771, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 616, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 752, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 684, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 53>\n<exp at level 53>\n<steal A:652 7%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:252>\n<capture_recipe A:272>\n<自動技能候補>\n<治癒>",
    
        },
    

        718 => {
    
          :name => "夜巡靈",
    
          :maxhp => 20,
    
          :maxmp => 38,
    
          :atk => 40,
    
          :def => 90,
    
          :spi => 60,
    
          :agi => 25,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 115,
    
          :drop1 => {:kind => 1, :item_id => 653, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 702, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 663, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 35>\n<exp at level 35>\n<steal A:653 19%>\n<break_threshold:5>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:253>\n<capture_recipe A:273>\n<自動技能候補>\n<狡詐>",
    
        },
    

        719 => {
    
          :name => "彷徨夜靈",
    
          :maxhp => 40,
    
          :maxmp => 62,
    
          :atk => 70,
    
          :def => 130,
    
          :spi => 95,
    
          :agi => 25,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 165,
    
          :drop1 => {:kind => 1, :item_id => 653, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 702, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 663, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 728, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 48>\n<exp at level 48>\n<steal A:653 13%>\n<break_threshold:5>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:253>\n<capture_recipe A:273>\n<自動技能候補>\n<狡詐>",
    
        },
    

        720 => {
    
          :name => "黑夜魔靈",
    
          :maxhp => 45,
    
          :maxmp => 65,
    
          :atk => 100,
    
          :def => 135,
    
          :spi => 100,
    
          :agi => 45,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 42,
    
          :gold => 190,
    
          :drop1 => {:kind => 1, :item_id => 653, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 702, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 663, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 728, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 701, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 54>\n<exp at level 54>\n<steal A:653 7%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:253>\n<capture_recipe A:273>\n<自動技能候補>\n<狡詐>",
    
        },
    

        721 => {
    
          :name => "阿勃梭魯",
    
          :maxhp => 65,
    
          :maxmp => 48,
    
          :atk => 130,
    
          :def => 60,
    
          :spi => 68,
    
          :agi => 75,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => true,
    
          :exp => 36,
    
          :gold => 195,
    
          :drop1 => {:kind => 1, :item_id => 654, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 639, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 753, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 610, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 640, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 55>\n<exp at level 55>\n<steal A:654 7%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:254>\n<capture_recipe A:274>\n<自動技能候補>\n<殘酷>",
    
        },
    

        722 => {
    
          :name => "寶貝龍",
    
          :maxhp => 45,
    
          :maxmp => 25,
    
          :atk => 75,
    
          :def => 60,
    
          :spi => 35,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 95,
    
          :drop1 => {:kind => 1, :item_id => 655, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 619, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 706, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 28>\n<exp at level 28>\n<steal A:655 15%>\n<break_threshold:7>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:255>\n<capture_recipe A:275>\n<自動技能候補>\n<殘酷>",
    
        },
    

        723 => {
    
          :name => "甲殼龍",
    
          :maxhp => 65,
    
          :maxmp => 39,
    
          :atk => 95,
    
          :def => 100,
    
          :spi => 55,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 160,
    
          :drop1 => {:kind => 1, :item_id => 655, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 619, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 706, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 718, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 46>\n<exp at level 46>\n<steal A:655 9%>\n<break_threshold:7>\n<break_resist:20>\n<break_recover:1>\n<capture_repeat I:255>\n<capture_recipe A:275>\n<自動技能候補>\n<殘酷>",
    
        },
    

        724 => {
    
          :name => "暴飛龍",
    
          :maxhp => 95,
    
          :maxmp => 69,
    
          :atk => 135,
    
          :def => 80,
    
          :spi => 95,
    
          :agi => 100,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 185,
    
          :drop1 => {:kind => 1, :item_id => 655, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 619, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 706, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 718, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 614, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 52>\n<exp at level 52>\n<steal A:655 3%>\n<break_threshold:8>\n<break_resist:30>\n<break_recover:1>\n<capture_repeat I:255>\n<capture_recipe A:275>\n<自動技能候補>\n<殘酷>",
    
        },
    

        725 => {
    
          :name => "鐵啞鈴",
    
          :maxhp => 40,
    
          :maxmp => 31,
    
          :atk => 55,
    
          :def => 80,
    
          :spi => 48,
    
          :agi => 30,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 65,
    
          :drop1 => {:kind => 1, :item_id => 656, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 698, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 18>\n<exp at level 18>\n<steal A:656 15%>\n<break_threshold:7>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:256>\n<capture_recipe A:276>\n<自動技能候補>\n<狡詐>",
    
        },
    

        726 => {
    
          :name => "金屬怪",
    
          :maxhp => 60,
    
          :maxmp => 46,
    
          :atk => 75,
    
          :def => 100,
    
          :spi => 68,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 150,
    
          :drop1 => {:kind => 1, :item_id => 656, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 698, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 686, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 43>\n<exp at level 43>\n<steal A:656 9%>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<capture_repeat I:256>\n<capture_recipe A:276>\n<自動技能候補>\n<狡詐>",
    
        },
    

        727 => {
    
          :name => "巨金怪",
    
          :maxhp => 80,
    
          :maxmp => 65,
    
          :atk => 135,
    
          :def => 130,
    
          :spi => 92,
    
          :agi => 70,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 190,
    
          :drop1 => {:kind => 1, :item_id => 656, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 698, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 686, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 755, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 53>\n<exp at level 53>\n<steal A:656 3%>\n<break_threshold:8>\n<break_resist:35>\n<break_recover:1>\n<capture_repeat I:256>\n<capture_recipe A:276>\n<自動技能候補>\n<狡詐>",
    
        },
    

        728 => {
    
          :name => "雪童子",
    
          :maxhp => 50,
    
          :maxmp => 35,
    
          :atk => 50,
    
          :def => 50,
    
          :spi => 50,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 130,
    
          :drop1 => {:kind => 1, :item_id => 657, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 735, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 681, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 665, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 40>\n<exp at level 40>\n<steal A:657 16%>\n<break_threshold:6>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:257>\n<capture_recipe A:277>\n<自動技能候補>\n<殘酷>",
    
        },
    

        729 => {
    
          :name => "雪妖女",
    
          :maxhp => 70,
    
          :maxmp => 53,
    
          :atk => 80,
    
          :def => 70,
    
          :spi => 75,
    
          :agi => 110,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 180,
    
          :drop1 => {:kind => 1, :item_id => 657, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 735, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 681, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 665, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 622, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 54>\n<exp at level 54>\n<steal A:657 4%>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<capture_repeat I:257>\n<capture_recipe A:277>\n<自動技能候補>\n<殘酷>",
    
        },
    

        730 => {
    
          :name => "鯉魚王",
    
          :maxhp => 20,
    
          :maxmp => 12,
    
          :atk => 10,
    
          :def => 55,
    
          :spi => 18,
    
          :agi => 80,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 65,
    
          :drop1 => {:kind => 1, :item_id => 658, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 771, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 616, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 18>\n<exp at level 18>\n<steal A:658 16%>\n<break_threshold:6>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:258>\n<capture_recipe A:278>\n<自動技能候補>\n<狡詐>",
    
        },
    

        731 => {
    
          :name => "暴鯉龍",
    
          :maxhp => 95,
    
          :maxmp => 53,
    
          :atk => 125,
    
          :def => 79,
    
          :spi => 80,
    
          :agi => 81,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 185,
    
          :drop1 => {:kind => 1, :item_id => 658, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 771, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 616, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 619, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 672, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 55>\n<exp at level 55>\n<steal A:658 4%>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<capture_repeat I:258>\n<capture_recipe A:278>\n<自動技能候補>\n<狡詐>",
    
        },
    

        732 => {
    
          :name => "燈籠魚",
    
          :maxhp => 75,
    
          :maxmp => 39,
    
          :atk => 38,
    
          :def => 38,
    
          :spi => 56,
    
          :agi => 67,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 85,
    
          :drop1 => {:kind => 1, :item_id => 659, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 697, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 649, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 25>\n<exp at level 25>\n<steal A:659 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:259>\n<capture_recipe A:279>\n<自動技能候補>\n<治癒>",
    
        },
    

        733 => {
    
          :name => "電燈怪",
    
          :maxhp => 125,
    
          :maxmp => 53,
    
          :atk => 58,
    
          :def => 58,
    
          :spi => 76,
    
          :agi => 67,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 145,
    
          :drop1 => {:kind => 1, :item_id => 659, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 617, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 697, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 649, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 621, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 42>\n<exp at level 42>\n<steal A:659 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:259>\n<capture_recipe A:279>\n<自動技能候補>\n<治癒>",
    
        },
    

        734 => {
    
          :name => "榛果球",
    
          :maxhp => 50,
    
          :maxmp => 24,
    
          :atk => 65,
    
          :def => 90,
    
          :spi => 35,
    
          :agi => 15,
    
          :hit => 95,
    
          :eva => 1,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 95,
    
          :drop1 => {:kind => 1, :item_id => 660, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 618, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 729, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 29>\n<exp at level 29>\n<steal A:660 22%>\n<break_threshold:4>\n<break_resist:0>\n<break_recover:1>\n<capture_repeat I:260>\n<capture_recipe A:280>\n<自動技能候補>\n<狡詐>",
    
        },
    

        735 => {
    
          :name => "佛烈托斯",
    
          :maxhp => 75,
    
          :maxmp => 42,
    
          :atk => 90,
    
          :def => 140,
    
          :spi => 60,
    
          :agi => 40,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => true,
    
          :exp => 32,
    
          :gold => 150,
    
          :drop1 => {:kind => 1, :item_id => 660, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 618, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 729, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 731, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 43>\n<exp at level 43>\n<steal A:660 10%>\n<break_threshold:5>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:260>\n<capture_recipe A:280>\n<自動技能候補>\n<狡詐>",
    
        },
    

        736 => {
    
          :name => "圓陸鯊",
    
          :maxhp => 58,
    
          :maxmp => 29,
    
          :atk => 70,
    
          :def => 45,
    
          :spi => 42,
    
          :agi => 42,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 75,
    
          :drop1 => {:kind => 1, :item_id => 661, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 653, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 22>\n<exp at level 22>\n<steal A:661 15%>\n<break_threshold:7>\n<break_resist:10>\n<break_recover:1>\n<capture_repeat I:261>\n<capture_recipe A:281>\n<自動技能候補>",
    
        },
    

        737 => {
    
          :name => "尖牙陸鯊",
    
          :maxhp => 68,
    
          :maxmp => 36,
    
          :atk => 90,
    
          :def => 65,
    
          :spi => 52,
    
          :agi => 82,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 160,
    
          :drop1 => {:kind => 1, :item_id => 661, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 653, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 718, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 46>\n<exp at level 46>\n<steal A:661 9%>\n<break_threshold:7>\n<break_resist:20>\n<break_recover:1>\n<capture_repeat I:261>\n<capture_recipe A:281>\n<自動技能候補>",
    
        },
    

        738 => {
    
          :name => "烈咬陸鯊",
    
          :maxhp => 108,
    
          :maxmp => 57,
    
          :atk => 130,
    
          :def => 95,
    
          :spi => 82,
    
          :agi => 102,
    
          :hit => 95,
    
          :eva => 9,
    
          :has_critical => true,
    
          :exp => 42,
    
          :gold => 200,
    
          :drop1 => {:kind => 1, :item_id => 661, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 616, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 653, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 718, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 655, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 56>\n<exp at level 56>\n<steal A:661 3%>\n<break_threshold:8>\n<break_resist:30>\n<break_recover:1>\n<capture_repeat I:261>\n<capture_recipe A:281>\n<自動技能候補>",
    
        },
    

        739 => {
    
          :name => "赫拉克羅斯",
    
          :maxhp => 80,
    
          :maxmp => 43,
    
          :atk => 125,
    
          :def => 75,
    
          :spi => 68,
    
          :agi => 85,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => true,
    
          :exp => 36,
    
          :gold => 200,
    
          :drop1 => {:kind => 1, :item_id => 662, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 624, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 654, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 687, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 627, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 57>\n<exp at level 57>\n<steal A:662 4%>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<capture_repeat I:262>\n<capture_recipe A:282>\n<自動技能候補>\n<殘酷>",
    
        },
    

        740 => {
    
          :name => "戴魯比",
    
          :maxhp => 45,
    
          :maxmp => 48,
    
          :atk => 60,
    
          :def => 30,
    
          :spi => 65,
    
          :agi => 65,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 75,
    
          :drop1 => {:kind => 1, :item_id => 663, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 608, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 619, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 663, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 22>\n<exp at level 22>\n<steal A:663 16%>\n<break_threshold:6>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:263>\n<capture_recipe A:283>\n<自動技能候補>\n<殘酷>",
    
        },
    

        741 => {
    
          :name => "黑魯加",
    
          :maxhp => 75,
    
          :maxmp => 69,
    
          :atk => 90,
    
          :def => 50,
    
          :spi => 95,
    
          :agi => 95,
    
          :hit => 95,
    
          :eva => 7,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 195,
    
          :drop1 => {:kind => 1, :item_id => 663, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 608, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 619, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 663, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 612, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 58>\n<exp at level 58>\n<steal A:663 4%>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<capture_repeat I:263>\n<capture_recipe A:283>\n<自動技能候補>\n<殘酷>",
    
        },
    

        742 => {
    
          :name => "盔甲鳥",
    
          :maxhp => 65,
    
          :maxmp => 36,
    
          :atk => 80,
    
          :def => 140,
    
          :spi => 55,
    
          :agi => 70,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => true,
    
          :exp => 36,
    
          :gold => 205,
    
          :drop1 => {:kind => 1, :item_id => 664, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 634, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 730, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 729, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 751, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 59>\n<exp at level 59>\n<steal A:664 4%>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<capture_repeat I:264>\n<capture_recipe A:284>\n<自動技能候補>\n<狡詐>",
    
        },
    

        743 => {
    
          :name => "拉魯拉絲",
    
          :maxhp => 28,
    
          :maxmp => 29,
    
          :atk => 25,
    
          :def => 25,
    
          :spi => 40,
    
          :agi => 40,
    
          :hit => 95,
    
          :eva => 2,
    
          :has_critical => false,
    
          :exp => 24,
    
          :gold => 65,
    
          :drop1 => {:kind => 1, :item_id => 665, :denominator => 4},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 670, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 685, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 18>\n<exp at level 18>\n<steal A:665 16%>\n<break_threshold:6>\n<break_resist:5>\n<break_recover:1>\n<capture_repeat I:265>\n<capture_recipe A:285>\n<自動技能候補>\n<治癒>",
    
        },
    

        744 => {
    
          :name => "奇魯莉安",
    
          :maxhp => 38,
    
          :maxmp => 43,
    
          :atk => 35,
    
          :def => 35,
    
          :spi => 60,
    
          :agi => 50,
    
          :hit => 95,
    
          :eva => 3,
    
          :has_critical => false,
    
          :exp => 32,
    
          :gold => 135,
    
          :drop1 => {:kind => 1, :item_id => 665, :denominator => 3},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 670, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 685, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 659, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 38>\n<exp at level 38>\n<steal A:665 10%>\n<break_threshold:6>\n<break_resist:15>\n<break_recover:1>\n<capture_repeat I:265>\n<capture_recipe A:285>\n<自動技能候補>\n<治癒>",
    
        },
    

        745 => {
    
          :name => "沙奈朵",
    
          :maxhp => 68,
    
          :maxmp => 85,
    
          :atk => 65,
    
          :def => 65,
    
          :spi => 120,
    
          :agi => 80,
    
          :hit => 95,
    
          :eva => 5,
    
          :has_critical => false,
    
          :exp => 42,
    
          :gold => 210,
    
          :drop1 => {:kind => 1, :item_id => 665, :denominator => 2},
    
          :drop2 => nil,
    
          :actions => [{:kind => 1, :basic => 0, :skill_id => 670, :rating => 5, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 685, :rating => 6, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 659, :rating => 7, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}, {:kind => 1, :basic => 0, :skill_id => 686, :rating => 8, :condition_type => 0, :condition_param1 => 0, :condition_param2 => 0}],
    
          :note => "<level set 60>\n<exp at level 60>\n<steal A:665 4%>\n<break_threshold:7>\n<break_resist:25>\n<break_recover:1>\n<capture_repeat I:265>\n<capture_recipe A:285>\n<自動技能候補>\n<治癒>",
    
        },
    

      })

    FIXED_BALANCE_OVERRIDES = {
    
        500 => {:maxhp=>3350, :atk=>51, :def=>58, :spi=>61, :agi=>61},
    
        501 => {:maxhp=>4250, :atk=>67, :def=>81, :spi=>55, :agi=>50},
    
        502 => {:maxhp=>5100, :atk=>85, :def=>82, :spi=>102, :agi=>102},
    
        503 => {:maxhp=>6200, :atk=>80, :def=>95, :spi=>124, :agi=>92},
    
        504 => {:maxhp=>6150, :atk=>120, :def=>135, :spi=>70, :agi=>110},
    
        505 => {:maxhp=>9950, :atk=>85, :def=>105, :spi=>165, :agi=>145},
    
        506 => {:maxhp=>9500, :atk=>154, :def=>185, :spi=>100, :agi=>155},
    
        507 => {:maxhp=>9900, :atk=>160, :def=>180, :spi=>207, :agi=>145},
    
        508 => {:maxhp=>11300, :atk=>190, :def=>210, :spi=>228, :agi=>210},
    
        509 => {:maxhp=>10800, :atk=>207, :def=>248, :spi=>248, :agi=>248},
    
        510 => {:maxhp=>13900, :atk=>220, :def=>265, :spi=>270, :agi=>225},
    
        511 => {:maxhp=>14600, :atk=>247, :def=>297, :spi=>297, :agi=>275},
    
        520 => {:maxhp=>8400, :atk=>126, :def=>138, :spi=>138, :agi=>113},
    
        521 => {:maxhp=>13600, :atk=>184, :def=>202, :spi=>202, :agi=>165},
    
        522 => {:maxhp=>17400, :atk=>242, :def=>266, :spi=>266, :agi=>217},
    
        523 => {:maxhp=>18700, :atk=>294, :def=>323, :spi=>323, :agi=>264},
    
        524 => {:maxhp=>25300, :atk=>358, :def=>393, :spi=>393, :agi=>322},
    
        530 => {:maxhp=>16200, :atk=>218, :def=>239, :spi=>239, :agi=>160},
    
        531 => {:maxhp=>25700, :atk=>318, :def=>349, :spi=>349, :agi=>286},
    
        540 => {:maxhp=>7400, :atk=>90, :def=>99, :spi=>99, :agi=>81},
    
        541 => {:maxhp=>8800, :atk=>120, :def=>151, :spi=>151, :agi=>124},
    
        542 => {:maxhp=>13900, :atk=>184, :def=>202, :spi=>180, :agi=>160},
    
        543 => {:maxhp=>15300, :atk=>230, :def=>253, :spi=>253, :agi=>207},
    
        544 => {:maxhp=>18400, :atk=>260, :def=>286, :spi=>286, :agi=>234},
    
        545 => {:maxhp=>18000, :atk=>288, :def=>316, :spi=>316, :agi=>259},
    
        546 => {:maxhp=>23600, :atk=>312, :def=>343, :spi=>343, :agi=>280},
    
        547 => {:maxhp=>25500, :atk=>334, :def=>367, :spi=>367, :agi=>300},
    
        548 => {:maxhp=>25600, :atk=>346, :def=>380, :spi=>300, :agi=>311},
    
        549 => {:maxhp=>25500, :atk=>346, :def=>380, :spi=>380, :agi=>311},
    
        550 => {:maxhp=>23600, :atk=>358, :def=>393, :spi=>393, :agi=>322},
    
        551 => {:maxhp=>800, :atk=>54, :def=>62, :spi=>62, :agi=>45},
    
        552 => {:maxhp=>1000, :atk=>60, :def=>80, :spi=>110, :agi=>110},
    
        553 => {:maxhp=>2400, :atk=>128, :def=>147, :spi=>40, :agi=>65},
    
        554 => {:maxhp=>2150, :atk=>140, :def=>184, :spi=>184, :agi=>90},
    
        555 => {:maxhp=>2300, :atk=>70, :def=>150, :spi=>208, :agi=>115},
    
        556 => {:maxhp=>2350, :atk=>201, :def=>140, :spi=>120, :agi=>230},
    
        557 => {:maxhp=>2700, :atk=>120, :def=>170, :spi=>230, :agi=>180},
    
        558 => {:maxhp=>3050, :atk=>242, :def=>240, :spi=>220, :agi=>190},
    
        559 => {:maxhp=>3000, :atk=>120, :def=>220, :spi=>276, :agi=>180},
    
        560 => {:maxhp=>3350, :atk=>250, :def=>230, :spi=>180, :agi=>286},
    
        561 => {:maxhp=>2750, :atk=>150, :def=>174, :spi=>120, :agi=>80},
    
        562 => {:maxhp=>2650, :atk=>222, :def=>220, :spi=>180, :agi=>200},
    
        563 => {:maxhp=>3500, :atk=>170, :def=>254, :spi=>180, :agi=>120},
    
        564 => {:maxhp=>2350, :atk=>130, :def=>230, :spi=>254, :agi=>254},
    
        565 => {:maxhp=>2400, :atk=>100, :def=>220, :spi=>254, :agi=>150},
    
      }
  end
end
