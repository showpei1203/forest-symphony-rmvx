#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：EnemyActionPattern_Core v8.02｜Enemy AI Decision
# 【用途】敵方 AI 的基礎行動決策核心：擴充行動條件、複合條件、rating roulette、State 行動表切換與條件目標再選。
# 【主要機制】主要定義／擴充 RPG::Enemy::Action、RPG::State、Game_Temp、Game_Condition_Members；下方原始說明與程式碼保留作細節依據。
# 【主要影響】RPG::Enemy::Action、RPG::State、Game_Temp、Game_Condition_Members、Game_Battler、Game_BattleAction、Game_Actor
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：TOP_SWITCH、ADDITION_CONDITION_SKILL、CONDITION_ROULETTE、RE_ACTION_TYPE_DEFAULT、USE_RANDOM_TARGET、CONDITION_SIZE、SWITCHES_RANGE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 6 個 alias／方法包裝，載入順序具有語意。
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
# 【Phase 23】本頁的行動 roulette／條件目標亂數已統一經 FS_AI_RANDOM；正常遊戲仍委派 Kernel.rand。
# 【測試】$TEST 下可先 FS_AI_RANDOM.enable(12345)，再觸發敵方行動，以固定抽選結果重現 AI。
#==============================================================================
#==============================================================================
#
#　■ エネミー行動パターン改良　□Ver8.02　□製作者：月紳士
#  
#　・RPGツクールVX用 RGSS2スクリプト
#
#    ●…書き換えメソッド(競合注意)　◎…メソッドのエイリアス　○…新規メソッド
#
#  ※二次配布禁止！配布元には利用規約があります。必ずそちらを見てください。
#------------------------------------------------------------------------------
# 更新履歴（過去の履歴はマニュアルに記載）
# Ver8.02 ○行動条件追加ダミースキルの設定に関する不具合を修正。
# Ver8.01 ○アクターの「行動パターン参照」ステート不具合修正。
# Ver8.00 ○「機能追加：二重行動」スクリプトの為の変更と仕様の見直し。
# Ver7.00 ○仕様の見直し。エネミーにも行動パターン変化ステート適用可能に。
# Ver6.00 ○機能追加：アクター行動パターン化 公開の為の更新。
# Ver5.53 ○行動条件９が機能しなかった不具合修正。
# Ver5.52 ○記述の見直し(仕様変更無し)
# Ver5.51 ○戦闘行動の強制時にも狙う攻撃をしてしまう不具合を修正。
# 　　　　　詳しくはマニュアルのオプション③をご覧ください。
# Ver5.50 ○スクリプトの簡略化。
# Ver5.00 ○Game_Unit::random_targetを書き換えている他スクリプトに対応。
#------------------------------------------------------------------------------
=begin
① 新增行動條件的功能
為敵人的行動模式新增額外的行動條件。
索引 (Switch No.)	條件名稱
0 (= TOP_SWITCH)	可適用或解除效果的對象
1 (= TOP_SWITCH + 1)	HP未完全恢復的對象
2 (= TOP_SWITCH + 2)	HP低於 1/2 的對象
3 (= TOP_SWITCH + 3)	HP低於 1/5 的對象
4 (= TOP_SWITCH + 4)	MP仍然剩餘的對象
5 (= TOP_SWITCH + 5)	仍能行動的對象
6 (= TOP_SWITCH + 6)	指定索引的對象
7 (= TOP_SWITCH + 7)	除了自己以外的對象
8 (= TOP_SWITCH + 8)	友方沒有戰鬥不能的狀態
9 (= TOP_SWITCH + 9)	當場上只剩自己一人時



② 支援設置多個行動條件
例如：可同時設定「回合數指定」+「HP 指定」的條件。
這樣可以對單一行動設置多個條件，只有當所有條件都符合時，才會執行該行動。


