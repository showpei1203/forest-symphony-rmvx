#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：SBS General Settings [3.4d]
# 【來源】Tankentai Sideview Battle System 3.4d 系列；Credits 包含 Kylock、Mr. Bubble、Shu、Moonlight、NightWalker、Enelvon、Atoa、AlphaWhelp、blackmorning、Mithran、Kaduki、Enu 等。
# 【用途】Tankentai SBS 的全域基礎設定。此頁先建立 module N01 常數，後續 SBS Battler Configuration、Sideview Core、Add-ons 與 FS Action Sequence 都依賴這些 Key／常數。
# 【隊伍位置】ACTOR_POSITION 目前提供 6 組座標；SUMMON_ACTOR_POSITION 提供 3 組召喚位置；MAX_MEMBER=6。若調高 MAX_MEMBER，ACTOR_POSITION 必須同步補足座標。
# 【戰鬥節奏】ACTION_WAIT=12、COLLAPSE_WAIT=12、WIN_WAIT=70，單位皆以 1/60 秒 frame 計。這些是 SBS 演出等待，不等同 FS ATB 蓄力速度。
# 【Help／敵人資訊】GUARD_HELP_TEXT='防禦'、ESCAPED_HELP_TEXT='逃跑'；WORD_STATE_DISPLAY=true、HP_DISPLAY=true、ACTOR_DISPLAY=false。Enemy Note 可用 <hide states> 隱藏狀態、<hide hp> 隱藏 HP；ENEMY_NON_DISPLAY／STATE_NON_DISPLAY 可按 ID 全域排除。
# 【場地／游標】FLOOR=[0,96,128] 為 BattleFloor X/Y/Opacity；CURSOR_X_PLUS／CURSOR_Y_PLUS 調整目標游標偏移。
# 【動畫／素材】BALLOON_GRAPHICS='Balloon'（Graphics/System）；NO_WEAPON=36 為無武器攻擊 Animation ID；RESURRECTION=41 為 Auto-Life 復活 Animation。Damage Popup 使用 Number+、Number-、MP_Number+、MP_Number-，並由 NUM_INTERBAL、NUM_DURATION 控制字距／存續時間。
# 【Battler 圖像】SHADOW=false；WALK_ANIME=false 時需要 Graphics/Characters/<filename>_1、_2...，尺寸需一致；ANIME_PATTERN=3、ANIME_KIND=4。
# 【背襲】BACK_ATTACK=false；NON_BACK_ATTACK_WEAPONS／ARMOR1~4／SKILLS 可指定防背襲來源，BACK_ATTACK_SWITCH 為 Switch 清單。BACK_ATTACK_NON_BACK_MIRROR 在原系統標示尚未實作。
# 【不死狀態相容】若其他腳本透過非標準 method 改 @immortal，可把方法名字串加入 IMMORTALITY_CHANGING_METHODS；目前只有 'your_method_here' 範例，未實測，不應當成正式 FS API。
# 【載入順序】這是 SBS 基礎設定頁，必須位於 Battler Configuration／Sideview 1/2／SBS Add-ons／FS SBS Action 之前；Action Key 與常數名不可中文化改名。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本說明固定置於腳本最前方；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 方法名、常數名、Notetag、Script Call、SBS Action Key、實際資料字串不可因中文化而改名。
# 3. 原作者、版本、Credits、License、網址保留；Phase 19 Archive 另保存翻譯前 byte-exact 原稿。
# 4. 本輪只整理文件／註解；Runtime code 與載入順序不得因翻譯而改變。
#==============================================================================
#==============================================================================
#------------------------------------------------------------------------------
#               Enu ( http://rpgex.sakura.ne.jp/home/ )
#==============================================================================

$imported = {} if $imported == nil
$imported["TankentaiSideview"] = true

