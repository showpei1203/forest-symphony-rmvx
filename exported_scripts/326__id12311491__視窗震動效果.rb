#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：視窗震動效果
# 【用途】UI／選單元件「視窗震動效果」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Game_Screen、Ex_WinAPI
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】gms.shake_window(5, 5, 15)；gms.shake_window(8, 8, 60, 9, 1)
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】Exhydra。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#===============================================================================
# Shake Window
#===============================================================================
# Author       : Exhydra
# Version      : 1.5
# Last Updated : 06/20/2011
#===============================================================================
# Updates
# -----------------------------------------------------------------------------
# » 06/20/11 Cleaned up code; Changed WinAPIs slightly.
# » 06/14/11 [FIX] Maintained the game window position through rapid calls
#            [FIX] Determines if the game is full screen and runs a normal
#                  screen shake instead.
# » 06/13/11 Initial Release.
#===============================================================================
# Future Options
# -----------------------------------------------------------------------------
# » Nothing! Suggestions?
#===============================================================================
# Instructions
# -----------------------------------------------------------------------------
# To Use :
#   Call : (from a Script Event command)
#     gms = $game_map.screen
#     gms.shake_window(power, speed, duration[, route, ds_option])
#
#     'route' Values
#      7 8 9
#      4  (6) - Default; Right then Left (Valid for Window Shake ONLY)
#      1 2 3
#
#     'ds_option' Values
#       (0)   - Default; Shake Window Only
#        1    - Shake Window and Screen
#        2    - Shake Screen Only
#   
#   Examples :
#     gms = $game_map.screen
#     gms.shake_window(5, 5, 15)
#
#     gms = $game_map.screen
#     gms.shake_window(8, 8, 60, 9, 1)
#===============================================================================
# Description
# -----------------------------------------------------------------------------
# - Shakes the window of the game, or shakes the window and the screen or just
#   shakes the screen. This script allows the user to go beyond the limitations
#   of the Shake Screen command within the Event Editor. However, that is just
#   a by-product and can be easily done without including this script.
#===============================================================================

#===============================================================================
# [NOTE:] -
#===============================================================================

#===============================================================================
# -? Game_Screen
# -----------------------------------------------------------------------------
# Summary of Changes:
#    New Method(s)     - shake_window
#    Aliased Method(s) - clear, update_shake
#===============================================================================

