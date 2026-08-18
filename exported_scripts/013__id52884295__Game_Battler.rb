#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Battler
# 【用途】VX 戰鬥者核心，定義 HP/MP、能力值、狀態、命中迴避、傷害、技能與物品效果。
# 【主要機制】Game_Actor 與 Game_Enemy 的父類，也是 Forest Symphony 大量戰鬥 Patch 的核心掛載點。
# 【主要影響】Game_Battler
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
# ** Game_Battler
#------------------------------------------------------------------------------
#  這個類專門用來處理參戰者。 是用於 Game_Actor和 Game_Enemy 的超級類。
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_reader   :battler_name      # 作戰身圖圖檔名
  attr_reader   :battler_hue       # 作戰身圖偏色度[色調]
  attr_reader   :hp                # HP
  attr_reader   :mp                # MP
  attr_reader   :action            # 作戰指令
  attr_accessor :hidden            # 用來判斷參戰敵人是否半途現身的標幟
  attr_accessor :immortal          # 用來判斷參戰敵人是否不敗之身的標幟
  attr_accessor :animation_id      # 動畫ID
  attr_accessor :animation_mirror  # 用來判斷動畫是否縱向翻轉的標幟
  attr_accessor :white_flash       # 判斷是否顯示精靈物設白色閃爍效果的標幟
  attr_accessor :blink             # 用來判斷是否顯示被傷害者閃爍效果的標幟
  attr_accessor :collapse          # 用來判斷是否掛掉/瀕死的標幟
  attr_reader   :skipped           # 行動結果：判斷掠過回合的標幟
  attr_reader   :missed            # 行動結果：判斷落空行為的標幟
  attr_reader   :evaded            # 行動結果：判斷規避行為的標幟
  attr_reader   :critical          # 行動結果：判斷暴擊行為的標幟
  attr_reader   :absorbed          # 行動結果：判斷汲取行為的標幟
  attr_reader   :hp_damage         # 行動結果：HP傷害量
  attr_reader   :mp_damage         # 行動結果：MP傷害量
  attr_reader   :weak              # 行動結果：弱點
  attr_reader   :strong            # 行動結果：抵抗
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    @battler_name = ""
    @battler_hue = 0
    @hp = 0
    @mp = 0
    @action = Game_BattleAction.new(self)
    @states = []                    # 狀態（ID陣列）
    @state_turns = {}               # 狀態將彌留的回合數（雜湊表）
    @hidden = false   
    @immortal = false
    clear_extra_values
    clear_sprite_effects
    clear_action_results
  end
  #--------------------------------------------------------------------------
  # * 參戰者附加參數變動值清零
  #--------------------------------------------------------------------------
  def clear_extra_values
    @maxhp_plus = 0
    @maxmp_plus = 0
    @atk_plus = 0
    @def_plus = 0
    @spi_plus = 0
    @agi_plus = 0
  end
  #--------------------------------------------------------------------------
  # * 精靈訊息用變數清零
  #--------------------------------------------------------------------------
  def clear_sprite_effects
    @animation_id = 0
    @animation_mirror = false
    @white_flash = false
    @blink = false
    @collapse = false
  end
  #--------------------------------------------------------------------------
  # * 貯存行動結果的變數清零
  #--------------------------------------------------------------------------
  def clear_action_results
    @skipped = false
    @missed = false
    @evaded = false
    @critical = false
    @absorbed = false
    @weak = false
    @strong = false
    @hp_damage = 0
    @mp_damage = 0
    @added_states = []              # 被添加的狀態（ID陣列）
    @removed_states = []            # 被移除的狀態（ID陣列）
    @remained_states = []           # 持續保留的狀態（ID陣列）
  end
  #--------------------------------------------------------------------------
  # * 獲得目前狀態的資訊並作為一個物件陣列
  #--------------------------------------------------------------------------
  def states
    result = []
    for i in @states
      result.push($data_states[i])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 獲取由上一回合的行動所附加的狀態的資訊
  #--------------------------------------------------------------------------
  def added_states
    result = []
    for i in @added_states
      result.push($data_states[i])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 獲取由上一回合的行動所解除的狀態的資訊
  #--------------------------------------------------------------------------
  def removed_states
    result = []
    for i in @removed_states
      result.push($data_states[i])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 獲取由上一回合遺留下來的的未被解除的狀態的資訊，
  #    通俗一點說的話，舉個例子，
  #    就是有參戰者嘗試催眠一個已經進入睡眠狀態的參戰者。
  #--------------------------------------------------------------------------
  def remained_states
    result = []
    for i in @remained_states
      result.push($data_states[i])
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * 判斷上回合的行動是否對參戰者狀態有影響
  #--------------------------------------------------------------------------
  def states_active?
    return true unless @added_states.empty?
    return true unless @removed_states.empty?
    return true unless @remained_states.empty?
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取HP上限值的上限的資訊
  #--------------------------------------------------------------------------
  def maxhp_limit
    return 999999
  end
  #--------------------------------------------------------------------------
  # * 獲取HP上限值的資訊
  #--------------------------------------------------------------------------
  def maxhp
    return [[base_maxhp + @maxhp_plus, 1].max, maxhp_limit].min
  end
  #--------------------------------------------------------------------------
  # * 獲取MP上限值的資訊
  #--------------------------------------------------------------------------
  def maxmp
    return [[base_maxmp + @maxmp_plus, 0].max, 9999].min
  end
  #--------------------------------------------------------------------------
  # * 獲取攻擊力資訊
  #--------------------------------------------------------------------------
  def atk
    n = [[base_atk + @atk_plus, 1].max, 999].min
    for state in states do n *= state.atk_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #--------------------------------------------------------------------------
  # * 獲取防禦力資訊
  #--------------------------------------------------------------------------
  def def
    n = [[base_def + @def_plus, 1].max, 999].min
    for state in states do n *= state.def_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #--------------------------------------------------------------------------
  # * 獲取精神意志力資訊
  #--------------------------------------------------------------------------
  def spi
    n = [[base_spi + @spi_plus, 1].max, 999].min
    for state in states do n *= state.spi_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #--------------------------------------------------------------------------
  # * 獲取敏捷力資訊
  #--------------------------------------------------------------------------
  def agi
    n = [[base_agi + @agi_plus, 1].max, 999].min
    for state in states do n *= state.agi_rate / 100.0 end
    n = [[Integer(n), 1].max, 999].min
    return n
  end
  #--------------------------------------------------------------------------
  # * 獲取[特等防禦]參數真偽資訊
  #--------------------------------------------------------------------------
  def super_guard
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取[優先攻擊]武器參數真偽資訊
  #--------------------------------------------------------------------------
  def fast_attack
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取[雙重攻擊]武器參數真偽資訊
  #--------------------------------------------------------------------------
  def dual_attack
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取[防禦暴擊]護具參數真偽資訊
  #--------------------------------------------------------------------------
  def prevent_critical
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取[MP消耗量減半]護具參數真偽資訊
  #--------------------------------------------------------------------------
  def half_mp_cost
    return false
  end
  #--------------------------------------------------------------------------
  # * 設置HP上限值
  #     new_maxhp : 新的HP上限值
  #--------------------------------------------------------------------------
  def maxhp=(new_maxhp)
    @maxhp_plus += new_maxhp - self.maxhp
    @maxhp_plus = [[@maxhp_plus, -9999].max, 9999].min
    @hp = [@hp, self.maxhp].min
  end
  #--------------------------------------------------------------------------
  # * 設置MP上限值
  #     new_maxmp : 新的MP上限值
  #--------------------------------------------------------------------------
  def maxmp=(new_maxmp)
    @maxmp_plus += new_maxmp - self.maxmp
    @maxmp_plus = [[@maxmp_plus, -9999].max, 9999].min
    @mp = [@mp, self.maxmp].min
  end
  #--------------------------------------------------------------------------
  # * 設置攻擊力指數
  #     new_atk : 新的攻擊力指數
  #--------------------------------------------------------------------------
  def atk=(new_atk)
    @atk_plus += new_atk - self.atk
    @atk_plus = [[@atk_plus, -999].max, 999].min
  end
  #--------------------------------------------------------------------------
  # * 設置防禦力指數
  #     new_def : 新的防禦力指數
  #--------------------------------------------------------------------------
  def def=(new_def)
    @def_plus += new_def - self.def
    @def_plus = [[@def_plus, -999].max, 999].min
  end
  #--------------------------------------------------------------------------
  # * 設置精神意志力指數
  #     new_spi : 新的精神意志力指數
  #--------------------------------------------------------------------------
  def spi=(new_spi)
    @spi_plus += new_spi - self.spi
    @spi_plus = [[@spi_plus, -999].max, 999].min
  end
  #--------------------------------------------------------------------------
  # * 設置敏捷力指數
  #     new_agi : 新的敏捷力指數
  #--------------------------------------------------------------------------
  def agi=(new_agi)
    @agi_plus += new_agi - self.agi
    @agi_plus = [[@agi_plus, -999].max, 999].min
  end
  #--------------------------------------------------------------------------
  # * 變更HP值
  #     hp : 新的HP值
  #--------------------------------------------------------------------------
  def hp=(hp)
    @hp = [[hp, maxhp].min, 0].max
    if @hp == 0 and not state?(1) and not @immortal
      add_state(1)                # 附加瀕死狀態（狀態1）
      @added_states.push(1)
    elsif @hp > 0 and state?(1)
      remove_state(1)             # 解除瀕死狀態（狀態1）
      @removed_states.push(1)
    end
  end
  #--------------------------------------------------------------------------
  # * 變更MP值
  #     mp : 新的MP值
  #--------------------------------------------------------------------------
  def mp=(mp)
    @mp = [[mp, maxmp].min, 0].max
  end
  #--------------------------------------------------------------------------
  # * 恢復健康
  #--------------------------------------------------------------------------
  def recover_all
    @hp = maxhp
    @mp = maxmp
    for i in @states.clone do remove_state(i) end
  end
  #--------------------------------------------------------------------------
  # * 判定我方參戰者是否進入瀕死狀態/判定敵人是否掛掉
  #--------------------------------------------------------------------------
  def dead?
    return (not @hidden and @hp == 0 and not @immortal)
  end
  #--------------------------------------------------------------------------
  # * 判定參戰者是否還活著
  #--------------------------------------------------------------------------
  def exist?
    return (not @hidden and not dead?)
  end
  #--------------------------------------------------------------------------
  # * 判定是否可以接受輸入指令
  #--------------------------------------------------------------------------
  def inputable?
    return (not @hidden and restriction <= 1)
  end
  #--------------------------------------------------------------------------
  # * 判定是否可以行動
  #--------------------------------------------------------------------------
  def movable?
    return (not @hidden and restriction < 4)
  end
  #--------------------------------------------------------------------------
  # * 判定是否可以躲過攻擊
  #--------------------------------------------------------------------------
  def parriable?
    return (not @hidden and restriction < 5)
  end
  #--------------------------------------------------------------------------
  # * 判定參戰者是否進入失語狀態
  #--------------------------------------------------------------------------
  def silent?
    return (not @hidden and restriction == 1) #狀態附加限制：不能使用技能
  end
  #--------------------------------------------------------------------------
  # * 判定參戰者是否進入狂暴狀態[該狀態可使參戰者反復普通攻擊敵人]
  #--------------------------------------------------------------------------
  def berserker?
    return (not @hidden and restriction == 2) #狀態附加限制：反復普通攻擊敵人
  end
  #--------------------------------------------------------------------------
  # * 判定參戰者是否進入蠱惑狀態[該狀態可使參戰者反復普通攻擊隊友]
  #--------------------------------------------------------------------------
  def confusion?
    return (not @hidden and restriction == 3) #狀態附加限制：反復普通攻擊敵人
  end
  #--------------------------------------------------------------------------
  # * 判斷參戰者是否正在防禦
  #--------------------------------------------------------------------------
  def guarding?
    return @action.guard?
  end
  #--------------------------------------------------------------------------
  # * 獲取屬性調整度
  #     element_id : 屬性編號
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    return 100
  end
  #--------------------------------------------------------------------------
  # * 獲取狀態附加的成功率
  #--------------------------------------------------------------------------
  def state_probability(state_id)
    return 0
  end
  #--------------------------------------------------------------------------
  # * 判定狀態是否被防疫
  #     state_id : 狀態編號
  #--------------------------------------------------------------------------
  def state_resist?(state_id)
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取普通攻擊屬性資訊
  #--------------------------------------------------------------------------
  def element_set
    return []
  end
  #--------------------------------------------------------------------------
  # * 獲取普通攻擊所附加的狀態的資訊
  #--------------------------------------------------------------------------
  def plus_state_set
    return []
  end
  #--------------------------------------------------------------------------
  # * 獲取普通攻擊所解除的狀態的資訊
  #--------------------------------------------------------------------------
  def minus_state_set
    return []
  end
  #--------------------------------------------------------------------------
  # * 檢查狀態
  #     state_id : 狀態編號
  #    當可用的狀態成功附加至目標的時候返回true。
  #--------------------------------------------------------------------------
  def state?(state_id)
    return @states.include?(state_id)
  end
  #--------------------------------------------------------------------------
  # * 判斷狀態目前還能夠持續的回合數是否等於該狀態自動移除的回合數
  #     state_id : 狀態編號
  #    若該狀態目前還能夠持續的回合數等於該狀態自動移除的回合數則返回true。
  #--------------------------------------------------------------------------
  def state_full?(state_id)
    return false unless state?(state_id)
    return @state_turns[state_id] == $data_states[state_id].hold_turn
  end
  #--------------------------------------------------------------------------
  # * 判斷某個狀態是否應該被無視
  #     state_id : 狀態編號
  #    在下列條件全部實現的時候返回true。
  #     * 如果要附加的狀態A存在於狀態B的[與此同時解除狀態]清單中。
  #     * 狀態B事先被附加。
  #     * 如果狀態B並沒有存在於狀態A的[與此同時解除狀態]清單中。
  #    這些條件什麼時候出現？舉個例子，你嘗試使某個瀕死的參戰者中毒（徒勞），
  #    在目標此時處於像攻擊力強/弱化這樣的狀態的情況下，此舉同樣無效。
  #--------------------------------------------------------------------------
  def state_ignore?(state_id)
    for state in states
      if state.state_set.include?(state_id) and
         not $data_states[state_id].state_set.include?(state.id)
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 判斷某個狀態是否應該被抵消
  #     state_id : 狀態編號
  #    在下列條件全部實現的時候返回true。
  #     * 要附加的新狀態的[可以被抵消]這個真偽標記為真（就是核取方塊被選中）。
  #     * 要附加的新狀態的[與此同時解除狀態]清單中包含至少一個現有的狀態。
  #    這些條件什麼時候出現？舉個例子，某個參戰者附加了攻擊力強化的狀態，
  #    則之前被附加的攻擊力弱化的狀態會和這個新狀態抵消。
  #--------------------------------------------------------------------------
  def state_offset?(state_id)
    return false unless $data_states[state_id].offset_by_opposite
    for i in @states
      return true if $data_states[state_id].state_set.include?(i)
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 狀態排序
  #    將 @states 陣列的內容按狀態顯示優先順序排序，優先順序較高者排序較靠前。
  #--------------------------------------------------------------------------
  def sort_states
    @states.sort! do |a, b|
      state_a = $data_states[a]
      state_b = $data_states[b]
      if state_a.priority != state_b.priority
        state_b.priority <=> state_a.priority
      else
        a <=> b
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 附加狀態
  #     state_id : 狀態編號
  #--------------------------------------------------------------------------
  def add_state(state_id)
    state = $data_states[state_id]        # 獲取狀態資料
    return if state == nil                # 數據非法？
    return if state_ignore?(state_id)     # 是否應該無視該狀態？
    unless state?(state_id)               # 該狀態之前未曾附加過？
      unless state_offset?(state_id)      # 是否有和這個狀態相抵消的狀態？
        @states.push(state_id)            # 將狀態編號加入 @states 陣列
      end
      if state_id == 1                    # 如果是瀕死狀態的話（狀態1）
        @hp = 0                           # 將HP值清零
      end

      unless inputable?                   # 若參戰者無法行動
        @action.clear                     # 清除其作戰行動指令
      end
      for i in state.state_set            # 獲取[與此同時解除狀態]清單
        remove_state(i)                   # 並且現行解除這些狀態
        @removed_states.delete(i)         # 它們的圖示將不會再顯示
      end
      sort_states                         # 按優先順序排列狀態圖示
    end
    @state_turns[state_id] = state.hold_turn    # 設置回合編號
  end
  #--------------------------------------------------------------------------
  # * 移除狀態
  #     state_id : 狀態編號
  #--------------------------------------------------------------------------
  def remove_state(state_id)
    return unless state?(state_id)        # 要解除的狀態在目標身上不存在？
    if state_id == 1 and @hp == 0         # 如果是瀕死狀態的話（狀態1）
      @hp = 1                             # 將HP值設為1
    end
    @states.delete(state_id)              # 從 @states 陣列刪除狀態編號
    @state_turns.delete(state_id)         # 從 @state_turns 中清除
  end
  #--------------------------------------------------------------------------
  # * 獲取限制資訊
  #    獲取目前所附加的所有狀態的累計限制資訊。
  #--------------------------------------------------------------------------
  def restriction
    restriction_max = 0
    for state in states
      if state.restriction >= restriction_max
        restriction_max = state.restriction
      end
    end
    return restriction_max
  end
  #--------------------------------------------------------------------------
  # * 判定[連續傷害]狀態
  #--------------------------------------------------------------------------
  def slip_damage?
    for state in states
      return true if state.slip_damage
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 判定狀態的[使落空率上升]真偽標記是否為真
  #--------------------------------------------------------------------------
  def reduce_hit_ratio?
    for state in states
      return true if state.reduce_hit_ratio
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * 獲取最重要的狀態持續訊息
  #--------------------------------------------------------------------------
  def most_important_state_text
    for state in states
      return state.message3 unless state.message3.empty?
    end
    return ""
  end
  #--------------------------------------------------------------------------
  # * 解除作戰狀態（呼叫于作戰結束時）
  #--------------------------------------------------------------------------
  def remove_states_battle
    for state in states
      remove_state(state.id) if state.battle_only
    end
  end
  #--------------------------------------------------------------------------
  # * 自然解除的狀態（每回合呼叫一次）
  #--------------------------------------------------------------------------
  def remove_states_auto
    clear_action_results
    for i in @state_turns.keys.clone
      if @state_turns[i] > 0
        @state_turns[i] -= 1
      elsif rand(100) < $data_states[i].auto_release_prob
        remove_state(i)
        @removed_states.push(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 由於受到傷害而引發的狀態解除（每當傷害產生時呼叫一次）
  #--------------------------------------------------------------------------
  def remove_states_shock
    for state in states
      if state.release_by_damage
        remove_state(state.id)
        @removed_states.push(state.id)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 對於使用技能所消耗的MP的計算
  #     skill : 技能
  #--------------------------------------------------------------------------
  def calc_mp_cost(skill)
    if half_mp_cost
      return skill.mp_cost / 2
    else
      return skill.mp_cost
    end
  end
  #--------------------------------------------------------------------------
  # * 判定技能是否可用
  #     skill : 技能
  #--------------------------------------------------------------------------
  def skill_can_use?(skill)
    return false unless skill.is_a?(RPG::Skill)
    return false unless movable?
    return false if silent? and skill.spi_f > 0
    return false if calc_mp_cost(skill) > mp
    if $game_temp.in_battle
      return skill.battle_ok?
    else
      return skill.menu_ok?
    end
  end
  #--------------------------------------------------------------------------
  # * 對於最終命中成功率的計算
  #     user : 發動攻擊的人，或者物品使用者，或者技能使用者
  #     obj  : 技能或物品（若是普通攻擊則為空）
  #--------------------------------------------------------------------------
  def calc_hit(user, obj = nil)
    if obj == nil                           # 為普通攻擊而設
      hit = user.hit                        # 獲取命中成功率
      physical = true
    elsif obj.is_a?(RPG::Skill)             # 為使用技能而設
      hit = obj.hit                         # 獲取成功率
      physical = obj.physical_attack
    else                                    # 為使用物品而設
      hit = 100                             # 強制命中成功率為100%
      physical = obj.physical_attack
    end
    if physical                             # 為實體攻擊而設
      hit /= 4 if user.reduce_hit_ratio?    # 當行動者進入盲目狀態的時候
    end
    return hit
  end
  #--------------------------------------------------------------------------
  # * 對於最終規避機率的計算
  #     user : 發動攻擊的人，或者物品使用者，或者技能使用者
  #     obj  : 技能或物品（若是普通攻擊則為空）
  #--------------------------------------------------------------------------
  def calc_eva(user, obj = nil)
    eva = self.eva
    unless obj == nil                       # 若是使用技能或者使用物品
      eva = 0 unless obj.physical_attack    # 如果不是實體攻擊則為0%
    end
    unless parriable?                       # 如果無法躲避
      eva = 0                               # 0%
    end
    return eva
  end
  #--------------------------------------------------------------------------
  # * 對於普通攻擊所造成的傷害的計算
  #     attacker : 發動攻擊的人
  #    最終所得的值將代入變數 @hp_damage
  #--------------------------------------------------------------------------
  def make_attack_damage_value(attacker)
    damage = attacker.atk * 4 - self.def * 2        # 基本計算結果
    damage = 0 if damage < 0                        # 如果值為負數，則值歸零
    damage *= elements_max_rate(attacker.element_set)   # 屬性調整
    damage /= 100
    if damage == 0                                  # 如果傷害為0，
      damage = rand(2)                              # 有50%的機率，傷害值為1
    elsif damage > 0                                # 一個正數？
      @critical = (rand(100) < attacker.cri)        # 會心一擊？
      @critical = false if prevent_critical         # 防會心一擊？
      damage *= 3 if @critical                      # 會心一擊矯正
    end
    damage = apply_variance(damage, 20)             # 分散度
    damage = apply_guard(damage)                    # 防禦調整
    @hp_damage = damage                             # HP傷害
  end
  #--------------------------------------------------------------------------
  # * 對於使用物品或使用技能所造成的傷害的計算
  #     user : 技能的使用者或物品的使用者
  #     obj  : 技能或物品（若是普通攻擊則為空）
  #    最終所得的值將代入變數 @hp_damage 和 @mp_damage.
  #--------------------------------------------------------------------------
  def make_obj_damage_value(user, obj)
    damage = obj.base_damage                        # 獲取基本傷害值
    if damage > 0                                   # 一個正數？
      damage += user.atk * 4 * obj.atk_f / 100      # 與使用者的攻擊力關係度
      damage += user.spi * 2 * obj.spi_f / 100      # 與使用者的意志力關係度
      unless obj.ignore_defense                     # 在無視防禦以外的情況下
        damage -= self.def * 2 * obj.atk_f / 100    # 與目標的攻擊力關係度
        damage -= self.spi * 1 * obj.spi_f / 100    # 與目標的意志力關係度
      end
      damage = 0 if damage < 0                      # 如果值為負數，則值歸零
    elsif damage < 0                                # 一個負數？
      damage -= user.atk * 4 * obj.atk_f / 100      # 與使用者的攻擊力關係度
      damage -= user.spi * 2 * obj.spi_f / 100      # 與使用者的意志力關係度
    end
    damage *= elements_max_rate(obj.element_set)    # 屬性調整
    damage /= 100
    damage = apply_variance(damage, obj.variance)   # 分散度
    damage = apply_guard(damage)                    # 防禦調整
    if obj.damage_to_mp  
      @mp_damage = damage                           # MP傷害
    else
      @hp_damage = damage                           # HP傷害
    end
  end
  #--------------------------------------------------------------------------
  # * 對於汲取效果的計算
  #     user : 技能的使用者或物品的使用者
  #     obj  : 技能或物品（若是普通攻擊則為空）
  #    在調用這個方法之前，變數 @hp_damage 和 @mp_damage 的值必須事先計算。
  #--------------------------------------------------------------------------
  def make_obj_absorb_effect(user, obj)
    if obj.absorb_damage                        # 若吸收傷害
      @hp_damage = [self.hp, @hp_damage].min    # HP傷害範圍調整
      @mp_damage = [self.mp, @mp_damage].min    # MP傷害範圍調整
      if @hp_damage > 0 or @mp_damage > 0       # 一個正數？
        @absorbed = true                        # 將汲取標記設置為ON
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 對於一個物品中HP恢復量的計算
  #--------------------------------------------------------------------------
  def calc_hp_recovery(user, item)
    result = maxhp * item.hp_recovery_rate / 100 + item.hp_recovery
    result *= 2 if user.pharmacology  # 擅長用藥且具備藥物知識，用藥雙倍療效
    return result
  end
  #--------------------------------------------------------------------------
  # * 對於一個物品中MP恢復量的計算
  #--------------------------------------------------------------------------
  def calc_mp_recovery(user, item)
    result = maxmp * item.mp_recovery_rate / 100 + item.mp_recovery
    result *= 2 if user.pharmacology  # 擅長用藥且具備藥物知識，用藥雙倍療效
    return result
  end
  #--------------------------------------------------------------------------
  # * 獲取屬性調整度上限
  #     element_set : 屬性組合
  #    在屬性組合中返回效果最大的屬性調整
  #--------------------------------------------------------------------------
  def elements_max_rate(element_set)
    return 100 if element_set.empty?                # 若沒有屬性
    rate_list = []
    for i in element_set
      rate_list.push(element_rate(i))
    end
    return rate_list.max
  end
  #--------------------------------------------------------------------------
  # * 應用分散度
  #     damage   : 傷害
  #     variance : 分散度
  #--------------------------------------------------------------------------
  def apply_variance(damage, variance)
    if damage != 0                                  # 若傷害值不為0
      amp = [damage.abs * variance / 100, 0].max    # 計算波動範圍
      damage += rand(amp+1) + rand(amp+1) - amp     # 應用分散度
    end
    return damage
  end
  #--------------------------------------------------------------------------
  # * 應用防禦調整
  #     damage : 傷害
  #--------------------------------------------------------------------------
  def apply_guard(damage)
    if damage > 0 and guarding?                     # 判斷是否在防禦中
      damage /= super_guard ? 4 : 2                 # 降低傷害
    end
    return damage
  end
  #--------------------------------------------------------------------------
  # * 傷害反彈
  #     user : 技能的使用者或物品的使用者
  #    在調用這個方法之前，@hp_damage， @mp_damage 以及 @absorbed 這三個變數
  #    的值必須事先計算完畢。
  #--------------------------------------------------------------------------
  def execute_damage(user)
    if @hp_damage > 0           # 傷害為正數
      remove_states_shock       # 因攻擊而造成的狀態解除
    end
    self.hp -= @hp_damage
    self.mp -= @mp_damage
    if @absorbed                # 若汲取行為存在
      user.hp += @hp_damage
      user.mp += @mp_damage
    end
  end
  #--------------------------------------------------------------------------
  # * 應用狀態變化
  #     obj : 技能，物品或發動攻擊的人
  #--------------------------------------------------------------------------
  def apply_state_changes(obj)
    plus = obj.plus_state_set             # 獲取要附加的狀態的資訊
    minus = obj.minus_state_set           # 獲取要接觸的狀態的資訊
    for i in plus                         # 附加狀態
      next if state_resist?(i)            # 該狀態被免疫？
      next if dead?                       # 目標已經瀕死或掛掉？
      next if i == 1 and @immortal        # 目標是不死之身？
      if state?(i)                        # 是否以前曾經附加過雷同的狀態
        @remained_states.push(i)          # 記錄未改變的狀態
        next                              # 跳出迴圈
      end
      if rand(100) < state_probability(i) # 判斷成功機率
        add_state(i)                      # 附加指定狀態
        @added_states.push(i)             # 記錄已附加的狀態
      end
    end
    for i in minus                        # 解除狀態
      next unless state?(i)               # 這個狀態未曾附加麼？
      remove_state(i)                     # 解除指定狀態
      @removed_states.push(i)             # 記錄已解除的狀態
    end
    for i in @added_states & @removed_states  # 如果有任何的狀態
      @added_states.delete(i)                 # 同時屬於已經附加和已經解除
      @removed_states.delete(i)               # 的區段，則同時清除
    end
  end
  #--------------------------------------------------------------------------
  # * 判定是否發動普通攻擊
  #     attacker : 發動攻擊的人
  #--------------------------------------------------------------------------
  def attack_effective?(attacker)
    if dead?
      return false
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 應用普通攻擊效果
  #     attacker : 發動攻擊的人
  #--------------------------------------------------------------------------
  def attack_effect(attacker)
    clear_action_results
    unless attack_effective?(attacker)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(attacker)            # 判定命中成功率
      @missed = true
      return
    end
    if rand(100) < calc_eva(attacker)#self.eva          # 判定規避成功率
      @evaded = true
      return
    end
    make_attack_damage_value(attacker)            # 傷害值計算
    execute_damage(attacker)                      # 傷害反彈
    if @hp_damage == 0                            # 無物理傷害？
      return                                    
    end
    apply_state_changes(attacker)                 # 狀態變更
  end
  #--------------------------------------------------------------------------
  # * 判斷一個技能是否能夠實施於目標
  #     user  : 技能使用者
  #     skill : 技能
  #--------------------------------------------------------------------------
  def skill_effective?(user, skill)
    if skill.for_dead_friend? != dead?
      return false
    end
    if not $game_temp.in_battle and skill.for_friend?
      return skill_test(user, skill)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 技能應用測試
  #     user  : 技能使用者
  #     skill : 技能
  #    這個方法用來判斷這個技能是否可以施用於目標。
  #    舉個例子，如果一個參戰者HP為滿的情況下則無法再添加HP。
  #--------------------------------------------------------------------------
  def skill_test(user, skill)
    tester = self.clone
    tester.make_obj_damage_value(user, skill)
    tester.apply_state_changes(skill)
    if tester.hp_damage < 0
      return true if tester.hp < tester.maxhp
    end
    if tester.mp_damage < 0
      return true if tester.mp < tester.maxmp
    end
    return true unless tester.added_states.empty?
    return true unless tester.removed_states.empty?
    return false
  end
  #--------------------------------------------------------------------------
  # * 應用技能效果
  #     user  : 技能使用者
  #     skill : 技能
  #--------------------------------------------------------------------------
  def skill_effect(user, skill)
    clear_action_results
    unless skill_effective?(user, skill)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(user, skill)         # 判定命中成功率
      @missed = true
      return
    end
    if rand(100) < calc_eva(user, skill)          # 判定規避成功率
      @evaded = true
      return
    end
    make_obj_damage_value(user, skill)            # 傷害值計算
    make_obj_absorb_effect(user, skill)           # 汲取效果值計算
    execute_damage(user)                          # 傷害反彈
    if skill.physical_attack and @hp_damage == 0  # 無物理傷害？
      return                                    
    end
    apply_state_changes(skill)                    # 狀態變更
  end
  #--------------------------------------------------------------------------
  # * 判定一個物品目前是否可用
  #     user : 物品使用者
  #     item : 物品
  #--------------------------------------------------------------------------
  def item_effective?(user, item)
    if item.for_dead_friend? != dead?
      return false
    end
    if not $game_temp.in_battle and item.for_friend?
      return item_test(user, item)
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * 物品應用測試
  #     user : 物品使用者
  #     item : 物品
  #    這個方法用來判斷這個物品是否可以應用於目標。
  #    舉個例子，如果一個參戰者HP為滿的情況下則無法再添加HP。
  #--------------------------------------------------------------------------
  def item_test(user, item)
    tester = self.clone
    tester.make_obj_damage_value(user, item)
    tester.apply_state_changes(item)
    if tester.hp_damage < 0 or tester.calc_hp_recovery(user, item) > 0
      return true if tester.hp < tester.maxhp
    end
    if tester.mp_damage < 0 or tester.calc_mp_recovery(user, item) > 0
      return true if tester.mp < tester.maxmp
    end
    return true unless tester.added_states.empty?
    return true unless tester.removed_states.empty?
    return true if item.parameter_type > 0
    return false
  end
  #--------------------------------------------------------------------------
  # * 應用物品效果
  #     user : 物品使用者
  #     item : 物品
  #--------------------------------------------------------------------------
  def item_effect(user, item)
    clear_action_results
    unless item_effective?(user, item)
      @skipped = true
      return
    end
    if rand(100) >= calc_hit(user, item)          # 判定命中成功率
      @missed = true
      return
    end
    if rand(100) < calc_eva(user, item)           # 判定規避成功率
      @evaded = true
      return
    end
    hp_recovery = calc_hp_recovery(user, item)    # HP恢復量計算
    mp_recovery = calc_mp_recovery(user, item)    # MP恢復量計算
    make_obj_damage_value(user, item)             # 傷害計算
    @hp_damage -= hp_recovery                     # 減去HP恢復量
    @mp_damage -= mp_recovery                     # 減去MP恢復量
    make_obj_absorb_effect(user, item)            # 汲取效果值計算
    execute_damage(user)                          # 傷害反彈
    item_growth_effect(user, item)                # 應用主角參數變更效果
    if item.physical_attack and @hp_damage == 0   # 無物理傷害？
      return                                    
    end
    apply_state_changes(item)                     # 狀態變更
  end
  #--------------------------------------------------------------------------
  # * 應用主角參數變更效果
  #     user : 物品使用者
  #     item : 物品
  #--------------------------------------------------------------------------
  def item_growth_effect(user, item)
    if item.parameter_type > 0 and item.parameter_points != 0
      case item.parameter_type
      when 1  # HP上限
        @maxhp_plus += item.parameter_points
      when 2  # MP上限
        @maxmp_plus += item.parameter_points
      when 3  # 攻擊力
        @atk_plus += item.parameter_points
      when 4  # 防禦力
        @def_plus += item.parameter_points
      when 5  # 精神意志力
        @spi_plus += item.parameter_points
      when 6  # 敏捷力
        @agi_plus += item.parameter_points
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 應用連續傷害效果
  #--------------------------------------------------------------------------
  def slip_damage_effect
    if slip_damage? and @hp > 0
      @hp_damage = apply_variance(maxhp / 10, 10)
      @hp_damage = @hp - 1 if @hp_damage >= @hp
      self.hp -= @hp_damage
    end
  end
end
