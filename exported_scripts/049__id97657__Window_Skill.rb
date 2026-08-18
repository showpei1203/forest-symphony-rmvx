#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Window_Skill
# 【用途】UI／選單元件「Window_Skill」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Window_Skill
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
# ** Window_Skill
#------------------------------------------------------------------------------
#  本視窗顯示於技能畫面中，用來羅列可用技能清單。
#==============================================================================

class Window_Skill < Window_Selectable
  attr_accessor :info_window
  #--------------------------------------------------------------------------
  # * 物件初始化
  #     x      : 視窗X座標
  #     y      : 視窗Y座標
  #     width  : 視窗寬度
  #     height : 視窗高度
  #     actor  : 主角
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, actor)
    super(x, y, width, height)
    @actor = actor
    @column_max = 1
    self.index = 0
    @info_window = nil
    refresh
  end
  #--------------------------------------------------------------------------
  # * 獲取可用技能的資訊
  #--------------------------------------------------------------------------
  def skill
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # * 更新內容顯示
  #--------------------------------------------------------------------------
  def refresh
    @data = []
    for skill in @actor.skills
      @data.push(skill)
      if skill.id == @actor.last_skill_id
        self.index = @data.size - 1
      end
    end
    @item_max = @data.size
    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end
  #--------------------------------------------------------------------------
  # * 繪製條目
  #     index : 條目編號
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    skill = @data[index]
    if skill != nil
      rect.width -= 4
      enabled = @actor.skill_can_use?(skill)
      draw_item_name11(skill, rect.x, rect.y, enabled)
      self.contents.draw_text(rect, @actor.calc_mp_cost(skill), 2)
    end
  end
  #--------------------------------------------------------------------------
  # * 更新動態説明視窗內容資訊
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(skill == nil ? "" : skill.description)
    @info_window.refresh(skill) unless @info_window.nil?###
    #@help_window.contents.font.color = system_color
    #@help_window.contents.font.size = 14
    #@help_window.contents.draw_text(480,11, 20, 20, @actor.overdrive.to_s) if $game_temp.in_battle
    #@help_window.contents.draw_text(450,11, 20, 20, "怒") if $game_temp.in_battle
    
    #@help_window.set_text
    #draw_actor_od_gauge_value(@actor, x+190, y-65, width = 80) if $game_temp.in_battle###
  end
end
