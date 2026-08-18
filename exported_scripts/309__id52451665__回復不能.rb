#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：回復不能
# 【用途】保留的 Runtime 元件「回復不能」。
# 【主要機制】主要定義／擴充 State、Game_Battler、Scene_Battle、RPG；下方原始說明與程式碼保留作細節依據。
# 【主要影響】State、Game_Battler、Scene_Battle、RPG
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 5 個 alias／方法包裝，載入順序具有語意。
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
#
#    回復不能ステート(RGSS2)
#　　(C)2008 TYPE74RX-T
#

#--------------------------------------------------------------------------
# ★ システムワードの登録：ＨＰ回復不能、ＭＰ回復不能
#--------------------------------------------------------------------------
module RPG
  class State
    alias rx_rgss2b20_rx_extract_sys_str_from_note rx_extract_sys_str_from_note
    def rx_extract_sys_str_from_note
      rx_get_sys = RX_T.get_system_word_in_note(@note, "ＨＰ回復不能")
     unless rx_get_sys == ""
       @@rx_copy_str += rx_get_sys
       @note = @note.sub(rx_get_sys, "")
       @note = @note.sub("\r\n", "")
     end
      rx_get_sys = RX_T.get_system_word_in_note(@note, "ＭＰ回復不能")
     unless rx_get_sys == ""
       @@rx_copy_str += rx_get_sys
       @note = @note.sub(rx_get_sys, "")
       @note = @note.sub("\r\n", "")
     end
     @rx_sys_str = @@rx_copy_str
      # メソッドを呼び戻す
      rx_rgss2b20_rx_extract_sys_str_from_note
    end
  end
end

#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　バトラーを扱うクラスです。このクラスは Game_Actor クラスと Game_Enemy クラ
# スのスーパークラスとして使用されます。
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias rx_rgss2b20_initialize initialize
  def initialize
    # メソッドを呼び戻す
    rx_rgss2b20_initialize
    @rx_hp_cannot_heal = false     # ★ ＨＰ回復不能フラグ
    @rx_mp_cannot_heal = false     # ★ ＭＰ回復不能フラグ
  end
  #--------------------------------------------------------------------------
  # ★ ＨＰ回復不能フラグ
  #--------------------------------------------------------------------------
  def rx_hp_cannot_heal
    return @rx_hp_cannot_heal
  end
  #--------------------------------------------------------------------------
  # ★ ＭＰ回復不能フラグ
  #--------------------------------------------------------------------------
  def rx_mp_cannot_heal
    return @rx_mp_cannot_heal
  end
  #--------------------------------------------------------------------------
  # ★ ＨＰＭＰ回復不能フラグ
  #--------------------------------------------------------------------------
  def rx_hpmp_cannot_heal
    return @rx_hpmp_cannot_heal
  end
  #--------------------------------------------------------------------------
  # ★ 回復不能判定
  #--------------------------------------------------------------------------
  def rx_get_cannot_heal
    @rx_hp_cannot_heal = false
    @rx_mp_cannot_heal = false
    for state in states
      @rx_hp_cannot_heal = true if state.rx_sys_str.include?("ＨＰ回復不能")
      @rx_mp_cannot_heal = true if state.rx_sys_str.include?("ＭＰ回復不能")
    end
  end
  #--------------------------------------------------------------------------
  # ● 制約の取得
  #    現在付加されているステートから最大の restriction を取得する。
  #--------------------------------------------------------------------------
  alias rx_rgss2b20_restriction restriction
  def restriction
    # ★ 回復不能判定
    rx_get_cannot_heal
    # メソッドを呼び戻す
    rx_rgss2b20_restriction
  end
  #--------------------------------------------------------------------------
  # ● ダメージの反映
  #     user : スキルかアイテムの使用者
  #    呼び出し前に @hp_damage、@mp_damage、@absorbed が設定されていること。
  #--------------------------------------------------------------------------
  alias rx_rgss2b20_execute_damage execute_damage
  def execute_damage(user)
    # ★ ＨＰ回復不能状態なら回復値を０に
    @hp_damage = 0 if self.rx_hp_cannot_heal and @hp_damage < 0
    # ★ ＭＰ回復不能状態なら回復値を０に
    @mp_damage = 0 if self.rx_mp_cannot_heal and @mp_damage < 0
    # ★ ＨＰ回復不能状態の使用者には吸収を無効に。
    if user.rx_hp_cannot_heal and @absorbed and @hp_damage > 0
      @absorbed = false
    end
    # ★ ＭＰ回復不能状態の使用者には吸収を無効に。
    if user.rx_mp_cannot_heal and @absorbed and @mp_damage > 0
      @absorbed = false
    end
    # メソッドを呼び戻す
    rx_rgss2b20_execute_damage(user)
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● HP ダメージ表示
  #     target : 対象者
  #     obj    : スキルまたはアイテム
  #--------------------------------------------------------------------------
  alias rx_rgss2b20_display_hp_damage display_hp_damage
  def display_hp_damage(target, obj = nil)
    if target.hp_damage == 0                # ノーダメージ
      return if obj != nil and obj.damage_to_mp
      return if obj != nil and obj.base_damage == 0
      # ★ ＨＰ回復不能ステートの対象に回復系のスキルまたはアイテムを使った場合
      if obj != nil and obj.base_damage < 0 and target.rx_hp_cannot_heal
        # 「効かなかった」表示
        text = sprintf(Vocab::ActionFailure, target.name)
        @message_window.add_instant_text(text)
        wait(30)
        return
      end
    end
    # メソッドを呼び戻す
    rx_rgss2b20_display_hp_damage(target, obj)
  end
end