#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Old Vers. Compatibility (K)
# 【用途】保留的 Runtime 元件「Old Vers. Compatibility (K)」。
# 【主要機制】主要定義／擴充 N01；下方原始說明與程式碼保留作細節依據。
# 【主要影響】N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：OLD_ANIME_KEYS。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
# + Sideview Battle System Old Version Compatibility Script (Kaduki)
#   v1.0
#------------------------------------------------------------------------------
# Due to the revised key names in the Battler Configuration script, old
# keys have been moved to a separate script. It is recommended that you 
# keep this script page installed in order to avoid errors with old
# action sequence scripts and such.
#
# The contents of each hash have not been changed.
#==============================================================================

module N01
  
  OLD_ANIME_KEYS = {
  
  # ANIME Key            No. Row Speed Loop Wait Fixed  Z Shadow  Weapon
#  "WAIT"            => [  1,  0,  15,  0,    0,    -1,   0, true,  "喬伊狀態待機" ],
  "WAIT" =>["STANDBY_POSE"],
  
  "WAIT(FIXED)"     => [  1,  0,  10,  2,   0,   1,   0, true,  "" ],
  "RIGHT(FIXED)"    => [  0,  2,  10,  1,   2,   1,   0, true,  "" ],
  "ATTACK_FAIL"     => [  2,  3,  10,  1,   8,   0,   0, true,  "" ],
  "MOVE_TO"         => [  1,  3,  11,  2,   0,  -1,   0, true,  "" ],
  "MOVE_TO2"        => [  2,  2,  11,  2,   0,  -1,   0, true,  "" ],
  "MOVE_AWAY"       => [  1,  3,  11,  2,   0,  -1,   0, true,  "" ],
  "ABOVE_DISPLAY"   => [  0,  1,   2,  1,   0,  -1, 600, true,  "" ],
  
  # ANIME Key                  Origin  X   Y  Time  Accel Jump Animation
  "START_POSITION"          => [  0,  54,   0,  1,   0,   0,  "MOVE_TO"],
  "START_POSITION3"         => [  0,  54,   0,  1,   0,   0,  "MOVE_TO2"],
  "START_POSITION2"         => [  0,  74,   0,  1,   0,   0,  "MOVE_TO"],
  "BEFORE_MOVE"             => [  3, -32,   0, 18,  -1,   0,  "MOVE_TO"],
  "AFTER_MOVE"              => [  0,  32,   0,  8,  -1,   0,  "MOVE_TO"],
  "4_MAN_ATTACK_1"          => [  2, 444,  96, 18,  -1,   0,  "MOVE_TO"],
  "4_MAN_ATTACK_2"          => [  2, 444, 212, 18,  -1,   0,  "MOVE_TO"],
  "4_MAN_ATTACK_3"          => [  2, 384,  64, 18,  -1,   0,  "MOVE_TO"],
  "4_MAN_ATTACK_4"          => [  2, 384, 244, 18,  -1,   0,  "MOVE_TO"],
  "EXTRUDE"                 => [  0,  12,   0,  1,   1,   0,  "DAMAGE"],
  "MOVING_TARGET"           => [  1,   0,   0, 18,  -1,   0,  "MOVE_TO"],
  "MOVING_TARGET_FAST"      => [  1,   0, -12,  8,   0,  -2,  "MOVE_TO"],
  "PREV_MOVING_TARGET"      => [  1,  24,   0, 35,   0,   0,  "ATTACK_MOVE"],
  "PREV_MOVING_TARGET_FAST" => [  1,  24,   0,  1,   0,   0,  "MOVE_TO"],
  "MOVING_TARGET_RIGHT"     => [  1,  96,  32, 16,  -1,   0,  "MOVE_TO"],
  "MOVING_TARGET_LEFT"      => [  1,  96, -32, 16,  -1,   0,  "MOVE_TO"],
  "JUMP_TO"                 => [  0, -32,   0,  8,  -1,  -4,  "MOVE_TO"],
  "JUMP_AWAY"               => [  0,  32,   0,  8,  -1,  -4,  "MOVE_AWAY"],
  "THROW_ALLY"              => [  0, -24,   0, 16,   0,  -2,  "MOVE_TO"],
  "PREV_JUMP_ATTACK"        => [  0, -32,   0, 12,  -1,  -2,  "WPN_SWING_V"],
  "PREV_STEP_ATTACK"        => [  1,  12,   0, 12,  -1,  -5,  "WPN_SWING_VS"],
  "REAR_SWEEP_ATTACK"       => [  1,  12,   0, 16,   0,  -3,  "WPN_SWING_V"],
  "JUMP_FIELD_ATTACK"       => [  1,   0,   0, 16,   0,  -5,  "WPN_SWING_V"],  
  
  # ANIME Key        　Type     A    B  Time  Animation
  "LIFT"        => ["float",   0, -30,  4, "WAIT(FIXED)"],
  
  # ANIME Key         Type   Time Accel Jump AnimationKey
  "COORD_RESET"   => ["reset", 16,  0,   0,  "MOVE_TO"],
  
  #  ANIME Key              Type   Object   Reset Type      ANIME/ACTION Key
  "LIGHT_BLOWBACK"    => ["SINGLE",     0,  "COORD_RESET",  "EXTRUDE"],
  "RIGHT_TURN"        => ["SINGLE",     0,  "COORD_RESET",  "CLOCKWISE_TURN"],
  "LIFT_ALLY"         => ["SINGLE",     0,             "",  "LIFT"],
  "4_MAN_ATK_1"       => ["SEQUENCE", -101, "COORD_RESET",  "4_MAN_ATTACK_1"],
  "4_MAN_ATK_2"       => ["SEQUENCE", -102, "COORD_RESET",  "4_MAN_ATTACK_2"],
  "4_MAN_ATK_3"       => ["SEQUENCE", -103, "COORD_RESET",  "4_MAN_ATTACK_3"],
  
  # ANIME Key            Type  Obj  Cont  Cond  Cond Value
  #                         A     B   C    D    E
  "2_MAN_ATK_COND"  => ["nece",   3,  0,  18,   1],
  "4_MAN_ATK_COND"  => ["nece",   3,  0,  19,   3],
  "FLOAT_STATE"     => ["nece",   0,  0,  17,   1],
  "CAT_STATE"       => ["nece",   0,  0,  20,   1],
  
  # ANIME Key                 Type   Time Start  End  Return
  "FALLEN"                => ["angle",  1, -90, -90,false],
  
  # ANIME Key               Type   ID  Object Invert  Wait  Weapon2
  "OBJ_ANIM"          => ["anime",  -1,  1,   false,  false, false],
  "OBJ_ANIM_WEIGHT"   => ["anime",  -1,  1,   false,   true, false],
  "OBJ_ANIM_WEAPON"   => ["anime",  -2,  1,   false,  false, false],
  "OBJ_ANIM_L"        => ["anime",  -1,  1,   false,  false,  true],
  "HIT_ANIM"          => ["anime",   1,  1,   false,  false, false],
  "KILL_HIT_ANIM"     => ["anime",  11,  1,   false,  false, false],
  
  # ANIME Key               Type   ID Object Pass Time Arc  Xp Yp Start Z Weapon
  "START_MAGIC_ANIM"    => ["m_a", 44,   4,  0,  52,   0,  0,  0,  2,false,""],
  "STAND_CAST"          => ["m_a", 80,   1,  0,  64,   0,  0,  0,  2, true,""],

  # ANIME Key　         　   Start  End Time  Type
  "WPN_THROW"           => [   0, 360,  8, "skill"],
  
  # ANIME Key   　      Type        Row  Loop
  "STATUS-NORMAL"   => ["balloon",   6,  1],
  "STATUS-CRITICAL" => ["balloon",   5,  1],
  "STATUS-SLEEP"    => ["balloon",   9,  1],
  
  # ANIME Key            Type  Object  State ID
  "2_MAN_TECH_GRANT" => ["sta+",  0,  18],
  "4_MAN_TECH_GRANT" => ["sta+",  0,  19],
  "CATFORM_GRANT"    => ["sta+",  0,  20],
  
  # ANIME Key            Type  Object  State ID
  "2_MAN_TECH_REVOKE" => ["sta-",  3,  18],
  "4_MAN_TECH_REVOKE" => ["sta-",  3,  19],
  
  # ANIME Key               Type   Reset  Filename
  "TRANSFORM_CANCEL"  => ["change", false,"$actor01"],

  }
  ANIME.merge!(OLD_ANIME_KEYS)
  
end
