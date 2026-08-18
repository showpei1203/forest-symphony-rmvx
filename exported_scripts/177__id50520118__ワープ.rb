#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：ワープ
# 【用途】保留的 Runtime 元件「ワープ」。
# 【主要機制】主要定義／擴充 Game_Interpreter、Game_Map、TWARP、Commands；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Interpreter、Game_Map、TWARP、Commands
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
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
#==============================================================================
# ★ RGSS2_ワープ Ver1.0
#==============================================================================
=begin

作者：tomoaky
webサイト：ひきも記 (http://hikimoki.sakura.ne.jp/)

今いるマップ上の通行可能セルへランダム移動する機能を追加します、
移動先の候補として矩形領域を指定することもできます。

使い方
  イベントコマンド『スクリプト』に warp と書くだけでOKです、
  一瞬で移動が完了します、演出等は何もないのでイベントコマンドで
  効果音やアニメーション、ウェイトを付けてください。

  warp(id) でワープする対象を指定できます、-1 ならプレイヤー、
  0 ならこのイベント、1以上 でそのIDをもつイベントが対象となります。

  warp(id, x, y, width, height) とすれば座標(x, y)を左上とした
  縦widthセル、横heightセルの矩形を移動先候補とします。

  warp の代わりに warp_jump を使うと、瞬間移動がジャンプに変化します。

注意点
  対象が今いる座標とイベントがいる座標は自動的に候補から除外されますが、
  地形的にどこにもつながっていない座標は候補に含まれます、こういったマップでは
  矩形領域の指定機能を利用してください。

  指定した矩形領域のすべてのセルがワープ不可セル（通行不可orイベントがいる）
  だった場合は今いる座標がワープ先に選ばれます。

2010.06.15　Ver1.0
  公開

=end

#==============================================================================
# ■ コマンド
#==============================================================================
module TWARP
module Commands
  module_function
  def warp(id = -1, x = nil, y = nil, width = 1, height = 1)
    character = $game_map.interpreter.get_character(id)
    x, y = $game_map.warp_pos(character, x, y, width, height)
    character.moveto(x, y)
  end
  def warp_jump(id = -1, x = nil, y = nil, width = 1, height = 1)
    character = $game_map.interpreter.get_character(id)
    x, y = $game_map.warp_pos(character, x, y, width, height)
    character.jump(x - character.x, y - character.y)
  end
end
end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  include TWARP::Commands
end

#==============================================================================
# ■ Game_Map
#==============================================================================
class Game_Map
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias twarp_game_map_setup setup
  def setup(map_id)
    twarp_game_map_setup(map_id)
    @twarp_pos = []
    for x in 0...width
      for y in 0...height
        for i in [2, 1, 0]                      # レイヤーの上から順に調べる
          tile_id = @map.data[x, y, i]          # タイル ID を取得
          next if tile_id == nil                # タイル ID 取得失敗 : 通行不可
          pass = @passages[tile_id]             # 通行属性を取得
          next if pass & 0x10 == 0x10           # [☆] : 通行に影響しない
          @twarp_pos.push([x, y]) unless pass & 0x01 == 0x01
          break
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ○ ワープ先座標を返す
  #--------------------------------------------------------------------------
  def warp_pos(character, x, y, width, height)
    if x == nil
      begin
        pos = @twarp_pos[rand(@twarp_pos.size)]
      end while !can_warp?(character, pos[0], pos[1])
    else
      a = []
      for i in x...x + width
        for j in y...y + height
          a.push([i, j]) if can_warp?(character, i, j)
        end
      end
      return character.x, character.y if a.empty?
      pos = a[rand(a.size)]
    end
    return pos[0], pos[1]
  end
  #--------------------------------------------------------------------------
  # ○ ワープ可能な座標かどうかを返す（現在の座標とイベントがいる座標を除外）
  #--------------------------------------------------------------------------
  def can_warp?(character, x, y)
    return false unless events_xy(x, y).empty?
    return false if $game_player.pos?(x, y)
    return true
  end
end


