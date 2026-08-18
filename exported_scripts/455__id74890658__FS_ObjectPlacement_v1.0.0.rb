#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_ObjectPlacement v1.0.0
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_ObjectPlacement v1.0.0」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_System、Game_Temp、Game_Map、Game_Interpreter、FS_ObjectPlacement
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：DEFAULTS、PUZZLES、RESULT_CODES、OBJECT_TAG、SLOT_TAG。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】fs_econ_complete_quest(任務ID)；$Item
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
#==============================================================================
# ■ FS_ObjectPlacement v1.0.0
#------------------------------------------------------------------------------
#  Forest Symphony 共用搬運／歸位／壓板／擺設支線核心
#  RPG Maker VX / RGSS2
#------------------------------------------------------------------------------
# 【用途】
#  本腳本接在月紳士「乗り物拡張」的物件搬運功能之上，負責：
#
#   1. 單一物件搬到指定位置。
#   2. 多個不同物件，各自放到正確位置。
#   3. 多個同類物件，放到任意相容位置／壓板。
#   4. 判斷放對、放錯、放在一般地面、位置已被占用。
#   5. 放錯後允許保留、退回拿起前位置，或退回初始位置。
#   6. 指定物件放置方向。
#   7. 自動更新放置點的 Self Switch A／B／C。
#   8. 自動完成 Quest Journal 目標、顯示下一目標。
#   9. 完成後可鎖定物件，避免玩家又搬走。
#  10. 可保存移動後座標，離開地圖再回來仍維持擺放結果。
#  11. 可寫入進度／結果／物件ID／位置ID到遊戲變數。
#  12. 可依正確、錯誤、落地、占用、完成呼叫不同共同事件。
#
#  本腳本「不會」直接發放 Quest 20～29 的任務報酬。
#  最終報酬仍應由委託人事件呼叫：
#
#     fs_econ_complete_quest(任務ID)
#
#  搬運謎題只負責完成其中一個任務目標。不要讓一張椅子兼任會計。
#
#==============================================================================
# ■ 一、安裝位置
#==============================================================================
#
#  請放在以下腳本之下、Main 之上：
#
#    乗り物拡張
#    QJ2 / Quest Journal
#    FS_QuestEconomyBridge（若有）
#    FS_ObjectPlacement v1.0.0   ← 本腳本
#    Main
#
#  本腳本不改寫「乗り物拡張」核心搬運方法，只使用它公開的：
#
#    get_on_event_test
#    get_on_event
#
#  以及物件放下後自動開啟「物件自己的 Self Switch D」的既有機制。
#
#==============================================================================
# ■ 二、乗り物拡張的素材前置設定
#==============================================================================
#
#  要搬運的事件圖，仍必須先在「乗り物拡張」的騎乘資料庫中登錄成：
#
#    @object_type = true
#
#  專案目前已登錄的範例包括：
#
#    !$Object
#    !$Object2
#    $Item
#
#  若使用新的角色圖檔，請先依「乗り物拡張」手冊新增 object_type 資料。
#  否則 get_on_event 會把它當成一般騎乘物，而不是舉起來。家具騎士團
#  雖然聽起來有市場，但目前支線顯然不是那個方向。
#
#==============================================================================
# ■ 三、事件名稱標籤
#==============================================================================
#
# 【可搬物件】
#
#    <FSOP_OBJECT:組別:物件Key>
#
#  範例：
#
#    石塊 <FSOP_OBJECT:strength_test:rock>
#    木雕鳥 <FSOP_OBJECT:altar_order:bird>
#    花瓶   <FSOP_OBJECT:altar_order:vase>
#    燭台   <FSOP_OBJECT:altar_order:candle>
#
# 【放置位置】
#
#    <FSOP_SLOT:組別:可接受Key>
#
#  範例：
#
#    石塊標記 <FSOP_SLOT:strength_test:rock>
#    鳥形凹槽 <FSOP_SLOT:altar_order:bird>
#    花瓶底座 <FSOP_SLOT:altar_order:vase>
#    燭台位置 <FSOP_SLOT:altar_order:candle>
#
# 【同一位置接受多種物件】
#
#    <FSOP_SLOT:組別:key1,key2,key3>
#
#  範例：
#
#    木箱區 <FSOP_SLOT:warehouse:small_box,large_box>
#
# 【接受任意物件】
#
#    <FSOP_SLOT:組別:*>
#
#  範例：
#
#    壓板 <FSOP_SLOT:pressure_test:*>
#
# 【指定放置方向】
#
#    <FSOP_SLOT:組別:可接受Key:方向>
#
#  方向：2下、4左、6右、8上
#
#    雕像底座 <FSOP_SLOT:statue_test:statue:2>
#
# 【非必要位置】
#
#    <FSOP_SLOT:組別:可接受Key:方向:optional>
#
#  方向不限制但要設 optional 時，可留空：
#
#    <FSOP_SLOT:組別:可接受Key::optional>
#
#  optional 位置仍會顯示正確／錯誤狀態，但不列入完成條件。
#
#  建議組別與 Key 使用半形英文、數字、底線。
#  標籤不綁事件 ID，因此地圖新增事件後不必重新改整張判定表。
#
#==============================================================================
# ■ 四、可搬物件事件頁
#==============================================================================
#
#  每個可搬物件建議使用三頁，頁面由左到右排列：
#
# 【第1頁：平常可搬】
#
#   條件：無，或依任務進度設定
#   圖像：已登錄 object_type 的圖
#   優先級：與角色相同
#   觸發：決定鍵
#   內容，腳本指令：
#
#     fs_place_pickup
#
# 【第2頁：完成後鎖定】
#
#   條件：Self Switch A = ON
#   圖像：同物件
#   優先級：與角色相同
#   觸發：決定鍵
#   內容：空白，或顯示「已經放好了」
#
#   預設使用 A 作為物件鎖定開關，可在設定改成其他字母。
#
# 【第3頁：放下後處理，必須放最右邊】
#
#   條件：Self Switch D = ON
#   圖像：同物件
#   優先級：與角色相同
#   觸發：自動執行
#   內容，腳本指令：
#
#     fs_place_drop
#
#  fs_place_drop 會自行關閉物件的 D，不要再另外寫 D = OFF。
#  D 是「乗り物拡張」保留的放下通知，請勿拿去做寶箱或其他狀態。
#
#==============================================================================
# ■ 五、放置位置事件頁
#==============================================================================
#
#  放置位置通常只需要一頁：
#
#   優先級：角色下方
#   穿透：ON
#   觸發：決定鍵或玩家接觸皆可，內容可空白
#
#  本腳本會自動操作該位置事件的 Self Switch：
#
#   A = 有正確物件
#   B = 有錯誤物件
#   C = 有任何物件占用
#
#  正確時 A、C 同時 ON。
#  錯誤時 B、C 同時 ON。
#  空位時 A、B、C 全部 OFF。
#
#  若要依狀態換圖，事件頁由左到右建議：
#
#   第1頁：空位
#   第2頁：C，占用通用外觀
#   第3頁：B，錯誤外觀
#   第4頁：A，正確外觀
#
#  因為最右頁優先，正確不會被 C 的通用頁蓋掉。這些小規則若靠記憶
#  維護，通常會在三個月後向製作者收取精神損害賠償。
#
#==============================================================================
# ■ 六、設定表 PUZZLES
#==============================================================================
#
#  每個「組別」可以在下方 PUZZLES 加一筆設定。
#  沒有設定的組別也能運作，會採 DEFAULTS。
#
#  常用欄位：
#
#   :quest_id                 Quest Journal 任務 ID，0 = 不連動
#   :objective_id             完成時要完成的目標索引，-1 = 不連動
#   :next_objective_id        完成後顯示的下一目標，-1 = 不處理
#   :require_quest_revealed   任務未顯示時禁止搬運
#   :require_objective_revealed 目標未顯示時禁止搬運
#
#   :lock_when_complete       完成後鎖定所有物件
#   :object_lock_switch       物件鎖定用 Self Switch，預設 "A"
#   :auto_uncomplete          未鎖定且配置被破壞時，取消目標完成
#   :conceal_next_when_undone 同時隱藏下一目標
#
#   :wrong_policy             放錯位置的處理
#   :ground_policy            放在非位置格的處理
#   :occupied_policy          位置已有其他物件的處理
#
#  policy 可用：
#
#   :allow      允許留在原處
#   :previous   退回本次拿起前的位置
#   :home       退回事件在編輯器中的初始位置
#
#   :required_count           需要正確的位置數；0 = 全部必要位置
#   :complete_switch          完成後開啟的全域 Switch；0 = 不使用
#
#  變數：0 = 不使用
#
#   :progress_variable        寫入目前正確數量
#   :total_variable           寫入必要位置總數
#   :result_variable          寫入最後結果代碼
#   :object_variable          寫入最後操作的物件事件 ID
#   :slot_variable            寫入最後接觸的位置事件 ID，沒有則 0
#
#  共同事件：0 = 不使用
#
#   :drop_common_event        每次有效放下後
#   :correct_common_event     放對時
#   :wrong_common_event       放錯時
#   :ground_common_event      放在一般地面時
#   :occupied_common_event    放到已占用位置時
#   :complete_common_event    整組首次完成時
#
#  音效：nil = 不播放；可用 :decision、:buzzer，或 [檔名,音量,音高]
#
#   :pickup_se
#   :correct_se
#   :wrong_se
#   :ground_se
#   :occupied_se
#   :complete_se
#
#==============================================================================
# ■ 七、公開事件指令
#==============================================================================
#
#  可搬物件第1頁：
#
#    fs_place_pickup
#
#  可搬物件 D 自動頁：
#
#    fs_place_drop
#
#  重新掃描目前地圖全部組別：
#
#    fs_place_refresh
#
#  重新掃描指定組別：
#
#    fs_place_refresh(:altar_order)
#
#  重置指定組別的位置與系統狀態：
#
#    fs_place_reset(:altar_order)
#
#  同時取消 Quest Journal 目標完成狀態：
#
#    fs_place_reset(:altar_order, true)
#
#  查詢：
#
#    fs_place_completed?(:altar_order)
#    fs_place_correct_count(:altar_order)
#    fs_place_required_count(:altar_order)
#    fs_place_last_result
#    fs_place_last_object_id
#    fs_place_last_slot_id
#
#  最後結果可能為：
#
#    :picked       成功拿起
#    :correct      正確放置
#    :wrong        錯誤位置
#    :ground       一般地面
#    :occupied     位置已被其他物件占用
#    :complete     本次放下使整組完成
#    :locked       已完成鎖定
#    :inactive     任務／目標尚未啟用
#    :blocked      乗り物拡張判定目前不能拿起
#    :invalid      標籤或事件無效
#    :missing_dependency 缺少乗り物拡張公開方法
#
#  RESULT_CODES 可用於遊戲變數的數字判定。
#
#==============================================================================
# ■ 八、範例
#==============================================================================
#
# 【Quest 5「力氣的證明」：一個石塊搬到標記】
#
#  石塊事件名稱：
#    石塊 <FSOP_OBJECT:strength_test:rock>
#
#  標記事件名稱：
#    搬運標記 <FSOP_SLOT:strength_test:rock>
#
#  下方 PUZZLES 已附 strength_test 範例：
#    完成 Quest 5 目標0，顯示目標1，完成後鎖定石塊。
#
# 【三個物品各歸其位】
#
#  物件：
#    <FSOP_OBJECT:altar_order:bird>
#    <FSOP_OBJECT:altar_order:vase>
#    <FSOP_OBJECT:altar_order:candle>
#
#  位置：
#    <FSOP_SLOT:altar_order:bird>
#    <FSOP_SLOT:altar_order:vase>
#    <FSOP_SLOT:altar_order:candle>
#
#  PUZZLES 新增：
#
#    :altar_order => {
#      :quest_id => 20,
#      :objective_id => 2,
#      :next_objective_id => 3,
#      :wrong_policy => :allow,
#      :lock_when_complete => true
#    },
#
# 【三個相同木箱放到任意三個區域】
#
#  三個物件都使用：
#    <FSOP_OBJECT:warehouse:box>
#
#  三個位置都使用：
#    <FSOP_SLOT:warehouse:box>
#
#==============================================================================

