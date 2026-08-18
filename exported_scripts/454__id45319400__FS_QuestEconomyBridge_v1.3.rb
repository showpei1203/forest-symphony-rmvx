#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_QuestEconomyBridge v1.3
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_QuestEconomyBridge v1.3」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Interpreter、Window_QuestInfo、FS_QUEST_ECONOMY_UI、FS_QUEST_ECONOMY、QuestData
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：LEVEL_DISPLAY、LEVEL_LABEL、LEVEL_ICON_LIMIT、META_LABEL_WIDTH、META_GAP、META_VALUE_FONT_SIZE、LEVEL_NUMBER_RESERVE、QUESTS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Quest Economy Bridge；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_QuestEconomyBridge v1.3
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8
#
# Quest 20～29 的正式經濟報酬。
# 不新增 Item 900～905，也不建立新的執行時資料庫物件。
# 報酬改為服務、商店、鍛造、調律、情報與黑市權限。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Quest Economy Bridge"] = "1.3"

module FS_QUEST_ECONOMY_UI
  # :number = 顯示「建議Lv 40」
  # :icons  = 顯示圖示，但最多 LEVEL_ICON_LIMIT 枚
  # :hidden = 不顯示任務建議等級
  LEVEL_DISPLAY = :number
  LEVEL_LABEL = "建議Lv "
  LEVEL_ICON_LIMIT = 5

  # 委託人／地點欄位配置
  META_LABEL_WIDTH = 76
  META_GAP = 4
  META_VALUE_FONT_SIZE = 18
  LEVEL_NUMBER_RESERVE = 96
end

