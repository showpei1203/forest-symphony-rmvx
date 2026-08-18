#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：光擴散效果[MENU用]
# 【用途】UI／選單元件「光擴散效果[MENU用]」。
# 【主要機制】擴充 Window／Scene／Sprite 顯示或操作；最終外觀可能由後載入 FS UI Patch 接管。
# 【主要影響】Game_Temp、Game_System、Game_Interpreter、Sprite_Reffect_Diffusion、Sprite_Reffect_Spiral、Spriteset_Map、Reffect
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
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
=begin
      ★ 光拡散エフェクト ★

      光が広がったり、集まったり、降ったりします。
      天候と似た使い方を想定しています。
      
      イベントコマンドのスクリプトから起動させてください。
      
      ● コマンド一覧 ●==================================================
      start_effect(type)
      --------------------------------------------------------------------
      光拡散エフェクトを開始します。
      引数の値によってエフェクトの種類が決定します
        1  => 中心から発散
        2  => 中心へ収束
        3  => 中央上部から下へ
        4  => 上部全体から下へ
        5  => 右上から左下へ
        
        21 => 不規則な螺旋を描いて上昇
        22 => ゆらゆらと上昇
        23 => 規則正しい螺旋を描いて上昇
      ====================================================================
      end_effect
      --------------------------------------------------------------------
      エフェクトの終了。画面上のエフェクトをすべて一気に開放します。
      ====================================================================
      end_effect_fade
      --------------------------------------------------------------------
      エフェクトの終了。画面上のエフェクトを少しづつ開放します。
      ====================================================================
      
      ver1.10

      Last Update : 2011/08/20
      08/20 : エフェクト追加
            : 処理構造の大幅な変更
      03/20 : 新規
      
      ろかん　　　http://kaisouryouiki.web.fc2.com/
=end

$rsi = {} if $rsi == nil
$rsi["光拡散エフェクト"] = true

module Reffect
  DS = [544, 416]
  @@span = false
  def initialize(viewport)
    @sp = [0, 0]     # 初期座標
    @ma = [0.0, 0.0] # 移動角度(ラジアン)
    @rd = 0.0        # 初期座標からの半径
    super(viewport)
    self.blend_type = 1
    @@span ^= true
  end
  def setGraphic(filename)
    self.bitmap = Cache.system(filename)
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height / 2
  end
  def setStartPosition(typeX, typeY)
    case typeX
    when 0 # ランダム
      @sp[0] = rand(DS[0] + 100) - 50
    when 1 # 画面外(左)
      @sp[0] = -30
    when 2 # 中央
      @sp[0] = DS[0] / 2
    when 3 # 画面外(右)
      @sp[0] = DS[0] + 30
    end
    case typeY
    when 0 # ランダム
      @sp[1] = rand(DS[1] + 50) - 25
    when 1 # 画面外(上)
      @sp[1] = -30
    when 2 # 中央
      @sp[1] = DS[1] / 2
    when 3 # 画面外(下)
      @sp[1] = DS[1] + 30
    end
    self.x = @sp[0]
    self.y = @sp[1]
  end
  def setMoveAngle(ax, ay = ax)
    @ma[0] = Math.cos(ax * 0.01)
    @ma[1] = Math.sin(ay * 0.01)
  end
  def getX
    @sp[0] + @rd * @ma[0]
  end
  def getY
    @sp[1] + @rd * @ma[1]
  end
  def getZoom
    (@rd * @ma[1] / DS[0] / 1.5 + 0.8) * (self.opacity / 255.0)
  end
end

class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :r_effect_sprites # 特殊効果スプライト群
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias r_effect_initialize initialize
  def initialize
    r_effect_initialize
    @r_effect_sprites = []
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果スプライトの解放
  #--------------------------------------------------------------------------
  def dispose_r_effect
    @r_effect_sprites.each{|sprite| sprite.dispose }
    @r_effect_sprites = []
  end
end

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :r_effect_type # 特殊効果の種類
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias r_effect_initialize initialize
  def initialize
    r_effect_initialize
    @r_effect_type = 0
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果の開始
  #--------------------------------------------------------------------------
  def start_effect(type)
    $game_temp.dispose_r_effect if @r_effect_type != type
    @r_effect_type = type
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果の終了（瞬時）
  #--------------------------------------------------------------------------
  def end_effect
    $game_temp.dispose_r_effect
    @r_effect_type = 0
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果の終了（フェード）
  #--------------------------------------------------------------------------
  def end_effect_fade
    @r_effect_type = 0
  end
end

class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● 特殊効果の開始
  #--------------------------------------------------------------------------
  def start_effect(type)
    $game_system.start_effect(type)
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果の終了（瞬時）
  #--------------------------------------------------------------------------
  def end_effect
    $game_system.end_effect
  end
  #--------------------------------------------------------------------------
  # ● 特殊効果の終了（フェード）
  #--------------------------------------------------------------------------
  def end_effect_fade
    $game_system.end_effect_fade
  end
