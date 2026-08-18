#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Bubs' Bow Add-on (K)
# 【來源】Mr. Bubble，Bow Attack Action Sequence for RPG Tankentai Sideview Battle System v2.0（Kaduki）。
# 【用途】替 Tankentai SBS 增加弓箭專用 ANIME／ACTION Key，讓武器或技能可以播放拉弓 Pose、弓動畫、箭矢 Projectile、命中動畫與回位。
# 【安裝／依賴】必須位於 Tankentai Sideview 主腳本之後。原作以 Bubs' Notetags for TSBS 的 <action: BOW_ATTACK> 方式綁定，也可在 SBS Configurations 的 Weapon／Skill Action Sequence Settings 指派 BOW_ATTACK。
# 【Notetag 範例】在 Skill 或 Weapon Note：<action: BOW_ATTACK>。BOW_ATTACK 是實際 Action Key，不可翻譯改名。
# 【動畫設定】BOW_ANIMATION=83、BOW2=84；專案資料庫必須存在相對應 Animation。若改動畫 ID，只改常數，不要改 DRAW_BOW／DRAW_BOW2 Key 名稱。
# 【ANIME Key】DRAW_POSE／DRAW_POSE2／DRAW_POSE3 控制 Kaduki Pose；DRAW_BOW／DRAW_BOW2 在使用者上播放資料庫 Animation；ARROW_ANGLE 定義飛行角度；SHOOT_ARROW 是 m_a Moving Animation／Projectile 設定。
# 【ACTION】BOW_ATTACK 與 BOW_ATTACK2 依序執行 STEP_FORWARD → 拉弓／Pose → Wait → SHOOT_ARROW → Wait → DAMAGE_ANIM → Wait → Can Collapse → FLEE_RESET。Action Sequence 由左至右、由上至下處理，逗號與 Key 字串不可任意刪改。
# 【視覺調整】若箭矢看起來從腳部射出，應調整 SHOOT_ARROW 的 Y pitch／起點，而不是修改傷害流程。原配置已對 Y 軸做過補償。
# 【呼叫方式】不直接呼叫 Ruby method；由 SBS Action Dispatcher 透過 BOW_ATTACK Key 執行。
# 【相關素材】資料庫 Animation 83、84；實際 Bow／Arrow 圖像由 SBS Weapon／Animation 設定引用，修改前反查 N01 Config 與資料庫動畫。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址等來源資訊保留；Phase 18 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理註解／說明，不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder／Authority 文件為準。
#==============================================================================
#==============================================================================
#   v2.0 (Kaduki)
#------------------------------------------------------------------------------
#  Script by Mr. Bubble
#------------------------------------------------------------------------------
#==============================================================================
#
#   [With Notetag]
#
#               <action: BOW_ATTACK>
#
#
#   [Battler Configuration]
#==============================================================================

module N01
  BOW_ANIMATION = 83
  BOW2 = 84
