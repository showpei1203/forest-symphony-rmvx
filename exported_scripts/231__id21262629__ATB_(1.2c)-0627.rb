#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：ATB (1.2c)-0627｜Tankentai ATB Runtime
# 【用途】Tankentai SBS 的 ATB 執行層。管理戰鬥者 ATB 累積、行動者排程、Charge、先制／偷襲、逃跑、狀態回合、ATB 游標／Gauge、指令視窗與戰鬥中技能／道具 UI。
# 【主要影響】Scene_Battle、Game_Battler、Game_Party、Sprite_ATB、Sprite_Cursor、Sprite_Battler、Spriteset_Battle、Window_Skill、Window_BattleStatus、Scene_ATB。
# 【設定來源】大部分可調參數不在本頁，而在前方「ATB Configurations」。本頁讀取 N02::ATB_* 常數並執行；若要改速度、Wait/Active、Turn、Charge、UI 位置，優先改 Config 頁。
# 【重要流程】戰鬥 start 時呼叫 $game_party.atb_customize；preemptive/surprise 直接設定 at_count；update/update_basic 持續處理行動者、Charge、逃跑、勝敗與各視窗；行動結束後依 ATB 規則重新排程。
# 【特殊既有設定】頁首歷史註解的 894 為「普通攻擊彈藥消耗所使用的職業 ID」。此值屬目前祖傳 Runtime 約定，未確認前不要任意改。
# 【UI／素材】直接使用 battle_skillwindowbg、battle_itemwindowbg、menu_bar、menu_喬伊、menu_米亞、menu_艾卓、menu_薇娜、menu_艾薇、menu_泰勒，以及 Battle-active 等既有資源。
# 【呼叫方式】由 Scene_Battle／Tankentai 自動執行，沒有建議的事件 Script Call。需要測 ATB 設定時以正式戰鬥驗證，不要直接呼叫 update_basic 或改 @action_battlers。
# 【載入順序】本頁是 Sideview／ATB 主鏈之一，含多個 alias，後方 FS Targeting、State、HUD、Battle Integrity 等還會再包裝；維持目前已驗證順序。
# 【來源】Tankentai ATB Ver1.2c（專案內 0627 修改版）；原日文程式註解保留，英文維護說明集中至本頁開頭。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 維護說明集中於腳本最前方；程式識別字、Notetag、Script Call、Action Key 不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；翻譯前 byte-exact 原稿另存 Phase 17 Archive。
# 3. 範例只列原文件或既有程式能直接證實的入口，不捏造 API。
# 4. 本輪除註解／說明外不修改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
# 894 - 普通攻擊彈藥消耗所使用的職業 ID
#==============================================================================
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  alias start_n02 start
  def start
    $gauge_stop = true
    $game_party.atb_customize
    start_n02
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  alias terminate_n02 terminate
  def terminate 
    terminate_n02
    # 二刀流の持ち替え処理を戻す
    for member in $game_party.members
      if member.two_swords_change
        member.change_equip_by_id(1, member.weapon_id)
        member.change_equip_by_id(0, 0)
        member.two_swords_change = false
      end  
      member.clear_sprite_effects
    end
  end
  #--------------------------------------------------------------------------
  # ● 戦闘開始の処理
  #--------------------------------------------------------------------------
  alias process_battle_start_n02 process_battle_start
  def process_battle_start
    @end_member = 0
    preemptive if $game_troop.preemptive
    surprise if $game_troop.surprise
    @status_window.visible = true
    process_battle_start_n02
    @status_window.refresh
    $gauge_stop = false
  end
  #--------------------------------------------------------------------------
  # ● 先制処理
  #--------------------------------------------------------------------------
  def preemptive
    $game_troop.preemptive = false
    for member in $game_party.members + $game_troop.members
      member.at_count = 1000 if member.actor?
      member.at_count = N02::ATB_BACKATTACK * -10 if !member.actor?
    end  
  end
  #--------------------------------------------------------------------------
  # ● 不意打ち処理
  #--------------------------------------------------------------------------
  def surprise
    $game_troop.surprise = false
    for member in $game_party.members + $game_troop.members
      member.at_count = N02::ATB_BACKATTACK * -10 if member.actor?
      member.at_count = 1000 if !member.actor?
    end
  end
  #--------------------------------------------------------------------------
  # ● 情報表示ビューポートの解放
  #--------------------------------------------------------------------------
  alias dispose_info_viewport_n02 dispose_info_viewport
  def dispose_info_viewport
    dispose_info_viewport_n02
    @cursor.dispose if @cursor != nil && !@cursor.disposed?
    @help_window.dispose if @help_window != nil && !@help_window.disposed?
    @help_windowbg.dispose if @help_window != nil && !@help_window.disposed?
    @help_window = nil
    @help_window2.dispose if @help_window2 != nil && !@help_window2.disposed?
    @help_windowbg.dispose if @help_window2 != nil && !@help_window2.disposed?
    @help_window2 = nil
    @skill_window.dispose if @skill_window != nil && !@skill_window.disposed?
    @skill_windowbg.dispose if @skill_window != nil && !@skill_window.disposed?###
    @skill_window = nil
    @item_window.dispose if @item_window != nil && !@item_window.disposed?
    @item_windowbg.dispose if @item_window != nil && !@item_window.disposed?###
    @item_window = nil # 1.1b
    
    # 釋放新加入的圖像資源
  if @face_sprite
    @face_sprite.bitmap.dispose if @face_sprite.bitmap
    @face_sprite.dispose
    @face_sprite = nil
  end

  if @char_sprite
    @char_sprite.bitmap.dispose if @char_sprite.bitmap
    @char_sprite.dispose
    @char_sprite = nil
  end
  
  dispose_text_command_sprites###
    
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新  ※再定義
  #--------------------------------------------------------------------------
  def update
    super
    update_basic(true)
    do_party_escape if @escape && $game_party.inputable? unless @judge
    unless $game_message.visible                # メッセージ表示中以外
      return if judge_win_loss if @judge == nil # 勝敗判定
      update_scene_change
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_basic(main = false)
    Graphics.update unless main                 # ゲーム画面を更新
    Input.update unless main                    # 入力情報を更新
    $game_system.update                         # タイマーを更新
    $game_troop.update                          # 敵グループを更新
    @spriteset.update                           # スプライトセットを更新
    @message_window.update                      # メッセージウィンドウを更新
    update_info_viewport if !$gauge_stop        # 情報表示ビューポートを更新
    # カーソル更新
    @cursor.update if @cursor != nil && @cursor.visible
    # メッセージ表示中はこれ以降処理させない
    if $game_message.visible
      @spriteset.gauge_off
      @info_viewport.visible = false
      return @message_window.visible = true
    end
    return if $gauge_stop
    # 戦闘中断、シーン切り替えの際これ以降は処理させない
    return if @judge
    return if $game_temp.next_scene != nil
    # ATBを更新
    process_battle_event if $game_temp.common_event_id > 0
    update_atb
    # ターゲット更新
    update_target if @target_members != nil
    # コマンド入力フェイズ
    start_actor_command_selection if @command_members.size != 0 && !@command_phase
    if @skill_window != nil
      update_skill_selection                    # スキル選択
    elsif @item_window != nil
      update_item_selection                     # アイテム選択
    elsif @party_command_window.visible && @party_command_window.active
      update_party_command_selection            # パーティコマンド選択
    elsif @actor_command_window.active
      update_actor_command_selection            # アクターコマンド選択
    end
  end
  #--------------------------------------------------------------------------
  # 若存在強制行動戰鬥者，優先讓其進入行動。
  # 若有 ATB 已就緒的戰鬥者，讓其進入行動。
  #--------------------------------------------------------------------------
  def update_atb
    prepare_forcing_atb
    if !@forcing_battlers.empty?
      if @active_battler == nil
        set_next_active_battler
        return
      end
    end # Mithran Force Action Fix 1.1e 結束。
    for member in $game_party.members + $game_troop.members
      # ACT更新
#       return start_main(member) if member.act_active && !@action_battlers.include?(member) && !member.union_battler && !member.action.forcing
      # 3.4a
      return set_next_action_battlers(member) if member.act_active && !@action_battlers.include?(member) && !member.union_battler && !member.action.forcing
      # ATBアクター更新
      if member.actor? && member.at_active && !@command_members.include?(member) && member.movable? && !member.action.forcing
        return start_auto_action(member) if member.auto_action?
        return @command_members.push(member)
      # ATBエネミー更新
      elsif !member.actor? && member.at_active && !@command_members.include?(member) && member.movable?
        return start_auto_action(member) unless member.action.forcing
      end
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def set_next_action_battlers(member)
    return if @judge 
    @message_window.clear
    @action_battlers.push(member)
    @status_window.refresh
    member.charge_start = false
    # アクティブバトラーがいなければ次の行動者をセット
    set_next_active_battler if @active_battler == nil
  end
  #--------------------------------------------------------------------------
  # ● 自動行動開始 
  #--------------------------------------------------------------------------
  def start_auto_action(member)
    return if @judge
    # 戦闘行動の作成
    member.make_action if member.union_skill_id == 0
    # チャージ設定
    act_type = charge_set(member)
    # 複数回行動の作成
    member.act_time = member.action_time[0] if !member.actor? 
    # 行動ゲージに切り替え
    @spriteset.change_act(act_type, member.actor?, member.index)
    # チャージアクション
    make_charge_action(member)
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def charge_set(member)
    act_type = member.charge
    # 通常攻撃(二刀のチャージ時間は双方武器の平均)
    if member.actor? && member.action.attack? && member.weapon_id != 0
      act_type = member.weapons[0].charge if member.weapons[0] != nil
      act_type2 = member.weapons[1].charge if member.weapons[1] != nil
      act_type[1] = (act_type[1] + act_type2[1]) / 2 if act_type2 != nil
    elsif member.action.attack?
      act_type = $data_weapons[member.weapon_id].charge if member.actor? && member.weapon_id != 0
      act_type = $data_weapons[member.weapon].charge if !member.actor? && member.weapon != 0
    end
    act_type = $data_skills[member.action.skill_id].charge if member.action.skill?
    act_type = $data_items[member.action.item_id].charge if member.action.item?
    # チャージボーナス加算
    if member.actor?
      act_type[1] += $data_weapons[member.weapon_id].charge_bonus if member.weapon_id != 0
      for i in 0...member.armors.size
        act_type[1] += member.armors[i].charge_bonus if member.armors[i] != nil
      end
    end
    # 1.2c
    for i in 0...member.states.size
      act_type[1] += member.states[i].charge_bonus if member.states[i] != nil
    end
    return act_type
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動者の準備  ※再定義 Original
  #--------------------------------------------------------------------------
#  def start_main(member)
#    return if @judge 
    # アクティブバトラーがいなければ次の行動者をセット
#  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def start_main
    # 3.4a
    # set_next_action_battlers(member). This gets rid of the new argument
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウインドウの表示  ※再定義
  #--------------------------------------------------------------------------
  def pop_help(obj)
    return if @help_window == nil && obj.extension.include?("HELPHIDE")
    return @help_window.visible = false if obj.extension.include?("HELPHIDE")
    return if @skill_window != nil && @skill_window.visible
    return if @item_window != nil && @item_window.visible
    @help_window = Window_Help.new if @help_window == nil
    @help_window.set_text(obj.name, 1)
    @help_window.visible = true
    @help_windowbg.visible = true    
  end
  #--------------------------------------------------------------------------
  # ● チャージアクション作成
  #--------------------------------------------------------------------------
  def make_charge_action(member)
    action = ""
    case member.action.kind
    when 0
      if member.actor?
        action = member.charge[3] if member.weapon_id == 0
        action = $data_weapons[member.weapon_id].charge[3] if member.weapon_id != 0
      else
        action = member.charge[3] if member.weapon == 0
        action = $data_weapons[member.weapon].charge[3] if member.weapon != 0
      end
    when 1;action = member.action.skill.charge[3]
    when 2;action = member.action.item.charge[3]
    end
    member.charge_action = action
    return if action == ""
    member.charge_start = true
    @spriteset.set_action(member.actor?, member.index, member.charge_action)
  end
  #--------------------------------------------------------------------------
  # ● アクション実行中  ※再定義
  #--------------------------------------------------------------------------
  def playing_action
    loop do
      break if @judge
      update_basic
      # アクティブバトラーに格納されているアクション情報を見る
      action = @active_battler.play
      next if action == 0
      @active_battler.play = 0
      if action[0] == "Individual"
        individual
      elsif action == "Can Collapse"
        unimmortaling
      elsif action == "Cancel Action"
        break action_end
      elsif action == "End"
        break action_end
      elsif action[0] == "OBJ_ANIM"
        damage_action(action[1])
      end 
    end  
  end
  #--------------------------------------------------------------------------
  # ● 戦闘アクション実行 
  #--------------------------------------------------------------------------
  def process_action
    
    # 合体攻撃処理
    union_possibility?
    process_union_skill if @active_battler.union_skill_id != 0
    return set_next_active_battler if @active_battler.union_battler
    # 暴走混乱処理
    @active_battler.action.prepare unless @active_battler.action.forcing
    # 戦闘行動開始
    $in_action = true
    @message_window.clear
    @active_battler.white_flash = true
    
    # ヘルプウインドウ表示
    help_on
    # 戦闘アクション実行
    execute_action if @active_battler.action.valid? && @active_battler.restriction < 4
    # ヘルプウインドウ隠蔽
    help_off
    # 強制行動などでバトラーが空になったら次の行動者へ
    return set_next_active_battler if @active_battler == nil
    hp_slip_damage(@active_battler) if N02::ATB_SLIP_DAMAGE == 0 
    mp_slip_damage(@active_battler) if N02::ATB_SLIP_DAMAGE == 0
    # 戦闘アクション終了
    @message_window.clear
    @active_battler.white_flash = false
    $in_action = false
    @spriteset.gauge_update
    # 合体攻撃終了処理
    end_union_skill if @active_battler.union_skill_id != 0
    # スキル派生がある場合、行動続行 
