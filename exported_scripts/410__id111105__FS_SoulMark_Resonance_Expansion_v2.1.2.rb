#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SoulMark_Resonance_Expansion v2.1.2
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_SoulMark_Resonance_Expansion v2.1.2」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RPG::Skill、Game_Battler、Game_BattleAction、Game_Party、Game_Enemy、Scene_Title、FS_SOULMARK_RESONANCE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SOUL_COUNT、SOUL_ARMOR_START、REPEAT_ITEM_START、FRAGMENT_ITEM_START、SOUL_SKILL_START、RESONANCE_HEADGEAR_START、RESONANCE_WEAPON_START、SOUL_HEAL_SKILL。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 15 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS SoulMark Support Expansion、FS SoulMark Resonance Expansion；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
# -*- coding: utf-8 -*-



#==============================================================================



# ■ FS_SoulMark_Resonance_Expansion v2.1.2

#

# 【本版安裝位置】

# 請直接替換原本的 SoulMark_Resonance_Expansion v2.0.0 腳本頁，

# 保持它位於 AutoSetup_10_RuntimeSupport 之下、FS_MasterSetup 00～20 之前。

# 另刪除後段的 FS_ResonanceHeadgear_KindRename v1.0。



#------------------------------------------------------------------------------



# RPG Maker VX / RGSS2



#



# 【安裝】



# 1. 刪除舊版 FS_SoulMark_Support_Expansion v1.0.0。



# 2. 放在所有 AutoSetup、Equipment Skills、EquipmentCombo、



#    CharacterCore、Battle State HUD、ATB、SoulRepeatRecipe 之下，Main 之上。



# 3. 本頁必須是最後一個資料庫與戰鬥機制補丁。



#



# 【內容】



# - Skill 193～198：召喚物療護／復甦。



# - Skill 200～265：66 招手工設計的魂刻專屬技，不耗 MP，消耗對應碎片。



# - Armor 220～285：喬伊的 66 件「鳴刻冠」，裝備於頭部欄，



#   與對應 Armor 600～665 魂刻組成 EquipmentCombo。



# - Weapon 266～275：其他五名角色各 2 把專屬殘響武器。



# - Item 800～814：特別殘響與任務材料。



# - 不建立 Weapon 200～265，也不執行舊存檔轉換。



# - State 50 破勢在 0 層時不進入 Battle HUD detail。



#



# 【手動測試指令】



#   FS_SOULMARK_RESONANCE.write_report



#   FS_SOULMARK_RESONANCE.print_report



#



# 測試模式會輸出：



#   FS_SoulMark_Resonance_Report.txt



#==============================================================================







$imported = {} if $imported == nil



$imported["FS SoulMark Support Expansion"] = "2.1.2"



$imported["FS SoulMark Resonance Expansion"] = "2.1.2"







