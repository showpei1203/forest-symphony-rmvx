#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_CharacterMechanicCore v1.3 OD Economy
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_CharacterMechanicCore v1.3 OD Economy」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Battler、Scene_Battle、Game_Actor、ALBERT_CHARACTER_CORE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：JOEY_ACTOR_ID、MIA_ACTOR_ID、AIZHUO_ACTOR_ID、VINA_ACTOR_ID、IVY_ACTOR_ID、TYLER_ACTOR_ID、ENABLE_JOEY_SUMMON_OD、ENABLE_IVY_COVER_OD。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 11 個 alias／方法包裝，載入順序具有語意；登記 $imported：AlbertCharacterMechanicCore；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# 【Phase 25】v1.3 的 Joey Pull／Mia Revive 已回寫主 skill_effect，移除同頁第二層 albert_cc_v13_old_skill_effect。
#==============================================================================
#==============================================================================



# ■ Albert_RMVX_CharacterMechanicCore_v1_3_OD_Economy_TC.rb



#------------------------------------------------------------------------------



# RPG Maker VX / RGSS2 / Ruby 1.8 相容



# Character Mechanic Core 角色機制核心 v1.3 OD 經濟版



#------------------------------------------------------------------------------



# 【用途】



# 本腳本建立在目前專案既有系統之上，將六名主要角色的特色統一接到



# KGC OverDrive（OD）底層資源，並提供：



#



#   1. 喬伊：召喚物行動獲得 OD、技能後觸發召喚物追擊。



#   2. 艾薇：實際替隊友 Cover 承傷時額外獲得 OD。



#   3. 艾卓：依「實際削減的 ATB 幅度」獲得 OD。



#   4. 維娜：成功附加新狀態或增加狀態疊層時獲得 OD；支援已中毒時一次增加多層。



#   5. 泰勒：使用 Break 破勢／崩防系統；我方屬性克制傷害也能協助累積破勢。



#   6. 米亞：依有效治療與溢出治療獲得 OD，並能轉換溢療價值。



#   7. 提供依 OD 強化治療量、Break 效率、條件式狀態疊層等通用功能。



#



#------------------------------------------------------------------------------



# 【相依腳本】



# 本腳本依目前專案環境設計，主要搭配：



#



#   Tankentai SBS



#   Tankentai ATB



#   KGC OverDrive



#   YEZ / YEM Custom Status Properties（CSP 疊層）



#   Albert_RMVX_ComboCore_AllInOne_v1_1_OD



#



# 請勿把本腳本放在 Main 以下，因為 Main 以下腳本不會生效。



#



#------------------------------------------------------------------------------



# 【建議腳本順序】



#



#   AutoBattleAI_IntegrationFix



#   Albert_RMVX_ComboCore_AllInOne_v1_1_OD



#   Albert_RMVX_CharacterMechanicCore_v1_2_TC   ← 本腳本



#   全腳本匯出工具



#   Main



#



#------------------------------------------------------------------------------



# 【主要角色 Actor ID】



#



#   喬伊   = 1



#   米亞   = 2



#   艾卓   = 3



#   維娜   = 4



#   艾薇   = 5



#   泰勒   = 6



#



# 如日後 Actor ID 有變更，請修改 ALBERT_CHARACTER_CORE 模組中的常數。



#



#==============================================================================



# ■ 一、六角色 OD 獲得規則



#==============================================================================



#



# 這些 Note Tag 可放在：技能、Actor、裝備、State。



# 實際讀取範圍會依功能而定，本腳本會整合技能、角色資料、裝備與目前狀態。



#



#------------------------------------------------------------------------------



# 【喬伊：召喚物每完成一次正常行動，喬伊獲得 OD】



#



#   <cc_od_summon_action:40>



#



# 代表每次場上召喚物正常完成行動，喬伊獲得 80 OD。



# 預設值由 JOEY_OD_PER_SUMMON_ACTION 控制。



# 召喚物追擊預設不算一次正常召喚物行動，避免無限循環。



#



#------------------------------------------------------------------------------



# 【艾薇：成功 Cover 承傷時額外獲得 OD】



#



#   <cc_od_cover:60>



#



# 代表艾薇實際替隊友承受一次 Cover 傷害時，額外獲得 60 OD。



# 注意：如果 KGC OverDrive 本身也會因受傷增加 OD，兩者會同時生效。



#



#------------------------------------------------------------------------------



# 【艾卓：依實際削減 ATB 幅度獲得 OD】



#



#   <cc_od_atb_per_10:20>



#



# 代表每實際削減目標 10% ATB，艾卓獲得 40 OD。



# 只計算實際減少量。例如目標只剩 10% ATB，即使技能理論削 30%，



# 也只按照真正減掉的 10% 計算。



#



#------------------------------------------------------------------------------



# 【維娜：成功附加／增加 State 疊層時獲得 OD】



#



#   <cc_od_state_stack:30>



#



# 每成功新增 1 層狀態，獲得 70 OD。



# 已整合 CSP 疊層判定，會比較技能使用前後的實際層數差。



#



#------------------------------------------------------------------------------



# 【泰勒：增加破勢與觸發崩防時獲得 OD】



#



#   <cc_od_break_point:25>



#   <cc_od_break:100>



#



# 第一行：每成功增加 1 點 Break 破勢，獲得 50 OD。



# 第二行：真正觸發崩防時，額外獲得 200 OD。



#



#------------------------------------------------------------------------------



# 【米亞：有效治療／溢療獲得 OD】



#



#   <cc_od_heal_percent:2.5>



#   <cc_od_overheal_percent:1>



#



# 第一行：每有效治療目標最大 HP 的 1%，獲得 5 OD。



# 第二行：每產生相當於目標最大 HP 1% 的溢療，獲得 3 OD。



#



#==============================================================================



# ■ 二、米亞：OD 強化治療與溢療轉換



#==============================================================================



#



# 【固定提高治療量】



#   <heal_bonus:15>



#   治療量 +15%。



#



# 【OD 達門檻時提高治療量】



#   <heal_bonus_if_od 50:20>



#   使用者 OD 達 50% 以上時，治療量 +20%。



#



# 【依目前 OD 比例線性提高治療量】



#   <heal_bonus_per_od_percent:0.2>



#   每 1% OD 提高 0.2% 治療量，滿 OD 時總共 +20%。



#



#------------------------------------------------------------------------------



# 【溢療轉 OD】



#   <overheal_to_od:50>



#   溢療量的 50% 轉成施術者 OD。



#



# 【溢療轉目標 MP】



#   <overheal_to_mp:30>



#   溢療量的 30% 回復目標 MP。



#



# 【溢療轉施術者 MP】



#   <overheal_to_user_mp:30>



#   溢療量的 30% 回復施術者 MP。



#



# 【溢療轉施術者 State 疊層】



#   <overheal_to_user_state 41:10>



#   每產生相當於目標最大 HP 10% 的溢療，施術者增加 1 層 State 41。



#   米亞的魔力層應使用此標籤，讓蓄積、增傷與消耗都歸屬米亞本人。



#



# 【溢療轉目標 State 疊層】



#   <overheal_to_state 41:10>



#   每產生相當於目標最大 HP 10% 的溢療，治療目標增加 1 層 State 41。



#   保留作為通用功能；真正屬於受療者的祝福可使用此標籤。



#



# 【溢療轉 Mana Shield 容量】



#   <overheal_to_shield 52:50>



#   溢療量的 50% 轉成 State 52 的動態 Mana Shield 容量。



#   需要搭配 Albert ComboCore 的 Mana Shield 功能。



#



#==============================================================================



# ■ 三、泰勒：Break 破勢／崩防系統



#==============================================================================



#



# 建議資料庫設定：



#



#   State 50：破勢進度狀態，建議 Note 寫 <max stack 5>



#   State 51：真正的崩防狀態，在資料庫設定 DEF / SPI Rate 與持續時間



#



# 技能 Note：



#



#   <break_power:1>



#     命中後增加 1 點破勢。



#



#   <break_state:50>



#     指定使用哪個 State 作為破勢進度。



