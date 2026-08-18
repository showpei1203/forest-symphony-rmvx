#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：QJ2 - CONFIGURATION
# 原作：Quest Journal 2.1b／modern algebra (rmrk.net)，2011-08-16
#
# 【用途】
# 本頁是 Quest Journal 2 的「設定＋任務資料」頁。它不會自動替遊戲建立任務；
# 任務流程仍由地圖事件／Common Event 自行製作。本頁負責：任務分類、排序、
# Menu／地圖快捷鍵入口、背景／WindowSkin、字體、顏色、Info Window 排版、
# 任務商店，以及每個 Quest ID 的名稱、目標、獎勵、難度等資料。
#
# 【依賴與載入順序】
# 1. 與「QJ2 - IMPLEMENTATION」成對使用，本頁設定必須先載入。
# 2. $imported["QuestJournal2.1"] = true 為相容判定，不可任意改名。
# 3. 若使用 Dargor Custom Commands、YEM Main Menu Melody、Full Status Custom
#    Menu、Phantasia-esque Menu 等舊式 Menu 整合，QJ2 必須位於那些系統之後。
# 4. Forest Symphony 已有自己的 Quest／ATS 整合；改入口前先查 LoadOrder Guide。
#
# 【可編輯區域 A：功能設定】
# CATEGORIES：任務分類與顯示順序。內建 :all、:active、:complete、:failed；
#             也可自訂 Symbol，例如 :primary、:secondary。自訂分類後需同步在
#             ICONS 建立同名 Symbol，並在 quest_data 的 custom_categories.push
#             把任務加入該分類。
# SORT_TYPE ：排序方式。
#             :id       依 Quest ID
#             :revealed 依揭露順序
#             :alphabet 依名稱字母
#             :level    依難度
#             :none     不排序
#             原腳本亦支援在名稱後加 reverse 反轉，例如 :revealedreverse。
# MENU_ACCESS：true 時可由主選單進入任務日誌。
# MENU_INDEX ：主選單中的插入位置。
# KEY_ACCESS ：true 時允許地圖快捷鍵進入。
# MAPKEY_BUTTON：地圖快捷鍵，例如 Input::L。
# MANUAL_REVEAL：true 時任務必須明確呼叫 reveal_quest 才會顯示；false 時，
#                一旦對任務目標執行 reveal／complete／fail 等操作即可自動啟用。
#
# 【可編輯區域 A：圖形與版面】
# BG_PICTURE / BG_OPACITY：任務畫面背景圖（Graphics/Pictures）與透明度。
# WINDOWS_SKIN / WINDOWS_OPACITY：WindowSkin（Graphics/System）與視窗透明度。
# LIST_WIDTH：左側任務／分類清單寬度。
# ICONS：分類、Menu、Gold、EXP、Level、Client、Location 等圖示 ID；自訂分類亦
#        必須在此加入相同 Symbol。
# COLOURS：active／complete／failed／label／content／subtitle 顏色。可填
#          WindowSkin palette index，或 [R,G,B,A]。
# LABEL_FONTNAME / LABEL_FONTSIZE / LABEL_BOLD：左側標題字體。
# INFO_LAYOUT：任務詳細資料的垂直排列。可用：:banner、:name、:client、:level、
#              :location、:description、:objectives、:rewards；把兩個 Symbol 放進
#              同一 Array 代表同一列，例如 [:client, :level]。
# NAME_* / CONTENT_FONTNAME / SUBTITLE_*：名稱、正文、子標題字體設定。
# CLIENT_WIDTH / LOCATION_WIDTH：Client／Location 可用的水平空間；0 代表自動。
# LEVEL_SPACE：Level Icon 間距。
# VOCAB_*：各標題文字，例如委託人、地點、主旨、任務、獎勵、EXP。
# OBJECTIVE_BULLET / REWARD_BULLET：目標／獎勵前綴。
# *_FONTSIZE：各區文字大小。
# DRAW_VOCAB_GOLD：是否同時畫 Gold 文字；false 可只畫 Icon。
# VOCAB_HELP_GENERAL / VOCAB_HELP_SELECTED / HELP_ALIGNMENT：Help Window 文字與對齊。
# JUSTIFY_PARAGRAPHS：是否對 Description／Objectives 做段落對齊。
#
# 【任務商店】
# VOCAB_PURCHASE：任務商店名稱；PURCHASE_USE_GOLD_ICON：是否顯示 Gold Icon。
# PURCHASE_INFO_LAYOUT：任務商店詳細資料版面。
# PURCHASE_SE = [SE檔名, 音量]：購買任務時音效。
# PURCHASE_LIST_WIDTH：商店列表寬度。
#
# 【可編輯區域 B：建立 Quest】
# 每個任務以唯一 Quest ID 建立：
#   when <quest_id>
#     banner = "filename"              # Graphics/Pictures 圖片，可留空
#     name = "任務名稱"
#     client = "委託人"
#     location = "地點"
#     description = "任務說明"
#     objectives[0] = "第一個目標"
#     objectives[1] = "第二個目標"
#     prime = [0, 1]                    # 必須完成的主要目標；省略＝全部目標
#     rewards = [[type,id,amount], ...] # 或直接放字串作顯示文字
#          level = 3
#     common_event = 12                 # 首次完成任務時立刻呼叫的 Common Event ID
#     icon_index = 123
#     custom_categories.push(:primary)
#
# Item／Weapon／Armor 的格式為 [type,id,amount]；Gold／EXP 的 id 欄位就是數量。
# 若 rewards 使用純字串，QJ2 只會顯示文字，give_quest_reward 不會自動發放。
# 至少應設定 name、description、objectives；其他欄位都有預設值。
# 若 prime 未設定，系統會把全部 objectives 視為主要目標。
#
# 【主要 Script Call／事件呼叫】
# 取得任務物件：
#   quest(1)
#   quest(1).name = "新的任務名稱"
#
# 控制目標：
#   reveal_objective(1, 0)          # 顯示 Quest 1 的第 0 個目標
#   conceal_objective(1, 0)
#   complete_objective(6, 2, 3)     # 完成 Quest 6 的第 2、3 個目標
#   uncomplete_objective(6, 2)
#   fail_objective(6, 2)
#   unfail_objective(6, 2)
#
# 任務本體：
#   reset_quest(1)                  # 回到初始狀態，進度全部清除
#   remove_quest(1)                 # 停用並重設
#   conceal_quest(1)                # 隱藏但保留進度
#   reveal_quest(1)                 # 啟用／重新顯示
#   change_reward_status(8)         # 預設 true，可防止重複給獎
#   change_reward_status(8, false)
#   give_quest_reward(8)            # 任務完成且未領獎時，發放 type 0～4 獎勵
#
# 入口控制：
#   change_quest_access(:disable)
#   change_quest_access(:enable)
#   change_quest_access(:disable_menu)
#   change_quest_access(:enable_menu)
#   change_quest_access(:disable_map)
#   change_quest_access(:enable_map)
#
# 外觀動態變更：
#   change_quest_background("bg_filename", 255)
#   change_quest_windows("windowskin_filename", 255)
#
# 條件分歧可用：
#   quest_revealed?(1)
#   objective_revealed?(1, 0, 1)
#   quest_complete?(1)
#   objective_complete?(1, 0, 1)
#   quest_failed?(1)
#   objective_failed?(1, 0, 1)
#   quest_rewarded?(1)
#
# 由事件直接開啟任務日誌：
#   call_quest              # 一般開啟
#   call_quest(6)           # 若 Quest 6 已揭露且可存取，直接開在 Quest 6
#
# 【任務商店 Script Call】
# 單筆格式：[quest_ID, cost, [objective_ids...], switch_ID]
#   quest_ID：可購買任務 ID
#   cost：價格
#   objective_ids：購買後立即揭露的目標；省略＝全部揭露
#   switch_ID：只有開關 ON 時才出售；省略＝永遠出售
# 範例：
#   a = []
#   a.push([1, 50, [0]], [4, 80, 1])
#   a.push([3, 100], [5, 75, [0,1], 1])
#   call_quest_shop(a, "Fighter's Guild")
#
# 若 Description／Objective 使用 Special Codes Formatter，原作提醒控制碼需以 \\
# 開頭，而不是單一 \；Forest Symphony 現行任務文字已有這類控制碼，勿隨意改。
#
# 【相關素材】
# BG_PICTURE、banner 會讀 Graphics/Pictures；WINDOWS_SKIN 讀 Graphics/System；
# PURCHASE_SE 讀 Audio/SE。實際檔名由本頁常數／各 Quest 資料決定。
#
# 【維護規則】
# 1. Quest ID 必須唯一；事件／Common Event 若用數字 ID 呼叫，改 ID 前先全域搜尋。
# 2. 公開 Script Call／Symbol／Notetag／控制碼不得翻譯或改名。
# 3. 原作者、版本、網址與 Credits 保留；下方英文長篇說明已整併成此中文手冊，
#    Runtime 程式與任務字串不因中文化而修改。
#==============================================================================
#==============================================================================
# Quest Journal 2.1b
# 作者：modern algebra (rmrk.net)｜日期：2011-08-16
# 原英文使用手冊已完整整理至本頁開頭「Forest Symphony｜繁體中文完整說明」。
# 下方保留 Runtime、QuestData、既有任務字串與原作者 API；不再重複一整段英文手冊。
#==============================================================================