module FS_QUEST_ECONOMY
  VERSION = "1.3"

  QUESTS = {
    20 => {
      :name => "空著的第七張椅子",
      :description => "拓荒營地始終替第七名巡衛保留一張椅子。沒有人願意說明他去了哪裡。",
      :client => "拓荒營地紀錄官",
      :location => "拓荒營地／南側巡邏路線",
      :objectives => ["找到第七名巡衛的下落", "檢查南側巡邏路線", "跟隨遺留的繩結", "決定如何處理巡衛的失職", "回報營地紀錄官"],
      :level => 3,
      :rewards => ["魯卡商店折扣10%", "300G", "120EXP"]
    },
    21 => {
      :name => "借來的名字",
      :description => "一名孩子替沒有名字的魂刻留下位置。名字究竟能不能讓舊記憶獲得新生？",
      :client => "等待朋友的孩子",
      :location => "魯卡村近郊",
      :objectives => ["調查孩子所稱的朋友", "找出無名魂刻留下的記憶", "決定是否讓孩子替它命名", "回到孩子身邊"],
      :level => 4,
      :rewards => ["新譜系首次碎片+1", "150G", "150EXP"]
    },
    22 => {
      :name => "第十三根界樁",
      :description => "界樁沒有自己長腿，但第十三根確實消失了。通常這代表有人比木頭更不老實。",
      :client => "拓荒隊測量員",
      :location => "拓荒營地外圍",
      :objectives => ["尋找失蹤的第十三根界樁", "調查遷徙獸群的路線", "修復或移動界樁", "向拓荒隊回報"],
      :level => 8,
      :rewards => ["碎片4比1交換權", "400G", "220EXP"]
    },
    23 => {
      :name => "夜班不點名",
      :description => "夜班紀錄只留下空白。營地的人裝作那是筆墨問題，筆墨因此承擔了不小的責任。",
      :client => "拓荒營地值勤官",
      :location => "拓荒營地夜間區域",
      :objectives => ["代替夜班人員巡查營地", "檢查沒有回應的三處燈塔", "找出失蹤人員", "將夜班紀錄交回"],
      :level => 10,
      :rewards => ["每章一次碎片補給", "450G", "250EXP"]
    },
    24 => {
      :name => "不會響的鐵砧",
      :description => "哈貝爾有一座鐵砧再也敲不出聲音。矮人不怕沉默，但非常討厭工具先沉默。",
      :client => "哈貝爾工坊主人",
      :location => "哈貝爾矮人村",
      :objectives => ["調查不會響的鐵砧", "尋找缺失的鍛造材料", "修復鐵砧的共鳴結構", "回報工坊主人"],
      :level => 17,
      :rewards => ["鍛造服務", "哈貝爾折扣10%", "800G", "450EXP"]
    },
    25 => {
      :name => "第零協議",
      :description => "封存工坊裡的機器人仍在等待一條從未被列入正式編號的命令。",
      :client => "哈貝爾舊工坊管理員",
      :location => "哈貝爾封存工坊",
      :objectives => ["找出第零協議的來源", "進入封存工坊", "確認機器人的終止命令", "選擇保留或刪除協議", "將協議記錄帶回"],
      :level => 19,
      :rewards => ["鍛造／調律費用-10%", "900G", "500EXP"]
    },
    26 => {
      :name => "被刪去的歌名",
      :description => "旋律仍有人會唱，名字卻被從記錄裡抹去。遺忘往往比保存更需要力氣。",
      :client => "尋找舊曲的吟遊者",
      :location => "精靈村",
      :objectives => ["尋找被刪去的歌名", "調查殘缺的樂譜", "從魂刻記憶中拼回旋律", "將歌名交給吟遊者"],
      :level => 26,
      :rewards => ["調律服務", "1200G", "700EXP"]
    },
    27 => {
      :name => "樹梢之下",
      :description => "精靈村把生活築在樹梢，樹根下的問題便很容易被所有人一起假裝看不見。",
      :client => "精靈村守林者",
      :location => "精靈村下層根域",
      :objectives => ["調查樹梢下的異常聲響", "找到不願離開的守林人", "處理被侵蝕的樹根", "決定守林人的去留"],
      :level => 29,
      :rewards => ["碎片回收服務", "1200G", "750EXP"]
    },
    28 => {
      :name => "完美證詞",
      :description => "三份證詞都毫無破綻，只是彼此完全不同。人類終於把說謊也做成了團隊合作。",
      :client => "主城調查官",
      :location => "主城",
      :objectives => ["收集三份互相矛盾的證詞", "檢查全知儀留下的紀錄", "找出被修改的部分", "確認真正的事件經過", "公開或封存真相"],
      :level => 36,
      :rewards => ["異常經濟紀錄權限", "1800G", "1000EXP"]
    },
    29 => {
      :name => "一段記憶的價錢",
      :description => "地下拍賣會替記憶標價。最後的選擇會決定你帶走黑市名冊，或把記憶焚成灰燼。",
      :client => "匿名委託",
      :location => "主城地下拍賣會",
      :objectives => ["接觸記憶拍賣會", "找出被販售記憶的來源", "追查買家與仲介", "決定如何處理記憶庫", "離開黑市"],
      :level => 40,
      :rewards => ["黑市交易權／記憶重構權", "1500EXP"]
    }
  }


  QUEST29_BRANCHES = {
    1 => {
      :description => "地下拍賣會替記憶標價。你保留了交易名冊，決定利用黑市追查被販售的記憶。",
      :objectives => ["接觸記憶拍賣會", "找出被販售記憶的來源",
        "追查買家與仲介", "保留地下拍賣會的黑市名冊",
        "帶著黑市名冊離開地下拍賣會"],
      :rewards => ["黑市交易權", "1500EXP"]
    },
    2 => {
      :description => "地下拍賣會替記憶標價。你焚毀了記憶庫，帶走殘留灰燼以重構被奪走的記憶。",
      :objectives => ["接觸記憶拍賣會", "找出被販售記憶的來源",
        "追查買家與仲介", "焚毀地下拍賣會的記憶庫",
        "帶著記憶灰燼離開地下拍賣會"],
      :rewards => ["記憶重構權", "免費重調律1次", "1500EXP"]
    }
  }

  def self.quest29_branch
    return 0 unless defined?(FS_ECONOMY)
    d = FS_ECONOMY.data
    return 0 if d == nil
    return d[:quest29_branch].to_i
  end

  def self.row_for(id, branch = 0)
    row = QUESTS[id.to_i]
    return nil if row == nil
    result = row.clone
    result[:objectives] = row[:objectives].clone
    result[:rewards] = row[:rewards].clone
    if id.to_i == 29
      branch = quest29_branch if branch.to_i == 0
      selected = QUEST29_BRANCHES[branch.to_i]
      if selected != nil
        result[:description] = selected[:description]
        result[:objectives] = selected[:objectives].clone
        result[:rewards] = selected[:rewards].clone
      end
    end
    return result
  end

  REWARD_VALUES = {
    20 => [300, 120],
    21 => [150, 150],
    22 => [400, 220],
    23 => [450, 250],
    24 => [800, 450],
    25 => [900, 500],
    26 => [1200, 700],
    27 => [1200, 750],
    28 => [1800, 1000],
    29 => [0, 1500]
  }

  def self.quest_data(id)
    row = row_for(id.to_i)
    return nil if row == nil
    objectives = row[:objectives].clone
    prime = []
    objectives.each_index { |i| prime.push(i) }
    rewards = row[:rewards].clone
    return ["", row[:name], row[:description], row[:client], row[:location],
      objectives, prime, rewards, row[:level], 0, 0, [:sidequest]]
  end

  def self.grant_exp(value)
    return if $game_party == nil
    members = $game_party.respond_to?(:all_members) ?
      $game_party.all_members : $game_party.members
    members.each do |actor|
      next if actor == nil
      actor.gain_exp(value.to_i, false)
    end
  end

  def self.apply_branch_to_journal(quest, branch)
    return if quest == nil
    row = row_for(29, branch)
    return if row == nil
    quest.description = row[:description] if quest.respond_to?(:description=)
    quest.objectives = row[:objectives].clone if quest.respond_to?(:objectives=)
    prime = []
    quest.objectives.each_index { |i| prime.push(i) }
    quest.prime_objectives = prime if quest.respond_to?(:prime_objectives=)
    quest.rewards = row[:rewards].clone if quest.respond_to?(:rewards=)
  end

  def self.complete_journal(id, branch = 0)
    return if $game_party == nil || !$game_party.respond_to?(:quests)
    quest = $game_party.quests[id.to_i] rescue nil
    return if quest == nil
    apply_branch_to_journal(quest, branch) if id.to_i == 29
    quest.concealed = false if quest.respond_to?(:concealed=)
    list = []
    quest.objectives.each_index { |i| list.push(i) }
    quest.complete_objective(*list) unless list.empty?
    quest.reward_given = true if quest.respond_to?(:reward_given=)
  end

  def self.complete(id, branch = 0)
    id = id.to_i
    return :invalid unless QUESTS.has_key?(id)
    return :branch_required if id == 29 && ![1, 2].include?(branch.to_i)
    return :already if FS_ECONOMY.quest_claimed?(id)

    values = REWARD_VALUES[id]
    $game_party.gain_gold(values[0]) if values[0].to_i > 0
    grant_exp(values[1]) if values[1].to_i > 0
    FS_ECONOMY.complete_quest_service(id, branch)
    if id == 29
      d = FS_ECONOMY.data
      d[:quest29_branch] = branch.to_i if d != nil
    end
    FS_ECONOMY.mark_quest_claimed(id)
    complete_journal(id, branch)
    return :success
  end

  def self.result_text(result, id = 0, branch = 0)
    case result
    when :success
      if id.to_i == 29 && branch.to_i == 1
        return "Quest 29完成：已選擇黑市名冊，解鎖黑市交易權。"
      elsif id.to_i == 29 && branch.to_i == 2
        return "Quest 29完成：已選擇記憶灰燼，解鎖記憶重構權。"
      end
      return "任務報酬與服務權限已取得。"
    when :already then return "這項任務報酬已經領取。"
    when :branch_required then return "Quest 29 必須指定分支：1黑市／2記憶重構。"
    else return "任務資料無效。"
    end
  end

  def self.claim_night_supply
    return :locked unless FS_ECONOMY.unlocked?(:night_supply)
    d = FS_ECONOMY.data
    return :already if d[:night_supply_chapter].to_i == FS_ECONOMY.chapter
    offsets = []
    FS_ECONOMY::SOUL_COUNT.times do |offset|
      offsets.push(offset) if FS_ECONOMY.captured_offset?(offset)
    end
    return :empty if offsets.empty?
    3.times do
      offset = offsets[rand(offsets.size)]
      item = $data_items[FS_ECONOMY.fragment_item_id(offset)] rescue nil
      $game_party.gain_item(item, 1) if item != nil
    end
    d[:night_supply_chapter] = FS_ECONOMY.chapter
    return :success
  end

  def self.exchange_fragments(from_offset, to_offset, amount = 4)
    return :locked unless FS_ECONOMY.unlocked?(:migration_route)
    amount = [amount.to_i, 4].max
    from_id = FS_ECONOMY.fragment_item_id(from_offset)
    to_id = FS_ECONOMY.fragment_item_id(to_offset)
    return :invalid if from_id <= 0 || to_id <= 0 || from_id == to_id
    # 只能換成已完成首次汲取的譜系，避免用低階碎片提前開未知魂刻。
    return :invalid unless FS_ECONOMY.captured_offset?(to_offset)
    from_item = $data_items[from_id] rescue nil
    to_item = $data_items[to_id] rescue nil
    return :invalid if from_item == nil || to_item == nil
    return :material_short if $game_party.item_number(from_item) < amount
    $game_party.lose_item(from_item, amount)
    $game_party.gain_item(to_item, 1)
    return :success
  end

  def self.enemy_economy_lines(enemy_id)
    return ["尚未取得異常紀錄權限。"] unless
      FS_ECONOMY.unlocked?(:anomaly_record_access)
    enemy = $data_enemies[enemy_id.to_i] rescue nil
    return ["敵人資料不存在。"] if enemy == nil
    armor_id = FS_ECONOMY_DROP.soul_armor_id(enemy) rescue 0
    return [enemy.name.to_s, "此敵人不屬於魂刻碎片掉落表。"] if armor_id <= 0
    offset = armor_id - FS_ECONOMY::SOUL_ARMOR_START
    fragment = $data_items[FS_ECONOMY.fragment_item_id(offset)] rescue nil
    headgear = $data_armors[FS_ECONOMY.headgear_id(offset)] rescue nil
    profile = FS_ECONOMY_DROP.profile(enemy) rescue nil
    info = FS_SOULMARK_RESONANCE.stage_info(enemy_id.to_i, armor_id) rescue [0,1,armor_id]
    lines = []
    lines.push(enemy.name.to_s)
    lines.push("掉落：" + (fragment == nil ? "未知碎片" : fragment.name.to_s) +
      "　固定#{profile[0]}／追加#{profile[1]}%×#{profile[2]}") if profile != nil
    repeat_frag = info[1].to_i <= 1 || info[0].to_i <= 0 ? 1 :
      (info[0].to_i >= info[1].to_i - 1 ? 3 : 2)
    lines.push("重複汲取：殘響1、碎片#{repeat_frag}")
    lines.push("配方：" + (headgear == nil ? "未知" : headgear.name.to_s) +
      "　製作費#{FS_ECONOMY.headgear_craft_gold(offset)}G")
    return lines
  end
