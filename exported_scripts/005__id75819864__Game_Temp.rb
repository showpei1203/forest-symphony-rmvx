#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Game_Temp
# 【用途】保存不寫入存檔的暫存資料，例如場景切換、戰鬥狀態、商店、名稱輸入與背景 Bitmap。
# 【主要機制】由 Scene、Interpreter、Battle 等流程共同使用；遊戲重新啟動或重建 Game_Temp 時會重置。
# 【主要影響】Game_Temp
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
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
# ** Game_Temp
#------------------------------------------------------------------------------
#  這個類用來操控那些不被包含於進度存檔中的資料。
#  這個類的實例被全域變數 $game_temp 所引用。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # * 宣告執行個體變數
  #--------------------------------------------------------------------------
  attr_accessor :next_scene               # 要切換到的場景（字串）
  attr_accessor :map_bgm                  # 地圖場景BGM（戰鬥前記憶用）
  attr_accessor :map_bgs                  # 地圖場景BGS（戰鬥前記憶用）
  attr_accessor :common_event_id          # 全域事件編號
  attr_accessor :in_battle                # 用來判斷是否在戰鬥的標幟
  attr_accessor :battle_proc              # 戰鬥回檔（進程）
  attr_accessor :shop_goods               # 交易交易品清單
  attr_accessor :shop_purchase_only       # 用來判斷交易是否單向交易的標幟
  attr_accessor :name_actor_id            # 名稱輸入處理：主角編號
  attr_accessor :name_max_char            # 名稱輸入處理：字元數上限
  attr_accessor :menu_beep                # 用來在菜單中判斷播放SE的標幟
  attr_accessor :last_file_index          # 上次使用的進度檔位元編號
  attr_accessor :debug_top_row            # 調試介面：存儲條件設置
  attr_accessor :debug_index              # 調試介面：存儲條件設置
  attr_accessor :background_bitmap        # 選單介面背景圖
  attr_accessor :target_index             # 暫存選到目標的index
  #--------------------------------------------------------------------------
  # * 物件初始化
  #--------------------------------------------------------------------------
  def initialize
    @next_scene = nil
    @map_bgm = nil
    @map_bgs = nil
    @common_event_id = 0
    @in_battle = false
    @battle_proc = nil
    @shop_goods = nil
    @shop_purchase_only = false
    @name_actor_id = 0
    @name_max_char = 0
    @menu_beep = false
    @last_file_index = 0
    @debug_top_row = 0
    @debug_index = 0
    @background_bitmap = Bitmap.new(1, 1)
    @target_index = 0
  end
end