#------------------------------------------------------------------------------
  BOW_ANIME = {
  
  
  "伸出"       => [  3,   0,true, 45,  45,  4,false,   0,  0,  8,  -6,false],
  "DRAW_POSE2" => [ 3,  1,  1,   2,   0,  -1,   0, true,"伸出" ],
  "DRAW_POSE3" => [ 3,  1,  3,   1,   0,  -1,   0, true,"伸出" ],
  "DRAW_POSE"  => [ 3,  1,  3,   2,   0,  -1,   0, true,"" ],
  "DRAW_BOW"  => ["anime",  BOW_ANIMATION,  0, false, false, false],
  "DRAW_BOW2"  => ["anime",  BOW2,  0, false, false, false],
  "ARROW_ANGLE"     => [ 30, 60,  11],
    
  "SHOOT_ARROW"  => ["m_a", 0,  0,   0, 15,  -10,  0, 0, 0,false,"ARROW_ANGLE"],   
  } # ← 此結構不可刪除。
  ANIME.merge!(BOW_ANIME)
  
  # Action Sequence 動作序列
  BOW_ATTACK_ACTION = {
  # 
  
  # Action Key
  "BOW_ATTACK" => [ # Anime Keys
                  "STEP_FORWARD", # 戰鬥者稍微向前一步
                  "DRAW_BOW",     # 在使用者身上播放拉弓動畫
                  "DRAW_POSE",    # 播放 Kaduki Pose
                  "16",           # 等待 16 幀
                  "SHOOT_ARROW",  # 向目標發射箭矢 Projectile
                  "12",           # 等待 12 幀
                  "DAMAGE_ANIM",
                  "16",           # 等待 12 幀
                  "Can Collapse",
                  "FLEE_RESET"    # 戰鬥者回到起始座標
                  ],
  
  # Action Key
  "BOW_ATTACK2" => [ # Anime Keys
                  "弓一步向前移动", # 戰鬥者稍微向前一步
                  "DRAW_BOW2",     # 在使用者身上播放拉弓動畫
                  "DRAW_POSE2",    # 播放 Kaduki Pose
                  "5",           # 等待 16 幀
                  "米亞弓發射動畫",
                  
                  "23",
                  "DRAW_POSE2",
                  "米亞弓發射動畫2",
                  "23",
                  "DAMAGE_ANIM",
                  "16",           # 等待 12 幀
                  "Can Collapse",
                  "FLEE_RESET"    # 戰鬥者回到起始座標
                  ],
                  
 # Action Key
  "二連矢" => [ # Anime Keys
                  "弓一步向前移动", # 戰鬥者稍微向前一步
                  "DRAW_BOW2",     # 在使用者身上播放拉弓動畫
                  "DRAW_POSE2",    # 播放 Kaduki Pose
                  "1",
                  "SHOOT_ARROW",  # 向目標發射箭矢 Projectile
                  "12",
                  "DAMAGE_ANIM",
                  "DRAW_BOW2",     # 在使用者身上播放拉弓動畫
                  "DRAW_POSE2",    # 播放 Kaduki Pose
                  "1",
                  "SHOOT_ARROW",  # 向目標發射箭矢 Projectile
                  "12",
                  "DAMAGE_ANIM",
                  "16",           # 等待 12 幀
                  "Can Collapse",
                  "FLEE_RESET"    # 戰鬥者回到起始座標
                  ],
                  
 # Action Key
  "多重連矢" => [ # Anime Keys
                  "弓一步向前移动", # 戰鬥者稍微向前一步
                  "DRAW_BOW2",     # 在使用者身上播放拉弓動畫
                  "DRAW_POSE2",    # 播放 Kaduki Pose
                  #"1",
                  "SHOOT_ARROW",  # 向目標發射箭矢 Projectile
                  "4",
                  "DAMAGE_ANIM",
                  "DRAW_BOW2",     # 在使用者身上播放拉弓動畫
                  "DRAW_POSE2",    # 播放 Kaduki Pose
                  #"1",
                  "SHOOT_ARROW",  # 向目標發射箭矢 Projectile
                  "4",
                  "DAMAGE_ANIM",
                  "準備跳躍",
                  "5",
                  "連矢2S1",
                  
                  "DRAW_BOW2",     # 在使用者身上播放拉弓動畫
                  "DRAW_POSE2",    # 播放 Kaduki Pose
                  #"1",
                  "SHOOT_ARROW",  # 向目標發射箭矢 Projectile
                  "4",
                  "DAMAGE_ANIM",
                  
                  "DRAW_BOW2",     # 在使用者身上播放拉弓動畫
                  "DRAW_POSE2",    # 播放 Kaduki Pose
                  #"1",
                  "SHOOT_ARROW",  # 向目標發射箭矢 Projectile
                  "4",
                  "DAMAGE_ANIM",
                  "16",           # 等待 12 幀
                  "Can Collapse",
                  "FLEE_RESET"    # 戰鬥者回到起始座標
                  ],
  }
  ACTION.merge!(BOW_ATTACK_ACTION)
end