③ 變更行動模式決定方式為「輪盤式」
行動決定方式改為 純粹的輪盤機制，以優先度為基礎來選擇行動。
這樣可以使用獨特的方式來規劃敵人的行動模式。



④ 透過狀態變化來改變行動模式
可透過 附加特定狀態 來 暫時改變敵人的行動模式。
例如：當敵人進入「狂暴」狀態時，可以讓它改變為不同的行動模式。
  このスクリプトの機能は大きくわけて４つあります。
  
  ① 新たな行動条件の追加機能。
　　エネミーの行動パターンに、新たな行動条件を追加します。

    index (Switche No.)       : 条件名
    
        0 (= TOP_SWITCH)     : 付加・解除が有効の対象
        1 (= TOP_SWITCH + 1) : HPが全快でない対象
        2 (= TOP_SWITCH + 2) : HPが1/2以下の対象
        3 (= TOP_SWITCH + 3) : HPが1/5以下の対象
        4 (= TOP_SWITCH + 4) : MPが残っている対象
        5 (= TOP_SWITCH + 5) : 動くことが出来る対象
        6 (= TOP_SWITCH + 6) : 指定indexの対象
        7 (= TOP_SWITCH + 7) : 自分以外の対象
        8 (= TOP_SWITCH + 8) : 味方に戦闘不能無し
        9 (= TOP_SWITCH + 9) : 自分ひとりの時

　② 行動条件を複数設定可能にする機能。
　　ターン指定＋HP指定...　というように
　　ひとつの行動に対して複数の条件を設定できるようになります。
　　それら複数の条件すべてを満たす時のみ、その行動をとります。

　③ 行動パターンの決定方法をルーレット方式へ変更。
　　行動パターンの決定の仕方を変えて、優先度による純粋なルーレット方式にします。
　　独自の方式で行動パターンを組むことができるようになります。

　④ 行動パターンを変化させるステートを作成。
 　 エネミーの行動パターンを、設定したステートを付加することで
　　一時的に別のエネミーの行動パターンに変化させることができます。

　機能の詳しい説明と、設定の仕方は、マニュアルを参照してください。

=end
#==============================================================================
# □ カスタマイズ項目
#==============================================================================
module Extension_Action_Condition

  TOP_SWITCH = 121
       #↑# 「新たな行動条件の追加機能」に使用するスイッチ郡の、
          # 最初の番号をここで指定します。
          # ゲーム中の判定に差し支えない番号にしてください。
                     
  ADDITION_CONDITION_SKILL = 83
       #↑#  敵の行動パターン設定において、条件の追加を設定する際に使用する
          # ダミースキルのidをここで設定します。スキルの名前は任意ですが、
          # "＋追加条件" などとしておくと、わかりやすいと思います。
                     
  CONDITION_ROULETTE = true
       #↑# 「行動パターンの決定方法をルーレット方式へ変更」機能は
          # 少し複雑な機能なので、機能をオフに出来るようにしています。
          # マニュアルを読んでわかりにくいと感じたら、オフにしてください。
          # オンにしたい場合は true、オフにしたい場合は false と書き入れます。

  RE_ACTION_TYPE_DEFAULT = 0
       #↑# スキルを使用した際、
          # ターン開始前の行動決定後～ターン中の行動順番が来るまでの間に
          # 行動条件に合うターゲットを消失した場合の動作を３種類から選べます。
          # 0 …(無鉄砲タイプ)
          #      スキルはそのまま実行し、
          #      スキルのターゲットが単独の場合はランダムに対象を選びます。
          # 1 …(好戦的タイプ)
          #      スキルを中止し、ランダム通常攻撃に切り替えます。
          # 2 …(慎重派タイプ)
          #      スキルを中止し、そのターンは様子を見ます。
          # ※ここでの設定はデフォルトの動作となります。
          # エネミー個別でも設定出来ます。方法はマニュアルを参照してください。

 #-----------------------------------------------------------------------------         

  USE_RANDOM_TARGET = false
       #↑# 条件にあった対象をランダムに選出する処理に、
          # Game_Unitクラスのrandom_targetメソッドを流用するか、否かを選べます。
          # オンにしたい場合は true、オフにしたい場合は false と書き入れます。
          # 詳しくはマニュアルのオプション③の項をご覧ください。
 
  CONDITION_SIZE = 10
       #↑# 拡張条件の項目数を示しています。
          # スクリプト改変し条件を追加する際はこの値は増やす必要がありますが
          # 通常、変更する必要はありません。
 
 # ------------------------------------------------(カスタマイズ項目ここまで)--
 
  SWITCHES_RANGE = TOP_SWITCH...(TOP_SWITCH + CONDITION_SIZE)
  
 # ----------------------------------------------------------------------------
