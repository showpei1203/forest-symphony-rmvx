#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_ForceAction_Bridge
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_ForceAction_Bridge」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Troop、Scene_Battle、Game_Interpreter、FS_FORCE_ACTION_BRIDGE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：RANDOM_TARGET、LAST_TARGET。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】force_action(A, B, C, D, E)；force_action(-1, 1, 1, 100, -1)；force_action(-1, 1, 0, 0, -1)
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
# ■ FS_ForceAction_Bridge
#------------------------------------------------------------------------------
#  讓事件中可使用 force_action(A, B, C, D, E)
#  直接接到目前 ATB 的 @forcing_battlers 佇列
#------------------------------------------------------------------------------
#  用法：
#    force_action(A, B, C, D, E)
#
#  A = 指定施術者方式
#      -1 : Actor ID
#       0 : 敵方隊伍位置（0 開始）
#       1 : 我方隊伍位置（0 開始）
#
#  B = 施術者 ID / 位置
#
#  C = 行動種類
#       0 : 基本行動
#       1 : 技能
#       2 : 物品
#
#  D = 行動 ID
#      若 C=0 時：
#       0 : 攻擊
#       1 : 防禦
#       2 : 逃跑
#       3 : 等待
#      若 C=1 時：
#       Skill ID
#      若 C=2 時：
#       Item ID
#
#  E = 目標
#      -2 : 上次目標（若無則隨機）
#      -1 : 隨機目標
#       0以上 : 目標 index
#
#  範例：
#    force_action(-1, 1, 1, 100, -1)
#    => Actor ID 1 強制使用技能 100，目標隨機
#
#    force_action(-1, 1, 0, 0, -1)
#    => Actor ID 1 強制普通攻擊隨機目標
#
#    force_action(0, 0, 1, 50, 0)
#    => 敵方第 1 隻強制使用技能 50，指定目標 index 0
#
#  注意：
#  1. 只能在戰鬥中使用
#  2. 同一 battler 若在前一次強制行動尚未執行前又再次 force_action，
#     後一次可能覆蓋前一次，因此不建議連續同 frame 對同一人排兩次
#  3. 此腳本依賴目前 Scene_Battle 內存在 @forcing_battlers
#==============================================================================

module FS_FORCE_ACTION_BRIDGE
  RANDOM_TARGET = -1
  LAST_TARGET   = -2

  #--------------------------------------------------------------------------
  # ● 取得我方戰鬥成員
  #--------------------------------------------------------------------------
  def self.party_battle_members
    if $game_party.respond_to?(:battle_members)
      return $game_party.battle_members
    else
      return $game_party.members
    end
  end

  #--------------------------------------------------------------------------
  # ● 依 A/B 取得施術者
  #--------------------------------------------------------------------------
  def self.resolve_subject(side_type, id)
    case side_type
    when -1
      return $game_actors[id]
    when 0
      members = $game_troop.members
      return members[id]
    when 1
      members = party_battle_members
      return members[id]
    end
    return nil
  end

  #--------------------------------------------------------------------------
  # ● 設定行動
  #--------------------------------------------------------------------------
  def self.setup_action(battler, action_type, action_id, target_index)
    return false if battler.nil?
    return false unless battler.respond_to?(:action)
    return false if battler.action.nil?

    battler.action.clear

    case action_type
    when 0  # 基本行動
      case action_id
      when 0
        battler.action.set_attack
      when 1
        battler.action.set_guard
      when 2
        battler.action.set_escape
      when 3
        battler.action.set_wait
      else
        return false
      end
    when 1  # 技能
      return false if $data_skills[action_id].nil?
      battler.action.set_skill(action_id)
    when 2  # 物品
      return false if $data_items[action_id].nil?
      battler.action.set_item(action_id)
    else
      return false
    end

    if target_index == RANDOM_TARGET
      battler.action.decide_random_target
    elsif target_index == LAST_TARGET
      if battler.respond_to?(:last_target_index) && !battler.last_target_index.nil?
        battler.action.target_index = battler.last_target_index
      else
        battler.action.decide_random_target
      end
    else
      battler.action.target_index = target_index
    end

    battler.action.forcing = true
    return true
  end
end

class Game_Troop < Game_Unit
  attr_accessor :fs_force_action_queue

  alias fs_force_action_bridge_initialize initialize
  def initialize
    fs_force_action_bridge_initialize
    @fs_force_action_queue = []
  end

  alias fs_force_action_bridge_clear clear
  def clear
    fs_force_action_bridge_clear
    @fs_force_action_queue = []
  end
end

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 將待執行的強制行動丟進 ATB 強制佇列
  #--------------------------------------------------------------------------
  def fs_drain_force_action_queue
    return unless $game_temp.in_battle
    @forcing_battlers ||= []
    $game_troop.fs_force_action_queue ||= []

    while !$game_troop.fs_force_action_queue.empty?
      battler = $game_troop.fs_force_action_queue.shift
      next if battler.nil?
      next unless battler.exist?
      next if @forcing_battlers.include?(battler)
      @forcing_battlers << battler
    end
  end

  alias fs_force_action_bridge_update_basic update_basic
  def update_basic(*args)
    fs_drain_force_action_queue
    fs_force_action_bridge_update_basic(*args)
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 強制行動
  #--------------------------------------------------------------------------
  def force_action(side_type, subject_id, action_type, action_id, target_index = -1)
    return false unless $game_temp.in_battle
    return false unless $scene.is_a?(Scene_Battle)

    battler = FS_FORCE_ACTION_BRIDGE.resolve_subject(side_type, subject_id)
    return false if battler.nil?
    return false unless battler.exist?

    success = FS_FORCE_ACTION_BRIDGE.setup_action(
      battler, action_type, action_id, target_index
    )
    return false unless success

    $game_troop.fs_force_action_queue ||= []
    $game_troop.fs_force_action_queue << battler
    return true
  end
end