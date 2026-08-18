#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_MechanicExpansion v1.2 OD Economy｜Phase11 AI Hook Refactor
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_MechanicExpansion v1.2 OD Economy」。
# 【主要機制】六主角／召喚物／狀態／Break／Robot Protocol 等角色機制擴充。Phase 11 起，AI 相關 albert_mx_* 方法只提供條件、目標加分與 Robot Protocol Hook；AutoBattleAI Authority 於執行時晚綁定這些 Hook，本頁不再 alias 八個 AI 方法與 make_action。
# 【主要影響】Game_Battler、RPG::State、Game_Enemy、Game_Actor、Scene_Battle、ALBERT_MECHANIC_EXPANSION、ALBERT_CHARACTER_CORE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：IVY_DEFAULT_STORE_RATE、IVY_DEFAULT_DIRECT_STORE_RATE、IVY_FURNACE_DIRECT_STORE_RATE、IVY_FURNACE_STATE_ID、IVY_DEFAULT_STORE_CAP_PERCENT、AIZHUO_TIMING_PASSIVE_SKILL_ID、AIZHUO_OD_ATB_BONUS_PER_PERCENT、AIZHUO_LOW_ATB_THRESHOLD。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】仍有多個戰鬥機制 alias／方法包裝，位置不可任意搬動；登記 $imported：AlbertMechanicExpansionAllInOne。Phase 11 已解除對 AutoBattleAI 的 9 層 alias 依賴，但本頁其他角色／狀態／戰鬥 Hook 仍依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前位置。
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
# 【Phase 23】Robot Protocol 的敵方目標抽選改走 FS_AI_RANDOM；本頁其他狀態成功率 rand 仍屬戰鬥機制 RNG，暫不納入 AI Provider。
# 【Phase 25】OD12 第二層 skill_effect alias 已改為 before/after Provider；本頁只保留一個 skill_effect wrapper。
#==============================================================================
# -*- coding: utf-8 -*-



#===============================================================================



# ■ Albert_RMVX_MechanicExpansion_AllInOne_v1_2_OD_Economy_TC



#-------------------------------------------------------------------------------



#  RPG Maker VX / RGSS2 / Ruby 1.8 相容



#  Forest Symphony 六主角＋召喚物機制擴充核心 v1.2 OD 經濟版



#-------------------------------------------------------------------------------



# 【放置位置】



#   請放在以下腳本全部之下、Main 之上：



#



#     RMVX_ComboCore_AllInOne_v1_1_OD



#     CharacterMechanicCore_v1_0_TC



#     ATB_DynamicResistance



#     SummonChain3_v1_0



#



#   最安全的方式：直接放在 SummonChain3_v1_0 下方、Main 上方。



#



#-------------------------------------------------------------------------------



# 【本腳本新增內容】



#



#  1. 喬伊：召喚物追擊可依「類型／功能角色」自動尋找在場召喚物。



#  2. 艾薇：Cover 實際承傷累積 → 復仇傷害爆發。



#  3. 艾卓：依目標目前 ATB 高度增傷／強化削減，成功打斷可獲 OD。



#  4. 維娜：比例型／SPI／ATK 型狀態爆發，以及 Boss 動態異常抗性。



#  5. 泰勒：敵人專屬 Break 門檻、Break 抗性、自然回復、消耗崩防終結技。



#  6. 米亞：依自身 State 疊層增傷，技能成功後消耗自身 State 疊層。



#  7. 寶可夢 AI：



#       <ai_bonus_vs_state 31:100>



#       <ai_require_state:31>



#       <ai_prefer_stack_below 31:5>



#  8. 機器人協議：



#       <robot_protocol_skill:241>



#       <robot_protocol_interval:3>



#       <robot_protocol_if_state 31:241>



#



#===============================================================================



# ■ 一、喬伊：類型／功能角色自動追擊



#===============================================================================



#



# 【召喚物分類】



#   除了 ComboCore 原本的 POKEMON_IDS / ROBOT_IDS / CLONE_IDS，



#   也支援直接寫在 Actor Note：



#



#     <summon_type:pokemon>



#     <summon_type:robot>



#     <summon_type:clone>



#



# 【功能角色】



#   可寫在召喚物 Actor / 裝備 / State Note：



#



#     <summon_role:poison_starter>



#     <summon_role:breaker>



#     <summon_role:finisher>



#



#   一個召喚物可以有多個 role。



#



# 【舊單段追擊，依類型自動選擇】



#   寫在喬伊技能 Note：



#



#     <summon_followup_type pokemon:241:700:200>



#



#   格式：



#     <summon_followup_type 類型:追擊技能ID:需求OD:成功後消耗OD>



#



# 【舊單段追擊，依功能角色自動選擇】



#



#     <summon_followup_role poison_starter:241:700:200>



#



# 【三段追擊，依類型自動選擇】



#



#     <summon_chain_type 1:pokemon:241:700:0>



#     <summon_chain_type 2:robot:250:700:100>



#     <summon_chain_type 3:clone:260:900:300>



#



# 【三段追擊，依功能角色自動選擇】



#



#     <summon_chain_role 1:poison_starter:241:700:0>



#     <summon_chain_role 2:corrosion_engine:250:700:100>



#     <summon_chain_role 3:finisher:260:900:300>



#



#   同一階段若有多名符合者，依目前 $game_party.members 順序挑第一個



#   「在場、存活、可追擊」的召喚物。



#



#===============================================================================



# ■ 二、艾薇：Cover 承傷累積 → 復仇爆發



#===============================================================================



#



# 【承傷累積】



#   艾薇預設會記錄 100% 的實際 Cover HP 損失。



#



#   可在 Actor / 裝備 / State Note 改倍率：



#



#     <store_cover_damage:150>



#



#   代表記錄實際 Cover HP 損失的 150%。



#



#   可改最大儲存上限，占自身最大 HP 百分比：



#



#     <cover_store_cap_percent:300>



#



#   預設最多儲存自身最大 HP 的 300%。



#



# 【復仇爆發技能】



#



#     <revenge_from_cover:50>



#



#   代表追加「目前累積 Cover 傷害 × 50%」的固定 HP 傷害。



#



#   若要成功命中後清空累積值：



#



#     <consume_stored_cover>



#



#   建議把復仇爆發設計成單體終結技，最容易平衡與理解。



#



#===============================================================================



# ■ 三、艾卓：ATB 時機獎勵／打斷



#===============================================================================



#



# 【目標 ATB 高於門檻時，強化 ATB 變化幅度】



#



#     <atb_bonus_if_target_atb_above 80:50>



#



#   目標目前 ATB >= 80% 時，ATB 削減／增加幅度額外 +50%。



#



# 【目標 ATB 高於門檻時，傷害增幅】



#



#     <bonus_if_target_atb_above 80:30>



#



# 【成功打斷】



#



#     <atb_interrupt_threshold:80>



#     <atb_interrupt_od:100>



#



#   若目標原本 ATB >= 80%，技能處理後被壓到 80% 以下，



#   視為一次成功打斷，艾卓獲得 100 OD。



#



#   也支援同義寫法：



#     <interrupt_if_target_atb_above:80>



#



#===============================================================================



# ■ 四、維娜：比例型／能力值型狀態爆發



#===============================================================================



#



# 【目標最大 HP 比例爆發】



#



#     <detonate_state_percent 31:2>



#



#   每層 State 31 額外造成「目標最大 HP 2%」傷害，成功後消耗 State 31。



#



# 【SPI 型爆發】



#



#     <detonate_state_spi 31:120>



#



#   每層額外造成「使用者 SPI × 120%」傷害。



#



# 【ATK 型爆發】



#



#     <detonate_state_atk 31:120>



#



# 【爆發傷害上限，可選】



#



#     <detonate_cap:5000>



#



#   只限制本腳本新增的比例／能力值爆發傷害，不影響原技能傷害。



#



#===============================================================================



# ■ 五、Boss 動態異常抗性



#===============================================================================



#



# 【Enemy Note】



#



#     <state_dynamic_resist>



#



#   啟用動態異常抗性。



#



#   預設只影響 State Note 有：



#



#     <dynamic_resist>



#   或



#     <control_state>



#



#   的狀態。



#



# 【指定清單】



#



#     <state_dynamic_resist_states:31,32,33>



#



# 【全部狀態都套用】



#



#     <state_dynamic_resist_all>



#



# 【每成功一次降低多少成功率倍率】



#



#     <state_resist_step:25>



#



#   預設每成功一次：100% → 75% → 50% → 25% → 10%。



#



# 【最低倍率】



#



#     <state_resist_min:10>



#



# 【Boss 每完成一次有效行動，恢復幾級】



#



#     <state_resist_recover:1>



#



#===============================================================================



# ■ 六、泰勒：敵人端 Break 規則



#===============================================================================



#



# 【Enemy Note】



#



#     <break_threshold:8>