module FS_ObjectPlacement
  VERSION = "1.0.0"

  #--------------------------------------------------------------------------
  # ● 預設設定
  #--------------------------------------------------------------------------
  DEFAULTS = {
    :enabled_switch => 0,
    :quest_id => 0,
    :objective_id => -1,
    :next_objective_id => -1,
    :require_quest_revealed => false,
    :require_objective_revealed => false,
    :lock_when_complete => true,
    :object_lock_switch => "A",
    :auto_uncomplete => false,
    :conceal_next_when_undone => false,
    :wrong_policy => :allow,
    :ground_policy => :allow,
    :occupied_policy => :previous,
    :required_count => 0,
    :complete_switch => 0,
    :progress_variable => 0,
    :total_variable => 0,
    :result_variable => 0,
    :object_variable => 0,
    :slot_variable => 0,
    :drop_common_event => 0,
    :correct_common_event => 0,
    :wrong_common_event => 0,
    :ground_common_event => 0,
    :occupied_common_event => 0,
    :complete_common_event => 0,
    :pickup_se => :decision,
    :correct_se => :decision,
    :wrong_se => :buzzer,
    :ground_se => nil,
    :occupied_se => :buzzer,
    :complete_se => :decision
  }

  #--------------------------------------------------------------------------
  # ● 支線設定表
  #    沒有列在這裡的組別仍可使用，會套用 DEFAULTS。
  #--------------------------------------------------------------------------
  PUZZLES = {
    # 舊 Quest 5「力氣的證明」正式相容範例
    :strength_test => {
      :quest_id => 5,
      :objective_id => 0,
      :next_objective_id => 1,
      :require_quest_revealed => true,
      :require_objective_revealed => true,
      :wrong_policy => :allow,
      :ground_policy => :allow,
      :lock_when_complete => true
    }

    # 三物歸位範例，請按實際任務 ID 再啟用：
    # :altar_order => {
    #   :quest_id => 20,
    #   :objective_id => 2,
    #   :next_objective_id => 3,
    #   :wrong_policy => :allow,
    #   :ground_policy => :allow,
    #   :lock_when_complete => true,
    #   :progress_variable => 0,
    #   :complete_common_event => 0
    # },
  }

  RESULT_CODES = {
    :none => 0,
    :picked => 1,
    :correct => 2,
    :wrong => 3,
    :ground => 4,
    :complete => 5,
    :blocked => 6,
    :inactive => 7,
    :invalid => 8,
    :occupied => 9,
    :locked => 10,
    :missing_dependency => 11,
    :carried => 12
  }

  OBJECT_TAG = /<FSOP_OBJECT\s*:\s*([^:>]+)\s*:\s*([^>]+)>/i
  SLOT_TAG   = /<FSOP_SLOT\s*:\s*([^>]+)>/i

  #--------------------------------------------------------------------------
  # ● 基本資料與正規化
  #--------------------------------------------------------------------------
  def self.normalize_group(value)
    value.to_s.strip.downcase.to_sym
  end

  def self.normalize_key(value)
    value.to_s.strip.downcase
  end

  def self.event_name(event)
    return "" if event == nil
    return event.name.to_s if event.respond_to?(:name)
    data = event.instance_variable_get(:@event) rescue nil
    return data.name.to_s if data != nil && data.respond_to?(:name)
    return ""
  end

  def self.object_data(event)
    name = event_name(event)
    match = OBJECT_TAG.match(name)
    return nil if match == nil
    group = normalize_group(match[1])
    key = normalize_key(match[2])
    return nil if key.empty?
    return {
      :group => group,
      :key => key,
      :event => event,
      :event_id => event.id
    }
  end

  def self.slot_data(event)
    name = event_name(event)
    match = SLOT_TAG.match(name)
    return nil if match == nil
    parts = match[1].split(":", -1)
    return nil if parts.size < 2
    group = normalize_group(parts[0])
    keys = parts[1].to_s.split(/[\s,|\/]+/).collect { |v| normalize_key(v) }
    keys.delete("")
    return nil if keys.empty?
    direction = parts[2].to_s.strip
    direction = direction.empty? ? 0 : direction.to_i
    direction = 0 unless [2, 4, 6, 8].include?(direction)
    mode = parts[3].to_s.strip.downcase
    optional = (mode == "optional" || mode == "option" || mode == "opt")
    return {
      :group => group,
      :keys => keys,
      :direction => direction,
      :optional => optional,
      :event => event,
      :event_id => event.id
    }
  end

  def self.config(group)
    group = normalize_group(group)
    result = DEFAULTS.clone
    custom = PUZZLES[group]
    custom.each { |key, value| result[key] = value } if custom != nil
    result[:object_lock_switch] = result[:object_lock_switch].to_s.upcase
    result[:object_lock_switch] = "A" unless ["A", "B", "C"].include?(result[:object_lock_switch])
    return result
  end

  def self.map_id
    return 0 if $game_map == nil
    return $game_map.map_id
  end

  def self.state_key(group, target_map_id = nil)
    target_map_id = map_id if target_map_id == nil
    return [target_map_id.to_i, normalize_group(group)]
  end

  def self.position_key(event, target_map_id = nil)
    target_map_id = map_id if target_map_id == nil
    return [target_map_id.to_i, event.id.to_i]
  end

  #--------------------------------------------------------------------------
  # ● Game_System 保存區（舊存檔也會自動補齊）
  #--------------------------------------------------------------------------
  def self.positions
    return {} if $game_system == nil
    return $game_system.fsop_positions
  end

  def self.homes
    return {} if $game_system == nil
    return $game_system.fsop_homes
  end

  def self.completed_states
    return {} if $game_system == nil
    return $game_system.fsop_completed_states
  end

  #--------------------------------------------------------------------------
  # ● Game_Temp 暫存區
  #--------------------------------------------------------------------------
  def self.pending_origins
    return {} if $game_temp == nil
    return $game_temp.fsop_pending_origins
  end

  def self.last_result
    return :none if $game_temp == nil
    return $game_temp.fsop_last_result || :none
  end

  def self.last_object_id
    return 0 if $game_temp == nil
    return $game_temp.fsop_last_object_id.to_i
  end

  def self.last_slot_id
    return 0 if $game_temp == nil
    return $game_temp.fsop_last_slot_id.to_i
  end

  def self.set_last(group, result, object_id = 0, slot_id = 0)
    return if $game_temp == nil
    $game_temp.fsop_last_group = normalize_group(group)
    $game_temp.fsop_last_result = result
    $game_temp.fsop_last_object_id = object_id.to_i
    $game_temp.fsop_last_slot_id = slot_id.to_i
    cfg = config(group)
    set_variable(cfg[:result_variable], RESULT_CODES[result] || 0)
    set_variable(cfg[:object_variable], object_id.to_i)
    set_variable(cfg[:slot_variable], slot_id.to_i)
  end

  #--------------------------------------------------------------------------
  # ● 事件與地圖掃描
  #--------------------------------------------------------------------------
  def self.current_events
    return [] if $game_map == nil || $game_map.events == nil
    return $game_map.events.values.compact
  end

  def self.objects(group = nil)
    target = group == nil ? nil : normalize_group(group)
    result = []
    current_events.each do |event|
      data = object_data(event)
      next if data == nil
      next if target != nil && data[:group] != target
      result.push(data)
    end
    return result
  end

  def self.slots(group = nil)
    target = group == nil ? nil : normalize_group(group)
    result = []
    current_events.each do |event|
      data = slot_data(event)
      next if data == nil
      next if target != nil && data[:group] != target
      result.push(data)
    end
    return result
  end

  def self.groups_on_map
    result = []
    objects.each { |data| result.push(data[:group]) }
    slots.each { |data| result.push(data[:group]) }
    return result.uniq
  end

  def self.carried_event
    return nil if $game_map == nil
    return $game_map.event_vehicle if $game_map.respond_to?(:event_vehicle)
    return nil
  end

  def self.carried_object?(event)
    current = carried_event
    return current != nil && current == event
  end

  def self.objects_at(x, y, group)
    result = []
    objects(group).each do |data|
      event = data[:event]
      next if carried_object?(event)
      next unless event.x == x && event.y == y
      result.push(data)
    end
    result.sort! { |a, b| a[:event_id] <=> b[:event_id] }
    return result
  end

  def self.slots_at(x, y, group)
    result = slots(group).select do |data|
      data[:event].x == x && data[:event].y == y
    end
    result.sort! { |a, b| a[:event_id] <=> b[:event_id] }
    return result
  end

  def self.slot_accepts?(slot, object)
    return false if slot == nil || object == nil
    return false unless slot[:group] == object[:group]
    key_ok = slot[:keys].include?("*") || slot[:keys].include?(object[:key])
    return false unless key_ok
    required_direction = slot[:direction].to_i
    return true if required_direction == 0
    return object[:event].direction == required_direction
  end

  #--------------------------------------------------------------------------
  # ● 任務連動
  #--------------------------------------------------------------------------
  def self.quest_interpreter(preferred = nil)
    return preferred if preferred != nil
    if $game_map != nil && $game_map.respond_to?(:interpreter)
      interpreter = $game_map.interpreter
      return interpreter if interpreter != nil
    end
    return Game_Interpreter.new if defined?(Game_Interpreter)
    return nil
  end

  def self.can_call?(interpreter, method_name)
    return false if interpreter == nil
    begin
      return interpreter.respond_to?(method_name, true)
    rescue
      return interpreter.respond_to?(method_name)
    end
  end

  def self.quest_call(interpreter, method_name, *args)
    return nil unless can_call?(interpreter, method_name)
    begin
      return interpreter.send(method_name, *args)
    rescue
      return nil
    end
  end

  def self.active?(group, interpreter = nil)
    cfg = config(group)
    switch_id = cfg[:enabled_switch].to_i
    return false if switch_id > 0 && ($game_switches == nil || !$game_switches[switch_id])
    quest_id = cfg[:quest_id].to_i
    objective_id = cfg[:objective_id].to_i
    return true if quest_id <= 0
    qi = quest_interpreter(interpreter)
    if cfg[:require_quest_revealed]
      return false unless can_call?(qi, :quest_revealed?)
      return false unless quest_call(qi, :quest_revealed?, quest_id)
    end
    if cfg[:require_objective_revealed] && objective_id >= 0
      return false unless can_call?(qi, :objective_revealed?)
      return false unless quest_call(qi, :objective_revealed?, quest_id, objective_id)
    end
    return true
  end

  def self.objective_complete?(group, interpreter = nil)
    cfg = config(group)
    quest_id = cfg[:quest_id].to_i
    objective_id = cfg[:objective_id].to_i
    return false if quest_id <= 0 || objective_id < 0
    qi = quest_interpreter(interpreter)
    return false unless can_call?(qi, :objective_complete?)
    return quest_call(qi, :objective_complete?, quest_id, objective_id) == true
  end

  def self.complete_objective_for(group, interpreter = nil)
    cfg = config(group)
    quest_id = cfg[:quest_id].to_i
    objective_id = cfg[:objective_id].to_i
    next_id = cfg[:next_objective_id].to_i
    return if quest_id <= 0 || objective_id < 0
    qi = quest_interpreter(interpreter)
    unless objective_complete?(group, qi)
      quest_call(qi, :complete_objective, quest_id, objective_id)
    end
    if next_id >= 0
      quest_call(qi, :reveal_objective, quest_id, next_id)
    end
  end

  def self.uncomplete_objective_for(group, interpreter = nil)
    cfg = config(group)
    return unless cfg[:auto_uncomplete]
    quest_id = cfg[:quest_id].to_i
    objective_id = cfg[:objective_id].to_i
    next_id = cfg[:next_objective_id].to_i
    return if quest_id <= 0 || objective_id < 0
    qi = quest_interpreter(interpreter)
    quest_call(qi, :uncomplete_objective, quest_id, objective_id)
    if cfg[:conceal_next_when_undone] && next_id >= 0
      quest_call(qi, :conceal_objective, quest_id, next_id)
    end
  end

  #--------------------------------------------------------------------------
  # ● Self Switch / Switch / Variable
  #--------------------------------------------------------------------------
  def self.set_self_switch(event_id, letter, value, target_map_id = nil)
    return if $game_self_switches == nil
    target_map_id = map_id if target_map_id == nil
    letter = letter.to_s.upcase
    return unless ["A", "B", "C", "D"].include?(letter)
    key = [target_map_id.to_i, event_id.to_i, letter]
    value = value ? true : false
    return if $game_self_switches[key] == value
    $game_self_switches[key] = value
    $game_map.need_refresh = true if $game_map != nil && $game_map.map_id == target_map_id.to_i
  end

  def self.set_switch(id, value)
    id = id.to_i
    return if id <= 0 || $game_switches == nil
    $game_switches[id] = value ? true : false
    $game_map.need_refresh = true if $game_map != nil
  end

  def self.set_variable(id, value)
    id = id.to_i
    return if id <= 0 || $game_variables == nil
    $game_variables[id] = value
  end

  #--------------------------------------------------------------------------
  # ● 音效與共同事件
  #--------------------------------------------------------------------------
  def self.play_se(setting)
    return if setting == nil
    begin
      case setting
      when :decision
        Sound.play_decision if defined?(Sound)
      when :buzzer
        Sound.play_buzzer if defined?(Sound)
      when :cancel
        Sound.play_cancel if defined?(Sound)
      when Array
        name = setting[0].to_s
        volume = setting[1] == nil ? 80 : setting[1].to_i
        pitch = setting[2] == nil ? 100 : setting[2].to_i
        RPG::SE.new(name, volume, pitch).play unless name.empty?
      when String
        RPG::SE.new(setting, 80, 100).play unless setting.empty?
      end
    rescue
      # 缺檔時不讓支線整個崩潰，聲音少一個總比存檔少一個好。
    end
  end

  def self.queue_common_event(common_event_id)
    common_event_id = common_event_id.to_i
    return if common_event_id <= 0 || $game_temp == nil
    $game_temp.fsop_common_event_queue.push(common_event_id)
  end

  def self.queue_result_common_events(group, result)
    cfg = config(group)
    queue_common_event(cfg[:drop_common_event])
    case result
    when :correct, :complete
      queue_common_event(cfg[:correct_common_event])
    when :wrong
      queue_common_event(cfg[:wrong_common_event])
    when :ground
      queue_common_event(cfg[:ground_common_event])
    when :occupied
      queue_common_event(cfg[:occupied_common_event])
    end
  end

  #--------------------------------------------------------------------------
  # ● 位置保存與復原
  #--------------------------------------------------------------------------
  def self.remember_home(event)
    key = position_key(event)
    return if homes.has_key?(key)
    data = event.instance_variable_get(:@event) rescue nil
    x = data != nil && data.respond_to?(:x) ? data.x : event.x
    y = data != nil && data.respond_to?(:y) ? data.y : event.y
    direction = event.direction
    homes[key] = [x, y, direction]
  end

  def self.save_position(event)
    remember_home(event)
    positions[position_key(event)] = [event.x, event.y, event.direction]
  end

  def self.move_event(event, position)
    return false if event == nil || position == nil
    x = position[0].to_i
    y = position[1].to_i
    direction = position[2].to_i
    event.moveto(x, y)
    event.set_direction(direction) if [2, 4, 6, 8].include?(direction) && event.respond_to?(:set_direction)
    save_position(event)
    return true
  end

  def self.restore_position(event)
    remember_home(event)
    position = positions[position_key(event)]
    return false if position == nil
    return move_event(event, position)
  end

  def self.restore_current_map
    objects.each do |data|
      remember_home(data[:event])
      restore_position(data[:event])
    end
    groups_on_map.each { |group| refresh_group(group, nil, true) }
  end

  #--------------------------------------------------------------------------
  # ● 放置點判定與畫面狀態
  #--------------------------------------------------------------------------
  def self.slot_status(slot)
    occupants = objects_at(slot[:event].x, slot[:event].y, slot[:group])
    occupied = !occupants.empty?
    correct = false
    wrong = false
    if occupants.size == 1
      correct = slot_accepts?(slot, occupants[0])
      wrong = !correct
    elsif occupants.size > 1
      wrong = true
    end
    return {
      :occupied => occupied,
      :correct => correct,
      :wrong => wrong,
      :occupants => occupants
    }
  end

  def self.apply_slot_switches(slot, status)
    event_id = slot[:event_id]
    set_self_switch(event_id, "A", status[:correct])
    set_self_switch(event_id, "B", status[:wrong])
    set_self_switch(event_id, "C", status[:occupied])
  end

  def self.required_slots(group)
    return slots(group).select { |slot| !slot[:optional] }
  end

  def self.required_count(group)
    return required_slots(group).size
  end

  def self.correct_count(group)
    count = 0
    required_slots(group).each do |slot|
      count += 1 if slot_status(slot)[:correct]
    end
    return count
  end

  def self.physically_complete?(group)
    cfg = config(group)
    total = required_count(group)
    return false if total <= 0
    needed = cfg[:required_count].to_i
    needed = total if needed <= 0 || needed > total
    return correct_count(group) >= needed
  end

  def self.completed?(group)
    return completed_states[state_key(group)] == true
  end

  def self.set_object_locks(group, value)
    cfg = config(group)
    letter = cfg[:object_lock_switch]
    objects(group).each do |data|
      set_self_switch(data[:event_id], letter, value)
    end
  end

  def self.update_progress_variables(group)
    cfg = config(group)
    set_variable(cfg[:progress_variable], correct_count(group))
    set_variable(cfg[:total_variable], required_count(group))
  end

  def self.refresh_group(group, interpreter = nil, allow_transition = true)
    group = normalize_group(group)
    slots(group).each do |slot|
      apply_slot_switches(slot, slot_status(slot))
    end
    update_progress_variables(group)

    physical = physically_complete?(group)
    old_state = completed?(group)
    cfg = config(group)
    key = state_key(group)

    is_active = active?(group, interpreter)
    if physical && (old_state || is_active)
      completed_states[key] = true
      set_switch(cfg[:complete_switch], true)
      set_object_locks(group, true) if cfg[:lock_when_complete]
      if allow_transition && !old_state && is_active
        complete_objective_for(group, interpreter)
        queue_common_event(cfg[:complete_common_event])
      end
    elsif old_state && !cfg[:lock_when_complete]
      completed_states[key] = false
      set_switch(cfg[:complete_switch], false)
      set_object_locks(group, false)
      uncomplete_objective_for(group, interpreter) if allow_transition
    elsif !old_state
      set_switch(cfg[:complete_switch], false)
      set_object_locks(group, false) unless cfg[:lock_when_complete]
    end
    return completed?(group)
  end

  def self.refresh_all(interpreter = nil)
    groups_on_map.each { |group| refresh_group(group, interpreter, true) }
  end

  #--------------------------------------------------------------------------
  # ● 拿起與放下
  #--------------------------------------------------------------------------
  def self.pickup(interpreter, event)
    data = object_data(event)
    if data == nil
      set_last(:invalid, :invalid, event == nil ? 0 : event.id, 0)
      play_se(:buzzer)
      return :invalid
    end
    group = data[:group]
    cfg = config(group)

    unless active?(group, interpreter)
      set_last(group, :inactive, event.id, 0)
      play_se(:buzzer)
      return :inactive
    end

    if cfg[:lock_when_complete] && completed?(group)
      set_last(group, :locked, event.id, 0)
      play_se(:buzzer)
      return :locked
    end

    unless interpreter.respond_to?(:get_on_event_test) && interpreter.respond_to?(:get_on_event)
      set_last(group, :missing_dependency, event.id, 0)
      play_se(:buzzer)
      return :missing_dependency
    end

    can_pickup = interpreter.get_on_event_test
    unless can_pickup
      set_last(group, :blocked, event.id, 0)
      play_se(:buzzer)
      return :blocked
    end

    remember_home(event)
    origin = [event.x, event.y, event.direction]
    success = interpreter.get_on_event
    unless success
      set_last(group, :blocked, event.id, 0)
      play_se(:buzzer)
      return :blocked
    end

    pending_origins[position_key(event)] = origin
    refresh_group(group, interpreter, true)
    set_last(group, :picked, event.id, 0)
    play_se(cfg[:pickup_se])
    return :picked
  end

  def self.policy_position(event, policy)
    policy = policy.to_sym rescue :allow
    case policy
    when :previous, :reject
      return pending_origins[position_key(event)] || positions[position_key(event)] || homes[position_key(event)]
    when :home
      return homes[position_key(event)]
    end
    return nil
  end

  def self.classify_drop(object)
    event = object[:event]
    same_slots = slots_at(event.x, event.y, object[:group])
    return [:ground, nil] if same_slots.empty?

    slot = same_slots[0]
    occupants = objects_at(event.x, event.y, object[:group])
    other_occupants = occupants.select { |data| data[:event_id] != object[:event_id] }
    return [:occupied, slot] unless other_occupants.empty?
    return [slot_accepts?(slot, object) ? :correct : :wrong, slot]
  end

  def self.drop(interpreter, event)
    data = object_data(event)
    if data == nil
      set_self_switch(event.id, "D", false) if event != nil
      set_last(:invalid, :invalid, event == nil ? 0 : event.id, 0)
      play_se(:buzzer)
      return :invalid
    end

    group = data[:group]
    cfg = config(group)
    result = :invalid
    slot = nil

    unless active?(group, interpreter)
      result = :inactive
    else
      result, slot = classify_drop(data)
      policy = case result
      when :wrong then cfg[:wrong_policy]
      when :ground then cfg[:ground_policy]
      when :occupied then cfg[:occupied_policy]
      else :allow
      end
      target = policy_position(event, policy)
      move_event(event, target) if target != nil
      save_position(event)
    end

    pending_origins.delete(position_key(event))
    old_completed = completed?(group)
    now_completed = refresh_group(group, interpreter, true)
    result = :complete if now_completed && !old_completed

    slot_id = slot == nil ? 0 : slot[:event_id]
    set_last(group, result, event.id, slot_id)
    if [:correct, :wrong, :ground, :occupied, :complete].include?(result)
      queue_result_common_events(group, result)
    end

    case result
    when :complete
      play_se(cfg[:complete_se])
    when :correct
      play_se(cfg[:correct_se])
    when :wrong
      play_se(cfg[:wrong_se])
    when :ground
      play_se(cfg[:ground_se])
    when :occupied
      play_se(cfg[:occupied_se])
    when :inactive
      play_se(:buzzer)
    end

    # 乗り物拡張的放下通知 D 必須在本頁結束前關閉。
    set_self_switch(event.id, "D", false)
    return result
  end

  #--------------------------------------------------------------------------
  # ● 重置
  #--------------------------------------------------------------------------
  def self.reset(group, reset_quest = false, interpreter = nil)
    group = normalize_group(group)
    current = carried_event
    if current != nil
      current_data = object_data(current)
      return :carried if current_data != nil && current_data[:group] == group
    end

    cfg = config(group)
    objects(group).each do |data|
      event = data[:event]
      remember_home(event)
      home = homes[position_key(event)]
      move_event(event, home) if home != nil
      positions.delete(position_key(event))
      pending_origins.delete(position_key(event))
      set_self_switch(event.id, "D", false)
      set_self_switch(event.id, cfg[:object_lock_switch], false)
    end

    slots(group).each do |slot|
      set_self_switch(slot[:event_id], "A", false)
      set_self_switch(slot[:event_id], "B", false)
      set_self_switch(slot[:event_id], "C", false)
    end

    completed_states.delete(state_key(group))
    set_switch(cfg[:complete_switch], false)
    set_variable(cfg[:progress_variable], 0)
    set_variable(cfg[:total_variable], required_count(group))

    if reset_quest
      qi = quest_interpreter(interpreter)
      quest_id = cfg[:quest_id].to_i
      objective_id = cfg[:objective_id].to_i
      next_id = cfg[:next_objective_id].to_i
      if quest_id > 0 && objective_id >= 0
        quest_call(qi, :uncomplete_objective, quest_id, objective_id)
        quest_call(qi, :conceal_objective, quest_id, next_id) if next_id >= 0
      end
    end

    set_last(group, :none, 0, 0)
    $game_map.need_refresh = true if $game_map != nil
    return :reset
  end
