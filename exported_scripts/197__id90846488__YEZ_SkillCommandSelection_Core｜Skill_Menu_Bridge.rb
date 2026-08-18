#==============================================================================
# 【Forest Symphony｜繁體中文完整說明】
#------------------------------------------------------------------------------
# 腳本：YEZ_SkillCommandSelection_Core｜Skill Menu Bridge
# 【來源】Yanfly Engine Zealous - Skill Command Selection，最後更新 2010-01-28。
# 【用途】重製 Scene_Skill，將「查看技能／學習技能／技能升級／被動／Mastery」等 YEZ 系統集中到同一技能選單；本專案主要啟用 view_skills、learn_skill、level_skill。
# 【設定】`YEZ::SKILL::COMMANDS` 決定指令順序；`CENTERED_COMMAND=true`；`VOCAB` 決定指令文字。目前 equip_state/learn_state/mastery 被註解，不顯示。
# 【相容依賴】會依 `$imported["JobSystemBase"]`、`StatusCommandMenu`、`JobSystemSkillLevels`、Passives、WeaponMasterySkills 決定 Window／Command。這是一個 Bridge，不是 Skill Cost 或 Skill Activation 最終 Authority。
# 【Debug】原版在 `$TEST/$BTEST` 下部分流程使用 F5 回復 MP；Equipment Overhaul 等頁也使用 F5～F8，因此未來 FS 自動測試快捷鍵不能直接搶這些按鍵。
# 【UI 素材】Graphics/System/Menu_TargetWindow、MenuBack_skill；Cache.menu 使用 Skill01～Skill03；另有既有 Menu mask／圖層相容。
# 【Load Order】重寫 Scene_Skill#start 並 alias initialize；後方 Skill Cost、Job Level、FS Equip/Skill Patch 都可能接續。移動前必須做完整 Skill Menu 回歸。
# 【呼叫】由主選單 Scene_Skill 自動使用，無額外事件 API。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 21 Archive 另保存修改前 byte-exact 原稿。
# 4. 本輪除 Friendly Monsters GoldFix 回寫外，只整理文件／架構標記；其餘 Runtime code 與載入順序不得因翻譯改變。
#==============================================================================
#===============================================================================
# 
# 最後更新：2010.01.28
# 
# 
#===============================================================================
# 更新紀錄
# -----------------------------------------------------------------------------
#===============================================================================
# 使用方式
# -----------------------------------------------------------------------------
# 
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# 
#===============================================================================
# 相容性
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
#===============================================================================

$imported = {} if $imported == nil
$imported["SkillCommandSelection"] = true

module YEZ
  module SKILL
    
    #===========================================================================
    # 基本設定
    # --------------------------------------------------------------------------
    #===========================================================================
    
    COMMANDS =[
      :view_skills, # 詳見頁首繁中說明
      :learn_skill, # 詳見頁首繁中說明
      :level_skill, # 詳見頁首繁中說明
    #  :equip_state, # 需要 Job System: Passives
    #  :learn_state, # 需要 Job System: Passives
    # :mastery,     # 需要 Weapon Mastery Skills
    ] # 詳見頁首繁中說明
    
    CENTERED_COMMAND = true
    
    VOCAB ={
      :view_skills => "",
      :equip_state => "Add Passive",
      :learn_skill => "",
      :level_skill => "",
    } # 詳見頁首繁中說明
    
  end # 詳見頁首繁中說明
end # 詳見頁首繁中說明

#===============================================================================
#===============================================================================

#===============================================================================
#===============================================================================

class Game_Temp
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  attr_accessor :scs_on
  attr_accessor :scs_oy
  
end # 詳見頁首繁中說明


#===============================================================================
#===============================================================================

class Window_Status_Actor_onSkills < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(160, 0, 384, 128)
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_face(@actor, 0, 0, size = 96)
    x = 104
    y = 0
    draw_actor_name(@actor, x, y)
    #draw_actor_class(@actor, x + 120, y)
    draw_actor_level(@actor, x, y + WLH * 1)
    draw_actor_state(@actor, x, y + WLH * 2)
    draw_actor_hp(@actor, x + 120, y + WLH * 1, 120)
    draw_actor_mp(@actor, x + 120, y + WLH * 2, 120)
  end
  
 
end # 詳見頁首繁中說明


#===============================================================================
#===============================================================================