#       此敵人的 Break 門檻為 8，優先於技能上的門檻。



#



#     <break_resist:50>



#       受到的 Break Power 降低 50%。



#



#     <break_immune>



#       完全免疫 Break Power。



#



#     <break_recover:1>



#       每完成一次有效行動，恢復 1 點破勢。



#



#     <break_recover_state:50>



#       指定自然回復哪個 Break 進度 State，預設讀 Character Core 設定。



#



# 【消耗崩防終結技】



#   寫在技能 Note：



#



#     <bonus_vs_state 51:100>



#     <consume_broken>



#



#   先吃到崩防增傷，成功命中後再移除崩防 State。



#



#===============================================================================



# ■ 七、米亞：自身魔力層增傷／消耗



#===============================================================================



#



# 【每層增傷】



#



#     <bonus_per_user_state_stack 41:15>



#



#   使用者每有 1 層 State 41，傷害 +15%。



#



# 【成功施放後消耗自身層數】



#



#     <consume_user_state 41:3>



#



#   技能至少對一個目標造成有效結果後，使用者消耗 3 層 State 41。



#   若剩餘層數 <= 0，直接移除 State。



#



#===============================================================================



# ■ 八、寶可夢 Combo-aware AI



#===============================================================================



#



# 寫在技能 Note：



#



#   <ai_bonus_vs_state 31:100>



#     對已有 State 31 的目標，AI 評價 +100。



#



#   <ai_require_state:31>



#     若沒有合法目標擁有 State 31，AI 不會選這招。



#     若選中這招，會自動修正到符合條件的目標。



#



#   <ai_prefer_stack_below 31:5>



#     優先選擇 State 31 疊層低於 5 的目標。



#     預設加分由 AI_PREFER_STACK_BONUS 控制。



#



#===============================================================================



# ■ 九、機器人固定協議



#===============================================================================



#



# 寫在 Robot Actor / 裝備 / State Note：



#



#   <robot_protocol_skill:241>



#   <robot_protocol_interval:3>



#



#   代表每第 3 次 AI 行動，固定嘗試 Skill 241。



#



# 條件協議：



#



#   <robot_protocol_if_state 31:241>



#



#   在「協議回合」時，若敵方有 State 31，優先使用 Skill 241，



#   並優先鎖定符合 State 31 的目標。



#



#   若條件協議無法成立，再使用 robot_protocol_skill；



#   若技能不可用，則退回原本 AutoBattleAI。



#



#===============================================================================







$imported = {} if $imported == nil



$imported["AlbertMechanicExpansionAllInOne"] = true







module ALBERT_MECHANIC_EXPANSION



  VERSION = "1.1"







  # 艾薇：蓄痛從戰鬥開始即生效。



  IVY_DEFAULT_STORE_RATE = 100.0          # Cover 實際損血轉蓄痛



  IVY_DEFAULT_DIRECT_STORE_RATE = 50.0   # 直接承傷轉蓄痛



  IVY_FURNACE_DIRECT_STORE_RATE = 100.0  # 痛苦熔爐期間直接承傷



  IVY_FURNACE_STATE_ID = 85



  IVY_DEFAULT_STORE_CAP_PERCENT = 200.0







  # 艾卓：學會「靜電回收」後取得泛用時間控制。



  AIZHUO_TIMING_PASSIVE_SKILL_ID = 122



  AIZHUO_OD_ATB_BONUS_PER_PERCENT = 0.2



  AIZHUO_LOW_ATB_THRESHOLD = 40.0



  AIZHUO_LOW_ATB_REFUND_PERCENT = 8.0

  # 超載迴路：支付標準 KGC OD 後，強化下一次實際 ATB 削減。
  AIZHUO_OVERLOAD_STATE_ID = 100
  AIZHUO_OVERLOAD_BONUS_PERCENT = 30.0
  AIZHUO_OVERLOAD_PIERCE_PERCENT = 30.0







  # Boss 動態異常抗性



  STATE_RESIST_DEFAULT_STEP = 25



  STATE_RESIST_DEFAULT_MIN = 10



  STATE_RESIST_DEFAULT_RECOVER = 1







  # 寶可夢 AI



  AI_PREFER_STACK_BONUS = 500







  #--------------------------------------------------------------------------



  # ● 安全讀取 Note



  #--------------------------------------------------------------------------



  def self.note(obj)



    return "" if obj == nil



    return obj.note.to_s if obj.respond_to?(:note) && obj.note != nil



    return ""



  end







  #--------------------------------------------------------------------------



  # ● 使用者完整 Note 來源



  #--------------------------------------------------------------------------



  def self.source_text(user, obj = nil)



    if defined?(ALBERT_CHARACTER_CORE) &&



       ALBERT_CHARACTER_CORE.respond_to?(:source_text)



      return ALBERT_CHARACTER_CORE.source_text(user, obj)



    end







    text = note(obj)



    return text if user == nil







    if user.actor?



      text += note(user.actor) if user.respond_to?(:actor)



      if user.respond_to?(:equips)



        for equip in user.equips.compact



          text += note(equip)



        end



      end



    elsif user.respond_to?(:enemy)



      text += note(user.enemy)



    end







    for state in user.states.compact



      text += note(state)



    end







    return text



  end







  #--------------------------------------------------------------------------



  # ● 夾值



  #--------------------------------------------------------------------------



  def self.clamp(value, min_value, max_value)



    return [[value, min_value].max, max_value].min



  end







  #--------------------------------------------------------------------------



  # ● 安全判定 Actor 是否習得指定技能



  #--------------------------------------------------------------------------



  def self.learned_skill?(battler, skill_id)



    return false if battler == nil



    return false unless battler.actor?



    return false unless battler.respond_to?(:skill_learn?)



    skill = $data_skills[skill_id] rescue nil



    return false if skill == nil



    return battler.skill_learn?(skill)



  end







  #--------------------------------------------------------------------------



  # ● 目前在場召喚物



  #--------------------------------------------------------------------------



  def self.battle_summons



    result = []



    return result if $game_party == nil







    for actor in $game_party.members



      next if actor == nil



      next unless actor.exist?



      next unless actor.respond_to?(:albert_summon?)



      next unless actor.albert_summon?



      result.push(actor)



    end







    return result



  end







  #--------------------------------------------------------------------------



  # ● 依類型取得召喚物候補



  #--------------------------------------------------------------------------



  def self.summons_by_type(type_name)



    type_name = type_name.to_s.downcase



    result = []







    for actor in battle_summons



      actual = actor.respond_to?(:albert_summon_type) ? actor.albert_summon_type : nil



      actual_text = actual == nil ? "summon" : actual.to_s.downcase



      result.push(actor) if actual_text == type_name



    end







    return result



  end







  #--------------------------------------------------------------------------



  # ● 依功能角色取得召喚物候補



  #--------------------------------------------------------------------------



  def self.summons_by_role(role_name)



    result = []



    for actor in battle_summons



      result.push(actor) if actor.respond_to?(:albert_mx_summon_role?) &&



                            actor.albert_mx_summon_role?(role_name)



    end



    return result



  end



end







#===============================================================================



# ■ Game_Battler



#===============================================================================