#    return set_next_active_battler if @active_battler.derivation != 0 && !@forcing_battler # Derivation 修正 1.1e。
    # エネミーの複数回行動
    return set_next_active_battler if enemy_order
    # 戦闘行動終了
    turn_end(@active_battler)
    # 次の行動者へ
    @action_battlers.delete(@active_battler)
    set_next_active_battler
  end 
  #--------------------------------------------------------------------------
  # ● ヘルプウインドウ表示 
  #--------------------------------------------------------------------------
  def help_on
    
    @help_window = Window_Help.new if @help_window == nil
    @help_window.visible = false
    
    @help_windowbg.visible = false
    return @help_window.visible = @help_windowbg.visible = true if @skill_window != nil && @skill_window.visible
    return @help_window.visible = @help_windowbg.visible = true if @item_window != nil && @item_window.visible
    return @help_window.visible = @help_windowbg.visible = true if @active_battler.action.guard?
    return @help_window.visible = @help_windowbg.visible = true if @active_battler.action.kind == 0 && @active_battler.action.basic == 2
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウインドウ隠蔽
  #--------------------------------------------------------------------------
  def help_off
   
    return if @help_window == nil
    return @help_window.visible = @help_windowbg.visible = true if @skill_window != nil && @skill_window.visible
    return @help_window.visible = @help_windowbg.visible = true if @item_window != nil && @item_window.visible
    @help_window.visible = false
    @help_windowbg.visible = false
        
  end
  #--------------------------------------------------------------------------
  # ● アクション終了  ※再定義
  #--------------------------------------------------------------------------
  def action_end
    # 初期化
    
    @individual_target = nil
    @active_battler.active = false
    @active_battler.clear_action_results
    # 念のため不死身化解除
    unimmortaling
    # 反射されていた場合
    if @active_battler.reflex != nil
      if @active_battler.action.skill?
        obj = @active_battler.action.skill
        @active_battler.perfect_skill_effect(@active_battler, obj)
      elsif @active_battler.action.item?
        obj = @active_battler.action.item
        @active_battler.item_effect(@active_battler, obj)
      else
        @active_battler.perfect_attack_effect(@active_battler)
      end
      pop_damage(@active_battler, obj, @active_battler.reflex)
      @active_battler.perform_collapse
      @active_battler.reflex = nil
      wait(N01::COLLAPSE_WAIT)
    end
    # 逆吸収で戦闘不能になった場合
    if @absorb_dead
      @active_battler.perform_collapse
      @absorb_dead = false
      wait(N01::COLLAPSE_WAIT)
    end
    # 次の行動までウエイトを挟む
    wait(N01::ACTION_WAIT)
  end  
  #--------------------------------------------------------------------------
  # ● 合体攻撃判定
  #--------------------------------------------------------------------------
  def union_skill?(member)
    # スキルに合体攻撃設定があるかチェック
    for union_action in member.action.skill.union_action
      union_skills = union_action if union_action.size != 0 && union_action.include?(member.action.skill_id)
    end
    return if union_skills == nil
    @partners = []
    @union_targets = union_target_decision(member, member.action.skill)
    @union_target_index = member.action.target_index
    # 合体攻撃メンバーが使用可能かチェック
    for skill_id in union_skills
      for actor in $game_party.members
        if actor.skill_can_use?($data_skills[skill_id]) && actor.skill_id_learn?(skill_id)
          @partners.push(actor)
          actor.union_skill_id = skill_id
        end
      end
    end
    # 合体攻撃使用不可
    if @partners.size != union_skills.size
      for actor in @partners do actor.union_skill_id = 0 end
      @partners = nil
      member.action.clear if !member.action.guard?
      return 
    end
    # 合体攻撃使用可
    for actor in @partners
      # パートナーアクション決定
      actor.action.kind = 1
      actor.action.skill_id = actor.union_skill_id
      actor.action.target_index = member.action.target_index
      # コマンド強制キャンセル
      if @command_members.include?(actor)
        force_action_command_cansel(actor) 
        start_auto_action(member)
      end
    end
    $in_union_action = true
    @union_size = 0
  end  
  #--------------------------------------------------------------------------
  # ● 合体攻撃可能か
  #--------------------------------------------------------------------------
  def union_possibility?
    return if @partners == nil
    for member in @partners
      union_cansel = true unless member.inputable?
    end
    return if !union_cansel
    end_union_skill
    @active_battler.action.clear if !@active_battler.action.guard?
  end
  #--------------------------------------------------------------------------
  # ● 合体攻撃ターゲット決定
  #--------------------------------------------------------------------------
  def union_target_decision(member, obj)
    targets = member.action.make_targets
    # デフォルトの複数回攻撃が設定されていれば単体ターゲットに変換
    targets = [targets[0]] if obj.for_two? or obj.for_three? or obj.dual?
    # ランダムターゲットの場合、一体を選択しランダム範囲を保持
    if obj.extension.include?("RANDOMTARGET")
      randum_targets = targets.dup
      targets = [randum_targets[rand(randum_targets.size)]]
    end
    # ターゲット情報をバトラースプライトに送る
    @spriteset.set_target(member.actor?, member.index, targets)
    return targets
  end   
  #--------------------------------------------------------------------------
  # ● 合体攻撃処理
  #--------------------------------------------------------------------------
  def process_union_skill
    @union_size += 1
    if @union_size != @partners.size
      return @active_battler.union_battler = true
    end
    # 合体攻撃スタート
    @action_battlers.delete(@active_battler)
    @active_battler.active = false
    @active_battler = @partners.shift
    @active_battler.act_active = true
    @active_battler.active = true
    @active_battler.union_battler = false
    @active_battler.action.kind = 1
    @active_battler.action.skill_id = @active_battler.union_skill_id
    @active_battler.action.target_index = @union_target_index
    for member in @partners
      member.action.kind = 1
      member.action.skill_id = member.union_skill_id
      member.action.target_index = @union_target_index
      member.mp -= member.calc_mp_cost($data_skills[member.action.skill_id]) if member != @active_battler # 3.4a
      member.force_target = ["N01target_change", @union_targets]
      @spriteset.update_target(true, member.index)
      # アクション実行
      @spriteset.set_action(true, member.index, member.action.skill.base_action)
    end
    @status_window.refresh # 3.4a
  end  
  #--------------------------------------------------------------------------
  # ● 合体攻撃終了処理 
  #--------------------------------------------------------------------------
  def end_union_skill
    @active_battler.union_skill_id = 0
    @active_battler.union_battler = false
    for member in @partners
      member.union_skill_id = 0
      member.union_battler = false
      member.action.clear
      @action_battlers.delete(member)
      turn_end(member)
    end
    @union_size = 0
    @partners = nil
    $in_union_action = false
  end
  #--------------------------------------------------------------------------
  # ● エネミーの行動回数作成 
  #--------------------------------------------------------------------------
  def enemy_order
    return false if @active_battler.actor?
    return false if @active_battler.act_time == 0 or !@active_battler.action.valid? 
    return true if rand(100) < @active_battler.action_time[1]
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def turn_end(member)
    member = @active_battler
    forced = member.action.forcing
    member.action.forcing = false
    t_index = member.action.target_index
    $in_action = false
    # アクション終了時のATBゲージ設定
    if !forced || (N02::FORCE_ACTION_CONSUME_GAUGE && forced)
      recharge_action(member)
    elsif member.act_active && !N02::FORCE_ACTION_CONSUME_GAUGE
      @spriteset.gauge_refill(member.actor?, member.index)
    end
    member.action.clear if !member.action.guard?
    member.action.target_index = t_index
    process_battle_event
    # ターン経過カウント
    @end_member += 1 if !forced || (N02::FORCE_ACTION_INCREASE_TURN && forced)
    passage = true if N02::ATB_TURN_COUNT == 2
    if @end_member >= $game_party.members.size + $game_troop.members.size
      passage = true if N02::ATB_TURN_COUNT == 0
      passage = true if N02::ATB_TURN_COUNT == 1 && @end_member == 2
    elsif @end_member == ($game_party.members.size + $game_troop.members.size) / 2
      passage = true if N02::ATB_TURN_COUNT == 1
    end
    # スリップダメージ
    if @slip_all_damage
      for battlers in $game_party.members + $game_troop.members do mp_slip_damage(battlers) end
      @slip_all_damage = false
      @slip_all_damaged = true
    end
    return if !passage
    # スリップダメージ
    if N02::ATB_SLIP_DAMAGE == 1 && !@slip_all_damaged
      for battlers in $game_party.members + $game_troop.members do hp_slip_damage(battlers) end
      @slip_all_damage = true
    end
    @slip_all_damaged = false
    @end_member = 0
    $game_troop.increase_turn
    $game_troop.turn_ending = true
    process_battle_event
    $game_troop.turn_ending = false
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● アクション終了時のATBゲージ設定 
  #--------------------------------------------------------------------------
  def recharge_action(member)
    member.act_count = 0
    recharge = member.recharge
    # 通常攻撃(二刀のチャージ時間は双方武器の平均)
    if member.actor? && member.action.attack?
      recharge = member.weapons[0].recharge if member.weapons[0] != nil
      recharge2 = member.weapons[1].recharge if member.weapons[1] != nil
      recharge = (recharge + recharge2) / 2 if recharge2 != nil
    elsif member.action.attack? 
      act_type = $data_weapons[member.weapon].charge if member.weapon != 0
    end
    recharge = $data_skills[member.action.skill_id].recharge if member.action.skill?
    recharge = $data_items[member.action.item_id].recharge if member.action.item?
    recharge = N02::ATB_GUARD_RESET if member.action.guard?
    # ATBゲージに切り替え
    @spriteset.change_atb(10 * recharge, member.actor?, member.index)
    @spriteset.gauge_refresh(member.actor?, member.index)
  end    
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def set_next_active_battler
    @forcing_battlers ||= []
    return if $game_party.all_dead? or $game_troop.all_dead?
    do_party_escape if @escape && $game_party.inputable? unless @judge
    # 全員の不死身化解除(イベント等で不死身設定がされていれば除く)
    prepare_forcing_atb    
    # エネミー複数回行動時
    @action_battlers.shift if @active_battler != nil && !@active_battler.actor? && @active_battler.act_time != 0
    loop do
      if !@forcing_battlers.empty?
        potential = @forcing_battlers.shift
        if potential.action.valid?
          @action_battlers.delete(potential)
          force_action_cleanup(potential)
          @active_battler = potential
        else
          potential.action.clear
        end
      else
        @active_battler = @action_battlers.shift
      end
      @active_battler.action.clear if @active_battler != nil && @active_battler.dead?
      return if @active_battler == nil
      # 戦闘行動開始
      return process_action if @active_battler.index != nil
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def process_battle_event
    @forcing_battlers ||= []
    members_size = $game_party.members.size
    loop do
      return if judge_win_loss
      return if $game_temp.next_scene != nil
      $game_troop.interpreter.update
      $game_troop.setup_battle_event
      @message_window.update
      if $game_message.visible
        @message_window.visible = true
        @status_window.visible = false
      end
      wait_for_message
      @message_window.visible = false
      @status_window.visible = true
      reset_atb_actor if members_size != $game_party.members.size
      prepare_forcing_atb
      return unless $game_troop.interpreter.running?
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def prepare_forcing_atb
    @forcing_battlers ||= []
    if $game_troop.forcing_battler != nil
      member = $game_troop.forcing_battler
      $game_troop.forcing_battler = nil
      force_action_cleanup(member)
      @action_battlers.delete(member)
      @forcing_battlers.delete(member)
      @forcing_battlers.push(member)
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def force_action_cleanup(member)
    return if member.nil?
    if @commander == member
      @message_window.visible = false
      @party_command_window.active = false
      @party_command_window.visible = false
      $in_command = $in_select = $in_target = $in_party_command = false
      @target_members = nil
      @actor_command_window.active = false
      @cursor.visible = false unless $game_party.all_dead? or $game_troop.all_dead?
      @command_phase = false
      target_select_cleanup
      end_skill_selection
      end_item_selection
      @party_command_window.active = @actor_command_window.active = false
      @actor_command_window_on = false
      @status_window.index = @actor_index = @actor_command_window.index = -1
      @command_members.delete(@commander)
      @commander = nil
      @actor_command_window.active = false
      @command_members.delete(member)
      @commander = nil
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def target_select_cleanup
    $in_target = false
    @help_window2.dispose if @help_window2 != nil
    @help_window2 = nil
    @help_window.visible = false if @help_window != nil
    @target_members = nil
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias battle_end_forcefix battle_end
  def battle_end(result)
    @forcing_battlers = []
    battle_end_forcefix(result)
  end
  #--------------------------------------------------------------------------
  # ● 全員の不死身化解除 
  #--------------------------------------------------------------------------
  def member_unimmortaling
    for member in $game_party.members + $game_troop.members
      next if member.non_dead
      next if member.dead?
      member.set_temp_immortal(false)
    end
  end
  #--------------------------------------------------------------------------
  # ● HPスリップダメージ
  #--------------------------------------------------------------------------
  def hp_slip_damage(member)
    member.clear_action_results
    return if !member.exist?
    member.slip_damage = false
    damage = 0
    # 0ターン解除のステートがあるかチェック
    for state in member.states
      member.remove_state(state.id) if state.extension.include?("ZEROTURNLIFT")
      # スリップダメージ実行　state = [ 対象, 定数, 割合, POP, 戦闘不能許可]
      next unless state.slip_damage #state.extension.include?("SLIPDAMAGE")
      for ext in state.slip_extension
        if ext[0] == "hp"
          base_damage = ext[1] + member.maxhp * ext[2] / 100
          damage += base_damage + base_damage * (rand(5) - rand(5)) / 100
          slip_pop = ext[3] unless ext[3] == nil # 3.4a
          slip_dead = ext[4] unless ext[4] == nil # 3.4a
          slip_damage_flug = true
          member.slip_damage = true
        end
      end  
    end
    # デフォルトのスリップダメージ