class Scene_Skill < Scene_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias initialize_scs initialize unless $@
  def initialize(actor_index = 0, last_index = 0)
    initialize_scs(actor_index, last_index)
    @last_index = last_index
    $game_temp.scs_on = true
  end

  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start
    super
    @actor = $game_party.members[@actor_index]
    $game_party.last_actor_index = @actor_index
    @viewport = Viewport.new(0, 0, 544, 416)
    @help_window = Window_Helpxxx.new###
    @help_window.viewport = @viewport
    @help_window.y = 128 +11
    if $imported["JobSystemBase"]
      @status_window = Window_JP_Actor.new(@actor)
    elsif $imported["StatusCommandMenu"]
      @status_window = Window_Status_Actor_onSkills.new(@actor)
    else
      @status_window = Window_Skill_Actor.new(@actor)
    end
    @status_window.viewport = @viewport
    
    @target_window = Window_RipMenuStatus.new(0, 0)
    @target_window.visible = false
    @target_window.active = false
    @target_windowbg = Sprite.new
    @target_windowbg.bitmap = Cache.system("Menu_TargetWindow")
    @target_windowbg.visible = false
    @com_count = 11
    create_command_window
    create_menu_background
    hide_target_window
  end
  
  def create_menu_background
    @menuback_sprite.dispose if @menuback_sprite != nil
    @menuback_sprite2.dispose if @menuback_sprite2 != nil
    @menuback_sprite = Sprite.new
    @menuback_sprite.bitmap = Cache.system("MenuBack_skill")
    @menuback_sprite.z -= 1
    @status_window.opacity = 0
    @command_window.opacity = 0
    @help_window.opacity = 0
    @skill_window.opacity = 0
    #####################################################################
    @sprites = [] # 詳見頁首繁中說明
    images_name = # 詳見頁首繁中說明
    ["Skill01","Skill02","Skill03"]
    for i in 0...images_name.size
     @sprites[i] = Sprite.new
     @sprites[i].bitmap = Cache.menu(images_name[i])
     @sprites[i].x = (i * 6) + 26 if i <= 1
     @sprites[i].x = (i * 6) + 18 if i > 1
     @sprites[i].y = (i * 26) + 19
     @sprites[i].opacity = 255
     @sprites[i].z = 9999
     @sprites[i].tone = Tone.new(0,0,0,255)
     @sprites[i].zoom_x = @sprites[i].zoom_y = 1.0############
    end
    ####################################################################
    ####################################################################
    @mask = Sprite.new
    @mask.bitmap = Cache.system("MenuBack_mask")
    @mask.z = 999
    @light = Sprite.new
		@light.bitmap = Cache.picture("le.png")
		@light.visible = true
    @light.x = 407 # 詳見頁首繁中說明
    @light.y = -20 # 詳見頁首繁中說明
    @light.zoom_x = 200 / 100.0
    @light.zoom_y = 200 / 100.0
    @light.opacity = 100
    @light.tone = Tone.new(255,-100,-255, 0)
    @light.blend_type = 1
		@light.z = 1000
    
    @light2 = Sprite.new
		@light2.bitmap = Cache.picture("le.png")
		@light2.visible = true
    @light2.x = 8
    @light2.y = 13
    @light2.zoom_x = 150 / 100.0
    @light2.zoom_y = 55 / 100.0
    @light2.opacity = 70
    @light2.tone = Tone.new(200,200,100, 100)
    @light2.blend_type = 1
		@light2.z = 1000
    
    fireflies(5)
    ####################################################################

    update_menu_background
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @help_window.dispose if @help_window != nil
    @info_window.dispose if @info_window != nil###
    @status_window.dispose if @status_window != nil
    @target_window.dispose if @target_window != nil
    @command_window.dispose if @command_window != nil
    @learndata_window.dispose if @learndata_window != nil
    @leveldata_window.dispose if @leveldata_window != nil
    @class_window.dispose if @class_window != nil
    @classdata_window.dispose if @classdata_window != nil
    @stapas_window.dispose if @stapas_window != nil
    @eqpaslist_window.dispose if @eqpaslist_window != nil
    @eqpasstat_window.dispose if @eqpasstat_window != nil
    @lepasdata_window.dispose if @lepasdata_window != nil
    @clpasdata_window.dispose if @clpasdata_window != nil
    ##########
    for i in 0..2
      @sprites[i].dispose
    end
    @light.dispose
    @light2.dispose
    @mask.dispose
    fireflies(0)
    @viewport.dispose
    #########
    dispose_mini_windows
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_command_window
    commands = []; @data = []; @mini_windows = {}
    for command in YEZ::SKILL::COMMANDS
      case command
      when :view_skills
        @skill_window = Window_Skill.new(0, 184, 272, 232, @actor)
        @skill_window.viewport = @viewport
        @skill_window.help_window = @help_window
        @skill_window.active = false
        @info_window = Window_SkillInfo2.new###
        @info_window.viewport = @viewport###
        @skill_window.info_window = @info_window###
        @mini_windows[@data.size] = @skill_window
        commands.push(YEZ::SKILL::VOCAB[command])
        
      when :learn_skill
        next unless $imported["JobSystemBase"]
        next unless $game_switches[YEZ::JOB::LEARN_ENABLE_SWITCH]
        dy = @status_window.height + @help_window.height
        @learnskill_window = Window_LearnSkill.new(0, dy, @actor)
        @learndata_window = Window_LearnData.new(@learnskill_window.width,
          @learnskill_window.y, @learnskill_window.skill, @actor, @actor.class_id)
        @learnskill_window.help_window = @help_window
        @learnskill_window.active = false
        @mini_windows[@data.size] = @learnskill_window
        commands.push(YEZ::JOB::LEARN_TITLE)
        
      when :level_skill
        next unless $imported["JobSystemSkillLevels"]
        next unless $game_switches[YEZ::JOB::LEVEL_ENABLE_SWITCH]
        dy = @status_window.height + @help_window.height
        @levelskill_window = Window_LevelSkill.new(0, dy, @actor)
        @leveldata_window = Window_LevelData.new(@levelskill_window.width,
          @levelskill_window.y, @levelskill_window.skill, @actor, @actor.class_id)
        @levelskill_window.help_window = @help_window
        @levelskill_window.active = false
        @mini_windows[@data.size] = @levelskill_window
        commands.push(YEZ::JOB::LEVEL_TITLE)
        
      when :equip_state
        next unless $imported["JobSystemPassives"]
        next unless $game_switches[YEZ::JOB::ENABLE_PASSIVE_SWITCH]
        create_passive_windows
        @equippas_window = Window_PassiveEquip.new(0, @help_window.y +
          @help_window.height, @actor)
        @equippas_window.help_window = @help_window
        @eqpaslist_window = Window_PassiveEquipList.new(0, @equippas_window.y,
          @actor)
        @eqpaslist_window.help_window = @help_window
        @eqpasstat_window = Window_PassiveEquipStat.new(@eqpaslist_window.width,
          @eqpaslist_window.y, @actor)
        @mini_windows[@data.size] = @equippas_window
        commands.push(YEZ::SKILL::VOCAB[command])
        
      when :learn_state
        next unless $imported["JobSystemPassives"]
        next unless $game_switches[YEZ::JOB::ENABLE_PASSIVE_SWITCH]
        create_passive_windows
        @learnpas_window = Window_LearnPassive.new(0, @help_window.y +
          @help_window.height, @actor)
        @learnpas_window.help_window = @help_window
        @lepasdata_window = Window_LearnPassiveData.new(@learnpas_window.width,
        @learnpas_window.y, @learnpas_window.passive, @actor)
        @learnpas_window.active = false
        @clpasdata_window = Window_Class_PassiveInfo.new(@class_window.width, 
          @learnpas_window.y, @actor) if @class_window != nil
        @mini_windows[@data.size] = @learnpas_window
        commands.push(YEZ::SKILL::VOCAB[command])
        
      when :mastery
        next unless $imported["WeaponMasterySkills"]
        @mastery_window = Window_Mastery.new(0, 128, @actor, true)
        @mini_windows[@data.size] = @mastery_window
        commands.push(YEZ::WEAPON_MASTERY::TITLE)
        
      else; next
      end
      @data.push(command)
    end
    if YEZ::SKILL::CENTERED_COMMAND
      @command_window = Window_Command_Centered.new(160, commands)
    else
      @command_window = Window_Command.new(160, commands)
    end
    @command_window.windowskin = Cache.windows("windowX")
    @command_window.height = 128
    @command_window.oy = $game_temp.scs_oy if $game_temp.scs_oy != nil
    @command_window.index = @last_index
    @command_window.active = true
    @command_window.viewport = @viewport
    update_mini_windows
    @help_window.contents.clear
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_mini_windows
    @last_index = @command_window.index
    @status_window.y = 0
    @class_window.y = 416*3 if @class_window != nil
    @classdata_window.y = @class_window.y if @classdata_window != nil
    @learndata_window.y = 416*3 if @learndata_window != nil
    @leveldata_window.y = 416*3 if @leveldata_window != nil
    @eqpaslist_window.y = 416*3 if @eqpaslist_window != nil
    @eqpasstat_window.y = 416*3 if @eqpasstat_window != nil
    @stapas_window.y = 416*3 if @stapas_window != nil
    @lepasdata_window.y = 416*3 if @lepasdata_window != nil
    @clpasdata_window.y = 416*3 if @clpasdata_window != nil
    class_id = @status_window.class
    for i in 0..(@mini_windows.size-1)
      @mini_windows[i].y = 416*3
    end
    case @mini_windows[@last_index]
    when @skill_window
      @help_window.visible = true
      @skill_window.refresh
      @mini_windows[@last_index].update_help
      @mini_windows[@last_index].y = @status_window.height
      @mini_windows[@last_index].y += @help_window.height if @help_window.visible
    when @learnskill_window
      @help_window.visible = true
      if @class_window != nil
        @class_window.y = @status_window.height + @help_window.height
        @classdata_window.y = @class_window.y
        @class_window.update_help
        return
      end
      @learnskill_window.refresh(class_id)
      @learndata_window.y = @status_window.height + @help_window.height
      @learndata_window.refresh(@learnskill_window.skill, @status_window.class)
      @mini_windows[@last_index].update_help
      @mini_windows[@last_index].y = @status_window.height
      @mini_windows[@last_index].y += @help_window.height if @help_window.visible
    when @levelskill_window
      @help_window.visible = true
      if @class_window != nil
        @class_window.y = @status_window.height + @help_window.height
        @classdata_window.y = @class_window.y
        @class_window.update_help
        return
      end
      @levelskill_window.refresh(class_id)
      @leveldata_window.y = @status_window.height + @help_window.height
      @leveldata_window.refresh(@levelskill_window.skill, @status_window.class)
      @mini_windows[@last_index].update_help
      @mini_windows[@last_index].y = @status_window.height
      @mini_windows[@last_index].y += @help_window.height if @help_window.visible
    when @equippas_window
      @equippas_window.refresh
      @stapas_window.refresh
      @eqpasstat_window.refresh
      @help_window.visible = true
      @stapas_window.y = 0
      @status_window.y = 416*3
      @equippas_window.y = @help_window.height + @help_window.y
      @eqpasstat_window.y = @equippas_window.y
      @equippas_window.update_help
    when @learnpas_window
      @learnpas_window.refresh(@stapas_window.class)
      @help_window.visible = true
      @stapas_window.y = 0
      @status_window.y = 416*3
      if @class_window != nil
        @class_window.y = @status_window.height + @help_window.height
        @clpasdata_window.y = @class_window.y
        @class_window.update_help
        return
      end
      @learnpas_window.y = @help_window.height + @help_window.y
      @lepasdata_window.y = @learnpas_window.y
      @learnpas_window.update_help
      
    when @mastery_window
      @help_window.visible = false
      @mini_windows[@last_index].y = @status_window.height
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def dispose_mini_windows
    for i in 0..(@mini_windows.size-1)
      next if @mini_windows[i] == nil
      @mini_windows[i].dispose
      @mini_windows[i] = nil
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh_windows(class_id = nil)
    @status_window.refresh(class_id) if @status_window != nil
    @class_window.refresh if @class_window != nil
    @classdata_window.refresh(class_id) if @classdata_window != nil
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def old_refresh_windows(class_id = nil)
    @status_window.refresh(class_id) if @status_window != nil
    @skill_window.refresh if @skill_window != nil
    @class_window.refresh if @class_window != nil
    @classdata_window.refresh(class_id) if @classdata_window != nil
    @learnskill_window.refresh(class_id) if @learnskill_window != nil
    @levelskill_window.refresh(class_id) if @levelskill_window != nil
    @equippas_window.refresh if @equippas_window != nil
    @stapas_window.refresh if @stapas_window != nil
    @eqpasstat_window.refresh if @eqpasstat_window != nil
    @learnpas_window.refresh(@stapas_window.class) if @learnpas_window != nil
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias return_scene_scs return_scene
  def return_scene
    $game_temp.scs_oy = nil
    $game_temp.scs_on = nil
    return_scene_scs
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def next_actor
    $game_temp.scs_oy = @command_window.oy
    @actor_index += 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Skill.new(@actor_index, @last_index)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def prev_actor
    $game_temp.scs_oy = @command_window.oy
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Skill.new(@actor_index, @last_index)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @help_window.update
      @target_windowbg.visible = false
    if @command_window.active
      update_command_selection
    elsif @subskill_window != nil and @subskill_window.active
      update_subskill_window
    elsif @learnskill_window != nil and @learnskill_window.active
      update_learnskill_selection
    elsif @levelskill_window != nil and @levelskill_window.active
      update_levelskill_selection
    elsif @equippas_window != nil and @equippas_window.active
      update_equippas_selection
    elsif @eqpaslist_window != nil and @eqpaslist_window.active
      update_equiplist_selection
    elsif @learnpas_window != nil and @learnpas_window.active
      update_learnpassive_selection
    elsif @class_window != nil and @class_window.active
      update_class_selection
    elsif @skill_window.active
      @skill_window.update
      update_skill_selection
    elsif @target_window.active
      @target_windowbg.visible = true
      @target_window.update
      update_target_selection
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_command_selection
    @info_window.visible = true if @command_window.index == 0
    @info_window.visible = false if @command_window.index == 1
    @info_window.visible = false if @command_window.index == 2
     
    @help_window.set_text("查看目前擁有的技能") if @command_window.index == 0
    @help_window.set_text("運用JP來學習新的技能") if @command_window.index == 1
    @help_window.set_text("運用JP來升級已擁有的技能") if @command_window.index == 2
    ################################
    for i in 0..2
      @sprites[i].tone = Tone.new(0,0,0,255)
      @sprites[i].y = (i * 26) + 19 # 詳見頁首繁中說明
    end
    @sprites[@command_window.index].tone = Tone.new(0,0,0)
    @com_count = 0 if Input.trigger?(Input::UP)
    @com_count = 0 if Input.trigger?(Input::DOWN)
    @sprites[@command_window.index].color.set(255, 255, 255, 0) if Input.trigger?(Input::UP)
      @sprites[@command_window.index].color.set(255, 255, 255, 0) if Input.trigger?(Input::DOWN)
      @sprites[@command_window.index].y = (@command_window.index * 26) + 19 if Input.trigger?(Input::UP)
      @sprites[@command_window.index].y = (@command_window.index * 26) + 19 if Input.trigger?(Input::DOWN)
    if @com_count <= 10
      @sprites[@command_window.index].color.set(255, 255, 255, 0) if @com_count == 9
      @sprites[@command_window.index].color.set(200, 255, 255, 160) if @com_count == 4
      @sprites[@command_window.index].y += 3 if @com_count == 9
      @sprites[@command_window.index].y -= 3 if @com_count == 0
      @com_count +=1
    end
