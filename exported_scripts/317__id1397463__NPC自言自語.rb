#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：NPC自言自語
# 【用途】保留的 Runtime 元件「NPC自言自語」。
# 【主要機制】主要定義／擴充 Game_Interpreter、Game_Character、Game_Event、Sprite_Character；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Interpreter、Game_Character、Game_Event、Sprite_Character、TMRBT、Commands
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SW_MESSAGE_STOP、MESSAGE_DURATION、MESSAGE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 6 個 alias／方法包裝，載入順序具有語意。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：murawin、Window。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# ★ RGSS2_村人のつぶやき自言自語
# tomoaky (http://hikimoki.hp.infoseek.co.jp/)
#==============================================================================

#==============================================================================
# ■ 設定項目
#==============================================================================
module TMRBT
  SW_MESSAGE_STOP = 1             # 機能無効化スイッチのID
  MESSAGE_DURATION = 180          # メッセージの表示時間（フレーム）
  MESSAGE = {}
  
  # おじさんタイプのメッセージリスト
  MESSAGE["工人魯卡"] = [
    '拓荒隊的工資豐厚', '我也想闖一番事業',
    '希望可以加入'
  ]
  
  # ゴブリンのメッセージリスト
  MESSAGE["班德奶奶"] = [
    '村莊越來越熱鬧', '小班，別跑太遠', '腰痠...'
  ]

  # ネコのメッセージリスト
  MESSAGE["班德爺爺"] = [
    '咳咳...', '背痛...！', '多思考'
  ]

  # 走る兵士のメッセージリスト
  MESSAGE["酒吧民兵"] = [
    '喝吧', '跟隊長做事很累', '忙裡偷閒', '再一杯',
    '是不是該回去了', '放輕鬆點'
  ]

  # 客Ａのメッセージリスト
  MESSAGE["酒吧工頭"] = [
    '木材出售', '產地現貨哦', '絕對便宜'
  ]
  
  # 客Ｂのメッセージリスト
  MESSAGE["民兵"] = [
    '錢多事少', '艾卓隊長很嚴厲', '想休息了...',
    '離鄉背井', '高額的工資！', '聽說還要練武',
    '想家了...', '肚子有點餓', '什麼時候可以喝一杯'
  ]
  
    # 客Ｂのメッセージリスト
  MESSAGE["工人"] = [
    '好不容易應徵上了', '工作繁忙', '嘿咻！',
    '嘿咻嘿咻！', '物資到了', '要運往哪裡？',
    '物資豐富', '人潮聚集', '吆呼~'
  ]
  
  MESSAGE["士兵"] = [
    '為了阿爾泰斯特！', '吾為吾城'
  ]
  
  MESSAGE["碎石士兵"] = [
    '有人可以幫忙嗎', '唔...', '傷腦筋啊'
  ]
  
  MESSAGE["營地婦女"] = [
    '這麼不小心！', '不應該！', '回家一定處罰'
  ]
  
    MESSAGE["營地武器"] = [
    '雖然及不上哈貝爾貨', '都是良品', '快來看看'
  ]
  
      MESSAGE["營地商人"] = [
    '老闆人呢', '想去哈貝爾', '需要糧食'
  ]
  
  MESSAGE["酒吧矮人"] = [
    '咀嚼咀嚼...', '咕嚕咕嚕...', '喂！再來一杯！', '乾杯啦', '看我一身精良的鎧甲',
    '我打造的武器才是最棒的！', '我的聖鎚啊！我還沒醉！'
  ]
   MESSAGE["酒吧競技"] = [
    '機器人旋風', '掀起機器人流行', '想想怎麼改裝', '動力推進', '機器格鬥！',
    '洛馬爾真的了不起！', '需要更多零件', '上啊', '打爆對手！'
  ]
  # 店員Ａのメッセージリスト
  MESSAGE["店員Ａ"] = [
    '困りますよお客さん', 'そんな…', 'えー？'
  ]
end

