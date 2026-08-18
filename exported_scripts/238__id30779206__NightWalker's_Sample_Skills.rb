#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：NightWalker's Sample Skills
# 【用途】技能系統元件「NightWalker's Sample Skills」。
# 【主要機制】可能影響技能資料、可用條件、消耗、熟練、選單或戰鬥執行。
# 【主要影響】N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：NW_CUSTOM_ANIME、NW_CUSTOM_SEQUENCE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】<action: FIRE_ASSIST>；<action: FROUST>
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
# Modifed from the original so the union attack skills will work in the ATB
# Know that you must also define the skills that are used as a union attack
# under ● ATB Union Skills Settings in the ATB Configuration's script.
#
# Notetags: <action: FIRE_ATTACK>
#           <action: FIRE_ASSIST>
#
#           <action: FROUST>

module N01
  NW_CUSTOM_ANIME = {
  
  # Battler Action Definition
  "FIRE_SWORD_ASSIST_ANIME"      => ["SEQUENCE",    21, "COORD_RESET",  "FIRE_ASSIST"],
  # Action Condition
  "FIRE_STATECHECK"  => ["nece",   3,   0,  21,    1],
  # State Granting Effect "Fire Bless"
  "FIRE_GRANT"       => ["sta+",  1,  21],
  # State Removal Effect "Fire Bless"
  "FIRE_REVOKE"       => ["sta-",  3,  21],
  # Target Modification
  "FIRE_SWORD_TARGET"      => ["target",   21,  1],
  # Attack Animation Settings
  "FIRE_ANIM" => ["anime", 88,  0, false,false, false],
  "FIRE_ANIM2" => ["anime", 89,  0, false,false, false],
  # Horizontal Movements of Battler Animations
  "FIRE_ATK1" => [1,  28, 0, 27, 0, 0, "ATTACK_MOVE"],
  "FIRE_ATK0" => [3, -64, 0, 20, 0, -2, "JUMP_ATTACK_POSE"],
  
  # Cut-in Start
  "FROUST_PIC_START"  => ["pic",   -200,  0,   0,  90, 20,false,"Froust"],
  # Cut-in End
  "FROUST_PIC_END"    => ["pic",   0,  80,   544,  90, 10,false,"Froust"],
  # Attack Animation Settings
  "FROUST_ANIM" => ["anime", 90, 0, false, false, false],
  # Battler Animations
  "FROUST_SPECIAL"   => [ 3, 0, 10,  -1,  0, -1,   0,  true, "OVER_SWING" ],
  "FROUST_SPECIAL2"   => [ 1, 3, 10,  2,  0, 1,   0,  true, "NO_SWING" ],
  }
ANIME.merge!(NW_CUSTOM_ANIME)

  NW_CUSTOM_SEQUENCE = {
  #Attack Action Sequence
  #
  # Unlike the normal version's way of creating a union attack, the main
  # attacker's sequence does not need a State Check, Forced Battler actions or
  # Target Modification single-actions. 
  # Simply create the attacker's sequence normally as if it was just another
  # skill sequence for a single character.
  "FIRE_ATTACK" => ["STAND_POSE","FIRE_ATK0","STANDBY_POSE","75","FIRE_ANIM","20","FIRE_ANIM2","20",
                    "FIRE_ATK1","WPN_SWING_V","DAMAGE_ANIM_WAIT","40","One Wpn Only",
                    "16","FLEE_RESET"],

  # Assist Action Sequence
  #
  # Unlike the normal version's way of creating a union attack, the assist's
  # sequence does not need to be a State Granting Effect.  In this case, rather
  # than linking the assist's skill to the "FIRE_STATE_GRANT" sequence, link
  # he skill to "FIRE_ASSIST".
  # Simply create the attacker's sequence normally as if it was just another
  # skill sequence for a single character.  Make sure you change the Scope
  # of the skill to something like One Enemy.
  "FIRE_ASSIST" => ["STAND_POSE","STEP_FORWARD","SKILL_POSE","24","CAST_ANIMATION",
                    "160","FLEE_RESET", "Can Collapse"],

  # State grant action sequence
  "FIRE_STATE_GRANT" => ["FIRE_GRANT"],
  
  # Froust Cut-In Attack Action Sequence
  "FROUST"        => ["STEP_FORWARD","FROUST_SPECIAL","5","FROUST_ANIM","FROUST_SPECIAL2",
                      "10","FROUST_PIC_START",
                      "100","FROUST_PIC_END","20","Clear image","10","MOVE_TO_TARGET",
                      "WPN_SWING_V","10","DAMAGE_ANIM_WAIT","20","Can Collapse",
                      "FLEE_RESET"],

  }
  ACTION.merge!(NW_CUSTOM_SEQUENCE)
  
end