class Game_Battler



  #--------------------------------------------------------------------------



  # ● Actor Note 召喚物分類後備



  #--------------------------------------------------------------------------



  if method_defined?(:albert_pokemon?) &&



     !method_defined?(:albert_mx_old_albert_pokemon?)



    alias albert_mx_old_albert_pokemon? albert_pokemon?



    def albert_pokemon?



      return true if albert_mx_old_albert_pokemon?



      return false unless actor?



      return !!(ALBERT_MECHANIC_EXPANSION.note(actor) =~



        /<summon_type\s*:\s*pokemon\s*>/i)



    end



  end







  if method_defined?(:albert_robot?) &&



     !method_defined?(:albert_mx_old_albert_robot?)



    alias albert_mx_old_albert_robot? albert_robot?



    def albert_robot?



      return true if albert_mx_old_albert_robot?



      return false unless actor?



      return !!(ALBERT_MECHANIC_EXPANSION.note(actor) =~



        /<summon_type\s*:\s*robot\s*>/i)



    end



  end







  if method_defined?(:albert_clone?) &&



     !method_defined?(:albert_mx_old_albert_clone?)



    alias albert_mx_old_albert_clone? albert_clone?



    def albert_clone?



      return true if albert_mx_old_albert_clone?



      return false unless actor?



      return !!(ALBERT_MECHANIC_EXPANSION.note(actor) =~



        /<summon_type\s*:\s*clone\s*>/i)



    end



  end







  #--------------------------------------------------------------------------



  # ● 召喚物功能角色



  #--------------------------------------------------------------------------



  def albert_mx_summon_roles



    text = ALBERT_MECHANIC_EXPANSION.source_text(self, nil)



    result = []



    text.scan(/<summon_role\s*:\s*([a-z0-9_]+)\s*>/i) do |data|



      role = data[0].to_s.downcase



      result.push(role) unless result.include?(role)



    end



    return result



  end







  def albert_mx_summon_role?(role_name)



    return albert_mx_summon_roles.include?(role_name.to_s.downcase)



  end







  #--------------------------------------------------------------------------



  # ● 艾薇：目前累積 Cover 傷害



  #--------------------------------------------------------------------------



  def albert_mx_stored_cover_damage



    @albert_mx_stored_cover_damage = 0 if @albert_mx_stored_cover_damage == nil



    value = @albert_mx_stored_cover_damage.to_i



    cap = (maxhp.to_f * albert_mx_cover_store_cap_percent / 100.0).to_i



    if cap > 0 && value > cap



      value = cap



      @albert_mx_stored_cover_damage = value



      albert_bshud_touch! if respond_to?(:albert_bshud_touch!)



    end



    return value



  end







  def albert_mx_stored_cover_damage=(value)



    value = value.to_i



    value = 0 if value < 0



    old_value = @albert_mx_stored_cover_damage.to_i



    @albert_mx_stored_cover_damage = value



    if old_value != value && respond_to?(:albert_bshud_touch!)



      albert_bshud_touch!



    end



  end







  # Cover 傷害採所有 Note 中最高倍率。



  def albert_mx_cover_store_rate



    text = ALBERT_MECHANIC_EXPANSION.source_text(self, nil)



    values = []



    text.scan(/<store_cover_damage\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      values.push(data[0].to_f)



    end



    return values.max unless values.empty?



    return ALBERT_MECHANIC_EXPANSION::IVY_DEFAULT_STORE_RATE



  end







  # 直接承傷平時記錄 50%；痛苦熔爐期間提高到 100%。



  # 另支援 Note：<store_direct_damage:數值>。



  def albert_mx_direct_store_rate



    text = ALBERT_MECHANIC_EXPANSION.source_text(self, nil)



    values = []



    text.scan(/<store_direct_damage\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      values.push(data[0].to_f)



    end



    return values.max unless values.empty?



    if state?(ALBERT_MECHANIC_EXPANSION::IVY_FURNACE_STATE_ID)



      return ALBERT_MECHANIC_EXPANSION::IVY_FURNACE_DIRECT_STORE_RATE



    end



    return ALBERT_MECHANIC_EXPANSION::IVY_DEFAULT_DIRECT_STORE_RATE



  end







  def albert_mx_cover_store_cap_percent



    text = ALBERT_MECHANIC_EXPANSION.source_text(self, nil)



    values = []



    text.scan(/<cover_store_cap_percent\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      values.push(data[0].to_f)



    end



    return values.max unless values.empty?



    return ALBERT_MECHANIC_EXPANSION::IVY_DEFAULT_STORE_CAP_PERCENT



  end







  def albert_mx_add_stored_cover_damage(amount)



    amount = amount.to_i



    return 0 if amount <= 0







    old_value = albert_mx_stored_cover_damage



    cap = (maxhp.to_f * albert_mx_cover_store_cap_percent / 100.0).to_i



    cap = 0 if cap < 0



    new_value = old_value + amount



    new_value = cap if cap > 0 && new_value > cap



    self.albert_mx_stored_cover_damage = new_value



    return new_value - old_value



  end







  def albert_mx_clear_stored_cover_damage



    self.albert_mx_stored_cover_damage = 0



  end







  #--------------------------------------------------------------------------



  # ● 共用：安全取得 State 疊層



  #--------------------------------------------------------------------------



  def albert_mx_state_stack_count(state_id)



    return 0 unless state?(state_id)



    if respond_to?(:albert_combo_stack_count)



      begin



        return albert_combo_stack_count(state_id).to_i



      rescue



      end



    end



    if respond_to?(:stack)



      begin



        return stack(state_id).to_i



      rescue



      end



    end



    return 1



  end







  #--------------------------------------------------------------------------



  # ● 共用：安全減少 State 疊層



  #--------------------------------------------------------------------------



  def albert_mx_reduce_state_stack(state_id, amount)



    amount = amount.to_i



    return 0 if amount <= 0



    return 0 unless state?(state_id)







    before = albert_mx_state_stack_count(state_id)



    remain = before - amount







    if remain <= 0



      remove_state(state_id)



      return before



    end







    if respond_to?(:stack)



      hash = instance_variable_get(:@state_stack)



      hash = {} if hash == nil



      hash[state_id] = remain



      instance_variable_set(:@state_stack, hash)



    elsif instance_variable_get(:@albert_cc_break_points) != nil



      hash = instance_variable_get(:@albert_cc_break_points)



      hash[state_id] = remain



    end







    return before - remain



  end







  #--------------------------------------------------------------------------



  # ● 艾薇：真正 Cover 承傷後累積復仇值



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_mx_old_execute_damage)



    alias albert_mx_old_execute_damage execute_damage



  end







  def execute_damage(user)



    before_hp = self.hp.to_i



    cover_redirect = instance_variable_get(:@albert_cover_redirect_guard) ? true : false



    opponent_damage = false



    if user != nil && user.respond_to?(:actor?) && respond_to?(:actor?)



      opponent_damage = user.actor? != actor?



    end







    albert_mx_old_execute_damage(user)







    if opponent_damage && respond_to?(:albert_cc_ivy?) && albert_cc_ivy?



      actual_loss = before_hp - self.hp.to_i



      if actual_loss > 0



        rate = cover_redirect ? albert_mx_cover_store_rate : albert_mx_direct_store_rate



        stored = (actual_loss * rate / 100.0).to_i



        albert_mx_add_stored_cover_damage(stored)



      end



    end



  end







  #--------------------------------------------------------------------------



  # ● 目標目前 ATB 百分比



  #--------------------------------------------------------------------------



  def albert_mx_atb_rate



    return 0.0 unless respond_to?(:at_count)



    value = at_count.to_f



    return ALBERT_MECHANIC_EXPANSION.clamp(value * 100.0 / 1000.0, 0.0, 100.0)



  end







  #--------------------------------------------------------------------------



  # ● 艾卓：ATB 門檻強化



  #--------------------------------------------------------------------------



  if method_defined?(:albert_combo_atb_bonus_percent) &&



     !method_defined?(:albert_mx_old_atb_bonus_percent)



    alias albert_mx_old_atb_bonus_percent albert_combo_atb_bonus_percent







    def albert_combo_atb_bonus_percent



      bonus = albert_mx_old_atb_bonus_percent.to_i



      user = respond_to?(:albert_combo_effect_user) ? albert_combo_effect_user : nil



      obj = respond_to?(:albert_combo_effect_obj) ? albert_combo_effect_obj : nil



      text = ALBERT_MECHANIC_EXPANSION.source_text(user, obj)



      rate = albert_mx_atb_rate







      text.scan(/<atb_bonus_if_target_atb_above\s+([0-9]+(?:\.[0-9]+)?)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



        bonus += data[1].to_f if rate >= data[0].to_f



      end







      if user != nil && user.respond_to?(:albert_cc_aizhuo?) &&



         user.albert_cc_aizhuo? &&



         ALBERT_MECHANIC_EXPANSION.learned_skill?(



           user, ALBERT_MECHANIC_EXPANSION::AIZHUO_TIMING_PASSIVE_SKILL_ID



         )



        od_rate = 0.0



        if defined?(ALBERT_CHARACTER_CORE) &&



           ALBERT_CHARACTER_CORE.respond_to?(:od_rate)



          od_rate = ALBERT_CHARACTER_CORE.od_rate(user).to_f



        end



        bonus += od_rate * ALBERT_MECHANIC_EXPANSION::AIZHUO_OD_ATB_BONUS_PER_PERCENT



      end

      if user != nil
        overload_bonus = user.instance_variable_get(:@albert_od_aizhuo_overload_bonus).to_f
        bonus += overload_bonus if overload_bonus > 0.0
      end







      return bonus.to_i



    end



  end







  #--------------------------------------------------------------------------



  # ● 通用傷害條件增幅擴充



  #    - 艾卓：bonus_if_target_atb_above



  #    - 米亞：bonus_per_user_state_stack



  #--------------------------------------------------------------------------



  if method_defined?(:albert_combo_damage_bonus_percent) &&



     !method_defined?(:albert_mx_old_damage_bonus_percent)



    alias albert_mx_old_damage_bonus_percent albert_combo_damage_bonus_percent







    def albert_combo_damage_bonus_percent(user, obj)



      bonus = albert_mx_old_damage_bonus_percent(user, obj).to_f



      text = ALBERT_MECHANIC_EXPANSION.source_text(user, obj)







      rate = albert_mx_atb_rate



      text.scan(/<bonus_if_target_atb_above\s+([0-9]+(?:\.[0-9]+)?)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



        bonus += data[1].to_f if rate >= data[0].to_f



      end







      if user != nil



        text.scan(/<bonus_per_user_state_stack\s+(\d+)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



          state_id = data[0].to_i



          per_stack = data[1].to_f



          stacks = user.respond_to?(:albert_mx_state_stack_count) ?



                   user.albert_mx_state_stack_count(state_id) : 0



          bonus += stacks * per_stack



        end



      end







      # 艾薇「怒擊」：蓄痛每達自身 MaxHP 指定比例便增加傷害，



      # 但不消耗蓄痛。格式：<bonus_per_stored_pain 門檻%:每階增傷%:上限%>



      if user != nil && user.respond_to?(:albert_cc_ivy?) && user.albert_cc_ivy?



        text.scan(/<bonus_per_stored_pain\s+([0-9]+(?:\.[0-9]+)?)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



          step_percent = data[0].to_f



          bonus_per_step = data[1].to_f



          bonus_cap = data[2].to_f



          next if step_percent <= 0.0 || user.maxhp.to_i <= 0



          stored = user.respond_to?(:albert_mx_stored_cover_damage) ?



                   user.albert_mx_stored_cover_damage.to_f : 0.0



          stored_percent = stored * 100.0 / user.maxhp.to_f



          steps = (stored_percent / step_percent).floor



          pain_bonus = steps * bonus_per_step



          pain_bonus = bonus_cap if pain_bonus > bonus_cap



          bonus += pain_bonus



        end



      end







      if defined?(ALBERT_COMBO_CORE)



        min_value = ALBERT_COMBO_CORE::DAMAGE_BONUS_MIN rescue -100



        max_value = ALBERT_COMBO_CORE::DAMAGE_BONUS_MAX rescue 900



        return ALBERT_MECHANIC_EXPANSION.clamp(bonus.to_i, min_value, max_value)



      end







      return bonus.to_i



    end



  end







  #--------------------------------------------------------------------------



  # ● 艾薇復仇傷害／維娜比例爆發



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_mx_old_make_obj_damage_value)



    alias albert_mx_old_make_obj_damage_value make_obj_damage_value



  end







  def make_obj_damage_value(user, obj)



    albert_mx_old_make_obj_damage_value(user, obj)



    return if obj == nil







    #-----------------------------------------------------------------------



    # 艾薇：Cover 累積傷害轉復仇爆發



    #-----------------------------------------------------------------------



    if user != nil && user.respond_to?(:albert_cc_ivy?) && user.albert_cc_ivy?



      text = ALBERT_MECHANIC_EXPANSION.source_text(user, obj)



      if text =~ /<revenge_from_cover\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i



        rate = $1.to_f



        base = user.albert_mx_stored_cover_damage







        if user.instance_variable_get(:@albert_mx_revenge_action_skill_id) == obj.id



          snapshot = user.instance_variable_get(:@albert_mx_revenge_action_snapshot)



          base = snapshot.to_i if snapshot != nil



        end







        extra = (base * rate / 100.0).to_i



        if extra > 0 && !obj.damage_to_mp



          @hp_damage = 0 if @hp_damage == nil



          @hp_damage += extra



        end



      end



    end







    #-----------------------------------------------------------------------



    # 維娜／通用：比例型與能力值型狀態爆發



    #-----------------------------------------------------------------------



    text = ALBERT_MECHANIC_EXPANSION.note(obj)



    bonus_damage = 0



    consume_ids = []







    text.scan(/<detonate_state_percent\s+(\d+)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      state_id = data[0].to_i



      percent = data[1].to_f



      next unless state?(state_id)



      stacks = albert_mx_state_stack_count(state_id)



      bonus_damage += (maxhp.to_f * percent / 100.0 * stacks).to_i



      consume_ids.push(state_id) unless consume_ids.include?(state_id)



    end







    text.scan(/<detonate_state_spi\s+(\d+)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      state_id = data[0].to_i



      rate = data[1].to_f



      next unless state?(state_id)



      next if user == nil



      stacks = albert_mx_state_stack_count(state_id)



      bonus_damage += (user.spi.to_f * rate / 100.0 * stacks).to_i



      consume_ids.push(state_id) unless consume_ids.include?(state_id)



    end







    text.scan(/<detonate_state_atk\s+(\d+)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      state_id = data[0].to_i



      rate = data[1].to_f



      next unless state?(state_id)



      next if user == nil



      stacks = albert_mx_state_stack_count(state_id)



      bonus_damage += (user.atk.to_f * rate / 100.0 * stacks).to_i



      consume_ids.push(state_id) unless consume_ids.include?(state_id)



    end







    if user != nil && bonus_damage > 0 &&
       text =~ /<detonate_od_bonus\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i
      od_bonus = $1.to_f
      bonus_damage = (bonus_damage.to_f * (100.0 + od_bonus) / 100.0).to_i
    end

    if text =~ /<detonate_cap\s*:\s*(\d+)\s*>/i



      cap = $1.to_i



      bonus_damage = [bonus_damage, cap].min if cap > 0



    end







    if bonus_damage > 0 && !obj.damage_to_mp



      @hp_damage = 0 if @hp_damage == nil



      @hp_damage += bonus_damage



    end







    # 只有真正在 skill_effect 執行時才記錄待消耗 State，



    # 避免 AI 傷害估算 clone 影響真實戰鬥資料。



    effect_obj = instance_variable_get(:@albert_effect_obj)



    if effect_obj != nil && effect_obj.equal?(obj) && !consume_ids.empty?



      @albert_mx_pending_scaled_consume_states = consume_ids.clone



    end



  end







  #--------------------------------------------------------------------------



  # ● 技能結果後處理



  #    - 標記本次技能是否成功，供米亞／艾薇「每次行動只消耗一次」使用。



  #    - 比例型狀態爆發後消耗目標 State。



  #    - 泰勒 consume_broken。



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_mx_old_skill_effect)



    alias albert_mx_old_skill_effect skill_effect



  end







  def skill_effect(user, skill)



    od12_context = albert_mx_od12_capture_skill_effect_context(user, skill)
    albert_mx_old_skill_effect(user, skill)







    success = false



    begin



      success = !@missed && !@evaded && !@skipped



      if success



        has_effect = false



        has_effect = true if @hp_damage != nil && @hp_damage != 0



        has_effect = true if @mp_damage != nil && @mp_damage != 0



        has_effect = true if respond_to?(:states_active?) && states_active?



        success = has_effect



      end



    rescue



      success = false



    end







    if success && user != nil



      user.instance_variable_set(:@albert_mx_action_success, true)



    end







    if success && @albert_mx_pending_scaled_consume_states != nil



      for state_id in @albert_mx_pending_scaled_consume_states



        remove_state(state_id) if state?(state_id)



      end



    end



    @albert_mx_pending_scaled_consume_states = nil







    if success && skill != nil



      text = ALBERT_MECHANIC_EXPANSION.note(skill)



      if text =~ /<consume_broken\s*>/i



        broken_id = 0



        if defined?(ALBERT_CHARACTER_CORE::BROKEN_STATE_ID)



          broken_id = ALBERT_CHARACTER_CORE::BROKEN_STATE_ID



        end



        if text =~ /<broken_state\s*:\s*(\d+)\s*>/i



          broken_id = $1.to_i



        end



        remove_state(broken_id) if broken_id > 0 && state?(broken_id)



      end



    end



    albert_mx_od12_after_skill_effect(user, skill, od12_context)
  end







  #--------------------------------------------------------------------------



  # ● 艾卓：成功打斷獎勵



  #--------------------------------------------------------------------------



  if method_defined?(:albert_combo_apply_atb_delta) &&



     !method_defined?(:albert_mx_old_apply_atb_delta)



    alias albert_mx_old_apply_atb_delta albert_combo_apply_atb_delta







    def albert_combo_apply_atb_delta(delta, state = nil)



      before = respond_to?(:at_count) ? at_count.to_i : nil



      user = respond_to?(:albert_combo_effect_user) ? albert_combo_effect_user : nil



      obj = respond_to?(:albert_combo_effect_obj) ? albert_combo_effect_obj : nil







      result = albert_mx_old_apply_atb_delta(delta, state)







      return result if before == nil



      return result if user == nil



      return result unless user.respond_to?(:albert_cc_aizhuo?) && user.albert_cc_aizhuo?



      return result unless delta.to_i < 0







      after = at_count.to_i



      actual_reduction = before - after



      return result if actual_reduction <= 0







      text = ALBERT_MECHANIC_EXPANSION.source_text(user, obj)







      # 低 ATB 目標仍有節奏回報：學會靜電回收後，



      # 單體 ATB 技能命中 ATB 低於 40% 的敵人時，自身 ATB 前進 8%。



      low_refund_ok = ALBERT_MECHANIC_EXPANSION.learned_skill?(



        user, ALBERT_MECHANIC_EXPANSION::AIZHUO_TIMING_PASSIVE_SKILL_ID



      )



      if low_refund_ok && obj != nil && obj.respond_to?(:for_one?) &&



         obj.for_one? && obj.respond_to?(:for_opponent?) && obj.for_opponent? &&



         before < (ALBERT_MECHANIC_EXPANSION::AIZHUO_LOW_ATB_THRESHOLD * 10.0).to_i &&



         !user.instance_variable_get(:@albert_mx_aizhuo_low_refund_used)



        user.instance_variable_set(:@albert_mx_aizhuo_low_refund_used, true)



        refund = (ALBERT_MECHANIC_EXPANSION::AIZHUO_LOW_ATB_REFUND_PERCENT * 10.0).to_i



        if refund > 0 && user.respond_to?(:albert_combo_apply_atb_delta)



          user.albert_combo_apply_atb_delta(refund, nil)



        end



      end







      threshold = nil







      if text =~ /<atb_interrupt_threshold\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i



        threshold = $1.to_f



      elsif text =~ /<interrupt_if_target_atb_above\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i



        threshold = $1.to_f



      end







      return result if threshold == nil







      threshold_value = (threshold * 10.0).to_i



      interrupted = before >= threshold_value && after < threshold_value



      return result unless interrupted







      # 新版：成功打斷不再免費增加 OD。
      # <atb_interrupt_cost:X> 會檢查本次行動開始時的 OD；足夠時才支付，
      # 並啟動後續的遲緩狀態。沒有 cost Tag 時仍保留舊版 gain 相容。
      paid = true
      if text =~ /<atb_interrupt_cost\s*:\s*(\d+)\s*>/i
        cost = $1.to_i
        start_od = defined?(ALBERT_CHARACTER_CORE) &&
                   ALBERT_CHARACTER_CORE.respond_to?(:action_start_od) ?
                   ALBERT_CHARACTER_CORE.action_start_od(user) : user.overdrive.to_i
        paid = start_od >= cost
        if paid && cost > 0 && defined?(ALBERT_CHARACTER_CORE) &&
           ALBERT_CHARACTER_CORE.respond_to?(:pay_conditional_od)
          paid = ALBERT_CHARACTER_CORE.pay_conditional_od(user, cost)
        end
      else
        gain = 0
        gain = $1.to_i if text =~ /<atb_interrupt_od\s*:\s*(\d+)\s*>/i
        if gain > 0 && defined?(ALBERT_CHARACTER_CORE) &&
           ALBERT_CHARACTER_CORE.respond_to?(:gain_od)
          ALBERT_CHARACTER_CORE.gain_od(user, gain)
        end
      end

      # 成功打斷且完成 OD 支付後附加指定狀態。
      if paid && text =~ /<atb_interrupt_state\s+(\d+)\s*:\s*(\d+)\s*>/i
        state_id = $1.to_i
        turns = $2.to_i
        unless state_resist?(state_id)
          chance = state_probability(state_id).to_i
          if rand(100) < chance
            existed = state?(state_id)
            add_state(state_id)
            if state?(state_id)
              turns_hash = instance_variable_get(:@state_turns)
              turns_hash[state_id] = turns if turns_hash != nil && turns > 0
              if existed
                @remained_states.push(state_id) if @remained_states != nil &&
                  !@remained_states.include?(state_id)
              else
                @added_states.push(state_id) if @added_states != nil &&
                  !@added_states.include?(state_id)
              end
            end
          end
        end
      end

      return result



    end



  end



end







#===============================================================================



# ■ ALBERT_CHARACTER_CORE：喬伊單段追擊自動候補



#===============================================================================



if defined?(ALBERT_CHARACTER_CORE) &&



   ALBERT_CHARACTER_CORE.respond_to?(:summon_followup_specs)



  module ALBERT_CHARACTER_CORE



    class << self



      unless method_defined?(:albert_mx_old_summon_followup_specs)



        alias albert_mx_old_summon_followup_specs summon_followup_specs



      end







      def summon_followup_specs(skill)



        result = albert_mx_old_summon_followup_specs(skill)



        text = note(skill)







        text.scan(/<summon_followup_type\s+([a-z_]+)\s*:\s*(\d+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?\s*>/i) do |data|



          type_name = data[0].to_s.downcase



          skill_id = data[1].to_i



          od_need = data[2].to_i



          od_cost = data[3] == nil ? 0 : data[3].to_i







          for actor in ALBERT_MECHANIC_EXPANSION.summons_by_type(type_name)



            result.push([actor.id, skill_id, od_need, od_cost])



          end



        end







        text.scan(/<summon_followup_role\s+([a-z0-9_]+)\s*:\s*(\d+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?\s*>/i) do |data|



          role_name = data[0].to_s.downcase



          skill_id = data[1].to_i



          od_need = data[2].to_i



          od_cost = data[3] == nil ? 0 : data[3].to_i







          for actor in ALBERT_MECHANIC_EXPANSION.summons_by_role(role_name)



            result.push([actor.id, skill_id, od_need, od_cost])



          end



        end







        return result



      end



    end



  end



end







#===============================================================================



# ■ ALBERT_SUMMON_CHAIN3：三段連鎖自動候補



#===============================================================================



if defined?(ALBERT_SUMMON_CHAIN3) &&



   ALBERT_SUMMON_CHAIN3.respond_to?(:chain_specs)



  module ALBERT_SUMMON_CHAIN3



    class << self



      unless method_defined?(:albert_mx_old_chain_specs)



        alias albert_mx_old_chain_specs chain_specs



      end







      def chain_specs(skill)



        result = albert_mx_old_chain_specs(skill)



        text = note(skill)







        text.scan(/<summon_chain_type\s+([1-3])\s*:\s*([a-z_]+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?(?:\s*:\s*(\d+))?\s*>/i) do |data|



          stage = data[0].to_i



          type_name = data[1].to_s.downcase



          skill_id = data[2].to_i



          od_need = data[3] == nil ? 0 : data[3].to_i



          od_cost = data[4] == nil ? 0 : data[4].to_i







          for actor in ALBERT_MECHANIC_EXPANSION.summons_by_type(type_name)



            result.push([stage, actor.id, skill_id, od_need, od_cost])



          end



        end







        text.scan(/<summon_chain_role\s+([1-3])\s*:\s*([a-z0-9_]+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?(?:\s*:\s*(\d+))?\s*>/i) do |data|



          stage = data[0].to_i



          role_name = data[1].to_s.downcase



          skill_id = data[2].to_i



          od_need = data[3] == nil ? 0 : data[3].to_i



          od_cost = data[4] == nil ? 0 : data[4].to_i







          for actor in ALBERT_MECHANIC_EXPANSION.summons_by_role(role_name)



            result.push([stage, actor.id, skill_id, od_need, od_cost])



          end



        end







        return result



      end



    end



  end



end







#===============================================================================



# ■ RPG::State：動態異常抗性標記



#===============================================================================



class RPG::State



  def albert_mx_dynamic_resist_state?



    text = ALBERT_MECHANIC_EXPANSION.note(self)



    return true if text =~ /<dynamic_resist\s*>/i



    return true if text =~ /<control_state\s*>/i



    return false



  end



end







#===============================================================================



# ■ Game_Enemy：Boss 動態異常抗性／敵人 Break 規則



#===============================================================================



class Game_Enemy < Game_Battler



  #--------------------------------------------------------------------------



  # ● 動態異常抗性



  #--------------------------------------------------------------------------



  def albert_mx_state_dynamic_resist?



    return false if enemy == nil



    text = ALBERT_MECHANIC_EXPANSION.note(enemy)



    return true if text =~ /<state_dynamic_resist\s*>/i



    return true if text =~ /<state_dynamic_resist_all\s*>/i



    return true if text =~ /<state_dynamic_resist_states\s*:/i



    return false



  end







  def albert_mx_dynamic_state_affected?(state_id)



    return false unless albert_mx_state_dynamic_resist?



    return false if state_id.to_i <= 1







    text = ALBERT_MECHANIC_EXPANSION.note(enemy)



    return true if text =~ /<state_dynamic_resist_all\s*>/i







    if text =~ /<state_dynamic_resist_states\s*:\s*([0-9,\s]+)\s*>/i



      ids = $1.split(/\s*,\s*/).collect { |value| value.to_i }



      return true if ids.include?(state_id.to_i)



    end







    state = $data_states[state_id]



    return false if state == nil



    return state.respond_to?(:albert_mx_dynamic_resist_state?) &&



           state.albert_mx_dynamic_resist_state?



  end







  def albert_mx_state_resist_step



    text = ALBERT_MECHANIC_EXPANSION.note(enemy)



    if text =~ /<state_resist_step\s*:\s*(\d+)\s*>/i



      return $1.to_i



    end



    return ALBERT_MECHANIC_EXPANSION::STATE_RESIST_DEFAULT_STEP



  end







  def albert_mx_state_resist_min



    text = ALBERT_MECHANIC_EXPANSION.note(enemy)



    if text =~ /<state_resist_min\s*:\s*(\d+)\s*>/i



      return ALBERT_MECHANIC_EXPANSION.clamp($1.to_i, 0, 100)



    end



    return ALBERT_MECHANIC_EXPANSION::STATE_RESIST_DEFAULT_MIN



  end







  def albert_mx_state_resist_recover



    text = ALBERT_MECHANIC_EXPANSION.note(enemy)



    if text =~ /<state_resist_recover\s*:\s*(\d+)\s*>/i



      return $1.to_i



    end



    return ALBERT_MECHANIC_EXPANSION::STATE_RESIST_DEFAULT_RECOVER



  end







  def albert_mx_state_resist_level(state_id)



    @albert_mx_state_resist_levels = {} if @albert_mx_state_resist_levels == nil



    return @albert_mx_state_resist_levels[state_id].to_i



  end







  def albert_mx_state_resist_rate(state_id)



    return 100 unless albert_mx_dynamic_state_affected?(state_id)



    level = albert_mx_state_resist_level(state_id)



    rate = 100 - level * albert_mx_state_resist_step



    return [rate, albert_mx_state_resist_min].max



  end







  def albert_mx_add_state_resist_level(state_id, amount = 1)



    return 0 unless albert_mx_dynamic_state_affected?(state_id)



    @albert_mx_state_resist_levels = {} if @albert_mx_state_resist_levels == nil



    old_value = albert_mx_state_resist_level(state_id)



    @albert_mx_state_resist_levels[state_id] = old_value + amount.to_i



    return @albert_mx_state_resist_levels[state_id] - old_value



  end







  def albert_mx_recover_state_resist_after_action



    return 0 unless albert_mx_state_dynamic_resist?



    return 0 if @albert_mx_state_resist_levels == nil







    recover = albert_mx_state_resist_recover



    return 0 if recover <= 0







    total = 0



    for state_id in @albert_mx_state_resist_levels.keys.clone



      old_value = @albert_mx_state_resist_levels[state_id].to_i



      new_value = old_value - recover



      new_value = 0 if new_value < 0



      @albert_mx_state_resist_levels[state_id] = new_value



      total += old_value - new_value



    end



    return total



  end







  def albert_mx_actual_state_application_context?



    return false unless $game_temp != nil && $game_temp.in_battle



    return false unless respond_to?(:albert_combo_effect_user)



    return albert_combo_effect_user != nil



  end







  #--------------------------------------------------------------------------



  # ● 最終狀態成功率套用動態抗性



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_mx_old_state_probability)



    alias albert_mx_old_state_probability state_probability



  end







  def state_probability(state_id)



    base = albert_mx_old_state_probability(state_id)



    return base unless albert_mx_dynamic_state_affected?(state_id)



    rate = albert_mx_state_resist_rate(state_id)



    result = (base.to_f * rate / 100.0).to_i



    return ALBERT_MECHANIC_EXPANSION.clamp(result, 0, 100)



  end







  #--------------------------------------------------------------------------



  # ● 首次成功附加 State 後提高動態抗性



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_mx_old_add_state)



    alias albert_mx_old_add_state add_state



  end







  def add_state(state_id)



    before_exists = state?(state_id)



    before_stack = albert_mx_state_stack_count(state_id)







    albert_mx_old_add_state(state_id)







    after_exists = state?(state_id)



    after_stack = albert_mx_state_stack_count(state_id)







    if albert_mx_actual_state_application_context? &&



       albert_mx_dynamic_state_affected?(state_id)



      success = (!before_exists && after_exists) || (after_stack > before_stack)



      albert_mx_add_state_resist_level(state_id, 1) if success



    end



  end







  #--------------------------------------------------------------------------



  # ● CSP 已存在 State 疊層增加時，也提高動態抗性



  #--------------------------------------------------------------------------



  if method_defined?(:remained_rules) &&



     !method_defined?(:albert_mx_old_remained_rules)



    alias albert_mx_old_remained_rules remained_rules







    def remained_rules(state_id, obj = nil)



      before = albert_mx_state_stack_count(state_id)



      result = albert_mx_old_remained_rules(state_id, obj)



      after = albert_mx_state_stack_count(state_id)







      if albert_mx_actual_state_application_context? &&



         albert_mx_dynamic_state_affected?(state_id) &&



         after > before



        albert_mx_add_state_resist_level(state_id, 1)



      end







      return result



    end



  end







  #--------------------------------------------------------------------------



  # ● 敵人端 Break 規則



  #--------------------------------------------------------------------------



  if method_defined?(:albert_cc_break_data) &&



     !method_defined?(:albert_mx_old_break_data)



    alias albert_mx_old_break_data albert_cc_break_data







    def albert_cc_break_data(user, skill)



      data = albert_mx_old_break_data(user, skill)



      return nil if data == nil







      power = data[0].to_i



      break_state = data[1].to_i



      broken_state = data[2].to_i



      threshold = data[3].to_i



      text = ALBERT_MECHANIC_EXPANSION.note(enemy)







      power = 0 if text =~ /<break_immune\s*>/i







      if text =~ /<break_resist\s*:\s*(\d+)\s*>/i



        resist = ALBERT_MECHANIC_EXPANSION.clamp($1.to_i, 0, 100)



        if power > 0



          reduced = (power.to_f * (100 - resist) / 100.0).ceil.to_i



          reduced = 1 if resist < 100 && reduced < 1



          power = reduced



        end



      end







      if text =~ /<break_threshold\s*:\s*(\d+)\s*>/i



        threshold = [$1.to_i, 1].max



      end







      return [power, break_state, broken_state, threshold]



    end



  end







  def albert_mx_break_recover_amount



    text = ALBERT_MECHANIC_EXPANSION.note(enemy)



    return $1.to_i if text =~ /<break_recover\s*:\s*(\d+)\s*>/i



    return 0



  end







  def albert_mx_break_recover_state_id



    text = ALBERT_MECHANIC_EXPANSION.note(enemy)



    return $1.to_i if text =~ /<break_recover_state\s*:\s*(\d+)\s*>/i



    if defined?(ALBERT_CHARACTER_CORE::BREAK_PROGRESS_STATE_ID)



      return ALBERT_CHARACTER_CORE::BREAK_PROGRESS_STATE_ID



    end



    return 0



  end







  def albert_mx_recover_break_after_action



    if instance_variable_get(:@albert_mx_skip_break_recover_once)
      instance_variable_set(:@albert_mx_skip_break_recover_once, false)
      return 0
    end

    amount = albert_mx_break_recover_amount



    state_id = albert_mx_break_recover_state_id



    return 0 if amount <= 0 || state_id <= 0



    return 0 unless state?(state_id)



    return albert_mx_reduce_state_stack(state_id, amount)



  end



end







#===============================================================================



# ■ Game_Actor：寶可夢 Combo-aware AI／機器人 Protocol



#===============================================================================



class Game_Actor < Game_Battler



  #--------------------------------------------------------------------------



  # ● AI Note 工具



  #--------------------------------------------------------------------------



  def albert_mx_ai_target_pool(skill)



    return [] if skill == nil



    if skill.for_opponent?



      return $game_troop.existing_members



    elsif skill.for_user?



      return [self]



    elsif skill.for_dead_friend?



      return $game_party.dead_members



    elsif skill.for_friend?



      return $game_party.existing_members



    end



    return []



  end







  def albert_mx_ai_required_state_ids(skill)



    result = []



    text = ALBERT_MECHANIC_EXPANSION.note(skill)



    text.scan(/<ai_require_state\s*:\s*(\d+)\s*>/i) do |data|



      result.push(data[0].to_i)



    end



    return result



  end







  def albert_mx_ai_target_condition_pass?(skill, target)



    return false if target == nil



    for state_id in albert_mx_ai_required_state_ids(skill)



      return false unless target.state?(state_id)



    end



    return true



  end







  def albert_mx_ai_valid_targets(skill)



    result = []



    for target in albert_mx_ai_target_pool(skill)



      result.push(target) if albert_mx_ai_target_condition_pass?(skill, target)



    end



    return result



  end







  def albert_mx_ai_skill_has_valid_target?(skill)



    required = albert_mx_ai_required_state_ids(skill)



    return true if required.empty?



    return !albert_mx_ai_valid_targets(skill).empty?



  end







  def albert_mx_ai_target_bonus(skill, target)



    return 0 if skill == nil || target == nil



    text = ALBERT_MECHANIC_EXPANSION.note(skill)



    bonus = 0







    text.scan(/<ai_bonus_vs_state\s+(\d+)\s*:\s*(-?\d+)\s*>/i) do |data|



      bonus += data[1].to_i if target.state?(data[0].to_i)



    end







    text.scan(/<ai_prefer_stack_below\s+(\d+)\s*:\s*(\d+)\s*>/i) do |data|



      state_id = data[0].to_i



      limit = data[1].to_i



      stacks = target.respond_to?(:albert_mx_state_stack_count) ?



               target.albert_mx_state_stack_count(state_id) : 0



      if stacks < limit



        bonus += ALBERT_MECHANIC_EXPANSION::AI_PREFER_STACK_BONUS



      end



    end







    return bonus



  end







  def albert_mx_ai_has_target_tags?(skill)



    text = ALBERT_MECHANIC_EXPANSION.note(skill)



    return true if text =~ /<ai_require_state\s*:/i



    return true if text =~ /<ai_bonus_vs_state\s+/i



    return true if text =~ /<ai_prefer_stack_below\s+/i



    return false



  end







  def albert_mx_ai_filter_actions(available_actions)



    result = []



    for skill in available_actions



      next if skill == nil



      next unless albert_mx_ai_skill_has_valid_target?(skill)



      result.push(skill)



    end



    return result



  end







  #--------------------------------------------------------------------------

  # ● AutoBattleAI 晚綁定整合（Phase 11）

  #--------------------------------------------------------------------------

  # albert_mx_ai_* 方法保留在本頁，作為角色機制資料／判定來源。

  # FS_AutoBattleAI_Authority v2.1 會在 AI 實際執行時以 respond_to? 呼叫它們。

  # 因此本頁不再 alias：

  #   albert_ai_damage_score / albert_auto_ai_note_bonus

  #   process_wild / balanced / healy / protect / support / ai_package

  # 也不再為 Robot Protocol 再包一層 Game_Actor#make_action。



  # ● 機器人協議資料



  #--------------------------------------------------------------------------



  def albert_mx_robot_protocol_data



    text = ALBERT_MECHANIC_EXPANSION.source_text(self, nil)



    default_skill = 0



    interval = 1



    conditionals = []







    if text =~ /<robot_protocol_skill\s*:\s*(\d+)\s*>/i



      default_skill = $1.to_i



    end







    if text =~ /<robot_protocol_interval\s*:\s*(\d+)\s*>/i



      interval = [$1.to_i, 1].max



    end







    text.scan(/<robot_protocol_if_state\s+(\d+)\s*:\s*(\d+)\s*>/i) do |data|



      conditionals.push([data[0].to_i, data[1].to_i])



    end







    return nil if default_skill <= 0 && conditionals.empty?



    return [default_skill, interval, conditionals]



  end







  def albert_mx_robot_protocol_target(skill, required_state_id = nil)



    return nil if skill == nil







    if skill.for_opponent?



      targets = $game_troop.existing_members



      if required_state_id != nil



        filtered = []



        for target in targets



          filtered.push(target) if target.state?(required_state_id)



        end



        targets = filtered



      end



      return nil if targets.empty?



      return targets[FS_AI_RANDOM.rand(targets.size, :robot_protocol_target)]



    elsif skill.for_user?



      return self



    elsif skill.for_dead_friend?



      targets = $game_party.dead_members



      return targets.empty? ? nil : targets[0]



    elsif skill.for_friend?



      targets = $game_party.existing_members



      return nil if targets.empty?



      weakest = targets[0]



      for target in targets



        weakest = target if target.hp < weakest.hp



      end



      return weakest



    end







    return nil



  end







  def albert_mx_try_robot_protocol



    return false unless respond_to?(:albert_robot?) && albert_robot?



    data = albert_mx_robot_protocol_data



    return false if data == nil







    default_skill_id = data[0]



    interval = data[1]



    conditionals = data[2]







    @albert_mx_robot_protocol_count = 0 if @albert_mx_robot_protocol_count == nil



    @albert_mx_robot_protocol_count += 1







    # 非協議回合，交回原 AI。



    return false unless @albert_mx_robot_protocol_count % interval == 0







    chosen_skill = nil



    chosen_target = nil







    # 1. 條件協議優先。



    for pair in conditionals



      state_id = pair[0]



      skill_id = pair[1]



      skill = $data_skills[skill_id]



      next if skill == nil



      next unless skill_can_use?(skill)







      target = albert_mx_robot_protocol_target(skill, state_id)



      next if target == nil && !skill.for_all?







      chosen_skill = skill



      chosen_target = target



      break



    end







    # 2. 沒有條件協議時，執行預設協議。



    if chosen_skill == nil && default_skill_id > 0



      skill = $data_skills[default_skill_id]



      if skill != nil && skill_can_use?(skill)



        target = albert_mx_robot_protocol_target(skill, nil)



        if target != nil || skill.for_all?



          chosen_skill = skill



          chosen_target = target



        end



      end



    end







    return false if chosen_skill == nil







    self.action.clear



    self.action.set_skill(chosen_skill.id)



    self.action.target_index = chosen_target.index if chosen_target != nil && !chosen_skill.for_all?



    return true



  end







  #--------------------------------------------------------------------------

  # ● Robot Protocol 的 make_action Hook（Phase 11）

  #--------------------------------------------------------------------------

  # 不再於此處 alias Game_Actor#make_action。

  # FS_AutoBattleAI_Authority v2.1 的 make_action 會在執行時偵測

  # albert_mx_try_robot_protocol，協議成功時直接結束本次選技。





end







#===============================================================================



# ■ Scene_Battle：每次技能行動一次性消耗／戰後回復



#===============================================================================



class Scene_Battle < Scene_Base



  #--------------------------------------------------------------------------



  # ● 戰鬥開始重置 Actor 端累積值



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_mx_old_start)



    alias albert_mx_old_start start



  end







  def start



    result = albert_mx_old_start







    if $game_party != nil



      for actor in $game_party.members



        next if actor == nil



        actor.instance_variable_set(:@albert_mx_robot_protocol_count, 0)



        actor.instance_variable_set(:@albert_mx_action_success, false)



        actor.instance_variable_set(:@albert_mx_revenge_action_snapshot, nil)



        actor.instance_variable_set(:@albert_mx_revenge_action_skill_id, nil)







        if actor.respond_to?(:albert_cc_ivy?) && actor.albert_cc_ivy?



          actor.albert_mx_clear_stored_cover_damage if



            actor.respond_to?(:albert_mx_clear_stored_cover_damage)



        end



      end



    end







    return result



  end







  #--------------------------------------------------------------------------



  # ● 技能行動範圍：



  #    - 艾薇復仇傷害使用行動開始時快照，確保多目標時計算一致。



  #    - 米亞／通用 consume_user_state 每次行動只消耗一次。



  #    - consume_stored_cover 每次行動只清空一次。



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_mx_old_execute_action_skill)



    alias albert_mx_old_execute_action_skill execute_action_skill



  end







  def execute_action_skill(*args)



    battler = @active_battler



    skill = nil



    begin



      skill = battler.action.skill if battler != nil && battler.action != nil



    rescue



      skill = nil



    end







    if battler != nil



      battler.instance_variable_set(:@albert_mx_action_success, false)



      battler.instance_variable_set(:@albert_mx_aizhuo_low_refund_used, false)



    end







    if battler != nil && skill != nil &&



       battler.respond_to?(:albert_cc_ivy?) && battler.albert_cc_ivy?



      text = ALBERT_MECHANIC_EXPANSION.source_text(battler, skill)



      if text =~ /<revenge_from_cover\s*:/i



        battler.instance_variable_set(



          :@albert_mx_revenge_action_snapshot,



          battler.albert_mx_stored_cover_damage



        )



        battler.instance_variable_set(:@albert_mx_revenge_action_skill_id, skill.id)



      end



    end







    begin



      result = albert_mx_old_execute_action_skill(*args)







      if battler != nil && skill != nil &&



         battler.instance_variable_get(:@albert_mx_action_success)



        text = ALBERT_MECHANIC_EXPANSION.source_text(battler, skill)







        # 米亞／通用：消耗使用者自己的 State 疊層。



        text.scan(/<consume_user_state\s+(\d+)\s*:\s*(\d+)\s*>/i) do |data|



          state_id = data[0].to_i



          amount = data[1].to_i



          battler.albert_mx_reduce_state_stack(state_id, amount) if



            battler.respond_to?(:albert_mx_reduce_state_stack)



        end







        # 艾薇：成功後清空 Cover 承傷累積。



        if text =~ /<consume_stored_cover\s*>/i



          battler.albert_mx_clear_stored_cover_damage if



            battler.respond_to?(:albert_mx_clear_stored_cover_damage)



        end



      end







      return result



    ensure



      if battler != nil



        battler.instance_variable_set(:@albert_mx_action_success, false)



        battler.instance_variable_set(:@albert_mx_aizhuo_low_refund_used, nil)



        battler.instance_variable_set(:@albert_mx_revenge_action_snapshot, nil)



        battler.instance_variable_set(:@albert_mx_revenge_action_skill_id, nil)



      end



    end



  end







  #--------------------------------------------------------------------------



  # ● 敵人完成有效行動後：



  #    - 回復動態異常抗性



  #    - 自然恢復 Break 進度



  #



  #  ATB_DynamicResistance 已經包過 execute_action；本補丁放在其下方，



  #  因此三套「行動後恢復」會依 alias 鏈安全串接。



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_mx_old_execute_action)



    alias albert_mx_old_execute_action execute_action



  end







  def execute_action(*args)



    battler = @active_battler



    valid_before = false







    begin



      valid_before = battler != nil &&



                     battler.action != nil &&



                     battler.action.valid?



    rescue



      valid_before = battler != nil



    end







    result = albert_mx_old_execute_action(*args)







    if valid_before && battler.is_a?(Game_Enemy)



      battler.albert_mx_recover_state_resist_after_action if



        battler.respond_to?(:albert_mx_recover_state_resist_after_action)



      battler.albert_mx_recover_break_after_action if



        battler.respond_to?(:albert_mx_recover_break_after_action)



    end







    return result



  end



end











#===============================================================================
# ■ v1.2 OD 經濟擴充
#===============================================================================
class Game_Battler
  def albert_mx_od12_note(obj)
    return "" if obj == nil
    return obj.note.to_s if obj.respond_to?(:note)
    return ""
  end

  def albert_mx_od12_success?
    return false if @missed || @evaded || @skipped
    return true
  end

  def albert_mx_od12_start_od(user)
    if defined?(ALBERT_CHARACTER_CORE) &&
       ALBERT_CHARACTER_CORE.respond_to?(:action_start_od)
      return ALBERT_CHARACTER_CORE.action_start_od(user)
    end
    return user.overdrive.to_i if user != nil && user.respond_to?(:overdrive)
    return 0
  end

  def albert_mx_od12_add_state_layers(state_id, amount)
    state_id = state_id.to_i
    amount = amount.to_i
    return if state_id <= 0 || amount <= 0
    before = state?(state_id)
    unless before
      add_state(state_id)
      amount -= 1 if state?(state_id)
    end
    if amount > 0 && respond_to?(:increase_stack)
      increase_stack(state_id, amount)
    end
  end

  # 泰勒：目標已有破勢時，持有足夠 OD 可強化乘隙追打。
  if method_defined?(:albert_combo_damage_bonus_percent) &&
     !method_defined?(:albert_mx_od12_old_damage_bonus_percent)
    alias albert_mx_od12_old_damage_bonus_percent albert_combo_damage_bonus_percent

    def albert_combo_damage_bonus_percent(user, obj)
      bonus = albert_mx_od12_old_damage_bonus_percent(user, obj).to_f
      text = albert_mx_od12_note(obj)
      if user != nil && user.respond_to?(:albert_cc_tyler?) && user.albert_cc_tyler? &&
         text =~ /<tyler_break_lock_od\s+(\d+)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i
        cost = $1.to_i
        add = $2.to_f
        state_id = defined?(ALBERT_CHARACTER_CORE::BREAK_PROGRESS_STATE_ID) ?
                   ALBERT_CHARACTER_CORE::BREAK_PROGRESS_STATE_ID : 50
        if state?(state_id) && albert_mx_od12_start_od(user) >= cost
          bonus += add
        end
      end
      return bonus.to_i
    end
  end

  #--------------------------------------------------------------------------
  # Phase 25：OD12 skill_effect 前置快照 Provider
  #--------------------------------------------------------------------------
  def albert_mx_od12_capture_skill_effect_context(user, skill)
    text = albert_mx_od12_note(skill)
    break_state_id = defined?(ALBERT_CHARACTER_CORE::BREAK_PROGRESS_STATE_ID) ?
                     ALBERT_CHARACTER_CORE::BREAK_PROGRESS_STATE_ID : 50
    break_before = state?(break_state_id)
    convert_source = 0
    convert_target = 0
    convert_keep = 0
    convert_cost = 0
    if text =~ /<convert_preserve_state_od\s+(\d+)\s*:\s*(\d+)\s*:\s*(\d+)\s*:\s*(\d+)\s*>/i
      convert_source = $1.to_i
      convert_target = $2.to_i
      convert_keep = $3.to_i
      convert_cost = $4.to_i
    end
    convert_before = convert_source > 0 ? albert_mx_state_stack_count(convert_source) : 0
    detonate_before = {}
    text.scan(/<detonate_preserve_state\s+(\d+)\s*:\s*(\d+)\s*>/i) do |data|
      sid = data[0].to_i
      detonate_before[sid] = albert_mx_state_stack_count(sid)
    end
    return {
      :text => text, :break_before => break_before,
      :convert_source => convert_source, :convert_target => convert_target,
      :convert_keep => convert_keep, :convert_cost => convert_cost,
      :convert_before => convert_before, :detonate_before => detonate_before,
    }
  end

  #--------------------------------------------------------------------------
  # Phase 25：OD12 skill_effect 後處理 Provider
  #--------------------------------------------------------------------------
  def albert_mx_od12_after_skill_effect(user, skill, context)
    context = {} unless context.is_a?(Hash)
    text = context[:text].to_s
    break_before = context[:break_before] ? true : false
    convert_source = context[:convert_source].to_i
    convert_target = context[:convert_target].to_i
    convert_keep = context[:convert_keep].to_i
    convert_cost = context[:convert_cost].to_i
    convert_before = context[:convert_before].to_i
    detonate_before = context[:detonate_before]
    detonate_before = {} unless detonate_before.is_a?(Hash)
    success = albert_mx_od12_success?

    if success && user != nil && self.equal?(user) &&
       text =~ /<aizhuo_overload_next_atb\s+([0-9]+(?:\.[0-9]+)?)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i
      user.instance_variable_set(:@albert_od_aizhuo_overload_bonus, $1.to_f)
      user.instance_variable_set(:@albert_od_aizhuo_overload_pierce, $2.to_f)
    end

    if success && user != nil && convert_source > 0 && convert_target > 0 &&
       convert_before > 0 && state?(convert_target) && !state?(convert_source) &&
       albert_mx_od12_start_od(user) >= convert_cost
      paid = true
      if convert_cost > 0 && defined?(ALBERT_CHARACTER_CORE) &&
         ALBERT_CHARACTER_CORE.respond_to?(:pay_conditional_od)
        paid = ALBERT_CHARACTER_CORE.pay_conditional_od(user, convert_cost)
      end
      albert_mx_od12_add_state_layers(convert_source, convert_keep) if paid
    end

    if success && user != nil
      for sid in detonate_before.keys
        next if detonate_before[sid].to_i <= 0
        keep = 0
        if text =~ /<detonate_preserve_state\s+#{sid}\s*:\s*(\d+)\s*>/i
          keep = $1.to_i
        end
        albert_mx_od12_add_state_layers(sid, keep)
      end
    end

    if success && user != nil && break_before &&
       user.respond_to?(:albert_cc_tyler?) && user.albert_cc_tyler? &&
       @hp_damage.to_i > 0 &&
       text =~ /<tyler_break_lock_od\s+(\d+)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i
      cost = $1.to_i
      if albert_mx_od12_start_od(user) >= cost
        paid = true
        if cost > 0 && defined?(ALBERT_CHARACTER_CORE) &&
           ALBERT_CHARACTER_CORE.respond_to?(:pay_conditional_od)
          paid = ALBERT_CHARACTER_CORE.pay_conditional_od(user, cost)
        end
        instance_variable_set(:@albert_mx_skip_break_recover_once, true) if paid
      end
    end
    return nil
  end

  # 下一次 ATB 削減只要真的削到數值，就消耗超載準備狀態。
  if method_defined?(:albert_combo_apply_atb_delta) &&
     !method_defined?(:albert_mx_od12_old_apply_atb_delta)
    alias albert_mx_od12_old_apply_atb_delta albert_combo_apply_atb_delta

    def albert_combo_apply_atb_delta(delta, state = nil)
      before = respond_to?(:at_count) ? at_count.to_i : nil
      user = respond_to?(:albert_combo_effect_user) ? albert_combo_effect_user : nil
      result = albert_mx_od12_old_apply_atb_delta(delta, state)
      if before != nil && delta.to_i < 0 && user != nil && respond_to?(:at_count)
        actual = before - at_count.to_i
        if actual > 0 &&
           (user.instance_variable_get(:@albert_od_aizhuo_overload_bonus).to_f > 0.0 ||
            user.instance_variable_get(:@albert_od_aizhuo_overload_pierce).to_f > 0.0)
          user.instance_variable_set(:@albert_od_aizhuo_overload_bonus, 0.0)
          user.instance_variable_set(:@albert_od_aizhuo_overload_pierce, 0.0)
          state_id = ALBERT_MECHANIC_EXPANSION::AIZHUO_OVERLOAD_STATE_ID
          user.remove_state(state_id) if state_id > 0 && user.state?(state_id)
        end
      end
      return result
    end
  end
end
