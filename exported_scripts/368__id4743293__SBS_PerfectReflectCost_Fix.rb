#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：SBS_PerfectReflectCost_Fix
# 【用途】戰鬥系統元件「SBS_PerfectReflectCost_Fix」。
# 【主要機制】負責戰鬥流程、數值、AI、演出或相容的一部分；可能透過 alias 疊加既有方法。
# 【主要影響】Scene_Battle、ALBERT_SBS_PERFECT_REFLECT_COST_FIX
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：PERFECT_HIT_CHECKS_REFLECT_AND_NULL、COSTABSORB_ONLY_ON_ACTUAL_HIT。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
# ■ Albert_RMVX_SBS_PerfectReflectCost_Fix.rb
#------------------------------------------------------------------------------
#  RPG Maker VX / RGSS2
#
#  放置位置：
#    Tankentai / SBS / ATB
#    Notetags for Tankentai
#    其他會改 Scene_Battle#damage_action 的腳本
#    Albert_RMVX_SBS_PerfectReflectCost_Fix.rb
#    Main
#
#  修正內容：
#    1. PERFECTHIT 不再自動繞過 magic reflect / physical reflect / null。
#       - perfect hit = 必中
#       - ignore reflect = 才無視反射/無效判定
#
#    2. COSTABSORB 不再於反射、無效、miss、evade、skipped 時吸收技能消耗。
#
#  注意：
#    原腳本的 IGNOREREFLECT 是直接跳過 magic_reflection / physics_reflection，
#    而這兩個方法同時處理 reflect 與 null。
#    為了避免改太多系統語意，本補丁保留此行為：
#      IGNOREREFLECT = 跳過反射/無效檢查。
#==============================================================================

module ALBERT_SBS_PERFECT_REFLECT_COST_FIX
  # true：
  #   perfect hit 仍要先檢查反射/無效。
  # false：
  #   回到原腳本行為，perfect hit 會繞過反射/無效。
  PERFECT_HIT_CHECKS_REFLECT_AND_NULL = true

  # true：
  #   absorb cost 只有在實際命中、沒有被反射/無效時才發動。
  # false：
  #   回到原腳本行為，只要被指定為目標就可能吸收消耗。
  COSTABSORB_ONLY_ON_ACTUAL_HIT = true
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * extension 安全判定
  #--------------------------------------------------------------------------
  def albert_sbs_prc_ext?(obj, word)
    return false if obj == nil
    return false unless obj.respond_to?(:extension)
    return obj.extension.include?(word)
  end

  #--------------------------------------------------------------------------
  # * 反射 / 無效判定
  #--------------------------------------------------------------------------
  def albert_sbs_prc_check_reflect_and_null(target, obj)
    return if obj == nil
    return if albert_sbs_prc_ext?(obj, "IGNOREREFLECT")
    magic_reflection(target, obj)
    physics_reflection(target, obj)
  end

  #--------------------------------------------------------------------------
  # * 技能效果套用
  #--------------------------------------------------------------------------
  def albert_sbs_prc_apply_skill_effect(target, obj)
    if target.hp == 0 && !obj.for_dead_friend?
      target.perfect_skill_effect(@active_battler, obj)
    elsif albert_sbs_prc_ext?(obj, "PERFECTHIT")
      target.perfect_skill_effect(@active_battler, obj)
    else
      target.skill_effect(@active_battler, obj)
    end
  end

  #--------------------------------------------------------------------------
  # * 物品效果套用
  #--------------------------------------------------------------------------
  def albert_sbs_prc_apply_item_effect(target, obj)
    if target.hp == 0 && !obj.for_dead_friend?
      target.perfect_item_effect(@active_battler, obj)
    elsif albert_sbs_prc_ext?(obj, "PERFECTHIT")
      target.perfect_item_effect(@active_battler, obj)
    else
      target.item_effect(@active_battler, obj)
    end
  end

  #--------------------------------------------------------------------------
  # * COSTABSORB 是否可以發動
  #--------------------------------------------------------------------------
  def albert_sbs_prc_costabsorb_ok?(target)
    return false if @reflection
    return false if @invalid
    return true unless ALBERT_SBS_PERFECT_REFLECT_COST_FIX::COSTABSORB_ONLY_ON_ACTUAL_HIT
    return false if target.respond_to?(:missed) && target.missed
    return false if target.respond_to?(:evaded) && target.evaded
    return false if target.respond_to?(:skipped) && target.skipped
    return true
  end

  #--------------------------------------------------------------------------
  # ● ダメージ処理
  #   重新定義原 SBS damage_action：
  #   - perfect hit 前先檢查 reflect/null
  #   - absorb cost 僅在有效命中後發動
  #--------------------------------------------------------------------------
  def damage_action(action)
    # 個別處理時，逐一取出目標
    @targets = [@individual_target.shift] if @active_battler.individual

    #----------------------------------------------------------------------
    # 技能
    #----------------------------------------------------------------------
    if @active_battler.action.skill?
      obj = @active_battler.action.skill

      for target in @targets
        return if target == nil
        return if target.dead? && !obj.for_dead_friend?

        target.revival = true if obj.for_dead_friend?

        if ALBERT_SBS_PERFECT_REFLECT_COST_FIX::PERFECT_HIT_CHECKS_REFLECT_AND_NULL
          albert_sbs_prc_check_reflect_and_null(target, obj)
        elsif !albert_sbs_prc_ext?(obj, "PERFECTHIT")
          albert_sbs_prc_check_reflect_and_null(target, obj)
        end

        albert_sbs_prc_apply_skill_effect(target, obj) unless @reflection or @invalid
        pop_damage(target, obj, action) unless @reflection or @invalid

        absorb_cost(target, obj) if albert_sbs_prc_costabsorb_ok?(target)

        @active_battler.reflex = action if @reflection
        @reflection = false
        @invalid = false
      end

    #----------------------------------------------------------------------
    # 物品
    #----------------------------------------------------------------------
    elsif @active_battler.action.item?
      obj = @active_battler.action.item

      for target in @targets
        return if target == nil
        return if target.dead? && !obj.for_dead_friend?

        target.revival = true if obj.for_dead_friend?

        if ALBERT_SBS_PERFECT_REFLECT_COST_FIX::PERFECT_HIT_CHECKS_REFLECT_AND_NULL
          albert_sbs_prc_check_reflect_and_null(target, obj)
        elsif !albert_sbs_prc_ext?(obj, "PERFECTHIT")
          albert_sbs_prc_check_reflect_and_null(target, obj)
        end

        albert_sbs_prc_apply_item_effect(target, obj) unless @reflection or @invalid
        pop_damage(target, obj, action) unless @reflection or @invalid

        @active_battler.reflex = action if @reflection
        @reflection = false
        @invalid = false
      end

    #----------------------------------------------------------------------
    # 普通攻擊
    #----------------------------------------------------------------------
    else
      obj = nil

      for target in @targets
        return if target == nil or target.dead?

        physics_reflection(target, nil)

        target.perfect_attack_effect(@active_battler) if target.hp <= 0
        target.attack_effect(@active_battler) unless target.hp <= 0 or @reflection or @invalid

        pop_damage(target, nil, action) unless @reflection or @invalid

        @active_battler.reflex = action if @reflection
        @reflection = false
        @invalid = false
      end
    end

    @status_window.refresh

    return if obj == nil
    target_decision(obj) if albert_sbs_prc_ext?(obj, "RANDOMTARGET")
  end
end