class Game_Screen
  #--------------------------------------------------------------------------
  # » Clear                                                         [ Alias ]
  #--------------------------------------------------------------------------
  alias ex_shakewindow_clear clear unless $@
  def clear
    @sw_power = 0
    @sw_speed = 0
    @sw_duration = 0
    @sw_direction = 0
    @sw_shake = 0
    @sw_hwnd = 0
    @sw_szEval = ""
    @sw_rect = []
   
    ex_shakewindow_clear
  end
 
  #--------------------------------------------------------------------------
  # » Shake Window                                                    [ New ]
  #     power        : Shake Intensity
  #     speed        : Shake Speed
  #     duration     : Shake Duration (60 = 1 sec)
  #    [route]       : Direction Window will Shake Towards
  #     7 8 9
  #     4 ?(6) - Default; Right then Left (Valid for Window Shake ONLY)
  #     1 2 3
  #    [ds_option]   : 'Double Shake' Option
  #      (0)   - Default; Window Shake Only
  #       1    - Window and Screen Shake
  #       2    - Screen Shake Only
  #--------------------------------------------------------------------------
  def shake_window(power, speed, duration, route = 6, ds_option = 0)
    return if @sw_shake != 0
    ds_option      = 2 if Ex_WinAPI.CheckFullScreen == true
   
    case ds_option
      when 1
        start_shake(power, speed, duration)
      when 2
        start_shake(power, speed, duration)
        return
    end
   
    case route
      when 1
        @sw_direction = 1
        @szEval = "@sw_rect[0] + (-@sw_shake), @sw_rect[1] + (@sw_shake)"
      when 2
        @sw_direction = 1
        @szEval = "@sw_rect[0], @sw_rect[1] + (@sw_shake)"
      when 3
        @sw_direction = 1
        @szEval = "@sw_rect[0] + (@sw_shake), @sw_rect[1] + (@sw_shake)"
      when 4
        @sw_direction = -1
        @szEval = "@sw_rect[0] + (@sw_shake), @sw_rect[1]"
      when 6
        @sw_direction = 1
        @szEval = "@sw_rect[0] + (@sw_shake), @sw_rect[1]"
      when 7
        @sw_direction = -1
        @szEval = "@sw_rect[0] + (@sw_shake), @sw_rect[1] + (@sw_shake)"
      when 8
        @sw_direction = -1
        @szEval = "@sw_rect[0], @sw_rect[1] + (@sw_shake)"
      when 9
        @sw_direction = -1
        @szEval = "@sw_rect[0] + (-@sw_shake), @sw_rect[1] + (@sw_shake)"
      else
        @sw_direction = 1
        @szEval = "@sw_rect[0] + (@sw_shake), @sw_rect[1]"
    end
     
    @sw_power = power
    @sw_speed = speed
    @sw_duration = duration
    @sw_hwnd = Ex_WinAPI.AcquireGameWindow
    @sw_rect = Ex_WinAPI.AcquireGameWindowRect
  end

  #--------------------------------------------------------------------------
  # » Update Shake                                                  [ Alias ]
  #--------------------------------------------------------------------------
  alias ex_shakewindow_update_shake update_shake unless $@
  def update_shake
    if @sw_duration >= 1 or @sw_shake != 0
      sw_delta = (@sw_power * @sw_speed * @sw_direction) / 10.0
      if @sw_duration <= 1 and @sw_shake * (@sw_shake + sw_delta) < 0
        @sw_shake = 0
      else
        @sw_shake += sw_delta
      end
      if @sw_shake > @sw_power * 2
        @sw_direction = -1
      end
      if @sw_shake < - @sw_power * 2
        @sw_direction = 1
      end
      if @sw_duration >= 1
        @sw_duration -= 1
      end
     
      if Ex_WinAPI.CheckFullScreen != true
        eval("Ex_WinAPI.SetWindowPosition(@sw_hwnd, " + @szEval + ",
              @sw_rect[2] - @sw_rect[0], @sw_rect[3] - @sw_rect[1])")
      end
     
    end
   
    ex_shakewindow_update_shake
  end
end