module FS_SOULMARK_RESONANCE



  VERSION = "2.1.2"







  SOUL_COUNT             = 66



  SOUL_ARMOR_START       = 600



  REPEAT_ITEM_START      = 200



  FRAGMENT_ITEM_START    = 600



  SOUL_SKILL_START       = 200



  RESONANCE_HEADGEAR_START = 220



  RESONANCE_WEAPON_START = 266







  SOUL_HEAL_SKILL       = 193



  SOUL_REVIVE_SKILL     = 194



  CLONE_HEAL_SKILL      = 195



  CLONE_REVIVE_SKILL    = 196



  ROBOT_HEAL_SKILL      = 197



  ROBOT_REVIVE_SKILL    = 198







  MEMORY_SCROLL_ARMOR   = 334



  REPAIR_MODULE_ARMOR   = 335







  JOEY_ACTOR_ID         = 1



  MIA_ACTOR_ID          = 2



  AIZHUO_ACTOR_ID       = 3



  VINA_ACTOR_ID         = 4



  IVY_ACTOR_ID          = 5



  TYLER_ACTOR_ID        = 6







  BREAK_STATE_ID        = 50



  BROKEN_STATE_ID       = 51







  HARMFUL_STATES = [31, 32, 33, 34, 35, 37, 38, 39, 41, 44, 45, 46, 47, 48, 49, 50, 59, 67]



  BUFF_STATES    = [52, 54, 55, 56, 57, 65, 72]







  MANAGED_BEGIN = "# FS_SOULMARK_RESONANCE_BEGIN"



  MANAGED_END   = "# FS_SOULMARK_RESONANCE_END"







  ELEMENT_NAMES = {



    4=>"一般", 5=>"格鬥", 6=>"飛行", 7=>"毒", 8=>"地面", 9=>"岩石",



    10=>"蟲", 11=>"幽靈", 12=>"鋼", 13=>"火", 14=>"水", 15=>"草",



    16=>"電", 17=>"超能力", 18=>"冰", 19=>"龍", 20=>"惡", 21=>"妖精"



  }







  SOUL_ARTS = [



    { :base => "草蛙", :species => "妙蛙種子系", :name => "根域共生", :description => "恢復單體召喚物18%最大HP，解除中毒與腐蝕，並提升精神。", :scope => 7, :element => 15, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [56], :effects => { :heal_maxhp => 18, :cleanse_ids => [31, 37] } },



    { :base => "火蜥", :species => "小火龍系", :name => "餘燼追獵", :description => "火屬性單體攻擊；灼燒目標增傷45%，並削減10% ATB。", :scope => 1, :element => 13, :base_damage => 225, :atk_f => 0, :spi_f => 180, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :bonus_vs_state => [34, 45], :atb_shift => -10, :bonus_low_hp => [30, 35], :state => [34, 35, 1] } },



    { :base => "沼螈", :species => "傑尼龜系", :name => "潮甲回流", :description => "恢復單體14%最大HP，解除濕潤並提高防禦。", :scope => 7, :element => 14, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [55], :effects => { :heal_maxhp => 14, :cleanse_ids => [32] } },



    { :base => "幻蝶", :species => "綠毛蟲系", :name => "鱗粉回音", :description => "蟲屬性單體攻擊，附加脆弱，並把一個異常狀態擴散給另一名敵人。", :scope => 1, :element => 10, :base_damage => 180, :atk_f => 0, :spi_f => 165, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [39, 65, 1], :spread => 1 } },



    { :base => "疾蜂", :species => "獨角蟲系", :name => "雙針獵線", :description => "蟲屬性單體物理攻擊；對中毒目標增傷35%，並嘗試疊加2層中毒。", :scope => 1, :element => 10, :base_damage => 210, :atk_f => 185, :spi_f => 0, :physical => true, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :bonus_vs_state => [31, 35], :state => [31, 55, 2] } },



    { :base => "比雕", :species => "波波系", :name => "風壓換位", :description => "一般屬性單體攻擊，附加遲緩並削減15% ATB；喬伊推進10% ATB。", :scope => 1, :element => 4, :base_damage => 190, :atk_f => 165, :spi_f => 0, :physical => true, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [38, 55, 1], :atb_shift => -15, :user_atb_shift => 10 } },



    { :base => "喵齒", :species => "小拉達系", :name => "飢速突襲", :description => "一般屬性物理攻擊；目標HP低於35%時大幅增傷，低於20%時再提升。", :scope => 1, :element => 4, :base_damage => 225, :atk_f => 190, :spi_f => 0, :physical => true, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :bonus_low_hp => [35, 60], :bonus_low_hp2 => [20, 40] } },



    { :base => "山雀", :species => "烈雀系", :name => "裂空覓隙", :description => "一般屬性物理攻擊，累積1層破勢；對崩勢目標增傷35%。", :scope => 1, :element => 4, :base_damage => 210, :atk_f => 180, :spi_f => 0, :physical => true, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 1, :bonus_vs_state => [51, 35] } },



    { :base => "毒涎", :species => "阿柏蛇系", :name => "蛇毒絞鏈", :description => "毒屬性單體攻擊，疊加2層中毒與遲緩；已中毒時追加腐蝕。", :scope => 1, :element => 7, :base_damage => 185, :atk_f => 0, :spi_f => 175, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [31, 65, 2], :state2 => [38, 55, 1], :state_if_state => [31, 37, 45, 1] } },



    { :base => "伏特", :species => "皮卡丘系", :name => "雷雨導標", :description => "電屬性單體攻擊；濕潤目標增傷50%，麻痺率提高並削減15% ATB。", :scope => 1, :element => 16, :base_damage => 215, :atk_f => 0, :spi_f => 180, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :bonus_vs_state => [32, 50], :state => [33, 35, 1], :state_if_state => [32, 33, 30, 1], :atb_shift => -15 } },



    { :base => "岩鼠", :species => "穿山鼠系", :name => "砂甲反擊", :description => "恢復單體10%最大HP，並提高攻擊與防禦。", :scope => 7, :element => 8, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [54, 55], :effects => { :heal_maxhp => 10 } },



    { :base => "妖狐", :species => "六尾系", :name => "狐火封脈", :description => "火屬性單體攻擊，高機率灼燒並有機率附加脆弱。", :scope => 1, :element => 13, :base_damage => 205, :atk_f => 0, :spi_f => 180, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [34, 60, 1], :state2 => [39, 35, 1] } },



    { :base => "粉球", :species => "胖丁系", :name => "月歌護心", :description => "恢復全體召喚物10%最大HP，並提高精神。", :scope => 8, :element => 4, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [56], :effects => { :heal_maxhp => 10 } },



    { :base => "音蝠", :species => "超音蝠系", :name => "超聲奪拍", :description => "飛行屬性單體攻擊，削減22% ATB並有機率混亂。", :scope => 1, :element => 6, :base_damage => 175, :atk_f => 0, :spi_f => 170, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :atb_shift => -22, :state => [41, 35, 1] } },



    { :base => "植根", :species => "走路草系", :name => "花毒培養", :description => "毒屬性單體攻擊，疊加3層中毒；已中毒時追加腐蝕。", :scope => 1, :element => 15, :base_damage => 180, :atk_f => 0, :spi_f => 175, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [31, 55, 3], :state_if_state => [31, 37, 45, 1] } },



    { :base => "蟲草", :species => "派拉斯系", :name => "孢子寄床", :description => "蟲屬性單體攻擊，附加寄生，並有低機率睡眠。", :scope => 1, :element => 10, :base_damage => 165, :atk_f => 0, :spi_f => 165, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [35, 60, 1], :state2 => [46, 25, 1] } },



    { :base => "夜蛾", :species => "毛球系", :name => "幻粉偏航", :description => "蟲屬性全體攻擊，附加盲目，並有低機率混亂。", :scope => 2, :element => 10, :base_damage => 130, :atk_f => 0, :spi_f => 155, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [48, 45, 1], :state2 => [41, 20, 1] } },



    { :base => "水鴨", :species => "可達鴨系", :name => "念潮逆流", :description => "水屬性單體攻擊，附加濕潤、削減12% ATB，喬伊推進10% ATB。", :scope => 1, :element => 14, :base_damage => 205, :atk_f => 0, :spi_f => 180, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [32, 70, 1], :atb_shift => -12, :user_atb_shift => 10 } },



    { :base => "潑猴", :species => "猴怪系", :name => "怒拳連攜", :description => "格鬥屬性物理攻擊，累積1層破勢；異常狀態目標增傷40%。", :scope => 1, :element => 5, :base_damage => 220, :atk_f => 190, :spi_f => 0, :physical => true, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 1, :bonus_any_status => 40 } },



    { :base => "風炎", :species => "卡蒂狗系", :name => "神速餘火", :description => "火屬性物理攻擊，附加灼燒並讓喬伊推進20% ATB。", :scope => 1, :element => 13, :base_damage => 210, :atk_f => 185, :spi_f => 0, :physical => true, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [34, 45, 1], :user_atb_shift => 20 } },



    { :base => "勇蛙", :species => "蚊香蝌蚪系", :name => "雨腹鐵壁", :description => "恢復全體8%最大HP並提高防禦。", :scope => 8, :element => 14, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [55], :effects => { :heal_maxhp => 8 } },



    { :base => "隱士", :species => "凱西系", :name => "光牆折返", :description => "提高全體召喚物的防禦與精神。", :scope => 8, :element => 17, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [55, 56], :effects => {  } },



    { :base => "豪俠", :species => "腕力系", :name => "四臂鎮勢", :description => "格鬥屬性物理攻擊，累積2層破勢；對崩勢目標增傷30%。", :scope => 1, :element => 5, :base_damage => 230, :atk_f => 195, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 2, :bonus_vs_state => [51, 30] } },



    { :base => "瑪瑙", :species => "瑪瑙水母系", :name => "酸囊崩岩", :description => "水屬性單體攻擊，疊加2層中毒並有機率腐蝕。", :scope => 1, :element => 14, :base_damage => 195, :atk_f => 0, :spi_f => 175, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [31, 55, 2], :state2 => [37, 35, 1] } },



    { :base => "滾石", :species => "小拳石系", :name => "岩殼護心", :description => "恢復單體8%最大HP，並提高防禦、獲得護盾。", :scope => 7, :element => 9, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [55, 52], :effects => { :heal_maxhp => 8 } },



    { :base => "炎駒", :species => "小火馬系", :name => "焰蹄超車", :description => "火屬性物理攻擊；目標ATB達70%以上時增傷35%，並讓喬伊推進15% ATB。", :scope => 1, :element => 13, :base_damage => 215, :atk_f => 190, :spi_f => 0, :physical => true, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :bonus_target_atb => [70, 35], :state => [34, 40, 1], :user_atb_shift => 15 } },



    { :base => "磁場", :species => "小磁怪系", :name => "磁音截流", :description => "電屬性單體攻擊，削減25% ATB並有機率麻痺。", :scope => 1, :element => 16, :base_damage => 180, :atk_f => 0, :spi_f => 175, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :atb_shift => -25, :state => [33, 35, 1] } },



    { :base => "疾走", :species => "嘟嘟系", :name => "三首節拍", :description => "一般屬性全體物理攻擊，並有機率附加遲緩。", :scope => 2, :element => 4, :base_damage => 145, :atk_f => 175, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [38, 30, 1] } },



    { :base => "汙泥", :species => "臭泥系", :name => "溶化黏域", :description => "毒屬性全體攻擊，疊加2層中毒並有機率腐蝕。", :scope => 2, :element => 7, :base_damage => 135, :atk_f => 0, :spi_f => 160, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [31, 50, 2], :state2 => [37, 30, 1] } },



    { :base => "幽魂", :species => "鬼斯系", :name => "亂光影燈", :description => "幽靈屬性單體攻擊；目標每有一種異常狀態，傷害提高12%，並有機率混亂。", :scope => 1, :element => 11, :base_damage => 190, :atk_f => 0, :spi_f => 175, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :bonus_per_status => 12, :state => [41, 45, 1] } },



    { :base => "夜縛", :species => "催眠貘系", :name => "眠波擺錘", :description => "超能力單體攻擊，削減15% ATB並有機率睡眠。", :scope => 1, :element => 17, :base_damage => 175, :atk_f => 0, :spi_f => 175, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :atb_shift => -15, :state => [46, 35, 1] } },



    { :base => "雷彈", :species => "霹靂電球系", :name => "超速放電殼", :description => "電屬性全體攻擊，削減10% ATB並有機率麻痺。", :scope => 2, :element => 16, :base_damage => 135, :atk_f => 0, :spi_f => 160, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :atb_shift => -10, :state => [33, 25, 1] } },



    { :base => "骨獸", :species => "卡拉卡拉系", :name => "回旋骨扣", :description => "地面屬性物理攻擊，累積1層破勢並削減10% ATB。", :scope => 1, :element => 8, :base_damage => 215, :atk_f => 190, :spi_f => 0, :physical => true, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 1, :atb_shift => -10 } },



    { :base => "菊石", :species => "菊石獸系", :name => "原始螺殼", :description => "恢復單體12%最大HP，並提高防禦與精神。", :scope => 7, :element => 9, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [55, 56], :effects => { :heal_maxhp => 12 } },



    { :base => "石盔", :species => "化石盔系", :name => "裂岩刃架", :description => "岩石屬性物理攻擊，累積2層破勢；對崩勢目標增傷45%。", :scope => 1, :element => 9, :base_damage => 240, :atk_f => 200, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 2, :bonus_vs_state => [51, 45] } },



    { :base => "超夢", :species => "超夢系", :name => "逆壓精神場", :description => "超能力全體攻擊，附加脆弱並削減12% ATB。", :scope => 2, :element => 17, :base_damage => 150, :atk_f => 0, :spi_f => 170, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [39, 45, 1], :atb_shift => -12 } },



    { :base => "夢幻", :species => "夢幻系", :name => "萬象借形", :description => "解除全體一個異常狀態，並提高攻擊、防禦與精神。", :scope => 8, :element => 17, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 4, :hit => 100, :variance => 8, :plus_states => [54, 55, 56], :effects => { :cleanse => 1 } },



    { :base => "尾立", :species => "尾立系", :name => "警戒尾環", :description => "提高全體敏捷並推進12% ATB。", :scope => 8, :element => 4, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [57], :effects => { :atb_shift => 12 } },



    { :base => "蛛網", :species => "圓絲蛛系", :name => "蛛絲封域", :description => "對全體附加遲緩，並有機率根縛。", :scope => 2, :element => 10, :base_damage => 1, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 3, :hit => 95, :variance => 0, :plus_states => [], :effects => { :state => [38, 65, 1], :state2 => [44, 30, 1] } },



    { :base => "天祐", :species => "波克比系", :name => "祈福星冠", :description => "恢復全體15%最大HP，解除一個異常狀態並提高精神。", :scope => 8, :element => 21, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 4, :hit => 100, :variance => 8, :plus_states => [56], :effects => { :heal_maxhp => 15, :cleanse => 1 } },



    { :base => "夢噬", :species => "天然雀系", :name => "預知回廊", :description => "超能力單體攻擊；目標ATB達70%以上時增傷50%，並削減20% ATB。", :scope => 1, :element => 17, :base_damage => 205, :atk_f => 0, :spi_f => 185, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :bonus_target_atb => [70, 50], :atb_shift => -20 } },



    { :base => "守護", :species => "咩利羊系", :name => "棉雷蓄能", :description => "恢復單體12%最大MP，並提高精神與敏捷。", :scope => 7, :element => 16, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [56, 57], :effects => { :mp_restore => 12 } },



    { :base => "輔雷", :species => "雷公系", :name => "雷霆巡界", :description => "電屬性全體攻擊；濕潤目標增傷45%，並削減12% ATB與附加麻痺。", :scope => 2, :element => 16, :base_damage => 155, :atk_f => 0, :spi_f => 175, :physical => false, :cooldown => 4, :hit => 100, :variance => 8, :plus_states => [], :effects => { :bonus_vs_state => [32, 45], :atb_shift => -12, :state => [33, 30, 1] } },



    { :base => "燃燼", :species => "炎帝系", :name => "王炎踏陣", :description => "火屬性全體物理攻擊，附加灼燒並累積1層破勢。", :scope => 2, :element => 13, :base_damage => 170, :atk_f => 195, :spi_f => 0, :physical => true, :cooldown => 4, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [34, 40, 1], :break => 1 } },



    { :base => "水蘊", :species => "水君系", :name => "北風靜域", :description => "恢復全體12%最大HP，提高防禦，並解除濕潤、遲緩與冰凍。", :scope => 8, :element => 14, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 4, :hit => 100, :variance => 8, :plus_states => [55], :effects => { :heal_maxhp => 12, :cleanse_ids => [32, 38, 47] } },



    { :base => "甲獸", :species => "幼基拉斯系", :name => "沙暴核心", :description => "岩石屬性物理攻擊，累積2層破勢，並提高喬伊防禦。", :scope => 1, :element => 9, :base_damage => 235, :atk_f => 200, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 2, :user_state => [55, 100, 1] } },



    { :base => "舞蓮", :species => "蓮葉童子系", :name => "雨舞輪唱", :description => "水屬性全體攻擊，附加濕潤並削減8% ATB。", :scope => 2, :element => 14, :base_damage => 145, :atk_f => 0, :spi_f => 170, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [32, 65, 1], :atb_shift => -8 } },



    { :base => "天翁", :species => "長翅鷗系", :name => "暴雨翼幕", :description => "恢復全體8%最大HP，並提高防禦與敏捷。", :scope => 8, :element => 14, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [55, 57], :effects => { :heal_maxhp => 8 } },



    { :base => "力士", :species => "幕下力士系", :name => "厚掌卸勢", :description => "格鬥屬性物理攻擊，累積2層破勢並削減12% ATB。", :scope => 1, :element => 5, :base_damage => 230, :atk_f => 200, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 2, :atb_shift => -12 } },



    { :base => "鋼顎", :species => "大嘴娃系", :name => "妖鋼咬合", :description => "鋼屬性物理攻擊，附加脆弱並移除一個增益；有增益時增傷30%。", :scope => 1, :element => 12, :base_damage => 220, :atk_f => 190, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [39, 45, 1], :dispel => 1, :bonus_vs_buff => 30 } },



    { :base => "鐵塔", :species => "可可多拉系", :name => "裝甲震鳴", :description => "鋼屬性全體攻擊，累積1層破勢並有機率遲緩。", :scope => 2, :element => 12, :base_damage => 150, :atk_f => 190, :spi_f => 0, :physical => true, :cooldown => 4, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 1, :state => [38, 30, 1] } },



    { :base => "海牙", :species => "利牙魚系", :name => "血潮獵殺", :description => "水屬性物理攻擊；濕潤目標增傷50%，低血量目標再增傷60%。", :scope => 1, :element => 14, :base_damage => 230, :atk_f => 200, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :bonus_vs_state => [32, 50], :bonus_low_hp => [30, 60] } },



    { :base => "平息", :species => "醜醜魚系", :name => "鏡湖再生", :description => "恢復單體25%最大HP，解除兩個異常狀態並提高精神。", :scope => 7, :element => 14, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 4, :hit => 100, :variance => 8, :plus_states => [56], :effects => { :heal_maxhp => 25, :cleanse => 2 } },



    { :base => "夜靈", :species => "夜巡靈系", :name => "魂火收容", :description => "幽靈屬性單體攻擊，吸收50%傷害並移除一個增益。", :scope => 1, :element => 11, :base_damage => 215, :atk_f => 0, :spi_f => 185, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :drain => 50, :dispel => 1 } },



    { :base => "先兆", :species => "阿勃梭魯系", :name => "災兆追獵", :description => "惡屬性物理攻擊；異常狀態目標增傷50%，崩勢目標再增傷35%。", :scope => 1, :element => 20, :base_damage => 230, :atk_f => 200, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :bonus_any_status => 50, :bonus_vs_state => [51, 35] } },



    { :base => "血月", :species => "寶貝龍系", :name => "龍血殘月", :description => "龍屬性物理攻擊，累積1層破勢；目標HP低於50%時增傷45%。", :scope => 1, :element => 19, :base_damage => 240, :atk_f => 205, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 1, :bonus_low_hp => [50, 45] } },



    { :base => "智能", :species => "鐵啞鈴系", :name => "彗星計算", :description => "鋼屬性物理攻擊，累積1層破勢、削減18% ATB；高ATB目標增傷30%。", :scope => 1, :element => 12, :base_damage => 225, :atk_f => 195, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 1, :atb_shift => -18, :bonus_target_atb => [70, 30] } },



    { :base => "冰晶", :species => "雪童子系", :name => "冰晶封拍", :description => "冰屬性單體攻擊，附加遲緩、削減12% ATB，並有低機率冰凍。", :scope => 1, :element => 18, :base_damage => 205, :atk_f => 0, :spi_f => 185, :physical => false, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [38, 65, 1], :state2 => [47, 18, 1], :atb_shift => -12 } },



    { :base => "狂暴", :species => "鯉魚王系", :name => "怒海蛻變", :description => "水屬性物理攻擊，累積2層破勢；目標HP低於35%時增傷70%。", :scope => 1, :element => 14, :base_damage => 235, :atk_f => 205, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 2, :bonus_low_hp => [35, 70] } },



    { :base => "海燈", :species => "燈籠魚系", :name => "深海燈標", :description => "水屬性單體攻擊，附加濕潤；濕潤目標另有高機率麻痺。", :scope => 1, :element => 14, :base_damage => 205, :atk_f => 0, :spi_f => 185, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [32, 70, 1], :state_if_state => [32, 33, 35, 1] } },



    { :base => "森果", :species => "榛果球系", :name => "爆殼森果", :description => "蟲屬性全體攻擊，並對每名命中目標累積1層破勢。", :scope => 2, :element => 10, :base_damage => 165, :atk_f => 195, :spi_f => 0, :physical => true, :cooldown => 4, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 1 } },



    { :base => "陸鯊", :species => "圓陸鯊系", :name => "地脈龍牙", :description => "龍屬性物理攻擊，累積2層破勢；對崩勢目標增傷40%。", :scope => 1, :element => 19, :base_damage => 245, :atk_f => 210, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :break => 2, :bonus_vs_state => [51, 40] } },



    { :base => "巨角", :species => "赫拉克羅斯系", :name => "巨角吸勢", :description => "蟲屬性物理攻擊，吸收40%傷害並累積1層破勢。", :scope => 1, :element => 10, :base_damage => 235, :atk_f => 205, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :drain => 40, :break => 1, :bonus_vs_state => [51, 30] } },



    { :base => "獄炎", :species => "戴魯比系", :name => "獄炎追魂", :description => "惡屬性物理攻擊，附加灼燒與脆弱；灼燒目標增傷30%。", :scope => 1, :element => 20, :base_damage => 230, :atk_f => 200, :spi_f => 0, :physical => true, :cooldown => 3, :hit => 100, :variance => 8, :plus_states => [], :effects => { :state => [34, 50, 1], :state2 => [39, 35, 1], :bonus_vs_state => [34, 30] } },



    { :base => "鐵堡", :species => "盔甲鳥系", :name => "鐵翼堡壘", :description => "提高全體召喚物的防禦與敏捷，並賦予護盾。", :scope => 8, :element => 12, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 4, :hit => 100, :variance => 8, :plus_states => [55, 57, 52], :effects => {  } },



    { :base => "安定", :species => "拉魯拉絲系", :name => "心穩共鳴", :description => "恢復全體12%最大HP，解除一個異常狀態並提高精神。", :scope => 8, :element => 17, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 4, :hit => 100, :variance => 8, :plus_states => [56], :effects => { :heal_maxhp => 12, :cleanse => 1 } }



  ]







  # 特別殘響與任務素材。每名角色的第一把武器消耗 2 個特別殘響，



  # 第二把消耗 3 個特別殘響、第一把武器與第二階任務素材。



  RESONANCE_ITEMS = {



    800 => ["月弦特別殘響", "米亞專屬殘響武器的核心素材。"],



    801 => ["零刻特別殘響", "艾卓專屬殘響武器的核心素材。"],



    802 => ["疫潮特別殘響", "維娜專屬殘響武器的核心素材。"],



    803 => ["代償特別殘響", "艾薇專屬殘響武器的核心素材。"],



    804 => ["崩城特別殘響", "泰勒專屬殘響武器的核心素材。"],



    805 => ["星祈枝晶", "月弦祈弓的任務材料。"],



    806 => ["天穹鏡羽", "天穹溢光弓的任務材料。"],



    807 => ["斷秒槍簧", "斷秒雷槍的任務材料。"],



    808 => ["時隙雷芯", "零刻截流槍的任務材料。"],



    809 => ["腐香骨片", "疫潮骨笛的任務材料。"],



    810 => ["萬毒音囊", "萬毒回聲笛的任務材料。"],



    811 => ["荊血斧心", "荊血戰斧的任務材料。"],



    812 => ["根脈誓鐵", "代償根斧的任務材料。"],



    813 => ["裂勢拳核", "裂勢拳鎧的任務材料。"],



    814 => ["震城臂骨", "崩城震臂的任務材料。"]



  }







  RESONANCE_WEAPONS = {



    266 => {



      :actor_id=>2, :name=>"月弦祈弓",



      :description=>"米亞專用。普通攻擊改以精神取代攻擊計算。",



      :atk=>38, :def=>0, :spi=>92, :agi=>18, :hit=>96,



      :note=>"<fs_attack_stat:spi>"



    },



    267 => {



      :actor_id=>2, :name=>"天穹溢光弓",



      :description=>"米亞專用。以精神普攻；治療HP最低的同伴，回復造成傷害20%。",



      :atk=>44, :def=>0, :spi=>112, :agi=>22, :hit=>97,



      :note=>"<fs_attack_stat:spi>\n<fs_attack_lowest_ally_heal:20>"



    },



    268 => {



      :actor_id=>3, :name=>"斷秒雷槍",



      :description=>"艾卓專用。普通攻擊削減目標8% ATB。",



      :atk=>98, :def=>18, :spi=>0, :agi=>28, :hit=>96,



      :note=>"<fs_attack_atb_shift:-8>"



    },



    269 => {



      :actor_id=>3, :name=>"零刻截流槍",



      :description=>"艾卓專用。普攻削減12% ATB；高ATB目標改為18%，並獲得50 OD。",



      :atk=>116, :def=>22, :spi=>0, :agi=>34, :hit=>97,



      :note=>"<fs_attack_atb_shift:-12>\n<fs_attack_atb_shift_high:80,-18>\n<fs_attack_od_on_high:50>"



    },



    270 => {



      :actor_id=>4, :name=>"疫潮骨笛",



      :description=>"維娜專用。普通攻擊改為敵全體，每名目標造成33%傷害。",



      :atk=>34, :def=>0, :spi=>94, :agi=>22, :hit=>95,



      :note=>"<fs_attack_all:33>"



    },



    271 => {



      :actor_id=>4, :name=>"萬毒回聲笛",



      :description=>"維娜專用。33%全體普攻，並有25%機率附加中毒。",



      :atk=>42, :def=>0, :spi=>112, :agi=>26, :hit=>96,



      :note=>"<fs_attack_all:33>\n<fs_attack_state:31,25>"



    },



    272 => {



      :actor_id=>5, :name=>"荊血戰斧",



      :description=>"艾薇專用。吸收普通攻擊實際傷害50%的HP。",



      :atk=>104, :def=>54, :spi=>0, :agi=>8, :hit=>95,



      :note=>"<fs_attack_lifesteal:50>"



    },



    273 => {



      :actor_id=>5, :name=>"代償根斧",



      :description=>"艾薇專用。普攻吸血50%；溢出治療依50%比例轉為OD。",



      :atk=>122, :def=>66, :spi=>0, :agi=>10, :hit=>96,



      :note=>"<fs_attack_lifesteal:50>\n<fs_attack_overheal_od:50>"



    },



    274 => {



      :actor_id=>6, :name=>"裂勢拳鎧",



      :description=>"泰勒專用。普通攻擊累積1層破勢。",



      :atk=>116, :def=>32, :spi=>0, :agi=>14, :hit=>97,



      :note=>"<fs_attack_break:1>"



    },



    275 => {



      :actor_id=>6, :name=>"崩城震臂",



      :description=>"泰勒專用。普攻累積1層破勢；爆擊時再增加1層。",



      :atk=>134, :def=>42, :spi=>0, :agi=>16, :hit=>98,



      :note=>"<fs_attack_break:1>\n<fs_attack_break_critical:1>"



    }



  }







  RESONANCE_RECIPES = {



    266 => [800, 2, 805, 1, 0],



    267 => [800, 3, 806, 1, 266],



    268 => [801, 2, 807, 1, 0],



    269 => [801, 3, 808, 1, 268],



    270 => [802, 2, 809, 1, 0],



    271 => [802, 3, 810, 1, 270],



    272 => [803, 2, 811, 1, 0],



    273 => [803, 3, 812, 1, 272],



    274 => [804, 2, 813, 1, 0],



    275 => [804, 3, 814, 1, 274]



  }







  @collisions = []



  @legacy_snapshots = {}



  @chain_info = {}







  #--------------------------------------------------------------------------



  # ● 基礎工具



  #--------------------------------------------------------------------------



  def self.clamp(value, low, high)



    value = low if value < low



    value = high if value > high



    return value



  end







  def self.set_value(obj, key, value)



    return if obj == nil



    setter = (key.to_s + "=").to_sym



    obj.send(setter, value) if obj.respond_to?(setter)



  end







  def self.ensure_record(array, id, klass)



    return nil if array == nil



    if defined?(FS_DB_AUTOSET) && FS_DB_AUTOSET.respond_to?(:ensure_record)



      return FS_DB_AUTOSET.ensure_record(array, id, klass)



    end



    while array.size <= id



      array.push(nil)



    end



    obj = array[id]



    if obj == nil



      obj = klass.new



      array[id] = obj



    end



    obj.id = id if obj.respond_to?(:id=)



    return obj



  end







  def self.named?(obj)



    return false if obj == nil || !obj.respond_to?(:name)



    return !obj.name.to_s.empty?



  end







  def self.managed?(obj)



    return false if obj == nil || !obj.respond_to?(:note)



    return obj.note.to_s.include?(MANAGED_BEGIN)



  end







  def self.record_collision(type, id, old_obj, new_name)



    return unless named?(old_obj)



    return if old_obj.name.to_s == new_name



    return if managed?(old_obj)



    @collisions.push("#{type} #{id}: 「#{old_obj.name}」將被「#{new_name}」覆寫")



  end







  def self.clear_runtime_caches(obj)



    return if obj == nil



    obj.instance_variables.each do |ivar|



      name = ivar.to_s



      next unless name =~ /(cache|equipment_skills|yanfly|target|base_action|extension|cost|charge|recharge|cooldown|field_effect|passive|capture_recipe)/i



      begin



        obj.instance_variable_set(ivar, nil)



      rescue



      end



    end



  end







  def self.refresh_item_class_cache(obj)



    return if obj == nil



    begin



      obj.instance_variable_set(:@cache_caricata2, nil)



      obj.carica_cache_personale_class if obj.respond_to?(:carica_cache_personale_class)



    rescue



    end



  end







  def self.managed_note(lines)



    return ([MANAGED_BEGIN] + lines + [MANAGED_END]).join("\n")



  end







  def self.replace_managed_block(obj, lines)



    return if obj == nil || !obj.respond_to?(:note) || !obj.respond_to?(:note=)



    text = obj.note.to_s



    pattern = /(?:\r?\n)?# FS_SOULMARK_(?:SUPPORT|RESONANCE)_BEGIN.*?# FS_SOULMARK_(?:SUPPORT|RESONANCE)_END(?:\r?\n)?/m



    text = text.gsub(pattern, "\n")



    text = text.gsub(/\A[\r\n]+|[\r\n]+\z/, "")



    block = managed_note(lines)



    obj.note = text.empty? ? block : text + "\n" + block



    clear_runtime_caches(obj)



  end







  def self.overwrite_note(obj, lines)



    return if obj == nil || !obj.respond_to?(:note=)



    obj.note = managed_note(lines)



    clear_runtime_caches(obj)



  end







  def self.configure_skill(id, data)



    skill = ensure_record($data_skills, id, RPG::Skill)



    return nil if skill == nil



    record_collision("Skill", id, skill, data[:name])



    defaults = {



      :name=>"", :icon_index=>0, :description=>"", :scope=>0, :occasion=>1,



      :speed=>0, :animation_id=>0, :common_event_id=>0, :base_damage=>0,



      :variance=>0, :atk_f=>0, :spi_f=>0, :mp_cost=>0, :hit=>100,



      :physical_attack=>false, :damage_to_mp=>false, :absorb_damage=>false,



      :ignore_defense=>false, :message1=>"", :message2=>"",



      :element_set=>[], :plus_state_set=>[], :minus_state_set=>[]



    }



    defaults.each do |key, value|



      value = value.clone if value.is_a?(Array)



      set_value(skill, key, value)



    end



    data.each do |key, value|



      next if key == :note



      value = value.clone if value.is_a?(Array)



      set_value(skill, key, value)



    end



    overwrite_note(skill, data[:note] || [])



    refresh_item_class_cache(skill)



    return skill



  end







  def self.configure_item(id, name, description)



    item = ensure_record($data_items, id, RPG::Item)



    return nil if item == nil



    record_collision("Item", id, item, name)



    set_value(item, :name, name)



    set_value(item, :description, description)



    set_value(item, :price, 0)



    set_value(item, :scope, 0)



    set_value(item, :occasion, 3)



    set_value(item, :speed, 0)



    set_value(item, :animation_id, 0)



    set_value(item, :common_event_id, 0)



    set_value(item, :base_damage, 0)



    set_value(item, :variance, 0)



    set_value(item, :atk_f, 0)



    set_value(item, :spi_f, 0)



    set_value(item, :hit, 100)



    set_value(item, :physical_attack, false)



    set_value(item, :damage_to_mp, false)



    set_value(item, :absorb_damage, false)



    set_value(item, :ignore_defense, false)



    set_value(item, :hp_recovery_rate, 0)



    set_value(item, :hp_recovery, 0)



    set_value(item, :mp_recovery_rate, 0)



    set_value(item, :mp_recovery, 0)



    set_value(item, :parameter_type, 0)



    set_value(item, :parameter_points, 0)



    set_value(item, :consumable, false)



    set_value(item, :element_set, [])



    set_value(item, :plus_state_set, [])



    set_value(item, :minus_state_set, [])



    overwrite_note(item, ["<pick item>", "<key item>", "<Almanac out>"])



    refresh_item_class_cache(item)



    return item



  end







  def self.copy_support_visual(target_id, source_id)



    return if $data_skills == nil



    target = $data_skills[target_id]



    source = $data_skills[source_id]



    return if target == nil || source == nil



    set_value(target, :icon_index, source.icon_index) if source.respond_to?(:icon_index)



    set_value(target, :animation_id, source.animation_id) if source.respond_to?(:animation_id)



  end







  #--------------------------------------------------------------------------



  # ● AutoSetup DATA 同步



  #--------------------------------------------------------------------------



  def self.patch_autoset_tables

    if defined?(FS_DB_AUTOSET_ITEMS) && FS_DB_AUTOSET_ITEMS.const_defined?("DATA")

      data = FS_DB_AUTOSET_ITEMS::DATA

      SOUL_ARTS.each_with_index do |art, index|

        repeat_id = REPEAT_ITEM_START + index

        frag_id = FRAGMENT_ITEM_START + index

        data[repeat_id] = {} unless data[repeat_id].is_a?(Hash)

        data[frag_id] = {} unless data[frag_id].is_a?(Hash)

        data[repeat_id][:name] = art[:base] + "殘響"

        data[repeat_id][:description] = "重複汲取" + art[:base] + "魂刻所得，用於合成鳴刻冠。"

        data[frag_id][:name] = art[:base] + "碎片"

        data[frag_id][:description] = "使用" + art[:base] + "魂刻專屬技與製作鳴刻冠時消耗。"

      end

      RESONANCE_ITEMS.each do |id, ary|

        data[id] = {} unless data[id].is_a?(Hash)

        data[id][:name] = ary[0]

        data[id][:description] = ary[1]

        data[id][:price] = 0

        data[id][:consumable] = false

        data[id][:note] = "<pick item>\n<key item>\n<Almanac out>"

      end

    end



    if defined?(FS_DB_AUTOSET_SKILLS) && FS_DB_AUTOSET_SKILLS.const_defined?("DATA")

      data = FS_DB_AUTOSET_SKILLS::DATA

      SOUL_ARTS.each_with_index do |art, index|

        id = SOUL_SKILL_START + index

        data[id] = soul_skill_data(index)

      end

    end



    if defined?(FS_DB_AUTOSET_WEAPONS) && FS_DB_AUTOSET_WEAPONS.const_defined?("DATA")

      data = FS_DB_AUTOSET_WEAPONS::DATA

      # Weapon 200～265 是已廢止的舊制範圍。新遊戲不再建立。

      SOUL_COUNT.times { |index| data.delete(200 + index) }

      RESONANCE_WEAPONS.each do |id, cfg|

        data[id] = cfg.clone

      end

    end



    if defined?(FS_DB_AUTOSET_ARMORS) && FS_DB_AUTOSET_ARMORS.const_defined?("DATA")

      data = FS_DB_AUTOSET_ARMORS::DATA

      SOUL_ARTS.each_with_index do |art, index|

        soul_id = SOUL_ARMOR_START + index

        if data[soul_id].is_a?(Hash)

          data[soul_id][:name] = art[:base] + "魂刻"

        end

        head_id = RESONANCE_HEADGEAR_START + index

        if data[head_id].is_a?(Hash)

          data[head_id][:kind] = 1

          data[head_id][:name] = resonance_headgear_name(data[head_id][:name], art[:base])

          data[head_id][:description] = resonance_headgear_description(data[head_id][:description], index, data[head_id])

          data[head_id][:note] = resonance_headgear_note(data[head_id][:note], index)

        end

      end

    end

    # MasterSetup 是目前權威資料源，必須同步改寫，避免載入時又把鳴刻冠寫回特殊欄。

    if defined?(FS_MASTER_SETUP) &&

       defined?(FS_MASTER_SETUP::ARMORS) &&

       FS_MASTER_SETUP::ARMORS.const_defined?("DATA")

      data = FS_MASTER_SETUP::ARMORS::DATA

      SOUL_ARTS.each_with_index do |art, index|

        head_id = RESONANCE_HEADGEAR_START + index

        if data[head_id].is_a?(Hash)

          data[head_id][:kind] = 1

          data[head_id][:name] = resonance_headgear_name(data[head_id][:name], art[:base])

          data[head_id][:description] = resonance_headgear_description(data[head_id][:description], index, data[head_id])

          data[head_id][:note] = resonance_headgear_note(data[head_id][:note], index)

        end

      end

    end



  end



  #--------------------------------------------------------------------------



  # ● 六個維護技能



  #--------------------------------------------------------------------------



  def self.apply_support_skills



    configure_skill(SOUL_HEAL_SKILL, {



      :name=>"魂刻療護", :description=>"恢復一個寶可夢召喚物的HP。",



      :scope=>7, :base_damage=>-210, :variance=>5, :spi_f=>165,



      :mp_cost=>12, :element_set=>[21],



      :note=>["<target_group: pokemon>","<fs_actor_only:1>","<cannot level>",



              "<charge: 4, 12%, 0>","<recharge:24%>","<action: 大地之息>"]



    })



    configure_skill(SOUL_REVIVE_SKILL, {



      :name=>"魂刻復甦", :description=>"復活一個死亡的寶可夢召喚物。",



      :scope=>9, :base_damage=>-180, :variance=>0, :spi_f=>80,



      :mp_cost=>30, :element_set=>[21],



      :note=>["<target_group: pokemon>","<fs_actor_only:1>","<cannot level>",



              "<charge: 4, 24%, 0>","<ricarica turni:3>","<action: 大地之息>"]



    })



    configure_skill(CLONE_HEAL_SKILL, {



      :name=>"回憶", :description=>"恢復一個複製人召喚物的HP。",



      :scope=>7, :base_damage=>-260, :variance=>4, :spi_f=>220,



      :mp_cost=>10, :element_set=>[21],



      :note=>["<target_group: clone>","<fs_actor_only:2>","<cannot level>",



              "<charge: 4, 10%, 0>","<recharge:22%>","<action: 大地之息>"]



    })



    configure_skill(CLONE_REVIVE_SKILL, {



      :name=>"新生", :description=>"復活一個死亡的複製人召喚物。",



      :scope=>9, :base_damage=>-300, :variance=>0, :spi_f=>160,



      :mp_cost=>28, :element_set=>[21],



      :note=>["<target_group: clone>","<fs_actor_only:2>","<cannot level>",



              "<charge: 4, 22%, 0>","<ricarica turni:3>","<action: 大地之息>"]



    })



    configure_skill(ROBOT_HEAL_SKILL, {



      :name=>"冷卻", :description=>"恢復一個機器人召喚物的HP。",



      :scope=>7, :base_damage=>-420, :variance=>3, :spi_f=>60,



      :mp_cost=>8, :element_set=>[16],



      :note=>["<target_group: robot>","<fs_actor_only:6>","<cannot level>",



              "<charge: 4, 8%, 0>","<recharge:20%>","<action: 大地之息>"]



    })



    configure_skill(ROBOT_REVIVE_SKILL, {



      :name=>"重組", :description=>"復活一個死亡的機器人召喚物。",



      :scope=>9, :base_damage=>-300, :variance=>0, :spi_f=>40,



      :mp_cost=>24, :element_set=>[16],



      :note=>["<target_group: robot>","<fs_actor_only:6>","<cannot level>",



              "<charge: 4, 20%, 0>","<ricarica turni:3>","<action: 大地之息>"]



    })



    copy_support_visual(SOUL_HEAL_SKILL, 110)



    copy_support_visual(CLONE_HEAL_SKILL, 110)



    copy_support_visual(ROBOT_HEAL_SKILL, 110)



    copy_support_visual(SOUL_REVIVE_SKILL, 118)



    copy_support_visual(CLONE_REVIVE_SKILL, 118)



    copy_support_visual(ROBOT_REVIVE_SKILL, 118)



  end







  def self.soul_skill_data(index)



    art = SOUL_ARTS[index]



    fragment_id = FRAGMENT_ITEM_START + index



    note = [



      "<usa oggetto:#{fragment_id}>",



      "<fs_actor_only:1>",



      "<fs_soul_art:#{index + 1}>",



      "<cannot level>",



      "<ricarica turni:#{art[:cooldown]}>",



      "<pop_text:#{art[:base]}的殘響，我好像聽到了。>"



    ].join("\n")



    return {



      :name=>art[:name], :description=>art[:description],



      :scope=>art[:scope], :occasion=>1, :base_damage=>art[:base_damage],



      :variance=>art[:variance], :atk_f=>art[:atk_f], :spi_f=>art[:spi_f],



      :mp_cost=>0, :hit=>art[:hit], :physical_attack=>art[:physical],



      :damage_to_mp=>false, :absorb_damage=>false, :ignore_defense=>false,



      :element_set=>[art[:element]], :plus_state_set=>art[:plus_states],



      :minus_state_set=>[], :note=>note



    }



  end







  def self.apply_soul_skills



    SOUL_ARTS.each_with_index do |art, index|



      data = soul_skill_data(index)



      lines = data[:note].split(/\n/)



      data = data.clone



      data[:note] = lines



      configure_skill(SOUL_SKILL_START + index, data)



    end



  end







  #--------------------------------------------------------------------------



  # ● 魂刻、殘響、碎片名稱與 equipskill



  #--------------------------------------------------------------------------



  def self.apply_soul_records



    SOUL_ARTS.each_with_index do |art, index|



      base = art[:base]



      repeat_id = REPEAT_ITEM_START + index



      fragment_id = FRAGMENT_ITEM_START + index



      armor_id = SOUL_ARMOR_START + index



      skill_id = SOUL_SKILL_START + index







      repeat_item = ensure_record($data_items, repeat_id, RPG::Item)



      if repeat_item != nil



        set_value(repeat_item, :name, base + "殘響")



        set_value(repeat_item, :description, "重複汲取" + base + "魂刻所得，用於合成鳴刻冠。")



        refresh_item_class_cache(repeat_item)



      end







      fragment = ensure_record($data_items, fragment_id, RPG::Item)



      if fragment != nil



        set_value(fragment, :name, base + "碎片")



        set_value(fragment, :description, "使用「" + art[:name] + "」時消耗1個。")



        refresh_item_class_cache(fragment)



      end







      armor = ensure_record($data_armors, armor_id, RPG::Armor)



      next if armor == nil



      set_value(armor, :name, base + "魂刻")



      head_id = RESONANCE_HEADGEAR_START + index
      headgear = $data_armors[head_id]
      head_name = if headgear != nil
                    resonance_headgear_name(headgear.name, art[:base])
                  else
                    "對應鳴刻冠"
                  end

      soul_description =
        "完整魂刻：可使用魂刻療護、魂刻復甦與「" +
        art[:name].to_s + "」；搭配「" + head_name +
        "」啟動召喚強化與開場技能。"

      set_value(armor, :description, soul_description)



      replace_managed_block(armor, [



        "<equipskill: #{SOUL_HEAL_SKILL}, #{SOUL_REVIVE_SKILL}, #{skill_id}>",



        "<fs_soulmark:#{armor_id}>"



      ])



      refresh_item_class_cache(armor)



    end







    RESONANCE_ITEMS.each do |id, ary|



      configure_item(id, ary[0], ary[1])



    end



  end







  #--------------------------------------------------------------------------

  # ● 喬伊的 Armor 220～285「鳴刻冠」

  #--------------------------------------------------------------------------

  HEADGEAR_PREFIXES = ["鳴刻冠・", "共鳴冠・", "魂冠・"]



  def self.resonance_headgear_name(name, fallback = "")

    base = name.to_s.dup

    HEADGEAR_PREFIXES.each do |prefix|

      if base.index(prefix) == 0

        base = base[prefix.size, base.size - prefix.size]

        break

      end

    end

    base = fallback.to_s + "鳴刻" if base == nil || base.empty?

    return "鳴刻冠・" + base

  end



  HEADGEAR_AI_STATE_NAMES = {
    17 => "攻擊型AI",
    18 => "治療型AI",
    22 => "防護型AI",
    23 => "支援型AI",
    25 => "均衡型AI"
  }

  def self.headgear_source_value(source, key, default = 0)
    return default if source == nil
    if source.is_a?(Hash)
      value = source[key]
      return value == nil ? default : value
    end
    if source.respond_to?(key)
      begin
        value = source.send(key)
        return value == nil ? default : value
      rescue
      end
    end
    return default
  end

  def self.headgear_source_note(source)
    return headgear_source_value(source, :note, "").to_s
  end

  def self.headgear_note_number(note, key)
    text = note.to_s
    pattern = /<\s*#{Regexp.escape(key.to_s)}\s*:\s*([+\-]?\d+)\s*>/i
    return 0 unless text =~ pattern
    return $1.to_i
  end

  def self.headgear_combo_state_ids(note)
    text = note.to_s
    return [] unless text =~ /<\s*combo_summon_state\s*:\s*([^>]+)>/i
    result = []
    $1.to_s.scan(/\d+/).each do |value|
      id = value.to_i
      result.push(id) if id > 0 && !result.include?(id)
    end
    return result
  end

  def self.headgear_opening_skill_id(note)
    text = note.to_s
    if text =~ /<\s*combo_summon_opening_skill\s*:\s*(\d+)\s*>/i
      return $1.to_i
    end
    return 0
  end

  def self.headgear_state_name(state_id)
    custom = HEADGEAR_AI_STATE_NAMES[state_id.to_i]
    return custom unless custom == nil || custom.empty?
    if $data_states != nil
      state = $data_states[state_id.to_i]
      return state.name.to_s if state != nil && state.name.to_s != ""
    end
    if defined?(FS_MASTER_SETUP) && defined?(FS_MASTER_SETUP::STATES) && FS_MASTER_SETUP::STATES.const_defined?("DATA")
      row = FS_MASTER_SETUP::STATES::DATA[state_id.to_i]
      return row[:name].to_s if row.is_a?(Hash) && row[:name].to_s != ""
    end
    return "狀態#{state_id}"
  end

  def self.headgear_skill_record(skill_id)
    if $data_skills != nil
      skill = $data_skills[skill_id.to_i]
      return skill unless skill == nil
    end
    return nil
  end

  def self.headgear_skill_name(skill_id)
    skill = headgear_skill_record(skill_id)
    return skill.name.to_s if skill != nil && skill.name.to_s != ""
    if defined?(FS_MASTER_SETUP) && defined?(FS_MASTER_SETUP::SKILLS) && FS_MASTER_SETUP::SKILLS.const_defined?("DATA")
      row = FS_MASTER_SETUP::SKILLS::DATA[skill_id.to_i]
      return row[:name].to_s if row.is_a?(Hash) && row[:name].to_s != ""
    end
    return "技能#{skill_id}"
  end

  def self.headgear_skill_scope(skill_id)
    skill = headgear_skill_record(skill_id)
    return skill.scope.to_i if skill != nil && skill.respond_to?(:scope)
    if defined?(FS_MASTER_SETUP) && defined?(FS_MASTER_SETUP::SKILLS) && FS_MASTER_SETUP::SKILLS.const_defined?("DATA")
      row = FS_MASTER_SETUP::SKILLS::DATA[skill_id.to_i]
      return row[:scope].to_i if row.is_a?(Hash)
    end
    return 0
  end

  def self.headgear_scope_text(scope)
    case scope.to_i
    when 1; return "對敵方單體使用"
    when 2; return "對敵方全體使用"
    when 3, 4, 5, 6; return "對隨機敵人使用"
    when 7; return "對一名我方使用"
    when 8; return "對我方全體使用"
    when 9; return "對一名倒下的我方使用"
    when 10; return "對所有倒下的我方使用"
    when 11; return "對自身使用"
    end
    return "使用"
  end

  def self.headgear_wearer_bonuses(source)
    result = []
    [[:atk, "攻擊"], [:def, "防禦"], [:spi, "精神"], [:agi, "敏捷"]].each do |key, label|
      value = headgear_source_value(source, key, 0).to_i
      next if value == 0
      sign = value > 0 ? "+" : ""
      result.push(label + sign + value.to_s)
    end
    note = headgear_source_note(source)
    hp = headgear_note_number(note, "MAXHP")
    mp = headgear_note_number(note, "MAXMP")
    if hp != 0
      sign = hp > 0 ? "+" : ""
      result.push("HP" + sign + hp.to_s)
    end
    if mp != 0
      sign = mp > 0 ? "+" : ""
      result.push("MP" + sign + mp.to_s)
    end
    return result
  end

  def self.resonance_headgear_description(description, index = nil, source = nil)
    text = description.to_s.dup
    text.gsub!("特殊裝備", "頭部裝備")
    text.gsub!("共鳴裝置", "鳴刻冠")
    return text if index == nil
    art = SOUL_ARTS[index.to_i]
    return text if art == nil
    note = headgear_source_note(source)
    state_names = []
    headgear_combo_state_ids(note).each do |state_id|
      name = headgear_state_name(state_id)
      state_names.push(name) unless name == "" || state_names.include?(name)
    end
    skill_id = headgear_opening_skill_id(note)
    skill_name = headgear_skill_name(skill_id)
    scope_text = headgear_scope_text(headgear_skill_scope(skill_id))
    bonuses = headgear_wearer_bonuses(source)
    parts = []
    parts.push("召喚物獲得" + state_names.join("、")) unless state_names.empty?
    parts.push("開場" + scope_text + "「" + skill_name + "」") if skill_id > 0
    parts.push("佩戴者" + bonuses.join("、")) unless bonuses.empty?
    prefix = "搭配" + art[:base].to_s + "魂刻啟動"
    return prefix + "：" + parts.join("；") + "。"
  end


  def self.resonance_headgear_note(note, index)

    result = []

    note.to_s.split(/[\r\n]+/).each do |line|

      text = line.to_s.strip

      next if text.empty?

      next if text =~ /<\s*equip\s+type\s*:/i

      next if text =~ /<\s*fs_(?:legacy_soul_gear|soul_weapon|resonance_headgear)\s*:/i

      result.push(text)

    end

    result.unshift("<equip type: 頭部>")

    result.push("<fs_resonance_headgear:#{index + 1}>")

    return result.join("\n")

  end



  def self.apply_resonance_headgears

    SOUL_ARTS.each_with_index do |art, index|

      id = RESONANCE_HEADGEAR_START + index

      armor = ensure_record($data_armors, id, RPG::Armor)

      next if armor == nil

      set_value(armor, :kind, 1)

      set_value(armor, :name, resonance_headgear_name(armor.name, art[:base]))

      set_value(armor, :description, resonance_headgear_description(armor.description, index, armor))

      set_value(armor, :note, resonance_headgear_note(armor.note, index))

      armor.equip_type = "頭部" if armor.respond_to?(:equip_type=)

      armor.yem_cache_armour_eo if armor.respond_to?(:yem_cache_armour_eo)

      add_armor_permission(JOEY_ACTOR_ID, id)

      refresh_item_class_cache(armor)

    end

  end



  #--------------------------------------------------------------------------



  # ● 武器資料建立／更新



  #--------------------------------------------------------------------------



  def self.configure_weapon(id, cfg)

    weapon = ensure_record($data_weapons, id, RPG::Weapon)

    return nil if weapon == nil

    record_collision("Weapon", id, weapon, cfg[:name])

    set_value(weapon, :name, cfg[:name])

    set_value(weapon, :description, cfg[:description])

    set_value(weapon, :icon_index, cfg[:icon_index].to_i)

    set_value(weapon, :price, 0)

    set_value(weapon, :hit, cfg[:hit].to_i)

    set_value(weapon, :atk, cfg[:atk].to_i)

    set_value(weapon, :def, cfg[:def].to_i)

    set_value(weapon, :spi, cfg[:spi].to_i)

    set_value(weapon, :agi, cfg[:agi].to_i)

    set_value(weapon, :two_handed, false)

    set_value(weapon, :fast_attack, false)

    set_value(weapon, :dual_attack, false)

    set_value(weapon, :critical_bonus, false)

    set_value(weapon, :element_set, cfg[:element_set] || [])

    set_value(weapon, :plus_state_set, [])

    set_value(weapon, :animation_id, cfg[:animation_id].to_i)

    overwrite_note(weapon, cfg[:note_lines] || [])

    refresh_item_class_cache(weapon)

    return weapon

  end



  #--------------------------------------------------------------------------



  # ● 五名角色的十把殘響武器



  #--------------------------------------------------------------------------



  def self.apply_resonance_weapons



    fallback = $data_weapons[100] rescue nil



    RESONANCE_WEAPONS.each do |id, data|



      cfg = {



        :name=>data[:name], :description=>data[:description],



        :icon_index=>(fallback != nil && fallback.respond_to?(:icon_index)) ? fallback.icon_index.to_i : 0,



        :animation_id=>(fallback != nil && fallback.respond_to?(:animation_id)) ? fallback.animation_id.to_i : 0,



        :hit=>data[:hit], :atk=>data[:atk], :def=>data[:def],



        :spi=>data[:spi], :agi=>data[:agi], :element_set=>[],



        :note_lines=>data[:note].to_s.split(/\n/) + ["<fs_resonance_weapon:#{data[:actor_id]}>"]



      }



      configure_weapon(id, cfg)



      add_weapon_permission(data[:actor_id], id)



    end



  end







  def self.add_weapon_permission(class_id, weapon_id)



    return if $data_classes == nil



    klass = $data_classes[class_id]



    return if klass == nil || !klass.respond_to?(:weapon_set)



    list = klass.weapon_set



    list = [] unless list.is_a?(Array)



    list = list.clone



    list.push(weapon_id) unless list.include?(weapon_id)



    klass.weapon_set = list



  end







  def self.add_armor_permission(class_id, armor_id)



    return if $data_classes == nil



    klass = $data_classes[class_id]



    return if klass == nil || !klass.respond_to?(:armor_set)



    list = klass.armor_set



    list = [] unless list.is_a?(Array)



    list = list.clone



    list.push(armor_id) unless list.include?(armor_id)



    klass.armor_set = list



  end







  def self.apply_support_armors



    ary = [



      [334, "記憶殘卷", "米亞專用；可維護與復甦複製人。", 8, 2, 2, [195,196], MIA_ACTOR_ID],



      [335, "維修模組", "泰勒專用；可冷卻與重組機器人。", 4, 8, 0, [197,198], TYLER_ACTOR_ID]



    ]



    ary.each do |row|



      armor = ensure_record($data_armors, row[0], RPG::Armor)



      next if armor == nil



      set_value(armor, :name, row[1])



      set_value(armor, :description, row[2])



      set_value(armor, :kind, 5)



      set_value(armor, :price, 0)



      set_value(armor, :atk, 0)



      set_value(armor, :def, row[4])



      set_value(armor, :spi, row[3])



      set_value(armor, :agi, row[5])



      overwrite_note(armor, ["<equip type: 特殊>", "<equipskill: " + row[6].join(", ") + ">"])



      add_armor_permission(row[7], row[0])



    end



  end







  #--------------------------------------------------------------------------



  # ● 合成配方



  #--------------------------------------------------------------------------



  #--------------------------------------------------------------------------

  # ● 合成配方由 FS_EconomyCore v1.1 統一管理

  #--------------------------------------------------------------------------

  def self.patch_sword_recipes

    return false

  end



  def self.patch_enemy_recipe_notes

    return if $data_enemies == nil

    i = 1

    while i < $data_enemies.size

      enemy = $data_enemies[i]

      if enemy != nil && enemy.respond_to?(:note) && enemy.respond_to?(:note=)

        text = enemy.note.to_s

        SOUL_COUNT.times do |index|

          armor_id = RESONANCE_HEADGEAR_START + index

          old_weapon_id = 200 + index

          text = text.gsub(/<\s*capture_recipe\s+W\s*:\s*#{old_weapon_id}\s*>/i,

                           "<capture_recipe A:#{armor_id}>")

        end

        enemy.note = text

        begin

          enemy.instance_variable_set(:@albert_capture_recipe_data, nil)

          enemy.instance_variable_set(:@albert_capture_recipe_loaded, false)

        rescue

        end

      end

      i += 1

    end

  end



  def self.unlock_headgear_recipe(armor_id)

    return if $game_party == nil || !$game_party.respond_to?(:sword_synthesize)

    table = $game_party.sword_synthesize

    return if table == nil

    table[2] = [] if table[2] == nil

    table[2][armor_id.to_i] = true

  end



  def self.unlock_resonance_pair_by_item(item_id)



    actor_index = nil



    actor_index = item_id - 800 if item_id >= 800 && item_id <= 804



    return if actor_index == nil



    first_id = RESONANCE_WEAPON_START + actor_index * 2



    unlock_weapon_recipe(first_id)



    unlock_weapon_recipe(first_id + 1)



  end







  def self.unlock_weapon_recipe(weapon_id)



    return if $game_party == nil || !$game_party.respond_to?(:sword_synthesize)



    table = $game_party.sword_synthesize



    return if table == nil



    table[1] = [] if table[1] == nil



    table[1][weapon_id] = true



  end







  #--------------------------------------------------------------------------



  # ● 技能／殘響武器辨識

  #--------------------------------------------------------------------------

  def self.soul_art_from_skill(skill)

    return nil if skill == nil

    index = skill.id.to_i - SOUL_SKILL_START

    return nil if index < 0 || index >= SOUL_ARTS.size

    return SOUL_ARTS[index]

  end



  def self.note_number(text, regexp, default_value = 0)

    return $1.to_i if text.to_s =~ regexp

    return default_value

  end



  # 僅供 Weapon 266～275 的五名角色殘響武器使用。

  def self.actor_feature_weapon(actor)

    return nil if actor == nil || !actor.respond_to?(:weapons)

    actor.weapons.compact.each do |weapon|

      next if weapon == nil

      text = weapon.note.to_s

      return weapon if text =~ /<\s*fs_resonance_weapon\s*:/i ||

                       text =~ /<\s*fs_attack_/i

    end

    return nil

  end



  #--------------------------------------------------------------------------

  # ● ATB／OD／Break 共通



  #--------------------------------------------------------------------------



  def self.atb_rate(battler)



    return 0 if battler == nil



    if battler.respond_to?(:act_count) && battler.act_count.to_i > 0



      return clamp(battler.act_count.to_i / 10, 0, 100)



    end



    if battler.respond_to?(:at_count)



      return clamp(battler.at_count.to_i / 10, 0, 100)



    end



    return 0



  end







  def self.shift_atb(battler, percent)



    return if battler == nil || percent.to_i == 0



    delta = percent.to_i * 10



    if battler.respond_to?(:act_count) && battler.act_count.to_i > 0



      value = clamp(battler.act_count.to_i + delta, 0, 1000)



      battler.act_count = value if battler.respond_to?(:act_count=)



    elsif battler.respond_to?(:at_count)



      value = clamp(battler.at_count.to_i + delta, 0, 1000)



      battler.at_count = value if battler.respond_to?(:at_count=)



    end



  end







  def self.gain_od(battler, amount)



    return if battler == nil || amount.to_i == 0



    if battler.respond_to?(:gain_od)



      battler.gain_od(amount.to_i)



    elsif battler.respond_to?(:od) && battler.respond_to?(:od=)



      max = battler.respond_to?(:maxod) ? battler.maxod.to_i : 1000



      battler.od = clamp(battler.od.to_i + amount.to_i, 0, max)



    end



  end







  def self.break_points(battler)



    return 0 if battler == nil



    if battler.respond_to?(:albert_cc_break_points)



      return battler.albert_cc_break_points(BREAK_STATE_ID).to_i



    end



    if battler.respond_to?(:stack)



      begin



        return battler.stack(BREAK_STATE_ID).to_i



      rescue



      end



    end



    return 0



  end







  def self.break_threshold(battler)



    threshold = 5



    if defined?(ALBERT_CHARACTER_CORE) && ALBERT_CHARACTER_CORE.const_defined?("BREAK_THRESHOLD")



      threshold = ALBERT_CHARACTER_CORE::BREAK_THRESHOLD.to_i



    end



    if battler != nil && battler.respond_to?(:enemy) && battler.enemy != nil



      text = battler.enemy.note.to_s



      threshold = $1.to_i if text =~ /<\s*break_threshold\s*:\s*(\d+)\s*>/i



    end



    threshold = 1 if threshold < 1



    return threshold



  end







  def self.add_break(battler, amount)



    return if battler == nil || amount.to_i <= 0



    if battler.respond_to?(:albert_cc_add_break_points)



      battler.albert_cc_add_break_points(BREAK_STATE_ID, amount.to_i)



    else



      amount.to_i.times { battler.add_state(BREAK_STATE_ID) }



    end



    if break_points(battler) >= break_threshold(battler)



      if battler.respond_to?(:albert_cc_clear_break_points)



        battler.albert_cc_clear_break_points(BREAK_STATE_ID)



      end



      battler.remove_state(BREAK_STATE_ID)



      battler.add_state(BROKEN_STATE_ID)



    end



  end







  #--------------------------------------------------------------------------



  # ● 魂刻專屬技的傷害修正



  #--------------------------------------------------------------------------



  def self.state_stack(battler, state_id)



    return 0 if battler == nil || !battler.state?(state_id)



    if battler.respond_to?(:stack)



      begin



        n = battler.stack(state_id).to_i



        return n > 0 ? n : 1



      rescue



      end



    end



    return 1



  end







  def self.status_count(battler)



    count = 0



    HARMFUL_STATES.each { |id| count += 1 if battler.state?(id) }



    return count



  end







  def self.has_buff?(battler)



    BUFF_STATES.each { |id| return true if battler.state?(id) }



    return false



  end







  def self.modify_soul_damage(target, user, skill)



    art = soul_art_from_skill(skill)



    return if art == nil || target == nil



    damage = target.instance_variable_get(:@hp_damage).to_i



    return if damage <= 0



    effects = art[:effects] || {}



    bonus = 0







    data = effects[:bonus_vs_state]



    bonus += data[1].to_i if data.is_a?(Array) && target.state?(data[0].to_i)







    data = effects[:bonus_low_hp]



    if data.is_a?(Array) && target.maxhp.to_i > 0 &&



       target.hp.to_i * 100 <= target.maxhp.to_i * data[0].to_i



      bonus += data[1].to_i



    end



    data = effects[:bonus_low_hp2]



    if data.is_a?(Array) && target.maxhp.to_i > 0 &&



       target.hp.to_i * 100 <= target.maxhp.to_i * data[0].to_i



      bonus += data[1].to_i



    end



    data = effects[:bonus_target_atb]



    bonus += data[1].to_i if data.is_a?(Array) && atb_rate(target) >= data[0].to_i



    bonus += effects[:bonus_any_status].to_i if effects[:bonus_any_status] &&



      status_count(target) > 0



    bonus += effects[:bonus_per_status].to_i * status_count(target) if



      effects[:bonus_per_status]



    bonus += effects[:bonus_vs_buff].to_i if effects[:bonus_vs_buff] &&



      has_buff?(target)







    damage = (damage * (100 + bonus) / 100.0).to_i



    target.instance_variable_set(:@hp_damage, damage)



  end







  #--------------------------------------------------------------------------



  # ● 魂刻專屬技命中後效果



  #--------------------------------------------------------------------------



  def self.apply_state_chance(target, data)



    return unless data.is_a?(Array) && data.size >= 3



    state_id = data[0].to_i



    chance = data[1].to_i



    stacks = data[2].to_i



    return if state_id <= 0 || stacks <= 0



    if target.respond_to?(:state_probability)



      begin



        chance = chance * target.state_probability(state_id).to_i / 100



      rescue



      end



    end



    if rand(100) < chance



      stacks.times { target.add_state(state_id) }



    end



  end







  def self.cleanse(target, count)



    count = count.to_i



    return if count <= 0



    HARMFUL_STATES.each do |state_id|



      next unless target.state?(state_id)



      target.remove_state(state_id)



      count -= 1



      break if count <= 0



    end



  end







  def self.cleanse_ids(target, ids)



    return unless ids.is_a?(Array)



    ids.each { |state_id| target.remove_state(state_id.to_i) }



  end







  def self.dispel(target, count)



    count = count.to_i



    return if count <= 0



    BUFF_STATES.each do |state_id|



      next unless target.state?(state_id)



      target.remove_state(state_id)



      count -= 1



      break if count <= 0



    end



  end







  def self.heal_percent(target, percent)



    return if target == nil || percent.to_i <= 0



    amount = [target.maxhp.to_i * percent.to_i / 100, 1].max



    before = target.hp.to_i



    target.hp += amount



    actual = target.hp.to_i - before



    target.instance_variable_set(:@hp_damage, -actual) if actual > 0



  end







  def self.restore_mp_percent(target, percent)



    return if target == nil || percent.to_i <= 0



    amount = [target.maxmp.to_i * percent.to_i / 100, 1].max



    before = target.mp.to_i



    target.mp += amount



    actual = target.mp.to_i - before



    target.instance_variable_set(:@mp_damage, -actual) if actual > 0



  end







  def self.spread_one_state(source)



    return unless source.respond_to?(:opponents_unit)



    state_id = 0



    HARMFUL_STATES.each do |id|



      if source.state?(id)



        state_id = id



        break



      end



    end



    return if state_id <= 0



    unit = source.actor? ? $game_troop : $game_party



    return if unit == nil



    candidates = unit.existing_members.select { |b| b != source }



    return if candidates.empty?



    candidates[rand(candidates.size)].add_state(state_id)



  end







  def self.apply_soul_post_effect(target, user, skill, before_hp)



    art = soul_art_from_skill(skill)



    return if art == nil || target == nil || user == nil



    return if target.instance_variable_get(:@missed)



    return if target.instance_variable_get(:@evaded)



    return if target.instance_variable_get(:@skipped)



    effects = art[:effects] || {}







    heal_percent(target, effects[:heal_maxhp]) if effects[:heal_maxhp]



    restore_mp_percent(target, effects[:mp_restore]) if effects[:mp_restore]



    cleanse(target, effects[:cleanse]) if effects[:cleanse]



    cleanse_ids(target, effects[:cleanse_ids]) if effects[:cleanse_ids]



    dispel(target, effects[:dispel]) if effects[:dispel]







    data = effects[:state_if_state]



    condition_was_present = data.is_a?(Array) ? target.state?(data[0].to_i) : false







    apply_state_chance(target, effects[:state])



    apply_state_chance(target, effects[:state2])







    if data.is_a?(Array) && condition_was_present



      apply_state_chance(target, [data[1], data[2], data[3]])



    end







    shift_atb(target, effects[:atb_shift]) if effects[:atb_shift]



    shift_atb(user, effects[:user_atb_shift]) if effects[:user_atb_shift]



    add_break(target, effects[:break]) if effects[:break]







    data = effects[:user_state]



    apply_state_chance(user, data) if data.is_a?(Array)







    actual_damage = before_hp.to_i - target.hp.to_i



    actual_damage = 0 if actual_damage < 0



    if effects[:drain] && actual_damage > 0



      user.hp += actual_damage * effects[:drain].to_i / 100



    end



    spread_one_state(target) if effects[:spread]



  end







  #--------------------------------------------------------------------------



  # ● 普通攻擊武器效果



  #--------------------------------------------------------------------------



  def self.attack_all_rate(actor)



    weapon = actor_feature_weapon(actor)



    return 0 if weapon == nil



    return $1.to_i if weapon.note.to_s =~ /<\s*fs_attack_all\s*:\s*(\d+)\s*>/i



    return 0



  end







  def self.modify_normal_attack_damage(target, attacker)



    return if attacker == nil || !attacker.actor?



    weapon = actor_feature_weapon(attacker)



    return if weapon == nil



    damage = target.instance_variable_get(:@hp_damage).to_i



    return if damage <= 0



    text = weapon.note.to_s







    if text =~ /<\s*fs_attack_stat\s*:\s*spi\s*>/i



      atk = attacker.atk.to_i



      spi = attacker.spi.to_i



      ratio = atk <= 0 ? 1.0 : spi.to_f / atk.to_f



      ratio = 0.50 if ratio < 0.50



      ratio = 2.50 if ratio > 2.50



      damage = (damage * ratio).to_i



    end







    if text =~ /<\s*fs_attack_all\s*:\s*(\d+)\s*>/i



      damage = (damage * $1.to_i / 100.0).to_i



    end



    target.instance_variable_set(:@hp_damage, [damage, 1].max)



  end







  def self.lowest_hp_ally(actor)



    return nil if actor == nil



    unit = actor.actor? ? $game_party : $game_troop



    return nil if unit == nil



    list = unit.existing_members



    return nil if list == nil || list.empty?



    return list.min do |a, b|



      ar = a.maxhp.to_i <= 0 ? 1000 : a.hp.to_f / a.maxhp.to_f



      br = b.maxhp.to_i <= 0 ? 1000 : b.hp.to_f / b.maxhp.to_f



      ar <=> br



    end



  end







  def self.apply_normal_attack_post(target, attacker, before_hp, critical)



    return if attacker == nil || !attacker.actor?



    weapon = actor_feature_weapon(attacker)



    return if weapon == nil



    return if target.instance_variable_get(:@missed)



    return if target.instance_variable_get(:@evaded)



    return if target.instance_variable_get(:@skipped)







    text = weapon.note.to_s



    actual = before_hp.to_i - target.hp.to_i



    actual = 0 if actual < 0







    if text =~ /<\s*fs_attack_lifesteal\s*:\s*(\d+)\s*>/i && actual > 0



      raw = actual * $1.to_i / 100



      before = attacker.hp.to_i



      attacker.hp += raw



      overheal = raw - (attacker.hp.to_i - before)



      if overheal > 0 && text =~ /<\s*fs_attack_overheal_od\s*:\s*(\d+)\s*>/i



        gain_od(attacker, overheal * $1.to_i / 100)



      end



    end







    if text =~ /<\s*fs_attack_lowest_ally_heal\s*:\s*(\d+)\s*>/i && actual > 0



      ally = lowest_hp_ally(attacker)



      ally.hp += actual * $1.to_i / 100 if ally != nil



    end







    if text =~ /<\s*fs_attack_atb_shift\s*:\s*(-?\d+)\s*>/i



      amount = $1.to_i



      if text =~ /<\s*fs_attack_atb_shift_high\s*:\s*(\d+)\s*,\s*(-?\d+)\s*>/i



        high = $1.to_i



        high_amount = $2.to_i



        if atb_rate(target) >= high



          amount = high_amount



          if text =~ /<\s*fs_attack_od_on_high\s*:\s*(\d+)\s*>/i



            gain_od(attacker, $1.to_i)



          end



        end



      end



      shift_atb(target, amount)



    end







    if text =~ /<\s*fs_attack_state\s*:\s*(\d+)\s*,\s*(\d+)\s*>/i



      target.add_state($1.to_i) if rand(100) < $2.to_i



    end







    amount = 0



    amount += $1.to_i if text =~ /<\s*fs_attack_break\s*:\s*(\d+)\s*>/i



    amount += $1.to_i if critical &&



      text =~ /<\s*fs_attack_break_critical\s*:\s*(\d+)\s*>/i



    add_break(target, amount) if amount > 0



  end







  #--------------------------------------------------------------------------



  # ● 同進化鏈高階形態加成



  #--------------------------------------------------------------------------



  def self.enemy_soul_armor_id(enemy)



    return 0 if enemy == nil || !enemy.respond_to?(:note)



    if enemy.note.to_s =~ /<\s*steal\s+A:(\d+)\s+\d+(?:[%％])?\s*>/i



      id = $1.to_i



      return id if id >= SOUL_ARMOR_START && id < SOUL_ARMOR_START + SOUL_COUNT



    end



    return 0



  end







  def self.rebuild_chain_info



    @chain_info = {}



    return if $data_enemies == nil



    groups = {}



    i = 1



    while i < $data_enemies.size



      enemy = $data_enemies[i]



      armor_id = enemy_soul_armor_id(enemy)



      if armor_id > 0



        groups[armor_id] = [] unless groups[armor_id].is_a?(Array)



        groups[armor_id].push(i)



      end



      i += 1



    end



    groups.each do |armor_id, ids|



      ids.sort!



      ids.each_with_index { |enemy_id, stage| @chain_info[enemy_id] = [stage, ids.size, armor_id] }



    end



  end







  def self.stage_info(enemy_id, armor_id = 0)



    info = @chain_info[enemy_id]



    return info if info != nil && (armor_id <= 0 || info[2] == armor_id)



    return [0, 1, armor_id]



  end







  def self.soul_armor_id_from_steal_object(sobj)



    return 0 if sobj == nil || !sobj.respond_to?(:armor_id)



    id = sobj.armor_id.to_i



    return 0 unless id >= SOUL_ARMOR_START && id < SOUL_ARMOR_START + SOUL_COUNT



    return id



  end







  def self.soul_already_captured?(armor_id)



    return false if $game_party == nil || !$game_party.respond_to?(:albert_soul_captured?)



    return $game_party.albert_soul_captured?(armor_id)



  end







  def self.repeat_capture_rate_bonus(stage_index, stage_count)



    return 0 if stage_count <= 1 || stage_index <= 0



    return [stage_index * 3, 9].min



  end







  def self.repeat_extra_echo(stage_index, stage_count)

    return 0

  end



  def self.repeat_fragment_bonus(stage_index, stage_count)

    return 1 if stage_count.to_i <= 1 || stage_index.to_i <= 0

    return 3 if stage_index.to_i >= stage_count.to_i - 1

    return 2

  end



  def self.first_capture_bonus(stage_index, stage_count)

    return [0, 2]

  end







  #--------------------------------------------------------------------------



  # ● 主套用



  #--------------------------------------------------------------------------



  def self.apply



    @collisions = []



    patch_autoset_tables



    apply_support_skills



    apply_soul_skills



    apply_soul_records



    apply_support_armors



    apply_resonance_headgears



    apply_resonance_weapons



    patch_enemy_recipe_notes



    FS_ECONOMY.apply_recipes if defined?(FS_ECONOMY) &&

      FS_ECONOMY.respond_to?(:apply_recipes)



    rebuild_chain_info



    write_report if $TEST || $BTEST



  end







  #--------------------------------------------------------------------------



  # ● 報告



  #--------------------------------------------------------------------------



  def self.report_lines



    lines = []



    lines.push("FS SoulMark Resonance Expansion v" + VERSION)



    lines.push("==================================================")



    lines.push("Manual soul arts: " + SOUL_ARTS.size.to_s + "/66")



    lines.push("Resonance headgear: Armor 220-285")



    lines.push("Resonance weapons: 266-275")



    lines.push("Detected evolution forms: " + @chain_info.size.to_s)



    lines.push("")



    if @collisions.empty?



      lines.push("COLLISION: none")



    else



      lines.push("COLLISION:")



      @collisions.each { |text| lines.push("  " + text) }



    end



    lines.push("")



    SOUL_ARTS.each_with_index do |art, index|



      lines.push(sprintf("%02d S%d/H%d/A%d/E%d/F%d | %s | %s",



        index + 1, SOUL_SKILL_START + index, RESONANCE_HEADGEAR_START + index,



        SOUL_ARMOR_START + index, REPEAT_ITEM_START + index,



        FRAGMENT_ITEM_START + index, art[:base], art[:name]))



    end



    lines.push("")



    RESONANCE_WEAPONS.each do |id, cfg|



      lines.push("W" + id.to_s + " " + cfg[:name] + " actor=" + cfg[:actor_id].to_s)



    end



    return lines



  end







  def self.write_report



    begin



      File.open("FS_SoulMark_Resonance_Report.txt", "wb") do |file|



        file.write(report_lines.join("\r\n"))



      end



      return true



    rescue



      return false



    end



  end







  def self.print_report



    print(report_lines.join("\n"))



  end