#################################################
################################
    @mask.visible = true if @command_window.active###
    
    @light.opacity = rand(20) + 90
    @light.x = 407 + rand(3) - 3
    @light.y = -20 + rand(3) - 3
    
    
    @light2.opacity = rand(40) + 70
     @light2.x = (@command_window.index * 6) + 8 if @command_window.index <= 1
     @light2.x = (@command_window.index * 6) + 0 if @command_window.index > 1
    @light2.y = (@command_window.index * 26) + 13
    ################################

    @command_window.update
    update_mini_windows if @last_index != @command_window.index
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif $TEST and Input.trigger?(Input::F5) # 詳見頁首繁中說明
      Sound.play_recovery
      @actor.mp += @actor.maxmp
      @status_window.refresh
      @skill_window.refresh if @skill_window.visible
    elsif Input.repeat?(Input::RIGHT)
      Sound.play_cursor
      next_actor
    elsif Input.repeat?(Input::LEFT)
      Sound.play_cursor
      prev_actor
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      @sprites[@command_window.index].color.set(200, 255, 255, 160)
      @sprites[@command_window.index].y = (@command_window.index * 26) + 19
      @mask.visible = false
      case @data[@command_window.index]
      when :view_skills
        @command_window.active = false
        @skill_window.active = true
        @info_window.visible = true
      when :mastery
        $scene = Scene_Mastery.new(@actor_index, @command_window.index)
      when :learn_skill
        @info_window.visible =false
        if @class_window != nil
          @command_window.active = false
          @class_window.active = true
        else
          start_learnskill_selection
        end
      when :level_skill
        @info_window.visible =false
        if @class_window != nil
          @command_window.active = false
          @class_window.active = true
        else
          start_levelskill_selection
        end
      when :equip_state
        Sound.play_decision
        @command_window.active = false
        @equippas_window.active = true
      when :learn_state
        if @class_window != nil
          @command_window.active = false
          @class_window.active = true
        else
          start_learn_passives
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_skill_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @skill_window.active = false
      @sprites[@command_window.index].color.set(255, 255, 255, 0)
      @sprites[@command_window.index].y = (@command_window.index * 26) + 19
    elsif $TEST and Input.trigger?(Input::F5) # 詳見頁首繁中說明
      Sound.play_recovery
      @actor.mp += @actor.maxmp
      @status_window.refresh
      @skill_window.refresh
    elsif Input.trigger?(Input::C)
      @skill = @skill_window.skill
      if @skill != nil
        @actor.last_skill_id = @skill.id
      end
      if @actor.skill_can_use?(@skill)
        Sound.play_decision
        determine_skill
      else
        Sound.play_buzzer
      end
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_class_selection
    @class_window.update
    if @class_window.class != @status_window.class
      @status_window.refresh(@class_window.class)
      @stapas_window.refresh(@class_window.class) if @stapas_window != nil
      @classdata_window.refresh(@class_window.class)
      @clpasdata_window.refresh(@class_window.class) if @clpasdata_window != nil
    end
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @class_window.active = false
    elsif Input.repeat?(Input::F8) and $TEST # 詳見頁首繁中說明
      Sound.play_equip
      value = YEZ::JOB::JP_COST * 10
      value *= 10 if Input.press?(Input::SHIFT)
      for class_id in @actor.all_unlocked_classes
        @actor.gain_jp(value + rand(value), class_id)
      end
      @class_window.refresh
      @status_window.refresh(@class_window.class)
    elsif Input.repeat?(Input::F7) and $TEST # 詳見頁首繁中說明
      Sound.play_equip
      value = YEZ::JOB::JP_COST * 10
      value *= 10 if Input.press?(Input::SHIFT)
      for class_id in @actor.all_unlocked_classes
        @actor.lose_jp(value + rand(value), class_id)
      end
      @class_window.refresh
      @status_window.refresh(@class_window.class)
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      refresh_windows(@status_window.class)
      class_id = @status_window.class
      case @data[@command_window.index]
      when :learn_skill
        start_learnskill_selection
        @learnskill_window.refresh(class_id)
        @learndata_window.y = @status_window.height + @help_window.height
        @learndata_window.refresh(@learnskill_window.skill, @status_window.class)
      when :level_skill
        start_levelskill_selection
        @levelskill_window.refresh(class_id)
        @leveldata_window.y = @status_window.height + @help_window.height
        @leveldata_window.refresh(@levelskill_window.skill, @status_window.class)
      when :learn_state
        start_learn_passives
        @learnpas_window.refresh(@stapas_window.class)
        @clpasdata_window.y = 416*3 if @clpasdata_window != nil
      end
      @class_window.y = 416*3
      @classdata_window.y = @class_window.y
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_passive_windows
    return if @stapas_window != nil
    @stapas_window = Window_Passive_Actor.new(@actor)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_equippas_selection
    @equippas_window.update
    if @equip_index != @equippas_window.index
      @equip_index = @equippas_window.index
    end
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @command_window.active = true
      @equippas_window.active = false
    elsif Input.trigger?(Input::C) or ($TEST and Input.trigger?(Input::F5))
      if @equip_index <= @equippas_window.auto_size - 1
        Sound.play_buzzer
        return
      end
      Sound.play_decision
      @equippas_window.active = false
      @equippas_window.y = 416*3
      @eqpaslist_window.active = true
      @eqpaslist_window.y = @help_window.height + @stapas_window.height
      @eqpaslist_window.refresh(@equippas_window.passive)
      @eqpasstat_window.y = @help_window.height + @stapas_window.height
      refresh_equipstat_window
      @eqpaslist_window.update_help
    elsif Input.trigger?(Input::X)
      if @equip_index <= @equippas_window.auto_size - 1
        Sound.play_buzzer
        return
      end
      return if @equippas_window.passive == nil
      Sound.play_equip
      slot = @equippas_window.index - @equippas_window.auto_size
      passive = 0
      last_hp = @actor.maxhp
      last_mp = @actor.maxmp
      @actor.equip_passive(passive, slot)
      @actor.hp += @actor.maxhp - last_hp
      @actor.mp += @actor.maxmp - last_mp
      @equippas_window.refresh
      @equippas_window.update_help
      @stapas_window.refresh
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh_equipstat_window
    @equiplist_last_index = @eqpaslist_window.index
    passive = @eqpaslist_window.passive
    slot = @equippas_window.index - @equippas_window.auto_size
    if passive == @equippas_window.passive or passive == nil
      passive = 0 
    elsif @actor.equipped_passives.include?(passive.id)
      passive = @actor.equipped_passives[slot]
    end
    @eqpasstat_window.refresh(passive, slot)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_equiplist_selection
    @eqpaslist_window.update
    refresh_equipstat_window if @equiplist_last_index != @eqpaslist_window.index
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @equippas_window.active = true
      @equippas_window.y = @help_window.height + @stapas_window.height
      @eqpaslist_window.active = false
      @eqpaslist_window.y = 416*3
      refresh_windows
      @equippas_window.refresh
      @equippas_window.update_help
    elsif $TEST and Input.repeat?(Input::F5) # 詳見頁首繁中說明
      Sound.play_equip
      passive = @eqpaslist_window.passive
      slot = @equippas_window.index - @equippas_window.auto_size
      passive = 0 if passive == nil or passive == @equippas_window.passive
      last_hp = @actor.maxhp
      last_mp = @actor.maxmp
      @actor.equip_passive(passive, slot)
      @actor.hp += @actor.maxhp - last_hp
      @actor.mp += @actor.maxmp - last_mp
      @equippas_window.active = true
      @equippas_window.y = @help_window.height + @stapas_window.height
      @eqpaslist_window.active = false
      @eqpaslist_window.y = 416*3
      refresh_windows
      @equippas_window.refresh
      @stapas_window.refresh
      @eqpasstat_window.refresh
      @equippas_window.update_help
    elsif Input.trigger?(Input::C)
      passive = @eqpaslist_window.passive
      if passive != nil and !@eqpaslist_window.enabled_passive?(passive)
        Sound.play_buzzer
        return
      end
      Sound.play_equip
      slot = @equippas_window.index - @equippas_window.auto_size
      passive = 0 if passive == nil or passive == @equippas_window.passive
      last_hp = @actor.maxhp
      last_mp = @actor.maxmp
      @actor.equip_passive(passive, slot)
      @actor.hp += @actor.maxhp - last_hp
      @actor.mp += @actor.maxmp - last_mp
      @equippas_window.active = true
      @equippas_window.y = @help_window.height + @stapas_window.height
      @eqpaslist_window.active = false
      @eqpaslist_window.y = 416*3
      refresh_windows
      @equippas_window.refresh
      @stapas_window.refresh
      @eqpasstat_window.refresh
      @equippas_window.update_help
    elsif Input.trigger?(Input::X)
      Sound.play_equip
      slot = @equippas_window.index - @equippas_window.auto_size
      passive = 0
      last_hp = @actor.maxhp
      last_mp = @actor.maxmp
      @actor.equip_passive(passive, slot)
      @actor.hp += @actor.maxhp - last_hp
      @actor.mp += @actor.maxmp - last_mp
      @equippas_window.active = true
      @equippas_window.y = @help_window.height + @stapas_window.height
      @eqpaslist_window.active = false
      @eqpaslist_window.y = 416*3
      refresh_windows
      @equippas_window.refresh
      @stapas_window.refresh
      @eqpasstat_window.refresh
      @equippas_window.update_help
    end
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start_learn_passives
    @learnpas_window.y = @help_window.height + @stapas_window.height
    @learnpas_window.active = true
    @lepasdata_window.y = @help_window.height + @stapas_window.height
    @lepasdata_window.refresh(@learnpas_window.passive, @stapas_window.class)
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_learnpassive_selection
    @learnpas_window.update
    if @last_learn_index != @learnpas_window.index
      @last_learn_index = @learnpas_window.index
      @lepasdata_window.refresh(@learnpas_window.passive, @stapas_window.class)
    end
    if Input.trigger?(Input::B)
      Sound.play_cancel
      if @class_window != nil
        @class_window.y = @learnpas_window.y
        @class_window.active = true
        @class_window.update_help
        @clpasdata_window.y = @class_window.y
        @learnpas_window.active = false
        @learnpas_window.y = 416*3
        @lepasdata_window.y = 416*3
      else
        @learnpas_window.active = false
        @command_window.active = true
      end
    elsif $TEST and Input.repeat?(Input::F8) # 詳見頁首繁中說明
      Sound.play_equip
      value = YEZ::JOB::DEFAULT_PASSIVE_JP_COST * 10
      value *= 10 if Input.press?(Input::SHIFT)
      @actor.gain_jp(value + rand(value), @stapas_window.class)
      @stapas_window.refresh
      @equippas_window.refresh if @equippas_window != nil
      @lepasdata_window.refresh(@learnpas_window.passive, @stapas_window.class)
      @class_window.refresh if @class_window != nil
      @learnpas_window.refresh
    elsif $TEST and Input.repeat?(Input::F7) # 詳見頁首繁中說明
      Sound.play_equip
      value = YEZ::JOB::DEFAULT_PASSIVE_JP_COST * 10
      value *= 10 if Input.press?(Input::SHIFT)
      @actor.lose_jp(value + rand(value), @stapas_window.class)
      @stapas_window.refresh
      @equippas_window.refresh if @equippas_window != nil
      @lepasdata_window.refresh(@learnpas_window.passive, @stapas_window.class)
      @class_window.refresh if @class_window != nil
      @learnpas_window.refresh
    elsif $TEST and Input.repeat?(Input::F5) # 詳見頁首繁中說明
      passive = @learnpas_window.passive
      return if passive == nil
      YEZ::JOB::LEARN_SOUND.play
      @actor.learn_passive(passive)
      @stapas_window.refresh
      @learnpas_window.refresh
      @equippas_window.refresh if @equippas_window != nil
      @lepasdata_window.refresh(passive, @stapas_window.class)
      @clpasdata_window.refresh(@class_window.class) if @clpasdata_window != nil
    elsif Input.trigger?(Input::C)
      passive = @learnpas_window.passive
      if passive == nil or !@learnpas_window.enabled_state?(passive)
        Sound.play_buzzer
        return
      end
      YEZ::JOB::LEARN_SOUND.play
      @actor.learn_passive(passive)
      @actor.lose_jp(passive.jp_cost, @stapas_window.class)
      @stapas_window.refresh
      @learnpas_window.refresh
      @equippas_window.refresh if @equippas_window != nil
      @lepasdata_window.refresh(passive, @stapas_window.class)
      @clpasdata_window.refresh(@class_window.class) if @clpasdata_window != nil
    end
  end
  
end # 詳見頁首繁中說明

#===============================================================================
#===============================================================================

class Window_Command_Centered < Window_Command
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def draw_item(index, enabled = true)
    rect = item_rect(index)
    rect.x += 4
    rect.width -= 8
    self.contents.clear_rect(rect)
    self.contents.font.color = normal_color
    self.contents.font.color.alpha = enabled ? 255 : 128
    self.contents.draw_text(rect, @commands[index], 1)
  end
  
end # 詳見頁首繁中說明

#===============================================================================
#===============================================================================

class Window_Skill_Actor < Window_Base
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(160, 0, 384, 128)
    @actor = actor
    refresh
  end
  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_face(@actor, 0, 0, size = 96)
    x = 104
    y = WLH / 2
    draw_actor_name(@actor, x, y)
    #draw_actor_class(@actor, x + 120, y)
    draw_actor_level(@actor, x, y + WLH * 1)
    draw_actor_state(@actor, x, y + WLH * 2)
    draw_actor_hp(@actor, x + 120, y + WLH * 1)
    draw_actor_mp(@actor, x + 120, y + WLH * 2)
  end
  
end # 詳見頁首繁中說明

#===============================================================================
# 
# 
#===============================================================================