end


#==============================================================================
# ■ RPG::Enemy::Action
#==============================================================================

class RPG::Enemy::Action
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :conditions_arrays                   # 行動条件配列
end

#==============================================================================
# ■ RPG::State
#==============================================================================

class RPG::State
  #--------------------------------------------------------------------------
  # ○ 行動パターンステート判定
  #--------------------------------------------------------------------------
  def action_condition_state
    return changing_enemy_action if changing_enemy_action
    return false
  end
  #--------------------------------------------------------------------------
  # ○ ステート [エネミー行動変化] 判定
  #--------------------------------------------------------------------------
  def changing_enemy_action
    if (/[<＜]エネミー行動変化[:：](\d+)[>＞]/) =~ @note
      return $1.to_i
    end
    return false
  end
end

#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　セーブデータに含まれない、一時的なデータを扱うクラスです。このクラスのイン
# スタンスは $game_temp で参照されます。
#==============================================================================

class Game_Temp
  #--------------------------------------------------------------------------
  # ○ 拡張行動条件に使用するスイッチ
  #--------------------------------------------------------------------------
  def ex_conditions_switches
    if @ex_conditions_switches == nil
      @ex_conditions_switches = make_ex_conditions_switches
    end
    return @ex_conditions_switches
  end
  #--------------------------------------------------------------------------
  # ○ 拡張行動条件に使用するスイッチデータの作成
  #--------------------------------------------------------------------------
  def make_ex_conditions_switches
    switches = Array.new(Extension_Action_Condition::CONDITION_SIZE){|i|i+Extension_Action_Condition::TOP_SWITCH}
    return switches
  end
end
  
#==============================================================================
# ■ Game_Condition_Members
#------------------------------------------------------------------------------
# “条件にあったメンバー”を選出する処理に
#  Game_Unitクラスのrandom_targetメソッドを流用する為の予備クラスです。
#  上記メソッドを改変する他スクリプトを併用した場合に、
#  その処理が“条件にあったメンバー”の選出に反映される為の工夫です。
#  このクラスのインスタンスは $game_condition_members で参照されます。
#==============================================================================