end







#==============================================================================



# ■ RPG::Skill：限定使用者



#==============================================================================



class RPG::Skill < RPG::UsableItem



  def fs_actor_only_id



    if note.to_s =~ /<\s*fs_actor_only\s*:\s*(\d+)\s*>/i



      return $1.to_i



    end



    return 0



  end



end







class Game_Battler



  alias fs_smre_skill_can_use skill_can_use? unless method_defined?(:fs_smre_skill_can_use)



  def skill_can_use?(skill)



    if skill != nil && skill.respond_to?(:fs_actor_only_id)



      actor_id = skill.fs_actor_only_id



      if actor_id > 0



        return false unless actor?



        return false unless self.id == actor_id



      end



    end



    return fs_smre_skill_can_use(skill)



  end



end







#==============================================================================



# ■ 魂刻技傷害與命中後效果



#==============================================================================



class Game_Battler



  alias fs_smre_skill_effective skill_effective? unless



    method_defined?(:fs_smre_skill_effective)



  def skill_effective?(user, skill)



    art = FS_SOULMARK_RESONANCE.soul_art_from_skill(skill)



    return self.hp.to_i > 0 if art != nil



    return fs_smre_skill_effective(user, skill)



  end







  alias fs_smre_make_obj_damage_value make_obj_damage_value unless



    method_defined?(:fs_smre_make_obj_damage_value)



  def make_obj_damage_value(user, obj)



    fs_smre_make_obj_damage_value(user, obj)



    FS_SOULMARK_RESONANCE.modify_soul_damage(self, user, obj)



  end







  alias fs_smre_skill_effect skill_effect unless method_defined?(:fs_smre_skill_effect)



  def skill_effect(user, skill)



    before_hp = self.hp



    result = fs_smre_skill_effect(user, skill)



    FS_SOULMARK_RESONANCE.apply_soul_post_effect(self, user, skill, before_hp)



    return result



  end