#==============================================================================
# ■ コマンド
#==============================================================================
module TMRBT
  module Commands
    module_function
    #--------------------------------------------------------------------------
    # ● 指定したIDのイベントにメッセージを強制
    #--------------------------------------------------------------------------
    def mes(id, text, count = 300)
      event = $game_map.interpreter.get_character(id)
      if event != nil
        event.message = text
        event.message_count = count
      end
    end
    #--------------------------------------------------------------------------
    # ● 指定したIDのイベントの村人タイプを変更
    #--------------------------------------------------------------------------
    def mes_type(id, type = nil)
      return if id < 0    # プレイヤーには無効
      event = $game_map.interpreter.get_character(id)
      if event != nil
        event.murabito = type
      end
    end
  end
end

class Game_Interpreter
  include TMRBT::Commands
end

#==============================================================================
# ■ Game_Character
#==============================================================================
class Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :message                  # フキダシメッセージ
  attr_accessor :message_count            # メッセージ待機カウント
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias tmrbt_game_character_initialize initialize
  def initialize
    tmrbt_game_character_initialize
    @message = ""
    @message_count = 60 + rand(240)
  end
  #--------------------------------------------------------------------------
  # ○ メッセージを表示できる状態かどうかを返す
  #--------------------------------------------------------------------------
  def message_can_speak?
    return false if @character_name == "" and @tile_id == 0
    return false if $game_switches[TMRBT::SW_MESSAGE_STOP]
    return true
  end
end

#==============================================================================
# ■ Game_Event
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :murabito                 # 村人タイプ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     map_id : マップ ID
  #     event  : イベント (RPG::Event)
  #--------------------------------------------------------------------------
  alias tmrbt_game_event_initialize initialize
  def initialize(map_id, event)
    tmrbt_game_event_initialize(map_id, event)
    @murabito = event.name =~ /<村人:(\S+?)>/i ? $1 : nil  # 村人判定
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias tmrbt_game_event_update update
  def update
    tmrbt_game_event_update
    if @murabito != nil
      if @message_count > 0
        @message_count -= 1
        if @message_count == 0
          if message_can_speak?
            n = TMRBT::MESSAGE[@murabito].size
            @message = TMRBT::MESSAGE[@murabito][rand(n)].clone
          end
          @message_count = 270 + rand(300)
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ 指定したIDのイベントにメッセージを強制（カスタム移動用）
  #--------------------------------------------------------------------------
  def mes(id, text, count = 300)
    TMRBT::Commands.mes(id == 0 ? @id : id, text, count)
  end
  #--------------------------------------------------------------------------
  # ○ 指定したIDのイベントの村人タイプを変更（カスタム移動用）
  #--------------------------------------------------------------------------
  def mes_type(id, type = nil)
    TMRBT::Commands.mes_type(id == 0 ? @id : id, type)
  end
end

