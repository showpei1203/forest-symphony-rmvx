#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Party
# 【用途】管理玩家隊伍、金錢、物品、裝備庫存、步數與隊伍成員。
# 【主要機制】Forest Symphony 的大型隊伍、召喚、經濟、商店與裝備系統都會使用此類。
# 【主要影響】Game_Party
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAX_MEMBERS。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
# ** Game_Party
#------------------------------------------------------------------------------
#  這個類用來操控主角隊伍，包含了隊伍所攜資金和物品等資訊。
#  這個類的實例被全域變數 $game_party 所引用。
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * 常數
  #--------------------------------------------------------------------------
  MAX_MEMBERS = 4                         # 在隊主角人數上限
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :gold                     # 所攜資金量
  attr_reader   :steps                    # 累計步數
  attr_accessor :last_item_id             # 游標記憶用：條目
  attr_accessor :last_actor_index         # 游標記憶用：主角
  attr_accessor :last_target_index        # 游標記憶用：目標
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize#def initialize
    super
    @gold = 0
    @steps = 0
    @last_item_id = 0
    @last_actor_index = 0
    @last_target_index = 0
    @actors = []      # 隊員類型 (主角編號)
    @items = {}       # 所攜物品 HASH 表 (物品編號)
    @weapons = {}     # 所攜武器 HASH 表 (武器編號)
    @armors = {}      # 所攜護具 HASH 表 (護具編號)
    #@ex_members = []  # 用於儲存曾經加入過隊伍的角色
  end
  #--------------------------------------------------------------------------
  # * 獲取隊員資訊
  #--------------------------------------------------------------------------
  def members
    result = []
    for i in @actors
      result.push($game_actors[i])
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # * 獲取物品物件陣列資訊 (包括武器和護具)
  #--------------------------------------------------------------------------
  def items
    result = []
    for i in @items.keys.sort
      result.push($data_items[i]) if @items[i] > 0
    end
    for i in @weapons.keys.sort
      result.push($data_weapons[i]) if @weapons[i] > 0
    end
    for i in @armors.keys.sort
      result.push($data_armors[i]) if @armors[i] > 0
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 設置隊伍初期陣容
  #--------------------------------------------------------------------------
  def setup_starting_members
    @actors = []
    for i in $data_system.party_members
      @actors.push(i)
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取隊伍名稱資訊
  #    若只有一個主角則返回這個主角的名稱，
  #    如果有多人在隊則返回“%s一行人”。（%s即領隊主角的名稱）
  #--------------------------------------------------------------------------
  def name
    if @actors.size == 0
      return ''
    elsif @actors.size == 1
      return members[0].name
    else
      return sprintf(Vocab::PartyName, members[0].name)
    end
  end
  #--------------------------------------------------------------------------
  # * 作戰測試時的主角隊伍設置
  #--------------------------------------------------------------------------
  def setup_battle_test_members
    @actors = []
    for battler in $data_system.test_battlers
      actor = $game_actors[battler.actor_id]
      actor.change_level(battler.level, false)
      actor.change_equip_by_id(0, battler.weapon_id, true)
      actor.change_equip_by_id(1, battler.armor1_id, true)
      actor.change_equip_by_id(2, battler.armor2_id, true)
      actor.change_equip_by_id(3, battler.armor3_id, true)
      actor.change_equip_by_id(4, battler.armor4_id, true)
      actor.recover_all
      @actors.push(actor.id)
    end
    @items = {}
    for i in 1...$data_items.size
      if $data_items[i].battle_ok?
        @items[i] = 99 unless $data_items[i].name.empty?
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取等級上限
  #--------------------------------------------------------------------------
  def max_level
    level = 0
    for i in @actors
      actor = $game_actors[i]
      level = actor.level if level < actor.level
    end
    return level
  end
  #--------------------------------------------------------------------------
  # * 主角入隊
  #     actor_id : 主角編號
  #--------------------------------------------------------------------------
  def add_actor(actor_id)
    if @actors.size < MAX_MEMBERS and not @actors.include?(actor_id)
      @actors.push(actor_id)
      $game_player.refresh
    end
  end
  #--------------------------------------------------------------------------
  # * 主角離隊
  #     actor_id : 主角編號
  #--------------------------------------------------------------------------
  def remove_actor(actor_id)
    @actors.delete(actor_id)
    $game_player.refresh
  end
  #--------------------------------------------------------------------------
  # * 資金變動
  #     n : 資金變動量
  #--------------------------------------------------------------------------
  def gain_gold(n)
    @gold = [[@gold + n, 0].max, 9999999].min
  end
  #--------------------------------------------------------------------------
  # * 資金損失
  #     n : 資金損失量
  #--------------------------------------------------------------------------
  def lose_gold(n)
    gain_gold(-n)
  end
  #--------------------------------------------------------------------------
  # * 累計步數
  #--------------------------------------------------------------------------
  def increase_steps
    @steps += 1
  end
  #--------------------------------------------------------------------------
  # * 獲取物品攜有量
  #     item : 物品（包括武器、護具）
  #--------------------------------------------------------------------------
  def item_number(item)
    case item
    when RPG::Item
      number = @items[item.id]
    when RPG::Weapon
      number = @weapons[item.id]
    when RPG::Armor
      number = @armors[item.id]
    end
    return number == nil ? 0 : number
  end
  #--------------------------------------------------------------------------
  # * 判定物品擁有情況
  #     item          : 物品
  #     include_equip : 算上主角身上的裝備
  #--------------------------------------------------------------------------
  def has_item?(item, include_equip = false)
    if item_number(item) > 0
      return true
    end
    if include_equip
      for actor in members
        return true if actor.equips.include?(item)
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 得失物品
  #     item          : 物品
  #     n             : 得失數量
  #     include_equip : 算上主角身上的裝備
  #--------------------------------------------------------------------------
  def gain_item(item, n, include_equip = false)
    number = item_number(item)
    case item
    when RPG::Item
      @items[item.id] = [[number + n, 0].max, 99].min
    when RPG::Weapon
      @weapons[item.id] = [[number + n, 0].max, 99].min
    when RPG::Armor
      @armors[item.id] = [[number + n, 0].max, 99].min
    end
    n += number
    if include_equip and n < 0
      for actor in members
        while n < 0 and actor.equips.include?(item)
          actor.discard_equip(item)
          n += 1
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 失去物品
  #     item          : 物品
  #     n             : 得失數量
  #     include_equip : 算上主角身上的裝備
  #--------------------------------------------------------------------------
  def lose_item(item, n, include_equip = false)
    gain_item(item, -n, include_equip)
  end
  #--------------------------------------------------------------------------
  # * 賣出物品
  #     item : 物品
  #    如果指定的物品物件允許被拿去賣錢，則執行此操作後這種物品的攜有量-1。
  #--------------------------------------------------------------------------
  def consume_item(item)
    if item.is_a?(RPG::Item) and item.consumable
      lose_item(item, 1)
    end
  end
  #--------------------------------------------------------------------------
  # * 判定物品是否可用
  #     item : 物品
  #--------------------------------------------------------------------------
  def item_can_use?(item)
    return false unless item.is_a?(RPG::Item)
    return false if item_number(item) == 0
    if $game_temp.in_battle
      return item.battle_ok?
    else
      return item.menu_ok?
    end
  end
  #--------------------------------------------------------------------------
  # * 判定是否允許輸入指令
  #    自動戰鬥也被視為允許輸入指令。
  #--------------------------------------------------------------------------
  def inputable?
    for actor in members
      return true if actor.inputable?
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 隊伍全滅判定
  #--------------------------------------------------------------------------
  def all_dead?
    if @actors.size == 0 and not $game_temp.in_battle
      return false 
    end
    return existing_members.empty?
  end
  #--------------------------------------------------------------------------
  # * 主角前進一步時的進程處理
  #--------------------------------------------------------------------------
  def on_player_walk
    for actor in members
      if actor.slip_damage?
        actor.hp -= 1 if actor.hp > 1   # 中毒所造成的傷害
        $game_map.screen.start_flash(Color.new(125,0,0,64), 30)
      end
      if actor.auto_hp_recover and actor.hp > 0
        actor.hp += 1                   # HP自動恢復
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 自動恢復處理 (呼叫於每回合結束時)
  #--------------------------------------------------------------------------
  def do_auto_recovery
    for actor in members
      actor.do_auto_recovery
    end
  end
  #--------------------------------------------------------------------------
  # * 移除作戰狀態 (呼叫于作戰結束時)
  #--------------------------------------------------------------------------
  def remove_states_battle
    for actor in members
      actor.remove_states_battle
    end
  end
end