#    if member.slip_damage? && member.exist? && !slip_damage_flug
#    end
    # 防具の自動回復があるか
    if member.actor? && member.auto_hp_recover && member.exist?
      damage -= member.maxhp / 20
      slip_pop = true
    end  
    # 戦闘不能不許可
    damage = member.hp - 1 if damage >= member.hp && slip_dead = false
    member.hp -= damage
    @spriteset.set_damage_pop(member.actor?, member.index, damage) if slip_pop
    member.perform_collapse if member.dead? && member.slip_damage
    member.clear_action_results
    @status_window.refresh
  end 
  #--------------------------------------------------------------------------
  # ● MPスリップダメージ
  #--------------------------------------------------------------------------
  def mp_slip_damage(member)
    member.clear_action_results
    return if !member.exist? or member.states.size == 0
    member.slip_damage = false
    mp_damage = 0
    for state in member.states
      next unless state.slip_damage #state.extension.include?("SLIPDAMAGE")
      for ext in state.slip_extension
        if ext[0] == "mp"
          base_damage = ext[1] + member.maxmp * ext[2] / 100
          mp_damage += base_damage + base_damage * (rand(5) - rand(5)) / 100
          slip_pop = ext[2]
          slip_damage_flug = true
        end
      end
    end  
    member.mp_damage = mp_damage
    member.mp -= mp_damage
    @spriteset.set_damage_pop(member.actor?, member.index, mp_damage) if slip_pop
    member.clear_action_results
    @status_window.refresh
  end  
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行 : 防御  ※再定義
  #--------------------------------------------------------------------------
  def execute_action_guard
    @help_window.set_text(N01::GUARD_HELP_TEXT, 1)#1
    @help_window.visible = true#2
    # バトラーのアクティブ化を解除
    @active_battler.force_damage -= @active_battler.maxhp / 10
    @active_battler.active = false
    wait(45)
    @help_window.visible = false if @help_window != nil#3
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行 : 逃走  ※再定義
  #--------------------------------------------------------------------------
  def execute_action_escape
    @spriteset.set_action(false, @active_battler.index, @active_battler.run_success)
    @help_window.set_text(N01::ESCAPED_HELP_TEXT, 1)
    @help_window.visible = true
    # バトラーのアクティブ化を解除
    @active_battler.active = false
    @active_battler.escape
    Sound.play_escape
    wait(45)
    @help_window.visible = false if @help_window != nil
  end
  #--------------------------------------------------------------------------
  # ● パーティコマンド選択の開始  ※再定義
  #--------------------------------------------------------------------------
  def start_party_command_selection    
    @info_viewport.visible = true
    @status_window.index = @actor_index = -1
  end
  #--------------------------------------------------------------------------
  # ● 次のアクターのコマンド入力へ  ※再定義
  #--------------------------------------------------------------------------
  def next_actor
  end
  #--------------------------------------------------------------------------
  # ● 前のアクターのコマンド入力へ  ※再定義
  #--------------------------------------------------------------------------
  def prior_actor
  end
  #--------------------------------------------------------------------------
  # ● アクターコマンド選択の開始  ※再定義
  #--------------------------------------------------------------------------
  def start_actor_command_selection   
    $in_command = true
    ############################################
    @friend_window.dispose if @friend_window != nil
    ############################################
    @command_phase = true
    @command_member_index = 0
    @commander = @command_members[@command_member_index]
    @status_window.active = true
    @status_window.index = @commander.index
    # カーソルセット
    @cursor = Sprite_Cursor.new if @cursor == nil
    @cursor.set(@commander)
    # 動けるキャラのみコマンドアクションを
    @spriteset.set_action(true, @commander.index,@commander.command_b) if @commander.inputable?
    @party_command_window.active = false
    @actor_command_window.setup(@commander)
    @actor_command_window.active = true
    @actor_command_window.index = 0
    @actor_command_window_on = true
    
    @status_window.refresh
  end
  #--------------------------------------------------------------------------
  # ● コマンド更新  ※再定義
  #--------------------------------------------------------------------------
  def update_actor_command_selection
    # コマンド入力できる状態でなくなればキャンセル
    return reset_command unless commanding?
    if Input.trigger?(Input::B)
      Input.update
      Sound.play_decision
      start_party_command
      
    elsif Input.trigger?(Input::C)
      Input.update
      case @actor_command_window.index
      when 0
        if @commander.class_id = 91..93
          if @commander.mp = 0
            Sound.play_buzzer
          else
          Sound.play_decision
          @commander.action.set_attack
          start_target_enemy_selection
          end
        else
        Sound.play_decision
        @commander.action.set_attack
        start_target_enemy_selection
        end
      when 1  # スキル  
        Sound.play_decision
        $in_select = true
        start_skill_selection
      when 2  # 防御
        Sound.play_decision
        @commander.action.set_guard
        end_command
      when 3  # アイテム
        Sound.play_decision
        $in_select = true
        start_item_selection
      end
    # →キーでコマンドキャラ送り
    elsif Input.trigger?(Input::RIGHT)
      next_commander
    # ←キーでコマンドキャラ戻し
    elsif Input.trigger?(Input::LEFT)
      back_commander
    end
  end
  #--------------------------------------------------------------------------
  # ● コマンド入力できる状態か
  #--------------------------------------------------------------------------
  def commanding?
    return false if @judge or $gauge_stop
    return false if @commander != nil && !@commander.inputable?
    return false if @commander != nil && @commander.union_skill_id != 0
    return false if @commander != nil && @commander.at_count < 1000
    return true
  end
  #--------------------------------------------------------------------------
  # ● コマンドキャラ送り
  #--------------------------------------------------------------------------
  def next_commander
    return if @command_members.size == 1 or @commander == nil
    Audio.se_play("Audio/SE/" + N02::NEXT_SOUND01[2], N02::NEXT_SOUND01[1],  N02::NEXT_SOUND01[0])
    # 動けるキャラのみコマンド戻りアクションを
    @spriteset.set_action(true, @commander.index,@commander.command_a) if @commander.inputable?
    # コマンド待ちメンバーのインデックスが最後なら
    if @command_member_index == @command_members.size - 1
      @command_member_index = 0
    # 次のキャラにコマンドを送る
    else
      @command_member_index += 1
    end
    @commander = @command_members[@command_member_index]
    @status_window.index = @commander.index
    @actor_command_window.setup(@commander) # 1.1c
    # カーソルセット
    @cursor.set(@commander)
    # 動けるキャラのみコマンドアクションを
    @spriteset.set_action(true, @commander.index,@commander.command_b) if @commander.inputable?
  end  
  #--------------------------------------------------------------------------
  # ● コマンドキャラ戻し
  #--------------------------------------------------------------------------
  def back_commander
    return if @command_members.size == 1 or @commander == nil
    Audio.se_play("Audio/SE/" + N02::NEXT_SOUND01[2], N02::NEXT_SOUND01[1],  N02::NEXT_SOUND01[0])
    # 動けるキャラのみコマンド戻りアクションを
    @spriteset.set_action(true, @commander.index,@commander.command_a) if @commander.inputable?
    # コマンド待ちメンバーのインデックスが最初なら
    if @command_member_index == 0
      @command_member_index = @command_members.size - 1
    # 前のキャラにコマンドを送る
    else
      @command_member_index -= 1
    end
    @commander = @command_members[@command_member_index]
    @status_window.index = @commander.index
    # カーソルセット
    @cursor.set(@commander)
    # 動けるキャラのみコマンドアクションを
    @spriteset.set_action(true, @commander.index,@commander.command_b) if @commander.inputable?
  end  
  #--------------------------------------------------------------------------
  # ● パーティコマンド選択の開始
  #--------------------------------------------------------------------------
  def start_party_command    
    $in_party_command = true
    $in_command = false
    @status_window.refresh
    @status_window.index = @actor_index = -1
    @info_viewport.visible = true
    @message_window.visible = false
    @pre_a_index = @actor_command_window.index
    @actor_command_window.active = false
    @actor_command_window.index = -1
    @party_command_window.active = true
    @party_command_window.index = 0
    @party_command_window.visible = true 
  end
  #--------------------------------------------------------------------------
  # ● パーティコマンド選択の更新
  #--------------------------------------------------------------------------
  def update_party_command_selection
    # コマンド入力できる状態でなくなればキャンセル
    return reset_command unless commanding?
    if Input.trigger?(Input::C)
      case @party_command_window.index
      when 0  # 戦う
        Sound.play_decision
        @status_window.index = @actor_index = -1
        end_party_command
      when 1  # 逃げる
        return Sound.play_buzzer if $game_troop.can_escape == false
        Sound.play_decision
        end_party_command
        process_escape if !@escape
      when 2
        Sound.play_decision        
        $scene = Scene_Party.new(1,2)
        end_party_command
      end
    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      end_party_command
    end
  end
  #--------------------------------------------------------------------------
  # ● パーティコマンド選択の終了
  #--------------------------------------------------------------------------
  def end_party_command
    $in_party_command = false
    $in_command = true
    @status_window.refresh
    @message_window.visible = false
    @party_command_window.active = false
    @actor_command_window.active = true
    @party_command_window.visible = false
    @actor_command_window.index = @pre_a_index
    @status_window.index = @commander.index
    @status_window.active = true
  end
  #--------------------------------------------------------------------------
  # ● 逃走の処理  ※再定義
  #--------------------------------------------------------------------------
  def process_escape
    @escape = true
    #$game_switches[50] = false
    closed_window
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def do_party_escape
    reset_atb_actor
    if $game_troop.preemptive
      success = true
    else
      success = (rand(100) < @escape_ratio)
    end
    for actor in $game_party.members
      if !actor.non_dead 
        actor.set_temp_immortal(false)
        if actor.hp == 0 and not actor.state?(1)
          actor.add_state(1)
          actor.added_states.push(1)
        end
      end
    end
    if $game_party.all_dead? # 若全員死亡，以敗北結束戰鬥。
      @escape = false
      @judge = true
      process_defeat
      battle_end(2)
      return true
    end
    for actor in $game_party.members
      unless actor.restriction >= 4
        @spriteset.set_action(true, actor.index, success ? actor.run_success : actor.run_ng )
      end
    end
    @info_viewport.visible = false
    @message_window.visible = true
    text = sprintf(Vocab::EscapeStart, $game_party.name)
    $game_message.texts.push(text)
    Sound.play_escape
    if !success
      $game_message.texts.push('\.' + Vocab::EscapeFailure)
    end
    wait_for_message
    if success
      @judge = true
      battle_end(1) # 以逃跑結束戰鬥。
