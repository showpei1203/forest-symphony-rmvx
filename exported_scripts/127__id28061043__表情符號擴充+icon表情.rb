#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：表情符號擴充+icon表情
# 【用途】保留的 Runtime 元件「表情符號擴充+icon表情」。
# 【主要機制】主要定義／擴充 Game_Character、Sprite_Character、Game_Interpreter；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Character、Sprite_Character、Game_Interpreter
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Balloon、Iconset、Audio/SE/Emotion_01、Audio/SE/Emotion_02、Audio/SE/MenuEffect1、Audio/SE/Emotion_03、Audio/SE/Emotion_04、Audio/SE/Emotion_05、Audio/SE/Emotion_06、Audio/SE/Emotion_07。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ■ アイコンバルーン表示スクリプト Ver1.00
#------------------------------------------------------------------------------
#    機能：アイコンをバルーンで表示できます
#    UPDATE - 2010.01.17
#    履歴   - 2010.01.17 Ver1.00版公開
#    製作者 - mitaka
#    サイト - 適当ツクール
#　　URL    - http://sky.geocities.jp/tekitotkool/
#==============================================================================
#==============================================================================
# ■ Game_Character
#------------------------------------------------------------------------------
# 　キャラクターを扱うクラスです。このクラスは Game_Player クラスと Game_Event
# クラスのスーパークラスとして使用されます。
#==============================================================================
class Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :iconballoon_id           # フキダシアイコン(アイコンID)
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_MtkIcon initialize
  def initialize
    initialize_MtkIcon
    
    @iconballoon_id = 0
  end
end
#==============================================================================
# ■ Sprite_Character
#------------------------------------------------------------------------------
# 　キャラクター表示用のスプライトです。Game_Character クラスのインスタンスを
# 監視し、スプライトの状態を自動的に変化させます。
#==============================================================================
class Sprite_Character < Sprite_Base
  #--------------------------------------------------------------------------
  # ● フキダシアイコン表示の開始（再定義）
  #--------------------------------------------------------------------------
  def start_balloon
    dispose_balloon
    @balloon_duration = 8 * 8 + BALLOON_WAIT
    @balloon_sprite = ::Sprite.new(viewport)
    @balloon_sprite.bitmap = Cache.system("Balloon")
    @balloon_sprite.ox = 16
    @balloon_sprite.oy = 32
    #@balloon_sprite.z = 255
    @icon_sprite = ::Sprite.new(viewport)
    @icon_sprite.bitmap = Cache.system("Iconset")
    @icon_sprite.ox = 12
    @icon_sprite.oy = 24
    Audio.se_play("Audio/SE/Emotion_01",70,100) if @balloon_id == 1
    Audio.se_play("Audio/SE/Emotion_02",70,100) if @balloon_id == 2
    Audio.se_play("Audio/SE/MenuEffect1",70,100) if @balloon_id == 3
    Audio.se_play("Audio/SE/Emotion_03",70,100) if @balloon_id == 4
    Audio.se_play("Audio/SE/Emotion_04",70,100) if @balloon_id == 5
    Audio.se_play("Audio/SE/Emotion_05",70,100) if @balloon_id == 6
    Audio.se_play("Audio/SE/Emotion_06",70,100) if @balloon_id == 7
    Audio.se_play("Audio/SE/Emotion_07",70,100) if @balloon_id == 9
    update_balloon
  end
  #--------------------------------------------------------------------------
  # ● フキダシアイコンの更新（再定義）
  #--------------------------------------------------------------------------
  def update_balloon
    if @balloon_duration > 0
      @balloon_duration -= 1
      if @balloon_duration == 0
        dispose_balloon
      else
        @balloon_sprite.x = x
        @balloon_sprite.y = y - height
        @balloon_sprite.z = z + 200
        if @balloon_duration < BALLOON_WAIT
          sx = 7 * 32
        else
          sx = (7 - (@balloon_duration - BALLOON_WAIT) / 8) * 32
        end
        sy = (@balloon_id - 1) * 32
        #既存バルーン表示
        @balloon_sprite.src_rect.set(sx, sy, 32, 32)
        #アイコンスプライトの情報設定
        @icon_sprite.x = x 
        @icon_sprite.y = y - height - 6
        @icon_sprite.z = z + 300
        #アイコンの位置設定
        ix = character.iconballoon_id % 16  * 24
        iy = character.iconballoon_id / 16  * 24
        #アイコン表示
        @icon_sprite.src_rect.set(ix, iy, 24, 24)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● フキダシアイコンの解放（再定義）
  #--------------------------------------------------------------------------
  def dispose_balloon
    if @balloon_sprite != nil
      @balloon_sprite.dispose
      @balloon_sprite = nil
    end
    if @icon_sprite != nil
      @icon_sprite.dispose
      @icon_sprite = nil
    end
  end
end
#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● フキダシアイコンの表示（再定義）
  #--------------------------------------------------------------------------
  def command_213
    character = get_character(@params[0])
    if character != nil
      character.balloon_id = @params[1]
      character.iconballoon_id = 0
    end
    return true
  end
#--------------------------------------------------------------------------
  # ● 追加バルーンの表示（新規追加）
  #--------------------------------------------------------------------------
  def disp_addballoon(target, index)
    character = get_character(target)
    if character != nil
      character.balloon_id = index
      character.iconballoon_id = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● アイコンバルーンの表示（新規追加）
  #--------------------------------------------------------------------------
  def disp_iconballoon(target, index)
    character = get_character(target)
    if character != nil
      character.balloon_id = 11 #空(中身なし）のバルーンを設定
      character.iconballoon_id = index
    end
  end
end