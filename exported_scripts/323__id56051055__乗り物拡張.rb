#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：乗り物拡張
# 【用途】保留的 Runtime 元件「乗り物拡張」。
# 【主要機制】主要定義／擴充 Riding_Data、Game_Vehicle、Scene_Title、RPG::AudioFile；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Riding_Data、Game_Vehicle、Scene_Title、RPG::AudioFile、Game_Map、Game_Character、Game_Event
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：HORSE_MAP_ID、HORSE_X、HORSE_Y、HORSE_FILE_NAME、HORSE_FILE_INDEX、HORSE_BGM_NAME、BIG_AIRSHIP_MAP_ID、BIG_AIRSHIP_X。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 31 個 alias／方法包裝，載入順序具有語意。
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
#
#　■乗り物拡張　□Ver. 2.82　□製作者：月紳士
#　・RPGツクールVX用 RGSS2スクリプト
#
#    ●…書き換えメソッド(競合注意)　◎…メソッドのエイリアス　○…新規メソッド
#
#  ※二次配布禁止！配布元には利用規約があります。必ずそちらを見てください。
#------------------------------------------------------------------------------
# 更新履歴
#  Ver. 2.82  パーティーメンバーの追従との併用時の動作を修正。
#  Ver. 2.81  茂みによるエンカウント増加が飛行中に適用されないよう修正。
#  Ver. 2.80  乗り物ステートの機能を追加。
#  Ver. 2.70  エンカウントしない乗り物機能が未実装だった為、追加。
#  Ver. 2.63  前回の修正が不十分だったことによる不具合を再修正。
#  Ver. 2.62  イベント乗り物を乗り継いだ際に再度乗れなくなる不具合を修正。
#  Ver. 2.61  下記更新の微調整。
#  Ver. 2.60  HARTS HORN様の「隊列歩行スクリプト」併用動作の修正と
#             月紳士のスクリプト【パーティーメンバーの追従】併用時用の更新。
#  Ver. 2.51  スクリプトの見直しと細かい動作修正。
#  Ver. 2.50  乗り物に乗った状態でのセーブ・ロード時の不具合を解消。
#
#   ※これ以前の更新履歴はマニュアルを参考にしてください。
#==============================================================================
=begin
  
　このスクリプトで追加されるのは以下の機能です。

　　○馬、大型飛行船、魔法の絨毯というみっつの新しい乗り物を追加。

　　○キャラクターが上に乗る、騎乗タイプの乗り物を作成できる。

　　○イベントにプレイヤーを乗り込ませたり、騎乗させたりできる。

　　○イベントにイベントを騎乗させることができる。

　　○システムの応用にて、イベントを持ち上げる、運ぶ、といったことも可能に。


　※ 詳しい説明はマニュアルをご覧ください。

=end

#==============================================================================
# □ 乗り物拡張・モジュール（カスタマイズ項目）
#==============================================================================

module Expansion_Vehicle
 
 # 馬の初期設定 # -----------------------------------------------------

  # 初期配置するマップのID／X座標／Y座標
    HORSE_MAP_ID = 0                     
    HORSE_X = 0
    HORSE_Y = 0

  # 画像ファイルの名前／画像ファイルのINDEX
    HORSE_FILE_NAME = "$littletiger"#"Animal"           
    HORSE_FILE_INDEX = 0#5

  # BGMファイルの名前
    HORSE_BGM_NAME = ""              

 # 大型飛行船の初期設定 # ----------------------------------------------

  # 初期配置するマップのID／X座標／Y座標
    BIG_AIRSHIP_MAP_ID = 1
    BIG_AIRSHIP_X = 11
    BIG_AIRSHIP_Y = 10

  # 画像ファイルの名前／画像ファイルのINDEX
    BIG_AIRSHIP_FILE_NAME = "$Wivern"
    BIG_AIRSHIP_FILE_INDEX = 0

  # BGMファイルの名前
    BIG_AIRSHIP_BGM_NAME = "Scene9"     

 # 魔法の絨毯の初期設定 # ----------------------------------------------

  # 初期配置するマップのID／X座標／Y座標
    MAGIC_CARPET_MAP_ID = 0
    MAGIC_CARPET_X = 0
    MAGIC_CARPET_Y = 0

  # 画像ファイルの名前／画像ファイルのINDEX
    MAGIC_CARPET_FILE_NAME = "Ride"
    MAGIC_CARPET_FILE_INDEX = 6

  # BGMファイルの名前
    MAGIC_CARPET_BGM_NAME = "Airship"     

 # その他の設定 # ------------------------------------------------------
    
  # エンカウントしない乗り物のID
    NOT_ENCOUNTER_VEHICIE_ID = [0, 1, 2, 3, 4, 5]
    # ID = 0:小型船／1:大型船／2:飛行船／3:馬／4:大型飛行船／5:魔法の絨毯
    
  # 乗り物ステート
    BOAT_STATE         = []  # 小型船
    SHIP_STATE         = []  # 大型船
    AIRSHIP_STATE      = []  # 飛行船
    HORSE_STATE        = []  # 馬
    BIG_AIRSHIP_STATE  = []  # 大型飛行船
    MAGIC_CARPET_STATE = []  # 魔法の絨毯
      
end

#==============================================================================
# □ Riding_Data
#------------------------------------------------------------------------------
# 　騎乗時の画像処理に必要なデータを扱うクラスです。このクラスのインスタンスは 
# $riding_data で参照されます。
#==============================================================================

class Riding_Data
  #--------------------------------------------------------------------------
  # ○ 騎乗用キャラクター・データ
  #--------------------------------------------------------------------------
  #  @riding_pct_name      # 騎乗時に重ねる画像のファイル名
  #                        # ※ ここを "self" にすると元々のキャラクター画像を
  #                        #    騎乗時に重ねる画像に使います。
  #  @riding_pct_index     # 騎乗時に重ねる画像のインデックス
  #  @positioning_down     # 下向きの際の位置修正値
  #  @positioning_left     # 左向きの際の位置修正値
  #  @positioning_right    # 右向きの際の位置修正値(省略可・省略時は左向きの逆の値を使用)
  #  @positioning_up       # 上向きの際の位置修正値
  #  @priority_type        # 待機時のふさわしいプライオリティ(0 の時のみ設定)
  #  @object_type          # 乗る側と乗られる側の処理逆転(する場合のみtrueを定義)
  #                        # ※ 物を持ち上げる表現に使います。
  #--------------------------------------------------------------------------
  def make_ride_data
    # 騎馬
    @character_name = "Animal"
    @character_index = 5
    @riding_pct_name = "Ride"
    @riding_pct_index = 0
    @positioning_down = [[0, -18], [0, -17], [0, -18]]
    @positioning_left = [[4, -17], [4, -16], [4, -17]]
    @positioning_up = [[0, -15], [0, -14], [0, -15]]
    set_ride_data
    
    # 騎小獅子
    @character_name = "$littletiger"
    @character_index = 0
    @riding_pct_name = "$littletiger2"
    @riding_pct_index = 0
    @positioning_down = [[0, -14], [0, -13], [0, -16]]
    @positioning_left = [[2, -11], [2, -10], [2, -13]]
    @positioning_up = [[0, -11], [0, -10], [0, -14]]
    set_ride_data
    
    # オオカミ
    @character_name = "Animal"
    @character_index = 6
    @riding_pct_name = "Ride"
    @riding_pct_index = 1
    @positioning_down = [[0, -20], [0, -19], [0, -20]]
    @positioning_left = [[4, -16], [4, -15], [4, -16]]
    @positioning_up = [[0, -15], [0, -14], [0, -15]]
    set_ride_data
    
    # いかだ
    @character_name = "Ride"
    @character_index = 2
    @positioning_down = [[0, -13], [0, -12], [0, -11]]
    @positioning_left = [[0, -11], [0, -12], [0, -13]]
    @positioning_up = [[0, -15], [0, -14], [0, -13]]
    @priority_type = 0
    set_ride_data
    
    # フロート
    @character_name = "Ride"
    @character_index = 5
    @positioning_down = [[0, -11], [0, -12], [0, -13]]
    @positioning_left = [[0, -11], [0, -12], [0, -13]]
    @positioning_up = [[0, -11], [0, -12], [0, -13]]
    @priority_type = 0
    set_ride_data
      
    # ペガサス
    @character_name = "Ride"
    @character_index = 3
    @riding_pct_name = "Ride"
    @riding_pct_index = 7
    @positioning_down = [[0, -19], [0, -20], [0, -21]]
    @positioning_left = [[4, -19], [4, -18], [4, -17]]
    @positioning_up = [[0, -15], [0, -14], [0, -13]]
    set_ride_data
    
    # トロッコ
    @character_name = "Vehicle"
    @character_index = 6
    @riding_pct_name = "Ride"
    @riding_pct_index = 4
    @positioning_down = [[0, -10], [0, -11], [0, -10]]
    @positioning_left = [[-2, -10], [-1, -10], [-2, -10]]
    @positioning_right = [[1, -10], [2, -10], [1, -10]]
    @positioning_up = [[0, -10], [0, -11], [0, -10]]
    set_ride_data
    
    # オブジェクト
    @character_name = "!$Object"
    @riding_pct_name = "self"
    @positioning_down = [[-1, -9], [0, -10], [1, -9]]
    @positioning_left = [[-6, -11], [-5, -10], [-4, -9]]
    @positioning_up = [[1, -11], [0, -12], [-1, -11]]
    @object_type = true
    set_ride_data
    
        # オブジェクト
    @character_name = "!$Object2"
    @riding_pct_name = "self"
    @positioning_down = [[-1, -9], [0, -10], [1, -9]]
    @positioning_left = [[-6, -11], [-5, -10], [-4, -9]]
    @positioning_up = [[1, -11], [0, -12], [-1, -11]]
    @object_type = true
    set_ride_data
    
    # アイテム
    @character_name = "$Item"
    @riding_pct_name = "self"
    @positioning_down = [[-1, 1], [0, 0], [1, 1]]
    @positioning_left = [[-6, -1], [-5, 0], [-4, 1]]
    @positioning_up = [[1, -1], [0, -2], [-1, -1]]
    @object_type = true
    set_ride_data

    # 魔法の絨毯
    @character_name = "Ride"
    @character_index = 6
    @positioning_down = [[0, -12], [0, -13], [0, -14]]
    @positioning_left = [[0, -10], [0, -11], [0, -12]]
    @positioning_up = [[0, -12], [0, -13], [0, -14]]
    @priority_type = 0
    set_ride_data
    
    # 飛竜
    @character_name = "$Wivern"
    @character_index = 0
    @riding_pct_name = "$Wivern_Ride"
    @riding_pct_index = 0
    @positioning_down = [[0, -25], [0, -24], [0, -24]]
    @positioning_left = [[7, -19], [7, -19], [7, -20]]
    @positioning_up = [[0, -24], [0, -23], [0, -23]]
    #@priority_type = 1
    set_ride_data
    
    # ランタン
    @character_name = "!Flame"
    @character_index = 1
    @riding_pct_name = "self"
    @positioning_down = [[-6, 5], [-5, 4], [-4, 5]]
    @positioning_left = [[-3, 3], [-2, 4], [-1, 5]]
    @positioning_up = [[7, 1], [8, 0], [7, -1]]
    @object_type = true
    set_ride_data
    
    # 宝玉
    @character_name = "!Other1"
    @character_index = 6
    @riding_pct_name = "self"
    @positioning_down = [[-1, 12], [0, 11], [1, 12]]
    @positioning_left = [[-6, 10], [-5, 11], [-4, 12]]
    @positioning_up = [[1, 10], [0, 9], [-1, 10]]
    @object_type = true
    set_ride_data
    
    # ニワトリ
    @character_name = "Animal"
    @character_index = 2
    @riding_pct_name = "self"
    @positioning_down = [[-1, 2], [0, 1], [1, 2]]
    @positioning_left = [[-8, -1], [-7, 0], [-6, 1]]
    @positioning_up = [[1, -2], [0, -3], [-1, -2]]
    @object_type = true
    set_ride_data
  end
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------  
  #　[character_name, character_index] をキーとしたハッシュとして
  #  他クラスより参照します。
  #--------------------------------------------------------------------------
  attr_accessor :data_riding_pct_name
  attr_accessor :data_riding_pct_index
  attr_accessor :data_positioning_down
  attr_accessor :data_positioning_left
  attr_accessor :data_positioning_right
  attr_accessor :data_positioning_up
  attr_accessor :data_priority_type
  attr_accessor :data_object_type
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @data_riding_pct_name = {}
    @data_riding_pct_index = {}
    @data_positioning_down = {}
    @data_positioning_left = {}
    @data_positioning_right = {}
    @data_positioning_up = {}
    @data_priority_type = {}
    @data_object_type = {}
    clear
    make_ride_data
  end
  #--------------------------------------------------------------------------
  # ○ クリア
  #--------------------------------------------------------------------------
  def clear
    @character_name = ""
    @character_index = 0
    @riding_pct_name = ""
    @riding_pct_index = 0
    @positioning_down = [[0, 0], [0, 0], [0, 0]]
    @positioning_left = [[0, 0], [0, 0], [0, 0]]
    @positioning_right = nil
    @positioning_up = [[0, 0], [0, 0], [0, 0]]
    @priority_type = nil
    @object_type = false
  end
  #--------------------------------------------------------------------------
  # ○ 騎乗用キャラクター・データベース化
  #--------------------------------------------------------------------------  
  def set_ride_data
    key = [@character_name, @character_index]
    @data_riding_pct_name[key] = @riding_pct_name
    @data_riding_pct_index[key] = @riding_pct_index
    @data_positioning_down[key] = @positioning_down
    @data_positioning_left[key] = @positioning_left
    if @positioning_right == nil
      @data_positioning_right[key] = [[], [], []]
      @data_positioning_right[key][0][0] = -@positioning_left[0][0]
      @data_positioning_right[key][0][1] = @positioning_left[0][1]
      @data_positioning_right[key][1][0] = -@positioning_left[1][0]
      @data_positioning_right[key][1][1] = @positioning_left[1][1]
      @data_positioning_right[key][2][0] = -@positioning_left[2][0]
      @data_positioning_right[key][2][1] = @positioning_left[2][1]
    else
      @data_positioning_right[key] = @positioning_right
    end
    @data_positioning_up[key] = @positioning_up
    @data_priority_type[key] = @priority_type
    @data_object_type[key] = @object_type
    clear
  end
