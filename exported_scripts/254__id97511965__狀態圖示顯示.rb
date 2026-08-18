#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：狀態圖示顯示
# 【用途】保留的 Runtime 元件「狀態圖示顯示」。
# 【主要機制】主要定義／擴充 Window_BattleStatusIcons、Scene_Battle；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Window_BattleStatusIcons、Scene_Battle
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意。
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
class Window_BattleStatusIcons < Window_Base
  def initialize
    super(0, 0, Graphics.width, Graphics.height)
    self.opacity = 0  # 透明背景
    self.contents_opacity = 120  # 設定整體內容透明度（0-255）
    refresh
  end

  def refresh
    contents.clear
    draw_status_icons
  end

  def draw_status_icons
    all_battlers = $game_party.members + $game_troop.members
    for battler in all_battlers
      next unless battler.exist?

      x = battler.position_x
      y = battler.position_y - 40  # 讓狀態圖示顯示在角色頭頂上

      draw_actor_states(battler, x, y)
    end
  end

  def draw_actor_states(battler, x, y)
    return if battler.states.empty?  # 如果沒有狀態，則不繪製背景
    icon_x = x - 16  # 調整圖示起始位置
    icon_y = y
    icon_x = x - 5 if battler.is_a?(Game_Enemy)
    icon_y = y + 5  if battler.is_a?(Game_Enemy)

    # 計算背景寬度（每個狀態圖示佔 24 像素）
    #status_count = battler.states.size
    #bg_width = status_count * 24 + 10  # 增加 10px 讓背景稍微比圖示大一點
    #bg_height = 28  # 固定高度

    # 🛠 **修正敵人背景方向**
    #if battler.is_a?(Game_Enemy)
    #  first_icon_x = icon_x - (status_count - 1) * 24  # 最左側的 icon 位置
    #  bg_x = first_icon_x - 5  # 讓背景從第一個 icon 開始，向右延伸
    #else
    #  bg_x = icon_x - 5  # 我方背景向右延伸
    #end
    # ️繪製背景
    #draw_status_background(icon_x, icon_y, bg_width, bg_height)

    
    if battler.is_a?(Game_Enemy)
      # 敵人圖示向左排列
      battler.states.reverse.each_with_index do |state, index|
        icon_index = state.icon_index
        draw_icon(icon_index, icon_x - (index * 24), icon_y)
      end
    else
      # 我方圖示向右排列
      battler.states.each_with_index do |state, index|
        icon_index = state.icon_index
        draw_icon(icon_index, icon_x + (index * 24), icon_y)
      end
    end
  end
  
  # 🛠 **新增：繪製圓角背景**
  def draw_status_background(x, y, width, height)
    rect = Rect.new(x - 5, y - 2, width, height)  # 往左偏移 5px 讓背景更美觀
    color = Color.new(65, 117, 120, 200)  # 透明度 150 的藍綠色背景
    contents.fill_rounded_rect(rect, color)
  end
end

class Scene_Battle < Scene_Base
  alias battle_status_window_start start
  def start
    battle_status_window_start
    @status_icon_window = Window_BattleStatusIcons.new
    @status_icon_window.visible = false
  end

  alias battle_status_window_update update
  def update
    battle_status_window_update
    update_status_window_visibility
  end

  def update_status_window_visibility
    @status_icon_window.visible = @actor_command_window.active
    @status_icon_window.refresh if @status_icon_window.visible
  end

  alias battle_status_window_terminate terminate
  def terminate
    battle_status_window_terminate
    @status_icon_window.dispose if @status_icon_window && !@status_icon_window.disposed?
  end
end

