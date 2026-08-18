#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SummonRuntime_Authority v2.0.1
# 【用途】Forest Symphony 正式 Authority「FS_SummonRuntime_Authority v2.0.1」，集中管理此功能目前應修改的主要實作。
# 【主要機制】本頁可能由既有 Base／第三方插件一路 Patch 而來；修改時仍需查看 LoadOrder Guide／Authority Map，確認是否還有後載入 wrapper。
# 【主要影響】Game_Actor、Scene_Map、Scene_Battle、AlbertSummonTemporaryBattle
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MAX_SUMMONS、FULL_RECOVER_ON_BATTLE_START、SUMMON_BATTLE_SWITCH、COMPENSATE_STANDBY_EXP、TRANSFER_JP_ON_EVOLUTION、TRANSFER_SKILL_LEVEL_ON_EVOLUTION、SYNC_DISPLAY_IDENTITY、SYNC_CURRENT_CLASS_LEARNINGS。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意；登記 $imported：Albert_SummonTemporaryBattle_DatabaseSync_Safe；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】AlbertSummonTemporaryBattle.repair_actor_from_current_database(11)；AlbertSummonTemporaryBattle.migrate_actor_class_to_database(11)
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
# PHASE7 ORIGINAL PAGE: 408 | SummonTemporaryBattle
#==============================================================================
#==============================================================================
# ■ Albert_SummonTemporaryBattle_v2_0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 目的：
#   取代舊「臨時加入」腳本。
#   召喚物不再於每次戰鬥前 setup(actor_id)，直接使用 $game_actors 中
#   原本就會持續保存、且會進入存檔的 Game_Actor 物件。
#
# 修正重點：
#   1. 不再 setup 召喚物，不重置等級、EXP、技能、JP、技能等級、裝備資料。
#   2. 不再使用 temp_level / temp_exp 保存召喚物進度。
#   3. 避免 temp_level 與 YEZ Job System: Skill Levels 的內部變數衝突。
#   4. 精確記錄本場實際加入的召喚物，戰後只移除這些角色。
#   5. 保留並恢復戰前 max_battle_member_count / battle_member_count。
#   6. 只接受 RPG::Armor 映射，避免武器 ID 與防具 ID 同號時誤召喚。
#   7. 保留裝備順序，最多加入 MAX_SUMMONS 隻召喚物。
#   8. 補回舊 ArmorManager 移除待命成員後所失去的待命 EXP。
#   9. 進化時改用真正的 actor.exp 傳承，不再依賴硬編碼 100 EXP。
#
# 安裝：
#   A. 將舊「臨時加入」整頁腳本停用或刪除。
#   B. 「全局工具」中的 ArmorMapping / EvolutionTable 可以保留。
#   C. 本腳本放在所有其他 Battle / HUD / H87 Skill Delay 腳本之後，
#      Main 之前。最好直接放在 Main 上方。
#
# 注意：
#   YEM Equipment Overhaul 的召喚物詳細頁若仍有 @summon.setup(actor_id)，
#   仍應另外移除；本腳本只負責戰鬥前後臨時加入流程。
#==============================================================================