end

#==============================================================================
# ■ Game_Vehicle
#------------------------------------------------------------------------------
# 　乗り物を扱うクラスです。このクラスは Game_Map クラスの内部で使用されます。
# 現在のマップに乗り物がないときは、マップ座標 (-1,-1) に設定されます。
#==============================================================================

class Game_Vehicle < Game_Character
  #--------------------------------------------------------------------------
  # ○ 拡張の乗り物のセッティング
  #      @move_speed : 乗り物の速度
  #      @walk_anime : 移動時アニメ
  #      @step_anime : 停止時アニメ
  #--------------------------------------------------------------------------
  def riding_vehicle_settings
    case @type
    when 3 # 馬
      @map_id = Expansion_Vehicle::HORSE_MAP_ID
      @x = Expansion_Vehicle::HORSE_X
      @y = Expansion_Vehicle::HORSE_Y
      @character_name = Expansion_Vehicle::HORSE_FILE_NAME
      @character_index = Expansion_Vehicle::HORSE_FILE_INDEX
      @bgm = RPG::BGM.new
      @bgm.name  = Expansion_Vehicle::HORSE_BGM_NAME
      
      @move_speed = 5
      @walk_anime = true
      @step_anime = false
      
    when 4 # 大型飛行船
      @map_id = Expansion_Vehicle::BIG_AIRSHIP_MAP_ID
      @x = Expansion_Vehicle::BIG_AIRSHIP_X
      @y = Expansion_Vehicle::BIG_AIRSHIP_Y
      @character_name = Expansion_Vehicle::BIG_AIRSHIP_FILE_NAME
      @character_index = Expansion_Vehicle::BIG_AIRSHIP_FILE_INDEX
      @bgm = RPG::BGM.new
      @bgm.name = Expansion_Vehicle::BIG_AIRSHIP_BGM_NAME
      
      @move_speed = 5
      @walk_anime = true
      @step_anime = true
      
    when 5 # 魔法の絨毯
      @map_id = Expansion_Vehicle::MAGIC_CARPET_MAP_ID
      @x = Expansion_Vehicle::MAGIC_CARPET_X
      @y = Expansion_Vehicle::MAGIC_CARPET_Y
      @character_name = Expansion_Vehicle::MAGIC_CARPET_FILE_NAME
      @character_index = Expansion_Vehicle::MAGIC_CARPET_FILE_INDEX
      @bgm = RPG::BGM.new
      @bgm.name = Expansion_Vehicle::MAGIC_CARPET_BGM_NAME
      
      @move_speed = 6
      @walk_anime = true
      @step_anime = true
    end
  end
  #--------------------------------------------------------------------------
  # ○ 既存の乗り物のセッティング
  #      @move_speed : 乗り物の速度
  #      @walk_anime : 移動時アニメ
  #      @step_anime : 停止時アニメ
  #--------------------------------------------------------------------------
  def tig_ev_vehicle_initialize
    case @type
    when 0 # 小型船
      @move_speed = 4
      @walk_anime = true
      @step_anime = true
    when 1 # 大型船
      @move_speed = 5
      @walk_anime = false
      @step_anime = true
    when 2 # 飛行船
      @move_speed = 5
      @walk_anime = true
      @step_anime = true
    end
  end
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :pattern                  # パターン
  attr_reader   :bgm                      # 乗り込み時BGM
  attr_accessor :priority_type            # プライオリティタイプ
  attr_accessor :move_speed               # 移動速度
  attr_accessor :walk_anime               # 歩行アニメ
  attr_accessor :step_anime               # 足踏みアニメ
  attr_accessor :instant                  # 一時的な呼び出しフラグ
  #--------------------------------------------------------------------------
  # ◎ システム設定のロード
  #--------------------------------------------------------------------------
  alias tig_ev_load_system_settings load_system_settings
  def load_system_settings
    tig_ev_load_system_settings
    tig_ev_vehicle_initialize
    riding_vehicle_settings
    @instant = false
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
                                     # 位置の調整
    if @driving
      @map_id = $game_map.map_id
      sync_with_player                
    elsif @map_id == $game_map.map_id
      moveto(@x, @y)
    end
                                     # プライオリティタイプ調整
    if [2, 4].include?(@type)         # 飛行船・大型飛行船の場合
      @priority_type = @driving ? 2 : vehicle_priority
    else                              # その他の乗り物
      @priority_type = @driving ? 1 : vehicle_priority
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    
    if [2, 4, 5].include?(@type)     # 飛行船・大型飛行船・魔法の絨毯の場合
      
      case @type                     # タイプに合わせた最頂点の高さの取得
      when 2 ; height = 1
      when 4 ; height = 2
      when 5 ; height = 1
      end
      
      if @driving
        return if $game_player.follow_member_gathering == true
        if @altitude < MAX_ALTITUDE * height
          @altitude += 1             # 高度を上げる
          
          #Shuu_Fog.change(10,"fog",0,-1,35,0)
          #$game_map.fogopac(1, 35, 15)
        end
      elsif @altitude > 0
        #$game_map.fogopac(1, 0, 15)
