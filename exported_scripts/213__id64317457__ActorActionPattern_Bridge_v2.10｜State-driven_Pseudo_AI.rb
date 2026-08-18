#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：ActorActionPattern_Bridge v2.10｜State-driven Pseudo AI
# 【用途】讓 Actor 透過 State 暫時引用 Enemy 行動表，形成 State-driven 擬似 AI／變身行為；沒有此 State 時交回既有 Actor make_action。
# 【主要機制】主要定義／擴充 RPG::State、Game_Actor、Scene_Battle；下方原始說明與程式碼保留作細節依據。
# 【主要影響】RPG::State、Game_Actor、Scene_Battle
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
# 【Phase 23】本頁是 FS_AutoBattleAI_Authority 前方的 Bridge；AutoBattleAI 無 AI State 時會透過 original_make_action 回到本頁既有行為。
# 【範例】State Note：<エネミー行動参照：1> 只允許已學技能；<エネミー行動変化：1> 可直接使用該 Enemy 行動表技能。
#==============================================================================
#==============================================================================
#
#　■ エネミー行動パターン改良
#     機能追加：アクター行動パターン化 □Ver2.10　□製作者：月紳士
#  
#　・RPGツクールVX用 RGSS2スクリプト
#
#    ●…書き換えメソッド(競合注意)　◎…メソッドのエイリアス　○…新規メソッド
#
#  ※二次配布禁止！配布元には利用規約があります。必ずそちらを見てください。
#------------------------------------------------------------------------------
# 更新履歴
# Ver2.10 ○「機能追加：二重行動」スクリプトの為の変更と仕様の見直し。
# Ver2.00 ○仕様の見直し。
#------------------------------------------------------------------------------
=begin

  ※このスクリプトは月紳士の「エネミー行動パターン改良」に
  　新たな機能を追加する拡張スクリプトです。
 　 「エネミー行動パターン改良」(Ver8.00以降)が必要となります。
  　このスクリプトは「エネミー行動パターン改良」より下に挿入してください。
  
#------------------------------------------------------------------------------

  このスクリプトを導入すると、エネミーの行動パターン処理を応用して、
  アクターを行動パターンで動かすことが出来るようになります。
  
  工夫次第で、擬似AIアクターを作ることが出来たり、
  エネミーへの変身を表現したり出来ます。
  
  行動指定はステートによって行います。
  
<エネミー行動参照：1>角色仍僅能使用自己學習過的技能

　もしくは

<エネミー行動変化：1>角色可以使用該敵人所有的技能，即使未曾學習過

　とメモ欄に書いたステートをアクターに付加してください。
　1 の部分は任意のエネミーのIDを入れます。(半角数字)

　これらステートにかかったアクターは、ステートにかかっている間
　自動戦闘となり、ID指定したエネミーの行動パターンで行動します。

　行動参照はアクターが習得しているスキルのみが行動に反映されます。
　行動変化はアクターのスキル習得有無に関係なくスキルを使います。

　 ※ このタイプのステートが付加した時点、もしくは解除された時点で
　　　未行動だった場合は、そのターンの行動はキャンセルされる仕様です。
  
   ※ エネミーの行動をそのまま流用している関係で、
  　　アクターには反映されない行動も出てきます。
  
　　　行動種類によっては不具合もあるかもしれません。
　　　不具合を起こす設定を避ける等の工夫もお願いします。

=end

#==============================================================================
# ■ RPG::State
#==============================================================================

class RPG::State
  #--------------------------------------------------------------------------
  # ◎ 行動パターンステート判定
  #--------------------------------------------------------------------------
  alias tig_eac_aac_action_condition_state action_condition_state
  def action_condition_state
    return reference_enemy_action if reference_enemy_action
    return tig_eac_aac_action_condition_state
  end
  #--------------------------------------------------------------------------
  # ○ ステート [エネミー行動参照] 判定
  #--------------------------------------------------------------------------
  def reference_enemy_action
    if (/[<＜]エネミー行動参照[:：](\d+)[>＞]/) =~ @note
      return $1.to_i
    end
    return false
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
  # ○ エネミー行動中のターゲット消失時の再行動タイプの取得
  #--------------------------------------------------------------------------
  def re_action_type
    for state in states.sort{|a, b| a.id <=> b.id} 
      if state.action_condition_state
        note = $data_enemies[state.action_condition_state].note
        return 0 if note.include?("<無鉄砲>")
        return 1 if note.include?("<好戦的>")
        return 2 if note.include?("<慎重派>")
        return Extension_Action_Condition::RE_ACTION_TYPE_DEFAULT
      end
    end
    return Extension_Action_Condition::RE_ACTION_TYPE_DEFAULT
  end
  #--------------------------------------------------------------------------
  # ● スキルの使用可能判定
  #     skill : スキル
  #--------------------------------------------------------------------------
  def skill_can_use?(skill)
    return false if not skill_learn?(skill) and not not_learn_skill_can_use ## 変更部分
    return super
  end
  #--------------------------------------------------------------------------
  # ◎ 未収得スキルの使用許可
  #--------------------------------------------------------------------------
  alias tig_eac_aac_not_learn_skill_can_use not_learn_skill_can_use
  def not_learn_skill_can_use
    return true if action_condition_state_a_changing_type?
    return tig_eac_aac_not_learn_skill_can_use
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
  # ○ ステート [行動パターン] が変身タイプか？
  #--------------------------------------------------------------------------
  def action_condition_state_a_changing_type? 
    for state in states
      if state.action_condition_state
        return state.changing_enemy_action
      end
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
    return nil
  end
  #--------------------------------------------------------------------------
  # ◎ オプション [自動戦闘] の取得
  #--------------------------------------------------------------------------
  alias tig_eac_aac_auto_battle auto_battle
  def auto_battle
    return true if action_condition_state?
    return tig_eac_aac_auto_battle
  end
  #--------------------------------------------------------------------------
  # ◎ 戦闘行動の作成 (自動戦闘用)
  #--------------------------------------------------------------------------
  alias tig_eac_aac_make_action make_action
  def make_action
    if action_condition_state?
      eac_make_action
    else
      tig_eac_aac_make_action
    end
  end
end  

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base  
  #--------------------------------------------------------------------------
  # ◎ 戦闘行動の実行 : 逃走
  #  ※ アクター用の逃走動作を作成。
  #--------------------------------------------------------------------------
  alias tig_eac_aac_execute_action_escape execute_action_escape
  def execute_action_escape
    return tig_eac_aac_execute_action_escape unless @active_battler.actor?
    text = sprintf(Vocab::EscapeStart, @active_battler.name)
    if $game_party.existing_members.size == 1
      Sound.play_escape
      @info_viewport.visible = false
      @message_window.visible = true
      $game_message.texts.push(text)
      wait_for_message
      return battle_end(1)  # パーティーが逃走したアクターひとりならば戦闘終了
    else                    # そうでなければ行動失敗
      @message_window.add_instant_text(text)
      Sound.play_escape
      wait(20)
      @message_window.add_instant_text(Vocab::EscapeFailure)
      wait(45)
    end
  end
end