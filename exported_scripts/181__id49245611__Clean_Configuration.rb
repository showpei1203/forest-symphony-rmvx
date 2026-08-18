#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：Clean Configuration（Quest Journal 2.1b 乾淨設定參考）
# 原作：modern algebra（rmrk.net）｜2011-08-16
#
# 【用途】
# 這一頁是 Quest Journal 2.1b 的「乾淨設定／範例設定」參考副本，整頁包在
# =begin ... =end 之間，因此目前不會執行。正式 Runtime 使用前方的
#「QJ2 - CONFIGURATION」與後方「QJ2 - IMPLEMENTATION」。保留本頁的目的，是
# 讓未來維護者可以直接查到原系統完整設定結構、任務資料格式、Script Call 與範例，
# 不需要再去找十幾年前的論壇附件。
#
# 【重要】
# 1. 本頁是參考文件，不要把 =begin / =end 拿掉，否則會再次宣告 QuestData 與
#    $imported，和正式 QJ2 設定重複。
# 2. 若要改 Forest Symphony 的正式任務資料，請改「QJ2 - CONFIGURATION」或
#    FS Quest Bridge，而不是本頁。
# 3. Script Call／Symbol／Notetag／Ruby 範例必須保留原拼字，不可翻成中文識別字。
#
# 【Quest Journal 核心概念】
# QJ2 只負責「顯示與追蹤任務狀態」，不會替遊戲自動建立任務流程。NPC 對話、
# 戰鬥、取得道具、地圖條件等仍由事件製作；事件再用 Script Call 更新任務狀態。
# 任務由 Quest ID 識別，每個任務包含名稱、說明、委託人、地點、目標、主要目標、
# 獎勵、難度、完成 Common Event、圖示與自訂分類。
#
# 【設定區 A｜功能】
# CATEGORIES   ：日誌分類及順序；內建 :all / :active / :complete / :failed，
#                也可自訂 Symbol，例如 :primary。自訂後需同步加入 ICONS，並在
#                任務資料的 custom_categories 加入相同 Symbol。
# SORT_TYPE    ：:id / :revealed / :alphabet / :level / :none；名稱後可加 reverse
#                反向排序，例如 :revealedreverse。
# MENU_ACCESS  ：是否從主選單進入。
# MENU_INDEX   ：主選單插入位置。
# KEY_ACCESS   ：是否允許地圖快捷鍵。
# MAPKEY_BUTTON：地圖快捷鍵，例如 Input::L。
# MANUAL_REVEAL：true 時必須 reveal_quest 才顯示；false 時操作目標即可自動揭露。
#
# 【設定區 A｜外觀】
# BG_PICTURE / BG_OPACITY         ：背景圖片（Graphics/Pictures）與透明度。
# WINDOWS_SKIN / WINDOWS_OPACITY  ：WindowSkin 與透明度。
# LIST_WIDTH                      ：左側任務清單寬度。
# ICONS / COLOURS                 ：分類、Gold、EXP、Level 等圖示與顏色。
# INFO_LAYOUT                     ：詳細資料垂直順序；兩個 Symbol 放同一 Array
#                                   代表同一列，例如 [:client, :level]。
# SUBTITLE_*                      ：字體、大小、粗體與內容排版。
# VOCAB_*                         ：畫面標題文字。
# *_FONTSIZE                      ：各區域字體大小。
# JUSTIFY_PARAGRAPHS              ：說明／目標是否左右對齊。
#
# 【任務資料格式｜設定區 B】
# when <quest_id>
#   banner = "Pictures 內檔名"
#   name = "任務名稱"
#   client = "委託人"
#   location = "地點"
#   description = "任務說明"
#   objectives[0] = "第一個目標"
#   objectives[1] = "第二個目標"
#   prime = [0, 1]                     # 完成任務所必需的目標 ID
#   rewards = [[0, item_id, amount],   # 0=Item
#              "純文字獎勵"]
#   level = 1
#   common_event = 0
#   icon_index = 0
#   custom_categories.push(:primary)
#
# prime 未設定時，預設所有 objectives 都是主要目標。rewards 除了顯示外，
# give_quest_reward 只能自動發放類型 0～4；純文字獎勵仍要由事件自行處理。
#
# 【事件 Script Call｜任務進度】
# quest(1)                              # 取得 Quest 1 的 Game_Quest
# quest(1).name = "新名稱"             # 可直接改公開資料
# reveal_objective(1, 0)                # 揭露 Quest 1 的目標 0
# conceal_objective(1, 0)
# complete_objective(1, 0, 1)
# uncomplete_objective(1, 0)
# fail_objective(1, 1)
# unfail_objective(1, 1)
# change_reward_status(1, true)         # 記錄獎勵已發放
# give_quest_reward(1)                  # 任務完成且尚未發獎時發放類型 0～4
# reset_quest(1)                        # 清空該任務所有進度
# remove_quest(1)                       # 停用並重設
# conceal_quest(1)                      # 隱藏但保留進度
# reveal_quest(1)                       # 顯示／重新啟用
# call_quest                            # 開啟任務日誌
# call_quest(1)                         # 直接開啟 Quest 1（需已揭露且可顯示）
#
# 【存取控制】
# change_quest_access(:disable)         # 禁止進入任務日誌
# change_quest_access(:enable)
# change_quest_access(:disable_menu)    # 移除主選單入口
# change_quest_access(:enable_menu)
# change_quest_access(:disable_map)     # 禁用地圖快捷鍵
# change_quest_access(:enable_map)
# change_quest_background("QuestBG", 200)
# change_quest_windows("Window", 200)
#
# 【條件分歧可用判定】
# objective_revealed?(quest_id, ...)
# quest_complete?(quest_id)
# objective_complete?(quest_id, ...)
# quest_failed?(quest_id)
# objective_failed?(quest_id, ...)
#
# 每個可購買任務用 [quest_id, cost, objective_id, switch_id] 描述。objective_id 可
# 指定購買後只揭露某個目標；switch_id 可限制商店中何時出現。把多個項目放進陣列：
# a = []
# a.push([1, 50, 0, 0], [2, 75, -1, 0])
# a.push([3, 100, -1, 0], [4, 75, -1, 1])
# call_quest_shop(a, "Fighter's Guild")
#
# 【相容性】
# 原作可自動加入 VX 預設主選單，也曾支援 Dargor Custom Commands、
# YEM Main Menu Melody、Full Status Custom Menu、Phantasia-esque Menu；使用這些
# 舊整合時 QJ2 必須在它們之後。Forest Symphony 現在另有自己的 Menu／Quest 整合，
# 以目前 Load Order Guide 為準。
#
# 【來源／授權】
# 原作者：modern algebra（rmrk.net）。此中文整理保留 API 與原資料格式，不取代原授權。
#==============================================================================
=begin
$imported = {} unless $imported
$imported["QuestJournal2.1"] = true

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

