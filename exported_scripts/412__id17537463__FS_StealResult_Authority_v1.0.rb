#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_StealResult_Authority v1.0
# 【用途】Forest Symphony 正式 Authority「FS_StealResult_Authority v1.0」，集中管理此功能目前應修改的主要實作。
# 【主要機制】本頁可能由既有 Base／第三方插件一路 Patch 而來；修改時仍需查看 LoadOrder Guide／Authority Map，確認是否還有後載入 wrapper。
# 【主要影響】Game_Battler、Scene_Battle、FS_STEAL_RESULT_SE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SUCCESS_SE_NAME、SUCCESS_SE_VOLUME、SUCCESS_SE_PITCH、FAILURE_SE_NAME、FAILURE_SE_VOLUME、FAILURE_SE_PITCH、FAILURE_ON_NO_HIT、FAILURE_ON_NO_ITEM。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# PHASE7 ORIGINAL PAGE: 437 | Tankentai_StealResultFix
#==============================================================================
#==============================================================================
# ■ FS_Tankentai_StealResultFix_v1_0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 修正問題：
#   KGC偷竊_Patch 的 execute_action_steal 只執行 playing_action，
#   沒有保證呼叫 target.skill_effect。
#
#   當汲取技能沒有傷害、狀態或其他效果時，
#   Tankentai 動作序列可能完全不執行 skill_effect，
#   導致 stolen_object 永遠為 nil，必定顯示失敗。
#
# 修正效果：
#   1. 保留技能命中率
#   2. 保留敵人迴避率
#   3. 保留招架判定
#   4. 0 傷害仍可正常汲取
#   5. 有傷害技能不會重複造成傷害
#   6. 每次行動只抽一次汲取機率
#   7. 防止多段動作重複汲取或覆蓋成功結果
#
# 放置位置：
#   所有 KGC Steal、Tankentai、戰鬥、DynamicCaptureRate、
#   SoulRepeatRecipe 與魂刻補丁之後，Main 之前。
#==============================================================================

if defined?(Game_Battler) &&
   Game_Battler.method_defined?(:make_obj_steal_result)

  class Game_Battler

    # 本次汲取行動是否執行過技能效果
    attr_accessor :fs_steal_effect_processed

    # 本次汲取行動是否執行過汲取判定
    attr_accessor :fs_steal_result_checked

    #--------------------------------------------------------------------------
    # ● 判斷是否為汲取技能
    #--------------------------------------------------------------------------
    def fs_steal_skill?(obj)
      return false if obj == nil
      return false unless obj.respond_to?(:steal?)

      begin
        return obj.steal?
      rescue
        return false
      end
    end

    #--------------------------------------------------------------------------
    # ● 包裝汲取判定
    #    同一次行動只能判定一次，避免多段動畫重複抽選。
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_tankentai_steal_old_make_result)
      alias fs_tankentai_steal_old_make_result make_obj_steal_result
    end

    def make_obj_steal_result(user, obj)
      unless fs_steal_skill?(obj)
        return fs_tankentai_steal_old_make_result(user, obj)
      end

      # 同一次汲取行動已經判定過
      return if @fs_steal_result_checked

      # 先標記，無論命中、失誤或迴避都算已完成一次判定
      @fs_steal_result_checked = true

      # 招架視同未命中，不進行擷取機率抽選
      if respond_to?(:parried)
        begin
          return if parried
        rescue
        end
      end

      fs_tankentai_steal_old_make_result(user, obj)
    end

    #--------------------------------------------------------------------------
    # ● 包裝技能效果
    #    只要 skill_effect 確實被呼叫，就記錄下來。
    #--------------------------------------------------------------------------
    if method_defined?(:skill_effect) &&
       !method_defined?(:fs_tankentai_steal_old_skill_effect)

      alias fs_tankentai_steal_old_skill_effect skill_effect

      def skill_effect(user, skill)
        steal_skill = fs_steal_skill?(skill)

        if steal_skill
          @fs_steal_effect_processed = true
        end

        result = fs_tankentai_steal_old_skill_effect(user, skill)

        # 某些後載入戰鬥腳本覆蓋了 KGC 的 skill_effect 掛鉤。
        # 技能效果已處理，但尚未執行汲取判定時，在此補做。
        if steal_skill && !@fs_steal_result_checked
          if respond_to?(:parried)
            begin
              if parried
                @fs_steal_result_checked = true
                return result
              end
            rescue
            end
          end

          make_obj_steal_result(user, skill)
        end

        return result
      end
    end
  end
end