end







#==============================================================================



# ■ 普通攻擊特殊效果



#==============================================================================



class Game_Battler



  alias fs_smre_make_attack_damage_value make_attack_damage_value unless



    method_defined?(:fs_smre_make_attack_damage_value)



  def make_attack_damage_value(attacker)



    fs_smre_make_attack_damage_value(attacker)



    FS_SOULMARK_RESONANCE.modify_normal_attack_damage(self, attacker)



  end







  alias fs_smre_attack_effect attack_effect unless method_defined?(:fs_smre_attack_effect)



  def attack_effect(attacker)



    before_hp = self.hp



    result = fs_smre_attack_effect(attacker)



    critical = self.instance_variable_get(:@critical) ? true : false



    FS_SOULMARK_RESONANCE.apply_normal_attack_post(self, attacker, before_hp, critical)



    return result



  end



end







class Game_BattleAction



  alias fs_smre_make_attack_targets make_attack_targets unless



    method_defined?(:fs_smre_make_attack_targets)



  def make_attack_targets



    rate = 0



    if battler != nil && battler.actor?



      rate = FS_SOULMARK_RESONANCE.attack_all_rate(battler)



    end



    return fs_smre_make_attack_targets if rate <= 0 || battler.confusion?



    targets = opponents_unit.existing_members



    targets += targets if battler.dual_attack



    return targets.compact



  end