class Game_Condition_Members < Game_Unit
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :targets
  #--------------------------------------------------------------------------
  # ○ オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super
    @targets = []
  end
  #--------------------------------------------------------------------------
  # ○ メンバーの取得
  #--------------------------------------------------------------------------
  def members
    return @targets
  end
  #--------------------------------------------------------------------------
  # ○ 生存しているメンバーの配列取得
  #--------------------------------------------------------------------------
  def existing_members
    return @targets
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
  # ○ オブジェクトの付加ステート・解除ステートが有効か判定
  #     obj : スキルもしくはアイテム
  #--------------------------------------------------------------------------
  def available_obj_state(obj)
    return false if obj == nil
    ava = false
    minus = obj.minus_state_set
    if minus != []
      for i in minus
        ava = true if state?(i) 
      end
    end
    plus = obj.plus_state_set
    if plus != []
      for i in plus
        ava = true
        ava = false if state?(i)
        ava = false if state_ignore?(i) 
      end
    end
    return ava
  end
  #--------------------------------------------------------------------------
  # ○ ステート [索敵：頻回] 判定
  #--------------------------------------------------------------------------
  def frequent_target? 
    for state in states
      return true if (/[<＜]索敵[:：]頻回[>＞]/) =~ state.note
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ○ ステート [索敵：極稀] 判定
  #--------------------------------------------------------------------------
  def rare_target? 
    for state in states
      return true if (/[<＜]索敵[:：]極稀[>＞]/) =~ state.note
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件合致判定（行動条件配列使用）
  #--------------------------------------------------------------------------
  def array_conditions_met?(arrays, skill)
    for array in arrays
      case array[0]
      when 1  # ターン数
        n = $game_troop.turn_count
        a = array[1]
        b = array[2]
        return false if (b == 0 and n != a)
        return false if (b > 0 and (n < 1 or n < a or n % b != a % b))
      when 2  # HP
        hp_rate = hp * 100.0 / maxhp
        return false if hp_rate < array[1]
        return false if hp_rate > array[2]
      when 3  # MP
        mp_rate = mp * 100.0 / maxmp
        return false if mp_rate < array[1]
        return false if mp_rate > array[2]
      when 4  # ステート
        return false unless state?(array[1])
      when 5  # パーティレベル
        return false if $game_party.max_level < array[1]
      when 6  # スイッチ
        switch_id = array[1]
        if $game_temp.ex_conditions_switches.include?(switch_id)  # 拡張行動条件合致判定
          return false if ex_conditions_met?(switch_id, skill) == false
        else                                           # 通常のスイッチ判定
          return false if $game_switches[switch_id] == false
        end
      end
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ○ 拡張行動条件合致判定
  #--------------------------------------------------------------------------
  def ex_conditions_met?(conditions, skill)
    index = conditions - Extension_Action_Condition::TOP_SWITCH
    case index
    when 5   # 動くことが出来る対象
      if skill != nil and skill.for_friend?
        if self.is_a?(Game_Enemy)
          return false if $game_troop.preemptive
        else
          return false if $game_troop.surprise
        end
      else
        if self.is_a?(Game_Enemy)
          return false if $game_troop.surprise
        else
          return false if $game_troop.preemptive
        end
      end
    when 8   # 味方に戦闘不能無し
      return false if @action.friends_unit.dead_members != []
    when 9   # 自分ひとりの時
      return false if @action.friends_unit.existing_members.size != 1
    end
    return true
  end
  #--------------------------------------------------------------------------
  # ○ 行動条件配列のセット
  #--------------------------------------------------------------------------
  #  ひとつの行動で複数の条件をあつかう為、
  #  後に続く追加行動条件を取得し、配列化して整理します。
  #--------------------------------------------------------------------------
  def set_conditions_arrays(actions, index)
    action = actions[index]
    action.conditions_arrays = []
    for n in index...actions.size
      sub_action = actions[n]
      unless n == index
        break unless sub_action.skill?
        break if sub_action.skill_id != Extension_Action_Condition::ADDITION_CONDITION_SKILL
      end
      array = [sub_action.condition_type, sub_action.condition_param1, sub_action.condition_param2]
      action.conditions_arrays.push(array)
    end
  end
  #--------------------------------------------------------------------------
  # ○ エネミー行動パターン改良式　戦闘行動の作成
  #--------------------------------------------------------------------------
  def eac_make_action(id = nil)
    reference_enemy = id ? $data_enemies[id] : candidate_actions_enemy
    return if reference_enemy == nil
    candidate_actions = reference_enemy.actions
    @action.clear
    return unless movable? # 行動不能なら中止
    
    #- 初期化
    available_actions = []
    rating_max = 0
    high_rating = 0
    actions_roulette = []
    
    #- 行動リストから行動候補を選出する
    for i in 0...candidate_actions.size
      #- 準備
      action = candidate_actions[i]                     
      skill = action.kind == 1 ? $data_skills[action.skill_id] : nil  
      next if action.kind == 1 and skill.id == Extension_Action_Condition::ADDITION_CONDITION_SKILL
                               # 追加行動条件用項目(ダミースキル)の場合は飛ばす       
      set_conditions_arrays(candidate_actions, i) if action.conditions_arrays.nil?
      arrays = action.conditions_arrays
      
      #- 条件を満たさない場合は次の行動候補へ
      next if @action.conditions_targets(arrays, skill) == []  # ターゲット無し
      next unless array_conditions_met?(arrays, skill)         # 行動条件
      next unless skill_can_use?(skill) if action.kind == 1    # スキル使用不可
      
      #- 行動候補へ
      if Extension_Action_Condition::CONDITION_ROULETTE  # ルーレット方式の場合
        next if action.rating < high_rating              # 昇順のみ登録
        action.rating.times do
          actions_roulette.push(action)
        end
        high_rating = action.rating
      else                                               # 本来の処理
        available_actions.push(action)
        rating_max = [rating_max, action.rating].max
      end
    end
    
    #- 行動の決定
    if Extension_Action_Condition::CONDITION_ROULETTE    # ルーレット方式の場合
      return if actions_roulette.empty?
      action = actions_roulette[FS_AI_RANDOM.rand(actions_roulette.size, :enemy_action_roulette)]
      @action.kind = action.kind
      @action.basic = action.basic
      @action.skill_id = action.skill_id
      @action.decide_random_target
      @action.target_conditions_arrays = action.conditions_arrays
    else                                                 # 本来の処理
      ratings_total = 0
      rating_zero = rating_max - 3
      for action in available_actions
        next if action.rating <= rating_zero
        ratings_total += action.rating - rating_zero
      end
      return if ratings_total == 0
      value = FS_AI_RANDOM.rand(ratings_total, :enemy_action_rating)
      for action in available_actions
        next if action.rating <= rating_zero
        if value < action.rating - rating_zero
          @action.kind = action.kind
          @action.basic = action.basic
          @action.skill_id = action.skill_id
          @action.decide_random_target
          @action.target_conditions_arrays = action.conditions_arrays
          return
        else
          value -= action.rating - rating_zero
        end
      end
    end
  end
  #--------------------------------------------------------------------------
  # ◎ ステート変化の適用
  #     obj : スキル、アイテム、または攻撃者
  #--------------------------------------------------------------------------
  alias tig_eac_apply_state_changes apply_state_changes
  def apply_state_changes(obj)
    tig_eac_apply_state_changes(obj)
    if $game_temp.in_battle               # 戦闘中なら
      for state in added_states
        if state.action_condition_state   # 行動変化ステートが付加された場合
          eac_make_action                 # 行動パターンを再選出
        end
      end
    end
      for state in removed_states
        if state.action_condition_state   # 行動変化ステートが除去された場合
          @action.clear                   # 行動パターンのクリア
        end
      end
  end
