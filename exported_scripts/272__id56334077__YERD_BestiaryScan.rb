#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：YERD_BestiaryScan｜Yanfly Engine RD - Bestiary + Display Scanned Enemy
# 最後更新：2009-06-13｜難度：Easy / Normal / Hard / Lunatic
# Credit：Yanfly；Window_Command 匯入部分致謝 KGC。
#
# 【用途】
# 戰鬥中選取敵人時顯示掃描資料，並提供主選單 Bestiary／敵人圖鑑。資料可分頁顯示 HP／MP、
# 能力、技能、屬性倍率、狀態成功率、偷竊、戰利品、掉落與自訂說明；可要求先用 Scan Skill
# 解鎖，也能針對特定 Enemy 用 <hide ...> 隱藏頁面。
#
# 【圖鑑入口】
# BESTIARY_SWITCH 控制主選單圖鑑是否可用；HIDDEN_MONSTERS 隱藏不應出現在圖鑑的 Enemy；
# BESTIARY_ORDER 控制顯示順序。CATEGORIZE_* 控制 Boss 類型切換與文字。
# 戰鬥掃描按鍵由 ENEMY_SCAN_BUTTON 控制，目前為 Input::SHIFT。
# REQUIRE_SCAN=true 時，Enemy Type 未被 Scan Skill 解鎖前不顯示精確資料。
#
# 【Skill Notetag｜解鎖資料】
# <scan whole>                    全部掃描資料
# <scan hp mp>                    HP／MP
# <scan stats>                    ADSA／HECO 能力頁
# <scan skills>                   Enemy Action List 中會使用的技能
# <scan elements>                 屬性倍率
# <scan status effects> / <scan states> 狀態成功率
# <scan steal>                    偷竊資料；需 KGC Steal
# <scan spoils>                   EXP／Gold／遭遇／擊倒／逃離等戰利品資訊
# <scan drops>                    掉落物；搭配 KGC ExtraDropItem 可顯示長清單
# <scan description>              自訂說明／Notes 頁
# 掃描狀態以 Enemy Type 為基礎共用，但戰場上的個別 Enemy 仍保有自己的即時數值修正。
#
# 【Enemy Notetag｜Boss／隱藏】
# <boss type x> / <boss type x,x>：指定一個或多個 Boss 類型，影響圖鑑分類與顯示樣式。
# <hide whole>                    ：整個 Enemy 不顯示掃描資料。
# <hide hp_mp>                    ：隱藏 HP／MP。
# <hide stats>                    ：隱藏能力。
# <hide skills>                   ：隱藏技能。
# <hide elements>                 ：隱藏屬性倍率。
# <hide status effects> / <hide states>：隱藏狀態成功率。
# <hide steal>                    ：隱藏可偷物品。
# <hide spoils>                   ：隱藏戰利品。
# <hide drops>                    ：隱藏掉落物。
# Description 沒有對應 hide tag；沒有在 ENEMY_NOTES Hash 建立內容時，說明頁本來就不出現。
#
# 【主要設定｜Bestiary】
# BESTIARY_TITLE / BESTIARY_LIST / BESTIARY_MASK：標題、Boss 類型列表文字、未知敵人遮罩。
# BESTIARY_SWITCH：啟用圖鑑 Menu Command 的 Switch ID。
# HIDDEN_MONSTERS：完全排除的 Enemy ID／Range。
# BESTIARY_ORDER：圖鑑顯示順序；若啟用字母排序則此順序可能不生效。
# MENU_FONT_SIZE、TEXT_*、ICON_*：整體圖鑑統計文字與圖示。
#
# 【主要設定｜Scan Window】
# ENEMY_SCAN_BUTTON：戰鬥掃描按鍵。
# HELP_WINDOW_*：戰鬥 Help Window 文字、開關、位置、寬度、透明度。
# DATA_LEFT / DATA_PAGE1 / DATA_PAGES / DATA_RIGHT：頁面導覽文字。
# PAGE_SOUND：翻頁 SE；nil 表示不播放。
# REPLACE_PAGE_MSG：true 時標題改顯示頁面類型，不顯示 Page X/Y。
# SHOW_GENERAL / TITLE_GENERAL：一般資料頁。
# GAUGE_HEIGHT / EXHAUST_COLOUR / FONT_SIZE：量表高度、耗盡色、小字大小。
# HIDDEN_HP / HIDDEN_MP / HIDDEN_STAT：未掃描或被隱藏時的替代文字。
# HP_DISPLAY_TYPE / MP_DISPLAY_TYPE：1目前值、2目前/最大、3百分比。
# BOSS_TYPES / TYPE_ORDERING：Boss 類型外觀與圖鑑分類順序。
# SHOW_DROPS / SHOW_NOTES：是否允許建立各資料頁。
# ELEMENT_HASH / STATES_HASH：哪些屬性／State 會被列入頁面。
# ENEMY_NOTES：Lunatic 自訂說明頁內容。
#
# 【相容性／alias】
# 原作支援 KGC ExtraDropItem、Steal，並 alias Game_Battler#skill_effect、
# Game_Enemy#initialize/transform/escape/perform_collapse、Scene_Battle 的掃描視窗流程。
# Forest Symphony 另有 EnemyBook／Bestiary 整合，因此載入順序具有語意，勿任意搬動。
#
# 【Runtime 字串】
# 本頁仍有 "Information"、"Status Effects"、"Skill Info" 等英文字串是實際遊戲 UI 資料，
# 不是註解。Phase 15 不擅自翻它們，以免把「文件中文化」混成遊戲文字改版；若要統一 UI，
# 應另開一版專門處理顯示文字。
#
# 【素材】
# PAGE_SOUND 範例曾使用 Wind7；掃描／圖鑑本身主要使用 Window／Iconset 與 Enemy Battler。
# 移除 WindowA、Wind7 或其他相關素材前仍需反查 FS EnemyBook 與 Data。
#==============================================================================
$imported = {} if $imported == nil
$imported["DisplayScannedEnemy"] = true

module YE
  module MENU
    module MONSTER
      
      #------------------------------------------------------------------------
      # 圖鑑設定
      #------------------------------------------------------------------------
      
      BESTIARY_TITLE  = "召喚圖鑑"     # 主選單顯示標題。
      BESTIARY_SWITCH = 3             # 控制圖鑑指令是否顯示的 Switch ID。
      BESTIARY_LIST   = "%s 列表"      # Boss 類型後方顯示文字。
      BESTIARY_MASK   = "?"            # 未知敵人的遮罩文字。
      
      HIDDEN_MONSTERS = [1..49,67..100]
      
      BESTIARY_ORDER = [1..100]
      
      CATEGORIZE_TEXT = "按下Shift: 改變分類"
      CATEGORIZE_HELP = "選擇想要的分類"
      CATEGORIZE_VIEW = "查詢 %s"
      CATEGORIZE_BUTTON = Input::SHIFT
      
      MENU_FONT_SIZE  = 16
      BESTIARY_INFO   = "資訊"
      TEXT_COMPLETION = "完成度"
      RATE_COMPLETION = "%#.05g%%"
      ICON_COMPLETION = 141
      TEXT_DISCOVERED = "已發現敵人種類數"
      ICON_DISCOVERED = 196
      TEXT_ENCOUNTERS = "已遭遇"
      TEXT_DEFEATED   = "死亡次數"
      TEXT_ESCAPED    = "逃離次數"
      TEXT_TYPE_DIS   = "%s 可發現種類"
      TEXT_TYPE_ENC   = "%s 召喚總次數"
      TEXT_TYPE_DEF   = "%s 死亡次數"
      TEXT_TYPE_ESC   = "%s 逃離次數"
      
      #------------------------------------------------------------------------
      # 戰鬥掃描視窗設定
      #------------------------------------------------------------------------
      
      ENEMY_SCAN_BUTTON = Input::SHIFT
      
      REQUIRE_SCAN   = false
      
      HELP_WINDOW_TX = "Press Shift to view enemy data."
      HELP_WINDOW_ON = true            # 控制視窗是否啟用。
      HELP_WINDOW_X  = 0               # 視窗 X 座標。
      HELP_WINDOW_Y  = 0               # 視窗 Y 座標。
      HELP_WINDOW_W  = 544             # 視窗寬度。
      HELP_WINDOW_O  = 255             # 視窗透明度。
      
      ENEMY_NAME = "%s 的資質"
      
      DATA_LEFT  = ""            # 可向左翻頁時顯示。
      DATA_PAGE1 = "Information"   # 只有一頁資訊時顯示。
      DATA_PAGES = "Page %d/%d"    # 多頁資訊時顯示；%d 為目前頁／總頁數。
      DATA_RIGHT = ""            # 可向右翻頁時顯示。
      DATA_CATEGORY_COLOUR = 4     # 分類文字顏色索引。
      
      PAGE_SOUND = nil# 翻頁 SE；nil 表示無音效。
      
      REPLACE_PAGE_MSG = true
      TITLE_UNKNOWN    = "Unknown"
      
      SHOW_GENERAL   = true
      TITLE_GENERAL  = "召喚記載"
      GAUGE_HEIGHT   = 5        # 量表高度。
      EXHAUST_COLOUR = 7        # 耗盡／空量表顏色。
      FONT_SIZE      = 16       # 較小文字的字體大小。
      HIDDEN_HP      = "?????"  # 未掃描／隱藏 HP 時的替代文字。
      HIDDEN_MP      = "?????"  # 未掃描／隱藏 MP 時的替代文字。
      DATA_STATES    = "Status Effects"   # 受影響狀態的分類標題。
      HIDDEN_STAT    = "???"    # 未掃描／隱藏能力時的替代文字。
      DATA_ATK       = "攻擊"    # 攻擊力顯示文字。
      DATA_DEF       = "防禦"    # 防禦力顯示文字。
      DATA_SPI       = "精神"    # 精神顯示文字。
      DATA_AGI       = "敏捷"    # 敏捷顯示文字。
      DATA_HIT       = "HIT"    # 命中率顯示文字。
      HIDE_HIT       = true    # true 時隱藏 HIT。
      DATA_EVA       = "EVA"    # 迴避率顯示文字。
      HIDE_EVA       = true    # true 時隱藏 EVA。
      DATA_CRI       = "CRI"    # 爆擊率顯示文字。
      HIDE_CRI       = true    # true 時隱藏 CRI。
      DATA_ODDS      = "LUK"    # LUK／Odds 顯示文字。
      HIDE_ODDS      = true     # true 時隱藏 Odds／LUK。
      
      HP_DISPLAY_TYPE = 2
      MP_DISPLAY_TYPE = 2
      
      # <boss type x> 會查詢此 Hash，決定該 Boss Type 的圖示、量表色與顯示名稱。
      BOSS_TYPES ={
      # Type => [Icon,HPIc,HPC1,HPC2,MPIc,MPC1,MPC2, 類型名稱, 複數名稱]
           0  =>  [3480,2449,  20,  21,2448,  22,  23, "召喚物", "召喚物"],
          # 1  =>  [ 118,  99,  20,  21, 100,  22,  23, "野怪", "野怪"],
          # 2  =>  [ 118,  99,  20,  21, 100,  22,  23, "Midboss", "Midbosses"],
      }
      
      TYPE_ORDERING = [0]
      
      ICON_HIGH = 142   # 能力高於基準值時使用的圖示。
      ICON_LOW  = 143   # 能力低於基準值時使用的圖示。
      ICON_ATK  = 2463     # ATK 圖示
      ICON_DEF  = 2451    # DEF 圖示
      ICON_SPI  = 2461    # SPI 圖示
      ICON_AGI  = 2460    # AGI 圖示
      ICON_HIT  = 2458   # HIT 圖示
      ICON_EVA  = 2457   # EVA 圖示
      ICON_CRI  = 2458   # CRI 圖示
      ICON_ODDS = 137   # ODD 圖示
      
      # 技能頁只列出該 Enemy Action List 中實際存在的技能；沒有列出的技能不會顯示。
      SHOW_SKILLS    = false
      TITLE_SKILLS   = "Skill Info"
      DATA_SKILLS    = "Skill Name"
      VIEW_SKILLS1   = "%d Skill"
      VIEW_SKILLS2   = "%d Skills"
      
      SHOW_ELEMENTS  = false
      TITLE_ELEMENTS = "Element Affinity"
      ICON_E_RATE_U  = 9        # 未知屬性倍率圖示。
      ICON_E_RATE_Z  = 96       # 屬性倍率 Z 圖示。
      ICON_E_RATE_A  = 99       # 屬性倍率 A 圖示。
      ICON_E_RATE_B  = 99       # 屬性倍率 B 圖示。
      ICON_E_RATE_C  = 102      # 屬性倍率 C 圖示。
      ICON_E_RATE_D  = 101      # 屬性倍率 D 圖示。
      ICON_E_RATE_E  = 100      # 屬性倍率 E 圖示。
      ICON_E_RATE_F  = 103      # 屬性倍率 F 圖示。
      ELEMENT_HASH ={
      
      "屬性抗性" => [
      [   4,  5,  6,  7,  8,   9,  10],
      [ 483, 482, 480, 484, 481, 485, 486]
      ],
      "物理/魔法抗性" => [
      [   15,   16],
      [  487,  488]
      ],
      
      }
      
      SHOW_STATES    = false
      TITLE_STATES   = "Status Chances"
      ICON_S_RATE_U  = 94       # 未知狀態成功率圖示。
      ICON_S_RATE_Z  = 96       # 狀態成功率 Z 圖示。
      ICON_S_RATE_A  = 99       # 狀態成功率 A 圖示。
      ICON_S_RATE_B  = 99       # 狀態成功率 B 圖示。
      ICON_S_RATE_C  = 102      # 狀態成功率 C 圖示。
      ICON_S_RATE_D  = 101      # 狀態成功率 D 圖示。
      ICON_S_RATE_E  = 100      # 狀態成功率 E 圖示。
      ICON_S_RATE_F  = 103      # 狀態成功率 F 圖示。
      STATES_HASH ={
      "Conditions" => [ 2,  3,  4,  5,  6,  7,  8],
      "Buffs"      => [ 9, 10, 11, 12],
      "Debuffs"    => [13, 14, 15, 16],
      }
      
      SHOW_STEAL     = false
      TITLE_STEAL    = "Steal Info"
      DATA_S_ITEM    = "Item Name"
      DATA_S_CHANCE  = "Rate"
      
      SHOW_SPOILS    = false
      TITLE_SPOILS   = "Victory Spoils"
      DEATH_SPOILS   = true      # true 時在死亡後揭露戰利品資訊
                                 # Enemy 死亡後揭露。
      DATA_GOLD      = "Gold"    # 金錢欄位標題。
      VIEW_GOLD      = "%d Gold" # 金錢數值格式。
      ICON_GOLD      = 205       # 金錢圖示。
      DATA_EXP       = "EXP"     # EXP 欄位標題。
      VIEW_EXP       = "%d EXP"  # EXP 數值格式。
      ICON_EXP       = 62        # EXP 圖示。
      DATA_ENCOUNTER = "Encounters" # 遭遇次數欄位標題。
      VIEW_ENC1      = "%d Time"    # 遭遇 1 次時的格式。
      VIEW_ENC2      = "%d Times"   # 遭遇多次時的格式。
      ICON_ENCOUNTER = 63           # 遭遇次數圖示。
      DATA_KILLED    = "Defeated"   # 擊倒次數欄位標題。
      VIEW_KILLED1   = "%d Kill"    # 擊倒 1 次時的格式。
      VIEW_KILLED2   = "%d Kills"   # 擊倒多次時的格式。
      ICON_KILLED    = 157          # 擊倒次數圖示。
      DATA_ESCAPED   = "Escaped"    # 逃離次數欄位標題。
      VIEW_ESCAPED1  = "%d Fled"    # 擊倒 1 次時的格式。
      VIEW_ESCAPED2  = "%d Fled"    # 擊倒多次時的格式。
      ICON_ESCAPED   = 155          # 逃離次數圖示。
      SPOIL_DROPS    = false     # 是否在戰利品頁顯示掉落物。
      DATA_DROPS     = "Drops"   # 掉落物欄位標題。
      
      SHOW_DROPS     = false
      TITLE_DROPS    = "Drops Info"
      DEATH_DROPS    = true      # true 時在死亡後揭露戰利品資訊
                                 # Enemy 死亡後揭露。
      DATA_D_ITEM    = "Drop Name"
      DATA_D_CHANCE  = "Chance"
      
      
      SHOW_NOTES            = false
      TITLE_NOTES           = "Notes"
      NOTE_PAGE_WIDTH       = 240
      NOTE_PAGE_TEXT_SIZE   = 16
      NOTE_PAGE_TEXT_COLOUR = 0
      
    end
  end