#==============================================================================
# ■ Sprite_Character
#==============================================================================
class Sprite_Character < Sprite_Base
  @@bitmap_murawin = Cache.system("murawin")
  @@windowskin = Cache.system("Window")
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     viewport  : ビューポート
  #     character : キャラクター (Game_Character)
  #--------------------------------------------------------------------------
  alias tmrbt_sprite_character_initialize initialize
  def initialize(viewport, character = nil)
    @message_duration = 0
    tmrbt_sprite_character_initialize(viewport, character)
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias tmrbt_sprite_character_dispose dispose
  def dispose
    dispose_message
    tmrbt_sprite_character_dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias tmrbt_sprite_character_update update
  def update
    tmrbt_sprite_character_update
    update_message
    if @character.message != ""
      @message = @character.message
      start_message
      @character.message = ""
    end
  end
  #--------------------------------------------------------------------------
  # ○ 文字色取得
  #     n : 文字色番号 (0～31)
  #--------------------------------------------------------------------------
  def text_color(n)
    x = 64 + (n % 8) * 8
    y = 96 + (n / 8) * 8
    return @@windowskin.get_pixel(x, y)
  end
  #--------------------------------------------------------------------------
  # ○ 特殊文字の変換
  #--------------------------------------------------------------------------
  def convert_special_characters
    @message.gsub!(/\\L/)              { "\x00" }
    @message.gsub!(/\\V\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    @message.gsub!(/\\N\[([0-9]+)\]/i) { $game_actors[$1.to_i].name }
    @message.gsub!(/\\C\[([0-9]+)\]/i) { "\x01[#{$1}]" }
    @message.gsub!(/\\\\/)             { "\\" }
  end
  #--------------------------------------------------------------------------
  # ○ フキダシメッセージ表示の開始
  #--------------------------------------------------------------------------
  def start_message
    dispose_message
    convert_special_characters
    @message_duration = TMRBT::MESSAGE_DURATION
    bitmap = Bitmap.new(160, 160)
    bitmap.font.size = 16
    w = 0
    contents_x = 4
    contents_y = 0
    loop do
      c = @message.slice!(/./m)         # 次の文字を取得
      case c
      when nil
        break                           # 描画すべき文字がなければ終了
      when "\x00"                       # 改行
        w = contents_x if w < contents_x
        contents_x = 4
        contents_y += 16
        next
      when "\x01"                       # \C[n]  (文字色変更)
        @message.sub!(/\[([0-9]+)\]/, "")
        bitmap.font.color = text_color($1.to_i)
        next
      else
        bitmap.draw_text(contents_x, contents_y, 40, 16, c)
        c_width = bitmap.text_size(c).width
        contents_x += c_width
        if contents_x >= 140            # 右端にきていれば改行
          w = contents_x if w < contents_x
          contents_x = 4
          contents_y += 16
        end
      end
    end
    h = contents_y + (contents_x == 4 ? 0 : 16)
    w = (w < contents_x ? contents_x + 4 : w + 4)
    @message_sprite = ::Sprite.new(viewport)
    @message_sprite.ox = w / 2
    @message_sprite.oy = h + 4
    @message_sprite.bitmap = Bitmap.new(w, h + 8)
    rect = Rect.new(0, 0, 8, 8)
    @message_sprite.bitmap.blt(0, 0, @@bitmap_murawin, rect, 192)
    rect.x += 8
    @message_sprite.bitmap.blt(w - 8, 0, @@bitmap_murawin, rect, 192)
    rect.y += 8
    @message_sprite.bitmap.blt(w - 8, h - 8, @@bitmap_murawin, rect, 192)
    rect.x -= 8
    @message_sprite.bitmap.blt(0, h - 8, @@bitmap_murawin, rect, 192)
    rect.set(16, 0, 8, 8)
    @message_sprite.bitmap.blt(@message_sprite.ox - 4, h,
      @@bitmap_murawin, rect, 192)
    color = @@bitmap_murawin.get_pixel(8, 8)
    color.alpha = 192
    @message_sprite.bitmap.fill_rect(8, 0, w - 16, h, color)
    @message_sprite.bitmap.fill_rect(0, 8, 8, h - 16, color)
    @message_sprite.bitmap.fill_rect(w - 8, 8, 8, h - 16, color)
    @message_sprite.bitmap.blt(0, 0, bitmap, bitmap.rect)
    bitmap.dispose
    update_message
  end
  #--------------------------------------------------------------------------
  # ○ フキダシメッセージの更新
  #--------------------------------------------------------------------------
  def update_message
    if @message_duration > 0
      @message_duration -= 1
      if @message_duration == 0 or not @character.message_can_speak?
        @message_duration = 0
        dispose_message
      else
        @message_sprite.x = x
        @message_sprite.y = y - height
        @message_sprite.z = z + 200
        @message_sprite.opacity = @message_duration * 24
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ フキダシメッセージの解放
  #--------------------------------------------------------------------------
  def dispose_message
    if @message_sprite != nil
      @message_sprite.dispose
      @message_sprite = nil
    end
  end
end



