#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_DynamicCaptureRate v1.4
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_DynamicCaptureRate v1.4」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RPG::State、RPG::Enemy、Game_Enemy、Game_Battler、Window_Help、Albert_CaptureRate
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MIN_RATE、MAX_RATE、HP_BONUS_TABLE、CUMULATIVE_HP_BONUS、AUTO_DETECT_ARMOR_MAPPING、AUTO_DETECT_CAPTURE_NAME、CAPTURE_NAME_WORDS、HELP_SHOW。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：AlbertDynamicCaptureRate、EnemyGuide；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
#==============================================================================
# ■ Albert_DynamicCaptureRate v1.4
#    RPG Maker VX / RGSS2
#------------------------------------------------------------------------------
# 目的：擴充既有 KGC Steal，讓「魂刻擷取」成功率依戰況動態變化。
#
# 最終擷取率 = 基礎擷取率
#            + HP 加成
#            + 狀態加成
#            + 特殊條件加成
#            + 裝備加成
#
# 重要：
#  - 動態公式只套用在「魂刻／擷取物件」。
#  - 一般道具、武器、金錢的偷竊，維持原 KGC Steal 判定方式。
#  - 魂刻可自動辨識：若偷取的是 Armor，且該 Armor ID 存在於
#    ArmorMapping.mapping，即視為魂刻。
#  - 也可在任意物品／武器／防具 NOTE 寫 <capture_object> 強制指定。
#  - 戰鬥選擇敵人時，在「敵人名字 Help Window」顯示目前魂刻擷取率。
#------------------------------------------------------------------------------
# 安裝位置：
#  建議放在以下腳本之下、Main 之上：
#   - KGC Steal
#   - ArmorMapping / 召喚系統
#
#  v1.4 不再使用 Scene_Battle#start 的延遲安裝。
#  直接在腳本載入時擴充 Window_Help#set_text_n01add，避免其他戰鬥腳本
#  覆寫 Scene_Battle#start 導致安裝程式根本沒有執行。
#
#  另外擴充魂刻辨識：
#    1. Armor NOTE 有 <capture_object>
#    2. Armor ID 存在 ArmorMapping.mapping
#    3. Armor 名稱含「魂刻／魂殼／魂壳／刻印」
#  三者符合任一即可視為魂刻。
#------------------------------------------------------------------------------
# 一、敵人原本的 KGC Steal 標籤仍照用
#
# <steal A:120 10%>
#
# 代表魂刻 Armor ID 120 的基礎擷取率為 10%。
# 建議魂刻一律使用「百分比格式」，不要使用分母格式。
#------------------------------------------------------------------------------
# 二、HP 加成
#
# 在下方 Albert_CaptureRate::HP_BONUS_TABLE 統一設定。
# 預設採累積制：
#   HP <= 70% : +5
#   HP <= 50% : 再 +10
#   HP <= 30% : 再 +15
#   HP <= 10% : 再 +15
#
# 因此：
#   60% HP => +5
#   40% HP => +15
#   20% HP => +30
#    8% HP => +45
#------------------------------------------------------------------------------
# 三、狀態加成
#
# 寫在 State NOTE：
#   <capture_bonus: 10>
#   <capture_bonus: -10>
#
# 敵人身上所有具有 capture_bonus 的狀態會累加。
#------------------------------------------------------------------------------
# 四、特殊條件加成
#
# 寫在 Enemy NOTE：
#
#   <capture_switch_bonus: 25, 10>
#     開關 25 ON 時，+10%。
#
#   <capture_variable_bonus: 12, >=, 5, 15>
#     變數 12 >= 5 時，+15%。
#
# 支援運算子：>=  <=  ==  =  >  <
# 可寫多行，全部符合者會累加。
#------------------------------------------------------------------------------
# 五、裝備加成
#
# 完整沿用 KGC Steal 原本的：
#   <steal_prob_plus +15%>
#
# 因此不需要重新做另一套裝備標籤。
#------------------------------------------------------------------------------
# 六、擷取率上限與下限
#
# 預設：0% ~ 85%
# 可在 Albert_CaptureRate 模組修改。
#------------------------------------------------------------------------------
# 七、除錯／UI 使用
#
# 每次對魂刻執行擷取後，敵方 Game_Enemy 會保存：
#   enemy.albert_last_capture_rate
#   enemy.albert_last_capture_parts
#
# parts 內容：
#   :base, :hp, :state, :special, :equip, :final
#
# 方便未來做「全知儀顯示擷取率」或戰鬥訊息補丁。
#==============================================================================