module AlbertSummonTemporaryBattle
  MAX_SUMMONS = 3

  # true：召喚物每場戰鬥開始前回滿 HP/MP、解除狀態與依 recover_all
  #       連動的其他恢復效果。這保留你舊腳本的行為。
  # false：保留上次戰鬥後的 HP/MP/狀態。
  FULL_RECOVER_ON_BATTLE_START = false

  # 你的召喚物戰鬥中判定開關。
  SUMMON_BATTLE_SWITCH = 50

  # 舊系統把待命角色暫時移出隊伍，導致 KGC LargeParty 原本的
  # STAND_BY_EXP_RATE 無法作用。true 會在戰果結算後補發一次。
  COMPENSATE_STANDBY_EXP = true

  # 進化時是否傳承已累積的 JP / 技能等級資料。
  TRANSFER_JP_ON_EVOLUTION = true
  TRANSFER_SKILL_LEVEL_ON_EVOLUTION = true

  @active = false
  @summon_entries = []
  @added_summon_ids = []
  @standby_ids = []
  @original_party_ids = []
  @original_battle_member_count = nil
  @original_max_battle_member_count = nil
  @standby_exp_granted = false

  #--------------------------------------------------------------------------
  # ● 取得 KGC LargeParty 的全隊成員
  #--------------------------------------------------------------------------
  def self.all_party_members
    if $game_party.respond_to?(:all_members)
      return $game_party.all_members
    end
    return $game_party.members
  end

  #--------------------------------------------------------------------------
  # ● 清除每場戰鬥用暫存
  #--------------------------------------------------------------------------
  def self.clear_runtime
    @active = false
    @summon_entries = []
    @added_summon_ids = []
    @standby_ids = []
    @original_party_ids = []
    @original_battle_member_count = nil
    @original_max_battle_member_count = nil
    @standby_exp_granted = false
  end

  #--------------------------------------------------------------------------
  # ● 避免舊存檔的 temp_level 影響 YEZ Skill Levels
  #--------------------------------------------------------------------------
  def self.clear_legacy_temp_level(actor)
    return if actor == nil
    if actor.respond_to?(:temp_level=)
      actor.temp_level = nil
    else
      actor.instance_variable_set(:@temp_level, nil)
    end
  end

  #--------------------------------------------------------------------------
  # ● 依喬伊裝備順序取得本場召喚物
  #    回傳 [[armor_id, actor_id], ...]
  #--------------------------------------------------------------------------
  def self.collect_summon_entries
    result = []
    actor_ids = []
    joey = $game_actors[1]
    return result if joey == nil
    return result unless defined?(ArmorMapping)

    joey.equips.each do |equip|
      next if equip == nil
      next unless equip.is_a?(RPG::Armor)

      armor_id = equip.id
      actor_id = ArmorMapping.mapping[armor_id]
      next if actor_id == nil
      next if actor_ids.include?(actor_id)

      result << [armor_id, actor_id]
      actor_ids << actor_id
      break if result.size >= MAX_SUMMONS
    end

    return result
  end

  #--------------------------------------------------------------------------
  # ● 暫存並移除待命成員
  #    保留舊架構，避免你的戰果視窗突然從最多 6 人膨脹成 9 人。
  #--------------------------------------------------------------------------
  def self.store_and_remove_standby_members
    @standby_ids = []
    return unless $game_party.respond_to?(:stand_by_members)

    $game_party.stand_by_members.each do |actor|
      next if actor == nil
      @standby_ids << actor.id
    end

    @standby_ids.each do |actor_id|
      $game_party.remove_actor(actor_id)
    end
  end

  #--------------------------------------------------------------------------
  # ● 戰鬥前準備
  #--------------------------------------------------------------------------
  def self.prepare
    clear_runtime
    @active = true

    if $game_party.respond_to?(:battle_member_count)
      @original_battle_member_count = $game_party.battle_member_count
    end
    if $game_party.respond_to?(:max_battle_member_count)
      @original_max_battle_member_count = $game_party.max_battle_member_count
    end

    # 記錄戰鬥前真正存在於隊伍中的角色，避免誤移除原有成員。
    @original_party_ids = all_party_members.map { |actor| actor.id }

    # 先清除目前隊伍與映射召喚物舊存檔殘留的 temp_level。
    all_party_members.each do |actor|
      clear_legacy_temp_level(actor)
    end
    if defined?(ArmorMapping)
      ArmorMapping.mapping.each_value do |actor_id|
        clear_legacy_temp_level($game_actors[actor_id])
      end
    end

    store_and_remove_standby_members
    @summon_entries = collect_summon_entries

    $game_switches[SUMMON_BATTLE_SWITCH] = !@summon_entries.empty?

    if $game_party.respond_to?(:max_battle_member_count=)
      base_count = @original_battle_member_count
      base_count = $game_party.members.size if base_count == nil
      needed = base_count + @summon_entries.size
      current_max = $game_party.max_battle_member_count
      $game_party.max_battle_member_count = [current_max, needed].max
    end

    @summon_entries.each do |entry|
      actor_id = entry[1]
      actor = $game_actors[actor_id]
      next if actor == nil

      originally_in_party = @original_party_ids.include?(actor_id)

      unless all_party_members.include?(actor)
        $game_party.add_actor(actor_id)
      end

      # 若因隊伍容量或其他腳本阻止加入，就不要把它列入戰後移除名單。
      next unless all_party_members.include?(actor)

      # 只記錄本場真正新增的召喚物。原本就在隊伍中的角色絕不能被誤移除。
      unless originally_in_party
        @added_summon_ids << actor_id unless @added_summon_ids.include?(actor_id)
      end

      # 保留舊腳本「召喚物每場滿狀態出戰」的設計，但不再 setup。
      actor.recover_all if FULL_RECOVER_ON_BATTLE_START
      actor.setup_elements if actor.respond_to?(:setup_elements)
    end

    # 對本場實際戰鬥成員重建屬性快取。
    $game_party.members.each do |actor|
      actor.setup_elements if actor != nil && actor.respond_to?(:setup_elements)
    end
  end

  #--------------------------------------------------------------------------
  # ● 補發待命 EXP
  #--------------------------------------------------------------------------
  def self.grant_standby_exp
    return unless @active
    return unless COMPENSATE_STANDBY_EXP
    return if @standby_exp_granted
    return if @standby_ids.empty?
    return unless defined?(KGC::LargeParty::STAND_BY_EXP_RATE)

    exp = $game_troop.exp_total * KGC::LargeParty::STAND_BY_EXP_RATE / 1000
    @standby_ids.each do |actor_id|
      actor = $game_actors[actor_id]
      next if actor == nil
      next unless actor.exist?
      actor.gain_exp(exp, false)
    end

    @standby_exp_granted = true
  end

  #--------------------------------------------------------------------------
  # ● 深複製簡單進度資料
  #--------------------------------------------------------------------------
  def self.deep_clone(value)
    return nil if value == nil
    begin
      return Marshal.load(Marshal.dump(value))
    rescue
      return value
    end
  end

  #--------------------------------------------------------------------------
  # ● 進化資料傳承
  #--------------------------------------------------------------------------
  def self.transfer_evolution_progress(old_actor, new_actor)
    return if old_actor == nil || new_actor == nil

    # 最重要：直接傳承真正總 EXP，不再用 temp_level/temp_exp 重組。
    new_actor.change_exp(old_actor.exp, false)

    if TRANSFER_JP_ON_EVOLUTION
      jp = old_actor.instance_variable_get(:@class_jp)
      unless jp == nil
        new_actor.instance_variable_set(:@class_jp, deep_clone(jp))
      end
    end

    if TRANSFER_SKILL_LEVEL_ON_EVOLUTION
      levels = old_actor.instance_variable_get(:@skill_level)
      unless levels == nil
        new_actor.instance_variable_set(:@skill_level, deep_clone(levels))
      end
    end

    clear_legacy_temp_level(new_actor)
  end

  #--------------------------------------------------------------------------
  # ● 只檢查本場真正出戰的召喚物是否進化
  #--------------------------------------------------------------------------
  def self.process_evolution
    return unless defined?(EvolutionTable)
    return unless defined?(ArmorMapping)
    return if @summon_entries.empty?

    updated_mapping = ArmorMapping.mapping.dup
    evolved_actor_ids = []

    @summon_entries.each do |entry|
      armor_id = entry[0]
      actor_id = entry[1]
      next if evolved_actor_ids.include?(actor_id)

      actor = $game_actors[actor_id]
      next if actor == nil

      new_actor_id = EvolutionTable.evolve?(actor_id, actor.level)
      next if new_actor_id == nil

      new_actor = $game_actors[new_actor_id]
      next if new_actor == nil

      transfer_evolution_progress(actor, new_actor)
      updated_mapping[armor_id] = new_actor_id
      evolved_actor_ids << actor_id

      $game_message.texts.push("#{actor.name} 進化成 #{new_actor.name}！")
    end

    ArmorMapping.set_mapping(updated_mapping)
  end

  #--------------------------------------------------------------------------
  # ● 還原待命成員
  #--------------------------------------------------------------------------
  def self.restore_standby_members
    @standby_ids.each do |actor_id|
      actor = $game_actors[actor_id]
      next if actor == nil
      unless all_party_members.include?(actor)
        $game_party.add_actor(actor_id)
      end
    end
  end

  #--------------------------------------------------------------------------
  # ● 戰鬥結束清理
  #--------------------------------------------------------------------------
  def self.cleanup
    return unless @active

    $game_switches[SUMMON_BATTLE_SWITCH] = false

    # EXP、JP、技能等級都已直接存在 actor 本體，不做任何 temp_* 回存。
    process_evolution

    @added_summon_ids.each do |actor_id|
      actor = $game_actors[actor_id]
      next if actor == nil
      if all_party_members.include?(actor)
        $game_party.remove_actor(actor_id)
      end
    end

    restore_standby_members

    if @original_battle_member_count != nil &&
       $game_party.respond_to?(:battle_member_count=)
      $game_party.battle_member_count = @original_battle_member_count
    end

    if @original_max_battle_member_count != nil &&
       $game_party.respond_to?(:max_battle_member_count=)
      $game_party.max_battle_member_count = @original_max_battle_member_count
    end

    clear_runtime
  end