#        Shuu_Fog.change(60,"")
        @altitude -= 1               # 高度を下げる
        if @altitude == 0
          @priority_type = vehicle_priority   # 待機時のプライオリティに
          $game_player.ride_off_character
          $game_switches[204] = false
          $game_player.turn_down
          update_bush_depth
          turn_left###下龍
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ◎ アニメカウントの更新
  #--------------------------------------------------------------------------
  alias tig_ev_update_animation update_animation unless $@
  def update_animation
    if riding_type? and rided_character == nil  # 乗り込み最中のアニメをオフに
      @pattern = @original_pattern
      return
    end
    unless @driving or @altitude > 0           # 乗り物未使用時のアニメをオフに
      @pattern = @original_pattern
      return
    end
    tig_ev_update_animation
  end
  #--------------------------------------------------------------------------
  # ◎ プレイヤーとの同期
  #--------------------------------------------------------------------------
  alias tig_ev_ve_sync_with_player sync_with_player
  def sync_with_player
    tig_ev_ve_sync_with_player
    @stop_count = $game_player.stop_count
                     # 停止時のアニメを正しくシンクロさせる為のカウント同期追加
    
  end
  #--------------------------------------------------------------------------
  # ◎ 移動可能判定
  #--------------------------------------------------------------------------
  alias tig_ev_ve_movable? movable?
  def movable?
    return false if (@type == 4 and @altitude < MAX_ALTITUDE * 2)
    return false if (@type == 5 and @altitude < MAX_ALTITUDE)
                                     # 上昇中、下降中ならば動けない(追加乗り物)
    return tig_ev_ve_movable?
  end
  #--------------------------------------------------------------------------
  # ○ 待機中のプライオリティの取得
  #--------------------------------------------------------------------------
  def vehicle_priority
    key = [@character_name, @character_index]
    result = $riding_data.data_priority_type[key]
    return result == nil ? 1 : result
  end
  #--------------------------------------------------------------------------
  # ◎ 画面 Y 座標の取得
  #--------------------------------------------------------------------------
  alias tig_ev_ve_screen_y screen_y
  def screen_y
    if @type == 5
      super - altitude / 5           # 魔法の絨毯を浮遊させる(高さの調節)
    else
      tig_ev_ve_screen_y
    end
  end
  #--------------------------------------------------------------------------
  # ● 乗り物に乗る
  #--------------------------------------------------------------------------
  def get_on
    @driving = true
    if [2, 4].include?(@type)     # 飛行船・大型飛行船の場合
      @direction = 2###騎乘物面向
    $game_player.turn_down
      @priority_type = 2          # プライオリティを「通常キャラの上」に変更
    end
    @bgm.play if @bgm.name != ""  # BGM 開始 (設定されていなければ今の曲を継続)
    add_vehicle_states
  end
  #--------------------------------------------------------------------------
  # ● 乗り物から降りる
  #--------------------------------------------------------------------------
  def get_off
    @driving = false
    unless [2, 4, 5].include?(@type)     # 飛行船・大型飛行船・魔法の絨毯の場合
      @priority_type = vehicle_priority   # 本来のプライオリティに戻す
      $game_player.ride_off_character     # 騎乗状態の解除
    end
    @direction = 2###騎乘物面向
    $game_player.turn_down
    remove_vehicle_state
    ####################
    if $game_switches[23] == true
      $game_actors[1].set_graphic("$actor01",0,"F96",0)
      $game_player.refresh
    end
    $game_switches[23] = false if $game_switches[23] == true
    $game_switches[37] = true
    $game_system.encounter_disabled = false
    $game_system.menu_disabled = false
    ###################
  end
  #--------------------------------------------------------------------------
  # ○ 乗り物ステートの取得
  #--------------------------------------------------------------------------
  def vehicle_states
    states = []
    case @type
    when 0 ; states = Expansion_Vehicle::BOAT_STATE
    when 1 ; states = Expansion_Vehicle::SHIP_STATE
    when 2 ; states = Expansion_Vehicle::AIRSHIP_STATE
    when 3 ; states = Expansion_Vehicle::HORSE_STATE
    when 4 ; states = Expansion_Vehicle::BIG_AIRSHIP_STATE
    when 5 ; states = Expansion_Vehicle::MAGIC_CARPET_STATE
    end
    return states
  end
  #--------------------------------------------------------------------------
  # ○ 乗り物ステートの付加
  #--------------------------------------------------------------------------
  def add_vehicle_states
    for state in vehicle_states
      $game_party.members.each {|actor|actor.add_state(state)}
    end
  end
  #--------------------------------------------------------------------------
  # ○ 乗り物ステートの解除
  #--------------------------------------------------------------------------
  def remove_vehicle_state
    for state in vehicle_states
      $game_party.members.each {|actor|actor.remove_state(state)}
    end
  end
  #--------------------------------------------------------------------------
  # ● 位置の変更　※変数指定を組み込み
  #       map_id : 移動先のマップID
  #            x : 移動先マップのX座標
  #            y : 移動先マップのY座標
  #    variables : 変数指定するか？
  #--------------------------------------------------------------------------
  def set_location(map_id, x, y, variables = false)
    
    # 変数で指定の場合
    if variables                            
      map_id = $game_variables[map_id]
      x = $game_variables[x]
      y = $game_variables[y]
    end
    
    @map_id = map_id
    @x = x
    @y = y
    refresh
  end
  #--------------------------------------------------------------------------
  # ○ 乗り物を呼び出す
  #     here : true = プレーヤーと同位置　false = プレーヤーの目の前
  #--------------------------------------------------------------------------
  def call(test = false, here = false)
    return false if $game_player.event_vehicle_lock
    
    # 対象となる位置座標を取得                                             
    if here # この場
      x = $game_player.x
      y = $game_player.y
    else    # 目の前
      x = $game_map.x_with_direction($game_player.x, $game_player.direction)
      y = $game_map.y_with_direction($game_player.y, $game_player.direction)
    end
    
    # 飛行船進入禁止エリア(拡張スクリプト設定)内で呼び出し禁止されているタイプ
    if $game_map.airship_obstacle_area != nil and
      $game_map.airship_obstacle_area.include?([x, y])             
      return false if Expansion_Vehicle::CAN_T_CALL.include?(@type)
    end
    
    # 他の乗り物がそこにある？
    return false if $game_map.vehicle_pos_nt?(x, y) 
    
    # タイプ別に通行判定・着陸判定
    case @type
    when 0  # 小型船
      can_call = $game_map.boat_passable?(x, y)
    when 1  # 大型船
      can_call = $game_map.ship_passable?(x, y)
    when 2  # 飛行船  
      can_call = $game_map.airship_land_ok?(x, y)
    when 3  # 馬
      can_call = $game_map.horse_passable?(x, y)
    when 4  # 大型飛行船
      can_call = $game_map.big_airship_land_ok?(x, y)
    when 5  # 魔法の絨毯
      can_call = $game_map.airship_land_ok?(x, y) 
    end
    
    # 判定に問題なければ実際に呼ぶ
    if can_call                                  
      set_location($game_map.map_id, x, y) unless test
      return true
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ○ この場に乗り物を呼び出す
  #      このコマンドで呼んだ乗り物は、降りた時に消えてしまう。
  #--------------------------------------------------------------------------
  def call_here
    call(false, true)
  end
  #--------------------------------------------------------------------------
  # ○ 目の前に乗り物を呼び出せるかのテスト
  #--------------------------------------------------------------------------
  def call_test
    return call(true)
  end
  #--------------------------------------------------------------------------
  # ○ この場に乗り物を呼び出せるかのテスト
  #--------------------------------------------------------------------------
  def call_test_here
    return call(true, true)
  end  
  #--------------------------------------------------------------------------
  # ○ 一時的に乗り物を呼び出す
  #      このコマンドで呼んだ乗り物は、降りた時に消えてしまう。
  #--------------------------------------------------------------------------
  def instant_call
    @instant = true
    call
  end
  #--------------------------------------------------------------------------
  # ○ この場に一時的に乗り物を呼び出す
  #      このコマンドで呼んだ乗り物は、降りた時に消えてしまう。
  #--------------------------------------------------------------------------
  def instant_call_here
    @instant = true
    call(false, true)
  end
end

#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　タイトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Title < Scene_Base
  #--------------------------------------------------------------------------
  # ◎ 各種ゲームオブジェクトの作成
  #--------------------------------------------------------------------------
  alias tig_ev_create_game_objects create_game_objects
  def create_game_objects
    tig_ev_create_game_objects
    $riding_data = Riding_Data.new             # 騎乗型キャラクターのデータ生成
  end
end

#==============================================================================
# ■ AudioFile
#------------------------------------------------------------------------------
# 　BGM、BGS、ME、SE のスーパークラスです。
#==============================================================================

class RPG::AudioFile
  #--------------------------------------------------------------------------
  # ○ ファイル(ネーム)の変更
  #  名前の変更だけで曲を変更できるように
  #--------------------------------------------------------------------------
  def name=(name)
    @name = name
  end
end