end

#==============================================================================
# ■ Game_BattleAction
#------------------------------------------------------------------------------
# 　戦闘行動を扱うクラスです。このクラスは Game_Battler クラスの内部で使用され
# ます。
#==============================================================================

class Game_BattleAction
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :target_conditions_arrays            # 条件ターゲット配列
  #--------------------------------------------------------------------------
  # ◎ クリア
  #--------------------------------------------------------------------------
  alias tig_eac_clear clear
  def clear
    tig_eac_clear
    @target_conditions_arrays = []
  end
  #--------------------------------------------------------------------------
  # ○ 条件にあうターゲットグループの取得
  #--------------------------------------------------------------------------
  def conditions_targets(arrays, skill) 
    if skill != nil and skill.for_friend?
      if skill.for_dead_friend?
        targets = friends_unit.dead_members
      elsif  skill.for_user?
        targets = [@battler]
      else
        targets = friends_unit.existing_members
      end
    else
      targets = opponents_unit.existing_members
    end
    
    for array in arrays
      new_targets = []
      if array[0] == 6
        case array[1]
        when Extension_Action_Condition::TOP_SWITCH      # 付加・解除が有効の対象
          for target in targets
            next unless target.available_obj_state(skill)
            new_targets.push(target)
          end
          targets = new_targets
        when (Extension_Action_Condition::TOP_SWITCH + 1) # HPが全快でない対象
          for target in targets
            new_targets.push(target) unless target.hp == target.maxhp
          end
          targets = new_targets
        when (Extension_Action_Condition::TOP_SWITCH + 2) # HPが1/2以下の対象
          for target in targets
            new_targets.push(target) if target.hp < (target.maxhp / 1.3)
          end
          targets = new_targets
        when (Extension_Action_Condition::TOP_SWITCH + 3) # HPが1/5以下の対象
          for target in targets
            new_targets.push(target) if target.hp < (target.maxhp / 5)
          end
          targets = new_targets
        when (Extension_Action_Condition::TOP_SWITCH + 4) # MPが残っている対象
          for target in targets
            new_targets.push(target) unless target.mp == 0
          end
          targets = new_targets
        when (Extension_Action_Condition::TOP_SWITCH + 5) # 動くことが出来る対象
          for target in targets
            new_targets.push(target) if target.movable? and not target.confusion?
          end
          targets = new_targets
        when (Extension_Action_Condition::TOP_SWITCH + 6) # 指定indexの対象
          if skill != nil and skill.for_friend?
            targets1 = friends_unit.members
          else
            targets1 = opponents_unit.members
          end
          for i in $game_troop.appoint_target
            new_targets.push(targets1[i])
          end
          targets = new_targets & targets
          targets = [] if targets == nil
        when (Extension_Action_Condition::TOP_SWITCH + 7) # 自分以外の対象
          for target in targets
            new_targets.push(target) if target != @battler
          end
          targets = new_targets
        end
      end
    end
    return targets
  end
  #--------------------------------------------------------------------------
  # ○ 条件ターゲットの作成
  #--------------------------------------------------------------------------
  def make_conditions_targets
    return if @forcing
    c_targets = conditions_targets(@target_conditions_arrays, skill)
    if c_targets != []
      target = roulette(c_targets)
      @target_index = target.index
    end
  end
  #--------------------------------------------------------------------------
  # ○ 条件ターゲット専用、ターゲットルーレット
  #--------------------------------------------------------------------------
  #  ターゲットグループから条件にあったターゲットを選出する為の
  #  専用ルーレットです。
  #--------------------------------------------------------------------------
  def roulette(targets)
    return nil if targets == []
    if Extension_Action_Condition::USE_RANDOM_TARGET
    #- random_targetメソッドを流用する場合
       
      $game_condition_members.targets = targets
      result_target = $game_condition_members.random_target
      unless result_target.frequent_target?  # <頻繁>以外は再ルーレット
        result_target = $game_condition_members.random_target
      end
      if result_target.rare_target?          # <極稀>なら再ルーレット
        result_target = $game_condition_members.random_target
      end
      return result_target
      
    else
    #- このメソッド内で独自の処理をする場合
      
      result_target = nil
      roulette = []
      for target in targets
        target.odds.times do
          roulette.push(target)
        end
      end
      result_target = roulette[FS_AI_RANDOM.rand(roulette.size, :enemy_condition_target)]
      unless result_target.frequent_target?  # <頻繁>以外は再ルーレット
        result_target = roulette[FS_AI_RANDOM.rand(roulette.size, :enemy_condition_target_retry1)]
      end
      if result_target.rare_target?          # <極稀>なら再ルーレット
        result_target = roulette[FS_AI_RANDOM.rand(roulette.size, :enemy_condition_target_retry2)]
      end
      return result_target
      
    end
  end