end

#===============================================================================
# Lunatic 模式／自訂說明頁
#===============================================================================
#
#
#    ENEMY_NOTES ={ 
#      enemy_id => "第一行|下一行",
# 
# 將 enemy_id 換成 Enemy ID；=> 後方填入說明文字，使用 | 分隔換行。
#
#===============================================================================

module YE
  module HASH
    
    ENEMY_NOTES ={ #複製第一行
         50  => "等級上限：Lv3|1.無|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         51  => "等級上限：Lv5|1.飛刺|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         52  => "",
         53  => "等級上限：Lv50|1.無|2.無|3.無|4.攻擊型態→無|5.防禦型態→群療術|6.魔法型態→無|7.敏捷型態→無",
         54  => "等級上限：Lv3|1.無|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         55  => "等級上限：Lv5|1.感染|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         56  => "等級上限：Lv10|1.無|2.無|3.無|4.攻擊型態→重擊|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         57  => "等級上限：Lv3|1.療傷|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         58  => "等級上限：Lv7|1.飛刺|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         59  => "等級上限：Lv25|1.飛刺|2.療傷|3.無|4.攻擊型態→重拳|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→感染",
         60  => "等級上限：Lv10|1.吸血攻擊|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         61  => "等級上限：Lv10|1.吸魔攻擊|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         62  => "等級上限：Lv10|1.群療術|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         63  => "等級上限：Lv10|1.毒攻擊|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         64  => "等級上限：Lv25|1.吸血攻擊|2.無|3.無|4.攻擊型態→吸魔攻擊|5.防禦型態→群療術|6.魔法型態→無|7.敏捷型態→毒攻擊",
         65  => "等級上限：Lv10|1.只會防禦|2.群療術|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         66  => "等級上限：Lv10|1.無|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         67  => "等級上限：Lv3|",
         #68史萊姆
         68  => "等級上限：Lv10|1.無|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         69  => "等級上限：Lv20|1.怒意|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無|",
         70  => "等級上限：Lv20|1.集中|2.風元素|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         71  => "等級上限：Lv30|1.集中|2.風元素|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→遲緩",
         72  => "等級上限：Lv40|1.集中|2.風元素|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→火元素|7.敏捷型態→遲緩",
         73  => "等級上限：Lv20|1.啃咬|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         74  => "等級上限：Lv20|1.混淆|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         75  => "等級上限：Lv10|1.冰凍|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         76  => "等級上限：Lv10|1.燃燒|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         77  => "等級上限：Lv10|1.流失|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         78  => "等級上限：Lv20|1.電元素|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→大家加油",
         79  => "等級上限：Lv30|1.冰凍|2.燃燒|3.流失|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→電元素|7.敏捷型態→大家加油",
         80  => "等級上限：Lv20|1.硬化|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
         81  => "等級上限：Lv30|1.硬化|2.無|3.無|4.攻擊型態→無|5.防禦型態→無|6.魔法型態→無|7.敏捷型態→無",
       1200 => "Hello, world.|It's nice to meet you.",
       1201 => "Good bye, world.|It was nice meeting you.",
    }
        
  end
end

#===============================================================================
#===============================================================================

module YE
  module REGEXP
    module BASEITEM
      
      SCAN_WHOLE = /<(?:SCAN_WHOLE|scan whole)>/i
      SCAN_HP_MP = /<(?:SCAN_HP_MP|scan hp mp)>/i
      SCAN_STATS = /<(?:SCAN_STATS|scan stats)>/i
      SCAN_SKILL = /<(?:SCAN_SKILLS|scan skills)>/i
      SCAN_ELEM  = /<(?:SCAN_ELEMENTS|scan elements)>/i
      SCAN_STATE = /<(?:SCAN_STATUS_EFFECTS|scan status effects|scan states)>/i
      SCAN_SPOIL = /<(?:SCAN_SPOILS|scan spoils)>/i
      SCAN_DROPS = /<(?:SCAN_DROPS|scan drops)>/i
      SCAN_STEAL = /<(?:SCAN_STEAL|scan steal)>/i
      SCAN_DESC  = /<(?:SCAN_DESCRIPTION|scan description)>/i
      
    end
    module ENEMY
      
      BOSS_TYPE  = /<(?:BOSS_TYPE|boss type)[ ]*(\d+(?:\s*,\s*\d+)*)>/i
      
      HIDE_WHOLE = /<(?:HIDE_WHOLE|hide whole)>/i
      HIDE_HP_MP = /<(?:HIDE_HP_MP|hide hp mp)>/i
      HIDE_STATS = /<(?:HIDE_STATS|hide stats)>/i
      HIDE_SKILL = /<(?:HIDE_SKILLS|hide skills)>/i
      HIDE_ELEM  = /<(?:HIDE_ELEMENTS|hide elements)>/i
      HIDE_STATE = /<(?:HIDE_STATUS_EFFECTS|hide status effects|hide states)>/i
      HIDE_SPOIL = /<(?:HIDE_SPOILS|hide spoils)>/i
      HIDE_DROPS = /<(?:HIDE_DROPS|hide drops)>/i
      HIDE_STEAL = /<(?:HIDE_STEAL|hide steal)>/i
      
    end
  end
  
  module_function
  #--------------------------------------------------------------------------
  # 將陣列範圍展開為整數
  #--------------------------------------------------------------------------
  def convert_integer_array(array)
    result = []
    for i in array
      case i
      when Range; result += i.to_a
      when Integer; result.push(i)
      end
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # 轉換後常數
  #--------------------------------------------------------------------------
  ENEMY_LIST = convert_integer_array(MENU::MONSTER::BESTIARY_ORDER)
  HIDDEN_ENEMY = convert_integer_array(MENU::MONSTER::HIDDEN_MONSTERS)
  
end

#===============================================================================
# RPG::Enemy 敵人資料
#===============================================================================

class RPG::Enemy
  
  #--------------------------------------------------------------------------
  # Yanfly 掃描資料快取
  #--------------------------------------------------------------------------
  def yanfly_cache_enemy_dse
    @hide_whole = false; @hide_hp_mp = false; @hide_stats = false
    @hide_elem = false; @hide_state = false; @hide_desc = false
    @hide_skill = false; @hide_spoil = false; @hide_drops = false
    @hide_steal = false
    @boss_type = []
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YE::REGEXP::ENEMY::BOSS_TYPE
        $1.scan(/\d+/).each { |num| 
        if num.to_i >= 0
          @boss_type.push(num.to_i)
        end }
        
      when YE::REGEXP::ENEMY::HIDE_WHOLE
        @hide_whole = true
      when YE::REGEXP::ENEMY::HIDE_HP_MP
        @hide_hp_mp = true
      when YE::REGEXP::ENEMY::HIDE_STATS
        @hide_stats = true
      when YE::REGEXP::ENEMY::HIDE_SKILL
        @hide_skill = true
      when YE::REGEXP::ENEMY::HIDE_ELEM
        @hide_elem = true
      when YE::REGEXP::ENEMY::HIDE_STATE
        @hide_state = true
      when YE::REGEXP::ENEMY::HIDE_SPOIL
        @hide_spoil = true
      when YE::REGEXP::ENEMY::HIDE_DROPS
        @hide_drops = true
      when YE::REGEXP::ENEMY::HIDE_STEAL
        @hide_steal = true
      
      end
    }
    @boss_type = [0] if @boss_type == []
  end
  
  #--------------------------------------------------------------------------
  # Boss 類型
  #--------------------------------------------------------------------------
  def boss_type
    yanfly_cache_enemy_dse if @boss_type == nil
    return @boss_type
  end
  
  #--------------------------------------------------------------------------
  # 隱藏掃描資料
  #--------------------------------------------------------------------------
  def hide_whole
    yanfly_cache_enemy_dse if @hide_whole == nil
    return @hide_whole
  end
  def hide_hp_mp
    yanfly_cache_enemy_dse if @hide_hp_mp == nil
    return @hide_hp_mp
  end
  def hide_stats
    yanfly_cache_enemy_dse if @hide_stats == nil
    return @hide_stats
  end
  def hide_skill
    yanfly_cache_enemy_dse if @hide_skill == nil
    return @hide_skill
  end
  def hide_elem
    yanfly_cache_enemy_dse if @hide_elem == nil
    return @hide_elem
  end
  def hide_state
    yanfly_cache_enemy_dse if @hide_state == nil
    return @hide_state
  end
  def hide_spoil
    yanfly_cache_enemy_dse if @hide_spoil == nil
    return @hide_spoil
  end
  def hide_drops
    yanfly_cache_enemy_dse if @hide_drops == nil
    return @hide_drops
  end
  def hide_steal
    yanfly_cache_enemy_dse if @hide_steal == nil
    return @hide_steal
  end
  