#



#   <broken_state:51>



#     指定破勢達門檻後轉成哪個崩防 State。



#



#   <break_threshold:5>



#     指定幾點破勢觸發崩防。



#



#   <break_bonus_if_od 50:1>



#   <break_bonus_if_od 80:1>



#     OD 達 50% 時額外 +1 破勢，達 80% 再額外 +1。



#     門檻加成為累加制。



#



#==============================================================================



# ■ 四、喬伊：召喚物追擊



#==============================================================================



#



# 在喬伊「觸發追擊的技能」Note 寫：



#



#   <summon_followup 18:241:700>



#



# 格式：



#   <summon_followup 召喚物ActorID:追擊技能ID:需求OD>



#



# 範例代表：



#   喬伊使用該技能前 OD 至少 700，且 Actor 18 的召喚物在場且存活時，



#   喬伊完整 SBS 動作結束後，Actor 18 立刻使用 Skill 241 追加攻擊。



#



# 若還要消耗喬伊 OD：



#



#   <summon_followup 18:241:700:200>



#



# 格式：



#   <summon_followup 召喚物ActorID:追擊技能ID:需求OD:觸發後消耗OD>



#



# 此例表示：需要 700 OD 才能觸發，成功追擊後消耗 200 OD。



#



# 追擊特色：



#   ・使用召喚物自己的能力值與技能公式。



#   ・使用追擊技能自己的 Tankentai SBS base_action。



#   ・不消耗召喚物正常 ATB。



#   ・不吃掉召喚物下一個正常回合。



#   ・預設不消耗召喚物 MP／OD，也不走正常技能冷卻鏈。



#   ・原目標死亡時，可依設定重新選擇存活敵人。



#   ・同一技能可以寫多組追擊 Note，但實際觸發數受 FOLLOWUP_MAX_PER_ACTION 限制。



#



# 注意：追擊直接插入 Tankentai SBS 行動流程，務必實機測試複雜多段技能、



# 即死技、召喚物死亡、目標死亡與其他特殊 Add-on 的互動。



#



#==============================================================================



# ■ 五、功能開關與預設值



#==============================================================================



#



# 可在 ALBERT_CHARACTER_CORE 模組內調整：



#



#   ENABLE_JOEY_SUMMON_OD



#   ENABLE_IVY_COVER_OD



#   ENABLE_AIZHUO_ATB_OD



#   ENABLE_VINA_STATE_OD



#   ENABLE_TYLER_BREAK



#   ENABLE_MIA_HEAL



#   ENABLE_SUMMON_FOLLOWUP



#



# 各功能可獨立設為 true / false。



#



# 其他常用設定：



#



#   BREAK_PROGRESS_STATE_ID



#   BROKEN_STATE_ID



#   BREAK_THRESHOLD



#   FOLLOWUP_MAX_PER_ACTION



#   FOLLOWUP_RETARGET_IF_DEAD



#   FOLLOWUP_SHOW_SKILL_NAME



#



#==============================================================================



# ■ 六、重要注意事項



#==============================================================================



#



# 1. 本腳本必須放在 Albert_RMVX_ComboCore_AllInOne_v1_1_OD 下方。



# 2. Main 以下腳本無效，不要放到 Main 以下。



# 3. Break 預設使用 State 50 / 51，若已被其他系統占用，請更換 ID。



# 4. 溢療轉 Mana Shield 需要 ComboCore 的 Mana Shield 功能正常運作。



# 5. 艾卓 OD 必須透過 ComboCore 的 albert_combo_apply_atb_delta 才能取得實際削減量。



# 6. 艾薇 Cover OD 依賴 ComboCore 設定的 @albert_cover_redirect_guard 標記。



# 7. 召喚物追擊為 Tankentai SBS 深度整合功能，正式使用前請逐項實機測試。



#



#==============================================================================







$imported = {} if $imported == nil



$imported["AlbertCharacterMechanicCore"] = true





#------------------------------------------------------------------------------



# 【維娜：已存在狀態時，成功附加可增加多層】



#   <state_stack_if_present 31:2>



# 寫在技能 Note。目標原本已有 State 31，且這次 State 31 判定成功時，

# 本次總共增加 2 層；目標原本沒有該狀態時，仍只增加原本的 1 層。

# 若已接近最大層數，實際增加量仍受 State 的 <max stack> 限制。



#------------------------------------------------------------------------------



# 【全隊：屬性克制傷害協助累積破勢】



# 我方 Actor／召喚物對敵人造成實際 HP 傷害，且判定為屬性克制時，

# 額外累積 WEAKNESS_BREAK_POWER 點破勢。

# 若技能本身另有 <break_power:X>，兩者會相加後再套用敵方 Break 抗性。

# 敵方已處於崩防時，仍遵守 BREAK_REBUILD_WHILE_BROKEN 設定。