#==============================================================================
#------------------------------------------------------------------------------
#==============================================================================
module N01
 #--------------------------------------------------------------------------
 #-------------------------------------------------------------------------- 
  #
  #                   X   Y     X   Y     X   Y     X   Y     X   Y     X   Y
  ACTOR_POSITION = [[390,125],[450,155],[410,195],[70, -100],[495,240],[515,270]]
  SUMMON_ACTOR_POSITION = [[350, 100],[310, 120],[350, 150]]
  MAX_MEMBER = 6
 #-------------------------------------------------------------------------- 
 #-------------------------------------------------------------------------- 
  ACTION_WAIT = 12
  COLLAPSE_WAIT = 12
  WIN_WAIT = 70
 #-------------------------------------------------------------------------- 
 #-------------------------------------------------------------------------- 
  GUARD_HELP_TEXT = "防禦"
  ESCAPED_HELP_TEXT = "逃跑"
 #--------------------------------------------------------------------------
 #-------------------------------------------------------------------------- 
  #
  WORD_STATE_DISPLAY = true
  #
  HP_DISPLAY = true
  ACTOR_DISPLAY = false  
  WORD_NORMAL_STATE = "正常"
  ENEMY_NON_DISPLAY = []#[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,26,27]  # ex.[1,2,3]
  STATE_NON_DISPLAY = []  # ex.[1,2,3]
 #-------------------------------------------------------------------------- 
 #-------------------------------------------------------------------------- 
  # FLOOR = [ X-position, Y-positon, Opacity]
  FLOOR = [0,96,128]
 #-------------------------------------------------------------------------- 
 #-------------------------------------------------------------------------- 
  CURSOR_X_PLUS = 0
  CURSOR_Y_PLUS = 0
 #-------------------------------------------------------------------------- 
 #-------------------------------------------------------------------------- 
  BALLOON_GRAPHICS = "Balloon"
 #-------------------------------------------------------------------------- 
 #-------------------------------------------------------------------------- 
  NO_WEAPON = 36
 #-------------------------------------------------------------------------- 
 #-------------------------------------------------------------------------- 
  RESURRECTION = 41
 #-------------------------------------------------------------------------- 
 #--------------------------------------------------------------------------
  DAMAGE_GRAPHICS = "Number+"
  RECOVER_GRAPHICS = "Number-"
  USE_MP_POP_GRAPHICS = true
  MP_DAMAGE_GRAPHICS = "MP_Number+"
  MP_RECOVER_GRAPHICS = "MP_Number-"
  NUM_INTERBAL = -1#-3
  # Duration (in frames) POP numbers are displayed.
  NUM_DURATION = 68
 #-------------------------------------------------------------------------- 
 #-------------------------------------------------------------------------- 
  # false: Pop-up Window skin is used.
  NON_DAMAGE_WINDOW = true
  POP_DAMAGE0 = "" # 詳見頁首繁中維護說明
  POP_MISS    = "未命中!" # 詳見頁首繁中維護說明
  POP_EVA     = "被閃躲!" # 詳見頁首繁中維護說明
  POP_CRI     = "爆擊!" # 詳見頁首繁中維護說明
  POP_MP_DAM  = "MP傷害" # 詳見頁首繁中維護說明
  POP_MP_REC  = "MP恢復" # 詳見頁首繁中維護說明
 #-------------------------------------------------------------------------- 
 #-------------------------------------------------------------------------- 
  # true: Allow the appearance shadows under battlers.
  SHADOW = false
  WALK_ANIME = false
  ANIME_PATTERN = 3
  ANIME_KIND = 4
 #-------------------------------------------------------------------------- 
 #-------------------------------------------------------------------------- 
  # true: Allow back attacks to occur.
  BACK_ATTACK = false
  BACK_ATTACK_NON_BACK_MIRROR = false
  NON_BACK_ATTACK_WEAPONS = []
  NON_BACK_ATTACK_ARMOR1 = []
  NON_BACK_ATTACK_ARMOR2 = []
  NON_BACK_ATTACK_ARMOR3 = []
  NON_BACK_ATTACK_ARMOR4 = []
  NON_BACK_ATTACK_SKILLS = []
  BACK_ATTACK_SWITCH = []
 #-------------------------------------------------------------------------- 
 #--------------------------------------------------------------------------
  IMMORTALITY_CHANGING_METHODS = ["your_method_here"] # 詳見頁首繁中維護說明
end


