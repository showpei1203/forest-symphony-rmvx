#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：狀態動畫顯示
# 【用途】保留的 Runtime 元件「狀態動畫顯示」。
# 【主要機制】主要定義／擴充 State、N01、RPG；下方原始說明與程式碼保留作細節依據。
# 【主要影響】State、N01、RPG
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：VS_ANIME、VS_ACTION。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
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
#--------------------------------------------------------------------------
# FF Style State Animation Sequence for Kaduki SBS
# Credits to Enu, Mr. Bubble and Hanzo Kimura (for modifications)
# Further Modified by SoFresh85 12/13/2009
#--------------------------------------------------------------------------
module N01
#STATE ANIMATION ID
#--------------------------------------------------------------------------
VS_ANIME = {
  # ANIME Key               Type   ID  Object Invert  Wait  Weapon2 
  "AN_BUFF"           => ["anime",  29,  0,    false,  false, false],
  "AN_FIRE"           => ["anime",  27,  0,    false,  false, false],
  "AN_DEBUFF"         => ["anime",  28,  0,    false,  false, false],
  "AN_POISON"         => ["anime",  2,  0,    false,  false, false],
  "AN_POISON2"         => ["anime",  3,  0,    true,  false, false],
  "AN_BLIND"          => ["anime",  55,  0,   false,  false, false],
  "AN_CONFUSE"        => ["anime",  56,  0,   false,  false, false],
  "AN_熊狀態"          => ["anime",  86,  0,    true,  false, false],
  "AN_狼狀態"          => ["anime",  87,  0,    true,  false, false],
  "AN_死神狀態"        => ["anime", 104,  0,    true,  false, false],
  "AN_戰神狀態"        => ["anime", 105,  0,    true,  false, false],
  "AN_STUN"           => ["anime",  55,  0,   false,  false, false]
  }
  
ANIME.merge!(VS_ANIME)  
#--------------------------------------------------------------------------
# �—� ACTION STATE SEQUENCE
#-------------------------------------------------------------------------- 
#    State               Control     Movement      Anim Call  Duration(60=1 sec)    
  VS_ACTION = {
    "ST_POISON"      => ["AN_POISON","BAD_POSE", "5"],
    "ST_BUFF"        => ["NO_MOVE", "WAIT","AN_BUFF", "30"],#正面狀態
    "ST_FIRE"        => ["NO_MOVE", "WAIT","AN_FIRE", "30"],#正面狀態
    "ST_DEBUFF"      => ["BAD_POSE","AN_DEBUFF", "15"],#負面狀態
    "ST_熊狀態"      => ["STANDBY_POSE","NO_MOVE","AN_熊狀態","30"],
    "ST_狼狀態"      => ["STANDBY_POSE","NO_MOVE","AN_狼狀態","30"],
    "ST_死神狀態"    => ["STANDBY_POSE2","NO_MOVE","AN_死神狀態","30"],
    "ST_戰神狀態"    => ["STANDBY_POSE2","NO_MOVE","AN_戰神狀態","30"],
    "ST_BLIND"       => ["NO_MOVE", "WAIT", "AN_BLIND", "60"],
    "ST_CONFUSE"     => ["NO_MOVE", "WAIT", "AN_CONFUSE", "60"],
    "ST_STUN"        => ["NO_MOVE", "WAIT (FIXED)", "AN_STUN", "10"],
    } #DO NOT REMOVE THIS
    
ACTION.merge!(VS_ACTION)

end
#--------------------------------------------------------------------------
#ACTION STATE SEQUENCE "when" triggers State ID and "return" triggers VS_Action
#-------------------------------------------------------------------------- 
module RPG
  class State
    alias vs_state_base_action base_action
    def base_action
    case @id
     #when 2    #This is the State ID from the database Being used.
     # return "ST_POISON"   #This is the VS_Action that will occur.
     #when 13,14,15,16
     # return "ST_DEBUFF"
     #when 21   #This is the State ID from the database Being used.
     # return "ST_熊狀態"   #This is the VS_Action that will occur.
     #when 22   #This is the State ID from the database Being used.
     # return "ST_狼狀態"   #This is the VS_Action that will occur.
      #when 27   #This is the State ID from the database Being used.
      #return "ST_死神狀態"   #104This is the VS_Action that will occur.
      when 28   #This is the State ID from the database Being used.
      return "ST_戰神狀態"   #105This is the VS_Action that will occur.
      #when 17,18,19,20,38,39,40,41,42,43,44
      #  return "ST_BUFF"
      #when 51
      #  return "ST_FIRE"
    end
      vs_state_base_action
    end
  end
end