module ALBERT_CHARACTER_CORE



  VERSION = "1.2"



  #--------------------------------------------------------------------------



  # ● 目前專案已確認的主要角色 Actor ID



  #--------------------------------------------------------------------------



  JOEY_ACTOR_ID   = 1



  MIA_ACTOR_ID    = 2



  AIZHUO_ACTOR_ID = 3



  VINA_ACTOR_ID   = 4



  IVY_ACTOR_ID    = 5



  TYLER_ACTOR_ID  = 6



  #--------------------------------------------------------------------------



  # ● 各功能模組開關



  #--------------------------------------------------------------------------



  ENABLE_JOEY_SUMMON_OD       = true



  ENABLE_IVY_COVER_OD         = false



  ENABLE_AIZHUO_ATB_OD        = true



  ENABLE_VINA_STATE_OD        = true



  ENABLE_TYLER_BREAK          = true



  ENABLE_MIA_HEAL             = true



  ENABLE_SUMMON_FOLLOWUP      = true



  #--------------------------------------------------------------------------



  # ● 各角色預設 OD 獲得量



  #   以下為較保守的初始值，可透過 Note Tag 覆蓋。



  #--------------------------------------------------------------------------



  JOEY_OD_PER_SUMMON_ACTION       = 40



  IVY_OD_PER_COVER                = 0



  AIZHUO_OD_PER_10_ATB_REDUCTION  = 20



  VINA_OD_PER_STATE_STACK         = 30



  TYLER_OD_PER_BREAK_POINT        = 25



  TYLER_OD_ON_BREAK               = 100



  MIA_OD_PER_HEAL_PERCENT         = 2.5



  MIA_OD_PER_OVERHEAL_PERCENT     = 1.0


  # 六名主角即使尚未學會標準 <overdrive N> 技能，也保留 KGC 預設 OD 來源。
  HERO_OD_ACTOR_IDS = [1, 2, 3, 4, 5, 6]

  # 戰鬥間最多攜帶 25% OD，避免上一場滿條後一路當祖產使用。
  OD_CARRYOVER_CAP = 250

  # 專屬機制每次行動的 OD 回收上限。KGC 預設來源不受此限制。
  MIA_SPECIAL_OD_ACTION_CAP     = 250
  AIZHUO_SPECIAL_OD_ACTION_CAP = 200
  VINA_SPECIAL_OD_ACTION_CAP   = 250

  # 維娜把既有病灶複製到其他目標時，使用較低的每層回收。
  VINA_OD_PER_COPIED_STATE_STACK = 15



  # 召喚物追擊預設不算一般召喚物行動，避免喬伊因此重複獲得 OD。



  FOLLOWUP_COUNTS_AS_SUMMON_ACTION = false



  #--------------------------------------------------------------------------



  # ● 泰勒 Break 破勢／崩防預設值



  #   請依資料庫實際使用情況設定 State ID。



  #



  #   BREAK_PROGRESS_STATE_ID：



  #     用來記錄破勢進度的隱藏／系統 State，建議使用 <max stack 5>。



  #



  #   BROKEN_STATE_ID：



  #     真正的崩防 State，請在資料庫設定 DEF／SPI Rate 等效果。



  #--------------------------------------------------------------------------



  BREAK_PROGRESS_STATE_ID = 50



  BROKEN_STATE_ID         = 51



  BREAK_THRESHOLD         = 5



  BREAK_REBUILD_WHILE_BROKEN = false



  # 我方 Actor／召喚物以屬性克制傷害命中敵人時，自動增加破勢。

  ENABLE_WEAKNESS_BREAK      = true



  WEAKNESS_BREAK_POWER       = 1



  # true：只讓我方 Actor／召喚物攻擊敵人時觸發，避免敵方反過來累積我方破勢。

  WEAKNESS_BREAK_ACTOR_TO_ENEMY_ONLY = true



  #--------------------------------------------------------------------------



  # ● 召喚物追擊預設設定



  #--------------------------------------------------------------------------



  FOLLOWUP_MAX_PER_ACTION = 1



  FOLLOWUP_RETARGET_IF_DEAD = true



  FOLLOWUP_SHOW_SKILL_NAME = true



  #--------------------------------------------------------------------------



  # ● 工具方法：安全讀取 Note



  #--------------------------------------------------------------------------



  def self.note(obj)



    return "" if obj == nil



    if defined?(ALBERT_COMBO_CORE) && ALBERT_COMBO_CORE.respond_to?(:note)



      return ALBERT_COMBO_CORE.note(obj)



    end



    return obj.note.to_s if obj.respond_to?(:note) && obj.note != nil



    return ""



  end



  # 整合技能／物品、Actor／Enemy 資料、裝備與目前 State 的 Note。



  def self.source_text(user, obj = nil)



    text = ""



    text += note(obj)



    return text if user == nil



    if user.actor?



      text += note(user.actor) if user.respond_to?(:actor)



      if user.respond_to?(:equips)



        for equip in user.equips.compact



          text += note(equip)



        end



      end



    else



      text += note(user.enemy) if user.respond_to?(:enemy)



    end



    for state in user.states.compact



      text += note(state)



    end



    return text



  end



  def self.clamp(value, min_value, max_value)



    return [[value, min_value].max, max_value].min



  end



  def self.actor_by_id(actor_id)



    return nil if $game_actors == nil



    actor = $game_actors[actor_id]



    return nil if actor == nil



    return actor



  end



  def self.actor_in_battle?(actor)



    return false if actor == nil



    return false if $game_party == nil



    return $game_party.members.include?(actor)



  end



  def self.gain_od(battler, value)



    return 0 if battler == nil



    return 0 unless battler.respond_to?(:overdrive)



    return 0 unless battler.respond_to?(:overdrive=)



    value = value.to_i



    return 0 if value == 0



    before = battler.overdrive.to_i



    battler.overdrive = before + value



    return battler.overdrive.to_i - before



  end



  def self.od_rate(battler)



    return 0.0 if battler == nil



    if battler.respond_to?(:albert_od_rate)



      return battler.albert_od_rate.to_f



    end



    return 0.0 unless battler.respond_to?(:overdrive)



    return 0.0 unless battler.respond_to?(:max_overdrive)



    max_value = battler.max_overdrive.to_f



    return 0.0 if max_value <= 0.0



    return battler.overdrive.to_f * 100.0 / max_value



  end



  def self.stack_count(battler, state_id)



    return 0 if battler == nil



    return 0 unless battler.state?(state_id)



    if battler.respond_to?(:stack)



      begin



        return [battler.stack(state_id).to_i, 1].max



      rescue



      end



    end



    return 1



  end



  #--------------------------------------------------------------------------



  # ● 各角色專屬 OD 獲得量覆蓋用 Note 輔助方法



  #



  # 範例，可放在技能／Actor／裝備／State：



  #   <cc_od_summon_action:40>



  #   <cc_od_cover:60>



  #   <cc_od_atb_per_10:20>



  #   <cc_od_state_stack:30>



  #   <cc_od_break_point:25>



  #   <cc_od_break:100>



  #   <cc_od_heal_percent:2.5>



  #   <cc_od_overheal_percent:1>



  #--------------------------------------------------------------------------



  def self.note_number(text, tag, default_value)



    regex = /<#{tag}\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i



    return $1.to_f if text =~ regex



    return default_value



  end



  #--------------------------------------------------------------------------



  # ● 召喚物追擊 Note 解析器



  #



  # 寫在喬伊技能 Note：



  #   <summon_followup 18:241:700>



  #     喬伊行動前 OD 至少 700 時，Actor 18 使用 Skill 241 追擊。



  #



  #   <summon_followup 18:241:700:200>



  #     同上，但成功觸發追擊後額外消耗喬伊 200 OD。



  #



  # 允許多組 Note；實際觸發數由 FOLLOWUP_MAX_PER_ACTION 限制。



  #--------------------------------------------------------------------------



  def self.summon_followup_specs(skill)



    result = []



    text = note(skill)



    regex = /<summon_followup\s+(\d+)\s*:\s*(\d+)\s*:\s*(\d+)(?:\s*:\s*(\d+))?\s*>/i



    text.scan(regex) do |data|



      actor_id = data[0].to_i



      skill_id = data[1].to_i



      od_need  = data[2].to_i



      od_cost  = data[3] == nil ? 0 : data[3].to_i



      result.push([actor_id, skill_id, od_need, od_cost])



    end



    return result



  end



end



#==============================================================================



# ■ Game_Battler



#==============================================================================