end # RPG::Enemy 敵人資料

#===============================================================================
# RPG::BaseItem 基礎資料
#===============================================================================
class RPG::BaseItem
  
  #--------------------------------------------------------------------------
  # Yanfly 掃描資料快取
  #--------------------------------------------------------------------------
  def yanfly_cache_baseitem_dse
    @scan_whole = false; @scan_hp_mp = false; @scan_stats = false
    @scan_elem = false; @scan_state = false; @scan_desc = false
    @scan_skill = false; @scan_spoil = false; @scan_drops = false
    @scan_steal = false
    
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when YE::REGEXP::BASEITEM::SCAN_WHOLE
        @scan_whole = true
      when YE::REGEXP::BASEITEM::SCAN_HP_MP
        @scan_hp_mp = true
      when YE::REGEXP::BASEITEM::SCAN_STATS
        @scan_stats = true
      when YE::REGEXP::BASEITEM::SCAN_SKILL
        @scan_skill = true
      when YE::REGEXP::BASEITEM::SCAN_ELEM
        @scan_elem = true
      when YE::REGEXP::BASEITEM::SCAN_STATE
        @scan_state = true
      when YE::REGEXP::BASEITEM::SCAN_SPOIL
        @scan_spoil = true
      when YE::REGEXP::BASEITEM::SCAN_DROPS
        @scan_drops = true
      when YE::REGEXP::BASEITEM::SCAN_STEAL
        @scan_steal = true
      when YE::REGEXP::BASEITEM::SCAN_DESC
        @scan_desc = true
      
      end
    }
  end
  
  #--------------------------------------------------------------------------
  # 技能掃描設定
  #--------------------------------------------------------------------------
  def scan_whole
    yanfly_cache_baseitem_dse if @scan_whole == nil
    return @scan_whole
  end
  def scan_hp_mp
    yanfly_cache_baseitem_dse if @scan_hp_mp == nil
    return @scan_hp_mp
  end
  def scan_stats
    yanfly_cache_baseitem_dse if @scan_stats == nil
    return @scan_stats
  end
  def scan_skill
    yanfly_cache_enemy_dse if @scan_skill == nil
    return @scan_skill
  end
  def scan_elem
    yanfly_cache_baseitem_dse if @scan_elem == nil
    return @scan_elem
  end
  def scan_state
    yanfly_cache_baseitem_dse if @scan_state == nil
    return @scan_state
  end
  def scan_spoil
    yanfly_cache_baseitem_dse if @scan_spoil == nil
    return @scan_spoil
  end
  def scan_drops
    yanfly_cache_baseitem_dse if @scan_drops == nil
    return @scan_drops
  end
  def scan_steal
    yanfly_cache_baseitem_dse if @scan_steal == nil
    return @scan_steal
  end
  def scan_desc
    yanfly_cache_baseitem_dse if @scan_desc == nil
    return @scan_desc
  end
  
end # RPG::BaseItem 基礎資料

#===============================================================================
# Game_Battler 戰鬥者
#===============================================================================

class Game_Battler

  #--------------------------------------------------------------------------
  # alias：skill_effect
  #--------------------------------------------------------------------------
  alias skill_effect_dse skill_effect unless $@
  def skill_effect(user, skill)
    skill_effect_dse(user, skill)
    if user.actor? and !self.actor?
      if skill.scan_hp_mp or skill.scan_whole
        $game_party.scan_hp_mp.push(enemy.id) unless $game_party.scan_hp_mp.include?(enemy.id)
      end
      if skill.scan_stats or skill.scan_whole
        $game_party.scan_stats.push(enemy.id) unless $game_party.scan_stats.include?(enemy.id)
      end
      if skill.scan_skill or skill.scan_whole
        $game_party.scan_skill.push(enemy.id) unless $game_party.scan_skill.include?(enemy.id)
      end
      if skill.scan_state or skill.scan_whole
        $game_party.scan_state.push(enemy.id) unless $game_party.scan_state.include?(enemy.id)
      end
      if skill.scan_elem or skill.scan_whole
        $game_party.scan_elem.push(enemy.id) unless $game_party.scan_elem.include?(enemy.id)
      end
      if skill.scan_spoil or skill.scan_whole
        $game_party.scan_spoil.push(enemy.id) unless $game_party.scan_spoil.include?(enemy.id)
      end
      if skill.scan_drops or skill.scan_whole
        $game_party.scan_drops.push(enemy.id) unless $game_party.scan_drops.include?(enemy.id)
      end
      if skill.scan_steal or skill.scan_whole
        $game_party.scan_steal.push(enemy.id) unless $game_party.scan_steal.include?(enemy.id)
      end
      if skill.scan_desc or skill.scan_whole
        $game_party.scan_desc.push(enemy.id) unless $game_party.scan_desc.include?(enemy.id)
      end
    end
  end
  
end

#===============================================================================
# Game_Party 隊伍
#===============================================================================

class Game_Party < Game_Unit
  
  #--------------------------------------------------------------------------
  # 公開實例變數
  #--------------------------------------------------------------------------
  attr_writer :monsters_encounter
  attr_writer :monsters_defeated
  attr_writer :monsters_escaped
  
  attr_writer :scan_hp_mp
  attr_writer :scan_stats
  attr_writer :scan_skill
  attr_writer :scan_state
  attr_writer :scan_elem
  attr_writer :scan_spoil
  attr_writer :scan_drops
  attr_writer :scan_steal
  attr_writer :scan_desc
  
  #--------------------------------------------------------------------------
  # 定義
  #--------------------------------------------------------------------------
  def monsters_encounter
    @monsters_encounter = {} if @monsters_encounter == nil
    return @monsters_encounter
  end
  def monsters_defeated
    @monsters_defeated = {} if @monsters_defeated == nil
    return @monsters_defeated
  end
  def monsters_escaped
    @monsters_escaped = {} if @monsters_escaped == nil
    return @monsters_escaped
  end
  
  #--------------------------------------------------------------------------
  # 定義
  #--------------------------------------------------------------------------
  def scan_hp_mp
    @scan_hp_mp = [] if @scan_hp_mp == nil
    return @scan_hp_mp
  end
  def scan_stats
    @scan_stats = [] if @scan_stats == nil
    return @scan_stats
  end
  def scan_skill
    @scan_skill = [] if @scan_skill == nil
    return @scan_skill
  end
  def scan_state
    @scan_state = [] if @scan_state == nil
    return @scan_state
  end
  def scan_elem
    @scan_elem = [] if @scan_elem == nil
    return @scan_elem
  end
  def scan_spoil
    @scan_spoil = [] if @scan_spoil == nil
    return @scan_spoil
  end
  def scan_drops
    @scan_drops = [] if @scan_drops == nil
    return @scan_drops
  end
  def scan_steal
    @scan_steal = [] if @scan_steal == nil
    return @scan_steal
  end
  def scan_desc
    @scan_desc = [] if @scan_desc == nil
    return @scan_desc
  end
  
end

#===============================================================================
# Game_Enemy 敵人實例
#===============================================================================

class Game_Enemy < Game_Battler
  
  #--------------------------------------------------------------------------
  # alias：initialize
  #--------------------------------------------------------------------------
  alias initialize_dse initialize unless $@
  def initialize(index, enemy_id)
    initialize_dse(index, enemy_id)
    $game_party.monsters_encounter = {} if $game_party.monsters_encounter == nil
    if $game_party.monsters_encounter[enemy_id] == nil
      $game_party.monsters_encounter[enemy_id] = 0
    end
    $game_party.monsters_encounter[enemy_id] += 1 unless $scene.is_a?(Scene_Bestiary)
  end
  
  #--------------------------------------------------------------------------
  # alias：transform
  #--------------------------------------------------------------------------
  alias transform_dse transform unless $@
  def transform(enemy_id)
    transform_dse(enemy_id)
    $game_party.monsters_encounter = {} if $game_party.monsters_encounter == nil
    if $game_party.monsters_encounter[enemy_id] == nil
      $game_party.monsters_encounter[enemy_id] = 0
    end
    $game_party.monsters_encounter[enemy_id] += 1
  end
  
  #--------------------------------------------------------------------------
  # alias：collapse
  #--------------------------------------------------------------------------
  alias perform_collapse_dse perform_collapse unless $@
  def perform_collapse
    perform_collapse_dse
    if $game_temp.in_battle and dead?
      if YE::MENU::MONSTER::DEATH_SPOILS
        $game_party.scan_spoil.push(enemy.id) unless $game_party.scan_spoil.include?(enemy.id)
      end
      if YE::MENU::MONSTER::DEATH_DROPS
        $game_party.scan_drops.push(enemy.id) unless $game_party.scan_drops.include?(enemy.id)
      end
      $game_party.monsters_defeated  = {} if $game_party.monsters_defeated == nil
      if $game_party.monsters_defeated[enemy_id] == nil
        $game_party.monsters_defeated[enemy_id] = 0
      end
      $game_party.monsters_defeated[enemy.id] += 1
    end
    
  end
  
  #--------------------------------------------------------------------------
  # alias：escape
  #--------------------------------------------------------------------------
  alias escape_dse escape unless $@
  def escape
    $game_party.monsters_escaped   = {} if $game_party.monsters_escaped == nil
    if $game_party.monsters_escaped[enemy_id] == nil
      $game_party.monsters_escaped[enemy_id] = 0
    end
    $game_party.monsters_escaped[enemy.id] += 1
    escape_dse
  end
  
  #--------------------------------------------------------------------------
  # 遭遇紀錄
  #--------------------------------------------------------------------------
  def encounters_dse
    if $game_party.monsters_encounter[enemy.id] == nil
      $game_party.monsters_encounter[enemy.id] = 0
    end
    return $game_party.monsters_encounter[enemy.id]
  end
  def defeated_dse
    if $game_party.monsters_defeated[enemy.id] == nil
      $game_party.monsters_defeated[enemy.id] = 0 
    end
    return $game_party.monsters_defeated[enemy.id]
  end
  def escaped_dse
    if $game_party.monsters_escaped[enemy.id] == nil
      $game_party.monsters_escaped[enemy.id] = 0 
    end
    return $game_party.monsters_escaped[enemy.id]
  end
  
end

#==============================================================================
# Window_Command（由 KGC 匯入）
#==============================================================================

class Window_Command < Window_Selectable
unless method_defined?(:add_command)
  #--------------------------------------------------------------------------
  # 加入指令
  #--------------------------------------------------------------------------
  def add_command(command)
    @commands << command
    @item_max = @commands.size
    item_index = @item_max - 1
    refresh_command
    draw_item(item_index)
    return item_index
  end
  #--------------------------------------------------------------------------
  # 重新整理指令
  #--------------------------------------------------------------------------
  def refresh_command
    buf = self.contents.clone
    self.height = [self.height, row_max * WLH + 32].max
    create_contents
    self.contents.blt(0, 0, buf, buf.rect)
    buf.dispose
  end
  #--------------------------------------------------------------------------
  # 插入指令
  #--------------------------------------------------------------------------
  def insert_command(index, command)
    @commands.insert(index, command)
    @item_max = @commands.size
    refresh_command
    refresh
  end
  #--------------------------------------------------------------------------
  # 移除指令
  #--------------------------------------------------------------------------
  def remove_command(command)
    @commands.delete(command)
    @item_max = @commands.size
    refresh
  end
