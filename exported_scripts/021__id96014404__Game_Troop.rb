#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Troop
# 【用途】管理戰鬥敵群、戰鬥事件、回合數、掉落與敵人行動。
# 【主要機制】Scene_Battle 與 Game_Interpreter 使用它執行 Troop Event；Enemy Summon 等功能也會擴充此層。
# 【主要影響】Game_Troop
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：LETTER_TABLE。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
# ** Game_Troop
#------------------------------------------------------------------------------
#  這個類用來操控敵人隊伍資料和一切與作戰相關的資料，同樣用於處理作戰事件指令。
#  這個類的實例被全域變數 $game_troop 所引用。
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # * 寫在敵人名稱後的字元
  #--------------------------------------------------------------------------
  LETTER_TABLE = [ '[A]','[B]','[C]','[D]','[E]','[F]','[G]','[H]','[I]','[J]',
                   '[K]','[L]','[M]','[N]','[O]','[P]','[Q]','[R]','[S]','[T]',
                   '[U]','[V]','[W]','[X]','[Y]','[Z]']
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :screen                   # 作戰畫面狀態
  attr_reader   :interpreter              # 作戰事件直譯器
  attr_reader   :event_flags              # 作戰事件已經執行的標幟
  attr_reader   :turn_count               # 回合數
  attr_reader   :name_counts              # 緩存敵人名稱的 HASH 表
  attr_accessor :can_escape               # 允許撤退的標幟
  attr_accessor :can_lose                 # 失敗後繼續劇情的標幟
  attr_accessor :preemptive               # 先發制人標幟
  attr_accessor :surprise                 # 偷襲標幟
  attr_accessor :turn_ending              # 回合結束進程標幟
  attr_accessor :forcing_battler          # 強制下達作戰指令的物件
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    super
    @screen = Game_Screen.new
    @interpreter = Game_Interpreter.new
    @event_flags = {}
    @enemies = []       # 敵人隊員們（敵人物件陣列）
    clear
  end
  #--------------------------------------------------------------------------
  # * 獲取隊員資訊
  #--------------------------------------------------------------------------
  def members
    return @enemies
  end
  
  def enemies
    return members
  end
  #--------------------------------------------------------------------------
  # * 清零
  #--------------------------------------------------------------------------
  def clear
    @screen.clear
    @interpreter.clear
    @event_flags.clear
    @enemies = []
    @turn_count = 0
    @names_count = {}
    @can_escape = false
    @can_lose = false
    @preemptive = false
    @surprise = false
    @turn_ending = false
    @forcing_battler = nil
  end
  #--------------------------------------------------------------------------
  # * 獲取隊員隊伍資訊
  #--------------------------------------------------------------------------
  def troop
    return $data_troops[@troop_id]
  end
  #--------------------------------------------------------------------------
  # * 設置
  #     troop_id : 敵人隊伍編號
  #--------------------------------------------------------------------------
  def setup(troop_id)
    clear
    @troop_id = troop_id
    @enemies = []
    for member in troop.members
      next if $data_enemies[member.enemy_id] == nil
      enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
      enemy.hidden = member.hidden
      enemy.immortal = member.immortal
      enemy.screen_x = member.x
      enemy.screen_y = member.y
      @enemies.push(enemy)
    end
    make_unique_names
  end
  #--------------------------------------------------------------------------
  # * 在名稱雷同的敵人的名稱後寫上用於區分的字元
  #--------------------------------------------------------------------------
  def make_unique_names
    for enemy in members
      next unless enemy.exist?
      next unless enemy.letter.empty?
      n = @names_count[enemy.original_name]
      n = 0 if n == nil
      enemy.letter = LETTER_TABLE[n % LETTER_TABLE.size]
      @names_count[enemy.original_name] = n + 1
    end
    for enemy in members
      n = @names_count[enemy.original_name]
      n = 0 if n == nil
      enemy.plural = true if n >= 2
    end
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    @screen.update
  end
  #--------------------------------------------------------------------------
  # * 獲取敵人名稱陣列資訊
  #    顯示于作戰開始時，重複的名字都將被刪除。
  #--------------------------------------------------------------------------
  def enemy_names
    names = []
    for enemy in members
      next unless enemy.exist?
      next if names.include?(enemy.original_name)
      names.push(enemy.original_name)
    end
    return names
  end
  #--------------------------------------------------------------------------
  # * 判定作戰事件（頁）的執行條件是否得到滿足
  #     page : 作戰事件頁
  #--------------------------------------------------------------------------
  def conditions_met?(page)
    c = page.condition
    if not c.turn_ending and not c.turn_valid and not c.enemy_valid and
       not c.actor_valid and not c.switch_valid
      return false      # 未設置條件則不執行
    end
    if @event_flags[page]
      return false      # 已執行
    end
    if c.turn_ending    # 在回合結束時
      return false unless @turn_ending
    end
    if c.turn_valid     # 回合數
      n = @turn_count
      a = c.turn_a
      b = c.turn_b
      return false if (b == 0 and n != a)
      return false if (b > 0 and (n < 1 or n < a or n % b != a % b))
    end
    if c.enemy_valid    # 敵人
      enemy = $game_troop.members[c.enemy_index]
      return false if enemy == nil
      return false if enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
    end
    if c.actor_valid    # 主角
      actor = $game_actors[c.actor_id]
      return false if actor == nil 
      return false if actor.hp * 100.0 / actor.maxhp > c.actor_hp
    end
    if c.switch_valid   # 開關
      return false if $game_switches[c.switch_id] == false
    end
    return true         # 條件被滿足
  end
  #--------------------------------------------------------------------------
  # * 設置作戰事件
  #--------------------------------------------------------------------------
  def setup_battle_event
    return if @interpreter.running?
    if $game_temp.common_event_id > 0
      common_event = $data_common_events[$game_temp.common_event_id]
      @interpreter.setup(common_event.list)
      $game_temp.common_event_id = 0
      return
    end
    for page in troop.pages
      next unless conditions_met?(page)
      @interpreter.setup(page.list)
      if page.span <= 1
        @event_flags[page] = true
      end
      return
    end
  end
  #--------------------------------------------------------------------------
  # * 遞增回合數
  #--------------------------------------------------------------------------
  def increase_turn
    for page in troop.pages
      if page.span == 1
        @event_flags[page] = false
      end
    end
    @turn_count += 1
  end
  #--------------------------------------------------------------------------
  # * 建立作戰行為
  #--------------------------------------------------------------------------
  def make_actions
    if @preemptive
      clear_actions
    else
      for enemy in members
        enemy.make_action
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 判定隊伍是否全滅
  #--------------------------------------------------------------------------
  def all_dead?
    return existing_members.empty?
  end
  #--------------------------------------------------------------------------
  # * 統計獲得的經驗值總和
  #--------------------------------------------------------------------------
  def exp_total
    exp = 0
    for enemy in dead_members
      exp += enemy.exp unless enemy.hidden
    end
    return exp
  end
  #--------------------------------------------------------------------------
  # * 統計獲得的資金量總和
  #--------------------------------------------------------------------------
  def gold_total
    gold = 0
    for enemy in dead_members
      gold += enemy.gold unless enemy.hidden
    end
    return gold
  end
  #--------------------------------------------------------------------------
  # * 創建掉落物品陣列
  #--------------------------------------------------------------------------
  def make_drop_items
    drop_items = []
    for enemy in dead_members
      for di in [enemy.drop_item1, enemy.drop_item2]
        next if di.kind == 0
        next if rand(di.denominator) != 0
        if di.kind == 1
          drop_items.push($data_items[di.item_id])
        elsif di.kind == 2
          drop_items.push($data_weapons[di.weapon_id])
        elsif di.kind == 3
          drop_items.push($data_armors[di.armor_id])
        end
      end
    end
    return drop_items
  end
end