$imported = {} if $imported == nil
$imported["AlbertDynamicCaptureRate"] = true

#==============================================================================
# ■ 設定
#==============================================================================
module Albert_CaptureRate
  # 最終成功率上下限
  MIN_RATE = 0
  MAX_RATE = 85

  # HP 加成表：[HP百分比門檻, 加成]
  # 預設為累積制。
  HP_BONUS_TABLE = [
    [70,  5],
    [50, 10],
    [30, 15],
    [10, 15],
  ]

  # true  = 累積全部符合的門檻
  # false = 只採用第一個符合門檻的加成
  CUMULATIVE_HP_BONUS = true

  # true = ArmorMapping.mapping 中的 Armor 自動視為魂刻／擷取物件
  AUTO_DETECT_ARMOR_MAPPING = true

  # true = Armor 名稱包含下列關鍵字時，也視為魂刻。
  # 這是為了避免某個魂刻尚未加入 ArmorMapping 時，UI 與動態公式整個失效。
  AUTO_DETECT_CAPTURE_NAME = true
  CAPTURE_NAME_WORDS = ["魂刻", "魂殼", "魂壳", "刻印"]

  #--------------------------------------------------------------------------
  # 敵人名字 Help Window 顯示設定
  #--------------------------------------------------------------------------
  HELP_SHOW = true
  HELP_LABEL = "魂刻擷取率"

  # true  = 沒有可擷取魂刻時，也顯示「不可擷取」
  # false = 沒有魂刻時完全不顯示
  # 建議測試階段先維持 true，這樣能一眼分辨是 UI 沒執行，還是魂刻沒被辨識。
  HELP_SHOW_UNAVAILABLE = true
  HELP_UNAVAILABLE_TEXT = "不可擷取"

  # 顯示位置。你目前的 set_text_n01add 會在中央畫敵人名稱，
  # 元素圖示約從 x=200 開始，因此預設放左側。
  HELP_X = 4
  HELP_WIDTH = 175
  HELP_TEXT_SIZE = 16

  # 用誰的裝備加成來預覽目前擷取率。
  # 本專案由喬伊負責擷取，因此預設 Actor ID = 1。
  CAPTURE_USER_ACTOR_ID = 1

  #--------------------------------------------------------------------------
  # ○ 取得 StealObject 對應的資料庫物件
  #--------------------------------------------------------------------------
  def self.database_object(sobj)
    return nil if sobj == nil
    case sobj.kind
    when 1
      return $data_items[sobj.item_id]
    when 2
      return $data_weapons[sobj.weapon_id]
    when 3
      return $data_armors[sobj.armor_id]
    end
    return nil
  end

  #--------------------------------------------------------------------------
  # ○ 是否屬於魂刻／擷取物件
  #--------------------------------------------------------------------------
  def self.capture_object?(sobj)
    return false if sobj == nil

    db_obj = database_object(sobj)

    # 1. 明確 Note 指定，優先度最高。
    if db_obj != nil && db_obj.respond_to?(:note)
      return true if db_obj.note =~ /<capture_object>/i
    end

    # 2. ArmorMapping 對應。使用 has_key? 兼容 RGSS2 的 Ruby 1.8。
    if AUTO_DETECT_ARMOR_MAPPING && sobj.kind == 3
      begin
        if defined?(ArmorMapping) && ArmorMapping.respond_to?(:mapping)
          mapping = ArmorMapping.mapping
          if mapping != nil && mapping.respond_to?(:has_key?)
            return true if mapping.has_key?(sobj.armor_id)
          end
        end
      rescue
        # ArmorMapping 尚未初始化時，不讓 HUD 因此報錯。
      end
    end

    # 3. 名稱關鍵字備援。
    if AUTO_DETECT_CAPTURE_NAME && sobj.kind == 3 && db_obj != nil
      name = db_obj.name.to_s
      CAPTURE_NAME_WORDS.each do |word|
        return true if name.include?(word)
      end
    end

    return false
  end

  #--------------------------------------------------------------------------
  # ○ 百分比顯示格式
  #--------------------------------------------------------------------------
  def self.rate_text(rate)
    value = rate.to_f
    integer = value.to_i
    return integer.to_s if (value - integer).abs < 0.001
    return sprintf("%.1f", value)
  end

  #--------------------------------------------------------------------------
  # ○ 數值比較
  #--------------------------------------------------------------------------
  def self.compare(value, operator, target)
    case operator
    when ">="
      return value >= target
    when "<="
      return value <= target
    when "==", "="
      return value == target
    when ">"
      return value > target
    when "<"
      return value < target
    end
    return false
  end