end







#==============================================================================

# ■ 特別殘響取得時，公開其他五名角色的兩份武器配方

#==============================================================================

class Game_Party < Game_Unit

  alias fs_smre_gain_item gain_item unless method_defined?(:fs_smre_gain_item)

  def gain_item(item, n, include_equip = false)

    result = fs_smre_gain_item(item, n, include_equip)

    if item != nil && item.is_a?(RPG::Item) && n.to_i > 0

      FS_SOULMARK_RESONANCE.unlock_resonance_pair_by_item(item.id.to_i)

    end

    return result

  end

end



#==============================================================================



# ■ DynamicCaptureRate：已持有魂刻後，高階形態提高重複汲取率



#==============================================================================



if defined?(Game_Enemy) && Game_Enemy.method_defined?(:albert_capture_rate_result)



  class Game_Enemy < Game_Battler



    alias fs_smre_capture_rate_result albert_capture_rate_result unless



      method_defined?(:fs_smre_capture_rate_result)



    def albert_capture_rate_result(user, sobj, store_result = true)



      result = fs_smre_capture_rate_result(user, sobj, store_result)



      return result unless result.is_a?(Array) && result.size >= 2



      armor_id = FS_SOULMARK_RESONANCE.soul_armor_id_from_steal_object(sobj)



      return result if armor_id <= 0



      return result unless FS_SOULMARK_RESONANCE.soul_already_captured?(armor_id)



      info = FS_SOULMARK_RESONANCE.stage_info(enemy_id, armor_id)



      bonus = FS_SOULMARK_RESONANCE.repeat_capture_rate_bonus(info[0], info[1])



      return result if bonus <= 0



      final_rate = FS_SOULMARK_RESONANCE.clamp(result[0].to_i + bonus, 1, 95)



      parts = result[1]



      parts = {} unless parts.is_a?(Hash)



      parts[:form_repeat] = bonus



      parts[:final] = final_rate



      @albert_last_capture_rate = final_rate if store_result



      @albert_last_capture_parts = parts if store_result



      return [final_rate, parts]



    end



  end



