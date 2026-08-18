#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scene_Skill
# 【用途】VX 技能場景，顯示角色技能並處理選擇、使用與目標。
# 【主要機制】由 RGSS2 Scene 流程自動建立／更新；本專案後續 Menu／Battle／UI Patch 可能重開啟同類別。
# 【主要影響】Scene_Skill
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
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
# ** Scene_Skill
#------------------------------------------------------------------------------
#  這個類用來執行顯示技能畫面的程式。
#==============================================================================

class Scene_Skill < Scene_Base
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     actor_index : 主角編號
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
  end
  #--------------------------------------------------------------------------
  # * 程式開始
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @actor = $game_party.members[@actor_index]
    @viewport = Viewport.new(0, 0, 544, 416)
    @help_window = Window_Help.new###
    #@help_window = Window_Helpxxx.new
    @help_window.viewport = @viewport
    @status_window = Window_SkillStatus.new(0, 56, @actor)
    @status_window.viewport = @viewport
    @skill_window = Window_Skill.new(0, 112, 544, 304, @actor)
    @skill_window.viewport = @viewport
    @skill_window.help_window = @help_window
    @target_window = Window_MenuStatus.new(0, 0)
    hide_target_window
  end
  #--------------------------------------------------------------------------
  # * 程式終止
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @help_window.dispose
    @status_window.dispose
    @skill_window.dispose
    @target_window.dispose
  end
  #--------------------------------------------------------------------------
  # * 返回之前的畫面
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Menu.new(1)
  end
  #--------------------------------------------------------------------------
  # * 切換畫面內容至下一個主角
  #--------------------------------------------------------------------------
  def next_actor
    @actor_index += 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Skill.new(@actor_index)
  end
  #--------------------------------------------------------------------------
  # * 切換畫面內容至上一個主角
  #--------------------------------------------------------------------------
  def prev_actor
    @actor_index += $game_party.members.size - 1
    @actor_index %= $game_party.members.size
    $scene = Scene_Skill.new(@actor_index)
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @help_window.update
    @status_window.update
    @skill_window.update
    @target_window.update
    if @skill_window.active
      update_skill_selection
    elsif @target_window.active
      update_target_selection
    end
  end
  #--------------------------------------------------------------------------
  # * 更新技能選擇指令輸入資訊
  #--------------------------------------------------------------------------
  def update_skill_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::R)
      Sound.play_cursor
      next_actor
    elsif Input.trigger?(Input::L)
      Sound.play_cursor
      prev_actor
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
  # * 判定技能是否可用
  #--------------------------------------------------------------------------
  def determine_skill
    if @skill.for_friend?
      show_target_window(@skill_window.index % 2 == 0)
      if @skill.for_all?
        @target_window.index = 99
      elsif @skill.for_user?
        @target_window.index = @actor_index + 100
      else
        if $game_party.last_target_index < @target_window.item_max
          @target_window.index = $game_party.last_target_index
        else
          @target_window.index = 0
        end
      end
    else
      use_skill_nontarget
    end
  end
  #--------------------------------------------------------------------------
  # * 更新目標選擇指令輸入資訊
  #--------------------------------------------------------------------------
  def update_target_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      hide_target_window
    elsif Input.trigger?(Input::C)
      if not @actor.skill_can_use?(@skill)
        Sound.play_buzzer
      else
        determine_target
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 判定技能是否可以施用於目標
  #    若無效（如施用增加HP的技能於瀕死者），播放“無效”SE。
  #--------------------------------------------------------------------------
  def determine_target
    used = false
    if @skill.for_all?
      for target in $game_party.members
        target.skill_effect(@actor, @skill)
        used = true unless target.skipped
      end
    elsif @skill.for_user?
      target = $game_party.members[@target_window.index - 100]
      target.skill_effect(@actor, @skill)
      used = true unless target.skipped
    else
      $game_party.last_target_index = @target_window.index
      target = $game_party.members[@target_window.index]
      target.skill_effect(@actor, @skill)
      used = true unless target.skipped
    end
    if used
      use_skill_nontarget
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示目標選擇視窗
  #     right : 視窗右對齊標幟（如果為false，則視窗左對齊）
  #--------------------------------------------------------------------------
  def show_target_window(right)
    @skill_window.active = false
    width_remain = 544 - @target_window.width
    @target_window.x = right ? width_remain : 0
    @target_window.visible = true
    @target_window.active = true
    if right
      @viewport.rect.set(0, 0, width_remain, 416)
      @viewport.ox = 0
    else
      @viewport.rect.set(@target_window.width, 0, width_remain, 416)
      @viewport.ox = @target_window.width
    end
  end
  #--------------------------------------------------------------------------
  # * 隱藏目標選擇視窗
  #--------------------------------------------------------------------------
  def hide_target_window
    @skill_window.active = true
    @target_window.visible = false
    @target_window.active = false
    @viewport.rect.set(0, 0, 544, 416)
    @viewport.ox = 0
  end
  #--------------------------------------------------------------------------
  # * 使用技能（技能效果應用目標為非我方單人）
  #--------------------------------------------------------------------------
  def use_skill_nontarget
    Sound.play_use_skill
    @actor.mp -= @actor.calc_mp_cost(@skill)
    @status_window.refresh
    @skill_window.refresh
    @target_window.refresh
    if $game_party.all_dead?
      $scene = Scene_Gameover.new
    elsif @skill.common_event_id > 0
      $game_temp.common_event_id = @skill.common_event_id
      $scene = Scene_Map.new
    end
  end
end
