#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Dialog system
# 【用途】保留的 Runtime 元件「Dialog system」。
# 【主要機制】主要定義／擴充 Dialog；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Dialog
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：STARTING_Z_VALUE。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
# ** Dialog system - RMVX
#------------------------------------------------------------------------------
# Zeriab
# Version 1.0
# 2008-02-16 (Year-Month-Day)
#------------------------------------------------------------------------------
# * Description :
#
#   A small framework like script for dialogs
#------------------------------------------------------------------------------
# * License :
#
#   Copyright (C) 2008  Zeriab
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Lesser Public License for more details.
#
#   For the full license see <http://www.gnu.org/licenses/> 
#   The GNU General Public License: http://www.gnu.org/licenses/gpl.txt
#   The GNU Lesser General Public License: http://www.gnu.org/licenses/lgpl.txt
#------------------------------------------------------------------------------
# * Instructions :
#
#   You can place this script pretty much anyway you like.
#   Place it above any other Dialogs you might be using.
#   Increase the STARTING_Z_VALUE if you have trouble with the dialog not
#   on top.
#==============================================================================
class Dialog
  STARTING_Z_VALUE = 1500 # Default value is 1500
  attr_accessor :value
  attr_writer :marked_to_close
  #--------------------------------------------------------------------------
  # * Getter with 'false' as default value
  #--------------------------------------------------------------------------
  def marked_to_close
	@marked_to_close = false  if @marked_to_close.nil?
	return @marked_to_close
  end
  #--------------------------------------------------------------------------
  # * Mark the dialog to close
  #--------------------------------------------------------------------------
  def mark_to_close
	self.marked_to_close = true
  end
  #--------------------------------------------------------------------------
  # * Show the dialog
  #   Returns the value from the dialog
  #--------------------------------------------------------------------------
  def self.show(*args, &block)
	dialog = self.new(*args, &block)
	dialog.marked_to_close = false
	return dialog.main
  end
  #--------------------------------------------------------------------------
  # * Initialization
  #--------------------------------------------------------------------------
  def initialize(*args, &block)
	# For subclasses to overwrite
  end
  #--------------------------------------------------------------------------
  # * Main processing
  #--------------------------------------------------------------------------
  def main
	# Create the dimmed background
	create_background
	# Create Windows
	main_window
	# Main loop
	loop do
	  # Update game screen
	  Graphics.update
	  # Update input information
	  Input.update
	  # Frame update
	  update
	  # Abort loop if the dialog should close
	  if marked_to_close
		break
	  end
	end
	# Dispose of windows
	main_dispose
	# Dispose of background
	dispose_background
	# Update input information
	Input.update
	# Returns the acquired value
	return self.value
  end
  #--------------------------------------------------------------------------
  # * Create the dimmed background
  #--------------------------------------------------------------------------
  def create_background
	bitmap = Bitmap.new(Graphics.width,Graphics.height)
	bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0,128))
	@background_sprite = Sprite.new
	@background_sprite.z = STARTING_Z_VALUE
	@background_sprite.bitmap = bitmap
  end
  #--------------------------------------------------------------------------
  # * Create the windows
  #--------------------------------------------------------------------------
  def main_window
	# For the subclasses to override
	# Remember to set their z.value to at least STARTING_Z_VALUE + 1
  end
  #--------------------------------------------------------------------------
  # * Dispose the background
  #--------------------------------------------------------------------------
  def dispose_background
	@background_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose the windows
  #--------------------------------------------------------------------------
  def main_dispose
	# For the subclasses to override
	# Dispose your windows here
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
	# For the subclasses to override
	if Input.trigger?(Input::B)
	  mark_to_close
	end
  end
end