#==============================================================================
# ■ Game_Map
#------------------------------------------------------------------------------
# 　マップを扱うクラスです。スクロールや通行可能判定などの機能を持っています。
# このクラスのインスタンスは $game_map で参照されます。
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :airship_obstacle_area            # 飛行船補助スクリプト連携用
  #--------------------------------------------------------------------------
  # ◎ セットアップ
  #     map_id : マップ ID
  # ※ 乗り物を別マップに乗り越した際の処理を追加
  #--------------------------------------------------------------------------
  alias tig_ev_setup setup
  def setup(map_id)
    tig_ev_setup(map_id)
    
    result = false
    if $game_player.vehicle_event_data != nil  # イベント乗り物持ち越し時の処理
      # マップ内に画像・名前が同じイベントが存在するなら乗り物を継続する
      for event in @events.values
        if event.name == $game_player.vehicle_event_data[0] and
           event.character_name == $game_player.vehicle_event_data[1] and
           event.character_index == $game_player.vehicle_event_data[2]
          $game_player.vehicle_event_data[3] = event.id
          if event.riding_type?
            $game_player.ride_off_character
            $game_player.ride_on(event)
            key = [event.character_name, event.character_index]
          end
          $game_player.moveto($game_player.new_x, $game_player.new_y)
          event.sync_with_player
          result = true
          break
        end
      end
    end
    unless result
      event_vehicle_refresh     # イベント乗り物の初期化(何も乗っていない状態に)
    end

    interpreter.update
    
  end
  #--------------------------------------------------------------------------
  # ○ イベント乗り物のリフレッシュ #####
  #--------------------------------------------------------------------------
  def event_vehicle_refresh
    $game_player.vehicle_event_data = nil
    $game_player.event_vehicle_lock = false
    $game_player.vehicle_hide = false
    if defined? $game_party.follow_member_transparent_off
      $game_party.follow_member_transparent_off
    end
    if $game_player.vehicle_type == -1
      $game_player.ride_off_character
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 乗り物の作成
  #--------------------------------------------------------------------------
  alias tig_ev_create_vehicles create_vehicles
  def create_vehicles
    tig_ev_create_vehicles
    @vehicles[3] = Game_Vehicle.new(3)    # 馬
    @vehicles[4] = Game_Vehicle.new(4)    # 大型飛行船
    @vehicles[5] = Game_Vehicle.new(5)    # 魔法の絨毯
  end
  #--------------------------------------------------------------------------
  # ○ 馬の取得
  #--------------------------------------------------------------------------
  def horse
    return @vehicles[3]
  end
  #--------------------------------------------------------------------------
  # ○  大型飛行船の取得
  #--------------------------------------------------------------------------
  def big_airship
    return @vehicles[4]
  end
  #--------------------------------------------------------------------------
  # ○  魔法の絨毯の取得
  #--------------------------------------------------------------------------
  def magic_carpet
    return @vehicles[5]
  end
  #--------------------------------------------------------------------------
  # ○  プレイヤーの乗り物になっているイベントの取得
  #-------------------------------------------------------------------------- 
  def event_vehicle
    return nil if $game_player.vehicle_event_data == nil
    return @events[$game_player.vehicle_event_data[3]]
  end
  #--------------------------------------------------------------------------
  # ○ 拡張乗り物用の通行障害判定
  #     ※ 一部の乗り物が通過することができないタイルのIDをここで指定。
  #--------------------------------------------------------------------------
  def ex_obstacle?(tile_id)
    if (2048..8191).include?(tile_id)
      tile_id -= ((tile_id - 2048) % 48)
    end
    return [157,
            160, 161, 162, 163, 164, 165, 166, 
            168, 169, 170, 171, 172, 174, 175, 
            184, 185, 186, 187, 188, 189, 190, 191, 
            200, 201, 202, 203, 204, 205, 206, 207, 
            208, 209, 210, 211, 212, 213, 214, 
            216, 217, 218, 219, 220, 221, 222, 
            226, 227, 228, 
            232, 233, 234, 235, 236, 237, 238, 
            241, 242, 
            248, 249, 250, 251, 252, 253, 254, 255, 
            2864, 3248, 3632, 4016, 
            2912, 3296, 3680, 4064].include?(tile_id)
  end
  #--------------------------------------------------------------------------
  # ○ 拡張乗り物用の通行許可判定
  #　　 ※ 浮遊型乗り物が越えることのできるタイルのIDをここで指定。
  #--------------------------------------------------------------------------
  def ex_pass?(tile_id)
    if (2048..8191).include?(tile_id)
      tile_id -= ((tile_id - 2048) % 48)
    end
    return [526, 527, 671, 679,
            2048, 2096, 2240, 2336,
            2432, 2528, 2624, 2720,
            1536,
            1544, 1545, 1546, 1547, 1548, 1549, 1550, 1551, 
            1560, 1561, 1562, 1563, 1564, 1565, 1566, 1567, 
            1576, 1577, 1578, 1579, 1580, 1581, 1582, 1583, 
            1624, 1625].include?(tile_id)
  end
  #--------------------------------------------------------------------------
  # ○ テーブル型オブジェクト判定
  #　　 ※ オブジェクト型乗り物を置くことができるタイルのIDをここで指定。
  #--------------------------------------------------------------------------
  def ex_table?(tile_id)
    if (2048..8191).include?(tile_id)
      tile_id -= ((tile_id - 2048) % 48)
    end
    return [75, 131,
            350, 352, 353, 354, 355, 
            680,
            3152, 3536, 3920, 4304].include?(tile_id)
  end
  #--------------------------------------------------------------------------
  # ○ 馬の通行可能判定
  #    ※ passable? メソッドを部分改造したものです。
  #--------------------------------------------------------------------------
  def horse_passable?(x, y, flag = 0x01)
    for event in events_xy(x, y)            # 座標が一致するイベントを調べる
      next if event.tile_id == 0            # グラフィックがタイルではない
      next if event.priority_type > 0       # [通常キャラの下] ではない
      next if event.through                 # すり抜け状態
      pass = @passages[event.tile_id]       # 通行属性を取得
      next if pass & 0x10 == 0x10           # [☆] : 通行に影響しない
      return true if pass & flag == 0x00    # [○] : 通行可
      return false if pass & flag == flag   # [×] : 通行不可
    end
    for i in [2, 1, 0]                      # レイヤーの上から順に調べる
      tile_id = @map.data[x, y, i]          # タイル ID を取得
      return false if tile_id == nil        # タイル ID 取得失敗 : 通行不可
      pass = @passages[tile_id]             # 通行属性を取得
      next if pass & 0x10 == 0x10           # [☆] : 通行に影響しない
      
      return false if ex_obstacle?(tile_id) ### 拡張通行不可(特殊部分) ###
      
      return true if pass & flag == 0x00    # [○] : 通行可
      return false if pass & flag == flag   # [×] : 通行不可
    end
    return false                            # 通行不可
  end
  #--------------------------------------------------------------------------
  # ○ 魔法の絨毯の通行可能判定
  #    ※ passable? メソッドを部分改造したものです。
  #--------------------------------------------------------------------------
  def magic_carpet_passable?(x, y, flag = 0x01)
    for event in events_xy(x, y)            # 座標が一致するイベントを調べる
      next if event.tile_id == 0            # グラフィックがタイルではない
      next if event.priority_type > 0       # [通常キャラの下] ではない
      next if event.through                 # すり抜け状態
      pass = @passages[event.tile_id]       # 通行属性を取得
      next if pass & 0x10 == 0x10           # [☆] : 通行に影響しない
      return true if pass & flag == 0x00    # [○] : 通行可
      return false if pass & flag == flag   # [×] : 通行不可
    end
    for i in [2, 1, 0]                      # レイヤーの上から順に調べる
      tile_id = @map.data[x, y, i]          # タイル ID を取得
      return false if tile_id == nil        # タイル ID 取得失敗 : 通行不可
      pass = @passages[tile_id]             # 通行属性を取得
      next if pass & 0x10 == 0x10           # [☆] : 通行に影響しない
      
      return false if ex_obstacle?(tile_id) ### 拡張通行不可(特殊部分) ###
      return true if ex_pass?(tile_id)      ### 拡張通行許可(特殊部分) ###
      
      return true if pass & flag == 0x00    # [○] : 通行可
      return false if pass & flag == flag   # [×] : 通行不可
    end
    return false                            # 通行不可
  end
  #--------------------------------------------------------------------------
  # ○ フロートの通行可能判定
  #    ※ passable? メソッドを部分改造したものです。
  #--------------------------------------------------------------------------
  def float_passable?(x, y, flag = 0x01)
 #   for event in events_xy(x, y)            # 座標が一致するイベントを調べる
 #     next if event.tile_id == 0            # グラフィックがタイルではない
 #     next if event.priority_type > 0       # [通常キャラの下] ではない
 #     next if event.through                 # すり抜け状態
 #     pass = @passages[event.tile_id]       # 通行属性を取得
 #     next if pass & 0x10 == 0x10           # [☆] : 通行に影響しない
 #     return true if pass & flag == 0x00    # [○] : 通行可
 #     return false if pass & flag == flag   # [×] : 通行不可
 #   end
    for i in [2, 1, 0]                      # レイヤーの上から順に調べる
      tile_id = @map.data[x, y, i]          # タイル ID を取得
      return false if tile_id == nil        # タイル ID 取得失敗 : 通行不可
      pass = @passages[tile_id]             # 通行属性を取得
      next if pass & 0x10 == 0x10           # [☆] : 通行に影響しない
      
      return false if ex_obstacle?(tile_id) ### 拡張通行不可(特殊部分) ###
      return true if ex_pass?(tile_id)      ### 拡張通行許可(特殊部分) ###
      
      #return true if pass & flag == 0x00    # [○] : 通行可 # コメントアウト
      #return false if pass & flag == flag   # [×] : 通行不可 # コメントアウト
    end
    return false                            # 通行不可
  end
  #--------------------------------------------------------------------------
  # ○ オブジェクトの設置可能判定
  #    ※ passable? メソッドを部分改造したものです。
  #--------------------------------------------------------------------------
  def object_passable?(x, y, flag = 0x01)
    for event in events_xy(x, y)            # 座標が一致するイベントを調べる
      next if event.tile_id == 0            # グラフィックがタイルではない
      next if event.priority_type > 0       # [通常キャラの下] ではない
      next if event.through                 # すり抜け状態
      pass = @passages[event.tile_id]       # 通行属性を取得
      next if pass & 0x10 == 0x10           # [☆] : 通行に影響しない
      return true if pass & flag == 0x00    # [○] : 通行可
      return false if pass & flag == flag   # [×] : 通行不可
    end
    for i in [2, 1, 0]                      # レイヤーの上から順に調べる
      tile_id = @map.data[x, y, i]          # タイル ID を取得
      return false if tile_id == nil        # タイル ID 取得失敗 : 通行不可
      pass = @passages[tile_id]             # 通行属性を取得
      next if pass & 0x10 == 0x10           # [☆] : 通行に影響しない
      return true if pass & flag == 0x00    # [○] : 通行可
      
      return true if ex_table?(tile_id)     ### テーブル判定(特殊部分) ###

      #return true if pass & flag == 0x00    # [○] : 通行可 # コメントアウト      
      #return false if pass & flag == flag   # [×] : 通行不可
    end
    return false                            # 通行不可
  end
  #--------------------------------------------------------------------------
  # ◎ 飛行船の着陸可能判定
  #     x : X 座標
  #     y : Y 座標
  #--------------------------------------------------------------------------
  alias tig_ev_airship_land_ok? airship_land_ok?
  def airship_land_ok?(x, y)
    if $game_player.now_vehicle == @vehicles[4]  # 現在の乗り物が大型船ならば
      return big_airship_land_ok?(x, y)           # 大型飛行船の着陸可能判定
    else                                         # 飛行船の着陸可能判定
      return false if hide_tile?(x, y)            # 物陰には着地不可
      for i in [2, 1, 0]
        return false if ex_obstacle?(@map.data[x, y, i]) # 拡張通行不可
      end
      return tig_ev_airship_land_ok?(x, y)       # 通常の着陸可能判定
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 大型飛行船の着陸可能判定
  #     x : X 座標
  #     y : Y 座標
  #--------------------------------------------------------------------------
  def big_airship_land_ok?(x, y)
    return false if hide_tile?(x, y)   # 物陰には着地不可
    return passable?(x, y)             # 通常の通行判定
  end
  #--------------------------------------------------------------------------
  # ○ 物陰か？判定
  #     x : X 座標
  #     y : Y 座標
  #--------------------------------------------------------------------------
  def hide_tile?(x, y)
    tile_id = @map.data[x, y, 2]
    if tile_id != nil
      return @passages[tile_id] == 0x16
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ○ なんらかの乗り物があるか？
  #     x : X 座標
  #     y : Y 座標
  #--------------------------------------------------------------------------
  def vehicle_pos_nt?(x, y)
    return true if boat.pos_nt?(x, y)
    return true if ship.pos_nt?(x, y)
    return true if airship.pos_nt?(x, y) and not airship.driving
    return true if horse.pos_nt?(x, y)
    return true if big_airship.pos_nt?(x, y) and not big_airship.driving
    return true if magic_carpet.pos_nt?(x, y)
    return false
  end
  #--------------------------------------------------------------------------
  # ◎ BGM / BGS 自動切り替え
  #    ※ 乗り物を降りた際のBGM再開の挙動を修正。
  #--------------------------------------------------------------------------
  alias tig_ev_autoplay autoplay
  def autoplay
    if $game_player.vehicle_type > -1            # 乗り物時の自動演奏
      $game_player.now_vehicle.bgm.play
      $game_player.walking_bgm = @map.bgm
      unless @map.autoplay_bgm                   # マップBGMが未設定なら
        $game_player.walking_bgm.name = ""        # 歩行再開時のBGMを無音に
      end
    else
      tig_ev_autoplay
    end
  end
