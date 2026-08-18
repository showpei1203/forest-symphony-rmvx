#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：敵人姓名
# 【用途】保留的 Runtime 元件「敵人姓名」。
# 【主要機制】主要定義／擴充 Sprite_BattleEnemyNames、Spriteset_Battle、Scene_Battle、KGC；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Sprite_BattleEnemyNames、Spriteset_Battle、Scene_Battle、KGC、TalesStyleEffect
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ENEMY_NAME_BACK。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意；登記 $imported：TalesStyleEffect。
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
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/
#_/    ◆ テイルズ式演出 - KGC_TalesStyleEffect ◆ VX ◆
#_/    ◇ Last update : 2009/08/18 ◇
#_/----------------------------------------------------------------------------
#_/  テイルズ式のエンカウント演出を行います。
#_/============================================================================
#_/ 【スキル】≪遅延スキル≫ より上に導入してください。
#_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/_/

#==============================================================================
# ★ カスタマイズ項目 - Customize BEGIN ★
#==============================================================================

module KGC
module TalesStyleEffect
  # ◆ 演出用画像
  #  "Graphics/System" から読み込む。
  ENEMY_NAME_BACK = "BattleEnemyName"  # 戦闘開始時の敵名
end
end

#==============================================================================
# ☆ カスタマイズ項目終了 - Customize END ☆
#==============================================================================

$imported = {} if $imported == nil
$imported["TalesStyleEffect"] = true

#==============================================================================
# □ Sprite_BattleEnemyNames
#------------------------------------------------------------------------------
#   戦闘開始時の敵名を表示するスプライトです。
#==============================================================================

class Sprite_BattleEnemyNames < Sprite_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport = nil)
    super(viewport)
    self.bitmap = Bitmap.new(Graphics.width, 288)
    self.x  = width
    self.y  = 104
    self.ox = width
    self.zoom_x  = 4
    self.opacity = 0
    self.visible = true
    @duration = 0
  end
  #--------------------------------------------------------------------------
  # ● 破棄
  #--------------------------------------------------------------------------
  def dispose
    if self.bitmap != nil
      self.bitmap.dispose
      self.bitmap = nil
    end
    super
  end
  #--------------------------------------------------------------------------
  # ○ リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    num = {}  # 名前 => 出現数
    $game_troop.members.each { |enemy|
      name = enemy.original_name
      num[name]  = 0 unless num.has_key?(name)
      num[name] += 1
    }

    bitmap.clear
    img = Cache.system(KGC::TalesStyleEffect::ENEMY_NAME_BACK)
    $game_troop.enemy_names.each_with_index { |name, i|
      dy = i * 36
      bitmap.blt(0, dy, img, img.rect)
      bitmap.font.size = 17  # 設定字體大小為 24
      bitmap.draw_text(width - 256, dy + 4, 224, Window_Base::WLH, name)
      if num[name] > 1
        bitmap.draw_text(width - 64, dy + 4, 48, Window_Base::WLH,
          sprintf("x%2d", num[name]), 2)
      end
    }
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_animation if visible
  end
  #--------------------------------------------------------------------------
  # ○ アニメーション更新
  #--------------------------------------------------------------------------
  def update_animation
    case @duration
    when 0..11
      self.opacity = (@duration + 1) * 64
      self.zoom_x  = (12 - @duration) / 3.0 + 1.0
    when 12
      self.x  = 0
      self.ox = 0
      self.zoom_x  = 1
    when 128..157
      self.zoom_x += 0.05
      self.opacity = (157 - @duration) * 8
    when 188
      self.visible = false
    end
    @duration += 2
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_KGC_TalesStyleEffect initialize
  def initialize
    initialize_KGC_TalesStyleEffect

    create_enemy_name
  end
  #--------------------------------------------------------------------------
  # ○ 敵名スプライトの作成
  #--------------------------------------------------------------------------
  def create_enemy_name
    @enemy_name_sprite = Sprite_BattleEnemyNames.new
    @enemy_name_sprite.z = 90
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias dispose_KGC_TalesStyleEffect dispose
  def dispose
    dispose_KGC_TalesStyleEffect

    dispose_enemy_name
  end
  #--------------------------------------------------------------------------
  # ○ 敵名スプライトの破棄
  #--------------------------------------------------------------------------
  def dispose_enemy_name
    @enemy_name_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias update_KGC_TalesStyleEffect update
  def update
    update_KGC_TalesStyleEffect

    update_enemy_name
  end
  #--------------------------------------------------------------------------
  # ○ 敵名スプライトの更新
  #--------------------------------------------------------------------------
  def update_enemy_name
    @enemy_name_sprite.update if @enemy_name_sprite != nil
  end
  #--------------------------------------------------------------------------
  # ○ 敵名スプライトのリフレッシュ
  #--------------------------------------------------------------------------
  def refresh_enemy_name
    @enemy_name_sprite.refresh
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Scene_Battle
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 戦闘開始の処理
  #--------------------------------------------------------------------------
  def process_battle_start
    @spriteset.refresh_enemy_name
    @message_window.clear
    wait(10)
    if $game_troop.preemptive
      text = sprintf(Vocab::Preemptive, $game_party.name)
      $game_message.texts.push(text)
    elsif $game_troop.surprise
      text = sprintf(Vocab::Surprise, $game_party.name)
      $game_message.texts.push(text)
    end
    #$game_message.texts.push("這場戰鬥不能輸！")
    #wait_for_message
    @message_window.clear
    make_escape_ratio
    process_battle_event
    start_party_command_selection
  end
end