#      $game_switches[36] = true
      $game_switches[50] = false
    @friend_window.dispose if @friend_window != nil#逃跑
    @bitmap_name.dispose if @bitmap_name
      return true
    else
      @escape_ratio += 10
      $game_party.clear_actions
      @info_viewport.visible = true
      @escape = false
      for member in $game_party.members
        member.clear_sprite_effects
      end
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ● アクターのATBを初期化
  #--------------------------------------------------------------------------
  def reset_atb_actor
    @command_members = []
    @commander = nil
    $in_action = @command_phase = false
    $in_command = $in_target = $in_select = false
    @message_window.clear
    for member in $game_party.members
      @action_battlers.delete(member)
      member.white_flash = false
      member.action.clear
      # ATBゲージに切り替え
      @spriteset.change_atb(N02::ATB_RUN_NG * -10, member.actor?, member.index)
    end
  end 
  #--------------------------------------------------------------------------
  # ● 開いているウインドウを閉じる
  #--------------------------------------------------------------------------
  def closed_window
    @cursor.dispose if @cursor != nil
    @cursor = nil
    @help_window.dispose if @help_window != nil
    @help_window = nil
    @help_window2.dispose if @help_window2 != nil
    @help_window2 = nil
    @skill_window.dispose if @skill_window != nil
    @skill_windowbg.dispose if @skill_window != nil
    @skill_window = nil
    @item_window.dispose if @item_window != nil
    @item_windowbg.dispose if @item_window != nil
    @item_window = nil
    @actor_command_window_on = false if @actor_command_window != nil
    @actor_command_window.active = false if @actor_command_window != nil
    @party_command_window.visible = false if @party_command_window != nil
    @party_command_window.active = false if @party_command_window != nil
    @status_window.index = @actor_index = @actor_command_window.index = -1
  end 
  #--------------------------------------------------------------------------
  # ● ターゲット選択の開始  ※再定義
  #--------------------------------------------------------------------------
  def start_target_selection(actor = false)
    @help_windowbg.visible = true if @help_windowbg != nil
    $in_target = true
    $in_command = $in_select = false
    @target_actors = actor
    @target_members = $game_party.members if @target_actors
    @target_members = $game_troop.members unless @target_actors
    # 不要なウインドウを消す
    @actor_command_window.active = false
    @skill_window.visible = false if @skill_window != nil
    @item_window.visible = false if @item_window != nil    
    @skill_windowbg.visible = false if @skill_window != nil
    @item_windowbg.visible = false if @item_window != nil
    # 存在しているターゲットで最も番号の低い対象を最初に指すように
    @index = 0
    @max_index = @target_members.size - 1
    # アクターは戦闘不能者でもターゲットできるようにエネミーと区別
    unless @target_actors
      @target_members.size.times do
        break if @target_members[@index].exist?
        @index += 1
      end
    end  
    # カーソルセット
    @cursor.set(@target_members[@index])
    @help_window.visible = false if @help_window != nil
    @help_window2 = Window_Help.new if @help_window2 == nil
    @help_window2.set_text_n01add(@target_members[@index])
  end
  #--------------------------------------------------------------------------
  # ● ターゲット選択更新  ※再定義
  #--------------------------------------------------------------------------
  def update_target#敵データ表示機能v2.0重新定義了
    # コマンド入力できる状態でなくなればキャンセル
    return reset_command unless commanding?
    return end_target_selection(cansel = true) if $game_troop.all_dead?
    cursor_down if !@target_members[@index].actor? && !@target_members[@index].exist?
    if Input.trigger?(Input::B)
      Input.update
      Sound.play_cancel
      end_target_selection(cansel = true)
    elsif Input.trigger?(Input::C)
      Input.update
      Sound.play_decision
      @commander.action.target_index = @index
      end_target_selection
      end_skill_selection
      end_item_selection
      @actor_command_window.active = false
      next_actor
    end
    if Input.repeat?(Input::LEFT)
      if @target_actors
        cursor_down if $back_attack
        cursor_up unless $back_attack
      else
        cursor_up if $back_attack
        cursor_down unless $back_attack
      end  
    end
    if Input.repeat?(Input::RIGHT)
      if @target_actors
        cursor_up if $back_attack
        cursor_down unless $back_attack
      else
        cursor_down if $back_attack
        cursor_up unless $back_attack
      end 
    end
    cursor_up if Input.repeat?(Input::UP)
    cursor_down if Input.repeat?(Input::DOWN)
  end
  #--------------------------------------------------------------------------
  # ● カーソルを前に移動  ※再定義
  #--------------------------------------------------------------------------
  def cursor_up
    Sound.play_cursor
    @target_members.size.times do
      @index += @target_members.size - 1
      @index %= @target_members.size
      break if @target_actors
      break if @target_members[@index].exist?
    end
    # カーソルセット
    # 確保 @index 不超出有效範圍
  @index = 0 if @index >= @target_members.size
    @cursor.set(@target_members[@index])
    @help_window2.set_text_n01add(@target_members[@index]) if @help_window2 != nil
  end
  #--------------------------------------------------------------------------
  # ● カーソルを次に移動  ※再定義
  #--------------------------------------------------------------------------
  def cursor_down
    Sound.play_cursor
    @target_members.size.times do
      @index += 1
      @index %= @target_members.size
      break if @target_actors
      break if @target_members[@index].exist?
    end
    # カーソルセット
    # 確保 @index 不超出有效範圍
  @index = 0 if @index >= @target_members.size
    @cursor.set(@target_members[@index])
    @help_window2.set_text_n01add(@target_members[@index]) if @help_window2 != nil
  end 
  #--------------------------------------------------------------------------
  # ● ターゲット選択の終了  再定義
  #--------------------------------------------------------------------------
  def end_target_selection(cansel = false)
    if @target_members == $game_troop.members && @enemy_element_window != nil
     unless @enemy_element_window.respond_to?(:disposed?) &&
         @enemy_element_window.disposed?
      @enemy_element_window.dispose
     end
     @enemy_element_window = nil
    end
    @spriteset.target_sprite_visible if @spriteset.respond_to?(:target_sprite_visible)###
    @help_windowbg.visible = false if @help_windowbg != nil
    $in_target = false
    if @help_window2 != nil  
      @help_window2.dispose
      @help_window2 = nil
    end 
    @help_window2.dispose if @help_window2 != nil
    @help_window2 = nil
    @help_window.visible = false if @help_window != nil
    @help_windowx.visible = false if @help_windowx != nil
    if @skill_window != nil
      @skill_windowbg.visible = true
      @skill_window.visible = @skill_window.active = true
      @help_windowx.visible = true if @help_windowx != nil
      @actor_command_window.active = false if cansel
      $in_select = true if cansel
    elsif @item_window != nil
      @item_windowbg.visible = true
      @item_window.visible = @item_window.active = true
      @help_window.visible = true if @help_window != nil
      @actor_command_window.active = false if cansel
      $in_select = true if cansel
    end
    @target_members = nil
    end_command if !cansel
    # カーソルセット
    @cursor.set(@commander) if cansel
    $in_command = true if cansel && @actor_command_window.index == 0
    @actor_command_window.active = true if cansel && @actor_command_window.index == 0
  end
  #--------------------------------------------------------------------------
  # ● コマンド初期化
  #--------------------------------------------------------------------------
  def reset_command
    @message_window.visible = false
    @party_command_window.active = false
    @commander.action.clear
    @party_command_window.visible = false
    $in_command = $in_select = $in_target = false
    @target_members = nil
    @actor_command_window.active = false
    @cursor.visible = false unless $game_party.all_dead? or $game_troop.all_dead?
    @command_phase = false
    end_skill_selection
    end_item_selection
    @party_command_window.active = @actor_command_window.active = false
    @actor_command_window_on = false
    @status_window.index = @actor_index = @actor_command_window.index = -1
    @command_members.delete(@commander)
    @commander = nil
  end  
  #--------------------------------------------------------------------------
  # ● 強制行動によるコマンドキャンセル
  #--------------------------------------------------------------------------
  def force_action_command_cansel(member)
    return if !member.inputable?
    end_target_selection if @commander == member # 1.1f
    return if member.nil?
    @pre_a_index ||= 0
    end_party_command if @commander == member
    # Force Action Fix 1.1e 結束。
    # チャージ設定
    act_type = charge_set(member)
    # 行動ゲージに切り替え
    @spriteset.change_act(act_type, member.actor?, member.index)
    # 動けるキャラのみコマンド戻りアクションを
    @spriteset.set_action(true, member.index,member.command_a) if member.actor? && member.inputable?
    # チャージアクション
    make_charge_action(member)
    # 以下の処理はコマンド入力中のアクター限定
    return if !member.actor? or @commander != member
    # カーソル消去
    @cursor.visible = false
    @command_phase = false
    # ウインドウ初期化
    end_skill_selection
    end_item_selection
    $in_target = false
    @help_window2.dispose if @help_window2 != nil
    @help_window2 = nil
    @help_window.visible = false if @help_window != nil
    @party_command_window.active = @actor_command_window.active = false
    @actor_command_window_on = false
    @status_window.index = @actor_index = @actor_command_window.index = -1
    @command_members.delete(member)
    @commander = nil
    @message_window.visible = false
    @party_command_window.active = false
    @party_command_window.visible = false
    $in_command = $in_select = $in_target = false
  end  
  #--------------------------------------------------------------------------
  # ● コマンド入力終了
  #--------------------------------------------------------------------------
  def end_command
    return if !@commander.inputable?   
    $in_command = false
    $in_select = false
    # カーソル消去
    @cursor.visible = false if @cursor.visible != nil # 1.2a
    @command_phase = false
    # アクション実行時間チェック
    act_type = charge_set(@commander)
    # 行動ゲージに切り替え
    @spriteset.change_act(act_type, true, @commander.index)
    # 動けるキャラのみコマンド戻りアクションを
    @spriteset.set_action(true, @commander.index,@commander.command_a) if @commander.inputable?
    # チャージアクション
    make_charge_action(@commander)
    # 合体攻撃チェック
    union_skill?(@commander) if @commander.action.skill? && @partners == nil
    # ウインドウ初期化
    @party_command_window.active = @actor_command_window.active = false
    @actor_command_window_on = false
    @status_window.index = @actor_index = @actor_command_window.index = -1
    @command_members.delete(@commander)
    @commander = nil
  end
  #--------------------------------------------------------------------------
  # ● 情報表示ビューポートの作成  ※再定義
  #--------------------------------------------------------------------------
  def create_info_viewport
    @command_members = []
    @action_battlers = []
    #@info_viewport = Viewport.new(0, 288, 544, 128)#原始
    @info_viewport = Viewport.new(0, 0, 544, 416)
    @info_viewport.z = 100
    @status_window = Window_BattleStatus.new
    @party_command_window = Window_PartyCommand2.new
    @actor_command_window = Window_ActorCommand.new    
    @status_window.viewport = @info_viewport
    @actor_command_window.viewport = @info_viewport
    @status_window.x = 128
    @actor_command_window.x = 672
    @info_viewport.visible = false
    @party_command_window.visible = false
    @info_viewport.ox = 128
    #####################################################################
    #@ba.x = 670
    #@ba.y = 315
    #@ba.z = 9999
    @bf = Sprite.new
    @bf.x = 540
    @bf.y = 169
    @bf.zoom_x = 0.8
    @bf.zoom_y = 0.8
    @bf.opacity = 0
    @bf2 = Sprite.new
    @bf2.x = 540
    @bf2.y = 216
    @bf2.opacity = 0
    #@bf.z = 1
    @sprites = []
    images_name =
    ["Battle01a","Battle02a","Battle03a","Battle04a","Battle05a"]
    for i in 0...images_name.size
     @sprites[i] = Sprite.new
     @sprites[i].bitmap = Cache.menu(images_name[i])
     @sprites[i].x = (i*20)+540
     @sprites[i].x -= (i*4)

     @sprites[i].x -= 15 if i == 1
     @sprites[i].x -= 20 if i == 2
     @sprites[i].x -= 15 if i == 3
     @sprites[i].x -= 5 if i == 4
     @sprites[i].y = (i*44) +230
      @sprites[i].y -= i*7
      @sprites[i].y -= 2 if i == 2
      @sprites[i].y -= 8 if i == 3
      @sprites[i].y -= 18 if i == 4
     @sprites[i].opacity = 255
     @sprites[i].z = 9999
     @sprites[i].tone = Tone.new(0,0,0,255)
     @sprites[i].zoom_x = @sprites[i].zoom_y = 1.0############
   end
    @com_count = 11
    ####################################################################
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def create_text_command_sprites(actor)
  return if @text_sprites

  commands = ["攻擊", "技能", "防禦", "物品", "逃走"]
  @text_sprites = []

  # 取得基準角色 (假設是 `actor_id = 1`)
  reference_actor = $game_party.members.find { |a| a.instance_variable_get(:@actor_id) == 1 }
  return unless reference_actor

  base_x = reference_actor.position_x - 100  # 放置在角色左側
  base_y = reference_actor.position_y - 50   # 初始 Y 位置
  
  # 創建半透明背景
  @text_bg_sprite = Sprite.new
  @text_bg_sprite.bitmap = Bitmap.new(40, 120)  # 設定背景大小
  #@text_bg_sprite.bitmap.fill_rect(0, 0, 40, 120, Color.new(0, 0, 0, 150)) # 黑色半透明背景
  rect = Rect.new (0, 0, 40, 100)
  @text_bg_sprite.bitmap.fill_rounded_rect(rect, Color.new(0, 0, 0, 150))
  @text_bg_sprite.x = base_x - 30  # 向左稍微調整
  @text_bg_sprite.y = base_y - 25  # 向上稍微調整
  @text_bg_sprite.z = 9  # 讓它在 `@text_sprites` 下方

  commands.each_with_index do |text, i|
    sprite = Sprite.new
    sprite.bitmap = Bitmap.new(120, 30)
    sprite.bitmap.font.size = 18
    sprite.bitmap.font.color = Color.new(255,98,96) if text == "物品"
    sprite.bitmap.draw_text(0, 0, 120, 30, text, 1)

    sprite.x = base_x - 70
    sprite.y = base_y - 23 + (i * 17)  # 依序向下排列
    sprite.z = 10
    #sprite.opacity = (text == "物品" ? 100 : 255)

    @text_sprites << sprite
  end

  @selected_command_index = 0
  update_text_command_opacity
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def update_text_command_opacity
  return unless @text_sprites

  @text_sprites.each_with_index do |sprite, i|
    if i == @selected_command_index
      sprite.opacity = 255  # 選中的指令