class Ex_WinAPI
  #--------------------------------------------------------------------------
  # » Windows API Declarations                                [ Windows API ]
  #--------------------------------------------------------------------------
  @@getCurrentThreadId       = Win32API.new('kernel32' ,'GetCurrentThreadId'      , ['']                                , 'L')
  @@getWindowLong            = Win32API.new('user32'   ,'GetWindowLongA'          , ['L', 'I']                          , 'L')
  @@getWindowRect            = Win32API.new('user32'   ,'GetWindowRect'           , ['L', 'P']                          , 'L')
  @@getWindowThreadProcessId = Win32API.new('user32'   ,'GetWindowThreadProcessId', ['L', 'P']                          , 'L')
  @@getClientRect            = Win32API.new('user32'   ,'GetClientRect'           , ['L', 'P']                          , 'L')
  @@setWindowPosition        = Win32API.new('user32'   ,'SetWindowPos'            , ['L', 'L', 'I', 'I', 'I', 'I', 'I'] , 'I')
  @@findWindowEx             = Win32API.new('user32'   ,'FindWindowEx'            , ['L', 'L', 'P', 'P']                , 'L')

  #--------------------------------------------------------------------------
  # » Constants
  #--------------------------------------------------------------------------
  @@gwl_STYLE                = -16
  
  @@ws_MINIMIZEBOX           = 0x20000
  @@ws_DLGFRAME              = 0x00400000
  @@ws_BORDER                = 0x00800000
  @@ws_SYSMENU               = 0x00080000
  @@ws_CLIPSIBLINGS          = 0x04000000
  @@ws_VISIBLE               = 0x10000000

  @@ws_RGSS_NORM             = @@ws_SYSMENU | @@ws_CLIPSIBLINGS | @@ws_VISIBLE |
                               @@ws_BORDER  | @@ws_DLGFRAME     | @@ws_MINIMIZEBOX
  
  #--------------------------------------------------------------------------
  # » Variables
  #--------------------------------------------------------------------------
  @@gameHwnd                 = nil
 
  #--------------------------------------------------------------------------
  # » Acquire Game Window                                     [ Windows API ]
  #--------------------------------------------------------------------------
  def self.AcquireGameWindow
    return @@gameHwnd if @@gameHwnd
    procID     = [0].pack('L')
    threadID   = @@getCurrentThreadId.call
    gameTitle = ($data_system.nil?) ? 0 : $data_system.game_title
    @@gameHwnd = 0

    begin
      @@gameHwnd = @@findWindowEx.call(0, @@gameHwnd, "RGSS Player", gameTitle)

      if @@gameHwnd
        wndThreadID = @@getWindowThreadProcessId.call(@@gameHwnd, procID)
       
        return @@gameHwnd unless wndThreadID != threadID; gameTitle = 0
      end
    end until @@gameHwnd == 0

    raise "ERROR : RGSS player window not found!"
    return 0
  end

  #--------------------------------------------------------------------------
  # » Acquire Game Window Long                                [ Windows API ]
  #--------------------------------------------------------------------------
  def self.AcquireGameWindowLong
    wHwnd   = self.AcquireGameWindow
    
    return @@getWindowLong.call(wHwnd, @@gwl_STYLE)
  end
  
  #--------------------------------------------------------------------------
  # » Acquire Game Window Rect                                [ Windows API ]
  #--------------------------------------------------------------------------
  def self.AcquireGameWindowRect
    aRect      = [0,0,0,0].pack('L4')
    wHwnd      = self.AcquireGameWindow
   
    @@getWindowRect.call(wHwnd, aRect)
    l, t, r, b = aRect.unpack('L4')
    return l, t, r, b
  end
 
  #--------------------------------------------------------------------------
  # » Acquire Client Screen Rect                              [ Windows API ]
  #--------------------------------------------------------------------------
  def self.AcquireClientScreenRect
    aScreen    = [0,0,0,0].pack('L4')
    wHwnd      = self.AcquireGameWindow
   
    @@getClientRect.call(wHwnd, aScreen)
    l, t, r ,b = aScreen.unpack('L4')
    return l, t, r, b
  end

  #--------------------------------------------------------------------------
  # » Check Full Screen                                       [ Windows API ]
  #--------------------------------------------------------------------------
  def self.CheckFullScreen
    aRect        = self.AcquireGameWindowRect
    aScreen      = self.AcquireClientScreenRect
    lCurrScreen  = self.AcquireGameWindowLong

    if aRect[0] <= aScreen[0] and
       aRect[1] <= aScreen[1] and
       aRect[2] >= aScreen[2] and
       aRect[3] >= aScreen[3] or 
       lCurrScreen | @@ws_RGSS_NORM != @@ws_RGSS_NORM
      return true
    else
      return false
    end
  end
 
  #--------------------------------------------------------------------------
  # » Set Window Position                                     [ Windows API ]
  #     window_hWnd  : Window HWND
  #     window_x     : Window Screen X (Top Left)
  #     window_y     : Window Screen Y (Top Left)
  #     window_w     : Window Width
  #     window_h     : Window Height
  #--------------------------------------------------------------------------
  def self.SetWindowPosition(window_hWnd, window_x, window_y, window_w, window_h)
    return @@setWindowPosition.call(window_hWnd, 0, window_x, window_y, window_w, window_h, 0)
  end

end