end







#==============================================================================

# ■ 汲取成功後獎勵

#------------------------------------------------------------------------------

# 由 Albert_SoulRepeatRecipe v1.1.2-FS 單一處理，避免多重 alias

# Scene_Battle#display_steal_item。

#==============================================================================



#==============================================================================



# ■ BattleStateHUD：破勢 1 層以上才顯示



#------------------------------------------------------------------------------



#  破勢 0 層：



#    - 不顯示頭頂狀態圖示



#    - 不顯示目標詳細視窗內容



#



#  破勢 1 層以上：



#    - 正常顯示破勢圖示



#    - 2 層以上正常顯示疊層數字



#



#  放置位置：



#    BattleStateHUD 與 FS_SOULMARK_RESONANCE 兩者之後、Main 之前。



#==============================================================================







if defined?(AlbertBattleStateHUD) &&



   defined?(FS_SOULMARK_RESONANCE)







  module AlbertBattleStateHUD



    class << self







      #------------------------------------------------------------------------



      # ● 破勢疊層讀取



      #------------------------------------------------------------------------



      unless method_defined?(:fs_break_hud_old_state_stack)



        alias fs_break_hud_old_state_stack state_stack



      end







      def state_stack(battler, state)



        if state != nil &&



           state.id.to_i == FS_SOULMARK_RESONANCE::BREAK_STATE_ID



          return FS_SOULMARK_RESONANCE.break_points(battler).to_i



        end







        return fs_break_hud_old_state_stack(battler, state)



      end







      #------------------------------------------------------------------------



      # ● 頭頂 HUD 圖示



      #------------------------------------------------------------------------



      unless method_defined?(:fs_break_hud_old_visible_states)



        alias fs_break_hud_old_visible_states visible_states



      end







      def visible_states(battler)



        result = fs_break_hud_old_visible_states(battler).clone



        points = FS_SOULMARK_RESONANCE.break_points(battler).to_i







        result.delete_if do |state|



          state != nil &&



          state.id.to_i == FS_SOULMARK_RESONANCE::BREAK_STATE_ID &&



          points < 1



        end







        return result



      end







      #------------------------------------------------------------------------



      # ● 詳細狀態視窗



      #------------------------------------------------------------------------



      unless method_defined?(:fs_break_hud_old_detail_states)



        alias fs_break_hud_old_detail_states detail_states



      end







      def detail_states(battler)



        result = fs_break_hud_old_detail_states(battler).clone



        points = FS_SOULMARK_RESONANCE.break_points(battler).to_i







        result.delete_if do |state|



          state != nil &&



          state.id.to_i == FS_SOULMARK_RESONANCE::BREAK_STATE_ID &&



          points < 1



        end







        return result



      end







      #------------------------------------------------------------------------



      # ● 詳細說明文字



      #------------------------------------------------------------------------



      unless method_defined?(:fs_break_hud_old_detail_text)



        alias fs_break_hud_old_detail_text detail_text



      end







      def detail_text(battler, state)



        if state != nil &&



           state.id.to_i == FS_SOULMARK_RESONANCE::BREAK_STATE_ID &&



           FS_SOULMARK_RESONANCE.break_points(battler).to_i < 1



          return ""



        end







        return fs_break_hud_old_detail_text(battler, state)



      end







    end



  end



end







#==============================================================================

# ■ AutoSetup RuntimeSupport 最終分類相容

#==============================================================================

if defined?(FS_DB_RUNTIME_SUPPORT)

  module FS_DB_RUNTIME_SUPPORT

    def self.normalize_special_armors

      return unless defined?($data_armors) && $data_armors.is_a?(Array)

      FS_SOULMARK_RESONANCE.apply_resonance_headgears

      [(286..295), (600..665)].each do |range|

        range.each do |id|

          armor = $data_armors[id]

          next unless armor.is_a?(RPG::Armor)

          armor.kind = 5

          armor.equip_type = "特殊" if armor.respond_to?(:equip_type=)

        end

      end

    end

  end

end



#==============================================================================



# ■ Scene_Title：最後套用



#==============================================================================



class Scene_Title < Scene_Base



  alias fs_smre_load_database load_database unless method_defined?(:fs_smre_load_database)



  def load_database



    fs_smre_load_database



    FS_SOULMARK_RESONANCE.apply



  end







  alias fs_smre_load_bt_database load_bt_database unless



    method_defined?(:fs_smre_load_bt_database)



  def load_bt_database



    fs_smre_load_bt_database



    FS_SOULMARK_RESONANCE.apply



  end



end









