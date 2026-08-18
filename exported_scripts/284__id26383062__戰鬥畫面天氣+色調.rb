#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：戰鬥畫面天氣+色調
# 【用途】戰鬥系統元件「戰鬥畫面天氣+色調」。
# 【主要機制】負責戰鬥流程、數值、AI、演出或相容的一部分；可能透過 alias 疊加既有方法。
# 【主要影響】Spriteset_Battle、MRA、BattleScreenEffects
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：WEATHER_SWITCH_ID、TONE_SWITCH_ID。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 4 個 alias／方法包裝，載入順序具有語意。
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
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#_/ ◆ Battle Screen Effects – MRA_BattleScreenEffects ◆ VX ◆
#_/ ◇ Last Update: 2008/09/27 ◇
#_/ ◆ Created by Mr. Anonymous ◆
#_/ ◆ Creator’s Blog: ◆
#_/ ◆ http://mraprojects.wordpress.com ◆
#_/—————————————————————————-
#_/ This script enables weather and screen tone to carry over from the map
#_/ screen into battle.
#_/============================================================================
#_/ Aliased Methods: Spriteset_Battle’s initialize, dispose, update,
#_/ update_viewports
#_/============================================================================
#_/ Install: Insert above main.
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#=============================================================================#
# ★ Customization ★ #
#=============================================================================#
module MRA
module BattleScreenEffects
# ★ Weather Switch ID ★
# This allows you to designate a switch that enables or disables the
# continuation of weather from the map into battle.
WEATHER_SWITCH_ID = 96
# ★ Screen Tone Switch ID ★
# This allows you to designate a switch that enables or disables the
# continuation of screen tone from the map into battle.
TONE_SWITCH_ID = 97
end
end
#=============================================================================#
# ★ End Customization ★ #
#=============================================================================#
#==============================================================================
# ** Spriteset_Battle
#——————————————————————————
# This class brings together battle screen sprites. It’s used within the
# Scene_Battle class.
#==============================================================================
class Spriteset_Battle
#————————————————————————–
# * Object Initialization
#————————————————————————–
alias initialize_mra_battle_screen_effects initialize
def initialize
if $game_switches[MRA::BattleScreenEffects::WEATHER_SWITCH_ID]
create_weather
end
initialize_mra_battle_screen_effects
end
#————————————————————————–
# * Dispose
#————————————————————————–
alias dispose_mra_battle_screen_effects dispose
def dispose
dispose_mra_battle_screen_effects
if $game_switches[MRA::BattleScreenEffects::WEATHER_SWITCH_ID]
dispose_weather
end
end
#————————————————————————–
# * Frame Update
#————————————————————————–
alias update_mra_battle_screen_effects update
def update
update_mra_battle_screen_effects
if $game_switches[MRA::BattleScreenEffects::WEATHER_SWITCH_ID]
update_weather
end
end
#————————————————————————–
# * Update Viewport
#————————————————————————–
alias update_viewports_mra_battle_screen_effects update_viewports
def update_viewports
update_viewports_mra_battle_screen_effects
if $game_switches[MRA::BattleScreenEffects::TONE_SWITCH_ID]
@viewport1.tone = $game_map.screen.tone
else
@viewport1.tone = $game_troop.screen.tone
end
end
#————————————————————————–
# * Create Weather
#————————————————————————–
def create_weather
@weather = Spriteset_Weather.new(@viewport2)
end
#————————————————————————–
# * Dispose of Weather
#————————————————————————–
def dispose_weather
@weather.dispose
end
#————————————————————————–
# * Update Weather
#————————————————————————–
def update_weather
@weather.type = $game_map.screen.weather_type
@weather.max = $game_map.screen.weather_max
@weather.ox = $game_map.display_x / 8
@weather.oy = $game_map.display_y / 8
@weather.update
end
end