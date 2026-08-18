#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Premade Action Sequences
# 【用途】保留的 Runtime 元件「Premade Action Sequences」。
# 【主要機制】主要定義／擴充 N01；下方原始說明與程式碼保留作細節依據。
# 【主要影響】N01
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：PREMADE_ANIME_KEYS、PREMADE_ACTION_SEQUENCES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】<action: SPEAR_ATTACK>；<action: THROW_RETURN_ATTACK>；<action: THROW_STICKY_ATTACK>
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
# + Premade Action Sequences for Tankentai Sideview Battle System
#------------------------------------------------------------------------------
# Sequences scripted by Mr. Bubble, AlphaWhelp and Kylock
#==============================================================================
# Add-on action sequences scripts from the original EXTRA demo have been 
# condensed into a single script. Although it is not required, it is assumed
# you are going to use the Tankentai Notetags script to assign these action 
# sequences to skills, items and weapons.
#
# You can use the following Notetags:
#
# <action: SPEAR_ATTACK>
# <action: THROW_RETURN_ATTACK>
# <action: THROW_STICKY_ATTACK>
# <action: THROW_MULTIPLE_ATTACK>
# <action: TKSLAM>
# <action: GUN_ATTACK>
# <action: STATIONARY_ATTACK>
# <action: STATIONARY_SKILL>
# <action: HYPERBARRAGE>
# <action: JUMPATTACK>
# <action: GIANT_TOSS>
# <action: OMNISLASH>
# <action: BACKSTAB>
# <action: HARP_ATTACK>
# <action: THROW_ITEM>
# <action: STRANGE_CUT-IN>
# <action: EXAMPLE_ANIM_ON_SELF>
#
# <action: ANTIPODE>
# <action: ANTIPODE_ASSIST>
#
# <action: SOUTHERN_CROSS>
# <action: SOUTHERN_CROSS_ASSIST>
#
# Unfortunately, I do not have the time to provide comments for all of the 
# anime keys and action sequences.
#==============================================================================

