#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：MEDAL 系統提示
# 【用途】保留的 Runtime 元件「MEDAL 系統提示」。
# 【主要機制】主要定義／擴充 Game_Interpreter、Game_Party、Game_Map、Spriteset_Map；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Interpreter、Game_Party、Game_Map、Spriteset_Map、Window_Medal、Scene_Medal、TMDL
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：MEDAL_ICON。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Iconset、Audio/SE/Saint5。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ★ RGSS2_メダル
# tomoaky (http://hikimoki.hp.infoseek.co.jp/)
#
# 2010/04/28　公開
#
# 実績的な何かが記録できるようになります。
# イベントコマンド『スクリプト』で
# medal("メダル名", "メダルの説明", n)
# を実行することでメダルを獲得することができます、n はメダルランクの値です
# 設定項目で MEDAL_ICON を４つ設定している場合は 0 ～ 3 を指定します。
#
# 同名のメダルは複数取得できません。
#
# メダル確認シーンをマップから直接呼び出す場合は
# $scene = Scene_Medal.new(false)
# を実行してください。
#==============================================================================

#==============================================================================
# ■ 設定項目
#==============================================================================
module TMDL
  MEDAL_ICON = [1762, 1763, 1764, 1765, 1766, 1767]     # メダルのアイコンID（任意の数）
#0=>功能獲得  1=>任務獲得   2=>任務更新  3=>任務完成
module Commands
  module_function
  def medal(name, description, rank)
    $game_party.gain_medal(name, description, rank)
  end
end

end

module Sound
  # メダルアンロック効果音
  def self.play_gain_medal
    Audio.se_play("Audio/SE/Saint5", 80, 90)
  end
end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  include TMDL::Commands
end

#==============================================================================
# ■ Game_Party
#==============================================================================
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :medal                    # 獲得メダル
  attr_reader   :new_medal                # 新規獲得メダル
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias tmdl_game_party_initialize initialize
  def initialize
    tmdl_game_party_initialize
    @medal = []
    @new_medal = []
  end
  #--------------------------------------------------------------------------
  # ● メダルの獲得
  #--------------------------------------------------------------------------
  def gain_medal(name, description, rank)
   # for medal in @medal   # 同名排他
   #   return if medal[0] == name
   # end
    @new_medal.push([name, description, rank])
  end
  #--------------------------------------------------------------------------
  # ● 新規獲得メダルを獲得済みメダルの配列へ移す
  #--------------------------------------------------------------------------
  def update_medal
    Sound.play_gain_medal
    t = Time.now
    @medal.unshift(@new_medal.shift + [t.strftime(" (%Y/%m/%d %H:%M)")])
    return [@medal[0][0], @medal[0][2]]
  end
end

#==============================================================================
# ■ Game_Map
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :medal_news               # 獲得メダル
  attr_reader   :medal_count              # メダルニュースの表示時間
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias tmdl_game_map_update update
  def update
    tmdl_game_map_update
    if @medal_news == nil
      unless $game_party.new_medal.empty? # 新しいメダルがある
        @medal_news = $game_party.update_medal
        @medal_count = 150
      end
    else
      @medal_count -= 1
      @medal_news = nil if @medal_count == 0
    end
  end
end

#==============================================================================
# ■ Spriteset_Map
#==============================================================================
class Spriteset_Map
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias tmdl_spriteset_map_initialize initialize
  def initialize
    @sprite_news = Sprite.new(nil)
    @sprite_news.bitmap = Bitmap.new(192, 32)
    @sprite_news.x = 344
    @sprite_news.oy = 32
    @sprite_news.z = 9999999
    @sprite_news.bitmap.font.size = 17
    tmdl_spriteset_map_initialize
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias tmdl_spriteset_map_dispose dispose
  def dispose
    @sprite_news.bitmap.dispose
    @sprite_news.dispose
    tmdl_spriteset_map_dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias tmdl_spriteset_map_update update
  def update
    @sprite_news.update
    if @medal_news != $game_map.medal_news
      @medal_news = $game_map.medal_news
      @sprite_news.bitmap.clear
      if @medal_news != nil
        @sprite_news.bitmap.fill_rect(0, 0, 192, 32, Color.new(0, 0, 0, 128))
        bitmap = Cache.system("Iconset")
        icon_index = TMDL::MEDAL_ICON[@medal_news[1]]
        rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
        @sprite_news.bitmap.blt(0, 4, bitmap, rect, 255)
        @sprite_news.bitmap.font.size = 17
        @sprite_news.bitmap.font.color = Color.new(220, 220, 220, 255)
        @sprite_news.bitmap.draw_text(24, 7, 168, 16, @medal_news[0])
        @sprite_news.bitmap.font.size = 16
        @sprite_news.bitmap.font.color = Color.new(192, 224, 255, 255)
        @sprite_news.bitmap.draw_text(24, 16, 160, 16, "功能開啟", 2) if icon_index == 28
        @sprite_news.bitmap.draw_text(24, 16, 160, 16, "任務獲得", 2) if icon_index == 710
        @sprite_news.bitmap.draw_text(24, 16, 160, 16, "任務更新", 2) if icon_index == 709
        @sprite_news.bitmap.draw_text(24, 16, 160, 16, "任務完成", 2) if icon_index == 691
      end
    end
    @sprite_news.visible = (@medal_news != nil)
    if @sprite_news.visible
      @sprite_news.opacity = $game_map.medal_count * 4
      @sprite_news.y = [300 - $game_map.medal_count, 40].min
    end
    tmdl_spriteset_map_update
  end
end

#==============================================================================
# ■ Window_Medal
#==============================================================================
class Window_Medal < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @column_max = 1
    self.index = 0
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    @item_max = $game_party.medal.size
    create_contents
    for i in 0...@item_max do draw_item(i) end
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #     index : 項目番号
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    item = $game_party.medal[index]
    rect.width -= 4
    draw_icon(TMDL::MEDAL_ICON[item[2]], rect.x, rect.y)
    rect.x += 24
    rect.width -= 24
    self.contents.draw_text(rect, item[0])
    self.contents.draw_text(rect, item[3], 2)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプテキスト更新
  #--------------------------------------------------------------------------
  def update_help
    item = $game_party.medal[self.index]
    @help_window.set_text(item == nil ? "" : item[1])
  end
end

#==============================================================================
# ■ Scene_Medal
#==============================================================================
class Scene_Medal < Scene_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(from_menu = true)
    @from_menu = from_menu
  end
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @help_window = Window_Help.new
    @item_window = Window_Medal.new(0, 56, 544, 360)
    @item_window.help_window = @help_window
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @item_window.dispose
    @help_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 元の画面へ戻る
  #--------------------------------------------------------------------------
  def return_scene
    if @from_menu
      $scene = Scene_Menu.new(6)
    else
      $scene = Scene_Map.new
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @item_window.update
    @help_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    end
  end
end