end

#==============================================================================
# ■ RPG::State
#==============================================================================
class RPG::State
  #--------------------------------------------------------------------------
  # ○ 狀態提供的擷取率加成
  #--------------------------------------------------------------------------
  def albert_capture_bonus
    return @albert_capture_bonus unless @albert_capture_bonus == nil

    @albert_capture_bonus = 0
    self.note.each_line do |line|
      if line =~ /<capture_bonus:\s*([+-]?\d+)>/i
        @albert_capture_bonus += $1.to_i
      end
    end

    return @albert_capture_bonus
  end
end

#==============================================================================
# ■ RPG::Enemy
#==============================================================================
class RPG::Enemy
  #--------------------------------------------------------------------------
  # ○ 特殊條件：開關加成
  #    回傳 [[switch_id, bonus], ...]
  #--------------------------------------------------------------------------
  def albert_capture_switch_bonuses
    return @albert_capture_switch_bonuses unless @albert_capture_switch_bonuses == nil

    @albert_capture_switch_bonuses = []
    self.note.each_line do |line|
      if line =~ /<capture_switch_bonus:\s*(\d+)\s*,\s*([+-]?\d+)>/i
        @albert_capture_switch_bonuses << [$1.to_i, $2.to_i]
      end
    end

    return @albert_capture_switch_bonuses
  end

  #--------------------------------------------------------------------------
  # ○ 特殊條件：變數加成
  #    回傳 [[variable_id, operator, target_value, bonus], ...]
  #--------------------------------------------------------------------------
  def albert_capture_variable_bonuses
    return @albert_capture_variable_bonuses unless @albert_capture_variable_bonuses == nil

    @albert_capture_variable_bonuses = []
    self.note.each_line do |line|
      if line =~ /<capture_variable_bonus:\s*(\d+)\s*,\s*(>=|<=|==|=|>|<)\s*,\s*(-?\d+)\s*,\s*([+-]?\d+)>/i
        @albert_capture_variable_bonuses << [$1.to_i, $2, $3.to_i, $4.to_i]
      end
    end

    return @albert_capture_variable_bonuses
  end
end