end
end

#===============================================================================
# 選單場景
#===============================================================================

class Scene_Menu < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias：create_command_window
  #--------------------------------------------------------------------------
  alias create_command_window_dse create_command_window unless $@
  def create_command_window
    create_command_window_dse
    return if $imported["CustomMenuCommand"]
    if $game_switches[YE::MENU::MONSTER::BESTIARY_SWITCH]
      scc_text = YE::MENU::MONSTER::BESTIARY_TITLE
      @command_bestiary = @command_window.add_command(scc_text)
      if @command_window.oy > 0
        @command_window.oy -= Window_Base::WLH
      end
    end
    @command_window.index = @menu_index
  end
  
  #--------------------------------------------------------------------------
  # alias：update_command_selection
  #--------------------------------------------------------------------------
  alias update_command_selection_dse update_command_selection unless $@
  def update_command_selection
    call_yerd_command = 0
    if Input.trigger?(Input::C)
      case @command_window.index
      when @command_bestiary
        Sound.play_decision
        $scene = Scene_Bestiary.new(@command_window.index)
      end
    end
    update_command_selection_dse
  end
  
end # 選單場景

#===============================================================================
# 標題場景
#===============================================================================

class Scene_Title < Scene_Base
  
  #--------------------------------------------------------------------------
  # alias：create_game_objects
  #--------------------------------------------------------------------------
  alias create_game_objects_dse create_game_objects unless $@
  def create_game_objects
    create_game_objects_dse
    $game_switches[YE::MENU::MONSTER::BESTIARY_SWITCH] = true
  end
  
end

#===============================================================================
# 戰鬥場景
#===============================================================================

class Scene_Battle
  
  #--------------------------------------------------------------------------
  # alias：create_info_viewport
  #--------------------------------------------------------------------------
  alias create_info_viewport_dse create_info_viewport unless $@
  def create_info_viewport
    create_info_viewport_dse
    #---
    @enemy_name_window = Window_Enemy_Name.new(0, 0, 272, 56)
    @enemy_name_window.visible = false
    @enemy_name_window.active = false
    #---
    @enemy_image_window = Window_Enemy_Image.new(0, 56, 272, 232)
    @enemy_image_window.visible = false
    @enemy_image_window.active = false
    #---
    @enemy_scan_window = Window_Enemy_Scan.new(272, 0, 272, 288, true)
    @enemy_scan_window.visible = false
    @enemy_scan_window.active = false
    #---
    hix = YE::MENU::MONSTER::HELP_WINDOW_X
    hiy = YE::MENU::MONSTER::HELP_WINDOW_Y
    hiw = YE::MENU::MONSTER::HELP_WINDOW_W
    text = YE::MENU::MONSTER::HELP_WINDOW_TX
    @scan_info_window = Window_Base.new(hix, hiy, hiw, 56)
    @scan_info_window.back_opacity = YE::MENU::MONSTER::HELP_WINDOW_O
    @scan_info_window.contents.draw_text(2, 0, hiw - 32, 24, text, 1)
    @scan_info_window.visible = false
    @scan_info_window.z = 200
  end
  
  #--------------------------------------------------------------------------
  # alias：terminate
  #--------------------------------------------------------------------------
  alias terminate_dse terminate unless $@
  def terminate
    @enemy_scan_window.dispose if @enemy_scan_window != nil
    @enemy_image_window.dispose if @enemy_image_window != nil
    @enemy_name_window.dispose if @enemy_name_window != nil
    @scan_info_window.dispose if @scan_info_window != nil
    terminate_dse
  end
  
  #--------------------------------------------------------------------------
  # alias：update_target_enemy_selection
  #--------------------------------------------------------------------------
  alias update_target_enemy_selection_dse update_target_enemy_selection unless $@
  def update_target_enemy_selection
    if YE::MENU::MONSTER::HELP_WINDOW_ON
      if @enemy_scan_window.active
        @scan_info_window.visible = false
      elsif @target_enemy_window.active
        @scan_info_window.visible = true 
      else
        @scan_info_window.visible = false
      end
    else
      @scan_info_window.visible = false
    end
    #------------------------------------------
    #------------------------------------------
    if @enemy_scan_window != nil and @enemy_scan_window.active
      @enemy_scan_window.update
      @enemy_image_window.update
      @enemy_name_window.update
      if Input.trigger?(Input::B)
        Sound.play_cancel
        @enemy_scan_window.disappear
        @enemy_image_window.disappear
        @enemy_name_window.visible = false
        @target_enemy_window.active = true
      elsif Input.trigger?(Input::LEFT) or Input.trigger?(Input::UP)
        @enemy_scan_window.previous_page
      elsif Input.trigger?(Input::RIGHT) or Input.trigger?(Input::DOWN)
        @enemy_scan_window.next_page
      elsif Input.trigger?(Input::L)
        @enemy_scan_window.top_page
      elsif Input.trigger?(Input::R)
        @enemy_scan_window.bottom_page
      end
    #------------------------------------------
    #------------------------------------------
    else
      if Input.trigger?(Input::B)
        @scan_info_window.visible = false
      elsif Input.trigger?(Input::C)
        @scan_info_window.visible = false
      elsif Input.trigger?(YE::MENU::MONSTER::ENEMY_SCAN_BUTTON)
        Sound.play_decision
        enemy = @target_enemy_window.enemy
        @enemy_scan_window.appear(enemy, @target_enemy_window)
        @enemy_image_window.appear(enemy, @target_enemy_window)
        @enemy_name_window.appear(enemy, @target_enemy_window)
        @target_enemy_window.active = false
      end
      update_target_enemy_selection_dse
      #---------
    end
  end
  
  #--------------------------------------------------------------------------
  # 更新敵人名稱視窗
  #--------------------------------------------------------------------------
  def update_enemy_name_window(enemy, window)
    @enemy_name_window.visible = true
    @enemy_name_window.contents.clear
    name = window.enemy.name
    @enemy_name_window.contents.draw_text(0, 0, 240, 32, name, 1)
    @enemy_name_window.update
  end
  
end

#===============================================================================
# 圖鑑場景
#===============================================================================

class Scene_Bestiary < Scene_Base
  
  #--------------------------------------------------------------------------
  # 初始化
  #--------------------------------------------------------------------------
  def initialize(menu_index = nil)
    @menu_index = menu_index
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @boss_type = 0
    @enemy_list_window = Window_Enemy_List.new(@boss_type)
    @enemy_list_window.x = 140
    @enemy_type_window = Window_Base.new(0, 0, 272, 56)
    @enemy_type_window.windowskin = Cache.system("WindowA")
    @enemy_type_window.x = 140
    refresh_type_window
    #text = YE::MENU::MONSTER::CATEGORIZE_TEXT
    @boss_help_window = Window_Base.new(136, 56, 272, 304)
    text = YE::MENU::MONSTER::CATEGORIZE_HELP
    @boss_help_window.back_opacity = 255
    @boss_help_window.contents.draw_text(0, 0, 240, 24, text, 1)
    @boss_help_window.visible = false
    @boss_type_window = Window_Boss_Types.new
    #---
    @enemy_name_window = Window_Enemy_Name.new(0, 0, 272, 56)
    @enemy_name_window.visible = false
    @enemy_name_window.active = false
    #---
    @enemy_image_window = Window_Enemy_Image.new(0, 56, 272, 360)
    @enemy_image_window.visible = false
    @enemy_image_window.active = false
    #---
    @enemy_scan_window = Window_Enemy_Scan.new(272, 0, 272, 416, true)
    @enemy_scan_window.visible = false
    @enemy_scan_window.active = false
    #---
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @boss_type_window.dispose if @boss_type_window != nil
    @boss_help_window.dispose if @boss_help_window != nil
    @enemy_name_window.dispose if @enemy_name_window != nil
    @enemy_image_window.dispose if @enemy_image_window != nil
    @enemy_scan_window.dispose if @enemy_scan_window != nil
    @enemy_list_window.dispose if @enemy_list_window != nil
    @enemy_type_window.dispose if @enemy_type_window != nil
  end
  
  #--------------------------------------------------------------------------
  # 返回上一場景
  #--------------------------------------------------------------------------
  def return_scene
    if @menu_index == nil
      $scene = Scene_Map.new
    else
      $scene = Scene_Menu.new(@menu_index)
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    if @boss_type_window.active
      update_type_window
    elsif @enemy_scan_window.active
      update_scan_window
    elsif @enemy_list_window.active
      update_enemy_list
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_type_window
    @boss_type_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @boss_type_window.visible = false
      @boss_help_window.visible = false
      @boss_type_window.active = false
      @enemy_list_window.active = true
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      last_boss_type = @boss_type
      @boss_type = @boss_type_window.type
      @enemy_list_window.refresh(@boss_type)
      @enemy_list_window.index = 0 unless last_boss_type == @boss_type
      refresh_type_window
      @boss_type_window.visible = false
      @boss_help_window.visible = false
      @boss_type_window.active = false
      @enemy_list_window.active = true
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_scan_window
    @enemy_scan_window.update
    @enemy_image_window.update
    @enemy_name_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @enemy_scan_window.disappear
      @enemy_image_window.disappear
      @enemy_name_window.visible = false
      @enemy_list_window.active = true
      @enemy = nil
    elsif Input.trigger?(Input::LEFT) or Input.trigger?(Input::UP)
      @enemy_scan_window.previous_page
    elsif Input.trigger?(Input::RIGHT) or Input.trigger?(Input::DOWN)
      @enemy_scan_window.next_page
    elsif Input.trigger?(Input::L)
      @enemy_scan_window.top_page
    elsif Input.trigger?(Input::R)
      @enemy_scan_window.bottom_page
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_enemy_list
    @enemy_list_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::C)
      if @enemy_list_window.enemy == nil
        Sound.play_buzzer
      elsif !viewable?(@enemy_list_window.enemy)
        Sound.play_buzzer
      else
        Sound.play_decision
        @enemy = Game_Enemy.new(0, @enemy_list_window.enemy.id)
        @enemy_scan_window.appear(@enemy)
        @enemy_image_window.appear(@enemy)
        @enemy_name_window.appear(@enemy)
        @enemy_list_window.active = false
      end
    #elsif Input.trigger?(YE::MENU::MONSTER::CATEGORIZE_BUTTON)
    #  播放確認音效
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def viewable?(enemy)
    $game_party.monsters_encounter[enemy.id] = 0 if
      $game_party.monsters_encounter[enemy.id] == nil
    return false if $game_party.monsters_encounter[enemy.id] <= 0
    return true
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh_type_window
    @enemy_type_window.contents.clear
    array = YE::MENU::MONSTER::BOSS_TYPES[@boss_type]
    icon = array[0]
    text = sprintf(YE::MENU::MONSTER::BESTIARY_LIST, array[7])
    @enemy_type_window.draw_icon(icon, 0, 0)
    @enemy_type_window.contents.draw_text(24, 0, 216, 24, text, 0)
  end
  
end

#==============================================================================
# Window_Enemy_List
#==============================================================================

