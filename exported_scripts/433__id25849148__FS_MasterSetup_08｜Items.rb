#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 08 Items
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 08 Items」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、ITEMS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：DATA。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / ITEMS
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
# ■ FS_MasterSetup 08 Items
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：08 / 20
# 分類用途：殘片、合成素材與一般物品資料
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP
  module ITEMS
    DATA = begin
          data = {
    
        200 => {
    
          :name => "草蛙殘響",
    
          :description => "草蛙的殘響，用於合成叢生芽冠。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        201 => {
    
          :name => "火蜥殘響",
    
          :description => "火蜥的殘響，用於合成灼翼導流環。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        202 => {
    
          :name => "沼螈殘響",
    
          :description => "沼螈的殘響，用於合成沼鎧承壓器。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        203 => {
    
          :name => "幻蝶殘響",
    
          :description => "幻蝶的殘響，用於合成夢粉複眼鏡。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        204 => {
    
          :name => "疾蜂殘響",
    
          :description => "疾蜂的殘響，用於合成雙針聚焦鞘。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        205 => {
    
          :name => "比雕殘響",
    
          :description => "比雕的殘響，用於合成風壓尾羽。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        206 => {
    
          :name => "囓齒殘響",
    
          :description => "囓齒的殘響，用於合成疾走門牙扣。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        207 => {
    
          :name => "山雀殘響",
    
          :description => "山雀的殘響，用於合成貫空喙環。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        208 => {
    
          :name => "毒涎殘響",
    
          :description => "毒涎的殘響，用於合成蛇瞳催眠墜。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        209 => {
    
          :name => "伏特殘響",
    
          :description => "伏特的殘響，用於合成雷尾蓄電環。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        210 => {
    
          :name => "岩鼠殘響",
    
          :description => "岩鼠的殘響，用於合成砂掘爪套。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        211 => {
    
          :name => "妖狐殘響",
    
          :description => "妖狐的殘響，用於合成狐火燈芯。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        212 => {
    
          :name => "粉球殘響",
    
          :description => "粉球的殘響，用於合成月歌共鳴鈴。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        213 => {
    
          :name => "音蝠殘響",
    
          :description => "音蝠的殘響，用於合成超聲翼膜。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        214 => {
    
          :name => "植根殘響",
    
          :description => "植根的殘響，用於合成毒粉花冠。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        215 => {
    
          :name => "蟲草殘響",
    
          :description => "蟲草的殘響，用於合成孢子菌核。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        216 => {
    
          :name => "夜蛾殘響",
    
          :description => "夜蛾的殘響，用於合成幻粉觸角。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        217 => {
    
          :name => "水鴨殘響",
    
          :description => "水鴨的殘響，用於合成念波止流器。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        218 => {
    
          :name => "潑猴殘響",
    
          :description => "潑猴的殘響，用於合成怒拳繃帶。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        219 => {
    
          :name => "風炎殘響",
    
          :description => "風炎的殘響，用於合成神速足環。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        220 => {
    
          :name => "勇蛙殘響",
    
          :description => "勇蛙的殘響，用於合成雨紋腹帶。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        221 => {
    
          :name => "隱士殘響",
    
          :description => "隱士的殘響，用於合成光牆湯匙陣。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        222 => {
    
          :name => "豪俠殘響",
    
          :description => "豪俠的殘響，用於合成四臂鍛帶。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        223 => {
    
          :name => "瑪瑙殘響",
    
          :description => "瑪瑙的殘響，用於合成酸囊導管。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        224 => {
    
          :name => "滾石殘響",
    
          :description => "滾石的殘響，用於合成岩殼護心。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        225 => {
    
          :name => "炎駒殘響",
    
          :description => "炎駒的殘響，用於合成焰蹄馬鐙。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        226 => {
    
          :name => "磁場殘響",
    
          :description => "磁場的殘響，用於合成磁音共振器。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        227 => {
    
          :name => "疾走殘響",
    
          :description => "疾走的殘響，用於合成三首節拍器。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        228 => {
    
          :name => "汙泥殘響",
    
          :description => "汙泥的殘響，用於合成溶化黏核。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        229 => {
    
          :name => "幽魂殘響",
    
          :description => "幽魂的殘響，用於合成亂光影燈。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        230 => {
    
          :name => "夜貘殘響",
    
          :description => "夜貘的殘響，用於合成眠波擺錘。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        231 => {
    
          :name => "雷彈殘響",
    
          :description => "雷彈的殘響，用於合成超速放電殼。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        232 => {
    
          :name => "骨獸殘響",
    
          :description => "骨獸的殘響，用於合成回旋骨扣。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        233 => {
    
          :name => "菊石殘響",
    
          :description => "菊石的殘響，用於合成原始螺殼。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        234 => {
    
          :name => "石盔殘響",
    
          :description => "石盔的殘響，用於合成裂岩刃架。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        235 => {
    
          :name => "超夢殘響",
    
          :description => "超夢的殘響，用於合成預知思維框。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        236 => {
    
          :name => "夢幻殘響",
    
          :description => "夢幻的殘響，用於合成無限揮指環。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        237 => {
    
          :name => "尾立殘響",
    
          :description => "尾立的殘響，用於合成協奏尾旗。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        238 => {
    
          :name => "蛛網殘響",
    
          :description => "蛛網的殘響，用於合成封鎖蛛絲輪。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        239 => {
    
          :name => "天祐殘響",
    
          :description => "天祐的殘響，用於合成祝福羽冠。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        240 => {
    
          :name => "夢囈殘響",
    
          :description => "夢囈的殘響，用於合成幻光耳墜。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        241 => {
    
          :name => "守護殘響",
    
          :description => "守護的殘響，用於合成光牆育護囊。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        242 => {
    
          :name => "轟雷殘響",
    
          :description => "轟雷的殘響，用於合成雷雲脈衝環。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        243 => {
    
          :name => "燃燼殘響",
    
          :description => "燃燼的殘響，用於合成王吼焰鬃。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        244 => {
    
          :name => "水蘊殘響",
    
          :description => "水蘊的殘響，用於合成風薄紗。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        245 => {
    
          :name => "甲獸殘響",
    
          :description => "甲獸的殘響，用於合成沙暴核心。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        246 => {
    
          :name => "舞蓮殘響",
    
          :description => "舞蓮的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        247 => {
    
          :name => "天翁殘響",
    
          :description => "天翁的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        248 => {
    
          :name => "力士殘響",
    
          :description => "力士的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        249 => {
    
          :name => "鋼顎殘響",
    
          :description => "鋼顎的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        250 => {
    
          :name => "鐵塔殘響",
    
          :description => "鐵塔的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        251 => {
    
          :name => "海牙殘響",
    
          :description => "海牙的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        252 => {
    
          :name => "平息殘響",
    
          :description => "平息的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        253 => {
    
          :name => "夜靈殘響",
    
          :description => "夜靈的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        254 => {
    
          :name => "先兆殘響",
    
          :description => "先兆的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        255 => {
    
          :name => "血月殘響",
    
          :description => "血月的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        256 => {
    
          :name => "智能殘響",
    
          :description => "智能的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        257 => {
    
          :name => "冰晶殘響",
    
          :description => "冰晶的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        258 => {
    
          :name => "狂暴殘響",
    
          :description => "狂暴的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        259 => {
    
          :name => "海燈殘響",
    
          :description => "海燈的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        260 => {
    
          :name => "榛果殘響",
    
          :description => "榛果的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        261 => {
    
          :name => "陸鯊殘響",
    
          :description => "陸鯊的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        262 => {
    
          :name => "巨角殘響",
    
          :description => "巨角的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        263 => {
    
          :name => "獄炎殘響",
    
          :description => "獄炎的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        264 => {
    
          :name => "鐵堡殘響",
    
          :description => "鐵堡的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
        265 => {
    
          :name => "安定殘響",
    
          :description => "安定的殘響，用於合成對應的專屬裝備。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => true,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>\n<key item>",
    
        },
    
      }
          data.merge!({
    
        600 => {
    
          :name => "草蛙碎片",
    
          :description => "草蛙的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        601 => {
    
          :name => "火蜥碎片",
    
          :description => "火蜥的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        602 => {
    
          :name => "沼螈碎片",
    
          :description => "沼螈的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        603 => {
    
          :name => "幻蝶碎片",
    
          :description => "幻蝶的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        604 => {
    
          :name => "疾蜂碎片",
    
          :description => "疾蜂的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        605 => {
    
          :name => "比雕碎片",
    
          :description => "比雕的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        606 => {
    
          :name => "囓齒碎片",
    
          :description => "囓齒的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        607 => {
    
          :name => "山雀碎片",
    
          :description => "山雀的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        608 => {
    
          :name => "毒涎碎片",
    
          :description => "毒涎的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        609 => {
    
          :name => "伏特碎片",
    
          :description => "伏特的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        610 => {
    
          :name => "岩鼠碎片",
    
          :description => "岩鼠的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        611 => {
    
          :name => "妖狐碎片",
    
          :description => "妖狐的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        612 => {
    
          :name => "粉球碎片",
    
          :description => "粉球的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        613 => {
    
          :name => "音蝠碎片",
    
          :description => "音蝠的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        614 => {
    
          :name => "植根碎片",
    
          :description => "植根的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        615 => {
    
          :name => "蟲草碎片",
    
          :description => "蟲草的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        616 => {
    
          :name => "夜蛾碎片",
    
          :description => "夜蛾的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        617 => {
    
          :name => "水鴨碎片",
    
          :description => "水鴨的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        618 => {
    
          :name => "潑猴碎片",
    
          :description => "潑猴的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        619 => {
    
          :name => "風炎碎片",
    
          :description => "風炎的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        620 => {
    
          :name => "勇蛙碎片",
    
          :description => "勇蛙的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        621 => {
    
          :name => "隱士碎片",
    
          :description => "隱士的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        622 => {
    
          :name => "豪俠碎片",
    
          :description => "豪俠的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        623 => {
    
          :name => "瑪瑙碎片",
    
          :description => "瑪瑙的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        624 => {
    
          :name => "滾石碎片",
    
          :description => "滾石的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        625 => {
    
          :name => "炎駒碎片",
    
          :description => "炎駒的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        626 => {
    
          :name => "磁場碎片",
    
          :description => "磁場的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        627 => {
    
          :name => "疾走碎片",
    
          :description => "疾走的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        628 => {
    
          :name => "汙泥碎片",
    
          :description => "汙泥的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        629 => {
    
          :name => "幽魂碎片",
    
          :description => "幽魂的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        630 => {
    
          :name => "夜貘碎片",
    
          :description => "夜貘的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        631 => {
    
          :name => "雷彈碎片",
    
          :description => "雷彈的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        632 => {
    
          :name => "骨獸碎片",
    
          :description => "骨獸的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        633 => {
    
          :name => "菊石碎片",
    
          :description => "菊石的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        634 => {
    
          :name => "石盔碎片",
    
          :description => "石盔的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        635 => {
    
          :name => "超夢碎片",
    
          :description => "超夢的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        636 => {
    
          :name => "夢幻碎片",
    
          :description => "夢幻的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        637 => {
    
          :name => "尾立碎片",
    
          :description => "尾立的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        638 => {
    
          :name => "蛛網碎片",
    
          :description => "蛛網的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        639 => {
    
          :name => "天祐碎片",
    
          :description => "天祐的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        640 => {
    
          :name => "夢囈碎片",
    
          :description => "夢囈的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        641 => {
    
          :name => "守護碎片",
    
          :description => "守護的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        642 => {
    
          :name => "轟雷碎片",
    
          :description => "轟雷的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        643 => {
    
          :name => "燃燼碎片",
    
          :description => "燃燼的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        644 => {
    
          :name => "水蘊碎片",
    
          :description => "水蘊的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        645 => {
    
          :name => "甲獸碎片",
    
          :description => "甲獸的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        646 => {
    
          :name => "舞蓮碎片",
    
          :description => "舞蓮的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        647 => {
    
          :name => "天翁碎片",
    
          :description => "天翁的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        648 => {
    
          :name => "力士碎片",
    
          :description => "力士的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        649 => {
    
          :name => "鋼顎碎片",
    
          :description => "鋼顎的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        650 => {
    
          :name => "鐵塔碎片",
    
          :description => "鐵塔的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        651 => {
    
          :name => "海牙碎片",
    
          :description => "海牙的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        652 => {
    
          :name => "平息碎片",
    
          :description => "平息的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        653 => {
    
          :name => "夜靈碎片",
    
          :description => "夜靈的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        654 => {
    
          :name => "先兆碎片",
    
          :description => "先兆的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        655 => {
    
          :name => "血月碎片",
    
          :description => "血月的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        656 => {
    
          :name => "智能碎片",
    
          :description => "智能的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        657 => {
    
          :name => "冰晶碎片",
    
          :description => "冰晶的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        658 => {
    
          :name => "狂暴碎片",
    
          :description => "狂暴的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        659 => {
    
          :name => "海燈碎片",
    
          :description => "海燈的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        660 => {
    
          :name => "榛果碎片",
    
          :description => "榛果的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        661 => {
    
          :name => "陸鯊碎片",
    
          :description => "陸鯊的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        662 => {
    
          :name => "巨角碎片",
    
          :description => "巨角的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        663 => {
    
          :name => "獄炎碎片",
    
          :description => "獄炎的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        664 => {
    
          :name => "鐵堡碎片",
    
          :description => "鐵堡的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
        665 => {
    
          :name => "安定碎片",
    
          :description => "安定的碎片；擊倒野生魂刻形態取得的戰鬥素材，與殘響分屬不同素材。",
    
          :scope => 0,
    
          :occasion => 3,
    
          :price => 0,
    
          :consumable => false,
    
          :hp_recovery_rate => 0,
    
          :hp_recovery => 0,
    
          :mp_recovery_rate => 0,
    
          :mp_recovery => 0,
    
          :parameter_type => 0,
    
          :parameter_points => 0,
    
          :plus_state_set => [],
    
          :minus_state_set => [],
    
          :note => "<pick item>",
    
        },
    
      })
          data
        end

  end
end
