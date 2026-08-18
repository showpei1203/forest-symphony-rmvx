#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MasterSetup 01 Skills Heroes v1.4 OD Economy
# 【用途】Forest Symphony MasterSetup 資料頁「FS_MasterSetup 01 Skills Heroes v1.4 OD Economy」，集中定義正式遊戲資料／修正資料。
# 【主要機制】依 00～20 編號順序建立技能、狀態、物品、裝備、敵人、文字、Soulmark 等 Authority 資料，最終由 Apply 頁套用。
# 【主要影響】FS_MASTER_SETUP、SKILLS
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ACTION_OVERRIDES、DATA。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】必須依 00～20 編號順序；18 Apply 不可提前。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】DATA AUTHORITY / SKILLS HEROES
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



# ■ FS_MasterSetup 01 Skills Heroes v1.4 OD Economy



#------------------------------------------------------------------------------



# RPG Maker VX / RGSS2



# 載入順序：01 / 20



# 分類用途：汲取與六名主要角色技能（ID 82、100～159）



#



# 本頁由 FS_MasterSetup_AllData_v1_1 自動等值拆分。



# 請依編號順序放置，並停用原本未拆分的整合頁，避免資料重複套用。



#==============================================================================







module FS_MASTER_SETUP



  module SKILLS



    ACTION_OVERRIDES = {



    



        82  => "汲取",



    



        110 => "治療之觸",



    



        120 => "精準刺擊"



    



      }







    DATA = {}







    DATA.merge!({



        82 => {



    



          :name => "魂刻汲取",



    



          :scope => 1,



    



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



    



          :note => "<steal>\n<action: 汲取>\n<jp cost:0>\n<cannot level>\n<pop_text:讓我聽見你的殘響。>\n<pop_text:這段旋律，我收下了。>",



    



        },



    







        100 => {



    



          :name => "森芽斬",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 120,



    



          :variance => 12,



    



          :atk_f => 150,



    



          :spi_f => 0,



    



          :mp_cost => 4,



    



          :hit => 97,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [15],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:0>\n<jp level:1>\n<charge: 4, 5%, 0>\n<recharge:22%>\n<state_chance 40:45>\n<joey_resonance_pull 100:12:18>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:先把旋律種下。>\n<pop_text:從這一刀開始共鳴。>",



    



        },



    







        101 => {



    



          :name => "共鳴標記",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 40,



    



          :variance => 0,



    



          :atk_f => 60,



    



          :spi_f => 60,



    



          :mp_cost => 6,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:400>\n<jp level:6>\n<jp skill:100>\n<charge: 4, 6%, 0>\n<recharge:18%>\n<state_chance 40:100>\n<joey_resonance_pull 100:12:18>\n<cannot level>\n<pop_text:聽見了嗎？跟上它。>\n<pop_text:把聲音留在那裡。>",



    



        },



    







        102 => {



    



          :name => "共鳴感知",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<cc_od_summon_action:55>\n<jp cost:900>\n<jp level:10>\n<jp skill:101>\n<PASSIVE_SKILL>\nSPI +5%\nAGI +5%\n</PASSIVE_SKILL>\n<hide>",



    



        },



    







        103 => {



    



          :name => "藤脈牽引",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 160,



    



          :variance => 10,



    



          :atk_f => 60,



    



          :spi_f => 130,



    



          :mp_cost => 10,



    



          :hit => 95,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [15],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:128>\n<jp level:12>\n<jp skill:101>\n<charge: 4, 10%, 0>\n<recharge:12%>\n<bonus_vs_state 40:30>\n<atb_shift:-12>\n<state_chance 38:40>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:別急，森林會抓住你。>\n<pop_text:節奏太快了，慢一點。>",



    



        },



    







        104 => {



    



          :name => "鳴刻指令",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 0,



    



          :variance => 0,



    



          :atk_f => 0,



    



          :spi_f => 0,



    



          :mp_cost => 14,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:1500>\n<jp level:18>\n<jp skill:103>\n<charge: 4, 12%, 0>\n<recharge:8%>\n<ricarica turni:1>\n<summon_followup_role starter:190:450:80>\n<cannot level>\n<pop_text:鳴刻，接續！>\n<pop_text:輪到你回應了！>",



    



        },



    







        105 => {



    



          :name => "龍森交錯",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 300,



    



          :variance => 12,



    



          :atk_f => 120,



    



          :spi_f => 120,



    



          :mp_cost => 18,



    



          :hit => 95,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [15, 19],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:2800>\n<jp level:27>\n<jp skill:103>\n<charge: 4, 16%, 0>\n<recharge:5%>\n<bonus_vs_state 40:45>\n<crit_rate:5>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:900>\n<level 2 jp cost:2600>\n<level 3 jp cost:6500>\n<pop_text:龍息與森脈，一起。>\n<pop_text:兩道旋律，交會。>",



    



        },



    







        106 => {



    



          :name => "和聲領袖",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<bonus_if_od 70:20>\n<jp cost:4500>\n<jp level:34>\n<jp skill:105>\n<PASSIVE_SKILL>\nMAXMP +10%\n</PASSIVE_SKILL>\n<hide>",



    



        },



    







        107 => {



    



          :name => "共鳴轉奏",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 180,



    



          :variance => 8,



    



          :atk_f => 90,



    



          :spi_f => 90,



    



          :mp_cost => 22,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:5000>\n<jp level:36>\n<jp skill:105>\n<charge: 4, 20%, 0>\n<recharge:0%>\n<ricarica turni:1>\n<summon_followup_type pokemon:190:600:120>\n<bonus_vs_state 40:30>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:900>\n<level 2 jp cost:2600>\n<level 3 jp cost:6500>\n<pop_text:換一段旋律。>\n<pop_text:別停，接著奏。>",



    



        },



    







        108 => {



    



          :name => "三聲連鎖",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 240,



    



          :variance => 8,



    



          :atk_f => 100,



    



          :spi_f => 100,



    



          :mp_cost => 30,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:9000>\n<jp level:46>\n<jp skill:107>\n<charge: 4, 28%, 0>\n<recharge:0%>\n<ricarica turni:3>\n<summon_chain_type 1:pokemon:190:650:0>\n<summon_chain_type 2:robot:191:700:100>\n<summon_chain_type 3:clone:192:178:250>\n<max level 2>\n<level dmg all:+10%>\n<level 1 jp cost:5000>\n<level 2 jp cost:12000>\n<pop_text:三聲，依序響起！>\n<pop_text:第一聲之後，別眨眼。>",



    



        },



    







        109 => {



    



          :name => "森之交響",



    



          :scope => 2,



    



          :occasion => 1,



    



          :base_damage => 650,



    



          :variance => 5,



    



          :atk_f => 170,



    



          :spi_f => 170,



    



          :mp_cost => 58,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [15, 19],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:16000>\n<jp level:58>\n<jp skill:108>\n<charge: 4, 40%, 0>\n<recharge:0%>\n<ricarica turni:4>\n<bonus_vs_state 40:60>\n<summon_chain_role 1:starter:190:178:0>\n<summon_chain_role 2:engine:191:900:150>\n<summon_chain_role 3:finisher:192:1000:350>\n<max level 2>\n<level dmg all:+10%>\n<level 1 jp cost:5000>\n<level 2 jp cost:12000>\n<pop_text:整座森林都在回應。>\n<pop_text:這就是我們的交響。>",



    



        },



    







        110 => {



    



          :name => "治療之觸",



    



          :scope => 7,



    



          :occasion => 1,



    



          :base_damage => -180,



    



          :variance => 4,



    



          :atk_f => 0,



    



          :spi_f => 180,



    



          :mp_cost => 6,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [21],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:0>\n<jp level:1>\n<charge: 4, 6%, 0>\n<recharge:20%>\n<heal_bonus:10>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:2000>\n<level 3 jp cost:5000>\n<pop_text:先別逞強，我在。>\n<pop_text:傷口會好起來的。>",



    



        },



    







        111 => {



    



          :name => "溢光",



    



          :scope => 7,



    



          :occasion => 1,



    



          :base_damage => -220,



    



          :variance => 4,



    



          :atk_f => 0,



    



          :spi_f => 190,



    



          :mp_cost => 10,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [21],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:400>\n<jp level:6>\n<jp skill:110>\n<charge: 4, 8%, 0>\n<recharge:15%>\n<overheal_to_user_state 41:10>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:2000>\n<level 3 jp cost:5000>\n<pop_text:多出來的光，我會收好。>\n<pop_text:讓光留在弦上。>",



    



        },



    







        112 => {



    



          :name => "溢光回路",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<jp cost:900>\n<jp level:10>\n<jp skill:111>\n<cc_od_overheal_percent:2.5>\n<heal_bonus_per_od_percent:0.15>\n<hide>",



    



        },



    







        113 => {



    



          :name => "魔力護幕",



    



          :scope => 7,



    



          :occasion => 1,



    



          :base_damage => -240,



    



          :variance => 4,



    



          :atk_f => 0,



    



          :spi_f => 210,



    



          :mp_cost => 14,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [21],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:128>\n<jp level:12>\n<jp skill:111>\n<charge: 4, 10%, 0>\n<recharge:12%>\n<overdrive 150>\n<overheal_to_shield 52:75>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:2000>\n<level 3 jp cost:5000>\n<pop_text:光會替你擋下來。>\n<pop_text:待在護幕裡。>",



    



        },



    







        114 => {



    



          :name => "群體禱歌",



    



          :scope => 8,



    



          :occasion => 1,



    



          :base_damage => -170,



    



          :variance => 4,



    



          :atk_f => 0,



    



          :spi_f => 155,



    



          :mp_cost => 24,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [21],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:1500>\n<jp level:18>\n<jp skill:113>\n<charge: 4, 14%, 0>\n<recharge:8%>\n<heal_bonus:5>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:2000>\n<level 3 jp cost:5000>\n<pop_text:大家一起，慢慢呼吸。>\n<pop_text:光會照到每一個人。>",



    



        },



    







        115 => {



    



          :name => "魔力彈",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 180,



    



          :variance => 8,



    



          :atk_f => 0,



    



          :spi_f => 190,



    



          :mp_cost => 12,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [21],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:2800>\n<jp level:27>\n<jp skill:113>\n<charge: 4, 12%, 0>\n<recharge:10%>\n<bonus_per_user_state_stack 41:15>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:存下的光，借我一下。>\n<pop_text:這次讓光去戰鬥。>",



    



        },



    







        116 => {



    



          :name => "大地祝福",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<jp cost:4500>\n<jp level:34>\n<jp skill:115>\n<PASSIVE_SKILL>\nMAXMP +15%\nSPI +10%\n</PASSIVE_SKILL>\n<hide>",



    



        },



    







        117 => {



    



          :name => "星輝爆發",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 400,



    



          :variance => 8,



    



          :atk_f => 0,



    



          :spi_f => 250,



    



          :mp_cost => 22,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [21, 6],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:5000>\n<jp level:36>\n<jp skill:115>\n<charge: 4, 20%, 0>\n<recharge:0%>\n<ricarica turni:1>\n<bonus_per_user_state_stack 41:20>\n<consume_user_state 41:3>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:900>\n<level 2 jp cost:2600>\n<level 3 jp cost:6500>\n<pop_text:星光，請回應我。>\n<pop_text:把累積的光釋放。>",



    



        },



    







        118 => {



    



          :name => "生命回響",



    



          :scope => 9,



    



          :occasion => 1,



    



          :base_damage => -300,



    



          :variance => 0,



    



          :atk_f => 0,



    



          :spi_f => 220,



    



          :mp_cost => 36,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [21],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:9000>\n<jp level:46>\n<jp skill:117>\n<charge: 4, 28%, 0>\n<recharge:0%>\n<ricarica turni:3>\n<revive_od_upgrade 300:60:20>\n<cannot level>\n<pop_text:還沒有結束，回來。>\n<pop_text:你的聲音還在。>",



    



        },



    







        119 => {



    



          :name => "大地頌歌",



    



          :scope => 8,



    



          :occasion => 1,



    



          :base_damage => -460,



    



          :variance => 0,



    



          :atk_f => 0,



    



          :spi_f => 290,



    



          :mp_cost => 58,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [21, 15],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:16000>\n<jp level:58>\n<jp skill:118>\n<charge: 4, 38%, 0>\n<recharge:0%>\n<ricarica turni:4>\n<overheal_to_shield 52:60>\n<overheal_to_user_state 41:25>\n<max level 2>\n<level dmg all:+10%>\n<level 1 jp cost:5000>\n<level 2 jp cost:12000>\n<pop_text:願大地托住所有人。>\n<pop_text:別怕，我們都會留下。>",



    



        },



    







        120 => {



    



          :name => "電刃突刺",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 140,



    



          :variance => 8,



    



          :atk_f => 150,



    



          :spi_f => 0,



    



          :mp_cost => 5,



    



          :hit => 97,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [16],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:0>\n<jp level:1>\n<charge: 4, 4%, 0>\n<recharge:25%>\n<atb_shift:-8>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:切入電位差。>\n<pop_text:路徑確認，突進。>",



    



        },



    







        121 => {



    



          :name => "截流",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 180,



    



          :variance => 8,



    



          :atk_f => 160,



    



          :spi_f => 0,



    



          :mp_cost => 8,



    



          :hit => 97,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [12, 16],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:400>\n<jp level:6>\n<jp skill:120>\n<charge: 4, 6%, 0>\n<recharge:20%>\n<atb_shift:-16>\n<atb_bonus_if_target_atb_above 60:35>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:電流到此為止。>\n<pop_text:你的節奏太明顯了。>",



    



        },



    







        122 => {



    



          :name => "靜電回收",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<jp cost:900>\n<jp level:10>\n<jp skill:121>\n<cc_od_atb_per_10:30>\n<hide>",



    



        },



    







        123 => {



    



          :name => "雷鎖",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 210,



    



          :variance => 8,



    



          :atk_f => 80,



    



          :spi_f => 120,



    



          :mp_cost => 12,



    



          :hit => 95,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [16],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:128>\n<jp level:12>\n<jp skill:121>\n<charge: 4, 8%, 0>\n<recharge:15%>\n<atb_shift:-14>\n<atb_bonus_vs_state 32:60>\n<state_chance_vs_state 33,32:35>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:濕度足夠，導通。>\n<pop_text:鎖定神經訊號。>",



    



        },



    







        124 => {



    



          :name => "超載迴路",



    



          :scope => 11,



    



          :occasion => 1,



    



          :base_damage => 0,



    



          :variance => 0,



    



          :atk_f => 0,



    



          :spi_f => 0,



    



          :mp_cost => 15,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [16],



    



          :plus_state_set => [42, 100],



    



          :minus_state_set => [],



    



          :note => "<jp cost:1500>\n<jp level:18>\n<jp skill:123>\n<charge: 4, 8%, 0>\n<recharge:15%>\n<ricarica turni:2>\n<overdrive 250>\n<aizhuo_overload_next_atb 30:30>\n<cannot level>\n<pop_text:提高輸出，承擔風險。>\n<pop_text:迴路開放，別拖時間。>",



    



        },



    







        125 => {



    



          :name => "時間斷層",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 300,



    



          :variance => 8,



    



          :atk_f => 180,



    



          :spi_f => 80,



    



          :mp_cost => 20,



    



          :hit => 97,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [12, 16],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:2800>\n<jp level:27>\n<jp skill:123>\n<charge: 4, 12%, 0>\n<recharge:8%>\n<atb_shift:-24>\n<atb_bonus_if_target_atb_above 80:50>\n<atb_interrupt_threshold:80>\n<atb_interrupt_cost:200>\n<atb_interrupt_state 38:2>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:900>\n<level 2 jp cost:2600>\n<level 3 jp cost:6500>\n<pop_text:你的下一秒，被切掉了。>\n<pop_text:時間窗口，現在關閉。>",



    



        },



    







        126 => {



    



          :name => "超頻神經",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<jp cost:4500>\n<jp level:34>\n<jp skill:125>\n<PASSIVE_SKILL>\nAGI +12%\n</PASSIVE_SKILL>\n<hide>",



    



        },



    







        127 => {



    



          :name => "鏈式放電",



    



          :scope => 2,



    



          :occasion => 1,



    



          :base_damage => 250,



    



          :variance => 12,



    



          :atk_f => 60,



    



          :spi_f => 180,



    



          :mp_cost => 28,



    



          :hit => 95,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [16],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:5000>\n<jp level:36>\n<jp skill:125>\n<charge: 4, 18%, 0>\n<recharge:0%>\n<ricarica turni:1>\n<bonus_vs_state 32:35>\n<atb_shift:-10>\n<atb_bonus_vs_state 32:40>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:900>\n<level 2 jp cost:2600>\n<level 3 jp cost:6500>\n<pop_text:接點完成，連鎖。>\n<pop_text:一個都別漏掉。>",



    



        },



    







        128 => {



    



          :name => "零時封鎖",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 460,



    



          :variance => 4,



    



          :atk_f => 220,



    



          :spi_f => 100,



    



          :mp_cost => 38,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [12, 16],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:9000>\n<jp level:46>\n<jp skill:127>\n<charge: 4, 24%, 0>\n<recharge:0%>\n<ricarica turni:3>\n<atb_shift:-35>\n<atb_bonus_if_target_atb_above 90:80>\n<atb_interrupt_threshold:90>\n<atb_interrupt_cost:350>\n<atb_interrupt_state 38:2>\n<max level 2>\n<level dmg all:+10%>\n<level 1 jp cost:5000>\n<level 2 jp cost:12000>\n<pop_text:歸零。>\n<pop_text:你沒有下一個動作。>",



    



        },



    







        129 => {



    



          :name => "終端超頻",



    



          :scope => 2,



    



          :occasion => 1,



    



          :base_damage => 620,



    



          :variance => 6,



    



          :atk_f => 160,



    



          :spi_f => 220,



    



          :mp_cost => 58,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [16],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:16000>\n<jp level:58>\n<jp skill:128>\n<charge: 4, 36%, 0>\n<recharge:0%>\n<ricarica turni:4>\n<atb_shift:-22>\n<bonus_if_target_atb_above 70:40>\n<atb_bonus_if_target_atb_above 70:50>\n<state_chance 33:25>\n<max level 2>\n<level dmg all:+10%>\n<level 1 jp cost:5000>\n<level 2 jp cost:12000>\n<pop_text:限制解除，直到結束。>\n<pop_text:讓計算追上勝利。>",



    



        },



    







        130 => {



    



          :name => "毒針",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 90,



    



          :variance => 4,



    



          :atk_f => 0,



    



          :spi_f => 140,



    



          :mp_cost => 5,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [7],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:0>\n<jp level:1>\n<charge: 4, 5%, 0>\n<recharge:22%>\n<state_chance 31:70>\n<ai_prefer_stack_below 31:5>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:先做一個小樣本。>\n<pop_text:毒理觀察，開始。>",



    



        },



    







        131 => {



    



          :name => "毒素培養",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 50,



    



          :variance => 0,



    



          :atk_f => 0,



    



          :spi_f => 100,



    



          :mp_cost => 8,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [7],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:400>\n<jp level:6>\n<jp skill:130>\n<charge: 4, 6%, 0>\n<recharge:18%>\n<state_chance 31:90>\n<state_stack_if_present 31:2>\n<ai_prefer_stack_below 31:5>\n<cannot level>\n<pop_text:濃度還不夠。>\n<pop_text:再養一層，別浪費病灶。>",



    



        },



    







        132 => {



    



          :name => "毒理學",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<state_chance_bonus 31:10>\n<state_chance_bonus 35:10>\n<state_chance_bonus 37:10>\n<state_chance_per_od_percent 31:0.1>\n<state_chance_per_od_percent 35:0.1>\n<state_chance_per_od_percent 37:0.1>\n<jp cost:900>\n<jp level:10>\n<jp skill:131>\n<PASSIVE_SKILL>\nSPI +10%\n</PASSIVE_SKILL>\n<hide>",



    



        },



    







        133 => {



    



          :name => "毒霧擴散",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 80,



    



          :variance => 0,



    



          :atk_f => 0,



    



          :spi_f => 100,



    



          :mp_cost => 12,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [7],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:128>\n<jp level:12>\n<jp skill:131>\n<charge: 4, 8%, 0>\n<recharge:15%>\n<overdrive 150>\n<spread_state 31:2:100>\n<cannot level>\n<pop_text:別只感染一個。>\n<pop_text:病灶應該學會旅行。>",



    



        },



    







        134 => {



    



          :name => "寄生漂移",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 120,



    



          :variance => 4,



    



          :atk_f => 0,



    



          :spi_f => 140,



    



          :mp_cost => 14,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [15],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:1500>\n<jp level:18>\n<jp skill:133>\n<charge: 4, 10%, 0>\n<recharge:12%>\n<drift_state 31:1>\n<state_chance 35:40>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:宿主換了，實驗繼續。>\n<pop_text:死亡不能中斷培養。>",



    



        },



    







        135 => {



    



          :name => "腐蝕煉成",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 160,



    



          :variance => 4,



    



          :atk_f => 0,



    



          :spi_f => 160,



    



          :mp_cost => 18,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [7],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:2800>\n<jp level:27>\n<jp skill:133>\n<charge: 4, 12%, 0>\n<recharge:8%>\n<ricarica turni:1>\n<convert_state 31:37>\n<convert_preserve_state_od 31:37:1:150>\n<cannot level>\n<pop_text:毒只是原料。>\n<pop_text:把症狀煉成破口。>",



    



        },



    







        136 => {



    



          :name => "病灶連鎖",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<jp cost:4500>\n<jp level:34>\n<jp skill:135>\n<cc_od_state_stack:45>\n<cc_od_state_copy:20>\n<hide>",



    



        },



    







        137 => {



    



          :name => "百病相生",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 280,



    



          :variance => 8,



    



          :atk_f => 0,



    



          :spi_f => 220,



    



          :mp_cost => 22,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [7, 17],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:5000>\n<jp level:36>\n<jp skill:135>\n<charge: 4, 16%, 0>\n<recharge:5%>\n<bonus_per_target_state:12>\n<bonus_if_state_count 3:35>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:900>\n<level 2 jp cost:2600>\n<level 3 jp cost:6500>\n<pop_text:症狀越多，答案越簡單。>\n<pop_text:你的病歷很有價值。>",



    



        },



    







        138 => {



    



          :name => "毒爆處刑",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 220,



    



          :variance => 4,



    



          :atk_f => 0,



    



          :spi_f => 180,



    



          :mp_cost => 32,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [7],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:9000>\n<jp level:46>\n<jp skill:137>\n<charge: 4, 24%, 0>\n<recharge:0%>\n<ricarica turni:2>\n<detonate_state_spi 31:90>\n<detonate_state_percent 31:0.8>\n<detonate_cap:6000>\n<overdrive 300>\n<detonate_od_bonus:20>\n<detonate_preserve_state 31:1>\n<consume_state 31>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:900>\n<level 2 jp cost:2600>\n<level 3 jp cost:6500>\n<pop_text:培養完成，處刑。>\n<pop_text:把所有毒，一次結算。>",



    



        },



    







        139 => {



    



          :name => "萬毒花園",



    



          :scope => 2,



    



          :occasion => 1,



    



          :base_damage => 460,



    



          :variance => 4,



    



          :atk_f => 0,



    



          :spi_f => 270,



    



          :mp_cost => 58,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [7, 15],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:16000>\n<jp level:58>\n<jp skill:138>\n<charge: 4, 36%, 0>\n<recharge:0%>\n<ricarica turni:4>\n<state_chance 31:75>\n<state_chance 37:45>\n<bonus_per_target_state:8>\n<max level 2>\n<level dmg all:+10%>\n<level 1 jp cost:5000>\n<level 2 jp cost:12000>\n<pop_text:歡迎進入我的培養皿。>\n<pop_text:每一朵花都有副作用。>",



    



        },



    







        140 => {



    



          :name => "盾撞",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 150,



    



          :variance => 12,



    



          :atk_f => 150,



    



          :spi_f => 0,



    



          :mp_cost => 4,



    



          :hit => 95,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [12],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:0>\n<jp level:1>\n<charge: 4, 5%, 0>\n<recharge:20%>\n<state_chance 49:20>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:退後，我來。>\n<pop_text:站穩，不准過去。>",



    



        },



    







        141 => {



    



          :name => "荊棘護陣",



    



          :scope => 11,



    



          :occasion => 1,



    



          :base_damage => 0,



    



          :variance => 0,



    



          :atk_f => 0,



    



          :spi_f => 0,



    



          :mp_cost => 8,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [15],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:400>\n<jp level:6>\n<jp skill:140>\n<charge: 4, 0%, 0>\n<recharge:20%>\n<ricarica turni:1>\n<ig:2,2,20>\n<io:10>\n<mpu:荊棘護陣！>\n<cannot level>\n<pop_text:躲我後面，快。>\n<pop_text:想碰他們，先問我的盾。>",



    



        },



    







        142 => {



    



          :name => "怒意不熄",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<jp cost:900>\n<jp level:10>\n<jp skill:141>\n<reduce_damage_if_od 50:12>\n<reduce_damage_per_od_percent:0.08>\n<hide>",



    



        },



    







        143 => {



    



          :name => "怒擊",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 220,



    



          :variance => 12,



    



          :atk_f => 180,



    



          :spi_f => 0,



    



          :mp_cost => 8,



    



          :hit => 95,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [15, 7],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:128>\n<jp level:12>\n<jp skill:141>\n<charge: 4, 8%, 0>\n<recharge:15%>\n<bonus_per_od_percent:0.35>\n<bonus_per_stored_pain 25:5:30>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:我現在很不爽。>\n<pop_text:這一拳算你的。>",



    



        },



    







        144 => {



    



          :name => "根網挑釁",



    



          :scope => 11,



    



          :occasion => 1,



    



          :base_damage => 0,



    



          :variance => 0,



    



          :atk_f => 0,



    



          :spi_f => 0,



    



          :mp_cost => 12,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [15],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:1500>\n<jp level:18>\n<jp skill:143>\n<charge: 4, 0%, 0>\n<recharge:20%>\n<ricarica turni:1>\n<it:300,15,1>\n<io:10>\n<mpu:根網挑釁！>\n<cannot level>\n<pop_text:看我，不准看別人。>\n<pop_text:有膽就衝我來。>",



    



        },



    







        145 => {



    



          :name => "痛苦熔爐",



    



          :scope => 11,



    



          :occasion => 1,



    



          :base_damage => 0,



    



          :variance => 0,



    



          :atk_f => 0,



    



          :spi_f => 0,



    



          :mp_cost => 16,



    



          :hit => 100,



    



          :physical_attack => false,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [13, 7],



    



          :plus_state_set => [85, 100],



    



          :minus_state_set => [],



    



          :note => "<jp cost:2800>\n<jp level:27>\n<jp skill:143>\n<charge: 4, 10%, 0>\n<recharge:10%>\n<ricarica turni:2>\n<cannot level>\n<pop_text:打吧，我會全部記住。>\n<pop_text:痛苦不會白費。>",



    



        },



    







        146 => {



    



          :name => "替身承擔",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<jp cost:4500>\n<jp level:34>\n<jp skill:145>\n<cover_store_cap_percent:400>\n<hide>",



    



        },



    







        147 => {



    



          :name => "復仇重擊",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 260,



    



          :variance => 8,



    



          :atk_f => 200,



    



          :spi_f => 0,



    



          :mp_cost => 18,



    



          :hit => 100,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [7, 12],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:5000>\n<jp level:36>\n<jp skill:145>\n<charge: 4, 18%, 0>\n<recharge:0%>\n<ricarica turni:1>\n<revenge_from_cover:50>\n<consume_stored_cover>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:900>\n<level 2 jp cost:2600>\n<level 3 jp cost:6500>\n<pop_text:剛才的，現在還你。>\n<pop_text:我替他們挨的，全算在你頭上。>",



    



        },



    







        148 => {



    



          :name => "城牆反擊",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 480,



    



          :variance => 10,



    



          :atk_f => 235,



    



          :spi_f => 0,



    



          :mp_cost => 28,



    



          :hit => 95,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [12],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:9000>\n<jp level:46>\n<jp skill:147>\n<charge: 4, 24%, 0>\n<recharge:0%>\n<ricarica turni:2>\n<overdrive 250>\n<bonus_if_od 70:45>\n<bonus_per_od_100:5>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:900>\n<level 2 jp cost:2600>\n<level 3 jp cost:6500>\n<pop_text:城牆也會揍人。>\n<pop_text:守住之後，輪到我。>",



    



        },



    







        149 => {



    



          :name => "怒海歸還",



    



          :scope => 2,



    



          :occasion => 1,



    



          :base_damage => 620,



    



          :variance => 6,



    



          :atk_f => 250,



    



          :spi_f => 0,



    



          :mp_cost => 52,



    



          :hit => 100,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [15, 7],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:16000>\n<jp level:58>\n<jp skill:148>\n<charge: 4, 38%, 0>\n<recharge:0%>\n<ricarica turni:4>\n<revenge_from_cover:80>\n<consume_stored_cover>\n<max level 2>\n<level dmg all:+10%>\n<level 1 jp cost:5000>\n<level 2 jp cost:12000>\n<pop_text:欠下的痛，全部歸還。>\n<pop_text:你打了多少，我還多少。>",



    



        },



    







        150 => {



    



          :name => "震拳",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 150,



    



          :variance => 8,



    



          :atk_f => 170,



    



          :spi_f => 0,



    



          :mp_cost => 4,



    



          :hit => 95,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [5],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:0>\n<jp level:1>\n<charge: 4, 5%, 0>\n<recharge:20%>\n<break_power:1>\n<break_state:50>\n<broken_state:51>\n<break_threshold:5>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:先敲一道裂縫。>\n<pop_text:拳頭比城門講道理。>",



    



        },



    







        151 => {



    



          :name => "破甲連擊",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 200,



    



          :variance => 12,



    



          :atk_f => 190,



    



          :spi_f => 0,



    



          :mp_cost => 8,



    



          :hit => 95,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [5],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:400>\n<jp level:6>\n<jp skill:150>\n<charge: 4, 8%, 0>\n<recharge:15%>\n<break_power:2>\n<break_state:50>\n<broken_state:51>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:一層一層拆。>\n<pop_text:護甲不是永久建築。>",



    



        },



    







        152 => {



    



          :name => "鬥志打磨",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<jp cost:900>\n<jp level:10>\n<jp skill:151>\n<cc_od_break_point:45>\n<hide>",



    



        },



    







        153 => {



    



          :name => "乘隙追打",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 240,



    



          :variance => 8,



    



          :atk_f => 210,



    



          :spi_f => 0,



    



          :mp_cost => 10,



    



          :hit => 95,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [5],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:128>\n<jp level:12>\n<jp skill:151>\n<charge: 4, 8%, 0>\n<recharge:15%>\n<bonus_vs_state 50:35>\n<tyler_break_lock_od 100:15>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:裂了就別想補。>\n<pop_text:我看到破口了。>",



    



        },



    







        154 => {



    



          :name => "破陣震波",



    



          :scope => 2,



    



          :occasion => 1,



    



          :base_damage => 180,



    



          :variance => 12,



    



          :atk_f => 140,



    



          :spi_f => 0,



    



          :mp_cost => 16,



    



          :hit => 95,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [5],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:1500>\n<jp level:18>\n<jp skill:153>\n<charge: 4, 14%, 0>\n<recharge:8%>\n<break_power:1>\n<break_state:50>\n<broken_state:51>\n<max level 3>\n<level dmg all:+8%>\n<level 1 jp cost:600>\n<level 2 jp cost:1800>\n<level 3 jp cost:4500>\n<pop_text:一起裂開吧。>\n<pop_text:站成一排，省我時間。>",



    



        },



    







        155 => {



    



          :name => "破勢超載",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 320,



    



          :variance => 8,



    



          :atk_f => 220,



    



          :spi_f => 0,



    



          :mp_cost => 18,



    



          :hit => 95,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [13, 5],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:2800>\n<jp level:27>\n<jp skill:153>\n<charge: 4, 14%, 0>\n<recharge:5%>\n<break_power:2>\n<break_bonus_od_tier 50:1:150>\n<break_bonus_od_tier 80:1:200>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:900>\n<level 2 jp cost:2600>\n<level 3 jp cost:6500>\n<pop_text:還差一點？那就加倍。>\n<pop_text:用力不夠，只是藉口。>",



    



        },



    







        156 => {



    



          :name => "破城者",



    



          :scope => 0,



    



          :occasion => 3,



    



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



    



          :note => "<mechanic_passive>\n<jp cost:4500>\n<jp level:34>\n<jp skill:155>\n<pen_rate:12>\n<hide>",



    



        },



    







        157 => {



    



          :name => "崩防追獵",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 400,



    



          :variance => 8,



    



          :atk_f => 255,



    



          :spi_f => 0,



    



          :mp_cost => 24,



    



          :hit => 100,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [5],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:5000>\n<jp level:36>\n<jp skill:155>\n<charge: 4, 18%, 0>\n<recharge:0%>\n<bonus_vs_state 51:80>\n<max level 3>\n<level dmg all:+10%>\n<level 1 jp cost:900>\n<level 2 jp cost:2600>\n<level 3 jp cost:6500>\n<pop_text:門開了，大家上！>\n<pop_text:崩防窗口，別浪費！>",



    



        },



    







        158 => {



    



          :name => "斷城終結",



    



          :scope => 1,



    



          :occasion => 1,



    



          :base_damage => 620,



    



          :variance => 4,



    



          :atk_f => 310,



    



          :spi_f => 0,



    



          :mp_cost => 36,



    



          :hit => 100,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [13, 5],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:9000>\n<jp level:46>\n<jp skill:157>\n<charge: 4, 28%, 0>\n<recharge:0%>\n<ricarica turni:3>\n<bonus_vs_state 51:120>\n<consume_broken>\n<max level 2>\n<level dmg all:+10%>\n<level 1 jp cost:5000>\n<level 2 jp cost:12000>\n<pop_text:窗口歸我，結束。>\n<pop_text:城倒了，人也別站著。>",



    



        },



    







        159 => {



    



          :name => "地裂終章",



    



          :scope => 2,



    



          :occasion => 1,



    



          :base_damage => 580,



    



          :variance => 6,



    



          :atk_f => 275,



    



          :spi_f => 0,



    



          :mp_cost => 58,



    



          :hit => 100,



    



          :physical_attack => true,



    



          :damage_to_mp => false,



    



          :absorb_damage => false,



    



          :ignore_defense => false,



    



          :element_set => [8, 5],



    



          :plus_state_set => [],



    



          :minus_state_set => [],



    



          :note => "<jp cost:16000>\n<jp level:58>\n<jp skill:158>\n<charge: 4, 40%, 0>\n<recharge:0%>\n<ricarica turni:4>\n<break_power:2>\n<break_bonus_od_tier 80:1:150>\n<max level 2>\n<level dmg all:+10%>\n<level 1 jp cost:5000>\n<level 2 jp cost:12000>\n<pop_text:地面先投降了。>\n<pop_text:整片戰場，一起碎。>",



    



        },



    







      })



  end



end









