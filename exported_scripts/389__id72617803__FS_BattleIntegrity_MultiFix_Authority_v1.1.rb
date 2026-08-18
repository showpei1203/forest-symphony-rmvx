#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_BattleIntegrity_MultiFix_Authority v1.1
# 【用途】Forest Symphony 正式 Authority「FS_BattleIntegrity_MultiFix_Authority v1.0」，集中管理此功能目前應修改的主要實作。
# 【主要機制】本頁可能由既有 Base／第三方插件一路 Patch 而來；修改時仍需查看 LoadOrder Guide／Authority Map，確認是否還有後載入 wrapper。
# 【主要影響】Game_Actor、Game_Battler、Scene_Battle、ALBERT_BATTLE_INTEGRITY_FIX、ALBERT_SUMMON_EQUIP_SKILL
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 7 個 alias／方法包裝，載入順序具有語意；登記 $imported：AlbertBattleIntegrityFix；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# Albert_BattleIntegrityFix_v1_0.rb
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 放置位置：
#   所有自製戰鬥補丁、EquipmentCombo、SummonTemporaryBattle、
#   Equip_SummonPage 系列之下，Main 之上。
#
# 修正內容：
#   1. EquipmentCombo 戰鬥結束仍呼叫 Base 的 State ownership cleanup；Storage／prepare 已回歸 Combo Authority。
#   2. SummonEquipSkill 的 ArmorMapping 只接受 RPG::Armor，避免武器／防具同 ID 撞號。
#   3. ATB 選敵期間合法目標突然變成 0 時，立即取消選擇，不保留舊目標。
#   4. SummonChain3 多段攻擊會累積整段行動中「曾經弱點／曾經暴擊」的結果。
#==============================================================================

$imported = {} if $imported == nil
$imported["AlbertBattleIntegrityFix"] = true

module ALBERT_BATTLE_INTEGRITY_FIX
  #--------------------------------------------------------------------------
  # 取得目前已實例化的 Actor，避免為了清理而把整個資料庫角色全部初始化。
  #--------------------------------------------------------------------------
  def self.instantiated_actors
    result = []
    return result if $game_actors == nil

    begin
      data = $game_actors.instance_variable_get(:@data)
      if data.is_a?(Array)
        for actor in data
          result.push(actor) if actor != nil && actor.is_a?(Game_Actor)
        end
      end
    rescue
    end

    return result
  end
end

#==============================================================================
# ■ Phase 31：EquipmentCombo State Storage 已回歸 Combo Base
#------------------------------------------------------------------------------
# 本頁只保留 battle-end lifecycle cleanup call，不再定義 storage API。
#==============================================================================

#==============================================================================
# ■ 修正 2：SummonEquipSkill ArmorMapping 只接受防具
#==============================================================================
module ALBERT_SUMMON_EQUIP_SKILL
  def self.summon_actor_for(user, skill)
    return nil if user == nil
    return nil if skill == nil
    return nil unless user.respond_to?(:equips)
    return nil unless defined?(ArmorMapping)
    return nil unless ArmorMapping.respond_to?(:mapping)

    mapping = nil
    begin
      mapping = ArmorMapping.mapping
    rescue
      mapping = nil
    end
    return nil if mapping == nil

    for equip in user.equips.compact
      # 核心修正：ArmorMapping 的 key 是 Armor ID，武器不得參與。
      next unless equip.is_a?(RPG::Armor)
      next unless equip.respond_to?(:skills)

      has_skill = false
      for equip_skill in equip.skills
        next if equip_skill == nil
        if equip_skill.id == skill.id
          has_skill = true
          break
        end
      end
      next unless has_skill

      actor_id = nil
      begin
        actor_id = mapping[equip.id]
      rescue
        actor_id = nil
      end

      next if actor_id == nil || actor_id.to_i <= 0
      return $game_actors[actor_id.to_i]
    end

    return nil
  end
end

#==============================================================================
# ■ 修正 4：SummonChain3 多段 weak / critical 累積
#------------------------------------------------------------------------------
# 原本只在整段行動結束後讀 target.weak / target.critical，
# 多段攻擊若「第 1 hit 暴擊、第 2 hit 普通」，最後可能只留下 false。
#
# 現在於每一次 make_obj_damage_value 結束後累積：
#   weak     = 本段任一 hit 曾命中弱點
#   critical = 本段任一 hit 曾暴擊
#==============================================================================
class Game_Battler
  unless method_defined?(:albert_sc3mh_old_make_obj_damage_value)
    alias albert_sc3mh_old_make_obj_damage_value make_obj_damage_value
  end

  def make_obj_damage_value(user, obj)
    albert_sc3mh_old_make_obj_damage_value(user, obj)

    flags = nil
    begin
      flags = instance_variable_get(:@albert_sc3_multihit_flags)
    rescue
      flags = nil
    end
    return if flags == nil

    begin
      flags[:weak] = true if respond_to?(:weak) && weak
    rescue
    end

    begin
      flags[:critical] = true if respond_to?(:critical) && critical
    rescue
    end
  end
end