end

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 新建立角色時，temp_level 應保持 nil，供 YEZ Skill Levels 暫時計算使用。
#==============================================================================
class Game_Actor < Game_Battler
  unless method_defined?(:albert_summon_temp_v2_initialize)
    alias albert_summon_temp_v2_initialize initialize
  end

  def initialize(actor_id)
    albert_summon_temp_v2_initialize(actor_id)
    @temp_level = nil
    @temp_exp = nil
  end
end

#==============================================================================
# ■ Scene_Map
#==============================================================================
class Scene_Map < Scene_Base
  unless method_defined?(:albert_summon_temp_v2_call_battle)
    alias albert_summon_temp_v2_call_battle call_battle
  end

  def call_battle
    AlbertSummonTemporaryBattle.prepare
    albert_summon_temp_v2_call_battle
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# display_result：舊架構移除待命角色後，補發其 KGC 待命 EXP。
# terminate：本腳本務必放在其他 Battle terminate 補丁之後，先讓所有舊的
#            terminate / H87 cooldown 清理看得到召喚物，再最後移除召喚物。
#==============================================================================
class Scene_Battle < Scene_Base
  if method_defined?(:display_result) &&
     !method_defined?(:albert_summon_temp_v2_display_result)
    alias albert_summon_temp_v2_display_result display_result

    def display_result
      albert_summon_temp_v2_display_result
      AlbertSummonTemporaryBattle.grant_standby_exp
    end
  end

  unless method_defined?(:albert_summon_temp_v2_terminate)
    alias albert_summon_temp_v2_terminate terminate
  end

  def terminate
    albert_summon_temp_v2_terminate
    AlbertSummonTemporaryBattle.cleanup
  end