module N01
  #============================================================================
  # Predefined Anime Keys
  #============================================================================
  PREMADE_ANIME_KEYS = {
  #-------------------------------------------------------------------------
  # AlphaWhelp's Spear Attack - Anime Keys
  #-------------------------------------------------------------------------
  # ANIME Keys              No. Row Speed Loop Wait Fixed Z Shadow Weapon
  "里歐施法姿勢"      => [  3,  3,   2,    0,  0,  -1,   2, true,"里歐武器"],
  "丟斧姿勢"          => [  4,  2,   2,    2,  0,  -1,   2, true,"VERT_SWING"],
  "丟物姿勢"          => [  3,  0,   2,    2,  0,  -1,   2, true,""],
  "左轉斧P"           => [  2,  0,   2,    2,  5,   0,   0, true, "左轉斧WP1" ],
  "右轉斧P"           => [  2,  0,   2,    2,  5,   0,   0, true, "右轉斧WP1" ],
  "左轉斧P2"          => [  2,  0,   2,    2,  5,   0,   0, true, "左轉斧WP2" ],
  "右轉斧P2"          => [  2,  0,   2,    2,  5,   0,   0, true, "右轉斧WP2" ],
  "艾薇跑步姿勢"         => [ 1, 3, 15,    0,  0,  -1,   0, true,"" ],
  "艾薇受傷姿勢"         => [ 1, 1, 15,    2,  0,  -1,   0, true,"" ],
  "艾薇則強姿勢"         => [ 4, 2, 15,    0,  0,   1,   0, true,"艾薇則強武器" ],
  "艾薇則強姿勢2"        => [ 4, 2, 15,    0,  0,   0,   0, true,"艾薇則強武器2" ],
  "艾薇發動姿勢"         => [ 4, 2, 15,    0,  0,   0,   0, true,"艾薇發動武器" ],
  "艾薇出招姿勢1"        => [ 2, 2, 15,    0,  0,   2,   0, true,"艾薇出招武器" ],
  "艾薇出招姿勢2"        => [ 2, 2, 15,    0,  0,   1,   0, true,"艾薇出招武器2"],
  "艾薇尾招姿勢"         => [ 4, 2, 15,    0,  0,   2,   0, true,"艾薇尾招武器" ],
  "死神發動"             => [ 2, 0, 16,    0,  0,   0,   2, true,"死神武器1"],
  "開啟狀態2"            => [ 3, 0, 16,    0,  0,   1,   2, true,"開啟武器2"],
  "開啟狀態3"            => [ 3, 0, 16,    0,  0,   2,   2, true,"開啟武器3"],
  "開啟狀態"             => [ 2, 0, 16,    0,  0,   0,   2, true,"開啟武器"],
  "突刺開始"             => [ 4, 1, 16,    0,  0,   0,   2, true,"突刺武器開始"],
  "突刺開始2"            => [ 4, 1, 16,    0,  0,   1,   2, true,"突刺武器開始2"],
  "突刺姿勢3"            => [ 4, 3, 16,    0,  0,   2,   2, true,"突刺武器開始3"],
  "突刺姿勢"             => [ 2, 1,  2,    2,  0,   2,   2, true,"突刺武器1"],
  "突刺姿勢2"            => [ 1, 0,  2,    2,  0,   2,   2, true,"突刺武器2"],
  "槍投開始"             => [ 4, 0, 16,    0,  0,   0,   2, true,"槍投一段"],
  "槍投等待"             => [ 4, 2,  8,    0,  0,  -1,   2, true,"槍投一段2"],
  "槍投開始2"            => [ 4, 0, 16,    0,  0,   1,   2, true,"槍投二段"],
  "槍投開始3"            => [ 4, 0, 16,    0,  0,   2,   2, true,""],
  "追月開始"             => [ 4, 1, 16,    0,  0,   0,   2, true,"追月一段"],
  "追月開始2"            => [ 4, 1,  8,    0,  0,   1,   2, true,"追月一段2"],
  "追月開始3"            => [ 3, 2,  8,    0,  0,   2,   2, true,"追月二段"],
  "追月開始4"            => [ 4, 0, 16,    0,  0,   0,   2, true,"追月三段"],
  "START_SPEAR_THRUST"   => [ 1, 0,  2,    2,  0,  -1,   2, true,"THRUST_BEGIN"],
  "END_SPEAR_THRUST"     => [ 3, 0,  2,    2,  0,  -1,   2, true,"THRUST_END"],
  "END_SPEAR_THRUST2"    => [ 3, 0,  2,    2,  0,  -1,   2, true,"THRUST_END2"],
  "END_SPEAR_THRUST3"    => [ 3, 0,  2,    2,  0,  -1,   2, true,"THRUST_END3"],
  "START_SPEAR_THRUSTs"  => [ 1, 0,  0,    0,  0,  -1,   2, true,"THRUST_BEGIN"],
  "END_SPEAR_THRUSTs"    => [ 3, 0,  0,    0,  0,  -1,   2, true,"THRUST_END"],

  # ANIME Keys          Xa  Ya   Za   A1  A2  Or  Inv  Xs Ys  Xp Yp Weapon2
  "里歐武器"        => [  0,  0, true,-235, -235, 0,false, 0, 0, -12, 0,false],
  "左轉斧WP1"       => [ -4,  0, false, 135, -45,  0, false,  1,  1,-24, -18,false],
  "左轉斧WP2"       => [ -4,  0, false, -45,-225,  0, false,  1,  1,-24, -18,false],
  "右轉斧WP1"       => [  4,  0,  true, 135, -45,  0, false,  1,  1,-24, -18,false],
  "右轉斧WP2"       => [  4,  0,  true, -45,-225,  0, false,  1,  1,-24, -18,false],
  "艾薇則強武器2"   => [  0, -2,true, 65,  65,0, false, 1, 1,-15, 10,false],
  "艾薇則強武器"    => [ 0, -2,false, 245,245,0, false, 1, 1,10, 0,false],
  "艾薇發動武器"    => [  0, -2,true, 245,245,0, false, 1, 1,10, 0,false],
  "艾薇出招武器2"   => [  0, -2,true,-55,-55, 0, false, 1, 1,-15,-15,false],
  "艾薇出招武器"    => [  0, -2,true, 65,  65,0, false, 1, 1,-15, 10,false],
  "艾薇尾招武器"    => [  0, -2,true, 65,  65,0, false, 1, 1,-15, 10,false],
  "死神武器1"       => [  0,  0,true,-285, -285, 0,false, 0, 0, 3, 5,false],
  "開啟武器3"       => [  0,  0,true,-240, -220, 0,false, 1, 1,-9, 4,false],
  "開啟武器2"       => [  0,  0,true,-240, -220, 0,false, 1, 1,-9,-2,false],
  "開啟武器"        => [  0,  0,true,-230, -230, 0,false, 1, 1,-20,-2,false],
  "突刺武器1"       => [  0,  0,true, 25, 25, 0,false, 1, 1,-9,-2,false],
  "突刺武器2"       => [  0,  0,true, 55, 55, 0,false, 1, 1,-9, 3,false],
  "THRUST_END"      => [ -4,  0,true, 45, 65, 0,false, 1, 1, -1, 3,false],
  "THRUST_END2"     => [ -4,  0,true, 65, 45, 0,false, 1, 1, -1, 3,false],
  "THRUST_END3"     => [ -4,  0,true, 55, 75, 0,false, 1, 1, -1, 3,false],
  "THRUST_BEGIN"    => [ 10,  0,true, 45, 65, 0,false, 1, 1, -4, 3,false],
  "突刺武器開始"    => [  0,  0,true, 45, 45, 0,false, 1, 1, -6, 3,false],
  "突刺武器開始2"   => [  0,  0,true, 50, 50, 0,false, 1, 1, -3, 4,false],
  "突刺武器開始3"   => [  0,  0,false,15, 15, 0,false, 1, 1, -14, -6,false],
  "槍投一段"        => [ -15,15,false,15, 15, 3,false, 1, 1,  0, 0,false],
  "槍投一段2"       => [  0,  2,false,15, 15, 3,false, 1, 1, -4, 7,false],
  "槍投二段"        => [ -15,15,false,45, 45, 3,false, 1, 1,  0, 0,false],
  "追月一段"        => [  0,  0,true, 60, 60, 0,false, 1, 1, -2, 5,false],
  "追月一段2"       => [  0,  0,false,75, 75, 0,false, 1, 1, -3, 3,false],
  "追月二段"        => [  0,  0,false,15, 15, 0,false, 1, 1,-15,-8,false],
  "追月三段"        => [  0,  0,false,265, 265, 0,false, 1, 1,12,-7,false],
  
  #                     Origin  X     Y  Time  Accel Jump    Animation
  "丟物"            => [  0,     0,   0,  -2,   -1,    0,  "丟物姿勢"],
  "丟斧"            => [  0,     0,   0,   6,   -1,   -3,  "丟斧姿勢"],
  "艾薇則強攻擊2"   => [  0,   -45,  20,   4,   -1,   -2,  "艾薇則強姿勢2"],
  "艾薇接出招"      => [  5,   34,   -5,   4,   -1,   -4,  "艾薇出招姿勢1"],
  "左轉斧"          => [  0,    0,    0,   4,   -1,   0,  "左轉斧P"],
  "右轉斧"          => [  0,    0,    0,   4,   -1,   0,  "右轉斧P"],
  "左轉斧2"         => [  0,    0,    0,   4,   -1,   0,  "左轉斧P2"],
  "右轉斧2"         => [  0,    0,    0,   4,   -1,   0,  "右轉斧P2"],
  "艾薇奔跑"        => [  0,   -45,   0,   4,   -1,    0,  "艾薇跑步姿勢"],
  "艾薇受傷後跳1"   => [  0,    35,   0,   8,   -1,   -3,  "艾薇受傷姿勢"],
  "艾薇受傷後跳2"   => [  0,    15,   0,   8,   -1,   -2,  "艾薇受傷姿勢"],
  "艾薇則強小退"    => [  0,     5,   0,   8,   -1,    0,  "艾薇則強姿勢"],
  "艾薇則強攻擊"    => [  0,   -45,   0,   4,   -1,   -2,  "艾薇則強姿勢2"],
  "艾薇後跳1"       => [  0,    35,   0,   8,   -1,   -3,  "艾薇待機姿勢"],
  "艾薇後跳2"       => [  0,    15,   0,   8,   -1,   -2,  "艾薇待機姿勢"],
  "艾薇尾招3"       => [  0,   -45, -10,   2,   -1,   -3,  "艾薇出招姿勢2"],
  "艾薇出招1"       => [  5,    44, -10,   1,   -1,    0,  "艾薇出招姿勢1"],
  "艾薇出招2"       => [  5,    44, -10,   8,   -1,   -3,  "艾薇出招姿勢2"],
  "艾薇尾招"        => [  0,    -5,  10,   4,   -1,    0,  "艾薇尾招姿勢"],
  "艾薇尾招2"       => [  0,    12,   0,   8,   -1,    3,  "艾薇待機姿勢2"],
  "出斷肢"          => [  0,   -60,   2,   4,   -1,    0,  "突刺開始2"],
  "出突刺"          => [  0,   -12,   2,   4,   -1,    0,  "突刺姿勢"],
  "回突刺"          => [  0,    32,   0,   4,   -1,    0,  "突刺姿勢2"],
  "出突刺2"         => [  0,   -24,  -2,   4,   -1,    0,  "突刺姿勢3"],
  "出突刺3"         => [  0,   -36,   3,   4,   -1,    0,  "END_SPEAR_THRUST"],
  "追月出招"        => [  0,   -4,   0,   1,   -1,    0,  "追月開始3"],
  "追月出招2"       => [  0,   -12,   0,   5,   -1,   -4,  "追月開始3"],
  "斷肢出招"        => [  0,    12,   0,   8,   -1,    -3,  "追月開始3"],
  "突刺蓄力"        => [  0,   24,   0,   8,   -1,   -2,  "STANDBY_POSE2"],#"突刺開始2"],
  "突刺出招"        => [  0, -170,   3,   3,   -1,    0,  "END_SPEAR_THRUST"],
  "死神出招"        => [  0,  -70,   3,   3,   -1,    0,  "END_SPEAR_THRUST"],
  "刺穿出招"        => [  0, -130,   3,   3,   -1,    0,  "END_SPEAR_THRUST"],
  "突刺出招2"       => [  0,    0,   3,   3,   -1,    0,  "END_SPEAR_THRUST"],
  "震地跳起"        => [  0,  -35,   5,   8,   -1,   -4,  "追月開始3"],
  "追月尾招"        => [  0,   16,   0,   8,   -1,   -3,  "追月開始4"],
  "斷肢尾招"        => [  0,   16,   0,  16,   -1,   -4,  "追月開始4"],
  "死神前進"        => [  5,   50,  -10,  4,   -1,    -2,  "ATTACK_MOVE_POSE2"],
  "死神後跳"        => [  5,  -20,  -10,  4,   -1,    -2,  "ATTACK_MOVE_POSE2"],
  "死神前跳"        => [  5,  100,  -10,  4,   -1,    -2,  "ATTACK_MOVE_POSE2"],
  "死神前進2"       => [  2,  272,  165,  8,   -1,    -2,  "ATTACK_MOVE_POSE2"],
  "死神前進3"       => [  2,   72,  165,  2,   -1,    -2,  "END_SPEAR_THRUST"],
  "背向-"            => [  0,   0,   0,  4,   0,   0,  "背向P"],
  "連斬S1-"          => [  5,  30,  -8, 10,   0,   0,  "連斬P1"],
  "連斬S2-"          => [  5,  28,  -8, 10,   0,   0,  "連斬P2"],
  "連斬S3-"          => [  5,  26,  -8, 10,   0,   0,  "連斬P3"],
  "連斬S4-"          => [  5,  24,  -8, 10,   0,   0,  "連斬P4"],
  "連斬S5-"          => [  5,  22,  -8, 10,   0,   0,  "連斬P5"],
  "連斬S6-"          => [  5,  60,  -8, 10,   0,   0,  "連斬P6"],
  "連斬2S1-"         => [  5,  20,  -8, 10,   0,   0,  "衝擊2P2"],
  "連斬2S2-"         => [  5,  30,  -8, 10,   0,   0,  "連斬2P1"],
  "連斬2S3-"         => [  5,  30,  -8, 10,   0,   0,  "連斬2P2"],
  "連斬2S4-"         => [  0,   2,   0, 10,   0,   0,  "連斬2P3"],
  "連斬2S5-"         => [  0,   2,   0, 10,   0,   0,  "連斬2P4"],
  "連斬2S6-"         => [  0,  -4,   0, 10,   0,   0,  "連斬2P5"],
  "連斬3S1-"         => [  5, -30,  -8, 10,  -4,  -5,  "連斬3P1"],
  "連斬3S2-"         => [  0,   0,   0, 4,   0,   0,  "連斬3P2"],
  "連斬3S3-"         => [  0,   0,   0, 4,   0,   0,  "連斬3P3"],
  "連斬3S4-"         => [  0,   0,   0, 4,   0,   0,  "連斬3P4"],
  "連斬3S5-"         => [  0,  80,   0, 10,   0,   0,  "連斬3P5"],
  #-------------------------------------------------------------------------
  # AlphaWhelp's Throwing Attacks - Anime Keys
  #-------------------------------------------------------------------------
  #ANIME Key        Type   ID Object Pass Time Arc  Xp Yp Start Z FlyGraphicAngle
  "STICKY_THROW" => ["m_a", 0, 0, 0, 18, -36, 0, 0, 0, false,"WPN_ROTATION"],
  "STICKY_THROW2" =>["m_a", 0, 0, 0, 18,   0, 0, 0, 0, false,"WPN_ROTATION2"],
   
  "SHURIKEN_THROW" => ["m_a", 0, 0, 0, 18, 0, 0, 0, 0, false,"WPN_ROTATION"],
  "槍投投出"       => ["m_a",71, 4, 0, 52, 0, 0, 0, 2,false,""],
  "弩彈射"         => ["m_a",159, 4, 0, 52, 0, 0, 0, 2,false,""],
  "弩射出"         => ["m_a",158, 4, 0, 52, 0, 0, 0, 2,false,""],
  "槍投命中"       => ["m_a",72, 0, 0, 52, 0, 0, 0, 2,false,""],
  "艾卓cast"       => ["m_a",73, 4, 0, 52, 0, 0, 0, 2, true,""],
  "艾卓死神cast"   => ["m_a",111, 4, 0, 52, 0, 0, 0, 2, true,""],
  "追月出招動畫"   => ["m_a",74, 4, 0, 52, 0, 0, 0, 2, true,""],
  "斷肢出招動畫"   => ["m_a",118, 4, 0, 52, 0, 0, 0, 2, true,""],
  "追月出招動畫2"  => ["m_a",76, 4, 0, 52, 0, 0, 0, 2, true,""],
  "震地出招動畫"   => ["m_a",79, 4, 0, 52, 0, 0, 0, 2, true,""],
  "戰死動畫1"      => ["m_a",106, 4, 0, 52, 0, 0, 0, 2, true,""],
  "戰死動畫2"      => ["m_a",107, 4, 0, 52, 0, 0, 0, 2, true,""],
  "死神攻擊動畫"   => ["m_a",108, 0, 0, 52, 0, 0, 0, 2, true,""],
  "死神出現動畫"   => ["m_a",109, 4, 0,100, 0, 0, 0, 2, true,""],
  "死神打雷"       => ["m_a",112, 4, 0, 52, 0, 0, 0, 2, true,""],
  "死神大招"       => ["m_a",114, 4, 2, 52, 0, 0, 0, 2, true,""],
  "死神出招"       => ["m_a",115, 4, 2, 52, 0, 0, 0, 2, true,""],
  "艾卓死神動畫"   => ["m_a",119, 4, 0, 52, 0, 0, 0, 2, true,""],
  "艾薇龍捲風"     => ["m_a",121, 4, 0, 52, 0, 0, 0, 2, true,""],
  "艾薇技能發動"   => ["m_a",122, 4, 0, 52, 0, 0, 0, 2, true,""],
  "艾薇技能尾招"   => ["m_a",123, 0, 0, 52, 0, 0, 0, 2, true,""],
  "艾薇技能撞到"   => ["m_a",124, 0, 0, 52, 0, 0, 0, 2, true,""],
  "艾薇技能狂砍"   => ["m_a",125, 0, 0, 52, 0, 0, 0, 2, true,""],
  "丟物品開始"     => ["m_a",  0,   0,  0,  12, -18,  0,  0,  0,false,"物品旋轉"],
  "START_WEAPON_THROW2"  => ["m_a",  0,   0,  0,  12, -18,  0,  0,  0,false,"WPN_ROTATION"],
  "END_WEAPON_THROW2"    => ["m_a",  0,   0,  0,  12,  18,  0,  0,  1,false,"WPN_ROTATION"],
  
  #-------------------------------------------------------------------------
  # Mr. Bubble's TK Slam - Anime Keys
  #-------------------------------------------------------------------------
  "TKSLAM_ENEMY"     => ["SEQUENCE",  0, "COORD_RESET",  "TKSLAM_ENEMYMOVE"],
  "TKSLAM_ENEMYFLOAT" => ["float", 0, -100,  60, "STAND_POSE"],
  "TKSLAM_ENEMYDROP" => ["float", -100, 0,  5, "STAND_POSE"],
  "TKSLAM_ENEMYROTATE" => ["angle", 55,   0, 180, false],
  "TKSLAM_ANIM" => ["anime", 53,  1, false,false, false],
  "drop_sound"       => ["sound", "se",  100, 80, "Evasion"],
  
  #-------------------------------------------------------------------------
  # Kylock's Gun Attack - Anime Keys
  #-------------------------------------------------------------------------
  "GUNSHOT" => ["sound", "se",  100, 100, "close1"],
  
  #-------------------------------------------------------------------------
  # Jump Attack - Anime Keys
  #-------------------------------------------------------------------------
  #                           Origin  X   Y  Time  Accel Jump Animation
  "JUMPATTACK_JUMP1"     => [  2,   260, -50,  22,   -2,   -1,  "STAND_POSE"],
  "JUMPATTACK_JUMP2"     => [  1,     0, 0 ,  16,   1,    -5,  "RIGHT(FIXED)"],
  "JUMPATTACK_MOVE"      => [  2,   -50, 100,  1,   0,     0,  "STAND_POSE"],
  
  #                           Type   Time Accel Jump Animation
  "JUMPATTACK_RESET"     => ["reset", 13,  0,   -4,  "MOVE_AWAY"],
  
  #                         Type1   Type2  Pitch Vol   Filename
  "se-Jump1"            => ["sound", "se", 100, 80, "Jump1"],

  #-------------------------------------------------------------------------
  # Giant Toss - Anime Keys
  #-------------------------------------------------------------------------
  #                        Origin  X   Y  Time  Accel Jump Animation
  "GIANTTOSS_EJUMP"     => [  2,   272, 250,  60, -1,  -7,  "STAND_POSE"], # Enemy
  "GIANTTOSS_MOVE"     => [  1,   0, -15,  30,   -5,  0,  "MOVE_TO"], # Enemy
  
  #                           Type   Time Start  End  Return
  "GIANTTOSS_ANGLE"       => ["angle", 4,   0, -20, false],
  "GIANTTOSS_ANGLERESET"       => ["angle", 2,   0, 0, false],

  #                         Type   Object   Reset Type      Action Name
  "GIANTTOSS_EACTION1"    => ["SINGLE",     0,  "",  "GIANTTOSS_FLOAT"], # Enemy
  "GIANTTOSS_EACTION2"    => ["SEQUENCE",     0,  "",  "GIANT_TOSS_ESEQ"], # Enemy

  #                  　       Type     A    B  Time  Animation
  "GIANTTOSS_FLOAT"      => ["float", 0, -25,  25, "STAND_POSE"],

  #                        Type   ID Object Pass Time Arc  Xp Yp Start Z Weapon
  "GIANTTOSS_ANIM"     => ["m_a",  72,   0,  0,  65,   0,  0,  0,  2,false,""],

  #-------------------------------------------------------------------------
  # Omnislash - Anime Keys
  #-------------------------------------------------------------------------
  # Omnislash
  "OMNISLASH_MOVE" => [  1,  20,   0, 6,  -5,   0,  "WAIT"],
  "OMNISLASH_JUMP" => [  1,  30,   0, 6,  -1,   -4,  "WAIT"],
  
  #-------------------------------------------------------------------------
  # Headwind - Anime Keys
  #-------------------------------------------------------------------------
  # Headwind
  "HEADWIND_BEFORESLIDE" => [  1,  100,   0, 20,  -5,   0,  "MOVE_TO"],
  "HEADWIND_SLIDE" => [  1,  -95,   0, 6,  -5,   0,  "STAND_POSE"],
  "HEADWIND_JUMP" => [  1,  100,   0, 30,  -5,   -6,  "MOVE_TO"],
  "HEADWIND_ANIM"  => ["anime",  101,  1, false,false, false],
  "HEADWIND_SPIN" => ["angle", 26,   0,-360,false],
  
  #-------------------------------------------------------------------------
  # Backstab - Anime Keys
  #-------------------------------------------------------------------------
  # Backstab
  "PORTAL_WARP" => [ 1, -30, 0, 1, 1, 0, "WAIT(RIGHT)"],
  "PORTAL_OPEN"      => ["anime",  77,  0, false,false, false],
  #-------------------------------------------------------------------------
  # Harp Attack - Anime Keys
  #-------------------------------------------------------------------------
  "FLYING_NOTES" => ["m_a", 32, 0, 1, 35, 10, 0, -5, 0,false,""],
  #-------------------------------------------------------------------------
  # Antipode - Anime Keys
  #-------------------------------------------------------------------------
  # Determines the target of assist actor
  # Target Mod name          Type   Object  Type
  "ANTIPODE_TARGET"      => ["target",   22,  1],
  "ANTIPODE_MOVE_1"       => [  2, 338,  163, 18,  -1,   0,  "MOVE_TO"],
  "ANTIPODE_MOVE_2"       => [  2, 356, 219, 18,  -1,   0,  "MOVE_TO"],
  "ICEBALL(SHOOT)" => ["m_a",  3,   0,  0,  15,   -20,  0,  0, 0,false,""],
  "FIREBLAST" => ["anime",  25,  1, false,false, false],
  "ICE_BLOCK" => ["anime",  26,  1, false,false, false],
  #-------------------------------------------------------------------------
  # Southern Cross- Anime Keys
  #-------------------------------------------------------------------------
  # Southern Cross
  # Mid-sequence trigger for the assist actor's animations
  "SOUTHCROSS_ASSISTANIME"  => ["SEQUENCE",   21, "COORD_RESET",  
                                "SOUTHCROSS_ASSIST_ATK"],
    
  "SOUTHCROSS_ANIM" => ["anime",  84,  1, false,false, false],
  # These MOVE single actions are for the main attacker
  "SOUTHCROSS_MOVE1" => [  1, 50,   40, 25,  -5,   0,  "MOVE_TO"],
  "SOUTHCROSS_MOVE2" => [  1,  -50,   -40, 10,  -5,   0,  "STAND_POSE"],
  # These MOVE single actions are for the assist character
  "SOUTHCROSS_MOVE3" => [  1, -50,   60, 25,  -5,   0,  "MOVE_TO"],
  "SOUTHCROSS_MOVE4" => [  1,  50,  -60, 10,  -5,   0,  "STAND_POSE"],

  
  } # <-- Do not delete this.
  ANIME.merge!(PREMADE_ANIME_KEYS)
  
