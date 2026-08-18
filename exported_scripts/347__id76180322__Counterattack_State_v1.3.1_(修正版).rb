#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Counterattack State v1.3.1 (修正版)
# 【用途】保留的 Runtime 元件「Counterattack State v1.3.1 (修正版)」。
# 【主要機制】主要定義／擴充 RPG::State、Game_Battler、Scene_Battle；下方原始說明與程式碼保留作細節依據。
# 【主要影響】RPG::State、Game_Battler、Scene_Battle
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：CounterattackState。
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
#===============================================================================
# 
# Shanghai Simple Script - Counterattack State
# Last Date Updated: 2010.05.02
# Level: Normal反擊
# 
# For a simple counterattack script with nothing fancy like skill counters,
# this script will have battlers retaliate if they're alive and have a state
# with the counterattack property. Compatibility with Battle Engine Melody.
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To install this script, open up your script editor and copy/paste this script
# to an open slot below ? Materials but above ? Main. Remember to save.
# 
# <counterattack>
# Just put this into your state's notebox and it will create a counterattack
# when the battler takes damage. Cannot counterattack other counterattacks.
#===============================================================================
 
$imported = {} if $imported == nil
$imported["CounterattackState"] = true
 
#==============================================================================
# RPG::State
#==============================================================================
 
class RPG::State
  #--------------------------------------------------------------------------
  # counterattack
  #--------------------------------------------------------------------------
  def counterattack
    return @counterattack if @counterattack != nil
    @counterattack = false
    self.note.split(/[\r\n]+/).each { |line|
      case line
      when /<(?:COUNTERATTACK|counter attack)>/i
        @counterattack = true
      end
    }
    return @counterattack
  end
end
 
#==============================================================================
# ** Game_Battler
#==============================================================================
 
class Game_Battler
  attr_accessor :action
  attr_accessor :counterattack
  #--------------------------------------------------------------------------
  # * Damage Reflection
  #--------------------------------------------------------------------------
  alias execute_damage_sss_counterattack execute_damage unless $@
  def execute_damage(user)
    execute_damage_sss_counterattack(user)
    create_counterattack if @hp_damage > 0
  end
  #--------------------------------------------------------------------------
  # * create_counterattack
  #--------------------------------------------------------------------------
  def create_counterattack
    return if !$scene.is_a?(Scene_Battle)
    return if !exist?
    return if $scene.active_battler.actor? == self.actor?
    for state in states
      next if !state.counterattack
      @counterattack = true
      break
    end
  end
end
 
#==============================================================================
# ** Scene_Battle
#==============================================================================
 
class Scene_Battle < Scene_Base
  attr_accessor :active_battler
  #--------------------------------------------------------------------------
  # * Execute Battle Actions
  #--------------------------------------------------------------------------
  alias execute_action_sss_counterattack execute_action unless $@
  def execute_action
    execute_action_sss_counterattack
    process_counterattack if !@process_counterattack
  end
  #--------------------------------------------------------------------------
  # * process_counterattack
  #--------------------------------------------------------------------------
  def process_counterattack
    @process_counterattack = true
    for member in ($game_party.existing_members + $game_troop.existing_members)
      break if @active_battler == nil or !@active_battler.exist?
      next if member == nil
      next if !member.counterattack
      last_action = member.action.clone
      last_battler = @active_battler
      member.action.set_attack
      member.action.target_index = @active_battler.index
      @active_battler = member
      inside_performed_actors = false
      if @performed_actors != nil
        inside_performed_actors = true if @performed_actors.include?(member)
      end
      @message_window.clear
      $game_switches[27] = true #反擊語句
      execute_action
      if @performed_actors != nil and !inside_performed_actors
        @performed_actors.delete(@active_battler)
      end
      @active_battler = last_battler
      member.action = last_action
      member.counterattack = nil
    end
    @process_counterattack = false
  end
end
 
#===============================================================================
# 
# END OF FILE
# 
#===============================================================================