end

#==============================================================================
# PHASE7 ORIGINAL PAGE: 409 | SummonTemporaryBattle_DatabaseSync
#==============================================================================
#==============================================================================

# ■ Albert_SummonTemporaryBattle_DatabaseSync_v2_0_1_Safe_RGSS2Fix

#------------------------------------------------------------------------------

# RPG Maker VX / RGSS2 / Ruby 1.8 compatible

#

# 目的：

#   取代舊版 Albert_SummonTemporaryBattle_DatabaseSync_v1_0。

#

# 舊版問題：

#   舊版會在戰鬥前直接把目前存檔 Game_Actor 的 @class_id 改成

#   $data_actors[actor_id].class_id，但不會同步 @class_jp、@skills、

#   @skill_level 等養成資料，容易形成「半新半舊」狀態。

#

# 本版原則：

#   1. 自動同步只處理顯示身分：名稱、行走圖、臉圖。

#   2. 絕不自動修改 @class_id。

#   3. 絕不呼叫 setup(actor_id)。

#   4. 絕不重置 EXP、JP、技能等級、裝備、HP/MP、State。

#   5. 可選擇把「目前 Class、目前等級依資料庫本應已學會的技能」補入 @skills。

#      只補不刪，避免誤刪事件習得技、裝備技、特殊腳本技能。

#   6. 提供手動修復舊存檔與明確 Class 遷移方法。

#

# 安裝：

#   A. 最佳方式：整頁取代舊 SummonTemporaryBattle_DatabaseSync。

#   B. 放在 Albert_SummonTemporaryBattle_v2_0 之後、

#      Equip_SummonPage_Extension 之前、Main 之前。

#

#==============================================================================



$imported = {} if $imported == nil

$imported["Albert_SummonTemporaryBattle_DatabaseSync_Safe"] = true