class Game_Battler



  #--------------------------------------------------------------------------



  # ● 六名角色身分判定輔助方法



  #--------------------------------------------------------------------------



  def albert_cc_joey?



    return actor? && self.id == ALBERT_CHARACTER_CORE::JOEY_ACTOR_ID



  end



  def albert_cc_mia?



    return actor? && self.id == ALBERT_CHARACTER_CORE::MIA_ACTOR_ID



  end



  def albert_cc_aizhuo?



    return actor? && self.id == ALBERT_CHARACTER_CORE::AIZHUO_ACTOR_ID



  end



  def albert_cc_vina?



    return actor? && self.id == ALBERT_CHARACTER_CORE::VINA_ACTOR_ID



  end



  def albert_cc_ivy?



    return actor? && self.id == ALBERT_CHARACTER_CORE::IVY_ACTOR_ID



  end



  def albert_cc_tyler?



    return actor? && self.id == ALBERT_CHARACTER_CORE::TYLER_ACTOR_ID



  end



  #--------------------------------------------------------------------------



  # ● 依 OD 調整治療量



  #



  # 可放在技能／Actor／裝備／State 的 Note Tag：



  #   <heal_bonus:15>



  #   <heal_bonus_if_od 50:20>



  #   <heal_bonus_per_od_percent:0.2>



  #--------------------------------------------------------------------------



  def albert_cc_heal_bonus_percent(user, obj)



    text = ALBERT_CHARACTER_CORE.source_text(user, obj)



    bonus = 0.0



    text.scan(/<heal_bonus\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      bonus += data[0].to_f



    end



    if user != nil



      rate = ALBERT_CHARACTER_CORE.od_rate(user)



      text.scan(/<heal_bonus_if_od\s+([0-9]+(?:\.[0-9]+)?)\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



        bonus += data[1].to_f if rate >= data[0].to_f



      end



      text.scan(/<heal_bonus_per_od_percent\s*:\s*(-?[0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



        bonus += rate * data[0].to_f



      end



    end



    return ALBERT_CHARACTER_CORE.clamp(bonus, -100.0, 900.0)



  end



  unless method_defined?(:albert_cc_old_make_obj_damage_value)



    alias albert_cc_old_make_obj_damage_value make_obj_damage_value



  end



  def make_obj_damage_value(user, obj)



    albert_cc_old_make_obj_damage_value(user, obj)



    return if obj == nil



    # 只處理 HP 治療；傷害部分已由 ComboCore 負責。



    if @hp_damage != nil && @hp_damage < 0



      bonus = albert_cc_heal_bonus_percent(user, obj)



      if bonus != 0



        @hp_damage = (@hp_damage * (100.0 + bonus) / 100.0).to_i



      end



    end



  end



  #--------------------------------------------------------------------------



  # ● 從技能 Note 讀取 Break 資料



  #



  #   <break_power:1>



  #   <break_state:50>



  #   <broken_state:51>



  #   <break_threshold:5>



  #   <break_bonus_if_od 50:1>



  #   <break_bonus_if_od 80:1>



  #



  # 多個 OD 門檻加成會累加。



  #--------------------------------------------------------------------------



  #--------------------------------------------------------------------------



  # ● 判定本次是否為可累積破勢的屬性克制傷害



  #--------------------------------------------------------------------------



  def albert_cc_weakness_break_eligible?(user, obj = nil)



    return false unless ALBERT_CHARACTER_CORE::ENABLE_WEAKNESS_BREAK



    return false if user == nil



    return false unless @weak



    return false unless @hp_damage.to_i > 0



    if ALBERT_CHARACTER_CORE::WEAKNESS_BREAK_ACTOR_TO_ENEMY_ONLY



      return false unless self.is_a?(Game_Enemy)



      return false unless user.respond_to?(:actor?) && user.actor?



    end



    text = ALBERT_CHARACTER_CORE.note(obj)



    return false if text =~ /<no_weakness_break\s*>/i



    return true



  end



  #--------------------------------------------------------------------------



  # ● 從技能／普通攻擊／物品讀取 Break 資料



  #



  #   <break_power:1>



  #   <break_state:50>



  #   <broken_state:51>



  #   <break_threshold:5>



  #   <break_bonus_if_od 50:1>



  #   <break_bonus_if_od 80:1>



  #



  # 屬性克制傷害會額外加入 WEAKNESS_BREAK_POWER。



  # 多個 OD 門檻加成會累加。



  #--------------------------------------------------------------------------



  def albert_cc_break_data(user, skill = nil)



    text = ALBERT_CHARACTER_CORE.source_text(user, skill)



    power = 0



    power += $1.to_i if text =~ /<break_power\s*:\s*(\d+)\s*>/i



    if albert_cc_weakness_break_eligible?(user, skill)



      power += [ALBERT_CHARACTER_CORE::WEAKNESS_BREAK_POWER.to_i, 0].max



    end



    return nil if power <= 0



    break_state = ALBERT_CHARACTER_CORE::BREAK_PROGRESS_STATE_ID



    broken_state = ALBERT_CHARACTER_CORE::BROKEN_STATE_ID



    threshold = ALBERT_CHARACTER_CORE::BREAK_THRESHOLD



    break_state = $1.to_i if text =~ /<break_state\s*:\s*(\d+)\s*>/i



    broken_state = $1.to_i if text =~ /<broken_state\s*:\s*(\d+)\s*>/i



    threshold = $1.to_i if text =~ /<break_threshold\s*:\s*(\d+)\s*>/i



    if user != nil



      od_rate = ALBERT_CHARACTER_CORE.od_rate(user)



      text.scan(/<break_bonus_if_od\s+([0-9]+(?:\.[0-9]+)?)\s*:\s*(\d+)\s*>/i) do |data|



        power += data[1].to_i if od_rate >= data[0].to_f



      end



      # 新版分段 OD 破勢：<break_bonus_od_tier 門檻%:追加點數:成本>

      start_od = ALBERT_CHARACTER_CORE.action_start_od(user)

      start_rate = 0.0

      if user.respond_to?(:max_overdrive) && user.max_overdrive.to_i > 0

        start_rate = start_od.to_f * 100.0 / user.max_overdrive.to_f

      end

      tier_cost = 0

      text.scan(/<break_bonus_od_tier\s+([0-9]+(?:\.[0-9]+)?)\s*:\s*(\d+)\s*:\s*(\d+)\s*>/i) do |data|

        need_rate = data[0].to_f

        add_power = data[1].to_i

        cost = data[2].to_i

        next if start_rate < need_rate

        next if start_od < tier_cost + cost

        power += add_power

        tier_cost += cost

      end

      old_cost = user.instance_variable_get(:@albert_cc_break_tier_cost).to_i

      user.instance_variable_set(:@albert_cc_break_tier_cost, [old_cost, tier_cost].max)



    end



    power = [power, 0].max



    threshold = [threshold, 1].max



    return [power, break_state, broken_state, threshold]



  end



  #--------------------------------------------------------------------------



  # ● CSP 不存在時的 Break 進度備援儲存機制



  #--------------------------------------------------------------------------



  def albert_cc_break_points(state_id)



    if respond_to?(:stack) && state?(state_id)



      begin



        return stack(state_id).to_i



      rescue



      end



    end



    @albert_cc_break_points = {} if @albert_cc_break_points == nil



    return @albert_cc_break_points[state_id].to_i



  end



  def albert_cc_add_break_points(state_id, amount)



    amount = amount.to_i



    return 0 if amount <= 0



    before = albert_cc_break_points(state_id)



    if respond_to?(:stack) && respond_to?(:increase_stack)



      amount.times { add_state(state_id) }



    else



      @albert_cc_break_points = {} if @albert_cc_break_points == nil



      @albert_cc_break_points[state_id] = before + amount



      add_state(state_id) unless state?(state_id)



    end



    after = albert_cc_break_points(state_id)



    return [after - before, 0].max



  end



  def albert_cc_clear_break_points(state_id)



    if respond_to?(:reset_stack)



      begin



        reset_stack(state_id)



      rescue



      end



    end



    if @albert_cc_break_points != nil



      @albert_cc_break_points.delete(state_id)



    end



    remove_state(state_id) if state?(state_id)



  end



  #--------------------------------------------------------------------------



  # ● 技能成功命中後處理 Break 破勢



  #--------------------------------------------------------------------------



  def albert_cc_process_break(user, skill)



    return unless ALBERT_CHARACTER_CORE::ENABLE_TYLER_BREAK



    return if user == nil



    return if @missed || @evaded || @skipped



    return if dead?



    data = albert_cc_break_data(user, skill)



    return if data == nil



    power = data[0]



    break_state = data[1]



    broken_state = data[2]



    threshold = data[3]



    return if power <= 0



    if state?(broken_state) && !ALBERT_CHARACTER_CORE::BREAK_REBUILD_WHILE_BROKEN



      return



    end



    gained = albert_cc_add_break_points(break_state, power)



    if user.albert_cc_tyler? && gained > 0

      tier_cost = user.instance_variable_get(:@albert_cc_break_tier_cost).to_i

      tier_paid = user.instance_variable_get(:@albert_cc_break_tier_cost_paid) ? true : false

      if tier_cost > 0 && !tier_paid

        paid = ALBERT_CHARACTER_CORE.pay_conditional_od(user, tier_cost)

        user.instance_variable_set(:@albert_cc_break_tier_cost_paid, true) if paid

      end


    end



    if user.albert_cc_tyler? && gained > 0



      text = ALBERT_CHARACTER_CORE.source_text(user, skill)



      per_point = ALBERT_CHARACTER_CORE.note_number(



        text, "cc_od_break_point", ALBERT_CHARACTER_CORE::TYLER_OD_PER_BREAK_POINT



      )



      ALBERT_CHARACTER_CORE.gain_special_od(
        user, :tyler_break, gained * per_point, 250
      )



    end



    if albert_cc_break_points(break_state) >= threshold



      albert_cc_clear_break_points(break_state)



      add_state(broken_state)



      if user.albert_cc_tyler?



        text = ALBERT_CHARACTER_CORE.source_text(user, skill)



        gain = ALBERT_CHARACTER_CORE.note_number(



          text, "cc_od_break", ALBERT_CHARACTER_CORE::TYLER_OD_ON_BREAK



        )



        ALBERT_CHARACTER_CORE.gain_special_od(
          user, :tyler_break, gain, 250
        )



      end



    end



  end



  #--------------------------------------------------------------------------



  # ● 治療與溢出治療轉換



  #



  # 可放在治療技能／米亞裝備／State／Actor Note：



  #



  #   <cc_od_heal_percent:2.5>



  #     每有效恢復目標最大 HP 的 1%，獲得 5 OD。



  #



  #   <cc_od_overheal_percent:1>



  #     每產生相當於目標最大 HP 1% 的溢療，獲得 3 OD。



  #



  #   <overheal_to_od:50>



  #     原始溢療量的 50% 轉為施術者 OD。



  #



  #   <overheal_to_mp:30>



  #     原始溢療量的 30% 回復目標 MP。



  #



  #   <overheal_to_user_mp:30>



  #     原始溢療量的 30% 回復施術者 MP。



  #



  #   <overheal_to_user_state 41:10>



  #     每產生相當於目標最大 HP 10% 的溢療，施術者增加 1 層 State 41。



  #     米亞的魔力層應使用此標籤。



  #



  #   <overheal_to_state 41:10>



  #     每產生相當於目標最大 HP 10% 的溢療，治療目標增加 1 層 State 41。



  #



  #   <overheal_to_shield 52:50>



  #     原始溢療量的 50% 轉成 State 52 的動態 Mana Shield 容量。



  #     需要 Albert ComboCore 的 Mana Shield 功能。



  #--------------------------------------------------------------------------



  def albert_cc_process_healing(user, skill, before_hp)



    return unless ALBERT_CHARACTER_CORE::ENABLE_MIA_HEAL



    return if user == nil || skill == nil



    return if @missed || @evaded || @skipped



    return if @hp_damage == nil || @hp_damage >= 0



    raw_heal = -@hp_damage.to_i



    actual_heal = self.hp.to_i - before_hp.to_i



    actual_heal = 0 if actual_heal < 0



    overheal = raw_heal - actual_heal



    overheal = 0 if overheal < 0



    text = ALBERT_CHARACTER_CORE.source_text(user, skill)



    # 米亞預設 OD 獲得核心，可由 Note 覆蓋。



    if user.albert_cc_mia? && maxhp > 0



      heal_rate = actual_heal.to_f * 100.0 / maxhp.to_f



      over_rate = overheal.to_f * 100.0 / maxhp.to_f



      per_heal = ALBERT_CHARACTER_CORE.note_number(



        text, "cc_od_heal_percent", ALBERT_CHARACTER_CORE::MIA_OD_PER_HEAL_PERCENT



      )



      per_over = ALBERT_CHARACTER_CORE.note_number(



        text, "cc_od_overheal_percent", ALBERT_CHARACTER_CORE::MIA_OD_PER_OVERHEAL_PERCENT



      )



      gain = (heal_rate * per_heal + over_rate * per_over).to_i



      ALBERT_CHARACTER_CORE.gain_special_od(
        user, :mia_heal, gain,
        ALBERT_CHARACTER_CORE::MIA_SPECIAL_OD_ACTION_CAP
      )



    end



    return if overheal <= 0



    # 溢療 → 施術者 OD



    text.scan(/<overheal_to_od\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      value = (overheal * data[0].to_f / 100.0).to_i



      ALBERT_CHARACTER_CORE.gain_od(user, value)



    end



    # 溢療 → 目標 MP



    text.scan(/<overheal_to_mp\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      value = (overheal * data[0].to_f / 100.0).to_i



      self.mp += value if value > 0



    end



    # 溢療 → 施術者 MP



    text.scan(/<overheal_to_user_mp\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      value = (overheal * data[0].to_f / 100.0).to_i



      user.mp += value if value > 0



    end



    # 溢療 → 施術者 State 疊層，依治療目標最大 HP 百分比換算。



    text.scan(/<overheal_to_user_state\s+(\d+)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      state_id = data[0].to_i



      step_percent = data[1].to_f



      next if step_percent <= 0.0 || maxhp <= 0



      next unless user.respond_to?(:add_state)



      over_rate = overheal.to_f * 100.0 / maxhp.to_f



      stacks = (over_rate / step_percent).to_i



      stacks.times { user.add_state(state_id) }



    end



    # 溢療 → 治療目標 State 疊層，依目標最大 HP 百分比換算。



    text.scan(/<overheal_to_state\s+(\d+)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      state_id = data[0].to_i



      step_percent = data[1].to_f



      next if step_percent <= 0.0 || maxhp <= 0



      over_rate = overheal.to_f * 100.0 / maxhp.to_f



      stacks = (over_rate / step_percent).to_i



      stacks.times { add_state(state_id) }



    end



    # 溢療 → 動態 Mana Shield 容量。



    text.scan(/<overheal_to_shield\s+(\d+)\s*:\s*([0-9]+(?:\.[0-9]+)?)\s*>/i) do |data|



      state_id = data[0].to_i



      percent = data[1].to_f



      capacity = (overheal * percent / 100.0).to_i



      next if capacity <= 0



      albert_cc_add_dynamic_mana_shield(state_id, capacity)



    end



  end



  #--------------------------------------------------------------------------



  # ● 增加 ComboCore Mana Shield 的動態容量



  #--------------------------------------------------------------------------



  def albert_cc_add_dynamic_mana_shield(state_id, capacity)



    return if capacity.to_i <= 0



    state = $data_states[state_id]



    return if state == nil



    had_state = state?(state_id)



    old_capacity = 0



    if had_state && respond_to?(:albert_mana_shield_remaining)



      begin



        old_capacity = albert_mana_shield_remaining(state_id).to_i



      rescue



        old_capacity = 0



      end



    end



    add_state(state_id) unless had_state



    # 需要 ComboCore 的 @albert_mana_shield_remaining Hash。



    if respond_to?(:albert_mana_shield_remaining)



      hash = instance_variable_get(:@albert_mana_shield_remaining)



      hash = {} if hash == nil



      hash[state_id] = old_capacity + capacity.to_i



      instance_variable_set(:@albert_mana_shield_remaining, hash)



    end



  end



  #--------------------------------------------------------------------------



  # ● 技能實際涉及的 State ID



  #   同時讀取資料庫 plus_state_set 與 ComboCore 的 Note 成功率標籤。



  #   舊版只讀 plus_state_set，導致維娜大量使用 <state_chance> 的技能



  #   成功疊層後沒有獲得 OD。這裡統一修正。



  #--------------------------------------------------------------------------



  def albert_cc_skill_state_ids(skill)



    result = []



    return result if skill == nil



    if skill.respond_to?(:plus_state_set) && skill.plus_state_set != nil



      for state_id in skill.plus_state_set



        state_id = state_id.to_i



        result.push(state_id) if state_id > 0



      end



    end



    text = ALBERT_CHARACTER_CORE.note(skill)



    text.scan(/<state_chance(?:_vs_state|_if_user_state|_if_od|_per_od_percent)?\s+(\d+)/i) do |data|



      state_id = data[0].to_i



      result.push(state_id) if state_id > 0



    end



    text.scan(/<state_stack_if_present\s+(\d+)\s*:/i) do |data|



      state_id = data[0].to_i



      result.push(state_id) if state_id > 0



    end



    return result.uniq



  end



  def albert_cc_capture_state_stacks(skill)



    result = {}



    for state_id in albert_cc_skill_state_ids(skill)



      result[state_id] = ALBERT_CHARACTER_CORE.stack_count(self, state_id)



    end



    return result



  end



  #--------------------------------------------------------------------------



  # ● 已存在狀態時，一次成功可增加指定總層數



  #



  #   <state_stack_if_present 31:2>



  #



  # 目標施放前已有 State 31，且原本的附加判定成功時，本次總增加 2 層。



  # 若目標原本沒有 State 31，仍由原判定只增加 1 層。



  #--------------------------------------------------------------------------



  def albert_cc_process_state_stack_if_present(user, skill, before_stacks)



    return if skill == nil



    return if @missed || @evaded || @skipped



    text = ALBERT_CHARACTER_CORE.note(skill)



    rules = []



    text.scan(/<state_stack_if_present\s+(\d+)\s*:\s*(\d+)\s*>/i) do |data|



      rules.push([data[0].to_i, data[1].to_i])



    end



    return if rules.empty?



    for rule in rules



      state_id = rule[0]



      total_gain = [rule[1], 1].max



      before = before_stacks[state_id].to_i



      next if before <= 0



      after = ALBERT_CHARACTER_CORE.stack_count(self, state_id)



      gained = after - before



      next if gained <= 0



      extra = total_gain - gained



      next if extra <= 0



      old_user = instance_variable_get(:@albert_effect_user)



      old_obj = instance_variable_get(:@albert_effect_obj)



      begin



        if respond_to?(:albert_combo_set_effect_context)



          albert_combo_set_effect_context(user, skill)



        end



        extra.times { add_state(state_id) }



      ensure



        instance_variable_set(:@albert_effect_user, old_user)



        instance_variable_set(:@albert_effect_obj, old_obj)



      end



    end



  end



  #--------------------------------------------------------------------------



  # ● 維娜：偵測技能實際新增的 State／疊層數



  #--------------------------------------------------------------------------



  def albert_cc_process_vina_state_od(user, skill, before_stacks)



    return unless ALBERT_CHARACTER_CORE::ENABLE_VINA_STATE_OD



    return if user == nil || skill == nil



    return unless user.albert_cc_vina?



    return if @missed || @evaded || @skipped



    gained_stacks = 0



    for state_id in before_stacks.keys



      before = before_stacks[state_id].to_i



      after = ALBERT_CHARACTER_CORE.stack_count(self, state_id)



      gained_stacks += after - before if after > before



    end



    return if gained_stacks <= 0



    text = ALBERT_CHARACTER_CORE.source_text(user, skill)



    per_stack = ALBERT_CHARACTER_CORE.note_number(



      text, "cc_od_state_stack", ALBERT_CHARACTER_CORE::VINA_OD_PER_STATE_STACK



    )



    ALBERT_CHARACTER_CORE.gain_special_od(
      user, :vina_state, gained_stacks * per_stack,
      ALBERT_CHARACTER_CORE::VINA_SPECIAL_OD_ACTION_CAP
    )



  end



  #--------------------------------------------------------------------------



  # ● 技能效果包裝：治療、條件疊層、State OD、Break



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_cc_old_skill_effect)
    alias albert_cc_old_skill_effect skill_effect
  end

  # Phase 25：同頁 skill_effect 單一 wrapper。
  # 舊雙層順序：Joey/Mia 前態快照 -> Core -> Stack/Heal/VinaOD/Break -> JoeyPull/MiaRevive。
  def skill_effect(user, skill)
    marked_before = state?(40)
    was_dead = dead?
    before_hp = self.hp
    before_stacks = albert_cc_capture_state_stacks(skill)
    result = albert_cc_old_skill_effect(user, skill)
    albert_cc_process_state_stack_if_present(user, skill, before_stacks)
    albert_cc_process_healing(user, skill, before_hp)
    albert_cc_process_vina_state_od(user, skill, before_stacks)
    albert_cc_process_break(user, skill)
    albert_cc_v13_process_joey_pull(user, skill, marked_before)
    albert_cc_v13_process_mia_revive(user, skill, was_dead)
    return result
  end



  #--------------------------------------------------------------------------



  # ● 普通攻擊／物品的屬性克制傷害也能累積破勢



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_cc_old_attack_effect)



    alias albert_cc_old_attack_effect attack_effect



  end



  def attack_effect(attacker)



    result = albert_cc_old_attack_effect(attacker)



    albert_cc_process_break(attacker, nil)



    return result



  end



  unless method_defined?(:albert_cc_old_item_effect)



    alias albert_cc_old_item_effect item_effect



  end



  def item_effect(user, item)



    result = albert_cc_old_item_effect(user, item)



    albert_cc_process_break(user, item)



    return result



  end



  #--------------------------------------------------------------------------



  # ● 艾薇：實際承受 Cover 轉移傷害時額外獲得 OD



  #   ComboCore 會在保護者身上設定 @albert_cover_redirect_guard 標記。



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_cc_old_execute_damage)



    alias albert_cc_old_execute_damage execute_damage



  end



  def execute_damage(user)



    cover_redirect = instance_variable_get(:@albert_cover_redirect_guard) ? true : false



    damage_before = @hp_damage.to_i



    albert_cc_old_execute_damage(user)



    if ALBERT_CHARACTER_CORE::ENABLE_IVY_COVER_OD && cover_redirect &&



       albert_cc_ivy? && damage_before > 0



      text = ALBERT_CHARACTER_CORE.source_text(self, nil)



      gain = ALBERT_CHARACTER_CORE.note_number(



        text, "cc_od_cover", ALBERT_CHARACTER_CORE::IVY_OD_PER_COVER



      )



      ALBERT_CHARACTER_CORE.gain_od(self, gain)



    end



  end



  #--------------------------------------------------------------------------



  # ● 艾卓：依實際 ATB 削減量獲得 OD



  #   掛接 ComboCore 實際修改 ATB 差值的方法。



  #--------------------------------------------------------------------------



  if method_defined?(:albert_combo_apply_atb_delta) &&



     !method_defined?(:albert_cc_old_apply_atb_delta)



    alias albert_cc_old_apply_atb_delta albert_combo_apply_atb_delta



    def albert_combo_apply_atb_delta(delta, state = nil)



      before = respond_to?(:at_count) ? at_count.to_i : nil



      user = respond_to?(:albert_combo_effect_user) ? albert_combo_effect_user : nil



      obj = respond_to?(:albert_combo_effect_obj) ? albert_combo_effect_obj : nil



      albert_cc_old_apply_atb_delta(delta, state)



      return if before == nil



      return unless ALBERT_CHARACTER_CORE::ENABLE_AIZHUO_ATB_OD



      return if user == nil || !user.albert_cc_aizhuo?



      after = at_count.to_i



      actual_reduction = before - after



      return if actual_reduction <= 0



      text = ALBERT_CHARACTER_CORE.source_text(user, obj)



      per_10 = ALBERT_CHARACTER_CORE.note_number(



        text, "cc_od_atb_per_10", ALBERT_CHARACTER_CORE::AIZHUO_OD_PER_10_ATB_REDUCTION



      )



      gain = (actual_reduction.to_f / 100.0 * per_10.to_f).to_i



      ALBERT_CHARACTER_CORE.gain_special_od(
        user, :aizhuo_atb, gain,
        ALBERT_CHARACTER_CORE::AIZHUO_SPECIAL_OD_ACTION_CAP
      )



    end



  end



end



#==============================================================================



# ■ Scene_Battle



#==============================================================================



class Scene_Battle < Scene_Base



  #--------------------------------------------------------------------------



  # ● 公開標記，用來避免召喚追擊遞迴或重複計算 OD。



  #--------------------------------------------------------------------------



  attr_reader :albert_cc_in_summon_followup



  #--------------------------------------------------------------------------



  # ● 喬伊：召喚物完成一次正常戰鬥行動後獲得 OD。



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_cc_old_execute_action)



    alias albert_cc_old_execute_action execute_action



  end



  def execute_action



    battler = @active_battler



    valid_before = true



    begin



      valid_before = battler.action.valid? if battler != nil



    rescue



      valid_before = true



    end



    albert_cc_old_execute_action



    return unless ALBERT_CHARACTER_CORE::ENABLE_JOEY_SUMMON_OD



    return if battler == nil || !valid_before



    return unless battler.respond_to?(:albert_summon?) && battler.albert_summon?



    return if @albert_cc_in_summon_followup &&



              !ALBERT_CHARACTER_CORE::FOLLOWUP_COUNTS_AS_SUMMON_ACTION



    joey = ALBERT_CHARACTER_CORE.actor_by_id(ALBERT_CHARACTER_CORE::JOEY_ACTOR_ID)



    return unless ALBERT_CHARACTER_CORE.actor_in_battle?(joey)



    return unless joey.exist?



    text = ALBERT_CHARACTER_CORE.source_text(joey, nil)



    gain = ALBERT_CHARACTER_CORE.note_number(



      text, "cc_od_summon_action", ALBERT_CHARACTER_CORE::JOEY_OD_PER_SUMMON_ACTION



    )



    ALBERT_CHARACTER_CORE.gain_od(joey, gain)



  end



  #--------------------------------------------------------------------------



  # ● 喬伊召喚物追擊



  #



  # 在喬伊完整 SBS 技能動畫／行動序列結束後觸發。



  # 召喚物使用自己的技能公式與 SBS base_action 執行追擊。



  # 不消耗召喚物 ATB，也不消耗召喚物 MP／OD。



  #--------------------------------------------------------------------------



  unless method_defined?(:albert_cc_old_execute_action_skill)



    alias albert_cc_old_execute_action_skill execute_action_skill



  end



  def execute_action_skill



    trigger_battler = @active_battler



    trigger_skill = nil



    pre_od = 0



    if trigger_battler != nil && trigger_battler.action != nil



      trigger_skill = trigger_battler.action.skill



      pre_od = trigger_battler.overdrive.to_i if trigger_battler.respond_to?(:overdrive)



    end



    albert_cc_old_execute_action_skill



    return unless ALBERT_CHARACTER_CORE::ENABLE_SUMMON_FOLLOWUP



    return if @albert_cc_in_summon_followup



    return if trigger_battler == nil || !trigger_battler.albert_cc_joey?



    # 若其他腳本轉換了技能，優先取得實際執行的技能。



    if trigger_battler.action != nil && trigger_battler.action.skill != nil



      trigger_skill = trigger_battler.action.skill



    end



    return if trigger_skill == nil



    targets = @targets == nil ? [] : @targets.compact.clone



    albert_cc_try_summon_followups(trigger_battler, trigger_skill, pre_od, targets)



  end



  #--------------------------------------------------------------------------



  # ● 依技能 Note 嘗試觸發召喚物追擊



  #--------------------------------------------------------------------------



  def albert_cc_try_summon_followups(joey, trigger_skill, pre_od, original_targets)



    specs = ALBERT_CHARACTER_CORE.summon_followup_specs(trigger_skill)



    return if specs.empty?



    count = 0



    for spec in specs



      break if count >= ALBERT_CHARACTER_CORE::FOLLOWUP_MAX_PER_ACTION



      summon_actor_id = spec[0]



      follow_skill_id = spec[1]



      od_need = spec[2]



      od_cost = spec[3]



      next if pre_od < od_need



      next if joey.respond_to?(:overdrive) && joey.overdrive.to_i < od_cost



      summon = ALBERT_CHARACTER_CORE.actor_by_id(summon_actor_id)



      next if summon == nil



      next unless ALBERT_CHARACTER_CORE.actor_in_battle?(summon)



      next unless summon.exist?



      next if summon.active



      if summon.respond_to?(:albert_summon?)



        next unless summon.albert_summon?



      end



      follow_skill = $data_skills[follow_skill_id]



      next if follow_skill == nil



      targets = albert_cc_followup_targets(summon, follow_skill, original_targets)



      next if targets.empty?



      success = albert_cc_execute_summon_followup(summon, follow_skill, targets)



      if success



        joey.overdrive -= od_cost if od_cost > 0 && joey.respond_to?(:overdrive)



        count += 1



      end



    end



  end



  #--------------------------------------------------------------------------



  # ● 追擊目標選擇規則



  #--------------------------------------------------------------------------



  def albert_cc_followup_targets(summon, skill, original_targets)



    targets = []



    if skill.for_user?



      return [summon]



    end



    if skill.for_friend?



      for target in original_targets



        targets.push(target) if target != nil && target.actor? == summon.actor? && target.exist?



      end



      if targets.empty?



        unit = summon.actor? ? $game_party : $game_troop



        targets = unit.existing_members.clone



      end



      return skill.for_one? ? [targets[0]].compact : targets



    end



    # 對敵技能：全體追擊以目前所有存活敵人為目標。



    opponent_unit = summon.actor? ? $game_troop : $game_party



    if skill.for_all?



      return opponent_unit.existing_members.clone



    end



    # 單體／隨機追擊會盡量保留喬伊原本攻擊的敵方目標。



    for target in original_targets



      next if target == nil



      next if target.actor? == summon.actor?



      next unless target.exist?



      targets.push(target)



    end



    if targets.empty? && ALBERT_CHARACTER_CORE::FOLLOWUP_RETARGET_IF_DEAD



      alive = opponent_unit.existing_members



      target = alive.empty? ? nil : alive[rand(alive.size)]



      targets.push(target) if target != nil



    end



    if skill.for_one? || skill.dual? || skill.for_random?



      return [targets[0]].compact



    end



    return targets



  end



  #--------------------------------------------------------------------------



  # ● 直接透過 Tankentai SBS 執行追擊



  #



  # 重要設計：



  #   ・使用 follow_skill.base_action，因此可正常使用自訂 SBS 動畫。



  #   ・Scene_Battle#damage_action 會把召喚物視為 @active_battler。



  #   ・傷害／狀態公式會以召喚物作為真正使用者。



  #   ・不呼叫正常 ATB execute_action，因此召喚物 ATB 不受影響。



  #   ・不執行正常技能消耗／冷卻鏈。



  #--------------------------------------------------------------------------



  def albert_cc_execute_summon_followup(summon, follow_skill, targets)



    return false if summon == nil || follow_skill == nil || targets.empty?



    return false unless respond_to?(:playing_action)



    return false if @spriteset == nil



    old_active = @active_battler



    old_targets = @targets



    old_action = summon.action



    old_active_flag = summon.active



    # 建立暫時行動物件，避免破壞召喚物原本已排定的 ATB 行動。



    temp_action = Game_BattleAction.new(summon)



    temp_action.set_skill(follow_skill.id)



    temp_action.target_index = targets[0].index if targets[0] != nil



    temp_action.forcing = true



    begin



      @albert_cc_in_summon_followup = true



      @active_battler = summon



      @targets = targets.compact.clone



      summon.instance_variable_set(:@action, temp_action)



      summon.active = true



      # 採用與 Tankentai 技能執行相同的不死保護處理。



      # 即死技能需要走 Tankentai 特殊的 dying 標記流程。



      if follow_skill.plus_state_set.include?(1)



        for member in $game_party.members + $game_troop.members



          next if member.immortal



          next if member.dead?



          member.dying = true



        end



      else



        immortaling if respond_to?(:immortaling)



      end



      @spriteset.set_target(summon.actor?, summon.index, @targets)



      @spriteset.set_action(summon.actor?, summon.index, follow_skill.base_action)



      if ALBERT_CHARACTER_CORE::FOLLOWUP_SHOW_SKILL_NAME && respond_to?(:pop_help)



        pop_help(follow_skill)



      end



      playing_action



      @status_window.refresh if @status_window != nil



      return true



    rescue Exception => e



      # 追擊失敗時不讓整場戰鬥直接崩潰。



      p "Albert Character Core follow-up error: #{e.message}" if $TEST



      return false



    ensure



      summon.instance_variable_set(:@action, old_action)



      summon.active = old_active_flag



      @active_battler = old_active



      @targets = old_targets



      @albert_cc_in_summon_followup = false



    end



  end



end



#==============================================================================



# ■ 用法摘要



#------------------------------------------------------------------------------



# OD 獲得：



#   <cc_od_summon_action:40>



#   <cc_od_cover:60>



#   <cc_od_atb_per_10:20>



#   <cc_od_state_stack:30>



#   <cc_od_break_point:25>



#   <cc_od_break:100>



#   <cc_od_heal_percent:2.5>



#   <cc_od_overheal_percent:1>



#



# 治療：



#   <heal_bonus:15>



#   <heal_bonus_if_od 50:20>



#   <heal_bonus_per_od_percent:0.2>



#   <overheal_to_od:50>



#   <overheal_to_mp:30>



#   <overheal_to_user_mp:30>



#   <overheal_to_user_state 41:10>



#   <overheal_to_state 41:10>



#   <overheal_to_shield 52:50>



#



# Break 破勢／崩防：



#   <break_power:1>



#   <break_state:50>



#   <broken_state:51>



#   <break_threshold:5>



#   <break_bonus_if_od 50:1>



#   <break_bonus_if_od 80:1>



#



# 喬伊召喚物追擊：



#   <summon_followup 18:241:700>



#   <summon_followup 18:241:700:200>



#==============================================================================











#==============================================================================
# ■ v1.3 OD 經濟整合
#------------------------------------------------------------------------------
#  1. 六名主角保留 KGC 預設 OD 來源，不再因尚未學會 <overdrive N> 而停用。
#  2. 戰鬥開始時，跨戰 OD 最多保留 250。
#  3. 專屬機制 OD 設有每次行動上限，避免全體／多段技能瞬間灌滿。
#  4. 喬伊 Lv1 起可用共鳴標記牽引召喚物 ATB。
#  5. 米亞生命回響可條件消耗 OD，強化復活與護盾。
#==============================================================================

module ALBERT_CHARACTER_CORE
  def self.action_start_od(battler)
    return 0 if battler == nil
    value = battler.instance_variable_get(:@albert_od_action_start_value)
    return value.to_i unless value == nil
    return battler.overdrive.to_i if battler.respond_to?(:overdrive)
    return 0
  end

  def self.reset_special_od_action_counters
    members = []
    members += $game_party.members if $game_party != nil
    members += $game_troop.members if $game_troop != nil
    for battler in members.compact
      battler.instance_variable_set(:@albert_special_od_action_gain, {})
      battler.instance_variable_set(:@albert_cc_break_tier_cost_paid, false)
      battler.instance_variable_set(:@albert_cc_break_tier_cost, 0)
      battler.instance_variable_set(:@albert_cc_mia_revive_od_paid, false)
    end
  end

  def self.gain_special_od(battler, key, value, cap)
    return 0 if battler == nil
    value = value.to_i
    return 0 if value <= 0
    cap = cap.to_i
    return gain_od(battler, value) if cap <= 0

    data = battler.instance_variable_get(:@albert_special_od_action_gain)
    data = {} unless data.is_a?(Hash)
    used = data[key].to_i
    room = cap - used
    return 0 if room <= 0
    actual = [value, room].min
    gained = gain_od(battler, actual)
    data[key] = used + [gained, 0].max
    battler.instance_variable_set(:@albert_special_od_action_gain, data)
    return gained
  end

  def self.pay_conditional_od(battler, amount)
    return false if battler == nil
    amount = amount.to_i
    return true if amount <= 0
    return false unless battler.respond_to?(:overdrive)
    return false unless battler.respond_to?(:overdrive=)
    return false if battler.overdrive.to_i < amount
    battler.overdrive = battler.overdrive.to_i - amount
    return true
  end
end

class Game_Actor < Game_Battler
  if method_defined?(:overdrive_skill_learned?) &&
     !method_defined?(:albert_cc_v13_old_overdrive_skill_learned)
    alias albert_cc_v13_old_overdrive_skill_learned overdrive_skill_learned?
  end

  def overdrive_skill_learned?
    if defined?(ALBERT_CHARACTER_CORE::HERO_OD_ACTOR_IDS) &&
       ALBERT_CHARACTER_CORE::HERO_OD_ACTOR_IDS.include?(id)
      return true
    end
    if respond_to?(:albert_cc_v13_old_overdrive_skill_learned)
      return albert_cc_v13_old_overdrive_skill_learned
    end
    return true
  end
end

class Scene_Battle < Scene_Base
  unless method_defined?(:albert_cc_v13_old_start)
    alias albert_cc_v13_old_start start
  end

  def start
    if $game_party != nil
      cap = ALBERT_CHARACTER_CORE::OD_CARRYOVER_CAP.to_i
      for actor in $game_party.members.compact
        next unless actor.respond_to?(:id)
        next unless ALBERT_CHARACTER_CORE::HERO_OD_ACTOR_IDS.include?(actor.id)
        next unless actor.respond_to?(:overdrive)
        next unless actor.respond_to?(:overdrive=)
        actor.overdrive = cap if actor.overdrive.to_i > cap
      end
    end
    albert_cc_v13_old_start
  end

  unless method_defined?(:albert_cc_v13_old_execute_action)
    alias albert_cc_v13_old_execute_action execute_action
  end

  def execute_action(*args)
    ALBERT_CHARACTER_CORE.reset_special_od_action_counters
    battler = @active_battler
    if battler != nil && battler.respond_to?(:overdrive)
      battler.instance_variable_set(
        :@albert_od_action_start_value, battler.overdrive.to_i)
    end
    return albert_cc_v13_old_execute_action(*args)
  end
end

class Game_Battler
  def albert_cc_v13_effect_success?
    return false if @missed || @evaded || @skipped
    return true
  end

  def albert_cc_v13_note(skill)
    return "" if skill == nil
    return skill.note.to_s if skill.respond_to?(:note)
    return ""
  end

  def albert_cc_v13_resonance_event?(state_id, existed_before)
    added = instance_variable_get(:@added_states)
    remained = instance_variable_get(:@remained_states)
    added = [] unless added.is_a?(Array)
    remained = [] unless remained.is_a?(Array)
    return true if added.include?(state_id)
    return true if existed_before && remained.include?(state_id)
    return false
  end

  def albert_cc_v13_highest_atb_summon
    return nil if $game_party == nil
    best = nil
    best_atb = -999999
    for member in $game_party.members.compact
      next unless member.respond_to?(:albert_summon?)
      next unless member.albert_summon?
      next unless member.exist?
      next unless member.respond_to?(:at_count)
      value = member.at_count.to_i
      if best == nil || value > best_atb
        best = member
        best_atb = value
      end
    end
    return best
  end

  def albert_cc_v13_process_joey_pull(user, skill, marked_before)
    return if user == nil || skill == nil
    return unless user.respond_to?(:albert_cc_joey?) && user.albert_cc_joey?
    return unless albert_cc_v13_effect_success?
    text = albert_cc_v13_note(skill)
    return unless text =~ /<joey_resonance_pull\s+(\d+)\s*:\s*(\d+)\s*:\s*(\d+)\s*>/i
    cost = $1.to_i
    normal = $2.to_i
    refresh = $3.to_i
    state_id = 40
    return unless state?(state_id)
    return unless albert_cc_v13_resonance_event?(state_id, marked_before)
    start_od = ALBERT_CHARACTER_CORE.action_start_od(user)
    return if start_od < cost
    summon = albert_cc_v13_highest_atb_summon
    return if summon == nil
    amount = marked_before ? refresh : normal
    delta = amount.to_i * 10
    return if delta <= 0
    if summon.respond_to?(:albert_combo_apply_atb_delta)
      summon.albert_combo_apply_atb_delta(delta, nil)
    else
      value = summon.instance_variable_get(:@at_count).to_i + delta
      value = 1000 if value > 1000
      summon.instance_variable_set(:@at_count, value)
    end
    ALBERT_CHARACTER_CORE.pay_conditional_od(user, cost)
  end

  def albert_cc_v13_process_mia_revive(user, skill, was_dead)
    return unless was_dead
    return unless hp.to_i > 0
    return if user == nil || skill == nil
    return unless user.respond_to?(:albert_cc_mia?) && user.albert_cc_mia?
    return unless albert_cc_v13_effect_success?
    return if user.instance_variable_get(:@albert_cc_mia_revive_od_paid)
    text = albert_cc_v13_note(skill)
    return unless text =~ /<revive_od_upgrade\s+(\d+)\s*:\s*(\d+)\s*:\s*(\d+)\s*>/i
    cost = $1.to_i
    hp_percent = $2.to_i
    shield_percent = $3.to_i
    return if ALBERT_CHARACTER_CORE.action_start_od(user) < cost

    minimum_hp = (maxhp.to_i * hp_percent / 100.0).to_i
    minimum_hp = 1 if minimum_hp < 1
    self.hp = minimum_hp if hp.to_i < minimum_hp

    capacity = (maxhp.to_i * shield_percent / 100.0).to_i
    if capacity > 0 && respond_to?(:albert_cc_add_dynamic_mana_shield)
      albert_cc_add_dynamic_mana_shield(52, capacity)
    end

    if ALBERT_CHARACTER_CORE.pay_conditional_od(user, cost)
      user.instance_variable_set(:@albert_cc_mia_revive_od_paid, true)
    end
  end

end