if defined?(Scene_Battle) &&
   Scene_Battle.method_defined?(:execute_action_steal) &&
   Scene_Battle.method_defined?(:display_steal_effects)

  class Scene_Battle

    #--------------------------------------------------------------------------
    # ● 汲取行動開始前，清除上一次的暫存結果
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_tankentai_steal_old_execute_action)
      alias fs_tankentai_steal_old_execute_action execute_action_steal
    end

    def execute_action_steal
      battlers = []

      if $game_party != nil
        begin
          battlers += $game_party.members
        rescue
        end
      end

      if $game_troop != nil
        begin
          battlers += $game_troop.members
        rescue
        end
      end

      battlers.compact.each do |battler|
        if battler.respond_to?(:fs_steal_effect_processed=)
          battler.fs_steal_effect_processed = false
        end

        if battler.respond_to?(:fs_steal_result_checked=)
          battler.fs_steal_result_checked = false
        end

        # 清除上一輪的顯示結果，但不清除敵人持有的偷竊物件
        if battler.respond_to?(:stolen_object=)
          battler.stolen_object = nil
        end
      end

      fs_tankentai_steal_old_execute_action
    end

    #--------------------------------------------------------------------------
    # ● 顯示汲取結果前，確認技能效果與汲取判定確實執行
    #--------------------------------------------------------------------------
    unless method_defined?(:fs_tankentai_steal_old_display_effects)
      alias fs_tankentai_steal_old_display_effects display_steal_effects
    end

    def display_steal_effects(target, obj = nil)
      steal_skill = false

      if obj != nil && obj.respond_to?(:steal?)
        begin
          steal_skill = obj.steal?
        rescue
          steal_skill = false
        end
      end

      if steal_skill && target != nil

        # Tankentai 沒有執行技能效果時，在顯示結果前補做一次。
        # 這會正常進行命中、迴避、傷害與狀態判定。
        unless target.fs_steal_effect_processed
          target.skill_effect(@active_battler, obj)
        end

        # 防止其他腳本又切斷 KGC 掛鉤。
        unless target.fs_steal_result_checked
          target.make_obj_steal_result(@active_battler, obj)
        end
      end

      fs_tankentai_steal_old_display_effects(target, obj)
    end
  end
end

#==============================================================================
# PHASE7 ORIGINAL PAGE: 438 | StealResultSE
#==============================================================================
#==============================================================================
# ■ FS_StealResultSE_v1_0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 功能：
#   汲取成功時播放成功音效。
#   命中後汲取失敗時播放失敗音效。
#   敵人已無可汲取物品時，也播放失敗音效。
#
# 預設不在 Miss／Evade／Parry 時追加失敗音效，
# 避免與原本的落空、迴避、招架音效重疊。
#
# 放置位置：
#   FS_Tankentai_StealResultFix_v1_0 之後、Main 之前。
#==============================================================================

module FS_STEAL_RESULT_SE

  #--------------------------------------------------------------------------
  # ● 音效設定
  #    檔案放在 Audio/SE，名稱不需要副檔名
  #--------------------------------------------------------------------------

  SUCCESS_SE_NAME   = "Recovery"
  SUCCESS_SE_VOLUME = 90
  SUCCESS_SE_PITCH  = 105

  FAILURE_SE_NAME   = "Buzzer1"
  FAILURE_SE_VOLUME = 75
  FAILURE_SE_PITCH  = 100

  # Miss／Evade／Parry 時是否也播放汲取失敗音效
  # false：只播放原本的落空／迴避／招架音效
  # true ：再追加一次汲取失敗音效
  FAILURE_ON_NO_HIT = false

  # 敵人已沒有可汲取物品時，是否播放失敗音效
  FAILURE_ON_NO_ITEM = true

  #--------------------------------------------------------------------------
  # ● 播放成功音效
  #--------------------------------------------------------------------------
  def self.play_success
    begin
      RPG::SE.new(
        SUCCESS_SE_NAME,
        SUCCESS_SE_VOLUME,
        SUCCESS_SE_PITCH
      ).play
    rescue
      # 自訂檔案不存在時，退回資料庫的確定音效
      Sound.play_decision if defined?(Sound)
    end
  end

  #--------------------------------------------------------------------------
  # ● 播放失敗音效
  #--------------------------------------------------------------------------
  def self.play_failure
    begin
      RPG::SE.new(
        FAILURE_SE_NAME,
        FAILURE_SE_VOLUME,
        FAILURE_SE_PITCH
      ).play
    rescue
      # 自訂檔案不存在時，退回資料庫的無效音效
      Sound.play_buzzer if defined?(Sound)
    end
  end
end


if defined?(Scene_Battle) &&
   Scene_Battle.method_defined?(:display_stole_object)

  class Scene_Battle < Scene_Base

    unless method_defined?(:fs_steal_se_old_display_stole_object)
      alias fs_steal_se_old_display_stole_object display_stole_object
    end

    #--------------------------------------------------------------------------
    # ● 顯示汲取結果
    #--------------------------------------------------------------------------
    def display_stole_object(target, obj = nil)

      if target != nil

        skipped = false
        missed  = false
        evaded  = false
        parried = false

        begin
          skipped = target.skipped
        rescue
        end

        begin
          missed = target.missed
        rescue
        end

        begin
          evaded = target.evaded
        rescue
        end

        begin
          parried = target.parried if target.respond_to?(:parried)
        rescue
          parried = false
        end

        no_hit = skipped || missed || evaded || parried

        if no_hit
          # 落空／迴避／招架通常已有原本的戰鬥音效
          if FS_STEAL_RESULT_SE::FAILURE_ON_NO_HIT && !skipped
            FS_STEAL_RESULT_SE.play_failure
          end

        else
          # 若安裝了汲取修復補丁，確認此次真的執行過判定
          checked = true

          if target.respond_to?(:fs_steal_result_checked)
            checked = target.fs_steal_result_checked
          end

          if checked
            result = nil

            begin
              result = target.stolen_object
            rescue
              result = nil
            end

            case result
            when nil
              # 命中，但機率判定失敗
              FS_STEAL_RESULT_SE.play_failure

            when :no_item
              # 敵人已沒有可汲取物品
              if FS_STEAL_RESULT_SE::FAILURE_ON_NO_ITEM
                FS_STEAL_RESULT_SE.play_failure
              end

            else
              # 實際取得金錢、物品、武器、防具或魂刻
              FS_STEAL_RESULT_SE.play_success
            end
          end
        end
      end

      fs_steal_se_old_display_stole_object(target, obj)
    end
  end
end