#    elsif sprite.bitmap.text == "物品"
#      sprite.opacity = 100  # 物品永遠是 100
    else
      sprite.opacity = 70  # 未選中的指令
    end
  end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def dispose_text_command_sprites
  return unless @text_sprites

  @text_sprites.each { |sprite| sprite.dispose }
  @text_sprites = nil
  
  if @text_bg_sprite
    @text_bg_sprite.bitmap.dispose
    @text_bg_sprite.dispose
    @text_bg_sprite = nil
  end
  end

  #--------------------------------------------------------------------------
  # ● 情報表示ビューポートの更新   ※再定義
  #--------------------------------------------------------------------------
  def update_info_viewport
    @party_command_window.update if @party_command_window.active
    @actor_command_window.update if @actor_command_window.active
    @status_window.update# if @status_window.active####
    @message_window.visible = false if !$game_message.visible
    @info_viewport.visible = true if !@message_window.visible
    ###
     # 取得當前指令角色
  if @actor_command_window_on
    actor = $game_party.members[@commander.index]
    actor_id = actor.instance_variable_get(:@actor_id)

    # 當 actor_id >= 7 時，隱藏原有的 @sprites
    if actor_id >= 7
      @sprites.each { |sprite| sprite.opacity = 0 if sprite }
      
      # 創建新指令圖片精靈
      create_text_command_sprites(actor)
    else
      # 恢復 @sprites 的可視度
      @sprites.each { |sprite| sprite.opacity = 255 if sprite }
      
      # 移除新指令圖片精靈
      dispose_text_command_sprites
    end
  end
    
    ###
    #end
    #############
    
    x = $game_party.members[@commander.index] if @actor_command_window_on
    x_id = x.instance_variable_get(:@actor_id) if @actor_command_window_on
    
    @actor_command_window.x += 32 if @actor_command_window.x < 672 && !@actor_command_window_on
    @actor_command_window.x -= 32 if @actor_command_window.x > 544 && @actor_command_window_on#原始
    dispose_text_command_sprites if !@actor_command_window_on
    
    for i in 0..4
      @sprites[i].x += 65 if @sprites[i].x < (i*20)+540 && !@actor_command_window_on
      @sprites[i].x -= 65 if @sprites[i].x > (i*20)+425 && @actor_command_window_on#原始
      
    end
  

  @bf.bitmap = Cache.menu("menu_喬伊") if @actor_command_window_on && x_id == 1
  @bf.bitmap = Cache.menu("menu_米亞") if @actor_command_window_on && x_id == 2
  @bf.bitmap = Cache.menu("menu_艾卓") if @actor_command_window_on && x_id == 3
  @bf.bitmap = Cache.menu("menu_薇娜") if @actor_command_window_on && x_id == 4
  @bf.bitmap = Cache.menu("menu_艾薇") if @actor_command_window_on && x_id == 5
  @bf.bitmap = Cache.menu("menu_泰勒") if @actor_command_window_on && x_id == 6
  @bf.bitmap = Cache.menu("menu_喬伊") if @actor_command_window_on && x_id >= 7
  
  if @actor_command_window_on && x_id >= 7
      actor = $game_actors[x_id]
      face_name = actor.face_name  # 臉圖檔名
      face_index = actor.face_index  # 臉圖索引 (0~7)
      character_name = actor.character_name
      # 創建角色臉圖精靈（如果尚未存在）
      unless @face_sprite
        @face_sprite = Sprite.new
        @face_sprite.viewport = @info_viewport
        @face_sprite.z = 200  # 確保顯示在前面
      end
      # 設置 bitmap 並繪製臉圖
  @face_sprite.bitmap = Bitmap.new(96, 96)  # 臉圖尺寸 (RPG Maker VX)
  @face_sprite.bitmap.blt(0, 0, Cache.face(face_name), Rect.new((face_index % 4) * 96, (face_index / 4) * 96, 96, 96))
      @face_sprite.x = 590
      @face_sprite.y = 270
      @face_sprite.opacity = 0

      # 創建角色行走圖精靈（如果尚未存在)
      # 載入完整角色行走圖
      
      unless @char_sprite
        @char_sprite = Sprite.new
        @char_sprite.z = 200
      end
      # 載入完整角色行走圖
      full_bitmap = Cache.character(character_name + "_1")
      # 計算單個角色的寬高（假設是標準 3x4）
      character_width = full_bitmap.width / 3
      character_height = full_bitmap.height / 4
      # 設定要擷取的範圍（第一排，第二格）
      rect = Rect.new(character_width, 0, character_width, character_height)
      
      
      # 創建新的 Sprite
  @char_sprite ||= Sprite.new
  @char_sprite.bitmap = Bitmap.new(character_width, character_height)
  @char_sprite.bitmap.blt(0, 0, full_bitmap, rect)
  
      @char_sprite.x = 480
      @char_sprite.y = 280
      @char_sprite.opacity = 0
    else
      # 隱藏圖像（但不立即 dispose，以防短時間內再次使用）
      @face_sprite.opacity = 0 if @face_sprite
      @char_sprite.opacity = 0 if @char_sprite
  end
  
  
  @bf.opacity = 255 if @actor_command_window_on
  @bf.opacity = 0 if @actor_command_window_on && x_id >= 7###
  @bf2.bitmap = Cache.menu("menu_bar")
  @bf2.opacity = 255 if @actor_command_window_on
  @bf2.opacity = 0 if @actor_command_window_on && x_id >= 7###
  #if @cursor != nil
  #end
  @bf.opacity = 0   if !@actor_command_window_on
  @bf.x = @sprites[0].x - 4
  @bf.x -= 10 if x_id == 5
  @bf2.opacity = 0   if !@actor_command_window_on
  @bf2.x = @sprites[0].x - 4
    
  end
  #--------------------------------------------------------------------------
  # ● スキル選択の開始  ※再定義
  #--------------------------------------------------------------------------
  def start_skill_selection
    @help_windowx = Window_Helpxxx.new if @help_windowx == nil###跑馬燈
    @help_windowx.z = 1002
    @help_windowx.visible = true
    @skill_window = Window_Skill2.new(0, 56, 544, 232, @commander)
    @skill_window.y += 0#20
    @sk_info_window = Window_SkillInfo.new(24+32, 232)###
    @sk_info_window.x = 350
    @sk_info_window.y = 56
    @skill_window.z = 1002
    @sk_info_window.z = 1002
    
    @skill_window.opacity = 0
    @skill_windowbg = Sprite.new
    @skill_windowbg.bitmap = Cache.system("battle_skillwindowbg")
    @skill_windowbg.z = 1001
    @skill_windowbg.visible = true
    
    @skill_window.help_window = @help_windowx
    @skill_window.info_window = @sk_info_window###
    @actor_command_window.active = false
  end
  #--------------------------------------------------------------------------
  # ● スキル選択の更新  ※再定義
  #--------------------------------------------------------------------------
  def update_skill_selection
    # コマンド入力できる状態でなくなればキャンセル
    return reset_command unless commanding?
    @skill_window.active = true
    @skill_window.update
    @help_windowx.update###
    @sk_info_window.update###
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_skill_selection
      $in_command = true
    elsif Input.trigger?(Input::C)
      @skill = @skill_window.skill
      if @skill != nil
        @commander.last_skill_id = @skill.id
      end
      if @commander.skill_can_use?(@skill)
        return Sound.play_buzzer if @commander.union_skill?(@skill.id) && !@commander.union_skill_can_use?(@skill.id)
        Sound.play_decision
        determine_skill
      else
        Sound.play_buzzer
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルの決定  ※再定義
  #--------------------------------------------------------------------------
  def determine_skill
    @commander.action.set_skill(@skill.id)
    @skill_window.active = false
    @help_windowx.visible = false
    if @skill.need_selection?
      if @skill.for_opponent?
        start_target_enemy_selection
      else
        start_target_actor_selection
      end
    else
      end_skill_selection
      end_target_selection
    end
  end
  #--------------------------------------------------------------------------
  # ● スキル選択の終了
  #--------------------------------------------------------------------------
  alias end_skill_selection_n01 end_skill_selection
  def end_skill_selection
    @skill_windowbg.visible = false if @skill_windowbg != nil
    end_skill_selection_n01
    @sk_info_window.dispose if @sk_info_window != nil###
    @skill_window = @sk_info_window = nil###
    $in_select = false
  end
  #--------------------------------------------------------------------------
  # ● アイテム選択の開始  ※再定義
  #--------------------------------------------------------------------------
  def start_item_selection    
    @help_window = Window_Help.new if @help_window == nil
    @help_window.visible = true
    @help_window.z = 1000
    @item_window = Window_Item.new(0, 56, 544, 232)
    @item_window.z = 1000
    @item_window.help_window = @help_window
    @actor_command_window.active = false
    
    @item_window.opacity = 0
    @item_windowbg = Sprite.new
    @item_windowbg.bitmap = Cache.system("battle_itemwindowbg")
    @item_windowbg.z = 999
    @item_windowbg.visible = true
  end
  #--------------------------------------------------------------------------
  # ● アイテム選択の更新  ※再定義
  #--------------------------------------------------------------------------
  def update_item_selection
    # コマンド入力できる状態でなくなればキャンセル
    return reset_command unless commanding?
    @item_window.active = true
    @item_window.update
    @help_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_item_selection
      $in_command = true # 1.1b
    elsif Input.trigger?(Input::C)
      @item = @item_window.item
      if @item != nil
        $game_party.last_item_id = @item.id
      end
      if $game_party.item_can_use?(@item)
        Sound.play_decision
        determine_item
      else
        Sound.play_buzzer
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテムの決定  ※再定義
  #--------------------------------------------------------------------------
  def determine_item
    @commander.action.set_item(@item.id)
    @item_window.active = false
    if @item.need_selection?
      if @item.for_opponent?
        start_target_enemy_selection
      else
        start_target_actor_selection
      end
    else
      end_item_selection
      end_target_selection
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム選択の終了
  #--------------------------------------------------------------------------
  alias end_item_selection_n01 end_item_selection
  def end_item_selection
    
    @item_windowbg.visible = false if @item_windowbg != nil
    
    end_item_selection_n01
    $in_select = false
  end
  #--------------------------------------------------------------------------
  # ● 勝敗判定  ※再定義
  #--------------------------------------------------------------------------
  def judge_win_loss
    return true unless $game_temp.in_battle
    if $game_party.all_dead?
      @judge = true
      $gauge_stop = true
      closed_window
      @spriteset.atb_dispose
      $game_troop.clear_actions
      $game_party.clear_actions
      process_defeat
      return true
    elsif $game_troop.all_dead?
      @judge = true
      $gauge_stop = true
      closed_window
      @spriteset.atb_dispose
      $game_troop.clear_actions
      $game_party.clear_actions
      process_victory
      return true
    else
      return false
    end
  end
end
#==============================================================================
#------------------------------------------------------------------------------