end

class Sprite_Reffect_Diffusion < Sprite
  #--------------------------------------------------------------------------
  # ● インクルード Reffect
  #--------------------------------------------------------------------------
  include Reffect
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    case $game_system.r_effect_type
    when 1
      @rd = rand(DS[0] / 3).to_f
      @moveSpeed = rand(50).next * 0.01 + 0.5
      @existCount = rand(100) + 80
      setStartPosition(2, 2)
      setMoveAngle(rand(2 * Math::PI * 100))
      setGraphic("RE_001")
    when 2
      @rd = rand(DS[0] / 3).to_f + 30.0
      @moveSpeed = rand(50).next * -0.01 - 0.5
      @existCount = rand(100) + 90
      setStartPosition(2, 2)
      setMoveAngle(rand(2 * Math::PI * 100))
      setGraphic("RE_001")
    when 3
      @rd = rand(DS[0] / 2).to_f
      @moveSpeed = rand(50).next * 0.01 + 0.5
      @existCount = rand(100) + 80
      setStartPosition(2, 1)
      setMoveAngle(rand(2 * Math::PI * 100), rand(Math::PI * 100))
      setGraphic("RE_001")
    when 4
      @rd = rand(DS[0] / 2).to_f
      @moveSpeed = rand(50).next * 0.01 + 0.5
      @existCount = rand(100) + 80
      setStartPosition(0, 1)
      setMoveAngle(rand(2 * Math::PI * 100), rand(Math::PI * 100))
      setGraphic("RE_001")
    when 5
      @rd = rand(DS[0] / 2).to_f
      @moveSpeed = rand(50).next * 0.01 + 0.5
      @existCount = rand(100) + 120
      setStartPosition(3, 1)
      setMoveAngle(rand(Math::PI * 100) + 90, rand(Math::PI * 100))
      setGraphic("RE_001")
    end
    @maxOpacity = rand(160) + 40
    self.opacity = 1
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    if self.opacity.zero?
      dispose
      $game_temp.r_effect_sprites.delete(self)
    else
      @existCount -= 1
      @rd = [@rd + @moveSpeed, 0.0].max
      self.x = getX
      self.y = getY
      self.zoom_x = self.zoom_y = getZoom
      self.opacity = [self.opacity + (@existCount > 0 ? 2 : -2), @maxOpacity].min
    end
  end
end

class Sprite_Reffect_Spiral < Sprite
  #--------------------------------------------------------------------------
  # ● インクルード Reffect
  #--------------------------------------------------------------------------
  include Reffect
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    case $game_system.r_effect_type
    when 21
      @rd = rand(200).next.to_f
      @moveSpeed = 5.0 - @rd / 50.0
      @nextAngle = rand(360).to_f
      @collapseSpeed = 1
      setStartPosition(2, 3)
      setGraphic("RE_002")
    when 22
      @rd = rand(40).next.to_f
      @moveSpeed = rand(100).next * 0.01 + 1.0
      @nextAngle = rand(360).to_f
      @collapseSpeed = rand(3).zero? ? 2 : 1
      setStartPosition(0, 3)
      setGraphic("RE_002")
    when 23
      @rd = 180
      @moveSpeed = 1.7
      @nextAngle = @@span ? 0.0 : 180.0
      @collapseSpeed = 0
      setStartPosition(2, 3)
      setGraphic("RE_002")
    end
    @floteY = self.y.to_f
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    if self.y <= -self.oy || self.opacity.zero?
      dispose
      $game_temp.r_effect_sprites.delete(self)
    else
      @nextAngle += [@moveSpeed, 2].min
      @nextAngle = 0.0 if @nextAngle >= 360
      setMoveAngle(@nextAngle * 1.74533)
      self.x = getX
      self.y = (@floteY -= @moveSpeed).round
      self.zoom_x = self.zoom_y = getZoom
      self.opacity -= @collapseSpeed
    end
  end
end

class Spriteset_Map
  @@re_add_count = 0
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias r_effect_dispose dispose
  def dispose
    r_effect_dispose
    $game_temp.dispose_r_effect
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias r_effect_update update
  def update
    r_effect_update
    unless $game_system.r_effect_type.zero?
      if @@re_add_count.zero?
        case $game_system.r_effect_type
        when  1..10
          sprite = Sprite_Reffect_Diffusion.new(@viewport3)
        when 21..30
          sprite = Sprite_Reffect_Spiral.new(@viewport3)
        end
        $game_temp.r_effect_sprites << sprite
        @@re_add_count = 10
      end
      @@re_add_count -= 1
    end
    $game_temp.r_effect_sprites.each{|sprite| sprite.update }
  end
end