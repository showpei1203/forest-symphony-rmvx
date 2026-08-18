#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Actor
# 【用途】VX 主角戰鬥資料類，管理角色等級、經驗、技能、裝備、參數與角色圖像。
# 【主要機制】繼承 Game_Battler，並被裝備、成長、召喚、角色 Profile 等大量 FS 系統擴充。
# 【主要影響】Game_Actor
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
# ** Game_Actor
#------------------------------------------------------------------------------
#  這個類用來操控主角，這個類作為 Game_Actors 類的內部類使用。
#  這個類的實例被類 Game_Party ($game_party) 所引用。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :name                     # 主角名
  attr_reader   :character_name           # 人物特徵圖圖檔名
  attr_reader   :character_index          # 人物特徵圖編號
  attr_reader   :face_name                # 頭像圖圖檔名
  attr_reader   :face_index               # 頭像圖編號
  attr_reader   :class_id                 # 職業編號
  attr_reader   :weapon_id                # 手持武器編號
  attr_reader   :armor1_id                # 手持護盾編號
  attr_reader   :armor2_id                # 頭戴護具編號
  attr_reader   :armor3_id                # 身穿護具編號
  attr_reader   :armor4_id                # 佩戴護具編號
  attr_reader   :level                    # 主角等級
  attr_reader   :exp                      # 經驗值
  attr_accessor :last_skill_id            # 游標記憶用：技能
  attr_accessor :temp_exp, :temp_level
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     actor_id : 主角編號
  #--------------------------------------------------------------------------
  def initialize(actor_id)
    super()
    setup(actor_id)
    @last_skill_id = 0
    @temp_exp = 0
    @temp_level = 1
  end
  #--------------------------------------------------------------------------
  # * 設置
  #     actor_id : 主角編號
  #--------------------------------------------------------------------------
  def setup(actor_id)
    actor = $data_actors[actor_id]
    @actor_id = actor_id
    @name = actor.name
    @character_name = actor.character_name
    @character_index = actor.character_index
    @face_name = actor.face_name
    @face_index = actor.face_index
    @class_id = actor.class_id
    @weapon_id = actor.weapon_id
    @armor1_id = actor.armor1_id
    @armor2_id = actor.armor2_id
    @armor3_id = actor.armor3_id
    @armor4_id = actor.armor4_id
    @level = actor.initial_level
    @exp_list = Array.new(101)
    make_exp_list
    @exp = @exp_list[@level]
    @skills = []
    for i in self.class.learnings
      learn_skill(i.skill_id) if i.level <= @level
    end
    clear_extra_values
    recover_all
  end
  #--------------------------------------------------------------------------
  # * 判定是否是主角（當然要返回true了喔~）
  #--------------------------------------------------------------------------
  def actor?
    return true
  end
  #--------------------------------------------------------------------------
  # * 獲取主角編號資訊
  #--------------------------------------------------------------------------
  def id
    return @actor_id
  end
  #--------------------------------------------------------------------------
  # * 獲取主角在隊伍內的編號資訊
  #--------------------------------------------------------------------------
  def index
    return $game_party.members.index(self)
  end
  #--------------------------------------------------------------------------
  # * 獲取主角物件資訊
  #--------------------------------------------------------------------------
  def actor
    return $data_actors[@actor_id]
  end
  #--------------------------------------------------------------------------
  # * 獲取類物件資訊
  #--------------------------------------------------------------------------
  def class
    return $data_classes[@class_id]
  end
  #--------------------------------------------------------------------------
  # * 獲取技能物件陣列資訊
  #--------------------------------------------------------------------------
  def skills
    result = []
    for i in @skills
      result.push($data_skills[i])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 獲取武器物件陣列資訊
  #--------------------------------------------------------------------------
  def weapons
    result = []
    result.push($data_weapons[@weapon_id])
    if two_swords_style
      result.push($data_weapons[@armor1_id])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 獲取護具物件陣列資訊
  #--------------------------------------------------------------------------
  def armors
    result = []
    unless two_swords_style
      result.push($data_armors[@armor1_id])
    end
    result.push($data_armors[@armor2_id])
    result.push($data_armors[@armor3_id])
    result.push($data_armors[@armor4_id])
    return result
  end
  #--------------------------------------------------------------------------
  # * 獲取已佩戴的裝備的物件的陣列資訊
  #--------------------------------------------------------------------------
  def equips
    return weapons + armors
  end
  #--------------------------------------------------------------------------
  # * 計算經驗值
  #--------------------------------------------------------------------------
  def make_exp_list
    @exp_list[1] = @exp_list[100] = 0
    m = actor.exp_basis
    n = 0.75 + actor.exp_inflation / 200.0;
    for i in 2..99
      @exp_list[i] = @exp_list[i-1] + Integer(m)
      m *= 1 + n;
      n *= 0.9;
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取屬性調整度
  #     element_id : 屬性編號
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    rank = self.class.element_ranks[element_id]
    result = [0,200,150,100,50,0,-100][rank]
    for armor in armors.compact
      result /= 2 if armor.element_set.include?(element_id)
    end
    for state in states
      result /= 2 if state.element_set.include?(element_id)
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 獲取狀態附加的成功率
  #     state_id : 狀態編號
  #--------------------------------------------------------------------------
  def state_probability(state_id)
    if $data_states[state_id].nonresistance
      return 100
    else
      rank = self.class.state_ranks[state_id]
      return [0,100,80,60,40,20,0][rank]
    end
  end
  #--------------------------------------------------------------------------
  # * 判定狀態是否被免疫
  #     state_id : 狀態編號
  #--------------------------------------------------------------------------
  def state_resist?(state_id)
    for armor in armors.compact
      return true if armor.state_set.include?(state_id)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取普通攻擊屬性資訊
  #--------------------------------------------------------------------------
  def element_set
    result = []
    if weapons.compact == []
      return [1]                  # 空手：格鬥屬性
    end
    for weapon in weapons.compact
      result |= weapon == nil ? [] : weapon.element_set
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 獲取普通攻擊所附加的影響（即改變狀態）
  #--------------------------------------------------------------------------
  def plus_state_set
    result = []
    for weapon in weapons.compact
      result |= weapon == nil ? [] : weapon.state_set
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 獲取HP上限值的上限資訊
  #--------------------------------------------------------------------------
  def maxhp_limit
    return 9999
  end
  #--------------------------------------------------------------------------
  # * 獲取初始HP上限值資訊
  #--------------------------------------------------------------------------
  def base_maxhp
    return actor.parameters[0, @level]
  end
  #--------------------------------------------------------------------------
  # * 獲取初始MP上限值資訊
  #--------------------------------------------------------------------------
  def base_maxmp
    return actor.parameters[1, @level]
  end
  #--------------------------------------------------------------------------
  # * 獲取初始攻擊力資訊
  #--------------------------------------------------------------------------
  def base_atk
    n = actor.parameters[2, @level]# +50# + base_atk_KGC_PassiveSkill
    for item in equips.compact do n += item.atk end
    return n
  end
  #--------------------------------------------------------------------------
  # * 獲取初始防禦力資訊
  #--------------------------------------------------------------------------
  def base_def
    n = actor.parameters[3, @level]
    for item in equips.compact do n += item.def end
    return n
  end
  #--------------------------------------------------------------------------
  # * 獲取初始精神意志力資訊
  #--------------------------------------------------------------------------
  def base_spi 
    n = actor.parameters[4, @level]
    for item in equips.compact do n += item.spi end
    return n
  end
  #--------------------------------------------------------------------------
  # * 獲取初始敏捷力資訊
  #--------------------------------------------------------------------------
  def base_agi
    n = actor.parameters[5, @level]
    for item in equips.compact do n += item.agi end
    return n
  end
  #--------------------------------------------------------------------------
  # * 獲取命中成功率資訊
  #--------------------------------------------------------------------------
  def hit
    if two_swords_style
      n1 = weapons[0] == nil ? 95 : weapons[0].hit
      n2 = weapons[1] == nil ? 95 : weapons[1].hit
      n = [n1, n2].min
    else
      n = weapons[0] == nil ? 95 : weapons[0].hit
    end
    ###
    for item in armors.compact
      n += item.hit
    end
    #n = hit_KGC_PassiveSkill + passive_params[:hit]
    #n = n * passive_params_rate[:hit] / 100
    #return Integer(n)
    return n
  end
  #--------------------------------------------------------------------------
  # * 獲取規避成功率資訊
  #--------------------------------------------------------------------------
  def eva
    n = 5
    for item in armors.compact do n += item.eva end
    return n
  end
  #--------------------------------------------------------------------------
  # * 獲取會心一擊成功率資訊
  #--------------------------------------------------------------------------
  def cri
    n = 4
    n += 4 if actor.critical_bonus
    for weapon in weapons.compact
      n += 4 if weapon.critical_bonus
    end
    return n
  end
  #--------------------------------------------------------------------------
  # * 獲取挨揍優先率資訊
  #--------------------------------------------------------------------------
  def odds
    return 4 - self.class.position
  end
  #--------------------------------------------------------------------------
  # * 獲取[雙手武器（貳刀流）]選項真偽資訊
  #--------------------------------------------------------------------------
  def two_swords_style
    return actor.two_swords_style
  end
  #--------------------------------------------------------------------------
  # * 獲取[不能更換裝備]選項真偽資訊
  #--------------------------------------------------------------------------
  def fix_equipment
    return actor.fix_equipment
  end
  #--------------------------------------------------------------------------
  # * 獲取[AI自動戰鬥]選項真偽資訊
  #--------------------------------------------------------------------------
  def auto_battle
    return actor.auto_battle
  end
  #--------------------------------------------------------------------------
  # * 獲取[2-4倍強力防禦]選項真偽資訊
  #--------------------------------------------------------------------------
  def super_guard
    return actor.super_guard
  end
  #--------------------------------------------------------------------------
  # * 獲取[該主角擅長用藥]選項真偽資訊
  #--------------------------------------------------------------------------
  def pharmacology
    return actor.pharmacology
  end
  #--------------------------------------------------------------------------
  # * 獲取[回合內先發制人]選項真偽資訊
  #--------------------------------------------------------------------------
  def fast_attack
    for weapon in weapons.compact
      return true if weapon.fast_attack
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取[連擊]選項真偽資訊
  #--------------------------------------------------------------------------
  def dual_attack
    for weapon in weapons.compact
      return true if weapon.dual_attack
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取[防止會心一擊]選項真偽資訊
  #--------------------------------------------------------------------------
  def prevent_critical
    for armor in armors.compact
      return true if armor.prevent_critical
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取[MP消耗減半]選項真偽資訊
  #--------------------------------------------------------------------------
  def half_mp_cost
    for armor in armors.compact
      return true if armor.half_mp_cost
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取[獲得雙倍EXP]選項真偽資訊
  #--------------------------------------------------------------------------
  def double_exp_gain
    for armor in armors.compact
      return true if armor.double_exp_gain
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取[自動恢復HP]選項真偽資訊
  #--------------------------------------------------------------------------
  def auto_hp_recover
    for armor in armors.compact
      return true if armor.auto_hp_recover
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取普通攻擊動畫編號資訊
  #--------------------------------------------------------------------------
  def atk_animation_id
    if two_swords_style
      return weapons[0].animation_id if weapons[0] != nil
      return weapons[1] == nil ? 1 : 0
    else
      return weapons[0] == nil ? 1 : weapons[0].animation_id
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取普通攻擊動畫編號資訊（貳刀流：另一隻手）
  #--------------------------------------------------------------------------
  def atk_animation_id2
    if two_swords_style
      return weapons[1] == nil ? 0 : weapons[1].animation_id
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取經驗值字串資訊
  #--------------------------------------------------------------------------
  def exp_s
    return @exp_list[@level+1] > 0 ? @exp : "-------"
  end
  #--------------------------------------------------------------------------
  # * 獲取等級提升所需總經驗值字串資訊
  #--------------------------------------------------------------------------
  def next_exp_s
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1] : "-------"
  end
  #--------------------------------------------------------------------------
  # * 獲取等級提升所欠經驗值字串資訊
  #--------------------------------------------------------------------------
  def next_rest_exp_s
    return @exp_list[@level+1] > 0 ?
      (@exp_list[@level+1] - @exp) : "-------"
  end
  #--------------------------------------------------------------------------
  # * 更換裝備（指定編號）
  #     equip_type : 裝備部位 (0..4)
  #     item_id    : 武器或護具的類型編號
  #     test       : 測試標幟（用於臨時更換裝備或作戰測試等情形）
  #    本指令受事件指令所調用，亦用於戰前準備。
  #--------------------------------------------------------------------------
  def change_equip_by_id(equip_type, item_id, test = false)
    if equip_type == 0 or (equip_type == 1 and two_swords_style)
      change_equip(equip_type, $data_weapons[item_id], test)
    else
      change_equip(equip_type, $data_armors[item_id], test)
    end
  end
  #--------------------------------------------------------------------------
  # * 更換裝備（指定物件）
  #     equip_type : 裝備部位 (0..4)
  #     item_id    : 武器或護具的類型編號
  #     test       : 測試標幟（用於臨時更換裝備或作戰測試等情形）
  #--------------------------------------------------------------------------
  def change_equip(equip_type, item, test = false)
    last_item = equips[equip_type]
    unless test
      return if $game_party.item_number(item) == 0 if item != nil
      $game_party.gain_item(last_item, 1)
      $game_party.lose_item(item, 1)
    end
    item_id = item == nil ? 0 : item.id
    case equip_type
    when 0  # 武器
      @weapon_id = item_id
      unless two_hands_legal?             # 雙手執拿武器的場合
        change_equip(1, nil, test)        # 自動卸下另一隻手上的裝備
      end
    when 1  # 護盾
      @armor1_id = item_id
      unless two_hands_legal?             # 雙手執拿武器的場合
        change_equip(0, nil, test)        # 自動卸下另一隻手上的裝備
      end
    when 2  # 頭戴
      @armor2_id = item_id
    when 3  # 身穿
      @armor3_id = item_id
    when 4  # 佩飾
      @armor4_id = item_id
    end
  end
  #--------------------------------------------------------------------------
  # * 丟棄裝備
  #     item : 要丟棄的武器或護具
  #    用於增減武器或防具時(同時選中了[允許變更主角裝備]這個真偽標記)。
  #--------------------------------------------------------------------------
  def discard_equip(item)
    if item.is_a?(RPG::Weapon)
      if @weapon_id == item.id
        @weapon_id = 0
      elsif two_swords_style and @armor1_id == item.id
        @armor1_id = 0
      end
    elsif item.is_a?(RPG::Armor)
      if not two_swords_style and @armor1_id == item.id
        @armor1_id = 0
      elsif @armor2_id == item.id
        @armor2_id = 0
      elsif @armor3_id == item.id
        @armor3_id = 0
      elsif @armor4_id == item.id
        @armor4_id = 0
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 判斷雙手執拿的裝備
  #--------------------------------------------------------------------------
  def two_hands_legal?
    if weapons[0] != nil and weapons[0].two_handed
      return false if @armor1_id != 0
    end
    if weapons[1] != nil and weapons[1].two_handed
      return false if @weapon_id != 0
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 判定裝備是否可以佩戴
  #     item : 物品條目
  #--------------------------------------------------------------------------
  def equippable?(item)
    if item.is_a?(RPG::Weapon)
      return self.class.weapon_set.include?(item.id)
    elsif item.is_a?(RPG::Armor)
      return false if two_swords_style and item.kind == 0
      return self.class.armor_set.include?(item.id)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 更改經驗值
  #     exp  : 新的經驗值
  #     show : 等級提升提示標幟
  #--------------------------------------------------------------------------
  def change_exp(exp, show)
    last_level = @level
    last_skills = skills
    @exp = [[exp, 9999999].min, 0].max
    while @exp >= @exp_list[@level+1] and @exp_list[@level+1] > 0
      level_up
    end
    while @exp < @exp_list[@level]
      level_down
    end
    @hp = [@hp, maxhp].min
    @mp = [@mp, maxmp].min
    if show and @level > last_level
      display_level_up(skills - last_skills)
    end
  end
  #--------------------------------------------------------------------------
  # * 等級提升
  #--------------------------------------------------------------------------
  def level_up
    @level += 1
    for learning in self.class.learnings
      learn_skill(learning.skill_id) if learning.level == @level
    end
  end
  #--------------------------------------------------------------------------
  # * 等級下降
  #--------------------------------------------------------------------------
  def level_down
    @level -= 1
  end
  #--------------------------------------------------------------------------
  # * 顯示等級提升的提示訊息
  #     new_skills : 新習得的技能的陣列
  #--------------------------------------------------------------------------
  def display_level_up(new_skills)
    $game_message.new_page
    text = sprintf(Vocab::LevelUp, @name, Vocab::level, @level)
    $game_message.texts.push(text)
    for skill in new_skills
      text = sprintf(Vocab::ObtainSkill, skill.name)
      $game_message.texts.push(text)
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取經驗值資訊（在裝備了經驗值翻倍的裝備的情況下）
  #     exp  : 經驗值增量
  #     show : 等級提升提示標幟
  #--------------------------------------------------------------------------
  def gain_exp(exp, show)
    if double_exp_gain
      change_exp(@exp + exp * 2, show)
    else
      change_exp(@exp + exp, show)
    end
  end
  #--------------------------------------------------------------------------
  # * 更改等級
  #     level : 新的等級
  #     show  : 等級提升提示標幟
  #--------------------------------------------------------------------------
  def change_level(level, show)
    level = [[level, 99].min, 1].max
    change_exp(@exp_list[level], show)
  end
  #--------------------------------------------------------------------------
  # * 習得技能
  #     skill_id : 技能編號
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    unless skill_learn?($data_skills[skill_id])
      @skills.push(skill_id)
      @skills.sort!
    end
  end
  #--------------------------------------------------------------------------
  # * 遺忘技能
  #     skill_id : 技能編號
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #--------------------------------------------------------------------------
  # * 判斷技能是否已經習得
  #     skill : 技能
  #--------------------------------------------------------------------------
  def skill_learn?(skill)
    return @skills.include?(skill.id)
  end
  #--------------------------------------------------------------------------
  # * 判定技能可用性
  #     skill : 技能
  #--------------------------------------------------------------------------
  def skill_can_use?(skill)
    return false unless skill_learn?(skill)
    return super
  end
  #--------------------------------------------------------------------------
  # * 變更主角名稱
  #     name : 新名稱
  #--------------------------------------------------------------------------
  def name=(name)
    @name = name
  end
  #--------------------------------------------------------------------------
  # * 變更主角職業（主角轉職）
  #     class_id : 新的職業
  #--------------------------------------------------------------------------
  def class_id=(class_id)
    @class_id = class_id
    for i in 0..4     # 移除目前不可用的裝備
      change_equip(i, nil) unless equippable?(equips[i])
    end
  end
  #--------------------------------------------------------------------------
  # * 更改主角圖片
  #     character_name  : 新的人物特徵圖圖檔名
  #     character_index : 新的人物特徵圖編號
  #     face_name       : 新的頭像圖圖檔名
  #     face_index      : 新的頭像圖編號
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_index, face_name, face_index)
    @character_name = character_name
    @character_index = character_index
    @face_name = face_name
    @face_index = face_index
  end
  #--------------------------------------------------------------------------
  # * 使用了精靈物設？
  #--------------------------------------------------------------------------
  def use_sprite?
    return false
  end
  #--------------------------------------------------------------------------
  # * 主角瀕死處理
  #--------------------------------------------------------------------------
  def perform_collapse
    if $game_temp.in_battle and dead?
      @collapse = true
      Sound.play_actor_collapse
    end
  end
  #--------------------------------------------------------------------------
  # * 主角HP自動恢復處理（呼叫於每回合結束時）
  #--------------------------------------------------------------------------
  def do_auto_recovery
    if auto_hp_recover and not dead?
      self.hp += maxhp / 20
    end
  end
  #--------------------------------------------------------------------------
  # * 創建作戰行為（用於AI自動戰鬥）
  #--------------------------------------------------------------------------
  def make_action
    @action.clear
    return unless movable?
    action_list = []
    action = Game_BattleAction.new(self)
    action.set_attack
    action.evaluate
    action_list.push(action)
    for skill in skills
      action = Game_BattleAction.new(self)
      action.set_skill(skill.id)
      action.evaluate
      action_list.push(action)
    end
    max_value = 0
    for action in action_list
      if action.value > max_value
        @action = action
        max_value = action.value
      end
    end
  end
end
