#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：QJ2 - IMPLEMENTATION
# 系統：Quest Journal 2.1b｜原作 modern algebra（rmrk.net）
#
# 【用途】
# Quest Journal 的執行核心。設定與 Quest 資料由「QJ2 - CONFIGURATION」提供；本頁
# 負責把資料變成實際的任務狀態、排序、視窗、日誌場景、任務商店與事件 Script Call。
# 正常調整任務內容／顏色／排版時不應直接改這一頁。
#
# 【主要資料類別】
# Game_Quest  ：單一任務執行狀態，保存 revealed / complete / failed objectives、
#              reward_given、concealed、cost 等。
# Game_Quests ：Game_Quest 集合與 :id / :revealed / :alphabet / :level 排序。
# Game_Party  ：持有 $game_party.quests。
# Game_System ：保存 Quest Journal 存取、排序、背景與 WindowSkin 等狀態。
# Game_Temp   ：場景切換與任務商店暫存資料。
#
# 【事件 Script Call】
# 這些方法由 Game_Interpreter 提供；參數格式與完整範例可查前一頁
#「Clean Configuration」或正式「QJ2 - CONFIGURATION」。
# quest(id)
# reveal_objective(id, ...)
# conceal_objective(id, ...)
# complete_objective(id, ...)
# uncomplete_objective(id, ...)
# fail_objective(id, ...)
# unfail_objective(id, ...)
# change_reward_status(id, true_or_false)
# give_quest_reward(id)
# reset_quest(id)
# remove_quest(id)
# conceal_quest(id)
# reveal_quest(id)
# objective_revealed?(id, ...)
# objective_complete?(id, ...)
# objective_failed?(id, ...)
# quest_complete?(id)
# quest_failed?(id)
# change_quest_access(:enable / :disable / :enable_menu / :disable_menu /
# change_quest_background(filename, opacity)
# change_quest_windows(filename, opacity)
# call_quest(id)
# call_quest_shop(array, "商店名稱")
#
# 【完成規則】
# complete?：所有 prime_objectives 都在 complete_objectives 中才成立。
# failed?  ：任一 prime_objective 出現在 failed_objectives 即成立。
# 首次完成時會把 common_event_id 寫入 $game_temp.common_event_id，之後把該 ID 清為 0，
# 避免同一任務完成 Common Event 重複觸發。
#
# 【獎勵】
# give_quest_reward 只自動處理設定格式中的 Item / Weapon / Armor / Gold / EXP；
# 純文字獎勵只是顯示資訊，仍需事件自行發放。reward_given 用於防止重複發獎。
#
# 【載入順序／修改原則】
# 1. 必須位於 QJ2 Configuration 後方。
# 2. Forest Symphony 的 Menu／ATS／Quest Bridge 會在後方再整合它；搬動前查 LoadOrder Guide。
# 3. 本頁含多處 alias／Scene／Window 整合，修改核心前先確認後續 FS Authority 是否再包裝。
# 4. Script Call 名稱、Symbol 與資料欄位是公開 API，不可因中文化而改名。
#
# 【素材】
# 任務 banner／背景等素材名稱主要來自 QuestData；本頁也會依設定讀取 Pictures、System
# 圖片。移除素材前必須反查正式 Configuration、事件與 FS Quest 整合。
#
# 【來源／授權】
# Quest Journal 2.1b，modern algebra（rmrk.net）。原作者資訊與 API 名稱保留。
#==============================================================================
#==============================================================================
# ** Game_Quest｜單一任務狀態
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Game_Quest 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 公開實例變數
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :revealed_objectives # 已揭露目標陣列
  attr_reader   :complete_objectives # 已完成目標陣列
  attr_reader   :failed_objectives   # 已失敗目標陣列
  attr_reader   :id                  # 在 $game_party.quests 中的 Quest ID
  attr_reader   :name                # 任務名稱
  attr_reader   :level               # 任務難度
  attr_accessor :banner              # 頂端顯示圖片
  attr_accessor :description         # 任務簡介
  attr_accessor :client              # 委託人名稱
  attr_accessor :location            # 任務地點
  attr_accessor :objectives          # 目標文字陣列
  attr_accessor :prime_objectives    # 主要目標 ID 陣列
  attr_accessor :rewards             # 獎勵資料陣列
  attr_accessor :common_event_id     # 首次完成時呼叫的 Common Event ID
  attr_accessor :icon_index          # 任務圖示 ID
  attr_accessor :custom_categories   # 自訂分類 Symbol 陣列
  attr_accessor :reward_given        # 避免重複發獎的旗標
  attr_accessor :concealed           # 任務是否隱藏
  attr_accessor :cost                # 任務商店售價
  alias rewarded? reward_given
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (id, cost = -1)
    @id = id
    @cost = cost
    reset
  end 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 重設
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def reset
    @banner, @name, @description, @client, @location, @objectives, 
      @prime_objectives, @rewards, @level, @common_event_id, @icon_index, 
      @custom_categories = QuestData.quest_data (id)
    @revealed_objectives, @complete_objectives, @failed_objectives = [], [], []
    @reward_given = false
    @concealed = QuestData::MANUAL_REVEAL
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def reveal_objective (*obj)
    for i in obj do obj.delete (i) if i >= @objectives.size end
    @revealed_objectives |= obj # 加入已揭露目標
    @revealed_objectives.sort! # 依目標 ID 由小到大排序
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def complete_objective (*obj)
    for i in obj
      obj.delete (i) if i >= @objectives.size || @failed_objectives.include? (i) 
      reveal_objective (i) unless @revealed_objectives.include? (i)
    end
    @complete_objectives |= obj # 加入已完成目標
    @complete_objectives.sort! # 依目標 ID 由小到大排序
    if complete?
      $game_temp.common_event_id = @common_event_id # 呼叫完成 Common Event
      @common_event_id = 0 # 避免重複呼叫
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def fail_objective (*obj)
    for i in obj
      obj.delete (i) if i >= @objectives.size
      reveal_objective (i) unless @revealed_objectives.include? (i)
    end
    @failed_objectives |= obj # 加入已揭露目標
    @failed_objectives.sort! # 依目標 ID 由小到大排序
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def conceal_objective (*obj)
    obj.each { |index| @revealed_objectives.delete (index) }
  end
  def uncomplete_objective (*obj)
    for i in obj do @complete_objectives.delete (i) end
  end
  def unfail_objective (*obj)
    for i in obj do @failed_objectives.delete (i) end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def objective_revealed? (*obj)
    return (obj - @revealed_objectives).empty?
  end
  def objective_complete? (*obj)
    return (obj - @complete_objectives).empty?
  end
  def objective_failed? (*obj)
    return (obj - @failed_objectives).empty?
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def complete? 
    return (@complete_objectives & @prime_objectives) == @prime_objectives
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def failed? 
    return !(@failed_objectives & @prime_objectives).empty?
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def name= (string)
    @name = string
    $game_party.quests.refresh_sort (:alphabet)
  end
  def level= (value)
    @level = value
    $game_party.quests.refresh_sort (:level)
  end
  def concealed= (value)
    @concealed = value
    value ? $game_party.quests.conceal_quest (id) : $game_party.quests.reveal_quest (id)
  end 
