#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Enemy
# 【用途】VX 敵人戰鬥資料類，管理敵人參數、行動條件、掉落、變身與戰鬥座標。
# 【主要機制】繼承 Game_Battler；敵人等級、AI、召喚、圖鑑等插件會在此層擴充。
# 【主要影響】Game_Enemy
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
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
# ** Game_Enemy
#------------------------------------------------------------------------------
#  這個類用來操控敵方人物，這個類作為 Game_troop 類($game_troop)的內部類使用。
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :index                    # 隊伍中隊員編號
  attr_reader   :enemy_id                 # 敵人類型編號
  attr_reader   :original_name            # 原始名稱
  attr_accessor :letter                   # 要附加於敵人名稱之後的字母
  attr_accessor :plural                   # 有多個敵人出現的標幟
  attr_accessor :screen_x                 # 作戰畫面X座標
  attr_accessor :screen_y                 # 作戰畫面Y座標
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     index    : 隊伍內隊員編號
  #     enemy_id : 敵人類型編號
  #--------------------------------------------------------------------------
  def initialize(index, enemy_id)
    super()
    @index = index
    @enemy_id = enemy_id
    enemy = $data_enemies[@enemy_id]
    @original_name = enemy.name
    @letter = ''
    @plural = false
    @screen_x = 0
    @screen_y = 0
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = maxhp
    @mp = maxmp
  end
  #--------------------------------------------------------------------------
  # * 判定是否是主角（當然要返回false了喔~）
  #--------------------------------------------------------------------------
  def actor?
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取敵人物件資訊
  #--------------------------------------------------------------------------
  def enemy
    return $data_enemies[@enemy_id]
  end
  #--------------------------------------------------------------------------
  # * 獲取敵人顯示名資訊
  #--------------------------------------------------------------------------
  def name
    if @plural
      return @original_name + letter
    else
      return @original_name
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取基礎HP上限值資訊
  #--------------------------------------------------------------------------
  def base_maxhp
    return enemy.maxhp
  end
  #--------------------------------------------------------------------------
  # * 獲取基礎MP上限值資訊
  #--------------------------------------------------------------------------
  def base_maxmp
    return enemy.maxmp
  end
  #--------------------------------------------------------------------------
  # * 獲取基礎攻擊力資訊
  #--------------------------------------------------------------------------
  def base_atk
    return enemy.atk
  end
  #--------------------------------------------------------------------------
  # * 獲取基礎防禦力資訊
  #--------------------------------------------------------------------------
  def base_def
    return enemy.def
  end
  #--------------------------------------------------------------------------
  # * 獲取基礎精神意志力資訊
  #--------------------------------------------------------------------------
  def base_spi
    return enemy.spi
  end
  #--------------------------------------------------------------------------
  # * 獲取基礎敏捷力資訊
  #--------------------------------------------------------------------------
  def base_agi
    return enemy.agi
  end
  #--------------------------------------------------------------------------
  # * 獲取命中率資訊
  #--------------------------------------------------------------------------
  def hit
    return enemy.hit
  end
  #--------------------------------------------------------------------------
  # * 獲取迴避率資訊
  #--------------------------------------------------------------------------
  def eva
    return enemy.eva
  end
  #--------------------------------------------------------------------------
  # * 獲取會心一擊率資訊
  #--------------------------------------------------------------------------
  def cri
    return enemy.has_critical ? 10 : 0
  end
  #--------------------------------------------------------------------------
  # * 獲取攻擊優勢資訊
  #--------------------------------------------------------------------------
  def odds
    return 1
  end
  #--------------------------------------------------------------------------
  # * 獲取屬性調整度資訊
  #     element_id : 屬性編號
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    rank = enemy.element_ranks[element_id]
    result = [0,200,150,100,50,0,-100][rank]
    for state in states
      result /= 2 if state.element_set.include?(element_id)
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 獲取狀態附加成功率資訊
  #     state_id : 狀態編號
  #--------------------------------------------------------------------------
  def state_probability(state_id)
    if $data_states[state_id].nonresistance
      return 100
    else
      rank = enemy.state_ranks[state_id]
      return [0,100,80,60,40,20,0][rank]
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取經驗值資訊
  #--------------------------------------------------------------------------
  def exp
    return enemy.exp
  end
  #--------------------------------------------------------------------------
  # * 獲取所攜資金資訊
  #--------------------------------------------------------------------------
  def gold
    return enemy.gold
  end
  #--------------------------------------------------------------------------
  # * 獲取掉落物品1的資訊
  #--------------------------------------------------------------------------
  def drop_item1
    return enemy.drop_item1
  end
  #--------------------------------------------------------------------------
  # * 獲取掉落物品2的資訊
  #--------------------------------------------------------------------------
  def drop_item2
    return enemy.drop_item2
  end
  #--------------------------------------------------------------------------
  # * 使用精靈物設？
  #--------------------------------------------------------------------------
  def use_sprite?
    return true
  end
  #--------------------------------------------------------------------------
  # * 獲取作戰畫面Z座標資訊
  #--------------------------------------------------------------------------
  def screen_z
    return 100
  end
  #--------------------------------------------------------------------------
  # * 執行敵人死亡處理
  #--------------------------------------------------------------------------
  def perform_collapse
    if $game_temp.in_battle and dead?
      @collapse = true
      Sound.play_enemy_collapse
    end
  end
  #--------------------------------------------------------------------------
  # * 撤退
  #--------------------------------------------------------------------------
  def escape
    @hidden = true
    @action.clear
  end
  #--------------------------------------------------------------------------
  # * 變身
  #     enemy_id : 要變身為的敵人類型的編號
  #--------------------------------------------------------------------------
  def transform(enemy_id)
    @enemy_id = enemy_id
    if enemy.name != @original_name
      @original_name = enemy.name
      @letter = ''
      @plural = false
    end
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    make_action
  end
  #--------------------------------------------------------------------------
  # * 確定執行作戰行為的條件是否得到滿足
  #     action : 作戰行為
  #--------------------------------------------------------------------------
  def conditions_met?(action)
    case action.condition_type
    when 1  # 回合數
      n = $game_troop.turn_count
      a = action.condition_param1
      b = action.condition_param2
      return false if (b == 0 and n != a)
      return false if (b > 0 and (n < 1 or n < a or n % b != a % b))
    when 2  # HP值
      hp_rate = hp * 100.0 / maxhp
      return false if hp_rate < action.condition_param1
      return false if hp_rate > action.condition_param2
    when 3  # MP值
      mp_rate = mp * 100.0 / maxmp
      return false if mp_rate < action.condition_param1
      return false if mp_rate > action.condition_param2
    when 4  # 狀態
      return false unless state?(action.condition_param1)
    when 5  # 隊伍中等級最高者的等級
      return false if $game_party.max_level < action.condition_param1
    when 6  # 開關
      switch_id = action.condition_param1
      return false if $game_switches[switch_id] == false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 建立作戰行為
  #--------------------------------------------------------------------------
  def make_action
    @action.clear
    return unless movable?
    available_actions = []
    rating_max = 0
    for action in enemy.actions
      next unless conditions_met?(action)
      if action.kind == 1
        next unless skill_can_use?($data_skills[action.skill_id])
      end
      available_actions.push(action)
      rating_max = [rating_max, action.rating].max
    end
    ratings_total = 0
    rating_zero = rating_max - 3
    for action in available_actions
      next if action.rating <= rating_zero
      ratings_total += action.rating - rating_zero
    end
    return if ratings_total == 0
    value = rand(ratings_total)
    for action in available_actions
      next if action.rating <= rating_zero
      if value < action.rating - rating_zero
        @action.kind = action.kind
        @action.basic = action.basic
        @action.skill_id = action.skill_id
        @action.decide_random_target
        return
      else
        value -= action.rating - rating_zero
      end
    end
  end
end
