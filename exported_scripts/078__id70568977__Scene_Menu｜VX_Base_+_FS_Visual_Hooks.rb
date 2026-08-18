#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：Scene_Menu｜VX Base + FS Visual Hooks
# 【用途】主選單 Scene 的基礎流程：建立六個標準指令、金錢視窗、角色狀態視窗，並處理 Item／Skill／Equip／Status／Save／End 的分流。
# 【選單順序】0 Item、1 Skill、2 Equip、3 Status、4 Save、5 End Game；Skill／Equip／Status 先進角色選擇，再建立對應 Scene。
# 【角色選擇】使用 Window_MenuStatus 與 `cursor` Character 素材顯示選擇游標；`$game_party.last_actor_index` 保存上次角色位置。
# 【禁用條件】隊伍為空時 Item/Skill/Equip/Status 禁用；`$game_system.save_disabled` 時 Save 禁用。
# 【FS 視覺歷史】頁內仍有一段 `=begin...=end` 的 menu01～menu08 背景切換舊實驗碼，正常 Runtime 不執行；目前不要因素材名稱出現在停用碼就判定一定在用。
# 【Load Order】這是早期 Scene_Menu 基礎層；後方 YEM Main Menu、FFXIII Layout、FS Menu/UI Patch 會再重開 Scene_Menu。不要把本頁當現行 Menu 最終 Authority，也不要隨意移到後面。
# 【呼叫】一般由 Scene_Map／引擎選單入口自動切換；外部腳本可 `$scene = Scene_Menu.new(index)`，但正式事件應優先沿既有選單流程。
# 【相關素材】`Graphics/Characters/cursor`；頁內停用歷史碼另提及 Graphics/System/menus/menu01～menu08。
# 【來源】RPG Maker VX Scene_Menu 基礎流程，專案內有 FS 視覺修改。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 21 Archive 另保存修改前 byte-exact 原稿。
# 4. 本輪除 Friendly Monsters GoldFix 回寫外，只整理文件／架構標記；其餘 Runtime code 與載入順序不得因翻譯改變。
#==============================================================================
#==============================================================================
#------------------------------------------------------------------------------
#==============================================================================

class Scene_Menu < Scene_Base
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    create_command_window
    @gold_window = Window_Gold.new(0, 360)
    @status_window = Window_MenuStatus.new(160, 0)
    @count = 0
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @command_window.dispose
    @gold_window.dispose
    @status_window.dispose
    for i in 0..7
      @sprites[i].dispose
    end
  end  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    #set_tone(@command_window.index)#####
    #set_tone(@command_window.index)
    @command_window.update
    @gold_window.update
    @status_window.update
=begin
       #-----------------------
    if @command_window.index != @old_index
      case @command_window.index
      when 0
        if @pic_now != 0
          @command_window.contents = Bitmap.new("Graphics/System/menus/menu01")
          @pic_now = 0
          #@dummy_sprite.bitmap = Bitmap.new("Graphics/System/menu/底图_物品")
        end
      when 1
        if @pic_now != 1
          @command_window.contents = Bitmap.new("Graphics/System/menus/menu02")
          @pic_now = 1
         
        end
      when 2
        if @pic_now != 2
          @command_window.contents = Bitmap.new("Graphics/System/menus/menu03")
          @pic_now = 2
        end
      when 3
        if @pic_now != 3
          @command_window.contents = Bitmap.new("Graphics/System/menus/menu04")
          @pic_now = 3
        end
      when 4
        if @pic_now != 4
          @command_window.contents = Bitmap.new("Graphics/System/menus/menu05")
          @pic_now = 4
        end
      when 5
        if @pic_now != 5
          @command_window.contents = Bitmap.new("Graphics/System/menus/menu06")
          @pic_now = 5
        end
      when 6
        if @pic_now != 6
          @command_window.contents = Bitmap.new("Graphics/System/menus/menu07")
          @pic_now = 6
        end
      when 7
        if @pic_now != 7
          @command_window.contents = Bitmap.new("Graphics/System/menus/menu08")
          @pic_now = 7
        end
      end
      @old_index = @command_window.index
    end
    #----------------------
=end
    if @command_window.active
      update_command_selection
    elsif @status_window.active
      update_actor_selection
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_command_window
    s1 = Vocab::item
    s2 = Vocab::skill
    s3 = Vocab::equip
    s4 = Vocab::status
    s5 = Vocab::save
    s6 = Vocab::game_end
    @command_window = Window_Command.new(160, [s1, s2, s3, s4, s5, s6])
    @command_window.index = @menu_index
    if $game_party.members.size == 0 # 詳見頁首繁中說明
      @command_window.draw_item(0, false) # 詳見頁首繁中說明
      @command_window.draw_item(1, false) # 詳見頁首繁中說明
      @command_window.draw_item(2, false) # 詳見頁首繁中說明
      @command_window.draw_item(3, false) # 詳見頁首繁中說明
    end
    if $game_system.save_disabled # 詳見頁首繁中說明
      @command_window.draw_item(4, false) # 詳見頁首繁中說明
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      if $game_party.members.size == 0 and @command_window.index < 4
        Sound.play_buzzer
        return
      elsif $game_system.save_disabled and @command_window.index == 4
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      case @command_window.index
      when 0 # 詳見頁首繁中說明
        $scene = Scene_Item.new
      when 1,2,3 # 詳見頁首繁中說明
        start_actor_selection
      when 4 # 詳見頁首繁中說明
        $scene = Scene_File.new(true, false, false)
      when 5 # 詳見頁首繁中說明
        $scene = Scene_End.new
      end
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start_actor_selection
    @command_window.active = false
    @status_window.active = true
    #####
    @cursor = Sprite.new
    @cursor.bitmap = Cache.character("cursor")
    @cursor.src_rect.set(0, 0, 32, 32)
    @cursor_flame = 0
    @as_flame = 0
    @cursor.x = -200
    @cursor.y = 90
    @cursor.ox = @cursor.width
    @cursor.oy = @cursor.height
    @cursor.z = 9999
    #####
      @as = Sprite.new
      @as.y = 69
      @as.ox = @as.width
      @as.oy = @as.height
      @as.z = 9999
    ######
    if $game_party.last_actor_index < @status_window.item_max
      @status_window.index = $game_party.last_actor_index
    else
      @status_window.index = 0
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def end_actor_selection
    @command_window.active = true
    @sprites[@command_window.index].color.set(255, 255, 255, 0)###
    @status_window.active = false
    @status_window.index = -1
    @cursor.x = -200
    @cursor.dispose
    @as.dispose
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_actor_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_actor_selection
    elsif Input.trigger?(Input::C)
      $game_party.last_actor_index = @status_window.index
      Sound.play_decision
      case @command_window.index
      when 1 # 詳見頁首繁中說明
        $scene = Scene_Skill.new(@status_window.index)
      when 2 # 詳見頁首繁中說明
        $scene = Scene_Equip.new(@status_window.index)
      when 3 # 詳見頁首繁中說明
        $scene = Scene_Status.new(@status_window.index)
      end
    end
  end
end
