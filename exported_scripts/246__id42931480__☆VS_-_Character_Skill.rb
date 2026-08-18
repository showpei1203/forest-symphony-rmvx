#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：☆VS - Character Skill
# 【用途】技能系統元件「☆VS - Character Skill」。
# 【主要機制】可能影響技能資料、可用條件、消耗、熟練、選單或戰鬥執行。
# 【主要影響】N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：VANCE_ANIME、VANCE_ACTION。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
# ■ Valkyrie Stories - Escallion Rising Custom Skill Sequence
#     May 17, 2011
#------------------------------------------------------------------------------
#  Script original by: Hanzo Kimura
#==============================================================================

module N01
#==============================================================================
# ■ Vance Skill Sequence
#==============================================================================
  VANCE_ANIME = {
  #--------------------------------------------------------------------------
  # Object - Animation's target. [0=Target] [1=Enemy's Area] 
  #                              [2=Party's Area] [4=Self]
  # Pass -  [0: Animation stops when it reaches the Object.] 
  #         [1: Animation passes through the Object and continues.] 
  # Start - Defines origin of animation movement.
  #              [0=Self] [1=Target] [2=No Movement] 
  # Z-axis - true: Animation will be over the battler sprite.
  #          false: Animation will be behind battler sprite.
  # Flying Graphic Angle - Insert only "Flying Graphic Angle" and
  #                        "Flying Graphic Skill Angle" ANIME keys. 
  # ANIMATIONS                 Type   ID Object Pass Time Arc  Xp Yp Start   Z  FlyGraphicAngle
  "FLAME_TOUCH"            => ["m_a",126,    4,  1,  52,  0,  0,  0,  0,  true,    ""],
  "ANIME_FLAME_BUSTER"     => ["m_a",125,    0,  1,  52,  0,  0,  0,  2,  true,    ""],
  }
  ANIME.merge!(VANCE_ANIME)
#==============================================================================
# ACTIONS
#============================================================================== 
  VANCE_ACTION = {
    "FLAME_BUSTER" => [ # Anime Keys
                  "Afterimage ON",
                  "STEP_FORWARD", # Battler steps forward a bit
                  "CAST_PHYS_AN", # Cast Physical Animation
                  "40",
                  "BB_TINT_SKILL",
                  "DRAW_POSE",    # Play Kaduki pose
                  "WPN_RAISED2",
                  "FLAME_TOUCH",  # Cast Animation
                  "80",
                  "MOVE_TO_TARGET",
                  "WPN_SWING_V",
                  "ANIME_FLAME_BUSTER",
                  "10",
                  "SHAKE_SCREEN_MILD",
                  "DAMAGE_ANIM",  # Damage the target and play the weapon
                                  # skill's animation (if it hits)
                  "16",           # Delays the sequence for 12 frames
                  "Can Collapse", # Determines if battler is at 0 HP
                                  # and turns off their immortal flag so
                                  # that they can die/collapse.
                  "EVADE_JUMP",
                  "BB_TINT_NORMAL",
                  "40",
                  "FLEE_RESET"    # Reset battler to start coordinates
                  ], # Closing square bracket. Don't forgot the comma!
    "FLAME_BUSTER2" => [ # Anime Keys
                  "Afterimage ON",
                  #"STEP_FORWARD", # Battler steps forward a bit
                  #"CAST_PHYS_AN", # Cast Physical Animation
                  "40",
                  #"BB_TINT_SKILL",
                  "DRAW_POSE",    # Play Kaduki pose
                  "WPN_RAISED2",
                  "FLAME_TOUCH",  # Cast Animation
                  "80",
                  "MOVE_TO_TARGET",
                  "WPN_SWING_V",
                  "ANIME_FLAME_BUSTER",
                  "10",
                  "SHAKE_SCREEN_MILD",
                  "DAMAGE_ANIM",  # Damage the target and play the weapon
                                  # skill's animation (if it hits)
                  "16",           # Delays the sequence for 12 frames
                  "EVADE_JUMP",
                  "EVADE_JUMP",
                  "WPN_SWING_V",
                  "DASH_ATTACK",
                  "ANIME_FLAME_BUSTER",
                  "10",
                  "SHAKE_SCREEN_MILD",
                  "DAMAGE_ANIM",
                  "Can Collapse", # Determines if battler is at 0 HP
                                  # and turns off their immortal flag so
                                  # that they can die/collapse.
                  "BB_TINT_NORMAL",
                  "40",
                  "FLEE_RESET"    # Reset battler to start coordinates
                  ], # Closing square bracket. Don't forgot the comma!
  }
  ACTION.merge!(VANCE_ACTION)
#==============================================================================
# ■ Cerina Skill Sequence
#==============================================================================





end