class Window_Enemy_List < Window_Selectable
  
  #--------------------------------------------------------------------------
  # 初始化
  #--------------------------------------------------------------------------
  def initialize(boss_type)
    super(0, 56, 272, 360)
    self.index = 0
    self.windowskin = Cache.system("WindowA")###
    refresh(boss_type)
  end
  
  #--------------------------------------------------------------------------
  # 重新整理
  #--------------------------------------------------------------------------
  def refresh(boss_type)
    @boss_type = boss_type
    @data = []
    for enemy in monster_list
      @data.push(enemy)
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  #--------------------------------------------------------------------------
  # 繪製項目
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    enemy = @data[index]
    $game_party.monsters_encounter[enemy.id] = 0 if 
      $game_party.monsters_encounter[enemy.id] == nil
    if $game_party.monsters_encounter[enemy.id] > 0
      text = enemy.name.gsub(/\[.*\]/) { "" }
      self.contents.font.color.alpha = 255
    else
      mask = YE::MENU::MONSTER::BESTIARY_MASK
      if mask.scan(/./).size == 1
        mask = mask * enemy.name.scan(/./).size
      end
      text = mask
      self.contents.font.color.alpha = 128
    end
    self.contents.draw_text(rect.x+4, rect.y, rect.width-4, WLH, text)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def include?(enemy)
    return false if enemy == nil
    return false unless enemy.boss_type.include?(@boss_type)
    return false if YE::HIDDEN_ENEMY.include?(enemy.id)
    return false if $imported["SwapDummyMonster"] and
      YE::SWAP::DUMMY_MONSTER.include?(enemy.id)
    return true
  end
  
  #--------------------------------------------------------------------------
  # 怪物清單
  #--------------------------------------------------------------------------
  def monster_list
    result = []
    for enemy_id in YE::ENEMY_LIST
      result.push($data_enemies[enemy_id]) if include?($data_enemies[enemy_id])
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # 回傳敵人
  #--------------------------------------------------------------------------
  def enemy
    return @data[self.index]
  end
  
end

#==============================================================================
# Window_Type_Data
#==============================================================================