#==============================================================================
# ■ Game_Enemy
#==============================================================================
class Game_Enemy < Game_Battler
  attr_reader :albert_last_capture_rate
  attr_reader :albert_last_capture_parts

  #--------------------------------------------------------------------------
  # ○ HP 加成
  #--------------------------------------------------------------------------
  def albert_capture_hp_bonus
    return 0 if self.maxhp <= 0

    hp_rate = self.hp * 100.0 / self.maxhp
    bonus = 0

    Albert_CaptureRate::HP_BONUS_TABLE.each do |data|
      threshold = data[0]
      value = data[1]
      next unless hp_rate <= threshold

      bonus += value
      break unless Albert_CaptureRate::CUMULATIVE_HP_BONUS
    end

    return bonus
  end

  #--------------------------------------------------------------------------
  # ○ 狀態加成
  #--------------------------------------------------------------------------
  def albert_capture_state_bonus
    bonus = 0
    self.states.compact.each do |state|
      bonus += state.albert_capture_bonus
    end
    return bonus
  end

  #--------------------------------------------------------------------------
  # ○ 特殊條件加成
  #--------------------------------------------------------------------------
  def albert_capture_special_bonus(user, sobj)
    bonus = 0

    self.enemy.albert_capture_switch_bonuses.each do |data|
      switch_id = data[0]
      value = data[1]
      bonus += value if $game_switches[switch_id]
    end

    self.enemy.albert_capture_variable_bonuses.each do |data|
      variable_id = data[0]
      operator = data[1]
      target_value = data[2]
      value = data[3]
      current = $game_variables[variable_id]

      if Albert_CaptureRate.compare(current, operator, target_value)
        bonus += value
      end
    end

    # 預留擴充鉤子，例如：BREAK、命中弱點次數、Boss 階段等。
    bonus += albert_capture_custom_bonus(user, sobj)

    return bonus
  end

  #--------------------------------------------------------------------------
  # ○ 自訂特殊條件鉤子
  #    預設 0。未來其他補丁可 alias 此方法追加判定。
  #--------------------------------------------------------------------------
  def albert_capture_custom_bonus(user, sobj)
    return 0
  end

  #--------------------------------------------------------------------------
  # ○ 基礎擷取率
  #    百分比標籤：直接使用 success_prob。
  #    分母標籤：換算成 100 / denominator，僅供相容。
  #--------------------------------------------------------------------------
  def albert_capture_base_rate(user, sobj)
    if sobj.success_prob > 0
      rate = sobj.success_prob.to_f
    else
      denominator = [sobj.denominator, 1].max
      rate = 100.0 / denominator
    end

    # 保留 KGC 的敏捷模式相容性。
    # 目前你的專案 AGILITY_BASED_STEAL = false，所以正常不會進入此段。
    if KGC::Steal::AGILITY_BASED_STEAL
      enemy_agi = [self.agi, 1].max
      rate = rate * user.agi.to_f / enemy_agi
    end

    return rate
  end

  #--------------------------------------------------------------------------
  # ○ 計算最終擷取率與各部分
  #    store_result = true 時保存到 albert_last_capture_*。
  #    Help Window 預覽使用 false，避免只是看資訊就改寫「最後一次擷取結果」。
  #--------------------------------------------------------------------------
  def albert_capture_rate_result(user, sobj, store_result = true)
    return nil if user == nil || sobj == nil

    base_bonus = albert_capture_base_rate(user, sobj)
    hp_bonus = albert_capture_hp_bonus
    state_bonus = albert_capture_state_bonus
    special_bonus = albert_capture_special_bonus(user, sobj)

    equip_bonus = 0
    if user.respond_to?(:steal_prob_plus)
      equip_bonus = user.steal_prob_plus
    end

    final_rate = base_bonus + hp_bonus + state_bonus + special_bonus + equip_bonus
    final_rate = [final_rate, Albert_CaptureRate::MIN_RATE].max
    final_rate = [final_rate, Albert_CaptureRate::MAX_RATE].min

    parts = {
      :base    => base_bonus,
      :hp      => hp_bonus,
      :state   => state_bonus,
      :special => special_bonus,
      :equip   => equip_bonus,
      :final   => final_rate,
    }

    if store_result
      @albert_last_capture_rate = final_rate
      @albert_last_capture_parts = parts
    end

    return [final_rate, parts]
  end

  #--------------------------------------------------------------------------
  # ○ 正式擷取判定使用：保存最後結果
  #--------------------------------------------------------------------------
  def albert_calculate_capture_rate(user, sobj)
    return albert_capture_rate_result(user, sobj, true)
  end

  #--------------------------------------------------------------------------
  # ○ UI 預覽使用：不改寫最後結果
  #--------------------------------------------------------------------------
  def albert_preview_capture_rate(user, sobj)
    return albert_capture_rate_result(user, sobj, false)
  end

  #--------------------------------------------------------------------------
  # ○ 取得目前尚未被擷取的第一個魂刻物件
  #--------------------------------------------------------------------------
  def albert_capture_object_for_hud
    return nil unless respond_to?(:steal_objects)

    objects = self.steal_objects
    return nil if objects == nil

    objects.each do |sobj|
      next if sobj == nil
      return sobj if Albert_CaptureRate.capture_object?(sobj)
    end

    return nil
  end

  #--------------------------------------------------------------------------
  # ○ UI 預覽使用的擷取角色
  #--------------------------------------------------------------------------
  def albert_capture_user_for_hud
    return nil if $game_actors == nil
    actor_id = Albert_CaptureRate::CAPTURE_USER_ACTOR_ID
    return $game_actors[actor_id]
  end

  #--------------------------------------------------------------------------
  # ○ 目前顯示用的擷取率
  #--------------------------------------------------------------------------
  def albert_current_capture_rate(user = nil)
    sobj = albert_capture_object_for_hud
    return nil if sobj == nil

    user = albert_capture_user_for_hud if user == nil
    return nil if user == nil

    result = albert_preview_capture_rate(user, sobj)
    return nil if result == nil
    return result[0]
  end
end