#==============================================================================
# ■ Scene_Battle 整合
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # Phase 31：EquipmentCombo before-state / ownership 邏輯已由 OpeningSkill
  # FinalAuthority v2.0 直接處理，本頁不再包 albert_prepare...。
  #--------------------------------------------------------------------------

  #--------------------------------------------------------------------------
  # ATB：選敵期間合法目標突然變成 0。
  #
  # 先讓 TargetPriority 做既有動態刷新，再用 Target Selection Exact 的
  # 最終合法判定重新過濾。若為 0，立即取消，不讓舊 @target_members 殘留。
  #--------------------------------------------------------------------------
  def albert_bif_atb_zero_enemy_targets?
    return false if @target_actors
    return false if @target_members == nil

    # 先讓原 TargetPriority 嘗試換成最新的最高優先合法群。
    if respond_to?(:albert_tp_refresh_enemy_targets)
      begin
        albert_tp_refresh_enemy_targets
      rescue
      end
    end

    return false if @target_members == nil

    current = nil
    if @index != nil && @index >= 0 && @index < @target_members.size
      current = @target_members[@index]
    end

    legal = []
    for enemy in @target_members
      next if enemy == nil

      valid = false
      if defined?(ALBERT_EXACT_TARGET_FIX)
        begin
          valid = ALBERT_EXACT_TARGET_FIX.manual_enemy_targetable?(enemy)
        rescue
          valid = false
        end
      else
        begin
          valid = enemy.exist?
        rescue
          valid = false
        end
      end

      legal.push(enemy) if valid
    end

    if legal.empty?
      @target_members = []
      @index = 0
      @max_index = -1
      return true
    end

    if legal != @target_members
      @target_members = legal
      new_index = current == nil ? nil : @target_members.index(current)
      @index = new_index == nil ? 0 : new_index
      @max_index = @target_members.size - 1

      if respond_to?(:albert_tp_sync_cursor_to_target_members)
        albert_tp_sync_cursor_to_target_members
      else
        target = @target_members[@index]
        @cursor.set(target) if @cursor != nil && target != nil
        if defined?(@help_window2) && @help_window2 != nil && target != nil
          @help_window2.set_text_n01add(target)
        end
      end
    end

    return false
  end

  # 包住最終 update_target。若 0 合法目標，取消後不再進入舊 update 鏈。
  unless method_defined?(:albert_bif_old_update_target)
    alias albert_bif_old_update_target update_target
  end

  def update_target
    if albert_bif_atb_zero_enemy_targets?
      Sound.play_buzzer
      end_target_selection(true) if respond_to?(:end_target_selection)
      return
    end

    albert_bif_old_update_target
  end

  #--------------------------------------------------------------------------
  # SummonChain3：建立快照時，同時開始累積本段所有 hit 的 weak / critical。
  #--------------------------------------------------------------------------
  if method_defined?(:albert_sc3_snapshot)
    unless method_defined?(:albert_sc3mh_old_snapshot)
      alias albert_sc3mh_old_snapshot albert_sc3_snapshot
    end

    def albert_sc3_snapshot(targets)
      list = targets == nil ? [] : targets.compact
      for target in list
        target.instance_variable_set(
          :@albert_sc3_multihit_flags,
          { :weak => false, :critical => false }
        )
      end

      return albert_sc3mh_old_snapshot(targets)
    end
  end

  #--------------------------------------------------------------------------
  # SummonChain3：分析結果後，把整段所有 hit 的累積旗標 OR 回結果。
  #--------------------------------------------------------------------------
  if method_defined?(:albert_sc3_analyze_result)
    unless method_defined?(:albert_sc3mh_old_analyze_result)
      alias albert_sc3mh_old_analyze_result albert_sc3_analyze_result
    end

    def albert_sc3_analyze_result(before_snapshot)
      result = nil

      begin
        result = albert_sc3mh_old_analyze_result(before_snapshot)
        return result if result == nil
        return result if before_snapshot == nil

        before_snapshot.each_value do |data|
          target = data[:target]
          next if target == nil

          flags = target.instance_variable_get(:@albert_sc3_multihit_flags)
          next if flags == nil

          result[:weak] = true if flags[:weak]
          result[:critical] = true if flags[:critical]
        end

        result[:hit] = true if result[:weak]
        result[:hit] = true if result[:critical]
        return result
      ensure
        if before_snapshot != nil
          before_snapshot.each_value do |data|
            target = data[:target]
            next if target == nil
            target.instance_variable_set(:@albert_sc3_multihit_flags, nil)
          end
        end
      end
    end
  end

  # 追擊執行失敗時不會進入 analyze_result，因此在此清除觀察旗標。
  if method_defined?(:albert_cc_execute_summon_followup)
    unless method_defined?(:albert_sc3mh_old_execute_summon_followup)
      alias albert_sc3mh_old_execute_summon_followup albert_cc_execute_summon_followup
    end

    def albert_cc_execute_summon_followup(summon, follow_skill, targets)
      result = albert_sc3mh_old_execute_summon_followup(summon, follow_skill, targets)

      unless result
        list = targets == nil ? [] : targets.compact
        for target in list
          target.instance_variable_set(:@albert_sc3_multihit_flags, nil)
        end
      end

      return result
    end
  end

  #--------------------------------------------------------------------------
  # 戰鬥離開前：
  #   - 清除 EquipmentCombo 所擁有的召喚物 State。
  #   - 清除萬一因例外殘留的 SummonChain3 多段觀察旗標。
  #
  # 放在既有 terminate 之前，確保 SummonTemporaryBattle 尚未移除召喚物。
  #--------------------------------------------------------------------------
  unless method_defined?(:albert_bif_old_terminate)
    alias albert_bif_old_terminate terminate
  end

  def terminate
    begin
      actors = ALBERT_BATTLE_INTEGRITY_FIX.instantiated_actors
      for actor in actors
        if actor.respond_to?(:albert_combo_clear_owned_summon_states)
          actor.albert_combo_clear_owned_summon_states
        end
        actor.instance_variable_set(:@albert_sc3_multihit_flags, nil)
      end

      for enemy in $game_troop.members
        enemy.instance_variable_set(:@albert_sc3_multihit_flags, nil) if enemy != nil
      end
    rescue
    ensure
      albert_bif_old_terminate
    end
  end
end

#==============================================================================
# END
#==============================================================================