#==============================================================================
# ■ Game_Battler (分割定義 1)
#------------------------------------------------------------------------------
# 　バトラーを扱うクラスです。
#==============================================================================
class Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :at_count         # コマンド待ちゲージ(1000がMAX)
  attr_accessor :at_active        # コマンド入力可能
  attr_accessor :atb_count_up     # ATBカウントアップ中
  attr_accessor :act_count        # 行動待ちゲージ(1000がMAX)
  attr_accessor :act_active       # 行動可能
  attr_accessor :at_speed         # ゲージアップスピード基準値
  attr_accessor :charge_action    # チャージアクション
  attr_accessor :charge_start     # チャージ中か
  attr_accessor :union_skill_id   # 合体攻撃スキルID
  attr_accessor :union_battler    # 合体攻撃参加者か
  attr_accessor :speed_level      # 戦闘参加者の最速スピード基準
  attr_accessor :low_speed_level  # 戦闘参加者の最遅スピード基準
  #--------------------------------------------------------------------------
  # ● ステートの付加  ATBダメージ処理を追加 
  #--------------------------------------------------------------------------
  alias add_state_n02 add_state
  def add_state(state_id)
    add_state_n02(state_id)
    if $data_states[state_id].atb_damage != 0
      @at_count = @at_count + $data_states[state_id].atb_damage * 10
      @at_count = 0 if @at_count < 0 && !$data_states[state_id].atb_minus_damage
      @at_count = 1000 if @at_count > 1000
      # ATBダメージでチャージキャンセル
      if $data_states[state_id].atb_damage < 0
        @act_count = 0
        @act_active = false
        @at_active = false
        @atb_count_up = true
      end 
    end  
  end 
  #--------------------------------------------------------------------------
  # ● 戦闘開始時のAT設定
  #--------------------------------------------------------------------------
  def atb_setting
    # 初期化
    @at_count = @act_count = @speed_level = @low_speed_level = @union_skill_id = 0
    @at_active = @act_active = @atb_count_up = @charge_start = @union_battler = false
    $in_party_command = $in_command = $in_target = $in_select = $in_action = false
    @charge_action = normal
    $in_union_action = false
    # ゲージアップスピード(戦闘速度)
    @at_speed = $game_party.atb_control[1]
    # ユーザー設定を使わない場合
    return if N02::ATB_CUSTOMIZE
    @at_speed = N02::ATB_SPEED
  end
  #--------------------------------------------------------------------------
  # ● ATBスピード基準値リフレッシュ
  #--------------------------------------------------------------------------
  def atb_base_speed_refresh
    battle_members = $game_party.members + $game_troop.members
    battle_members.sort! do |a,b|
      b.agi - a.agi
    end
    self.speed_level = battle_members[0].agi
    self.low_speed_level = battle_members[battle_members.size - 1].agi
  end
  #--------------------------------------------------------------------------
  # ● 自動行動判定
  #--------------------------------------------------------------------------
  def auto_action?
    return true if berserker? or confusion? or auto_battle or @union_skill_id != 0
    return false
  end
  #--------------------------------------------------------------------------
  # ● 合体攻撃スキル判定
  #--------------------------------------------------------------------------
  def union_skill?(skill_id)
    # スキルに合体攻撃設定があるかチェック
    for union_action in $data_skills[skill_id].union_action
      union_skills = union_action if union_action.size != 0 && union_action.include?(skill_id)
    end
    return false if union_skills == nil
    return true
  end  
  #--------------------------------------------------------------------------
  # ● 合体攻撃使用可能判定 
  #--------------------------------------------------------------------------
  def union_skill_can_use?(skill_id)
    return false if $in_union_action
    for union_action in $data_skills[skill_id].union_action
      union_skills = union_action if union_action.size != 0 && union_action.include?(skill_id)
    end
    return false if union_skills == nil
    partners = []
    # 合体攻撃メンバーが使用可能かチェック
    for skill_id in union_skills
      for actor in $game_party.members
        if actor.skill_can_use?($data_skills[skill_id]) && actor.skill_id_learn?(skill_id)
          partners.push(actor) 
        end
      end
    end
    return false if partners.size != union_skills.size
    return true
  end
end  
#==============================================================================
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。
#==============================================================================
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor   :atb_custom                       # ATBユーザー設定
  attr_accessor   :atb_control                      # ATB設定
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_n02 initialize
  def initialize
    initialize_n02
    @atb_control = []
    @atb_custom = [N02::ATB_NEWGAME_MODE, N02::ATB_NEWGAME_SPEED - 1]
  end
  #--------------------------------------------------------------------------
  # ● ユーザー設定をATB設定に反映
  #--------------------------------------------------------------------------
  def atb_customize
    # ウエイト・アクティブ設定を格納
    case @atb_custom[0]
    when 0;@atb_control[0] = N02::ATB_MODE1
    when 1;@atb_control[0] = N02::ATB_MODE2
    when 2;@atb_control[0] = N02::ATB_MODE3
    end
    # 戦闘速度を格納
    @atb_control[1] = N02::ATB_SPEED_MODE[@atb_custom[1]]
    # ユーザー設定を使わない場合
    return if N02::ATB_CUSTOMIZE
    @atb_control[0] = ["",N02::ATB_PARTY_COMMAND_WAIT, N02::ATB_COMMAND_WAIT, N02::ATB_TARGET_WAIT, N02::ATB_SELECT_WAIT, N02::ATB_ACTION_WAIT]
    @atb_control[1] = N02::ATB_SPEED
  end
end 
#==============================================================================
#------------------------------------------------------------------------------
# 　ATBゲージ用のスプライトです。
#==============================================================================
class Sprite_ATB < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :battler
  attr_accessor :count            # 更新カウント
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化 
  #--------------------------------------------------------------------------
  def initialize(viewport,battler = nil)
    super(viewport)
    @battler = battler
    @count = 0
    @base_atb_count = 1
    @restriction_count = 0
    @state_freeze = false
    @update = 0
    @pre_width = 0
    make_gauge
    start_atb
    @party_command_wait = $game_party.atb_control[0][1]
    @command_wait = $game_party.atb_control[0][2]
    @target_wait = $game_party.atb_control[0][3]
    @select_wait = $game_party.atb_control[0][4]
    @action_wait = $game_party.atb_control[0][5]
  end
  #--------------------------------------------------------------------------
  # ● ATB初期値セッティング
  #--------------------------------------------------------------------------
  def start_atb
    atb = battler.atb_base * 10 + rand(N02::ATB_BASE_ADD) * 10
    if battler.actor?
      atb1 = battler.weapons[0].atb_base * 10 if battler.weapons[0] != nil
      atb2 = battler.weapons[1].atb_base * 10 if battler.weapons[1] != nil
      atb1 = atb if atb1 == nil
      atb2 = atb1 if atb2 == nil
      atb += (atb1 + atb2) / 2
      for i in 0...battler.armors.size
        # 二刀はキャンセル
        next if battler.two_swords_style && battler.armors[0] != nil && battler.armors[0]
        atb += battler.armors[i].atb_base * 10 if battler.armors[i] != nil
      end  
    end
    change_atb(atb)
  end
  #--------------------------------------------------------------------------
  # ● ゲージ作成
  #--------------------------------------------------------------------------
  def make_gauge
    self.bitmap = Cache.system("atb_bar_skin")
    @gauge = Sprite.new(viewport)
    @gauge.bitmap = Cache.system("atb_bar")
    @gauge_max = Sprite.new(viewport)
    @gauge_max.bitmap = Cache.system("atb_bar_active")
    @gauge_max.visible = false
    @gauge_division = 1000 / N02::ATB_WIDTH
    @gauge_space = N02::ATB_SPACE
  end
  #--------------------------------------------------------------------------
  # ● 座標セット
  #--------------------------------------------------------------------------
  def set(x, y)
    self.ox = @gauge.ox = @gauge_max.ox = self.bitmap.width / 2
    self.oy = @gauge.oy = @gauge_max.oy = self.bitmap.height / 2
    self.visible = @gauge.visible = @gauge_max.visible = false
    if @battler.actor? && N02::ATB_POSITION_HPWINDOW
      self.z = @gauge.z = @gauge_max.z = 1000
      self.x = @gauge.x = @gauge_max.x = N02::ATB_PARTY_POSITION[@battler.index][0]
      self.y = @gauge.y = @gauge_max.y = N02::ATB_PARTY_POSITION[@battler.index][1]
      return 
    end
    adjust = N02::ATB_POSITION_ENEMY
    adjust = N02::ATB_POSITION_ACTOR if battler.actor?
    self.x = @gauge.x = @gauge_max.x = x + adjust[0]
    self.x = @gauge.x = @gauge_max.x = x - adjust[0] if $back_attack
    if battler.actor? == false
      if @battler.enemy_id == 9#魔化野豬
       adjust[1] = 0 ###
      elsif @battler.enemy_id == 59#魔化野豬
       adjust[1] = 0 ###
     end
    end
    self.y = @gauge.y = @gauge_max.y = y + adjust[1]
    self.z = @gauge.z = @gauge_max.z = battler.position_z + 10
    @gauge_max.z += 1
  end
  #--------------------------------------------------------------------------
  # ● ATBゲージ切り替え
  #--------------------------------------------------------------------------
  def change_atb(restart_gauge = 0)
    @battler.atb_base_speed_refresh
    case N02::ATB_BASE_SPEED
    when 0
      return @base_atb_count = @battler.at_speed * battler.agi if N02::ATB_ABSOLUTE_SPEED == 0
      @base_atb_count = @battler.at_speed * battler.agi / N02::ATB_ABSOLUTE_SPEED
    when 1
      return @base_atb_count = @battler.at_speed * battler.agi if @battler.speed_level == 0
      @base_atb_count = @battler.at_speed * battler.agi / @battler.speed_level
    when 2
      return @base_atb_count = @battler.at_speed * @battler.agi if @battler.low_speed_level == 0
      @base_atb_count = @battler.at_speed * @battler.agi / @battler.low_speed_level
    when 3
      return @base_atb_count = @battler.at_speed * @battler.agi if @battler.speed_level / 2 + @battler.low_speed_level / 2 == 0
      @base_atb_count = @battler.at_speed * @battler.agi / (@battler.speed_level / 2 + @battler.low_speed_level / 2)
    end
    @base_atb_count = 1 if @base_atb_count == 0
    @battler.at_count = restart_gauge
    @battler.act_count = 0
    @gauge.bitmap = Cache.system("atb_bar")
    @battler.act_active = false
    @battler.at_active = false
    @battler.atb_count_up = true
  end
  #--------------------------------------------------------------------------
  # ● ACTゲージ切り替え
  #--------------------------------------------------------------------------
  def change_act(act_type)
    change_atb
    case act_type[0]
    when 0
      base = @battler.at_speed * @battler.agi
      base = @battler.at_speed * @battler.agi / act_type[2] if act_type[2] != 0
    when 1
      base = @battler.at_speed * @battler.agi / @battler.speed_level
    when 2
      base = @battler.at_speed * @battler.agi if @battler.low_speed_level == 0
      base = @battler.at_speed * @battler.agi / @battler.low_speed_level
    when 3
      base = @battler.at_speed * @battler.agi if @battler.speed_level / 2 + @battler.low_speed_level / 2 == 0
      base = @battler.at_speed * @battler.agi / (@battler.speed_level / 2 + @battler.low_speed_level / 2) 
    when 4
      base = @battler.at_speed
    end
    if act_type[1] <= 0
      @base_act_count = 1000
    else
      @base_act_count = base *  100 / act_type[1]
    end
    @base_act_count = 1 if @base_act_count == 0
    @battler.act_count = 0
    @gauge.bitmap = Cache.system("act_bar")
    @battler.atb_count_up = false
    @battler.at_active = false
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # ステート管理
    states_control
    # 強制ゲージストップ
    return if $gauge_stop or !@battler.exist? or $game_message.visible
    # アクションウエイト
    wait = true if $in_action && !@action_wait
    wait = false if $in_action && @action_wait
    # パーティコマンド選択中ウエイト
    wait = true if $in_party_command && !@party_command_wait
    wait = false if $in_party_command && @party_command_wait
    # 戦闘コマンド選択中ウエイト
    wait = true if $in_command && !@command_wait
    wait = false if $in_command && @command_wait
    # ターゲット選択中ウエイト
    wait = true if $in_target && !@target_wait
    wait = false if $in_target && @target_wait
    # スキル/アイテム選択中ウエイト
    wait = true if $in_select && !@select_wait
    wait = false if $in_select && @select_wait
    # アクション中はゲージを消すか
    self.visible = @gauge.visible = true
    self.visible = @gauge_max.visible = @gauge.visible = false if @battler.act_active && N02::ATB_ACTION_ENEMY_OFF && !@battler.actor? && @battler.union_skill_id == 0
    self.visible = @gauge_max.visible = @gauge.visible = false if @battler.act_active && N02::ATB_ACTION_ACTOR_OFF && @battler.actor? && @battler.union_skill_id == 0
    # ゲージ表示設定
    self.visible = @gauge.visible = @gauge_max.visible = false if !@battler.atb_on
    self.visible = @gauge.visible = @gauge_max.visible = false if @battler.actor? && $game_message.visible && N02::ATB_POSITION_HPWINDOW
    # 見えないエネミーはゲージ隠蔽
    self.visible = @gauge.visible = @gauge_max.visible = false if !@battler.actor? && !@battler.exist?
    # ボタン入力によるゲージ制御
    wait = true if Input.press?(Input::ALT) && N02::ATB_ALT_WAIT
    wait = false if Input.press?(Input::CTRL) && N02::ATB_CTRL_ACTIVE
    # 自身のみアクションウエイト
    wait = true if @battler.act_active
    # ゲージウエイト
    return if wait
    # ステートによるゲージストップ処理
    return recover_states_freeze if @state_freeze
    # ゲージカウントアップ
    gauge_update
    # ゲージ描画
    return if @pre_width == @gauge_space + @battler.act_count / @gauge_division && !@battler.atb_count_up
    return if @pre_width == @gauge_space + @battler.at_count / @gauge_division && @battler.atb_count_up
    gauge_refresh
  end
  #--------------------------------------------------------------------------
  # ● ゲージカウントアップ
  #--------------------------------------------------------------------------
  def gauge_update
    # ACTカウントアップ
    act if !@battler.atb_count_up && !@battler.at_active && !@battler.act_active
    # ATBカウントアップ
    atb if @battler.atb_count_up
  end
  #--------------------------------------------------------------------------
  # ● ゲージリフレッシュ
  #--------------------------------------------------------------------------
  def gauge_refresh
    @gauge_max.visible = false if !@battler.act_active && !@battler.at_active
    @gauge.src_rect.width = @pre_width = @gauge_space + @battler.act_count / @gauge_division if !@battler.atb_count_up && !@battler.at_active && !@battler.act_active
    @gauge.src_rect.width = @pre_width = @gauge_space + @battler.at_count / @gauge_division if @battler.atb_count_up
  end
  #--------------------------------------------------------------------------
  # ● ゲージ隠蔽
  #--------------------------------------------------------------------------
  def off
    self.visible = @gauge.visible = @gauge_max.visible = false
  end
  #--------------------------------------------------------------------------
  # ● ゲージ表示
  #--------------------------------------------------------------------------
  def on
    self.visible = @gauge.visible = @gauge_max.visible = true
    gauge_refresh
  end
  #--------------------------------------------------------------------------
  # ● ステート管理
  #--------------------------------------------------------------------------
  def states_control
    self.visible = @gauge_max.visible = @gauge.visible = false if !@battler.actor? && !@battler.exist?
    if !@state_freeze && !@battler.movable?
      # 行動不能はゲージを0に
      @restriction_count = @battler.at_count
      @state_freeze = true
      @atb_dead = true if @battler.dead? && !@atb_dead
      change_atb(0)
      gauge_refresh
    # ステート復帰時
    elsif @battler.movable? && @state_freeze
      @state_freeze = false
      # 戦闘不能復帰時のゲージ処理
      return if !@atb_dead
      change_atb(N02::ATB_DEAD_COUNT * 10)
      @atb_dead = false
      gauge_refresh
    end
  end
  #--------------------------------------------------------------------------
  # ● ステートによるゲージストップ回復
  #--------------------------------------------------------------------------
  def recover_states_freeze
    @restriction_count += @base_atb_count
    @restriction_count += @base_atb_count * 2 if Input.press?(Input::SHIFT) && N02::ATB_SHIFT_BOOST
    if @restriction_count >= 1000
      # ステート自然回復許可
      @battler.remove_states_auto
      @restriction_count = 0 
    end
  end
  #--------------------------------------------------------------------------
  # ● ATBカウント
  #--------------------------------------------------------------------------
  def atb
    if @battler.at_count <= 1000
      @gauge_max.visible = false
      @battler.at_count += @base_atb_count
      @battler.at_count += @base_atb_count * 2 if Input.press?(Input::SHIFT) && N02::ATB_SHIFT_BOOST
    end
    # ATBゲージMAX
    if @battler.at_count >= 1000
      # ステート自然回復
      @battler.remove_states_auto
      @battler.atb_count_up = false
      @battler.at_active = true
      @gauge.src_rect.width = 52
      return if !@battler.atb_on
      Audio.se_play("Audio/SE/" + N02::ATB_MAX_SOUND01[2], N02::ATB_MAX_SOUND01[1],  N02::ATB_MAX_SOUND01[0])
      @gauge_max.visible = true
    end
    @battler.act_active = false
  end  
  #--------------------------------------------------------------------------
  # ● ACTカウント
  #--------------------------------------------------------------------------
  def act
    if @battler.act_count <= 1000
      @gauge_max.visible = false
      @battler.act_count += @base_act_count
      @battler.at_count += @base_atb_count * 3 if Input.press?(Input::SHIFT) && N02::ATB_SHIFT_BOOST
    end
    # ACTゲージMAX
    if @battler.act_count >= 1000 && !@battler.act_active
      @battler.act_active = true
      @gauge.src_rect.width = 52
      return if !@battler.atb_on
      Audio.se_play("Audio/SE/" + N02::ACT_MAX_SOUND01[2], N02::ACT_MAX_SOUND01[1],  N02::ACT_MAX_SOUND01[0])
      @gauge_max.visible = true
    end
  end  
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    super
    @gauge.dispose
    @gauge_max.dispose
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def refill 
    @battler.act_active = false
    @battler.at_active = false
    @battler.act_count = 0
    @battler.at_count = 1000
    @battler.atb_count_up = true
    @gauge.bitmap = Cache.system("atb_bar")
  end
