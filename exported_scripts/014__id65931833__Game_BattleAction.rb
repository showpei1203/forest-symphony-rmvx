#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_BattleAction
# 【用途】VX 戰鬥行動資料物件，保存攻擊／防禦／技能／物品、目標與行動速度。
# 【主要機制】負責建立目標與 AI 評價；本專案 Targeting 長鏈會多次包裝 make_obj_targets 等方法，位置不可任意調整。
# 【主要影響】Game_BattleAction
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
# ** Game_BattleAction
#------------------------------------------------------------------------------
#  這個類用來操控戰鬥行為，
#  這個類作為 Game_Battler 類的內部類使用。
#==============================================================================


class Game_BattleAction
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_accessor :battler                  # 參戰者
  attr_accessor :speed                    # 速度
  attr_accessor :kind                     # 行動種類（本能/技能/物品）
  attr_accessor :basic                    # 本能（攻擊/防禦/撤退/等待）
  attr_accessor :skill_id                 # 技能編號
  attr_accessor :item_id                  # 物品編號
  attr_accessor :target_index             # 目標編號
  attr_accessor :forcing                  # 強制行動標幟
  attr_accessor :value                    # AI自動戰鬥評估度
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     battler : 參戰者
  #--------------------------------------------------------------------------
  def initialize(battler)
    @battler = battler
    clear
  end
  #--------------------------------------------------------------------------
  # * 清零
  #--------------------------------------------------------------------------
  def clear
    @speed = 0
    @kind = 0
    @basic = -1
    @skill_id = 0
    @item_id = 0
    @target_index = -1
    @forcing = false
    @value = 0
  end
  #--------------------------------------------------------------------------
  # * 獲取友隊資訊
  #--------------------------------------------------------------------------
  def friends_unit
    if battler.actor?
      return $game_party
    else
      return $game_troop
    end
  end
  #--------------------------------------------------------------------------
  # * 獲取敵人隊伍資訊
  #--------------------------------------------------------------------------
  def opponents_unit
    if battler.actor?
      return $game_troop
    else
      return $game_party
    end
  end
  #--------------------------------------------------------------------------
  # * 設置普通攻擊
  #--------------------------------------------------------------------------
  def set_attack
    @kind = 0
    @basic = 0
  end
  #--------------------------------------------------------------------------
  # * 設置防禦
  #--------------------------------------------------------------------------
  def set_guard
    @kind = 0
    @basic = 1
  end
  #--------------------------------------------------------------------------
  # * 設置技能
  #     skill_id : 技能編號
  #--------------------------------------------------------------------------
  def set_skill(skill_id)
    @kind = 1
    @skill_id = skill_id
  end
  #--------------------------------------------------------------------------
  # * 設置物品
  #     item_id : 物品編號
  #--------------------------------------------------------------------------
  def set_item(item_id)
    @kind = 2
    @item_id = item_id
  end
  #--------------------------------------------------------------------------
  # * 普通攻擊判定
  #--------------------------------------------------------------------------
  def attack?
    return (@kind == 0 and @basic == 0)
  end
  #--------------------------------------------------------------------------
  # * 防禦判定
  #--------------------------------------------------------------------------
  def guard?
    return (@kind == 0 and @basic == 1)
  end
  #--------------------------------------------------------------------------
  # * 空行為判定
  #--------------------------------------------------------------------------
  def nothing?
    return (@kind == 0 and @basic < 0)
  end
  #--------------------------------------------------------------------------
  # * 技能判定
  #--------------------------------------------------------------------------
  def skill?
    return @kind == 1
  end
  #--------------------------------------------------------------------------
  # * 獲取技能使用物件
  #--------------------------------------------------------------------------
  def skill
    return skill? ? $data_skills[@skill_id] : nil
  end
  #--------------------------------------------------------------------------
  # * 物品判定
  #--------------------------------------------------------------------------
  def item?
    return @kind == 2
  end
  #--------------------------------------------------------------------------
  # * 獲取物品使用物件
  #--------------------------------------------------------------------------
  def item
    return item? ? $data_items[@item_id] : nil
  end
  #--------------------------------------------------------------------------
  # * 判定是否用於我方單人
  #--------------------------------------------------------------------------
  def for_friend?
    return true if skill? and skill.for_friend?
    return true if item? and item.for_friend?
    return false
  end
  #--------------------------------------------------------------------------
  # * 判定是否用於我方單個瀕死者
  #--------------------------------------------------------------------------
  def for_dead_friend?
    return true if skill? and skill.for_dead_friend?
    return true if item? and item.for_dead_friend?
    return false
  end
  #--------------------------------------------------------------------------
  # * 隨機目標
  #--------------------------------------------------------------------------
  def decide_random_target
    if for_friend?
      target = friends_unit.random_target
    elsif for_dead_friend?
      target = friends_unit.random_dead_target
    else
      target = opponents_unit.random_target
    end
    if target == nil
      clear
    else
      @target_index = target.index
    end
  end
  #--------------------------------------------------------------------------
  # * 上一個目標
  #--------------------------------------------------------------------------
  def decide_last_target
    if @target_index == -1
      target = nil
    elsif for_friend?
      target = friends_unit.members[@target_index]
    else
      target = opponents_unit.members[@target_index]
    end
    if target == nil or not target.exist?
      clear
    end
  end
  #--------------------------------------------------------------------------
  # * 行為預備
  #--------------------------------------------------------------------------
  def prepare
    if battler.berserker? or battler.confusion?   # 狂暴狀態或蠱惑狀態？
      set_attack                                  # 切換為普通攻擊
    end
  end
  #--------------------------------------------------------------------------
  # * 判定行為合法性
  #    假設一個事件指令不會導致[強行下達指令……]，如果因為狀態限制或者所需
  #    物品不夠用等原因導致行為無法落實，則返回false。
  #--------------------------------------------------------------------------
  def valid?
    return false if nothing?                      # 什麼都不做
    return true if @forcing                       # 強制行動
    return false unless battler.movable?          # 無法行動
    if skill?                                     # 技能
      return false unless battler.skill_can_use?(skill)
    elsif item?                                   # 物品
      return false unless friends_unit.item_can_use?(item)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 確認行為的速度
  #--------------------------------------------------------------------------
  def make_speed
    @speed = battler.agi + rand(5 + battler.agi / 4)
    @speed += skill.speed if skill?
    @speed += item.speed if item?
    @speed += 2000 if guard?
    @speed += 1000 if attack? and battler.fast_attack
  end
  #--------------------------------------------------------------------------
  # * 創建目標陣列
  #--------------------------------------------------------------------------
  def make_targets
    if attack?
      return make_attack_targets
    elsif skill?
      return make_obj_targets(skill)
    elsif item?
      return make_obj_targets(item)
    end
  end
  #--------------------------------------------------------------------------
  # * 創建普通攻擊的目標
  #--------------------------------------------------------------------------
  def make_attack_targets
    targets = []
    if battler.confusion?
      targets.push(friends_unit.random_target)
    elsif battler.berserker?
      targets.push(opponents_unit.random_target)
    else
      targets.push(opponents_unit.smooth_target(@target_index))
    end
    if battler.dual_attack      # 連鎖攻擊
      targets += targets
    end
    return targets.compact
  end
  #--------------------------------------------------------------------------
  # * 創建物品或技能的使用目標
  #     obj : 技能或物品
  #--------------------------------------------------------------------------
  def make_obj_targets(obj)
    targets = []
    if obj.for_opponent?
      if obj.for_random?
        if obj.for_one?         # 敵方單體 隨機目標
          number_of_targets = 1
        elsif obj.for_two?      # 敵方二體 隨機目標
          number_of_targets = 2
        else                    # 敵方三體 隨機目標
          number_of_targets = 3
        end
        number_of_targets.times do
          targets.push(opponents_unit.random_target)
        end
      elsif obj.dual?           # 敵方單體 連擊
        targets.push(opponents_unit.smooth_target(@target_index))
        targets += targets
      elsif obj.for_one?        # 敵方單體
        targets.push(opponents_unit.smooth_target(@target_index))
      else                      # 敵方全體
        targets += opponents_unit.existing_members
      end
    elsif obj.for_user?         # 使用者自身
      targets.push(battler)
    elsif obj.for_dead_friend?
      if obj.for_one?           # 我方單個瀕死者
        targets.push(friends_unit.smooth_dead_target(@target_index))
      else                      # 我方所有瀕死者
        targets += friends_unit.dead_members
      end
    elsif obj.for_friend?
      if obj.for_one?           # 我方單體
        targets.push(friends_unit.smooth_target(@target_index))
      else                      # 我方全體
        targets += friends_unit.existing_members
      end
    end
    return targets.compact
  end
  #--------------------------------------------------------------------------
  # * 行為價值評估（AI自動戰鬥）
  #    @value 和 @target_index 這兩個變數將被自動設置。
  #--------------------------------------------------------------------------
  def evaluate
    if attack?
      evaluate_attack
    elsif skill?
      evaluate_skill
    else
      @value = 0
    end
    if @value > 0
      @value + rand(nil)
    end
  end
  #--------------------------------------------------------------------------
  # * 普通攻擊評估
  #--------------------------------------------------------------------------
  def evaluate_attack
    @value = 0
    for target in opponents_unit.existing_members
      value = evaluate_attack_with_target(target)
      if value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 普通攻擊評估（對於目標的指定）
  #     target : 目標參戰者
  #--------------------------------------------------------------------------
  def evaluate_attack_with_target(target)
    target.clear_action_results
    target.make_attack_damage_value(battler)
    return target.hp_damage.to_f / [target.hp, 1].max
  end
  #--------------------------------------------------------------------------
  # * 技能評估
  #--------------------------------------------------------------------------
  def evaluate_skill
    @value = 0
    unless battler.skill_can_use?(skill)
      return
    end
    if skill.for_opponent?
      targets = opponents_unit.existing_members
    elsif skill.for_user?
      targets = [battler]
    elsif skill.for_dead_friend?
      targets = friends_unit.dead_members
    else
      targets = friends_unit.existing_members
    end
    for target in targets
      value = evaluate_skill_with_target(target)
      if skill.for_all?
        @value += value
      elsif value > @value
        @value = value
        @target_index = target.index
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 技能評估（對於目標的指定）
  #     target : 目標參戰者
  #--------------------------------------------------------------------------
  def evaluate_skill_with_target(target)
    target.clear_action_results
    target.make_obj_damage_value(battler, skill)
    if skill.for_opponent?
      return target.hp_damage.to_f / [target.hp, 1].max
    else
      recovery = [-target.hp_damage, target.maxhp - target.hp].min
      return recovery.to_f / target.maxhp
    end
  end
end
