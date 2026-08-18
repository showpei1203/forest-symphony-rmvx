#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Dash Action Sequence
# 【用途】保留的 Runtime 元件「Dash Action Sequence」。
# 【主要機制】主要定義／擴充 Skill、Weapon、N01、RPG；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Skill、Weapon、N01、RPG
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：DASH_ELEMENT、SHOW_SKILL_ANIM_DASH、DASH_ATTACK_ACTION。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
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
# ■ Dash Skill/Weapon 1.2 for RPG Tankentai Sideview Battle System
# Released up on 9.28.2008
#------------------------------------------------------------------------------
# Written by Enelvon Siolach
#==============================================================================
# This script makes all weapons and skills with the Dash element, default 30,
# have a dash strike through the enemy as their attack.
#==============================================================================
# ■ Release Notes
#------------------------------------------------------------------------------
# 1.0
# ● Original Release.
# 1.1
# ● Added support for the skill animation.
# 1.2
# ● Fixed a bug with the skill animation.
#==============================================================================
# ■ Installation Notes
#------------------------------------------------------------------------------
# Plug and play. Set the DASH_ELEMENT to the Element ID of Dash. Add
# Dash to your Dash skills/weapons, and you're done!
#==============================================================================

module N01
# Element used to define a skill as a Dash skill
DASH_ELEMENT = 30 # Default is 30, my Dash Element.

SHOW_SKILL_ANIM_DASH = true #When true, if a skill has the Dash element it will have the magic animation before the dash. When false, it is the same as the
#weapon dash animation.
# Action Sequence
DASH_ATTACK_ACTION = {
"DASH_ATTACK_SKILL" => ["START_MAGIC_ANIM","45","JUMP_TO_TARGET","JUMP_AWAY","JUMP_AWAY","JUMP_AWAY","DASH_ATTACK","16","OBJ_ANIM_WEIGHT",
"One Wpn Only","16","Can Collapse","COORD_RESET"],
"DASH_ATTACK" => ["JUMP_TO_TARGET","JUMP_AWAY","JUMP_AWAY","JUMP_AWAY","DASH_ATTACK","16","OBJ_ANIM_WEIGHT","One Wpn Only","16","Can Collapse","COORD_RESET"],}
ACTION.merge!(DASH_ATTACK_ACTION)
end

module RPG
class Skill
alias enelvon_dash_base_action base_action
def base_action
# If the Dash Element is checked on the skills tab in the database,
# the Dash attack action sequence is used.
if $data_skills[@id].element_set.include?(N01::DASH_ELEMENT) && N01::SHOW_SKILL_ANIM_DASH == true
return "DASH_ATTACK_SKILL"
elsif $data_skills[@id].element_set.include?(N01::DASH_ELEMENT) && N01::SHOW_SKILL_ANIM_DASH == false
return "DASH_ATTACK"
end
enelvon_dash_base_action
end
end
class Weapon
alias enelvon_dash_weapon_base_action base_action
def base_action
# If the Dash Element is checked on the weapons tab in the database,
# the Dash attack action sequence is used.
if $data_weapons[@id].element_set.include?(N01::DASH_ELEMENT)
return "DASH_ATTACK"
end
enelvon_dash_weapon_base_action
end
end
end