end 
#==============================================================================
#------------------------------------------------------------------------------
# 　カーソルのスプライトです。
#==============================================================================
class Sprite_Cursor < Sprite_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化 
  #--------------------------------------------------------------------------
  def initialize
    super
    create_target_cursor
  end
  #--------------------------------------------------------------------------
  # ● ターゲットカーソルスプライトの作成
  #--------------------------------------------------------------------------
  def create_target_cursor
    self.bitmap = Cache.system("cursor")
    @width = self.bitmap.width
    @height = self.bitmap.height / 3
    self.src_rect.set(0, 0, @width, @height)
    @cursor_flame = 0
    self.x = @pre_x = 272
    self.y = @pre_y = 208
    self.z = 300
    self.ox = @width
    self.oy = @height
    self.visible = false
    @time = 0
    @flash_time = 0
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    # カーソル画像更新
    @cursor_flame = 0 if @cursor_flame == 40
    self.src_rect.set(0,           0, @width, @height) if @cursor_flame == 0
    self.src_rect.set(0,     @height, @width, @height) if @cursor_flame == 10
    self.src_rect.set(0, 2 * @height, @width, @height) if @cursor_flame == 20
    self.src_rect.set(0,     @height, @width, @height) if @cursor_flame == 30
    @cursor_flame += 1
    # カーソル座標更新
    return if @battler == nil
    # ターゲットを光らせる
    @flash_time -= 1
    if @flash_time == 0 && @battler.exist? && !@battler.collapse
      @battler.white_flash = true
      @flash_time = 20
    end
    if @time == 0
      self.x = @battler.position_x + N01::CURSOR_X_PLUS
      return self.y = (@battler.position_y + N01::CURSOR_Y_PLUS) - @battler.graphics_width / 5
    end  
    @time -= 1
    self.x = @pre_x + (@battler.position_x + N01::CURSOR_X_PLUS - @pre_x) * (9 - @time) / 9
    self.y = @pre_y + (@battler.position_y + N01::CURSOR_Y_PLUS - @battler.graphics_width / 5 - @pre_y) * (9 - @time) / 9
  end
  #--------------------------------------------------------------------------
  # ● カーソル移動情報セット 
  #--------------------------------------------------------------------------
  def set(battler)
    self.visible = true
    @battler = battler
    return if @battler == nil
    
    
    @battler.white_flash = true if @battler.exist? && !@battler.collapse
    @time = 9
    @flash_time = 20
    @pre_x = self.x
    @pre_y = self.y
  end
end
#==============================================================================
#------------------------------------------------------------------------------
# 　バトラー表示用のスプライトです。
#==============================================================================
class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # ● バトラー作成
  #--------------------------------------------------------------------------
  alias make_battler_n01 make_battler
  def make_battler
    make_battler_n01

    make_atb
  end  
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  alias dispose_n01 dispose
  def dispose
    dispose_n01
    @atb_gauge.dispose if @atb_gauge != nil
  end  
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  alias stand_by_n02 stand_by
  def stand_by
    @battler.charge_start = false if @battler.charge_start && !@battler.exist?
    return @repeat_action = @battler.charge_action if @battler.charge_start
    stand_by_n02
  end 
  #--------------------------------------------------------------------------
  # ● ATBゲージ作成
  #--------------------------------------------------------------------------
  def make_atb
    return if battler == nil
    battler.atb_setting
    if battler.actor? && N02::ATB_POSITION_HPWINDOW
      @atb_gauge = Sprite_ATB.new(@viewport2,battler)
    else
      @atb_gauge = Sprite_ATB.new(viewport,battler)
    end
    @atb_gauge.set(self.x, self.y)
  end  
  #--------------------------------------------------------------------------
  # ● ATBゲージビューポート作成
  #--------------------------------------------------------------------------
  def make_atb_viewport(new_viewport)
    @viewport2 = new_viewport
  end  
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias update_n01 update
  def update
    update_n01
    # ATB更新
    @atb_gauge.update if @atb_gauge != nil
  end
  #--------------------------------------------------------------------------
  # ● ゲージ更新
  #--------------------------------------------------------------------------
  def gauge_update
    @atb_gauge.gauge_update if @atb_gauge != nil
  end
  #--------------------------------------------------------------------------
  # ● ゲージリフレッシュ
  #--------------------------------------------------------------------------
  def gauge_refresh
    @atb_gauge.gauge_refresh if @atb_gauge != nil
  end
  #--------------------------------------------------------------------------
  # ● ゲージ表示
  #--------------------------------------------------------------------------
  def gauge_on
    @atb_gauge.on if @atb_gauge != nil
  end
  #--------------------------------------------------------------------------
  # ● ゲージ隠蔽
  #--------------------------------------------------------------------------
  def gauge_off
    @atb_gauge.off if @atb_gauge != nil
  end
  #--------------------------------------------------------------------------
  # ● ATBゲージ切り替え
  #--------------------------------------------------------------------------
  def change_atb(restart_gauge)
    @atb_gauge.change_atb(restart_gauge) if @atb_gauge != nil
  end
  #--------------------------------------------------------------------------
  # ● ACTゲージ切り替え
  #--------------------------------------------------------------------------
  def change_act(act_type)
    @atb_gauge.change_act(act_type) if @atb_gauge != nil
  end
  #--------------------------------------------------------------------------
  # ● ATBゲージ開放
  #--------------------------------------------------------------------------
  def atb_dispose
    @atb_gauge.dispose if @atb_gauge != nil
    @atb_gauge = nil
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def gauge_refill
    @atb_gauge.refill
  end
end
#==============================================================================
#------------------------------------------------------------------------------
# 　バトル画面のスプライトをまとめたクラスです。
#==============================================================================
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● アクタースプライトの作成
  #--------------------------------------------------------------------------
  alias create_actors_n01 create_actors
  def create_actors
    create_actors_n01
    if N02::ATB_POSITION_HPWINDOW
      for sprites in @actor_sprites + @enemy_sprites
        sprites.make_atb_viewport(@viewport4)
      end
    end  
  end
  #--------------------------------------------------------------------------
  # ● ターゲット情報リフレッシュ
  #--------------------------------------------------------------------------
  def update_target(actor, index)
    @actor_sprites[index].update_target if actor
    @enemy_sprites[index].update_target unless actor
  end
  #--------------------------------------------------------------------------
  # ● ゲージ更新
  #--------------------------------------------------------------------------
  def gauge_update
    for sprites in @actor_sprites + @enemy_sprites
      sprites.gauge_update if sprites != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● ゲージリフレッシュ
  #--------------------------------------------------------------------------
  def gauge_refresh(actor, index)
    @actor_sprites[index].gauge_refresh if actor
    @enemy_sprites[index].gauge_refresh unless actor
  end
  #--------------------------------------------------------------------------
  # ● ゲージ表示
  #--------------------------------------------------------------------------
  def gauge_on
    for sprites in @actor_sprites + @enemy_sprites
      sprites.gauge_on if sprites != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● ゲージ隠蔽
  #--------------------------------------------------------------------------
  def gauge_off
    for sprites in @actor_sprites + @enemy_sprites
      sprites.gauge_off if sprites != nil
    end
  end
  #--------------------------------------------------------------------------
  # ● ATBゲージ切り替え
  #--------------------------------------------------------------------------
  def change_atb(restart_gauge, actor, index)
    @actor_sprites[index].change_atb(restart_gauge) if actor
    @enemy_sprites[index].change_atb(restart_gauge) unless actor
  end
  #--------------------------------------------------------------------------
  # ● ACTゲージ切り替え
  #--------------------------------------------------------------------------
  def change_act(act_type, actor, index)
    @actor_sprites[index].change_act(act_type) if actor
    @enemy_sprites[index].change_act(act_type) unless actor
  end
  #--------------------------------------------------------------------------
  # ● ATBゲージ一斉開放
  #--------------------------------------------------------------------------
  def atb_dispose
    for sprites in @actor_sprites + @enemy_sprites
      sprites.atb_dispose if sprites != nil
    end
  end
  #--------------------------------------------------------------------------
  #--------------------------------------------------------------------------
  def gauge_refill(actor, index)
    @actor_sprites[index].gauge_refill if actor
    @enemy_sprites[index].gauge_refill unless actor
  end