end

#==============================================================================
# ** Game_Quests｜任務集合／排序
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Game_Quests
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize
    @data = {}
    @id_sort = []
    @revealed_sort = []
    @alphabet_sort = []
    @level_sort = []
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #    quest_id：Quest ID
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def [] (quest_id)
    return Game_Quest.new (0) unless quest_id.is_a? (Integer)
    if @data[quest_id] == nil
      @data[quest_id] = Game_Quest.new (quest_id) 
      reveal_quest (quest_id) unless @data[quest_id].concealed
    end
    return @data[quest_id]
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def list
    quest_list = []
    type = $game_system.quest_sort_type.to_s
    reverse = !(type.sub! (/reverse/i) { "" }).nil?
    case type.to_sym
    when :id
      @id_sort.each { |id| quest_list.push (@data[id]) }
    when :revealed
      @revealed_sort.each { |id| quest_list.push (@data[id]) }
    when :alphabet
      @alphabet_sort.each { |id| quest_list.push (@data[id]) }
    when :level
      @level_sort.each { |id| quest_list.push (@data[id]) }
    else
      quest_list = @data.values
    end
    quest_list.each { |i| quest_list.delete (i) if i.concealed }
    return reverse ? quest_list.reverse : quest_list
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def completed_list
    complete_quests = []
    list.each { |i| complete_quests.push (i) if i.complete? }
    return complete_quests
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def failed_list
    failed_quests = []
    list.each { |i| failed_quests.push (i) if i.failed? }
    return failed_quests
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def active_list
    return list - failed_list - completed_list
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def category_list (category)
    case category
    when :all then return list
    when :active then return active_list
    when :complete then return completed_list
    when :failed then return failed_list
    else
      quest_list = []
      list.each { |quest| quest_list.push (quest) if quest.custom_categories.include? (category) }
      return quest_list
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def get_location (quest_id)
    return nil, nil unless @data[quest_id]
    for i in 0...QuestData::CATEGORIES.size
      index = category_list (QuestData::CATEGORIES[i]).index (@data[quest_id])
      return i, index if index != nil
    end
    return nil, nil
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def revealed? (quest_id)
    return !@data[quest_id].nil? && !@data[quest_id].concealed
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def remove (quest_id)
    conceal_quest (quest_id)
    @data.delete (quest_id)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 清除
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def clear
    @data.clear
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def reveal_quest (quest_id)
    return if !@data[quest_id] ||@id_sort.include? (quest_id)
    $game_system.last_quest_id = quest_id
    @revealed_sort.push (quest_id) 
    sorted = false
    for i in 0...@id_sort.size
      if @id_sort[i] > quest_id
        @id_sort.insert (i, quest_id)
        sorted = true
        break
      end
    end
    @id_sort.push (quest_id) unless sorted
    sorted = false
    for i in 0...@alphabet_sort.size
      if @data[@alphabet_sort[i]].name.downcase > @data[quest_id].name.downcase
        @alphabet_sort.insert (i, quest_id)
        sorted = true
        break
      end
    end
    @alphabet_sort.push (quest_id) unless sorted
    sorted = false
    for i in 0...@level_sort.size
      if @data[@level_sort[i]].level > @data[quest_id].level
        @level_sort.insert (i, quest_id)
        sorted = true
        break
      end
    end
    @level_sort.push (quest_id) unless sorted
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def conceal_quest (quest_id)
    [@revealed_sort, @alphabet_sort, @id_sort, @level_sort].each { |ary| ary.delete (quest_id) }
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def refresh_sort (sort_type)
    case sort_type
    when :alphabet
      s = @data.values.sort { |a, b| a.name.downcase <=> b.name.downcase }
      @alphabet_sort.clear
      s.each { |quest| @alphabet_sort.push (quest.id) }
    when :level
      s = @data.values.sort { |a, b| a.level <=> b.level }
      @level_sort.clear
      s.each { |quest| @level_sort.push (quest.id) }
    end
  end
end

#==============================================================================
# ** Game_Temp｜暫存任務資料
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Game_Temp
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 公開實例變數
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_accessor :quest_shop_array
  attr_accessor :quest_shop_name
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias maba_qjrnl_iniz_5uv1 initialize
  def initialize (*args)
    maba_qjrnl_iniz_5uv1 (*args)
    @quest_shop_array = []
    @quest_shop_name = QuestData::VOCAB_PURCHASE
  end
end

#==============================================================================
# ** Game_System｜任務系統設定
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Game_System
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 公開實例變數
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :quest_menuaccess
  attr_accessor :quest_disabled
  attr_accessor :quest_keyaccess
  attr_accessor :quest_sort_type
  attr_accessor :qj_bg_picture
  attr_accessor :qj_bg_opacity
  attr_accessor :qj_windowskin
  attr_accessor :qj_window_opacity
  attr_accessor :last_quest_cat
  attr_accessor :last_quest_id
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias modlg_qstjrnl_iniz_4rd2 initialize
  def initialize (*args)
    modlg_qstjrnl_iniz_4rd2 (*args)
    @quest_menuaccess = QuestData::MENU_ACCESS
    @quest_disabled = false
    @quest_keyaccess = QuestData::KEY_ACCESS
    @quest_sort_type = QuestData::SORT_TYPE
    @qj_bg_picture = QuestData::BG_PICTURE
    @qj_bg_opacity = QuestData::BG_OPACITY
    @qj_windowskin = QuestData::WINDOWS_SKIN
    @qj_window_opacity = QuestData::WINDOWS_OPACITY
    @last_quest_cat = 0
    @last_quest_id = 0
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def quest_menuaccess= (value)
    @quest_menuaccess = value
    @fscms_command_list ? c = @fscms_command_list : (@tpcms_command_list ? c = @tpcms_command_list : return)
    value ? (c.insert (QuestData::MENU_INDEX, :quest2) unless c.include? (:quest2)) : 
      c.delete (:quest2)
  end
end

#==============================================================================
# ** Game_Party｜任務資料持有者
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Game_Party
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 公開實例變數
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  attr_reader   :quests
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias modalg_qst_jrnl_party_init_quests initialize
  def initialize
    modalg_qst_jrnl_party_init_quests
    @quests = Game_Quests.new
  end
end