$imported = {} unless $imported
$imported["QuestJournal2.1"] = true

#==============================================================================
# *** Quest Data／任務資料
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

module QuestData
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #    可編輯區域 A
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  # 功能設定
  CATEGORIES = [:active, :failed, :complete]
  SORT_TYPE = :revealed
  MENU_ACCESS = false
  MENU_INDEX = 5
  KEY_ACCESS = false
  MAPKEY_BUTTON = Input::L
  MANUAL_REVEAL = false
  # 圖形／介面設定
  BG_PICTURE = "NEW2013"
  BG_OPACITY = 255
  WINDOWS_SKIN = "window_NEW"
  WINDOWS_OPACITY = 0
  LIST_WIDTH = 208
  ICONS = {                 
    :all => 0,
    :active => 149,
    :complete => 150,
    :failed => 179,
    :menu => 178,
    :gold => 147,
    :exp => 133,
    :level => 62,
    :client => 0,
    :location => 0,
    :romance => 216,
  }
  COLOURS = {
    :active => 0,
    :complete => [202, 255, 45],
    :failed => [255, 84, 89],
    :label => 16,
    :content => 0,
    :subtitle => 16
  }
  VOCAB_QUESTS = ""
  LABEL_FONTNAME = ["微軟正黑體", "Verdana", "Arial", "Times New Roman"]
  LABEL_FONTSIZE = 24        
  LABEL_BOLD = true
  INFO_LAYOUT = [:banner, :name, [:client, :level], :location, :description,
    :objectives, :rewards]
  NAME_FONTNAME = ["微軟正黑體", *Font.default_name]        
  NAME_FONTSIZE = 24
  NAME_BOLD = true
  CONTENT_FONTNAME = ["微軟正黑體", *Font.default_name]
  SUBTITLE_FONTNAME = ""  
  SUBTITLE_FONTSIZE = 20
  SUBTITLE_BOLD = true
  VOCAB_CLIENT = "委託人:"
  CLIENT_WIDTH = 10          
  VOCAB_LOCATION = "地點:"
  LOCATION_WIDTH = 0        
  LEVEL_SPACE = 16
  VOCAB_DESCRIPTION = "主旨"
  DESC_FONTSIZE = 20
  VOCAB_OBJECTIVES = ""
  OBJECTIVE_BULLET = ""
  OBJ_FONTSIZE = 18
  VOCAB_REWARDS = "獎勵"
  REWARD_BULLET = ""
  REWARD_FONTSIZE = 16
  ITEM_NUMBER_PREFACE = "x"
  VOCAB_EXP = "EXP"
  DRAW_VOCAB_GOLD = true
  VOCAB_HELP_GENERAL = "按下確定鍵可查看任務內容"
  VOCAB_HELP_SELECTED = "利用上、下鍵捲動任務內容"
  HELP_ALIGNMENT = 1        
  JUSTIFY_PARAGRAPHS = true
  # 任務商店設定
  VOCAB_PURCHASE = "Quest Shop"
  PURCHASE_USE_GOLD_ICON = true
  PURCHASE_INFO_LAYOUT = [:name, [:client, :level], :location, :description, 
    :rewards]
  PURCHASE_SE = ["Shop", 80]
  PURCHASE_LIST_WIDTH = 224
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #    可編輯區域 A 結束
  #////////////////////////////////////////////////////////////////////////////
  ICONS.default = 0
  COLOURS.default = 0
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 任務資料
  #````````````````````````````````````````````````````````````````````````````
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def self.quest_data (id)
    banner = ""
    name = "??????"
    description = "??????????"
    client = ""
    location = ""
    objectives = []
    prime = nil
    rewards = []
    level = 0
    common_event = 0
    icon_index = 0
    custom_categories = []
    case id
    #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
    #    可編輯區域 B
    #````````````````````````````````````````````````````````````````````````
    #
    #        banner = "filename"
    #        name = "quest_name" 
    #        client = "person who gave the quest"
    #        location = "place to go for the quest"
    #        description = "quest_description"
    #        objectives[0] = "first_objective"
    #        ...
    #        objectives[n] = "(n - 1)th objective" 
    #        prime = [objective_id, ..., objective_id]
    #        rewards = [ [type, id, amount], ..., [type, id], "text" ]
    #                level = integer
    #        common_event = id
    #        icon_index = quest_icon_index
    #        custom_categories.push (:symbol_1, ..., :symbol_n)
    #
    #
    #   
    #      banner = ""
    #      name = "??????"
    #      description = "??????????"
    #      client = ""
    #      location = ""
    #      objectives = []
    #      prime = [all objectives]
    #      rewards = []
    #            level = 0
    #      common_event = 0
    #      icon_index = 0
    #      custom_categories = []
    #
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    when 1
      name = "村長的委託"
      banner = "legendary_LUCA"
      description = "\\b\\c民兵通知，\\u村長\/u請喬伊過去一趟\n"
      client = ""
      location = ""
      objectives[0] = "\\b→到村長家和村長對話"
      objectives[1] = "\\b→前往村外位於北方的洞窟"
      objectives[2] = "\\b→找村長領賞囉"
      objectives[3] = "\\b→再次前往橡木聖地"
      objectives[4] = "\\b→再次去找村長"
      rewards = [ "\\IC[133] EXP 100%",[0,31] ]
      icon_index = 1760
    when 2
      name = "心跳一百二"
      banner = "legendary_LUCA"
      description = "\\b\\c到各村落認識女僕姐妹淘們！\n "
      objectives[0] = "\\b→認識全部的姊妹淘，已找到\\v[150]位"
      objectives[1] = "\\b→心跳時刻"
      icon_index = 2000
    # when 2 # Quest 2
    #  name = "菇菇愛好者"
    #  description = "The alchemist's assistant needs help collecting some mushrooms at the Beach Cave"
    #  objectives[0] = "Collect 2 Brown Mushrooms"
    #  objectives[1] = "Collect 1 Elder's Cap Mushroom (Optional)"
    #  objectives[2] = "Return to the Alchemist's assistant for a reward"
    #  prime = [0, 2]
    #  rewards = [ [0, 1], [4, 20] ]
    #  icon_index = 165
    when 3
      name = "千金大小姐"
      banner = "legendary_LUCA"
      description = "\\b\\c陪艾薇前往坎普營地\n"
      objectives[0] = "\\b→到村口找艾薇"
      objectives[1] = "\\b→帶艾薇到橡木聖地"
      objectives[2] = "\\b→前往坎普營地"
      objectives[3] = "\\b→到主營帳探探艾卓的消息"
      objectives[4] = "\\b→打倒營地的\\IC[138]衛兵\\v[152]位，共8位"
      rewards = [ "\\IC[133] EXP 100%","\\IC[1303]?????" ]
      icon_index = 1765
    when 4
       name = "尋找特製乳酪"
      banner = "legendary_LUCA"
      description = "\\b\\c溫蒂很著急，一起幫她找看看\n"
      objectives[0] = "\\b→應該在附近，試著使用狼型態找找看吧？"
      objectives[1] = "\\b→找到了，快拿給溫蒂"
      rewards = [[0, 31]]
      icon_index = 172
    when 5
      name = "力氣的證明"
      banner = "legendary_LUCA"
      description = "\\b\\c向工人證明喬伊的力氣\n"
      objectives[0] = "\\b→搬到標記處，試著使用熊型態搬看看吧？"
      objectives[1] = "\\b→成功了，找工人討賞"
      rewards = [[0, 31]]
      icon_index = 137
    when 6
      name = "艾卓的任務"
      banner = "legendary_CAMP"
      description = "\\b\\c配合艾卓的行動\n"
      objectives[0] = "\\b→救治被打倒的9位衛兵，已救治\\v[154]位"
      objectives[1] = "\\b→回去找艾卓報到"
      objectives[2] = "\\b→前往哈貝爾村"
      objectives[3] = "\\b→找到哈貝爾村的村長"
      objectives[4] = "\\b→找到阿法古倫"
      objectives[5] = "\\b→找到哈貝爾鍛造第一名的柔伊"
      objectives[6] = "\\b→前往阿爾泰斯特城"
      rewards = [ "\\IC[133] EXP 100%","\\IC[1303]?????" ]
      icon_index = 1764
    when 7
      name = "還錢的酒客"
      banner = "legendary_CAMP"
      description = "\\b\\c幫忙丟臉的酒客還錢吧\n"
      objectives[0] = "\\b→幫忙拿錢給綠林酒吧的老闆娘"
      objectives[1] = "\\b→回去找這位糊塗的仁兄"
      rewards = [ "\\IC[1490] ????G" ]
      icon_index = 617
    when 8
      name = "弄丟的玩偶"
      banner = "legendary_CAMP"
      description = "\\b\\c幫小女孩找她心愛的玩偶\n"
      objectives[0] = "\\b→在營地內的河邊找看看吧？"
      objectives[1] = "\\b→將玩偶還給小女孩"
      rewards = [[2, 85]]
      icon_index = 2702
    when 10
      name = "麥格尼的心願"
      banner = "legendary_HABBEL"
      description = "\\b\\c到底在意的是鍛造技術還是暗戀對象呢？\n"
      objectives[0] = "\\b→蒐集10份礦材，目前有\\MIID[103]份"
      objectives[1] = "\\b→找到頭盔專用鐵鎚"
      objectives[2] = "\\b→將頭盔拿給酒吧老闆娘賽荷"
      objectives[3] = "\\b→再去找麥格尼"
      rewards = [ "\\IC[140]機器人TX-000" ]
      icon_index = 32
      #custom_categories.push (:romance)
    when 11
      name = "哈林德的傷勢"
      banner = "legendary_HABBEL"
      description = "\\b\\c幫幫這位很會忍痛的矮人爺爺\n"
      objectives[0] = "\\b→找到村長夫人納吉司"
      objectives[1] = "\\b→將特製藥水交給哈林德"
      rewards = [ "\\IC[19] ?????" ]
      icon_index = 872
    when 12
      name = "所謂的文化"
      description = "Books bring you great wisdom. You should read more."
      objectives[0] = "Find and read a book"
      icon_index = 176
      rewards.push ( [4, 15] )
      common_event = 1
    when 108
      name = "Purchase Me!"
      description = "This is just an extra sample quest so you can see the quest shop."
      client = "Rumour Monger"
      objectives[0] = "\\MIID[1]Thank you for buying me"
      objectives[1] = "These aren't real objectives"
      objectives[2] = "See how all my objectives were revealed?"
      rewards.push ( [3, 200] )
      level = 5
      icon_index = 93
    when 109
      name = "Treasure Hunt"
      description = "The legendary Redbeard supposedly buried his treasure nearby"
      objectives[0] = "Look between a tree and a distinctive rock at the beach"
      objectives[1] = "Go to the Barren Plains and search through the mausoleum"
      icon_index = 194
      rewards = [ "\\icon[147]????" ]
      level = 2
    when 110
      name = "Warning"
      description = "A village may be in the path of a migrating herd of orcs"
      client = "Scout"
      location = "Lavendale"
      objectives[0] = "Go to the town of Lavendale and warn them of the impending danger"
      objectives[1] = "Obstruct the herd to give the villagers time to escape"
      objectives[2] = "Speak to the mayor for a reward"
      icon_index = 94
      rewards = [ [2, 7], [4, 250] ]
      level = 4
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    #    可編輯區域 B 結束
    #////////////////////////////////////////////////////////////////////////
    end
    unless prime
      prime = []
      objectives.each_index { |i| prime.push (i) }
    end
    return banner, name, description, client, location, objectives, prime, 
      rewards, level, common_event, icon_index, custom_categories
  end
end
