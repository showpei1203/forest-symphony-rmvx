#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Guns Action Sequence (K)
# 【用途】保留的 Runtime 元件「Guns Action Sequence (K)」。
# 【主要機制】主要定義／擴充 N01；下方原始說明與程式碼保留作細節依據。
# 【主要影響】N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：RANGED_ANIME、RANGED_ATTACK_ACTION。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】<action: GUN_ATTACK>
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
# + Guns Action Sequence Addon for RPG Tankentai Sideview Battle System
#   v1.3 (Only for Kaduki battlers)
#------------------------------------------------------------------------------
#  Script original by: Kylock
#  1.2 By Night'Walker
#==============================================================================
#   Requested by gend0 (rpgrevolution.com)
#   This is a script that adds new functionality to the Sideview battle System
# in the way of an additional animation for gun weapons.
#   To use this script, simply add it below the Sideview Battle System scripts
# and make sure your gun have element 6(Whip) checked in the game database on
# the weapons tab.  This can be changed below if you like your whip element.
#------------------------------------------------------------------------------
# ++ Assigning a Gun Action to Skills and Weapons
#
#   [With Notetag]
# * In the Notes field of a skill or weapon, type in
#
#               <action: GUN_ATTACK>
#
#   You do not need quotes around GUN_ATTACK. Remember that it requires 
#   Notetags for Tankentai Add-on
#
#==============================================================================

module N01
  RANGED_ANIME = {
  # Magic Animation
  "FIRE_GUN"       => ["m_a", 87,   4,  0,  12,   0,  0,  0, 2, true,""],
  # Weapon Animations
  "DOWN_TO_LEFT" =>[ 6, 3, false, 120, 45, 4, false, 1, 1, 0,  0, false],
  "LEFT_TO_UP" =>  [ 6, 3, false, 45, -15, 4, false, 1, 1, 0,  0, false],
  "LEFT_TO_UPL" => [ 6, 3, false, 45, -15, 4, false, 1, 1, 0,  0, true],
  "VERT_SWING-" => [   6,   3,false,-15,  45,  4,false,   1,  1,  0,  0,false],
  # Battler Animations
  "DRAW_WEAPON" => [ 0, 3, 4, 2, 0, -1, 0, true,"DOWN_TO_LEFT"],
  "GUN_FIRE"    => [ 3, 3, 1, 2, 0, -1, 0, true,"LEFT_TO_UP"],
  "GUN_FIREL"   => [ 3, 3, 1, 2, 0, -1, 0, true,"LEFT_TO_UPL"],
  "WPN_SWING_V-"=> [ 0, 3, 4, 2, 0, -1, 0, true,"VERT_SWING-"],
  "FRONT_JUMP"              => [  0, -32,   0,  16,  0,  -3,  "JUMP_ATTACK_POSE"],}
  ANIME.merge!(RANGED_ANIME)
  # Action Sequence
  RANGED_ATTACK_ACTION = {
    "弩" => ["FRONT_JUMP","DRAW_WEAPON","14","DAMAGE_ANIM","6","FIRE_GUN","GUN_FIRE",
    "5","WPN_SWING_V-","20","WEAPON2_DAMAGE","6","Two Wpn Only","FIRE_GUN",
    "GUN_FIREL","Two Wpn Only",
    "5","Can Collapse","MOVE_TO","RESET"],}
  ACTION.merge!(RANGED_ATTACK_ACTION)
end