module QuestData
  #\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  CATEGORIES = [:all, :active, :complete, :failed]
  SORT_TYPE = :revealed
  MENU_ACCESS = true
  MENU_INDEX = 4
  KEY_ACCESS = false
  MAPKEY_BUTTON = Input::L
  MANUAL_REVEAL = false     
  BG_PICTURE = ""
  BG_OPACITY = 255
  WINDOWS_SKIN = "Window"
  WINDOWS_OPACITY = 200
  LIST_WIDTH = 184
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
  }
  COLOURS = {
    :active => 0,
    :complete => 3,
    :failed => 10,
    :label => 16,
    :content => 0,
    :subtitle => 16
  }
  VOCAB_QUESTS = "Quests"
  LABEL_FONTNAME = ""
  LABEL_FONTSIZE = 0        
  LABEL_BOLD = false
  INFO_LAYOUT = [:banner, :name, [:client, :level], :location, :description,
    :objectives, :rewards]
  NAME_FONTNAME = ""        
  NAME_FONTSIZE = 20
  NAME_BOLD = true
  CONTENT_FONTNAME = ""
  SUBTITLE_FONTNAME = ""  
  SUBTITLE_FONTSIZE = 20
  SUBTITLE_BOLD = true
  VOCAB_CLIENT = "Client:"
  CLIENT_WIDTH = 0          
  VOCAB_LOCATION = "Locale:"
  LOCATION_WIDTH = 0        
  LEVEL_SPACE = 16
  VOCAB_DESCRIPTION = "Description"
  DESC_FONTSIZE = 20
  VOCAB_OBJECTIVES = "Objectives"
  OBJECTIVE_BULLET = "●"
  OBJ_FONTSIZE = 20
  VOCAB_REWARDS = "Rewards"
  REWARD_BULLET = ""
  REWARD_FONTSIZE = 20
  ITEM_NUMBER_PREFACE = "x"
  VOCAB_EXP = "EXP"
  DRAW_VOCAB_GOLD = true
  VOCAB_HELP_GENERAL = "Use the horizontal directional keys to switch categories"
  VOCAB_HELP_SELECTED = "Use the vertical directional keys to scroll up and down"
  HELP_ALIGNMENT = 1        
  JUSTIFY_PARAGRAPHS = false
  VOCAB_PURCHASE = "Quest Shop"
  PURCHASE_USE_GOLD_ICON = true
  PURCHASE_INFO_LAYOUT = [:banner, :name, [:client, :level], :location, 
    :description, :objectives, :rewards]
  PURCHASE_SE = ["Shop", 80]
  PURCHASE_LIST_WIDTH = 224
  #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
  #////////////////////////////////////////////////////////////////////////////
  ICONS.default = 0
  COLOURS.default = 0
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
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
    #````````````````````````````````````````````````````````````````````````
    #
    #      when <quest_id> # 指定任務 ID
    #        banner = "圖片檔名"
    #        name = "任務名稱" 
    #        client = "委託人"
    #        location = "任務地點"
    #        description = "任務說明"
    #        objectives[0] = "第一個目標"
    #        ...
    #        objectives[n] = "第 n 個目標" 
    #        prime = [objective_id, ..., objective_id] # 主要目標 ID
    #        rewards = [ [type, id, amount], ..., [type, id], "文字獎勵" ]
    #        level = integer # 任務等級
    #        common_event = id # 首次完成時執行的 Common Event ID
    #        icon_index = quest_icon_index # 任務圖示 Index
    #        custom_categories.push (:symbol_1, ..., :symbol_n) # 自訂分類
    #
    #        rewards 的 type：0=Item、1=Weapon、2=Armor、3=Gold、4=EXP。
    #        Item／Weapon／Armor 的 id 是資料庫 ID；Gold／EXP 則以數值欄位表示數量。
    #
    #   
    #      banner = ""
    #      name = "??????"
    #      description = "??????????"
    #      client = ""
    #      location = ""
    #      objectives = []
    #      prime = [所有主要目標 ID]
    #      rewards = []
    #      level = 0
    #      common_event = 0
    #      icon_index = 0
    #      custom_categories = []
    #
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    when 1
      name = "Quest 1"
      banner = ""
      description = "This is the first quest the players receive. It probably involves playing fetch with lazy humans."
      client = ""
      location = ""
      objectives[0] = "The first objective (ID 0)"
      objectives[1] = "Do this next (ID 1)"
      objectives[2] = "Return to collect your reward"
      prime = [0, 1]
      rewards = [ [0, 1, 3], [3, 100] ]
      level = 0
      common_event = 0
      icon_index = 212
      custom_categories = []
    when 4
      name = "Lovely Lucy"
      description = "Pursue the affections of \\c[6]Lucy\\c[0]"
      objectives[0] = "Buy her a present from the vendor"
      objectives[1] = "Take her out to dinner"
      objectives[2] = "Walk her back to her home"
      rewards = [ [4, 50], "\\icon[137]A kiss from Lucy" ]
      icon_index = 77
    #||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
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
=end
