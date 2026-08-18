#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：目標過濾-new
# 【用途】目標選取／目標規則元件「目標過濾-new」。
# 【主要機制】目前 Targeting 存在多層 wrapper；會影響 Game_BattleAction、Scene_Battle 或選取 Window，必須遵守 Authority Map。
# 【主要影響】Scene_Battle
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
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
class Scene_Battle < Scene_Base
  alias old_start_target_selection start_target_selection
  def start_target_selection(actor = false)
    @target_members = []  # 清空目標列表
    old_start_target_selection(actor)

    if @target_actors
      if skill_switch_condition
       @target_members = $game_party.members.select { |member| member.id >= 7 && !member.dead?}
      else
       @target_members = $game_party.members.select { |member| member.id < 7 && !member.dead?}
      end
      #@target_members = $game_party.members.select { |member| valid_target?(member) }
    else
      #refresh_enemy_target_members
    end
    #selected_member = @target_members[@index]  # 取得目前選擇的角色
    #target_index = $game_party.members.index(selected_member)  # 取得該角色在隊伍中的 Index
    #$game_temp.target_index = @target_members[@index].id###
    #p "獲取的ACTOR ID: #{$game_temp.target_index}"
    @cursor.set(@target_members[@index])
    @help_window2.set_text_n01add(@target_members[@index])
  end
  
  #--------------------------------------------------------------------------
# ★ 读技能 note 中＜特殊使用条件＞的“スイッチ, 50”条件（用于我方选择）
#--------------------------------------------------------------------------
def skill_switch_condition
  return false if @skill.nil? || !@skill.is_a?(RPG::Skill)
  flag = false
  flg = false
  @skill.note.each_line { |line|
    flg = true  if line.include?("<特殊使用条件>")
    flg = false if line.include?("</特殊使用条件>")
    next if line.include?("<特殊使用条件>") || line.include?("</特殊使用条件>")
    if flg
      a = line.split(/\s*,\s*/)
      flag = true if a[0] == "スイッチ" && a[1].to_i == 50
    end
  }
  return flag
end
#--------------------------------------------------------------------------
# ★ 读技能 note 中的前后排条件（关键字：前排、後排，不带尖括号）
#--------------------------------------------------------------------------
def skill_position_condition
  return nil if @skill.nil? || !@skill.is_a?(RPG::Skill)
  pos = nil
  @skill.note.each_line { |line|
    if line.include?("前排")
      pos = "front"
    elsif line.include?("後排")
      pos = "back"
    end
  }
  return pos
end

#--------------------------------------------------------------------------
# ★ 读武器 note 中是否含有“後排”字样（方式同技能 note）
#$data_weapons[@item.id].note
#--------------------------------------------------------------------------
def weapon_back_condition
  return false if @active_battler.nil? || !@active_battler.is_a?(Game_Actor) || @active_battler.weapon.nil?
  flag = false
  $game_actors[x_id].weapons[0].note.each_line { |line|
    flag = true if line.include?("後排")
  }
  return flag
end
  #--------------------------------------------------------------------------
  # ● 檢查敵人是否處於狀態 N
  #--------------------------------------------------------------------------
  def has_state_n?(enemy)
    return enemy.state?(13)  # N_STATE_ID 替換為實際的狀態 ID
  end
#--------------------------------------------------------------------------
  # ● 更新敵人目標選擇 (篩選符合條件的敵人)
  #--------------------------------------------------------------------------
  def refresh_enemy_target_members
  targets = $game_troop.existing_members.select { |enemy| enemy.exist? && !enemy.friendly? }

  # 優先篩選狀態 N 的敵人
  state_n_targets = targets.select { |enemy| has_state_n?(enemy) }
  unless state_n_targets.empty?
    @target_members = state_n_targets
    return  # 若有狀態 N 的敵人，直接結束
  end

  # 檢查是否有前排敵人
  #front_row_enemies = targets.select { |enemy| enemy_position(enemy) == "front" }

  # 若有前排敵人，只選擇前排敵人
  #unless front_row_enemies.empty?
  #  @target_members = front_row_enemies
  #  return
  #end

  # 若沒有前排敵人，則選擇所有敵人
  #@target_members = targets
end


end
  