end

#==============================================================================
# ■ Game_Character
#------------------------------------------------------------------------------
# 　キャラクターを扱うクラスです。このクラスは Game_Player クラスと Game_Event
# クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :altitude
  attr_reader   :stop_count
  attr_reader   :on_tile        # 壁タイル拡張用ダミー
  attr_reader   :turn_back      # 壁タイル拡張用ダミー
  attr_accessor :stop_count
  attr_accessor :riding_character_id
  attr_accessor :rided_character_id
  #--------------------------------------------------------------------------
  # ◎ オブジェクト初期化
  #--------------------------------------------------------------------------
  alias tig_ev_initialize initialize 
  def initialize  
    tig_ev_initialize
    @riding_character_id = nil
    @rided_character_id = nil
    @altitude = 0
  end
  #--------------------------------------------------------------------------
  # ◎ 移動時の更新
  #    ※ 他のキャラクターへの騎乗時のアニメを停止させる。
  #--------------------------------------------------------------------------
  alias tig_ev_update_move update_move
  def update_move
    tig_ev_update_move
    if riding_character != nil           # 他のキャラクターへ騎乗している場合
      key = [riding_character.character_name, riding_character.character_index]
      unless $riding_data.data_object_type[key]  # オブジェクトタイプでなければ
        @anime_count = 0
      end
    end
  end 
  #--------------------------------------------------------------------------
  # ○ 騎乗タイプの乗り物か？(オブジェクトタイプ含む)
  #--------------------------------------------------------------------------
  def riding_type?
    key = [@character_name, @character_index]
    return $riding_data.data_riding_pct_name.key?(key)
  end
  #--------------------------------------------------------------------------
  # ○ オブジェクトタイプ(の乗り物)か？
  #--------------------------------------------------------------------------
  def object_type?
    key = [@character_name, @character_index]
    return $riding_data.data_object_type.key?(key)
  end
  #--------------------------------------------------------------------------
  # ◎ キャラクター衝突判定
  #     x : X 座標
  #     y : Y 座標
  #    プレイヤーと乗り物を含め、通常キャラの衝突を検出する。
  #--------------------------------------------------------------------------
  alias tig_ev_collide_with_characters? collide_with_characters?
  def collide_with_characters?(x, y)
    if @priority_type == 1                     # 自分が通常キャラ
      if self.is_a?(Game_Player)                # プレイヤーの場合
        if riding_character != nil              # 騎乗している場合
          return true if $game_player.other_vehicle?(x, y) # その他の乗り物と衝突   
        end
      else                                      # プレイヤー以外の場合
        return true if $game_map.vehicle_pos_nt?(x, y) # 乗り物と衝突
      end
    end
    return tig_ev_collide_with_characters?(x, y)
  end
  #--------------------------------------------------------------------------
  # ◎ 画面 Z 座標の取得
  #    ※ 騎乗用画像追加により同位置画像が増える為、
  #       重なり順を座標に合わせて整理している。
  #--------------------------------------------------------------------------
  alias tig_ev_screen_z screen_z
  def screen_z
    if riding_character != nil
      return riding_character.screen_z + 1
    end
    return tig_ev_screen_z + (screen_y / 18) * 3   
  end    
  #--------------------------------------------------------------------------
  # ◎ 茂み深さの更新
  #    ※ 騎乗したキャラクターに茂み処理がされるのを防ぐ。
  #--------------------------------------------------------------------------
  alias tig_ev_update_bush_depth update_bush_depth
  def update_bush_depth
    if self.is_a?(Game_Player) and $game_player.now_vehicle != nil
      return @bush_depth = 0
    elsif self.is_a?(Game_Vehicle) and @type == 5 
      return @bush_depth = 0
    elsif riding_character != nil
      return @bush_depth = 0 unless riding_character.object_type?
    end
    return tig_ev_update_bush_depth
  end
  #--------------------------------------------------------------------------
  # ○ 他のキャラクターにのる
  #-------------------------------------------------------------------------- 
  def ride_on(character, test = false)
    return false if riding_character != nil         # 既に騎乗中なら騎乗不可
    return false if character.rided_character != nil 
                                       # すでに乗り手がいるキャラへは騎乗不可
    return true if test                # テストならばここで true を返して終了
    
    if character.is_a?(Game_Player)
      @riding_character_id = 0
    elsif character.is_a?(Game_Vehicle)
      @riding_character_id = -1
      @riding_character_id -= character.type
    else
      @riding_character_id = character.id
    end
    if self.is_a?(Game_Player)
      character.rided_character_id = 0
    elsif self.is_a?(Game_Vehicle)
      character.rided_character_id = -1
      character.rided_character_id -= @type
    else
      character.rided_character_id = @id
    end   
    character.sync_with_rided
    return true
  end
  #--------------------------------------------------------------------------
  # ○ 自分が乗り物にしているキャラクター
  #--------------------------------------------------------------------------
  def riding_character
    return if @riding_character_id == nil
    if @riding_character_id == 0
      return $game_player 
    elsif @riding_character_id < 0
      return $game_map.vehicles[@riding_character_id.abs - 1]
    else
      return $game_map.events[@riding_character_id]
    end
  end
  #--------------------------------------------------------------------------
  # ○ 自分の乗り手となっているキャラクター
  #--------------------------------------------------------------------------
  def rided_character
    return if @rided_character_id == nil
    if @rided_character_id == 0
      return $game_player 
    elsif @rided_character_id < 0
      return $game_map.vehicles[@rided_character_id.abs - 1]
    else
      return $game_map.events[@rided_character_id]
    end
  end
  #--------------------------------------------------------------------------
  # ○ 他のキャラクターからおりる
  #-------------------------------------------------------------------------- 
  def ride_off_character(test = false)
    return false if riding_character == nil     # 騎乗してなければ降りれない
    return true if test                # テストならばここで true を返して終了

    riding_character.rided_character_id = nil
    @riding_character_id = nil
    return true
  end
  #--------------------------------------------------------------------------
  # ○ 騎乗キャラクターとの同期
  #--------------------------------------------------------------------------
  def sync_with_rided
    @x = rided_character.x
    @y = rided_character.y
    @real_x = rided_character.real_x
    @real_y = rided_character.real_y
    @direction = @direction_fix ? @direction : rided_character.direction
    update_bush_depth
    @stop_count = rided_character.stop_count
  end
  #--------------------------------------------------------------------------
  # ○ 段差マップ用・拡張通過判定(ダミーメソッド)
  #--------------------------------------------------------------------------
  def ex_passable(direction, test = false)
    return true
  end
end

#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　イベントを扱うクラスです。条件判定によるイベントページ切り替えや、並列処理
# イベント実行などの機能を持っており、Game_Map クラスの内部で使用されます。
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :passable_type
  attr_accessor :priority_type
  #--------------------------------------------------------------------------
  # ◎ オブジェクト初期化
  #     map_id : マップ ID
  #     event  : イベント (RPG::Event)
  #--------------------------------------------------------------------------
  alias tig_ev_event_initialize initialize
  def initialize(map_id, event)
    tig_ev_event_initialize(map_id, event)
    set_passable_setting
  end
  #--------------------------------------------------------------------------
  # ○ イベントの通行判定設定
  #--------------------------------------------------------------------------  
  def set_passable_setting
    @passable_type = -1
    @event.name = @event.name.sub(/[\<＜]小型船[\>＞]/, "") 
    @passable_type = 0 if $& != nil
    @event.name = @event.name.sub(/[\<＜]大型船[\>＞]/, "") 
    @passable_type = 1 if $& != nil
    @event.name = @event.name.sub(/[\<＜]馬[\>＞]/, "") 
    @passable_type = 2 if $& != nil
    @event.name = @event.name.sub(/[\<＜]フロート[\>＞]/, "") 
    @passable_type = 3 if $& != nil
  end
  #--------------------------------------------------------------------------
  # ○ 名前の取得
  #--------------------------------------------------------------------------
  def name
    return @event.name
  end
  #--------------------------------------------------------------------------
  # ◎ フレーム更新
  #--------------------------------------------------------------------------
  alias tig_ev_update update
  def update
    if riding_character != nil
      riding_character.sync_with_rided
    end
    tig_ev_update
  end
  #--------------------------------------------------------------------------
  # ◎ 自律移動の更新
  #--------------------------------------------------------------------------
  alias tig_ev_update_self_movement update_self_movement unless $@
  def update_self_movement
    return if rided_character != nil
    tig_ev_update_self_movement
  end
  #--------------------------------------------------------------------------
  # ○ プレイヤーとの同期
  #--------------------------------------------------------------------------
  def sync_with_player
    @x = $game_player.x
    @y = $game_player.y
    @real_x = $game_player.real_x
    @real_y = $game_player.real_y
    @direction = @direction_fix ? @direction : $game_player.direction
    update_bush_depth
    @stop_count = $game_player.stop_count
    @on_tile = $game_player.on_tile
    @turn_back = $game_player.turn_back
  end
  #--------------------------------------------------------------------------
  # ● マップ通行可能判定
  #     x : X 座標
  #     y : Y 座標
  #--------------------------------------------------------------------------
  def map_passable?(x, y)
    case @passable_type
    when 0  # 小型船
      return $game_map.boat_passable?(x, y)
    when 1  # 大型船
      return $game_map.ship_passable?(x, y)
    when 2  # 馬
      return $game_map.horse_passable?(x, y)
    when 3  # フロート
      return $game_map.float_passable?(x, y)
    else    # 徒歩
      return $game_map.passable?(x, y)
    end
  end
  #--------------------------------------------------------------------------
  # ● イベント起動
  #--------------------------------------------------------------------------
  #  lock(イベント起動時に主人公の方を向く動作)をする条件を
  #  イベント内にイベントコマンド・文章を表示が含まれている場合のみに
  #  限定する改変をしています。
  #  これにより、イベントへの乗り込み動作をスムーズに見せます。
  #--------------------------------------------------------------------------
  def start
    return if @list.size <= 1                   # 実行内容が空？
    @starting = true
    
    result = false                              ### 追加部分(ここから) ###
    for i in 0...@list.size
      result = true if @list[i].code == 101
    end                                         ### 追加部分(ここまで) ###
    
    lock if @trigger < 3 and result             #### 改変部分(この行) ####
    
    unless $game_map.interpreter.running?
      $game_map.interpreter.setup_starting_event
    end
  end