end
#==============================================================================
#------------------------------------------------------------------------------
# 　スキル画面などで、使用できるスキルの一覧を表示するウィンドウです。
#==============================================================================
class Window_Skill < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 項目の描画  ※再定義
  #--------------------------------------------------------------------------
  def draw_item(index)
    rect = item_rect(index)
    self.contents.clear_rect(rect)
    skill = @data[index]
    if skill != nil
      rect.width -= 4
      enabled = @actor.skill_can_use?(skill)
      enabled = @actor.union_skill_can_use?(skill.id) if @actor.union_skill?(skill.id)
      draw_item_name10(skill, rect.x, rect.y, enabled)
      self.contents.draw_text(rect, @actor.calc_mp_cost(skill), 2)
    end
  end
end  

#==============================================================================
#------------------------------------------------------------------------------
# 　バトル画面でパーティメンバーのステータスを表示するウィンドウです。
#==============================================================================
class Window_BattleStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # ● カーソルを下に移動  ※再定義
  #--------------------------------------------------------------------------
  def cursor_down(wrap = false)
  end
  #--------------------------------------------------------------------------
  # ● カーソルを上に移動  ※再定義
  #--------------------------------------------------------------------------
  def cursor_up(wrap = false)
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新  ※再定義
  #--------------------------------------------------------------------------
  def update
    super
    update_cursor
    call_update_help
  end
end 
#==============================================================================
#------------------------------------------------------------------------------
# 　バトル画面で、戦うか逃げるかを選択するウィンドウです。
#==============================================================================
class Window_PartyCommand2 < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 234, 544, 56)
    @item_max = 2
    @column_max = 2
    self.contents.draw_text(32, 0, 96, WLH, "#{Vocab.fight}", 2) # 1.1b
    
    #self.contents.draw_text(160, 0, 96, WLH, "#{"Switch"}", 2)
    
    self.contents.draw_text(310, 0, 96, WLH, "#{Vocab.escape}", 2) if $game_troop.can_escape # 1.1b
    self.contents.font.color.alpha = 128
    self.contents.draw_text(310, 0, 96, WLH, "#{Vocab.escape}", 2) if !$game_troop.can_escape # 1.1b
    self.active = false
  end
end

#==============================================================================
#------------------------------------------------------------------------------
# 　メニュー画面でATB設定を表示するウィンドウです。
#==============================================================================
class Window_ATB_active < Window_Selectable
  # アクティブタイムバトルのカスタマイズ項目からのテキスト
  ATB_MODE_NAME = N02::ATB_MODE_NAME
  ATB_MODE1 = N02::ATB_MODE1[0]
  ATB_MODE2 = N02::ATB_MODE2[0]
  ATB_MODE3 = N02::ATB_MODE3[0]
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 174, 544, 56)
    @item_max = 3
    @column_max = 3
    set_active
    self.active = true
    self.index = $game_party.atb_custom[0]
  end
  #--------------------------------------------------------------------------
  # ● アクティブ化
  #--------------------------------------------------------------------------
  def set_active
    self.contents.clear
    self.contents.font.size = 15
    self.contents.font.color = crisis_color
    self.contents.draw_text(  0, 0, 100, WLH, ATB_MODE_NAME, 0)
    self.contents.draw_text(  0, 0, 100, WLH, ATB_MODE_NAME, 0)
    self.contents.font.size = 20
    self.contents.font.color = normal_color
    refresh
  end  
  #--------------------------------------------------------------------------
  # ● アクティブ解除
  #--------------------------------------------------------------------------
  def non_active
    self.contents.clear
    self.contents.font.size = 15
    self.contents.font.color = system_color
    self.contents.draw_text(  0, 0, 100, WLH, ATB_MODE_NAME, 0)
    self.contents.font.size = 20
    self.contents.font.color = normal_color
    refresh
  end  
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def refresh
    case $game_party.atb_custom[0]
    when 0
      self.contents.draw_text(100, 0, 140, WLH, ATB_MODE1, 1)
      self.contents.font.color.alpha = 100
      self.contents.draw_text(240, 0, 140, WLH, ATB_MODE2, 1)
      self.contents.draw_text(380, 0, 140, WLH, ATB_MODE3, 1)
    when 1
      self.contents.font.color.alpha = 100
      self.contents.draw_text(100, 0, 140, WLH, ATB_MODE1, 1)
      self.contents.font.color = normal_color
      self.contents.draw_text(240, 0, 140, WLH, ATB_MODE2, 1)
      self.contents.font.color.alpha = 100
      self.contents.draw_text(380, 0, 140, WLH, ATB_MODE3, 1)
    when 2
      self.contents.font.color.alpha = 100
      self.contents.draw_text(100, 0, 140, WLH, ATB_MODE1, 1)
      self.contents.draw_text(240, 0, 140, WLH, ATB_MODE2, 1)
      self.contents.font.color = normal_color
      self.contents.draw_text(380, 0, 140, WLH, ATB_MODE3, 1)
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = 140
    rect.height = 24
    rect.x = index % @column_max * rect.width + 100
    rect.y = index / @column_max * WLH
    return rect
  end
end  
#==============================================================================
#------------------------------------------------------------------------------
# 　メニュー画面でATB設定を表示するウィンドウです。
#==============================================================================
class Window_ATB_speed < Window_Selectable
  # アクティブタイムバトルのカスタマイズ項目からのテキスト
  ATB_MODE_NAME = N02::ATB_SPEED_NAME
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 230, 544, 56)
    @item_max = 9
    @column_max = 9
    non_active
    self.active = false
    self.index = -1
  end
  #--------------------------------------------------------------------------
  # ● アクティブ化
  #--------------------------------------------------------------------------
  def set_active
    self.contents.clear
    self.contents.font.size = 15
    self.contents.font.color = crisis_color
    self.contents.draw_text(  0, 0, 140, WLH, ATB_MODE_NAME, 0)
    self.contents.draw_text(  0, 0, 140, WLH, ATB_MODE_NAME, 0)
    self.contents.font.size = 22
    self.contents.font.color = normal_color
    refresh
  end  
  #--------------------------------------------------------------------------
  # ● アクティブ解除
  #--------------------------------------------------------------------------
  def non_active
    self.contents.clear
    self.contents.font.size = 15
    self.contents.font.color = system_color
    self.contents.draw_text(  0, 0, 140, WLH, ATB_MODE_NAME, 0)
    self.contents.font.size = 22
    self.contents.font.color = normal_color
    refresh
  end  
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得 edited
  #--------------------------------------------------------------------------
  def refresh
    self.contents.font.color.alpha = 96
    for i in 0..8
      self.contents.draw_text(94 + 38 * i, 0, 140, WLH, (i + 1).to_s, 1)
    end
    self.contents.font.color.alpha = 256
    for i in 0..8
      case $game_party.atb_custom[1]
        when i;self.contents.draw_text(94 + 38 * i, 0, 140, WLH, (i + 1).to_s, 1)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● 項目を描画する矩形の取得
  #--------------------------------------------------------------------------
  def item_rect(index)
    rect = Rect.new(0, 0, 0, 0)
    rect.width = 38
    rect.height = 24
    rect.x = index % @column_max * rect.width + 145
    rect.y = index / @column_max * WLH
    return rect
  end
end  
#==============================================================================
#------------------------------------------------------------------------------
# 　ATB設定の説明を表示するウィンドウです。
#==============================================================================
class Window_ATB_Help < Window_Base
  # アクティブタイムバトルのカスタマイズ項目からのテキスト
  ATB_MODE_NAME = N02::ATB_MODE_NAME
  ATB_MODE1 = N02::ATB_MODE1[0]
  ATB_MODE2 = N02::ATB_MODE2[0]
  ATB_MODE3 = N02::ATB_MODE3[0]
  ATB_MODE1_HELP = N02::ATB_MODE1_HELP
  ATB_MODE2_HELP = N02::ATB_MODE2_HELP
  ATB_MODE3_HELP = N02::ATB_MODE3_HELP
  ATB_SPEED_NAME = N02::ATB_SPEED_NAME
  ATB_SPEED_HELP = N02::ATB_SPEED_HELP
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 56, 544, 96)
  end
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def set_text_active(index)
    text1 = ATB_MODE_NAME + "  ["
    case index
    when 0
      text1 += ATB_MODE1 + "]"
      text2 = ATB_MODE1_HELP
    when 1
      text1 += ATB_MODE2 + "]"
      text2 = ATB_MODE2_HELP
    when 2
      text1 += ATB_MODE3 + "]"
      text2 = ATB_MODE3_HELP
    end
    self.contents.clear
    self.contents.font.color = crisis_color
    self.contents.draw_text(4, 4, self.width - 40, WLH, text1, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 34, self.width - 40, WLH, text2, 0)
  end
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def set_text_speed
    text1 = ATB_SPEED_NAME
    text2 = ATB_SPEED_HELP
    self.contents.clear
    self.contents.font.color = crisis_color
    self.contents.draw_text(4, 4, self.width - 40, WLH, text1, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 34, self.width - 40, WLH, text2, 0)
  end
end

#==============================================================================
#------------------------------------------------------------------------------
# 　ATB設定タイトル・操作を表示するウィンドウです。
#==============================================================================
class Window_ATB_Title < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 544, 56)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def refresh
    text1 = N02::ATB_CUSTOMIZE_NAME
    text2 = N02::ATB_CUSTOMIZE_HELP # 1.1b
    self.contents.clear
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 96, WLH, text1, 0)
    self.contents.font.color = normal_color
    self.contents.draw_text(110, 0, 420, WLH, text2, 0)
  end
end

#==============================================================================
#------------------------------------------------------------------------------
# 　ATB設定を行うクラスです。
#==============================================================================
class Scene_ATB < Scene_Base
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @title_window = Window_ATB_Title.new
    @help_window = Window_ATB_Help.new
    @active_window = Window_ATB_active.new
    @speed_window = Window_ATB_speed.new
    @help_window.set_text_active(@active_window.index)
    @active_window_index = @active_window.index
    @speed_window_index = $game_party.atb_custom[1]
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    $game_party.atb_customize
    dispose_menu_background
    @title_window.dispose
    @help_window.dispose
    @active_window.dispose
    @speed_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● 元の画面へ戻る
  #--------------------------------------------------------------------------
  def return_scene
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background
    @help_window.update
    @active_window.update
    @speed_window.update
    if @active_window.active
      update_active_selection
    elsif @speed_window.active
      update_speed_selection
    end
  end
  #--------------------------------------------------------------------------
  # ● アイテム選択の更新
  #--------------------------------------------------------------------------
  def update_active_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      $game_party.atb_custom[0] = @active_window.index
      @active_window.set_active
    elsif Input.trigger?(Input::UP) or Input.trigger?(Input::DOWN)
      Sound.play_cursor
      @speed_window.active = true
      @speed_window.set_active
      @speed_window.index = @speed_window_index
      @active_window.active = false
      @active_window.non_active
      @active_window_index = @active_window.index
      @active_window.index = -1
      @help_window.set_text_speed
    elsif Input.trigger?(Input::LEFT) or Input.trigger?(Input::RIGHT)
      @help_window.set_text_active(@active_window.index)
    end
  end
  #--------------------------------------------------------------------------
  # ● ターゲット選択の更新
  #--------------------------------------------------------------------------
  def update_speed_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      $game_party.atb_custom[1] = @speed_window.index
      @speed_window.set_active
    elsif Input.trigger?(Input::UP) or Input.trigger?(Input::DOWN)
      Sound.play_cursor
      @active_window.active = true
      @active_window.set_active
      @active_window.index = @active_window_index
      @speed_window.active = false
      @speed_window.non_active
      @speed_window_index = @speed_window.index
      @speed_window.index = -1
      @help_window.set_text_active(@active_window.index)
    end
  end
end