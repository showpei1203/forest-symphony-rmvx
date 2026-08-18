#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：BattleCommandVisual_Compat｜Legacy Spin Disabled
# 【來源】原頁包含 ziifee Tankentai ATB Spin Command 的歷史版本，以及 FS 後續實際啟用的 Battle Command 視覺相容碼。
# 【重要現況】原 `Window_SpinCommand / Window_ActorCommand` Spin 實作整段被 `=begin ... =end` 停用，正常 Runtime 不會執行；Phase 20 將該停用原碼移出正式 Script Page，完整 byte-exact 原稿保留於 Archive。
# 【目前真正執行】只保留 `Window_BattleStatus` 的舊式狀態窗 override，以及 `Scene_Battle#update_actor_command_selection` 的 5 個指令圖示顯示／輸入流程。這頁因此不是 Spin Command Core，也不是 BattleStatusHUD_Core。
# 【指令順序】active Scene_Battle 以 index 0攻擊、1技能、2防禦、3物品、4逃跑處理；角色 ID>=7 時會禁止 Item。逃跑仍檢查 `$game_troop.can_escape`。
# 【相關素材】目前 active code 直接讀 `Graphics/Menu/Battle01..Battle05.png` 與 `Battle01a..Battle05a.png`，專案 ZIP 已確認十張皆存在。歷史 Spin40 僅存在已停用原碼，Phase 20 後不再是本頁 Runtime 素材依賴。
# 【Load Order】它直接重定義 `Scene_Battle#update_actor_command_selection`，必須維持目前已驗證位置；後方 Tankentai/ATB/FS Targeting 仍可能包裝相關流程。不要因名稱含「Compat」就搬到所有戰鬥腳本最後。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 20 Archive 另保存修改前 byte-exact 原稿。
# 4. 除 EnemySummon SafePosition 責任回寫外，本輪只整理文件／註解；其他 Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#==============================================================================
#==============================================================================

class Window_BattleStatus
  #--------------------------------------------------------------------------
  # œ ƒIƒuƒWƒFƒNƒg‰Šú‰» ‰ü
  #--------------------------------------------------------------------------
  def initialize
    super(128, 0+30, 416, 544)#128
    @column_max = 3
    refresh
    self.active = false
    self.opacity = 0
  end
  #--------------------------------------------------------------------------
  # œ €–Ú‚Ì•`‰æ ‰ü
  #--------------------------------------------------------------------------
  def draw_item(index)
    x = index * 96#(i * 139) + 40
    rect = Rect.new(x, 0, 96, 96)
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    actor = $game_party.members[index]
    draw_actor_face(actor, x + 2, 2, 92)
    draw_actor_state(actor, x + 72, WLH * 3)
    self.contents.font.color = hp_color(actor)
    size = 18
    self.contents.font.size = size
    self.contents.draw_text(x, WLH * 1 + 20 - size, 80, WLH, actor.name)
    self.contents.font.size = 20
    draw_actor_hp(actor, x, WLH * 2, 80)
    draw_actor_mp(actor, x, WLH * 3, 70)
  end
  #--------------------------------------------------------------------------
  # œ ƒJ[ƒ\ƒ‹‚ÌXV
  #--------------------------------------------------------------------------
  def update_cursor
    self.cursor_rect.empty
   # if @index < 0               # 無光標
   # elsif @index < @item_max    # 正常狀態
   #   self.cursor_rect.set(index * 139, 0, 96, 128)
  end
end

#******************************************************************************
# š ƒAƒNƒeƒBƒuƒ^ƒCƒ€‰ü‘¢•”
#******************************************************************************

#==============================================================================
#==============================================================================
class Scene_Battle
  #--------------------------------------------------------------------------
  # 攻擊 技能 防禦 物品
  #--------------------------------------------------------------------------
  def update_actor_command_selection
    
    ################################
    for i in 0..4
      @sprites[i].tone = Tone.new(0,0,0,255)
      @sprites[i].y = (i*44) +230
      @sprites[i].y -= i*7
      @sprites[i].y -= 2 if i == 2
      @sprites[i].y -= 8 if i == 3
      @sprites[i].y -= 18 if i == 4
      @sprites[i].color.set(255, 255, 255, 0) if Input.trigger?(Input::UP)
      @sprites[i].color.set(255, 255, 255, 0) if Input.trigger?(Input::DOWN)
    end
    
    @sprites[@actor_command_window.index].tone = Tone.new(0,0,0)
    images2 = # 詳見頁首繁中說明
    ["Battle01","Battle02","Battle03","Battle04","Battle05"]
    images1 = # 詳見頁首繁中說明
    ["Battle01a","Battle02a","Battle03a","Battle04a","Battle05a"]
    for i in 0..4
      if i == @actor_command_window.index
       @sprites[i].bitmap = Cache.menu(images2[i])
      else
       @sprites[i].bitmap = Cache.menu(images1[i])
      end
    end
    @com_count = 0 if Input.trigger?(Input::UP)
    @com_count = 0 if Input.trigger?(Input::DOWN)
    if @com_count <= 10
      @sprites[@actor_command_window.index].color.set(255, 255, 255, 0) if @com_count == 9
      @sprites[@actor_command_window.index].color.set(200, 255, 255, 160) if @com_count == 4
      @sprites[@actor_command_window.index].y += 3 if @com_count == 9
      @sprites[@actor_command_window.index].y -= 3 if @com_count == 0
      @com_count +=1
    end
#################################################
  #  x = $game_party.members[@commander.index] if @actor_command_window_on
  #  x_id = x.instance_variable_get(:@actor_id) if @actor_command_window_on
    
    # ƒRƒ}ƒ“ƒh“ü—Í‚Å‚«‚éó‘Ô‚Å‚È‚­‚È‚ê‚ÎƒLƒƒƒ“ƒZƒ‹
    return reset_command unless commanding?
    ###
    if Input.trigger?(Input::UP) && @text_sprites
    @selected_command_index = (@selected_command_index - 1) % @text_sprites.size
    update_text_command_opacity
    elsif Input.trigger?(Input::DOWN) && @text_sprites
    @selected_command_index = (@selected_command_index + 1) % @text_sprites.size
    update_text_command_opacity
    end
    ###
    if Input.trigger?(Input::C)
      @sprites[@actor_command_window.index].color.set(255, 255, 255, 0)
      Input.update
      case @actor_command_window.index
      when 0  # 攻擊
        Sound.play_decision
        @commander.action.set_attack
        start_target_enemy_selection
      when 1  # 技能
        Sound.play_decision
        $in_select = true
        start_skill_selection
      when 2  # 防禦
        Sound.play_decision
        @commander.action.set_guard
        end_command
      when 3  # 物品
        x = $game_party.members[@commander.index] if @actor_command_window_on
        x_id = x.instance_variable_get(:@actor_id) if @actor_command_window_on
        if x_id >= 7
          Sound.play_buzzer
          return
        end
        Sound.play_decision
        $in_select = true
        start_item_selection
      when 4  # 逃跑
        if $game_troop.can_escape == false
          Sound.play_buzzer
          return
        end
        Sound.play_decision
        process_escape
      end
    
    end
  end
end
