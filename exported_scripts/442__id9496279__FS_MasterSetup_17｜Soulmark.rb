#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 17 Soulmark
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 17 Soulmark」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、SOULMARK
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ELEMENT_NAMES、HARMFUL_STATES、BUFF_STATES、SOUL_ARTS、RESONANCE_ITEMS、RESONANCE_WEAPONS、RESONANCE_RECIPES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / SOULMARK
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
# ■ FS_MasterSetup 17 Soulmark
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 載入順序：17 / 20
# 分類用途：魂刻技能、共鳴素材、武器與配方
#
# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。
# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。
#==============================================================================

module FS_MASTER_SETUP
  module SOULMARK
    ELEMENT_NAMES = {
    
        4=>"一般", 5=>"格鬥", 6=>"飛行", 7=>"毒", 8=>"地面", 9=>"岩石",
    
        10=>"蟲", 11=>"幽靈", 12=>"鋼", 13=>"火", 14=>"水", 15=>"草",
    
        16=>"電", 17=>"超能力", 18=>"冰", 19=>"龍", 20=>"惡", 21=>"妖精"
    
      }

    HARMFUL_STATES = [31, 32, 33, 34, 35, 37, 38, 39, 41, 44, 45, 46, 47, 48, 49, 50, 59, 67]

    BUFF_STATES = [52, 54, 55, 56, 57, 65, 72]

    SOUL_ARTS = [
    
        { :base => "草蛙", :species => "妙蛙種子系", :name => "根域共生", :description => "恢復單體召喚物18%最大HP，解除中毒與腐蝕，並提升精神。", :scope => 7, :element => 15, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [56], :effects => { :heal_maxhp => 18, :cleanse_ids => [31, 37] } },
    
        { :base => "火蜥", :species => "小火龍系", :name => "餘燼追獵", :description => "火屬性單體攻擊；灼燒目標增傷45%，並削減10% ATB。", :scope => 1, :element => 13, :base_damage => 225, :atk_f => 0, :spi_f => 180, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [], :effects => { :bonus_vs_state => [34, 45], :atb_shift => -10, :bonus_low_hp => [30, 35], :state => [34, 35, 1] } },
    
        { :base => "沼螈", :species => "沼躍魚系", :name => "潮甲回流", :description => "恢復單體14%最大HP，解除濕潤並提高防禦。", :scope => 7, :element => 14, :base_damage => 0, :atk_f => 0, :spi_f => 0, :physical => false, :cooldown => 2, :hit => 100, :variance => 8, :plus_states => [55], :effects => { :heal_maxhp => 14, :cleanse_ids => [32] } },
    
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

  end
end
