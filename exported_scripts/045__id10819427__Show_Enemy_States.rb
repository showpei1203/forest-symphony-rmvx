#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Show Enemy States
# 【用途】保留的 Runtime 元件「Show Enemy States」。
# 【主要機制】主要定義／擴充 Window_TargetEnemy；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Window_TargetEnemy
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MA_SHOW_ICONS_NUM。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】modern algebra。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
#  Show Enemy States
#  Version: 1.0
#  Author: modern algebra
#  Date: July 13, 2009
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Description:
#    This script shows enemy states when targetting them in the DBS. It is 
#   recommended that it be used with Ziifee's State Icon Animation script or
#   any other State cycling script, as it looks best when displaying only one
#   icon at a time.
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Instructions:
#    Place above Main and below other custom scripts in the Script Editor.
#==============================================================================
# ** Window_TargetEnemy
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#  Summary of Changes:
#    aliased methods - draw_item, item_rect
#==============================================================================

class Window_TargetEnemy < Window_Command
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Constants
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  MA_SHOW_ICONS_NUM = 3 # Number of icons to show prefacing the enemy name
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Draw Item
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias mdlg_joy_drw_enmy_stt_drwitm_0gh3 draw_item
  def draw_item (index, *args)
    mdlg_joy_drw_enmy_stt_drwitm_0gh3 (index, *args)
    name_rect = item_rect(index)
    w = 24*MA_SHOW_ICONS_NUM
    icon_rect = Rect.new (name_rect.x - w - 4, name_rect.y, w + 4, name_rect.height)
    contents.clear_rect (icon_rect)
    # Draw Enemy State by Actor State method
    draw_actor_state (@enemies[index], icon_rect.x, icon_rect.y, w)
  end
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # * Item Rect
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  alias drbr_jy_enmyststes_show_itmrect_7j24 item_rect
  def item_rect (*args)
    rect = drbr_jy_enmyststes_show_itmrect_7j24 (*args)
    rect.x += ((24*MA_SHOW_ICONS_NUM) + 4)
    rect.width -= ((24*MA_SHOW_ICONS_NUM) + 4)
    return rect
  end
end