end

#==============================================================================
# ■ QuestData：只覆寫 Quest 20～29
#==============================================================================
if defined?(QuestData)
  module QuestData
    class << self
      alias fs_qe_old_quest_data quest_data unless
        method_defined?(:fs_qe_old_quest_data)

      def quest_data(id)
        row = FS_QUEST_ECONOMY.quest_data(id)
        return row if row != nil
        return fs_qe_old_quest_data(id)
      end
    end
  end
end

class Game_Interpreter
  def fs_econ_complete_quest(id, branch = 0)
    result = FS_QUEST_ECONOMY.complete(id, branch)
    $game_message.texts.push(FS_QUEST_ECONOMY.result_text(result, id, branch)) if
      $game_message != nil
    return result
  end

  def fs_econ_claim_night_supply
    result = FS_QUEST_ECONOMY.claim_night_supply
    text = case result
    when :success then "領取本章夜班補給：已取得3枚已收錄譜系碎片。"
    when :already then "本章夜班補給已領取。"
    when :empty then "尚未收錄可供補給的魂刻譜系。"
    else "尚未解鎖夜班補給。"
    end
    $game_message.texts.push(text) if $game_message != nil
    return result
  end

  def fs_econ_exchange_fragments(from_offset, to_offset, amount = 4)
    from_id = FS_ECONOMY.fragment_item_id(from_offset)
    to_id = FS_ECONOMY.fragment_item_id(to_offset)
    from_item = $data_items[from_id] rescue nil
    to_item = $data_items[to_id] rescue nil
    amount = [amount.to_i, 4].max
    result = FS_QUEST_ECONOMY.exchange_fragments(from_offset, to_offset, amount)
    if result == :success
      text = sprintf("%s×%d 已交換為 %s×1。",
        from_item == nil ? "來源碎片" : from_item.name.to_s,
        amount,
        to_item == nil ? "目標碎片" : to_item.name.to_s)
    else
      text = FS_ECONOMY.result_text(result)
    end
    $game_message.texts.push(text) if $game_message != nil
    return result
  end

  def fs_econ_enemy_intel(enemy_id)
    lines = FS_QUEST_ECONOMY.enemy_economy_lines(enemy_id)
    lines.each { |line| $game_message.texts.push(line) } if $game_message != nil
    return lines
  end
  def fs_econ_quest29_branch
    branch = FS_QUEST_ECONOMY.quest29_branch
    text = case branch
    when 1 then "Quest 29分支：黑市名冊。"
    when 2 then "Quest 29分支：記憶灰燼／記憶重構。"
    else "Quest 29尚未選擇分支。"
    end
    $game_message.texts.push(text) if $game_message != nil
    return branch
  end

