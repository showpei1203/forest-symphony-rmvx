#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：存檔跳出訊息
# 【用途】保留的 Runtime 元件「存檔跳出訊息」。
# 【主要機制】主要定義／擴充 Scene_File；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Scene_File
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SAVE_CONFIRM_CAPTION、SAVE_CONFIRM_LENGTH、BLUR_BEFORE_CONFIRM_CAP。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】Mithran。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
# Save confirmation popup
# By Mithran
# Makes a small window popup indicating the game has been saved, after it has been
# saved.
# Install: Insert below any custom file systems.  Should work with most 
# custom file systems.

class Scene_File
  SAVE_CONFIRM_CAPTION = "存檔完成！"
  SAVE_CONFIRM_LENGTH = 120 # Max length in frames for the confirmed window to stay
  BLUR_BEFORE_CONFIRM_CAP = true
  # If set to true, the file screen will blur into the background before showing
  # the save confirmation box
  alias do_save_orig_popconfirm do_save
  def do_save
    do_save_orig_popconfirm 
    @save_done = true
  end

  alias terminate_orig_popconfirm terminate
  def terminate
    if @save_done
      bp = Graphics.snap_to_bitmap
      bp.blur  if BLUR_BEFORE_CONFIRM_CAP
      bs = Sprite.new
      bs.bitmap = bp
    end
    terminate_orig_popconfirm
    if @save_done
      save_done_popup
      bs.dispose
    end
  end
  
  def save_done_popup
    Graphics.transition(0)
    create_save_done_window
    update_save_done_window
    close_save_done_window
    Graphics.freeze
  end
  
  def create_save_done_window
    tw = Bitmap.new(32, 32).text_size(SAVE_CONFIRM_CAPTION).width
    @save_done_window = Window_Base.new(0, 0, tw + 32, Window_Base::WLH + 29)
    @save_done_window.openness = 0
    @save_done_window.contents.draw_text(0, 0, tw, Window_Base::WLH, SAVE_CONFIRM_CAPTION)
    @save_done_window.x = (Graphics.width - @save_done_window.width) / 2
    @save_done_window.y = (Graphics.height - @save_done_window.height) / 2
    @save_done_window.open
  end
  
  def update_save_done_window
    sl = 0
    while sl < SAVE_CONFIRM_LENGTH
      Graphics.update
      Input.update
      @save_done_window.update
      sl += 1 unless @save_done_window.openness < 255
      break if Input.trigger?(Input::C)
    end
  end
  
  def close_save_done_window
    @save_done_window.close
    while @save_done_window.openness > 0
      Graphics.update; @save_done_window.update
    end
    @save_done_window.dispose
  end
  
end