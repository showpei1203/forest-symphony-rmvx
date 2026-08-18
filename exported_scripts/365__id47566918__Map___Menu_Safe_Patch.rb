#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Map / Menu Safe Patch
# 【用途】UI／選單元件「Map / Menu Safe Patch」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Scene_Base、Scene_Menu
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意。
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
# ■ Albert RMVX Map / Menu Safe Patch
#------------------------------------------------------------------------------
# 放置位置：
#   所有「地圖 / MENU」相關素材之下、Main 之上。
#
# 目的：
#   1. 修正 YEM Main Menu + Quest Journal 造成的重複任務指令風險
#   2. 修正 FF13 Menu 固定只建立 8 個選單圖片，但實際指令可能超過 8 個
#   3. 讓選單背景 dispose 比較安全，避免雙重 dispose 造成錯誤
#
# 注意：
#   ISS - ParaPassa 裡的「class Scene_Map < Scene_Map」無法靠本補丁修正，
#   因為那一行若在 Main 前執行，遊戲會在讀到該頁時就中止。
#   必須直接到 ISS - ParaPassa 腳本，把：
#     class Scene_Map < Scene_Map
#   改成：
#     class Scene_Map
#==============================================================================

#==============================================================================
# ■ YEM Main Menu / Quest Journal Duplicate Guard
#------------------------------------------------------------------------------
# QJ2 在 YEM Main Menu Melody 存在時，會無條件插入 :quest2。
# 但你的 YEM::MENU::MENU_COMMANDS 裡已經手動放了 :quests1，
# 且 QJ2 後面的設定 MENU_ACCESS 可能是 false。
# 這裡避免任務指令重複，降低 FF13 Menu 指令數超過圖片數的風險。
#==============================================================================

if defined?(YEM) && defined?(YEM::MENU) && defined?(YEM::MENU::MENU_COMMANDS)
  if YEM::MENU::MENU_COMMANDS.include?(:quests1) &&
     YEM::MENU::MENU_COMMANDS.include?(:quest2)
    YEM::MENU::MENU_COMMANDS.delete(:quest2)
  end
  if defined?(QuestData) && QuestData.const_defined?(:MENU_ACCESS)
    unless QuestData::MENU_ACCESS
      YEM::MENU::MENU_COMMANDS.delete(:quest2)
    end
  end
end


#==============================================================================
# ■ Scene Base Safe Menu Background Dispose
#==============================================================================

class Scene_Base
  def dispose_menu_background
    if @menuback_sprite && @menuback_sprite.respond_to?(:disposed?)
      @menuback_sprite.dispose unless @menuback_sprite.disposed?
    elsif @menuback_sprite
      @menuback_sprite.dispose
    end
  end
end


#==============================================================================
# ■ FF13 / YEM Menu Sprite Safety
#------------------------------------------------------------------------------
# FF13 Layout 固定建立 Menu01 ~ Menu08 八張圖。
# 但 YEM / QJ / 其他插件可能讓指令數變成 9 個以上。
# 如果 @command_window.index 到 8，原本 @sprites[8] 會是 nil。
#==============================================================================

class Scene_Menu < Scene_Base
  unless method_defined?(:albert_mapmenu_safe_start)
    alias albert_mapmenu_safe_start start
  end

  def start
    albert_mapmenu_safe_start
    albert_ensure_menu_command_sprites
  end

  def albert_menu_command_count
    if @command_window && @command_window.respond_to?(:item_max)
      return @command_window.item_max
    end
    if defined?(YEM) && defined?(YEM::MENU) && defined?(YEM::MENU::MENU_COMMANDS)
      return YEM::MENU::MENU_COMMANDS.size
    end
    return @sprites ? @sprites.size : 0
  end

  def albert_ensure_menu_command_sprites
    return unless @sprites.is_a?(Array)
    count = [albert_menu_command_count, @sprites.size].max
    return if count <= @sprites.size

    while @sprites.size < count
      i = @sprites.size
      sprite = Sprite.new

      # 優先使用 Menu09、Menu10...；如果沒有，就複用最後一張圖。
      filename = sprintf("Menu%02d", i + 1)
      begin
        sprite.bitmap = Cache.menu(filename)
      rescue
        last = @sprites.compact.reverse.find { |s| s && !s.disposed? && s.bitmap }
        sprite.bitmap = last ? last.bitmap : Bitmap.new(1, 1)
      end

      if sprite.bitmap
        sprite.x = (i * -10) + 30 + 90 if i >= 4
        sprite.x = (i * 10) - 30 + 80 if i < 4
        sprite.y = (i * sprite.height * 1.307 + (Graphics.height - sprite.height) / 1.5) - 171
      end
      sprite.opacity = 255
      sprite.z = 9999
      sprite.tone = Tone.new(0, 0, 0, 255)
      @sprites[i] = sprite
    end
  end

  # 保險：離開選單時，把第 9 張以後的 sprite 也處理掉。
  # 不取代原本 terminate，避免破壞 FF13 / YEM 的清理鏈，只補漏網之魚。
  unless method_defined?(:albert_mapmenu_safe_terminate)
    alias albert_mapmenu_safe_terminate terminate
  end

  def terminate
    albert_mapmenu_safe_terminate
    if @sprites.is_a?(Array)
      @sprites.each do |sprite|
        next if sprite == nil
        next if sprite.disposed?
        sprite.dispose
      end
    end
  end
end