end


#==============================================================================
# ■ Window_QuestInfo：委託人欄寬度修正
#------------------------------------------------------------------------------
# 原設定 CLIENT_WIDTH = 10，但原方法會再減去已使用的x座標，
# 最後得到負寬度，造成委託人右側出現裁切後的白色殘字。
#==============================================================================
if defined?(Window_QuestInfo)
  class Window_QuestInfo < Window_Base
    def draw_client(y)
      return y if @quest == nil || @quest.client.to_s.empty?
      x = 0
      if QuestData::ICONS[:client] != 0
        draw_icon(QuestData::ICONS[:client], x, y)
        x += 28
      end
      unless QuestData::VOCAB_CLIENT.empty?
        set_font(1)
        self.contents.draw_text(x, y, 80, WLH, QuestData::VOCAB_CLIENT)
        x += 80
      end

      reserve = 0
      if @quest.level.to_i > 0 && QuestData::ICONS[:level] != 0
        icon_count = [[@quest.level.to_i, 1].max, 5].min
        reserve = icon_count * QuestData::LEVEL_SPACE + 8
      end
      right_edge = self.contents.width - reserve
      configured = QuestData::CLIENT_WIDTH.to_i
      if configured > x && configured < right_edge
        right_edge = configured
      end
      width = right_edge - x
      width = self.contents.width - x if width < 24

      set_font(0)
      old_size = self.contents.font.size
      self.contents.font.size = [old_size, 18].min
      self.contents.draw_text(x, y, width, WLH, @quest.client.to_s, 0)
      self.contents.font.size = old_size
      return y + WLH
    end
  end
