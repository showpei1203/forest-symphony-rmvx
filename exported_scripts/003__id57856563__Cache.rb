#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Cache
# 【用途】VX 圖像快取模組，統一載入並快取 Animation、Battler、Character、Face、Picture、System 等 Bitmap。
# 【主要機制】相同路徑與色相會共用 Bitmap，避免重複 I/O；Forest Symphony 另外擴充 logo／save／menu 路徑。
# 【主要影響】Cache
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
# ** Cache
#------------------------------------------------------------------------------
#  這個模組先載入每個圖像素材[圖檔]並建立 Bitmap 物件，然後預留之。
#  為了節省載入時間並節省記憶體，這個模組將已經建成的 Bitmap 物件載入至內部 
#  HASH 表， 並允許程式在需要重複調用相同的圖檔的時候能夠返回事先存在的物件。
#==============================================================================

module Cache
  #--------------------------------------------------------------------------
  # * 獲取動畫膠片圖檔
  #     filename : 圖檔名
  #     hue      : 偏色度[色調]
  #--------------------------------------------------------------------------
  def self.animation(filename, hue)
    load_bitmap("Graphics/Animations/", filename, hue)
  end
  #--------------------------------------------------------------------------
  # * 獲取參戰者圖檔
  #     filename : 圖檔名
  #     hue      : 偏色度[色調]
  #--------------------------------------------------------------------------
  def self.battler(filename, hue)
    load_bitmap("Graphics/Battlers/", filename, hue)
  end
  #--------------------------------------------------------------------------
  # * 獲取人物特徵圖檔
  #     filename : 圖檔名
  #--------------------------------------------------------------------------
  def self.character(filename)
    load_bitmap("Graphics/Characters/", filename)
  end
  #--------------------------------------------------------------------------
  # * 獲取頭像圖檔
  #     filename : 圖檔名
  #--------------------------------------------------------------------------
  def self.face(filename)
    load_bitmap("Graphics/Faces/", filename)
  end
  #--------------------------------------------------------------------------
  # * 獲取遠景圖檔
  #     filename : 圖檔名
  #--------------------------------------------------------------------------
  def self.parallax(filename)
    load_bitmap("Graphics/Parallaxes/", filename)
  end
  #--------------------------------------------------------------------------
  # * 獲取圖片檔案[供“顯示圖片……”事件指令調用]
  #     filename : 圖檔名
  #--------------------------------------------------------------------------
  def self.picture(filename)
    load_bitmap("Graphics/Pictures/", filename)
  end
  #--------------------------------------------------------------------------
  # * 獲取系統介面圖檔
  #     filename : 圖檔名
  #--------------------------------------------------------------------------
  def self.system(filename)
    load_bitmap("Graphics/System/", filename)
  end
  def self.logo(filename)
    load_bitmap("Graphics/Logo/", filename)
  end
  def self.save(filename)
    load_bitmap("Saves/", filename)
  end
  def self.menu(filename)
    load_bitmap("Graphics/Menu/", filename)
  end
  #--------------------------------------------------------------------------
  # * 清空緩存
  #--------------------------------------------------------------------------
  def self.clear
    @cache = {} if @cache == nil
    @cache.clear
    GC.start
  end
  #--------------------------------------------------------------------------
  # * 載入圖檔
  #--------------------------------------------------------------------------
  def self.load_bitmap(folder_name, filename, hue = 0)
    @cache = {} if @cache == nil
    path = folder_name + filename
    if not @cache.include?(path) or @cache[path].disposed?
      if filename.empty?
        @cache[path] = Bitmap.new(32, 32)
      else
        @cache[path] = Bitmap.new(path)
      end
    end
    if hue == 0
      return @cache[path]
    else
      key = [path, hue]
      if not @cache.include?(key) or @cache[key].disposed?
        @cache[key] = @cache[path].clone
        @cache[key].hue_change(hue)
      end
      return @cache[key]
    end
  end
end
