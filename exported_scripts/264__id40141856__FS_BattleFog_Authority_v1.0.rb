#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_BattleFog_Authority v1.0
# 【用途】Forest Symphony 正式 Authority「FS_BattleFog_Authority v1.0」，集中管理此功能目前應修改的主要實作。
# 【主要機制】本頁可能由既有 Base／第三方插件一路 Patch 而來；修改時仍需查看 LoadOrder Guide／Authority Map，確認是否還有後載入 wrapper。
# 【主要影響】Sprite_Mist、Spriteset_Battle、Sprite_Mist1、BMIST
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SW_NOUSE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 6 個 alias／方法包裝，載入順序具有語意；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：mist。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
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
# PHASE 8 AUTHORITY: FS_BattleFog_Authority v1.0
# BMIST 原始戰鬥霧＋目前正式 Runtime Patch。
# Original load order: 269:雾气效果 -> 270:霧氣效果｜Battle Runtime Patch
#==============================================================================
# PHASE8 ORIGINAL PAGE: 269 | 雾气效果
#==============================================================================
#==============================================================================
# RGSS2_バトルミスト
# tomoaky (http://hikimoki.hp.infoseek.co.jp/)
#
# 2010/03/29  ミストの表示サイズ等を少し変更
# 2010/01/04  公開
#
# 戦闘シーンの背景に霧を表示するスクリプト素材です、
# スクリプトエディタで "▼ 素材" の下あたりに挿入してください。
# 動作には mist.拡張子 という画像ファイルが必要になります、
# Graphics/System の中に置いてください。
#==============================================================================

#==============================================================================
# □ 設定項目
#==============================================================================
module BMIST
  SW_NOUSE = 32                            # 功能显示使用开关号码
end

#==============================================================================
# ■ Sprite_Mist
#==============================================================================
class Sprite_Mist < Sprite
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    #self.bitmap = Cache.parallax ("back08") if $BTEST
    self.bitmap = Cache.system("mist")
    self.blend_type = 1
    self.opacity = 150
    self.ox = 128
    self.oy = 128#64
    self.y = Graphics.height - 128 - self.oy + rand(128)#32)
    setup
    self.x = rand(Graphics.width)
    @real_x = self.x << 10
  end
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  def setup
    @vx = rand(512) + 512#256
    self.zoom_x = (rand(600) + 700) / 1200.0
    if self.zoom_x < 1.0    # バトラーの奥に配置
      self.z = 2
    else                    # バトラーの手前に配置
      self.z = 400
    end
    self.zoom_y = self.zoom_x
    self.x = Graphics.width + (128 * self.zoom_x).to_i
    @real_x = self.x << 10
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    @real_x -= @vx
    self.x = @real_x >> 10
    setup if self.x < (0 - (128 * self.zoom_x).to_i)
  end
end

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● バトルバックスプライトの作成
  #--------------------------------------------------------------------------
  alias bmist_spriteset_battle_create_battleback create_battleback
  def create_battleback
    bmist_spriteset_battle_create_battleback
    ###
    ###
    
    @mist_sprites = []
    unless $game_switches[BMIST::SW_NOUSE]
      for i in 0...13 do @mist_sprites.push(Sprite_Mist.new(@viewport1)) end
    end
  end
  #--------------------------------------------------------------------------
  # ● バトルバックスプライトの解放
  #--------------------------------------------------------------------------
  alias bmist_spriteset_battle_dispose_battleback dispose_battleback
  def dispose_battleback
    bmist_spriteset_battle_dispose_battleback
    for sprite in @mist_sprites do sprite.dispose end
  end
  #--------------------------------------------------------------------------
  # ● バトルバックの更新
  #--------------------------------------------------------------------------
  alias bmist_spriteset_battle_update_battleback update_battleback
  def update_battleback
    bmist_spriteset_battle_update_battleback
    for sprite in @mist_sprites do sprite.update end
  end
end



#==============================================================================
# PHASE8 ORIGINAL PAGE: 270 | 霧氣效果｜Battle Runtime Patch
#==============================================================================
#==============================================================================
# RGSS2_バトルミスト
# tomoaky (http://hikimoki.hp.infoseek.co.jp/)
#
# 2010/03/29  ミストの表示サイズ等を少し変更
# 2010/01/04  公開
#
# 戦闘シーンの背景に霧を表示するスクリプト素材です、
# スクリプトエディタで "▼ 素材" の下あたりに挿入してください。
# 動作には mist.拡張子 という画像ファイルが必要になります、
# Graphics/System の中に置いてください。
#==============================================================================

#==============================================================================
# □ 設定項目
#==============================================================================
module BMIST
  SW_NOUSE = 32                            # 功能显示使用开关号码
end

#==============================================================================
# ■ Sprite_Mist
#==============================================================================
class Sprite_Mist1 < Sprite
  #################
 # include Wora_NSS
  #################
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(viewport)
    super(viewport)
    self.bitmap = Cache.save ("temp1")
    self.bitmap = Cache.parallax ("back08") if $BTEST
    #Wora_NSS.shot('Graphics/System/' + 'temp')
#    wora_nss_scemap_ter
    #$game_map.wora_nss_scemap_ter
    #self.bitmap = $game_temp.background_bitmap
    self.z = 50
  end
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  def setup

  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose if $BTEST
    super
  end
  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    
  end
end

#==============================================================================
# ■ Spriteset_Battle
#==============================================================================
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● バトルバックスプライトの作成
  #--------------------------------------------------------------------------
  alias bmist_spriteset_battle_create_battleback1 create_battleback
  def create_battleback
    bmist_spriteset_battle_create_battleback1
    #@battleback_sprite = Sprite_Mist1.new(@viewport1)
    ###
    @battleback_sprite = Sprite_Mist1.new(@viewport1)###
    @battleback_sprite = Sprite_Mist1.new(@viewport1) if $BTEST
    
  end
  #--------------------------------------------------------------------------
  # ● バトルバックスプライトの解放
  #--------------------------------------------------------------------------
  alias bmist_spriteset_battle_dispose_battleback1 dispose_battleback
  def dispose_battleback
    bmist_spriteset_battle_dispose_battleback1
    @battleback_sprite.dispose if $BTEST
    #@battleback_sprite.dispose
  #  @back.dispose
    @battleback_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● バトルバックの更新
  #--------------------------------------------------------------------------
  alias bmist_spriteset_battle_update_battleback1 update_battleback
  def update_battleback
    bmist_spriteset_battle_update_battleback1
    @battleback_sprite.update if $BTEST
#    @back.update
    @battleback_sprite.update
  end
end