module AlbertSummonTemporaryBattle



  #--------------------------------------------------------------------------

  # ● 自動同步設定

  #--------------------------------------------------------------------------



  # true：同步名稱、行走圖、臉圖。

  SYNC_DISPLAY_IDENTITY = true



  # true：將目前 Class 在目前等級以前應學會、但存檔 @skills 缺少的技能補入。

  #       只補不刪。

  SYNC_CURRENT_CLASS_LEARNINGS = true



  # false：不在自動流程重建 EXP List。

  #        若你修改 Actor 的 exp_basis / exp_inflation，請用手動修復方法處理。

  REBUILD_EXP_LIST_AUTOMATICALLY = false



  #--------------------------------------------------------------------------

  # ● 取得目前資料庫 Actor

  #--------------------------------------------------------------------------

  def self.current_database_actor(actor_id)

    actor_id = actor_id.to_i

    return nil if actor_id <= 0

    return nil if $data_actors == nil

    return $data_actors[actor_id]

  end



  #--------------------------------------------------------------------------

  # ● 取得目前存檔 Game_Actor

  #--------------------------------------------------------------------------

  def self.current_runtime_actor(actor_id)

    actor_id = actor_id.to_i

    return nil if actor_id <= 0

    return nil if $game_actors == nil

    return $game_actors[actor_id]

  end



  #--------------------------------------------------------------------------

  # ● 安全同步顯示身分

  #    不碰 @class_id / @class_jp / @skills / @skill_level。

  #--------------------------------------------------------------------------

  def self.sync_actor_display_identity(actor, data)

    return actor if actor == nil

    return actor if data == nil



    actor.instance_variable_set(:@actor_id, data.id)

    actor.instance_variable_set(:@name, data.name)

    actor.instance_variable_set(:@character_name, data.character_name)

    actor.instance_variable_set(:@character_index, data.character_index)

    actor.instance_variable_set(:@face_name, data.face_name)

    actor.instance_variable_set(:@face_index, data.face_index)



    return actor

  end



  #--------------------------------------------------------------------------

  # ● 依目前 Runtime Class / Level 補入資料庫應有技能

  #    只補不刪。

  #--------------------------------------------------------------------------

  def self.sync_current_class_learnings(actor)

    return actor if actor == nil

    return actor unless actor.respond_to?(:class)

    return actor unless actor.respond_to?(:level)

    return actor unless actor.respond_to?(:learn_skill)



    klass = actor.class

    return actor if klass == nil

    return actor unless klass.respond_to?(:learnings)



    klass.learnings.each do |learning|

      next if learning == nil

      next if learning.level.to_i > actor.level.to_i

      skill_id = learning.skill_id.to_i

      next if skill_id <= 0

      next if $data_skills == nil

      next if $data_skills[skill_id] == nil

      actor.learn_skill(skill_id)

    end



    return actor

  end



  #--------------------------------------------------------------------------

  # ● 重建 EXP List，但保留目前總 EXP / 等級，不自動 Change Exp

  #--------------------------------------------------------------------------

  def self.rebuild_actor_exp_list(actor)

    return actor if actor == nil

    return actor unless actor.respond_to?(:make_exp_list)

    actor.make_exp_list

    return actor

  end



  #--------------------------------------------------------------------------

  # ● 安全自動同步

  #

  # 重要：

  #   舊版在這裡直接 set @class_id。

  #   本版故意不做。

  #--------------------------------------------------------------------------

  def self.sync_actor_database_data(actor_id)

    actor = current_runtime_actor(actor_id)

    data  = current_database_actor(actor_id)



    return actor if actor == nil

    return actor if data == nil



    sync_actor_display_identity(actor, data) if SYNC_DISPLAY_IDENTITY

    sync_current_class_learnings(actor) if SYNC_CURRENT_CLASS_LEARNINGS

    rebuild_actor_exp_list(actor) if REBUILD_EXP_LIST_AUTOMATICALLY



    return actor

  end



  #--------------------------------------------------------------------------

  # ● 手動修復單一 Actor

  #

  # 呼叫：

  #   AlbertSummonTemporaryBattle.repair_actor_from_current_database(11)

  #

  # 預設：

  #   - 同步顯示身分

  #   - 補入目前 Class / Level 應有技能

  #   - 不改 Class ID

  #   - 不重建 EXP List

  #--------------------------------------------------------------------------

  def self.repair_actor_from_current_database(actor_id, rebuild_exp_list = false)

    actor = sync_actor_database_data(actor_id)

    return nil if actor == nil



    rebuild_actor_exp_list(actor) if rebuild_exp_list

    return actor

  end



  #--------------------------------------------------------------------------

  # ● 手動修復所有 ArmorMapping 目前映射召喚物

  #

  # 呼叫：

  #   AlbertSummonTemporaryBattle.repair_all_mapped_summons

  #

  # 或重建 EXP List：

  #   AlbertSummonTemporaryBattle.repair_all_mapped_summons(true)

  #--------------------------------------------------------------------------

  def self.repair_all_mapped_summons(rebuild_exp_list = false)

    return [] unless defined?(ArmorMapping)

    return [] unless ArmorMapping.respond_to?(:mapping)



    ids = []

    ArmorMapping.mapping.each_value do |actor_id|

      actor_id = actor_id.to_i

      next if actor_id <= 0

      next if ids.include?(actor_id)

      ids << actor_id

    end



    ids.each do |actor_id|

      repair_actor_from_current_database(actor_id, rebuild_exp_list)

    end



    return ids

  end



  #--------------------------------------------------------------------------

  # ● 明確、安全地遷移 Class ID

  #

  # 只有你「確定要把舊存檔 Actor 轉成目前資料庫 Class」時才呼叫。

  # 自動同步永遠不會呼叫這個方法。

  #

  # 呼叫：

  #   AlbertSummonTemporaryBattle.migrate_actor_class_to_database(11)

  #

  # JP 規則：

  #   - 若舊 Class 有 JP，而新 Class JP 為 0，移動到新桶。

  #   - 若新舊兩桶都有 JP，不自動合併，避免重複或誤吞資料。

  #--------------------------------------------------------------------------

  def self.migrate_actor_class_to_database(actor_id)

    actor = current_runtime_actor(actor_id)

    data  = current_database_actor(actor_id)



    return nil if actor == nil

    return actor if data == nil



    old_class_id = actor.class_id.to_i

    new_class_id = data.class_id.to_i



    return actor if new_class_id <= 0

    return actor if old_class_id == new_class_id



    if actor.respond_to?(:class_jp)

      jp_hash = actor.class_jp

      old_jp = jp_hash[old_class_id].to_i

      new_jp = jp_hash[new_class_id].to_i



      if old_jp > 0 && new_jp == 0

        jp_hash[new_class_id] = old_jp

        jp_hash[old_class_id] = 0

      end

    end



    # 故意直接改 ivar，不呼叫 class_id=，避免自動卸裝等副作用。

    actor.instance_variable_set(:@class_id, new_class_id)



    sync_current_class_learnings(actor)

    return actor

  end



  #--------------------------------------------------------------------------

  # ● 取得偵錯資訊

  #

  # 事件測試：

  #   p AlbertSummonTemporaryBattle.actor_database_debug_info(11)

  #--------------------------------------------------------------------------

  def self.actor_database_debug_info(actor_id)

    actor = current_runtime_actor(actor_id)

    data  = current_database_actor(actor_id)

    return nil if actor == nil || data == nil



    # RGSS2 內建 Ruby 沒有 Object#instance_variable_defined?。

    # 不存在的 @skills 直接讀取會回傳 nil。

    runtime_skills = actor.instance_variable_get(:@skills)

    runtime_skills = [] if runtime_skills == nil



    class_learning_ids = []

    klass = actor.class

    if klass != nil && klass.respond_to?(:learnings)

      klass.learnings.each do |learning|

        next if learning == nil

        next if learning.level.to_i > actor.level.to_i

        class_learning_ids << learning.skill_id.to_i

      end

    end



    info = {}

    info[:actor_id] = actor_id.to_i

    info[:runtime_name] = actor.name

    info[:database_name] = data.name

    info[:runtime_class_id] = actor.class_id.to_i

    info[:database_class_id] = data.class_id.to_i

    info[:runtime_level] = actor.level.to_i

    info[:runtime_skill_ids] = runtime_skills.clone

    info[:database_learning_ids_at_level] = class_learning_ids.uniq.sort

    info[:missing_learning_ids] = class_learning_ids.uniq - runtime_skills



    if actor.respond_to?(:class_jp)

      info[:class_jp] = actor.class_jp.clone

    end



    return info

  end



  #--------------------------------------------------------------------------

  # ● 戰鬥前取得召喚名單後，執行安全同步

  #--------------------------------------------------------------------------

  class << self

    unless method_defined?(:albert_safe_db_sync_collect_summon_entries)

      alias albert_safe_db_sync_collect_summon_entries collect_summon_entries

    end



    def collect_summon_entries

      result = albert_safe_db_sync_collect_summon_entries

      result.each do |entry|

        actor_id = entry[1]

        sync_actor_database_data(actor_id)

      end

      return result

    end

  end



end