end

#==============================================================================
# ■ Game_Player
#------------------------------------------------------------------------------
# 　プレイヤーを扱うクラスです。イベントの起動判定や、マップのスクロールなどの
# 機能を持っています。このクラスのインスタンスは $game_player で参照されます。
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :new_x
  attr_reader   :new_y
  attr_accessor :walking_bgm
  attr_accessor :vehicle_event_data
  attr_accessor :not_encounter_vehicle_id
  attr_accessor :event_vehicle_lock
  attr_accessor :follow_member_gathering  #【パーティーメンバーの追従】併用時用
  attr_accessor :vehicle_hide
  #--------------------------------------------------------------------------
  # ◎ オブジェクト初期化
  #--------------------------------------------------------------------------
  alias tig_ev_pl_initialize initialize
  def initialize
    tig_ev_pl_initialize

    @not_encounter_vehicle_id = Expansion_Vehicle::NOT_ENCOUNTER_VEHICIE_ID   
                                                  # 非遭遇乗り物IDの初期値設定
    @event_vehicle_lock = false
  end
  #--------------------------------------------------------------------------
  # ○ 今乗っている乗り物
  #--------------------------------------------------------------------------
  def now_vehicle
    if in_event_vehicle?
      return $game_map.events[@vehicle_event_data[3]] unless event_vehicle_object?
    end
    return nil if @vehicle_type == -1
    return $game_map.vehicles[@vehicle_type]
  end
  #--------------------------------------------------------------------------
  # ○ 今乗っている乗り物が騎乗タイプか？
  #--------------------------------------------------------------------------
  def now_vehicle_riding_type?
    return false if now_vehicle == nil
    return now_vehicle.riding_type?
  end
  #--------------------------------------------------------------------------
  # ○ イベント乗り物の取得
  #-------------------------------------------------------------------------- 
  def event_vehicle
    return nil unless in_event_vehicle?
    return $game_map.events[@vehicle_event_data[3]]
  end
  #--------------------------------------------------------------------------
  # ○ イベントに乗っているか判定
  #--------------------------------------------------------------------------
  def in_event_vehicle?
    return @vehicle_event_data != nil
  end
  #--------------------------------------------------------------------------
  # ○  イベント乗り物がオブジェクトタイプか？
  #-------------------------------------------------------------------------- 
  def event_vehicle_object?
    return false unless event_vehicle
    key = [event_vehicle.character_name, event_vehicle.character_index]
    return $riding_data.data_object_type[key]
  end
  #--------------------------------------------------------------------------
  # ○ 今乗っている乗り物と別の乗り物がそこにあるか？
  #--------------------------------------------------------------------------
  def other_vehicle?(x = @x, y = @y)
    return false if @vehicle_type == -1
    for vehicle in $game_map.vehicles
      if vehicle.pos?(x, y)
        return true if vehicle != now_vehicle
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ◎ 飛行船(もしくは大型飛行船)に乗っている状態判定
  #--------------------------------------------------------------------------
  alias tig_ev_airship? in_airship?
  def in_airship?
    return true if @vehicle_type == 4
    return tig_ev_airship?
  end
  #--------------------------------------------------------------------------
  # ◎ 移動可能判定
  #--------------------------------------------------------------------------
  alias tig_ev_pl_movable? movable?
  def movable?
    if [4, 5].include?(@vehicle_type)
      return false if moving?                     # 移動中
      return false if @move_route_forcing         # 移動ルート強制中
      return false if @vehicle_getting_on         # 乗る動作の途中
      return false if @vehicle_getting_off        # 降りる動作の途中
      return false if $game_message.visible       # メッセージ表示中
      return false unless $game_map.big_airship.movable? or
                          $game_map.magic_carpet.movable?
      return true
    else
      return tig_ev_pl_movable?
    end
  end
  #--------------------------------------------------------------------------
  # ◎ マップ通行可能判定
  #     x : X 座標
  #     y : Y 座標
  #--------------------------------------------------------------------------
  alias tig_ev_map_passable? map_passable?
  def map_passable?(x, y)
    if in_event_vehicle?
      return $game_map.event_vehicle.map_passable?(x, y)
    end
    case @vehicle_type
    when 3  
      return $game_map.horse_passable?(x, y)
    when 4
      return $game_map.big_airship_passable?(x, y)
    when 5
      return $game_map.magic_carpet_passable?(x, y)
    else    
      return tig_ev_map_passable?(x, y)
    end
  end
  #--------------------------------------------------------------------------
  # ◎ フレーム更新
  #--------------------------------------------------------------------------
  alias tig_ev_update update
  def update
    tig_ev_update
    update_event_vehicle
  end
  #--------------------------------------------------------------------------
  # ◎ 乗り物の乗降
  #--------------------------------------------------------------------------
  alias tig_ev_get_on_off_vehicle get_on_off_vehicle
  def get_on_off_vehicle
    return false unless movable?
    if in_event_vehicle?
      unless @event_vehicle_lock
        result = get_off_event_vehicle
        if result
          unless event_vehicle_object?
            @vehicle_getting_off_wait = true #【パーティーメンバーの追従】併用時用
            @vehicle_hide = false            #【パーティーメンバーの追従】併用時用
          end
          return result
        end
      else
        return false
      end
    else
      return tig_ev_get_on_off_vehicle
    end
  end
  #--------------------------------------------------------------------------
  # ● 乗り物の処理
  #--------------------------------------------------------------------------
  def update_vehicle
    return unless in_vehicle?
    vehicle = $game_map.vehicles[@vehicle_type]
    if @vehicle_getting_on                    # 乗る途中？
      vehicle.moveto(@x, @y)         # 乗っている間に自律移動してしまうのを防ぐ
      if not moving? and not @follow_member_gathering
        if vehicle.riding_type?
          unless [2, 4].include?(@vehicle_type)
            vehicle.priority_type = 1
          end
          ride_on(vehicle)
        else
          @transparent = true                 # 透明化
        end
        @direction = vehicle.direction        # 向きを変更
        @move_speed = vehicle.speed           # 移動速度を変更
        @vehicle_getting_on = false           # 乗る動作終了
      end
    elsif @vehicle_getting_off                # 降りる途中？
      if not moving? and vehicle.altitude == 0
        @vehicle_getting_off = false          # 降りる動作終了
        if vehicle.riding_type?
          vehicle.priority_type = vehicle.vehicle_priority
        else
          @transparent = false                  # 透明を解除          
        end
        if vehicle.instant
          vehicle.instant = false
          vehicle.set_location(0, 0, 0)
        end
        @vehicle_type = -1                    # 乗り物タイプ消去
        update_bush_depth
      end
    else                                      # 乗り物に乗っている
      vehicle.sync_with_player                # プレイヤーと同時に動かす
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 乗り物に乗る
  #    現在乗り物に乗っていないことが前提。
  #--------------------------------------------------------------------------
  alias tig_ev_get_on_vehicle get_on_vehicle
  def get_on_vehicle
    if $game_map.horse.pos?(@x, @y)                 # 馬と重なっている？
      get_on_horse
      return true
    elsif $game_map.big_airship.pos?(@x, @y)        # 大型飛行船と重なっている？
      get_on_big_airship
      return true
    elsif $game_map.magic_carpet.pos?(@x, @y)       # 魔法の絨毯と重なっている？
      get_on_magic_carpet
      return true
    end
    return tig_ev_get_on_vehicle
  end
  #--------------------------------------------------------------------------
  # ◎ 乗り物から降りる
  #    現在乗り物に乗っていることが前提。
  #--------------------------------------------------------------------------
  alias tig_ev_get_off_vehicle get_off_vehicle
  def get_off_vehicle
    return false if other_vehicle?
    return false if $game_map.hide_tile?(x, y)
    if @vehicle_type < 2
      return false unless tig_ev_get_off_vehicle
    elsif @vehicle_type == 2
      return false unless tig_ev_get_off_vehicle
      @direction = 4
    else
      if @vehicle_type == 3
        return false unless $game_map.events_xy(@x, @y).empty?
        @direction = 2
      elsif @vehicle_type == 4 or @vehicle_type == 5
        return false unless airship_land_ok?(@x, @y)
        @direction = 4
      end
      now_vehicle.get_off                           # 降りる処理
      @vehicle_getting_off = true                   # 降りる動作の開始
      @move_speed = 4                               # 移動速度を戻す
      @through = false                              # すり抜け OFF
      @walking_bgm.play                             # 歩行時の BGM 復帰
      make_encounter_count                          # エンカウント初期化
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ○ 馬に乗る
  #--------------------------------------------------------------------------
  def get_on_horse
    @vehicle_getting_on = true        # 乗り込み中フラグ
    @vehicle_type = 3                 # 乗り物タイプ設定
    @walking_bgm = RPG::BGM::last     # 歩行時の BGM 記憶
    $game_map.horse.get_on            # 乗り込み処理
  end
  #--------------------------------------------------------------------------
  # ○ 大型飛行船に乗る
  #--------------------------------------------------------------------------
  def get_on_big_airship
    @vehicle_getting_on = true        # 乗る動作の開始
    @vehicle_type = 4                 # 乗り物タイプ設定
    @through = true                   # すり抜け ON
    @walking_bgm = RPG::BGM::last     # 歩行時の BGM 記憶
    $game_map.big_airship.get_on      # 乗り込み処理
  end
  #--------------------------------------------------------------------------
  # ○ 魔法の絨毯に乗る
  #--------------------------------------------------------------------------
  def get_on_magic_carpet
    @vehicle_getting_on = true        # 乗る動作の開始
    @vehicle_type = 5                 # 乗り物タイプ設定
    @walking_bgm = RPG::BGM::last     # 歩行時の BGM 記憶
    $game_map.magic_carpet.get_on     # 乗り込み処理
  end
  #--------------------------------------------------------------------------
  # ○ イベントに乗る
  #--------------------------------------------------------------------------
  def get_on_event(event_id, test = false)
    vehicle = $game_map.events[event_id]
    return false if in_vehicle?
    return false if in_event_vehicle?
    return false if riding_character != nil
    return false if vehicle.rided_character != nil
    return false if vehicle.moving?
    return true if test

    @vehicle_getting_on = true                  # 乗り込み中フラグ
    
    @vehicle_event_data = []                    # イベント乗り物データ登録
    @vehicle_event_data[0] = vehicle.name
    @vehicle_event_data[1] = vehicle.character_name
    @vehicle_event_data[2] = vehicle.character_index
    @vehicle_event_data[3] = vehicle.id
    key = [vehicle.character_name, vehicle.character_index]
    if $riding_data.data_priority_type[key] == 0
      @vehicle_event_data[4] = vehicle.priority_type
      vehicle.priority_type = 0
    end
    vehicle.stop_count = -20
    front_x = $game_map.x_with_direction(@x, @direction)
    front_y = $game_map.y_with_direction(@y, @direction)
    if vehicle.x == front_x and vehicle.y == front_y
      unless $riding_data.data_object_type[key]
        if @follow_member_gathering != nil
          @follow_member_gathering = true  # 【パーティーメンバーの追従】併用時用
        end
        force_move_forward                         # 一歩前進
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ○ イベント乗り物の処理
  #--------------------------------------------------------------------------
  def update_event_vehicle
    return unless in_event_vehicle?
    vehicle = $game_map.events[@vehicle_event_data[3]]
    key = [vehicle.character_name, vehicle.character_index]
    if @vehicle_getting_on                    # 乗る途中？
      if not moving? and not @follow_member_gathering
        if @vehicle_event_data[4] != nil
          vehicle.priority_type = 1
        end
        if vehicle.riding_type?
          if $riding_data.data_object_type[key]
            vehicle.set_direction(@direction)
          end
          ride_on(vehicle)
        else
          @transparent = true                 # 透明化
        end
        @vehicle_getting_on = false           # 乗る動作終了
        @through = false
      end
    elsif @vehicle_getting_off                # 降りる途中？
      if not moving?
        if @vehicle_event_data[4] != nil
          vehicle.priority_type = @vehicle_event_data[4]
        end
        @vehicle_getting_off = false          # 降りる動作終了
        key = [$game_map.map_id, @vehicle_event_data[3], "D"]
        $game_self_switches[key] = true
        $game_map.need_refresh = true
        $game_player.vehicle_event_data = nil
        update_bush_depth
      end
    else
      vehicle.sync_with_player                # イベント位置を同期
    end
  end
  #--------------------------------------------------------------------------
  # ○ イベントから降りる処理
  #--------------------------------------------------------------------------
  def get_off_event_vehicle
    
    vehicle = $game_map.event_vehicle
    front_x = $game_map.x_with_direction(@x, @direction)
    front_y = $game_map.y_with_direction(@y, @direction)
    key = [vehicle.character_name, vehicle.character_index]
    if [0, 1, 3].include?(vehicle.passable_type)
      return false unless tig_ev_map_passable?(front_x, front_y)   # 接岸できない
      if $riding_data.data_priority_type[key] == 0
        @vehicle_event_data[4] = vehicle.priority_type
        vehicle.priority_type = 0
      end
      force_move_forward
    elsif $riding_data.data_object_type[key] and
          vehicle.priority_type == 1
      @vehicle_getting_off_wait = false   #【パーティーメンバーの追従】併用時用
      return false if collide_with_characters?(front_x, front_y)
      return false unless $game_map.object_passable?(front_x, front_y)
      return false unless vehicle.ex_passable(@direction)
      case @direction
      when 2;  vehicle.move_down(false)
      when 4;  vehicle.move_left(false)
      when 6;  vehicle.move_right(false)
      when 8;  vehicle.move_up(false)
      end
      vehicle.moveto(front_x, front_y)
    end
    if vehicle.riding_type?
      ride_off_character
      #$game_switches[203] = true
    else
      @transparent = false                       # 透明を解除 
      #$game_switches[203] = true
    end
    vehicle.stop_count = 0
    @vehicle_getting_off = true
    #$game_switches[203] = true
    return true
  end
  #--------------------------------------------------------------------------
  # ○ イベントからの強制離脱
  #--------------------------------------------------------------------------
  def compulsory_off_event_vehicle(erase = false)
    vehicle = $game_map.event_vehicle
    if vehicle and vehicle.riding_type?
      ride_off_character
    else
      @transparent = false                       # 透明を解除     
    end
    @vehicle_getting_off_wait = true      #【パーティーメンバーの追従】併用時用
    @vehicle_hide = false                 #【パーティーメンバーの追従】併用時用
    $game_player.vehicle_event_data = nil
    update_bush_depth
    vehicle.erase if erase
  end
  #--------------------------------------------------------------------------
  # ● エンカウントの更新
  #--------------------------------------------------------------------------
  def update_encounter
    return if $TEST and Input.press?(Input::CTRL)   # テストプレイ中？
    return if @not_encounter_vehicle_id.include?(@vehicle_type)    ## 変更点
    if $game_player.in_airship?              # 飛行中なら          ## 追加点
      @encounter_count -= 1                  # カウントを 1 減らす ## 追加点
    elsif $game_map.bush?(@x, @y)            # 茂みなら            ## 変更点
      @encounter_count -= 2                  # カウントを 2 減らす
    else                                     # 茂み以外なら
      @encounter_count -= 1                  # カウントを 1 減らす
    end
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
  # ◎ フレーム更新
  #--------------------------------------------------------------------------
  alias tig_ev_update update
  def update
    tig_ev_update
    riding_positioning
  end
  #--------------------------------------------------------------------------
  # ○ 騎乗用画像のファイルの名前取得
  #--------------------------------------------------------------------------
  def riding_pct_name
    key = [@character.character_name, @character.character_index]
    return $riding_data.data_riding_pct_name[key]
  end
  #--------------------------------------------------------------------------
  # ○ 騎乗用画像のファイルのインデックス取得
  #--------------------------------------------------------------------------
  def riding_pct_index
    key = [@character.character_name, @character.character_index]
    return $riding_data.data_riding_pct_index[key]
  end
  #--------------------------------------------------------------------------
  # ○ 騎乗しているキャラクターの取得
  #--------------------------------------------------------------------------
  def riding_character
    return @character.riding_character
  end
  #--------------------------------------------------------------------------
  # ○ 騎乗しているキャラクターの取得
  #--------------------------------------------------------------------------
  def rided_character
    return @character.rided_character
  end
  #--------------------------------------------------------------------------
  # ○ 騎乗時のX座標修正値の取得
  #--------------------------------------------------------------------------
  def riding_positioning_x(key_character, base_character)
    key = [key_character.character_name, key_character.character_index]
    return 0 unless $riding_data.data_positioning_down.key?(key)
    pattern = base_character.pattern
    pattern = 1 if pattern == 3
    case base_character.direction
    when 2
      return $riding_data.data_positioning_down[key][pattern][0]
    when 4
      return $riding_data.data_positioning_left[key][pattern][0]
    when 6
      return $riding_data.data_positioning_right[key][pattern][0]
    when 8
      return $riding_data.data_positioning_up[key][pattern][0]
    end
  end
  #--------------------------------------------------------------------------
  # ○ 騎乗時のY座標修正値の取得
  #--------------------------------------------------------------------------
  def riding_positioning_y(key_character, base_character)
    key = [key_character.character_name, key_character.character_index]
    return 0 unless $riding_data.data_positioning_down.key?(key)
    pattern = base_character.pattern
    pattern = 1 if pattern == 3
    case base_character.direction
    when 2
      return $riding_data.data_positioning_down[key][pattern][1]
    when 4
      return $riding_data.data_positioning_left[key][pattern][1]
    when 6
      return $riding_data.data_positioning_right[key][pattern][1]
    when 8
      return $riding_data.data_positioning_up[key][pattern][1]
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 騎乗時の位置補正
  #--------------------------------------------------------------------------
  def riding_positioning
    if riding_character != nil
      key = [riding_character.character_name, riding_character.character_index]
      unless $riding_data.data_object_type[key]
        self.x += riding_positioning_x(riding_character, riding_character)
        self.y = riding_character.screen_y
        self.y += riding_positioning_y(riding_character, riding_character)
      end
    end
    if rided_character != nil
      key = [@character.character_name, @character.character_index]
      if $riding_data.data_object_type[key]
        self.x += riding_positioning_x(@character, rided_character)
        self.y += riding_positioning_y(@character, rided_character)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 転送元ビットマップの更新
  #--------------------------------------------------------------------------
  alias tig_ev_update_bitmap update_bitmap
  def update_bitmap
    tig_ev_update_bitmap
    if @character.rided_character != nil  
      return if @back_seeing == true
      return if riding_pct_name == nil
      if @ride_sprite == nil or
         @riding_pct_name != riding_pct_name or
         @riding_pct_index != riding_pct_index
        
        @riding_pct_name = riding_pct_name
        @riding_pct_index = riding_pct_index
        @ride_sprite = ::Sprite.new(viewport)
        file_name = @riding_pct_name == "self" ? @character.character_name : @riding_pct_name
        @ride_sprite.bitmap = Cache.character(file_name)
        sign = file_name[/^[\!\$]./]
        if sign != nil and sign.include?('$')
          @rcw = @ride_sprite.bitmap.width / 3
          @rch = @ride_sprite.bitmap.height / 4
        else
          @rcw = @ride_sprite.bitmap.width / 12
          @rch = @ride_sprite.bitmap.height / 8
        end
        @ride_sprite.ox = @rcw / 2
        @ride_sprite.oy = @rch
      end
    else
      dispose_ride_sprite
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 転送元矩形の更新
  #--------------------------------------------------------------------------
  alias tig_ev_update_src_rect update_src_rect
  def update_src_rect
    tig_ev_update_src_rect
    dispose_ride_sprite if @back_seeing == true
    return if @ride_sprite == nil
    
    index = @riding_pct_name == "self" ? @character.character_index : @riding_pct_index
    pattern = @character.pattern < 3 ? @character.pattern : 1
    sx = (index % 4 * 3 + pattern) * @rcw
    sy = (index / 4 * 4 + (@character.direction - 2) / 2) * @rch
    @ride_sprite.src_rect.set(sx, sy, @rcw, @rch) 
    @ride_sprite.x = @character.screen_x
    @ride_sprite.y = @character.screen_y
    @ride_sprite.z = @character.screen_z + 2
    @ride_sprite.viewport = viewport

    if @riding_pct_name == "self" and rided_character.direction == 8
      @ride_sprite.x = -50
    end
    key = [@character.character_name, @character.character_index]
    if $riding_data.data_object_type[key]
      @ride_sprite.x += riding_positioning_x(@character, rided_character)
      @ride_sprite.y += riding_positioning_y(@character, rided_character)
    end
  end
  #--------------------------------------------------------------------------
  # ◎ 解放
  #--------------------------------------------------------------------------
  alias tig_ev_dispose dispose
  def dispose
    tig_ev_dispose
    dispose_ride_sprite
  end
  #--------------------------------------------------------------------------
  # ◎ 騎乗用スプライトの消去
  #--------------------------------------------------------------------------
  def dispose_ride_sprite
    if @ride_sprite != nil
      $game_system.menu_disabled = false
      #$game_switches[204] = false#ground
      $game_switches[203] = true#par###
      $game_switches[202] = true
      
      $game_switches[37] = true#圓盤###
      #$fog.delete(1)
      @ride_sprite.dispose
      @ride_sprite = nil
    end
  end