end

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス ($game_actors)
# の内部で使用され、Game_Party クラス ($game_party) からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ○ 未収得スキルの使用許可（追加スクリプト用定義）
  #--------------------------------------------------------------------------
  def not_learn_skill_can_use
    return false
  end
  #--------------------------------------------------------------------------
  # ○ ステート [行動パターン] 判定（追加スクリプト用定義）
  #--------------------------------------------------------------------------
  def action_condition_state?
    return false
  end
  #--------------------------------------------------------------------------
  # ○ 行動候補エネミー（追加スクリプト用定義）
  #--------------------------------------------------------------------------
  def candidate_actions_enemy
    return nil
  end
end

#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　敵キャラを扱うクラスです。このクラスは Game_Troop クラス ($game_troop) の
# 内部で使用されます。
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ○ ターゲット消失時の再行動タイプの取得
  #--------------------------------------------------------------------------
  def re_action_type
    return 0 if enemy.note.include?("<無鉄砲>")
    return 1 if enemy.note.include?("<好戦的>")
    return 2 if enemy.note.include?("<慎重派>")
    return Extension_Action_Condition::RE_ACTION_TYPE_DEFAULT
  end
  #--------------------------------------------------------------------------
  # ○ ステート [行動パターン] 判定
  #--------------------------------------------------------------------------
  def action_condition_state? 
    for state in states
      return true if state.action_condition_state
    end
    return false
  end
  #--------------------------------------------------------------------------
  # ○ 行動候補エネミー
  #--------------------------------------------------------------------------
  def candidate_actions_enemy
    for state in states.sort{|a, b| a.id <=> b.id} 
      if state.action_condition_state
        return $data_enemies[state.action_condition_state]
      end
    end
    return enemy
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の作成（再定義）
  #--------------------------------------------------------------------------
  def make_action
    eac_make_action
  end