end


#==============================================================================
# ■ Window_QuestInfo：任務建議等級顯示
#------------------------------------------------------------------------------
# 原Quest Journal以 @quest.level.times 直接畫圖示。
# Level 40因此會畫40枚，像圖示在進行人口普查。
#==============================================================================
if defined?(Window_QuestInfo)
  class Window_QuestInfo < Window_Base
    def draw_level(y)
      level = @quest == nil ? 0 : @quest.level.to_i
      return y if level < 1
      mode = FS_QUEST_ECONOMY_UI::LEVEL_DISPLAY

      if mode == :hidden
        return y
      elsif mode == :icons
        icon_id = QuestData::ICONS[:level].to_i
        if icon_id == 0
          text = FS_QUEST_ECONOMY_UI::LEVEL_LABEL + level.to_s
          set_font(0)
          self.contents.draw_text(
            0, y, self.contents.width, WLH, text, 2)
        else
          limit = FS_QUEST_ECONOMY_UI::LEVEL_ICON_LIMIT.to_i
          limit = 1 if limit < 1
          count = [level, limit].min
          x = self.contents.width - 24
          count.times do
            draw_icon(icon_id, x, y)
            x -= QuestData::LEVEL_SPACE
          end
          if level > limit
            set_font(0)
            self.contents.draw_text(
              0, y, x, WLH, "Lv " + level.to_s, 2)
          end
        end
      else
        text = FS_QUEST_ECONOMY_UI::LEVEL_LABEL + level.to_s
        set_font(0)
        self.contents.draw_text(
          0, y, self.contents.width, WLH, text, 2)
      end
      return y + WLH
    end
  end
