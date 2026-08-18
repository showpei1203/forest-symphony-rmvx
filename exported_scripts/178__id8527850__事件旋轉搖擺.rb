#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：事件旋轉搖擺
# 【用途】地圖／事件元件「事件旋轉搖擺」。
# 【主要機制】擴充 Game_Map／Game_Event／Game_Character／Spriteset_Map 或事件 Script Call。
# 【主要影響】Game_Character、Game_Event、Sprite_Character、Game_Interpreter、SPREX、SPREX::Commands
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SWING_ANGLE、CIRCLE_DIST。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 4 個 alias／方法包裝，載入順序具有語意。
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
# ★ RGSS2_キャラクタースプライトEX Ver1.0
#==============================================================================
=begin

作者：tomoaky
webサイト：ひきも記 (http://hikimoki.sakura.ne.jp/)

キャラクタースプライトに以下の機能を追加します。
  ・任意の拡大率に変更
  ・拡大縮小アニメーション
  ・ふらふらアニメーション
  ・円運動アニメーション

イベントコマンドのスクリプトで以下のようなコマンドが使えるようになります。

  zoom(event_id, zoom_x, zoom_y)
  指定したIDのイベントの拡大率をzoom_x, zoom_yに変更します、
  zoom(1, 1.5, 3.0)　とした場合はイベントID1を横1.5倍、縦3倍。
  
  zoom_anime(event_id, flag)
  指定したIDのイベントが拡大と縮小を繰り返すようになります。
    
  swing(event_id, flag)
  指定したIDのイベントがふらふらと揺れるようになります。
  
  circle(event_id, flag)
  指定したIDのイベントが円運動をするようになります、
  移動するのはスプライトだけなので、イベントの位置は変化しません。

  event_id に 0 を指定すると実行中のイベントが対象になり、-1 を指定すれば
  プレイヤーキャラが対象になります。
  flag には true か false を指定してください。
  swing(-1, true)　でプレイヤーのふらふらアニメーションを有効にします。

上記のイベントコマンドを使う方法以外に、イベント名を使って
設定することもできます。以下の文字列をイベント名に加えてください。
  <zm=1.5,2.0>　拡大率の設定、この例では横1.5倍、縦2倍になります
  <za>　拡大縮小アニメーションを有効にする
  <sw>　ふらふらアニメーションを有効にする
  <cc>　円運動アニメーションを有効にする

2009.12.24　Ver1.0
  公開
  
=end

#==============================================================================
# □ 設定項目
#==============================================================================
module SPREX
  SWING_ANGLE = 30                        # ふらふらする角度
  CIRCLE_DIST = 16                        # 円運動の半径
end

#==============================================================================
# ■ Game_Character
#==============================================================================
class Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :zoom_x                   # ｘ方向の拡大率
  attr_accessor :zoom_y                   # ｙ方向の拡大率
  attr_accessor :zoom_anime               # ズームアニメフラグ
  attr_accessor :swing                    # ふらふらフラグ
  attr_accessor :circle                   # 円運動フラグ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias sprex_game_character_initialize initialize
  def initialize
    sprex_game_character_initialize
    @zoom_x = 1.0
    @zoom_y = 1.0
    @zoom_anime = false
    @swing = false
    @circle = false
  end
end

#==============================================================================
# ■ Game_Event
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     map_id : マップ ID
  #     event  : イベント (RPG::Event)
  #--------------------------------------------------------------------------
  alias sprex_game_event_initialize initialize
  def initialize(map_id, event)
    sprex_game_event_initialize(map_id, event)
    if event.name =~ /<zm=(\d+\.\d+),(\d+\.\d+)>/i
      @zoom_x = $1.to_f
      @zoom_y = $2.to_f
    end
    @zoom_anime = true if event.name =~ /<za>/i
    @swing = true if event.name =~ /<sw>/i
    @circle = true if event.name =~ /<cc>/i
  end
end

#==============================================================================
# ■ Sprite_Character
#==============================================================================
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     viewport  : ビューポート
  #     character : キャラクター (Game_Character)
  #--------------------------------------------------------------------------
  alias sprex_sprite_character_initialize initialize
  def initialize(viewport, character = nil)
    @ex_count = 0                         # 特殊演出用のカウンタ
    sprex_sprite_character_initialize(viewport, character)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias sprex_sprite_character_update update
  def update
    sprex_sprite_character_update
    @ex_count = (@ex_count + 1) & 255
    if @character.zoom_anime              # ズームアニメの更新
      self.zoom_x = Math.sin(Math::PI * @ex_count / 128) * 0.5 + 1.5
      self.zoom_y = self.zoom_x
    else                          # ズームアニメが無効なら指定した拡大率を使う
      self.zoom_x = @character.zoom_x
      self.zoom_y = @character.zoom_y
    end
    if @character.swing                   # ふらふら状態の更新
      self.angle = Math.sin(Math::PI * @ex_count / 128) * SPREX::SWING_ANGLE
    end
    if @character.circle                  # 円運動状態の更新
      a = Math::PI * @ex_count / 128
      self.x += Math.sin(a) * SPREX::CIRCLE_DIST
      self.y += Math.cos(a) * SPREX::CIRCLE_DIST
    end
  end
end

#==============================================================================
# □ コマンドの追加
#==============================================================================
module SPREX::Commands
  module_function
  #--------------------------------------------------------------------------
  # ○ キャラクタースプライトの拡大率を変更
  #--------------------------------------------------------------------------
  def zoom(id, zoom_x, zoom_y)
    target = $game_map.interpreter.get_character(id)
    target.zoom_x = zoom_x
    target.zoom_y = zoom_y
  end
  #--------------------------------------------------------------------------
  # ○ キャラクタースプライトのズームアニメを変更
  #--------------------------------------------------------------------------
  def zoom_anime(id, flag)
    $game_map.interpreter.get_character(id).zoom_anime = flag
  end
  #--------------------------------------------------------------------------
  # ○ キャラクタースプライトのふらふら状態を変更
  #--------------------------------------------------------------------------
  def swing(id, flag)
    $game_map.interpreter.get_character(id).swing = flag
  end
  #--------------------------------------------------------------------------
  # ○ キャラクタースプライトの円運動状態を変更
  #--------------------------------------------------------------------------
  def circle(id, flag)
    $game_map.interpreter.get_character(id).circle = flag
  end
end
class Game_Interpreter
  include SPREX::Commands
end