end

#==============================================================================
# ■ Spriteset_Map
#------------------------------------------------------------------------------
# 　マップ画面のスプライトやタイルマップなどをまとめたクラスです。このクラスは
# Scene_Map クラスの内部で使用されます。
#==============================================================================



#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。このクラスは Game_Map クラス、
# Game_Troop クラス、Game_Event クラスの内部で使用されます。
#==============================================================================

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ◎ 乗り物の乗降
  #--------------------------------------------------------------------------
  alias tig_ev_command_206 command_206
  def command_206
    @wait_count = 2       #【パーティーメンバーの追従】併用時にあったほうがよい
    return tig_ev_command_206
  end
  #--------------------------------------------------------------------------
  # ○ 小型船
  #--------------------------------------------------------------------------
  def boat
    return $game_map.boat
  end
  #--------------------------------------------------------------------------
  # ○ 大型船
  #--------------------------------------------------------------------------
  def ship
    return $game_map.ship
  end
  #--------------------------------------------------------------------------
  # ○ 飛行船
  #--------------------------------------------------------------------------
  def airship
    return $game_map.airship
  end
  #--------------------------------------------------------------------------
  # ○ 馬
  #--------------------------------------------------------------------------
  def horse
    return $game_map.horse
  end
  #--------------------------------------------------------------------------
  # ○ 大型飛行船
  #--------------------------------------------------------------------------
  def big_airship
    return $game_map.big_airship
  end
  #--------------------------------------------------------------------------
  # ○ 魔法の絨毯
  #--------------------------------------------------------------------------
  def magic_carpet
    return $game_map.magic_carpet
  end
  #--------------------------------------------------------------------------
  # ○ プレーヤーがイベントに乗る
  # ※ 乗り物にするイベントの「スクリプト」コマンドで実行する。
  #--------------------------------------------------------------------------
  def get_on_event(test = false)
    if @event_id > 0
      return false if $game_player.event_vehicle_lock
      return $game_player.get_on_event(@event_id, test)
    else  
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ○ プレーヤーがイベントに乗れるかのテスト
  #  ※ 乗り物にするイベントの「スクリプト」コマンドで実行する。
  #--------------------------------------------------------------------------
  def get_on_event_test
    return get_on_event(true)
  end
  #--------------------------------------------------------------------------
  # ○ プレイヤーがイベント乗り物に乗っているかの判定
  #    word : 指定語句
  #　※ 指定語句がなければ乗り物にのっているかどうかを判定
  #     あればその語句が名前に含まれている乗り物にのっているかを判定
  #--------------------------------------------------------------------------
  def player_in_event_vehicle(word = nil)
    return false unless $game_player.in_event_vehicle?
    return true if word == nil
    return $game_map.event_vehicle.name.include?(word)
  end
  #--------------------------------------------------------------------------
  # ○ プレーヤーのイベント乗り物をロックする
  #--------------------------------------------------------------------------  
  def event_vehicle_lock
    $game_player.event_vehicle_lock = true
  end
  #--------------------------------------------------------------------------
  # ○ プレーヤーのイベント乗り物をロックを解除する
  #--------------------------------------------------------------------------  
  def event_vehicle_lock_off
    $game_player.event_vehicle_lock = false
  end
  #--------------------------------------------------------------------------
  # ○ プレーヤーをイベントから強制的に降ろす
  #--------------------------------------------------------------------------  
  def event_vehicle_compulsory_off
    $game_player.compulsory_off_event_vehicle
  end
  #--------------------------------------------------------------------------
  # ○ プレーヤーのイベント乗り物を消去する
  #--------------------------------------------------------------------------  
  def event_vehicle_erase
    $game_player.compulsory_off_event_vehicle(true)
  end
  #--------------------------------------------------------------------------
  # ○ イベントをイベントに乗せる
  #     event_id : 乗り手になるイベントのID
  #   vehicle_id : 乗り物になるイベントのID
  #--------------------------------------------------------------------------
  def event_vehicle(event_id, vehicle_id, test = false)
    if $game_map.events[event_id] != nil and $game_map.events[vehicle_id] != nil
      return $game_map.events[event_id].ride_on($game_map.events[vehicle_id], test)
    else  
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ○ イベントをイベントに乗せることが出来るかのテスト
  #--------------------------------------------------------------------------
  def event_vehicle_test(event_id, vehicle_id)
    return event_vehicle_test(event_id, vehicle_id, true)
  end
  #--------------------------------------------------------------------------
  # ○ イベントから降ろす
  #     event_id : イベントから降ろすイベントのID
  #--------------------------------------------------------------------------
  def get_off_event(event_id, test = false)
    if $game_map.events[event_id] != nil
      return $game_map.events[event_id].ride_off_character(test)
    else  
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ○ イベントから降ろすことが出来るかのテスト
  #--------------------------------------------------------------------------
  def get_off_event_test(event_id)
    return get_off_event_test(event_id, true)
  end
  #--------------------------------------------------------------------------
  # ○ イベントをID指定してセルフスイッチを操作する
  #--------------------------------------------------------------------------
  def self_switches(event_id, switches_id, on_off)
    return if $game_map.events == nil
    return if $game_map.events[event_id] == nil
    key = [$game_map.map_id, event_id, switches_id]
    $game_self_switches[key] = on_off
    $game_map.need_refresh = true
    $game_map.need_refresh = true
  end
  #--------------------------------------------------------------------------
  # ○ ID指定したイベントのセルフスイッチをオン
  #--------------------------------------------------------------------------
  def self_switches_on(event_id, switches_id)
    self_switches(event_id, switches_id, true)
  end
  #--------------------------------------------------------------------------
  # ○ ID指定したイベントのセルフスイッチをオフ
  #--------------------------------------------------------------------------
  def self_switches_off(event_id, switches_id)
    self_switches(event_id, switches_id, false)
  end
  #--------------------------------------------------------------------------
  # ○ ID指定したイベントのセルフスイッチをクリア(すべてオフ)
  #--------------------------------------------------------------------------
  def self_switches_clear(event_id)
    self_switches(event_id, "A", false)
    self_switches(event_id, "B", false)
    self_switches(event_id, "C", false)
    self_switches(event_id, "D", false)
  end
  #--------------------------------------------------------------------------
  # ○ ID指定したイベントがオンか？
  #--------------------------------------------------------------------------
  def self_switches_on?(event_id, switches_id)
    key = [$game_map.map_id, event_id, switches_id]
    return $game_self_switches[key] == true
  end
  #--------------------------------------------------------------------------
  # ○ ID指定したイベントがオフか？
  #--------------------------------------------------------------------------
  def self_switches_off?(event_id, switches_id)
    key = [$game_map.map_id, event_id, switches_id]
    return $game_self_switches[key] == false
  end
  #--------------------------------------------------------------------------
  # ○ イベントと同位置のイベントのセルフスイッチをオン
  #--------------------------------------------------------------------------
  def self_switches_on_here(switches_id)
    self_switches_here(switches_id, true)
  end
  #--------------------------------------------------------------------------
  # ○ イベントと同位置のイベントのセルフスイッチをオフ
  #--------------------------------------------------------------------------
  def self_switches_off_here(switches_id)
    self_switches_here(switches_id, false)
  end
  #--------------------------------------------------------------------------
  # ○ イベントと同位置のイベントのセルフスイッチを操作する
  #--------------------------------------------------------------------------
  def self_switches_here(switches_id, on_off)
    return if $game_map.events == nil
    result = false
    main_event = $game_map.events[@event_id]
    for event in $game_map.events_xy(main_event.x, main_event.y)
      next if event == main_event
      key = [$game_map.map_id, event.id, switches_id]
      $game_self_switches[key] = on_off
      $game_map.need_refresh = true
      result = true
    end
    $game_map.need_refresh = true if result
  end
end