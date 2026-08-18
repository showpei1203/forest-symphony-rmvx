#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 09 Equipment v1.2｜鳴刻冠正式版
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 09 Equipment v1.2｜鳴刻冠正式版」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、WEAPONS、ARMORS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：DATA、NORMAL_POWER、UNTOUCHED_SOUL_RANGE、BALANCE_OVERRIDES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / EQUIPMENT
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#--------------------------------------------------
#==============================================================================



# ■ FS_MasterSetup 09 Equipment v1.2（鳴刻冠正式版）



#------------------------------------------------------------------------------



# RPG Maker VX / RGSS2



# 載入順序：09 / 20



# 分類用途：武器、防具、魂刻裝備與裝備平衡
# Armor 220～285 已正式定義為頭部裝備「鳴刻冠」；不得再轉換為 Weapon 200～265。



#



# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。



# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。



#==============================================================================







module FS_MASTER_SETUP



  module WEAPONS



    DATA = {



    



        100 => {



    



          :name => "林芽短刃",



    



          :atk => 8,



    



          :def => 0,



    



          :spi => 4,



    



          :agi => 0,



    



          :hit => 95,



    



          :note => "",



    



        },



    



        101 => {



    



          :name => "鳴脈刃",



    



          :atk => 22,



    



          :def => 0,



    



          :spi => 14,



    



          :agi => 4,



    



          :hit => 95,



    



          :note => "<equipskill:101>",



    



        },



    



        102 => {



    



          :name => "殘響連結器",



    



          :atk => 38,



    



          :def => 0,



    



          :spi => 30,



    



          :agi => 8,



    



          :hit => 95,



    



          :note => "<charge bonus:-3%>\n<auto state:89>",



    



        },



    



        103 => {



    



          :name => "龍森雙鳴",



    



          :atk => 58,



    



          :def => 0,



    



          :spi => 48,



    



          :agi => 14,



    



          :hit => 95,



    



          :note => "",



    



        },



    



        104 => {



    



          :name => "森之指揮棒",



    



          :atk => 82,



    



          :def => 0,



    



          :spi => 70,



    



          :agi => 22,



    



          :hit => 95,



    



          :note => "<equipskill:109>\n<auto state:89>\n<atb base:5%>",



    



        },



    



        105 => {



    



          :name => "木靈杖",



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 10,



    



          :agi => 0,



    



          :hit => 95,



    



          :note => "",



    



        },



    



        106 => {



    



          :name => "祈光杖",



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 28,



    



          :agi => 4,



    



          :hit => 95,



    



          :note => "<equipskill:111>",



    



        },



    



        107 => {



    



          :name => "溢光枝杖",



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 48,



    



          :agi => 8,



    



          :hit => 95,



    



          :note => "<charge bonus:-2%>\n<auto state:87>",



    



        },



    



        108 => {



    



          :name => "星輝長杖",



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 72,



    



          :agi => 12,



    



          :hit => 95,



    



          :note => "",



    



        },



    



        109 => {



    



          :name => "大地聖杖",



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 100,



    



          :agi => 18,



    



          :hit => 95,



    



          :note => "<equipskill:119>\n<auto state:87>\n<charge bonus:-5%>",



    



        },



    



        110 => {



    



          :name => "電鋼短刃",



    



          :atk => 10,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 5,



    



          :hit => 95,



    



          :note => "",



    



        },



    



        111 => {



    



          :name => "截流刀",



    



          :atk => 28,



    



          :def => 0,



    



          :spi => 4,



    



          :agi => 10,



    



          :hit => 95,



    



          :note => "<equipskill:121>",



    



        },



    



        112 => {



    



          :name => "雷鎖雙刃",



    



          :atk => 48,



    



          :def => 0,



    



          :spi => 8,



    



          :agi => 16,



    



          :hit => 95,



    



          :note => "<charge bonus:-4%>\n<auto state:88>",



    



        },



    



        113 => {



    



          :name => "零時鋒",



    



          :atk => 72,



    



          :def => 0,



    



          :spi => 12,



    



          :agi => 24,



    



          :hit => 95,



    



          :note => "<atb base:8%>\n<charge bonus:-5%>",



    



        },



    



        114 => {



    



          :name => "終端超頻刃",



    



          :atk => 102,



    



          :def => 0,



    



          :spi => 18,



    



          :agi => 34,



    



          :hit => 95,



    



          :note => "<equipskill:129>\n<auto state:88>\n<charge bonus:-7%>\n<atb base:10%>",



    



        },



    



        115 => {



    



          :name => "毒針杖",



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 10,



    



          :agi => 4,



    



          :hit => 95,



    



          :note => "",



    



        },



    



        116 => {



    



          :name => "培養儀杖",



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 28,



    



          :agi => 8,



    



          :hit => 95,



    



          :note => "<equipskill:131>",



    



        },



    



        117 => {



    



          :name => "腐蝕導杖",



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 50,



    



          :agi => 12,



    



          :hit => 95,



    



          :note => "<charge bonus:-2%>\n<auto state:86>",



    



        },



    



        118 => {



    



          :name => "病灶權杖",



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 74,



    



          :agi => 18,



    



          :hit => 95,



    



          :note => "",



    



        },



    



        119 => {



    



          :name => "萬毒花杖",



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 104,



    



          :agi => 26,



    



          :hit => 95,



    



          :note => "<equipskill:139>\n<auto state:86>\n<charge bonus:-5%>",



    



        },



    



        120 => {



    



          :name => "藤盾槍",



    



          :atk => 8,



    



          :def => 8,



    



          :spi => 0,



    



          :agi => 0,



    



          :hit => 95,



    



          :note => "",



    



        },



    



        121 => {



    



          :name => "棘牆槍",



    



          :atk => 22,



    



          :def => 18,



    



          :spi => 0,



    



          :agi => 0,



    



          :hit => 95,



    



          :note => "<equipskill:141>",



    



        },



    



        122 => {



    



          :name => "庇護重槍",



    



          :atk => 38,



    



          :def => 30,



    



          :spi => 0,



    



          :agi => 0,



    



          :hit => 95,



    



          :note => "<auto state:85>",



    



        },



    



        123 => {



    



          :name => "痛爐壁槍",



    



          :atk => 58,



    



          :def => 46,



    



          :spi => 0,



    



          :agi => 0,



    



          :hit => 95,



    



          :note => "<cover_store_cap_percent:350>",



    



        },



    



        124 => {



    



          :name => "怒海城槍",



    



          :atk => 82,



    



          :def => 66,



    



          :spi => 0,



    



          :agi => 0,



    



          :hit => 95,



    



          :note => "<equipskill:149>\n<auto state:85>\n<cover_store_cap_percent:400>",



    



        },



    



        125 => {



    



          :name => "粗鐵拳甲",



    



          :atk => 12,



    



          :def => 4,



    



          :spi => 0,



    



          :agi => 0,



    



          :hit => 95,



    



          :note => "",



    



        },



    



        126 => {



    



          :name => "破甲拳甲",



    



          :atk => 34,



    



          :def => 10,



    



          :spi => 0,



    



          :agi => 0,



    



          :hit => 95,



    



          :note => "<equipskill:151>",



    



        },



    



        127 => {



    



          :name => "震城臂鎧",



    



          :atk => 58,



    



          :def => 18,



    



          :spi => 0,



    



          :agi => 4,



    



          :hit => 95,



    



          :note => "<pen_rate:6>",



    



        },



    



        128 => {



    



          :name => "斷城拳鎧",



    



          :atk => 86,



    



          :def => 28,



    



          :spi => 0,



    



          :agi => 8,



    



          :hit => 95,



    



          :note => "<pen_rate:10>",



    



        },



    



        129 => {



    



          :name => "地裂王拳",



    



          :atk => 118,



    



          :def => 40,



    



          :spi => 0,



    



          :agi => 12,



    



          :hit => 95,



    



          :note => "<equipskill:159>\n<pen_rate:14>\n<crit_rate:4>",



    



        },



    



      }







    NORMAL_POWER = {



    



        100 => 260,



    



        101 => 300,



    



        102 => 340,



    



        103 => 380,



    



        104 => 420,



    



        105 => 260,



    



        106 => 300,



    



        107 => 340,



    



        108 => 380,



    



        109 => 420,



    



        110 => 260,



    



        111 => 300,



    



        112 => 340,



    



        113 => 380,



    



        114 => 420,



    



        115 => 260,



    



        116 => 300,



    



        117 => 340,



    



        118 => 380,



    



        119 => 420,



    



        120 => 260,



    



        121 => 300,



    



        122 => 340,



    



        123 => 380,



    



        124 => 420,



    



        125 => 260,



    



        126 => 300,



    



        127 => 340,



    



        128 => 380,



    



        129 => 420,



    



      }







  end







  module ARMORS



    DATA = {



    



        220 => {



    



          :name => "鳴刻冠・叢生芽冠",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:600>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:602>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 200,



    



          :recipe_qty => 3,



    



        },



    



        221 => {



    



          :name => "鳴刻冠・灼翼導流環",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:601>\n<combo_summon_state:25,57>\n<combo_summon_opening_skill:613>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 201,



    



          :recipe_qty => 3,



    



        },



    



        222 => {



    



          :name => "鳴刻冠・沼鎧承壓器",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:602>\n<combo_summon_state:22,55>\n<combo_summon_opening_skill:618>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 202,



    



          :recipe_qty => 3,



    



        },



    



        223 => {



    



          :name => "鳴刻冠・夢粉複眼鏡",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:603>\n<combo_summon_state:23>\n<combo_summon_opening_skill:604>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 203,



    



          :recipe_qty => 3,



    



        },



    



        224 => {



    



          :name => "鳴刻冠・雙針聚焦鞘",



    



          :kind => 1,



    



          :atk => 4,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 4,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:604>\n<combo_summon_state:17,62>\n<combo_summon_opening_skill:676>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 204,



    



          :recipe_qty => 3,



    



        },



    



        225 => {



    



          :name => "鳴刻冠・風壓尾羽",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:605>\n<combo_summon_state:23,57>\n<combo_summon_opening_skill:637>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 205,



    



          :recipe_qty => 3,



    



        },



    



        226 => {



    



          :name => "鳴刻冠・疾走門牙扣",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:606>\n<combo_summon_state:17,57>\n<combo_summon_opening_skill:639>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 206,



    



          :recipe_qty => 3,



    



        },



    



        227 => {



    



          :name => "鳴刻冠・貫空喙環",



    



          :kind => 1,



    



          :atk => 6,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:607>\n<combo_summon_state:17,54>\n<combo_summon_opening_skill:636>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 207,



    



          :recipe_qty => 3,



    



        },



    



        228 => {



    



          :name => "鳴刻冠・蛇瞳催眠墜",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:608>\n<combo_summon_state:23>\n<combo_summon_opening_skill:646>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 208,



    



          :recipe_qty => 3,



    



        },



    



        229 => {



    



          :name => "鳴刻冠・雷尾蓄電環",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:609>\n<combo_summon_state:23,57>\n<combo_summon_opening_skill:649>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 209,



    



          :recipe_qty => 3,



    



        },



    



        230 => {



    



          :name => "鳴刻冠・砂掘爪套",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:610>\n<combo_summon_state:17,55>\n<combo_summon_opening_skill:656>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 210,



    



          :recipe_qty => 3,



    



        },



    



        231 => {



    



          :name => "鳴刻冠・狐火燈芯",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:611>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:663>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 211,



    



          :recipe_qty => 3,



    



        },



    



        232 => {



    



          :name => "鳴刻冠・月歌共鳴鈴",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:612>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:666>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 212,



    



          :recipe_qty => 3,



    



        },



    



        233 => {



    



          :name => "鳴刻冠・超聲翼膜",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:613>\n<combo_summon_state:25,57>\n<combo_summon_opening_skill:690>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 213,



    



          :recipe_qty => 3,



    



        },



    



        234 => {



    



          :name => "鳴刻冠・毒粉花冠",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:614>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:601>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 214,



    



          :recipe_qty => 3,



    



        },



    



        235 => {



    



          :name => "鳴刻冠・孢子菌核",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:615>\n<combo_summon_state:23>\n<combo_summon_opening_skill:669>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 215,



    



          :recipe_qty => 3,



    



        },



    



        236 => {



    



          :name => "鳴刻冠・幻粉觸角",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:616>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:604>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 216,



    



          :recipe_qty => 3,



    



        },



    



        237 => {



    



          :name => "鳴刻冠・念波止流器",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:617>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:671>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 217,



    



          :recipe_qty => 3,



    



        },



    



        238 => {



    



          :name => "鳴刻冠・怒拳繃帶",



    



          :kind => 1,



    



          :atk => 6,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:618>\n<combo_summon_state:17,54>\n<combo_summon_opening_skill:676>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 218,



    



          :recipe_qty => 3,



    



        },



    



        239 => {



    



          :name => "鳴刻冠・神速足環",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:619>\n<combo_summon_state:17,57>\n<combo_summon_opening_skill:679>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 219,



    



          :recipe_qty => 3,



    



        },



    



        240 => {



    



          :name => "鳴刻冠・雨紋腹帶",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:620>\n<combo_summon_state:23,55>\n<combo_summon_opening_skill:673>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 220,



    



          :recipe_qty => 3,



    



        },



    



        241 => {



    



          :name => "鳴刻冠・光牆湯匙陣",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:621>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:705>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 221,



    



          :recipe_qty => 3,



    



        },



    



        242 => {



    



          :name => "鳴刻冠・四臂鍛帶",



    



          :kind => 1,



    



          :atk => 6,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:622>\n<combo_summon_state:17,54>\n<combo_summon_opening_skill:687>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 222,



    



          :recipe_qty => 3,



    



        },



    



        243 => {



    



          :name => "鳴刻冠・酸囊導管",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:623>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:644>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 223,



    



          :recipe_qty => 3,



    



        },



    



        244 => {



    



          :name => "鳴刻冠・岩殼護心",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:624>\n<combo_summon_state:22,55>\n<combo_summon_opening_skill:618>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 224,



    



          :recipe_qty => 3,



    



        },



    



        245 => {



    



          :name => "鳴刻冠・焰蹄馬鐙",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:625>\n<combo_summon_state:17,57>\n<combo_summon_opening_skill:662>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 225,



    



          :recipe_qty => 3,



    



        },



    



        246 => {



    



          :name => "鳴刻冠・磁音共振器",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:626>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:764>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 226,



    



          :recipe_qty => 3,



    



        },



    



        247 => {



    



          :name => "鳴刻冠・三首節拍器",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:627>\n<combo_summon_state:17,57>\n<combo_summon_opening_skill:661>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 227,



    



          :recipe_qty => 3,



    



        },



    



        248 => {



    



          :name => "鳴刻冠・溶化黏核",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:628>\n<combo_summon_state:22,55>\n<combo_summon_opening_skill:700>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 228,



    



          :recipe_qty => 3,



    



        },



    



        249 => {



    



          :name => "鳴刻冠・亂光影燈",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:629>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:665>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 229,



    



          :recipe_qty => 3,



    



        },



    



        250 => {



    



          :name => "鳴刻冠・眠波擺錘",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:630>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:671>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 230,



    



          :recipe_qty => 3,



    



        },



    



        251 => {



    



          :name => "鳴刻冠・超速放電殼",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:631>\n<combo_summon_state:17,57>\n<combo_summon_opening_skill:704>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 231,



    



          :recipe_qty => 3,



    



        },



    



        252 => {



    



          :name => "鳴刻冠・回旋骨扣",



    



          :kind => 1,



    



          :atk => 6,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:632>\n<combo_summon_state:17,54>\n<combo_summon_opening_skill:707>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 232,



    



          :recipe_qty => 3,



    



        },



    



        253 => {



    



          :name => "鳴刻冠・原始螺殼",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:633>\n<combo_summon_state:25,55>\n<combo_summon_opening_skill:715>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 233,



    



          :recipe_qty => 3,



    



        },



    



        254 => {



    



          :name => "鳴刻冠・裂岩刃架",



    



          :kind => 1,



    



          :atk => 6,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:634>\n<combo_summon_state:17,54>\n<combo_summon_opening_skill:709>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 234,



    



          :recipe_qty => 3,



    



        },



    



        255 => {



    



          :name => "鳴刻冠・預知思維框",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:635>\n<combo_summon_state:25,56>\n<combo_summon_opening_skill:682>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 235,



    



          :recipe_qty => 2,



    



        },



    



        256 => {



    



          :name => "鳴刻冠・無限揮指環",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:636>\n<combo_summon_state:25,57>\n<combo_summon_opening_skill:626>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 236,



    



          :recipe_qty => 2,



    



        },



    



        257 => {



    



          :name => "鳴刻冠・協奏尾旗",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:637>\n<combo_summon_state:23,57>\n<combo_summon_opening_skill:722>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 237,



    



          :recipe_qty => 3,



    



        },



    



        258 => {



    



          :name => "鳴刻冠・封鎖蛛絲輪",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:638>\n<combo_summon_state:23,55>\n<combo_summon_opening_skill:726>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 238,



    



          :recipe_qty => 3,



    



        },



    



        259 => {



    



          :name => "鳴刻冠・祝福羽冠",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:639>\n<combo_summon_state:18,56>\n<combo_summon_opening_skill:659>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 239,



    



          :recipe_qty => 3,



    



        },



    



        260 => {



    



          :name => "鳴刻冠・幻光耳墜",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:640>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:665>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 240,



    



          :recipe_qty => 3,



    



        },



    



        261 => {



    



          :name => "鳴刻冠・光牆育護囊",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 4,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +80>\n<combo_actor:1>\n<combo_require_armor:641>\n<combo_summon_state:18,64>\n<combo_summon_opening_skill:705>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 241,



    



          :recipe_qty => 3,



    



        },



    



        262 => {



    



          :name => "鳴刻冠・雷雲脈衝環",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:642>\n<combo_summon_state:23,57>\n<combo_summon_opening_skill:649>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 242,



    



          :recipe_qty => 2,



    



        },



    



        263 => {



    



          :name => "鳴刻冠・王吼焰鬃",



    



          :kind => 1,



    



          :atk => 6,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:643>\n<combo_summon_state:17,54>\n<combo_summon_opening_skill:736>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 243,



    



          :recipe_qty => 2,



    



        },



    



        264 => {



    



          :name => "鳴刻冠・風薄紗",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:644>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:681>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 244,



    



          :recipe_qty => 2,



    



        },



    



        265 => {



    



          :name => "鳴刻冠・沙暴核心",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:645>\n<combo_summon_state:17,55>\n<combo_summon_opening_skill:657>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 245,



    



          :recipe_qty => 4,



    



        },



    



        266 => {



    



          :name => "鳴刻冠・雨舞蓮帽",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:646>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:673>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 246,



    



          :recipe_qty => 3,



    



        },



    



        267 => {



    



          :name => "鳴刻冠・順風喉囊",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:647>\n<combo_summon_state:25,57>\n<combo_summon_opening_skill:725>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 247,



    



          :recipe_qty => 3,



    



        },



    



        268 => {



    



          :name => "鳴刻冠・猛推腰綱",



    



          :kind => 1,



    



          :atk => 6,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:648>\n<combo_summon_state:17,54>\n<combo_summon_opening_skill:687>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 248,



    



          :recipe_qty => 3,



    



        },



    



        269 => {



    



          :name => "鳴刻冠・鐵顎護髮環",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:649>\n<combo_summon_state:22,55>\n<combo_summon_opening_skill:751>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 249,



    



          :recipe_qty => 4,



    



        },



    



        270 => {



    



          :name => "鳴刻冠・鋼岩胸核",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:650>\n<combo_summon_state:22,55>\n<combo_summon_opening_skill:751>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 250,



    



          :recipe_qty => 3,



    



        },



    



        271 => {



    



          :name => "鳴刻冠・鬼面背鰭",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:651>\n<combo_summon_state:17,57>\n<combo_summon_opening_skill:611>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 251,



    



          :recipe_qty => 3,



    



        },



    



        272 => {



    



          :name => "鳴刻冠・癒潮鱗帶",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 4,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +80>\n<combo_actor:1>\n<combo_require_armor:652>\n<combo_summon_state:18,64>\n<combo_summon_opening_skill:684>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 252,



    



          :recipe_qty => 3,



    



        },



    



        273 => {



    



          :name => "鳴刻冠・冥火靈燈",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:653>\n<combo_summon_state:23,55>\n<combo_summon_opening_skill:663>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 253,



    



          :recipe_qty => 4,



    



        },



    



        274 => {



    



          :name => "鳴刻冠・災兆劍飾",



    



          :kind => 1,



    



          :atk => 4,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 4,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:654>\n<combo_summon_state:17,62>\n<combo_summon_opening_skill:753>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 254,



    



          :recipe_qty => 4,



    



        },



    



        275 => {



    



          :name => "鳴刻冠・龍息翼扣",



    



          :kind => 1,



    



          :atk => 6,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:655>\n<combo_summon_state:17,54>\n<combo_summon_opening_skill:718>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 255,



    



          :recipe_qty => 4,



    



        },



    



        276 => {



    



          :name => "鳴刻冠・彗星演算核",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:656>\n<combo_summon_state:25,55>\n<combo_summon_opening_skill:755>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 256,



    



          :recipe_qty => 4,



    



        },



    



        277 => {



    



          :name => "鳴刻冠・冰風面紗",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:657>\n<combo_summon_state:23,57>\n<combo_summon_opening_skill:681>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 257,



    



          :recipe_qty => 3,



    



        },



    



        278 => {



    



          :name => "鳴刻冠・攀瀑逆鱗環",



    



          :kind => 1,



    



          :atk => 6,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:658>\n<combo_summon_state:17,54>\n<combo_summon_opening_skill:672>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 258,



    



          :recipe_qty => 3,



    



        },



    



        279 => {



    



          :name => "鳴刻冠・導電燈囊",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:659>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:649>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 259,



    



          :recipe_qty => 3,



    



        },



    



        280 => {



    



          :name => "鳴刻冠・撒菱殼匣",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:660>\n<combo_summon_state:22,55>\n<combo_summon_opening_skill:729>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 260,



    



          :recipe_qty => 3,



    



        },



    



        281 => {



    



          :name => "鳴刻冠・地脈刃",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 6,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:661>\n<combo_summon_state:17,57>\n<combo_summon_opening_skill:653>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 261,



    



          :recipe_qty => 4,



    



        },



    



        282 => {



    



          :name => "鳴刻冠・巨角鍛環",



    



          :kind => 1,



    



          :atk => 6,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<combo_actor:1>\n<combo_require_armor:662>\n<combo_summon_state:17,54>\n<combo_summon_opening_skill:687>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 262,



    



          :recipe_qty => 4,



    



        },



    



        283 => {



    



          :name => "鳴刻冠・焦獄項圈",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:663>\n<combo_summon_state:23,56>\n<combo_summon_opening_skill:663>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 263,



    



          :recipe_qty => 4,



    



        },



    



        284 => {



    



          :name => "鳴刻冠・鋼羽撒菱匣",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 6,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXHP: +60>\n<combo_actor:1>\n<combo_require_armor:664>\n<combo_summon_state:22,55>\n<combo_summon_opening_skill:729>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 264,



    



          :recipe_qty => 4,



    



        },



    



        285 => {



    



          :name => "鳴刻冠・祈願心紗",



    



          :kind => 1,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 6,



    



          :agi => 0,



    



          :note => "<equip type: 頭部>\n<MAXMP: +8>\n<combo_actor:1>\n<combo_require_armor:665>\n<combo_summon_state:18,56>\n<combo_summon_opening_skill:659>\n<combo_summon_opening_target:-1>",



    



          :recipe_item => 265,



    



          :recipe_qty => 4,



    



        },



    



        286 => {



    



          :name => "艾卓映紋",



    



          :kind => 5,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 特殊>\n<capture_object>",



    



        },



    



        287 => {



    



          :name => "艾薇映紋",



    



          :kind => 5,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 特殊>\n<capture_object>",



    



        },



    



        288 => {



    



          :name => "米亞映紋",



    



          :kind => 5,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 特殊>\n<capture_object>",



    



        },



    



        289 => {



    



          :name => "維娜映紋",



    



          :kind => 5,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 特殊>\n<capture_object>",



    



        },



    



        290 => {



    



          :name => "泰勒映紋",



    



          :kind => 5,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 特殊>\n<capture_object>",



    



        },



    



        291 => {



    



          :name => "壁壘機核心",



    



          :kind => 5,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 特殊>\n<capture_object>",



    



        },



    



        292 => {



    



          :name => "雷序機核心",



    



          :kind => 5,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 特殊>\n<capture_object>",



    



        },



    



        293 => {



    



          :name => "腐蝕機核心",



    



          :kind => 5,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 特殊>\n<capture_object>",



    



        },



    



        294 => {



    



          :name => "破城機核心",



    



          :kind => 5,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 特殊>\n<capture_object>",



    



        },



    



        295 => {



    



          :name => "淨化機核心",



    



          :kind => 5,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 特殊>\n<capture_object>",



    



        },



    



        296 => {



    



          :name => "守林輕裝・1",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 2,



    



          :agi => 4,



    



          :note => "<equip type: 身體>\n<MAXHP: +55>\n<charge bonus:-0%>",



    



        },



    



        297 => {



    



          :name => "守林輕裝・2",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 5,



    



          :agi => 8,



    



          :note => "<equip type: 身體>\n<MAXHP: +120>\n<charge bonus:-1%>",



    



        },



    



        298 => {



    



          :name => "守林輕裝・3",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 9,



    



          :agi => 14,



    



          :note => "<equip type: 身體>\n<MAXHP: +220>\n<charge bonus:-2%>",



    



        },



    



        299 => {



    



          :name => "守林輕裝・4",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 14,



    



          :agi => 22,



    



          :note => "<equip type: 身體>\n<MAXHP: +360>\n<charge bonus:-3%>",



    



        },



    



        300 => {



    



          :name => "守林輕裝・5",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 20,



    



          :agi => 32,



    



          :note => "<equip type: 身體>\n<MAXHP: +520>\n<charge bonus:-4%>",



    



        },



    



        301 => {



    



          :name => "共鳴法衣・1",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 12,



    



          :agi => 0,



    



          :note => "<equip type: 身體>\n<MAXMP: +20>",



    



        },



    



        302 => {



    



          :name => "共鳴法衣・2",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 28,



    



          :agi => 0,



    



          :note => "<equip type: 身體>\n<MAXMP: +45>",



    



        },



    



        303 => {



    



          :name => "共鳴法衣・3",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 48,



    



          :agi => 0,



    



          :note => "<equip type: 身體>\n<MAXMP: +80>",



    



        },



    



        304 => {



    



          :name => "共鳴法衣・4",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 72,



    



          :agi => 0,



    



          :note => "<equip type: 身體>\n<MAXMP: +125>",



    



        },



    



        305 => {



    



          :name => "共鳴法衣・5",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 100,



    



          :agi => 0,



    



          :note => "<equip type: 身體>\n<MAXMP: +180>\n<half mp cost>",



    



        },



    



        306 => {



    



          :name => "壁壘重鎧・1",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 12,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 身體>\n<MAXHP: +90>",



    



        },



    



        307 => {



    



          :name => "壁壘重鎧・2",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 28,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 身體>\n<MAXHP: +200>",



    



        },



    



        308 => {



    



          :name => "壁壘重鎧・3",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 48,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 身體>\n<MAXHP: +360>",



    



        },



    



        309 => {



    



          :name => "壁壘重鎧・4",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 72,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 身體>\n<MAXHP: +560>",



    



        },



    



        310 => {



    



          :name => "壁壘重鎧・5",



    



          :kind => 2,



    



          :atk => 0,



    



          :def => 100,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 身體>\n<MAXHP: +800>\n<prevent critical>",



    



        },



    



        311 => {



    



          :name => "突擊束甲・1",



    



          :kind => 2,



    



          :atk => 45,



    



          :def => 8,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 身體>",



    



        },



    



        312 => {



    



          :name => "突擊束甲・2",



    



          :kind => 2,



    



          :atk => 100,



    



          :def => 18,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 身體>",



    



        },



    



        313 => {



    



          :name => "突擊束甲・3",



    



          :kind => 2,



    



          :atk => 180,



    



          :def => 30,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 身體>",



    



        },



    



        314 => {



    



          :name => "突擊束甲・4",



    



          :kind => 2,



    



          :atk => 280,



    



          :def => 46,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 身體>",



    



        },



    



        315 => {



    



          :name => "突擊束甲・5",



    



          :kind => 2,



    



          :atk => 400,



    



          :def => 64,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 身體>",



    



        },



    



        316 => {



    



          :name => "共鳴靈鐲・1",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 18,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<cc_od_summon_action:60>",



    



        },



    



        317 => {



    



          :name => "共鳴靈鐲・2",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 38,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<cc_od_summon_action:70>",



    



        },



    



        318 => {



    



          :name => "共鳴靈鐲・3",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 68,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<cc_od_summon_action:80>",



    



        },



    



        319 => {



    



          :name => "溢光聖印・1",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 20,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<cc_od_overheal_percent:3>",



    



        },



    



        320 => {



    



          :name => "溢光聖印・2",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 44,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<cc_od_overheal_percent:3.5>",



    



        },



    



        321 => {



    



          :name => "溢光聖印・3",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 76,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<auto state:87>",



    



        },



    



        322 => {



    



          :name => "零時環・1",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 8,



    



          :note => "<equip type: 飾品>\n<charge bonus:-3%>",



    



        },



    



        323 => {



    



          :name => "零時環・2",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 16,



    



          :note => "<equip type: 飾品>\n<charge bonus:-5%>",



    



        },



    



        324 => {



    



          :name => "零時環・3",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 28,



    



          :note => "<equip type: 飾品>\n<auto state:88>",



    



        },



    



        325 => {



    



          :name => "毒理匣・1",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 18,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<cc_od_state_stack:50>",



    



        },



    



        326 => {



    



          :name => "毒理匣・2",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 40,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<cc_od_state_stack:55>",



    



        },



    



        327 => {



    



          :name => "毒理匣・3",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 72,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<auto state:86>",



    



        },



    



        328 => {



    



          :name => "替身徽記・1",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<MAXHP: +120>\n<cover_store_cap_percent:325>",



    



        },



    



        329 => {



    



          :name => "替身徽記・2",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<MAXHP: +260>\n<cover_store_cap_percent:350>",



    



        },



    



        330 => {



    



          :name => "替身徽記・3",



    



          :kind => 4,



    



          :atk => 0,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<MAXHP: +460>\n<cover_store_cap_percent:400>",



    



        },



    



        331 => {



    



          :name => "破城楔・1",



    



          :kind => 4,



    



          :atk => 4,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<pen_rate:4>",



    



        },



    



        332 => {



    



          :name => "破城楔・2",



    



          :kind => 4,



    



          :atk => 8,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<pen_rate:8>",



    



        },



    



        333 => {



    



          :name => "破城楔・3",



    



          :kind => 4,



    



          :atk => 12,



    



          :def => 0,



    



          :spi => 0,



    



          :agi => 0,



    



          :note => "<equip type: 飾品>\n<pen_rate:12>",



    



        },



    



      }







    UNTOUCHED_SOUL_RANGE = (600..665)







    BALANCE_OVERRIDES = {



    



        311 => {:atk=>8},



    



        312 => {:atk=>18},



    



        313 => {:atk=>30},



    



        314 => {:atk=>46},



    



        315 => {:atk=>64},



    



      }







  end



end









