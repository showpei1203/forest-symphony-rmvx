#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Skill Activation Config
# 【用途】技能系統元件「Skill Activation Config」。
# 【主要機制】可能影響技能資料、可用條件、消耗、熟練、選單或戰鬥執行。
# 【主要影響】CRMSN
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：BAR、LOGO、POINTER、KEYS、TIMING_LOGO、SEQUENCE_LOGO、MASH_LOGO、HIT_IMAGE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】CrimsonSeas。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#================================================================================
#Skill Activation Config v1.3
#
#  Script by CrimsonSeas
#================================================================================

module CRMSN
#------------------------------------------------------------------------------
#Image Config
#------------------------------------------------------------------------------
#Name for your image files.
#BAR: image file for the back of the gauge
#LOGO: image file for activation logo
#POINTER :image file for pointer
#IMPORTANT :
#Copy Activate_Bar.png, Overdrive_Logo.png, and Activate_Pointer.png to 
#Graphics/System folder.
  BAR = "Activate_Bar"
  LOGO = "Activate_Logo"
  POINTER = "Activate_Pointer"
  KEYS = "key input"
  TIMING_LOGO = "Timing_Logo"
  SEQUENCE_LOGO = "Sequence_Logo"
  MASH_LOGO = "Mash_Logo"
  HIT_IMAGE = "Activate_Area"
  SUCCESS_LOGO = "Success_Logo"
  FAIL_LOGO = "Fail_Logo"
  TIME_IMAGE = "Time"
#-------------------------------------------------------------------------------
#Range & Speed Config (for mash and timing)
#-------------------------------------------------------------------------------
#For determining maximum and minimum x position for pointer, and determining
#successful hit area. This is important since the pointer won't necessarily start
#at the very beginning of the bar, and won't end at the very end of the bar.
#You'll see what I mean if you play it in slow speed.
#Speed for pointer is also set here, the higher the faster it is.
#POINTER_RANGE = How long is the area that the pointer can move.
#HIT_RANGE = How long is the hit area.
#SPEED : addition(or substraction) for pointer's x. Must be positive.
#-------------------------------------------------------------------------------
#Tips for calculating these 3 values.
#It is best to set POINTER_RANGE = Bar's width-Pointer's width - 4.
#Set value for speed as an integer that can divide POINTER_RANGE with no remainder
#As for hit range, set it as HIT_RANGE = n*SPEED
#where n is an integer. n sets the width for hit_range.
  POINTER_RANGE = 288
  HIT_RANGE = 48
  SPEED = 8
#-------------------------------------------------------------------------------
#Key Icon Order
#-------------------------------------------------------------------------------
#This part determines which icon is for which input. You should arrange this
#according to your keys image file
  KEYS_ARRAY = ["Z", "X", "A", "S", "Q", "W", "UP", "LEFT", "DOWN", "RIGHT"]
#-------------------------------------------------------------------------------
#Sounds Config
#-------------------------------------------------------------------------------
#Sound played when activation window starts.
  START_SOUND = "Heal1"
#Sound played as the time left is an integer (3 secs left, 2 secs left etc)
  SEC_SOUND = "Cursor"
#Sound played when success
  SUCCESS_SOUND = "Chime2"
#Sound played when miss
  MISS_SOUND = "Buzzer1"
#Sound played when fail
  FAIL_SOUND = "Buzzer1"
#-------------------------------------------------------------------------------
#Default Time Config
#-------------------------------------------------------------------------------
#Length of activation period (seconds * 60)
  TIME = 120
#Length of starting delay. It would be quite surprising if the window suddenly
#suddenly shows up and immediately start, so it is best to give a little delay
#to give player some time to prepare (seconds * 60)
  DELAY = 30
#-------------------------------------------------------------------------------
#Default Power up Config
#-------------------------------------------------------------------------------
#Sets maximum power up in percent (Max = 100)
  MAX_POWER_UP = 50
#Sets minimum power up in percent (Max = 100). This is the power up value when
#player gets a success right before the time reaches 0.
  MIN_POWER_UP = 5
#-------------------------------------------------------------------------------
#Default Activation Type
#-------------------------------------------------------------------------------
#"TIMING" = Timing press type
#"SEQUENCE" = Sequence Input type
#"MASH" = Mash Input type
  DEFAULT_TYPE = "SEQUENCE"
#-------------------------------------------------------------------------------
#Default Activation Effect
#-------------------------------------------------------------------------------
#ADDNUM = Variable hit number
#DMGUP = Add skill damage
#CONTINUE = Skill will be canceled if failed
  DEFAULT_EFFECT = "CONTINUE"
#-------------------------------------------------------------------------------
#Default sequences for sequence activation
#-------------------------------------------------------------------------------
#You can enter more than one sequence in an array. When sequence is called, one
#sequence will be picked randomly. See example in Activation Property Config
  DEFAULT_SEQUENCE = [["UP", "DOWN", "LEFT", "RIGHT"]]
  
#-------------------------------------------------------------------------------
#Separate Windowskin
#-------------------------------------------------------------------------------
#Set to true if you want to use separate skin
  USE_SKIN = false
#Namefor the windowskin. File must be in Graphics/System folder
  SKIN = ""
#-------------------------------------------------------------------------------
#Darken background
#-------------------------------------------------------------------------------
#Set to true to darken battle window during activation. activation window doesn't
#get darken. You must have "Black Screen.png" in your Graphics/Picture folder.
  DARK = true
end