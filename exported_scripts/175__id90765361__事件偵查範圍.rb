#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：事件偵查範圍
# 【用途】地圖／事件元件「事件偵查範圍」。
# 【主要機制】擴充 Game_Map／Game_Event／Game_Character／Spriteset_Map 或事件 Script Call。
# 【主要影響】Game_Event、MOG
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SENSOR_KEY。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】Moghunter。原作者 Credits／License／網址等原文仍保留在下方。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#==============================================================================
# MOG VX - Event Sensor Range
#==============================================================================
# By Moghunter 
# http://www.atelier-rgss.com/
#
# ■ Ativa uma determinada página (SELF SWITCH D)do evento dependendo da
# distância do personagem. Isso serve para o evento ter 2 comportamentos
# uma quando o personagem estiver perto e outro para quando o personagem 
# estiver longe, útil para fazer puzzles ou eventos inimigos.
# ---------------------------------------------------------------------------
# Para definir a distância do sensor do evento basta colocar no nome
# a seguinte syntax.
#
# <sensorX>
#
# X - Distância do sensor.
#
# Ex - <sensor5>
# ---------------------------------------------------------------------------
# NOTA - Não esqueça de criar uma nova página com a chave de ativação, está
# página será ativada quando o personagem entrar no sensor do evento.
#==============================================================================
module MOG
  # Definição da chave de switch. ( A, B , C ,D )
  SENSOR_KEY = "D"
end  
#==============================================================================
# Game_Event
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● initialize
  #--------------------------------------------------------------------------
  alias mog_sensor_range initialize
  def initialize(map_id, event)
    if event.name =~ /<sensor(\d+)>/i
        @sensor_range = $1.to_i
    else    
        @sensor_range = 0
    end
    @key_act = false
    @key_act_old = @key_act
    mog_sensor_range(map_id, event)    
  end    
  #--------------------------------------------------------------------------
  # ● update
  #--------------------------------------------------------------------------
  alias mog_sensor_update update
  def update
      mog_sensor_update
      if @sensor_range > 0
         sx = distance_x_from_player
         sy = distance_y_from_player
         range = (sx.abs + sy.abs)
         sensor = (range >= @sensor_range)      
         if sensor
            @key_act = false
          else
            @key_act = true
         end
       end  
     page_check if @key_act_old != @key_act
   end  
  #--------------------------------------------------------------------------
  # ● page_check
  #--------------------------------------------------------------------------   
   def page_check
      @key_act_old = @key_act
      key = [@map_id, @event.id, MOG::SENSOR_KEY]
      $game_self_switches[key] = @key_act
      refresh
   end
end


$mog_rgssvx_event_sensor_range = true