#==============================================================================
# ■ Game_Battler
#    重寫 KGC Steal 的成功判定：
#      - 魂刻：使用動態擷取公式
#      - 非魂刻：維持原 KGC Steal 邏輯
#==============================================================================
class Game_Battler
  def make_obj_steal_result(user, obj)
    return unless obj.steal?
    return if @skipped || @missed || @evaded

    if self.steal_objects.compact.empty?
      @stolen_object = :no_item
      return
    end

    @stolen_object = nil
    stolen_index = -1

    self.steal_objects.each_with_index do |sobj, i|
      next if sobj == nil

      success = false

      #--------------------------------------------------------------------
      # 魂刻／擷取物件：動態擷取率
      #--------------------------------------------------------------------
      if self.is_a?(Game_Enemy) && Albert_CaptureRate.capture_object?(sobj)
        result = self.albert_calculate_capture_rate(user, sobj)
        final_rate = result[0]

        # 使用 0...9999 亂數，支援小數百分比且避免原 KGC 的邊界偏差。
        success = rand(10000) < (final_rate * 100).to_i

      #--------------------------------------------------------------------
      # 一般偷竊物：維持原 KGC Steal 邏輯
      #--------------------------------------------------------------------
      else
        if sobj.success_prob > 0
          success_prob = sobj.success_prob

          if KGC::Steal::AGILITY_BASED_STEAL
            enemy_agi = [self.agi, 1].max
            success_prob = success_prob * user.agi / enemy_agi
          end

          success = !(success_prob + user.steal_prob_plus < rand(100))
        else
          if rand(sobj.denominator) == 0
            success = true
          else
            success = !(user.steal_prob_plus < rand(100))
          end
        end
      end

      next unless success

      #--------------------------------------------------------------------
      # 偷竊／擷取成功
      #--------------------------------------------------------------------
      @stolen_object = sobj
      stolen_index = i

      if $imported["EnemyGuide"]
        self_id = (self.actor? ? self.id : self.enemy_id)
        KGC::Commands.set_enemy_object_stolen(self_id, stolen_index)
      end

      break
    end

    if stolen_index != -1
      @steal_objects[stolen_index] = nil
    end
  end
end

#==============================================================================
# ■ Window_Help#set_text_n01add 直接整合版
#------------------------------------------------------------------------------
#  目前的戰鬥目標選擇流程會直接呼叫：
#    @help_window2 = Window_Help.new
#    @help_window2.set_text_n01add(@target_members[@index])
#
#  v1.4 不再等待 Scene_Battle#start 才安裝。
#  原因是大型腳本庫中 Scene_Battle#start 很可能又被其他腳本重寫，導致安裝程式
#  根本沒執行。既然 set_text_n01add 在本專案中已經存在，直接 alias 最可靠。
#==============================================================================

if defined?(Window_Help) && Window_Help.method_defined?(:set_text_n01add)
  class Window_Help < Window_Base
    unless method_defined?(:albert_capture_v14_old_set_text_n01add)
      alias albert_capture_v14_old_set_text_n01add set_text_n01add
    end

    #------------------------------------------------------------------------
    # ○ 敵人目標資訊更新
    #------------------------------------------------------------------------
    def set_text_n01add(member)
      albert_capture_v14_old_set_text_n01add(member)
      albert_draw_capture_rate_in_target_help(member)
    end

    #------------------------------------------------------------------------
    # ○ 在敵人名稱 Help Window 左側追加目前魂刻擷取率
    #------------------------------------------------------------------------
    def albert_draw_capture_rate_in_target_help(member)
      return unless Albert_CaptureRate::HELP_SHOW
      return if member == nil
      return unless member.is_a?(Game_Enemy)
      return if self.contents == nil

      rate = nil
      if member.respond_to?(:albert_current_capture_rate)
        begin
          rate = member.albert_current_capture_rate
        rescue
          rate = nil
        end
      end

      if rate == nil && !Albert_CaptureRate::HELP_SHOW_UNAVAILABLE
        return
      end

      x = Albert_CaptureRate::HELP_X.to_i
      width = Albert_CaptureRate::HELP_WIDTH.to_i
      return if width <= 0

      old_size  = self.contents.font.size
      old_bold  = self.contents.font.bold
      old_color = self.contents.font.color

      self.contents.font.size = Albert_CaptureRate::HELP_TEXT_SIZE.to_i
      self.contents.font.bold = true

      label = Albert_CaptureRate::HELP_LABEL.to_s + "："
      label_width = self.contents.text_size(label).width + 4
      label_width = [label_width, width].min

      self.contents.font.color = system_color
      self.contents.draw_text(x, 0, label_width, WLH, label, 0)

      value_text = if rate == nil
                     Albert_CaptureRate::HELP_UNAVAILABLE_TEXT.to_s
                   else
                     Albert_CaptureRate.rate_text(rate) + "%"
                   end

      value_x = x + label_width
      value_width = width - label_width
      if value_width > 0
        self.contents.font.color = normal_color
        self.contents.draw_text(value_x, 0, value_width, WLH, value_text, 0)
      end

      self.contents.font.size = old_size
      self.contents.font.bold = old_bold
      self.contents.font.color = old_color
    end
  end
end

#==============================================================================
# ■ END
#==============================================================================
