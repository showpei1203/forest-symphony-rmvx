#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：TPet_Window
# 【用途】UI／選單元件「TPet_Window」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】TPet_Window_Item、TPet_Status、TPet_Cursor
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：IconSet。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ■ TPet_Window_Item
#------------------------------------------------------------------------------
# 　エサ専用アイテム画面ウィンドウ
#==============================================================================

class TPet_Window_Item< Window_Item
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #     item : アイテム
  #--------------------------------------------------------------------------
  def include?(item)
    return false if item == nil
    if item.is_a?(RPG::Item)
      note = $data_items[item.id].note
    elsif item.is_a?(RPG::Weapon)
      note = $data_weapons[item.id].note
    else
      note = $data_armors[item.id].note
    end
    return true if note =~ /<餌>/i
    return false
  end
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #     item : アイテム
  #--------------------------------------------------------------------------
  def enable?(item)
    return true
  end
end

#==============================================================================
# ■ TPet_Status
#------------------------------------------------------------------------------
# 　ペットのステータスウィンドウ
#==============================================================================

class TPet_Status < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0+50, 544, TPET::MAX_PET * 32 + 32)
    self.opacity = 0
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    x = 16
    i = 0
    for pet in $scene.pet
      next if pet == nil
      draw_character(pet.character_name, pet.character_index, x+32, i * 32 + 32 +32)
      self.contents.font.color = system_color
      self.contents.draw_text(x + 176-30, i * 32 + 26, 32, WLH, "LV")
      self.contents.draw_text(x + 260-30, i * 32 + 26, 64, WLH, "滿腹度")
      self.contents.draw_text(x + 376-30, i * 32 + 26, 64, WLH, "親密度")
      self.contents.font.color = normal_color
      self.contents.draw_text(x + 32, i * 32 + 26, 128, WLH, $game_actors[TPET::USE_NAME_ID + i].name)
      self.contents.draw_text(x + 212-30, i * 32 + 26, 32, WLH, $game_variables[TPET::USE_VARIABLES_ID + i * 6 + 1].to_i)
      self.contents.draw_text(x + 328-30, i * 32 + 26, 32, WLH, $game_variables[TPET::USE_VARIABLES_ID + i * 6 + 3].to_i)
      self.contents.draw_text(x + 444-30, i * 32 + 26, 32, WLH, $game_variables[TPET::USE_VARIABLES_ID + i * 6 + 4].to_i)
      i += 1
    end
  end
end

#==============================================================================
# ■ TPet_Cursor
#------------------------------------------------------------------------------
# 　ペットのカーソルクラス
#==============================================================================
class TPet_Cursor < Sprite
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super
    self.bitmap = Cache.system("IconSet")
    self.src_rect = Rect.new(48, 72, 24, 24)
    self.x = 272
    self.y = 208
    self.z = 500
    self.ox = 12
    self.oy = 12
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 指定位置へカーソルを移動する
  #--------------------------------------------------------------------------
  def move(x, y)
    self.x = x
    self.y = y
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    if Input.press?(Input::LEFT)
      self.x -= 4
    elsif Input.press?(Input::RIGHT)
      self.x += 4
    end
    if Input.press?(Input::UP)
      self.y -= 4
    elsif Input.press?(Input::DOWN)
      self.y += 4
    end
    self.x = 0 if self.x < 0
    self.x = 544 if self.x > 544
    self.y = 0 if self.y < 0
    self.y = 416 if self.y > 416
  end
end