end

#==============================================================================
# ■ Game_System：保存資料
#==============================================================================
if defined?(Game_System)
  class Game_System
    def fsop_positions
      @fsop_positions = {} if @fsop_positions == nil
      return @fsop_positions
    end

    def fsop_homes
      @fsop_homes = {} if @fsop_homes == nil
      return @fsop_homes
    end

    def fsop_completed_states
      @fsop_completed_states = {} if @fsop_completed_states == nil
      return @fsop_completed_states
    end
  end
end

#==============================================================================
# ■ Game_Temp：暫存資料與共同事件佇列
#==============================================================================
if defined?(Game_Temp)
  class Game_Temp
    attr_accessor :fsop_last_group
    attr_accessor :fsop_last_result
    attr_accessor :fsop_last_object_id
    attr_accessor :fsop_last_slot_id

    def fsop_pending_origins
      @fsop_pending_origins = {} if @fsop_pending_origins == nil
      return @fsop_pending_origins
    end

    def fsop_common_event_queue
      @fsop_common_event_queue = [] if @fsop_common_event_queue == nil
      return @fsop_common_event_queue
    end
  end
end

#==============================================================================
# ■ Game_Map：地圖載入時復原物件位置；安全送出共同事件
#==============================================================================
if defined?(Game_Map)
  class Game_Map
    unless method_defined?(:fsop_object_placement_setup)
      alias fsop_object_placement_setup setup
      def setup(map_id)
        fsop_object_placement_setup(map_id)
        FS_ObjectPlacement.restore_current_map
      end
    end

    unless method_defined?(:fsop_object_placement_update)
      alias fsop_object_placement_update update
      def update
        fsop_object_placement_update
        if $game_temp != nil && $game_temp.common_event_id.to_i == 0
          queue = $game_temp.fsop_common_event_queue
          $game_temp.common_event_id = queue.shift.to_i unless queue.empty?
        end
      end
    end
  end