#============================================================================
# Premade Action Sequences - Action Sequences
#============================================================================
  PREMADE_ACTION_SEQUENCES = {
  #-------------------------------------------------------------------------
  # AlphaWhelp's Spear Attack - Action Sequence
  #-------------------------------------------------------------------------
  "泰勒弩攻擊" =>["泰勒後退2","泰勒拿弩姿勢","5","弩準備動畫","泰勒弩攻擊姿勢",
                  "15","泰勒弩攻擊姿勢","弩射出","5","弩彈射","5",
                   "WEAPON_DAMAGE","10","泰勒起始跳","Can Collapse","RESET"],
  "里歐施法" => ["里歐施法姿勢"],
  "艾薇普攻2" => [
                 "艾薇出招2","艾薇出招1","DAMAGE_ANIM","25",
                 "艾薇後跳1",
                 "Can Collapse","Afterimage OFF","FLEE_RESET","艾薇憤怒判斷"],
  
  "加憤怒" =>[ "Afterimage ON","艾薇技能發動","艾薇發動姿勢","32",
               "艾薇憤怒判斷",
               "Can Collapse","Afterimage OFF","FLEE_RESET"
             ],
                
  "丟斧頭" => ["Afterimage ON","艾薇技能發動","艾薇發動姿勢","32",
               "丟斧","absorb1","STAND_POSE",
               "START_WEAPON_THROW2","12","SHAKE_SCREEN2","WEAPON_DAMAGE","Can Collapse",
               "END_WEAPON_THROW2","5","RESET"],
                
  "艾薇丟" => ["Afterimage ON",
               "丟斧","absorb1","STAND_POSE",
               "START_WEAPON_THROW2","12","WEAPON_DAMAGE",
               "Afterimage OFF","Can Collapse",
               "5","RESET"],    
               
   "泰勒丟" => ["Afterimage ON",
               "丟物",#"STAND_POSE",
               "丟物品開始","12","DAMAGE_ANIM",
               "丟物",#"STAND_POSE",
               "丟物品開始","12","DAMAGE_ANIM",
               "丟物",#"STAND_POSE",
               "丟物品開始","12","DAMAGE_ANIM",
               "丟物",#"STAND_POSE",
               "丟物品開始","12","DAMAGE_ANIM",
               "丟物",#"STAND_POSE",
               "丟物品開始","12","DAMAGE_ANIM",
               "Can Collapse",
               "5","RESET"],     
 
  "金錢丟" => ["Afterimage ON",
               "丟物","pop text_skill",#"STAND_POSE",
               "丟物品開始","喬伊不爽動畫","12","DAMAGE_ANIM","Can Collapse",
               "5","RESET"],    
               
  "揮霍無度" => ["Afterimage ON",
                "丟物","pop text_skill",#"STAND_POSE",
               "丟物品開始","喬伊不爽動畫","12","DAMAGE_ANIM",
               "丟物",#"STAND_POSE",
               "丟物品開始","喬伊不爽動畫","12","DAMAGE_ANIM",
               "丟物",#"STAND_POSE",
               "丟物品開始","喬伊不爽動畫","12","DAMAGE_ANIM","Can Collapse",
               "5","RESET"],   
               
  "物品丟" => ["Afterimage ON",
               "丟物",#"STAND_POSE",
               "丟物品開始","12","DAMAGE_ANIM","Can Collapse",
               "5","RESET"],  
               
  "重擊合招" => ["重擊S1",
                 "艾薇技能發動","艾薇發動姿勢","32",
                 "準備跳躍" ,"Afterimage ON","重擊S2","重擊S3","5",
                 "SHAKE_SCREEN_MILD2","DAMAGE_ANIM_WAIT",
                 "Afterimage OFF",
                 "重擊2S1","WEAPON_DAMAGE","後空翻1","重擊2S2",
                 "後空翻2","重擊2S3","後空翻3","重擊2S4","後空翻4","重擊2S5","後空翻1",
                 "重擊2S2","後空翻2","重擊2S3","後空翻3","重擊2S4","後空翻4","重擊2S5",
                 "重擊2S6",
  
                 "Afterimage ON","準備跳躍","重擊3S1","10","Invert",
                 "重擊3S2","SHAKE_SCREEN_MILD2","10","WEAPON_DAMAGE",
                 "Invert","Afterimage OFF","RESET"
                ],            
                 
  "耍斧頭" =>[ "Afterimage ON","艾薇技能發動","艾薇發動姿勢","32",
               "艾薇出招2","艾薇出招1","DAMAGE_ANIM","12","音符心情",
               "右轉斧","右轉斧2","右轉斧",
               "艾薇接出招",
               "艾薇技能狂砍","SHAKE_SCREEN2","DAMAGE","20",
               "艾薇後跳1","艾薇後跳2",
               "Can Collapse","Afterimage OFF","FLEE_RESET"
             ],
                 
  "東張西望" => ["弱點S1","艾薇發動姿勢","艾薇技能發動","32",
                  "Afterimage ON","問號心情","弱點S2","弱點S3","弱點S4","5",
                  "弱點S5",
                  "弱點S6","艾薇發動姿勢","16","電燈泡心情","60",
                  "艾薇則強攻擊","艾薇技能尾招",
                  "SHAKE_SCREEN2","DAMAGE_ANIM_WAIT",
                  "艾薇後跳1","艾薇後跳2",
                  "Can Collapse","Afterimage OFF","FLEE_RESET"],
                 
                 
  "挫折再起"  => ["Afterimage ON","艾薇技能發動","艾薇發動姿勢","32",
                 "艾薇出招2","艾薇出招1","DAMAGE_ANIM","12","艾薇後跳1","12",
                 "艾薇奔跑","4","艾薇技能撞到","艾薇受傷後跳1","艾薇受傷後跳2","30",
                 "艾薇則強姿勢","12","不爽心情","80","艾薇則強攻擊",
                 "艾薇技能尾招","DAMAGE","32",
                 "艾薇則強姿勢","5","艾薇則強姿勢2","艾薇技能尾招","DAMAGE","5",
                 "艾薇則強姿勢","3","艾薇則強姿勢2","艾薇技能尾招","DAMAGE","3",
                 "艾薇則強姿勢","1","艾薇則強姿勢2","艾薇技能尾招","DAMAGE","1",
                 "不爽心情",
                 "艾薇則強姿勢","1","艾薇則強姿勢2","艾薇技能狂砍","SHAKE_SCREEN2",
                 "DAMAGE","32",
                 "艾薇後跳1","艾薇後跳2",
                 "Can Collapse","Afterimage OFF","FLEE_RESET"
                  ],
                 
                 
  "遇強則強"  =>["Afterimage ON","艾薇技能發動","艾薇發動姿勢","32",
                 "艾薇出招2","艾薇出招1","DAMAGE_ANIM","12","艾薇後跳1",
                 "轉身音效","艾薇則強姿勢","12","驚嘆號心情","60",
                 #"FPS_SLOW",
                 "艾薇則強攻擊","艾薇技能尾招","DAMAGE","8",
                 "重擊2S2","後空翻1","重擊2S3","後空翻2",
                 "重擊2S4","後空翻3","重擊2S5","後空翻4",
                 "艾薇則強攻擊2","艾薇技能尾招","DAMAGE","SHAKE_SCREEN2",
                 "32",
                 #"FPS_NORMAL",
                 "艾薇後跳1","艾薇後跳2",
                 "Can Collapse","Afterimage OFF","FLEE_RESET"
                 ],
  
  "旋轉攻擊" => ["Afterimage ON","艾薇技能發動","艾薇發動姿勢","pop text_skill","32",
                 "艾薇出招2","艾薇出招1","DAMAGE_ANIM","SHAKE_SCREEN2","25",
                "連斬3S2-","5","音符心情",
                 "連斬3S3-","5","連斬3S2-","背向-","5","DAMAGE_ANIM","連斬3S4-","5",
                 "連斬3S3-","3","連斬3S2-","背向-","3","DAMAGE_ANIM","連斬3S4-","3",
                 "艾薇龍捲風",
                 "連斬3S3-","1","連斬3S2-","背向-","1","DAMAGE_ANIM","1","連斬3S4-","1",
                 "連斬3S3-","1","連斬3S2-","背向-","1","DAMAGE_ANIM","1","連斬3S4-","1", 
                 "連斬3S3-","1","連斬3S2-","1","背向-","艾薇尾招3",
"Afterimage OFF","艾薇前頃","2","艾薇尾招","艾薇技能尾招","DAMAGE","SHAKE_SCREEN2","正常",
                 "艾薇後跳1","艾薇後跳2",
                 "Can Collapse","Afterimage OFF","FLEE_RESET"],       
  
  "旋轉攻擊測試" => ["Afterimage ON","艾薇技能發動","艾薇發動姿勢","32",
                 "艾薇出招2","艾薇出招1","GAME_VAR_122_=0","DAMAGE_ANIM","SHAKE_SCREEN2","25",
                "連斬3S2-","5","音符心情",
                 "連斬3S3-","5","連斬3S2-","背向-","5","DAMAGE_ANIM","連斬3S4-","5",
                 "連斬3S3-","3","連斬3S2-","背向-","3","DAMAGE_ANIM","連斬3S4-","3",
                 "艾薇龍捲風",
                 "連斬3S3-","1","連斬3S2-","背向-","1","GAME_VAR_122_+100","DAMAGE_ANIM","1","連斬3S4-","1",
                 "連斬3S3-","1","連斬3S2-","背向-","1","DAMAGE_ANIM","1","連斬3S4-","1", 
                 "連斬3S3-","1","連斬3S2-","1","背向-","艾薇尾招3",
"Afterimage OFF","艾薇前頃","2","艾薇尾招","艾薇技能尾招","GAME_VAR_122_+100","DAMAGE","SHAKE_SCREEN2","正常",
                 "艾薇後跳1","艾薇後跳2",
                 "Can Collapse","Afterimage OFF","FLEE_RESET"],                      
  
  "SPEAR_ATTACK" => ["pop text","MOVE_TO_TARGET2","START_SPEAR_THRUST","4",
      "END_SPEAR_THRUST","DAMAGE_ANIM_WAIT","16",
      "Can Collapse","FLEE_RESET"],
      
  "槍投" => ["Afterimage ON","槍投開始","4","艾卓光效","32","槍投開始2","4","槍投開始3",
             "槍投投出","pop text_skill","16","槍投命中","DAMAGE_ANIM_WAIT","16","Can Collapse",
             "Afterimage OFF","FLEE_RESET"], 
   "槍投技能等待" => ["槍投等待"],
   "艾卓前進" => ["艾卓前進動作"],
   
   "追月" => ["Afterimage ON","追月開始2","pop text_skill","艾卓光效","32","追月開始2","1","追月出招","追月出招動畫",
              "追月尾招","1",#"REAL_TARGET","追月動畫前進","8",
              "追月出招","1","追月出招動畫2","追月開始2","8","REAL_TARGET","追月動畫前進","8",
              "DAMAGE_ANIM_WAIT","16","Can Collapse","Afterimage OFF","FLEE_RESET"],
              
   "震地" => ["Afterimage ON","震地前進","8","追月開始4","艾卓光效","pop text_skill",
              "32","追月開始4","震地出招動畫","震地跳起","追月開始2","8","DAMAGE_ANIM","SHAKE_SCREEN2","16",
              "Can Collapse","Afterimage OFF","FLEE_RESET"],
  "精準刺擊" => ["Afterimage ON","震地前進","8","突刺開始","艾卓光效","16","pop text_skill",
             "突刺蓄力","艾卓cast","40","突刺開始2","4","突刺出招","DAMAGE_ANIM_WAIT",
             "16","Can Collapse","Afterimage OFF","FLEE_RESET"],
   
  "追月亂舞" => ["Afterimage ON","追月開始2","pop text_skill","艾卓光效","32",
                 "追月出招","追月出招動畫","追月尾招","1",
                 "追月出招","1","追月出招動畫2","追月開始2","16",
                 "突刺蓄力","艾卓cast","40",
                 "追月出招2","1","追月出招動畫2","追月開始2","SHAKE_SCREEN2",
                 "8","REAL_TARGET","追月動畫前進","8","DAMAGE_ANIM_WAIT","16",
                 "Can Collapse","Afterimage OFF","FLEE_RESET"],
  "三連刺"    => ["Afterimage ON","震地前進","8","突刺開始","艾卓光效","16","pop text_skill",
                "突刺開始2","出突刺","DAMAGE_ANIM",
                #"突刺開始2",
                "出突刺2","DAMAGE_ANIM","2","出突刺3",#"回突刺",
                "DAMAGE_ANIM_WAIT",
                "16","Can Collapse","Afterimage OFF","FLEE_RESET"],
  
  "刺穿"      =>["Afterimage ON",
                 
                 "震地前進","8","槍投開始","艾卓光效",
                 "32",#"追月出招","追月出招動畫","追月尾招","8","擊飛","4",
                 "槍投開始2","槍投開始3",#"槍投投出",
                 "pop text_skill",
                 "刺穿出招","8","DAMAGE_ANIM_WAIT",#"槍投投出","刺穿出招","8","DAMAGE_ANIM_WAIT",
                "16","Can Collapse","Afterimage OFF","FLEE_RESET"],   
                
  "格擋大師"   =>["Afterimage ON","原地前進","8","槍投開始","艾卓光效","pop text_skill",
                 #"CAST_ANIMATION",   # Play cast animation on self
    "ANIM_WAIT",        # Play skill/weapon/item animation, wait until it's done
    "4",                # Delay sequence for 4 frames
    "DAMAGE",           # Deal damage
  
                  "32","Afterimage OFF","FLEE_RESET"],
                
   
  "斷肢"      =>["Afterimage ON","斷肢前進","8","死神發動","艾卓光效","TINT_SCREEN_BLACK","32",
                 "死神發動","追月開始2","1","追月出招","斷肢出招動畫","斷肢尾招","斷肢擊飛","32",
                "出斷肢","DAMAGE_ANIM","出斷肢","DAMAGE_ANIM","出斷肢","DAMAGE_ANIM","死神發動","8",
                "16","NORMAL_SCREEN_COLOR","Can Collapse","Afterimage OFF","FLEE_RESET"
                 ],
  "開啟戰神模式" =>["Afterimage ON","追月開始2","4","艾卓光效","32",
                    "左轉槍","左轉槍2",
                    "開啟狀態2","4","開啟狀態3","戰死動畫1","12",
                    "DAMAGE_ANIM","16","Can Collapse","Afterimage OFF","FLEE_RESET"
                    ],
  
  "開啟死神模式" =>["Afterimage ON","追月開始2","4","艾卓光效","32",
                    "右轉槍","右轉槍2",
                    "開啟狀態2","4","開啟狀態3","戰死動畫2","12",
                    "DAMAGE_ANIM","16","Can Collapse","Afterimage OFF","FLEE_RESET"
                   ],
  
  "死神發動" => ["Afterimage ON","死神發動","4","艾卓光效","TINT_SCREEN_BLACK","38",
                 "死神前進","4","突刺開始2","出突刺","DAMAGE_ANIM",
                 "出突刺2","DAMAGE_ANIM","2","出突刺3","DAMAGE_ANIM_WAIT",
                 "死神前跳","4",
                 "艾卓死神cast","死神發動","32","死神攻擊動畫","12",
                 "震地跳起","追月開始2",
                 "16","死神打雷","DAMAGE","SHAKE_SCREEN2","NORMAL_SCREEN_COLOR",
                 
                 "Can Collapse","Afterimage OFF","FLEE_RESET"
                 #"敵人是否流血","死神前進","DAMAGE_ANIM","16"
                 ],
  
   "死神煉獄" => ["Afterimage ON","死神發動","4","艾卓光效","TINT_SCREEN_BLACK","38","死神前進2",
                  "死神發動","16","死神出現動畫","80","死神出招","死神前進3","32",
                  "死神發動","DAMAGE_ANIM","SHAKE_SCREEN2","16",
                  "死神大招","DAMAGE","SHAKE_SCREEN2",
                  "NORMAL_SCREEN_COLOR","16","Can Collapse","Afterimage OFF","FLEE_RESET"
                  ],              
                 
  "三連刺2" => ["Afterimage ON","JUMP_BACK2","VICTORY_POSE2","閃爍","光效2","MOVE_TO_TARGET2","Afterimage OFF","START_SPEAR_THRUST","4",
      "END_SPEAR_THRUST","DAMAGE_ANIM",
      "START_SPEAR_THRUST","END_SPEAR_THRUST2","DAMAGE_ANIM",
      "START_SPEAR_THRUST","END_SPEAR_THRUST3","DAMAGE_ANIM_WAIT","16","Can Collapse","LINK_SKILL_144", "FLEE_RESET"],
  "連刺" => ["Afterimage ON","JUMP_BACK2","VICTORY_POSE2","閃爍","Afterimage OFF",
      "START_SPEAR_THRUST","END_SPEAR_THRUST2","SHAKE_SCREEN","DAMAGE_ANIM102s","DAMAGE","144","16","Can Collapse","FLEE_RESET"],
  # "三連刺" => ["Afterimage ON","JUMP_BACK2","STANDBY_POSE3","閃爍","光效2","MOVE_TO_TARGET2","Afterimage OFF","START_SPEAR_THRUST","4",
  #-------------------------------------------------------------------------
  # AlphaWhelp's Throwing Attacks - Action Sequences
  #-------------------------------------------------------------------------
  "THROW_RETURN_ATTACK" => ["STEP_FORWARD","WPN_SWING_V","STAND_POSE",
      "START_WEAPON_THROW","12","DAMAGE_ANIM_WAIT","Can Collapse",
      "END_WEAPON_THROW", "12", "COORD_RESET"],

  "THROW_STICKY_ATTACK" => ["STEP_FORWARD","WPN_SWING_V","STAND_POSE",
      "STICKY_THROW","12","DAMAGE_ANIM_WAIT",
      "Can Collapse","COORD_RESET"],

  "THROW_MULTIPLE_ATTACK" => ["STEP_FORWARD","WPN_SWING_V","STAND_POSE",
      "SHURIKEN_THROW","12","DAMAGE_ANIM_WAIT","WPN_SWING_V","bow1",
      "STAND_POSE","SHURIKEN_THROW","12","DAMAGE_ANIM_WAIT","WPN_SWING_V",
      "bow1","STAND_POSE","SHURIKEN_THROW","12","DAMAGE_ANIM_WAIT",
      "Can Collapse","COORD_RESET"],      
  #-------------------------------------------------------------------------
  # Mr. Bubble's TK Slam - Action Sequences
  #-------------------------------------------------------------------------
  # Caster's Sequence
  "TKSLAM"          => ["STEP_FORWARD", "STAND_POSE", "CAST_ANIMATION", "45",
                        "TKSLAM_ANIM", "TKSLAM_ENEMY", "120", 
                          "DAMAGE_ANIM", "60","One Wpn Only","16","Can Collapse","FLEE_RESET"],
                          
  # Enemy's Sequence
  "TKSLAM_ENEMYMOVE" => ["TKSLAM_ENEMYROTATE","TKSLAM_ENEMYFLOAT", "50","drop_sound",
                        "TKSLAM_ENEMYDROP", "30"],
  #-------------------------------------------------------------------------
  # Kylock's Gun Attack - Action Sequence
  #-------------------------------------------------------------------------
  "GUN_ATTACK" => ["JUMP_AWAY","WPN_SWING_V","30","GUNSHOT","WPN_SWING_V",
      "DAMAGE_ANIM_WAIT","12","WPN_SWING_VL","OBJ_ANIM_L","One Wpn Only",
      "16","Can Collapse","JUMP_TO","COORD_RESET"],
  #-------------------------------------------------------------------------
  # Stationary Attack and Skill - Action Sequences
  #-------------------------------------------------------------------------
  "STATIONARY_ATTACK" => ["10","ANIM_WAIT","DAMAGE","Can Collapse","RESET"],
  
  "STATIONARY_SKILL" => ["STAND_POSE","CAST_ANIMATION",
                          "WPN_SWING_UNDER","WPN_RAISED","WPN_SWING_V",
                        "ANIM_WAIT","DAMAGE","Can Collapse","24","RESET"],
  #-------------------------------------------------------------------------
  # Hyper Barrage - Action Sequence
  #-------------------------------------------------------------------------
  # Hyper Barrage
  "HYPERBARRAGE" => ["STEP_FORWARD","DRAW_BOW", "DRAW_POSE", "16", 
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "DRAW_BOW", "SHOOT_ARROW", "DRAW_POSE","HYPERBARRAGE_ANIM", "7","DAMAGE_ANIM",
      "Can Collapse", "20", "COORD_RESET"],
  #-------------------------------------------------------------------------
  # Jump Attack - Action Sequence
  #-------------------------------------------------------------------------
  # Jump Attack
  "JUMPATTACK" => ["STEP_FORWARD","Afterimage ON","se-Jump1","JUMPATTACK_JUMP1",
                  "JUMPATTACK_MOVE", "30",
                  "JUMPATTACK_JUMP2", "WEAPON_DAMAGE","Can Collapse",
                  "JUMPATTACK_RESET", "Afterimage OFF"],
  #-------------------------------------------------------------------------
  # Giant Toss - Action Sequences
  #-------------------------------------------------------------------------
  # Giant Toss
  "GIANT_TOSS"          => ["MOVE_TO_TARGET", "GIANTTOSS_MOVE","STAND_POSE",
                          "GIANTTOSS_ANGLE","GIANTTOSS_EACTION1", "55", 
                          "GIANTTOSS_ANGLERESET","GIANTTOSS_EACTION2", "60",
                          "GIANTTOSS_ANIM","DAMAGE_ANIM", "20",
                          "Can Collapse","FLEE_RESET"],

  # Giant Toss: Enemy Sequence
  "GIANT_TOSS_ESEQ"     => ["Afterimage ON","CLOCKWISE_TURN","GIANTTOSS_EJUMP",
                            "Afterimage OFF"],
  #-------------------------------------------------------------------------
  # Omnislash - Action Sequence
  #-------------------------------------------------------------------------
  "OMNISLASH"  => [    "STEP_FORWARD", "CAST_ANIMATION", "STAND_POSE", 
                "60", "Afterimage ON",            "OMNISLASH_JUMP",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_JUMP", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_MOVE", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_JUMP", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_MOVE", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_MOVE", "8", #5
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_MOVE", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_JUMP", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_JUMP", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_MOVE", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_MOVE", "8", #10
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_JUMP", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_MOVE", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_JUMP", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_MOVE", "8",
                "WPN_SWING_V", "WEAPON_DAMAGE", "OMNISLASH_JUMP",
                "CAST_ANIMATION", "60","OMNISLASH_JUMP",
                "WPN_SWING_V", "WEAPON_DAMAGE", #15
                "60", "Afterimage OFF",
                "Can Collapse", "FLEE_RESET"],
  #-------------------------------------------------------------------------
  # Backstab - Action Sequence
  #-------------------------------------------------------------------------
  "BACKSTAB"      => ["STEP_FORWARD", "CAST_ANIMATION", "STAND_POSE", 
                        "45","PORTAL_WARP","12", "Invert",
                        "WPN_SWING_V", "DAMAGE_ANIM","30",
                        "Can Collapse", "Invert","FLEE_RESET"],
  #-------------------------------------------------------------------------
  # Harp Attack - Action Sequence
  #-------------------------------------------------------------------------
  "HARP_ATTACK" => ["STEP_FORWARD","WPN_SWING_V", "FLYING_NOTES", "35",
                "DAMAGE_ANIM","One Wpn Only",
                "25","Can Collapse","COORD_RESET"],
  #-------------------------------------------------------------------------
  # Throw Item - Action Sequence
  #-------------------------------------------------------------------------
  "THROW_ITEM"           => ["STEP_FORWARD","STAND_POSE",
                            "STICKY_THROW","12","DAMAGE_ANIM_WAIT",
                            "Can Collapse","COORD_RESET"],
                            
  "THROW_ITEM2"           => ["STEP_FORWARD",
                              "STAND_POSE3","10","STICKY_THROW2","THROUGH_POSE","12","DAMAGE_ANIM",
                              "STAND_POSE3","10","STICKY_THROW2","THROUGH_POSE","12","DAMAGE_ANIM",
                              "STAND_POSE3","10","STICKY_THROW2","THROUGH_POSE","12","DAMAGE_ANIM_WAIT",
                              "Can Collapse","COORD_RESET"],
  #-------------------------------------------------------------------------
  # Strange Cut-in - Action Sequence
  #-------------------------------------------------------------------------
  "STRANGE_CUT_IN"           => ["STEP_FORWARD","CAST_ANIMATION","STAND_POSE",
                            "SHOW_PICTURE_1","ROTATE_PICTURE_1(CCW)",
                            "TINT_PICTURE_1_BLUE","120", "TINT_SCREEN_RED",
                            "MOVE_PICTURE_1","STICKY_THROW","NORMAL_SCREEN_COLOR",
                            "12","RED_FLASH",
                            "absorb1","SHAKE_SCREEN","DAMAGE_ANIM_WAIT",
                            "Can Collapse","RESET","CLEAR_ALL_PICTURES"],
  #-------------------------------------------------------------------------
  # Antipode - Action Sequence
  #-------------------------------------------------------------------------
  # Antipode
  "ANTIPODE"      => [
                  "CAST_ANIMATION", "STAND_POSE","45",
                  "ANTIPODE_MOVE_1",
                  "STAND_POSE",
                  "75", "ICE_BLOCK", "DAMAGE_ANIM", "10", 
                  "CAST_ANIMATION", "60", 
                  "WPN_SWING_V", "TINT_SCREEN_RED","FIREBALL(SHOOT)",
                  "23", "FIREBLAST", "10", "STAND_POSE",
                  "DAMAGE_ANIM", "56", 
                  "NORMAL_SCREEN_COLOR",
                  "Can Collapse","FLEE_RESET"],
  # Sequence animation for assist actor.
  "ANTIPODE_ASSIST" => ["CAST_ANIMATION","STAND_POSE","45", 
                          "ANTIPODE_MOVE_2", 
                            "STAND_POSE",
                           "60", "WPN_SWING_V", 
                          "TINT_SCREEN_BLUE","ICEBALL(SHOOT)", "10",
                          "STAND_POSE","195", 
                          "FLEE_RESET"],
  #-------------------------------------------------------------------------
  # Southern Cross - Action Sequence
  #-------------------------------------------------------------------------
  # Southern Cross Attacker Anim sequence
  "SOUTHERN_CROSS"      => [
                          "SOUTHCROSS_ASSISTANIME", "STAND_POSE", 
                          "STEP_FORWARD","CAST_ANIMATION","STAND_POSE", 
                          "60", "SOUTHCROSS_MOVE1","WPN_SWING_V", "40", 
                          "SOUTHCROSS_ANIM","SOUTHCROSS_MOVE2", "WPN_RAISED", 
                          "60", "DAMAGE_ANIM", "95",
                          "Can Collapse",
                          "FLEE_RESET", "SOUTHCROSS_STATEREMOVE"],
                          
  # Sequence animation for assist actor.
  "SOUTHERN_CROSS_ASSIST" => ["STAND_POSE", "STEP_FORWARD",
                          "CAST_ANIMATION", "STAND_POSE","60",
                          "SOUTHCROSS_MOVE3", "Invert", "WPN_SWING_V", "87", 
                          "SOUTHCROSS_MOVE4", "STAND_POSE",  "WPN_RAISED", 
                          "108", "Invert",
                          "FLEE_RESET"],

  #-------------------------------------------------------------------------
  # Hide Battler (during animation) - Action Sequence
  #-------------------------------------------------------------------------
  
  "EXAMPLE_ANIM_ON_SELF" => ["STEP_FORWARD","STAND_POSE","INVISIBLE_POSE",
                            "ANIM_ON_SELF_WAIT", 
                            "DAMAGE","Can Collapse", "RESET"],
  
  } # <-- Do not delete this.
  ACTION.merge!(PREMADE_ACTION_SEQUENCES)
end