#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：行動封印
# 【用途】保留的 Runtime 元件「行動封印」。
# 【主要機制】主要定義／擴充 State、Game_Battler、Game_BattleAction、Window_ActorCommand；下方原始說明與程式碼保留作細節依據。
# 【主要影響】State、Game_Battler、Game_BattleAction、Window_ActorCommand、Scene_Battle、RPG
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
=begin
RPG探検隊 様の「アクティブタイムバトルスクリプトVer1.2」
にアクション封印ステートを追加
回想領域 様の「各戦闘コマンド封印ステートVer1.11」を元にATB向けに改造しました。

ATBスクリプトより下においてください。

=end
module RPG
  class State
    # メモ欄から封印アクションを取得
    def setup_seal
      @a_seal = self.note.include?("攻撃封印")
      @s_seal = self.note.include?("スキル封印")
      @g_seal = self.note.include?("防御封印")
      @i_seal = self.note.include?("アイテム封印")
    end
    
    def a_seal?
      setup_seal if @a_seal.nil?
      return @a_seal
    end
    def s_seal?
      setup_seal if @s_seal.nil?
      return @s_seal
    end
    def g_seal?
      setup_seal if @g_seal.nil?
      return @g_seal
    end
    def i_seal?
      setup_seal if @i_seal.nil?
      return @i_seal
    end
  end
end

class Game_Battler
  def a_seal?
    result = false
    for state in self.states
      if state.a_seal?
        result = true
        break
      end
    end
    return result
  end
  def s_seal?
    result = false
    for state in self.states
      if state.s_seal?
        result = true
        break
      end
    end
    return result
  end
  def g_seal?
    result = false
    for state in self.states
      if state.g_seal?
        result = true
        break
      end
    end
    return result
  end
  def i_seal?
    result = false
    for state in self.states
      if state.i_seal?
        result = true
        break
      end
    end
    return result
  end
  
  #--------------------------------------------------------------------------
  # ● スキルの使用可能判定
  #     skill : スキル
  #--------------------------------------------------------------------------
  alias :_atb_with_seal__skill_can_use? :skill_can_use? unless method_defined?(:_atb_with_seal__skill_can_use?)
  def skill_can_use?(skill)
    return false if self.s_seal?
    _atb_with_seal__skill_can_use?(skill)
  end
  
end
class Game_BattleAction
  #--------------------------------------------------------------------------
  # ● 行動が有効か否かの判定
  #--------------------------------------------------------------------------
  alias :_atb_with_seal__valid? :valid? unless method_defined?(:_atb_with_seal__valid?)
  def valid?
    return false if attack? && battler.a_seal?
    return false if skill? && battler.s_seal?
    return false if guard? && battler.g_seal?
    return false if item? && battler.i_seal?
    _atb_with_seal__valid?
  end

end

class Window_ActorCommand
  #--------------------------------------------------------------------------
  # ● セットアップ
  #--------------------------------------------------------------------------
  alias :_atb_with_seal__setup :setup unless method_defined?(:_atb_with_seal__setup)
  def setup(actor)
    @actor = actor
    @states = []
    _atb_with_seal__setup(actor)
  end
  
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  # 再定義
  def refresh
    self.contents.clear
    if @actor.nil?
      @states = []
      for i in 0...@item_max
        draw_item(i)
      end
    else
      draw_item(0, !@actor.a_seal?)
      draw_item(1, !@actor.s_seal?)
      draw_item(2, !@actor.g_seal?)
      draw_item(3, !@actor.i_seal?)
      @states = @actor.states
    end
  end

  # 更新
  def update
    # ステート変化があった場合はリフレッシュ
    refresh if !@actor.nil? and @states != @actor.states
    super
  end

end

class Scene_Battle
  #--------------------------------------------------------------------------
  # ● コマンド入力できる状態か
  #--------------------------------------------------------------------------
  alias :_atb_with_seal__commanding? :commanding? unless method_defined?(:_atb_with_seal__commanding?)
  def commanding?
    if @commander.a_seal? and @commander.s_seal? and @commander.g_seal? and @commander.i_seal?
      return false
    end
    _atb_with_seal__commanding?
  end
  
  #--------------------------------------------------------------------------
  # ● コマンド更新
  #--------------------------------------------------------------------------
  alias :_atb_with_seal__update_actor_command_selection :update_actor_command_selection unless method_defined?(:_atb_with_seal__update_actor_command_selection)
  def update_actor_command_selection
    # コマンド入力できる状態でなくなればキャンセル
    return reset_command unless commanding?
    # 封印されているアクションが選択された場合はブザーを鳴らして制御を戻す
    if Input.trigger?(Input::C)
      case @actor_command_window.index
      when 0  # 攻撃
        if @commander.a_seal?
          Sound.play_buzzer
          Input.update
          return
        end
      when 1  # スキル
        if @commander.s_seal?
          Sound.play_buzzer
          Input.update
          return
        end
      when 2  # 防御
        if @commander.g_seal?
          Sound.play_buzzer
          Input.update
          return
        end
      when 3  # アイテム
        if @commander.i_seal?
          Sound.play_buzzer
          Input.update
          return
        end
      end
    end
    _atb_with_seal__update_actor_command_selection
  end
end