class Window_Type_Data < Window_Base
  
  #--------------------------------------------------------------------------
  # 初始化
  #--------------------------------------------------------------------------
  def initialize(boss_type)
    super(272, 56, 272, 360)
    self.windowskin = Cache.system("WindowA")
    refresh(boss_type)
  end
  
  #--------------------------------------------------------------------------
  # 重新整理
  #--------------------------------------------------------------------------
  def refresh(boss_type = 0)
    self.contents.clear
    self.contents.font.size = Font.default_size
    @boss_type = boss_type
    sw = self.width - 32
    @category_colour = YE::MENU::MONSTER::DATA_CATEGORY_COLOUR
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::BESTIARY_INFO
    self.contents.draw_text(0, 0, sw, WLH, text, 1)
    
    unique_discovered = 0#可發現
    unique_type_enc = 0  #召喚總數
    unique_encounters = 0#已發現
    unique_defeated = 0
    unique_escaped = 0
    total_encountered = 0#已遭遇
    total_defeated = 0
    total_escaped = 0
    type_encountered = 0
    type_defeated = 0
    type_escaped = 0
    
    for key in $game_party.monsters_encounter
      next if key[1] == nil or key[1] <= 0
      unique_encounters += 1
      total_encountered += key[1]
      if $data_enemies[key[0]].boss_type.include?(@boss_type)
        unique_discovered += 1
        unique_type_enc += key[1]##已召喚次數(正確)
      end
    end
    for key in $game_party.monsters_defeated
      next if key[1] == nil or key[1] <= 0
      total_defeated += key[1]
      if $data_enemies[key[0]].boss_type.include?(@boss_type)
        unique_defeated += key[1]
      end
    end
    for key in $game_party.monsters_escaped
      next if key[1] == nil or key[1] <= 0
      total_escaped += key[1]
      if $data_enemies[key[0]].boss_type.include?(@boss_type)
        unique_escaped += key[1]
      end
    end
    total_size = YE::ENEMY_LIST.size - YE::HIDDEN_ENEMY.size
    
    self.contents.font.size = YE::MENU::MONSTER::MENU_FONT_SIZE
    #---
    dy = WLH + WLH / 2
    boss_type_name = YE::MENU::MONSTER::BOSS_TYPES[@boss_type][8]
    icon = YE::MENU::MONSTER::BOSS_TYPES[@boss_type][0]
    #---
    self.contents.font.color = text_color(@category_colour)
    draw_icon(YE::MENU::MONSTER::ICON_COMPLETION, 0, dy)
    text = YE::MENU::MONSTER::TEXT_COMPLETION
    self.contents.draw_text(24, dy, sw-24, WLH, text, 0)
    self.contents.font.color = normal_color
    text = sprintf(YE::MENU::MONSTER::RATE_COMPLETION, bestiary_completion)
    self.contents.draw_text(24, dy, sw-24, WLH, text, 2)
    #---
    dy += WLH + WLH / 2
    self.contents.font.color = text_color(@category_colour)
    draw_icon(YE::MENU::MONSTER::ICON_DISCOVERED, 0, dy)
    text = YE::MENU::MONSTER::TEXT_DISCOVERED#已發現
    self.contents.draw_text(24, dy, sw-24, WLH, text, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(24, dy, sw-24, WLH, unique_encounters, 2)
    #---
    dy += WLH
    self.contents.font.color = text_color(@category_colour)
    draw_icon(icon, 12, dy)#可發現
    text = sprintf(YE::MENU::MONSTER::TEXT_TYPE_DIS, boss_type_name)
    self.contents.draw_text(36, dy, sw-36, WLH, text, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(36, dy, sw-36, WLH, unique_discovered, 2)
    #---
    dy += WLH
    self.contents.font.color = text_color(@category_colour)
    draw_icon(YE::MENU::MONSTER::ICON_ENCOUNTER, 0, dy)
    text = YE::MENU::MONSTER::TEXT_ENCOUNTERS#已遭遇
    self.contents.draw_text(24, dy, sw-24, WLH, text, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(24, dy, sw-24, WLH, total_encountered, 2)
    #---
    dy += WLH
    self.contents.font.color = text_color(@category_colour)
    draw_icon(icon, 12, dy)
    text = sprintf(YE::MENU::MONSTER::TEXT_TYPE_ENC, boss_type_name)
    self.contents.draw_text(36, dy, sw-36, WLH, text, 0)
    self.contents.font.color = normal_color#可召喚總數(正確)
    self.contents.draw_text(36, dy, sw-36, WLH, unique_type_enc, 2)
    #---
    dy += WLH
    self.contents.font.color = text_color(@category_colour)
    draw_icon(YE::MENU::MONSTER::ICON_KILLED, 0, dy)
    text = YE::MENU::MONSTER::TEXT_DEFEATED
    self.contents.draw_text(24, dy, sw-24, WLH, text, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(24, dy, sw-24, WLH, total_defeated, 2)
    #---
    dy += WLH
    self.contents.font.color = text_color(@category_colour)
    draw_icon(icon, 12, dy)
    text = sprintf(YE::MENU::MONSTER::TEXT_TYPE_DEF, boss_type_name)
    self.contents.draw_text(36, dy, sw-36, WLH, text, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(36, dy, sw-36, WLH, unique_defeated, 2)
    #---
    dy += WLH
    self.contents.font.color = text_color(@category_colour)
    draw_icon(YE::MENU::MONSTER::ICON_ESCAPED, 0, dy)
    text = YE::MENU::MONSTER::TEXT_ESCAPED
    self.contents.draw_text(24, dy, sw-24, WLH, text, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(24, dy, sw-24, WLH, total_escaped, 2)
    #---
    dy += WLH
    self.contents.font.color = text_color(@category_colour)
    draw_icon(icon, 12, dy)
    text = sprintf(YE::MENU::MONSTER::TEXT_TYPE_ESC, boss_type_name)
    self.contents.draw_text(36, dy, sw-36, WLH, text, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(36, dy, sw-36, WLH, unique_escaped, 2)
  end
  
  #--------------------------------------------------------------------------
  # 圖鑑完成度
  #--------------------------------------------------------------------------
  def bestiary_completion
    total = 0; result = 0
    for enemy in $data_enemies
      next if $imported["SwapDummyMonster"] and 
        YE::SWAP::DUMMY_MONSTER.include?(enemy.id)
      next if YE::HIDDEN_ENEMY.include?(enemy.id)
      next if enemy == nil
      total += 1
      if $game_party.monsters_encounter.include?(enemy.id) and 
        $game_party.monsters_encounter[enemy.id] > 0
        result += 1 
      end
      next unless YE::MENU::MONSTER::REQUIRE_SCAN
      next if enemy.hide_whole
      total += 1 if YE::MENU::MONSTER::SHOW_GENERAL and !enemy.hide_hp_mp
      total += 1 if YE::MENU::MONSTER::SHOW_GENERAL and !enemy.hide_stats
      total += 1 if YE::MENU::MONSTER::SHOW_SKILLS and !enemy.hide_skill
      total += 1 if YE::MENU::MONSTER::SHOW_ELEMENTS and !enemy.hide_elem
      total += 1 if YE::MENU::MONSTER::SHOW_STATES and !enemy.hide_state
      total += 1 if YE::MENU::MONSTER::SHOW_SPOILS and !enemy.hide_spoil
      if YE::MENU::MONSTER::SPOIL_DROPS or (YE::MENU::MONSTER::SHOW_DROPS and
        $imported["ExtraDropItem"]) and !enemy.hide_drops
        total += 1
      end
      if $imported["Steal"] and YE::MENU::MONSTER::SHOW_STEAL and
        !enemy.hide_steal
        total += 1
      end
      if YE::MENU::MONSTER::SHOW_NOTES and YE::HASH::ENEMY_NOTES.include?(enemy.id)
        total += 1
      end
    end
    if YE::MENU::MONSTER::REQUIRE_SCAN
      result += $game_party.scan_hp_mp.size
      result += $game_party.scan_stats.size
      result += $game_party.scan_skill.size
      result += $game_party.scan_state.size
      result += $game_party.scan_spoil.size
      result += $game_party.scan_drops.size
      result += $game_party.scan_steal.size
      result += $game_party.scan_desc.size
    end
    result *= 100.0
    result /= total
    return result
  end
  
end

#==============================================================================
# Window_Boss_Types
#==============================================================================

class Window_Boss_Types < Window_Selectable
  
  #--------------------------------------------------------------------------
  # 初始化
  #--------------------------------------------------------------------------
  def initialize
    super(136, 80, 272, 280)
    self.windowskin = Cache.system("WindowA")###
    self.index = 0
    self.opacity = 0
    self.visible = false
    self.active = false
    refresh
  end
  
  #--------------------------------------------------------------------------
  # 重新整理
  #--------------------------------------------------------------------------
  def refresh
    @data = YE::MENU::MONSTER::TYPE_ORDERING
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def type
    return @data[self.index]
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    type = @data[index]
    icon = YE::MENU::MONSTER::BOSS_TYPES[type][0]
    name = YE::MENU::MONSTER::BOSS_TYPES[type][8]
    text = sprintf(YE::MENU::MONSTER::CATEGORIZE_VIEW, name)
    draw_icon(icon, rect.x+4, rect.y)
    self.contents.draw_text(rect.x+28, rect.y, rect.width-28, WLH, text)
  end
  
end

#===============================================================================
# 敵人名稱視窗
#===============================================================================

class Window_Enemy_Name < Window_Base
  
  #--------------------------------------------------------------------------
  # 初始化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.windowskin = Cache.system("WindowA")###
    self.back_opacity = 255
    @target_enemy_window = nil
    self.z = 200
    self.visible = false
  end
  
  #--------------------------------------------------------------------------
  # 顯示／隱藏
  #--------------------------------------------------------------------------
  def appear(enemy, window = nil)
    @enemy = enemy
    @target_enemy_window = window
    self.openness = 128
    @opening = true
    self.visible = true
    draw_content
  end
  
  def disappear
    self.visible = false
  end
  
  #--------------------------------------------------------------------------
  # 繪製內容
  #--------------------------------------------------------------------------
  def draw_content
    self.contents.clear
    text = sprintf(YE::MENU::MONSTER::ENEMY_NAME, @enemy.name)
    if $imported["EnemyLevelControl"]
      level = @enemy.level
      text = sprintf(YE::BATTLE::ENEMY::SCANNED_ENEMY_LEVEL, level, text)
    end
    self.contents.draw_text(0, 0, 240, 24, text, 1)
  end
  
end

#===============================================================================
# 敵人圖片視窗
#===============================================================================

class Window_Enemy_Image < Window_Base
  
  #--------------------------------------------------------------------------
  # 初始化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    self.windowskin = Cache.system("WindowA")###
    self.back_opacity = 255
    @target_enemy_window = nil
    self.z = 200
    self.visible = false
  end
  
  #--------------------------------------------------------------------------
  # 顯示／隱藏
  #--------------------------------------------------------------------------
  def appear (enemy, window = nil)
    @enemy = enemy
    @target_enemy_window = window
    self.openness = 128
    @opening = true
    self.visible = true
    draw_content
  end
  
  def disappear
    self.visible = false
  end
  
  #--------------------------------------------------------------------------
  # 繪製內容
  #--------------------------------------------------------------------------
  def draw_content
    self.contents.clear
    enemybit = Cache.battler(@enemy.battler_name, @enemy.battler_hue)
    bw = enemybit.width
    bh = enemybit.height
    if bw > (self.width - 32)
      bw = (self.width - 32)
      bh *= (self.width - 32)
      bh /= enemybit.width
    end
    if bh > (self.height - 32)
      bh = (self.height - 32)
      bw *= (self.height - 32)
      bw /= enemybit.height
    end
    rect = Rect.new(0, 0, bw, bh)
    #---------
    rect.x = (self.width - 32 - rect.width) / 2
    rect.y = (self.height - 32 - rect.height) / 2
    #---------
    self.contents.stretch_blt(rect, enemybit, enemybit.rect)
  end
  
end

#===============================================================================
# 敵人掃描視窗
#===============================================================================

class Window_Enemy_Scan < Window_Base
  
  #--------------------------------------------------------------------------
  # 初始化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, inbattle)
    super(x, y, width, height)
    self.windowskin = Cache.system("WindowA")###
    self.back_opacity = 255
    @target_enemy_window = nil
    @inbattle = inbattle
    @require = YE::MENU::MONSTER::REQUIRE_SCAN
    self.z = 200
    self.visible = false
  end
  
  #--------------------------------------------------------------------------
  # 顯示／隱藏
  #--------------------------------------------------------------------------
  def appear (enemy, window = nil)
    @enemy = enemy
    @target_enemy_window = window
    @page = 1
    @total_pages = create_total_pages
    draw_enemy_data
    self.openness = 128
    @opening = true
    self.active = true
    self.visible = true
  end
  
  def disappear
    self.active = false
    self.visible = false
  end
  
  #--------------------------------------------------------------------------
  # 切換頁面
  #--------------------------------------------------------------------------
  def next_page
    if @page != @total_pages
      @page += 1
    else
      @page = 1
    end
    turn_sound
    draw_enemy_data
  end
  
  def previous_page
    if @page != 1
      @page -= 1
    else
      @page = @total_pages
    end
    turn_sound
    draw_enemy_data
  end
  
  def top_page
    @page = 1
    turn_sound
    draw_enemy_data
  end
  
  def bottom_page
    @page = @total_pages
    turn_sound
    draw_enemy_data
  end
  
  #--------------------------------------------------------------------------
  # 播放翻頁音效
  #--------------------------------------------------------------------------
  def turn_sound
    unless YE::MENU::MONSTER::PAGE_SOUND == nil
      sound = YE::MENU::MONSTER::PAGE_SOUND
      sound.play
    end
  end
  
  #--------------------------------------------------------------------------
  # 繪製敵人資料
  #--------------------------------------------------------------------------
  def draw_enemy_data
    self.contents.clear
    self.contents.font.color.alpha = 255
    self.contents.font.size = Font.default_size
    self.contents.font.color = normal_color
    @category_colour = YE::MENU::MONSTER::DATA_CATEGORY_COLOUR
    #--------------------
    pagecase = @contents[@page - 1]
    if @page == 1 and !YE::MENU::MONSTER::REPLACE_PAGE_MSG
      text1 = ""
    else
      text1 = YE::MENU::MONSTER::DATA_LEFT
    end
    if YE::MENU::MONSTER::REPLACE_PAGE_MSG #--------------------------------------
      
      text2 = case_page_name(pagecase)
      
    else #----------------------------------------------------------------------
      text2 = sprintf(YE::MENU::MONSTER::DATA_PAGES, @page, @total_pages)
    end
    if @page == @total_pages and !YE::MENU::MONSTER::REPLACE_PAGE_MSG
      text3 = ""
    else
      text3 = YE::MENU::MONSTER::DATA_RIGHT
    end
    #--------------------
    self.contents.draw_text(2, 0, 232, WLH, text1, 0)
    self.contents.draw_text(2, 0, 232, WLH, text2, 1)
    self.contents.draw_text(2, 0, 232, WLH, text3, 2)
    #--------------------
    if @enemy != nil
      case_page_run(pagecase)
    end
  end
  
  #--------------------------------------------------------------------------
  # 建立一般資訊頁
  #--------------------------------------------------------------------------
  def make_general_page
    y = WLH
    x = 0
    sw = self.width - 32
    gc0 = gauge_back_color
    gce = text_color(YE::MENU::MONSTER::EXHAUST_COLOUR)
    gh = YE::MENU::MONSTER::GAUGE_HEIGHT
    dx = (sw - (24 * @enemy.enemy.boss_type.size)) / 2
    for boss_type in @enemy.enemy.boss_type
      array = YE::MENU::MONSTER::BOSS_TYPES[boss_type]
      icon = array[0]
      draw_icon(icon, dx, y, true)
      dx += 24
    end
    dsearray = YE::MENU::MONSTER::BOSS_TYPES[@enemy.enemy.boss_type[0]]
    y += WLH
    if @enemy.maxhp > @enemy.base_maxhp
      icon = YE::MENU::MONSTER::ICON_HIGH
    elsif @enemy.maxhp < @enemy.base_maxhp
      icon = YE::MENU::MONSTER::ICON_LOW
    else
      icon = dsearray[1]
    end
    @enemy.hp = @enemy.maxhp if @enemy.hp > @enemy.maxhp
    gc1 = text_color(dsearray[2])
    gc2 = text_color(dsearray[3])
    gy = y + WLH - 8 - (gh - 6)
    if @enemy.maxhp < @enemy.base_maxhp and @enemy.base_maxhp > 0
      gb = sw * @enemy.maxhp / @enemy.base_maxhp
      self.contents.fill_rect(x, gy, sw-130, gh, gce)###
    else
      gb = sw
    end
    self.contents.fill_rect(x, gy, gb-130, gh, gc0)###
    if @enemy.maxhp <= 0
      if @enemy.base_maxhp <= 0
        gw = sw
      else
        gw = 0
      end
    else
      gw = gb * @enemy.hp / @enemy.maxhp
      self.contents.gradient_fill_rect(x, gy, gw-130, gh, gc1, gc2)###
    end
    draw_icon(icon, x, y, true)
    text = Vocab::hp
    self.contents.font.color = text_color(@category_colour)
    self.contents.font.size = 16###
    self.contents.draw_text(24, y, sw-24, WLH, text, 0)###
    self.contents.font.color = normal_color
    hidehp = false
    if @require
      hidehp = true unless $game_party.scan_hp_mp.include?(@enemy.enemy_id)
    end
    if hidehp or @enemy.enemy.hide_hp_mp
      text = YE::MENU::MONSTER::HIDDEN_HP
    elsif YE::MENU::MONSTER::HP_DISPLAY_TYPE == 1
      text = @enemy.hp
    elsif YE::MENU::MONSTER::HP_DISPLAY_TYPE == 2
      text = sprintf("%d/%d",@enemy.hp,@enemy.maxhp)
    else
      text = sprintf("%#.05g%%",@enemy.hp * 100.000 / @enemy.maxhp)
    end
    self.contents.draw_text(0-130, y, sw, WLH, text, 2)###
    y += WLH
    if @enemy.maxmp > @enemy.base_maxmp
      icon = YE::MENU::MONSTER::ICON_HIGH
    elsif @enemy.maxmp < @enemy.base_maxmp
      icon = YE::MENU::MONSTER::ICON_LOW
    else
      icon = dsearray[4]
    end
    @enemy.mp = @enemy.maxmp if @enemy.mp > @enemy.maxmp
    gc1 = text_color(dsearray[5])
    gc2 = text_color(dsearray[6])
    gy = y + WLH - 8 - (gh - 6)
    if @enemy.maxmp < @enemy.base_maxmp and @enemy.base_maxmp > 0
      gb = sw * @enemy.maxmp / @enemy.base_maxmp
      self.contents.fill_rect(x, gy, sw-130, gh, gce)###
    else
      gb = sw
    end
    self.contents.fill_rect(x, gy, gb-130, gh, gc0)###
    if @enemy.maxmp <= 0
      if @enemy.base_maxmp <= 0
        gw = sw
      else
        gw = 0
      end
    else
      gw = gb * @enemy.mp / @enemy.maxmp
    end
    self.contents.gradient_fill_rect(x, gy, gw-130, gh, gc1, gc2)###
    draw_icon(icon, x, y, true)
    text = Vocab::mp
    self.contents.font.color = text_color(@category_colour)
    self.contents.draw_text(24, y, sw-24, WLH, text, 0)
    self.contents.font.color = normal_color
    hidemp = false
    if @require
      hidemp = true unless $game_party.scan_hp_mp.include?(@enemy.enemy_id)
    end
    if hidemp or @enemy.enemy.hide_hp_mp
      text = YE::MENU::MONSTER::HIDDEN_MP
    elsif YE::MENU::MONSTER::MP_DISPLAY_TYPE == 1
      text = @enemy.mp
    elsif YE::MENU::MONSTER::MP_DISPLAY_TYPE == 2
      text = sprintf("%d/%d",@enemy.mp,@enemy.maxmp)
    else
      if @enemy.maxmp
        text = sprintf("%#.05g%%", 100.000)
      else
        text = sprintf("%#.05g%%",@enemy.mp * 100.000 / @enemy.maxmp)
      end
    end
    self.contents.draw_text(0-130, y, sw, WLH, text, 2)###
    self.contents.font.size = YE::MENU::MONSTER::FONT_SIZE
    hide = YE::MENU::MONSTER::HIDDEN_STAT
    hidestats = false
    if @require
      hidestats = true unless $game_party.scan_stats.include?(@enemy.enemy_id)
    end
    if hidestats or @enemy.enemy.hide_stats
      textatk = hide; textdef = hide; textspi = hide; textagi = hide
      texthit = hide; texteva = hide; textcri = hide; textodds = hide
    else
      textatk = @enemy.atk; textdef = @enemy.def
      textspi = @enemy.spi; textagi = @enemy.agi
      texthit = sprintf("%d%%",@enemy.hit)
      texteva = sprintf("%d%%",@enemy.eva)
      textcri = sprintf("%d%%",@enemy.cri)
      textodds = sprintf("%d", @enemy.odds)
    end
    y += WLH + WLH / 4
    if @enemy.atk > @enemy.base_atk
      icon = YE::MENU::MONSTER::ICON_HIGH
    elsif @enemy.atk < @enemy.base_atk
      icon = YE::MENU::MONSTER::ICON_LOW
    else
      icon = YE::MENU::MONSTER::ICON_ATK
    end
    draw_icon(icon, 0, y, true)
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_ATK
    self.contents.draw_text(24, y, sw/4-24, WLH, text, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(sw/4, y, sw/4-12, WLH, textatk, 0)
    unless YE::MENU::MONSTER::HIDE_HIT
      icon = YE::MENU::MONSTER::ICON_HIT
      draw_icon(icon, sw/2, y, true)
      self.contents.font.color = text_color(@category_colour)
      text = YE::MENU::MONSTER::DATA_HIT
      self.contents.draw_text(sw/2+24, y, sw/4-24, WLH, text, 0)
      self.contents.font.color = normal_color
      self.contents.draw_text(sw*3/4, y, sw/4-12, WLH, texthit, 2)
    end
    y += WLH
    if @enemy.def > @enemy.base_def
      icon = YE::MENU::MONSTER::ICON_HIGH
    elsif @enemy.def < @enemy.base_def
      icon = YE::MENU::MONSTER::ICON_LOW
    else
      icon = YE::MENU::MONSTER::ICON_DEF
    end
    draw_icon(icon, 0, y, true)
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_DEF
    self.contents.draw_text(24, y, sw/4-24, WLH, text, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(sw/4, y, sw/4-12, WLH, textdef, 0)
    unless YE::MENU::MONSTER::HIDE_EVA
      icon = YE::MENU::MONSTER::ICON_EVA
      draw_icon(icon, sw/2, y, true)
      self.contents.font.color = text_color(@category_colour)
      text = YE::MENU::MONSTER::DATA_EVA
      self.contents.draw_text(sw/2+24, y, sw/4-24, WLH, text, 0)
      self.contents.font.color = normal_color
      self.contents.draw_text(sw*3/4, y, sw/4-12, WLH, texteva, 2)
    end
    #x += 15
    y += WLH
    if @enemy.spi > @enemy.base_spi
      icon = YE::MENU::MONSTER::ICON_HIGH
    elsif @enemy.spi < @enemy.base_spi
      icon = YE::MENU::MONSTER::ICON_LOW
    else
      icon = YE::MENU::MONSTER::ICON_SPI
    end
    draw_icon(icon, 0, y, true)
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_SPI
    self.contents.draw_text(24, y, sw/4-24, WLH, text, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(sw/4, y, sw/4-12, WLH, textspi, 0)
    unless YE::MENU::MONSTER::HIDE_CRI
      icon = YE::MENU::MONSTER::ICON_CRI
      draw_icon(icon, sw/2, y, true)
      self.contents.font.color = text_color(@category_colour)
      text = YE::MENU::MONSTER::DATA_CRI
      self.contents.draw_text(sw/2+24, y, sw/4-24, WLH, text, 0)
      self.contents.font.color = normal_color
      self.contents.draw_text(sw*3/4, y, sw/4-12, WLH, textcri, 2)
    end
    y += WLH
    if @enemy.agi > @enemy.base_agi
      icon = YE::MENU::MONSTER::ICON_HIGH
    elsif @enemy.agi < @enemy.base_agi
      icon = YE::MENU::MONSTER::ICON_LOW
    else
      icon = YE::MENU::MONSTER::ICON_AGI
    end
    draw_icon(icon, 0, y, true)
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_AGI
    self.contents.draw_text(24, y, sw/4-24, WLH, text, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(sw/4, y, sw/4-12, WLH, textagi, 0)
    unless YE::MENU::MONSTER::HIDE_ODDS
      icon = YE::MENU::MONSTER::ICON_ODDS
      draw_icon(icon, sw/2, y, true)
      self.contents.font.color = text_color(@category_colour)
      text = YE::MENU::MONSTER::DATA_ODDS
      self.contents.draw_text(sw/2+24, y, sw/4-24, WLH, text, 0)
      self.contents.font.color = normal_color
      self.contents.draw_text(sw*3/4, y, sw/4-12, WLH, textodds, 2)
    end
    #######
    make_notes_page
    make_elements_page
    ######
    y += WLH + WLH / 4
    state_draw = @enemy.states
    for state in state_draw
      state_draw.delete(state) if state.icon_index == 0
    end
    unless state_draw == []
      self.contents.font.size = Font.default_size
      self.contents.font.color = text_color(@category_colour)
      text = YE::MENU::MONSTER::DATA_STATES
      self.contents.draw_text(0, y, sw, WLH, text, 1)
      y += WLH
      draw_actor_state(@enemy, 0, y, sw + 12)
    end
  end # 建立一般資訊頁
  
  #--------------------------------------------------------------------------
  # 建立技能頁
  #--------------------------------------------------------------------------
  def make_skills_page
    x = 0
    y = WLH
    sw = self.width - 32
    action_list = []
    skilltotal = 0
    for action in @enemy.enemy.actions
      if action.kind == 1
        obj = $data_skills[action.skill_id]
        unless action_list.include?(obj)
          action_list.push(obj) 
          skilltotal += 1
        end
      end
    end
    y += WLH
    self.contents.font.color = normal_color
    for obj in action_list
      break if (y + 24) > (self.height - 32)
      draw_item_name(obj, x, y, true)
      y += WLH
    end
    y = WLH
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_SKILLS
    self.contents.draw_text(0, y, sw, WLH, text, 0)
    if skilltotal == 1
      text = sprintf(YE::MENU::MONSTER::VIEW_SKILLS1, skilltotal)
    else
      text = sprintf(YE::MENU::MONSTER::VIEW_SKILLS2, skilltotal)
    end
    self.contents.draw_text(0, y, sw, WLH, text, 2)
  end
  
  ##############################
    #--------------------------------------------------------------------------
  # ○ チャートライン描画
  #     cx, cy : 中心 X, Y
  #     r      : 半径
  #     n      : 頂点数
  #     breaks : 空間数
  #     pw     : ペン幅
  #--------------------------------------------------------------------------
  def draw_chart_line(cx, cy, r, n, breaks, pw)
    color = KGC::ExtendedStatusScene::CHART_BASE_COLOR.clone
    contents.draw_regular_polygon(cx, cy, r, n, color, pw)
    color.alpha = color.alpha * 5 / 8
    contents.draw_spoke(cx, cy, r, n, color, pw)
    (1..breaks).each { |i|
      contents.draw_regular_polygon(cx, cy, r * i / breaks, n, color, pw)
    }
  end
  #--------------------------------------------------------------------------
  # ○ チャート描画
  #     cx, cy : 中心 X, Y
  #     r      : 半径
  #     points : 頂点リスト
  #     pw     : ペン幅
  #--------------------------------------------------------------------------
  def draw_chart(cx, cy, r, points, pw)
    contents.draw_polygon(points, KGC::ExtendedStatusScene::CHART_LINE_COLOR, 2)
  end
  
   def draw_chart_flash(sprite, x, y, r, points, pw)
    points = points.clone
    points.each { |pt| pt[0] -= x }

    cx = x + r + 28
    cy = y + r + 28
    color = KGC::ExtendedStatusScene::CHART_FLASH_COLOR
    sprite.bitmap.clear
    sprite.bitmap.fill_polygon(points, Color.new(0, 0, 0, 0), color)
    sprite.ox = cx - x
    sprite.oy = cy
    sprite.x  = self.x + cx + 16
    sprite.y  = self.y + cy + 16
  end
  ##############################
  #--------------------------------------------------------------------------
  # 建立屬性頁
  #--------------------------------------------------------------------------
  def make_elements_page
    x = 40
    y = 220
       ############################
    r  = (contents.height - y - 56) / 2
    cx = x + r + 28
    cy = y + r + 28
    pw = (Bitmap.smoothing_mode == TRGSSX::SM_ANTIALIAS ? 2 : 1)
    elements = KGC::ExtendedStatusScene::CHECK_ELEMENT_LIST

    draw_chart_line(cx, cy, r, elements.size, 3, pw)

    # チャート
    points = []
    elements.each_with_index { |e, i|
      n   = @enemy.element_rate(e)
      n   = 100 - n if KGC::ExtendedStatusScene::RESIST_NUM_STYLE == 1
      n   = [[n, -100].max, 200].min
      dr  = r * (n + 100) / 100 / 3
      rad = Math::PI * (360.0 * i / elements.size - 90.0) / 180.0
      dx  = cx + Integer(dr * Math.cos(-rad))
      dy  = cy + Integer(dr * Math.sin(rad))
      points << [dx, dy]

      dx = cx + Integer((r + 14) * Math.cos(-rad)) - 12
      dy = cy + Integer((r + 14) * Math.sin(rad))  - 12
      draw_icon(KGC::ExtendedStatusScene::ELEMENT_ICON[e], dx, dy)
    }

    draw_chart(cx, cy, r, points, pw)
    #draw_chart_flash(@element_chart_sprite, x, y, r, points, pw)

    return (x + cx + r + 42)
    ############################
    #y = WLH
    sw = self.width - 32
    for key in YE::MENU::MONSTER::ELEMENT_HASH
      doublearr = key[1]
      ele_array = doublearr[0]
      ele_icon  = doublearr[1]
      self.contents.font.color = text_color(@category_colour)
      text = key[0]
      self.contents.draw_text(0-0, y, sw, WLH, text, 1)###x
      y += WLH
      x = (sw - ele_array.size * 24) / 2
      x -= 0###
      for icon in ele_icon
        draw_icon(icon, x, y, true)
        x += 24
        ###
      end
      y += WLH
      x = (sw - ele_array.size * 24) / 2
      x -= 0###
      for element in ele_array
        rank = @enemy.enemy.element_ranks[element]
        result = [0,1,2,3,4,5,6][rank]
        if result == 0
          
          draw_icon(YE::MENU::MONSTER::ICON_E_RATE_Z, x, y, true)
        elsif result == 1
          self.contents.font.size = 15
          self.contents.font.color = normal_color
          self.contents.draw_text(x, y, 32, 32, "致命", 0)
          self.contents.font.size = 16
          #draw_icon(YE::MENU::MONSTER::ICON_E_RATE_A, x, y, true)
        elsif result == 2
          self.contents.font.size = 15
          self.contents.font.color = normal_color
          self.contents.draw_text(x, y, 32, 32, "較弱", 0)
          self.contents.font.size = 16
          #draw_icon(YE::MENU::MONSTER::ICON_E_RATE_B, x, y, true)
        elsif result == 3
          self.contents.font.size = 15
          self.contents.font.color = normal_color
          self.contents.draw_text(x, y, 32, 32, "正常", 0)
          self.contents.font.size = 16
          #draw_icon(YE::MENU::MONSTER::ICON_E_RATE_C, x, y, true)
        elsif result == 4
          self.contents.font.size = 15
          self.contents.font.color = normal_color
          self.contents.draw_text(x, y, 32, 32, "較強", 0)
          self.contents.font.size = 16
          #draw_icon(YE::MENU::MONSTER::ICON_E_RATE_D, x, y, true)
        elsif result == 5
          self.contents.font.size = 15
          self.contents.font.color = normal_color
          self.contents.draw_text(x, y, 32, 32, "極強", 0)
          self.contents.font.size = 16
          #draw_icon(YE::MENU::MONSTER::ICON_E_RATE_E, x, y, true)
        elsif result == 6
          self.contents.font.size = 15
          self.contents.font.color = normal_color
          self.contents.draw_text(x, y, 32, 32, "全抗", 0)
          self.contents.font.size = 16
          #draw_icon(YE::MENU::MONSTER::ICON_E_RATE_F, x, y, true)
        else
          draw_icon(YE::MENU::MONSTER::ICON_E_RATE_U, x, y, true)
        end
        x += 24
      end
      y += WLH * 1
    end
  end # 建立屬性頁
  
  #--------------------------------------------------------------------------
  # 建立狀態頁
  #--------------------------------------------------------------------------
  def make_states_page
    x = 0
    y = WLH
    sw = self.width - 32
    for key in YE::MENU::MONSTER::STATES_HASH
      states_array = key[1]
      self.contents.font.color = text_color(@category_colour)
      text = key[0]
      self.contents.draw_text(0, y, sw, WLH, text, 1)
      y += WLH
      x = (sw - states_array.size * 24) / 2
      for state_id in states_array
        icon = $data_states[state_id].icon_index
        draw_icon(icon, x, y, true)
        x += 24
      end
      y += WLH
      x = (sw - states_array.size * 24) / 2
      for state_id in states_array
        icon = $data_states[state_id].icon_index
        rank = @enemy.enemy.state_ranks[state_id]
        result = [0,1,2,3,4,5,6][rank]
        if result == 0
          draw_icon(YE::MENU::MONSTER::ICON_S_RATE_Z, x, y, true)
        elsif result == 1
          draw_icon(YE::MENU::MONSTER::ICON_S_RATE_A, x, y, true)
        elsif result == 2
          draw_icon(YE::MENU::MONSTER::ICON_S_RATE_B, x, y, true)
        elsif result == 3
          draw_icon(YE::MENU::MONSTER::ICON_S_RATE_C, x, y, true)
        elsif result == 4
          draw_icon(YE::MENU::MONSTER::ICON_S_RATE_D, x, y, true)
        elsif result == 5
          draw_icon(YE::MENU::MONSTER::ICON_S_RATE_E, x, y, true)
        elsif result == 6
          draw_icon(YE::MENU::MONSTER::ICON_S_RATE_F, x, y, true)
        else
          draw_icon(YE::MENU::MONSTER::ICON_S_RATE_U, x, y, true)
        end
        x += 24
      end
      y += WLH
    end
  end # 建立狀態頁
  
  #--------------------------------------------------------------------------
  # 建立偷竊頁
  #--------------------------------------------------------------------------
  def make_steal_page
    return unless $imported["Steal"]
    x = 0
    y = 0
    sw = self.width - 32
    y += WLH
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_S_ITEM
    self.contents.draw_text(0, y, sw, WLH, text, 0)
    text = YE::MENU::MONSTER::DATA_S_CHANCE
    self.contents.draw_text(0, y, sw, WLH, text, 2)
    y += WLH
    steal_objects = @enemy.steal_objects.clone
    steal_objects.each_with_index { |item, i|
      break if (y + 24) > (self.height - 32)
      next if item == nil
      case item.kind
      when 0
        next
      when 1
        steal_item = $data_items[item.item_id]
      when 2
        steal_item = $data_weapons[item.weapon_id]
      when 3
        steal_item = $data_armors[item.armor_id]
      end
      draw_item_name(steal_item, 0, y)
      text = sprintf("%d%%", item.success_prob)
      self.contents.draw_text(0, y, sw, WLH, text, 2)
      y += WLH
    }
  end # 建立偷竊頁
  
  #--------------------------------------------------------------------------
  # 建立戰利品頁
  #--------------------------------------------------------------------------
  def make_spoils_page
    x = 0
    y = 0
    sw = self.width - 32
    y += WLH
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_ENCOUNTER
    self.contents.draw_text(24, y, sw-24, WLH, text, 0)
    draw_icon(YE::MENU::MONSTER::ICON_ENCOUNTER, 0, y, true)
    self.contents.font.color = normal_color
    if @enemy.encounters_dse == 1
      text = sprintf(YE::MENU::MONSTER::VIEW_ENC1, @enemy.encounters_dse)
    else
      text = sprintf(YE::MENU::MONSTER::VIEW_ENC2, @enemy.encounters_dse)
    end
    self.contents.draw_text(24, y, sw-24, WLH, text, 2)
    y += WLH
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_KILLED
    self.contents.draw_text(24, y, sw-24, WLH, text, 0)
    draw_icon(YE::MENU::MONSTER::ICON_KILLED, 0, y, true)
    self.contents.font.color = normal_color
    if @enemy.defeated_dse == 1
      text = sprintf(YE::MENU::MONSTER::VIEW_KILLED1, @enemy.defeated_dse)
    else
      text = sprintf(YE::MENU::MONSTER::VIEW_KILLED2, @enemy.defeated_dse)
    end
    self.contents.draw_text(24, y, sw-24, WLH, text, 2)
    y += WLH
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_ESCAPED
    self.contents.draw_text(24, y, sw-24, WLH, text, 0)
    draw_icon(YE::MENU::MONSTER::ICON_ESCAPED, 0, y, true)
    self.contents.font.color = normal_color
    if @enemy.escaped_dse == 1
      text = sprintf(YE::MENU::MONSTER::VIEW_ESCAPED1, @enemy.escaped_dse)
    else
      text = sprintf(YE::MENU::MONSTER::VIEW_ESCAPED2, @enemy.escaped_dse)
    end
    self.contents.draw_text(24, y, sw-24, WLH, text, 2)
    y += WLH
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_GOLD
    self.contents.draw_text(24, y, sw-24, WLH, text, 0)
    draw_icon(YE::MENU::MONSTER::ICON_GOLD, 0, y, true)
    self.contents.font.color = normal_color
    text = sprintf(YE::MENU::MONSTER::VIEW_GOLD, @enemy.gold)
    self.contents.draw_text(24, y, sw-24, WLH, text, 2)
    y += WLH
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_EXP
    self.contents.draw_text(24, y, sw-24, WLH, text, 0)
    draw_icon(YE::MENU::MONSTER::ICON_EXP, 0, y, true)
    self.contents.font.color = normal_color
    text = sprintf(YE::MENU::MONSTER::VIEW_EXP, @enemy.exp)
    self.contents.draw_text(24, y, sw-24, WLH, text, 2)
    if YE::MENU::MONSTER::SPOIL_DROPS and !@enemy.enemy.hide_drops
      y += WLH
      drop_items = [@enemy.drop_item1, @enemy.drop_item2]
      if $imported["ExtraDropItem"]
        drop_items += @enemy.extra_drop_items
      end
      self.contents.font.color = text_color(@category_colour)
      text = YE::MENU::MONSTER::DATA_DROPS
      self.contents.draw_text(0, y, sw, WLH, text, 1)
      y += WLH
      drop_items.each_with_index { |item, i|
        break if (y + 24) > (self.height - 32)
        case item.kind
        when 0
          next
        when 1
          drop_item = $data_items[item.item_id]
        when 2
          drop_item = $data_weapons[item.weapon_id]
        when 3
          drop_item = $data_armors[item.armor_id]
        end
        draw_item_name(drop_item, 0, y)
        if $imported["ExtraDropItem"] && item.drop_prob > 0
          text = sprintf("%d%%", item.drop_prob)
        else
          text = sprintf("%d%%", 1 * 100 /item.denominator)
        end
        self.contents.draw_text(0, y, sw, WLH, text, 2)
        y += WLH
      }
    end
  end # 建立戰利品頁
  
  #--------------------------------------------------------------------------
  # 建立掉落頁
  #--------------------------------------------------------------------------
  def make_drops_page
    x = 0
    y = 0
    sw = self.width - 32
    y += WLH
    self.contents.font.color = text_color(@category_colour)
    text = YE::MENU::MONSTER::DATA_D_ITEM
    self.contents.draw_text(0, y, sw, WLH, text, 0)
    text = YE::MENU::MONSTER::DATA_D_CHANCE
    self.contents.draw_text(0, y, sw, WLH, text, 2)
    y += WLH
    drop_items = [@enemy.drop_item1, @enemy.drop_item2]
    if $imported["ExtraDropItem"]
      drop_items += @enemy.extra_drop_items
    end
    drop_items.each_with_index { |item, i|
      break if (y + 24) > (self.height - 32)
      case item.kind
      when 0
        next
      when 1
        drop_item = $data_items[item.item_id]
      when 2
        drop_item = $data_weapons[item.weapon_id]
      when 3
        drop_item = $data_armors[item.armor_id]
      end
      draw_item_name(drop_item, 0, y)
      if $imported["ExtraDropItem"] && item.drop_prob > 0
        text = sprintf("%d%%", item.drop_prob)
      else
        text = sprintf("%d%%", 1 * 100 /item.denominator)
      end
      self.contents.draw_text(0, y, sw, WLH, text, 2)
      y += WLH
    }
  end # 建立掉落頁
  
  #--------------------------------------------------------------------------
  # 建立備註頁
  #--------------------------------------------------------------------------
  def make_notes_page
    self.contents.font.color.alpha = 255
    self.contents.font.size = YE::MENU::MONSTER::NOTE_PAGE_TEXT_SIZE
    self.contents.font.color = text_color(YE::MENU::MONSTER::NOTE_PAGE_TEXT_COLOUR)
    ###
    #x = 100
    y = 50
    ###
    #y = 24
    txsize = YE::MENU::MONSTER::NOTE_PAGE_TEXT_SIZE + 4
    text = YE::HASH::ENEMY_NOTES[@enemy.enemy_id]
    nwidth = YE::MENU::MONSTER::NOTE_PAGE_WIDTH
    buf = text.gsub(/\\N(\[\d+\])/i) { "\\__#{$1}" }
    lines = buf.split(/(?:[|]|\\n)/i)
    lines.each_with_index { |l, i|
      l.gsub!(/\\__(\[\d+\])/i) { "\\N#{$1}" }
      self.contents.draw_text(0+130, i * txsize + y, nwidth, WLH, l, 0)
    }
  end
  
  #--------------------------------------------------------------------------
  # 建立總頁數
  #--------------------------------------------------------------------------
  def create_total_pages
    @contents = []
    @contents.push(0) if YE::MENU::MONSTER::SHOW_GENERAL
    #----------------
    action_list = []
    for action in @enemy.enemy.actions
      if action.kind == 1
        obj = $data_skills[action.skill_id]
        action_list.push(obj) unless action_list.include?(obj)
      end
    end
    if YE::MENU::MONSTER::SHOW_SKILLS and action_list != []
      if @require
        if $game_party.scan_skill.include?(@enemy.enemy_id)
          @contents.push(1) unless @enemy.enemy.hide_skill
        end
      else
        @contents.push(1) unless @enemy.enemy.hide_skill
      end
    end
    #----------------
    if YE::MENU::MONSTER::SHOW_ELEMENTS
      if @require
        if $game_party.scan_elem.include?(@enemy.enemy_id)
          @contents.push(2) unless @enemy.enemy.hide_elem
        end
      else
        @contents.push(2) unless @enemy.enemy.hide_elem
      end
    end
    #----------------
    if YE::MENU::MONSTER::SHOW_STATES
      if @require
        if $game_party.scan_state.include?(@enemy.enemy_id)
          @contents.push(3) unless @enemy.enemy.hide_state
        end
      else
        @contents.push(3) unless @enemy.enemy.hide_state
      end
    end
    #----------------
    if YE::MENU::MONSTER::SHOW_STEAL and $imported["Steal"]
      if @require
        if $game_party.scan_steal.include?(@enemy.enemy_id)
          @contents.push(80) unless @enemy.enemy.hide_steal
        end
      else
        @contents.push(80) unless @enemy.enemy.hide_steal
      end
    end
    #----------------
    if YE::MENU::MONSTER::SHOW_SPOILS
      if @require
        if $game_party.scan_spoil.include?(@enemy.enemy_id)
          @contents.push(90) unless @enemy.enemy.hide_spoil
        end
      else
        @contents.push(90) unless @enemy.enemy.hide_spoil
      end
    end
    #----------------
    if YE::MENU::MONSTER::SHOW_DROPS
      if @require
        if $game_party.scan_drops.include?(@enemy.enemy_id)
          @contents.push(91) unless @enemy.enemy.hide_drops
        end
      else
        @contents.push(91) unless @enemy.enemy.hide_drops
      end
    end
    #----------------
    if YE::MENU::MONSTER::SHOW_NOTES
      if @require
        if YE::HASH::ENEMY_NOTES.include?(@enemy.enemy_id)
          @contents.push(100) if $game_party.scan_desc.include?(@enemy.enemy_id)
        end
      else
        if YE::HASH::ENEMY_NOTES.include?(@enemy.enemy_id)
          @contents.push(100)
        end
      end
    end
    #----------------
    n = @contents.size
    return n
  end
  
  #--------------------------------------------------------------------------
  # 取得頁面名稱
  #--------------------------------------------------------------------------
  def case_page_name(pagecase)
    if pagecase == 0
      text = YE::MENU::MONSTER::TITLE_GENERAL
    elsif pagecase == 1
      text = YE::MENU::MONSTER::TITLE_SKILLS
    elsif pagecase == 2
      text = YE::MENU::MONSTER::TITLE_ELEMENTS
    elsif pagecase == 3
      text = YE::MENU::MONSTER::TITLE_STATES
    elsif pagecase == 80
      text = YE::MENU::MONSTER::TITLE_STEAL
    elsif pagecase == 90
      text = YE::MENU::MONSTER::TITLE_SPOILS
    elsif pagecase == 91
      text = YE::MENU::MONSTER::TITLE_DROPS
    elsif pagecase == 100
      text = YE::MENU::MONSTER::TITLE_NOTES
    else
      text = YE::MENU::MONSTER::TITLE_UNKNOWN
    end
    return text
  end
  
  #--------------------------------------------------------------------------
  # 執行指定頁面
  #--------------------------------------------------------------------------
  def case_page_run(pagecase)
    if pagecase == 0
      make_general_page
    elsif pagecase == 1
      make_skills_page
    elsif pagecase == 2
      make_elements_page
    elsif pagecase == 3
      make_states_page
    elsif pagecase == 80
      make_steal_page
    elsif pagecase == 90
      make_spoils_page
    elsif pagecase == 91
      make_drops_page
    elsif pagecase == 100
      make_notes_page
    end
  end
  
end

#===============================================================================
#
# 檔案結束
#
#===============================================================================