end


#==============================================================================
# ■ Window_QuestInfo：委託人／地點欄位統一排列 v1.3
#------------------------------------------------------------------------------
# 原腳本把委託人與地點內容靠右對齊，且數字等級模式沒有保留右側空間。
# 結果同一列中的委託人、內容與「建議Lv」各自選擇人生方向。
# 本版固定使用：
#   左側：欄位名稱
#   中間：內容，靠左
#   右側：建議等級
#==============================================================================
if defined?(Window_QuestInfo)
  class Window_QuestInfo < Window_Base
    def fs_econ_level_reserve_width
      return 0 if @quest == nil || @quest.level.to_i < 1
      mode = FS_QUEST_ECONOMY_UI::LEVEL_DISPLAY
      return 0 if mode == :hidden

      if mode == :icons && QuestData::ICONS[:level].to_i != 0
        limit = FS_QUEST_ECONOMY_UI::LEVEL_ICON_LIMIT.to_i
        limit = 1 if limit < 1
        count = [@quest.level.to_i, limit].min
        return count * QuestData::LEVEL_SPACE + 32
      end
      return FS_QUEST_ECONOMY_UI::LEVEL_NUMBER_RESERVE
    end

    def fs_econ_draw_meta_row(y, vocab, value, reserve_right)
      x = 0
      icon_id = 0
      if vocab == QuestData::VOCAB_CLIENT
        icon_id = QuestData::ICONS[:client].to_i
      elsif vocab == QuestData::VOCAB_LOCATION
        icon_id = QuestData::ICONS[:location].to_i
      end

      if icon_id != 0
        draw_icon(icon_id, x, y)
        x += 28
      end

      label_width = FS_QUEST_ECONOMY_UI::META_LABEL_WIDTH.to_i
      label_width = 60 if label_width < 60

      unless vocab.to_s.empty?
        set_font(1)
        self.contents.draw_text(
          x, y, label_width, WLH, vocab.to_s, 0)
      end

      value_x = x + label_width +
        FS_QUEST_ECONOMY_UI::META_GAP.to_i
      value_width = self.contents.width -
        value_x - reserve_right.to_i
      value_width = 24 if value_width < 24

      set_font(0)
      old_size = self.contents.font.size
      size = FS_QUEST_ECONOMY_UI::META_VALUE_FONT_SIZE.to_i
      size = old_size if size <= 0
      self.contents.font.size = [old_size, size].min
      self.contents.draw_text(
        value_x, y, value_width, WLH, value.to_s, 0)
      self.contents.font.size = old_size
      return y + WLH
    end

    def draw_client(y)
      return y if @quest == nil || @quest.client.to_s.empty?
      reserve = fs_econ_level_reserve_width
      return fs_econ_draw_meta_row(
        y, QuestData::VOCAB_CLIENT, @quest.client, reserve)
    end

    def draw_location(y)
      return y if @quest == nil || @quest.location.to_s.empty?
      return fs_econ_draw_meta_row(
        y, QuestData::VOCAB_LOCATION, @quest.location, 0)
    end
  end
end