end

#==============================================================================
# ■ Game_Interpreter：事件公開指令
#==============================================================================
if defined?(Game_Interpreter)
  class Game_Interpreter
    def fs_place_pickup
      event = $game_map == nil ? nil : $game_map.events[@event_id]
      return FS_ObjectPlacement.pickup(self, event)
    end

    def fs_place_drop
      event = $game_map == nil ? nil : $game_map.events[@event_id]
      return FS_ObjectPlacement.drop(self, event)
    end

    def fs_place_refresh(group = nil)
      if group == nil
        FS_ObjectPlacement.refresh_all(self)
      else
        FS_ObjectPlacement.refresh_group(group, self, true)
      end
    end

    def fs_place_reset(group, reset_quest = false)
      return FS_ObjectPlacement.reset(group, reset_quest, self)
    end

    def fs_place_completed?(group)
      return FS_ObjectPlacement.completed?(group)
    end

    def fs_place_correct_count(group)
      return FS_ObjectPlacement.correct_count(group)
    end

    def fs_place_required_count(group)
      return FS_ObjectPlacement.required_count(group)
    end

    def fs_place_last_result
      return FS_ObjectPlacement.last_result
    end

    def fs_place_last_object_id
      return FS_ObjectPlacement.last_object_id
    end

    def fs_place_last_slot_id
      return FS_ObjectPlacement.last_slot_id
    end
  end
end