end

#==============================================================================
# ■ Game_Troop
#------------------------------------------------------------------------------
# 　敵グループおよび戦闘に関するデータを扱うクラスです。バトルイベントの処理も
# 行います。このクラスのインスタンスは $game_troop で参照されます。
#==============================================================================

class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # ○ 公開インスタンス変数
  #-------------------------------------------------------------------------- 
  attr_accessor :appoint_target      # ターゲット指定
  #--------------------------------------------------------------------------
  # ◎ オブジェクト初期化
  #--------------------------------------------------------------------------
  alias tig_eac_initialize initialize
  def initialize
    tig_eac_initialize
    @appoint_target = []
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
  alias tig_eac_create_game_objects create_game_objects
  def create_game_objects
    tig_eac_create_game_objects
    $game_condition_members          = Game_Condition_Members.new
  end
end

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ◎ 戦闘行動の実行
  #  ※ 行動直前にターゲットを再選択する処理を追加。
  #--------------------------------------------------------------------------
  alias tig_eac_execute_action execute_action
  def execute_action
    if (@active_battler.actor? and @active_battler.action_condition_state?) or
        not @active_battler.actor?
      @active_battler.action.make_conditions_targets
    end
    tig_eac_execute_action
  end
  #--------------------------------------------------------------------------
  # ◎ 戦闘行動の実行 : スキル
  #  ※ ターゲット消失時の再行動処理を追加。
  #--------------------------------------------------------------------------
  alias tig_eac_execute_action_skill execute_action_skill
  def execute_action_skill
    if (@active_battler.actor? and @active_battler.action_condition_state?) or
        not @active_battler.actor?
      arrays = @active_battler.action.target_conditions_arrays
      skill = @active_battler.action.skill
      if @active_battler.action.conditions_targets(arrays, skill) == []
        unless @active_battler.action.forcing
          case @active_battler.re_action_type
          when 1 # 好戦的タイプ
            @active_battler.action.set_attack
            @active_battler.action.skill_id = 0
            return execute_action_attack
          when 2 # 慎重派タイプ
            @active_battler.action.skill_id = 0
            @active_battler.action.kind = 0
            @active_battler.action.basic = 3
            return execute_action_wait
          end
        end
      end
    end
    tig_eac_execute_action_skill
  end
end