#==============================================================================
# ** Game_Interpreter｜訊息／選項／ATS Script Call
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Game_Interpreter
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def call_quest (quest_id = 0)
    Sound.play_decision
    $game_system.last_quest_id = quest_id if quest_id != 0 && quest_revealed? (quest_id)
    $game_temp.next_scene = "quest"
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def call_quest_shop (quest_array, shop_name = QuestData::VOCAB_PURCHASE)
    $game_temp.next_scene = "quest shop"
    $game_temp.quest_shop_array = quest_array
    $game_temp.quest_shop_name = shop_name
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def change_quest_access (sym)
    case sym
    when :enable then $game_system.quest_disabled = false
    when :disable then $game_system.quest_disabled = true
    when :enable_menu then $game_system.quest_menuaccess = true 
    when :disable_menu then $game_system.quest_menuaccess = false 
    when :enable_map then $game_system.quest_keyaccess = true 
    when :disable_map then $game_system.quest_keyaccess = false 
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def change_quest_background (picture, opacity = $game_system.qj_bg_opacity)
    $game_system.qj_bg_picture = picture
    $game_system.qj_bg_opacity = opacity
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def change_quest_windows (skin, opacity = $game_system.qj_window_opacity)
    $game_system.qj_windowskin = skin
    $game_system.qj_window_opacity = opacity
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def reset_quest (id)
    quest (id).reset
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def remove_quest (id)
    $game_party.quests.remove (id)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def reveal_quest (id)
    $game_party.quests[id].concealed = false
  end
  def conceal_quest (id)
    $game_party.quests[id].concealed = true
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def quest (id)
    return $game_party.quests[id]
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def quest_revealed? (id)
    return $game_party.quests.revealed? (id)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  [:reveal_objective, :conceal_objective, :complete_objective,
   :uncomplete_objective, :fail_objective, :unfail_objective].each { |method|
    define_method (method) { |id, *obj| quest (id).send (method, *obj) } 
  }
  [:objective_revealed?, :objective_complete?, :objective_failed?].each { |method|
    define_method (method) { |id, *obj| quest_revealed? (id) && quest (id).send (method, *obj) }
  }
  [:reset, :complete?, :rewarded?, :failed?].each { |method|
    define_method ("quest_#{method}".to_sym) { |id| quest_revealed? (id) && quest (id).send (method) } 
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def give_quest_reward (quest_id)
    return false if !quest_complete? (quest_id) || quest_rewarded? (quest_id)
    params = @params.dup
    (quest (quest_id)).rewards.each { |reward|
      next unless reward.is_a? (Array)
      @params = [reward[1], 0, 0, (reward[2] ? reward[2] : 1)]
      case reward[0]
      when 0 then command_126 # 物品
      when 1 then command_127 # 武器
      when 2 then command_128 # 防具
      when 3
        @params = [0, 0, reward[1]]
        command_125
      when 4
        @params = [0, 0, 0, reward[1], true]
        command_315
      end
    }
    @params = params
    change_reward_status (quest_id, true)
    return true
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def change_reward_status (id, value = true)
    quest (id).reward_given = value
  end
end

#==============================================================================
# ** Window_Base｜任務文字／圖示繪製
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 文字顏色
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malbr_questj2_txtcol_5rf1 text_color
  def text_color (color, *args)
    return ( color.is_a? (Array) ? Color.new (*color) :  malbr_questj2_txtcol_5rf1 (color, *args) )
  end
end

#==============================================================================
# ** Window_Message｜主訊息視窗
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Window_Message
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 轉換特殊控制碼
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_qstjrnl_cnvrtspecnq_6yh2 convert_special_characters
  def convert_special_characters (*args)
    ma_qstjrnl_cnvrtspecnq_6yh2 (*args)
    @text.gsub! (/\\NQ\[(\d+)\]/i) { $game_party.quests[$1.to_i].name }
  end
end

if Object.const_defined? (:Paragrapher) && Paragrapher.const_defined? (:Formatter_SpecialCodes)
  class Paragrapher::Formatter_SpecialCodes
    alias mlg_qstj_prfrmsub_5th2 perform_substitution
    def perform_substitution (*args)
      text = mlg_qstj_prfrmsub_5th2 (*args)
      text.gsub! (/\\NQ\[(\d+)\]/i) { $game_party.quests[$1.to_i].name }
      return text
    end
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Window_QuestLabel < Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (width = QuestData::LIST_WIDTH, height = 32 + WLH, text = QuestData::VOCAB_QUESTS)
    super (0, 0, width, height)
    self.windowskin = Cache.system ($game_system.qj_windowskin)
    self.opacity = $game_system.qj_window_opacity
    self.contents.font.name = QuestData::LABEL_FONTNAME unless QuestData::LABEL_FONTNAME.empty?
    if QuestData::LABEL_FONTSIZE == 0
      self.contents.font.size = [height - 36, 28].min
      while (contents.text_size (text).width > contents.width) && contents.font.size > Font.default_size
        contents.font.size -= 1
      end
    else
      contents.font.size = QuestData::LABEL_FONTSIZE
    end
    self.contents.font.bold = QuestData::LABEL_BOLD
    self.contents.font.color = text_color (QuestData::COLOURS[:label])
    self.contents.draw_text (contents.rect, text, 1)
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Window_QuestPurchaseGold < Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (y, width = QuestData::PURCHASE_LIST_WIDTH)
    super (0, y, width, 32 + WLH)
    self.windowskin = Cache.system ($game_system.qj_windowskin)
    self.opacity = $game_system.qj_window_opacity
    refresh
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 重新整理
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def refresh
    self.contents.clear
    if QuestData::PURCHASE_USE_GOLD_ICON
      draw_icon (QuestData::ICONS[:gold], 0, 0)
      x = 28
    else
      x = 4
    end
    draw_currency_value ($game_party.gold, x, 0, contents.width - x)
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Window_QuestCategory < Window_Base 
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (category_index = 0, width = QuestData::LIST_WIDTH)
    hght = 56 
    @all_index = QuestData::CATEGORIES.index (:all)
    hght += 8
    super (0, WLH + 32, width, hght)
    self.windowskin = Cache.system ($game_system.qj_windowskin)
    self.opacity = $game_system.qj_window_opacity
    total = 24*QuestData::CATEGORIES.size
    total += 16 if hght == 64
    @spacing = (contents.width - total) / (QuestData::CATEGORIES.size - 1)
    refresh (category_index)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 重新整理
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def refresh (category_index = 0)
    contents.clear
    for i in 0...QuestData::CATEGORIES.size
      draw_item (i, i == category_index)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_item (index, enabled = false)
    x = index*(12 + @spacing) + 20
    #x = index*(24 + @spacing)
    x += 16 if @all_index && index > @all_index && contents.height == 32
    category = QuestData::CATEGORIES[index]
    if @all_index != index || contents.height == 24
      y = (contents.height == 32 ? 4 : 0)
      self.contents.clear_rect (x, y, 24, 24)
      draw_icon (QuestData::ICONS[category], x, y, enabled)
    else
      self.contents.clear_rect (x, 0, 40, 32)
      draw_icon (QuestData::ICONS[:complete], x, 0, enabled)
      draw_icon (QuestData::ICONS[:failed], x + 16, 0, enabled)
      draw_icon (QuestData::ICONS[:active], x + 8, 8, enabled)
    end
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Window_QuestList < Window_Command
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (free, width = QuestData::LIST_WIDTH, category = QuestData::CATEGORIES[0], quest_index = 0)
    super (width, [], 1, free / WLH)
    change_list (category)
    self.windowskin = Cache.system ($game_system.qj_windowskin)
    self.opacity = $game_system.qj_window_opacity
    self.index = quest_index
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def change_list (list_type)
    if list_type.is_a? (Array)
      @commands = list_type
    else
      @commands = $game_party.quests.category_list (list_type)
      @commands = [] if @commands.nil?
    end
    @item_max = @commands.size####跳窗
    self.contents = Bitmap.new (contents.width, [self.height - 32, @item_max*WLH].max)
    self.index = 0
    refresh
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def quest
    return @commands[self.index]
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    self.contents.font.color.alpha = (enabled ? 255 : 128)
    quest = @commands[index]
    draw_icon (quest.icon_index, rect.x, rect.y, enabled)
    rect.x += 28
    rect.width -= 28
    if quest.cost > -1
      self.contents.font.color = text_color (QuestData::COLOURS[:active])
      self.contents.draw_text (rect, quest.cost.to_s, 2)
      rect.width -= (self.contents.text_size (quest.cost.to_s).width + 6)
    else
      self.contents.font.color = text_color (quest.complete? ? 
        QuestData::COLOURS[:complete] : (quest.failed? ? 
        QuestData::COLOURS[:failed] : QuestData::COLOURS[:active])) 
    end
    self.contents.draw_text(rect, quest.name)
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Window_QuestInfo < Window_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (height = Graphics.height - (32 + WLH), x = QuestData::LIST_WIDTH, layout = QuestData::INFO_LAYOUT)
    super (x, 0, Graphics.width - x, height)
    @layout = layout
    self.windowskin = Cache.system ($game_system.qj_windowskin)
    self.opacity = $game_system.qj_window_opacity
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 重新整理
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def refresh (quest)
    contents.clear
    if quest.nil?
      create_contents
      return
    end
    @quest = quest
    if !Object.const_defined? (:Paragrapher) || !Paragrapher.const_defined? (:Formatter)
      p "This script requires the Paragraph Formatter 2.0! You can get it at RMRK:", 
      "    http://rmrk.net/index.php/topic,25129.0.html", "The Special Codes Formatter is supported, but you still need the base script."
    else
      if Paragrapher.const_defined? (:Formatter_SpecialCodes)
        @paragrapher = Paragrapher.new (Paragrapher::Formatter_SpecialCodes.new, Paragrapher::Artist_SpecialCodes.new)
      else
        @paragrapher = Paragrapher.new (contents.paragraph_formatter, contents.paragraph_artist)
      end
    end
    h = 0
    set_font (0)
    for subtitle in @layout
      sub = subtitle.is_a? (Array) ? subtitle[0] : subtitle
      h += calculate_height_req (sub)
    end
    self.contents = Bitmap.new (contents.width, [h, self.height - 32].max) 
    y = 0
    for subtitle in @layout
      if subtitle.is_a? (Array)
        max_y = y
        for i in subtitle 
          y_plus = draw_section (i, y)
          max_y = y_plus if y_plus > max_y
        end
        y = max_y
      else
        y = draw_section (subtitle, y) 
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def calculate_height_req (section)
    case section
    when :banner then return Cache.picture (@quest.banner).height unless @quest.banner.empty?
    when :name then return WLH unless @quest.name.empty?
    when :level then return WLH unless @quest.level <= 0
    when :client then return WLH unless @quest.client.empty?
    when :location then return WLH unless @quest.location.empty?
    when :description
      if @paragrapher && !@quest.description.empty?
        bmp = Bitmap.new (contents.width - 16, WLH)
        bmp.font = contents.font.dup
        bmp.font.size = QuestData::DESC_FONTSIZE
        @desc_ft = @paragrapher.formatter.format (@quest.description, bmp)
        return (@desc_ft.lines.size*bmp.font.size) + ((3*WLH) / 2) + 4
      end
    when :objectives
      if @paragrapher && !@quest.revealed_objectives.empty?
        tw = self.contents.text_size (QuestData::OBJECTIVE_BULLET).width
        bmp = Bitmap.new (contents.width - 12 - tw, WLH)
        bmp.font = contents.font.dup
        bmp.font.size = QuestData::OBJ_FONTSIZE
        h = 0
        @objs_ft = []
        for i in @quest.revealed_objectives
             ft = @paragrapher.formatter.format (@quest.objectives[i].dup, bmp)
          h += (ft.lines.size * bmp.font.size) + 2
          @objs_ft.push (ft)
        end
        return h + 2
      end
    when :rewards then return WLH*(@quest.rewards.size + 1) unless @quest.rewards.empty?
    end
    return 0
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_section (section, y)
    set_font (0)
    case section
    when :banner then y = draw_banner (y)
    when :name then y = draw_name (y)
    when :level then y = draw_level (y)
    when :client then y = draw_client (y)
    when :location then y = draw_location (y)
    when :description then y = draw_description (y) - 30
    when :objectives then y = draw_objectives (y) + 15
    when :rewards then y = draw_rewards (y)###間距離
    end
    return y
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_banner (y)
    return y if @quest.banner.empty?
    banner = Cache.picture (@quest.banner)
    self.contents.blt ((contents.width - banner.width) / 2, y, banner, banner.rect)
    return y + banner.height
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_name (y)
    return y if @quest.name.empty?
    self.contents.font.name = QuestData::NAME_FONTNAME.empty? ? Font.default_name : QuestData::NAME_FONTNAME
    self.contents.font.size = QuestData::NAME_FONTSIZE == 0 ? Font.default_size : QuestData::NAME_FONTSIZE 
    self.contents.font.bold = QuestData::NAME_BOLD
    self.contents.font.color = text_color (@quest.complete? ? 
      QuestData::COLOURS[:complete] : (@quest.failed? ? 
      QuestData::COLOURS[:failed] : QuestData::COLOURS[:active])) 
    self.contents.draw_text (0, y, self.contents.width, WLH, @quest.name, 1)
    return y + WLH
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_level (y)
    return y if @quest.level < 1
    if QuestData::ICONS[:level] != 0
      x = self.contents.width - 24
      @quest.level.times do 
        draw_icon (QuestData::ICONS[:level], x, y)
        x -= QuestData::LEVEL_SPACE
      end
    else
      set_font (1)
      self.contents.draw_text (0, y, contents.width, WLH, @quest.level.to_s, 2)
    end
    return y + WLH
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_client (y)
    return y if @quest.client.empty?
    x = 0
    if QuestData::ICONS[:client] != 0
      draw_icon (QuestData::ICONS[:client], x, y)
      x += 28
    end
    if !QuestData::VOCAB_CLIENT.empty?
      set_font (1)
      self.contents.draw_text (x, y, 80, WLH, QuestData::VOCAB_CLIENT)
      x += 80
    end
    set_font (0)
    wdth = QuestData::CLIENT_WIDTH == 0 ? (contents.width - ((5*QuestData::LEVEL_SPACE) + 8)) : QuestData::CLIENT_WIDTH
    self.contents.draw_text (x, y, wdth -  x, WLH, @quest.client, 2)
    return y + WLH
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_location (y)
    return y if @quest.location.empty?
    x = 0
    if QuestData::ICONS[:location] != 0
      draw_icon (QuestData::ICONS[:location], x, y)
      x += 28
    end
    if !QuestData::VOCAB_LOCATION.empty?
      set_font (1)
      self.contents.draw_text (x, y, 80, WLH, QuestData::VOCAB_LOCATION)
      x += 80
    end
    set_font (0)
    wdth = QuestData::LOCATION_WIDTH == 0 ? (contents.width - ((5*QuestData::LEVEL_SPACE) + 8)) : QuestData::LOCATION_WIDTH
    self.contents.draw_text (x, y, wdth - x, WLH, @quest.location, 2)
    return y + WLH
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_description (y)
    return y if !@paragrapher || @quest.description.empty?
    hght = @desc_ft.lines.size * @desc_ft.bitmap.font.size
    font = @desc_ft.bitmap.font.dup
    @desc_ft.bitmap.dispose
    @desc_ft.bitmap = Bitmap.new (self.contents.width, hght)
    @desc_ft.bitmap.font = font
    set_font (1)
    rect = Rect.new (2, y + (WLH / 2), self.contents.width - 4, hght + WLH)
    rect2 = Rect.new (4, y + (WLH / 2) + 2, self.contents.width - 8, hght + WLH - 4)
    # 65 117 120
    if Bitmap.method_defined? (:fill_rounded_rect)
      #self.contents.fill_rounded_rect (rect, self.contents.font.color)
      self.contents.fill_rounded_rect (rect, Color.new (65, 117, 120))
      self.contents.fill_rounded_rect (rect2, Color.new (0, 0, 0, 88))
    else
      self.contents.fill_rect (rect, self.contents.font.color)
      self.contents.clear_rect (rect2)
    end
     #tw = self.contents.text_size (QuestData::VOCAB_DESCRIPTION).width
     #self.contents.clear_rect (32, y, tw + 4, WLH)
    #self.contents.font.color = Color.new (65, 117, 120)###
     #self.contents.draw_text (34, y, tw + 2, WLH, QuestData::VOCAB_DESCRIPTION)
     #set_font (0)
    @paragrapher.artist.draw (@desc_ft, QuestData::JUSTIFY_PARAGRAPHS)
    self.contents.blt (8, y + WLH, @desc_ft.bitmap, @desc_ft.bitmap.rect)
    @desc_ft.bitmap.dispose
    @desc_ft = nil
    return rect.y + rect.height + 4
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_objectives (y)
    return y if !@paragrapher || @quest.revealed_objectives.empty?
    set_font (1)
    self.contents.draw_text (32, y, contents.width - 32, WLH, QuestData::VOCAB_OBJECTIVES)
    tw = self.contents.text_size (QuestData::OBJECTIVE_BULLET).width
    y += WLH
    bmp = @objs_ft[0].bitmap
    for i in 0...@quest.revealed_objectives.size
      set_font (1)
      self.contents.draw_text (8, y, tw, WLH, QuestData::OBJECTIVE_BULLET)
      set_font (0)
      ft = @objs_ft[i]
      ft.bitmap = Bitmap.new (contents.width, ft.lines.size*bmp.font.size)
      ft.bitmap.font = bmp.font.dup
      obj = @quest.revealed_objectives[i]
      ft.bitmap.font.color = text_color (@quest.objective_complete? (obj) ? 
        QuestData::COLOURS[:complete] : (@quest.objective_failed? (obj) ? 
        QuestData::COLOURS[:failed] : QuestData::COLOURS[:active])) 
      @paragrapher.artist.draw (ft, QuestData::JUSTIFY_PARAGRAPHS)
      self.contents.blt (12 + tw, y + 2, ft.bitmap, ft.bitmap.rect)
      y += 2 + ((ft.bitmap.font.size)*ft.lines.size) - 5 - 5###
      ft.bitmap.dispose
    end
    bmp.dispose
    @objs_ft.clear
    return y + 2###
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def draw_rewards (y)
    return y if @quest.rewards.empty?
    y += 25 if $scene.is_a?(Scene_QuestPurchase)
    set_font (1)
    self.contents.draw_text (32, y, contents.width - 32, WLH, QuestData::VOCAB_REWARDS)
    x = QuestData::REWARD_BULLET.empty? ? 8 : 12 + (contents.text_size (QuestData::REWARD_BULLET).width)
    y += WLH
    for reward in @quest.rewards
      set_font (1)
      self.contents.draw_text (8, y, 100, WLH, QuestData::REWARD_BULLET)
      set_font (0)
      self.contents.font.size = QuestData::REWARD_FONTSIZE
      if reward.is_a? (Array)
        item = nil
        case reward[0]
        when 0 then item = $data_items[reward[1]]
        when 1 then item = $data_weapons[reward[1]]
        when 2 then item = $data_armors[reward[1]]
        when 3
          draw_icon (QuestData::ICONS[:gold], x, y)
          self.contents.font.color = normal_color
          self.contents.draw_text (x + 24, y, contents.width - x - 24, WLH, reward[1].to_s)
          if QuestData::DRAW_VOCAB_GOLD
            tw = self.contents.text_size(reward[1].to_s).width
            self.contents.font.color = system_color
            self.contents.draw_text(x + tw + 28, y, contents.width - x - 28 - tw, WLH, Vocab::gold)
          end
        when 4
          draw_icon (QuestData::ICONS[:exp], x, y)
          self.contents.font.color = normal_color
          self.contents.draw_text (x + 24, y, contents.width - x - 24, WLH, reward[1].to_s)
          tw = self.contents.text_size(reward[1].to_s).width
          self.contents.font.color = system_color
          self.contents.draw_text(x + tw + 28, y, contents.width - x - 28 - tw, WLH, QuestData::VOCAB_EXP)
        end
        if item != nil
          draw_item_name (item, x, y)
          unless reward[2].nil?
            contents.font.color = system_color
            tw = contents.text_size (item.name).width + 28
            contents.draw_text (x + tw, y, 100, WLH, "#{QuestData::ITEM_NUMBER_PREFACE}#{reward[2]}")
          end
        end
      else
        set_font (0)
        if Object.const_defined? (:Paragrapher) && Paragrapher.const_defined? (:Formatter_SpecialCodes)
          bmp = Bitmap.new (contents.width - x, WLH)
          bmp.font = contents.font.dup
          bmp.font.size = QuestData::REWARD_FONTSIZE
          @paragrapher.paragraph (reward, bmp)
          self.contents.blt (x, y, bmp, bmp.rect)
          bmp.dispose
        else
          self.contents.draw_text (x, y, contents.width - x, WLH, reward)
        end
      end
      y += WLH
    end
    return y
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def set_font (type = 0)
    case type
    when 0
      self.contents.font.name = QuestData::CONTENT_FONTNAME.empty? ? Font.default_name : QuestData::CONTENT_FONTNAME
      self.contents.font.size = Font.default_size
      self.contents.font.bold = false
      self.contents.font.color = normal_color
    when 1
      self.contents.font.name = QuestData::SUBTITLE_FONTNAME.empty? ? Font.default_name : QuestData::SUBTITLE_FONTNAME
      self.contents.font.size = QuestData::SUBTITLE_FONTSIZE == 0 ? Font.default_size : QuestData::SUBTITLE_FONTSIZE
      self.contents.font.bold = QuestData::SUBTITLE_BOLD
      self.contents.font.color = system_color
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def normal_color
    return text_color (QuestData::COLOURS[:content])
  end
  def system_color
    return text_color (QuestData::COLOURS[:subtitle])
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update
    if Input.press? (Input::DOWN)
      self.oy = [self.oy + 3, contents.height - self.height + 32].min
    elsif Input.press? (Input::UP)
      self.oy = [self.oy - 3, 0].max
    end
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

  class Scene_Map < Scene_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias ma_qj2_keyaces_upd_6yc1 update
  def update (*args)
    ma_qj2_keyaces_upd_6yc1 (*args)
    if $game_system.quest_keyaccess && Input.trigger? (QuestData::MAPKEY_BUTTON)
      if $game_system.quest_disabled || $game_party.quests.list.empty?
        Sound.play_buzzer
      else
        Sound.play_decision
        $game_temp.next_scene = "quest"
      end
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias malb_questj_updscene_5tg2 update_scene_change
  def update_scene_change (*args)
    scene_call = $game_temp.next_scene
    malb_questj_updscene_5tg2 (*args)
    if $game_temp.next_scene.nil? && !scene_call.nil?
      case scene_call 
      when "quest"
        $scene = Scene_Quest.new
      when "quest shop"
        $scene = Scene_QuestPurchase.new ($game_temp.quest_shop_array, $game_temp.quest_shop_name)
      end
    end
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Scene_Quest < Scene_Base
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (*args)
    if args.size == 0
      cat_ind = $game_system.last_quest_cat
      cat = QuestData::CATEGORIES[cat_ind]
      ind = ($game_party.quests.category_list (cat)).index ($game_party.quests[$game_system.last_quest_id])
      if !ind.nil?
        @category_index, @quest_index = cat_ind, ind
      else
        @category_index, @quest_index = $game_party.quests.get_location ($game_system.last_quest_id)
      end
    else
      @category_index = args[0] < QuestData::CATEGORIES.size ? args[0] : 0
      @quest_index = args[1]
    end
    @category_index = 0 if @category_index.nil?
    @quest_index = 0 if @quest_index.nil?
    @info_window_active = false
    @from_menu = $scene.is_a? (Scene_Menu)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def start
    super
    create_menu_background
    unless $game_system.qj_bg_picture.empty?
      @bg_sprite = Sprite.new
      @bg_sprite.bitmap = Cache.picture ($game_system.qj_bg_picture)
      @bg_sprite.opacity = $game_system.qj_bg_opacity
    end
    free_space = Graphics.height - 96 - 2*Window_Base::WLH
    if QuestData::CATEGORIES.size > 1
      @category_window = Window_QuestCategory.new (@category_index)
      free_space -= @category_window.height
    end
    @label_window = Window_QuestLabel.new (QuestData::LIST_WIDTH, 32 + Window_Base::WLH + (free_space % Window_Base::WLH))
    y = @label_window.height 
    if @category_window
      @category_window.y = y
      y += @category_window.height
    end
    @category_window.x += 2
    @category_window.y += 10 + 47
    @list_window = Window_QuestList.new (free_space, QuestData::LIST_WIDTH, QuestData::CATEGORIES[@category_index], @quest_index)
    @list_window.y = y
    @list_window.x += 2
    @list_window.y += 4 + 47
    @list_window.active = true
    @info_window = Window_QuestInfo.new
    @info_window.y += 52
    @info_window.x -= 4
    @info_window.refresh (@list_window.quest)
    @help_window = Window_Help.new
    @help_window.windowskin = Cache.system ($game_system.qj_windowskin)
    @help_window.opacity = $game_system.qj_window_opacity
    @help_window.x = -165
    @help_window.y = Graphics.height - @help_window.height - 4 - 313
    @help_window.width = Graphics.width
    @help_window.create_contents
    @help_window.contents.font.size = 17
    @help_window.set_text (QuestData::VOCAB_HELP_GENERAL, QuestData::HELP_ALIGNMENT)
    ####################
    @as = Sprite.new
    @as.x = 68
    @as.y = 68 + 47
    @as.ox = @as.width
    @as.oy = @as.height
    @as.z = 9999
    @com_count = 11
    
    @light = Sprite.new
		@light.bitmap = Cache.picture("le.png")
		@light.visible = true
    @light.x = 407
    @light.y = -20
    @light.zoom_x = 200 / 100.0
    @light.zoom_y = 200 / 100.0
    @light.opacity = 100
    @light.tone = Tone.new(255,-100,-255, 0)
    @light.blend_type = 1
		@light.z = 1000
    
    @light2 = Sprite.new
		@light2.bitmap = Cache.picture("le.png")
		@light2.visible = true
    @light2.x = 34
    @light2.y = 100 + 47
    @light2.zoom_x = 50 / 100.0
    @light2.zoom_y = 50 / 100.0
    @light2.opacity = 190
    @light2.tone = Tone.new(200,200,100, 100)
    @light2.blend_type = 1
    
    @js_flame = 0
    @js = Sprite.new
    @js.x = 90
    @js.y = 36 +47
    @js.ox = @as.width
    @js.oy = @as.height
    @js.z = 9999
    
    fireflies(4)
    #################### 
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def terminate
    super
    dispose_menu_background
    if @bg_sprite
      @bg_sprite.bitmap.dispose
      @bg_sprite.dispose
    end
    @label_window.dispose
    @category_window.dispose if @category_window
    @list_window.dispose
    @info_window.dispose
    @help_window.dispose
    ##########
    @as.dispose
    @light.dispose
    @light2.dispose
    @js.dispose
    fireflies(0)
    ##########
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update
    super
    update_menu_background
    if @list_window.active
      update_list_window
    elsif @info_window_active
      update_info_window
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_list_window
    @list_window.update
    update_category_window if @category_window
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger? (Input::C)
      action_pressed_from_list
    elsif Input.press? (Input::DOWN) || Input.press? (Input::UP)
      @info_window.refresh (@list_window.quest)
    end
    ################################
    @light.opacity = rand(20) + 90
    @light.x = 407 + rand(3) - 3
    @light.y = -20 + rand(3) - 3
    
    @light2.opacity = rand(20) + 190
    ################################
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_category_window
    if (Input.trigger? (Input::LEFT) || Input.trigger? (Input::RIGHT)) 
      add_int = Input.trigger? (Input::LEFT) ? -1 : 1###
      @category_index = (@category_index + add_int) % QuestData::CATEGORIES.size
      Sound.play_cursor
      @category_window.refresh (@category_index)
      @list_window.change_list (QuestData::CATEGORIES[@category_index])
      @info_window.refresh (@list_window.quest)
    end
    ###########################
    @com_count = 0 if Input.trigger?(Input::RIGHT)
    @com_count = 0 if Input.trigger?(Input::LEFT)
    @as.bitmap = Cache.menu("Quest01") if @category_index == 0
    @as.bitmap = Cache.menu("Quest02") if @category_index == 1
    @as.bitmap = Cache.menu("Quest03") if @category_index == 2
    if @com_count <= 10
      @as.x += 3 if @com_count == 8
      @as.x -= 3 if @com_count == 5
      @as.x += 3 if @com_count == 2
      @as.x -= 3 if @com_count == 0
      @com_count +=1
    end
    @light2.x = 34 if @category_index == 0
    @light2.x = 91 if @category_index == 1
    @light2.x = 148 if @category_index == 2
    
    @js_flame = 0 if Input.trigger?(Input::RIGHT)
    @js_flame = 0 if Input.trigger?(Input::LEFT)
    @js.bitmap = Cache.character("$actor01_1") if @category_index == 0
    @js.bitmap = Cache.character("$actor01_5") if @category_index == 1
    @js.bitmap = Cache.character("$actor01_7") if @category_index == 2
    
    if @js_flame <= 60
       @js_flame = 0 if @js_flame == 60
       @js.src_rect.set(0,  0, 32, 32) if @js_flame == 45
       @js.src_rect.set(32,  0, 32, 32) if @js_flame == 30
       @js.src_rect.set(64,  0, 32, 32) if @js_flame == 15
       @js.src_rect.set(32,  0, 32, 32) if @js_flame == 0
      @js_flame += 1
      end
    ###########################
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_info_window
    @info_window.update
    if Input.trigger? (Input::B) || Input.trigger? (Input::C)
      Sound.play_cancel
      @info_window_active = false
      @info_window.oy = 0
      @list_window.active = true
      @help_window.set_text (QuestData::VOCAB_HELP_GENERAL, QuestData::HELP_ALIGNMENT)
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def action_pressed_from_list
    if @info_window.contents.height > @info_window.height - 32
      Sound.play_decision
      @info_window_active = true
      @list_window.active = false
      @help_window.set_text (QuestData::VOCAB_HELP_SELECTED, QuestData::HELP_ALIGNMENT)
    else
      Sound.play_buzzer
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def return_scene
    unless @list_window.quest.nil?
      $game_system.last_quest_id = @list_window.quest.id 
      $game_system.last_quest_cat = @category_index
    end
    $scene = @from_menu ? Scene_Menu.new (QuestData::MENU_INDEX) : Scene_Map.new
  end
end

#==============================================================================
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#==============================================================================

class Scene_QuestPurchase < Scene_Quest
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * 物件初始化
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def initialize (quest_array = [], shop_name = QuestData::VOCAB_PURCHASE)
    @quest_list, @quest_reveals = [], []
    quest_array.each { |quest_a|
      quest = Game_Quest.new (quest_a[0], (quest_a[1] ? quest_a[1] : -1))
      if quest_a[3] 
        reveals = quest_a[2]
        switch = quest_a[3]
      else
        if quest_a[2].is_a? (Array)
          reveals = quest_a[2]
          switch = nil
        else
          reveals = []
          quest.objectives.each_index { |i| reveals.push (i) }
          switch = quest_a[2]
        end
      end
      if (switch.nil? || $game_switches[switch]) && !$game_party.quests.revealed? (quest_a[0])
        quest.reveal_objective (*reveals)
        @quest_list.push (quest)
        @quest_reveals.push (reveals)
      end
    }
    @shop_name = shop_name
    @info_window_active = false
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def start
    create_menu_background
    unless $game_system.qj_bg_picture.empty?
      @bg_sprite = Sprite.new
      @bg_sprite.bitmap = Cache.picture ("qbg")
      @bg_sprite.opacity = $game_system.qj_bg_opacity
    end
    wlh = Window_Base::WLH
    fs = Graphics.height - (96 + 2*wlh)
    @label_window = Window_QuestLabel.new (QuestData::PURCHASE_LIST_WIDTH, 32 + wlh + (fs % 24), @shop_name)
    @list_window = Window_QuestList.new (fs, QuestData::PURCHASE_LIST_WIDTH, @quest_list)
    @list_window.y = @label_window.height 
    @list_window.active = true
    for i in 0...@quest_list.size
      @list_window.draw_item (i, false) if $game_party.gold < @quest_list[i].cost
    end
    @info_window = Window_QuestInfo.new (Graphics.height, QuestData::PURCHASE_LIST_WIDTH, QuestData::PURCHASE_INFO_LAYOUT)
    @info_window.refresh (@list_window.quest)
    @gold_window = Window_QuestPurchaseGold.new (@list_window.y + @list_window.height)
    #################
    @light = Sprite.new
		@light.bitmap = Cache.picture("le.png")
		@light.visible = false
    @light.x = 407
    @light.y = -20
    @light.zoom_x = 200 / 100.0
    @light.zoom_y = 200 / 100.0
    @light.opacity = 100
    @light.tone = Tone.new(255,-100,-255, 0)
    @light.blend_type = 1
		@light.z = 1000
    
    @light2 = Sprite.new
		@light2.bitmap = Cache.picture("le.png")
		@light2.visible = false
    #################
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def terminate
    dispose_menu_background
    if @bg_sprite
      @bg_sprite.bitmap.dispose
      @bg_sprite.dispose
    end
    @label_window.dispose
    @list_window.dispose
    @info_window.dispose
    @gold_window.dispose
    @light.dispose
    @light2.dispose
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def update_info_window
    @info_window.update
    if Input.trigger? (Input::B)
      Sound.play_cancel
      @info_window_active = false
      @info_window.oy = 0
      @list_window.active = true
    elsif Input.trigger? (Input::C)
      purchase_quest 
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def action_pressed_from_list
    if @info_window.contents.height > @info_window.height - 32
      Sound.play_decision
      @info_window_active = true
      @list_window.active = false
    else
      purchase_quest
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def purchase_quest
    if @list_window.quest.nil? || $game_party.gold < @list_window.quest.cost
      Sound.play_buzzer
    else
      (RPG::SE.new (*QuestData::PURCHASE_SE)).play
      $game_party.lose_gold (@list_window.quest.cost) unless @list_window.quest.cost < 0
      quest = $game_party.quests[@list_window.quest.id]
      $game_party.quests.reveal_quest (@list_window.quest.id)
      quest.reveal_objective (*@quest_reveals[@list_window.index])
      quest.concealed = false
      @quest_list.delete_at (@list_window.index)
      @quest_reveals.delete_at (@list_window.index)
      @list_window.change_list (@quest_list)
      for i in 0...@quest_list.size
        @list_window.draw_item (i, false) if $game_party.gold < @quest_list[i].cost
      end
      @info_window.refresh (@list_window.quest)
      @gold_window.refresh
    end
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  def return_scene
    $scene = Scene_Map.new
  end
end

if $imported && $imported["MainMenuMelody"]
  YEM::MENU::MENU_COMMANDS.insert (QuestData::MENU_INDEX, :quest2)
  YEM::MENU::MENU_ICONS[:quest2] = QuestData::ICONS[:menu]
  YEM::MENU::IMPORTED_COMMANDS[:quest2] = [:quest_access, :quest_disable, false, QuestData::ICONS[:menu], QuestData::VOCAB_QUESTS, "Scene_Quest"]
  
  class Game_Switches
    alias ma_yemmm_qustjrn_get_6yh1 []
    def [] (id, *args)
      return $game_system.quest_disabled || $game_party.quests.list.empty? if id == :quest_disable
      return !$game_system.quest_menuaccess if id == :quest_access
      return ma_yemmm_qustjrn_get_6yh1 (id, *args)
    end
  end
elsif Game_System.method_defined? (:fscms_command_list)
  ModernAlgebra::FSCMS_CUSTOM_COMMANDS[:quest2] = [QuestData::VOCAB_QUESTS, 
    QuestData::ICONS[:menu], "$game_system.quest_disabled || $game_party.quests.list.empty?", 
    false, Scene_Quest]
  ModernAlgebra::FSCMS_COMMANDLIST.insert (QuestData::MENU_INDEX, :quest2) if QuestData::MENU_ACCESS
elsif Game_System.method_defined? (:tpcms_command_list)
  Phantasia_CMS::CUSTOM_COMMANDS[:quest2] = [QuestData::VOCAB_QUESTS, 
    QuestData::ICONS[:menu], "$game_system.quest_disabled || $game_party.quests.list.empty?", 
    false, Scene_Quest]
  Phantasia_CMS::COMMANDLIST.insert (QuestData::MENU_INDEX, :quest2) if QuestData::MENU_ACCESS
else
  if Object.const_defined? (:Custom_Commands) 
    Custom_Commands::Icons[QuestData::VOCAB_QUESTS] = QuestData::ICONS[:menu]
  end
  #============================================================================
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #============================================================================
  unless Window_Command.method_defined? (:ma_disabled_commands)
    class Window_Command
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # * 公開實例變數
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      attr_reader :ma_disabled_commands
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      alias malg_quest2_initz_6tg2 initialize
      def initialize (*args)
        @ma_disabled_commands = []
        malg_quest2_initz_6tg2 (*args)
      end
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      alias mab_qstj_itmdraw_8ic4 draw_item
      def draw_item (index, enabled = true, *args)
        mab_qstj_itmdraw_8ic4 (index, enabled, *args)
        enabled ? @ma_disabled_commands.delete (index) : 
          (@ma_disabled_commands.push (index) if !@ma_disabled_commands.include? (index))
      end
    end
  end
  #============================================================================
  # ** 選單場景
  #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  #============================================================================
  
  class Scene_Menu
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # * 物件初始化
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias magba_questj_ini_5rc1 initialize
    def initialize (menu_index = 0, *args)
      magba_questj_ini_5rc1 (menu_index, *args)
      if $game_system.quest_menuaccess 
        $scene.is_a? (Scene_Quest) ? @menu_index = QuestData::MENU_INDEX : (@menu_index += 1 if @menu_index >= QuestData::MENU_INDEX)
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias modrn_qusjrnl2_cmmndwin_5th9 create_command_window
    def create_command_window (*args)
      modrn_qusjrnl2_cmmndwin_5th9 (*args)
      if $game_system.quest_menuaccess 
        c = @command_window.commands.dup
        c.insert (QuestData::MENU_INDEX, QuestData::VOCAB_QUESTS)
        width = @command_window.width
        disabled = @command_window.ma_disabled_commands
        @command_window.dispose
        @command_window = @command_window.class.new (width, c)
        @command_window.index = @menu_index
        disabled.each { |i|
          i += 1 if i >= QuestData::MENU_INDEX
          @command_window.draw_item (i, false)
        }
        @command_window.draw_item (QuestData::MENU_INDEX, false) if $game_system.quest_disabled || $game_party.quests.list.empty?
      end
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias malg_questj_cmmndupd_4rn6 update_command_selection
    def update_command_selection (*args)
      if $game_system.quest_menuaccess 
        if @command_window.index == QuestData::MENU_INDEX && Input.trigger? (Input::C)
          if $game_system.quest_disabled || $game_party.quests.list.empty?
            Sound.play_buzzer
          else
            Sound.play_decision
            $scene = Scene_Quest.new
          end
          return
        end
        change = @command_window.index > QuestData::MENU_INDEX && !Object.const_defined? (:Custom_Commands)
        @command_window.index -= 1 if change
      end
      malg_questj_cmmndupd_4rn6 (*args)
      @command_window.index += 1 if $game_system.quest_menuaccess && change 
    end
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    alias ma_journalqst_actorupd_3gb8 update_actor_selection
    def update_actor_selection (*args)
      if $game_system.quest_menuaccess 
        change = @command_window.index > QuestData::MENU_INDEX
        @command_window.index -= 1 if change
      end
      ma_journalqst_actorupd_3gb8 (*args)
      @command_window.index += 1 if $game_system.quest_menuaccess && change
    end
  end
end
