#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Sideview 2 (3.4d)｜Scene / Battle Runtime
# 【用途】Tankentai Sideview 的 Scene_Battle 與戰鬥執行層，連接指令輸入、目標選擇、Spriteset、武器／移動動畫、傷害演出、戰鬥開始／結束與 ATB/SBS 相容流程。
# 【主要影響】Scene_Battle、Game_BattleAction、Sprite_Base、Spriteset_Battle、Sprite_MoveAnime、Sprite_Weapon、Game_Battler。
# 【載入順序】此頁含大量 alias／覆寫，是 FS Battle Authority Chain 的基礎層之一；必須維持目前已驗證位置，後方 Targeting、ATB、MarkedCommand、TargetUI 等會再包裝部分方法。
# 【重要責任】
#   - 戰鬥開始／結束時建立與釋放 Sideview UI/Sprite。
#   - 雙持武器顯示的暫時交換與復原。
#   - 目標游標、敵我選取、Help Window 與目標名稱顯示。
#   - set_action / update_basic / stand-by action 與 SBS 動作等待。
#   - Sprite_MoveAnime、Sprite_Weapon、Game_Battler 動作資料與命中演出。
# 【FS 注意】本頁並非 Targeting 最終 Authority。選取相關行為後續仍經 TargetPriority、TargetGroupExact、MarkedCommand、BattleTargetUI 等層；修改前必查 Battle Authority Map。
# 【相關素材】battle_helpwindowbg、Battle_ItemSelectEnemy、Battle_ItemSelectActor、cursor、Iconset，以及 Graphics/Battlers、Graphics/Characters 等 SBS 素材。
# 【呼叫方式】由戰鬥 Scene 與 SBS 自動執行；沒有建議的獨立事件 Script Call。
# 【範例】要修改技能動作表現，使用 SBS Action Key／FS SBS Bridge；不要直接呼叫 start_target_selection 或操作 @cursor，因為後續 Targeting Authority 會接管。
# 【來源】Sideview Ver3.4d Runtime；原始日文註解保留，英文維護旁註已中文化／集中至開頭。
#------------------------------------------------------------------------------
# 【文件維護規則】
# 1. 本頁所有維護說明集中於腳本最前方；下方程式識別字、Notetag、Action Key、方法名不可翻譯改名。
# 2. 原作者、版本、Credits、License、網址等來源資訊保留；完整翻譯前原稿另存 Phase 16 Archive。
# 3. 範例只使用原文件已明示的 API／Notetag，或由既有方法簽章可直接證實的呼叫方式。
# 4. 本輪只改註解／說明，不改任何可執行 Ruby；載入順序仍以 FS LoadOrder Guide／Authority Map 為準。
#==============================================================================
#==============================================================================
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================
class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  alias terminate_n01 terminate
  def terminate
    terminate_n01
    # 二刀流の持ち替え処理を戻す
    for member in $game_party.members
      if member.two_swords_change
        member.change_equip_by_id(1, member.weapon_id)
        member.change_equip_by_id(0, 0)
        member.two_swords_change = false
      end  
    end
  end
  #--------------------------------------------------------------------------
  # ● 戦闘開始の処理
  #--------------------------------------------------------------------------
  alias process_battle_start_n01 process_battle_start
  def process_battle_start
        
    @help_windowbg = Sprite.new
    @help_windowbg.bitmap = Cache.system("battle_helpwindowbg")
    @help_windowbg.visible = false
    
    process_battle_start_n01
    # 二刀流で左(下部表示)に武器を持ち右(上部表示)に武器を持たないように
    # している場合、ここで強制的に持ち替えさせる
    for member in $game_party.members
      if member.weapons[0] == nil and member.weapons[1] != nil
        member.change_equip_by_id(0, member.armor1_id)
        member.change_equip_by_id(1, 0)
        member.two_swords_change = true
      end
    end  
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  alias update_n01 update
  def update
    reset_stand_by_action
    super
    update_n01
  end
  #--------------------------------------------------------------------------
  # ● イベント操作によるＨＰ変動でキャラクターアクションを再設定
  #--------------------------------------------------------------------------
  def reset_stand_by_action
    if $game_temp.status_window_refresh
      $game_temp.status_window_refresh = false
      for member in $game_party.members + $game_troop.members
        @spriteset.set_stand_by_action(member.actor?, member.index)
        # 自動復活チェック
        resurrection(member) if member.hp == 0
      end  
      @status_window.refresh
    end
  end  
  #--------------------------------------------------------------------------
  # ● 敗北の処理
  #--------------------------------------------------------------------------
  alias process_defeat_n01 process_defeat
  def process_defeat
    $game_switches[50] = false
    @bitmap_name.dispose if @bitmap_name
    @friend_window.dispose if @friend_window != nil#敗北
    for member in $game_party.members
      @spriteset.set_stand_by_action(member.actor?, member.index)
    end
    process_defeat_n01
#    $game_switches[36] = true
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウインドウの表示
  #--------------------------------------------------------------------------
  def pop_help(obj)
    return if obj.extension.include?("HELPHIDE")
    @help_window = Window_Help.new if @help_window == nil
    @help_window.set_text(obj.name, 1)
    @help_window.visible = true
  end
  #--------------------------------------------------------------------------
  # ● 情報表示ビューポートの移動
  #--------------------------------------------------------------------------
  def move1_info_viewport
    @info_viewport.ox = 128
    loop do
      update_basic
      @info_viewport.ox -= 8
      @party_command_window.x -= 8
      @actor_command_window.x += 8
      break if @info_viewport.ox == 64
    end  
  end
  #--------------------------------------------------------------------------
  # ● 情報表示ビューポートの移動
  #--------------------------------------------------------------------------
  def move2_info_viewport
    @info_viewport.ox = 64
    loop do
      update_basic
      @info_viewport.ox -= 8
      @party_command_window.x += 8
      @actor_command_window.x -= 8
      break if @info_viewport.ox == 0
    end  
  end
  #--------------------------------------------------------------------------
  # ● 次のアクターのコマンド入力へ
  #--------------------------------------------------------------------------
  alias next_actor_n01 next_actor
  def next_actor
    # 動けるキャラのみコマンドアクションを
    if @active_battler != nil && @active_battler.inputable? && @active_battler.actor?
      @spriteset.set_action(true, @actor_index,@active_battler.command_a)
    end
    # 最後のアクターの場合、アクションが終わるまで待つ
    @wait_count = 32 if @actor_index == $game_party.members.size-1 
    next_actor_n01
    # 動けるキャラのみコマンドアクションを
    if @active_battler != nil && @active_battler.inputable? && @active_battler.actor?
      @spriteset.set_action(true, @actor_index,@active_battler.command_b)
    end
  end
  #--------------------------------------------------------------------------
  # ● 前のアクターのコマンド入力へ
  #--------------------------------------------------------------------------
  alias prior_actor_n01 prior_actor
  def prior_actor
    # 動けるキャラのみコマンドアクションを
    if @active_battler != nil && @active_battler.inputable? && @active_battler.actor?
      @active_battler.action.clear
      @spriteset.set_action(true, @actor_index,@active_battler.command_a)
    end
    prior_actor_n01
    # 動けるキャラのみコマンドアクションを
    if @active_battler != nil && @active_battler.inputable? && @active_battler.actor?
      @active_battler.action.clear
      @spriteset.set_action(true, @actor_index,@active_battler.command_b)
    end
  end  
  #--------------------------------------------------------------------------
  # ● ターゲット選択の開始  ※再定義
  #--------------------------------------------------------------------------
  def start_target_enemy_selection
    @bitmap_name = Sprite.new
    @bitmap_name.bitmap = Cache.system("Battle_ItemSelectEnemy")
    @bitmap_name.opacity = 0
    start_target_selection
  end
  #--------------------------------------------------------------------------
  # ● ターゲット選択の開始  ※再定義
  #--------------------------------------------------------------------------
  def start_target_actor_selection
    @bitmap_name = Sprite.new
    @bitmap_name.bitmap = Cache.system("Battle_ItemSelectActor")
    @bitmap_name.opacity = 0
    #@bf.opacity = 155 if actor###
    start_target_selection(true)
  end
  #--------------------------------------------------------------------------
  # ● ターゲット選択の開始
  #--------------------------------------------------------------------------
  def start_target_selection(actor = false)
    members = $game_party.members if actor
    members = $game_troop.members unless actor
    #@bf.opacity = 155 if actor
    # カーソルスプライトの作成
    @cursor = Sprite.new
    @cursor.bitmap = Cache.character("cursor")
    @cursor.src_rect.set(0, 0, 32, 32)
    @cursor_flame = 0
    @cursor.x = -200
    @cursor.y = -200
    @cursor.ox = @cursor.width
    @cursor.oy = @cursor.height
    # ターゲット名を表示するヘルプウインドウを作成
    @help_windowx.visible = false if @help_windowx != nil
    @help_window.visible = false if @help_window != nil
    @help_window2 = Window_Help.new if @help_window2 == nil
    # 不要なウインドウを消す
    @actor_command_window.active = false
    @skill_window.visible = false if @skill_window != nil
    @item_window.visible = false if @item_window != nil
    # 存在しているターゲットで最も番号の低い対象を最初に指すように
    @index = 0
    @max_index = members.size - 1
    # アクターは戦闘不能者でもターゲットできるようにエネミーと区別
    unless actor
      members.size.times do
        break if members[@index].exist?
        #break if !members[@index].special_target? && $game_troop.exist_target_ok###
        @index += 1
      end
    end  
#     @help_window2.set_text(members[@index].name, 1) # 3.4a
    @help_window2.set_text_n01add(members[@index])
    select_member(actor)
  end
  #--------------------------------------------------------------------------
  # ● ターゲット選択
  #--------------------------------------------------------------------------
  def select_member(actor = false)
    members = $game_party.members if actor
    members = $game_troop.members unless actor
    loop do
      update_basic
      @cursor_flame = 0 if @cursor_flame == 30
      @cursor.src_rect.set(0,  0, 32, 32) if @cursor_flame == 29
      @cursor.src_rect.set(0, 32, 32, 32) if @cursor_flame == 15
      point = @spriteset.set_cursor(actor, @index)
      # point is the screen coordinate of the target
      @cursor.x = point[0] # Cursor X
      @cursor.y = point[1] # Cursor Y
      @cursor_flame += 1
      if Input.trigger?(Input::B)
        Sound.play_cancel
        end_target_selection
        break
      elsif Input.trigger?(Input::C)
        Sound.play_decision
        @active_battler.action.target_index = @index # if you get an error on this line, remove the Enemy Gauge Add-on script
        end_target_selection
        end_skill_selection
        end_item_selection
        next_actor
        break
      end
      if Input.repeat?(Input::LEFT)
        if actor
          cursor_down(members, actor) if $back_attack
          cursor_up(members, actor) unless $back_attack
        else
          cursor_up(members, actor) if $back_attack
          cursor_down(members, actor) unless $back_attack
        end  
      end
      if Input.repeat?(Input::RIGHT)
        if actor
          cursor_up(members, actor) if $back_attack
          cursor_down(members, actor) unless $back_attack
        else
          cursor_down(members, actor) if $back_attack
          cursor_up(members, actor) unless $back_attack
        end 
      end
      cursor_up(members, actor) if Input.repeat?(Input::UP)
      cursor_down(members, actor) if Input.repeat?(Input::DOWN)
    end
  end
  #--------------------------------------------------------------------------
  # ● Move Cursor Target Up
  #--------------------------------------------------------------------------
  def cursor_up(members, actor)
    Sound.play_cursor
    members.size.times do
      @index += members.size - 1
      @index %= members.size
      break if actor
      break if members[@index].exist?
    end
    @help_window2.set_text_n01add(members[@index])
  end
  #--------------------------------------------------------------------------
  # ● Move Cursor Target Down
  #--------------------------------------------------------------------------
  def cursor_down(members, actor)
    Sound.play_cursor
    members.size.times do
      @index += 1
      @index %= members.size
      break if actor
      break if members[@index].exist? && !actor
    end
    @help_window2.set_text_n01add(members[@index])
  end
  #--------------------------------------------------------------------------
  # ● ターゲット選択の終了
  #--------------------------------------------------------------------------
  def end_target_selection
    @actor_command_window.active = true if @actor_command_window.index == 0
    @skill_window.visible = true if @skill_window != nil
    #@help_windowx.visible = true if @skill_window != nil
    @item_window.visible = true if @item_window != nil
    @cursor.dispose
    @cursor = nil
    if @help_window2 != nil  
      @help_window2.dispose
      @help_window2 = nil
    end  
    #@help_window2.visible = false###
    @help_window.visible = true if @help_window != nil
    #@help_windowx.visible = true if @help_windowx != nil
  end
  #--------------------------------------------------------------------------
  # ● 逃走の処理  ※再定義
  #--------------------------------------------------------------------------
  def process_escape
    @info_viewport.visible = false
    @message_window.visible = true
    text = sprintf(Vocab::EscapeStart, $game_party.name)
    $game_message.texts.push(text)
    if $game_troop.preemptive
      success = true
    else
      success = (rand(100) < @escape_ratio)
    end
    Sound.play_escape
    # 動けないアクターを除いて逃走成功アクション
    if success
      for actor in $game_party.members
        unless actor.restriction >= 4
          @spriteset.set_action(true, actor.index,actor.run_success)
        end
      end  
      wait_for_message
      battle_end(1)
#      $game_switches[36] = true
    # 動けないアクターを除いて逃走失敗アクション
    else
      for actor in $game_party.members
        unless actor.restriction >= 4
          @spriteset.set_action(true, actor.index,actor.run_ng)
        end
      end
      @escape_ratio += 10
      $game_message.texts.push('\.' + Vocab::EscapeFailure)
      wait_for_message
      $game_party.clear_actions
      start_main
    end
  end
  #--------------------------------------------------------------------------
  # ● 勝利の処理
  #--------------------------------------------------------------------------
  alias process_victory_n01 process_victory
  def process_victory
    @status_window.visible = true
    @message_window.visible = false
    # ボスコラプスはウエイトを長く挟む
    for enemy in $game_troop.members
      break boss_wait = true if enemy.collapse_type == 3
    end
    wait(440) if boss_wait
    wait(N01::WIN_WAIT) unless boss_wait
    # 動けないアクターを除いて勝利アクション
    for actor in $game_party.members
      unless actor.restriction >= 4
        @spriteset.set_action(true, actor.index,actor.win)
      end
    end
    process_victory_n01
#    $game_switches[36] = true
  end
  #--------------------------------------------------------------------------
  # ● 戦闘処理の実行開始  ※再定義
  #--------------------------------------------------------------------------
  def start_main
    $game_troop.increase_turn
    @info_viewport.visible = true
    @info_viewport.ox = 0
    @party_command_window.active = false
    @actor_command_window.active = false
    @status_window.index = @actor_index = -1
    @active_battler = nil
    @message_window.clear
    $game_troop.make_actions
    make_action_orders
    # 情報表示ビューポートの移動
    move1_info_viewport
    # スキル名を表示するヘルプウインドウを作成
    @help_window = Window_Help.new
    @help_window.visible = false
    process_battle_event
  end
  #--------------------------------------------------------------------------
  # ● バトルイベントの処理  ※再定義
  #--------------------------------------------------------------------------
  def process_battle_event
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
      if $game_troop.forcing_battler != nil 
        process_action
      end 
      return unless $game_troop.interpreter.running?
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  # ● 行動順序作成
  #--------------------------------------------------------------------------
  alias make_action_orders_n01 make_action_orders
  def make_action_orders
    make_action_orders_n01
    # エネミーの行動回数チェック
    for enemy in $game_troop.members
      enemy.act_time = 0
      if enemy.action_time[0] != 1
        action_time = 0
        # 確率から回数を取得
        for i in 1...enemy.action_time[0]
          action_time += 1 if rand(100) < enemy.action_time[1]
        end
        enemy.act_time = action_time
        action_time.times do
          enemy_order_time(enemy)
          action_time -= 1
          break if action_time == 0
        end  
        enemy.adj_speed = nil
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● エネミーの行動回数作成
  #--------------------------------------------------------------------------
  def enemy_order_time(enemy)
    enemy.make_action_speed2(enemy.action_time[2])
    select_time = 0
    for member in @action_battlers
      select_time += 1
      break @action_battlers.push(enemy) if member.action.speed < enemy.adj_speed
      break @action_battlers.push(enemy) if select_time == @action_battlers.size
    end
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行
  #--------------------------------------------------------------------------
  alias execute_action_n01 execute_action
  def execute_action
    # スキル、アイテム拡張で行動前にフラッシュさせない設定があるなら
    if @active_battler.action.kind != 0
      obj = @active_battler.action.skill if @active_battler.action.kind == 1
      obj = @active_battler.action.item if @active_battler.action.kind == 2
      if obj.extension.include?("NOFLASH")
        @active_battler.white_flash = false
      end  
    end 
    # バトラーをアクティブ化
    @active_battler.active = true
    # 強制行動中のスキル派生
    @active_battler.derivation = 0 if @active_battler.action.forcing
    execute_action_n01
    # スキル派生がある場合、行動続行
    if @active_battler.derivation != 0
      @active_battler.action.kind = 1
      @active_battler.action.skill_id = @active_battler.derivation
      # we dont need the derivation variable anymore, its already been set
      @active_battler.derivation = 0 # Derivation fix, 1.1e
      @action_battlers.unshift(@active_battler)
      return process_action
    end
    # 複数回行動のエネミーがいる場合、次の行動を決定
    if !@active_battler.actor? && @active_battler.act_time != 0
      @active_battler.make_action
      @active_battler.act_time -= 1
    end
  end
  #--------------------------------------------------------------------------
  # ● ターン終了  ※再定義
  #--------------------------------------------------------------------------
  def turn_end
    for member in $game_party.members + $game_troop.members
      member.clear_action_results
      next unless member.exist?
      member.slip_damage = false
      actor = member.actor?
      damage = 0
      slip_pop = true
      slip_dead = true
      # 0ターン解除のステートがあるかチェック
      for state in member.states
        member.remove_state(state.id) if state.extension.include?("ZEROTURNLIFT")
        # スリップダメージ実行　state = [ 対象, 定数, 割合, POP, 戦闘不能許可]
        next unless state.slip_damage #state.extension.include?("SLIPDAMAGE")
        for ext in state.slip_extension
          if ext[0] == "hp"
            base_damage = ext[1] + member.maxhp * ext[2] / 100
            damage += base_damage #+ base_damage / 100 # * (rand(5) - rand(5)) / 100
            slip_pop = ext[3] unless ext[3] == nil
            slip_dead = ext[4] unless ext[4] == nil
            slip_damage_flug = true
            member.slip_damage = true
          end
        end  
      end
      # デフォルトのスリップダメージ
#      if member.slip_damage? && member.exist? && !slip_damage_flug
#        damage += member.apply_variance(member.maxhp / 10, 10)
#        slip_dead = false
#        slip_pop = true
#        slip_damage_flug = true
#        member.slip_damage = true
#      end
      damage = member.hp - 1 if damage >= member.hp && slip_dead = false
      member.hp -= damage
      @spriteset.set_damage_pop(actor, member.index, damage) if slip_pop
      member.perform_collapse if member.dead? && member.slip_damage
      member.clear_action_results
    end
    @status_window.refresh
    # HPとMPのタイミングをずらす
    wait(55) if slip_damage_flug
    slip_damage_flug = false
    for member in $game_party.members + $game_troop.members
      member.clear_action_results
      next unless member.exist?
      actor = member.actor?
      mp_damage = 0
      for state in member.states
        next unless state.slip_damage #state.extension.include?("SLIPDAMAGE")
        for ext in state.slip_extension
          if ext[0] == "mp"
            base_damage = ext[1] + member.maxmp * ext[2] / 100
            mp_damage += base_damage #+ base_damage / 100 # * (rand(5) - rand(5)) / 100
            slip_pop = ext[2]
            slip_damage_flug = true
          end
        end
        member.mp_damage = mp_damage
        member.mp -= mp_damage
        @spriteset.set_damage_pop(actor, member.index, mp_damage) if slip_pop
      end   
      member.clear_action_results
    end
    @status_window.refresh
    # ダメージと回復のタイミングをずらす
    wait(55) if slip_damage_flug
    # 自動回復があるか
    for member in $game_party.members
      if member.auto_hp_recover and member.exist?
        plus_hp = member.maxhp / 20
        member.hp += plus_hp
        @spriteset.set_damage_pop(true, member.index, plus_hp * -1)
        plus_hp_flug = true
      end
      member.clear_action_results
    end
    @status_window.refresh
    wait(55) if plus_hp_flug
    @help_window.dispose if @help_window != nil
    @help_windowbg.visible = false
    #@help_window.visible = false###
    @help_window = nil
    move2_info_viewport
    $game_troop.turn_ending = true
    $game_troop.preemptive = false
    $game_troop.surprise = false
    process_battle_event
    $game_troop.turn_ending = false
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行 : 攻撃  ※再定義
  #--------------------------------------------------------------------------
  def execute_action_attack    
    if @active_battler.actor?     
      if @active_battler.weapon_id == 0
        action = @active_battler.non_weapon 
        # 行動中に死なないようメンバー全員を不死身化
        immortaling
      else  
        action = $data_weapons[@active_battler.weapon_id].base_action
        # 戦闘不能付与の武器で不死身設定を分岐
        if $data_weapons[@active_battler.weapon_id].state_set.include?(1)
          for member in $game_party.members + $game_troop.members
            next if member.immortal
            next if member.dead?
            member.dying = true
          end
        else
          immortaling 
        end 
      end  
    else
      if @active_battler.weapon == 0
        action = @active_battler.base_action
        immortaling
      else       
        action = $data_weapons[@active_battler.weapon].base_action
        if $data_weapons[@active_battler.weapon].state_set.include?(1)
          for member in $game_party.members + $game_troop.members
            next if member.immortal
            next if member.dead?
            member.dying = true
          end
        else
          immortaling 
        end
      end  
    end 
    target_decision
    @spriteset.set_action(@active_battler.actor?, @active_battler.index, action)
    playing_action
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行 : 防御  ※再定義
  #--------------------------------------------------------------------------
  def execute_action_guard
    @help_window.set_text(N01::GUARD_HELP_TEXT, 1)
    @help_window.visible = true
    # バトラーのアクティブ化を解除
    @active_battler.active = false
    wait(45)
    @help_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行 : 逃走
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
    @help_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行 : 待機  ※再定義
  #--------------------------------------------------------------------------
  def execute_action_wait
    # バトラーのアクティブ化を解除
    @active_battler.active = false
    wait(45)
  end   
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行 : スキル  ※再定義
  #--------------------------------------------------------------------------
  def execute_action_skill
    skill = @active_battler.action.skill
    return unless @active_battler.action.valid? # 3.3d, Force action bug fix
    # 戦闘不能付与のスキルで不死身設定を分岐
    if skill.plus_state_set.include?(1)
      for member in $game_party.members + $game_troop.members
        next if member.immortal
        next if member.dead?
        member.dying = true
      end
    else
      # 行動中に死なないようメンバー全員を不死身化
      immortaling 
    end
    # ターゲット決定
    target_decision(skill)
    # アクション開始
    @spriteset.set_action(@active_battler.actor?, @active_battler.index, skill.base_action)
    # ヘルプウインドウにスキル名表示
    pop_help(skill)
    ##################
#    if dai_surr_skill?
#    skill_1 = @active_battler.action.skill
    # メモ欄を取得
#    a = dai_surr_skill_note_include(skill_1.note)
#    return if a == false
    # 効果範囲、周囲効果スキル、時間差を取得
#    ra, ra_id, n = [a[1].to_i, a[2].to_i], a[3].to_i, a[4].to_i
#    skill_2 = $data_skills[ra_id]
#    target = @active_battler.action.make_targets[0]
    # 周囲対象取得
#    if @active_battler.actor?
#      s_t = $game_troop.surr_enemy_get(target, ra)
#    else
#      s_t = $game_party.surr_actor_get(target)
#    end
#    id_1, id_2 = skill_1.animation_id, skill_2.animation_id
    # 時間差アニメの表示
    #display_surr_skill_animation(target, id_1, s_t, id_2, n)
#    display_surr_skill_animation(target, id_2, s_t, id_2, n)
    # 行動結果の反映（中心ターゲット）
#    @surr_skill = true
#    for target in s_t
#      target.skill_effect(@active_battler, skill_2)
      #display_action_effects(target, skill_2)
      #target.play = ["受傷後退","20","RESET"]
      #start_action(target.hit)
#      target.force_damage = target.hp_damage
#    end
#    @surr_skill = false
    #wait(30) if DAI_Surr_Skill::D
#    end
    ##################
    # アクション中
    playing_action
    # Calculate skill cost and remove MP. 3.4a
#    @active_battler.mp -= @active_battler.calc_mp_cost(skill)
    # ステータスウインドウをリフレッシュ
    @status_window.refresh
    # コモンイベント取得
    $game_temp.common_event_id = skill.common_event_id
  end 
  #--------------------------------------------------------------------------
  # ● 戦闘行動の実行 : アイテム  ※再定義
  #--------------------------------------------------------------------------
  def execute_action_item
    item = @active_battler.action.item
    # 戦闘不能付与のアイテムで不死身設定を分岐
    if item.plus_state_set.include?(1)
      for member in $game_party.members + $game_troop.members
        next if member.immortal
        next if member.dead?
        member.dying = true
      end
    else
      # 行動中に死なないようメンバー全員を不死身化
      immortaling 
    end
    $game_party.consume_item(item)
    target_decision(item)
    @spriteset.set_action(@active_battler.actor?, @active_battler.index, item.base_action)
    pop_help(item)
    playing_action
    $game_temp.common_event_id = item.common_event_id
  end
  #--------------------------------------------------------------------------
  # ● ターゲット決定
  #--------------------------------------------------------------------------
  def target_decision(obj = nil)
    @targets = @active_battler.action.make_targets
    # ターゲットがいない場合、アクション中断
    if @targets.size == 0
      action = @active_battler.recover_action
      @spriteset.set_action(@active_battler.actor?, @active_battler.index, action)
    end
    if obj != nil
      # デフォルトの複数回攻撃が設定されていれば単体ターゲットに変換
      if obj.for_two? or obj.for_three? or obj.dual?
        @targets = [@targets[0]]
      end
      # ランダムターゲットの場合、一体を選択しランダム範囲を保持
      if obj.extension.include?("RANDOMTARGET")
        randum_targets = @targets.dup
        @targets = [randum_targets[rand(randum_targets.size)]]
      end
    end
    # ターゲット情報をバトラースプライトに送る
    @spriteset.set_target(@active_battler.actor?, @active_battler.index, @targets)
  end   
  #--------------------------------------------------------------------------
  # ● アクション実行中
  #--------------------------------------------------------------------------
  def playing_action
    loop do
      update_basic
      # Action order is stored from the active battler
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
  # ● 個別処理
  #--------------------------------------------------------------------------
  def individual
    # ターゲット情報を保持
    @individual_target = @targets
    @stand_by_target = @targets.dup
  end 
  #--------------------------------------------------------------------------
  # ● コラプス禁止
  #--------------------------------------------------------------------------
  def immortaling # for sideview 2
    for member in $game_party.members + $game_troop.members
      # everyone currently in the battle
      next if member.dead? # skip if they are dead
      member.set_temp_immortal
      # set the immortal flag
    end  
  end
  #--------------------------------------------------------------------------
  # ● コラプス許可
  #--------------------------------------------------------------------------
  def unimmortaling
    # 個別処理中はコラプス許可しない
    return if @active_battler.individual
    # 全員の不死身化解除(イベント等で不死身設定がされていれば除く)
    for member in $game_party.members + $game_troop.members
      if member.dying
        member.dying = false
        if member.dead? or member.hp == 0
          member.add_state(1)
          member.perform_collapse
        end
      end
      next if member.non_dead
      next if member.dead?
      member.set_temp_immortal(false) # only changed this line, 3.3c
      member.add_state(1) if member.hp == 0
      member.perform_collapse
    end
    # この時点で待機アクションに即反映させる
    @targets = @stand_by_target if @stand_by_target != nil
    return if @targets == nil or @targets.size == 0
    for target in @targets
      @spriteset.set_stand_by_action(target.actor?, target.index)
      # 自動復活チェック
      next unless target.hp == 0
      resurrection(target)
    end  
  end
  #--------------------------------------------------------------------------
  # ● 自動復活
  #--------------------------------------------------------------------------
  def resurrection(target)
    for state in target.states
      for ext in state.extension
        name = ext.split('')
        next unless name[0] == "A"
        wait(50)
        name = name.join
        name.slice!("AUTOLIFE/")
        target.hp = target.maxhp * name.to_i / 100
        target.remove_state(1)
        target.remove_state(state.id)
        target.animation_id = N01::RESURRECTION
        target.animation_mirror = true if $back_attack
        @status_window.refresh
        wait($data_animations[N01::RESURRECTION].frame_max * 4)
      end  
    end
  end
  #--------------------------------------------------------------------------
  # ● 魔法反射・無効
  #--------------------------------------------------------------------------
  def magic_reflection(target, obj)
    return if obj.physical_attack
    for state in target.states
      for ext in state.extension
        name = ext.split('')
        next unless name[0] == "M"
        if name[3] == "R"
          name = name.join
          name.slice!("MAGREFLECT/")
          target.animation_id = name.to_i
          target.animation_mirror = true if $back_attack
          @reflection = true
        else
          name = name.join
          name.slice!("MAGNULL/")
          target.animation_id = name.to_i
          target.animation_mirror = true if $back_attack
          @invalid = true
        end  
      end  
    end
  end
  #--------------------------------------------------------------------------
  # ● 物理反射・無効
  #--------------------------------------------------------------------------
  def physics_reflection(target, obj)
    return if obj != nil && !obj.physical_attack
    for state in target.states
      for ext in state.extension
        name = ext.split('')
        next unless name[0] == "P"
        if name[3] == "R"
          name = name.join
          name.slice!("PHYREFLECT/")
          target.animation_id = name.to_i
          target.animation_mirror = true if $back_attack
          @reflection = true
        else
          name = name.join
          name.slice!("PHYNULL/")
          target.animation_id = name.to_i
          target.animation_mirror = true if $back_attack
          @invalid = true
        end 
      end  
    end
  end
  #--------------------------------------------------------------------------
  # ● Absorb Skill MP/HP Cost
  #--------------------------------------------------------------------------
  def absorb_cost(target, obj)
    for state in target.states
      if state.extension.include?("COSTABSORB")
        cost = @active_battler.calc_mp_cost(obj)
        if $imported["MPCostAlter"] # KGC_MPCostAlter
          hp_cost = @active_battler.calc_hp_cost(obj)
          # Return cost of skill if has an HP cost
          return target.hp += hp_cost if hp_cost > 0
        end
        # Return MP cost of skill that battler was hit by
        return target.mp += cost
      end  
    end 
  end
  #--------------------------------------------------------------------------
  # ● 吸収処理
  #--------------------------------------------------------------------------
  def absorb_attack(obj, target, index, actor)
    absorb = target.hp_damage
    absorb = target.mp_damage if target.mp_damage != 0
    # ターゲットが複数同時の吸収処理
    @wide_attack = true if obj.scope == 2 or obj.scope == 4 or obj.scope == 6 or obj.extension.include?("TARGETALL")
    if @wide_attack && @absorb == nil && @targets.size != 1
      # 吸収した分を戻す
      @active_battler.hp -= @active_battler.hp_damage
      @active_battler.mp -= @active_battler.mp_damage
      # 後で吸い戻す数値として加算
      @absorb = absorb
      @absorb_target_size = @targets.size - 2
    elsif @absorb != nil && @absorb_target_size > 0
      @active_battler.hp -= @active_battler.hp_damage
      @active_battler.mp -= @active_battler.mp_damage
      @absorb += absorb
      @absorb_target_size -= 1
    # 複数ターゲットの最終吸収処理
    elsif @absorb != nil
      # 吸収した分を戻す
      @active_battler.hp -= @active_battler.hp_damage
      @active_battler.mp -= @active_battler.mp_damage
      @absorb += absorb
      # ここで全吸収分を反映
      @active_battler.hp_damage = -@absorb 
      @active_battler.mp_damage = -@absorb if target.mp_damage != 0
      @active_battler.hp -= @active_battler.hp_damage
      @active_battler.mp -= @active_battler.mp_damage
      # 吸収量が0の場合の吸収者側処理
      absorb_action = ["absorb", nil, false] if @absorb == 0
      absorb_action = [nil, nil, false] if @absorb != 0
      @spriteset.set_damage_action(actor, index, absorb_action)
      @active_battler.perform_collapse
      @absorb = nil
      @absorb_target_size = nil
    # 単体での吸収処理
    else
      # 吸収量が0の場合の吸収者側処理
      absorb_action = ["absorb", nil, false] if absorb == 0
      absorb_action = [nil, nil, false] if absorb != 0
      @spriteset.set_damage_action(actor, index, absorb_action)
      # 逆吸収でHP0になった場合
      @absorb_dead = true if @active_battler.hp == 0 && !@active_battler.non_dead
    end
    # 吸収量が0の場合の対象者側処理
    return 0 if absorb == 0
  end
  #--------------------------------------------------------------------------
  # ● アクション終了
  #--------------------------------------------------------------------------
  def action_end
    # 初期化
    @individual_target = nil
    @help_window.visible = false if @help_window != nil && @help_window.visible
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
  # ● ダメージ処理
  #--------------------------------------------------------------------------
  def damage_action(action)
    # 個別処理の場合ターゲットを一つずつ抜き出す
    @targets = [@individual_target.shift] if @active_battler.individual
    # スキルの場合
    if @active_battler.action.skill?
      obj = @active_battler.action.skill
      for target in @targets
        return if target == nil 
        return if target.dead? && !obj.for_dead_friend?
        # HPが0なら戦闘不能復活以外はミスしない
        target.revival = true if obj.for_dead_friend?
        if target.hp == 0 && !obj.for_dead_friend?
          target.perfect_skill_effect(@active_battler, obj)
        # 必中確認
        elsif obj.extension.include?("PERFECTHIT")
          target.perfect_skill_effect(@active_battler, obj)
        else
          # 反射確認
          magic_reflection(target, obj) unless obj.extension.include?("IGNOREREFLECT")
          physics_reflection(target, obj) unless obj.extension.include?("IGNOREREFLECT")
          # ダメージ計算
          target.skill_effect(@active_battler, obj) unless @reflection or @invalid
        end  
        pop_damage(target, obj, action) unless @reflection or @invalid
        # コスト吸収確認
        absorb_cost(target, obj)
        # 反射アクション取得
        @active_battler.reflex = action if @reflection
        @reflection = false
        @invalid = false
      end
    # アイテムの場合
    elsif @active_battler.action.item?
      obj = @active_battler.action.item
      for target in @targets
        return if target == nil 
        return if target.dead? && !obj.for_dead_friend?
        target.revival = true if obj.for_dead_friend?
        if target.hp == 0 && !obj.for_dead_friend?
          target.perfect_item_effect(@active_battler, obj)
        elsif obj.extension.include?("PERFECTHIT")
          target.perfect_item_effect(@active_battler, obj)
        else
          magic_reflection(target, obj) unless obj.extension.include?("IGNOREREFLECT")
          physics_reflection(target, obj) unless obj.extension.include?("IGNOREREFLECT")
          target.item_effect(@active_battler, obj) unless @reflection or @invalid
        end
        pop_damage(target, obj, action) unless @reflection or @invalid
        @active_battler.reflex = action if @reflection
        @reflection = false
        @invalid = false
      end
    # 通常攻撃の場合
    else 
      for target in @targets
        return if target == nil or target.dead?
        physics_reflection(target, nil)
        target.perfect_attack_effect(@active_battler) if target.hp <= 0
        target.attack_effect(@active_battler) unless target.hp <= 0 or @reflection or @invalid
        pop_damage(target, nil, action) unless @reflection or @invalid
        # 反射アクション取得
        @active_battler.reflex = action if @reflection
        @reflection = false
        @invalid = false
      end
    end
    # ステータスウインドウをリフレッシュ
    @status_window.refresh
    # 連続行動中のランダムターゲットを考慮し、すぐに次のターゲットを選択
    return if obj == nil
    target_decision(obj) if obj.extension.include?("RANDOMTARGET")
  end
  #--------------------------------------------------------------------------
  # ● Pop Damage  action = [Animation ID, Invert Flag, Allow Reaction]
  #--------------------------------------------------------------------------
  def pop_damage(target, obj, action)
    index = @active_battler.index
    actor = @active_battler.actor?
    if obj != nil
      # スキルやアイテムが吸収属性なら
      absorb = absorb_attack(obj, target, index, actor) if obj.absorb_damage
      action.push(true) if absorb == 0
      # 拡張設定でダメージアクション禁止なら
      action[2] = false if obj.extension.include?("NOOVERKILL")
    end
    # 対象のリアクション
    @spriteset.set_damage_action(target.actor?, target.index, action)
  end
end  
#==============================================================================
# ■ Game_BattleAction
#------------------------------------------------------------------------------
# 　戦闘行動を扱うクラスです。
#==============================================================================
class Game_BattleAction
  #--------------------------------------------------------------------------
  # * Game_BattleAction#valid? is no longer redefined
  #--------------------------------------------------------------------------

  #--------------------------------------------------------------------------
  # * Create Target Array -redefinition
  #--------------------------------------------------------------------------
  def make_targets
    if attack?
      return make_attack_targets
    elsif skill?
      targets = make_obj_targets(skill)
      targets = make_obj_targets2(skill, targets) if skill.extension != ["NONE"]
      return targets
    elsif item?
      targets = make_obj_targets(item)
      targets = make_obj_targets2(item, targets) if item.extension != ["NONE"]
      return targets
    end
  end
  #--------------------------------------------------------------------------
  # ● スキルまたはアイテムのターゲット作成の拡張
  #--------------------------------------------------------------------------
  def make_obj_targets2(obj, targets)
    if obj.extension.include?("TARGETALL")
      targets = []
      targets += opponents_unit.existing_members
      targets += friends_unit.existing_members
    end
    if obj.extension.include?("OTHERS")
      targets.delete($game_party.members[battler.index]) if battler.actor?
      targets.delete($game_troop.members[battler.index]) unless battler.actor?
    end
    return targets.compact
  end
######################  
  def dai_surr_skill_note_include(note)
    return false
  end
#####################
  
end
#==============================================================================
# ■ Sprite_Base
#------------------------------------------------------------------------------
#  A sprite class with animation display processing added.
#==============================================================================
class Sprite_Base < Sprite
  #--------------------------------------------------------------------------
  # ● Update Animation -aliased
  #     Allows animation to follow target if animation position is "Center"
  #--------------------------------------------------------------------------
  alias update_animation_n01 update_animation
  def update_animation
    if @animation.position == 1 # 3.4a
      @animation_ox = x - ox + width / 2
      @animation_oy = y - oy + height / 2
    end
    update_animation_n01
  end 
end  
#==============================================================================
# ■ Spriteset_Battle
#------------------------------------------------------------------------------
#  This class brings together battle screen sprites. It's used within the
# Scene_Battle class.
#==============================================================================
class Spriteset_Battle
  #--------------------------------------------------------------------------
  # ● エネミースプライトの作成
  #--------------------------------------------------------------------------
  def create_enemies
    @enemy_sprites = []
    for i in 0...$game_troop.members.size
      @enemy_sprites.push(Sprite_Battler.new(@viewport1, $game_troop.members[i]))
      @enemy_sprites[i].opacity = 0 if $game_troop.members[i].hidden
    end
  end
  #--------------------------------------------------------------------------
  # ● アクタースプライトの作成
  #--------------------------------------------------------------------------
  def create_actors
    @actor_sprites = []
    # メンバー最大数スプライトを用意
    for i in 0...N01::MAX_MEMBER
      @actor_sprites.push(Sprite_Battler.new(@viewport1, $game_party.members[i]))
      if $game_party.members[i] != nil 
        @actor_sprites[i].make_battler
        @actor_sprites[i].first_action
      end
    end 
  end
  #--------------------------------------------------------------------------
  # * Create Battlefloor Sprite -aliased
  #--------------------------------------------------------------------------
  alias create_battlefloor_n01 create_battlefloor
  def create_battlefloor
    create_battlefloor_n01
    @battlefloor_sprite.x = N01::FLOOR[0]
    @battlefloor_sprite.y = N01::FLOOR[1]
    @battlefloor_sprite.opacity = N01::FLOOR[2]
    # Mirror BattleFloor and Battleback when a surprise attack
    back_attack
    if $back_attack
      @battlefloor_sprite.mirror = true
#      @battleback_sprite.mirror = false#true
      $game_troop.surprise = true
    else  
      $game_troop.surprise = false
    end  
  end  
  #--------------------------------------------------------------------------
  # ● Back Attack
  #--------------------------------------------------------------------------
  def back_attack  
    # 強制バックアタックならフラグオン
    for i in 0...N01::BACK_ATTACK_SWITCH.size
      return $back_attack = true if $game_switches[N01::BACK_ATTACK_SWITCH[i]]
    end
    # 不意打ちが発生していなければ処理を中断
    return $back_attack = false unless $game_troop.surprise && N01::BACK_ATTACK
    # 装備等によるバックアタック無効化をチェック
    for actor in $game_party.members
      return $back_attack = false if N01::NON_BACK_ATTACK_WEAPONS.include?(actor.weapon_id)
      return $back_attack = false if N01::NON_BACK_ATTACK_ARMOR1.include?(actor.armor1_id)
      return $back_attack = false if N01::NON_BACK_ATTACK_ARMOR2.include?(actor.armor2_id)
      return $back_attack = false if N01::NON_BACK_ATTACK_ARMOR3.include?(actor.armor3_id)
      return $back_attack = false if N01::NON_BACK_ATTACK_ARMOR4.include?(actor.armor4_id)
      for i in 0...N01::NON_BACK_ATTACK_SKILLS.size
        return $back_attack = false if actor.skill_id_learn?(N01::NON_BACK_ATTACK_SKILLS[i])
      end  
    end
    # バックアタック発生
    $back_attack = true
  end
  #--------------------------------------------------------------------------
  # ● Update Actors  -redefined
  #--------------------------------------------------------------------------
  def update_actors
    for i in 0...@actor_sprites.size
      if $party_change
        $party_change = false
        dispose_actors
        return create_actors
      end 
      if @actor_sprites[i].battler.id != $game_party.members[i].id
        dispose_actors
        return create_actors
      end
      @actor_sprites[i].update
    end
  end
  #--------------------------------------------------------------------------
  # ● ダメージアクションセット　
  #--------------------------------------------------------------------------  
  def set_damage_action(actor, index, action)
    @actor_sprites[index].damage_action(action) if actor
    @enemy_sprites[index].damage_action(action) unless actor
  end
  #--------------------------------------------------------------------------
  # ● ダメージPOPセット　
  #--------------------------------------------------------------------------  
  def set_damage_pop(actor, index, damage)
    @actor_sprites[index].damage_pop(damage) if actor
    @enemy_sprites[index].damage_pop(damage) unless actor
  end
  #--------------------------------------------------------------------------
  # ● ターゲットセット
  #--------------------------------------------------------------------------  
  def set_target(actor, index, target)
    @actor_sprites[index].get_target(target) if actor
    @enemy_sprites[index].get_target(target) unless actor
  end
  #--------------------------------------------------------------------------
  # ● アクションセット
  #--------------------------------------------------------------------------  
  def set_action(actor, index, kind)
    @actor_sprites[index].start_action(kind) if actor
    @enemy_sprites[index].start_action(kind) unless actor
  end  
  #--------------------------------------------------------------------------
  # ● 待機アクションセット
  #--------------------------------------------------------------------------  
  def set_stand_by_action(actor, index)
    @actor_sprites[index].push_stand_by if actor
    @enemy_sprites[index].push_stand_by unless actor
  end  
  #--------------------------------------------------------------------------
  # ● カーソル移動のセット
  #--------------------------------------------------------------------------  
  def set_cursor(actor, index)
    return [@actor_sprites[index].x + N01::CURSOR_X_PLUS, @actor_sprites[index].y + N01::CURSOR_Y_PLUS] if actor
    return [@enemy_sprites[index].x + N01::CURSOR_X_PLUS, @enemy_sprites[index].y + N01::CURSOR_Y_PLUS] unless actor
  end
end
#==============================================================================
# ■ Sprite_MoveAnime
#------------------------------------------------------------------------------
# 　アニメ飛ばし用のスプライトです。
#==============================================================================
class Sprite_MoveAnime < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :battler
  attr_accessor :base_x   # Base X coordinate
  attr_accessor :base_y   # Base Y coordinate
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化 
  #--------------------------------------------------------------------------
  def initialize(viewport,battler = nil)
    super(viewport)
    @battler = battler
    self.visible = false
    @base_x = 0
    @base_y = 0
    @move_x = 0                # 動かしたX座標
    @move_y = 0                # 動かしたY座標
    @moving_x = 0              # 1フレーム当たり動かすX座標
    @moving_y = 0              # 1フレーム当たり動かすY座標
    @orbit = 0                 # 円軌道
    @orbit_plus = 0            # 加算する円軌道
    @orbit_time = 0            # 円軌道計算時間
    @through = false           # 貫通するかどうか
    @finish = false            # 移動終了フラグ
    @time = 0                  # 移動時間
    @angle = 0                 # 武器の角度
    @angling = 0               # 1フレーム当たり動かす武器の角度
  end
  #--------------------------------------------------------------------------
  # ● アクションを取得
  #--------------------------------------------------------------------------  
  def anime_action(id,mirror,distanse_x,distanse_y,type,speed,orbit,weapon,icon_index,icon_weapon)
    # Distance calculation per frame 
    @time = speed
    @moving_x = distanse_x / speed
    @moving_y = distanse_y / speed
    # Can animation can pass through target?
    @through = true if type == 1
    # 円軌道を取得
    @orbit_plus = orbit
    @orbit_time = @time
    # If a weapon graphic is used
    if weapon != ""
      action = N01::ANIME[weapon].dup
      @angle = action[0]
      end_angle = action[1]
      time = action[2]
      # if battler is an enemy and not in a back attack 3.4a
      if !battler.actor? && !$back_attack
        # Invert angles of flying graphic and mirror it
        @angle *= -1
        end_angle *= -1
        mirror = true
      end
      # if back attack, invert defined angles 3.4a
      if $back_attack
        @angle *= -1 unless !battler.actor?
        end_angle *= -1 unless !battler.actor?
        mirror = true if battler.actor?
        mirror = false if !battler.actor?
      end
      # 1フレームあたりの回転角度を出す
      @angling = (end_angle - @angle)/ time
      # 開始角度を取る
      self.angle = @angle
      # 武器グラフィックを表示
      self.mirror = mirror
      if icon_weapon
        self.bitmap = Cache.system("Iconset")
        self.src_rect.set(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
        self.ox = 12
        self.oy = 12
      else 
        self.bitmap = Cache.character(icon_index)
        self.ox = self.bitmap.width / 2
        self.oy = self.bitmap.height / 2
      end  
      self.visible = true
      # バトラーより手前に表示
      self.z = 1000
    end  
    # 最初は動かさず一回だけ表示
    self.x = @base_x + @move_x
    self.y = @base_y + @move_y + @orbit
    if id != 0
      animation = $data_animations[id]
      start_animation(animation, mirror)
    end
  end  
  #--------------------------------------------------------------------------
  # ● 変化した動きをリセット
  #--------------------------------------------------------------------------  
  def action_reset
    @moving_x = @moving_y = @move_x = @move_y = @base_x = @base_y = @orbit = 0
    @orbit_time = @angling = @angle = 0    
    @through = self.visible = @finish = false
    dispose_animation
  end   
  #--------------------------------------------------------------------------
  # ● 貫通終了
  #--------------------------------------------------------------------------  
  def finish?
    return @finish
  end 
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # 時間消費
    @time -= 1
    # 時間まで指定の動きを
    if @time >= 0
      @move_x += @moving_x
      @move_y += @moving_y
      # 円軌道計算
      if @time < @orbit_time / 2
        @orbit_plus = @orbit_plus * 5 / 4
      elsif @time == @orbit_time / 2
        @orbit_plus *= -1
      else
        @orbit_plus = @orbit_plus * 2 / 3
      end  
      @orbit += @orbit_plus
    end    
    # 時間がきても貫通ならそのまま直進
    @time = 100 if @time < 0 && @through
    @finish = true if @time < 0 && !@through
    # スプライトの座標を更新
    self.x = @base_x + @move_x
    self.y = @base_y + @move_y + @orbit
    # 貫通の場合、画面から消えたら終了フラグオン
    if self.x < -200 or self.x > 840 or self.y < -200 or self.y > 680
      @finish = true
    end
    # 武器グラフィック更新
    if self.visible
      @angle += @angling
      self.angle = @angle
    end  
  end
end
#==============================================================================
# ■ Sprite_Weapon
#------------------------------------------------------------------------------
# 　ウエポン表示用のスプライトです。
#==============================================================================
class Sprite_Weapon < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :battler
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化 
  #--------------------------------------------------------------------------
  def initialize(viewport,battler = nil)
    super(viewport)
    @battler = battler
    @action = []                     # 武器のアクション情報
    @move_x = 0                      # 動かしたX座標
    @move_y = 0                      # 動かしたY座標
    @move_z = 0                      # 動かしたZ座標
    @plus_x = 0                      # 微調整分のX座標
    @plus_y = 0                      # 微調整分のY座標
    @angle = 0                       # 武器の回転角度
    @zoom_x = 1                      # 武器の横拡大率
    @zoom_y = 1                      # 武器の縦拡大率
    @moving_x = 0                    # 1フレーム当たり動かすX座標
    @moving_y = 0                    # 1フレーム当たり動かすY座標
    @angling = 0                     # 1フレーム当たりの回転角度
    @zooming_x = 1                   # 1フレーム当たりの横拡大率
    @zooming_y = 1                   # 1フレーム当たりの縦拡大率    
    @freeze = -1                     # 固定アニメ用武器位置
    @mirroring = false               # バトラーが反転しているか
    @time = N01::ANIME_PATTERN + 1   # 更新回数
    # 武器を取得
    weapon_graphics 
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    self.bitmap.dispose if self.bitmap != nil
    super
  end
  #--------------------------------------------------------------------------
  # ● 武器を取得
  #--------------------------------------------------------------------------  
  def weapon_graphics(left = false)
    if @battler.actor?
      weapon = @battler.weapons[0] unless left
      weapon = @battler.weapons[1] if left
    else
      weapon = $data_weapons[@battler.weapon]
    end
    # 武器がなければ処理をキャンセル
    return if weapon == nil
    # アイコンを利用するなら
    if weapon.graphic == ""
      icon_index = weapon.icon_index
      self.bitmap = Cache.system("Iconset")
      self.src_rect.set(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
      @weapon_width = @weapon_height = 24
    # ID指定があったら、アイコンではなくそのグラフィックを取得  
    else
      self.bitmap = Cache.character(weapon.graphic)
      @weapon_width = self.bitmap.width
      @weapon_height = self.bitmap.height
    end
  end
  #--------------------------------------------------------------------------
  # ● アニメ固定時の武器位置を取得
  #--------------------------------------------------------------------------  
  def freeze(action)
    @freeze = action
  end
  #--------------------------------------------------------------------------
  # ● 武器アクションを取得 freeze
  #--------------------------------------------------------------------------  
  def weapon_action(action,loop)
    # 名称がない場合は非表示に
    if action == ""
      self.visible = false
    # 素手なら非表示に
    elsif @weapon_id == 0
      self.visible = false
    # 武器アクション情報を受け取る
    else
      @action = N01::ANIME[action]
      act0 = @action[0]
      act1 = @action[1]
      act2 = @action[2]
      act3 = @action[3]
      act4 = @action[4]
      act5 = @action[5]
      act6 = @action[6]
      act7 = @action[7]
      act8 = @action[8]
      act9 = @action[9]
      act10 = @action[10]
      # バトラーが反転してる場合、X軸の動きを逆に
      if @mirroring
        act0 *= -1
        act3 *= -1
        act4 *= -1
        act9 *= -1
      end
      # キャラのアニメパターン数をチェック
      time = N01::ANIME_PATTERN 
      # Z座標をチェック
      if act2
        self.z = @battler.position_z + 1
      else
        self.z = @battler.position_z - 1
      end
      # 反転はここで実行し、すでに反転している場合は元に戻す
      if act6
        if self.mirror
          self.mirror = false
        else
          self.mirror = true
        end
      end
      # バトラーの反転を反映
      if @mirroring
        if self.mirror
          self.mirror = false
        else
          self.mirror = true
        end
      end 
      # アニメパターン数で割った変化を計算
      @moving_x = act0 / time
      @moving_y = act1 / time
      # 最初の角度を代入 Assign first angle 
      @angle = act3
      self.angle = @angle
      # 更新角度を計算 Update angle calculation
      @angling = (act4 - act3)/ time
      # 角度が割り切れない場合、ここで余り分を回転加算 If angle is divided evenly
      @angle += (act4 - act3) % time
      # Weapon sprite scaling
      @zooming_x = (1 - act7) / time
      @zooming_y = (1 - act8) / time
      # 反転してる場合、回転元の原点を逆に
      if self.mirror
        case act5
        when 1 # 左上→右上に
          act5 = 2
        when 2 # 右上→左上に
          act5 = 1
        when 3 # 左下→右下に
          act5 = 4
        when 4 # 右下→左下に
          act5 = 3
        end  
      end    
      # 回転元の原点を設定
      case act5
      when 0 # 中心
        self.ox = @weapon_width / 2
        self.oy = @weapon_height / 2
      when 1 # 左上
        self.ox = 0
        self.oy = 0
      when 2 # 右上
        self.ox = @weapon_width
        self.oy = 0
      when 3 # 左下
        self.ox = 0
        self.oy = @weapon_height
      when 4 # 右下
        self.ox = @weapon_width
        self.oy = @weapon_height
      end  
      # 座標微調整
      @plus_x = act9
      @plus_y = act10
      # 往復ループならフラグオン
      @loop = true if loop == 0
      # 初回で0から始まるように、この時点で-1回の動きをさせる
      @angle -= @angling
      @zoom_x -= @zooming_x
      @zoom_y -= @zooming_y
      # スプライトの座標を更新
      @move_x -= @moving_x
      @move_y -= @moving_y 
      @move_z = 1000 if act2
      # 固定アニメの場合、この時点で動きを消化
      if @freeze != -1
        for i in 0..@freeze + 1
          @angle += @angling
          @zoom_x += @zooming_x
          @zoom_y += @zooming_y
          # スプライトの座標を更新
          @move_x += @moving_x
          @move_y += @moving_y 
        end
        @angling = 0
        @zooming_x = 0
        @zooming_y = 0
        @moving_x = 0
        @moving_y = 0
      end 
      # 可視
      self.visible = true
    end 
  end  
  #--------------------------------------------------------------------------
  # ● 変化した動きを全部リセット
  #--------------------------------------------------------------------------  
  def action_reset
    @moving_x = @moving_y = @move_x = @move_y = @plus_x = @plus_y = 0
    @angling = @zooming_x = @zooming_y = @angle = self.angle = @move_z = 0
    @zoom_x = @zoom_y = self.zoom_x = self.zoom_y = 1
    self.mirror = self.visible = @loop = false
    @freeze = -1
    @action = []
    @time = N01::ANIME_PATTERN + 1
  end 
  #--------------------------------------------------------------------------
  # ● 往復ループさせる
  #--------------------------------------------------------------------------  
  def action_loop
    # 動きを反対に
    @angling *= -1
    @zooming_x *= -1
    @zooming_y *= -1
    @moving_x *= -1
    @moving_y *= -1
  end  
  #--------------------------------------------------------------------------
  # ● アクターが反転している場合、自身も反転させる
  #--------------------------------------------------------------------------
  def mirroring 
    return @mirroring = false if @mirroring
    @mirroring = true
  end  
  #--------------------------------------------------------------------------
  # ● アクターアニメが更新された時のみ武器アクションの変化を更新
  #--------------------------------------------------------------------------
  def action
    return if @time <= 0
    @time -= 1
    # 回転、拡大縮小を更新
    @angle += @angling
    @zoom_x += @zooming_x
    @zoom_y += @zooming_y
    # スプライトの座標を更新
    @move_x += @moving_x
    @move_y += @moving_y 
    # 往復ループなら動きを反転
    if @loop && @time == 0
      @time = N01::ANIME_PATTERN + 1
      action_loop
    end 
  end  
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    # 回転、拡大縮小を更新
    self.angle = @angle
    self.zoom_x = @zoom_x
    self.zoom_y = @zoom_y
    # スプライトの座標を更新
    self.x = @battler.position_x + @move_x + @plus_x
    self.y = @battler.position_y + @move_y + @plus_y
    self.z = @battler.position_z + @move_z - 1
  end
end

#==============================================================================
# ■ Game_Battler (分割定義 1)
#------------------------------------------------------------------------------
# 　バトラーを扱うクラスです。
#==============================================================================
class Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :hp_damage        # 行動結果: HP ダメージ
  attr_accessor :mp_damage        # 行動結果: MP ダメージ
  attr_accessor :move_x           # X方向の移動補正
  attr_accessor :move_y           # Y方向の移動補正
  attr_accessor :move_z           # Z方向の移動補正
  attr_accessor :jump             # ジャンプ補正
  attr_accessor :active           # アクティブか
  attr_accessor :non_dead         # 不死身フラグ
  attr_accessor :dying            # 即死フラグ
  attr_accessor :slip_damage      # スリップダメージフラグ
  attr_accessor :derivation       # スキル派生ID
  attr_accessor :individual       # スキル派生ID
  attr_accessor :play             # アクション情報
  attr_accessor :force_action     # 強制されるアクション情報
  attr_accessor :force_target     # ターゲット変更情報
  attr_accessor :revival          # 復活
  attr_accessor :double_damage    # HPMP両方同時ダメージ
  attr_accessor :reflex           # スキル反射情報
  attr_accessor :absorb           # スキルコスト吸収
  attr_reader   :base_position_x  # 初期配置X座標
  attr_reader   :base_position_y  # 初期配置Y座標   
  attr_accessor :force_damage     # イベントでのダメージ
  attr_accessor :graphics_width   # Battler graphic width per cell (from ATB)
  attr_accessor :graphics_height  # Battler graphic height per cell (from ATB)
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_n01 initialize
  def initialize
    initialize_n01
    @move_x = @move_y = @move_z = @plus_y = @jump = @derivation = @play = 0
    @force_action = @force_target = @base_position_x = @base_position_y = 0
    @absorb = @act_time = @force_damage = 0 # 3.4a
    @active = @individual = @slip_damage = @revival = false # removed ref to @non_dead 3.3c
    @double_damage = @dying = false
    @non_dead = @immortal # object initilization, sync @non_dead and @immortal 3.3c
  end
  #--------------------------------------------------------------------------
  # ● Set Immortality Temporarily
  #--------------------------------------------------------------------------
  def set_temp_immortal(flag = true) # New method, 3.3c
    # set immortality temporarily, used from the SBS scripts
    @immortal = flag # ONLY @immortal is set, @non_dead is not touched
  end
  #--------------------------------------------------------------------------
  # ● standard accessor for @immortal
  #--------------------------------------------------------------------------
  alias immortal_set_SBS immortal=
  def immortal=(flag) # standard accessor for @immortal
    @immortal = flag
    @non_dead = flag # when the standard accessor is used (eg., from OUTSIDE the
    # SBS scripts, Game_Troop#setup, etc.), the @non_dead flag is also set.
  end
  N01::IMMORTALITY_CHANGING_METHODS.each {|m|
  aStr = %Q(
  if method_defined?(:#{m}) && !method_defined?(:aliased_immortal_#{m})
    alias :aliased_immortal_#{m} :#{m}
    def #{m}(*args)
      val = aliased_immortal_#{m}(*args)
      @non_dead = @immortal
      return val
    end
  end
  )
  module_eval(aStr)
  # makes an alias for the given methods, syncs @non_dead with
  # @immortal after the method is run, and perserves the return value and argv
  }
  #--------------------------------------------------------------------------
  # ● 一番新しいステートIDを返す
  #--------------------------------------------------------------------------
  def state_id
    return @states[@states.size - 1]
  end
  #--------------------------------------------------------------------------
  # ++ Consume skill cost
  #    No longer used in execute_action_skill and is replaced by the default
  #    method of consuming MP.
  #--------------------------------------------------------------------------
#  def consum_skill_cost(skill)
#    return false unless skill_can_use?(skill)
#    cost = calc_mp_cost(skill)
#    return self.hp -= cost if skill.extension.include?("CONSUMEHP")
#    return self.mp -= cost
#  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃によるダメージ計算  二刀流補正
  #--------------------------------------------------------------------------
#  alias make_attack_damage_value_n01 make_attack_damage_value
#  def make_attack_damage_value(attacker)
#    make_attack_damage_value_n01(attacker)
#    # 二本の武器を装備しているときのみ補正を有効に
#    return unless attacker.actor?
#    return if attacker.weapons[0] == nil
#    return if attacker.weapons[1] == nil
#    @hp_damage = @hp_damage * N01::TWO_SWORDS_STYLE[0] / 100
#  end
  #--------------------------------------------------------------------------
  # ● スキルまたはアイテムによるダメージ計算　二刀流補正
  #--------------------------------------------------------------------------
#  alias make_obj_damage_value_n01 make_obj_damage_value
#  def make_obj_damage_value(user, obj)
#    make_obj_damage_value_n01(user, obj)
#    # 二本の武器を装備しているときのみ補正を有効に
#    return unless user.actor?
#    return if user.weapons[0] == nil
#    return if user.weapons[1] == nil
    # Edited 3.4a
    # if obj is a normal attack
#    if obj == nil 
#      if obj.damage_to_mp  
#        @mp_damage = @mp_damage * N01::TWO_SWORDS_STYLE[1] / 100 # MP にダメージ
#      else
#        @hp_damage = @hp_damage * N01::TWO_SWORDS_STYLE[1] / 100 # HP にダメージ
#      end
#    end
#  end
  #--------------------------------------------------------------------------
  # ● 通常攻撃の効果適用  すでに戦闘不能で絶対に回避できない処理
  #--------------------------------------------------------------------------
  def perfect_attack_effect(attacker)
    clear_action_results
    make_attack_damage_value(attacker)            # ダメージ計算
    execute_damage(attacker)                      # ダメージ反映
    apply_state_changes(attacker)                 # ステート変化
  end
  #--------------------------------------------------------------------------
  # ● スキルの効果適用  すでに戦闘不能で絶対に回避できない処理
  #--------------------------------------------------------------------------
  def perfect_skill_effect(user, skill)
    clear_action_results
    make_obj_damage_value(user, skill)            # ダメージ計算
    make_obj_absorb_effect(user, skill)           # 吸収効果計算
    execute_damage(user)                          # ダメージ反映
    apply_state_changes(skill)                    # ステート変化
  end
  #--------------------------------------------------------------------------
  # ● アイテムの効果適用  すでに戦闘不能で絶対に回避できない処理
  #--------------------------------------------------------------------------
  def perfect_item_effect(user, item)
    clear_action_results
    hp_recovery = calc_hp_recovery(user, item)    # HP 回復量計算
    mp_recovery = calc_mp_recovery(user, item)    # MP 回復量計算
    make_obj_damage_value(user, item)             # ダメージ計算
    @hp_damage -= hp_recovery                     # HP 回復量を差し引く
    @mp_damage -= mp_recovery                     # MP 回復量を差し引く
    make_obj_absorb_effect(user, item)            # 吸収効果計算
    execute_damage(user)                          # ダメージ反映
    item_growth_effect(user, item)                # 成長効果適用
    if item.physical_attack and @hp_damage == 0   # 物理ノーダメージ判定
      return                                    
    end
    apply_state_changes(item)                     # ステート変化
  end
  #--------------------------------------------------------------------------
  # ● ダメージの反映
  #--------------------------------------------------------------------------
  alias execute_damage_n01 execute_damage
  def execute_damage(user)
    execute_damage_n01(user)
    # 吸収の場合ここで処理を相殺
    if @absorbed                
      user.hp_damage = -@hp_damage
      user.mp_damage = -@mp_damage
    end
  end
  #--------------------------------------------------------------------------
  # * Apply Skill Effects
  #     user  : Skill user
  #     obj   : skill
  #--------------------------------------------------------------------------
  alias skill_effect_n01 skill_effect
  def skill_effect(user, obj)
    # 変化前のHPMPを保持
    nowhp = self.hp
    nowmp = self.mp
    # 現在HPMP威力計算用に変化前の使用者HPMPを取得
    # 拡張設定チェック
#    check_extension(obj)
    # ダメージ計算
    skill_effect_n01(user, obj)
    # ダメージ系の拡張がある場合ここで処理を相殺
    if @extension 
      self.hp = nowhp
      self.mp = nowmp
    end
    # 攻撃が当たっていない場合は処理中断
    return if self.evaded or self.missed
    # ダメージ属性変換
    damage = @hp_damage unless obj.damage_to_mp
    damage = @mp_damage if obj.damage_to_mp
    # 割合ダメージ
    if @ratio_maxdamage != nil
      damage = self.maxhp * @ratio_maxdamage / 100 unless obj.damage_to_mp
      damage = self.maxmp * @ratio_maxdamage / 100 if obj.damage_to_mp
      damage = damage * elements_max_rate(obj.element_set) / 100 # 3.3c, elemental adjustment
    end
    if @ratio_nowdamage != nil
      damage = self.hp * @ratio_nowdamage / 100 unless obj.damage_to_mp
      damage = self.mp * @ratio_nowdamage / 100 if obj.damage_to_mp
      damage = damage * elements_max_rate(obj.element_set) / 100 # 3.3c, elemental adjustment
    end
#    # コスト威力
#     if @cost_damage
#       cost = user.calc_mp_cost(obj)
#       if obj.extension.include?("CONSUMEHP")
#         damage = damage * cost / user.maxhp
#       else
#         damage = damage * cost / user.maxmp
#       end
#     end 
    # 現在HP威力
#     damage = damage * user_hp / user.maxhp if @nowhp_damage
    # 現在MP威力
#     damage = damage * user_mp / user.maxmp if @nowmp_damage
    # ダメージ属性変換戻し
    @hp_damage = damage unless obj.damage_to_mp
    @mp_damage = damage if obj.damage_to_mp
    # 拡張反映
    if @extension
      self.hp -= @hp_damage
      self.mp -= @mp_damage
    end
    # 初期化
    @extension = false
    @cost_damage = false
    @nowhp_damage = false
    @nowmp_damage = false
    @ratio_maxdamage = nil
    @ratio_nowdamage = nil
  end
  #--------------------------------------------------------------------------
  # ● Check Skill Extentions
  #--------------------------------------------------------------------------
#   def check_extension(skill)
#     for ext in skill.extension
#       # コスト威力
#       if ext == "COSTPOWER"  
#         @extension = true
#         next @cost_damage = true 
#       # 現在HP威力
#       if ext == "HPNOWPOWER"
#         @extension = true
#         next @nowhp_damage = true 
#       # 現在MP威力
#       elsif ext == "MPNOWPOWER"
#         @extension = true
#         next @nowmp_damage = true
#      else
#        # 割合ダメージ
#        name = ext.split('')
#        if name[7] == "M"
#          name = name.join
#          name.slice!("%DAMAGEMAX/")
#          @extension = true
#          next @ratio_maxdamage = name.to_i
#        elsif name[7] == "N"
#          name = name.join
#          name.slice!("%DAMAGENOW/")
#          @extension = true
#          next @ratio_nowdamage = name.to_i
#        end  
#       end
#     end  
#   end
  #--------------------------------------------------------------------------
  # ● 初期配置の変更
  #--------------------------------------------------------------------------
  def change_base_position(x, y)
    @base_position_x = x
    @base_position_y = y
  end
  #--------------------------------------------------------------------------
  # ● 初期化
  #--------------------------------------------------------------------------
  def reset_coordinate
    @move_x = @move_y = @move_z = @jump = @derivation = 0
    @active = @individual = false # removed reference to non_dead, 3.3c
  end
  #--------------------------------------------------------------------------
  # ● スリップダメージの効果適用
  #--------------------------------------------------------------------------
  def slip_damage_effect
    if slip_damage? and @hp > 0
      @hp_damage = apply_variance(maxhp / 10, 10)
      @hp_damage = @hp - 1 if @hp_damage >= @hp
      self.hp -= @hp_damage
    end
  end
  #--------------------------------------------------------------------------
  # ● イベントでのダメージPOP
  #--------------------------------------------------------------------------
  def damage_num(num = nil)
    return if dead? or !$game_temp.in_battle or num == 0
    @force_damage = num
  end
end

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。
#==============================================================================
class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :two_swords_change          # 二刀流強制持ち替えフラグ
  #--------------------------------------------------------------------------
  # ● IDによるスキルの習得済み判定
  #--------------------------------------------------------------------------
  def skill_id_learn?(skill_id)
    return @skills.include?(skill_id)
  end
  #--------------------------------------------------------------------------
  # ● スキルの使用可能判定  ※再定義
  #--------------------------------------------------------------------------
  def skill_can_use?(skill)
    return super
  end
  #--------------------------------------------------------------------------
  # ● グラフィックの変更
  #--------------------------------------------------------------------------
  def graphic_change(character_name)
    @character_name = character_name
  end
  #--------------------------------------------------------------------------
  # ● コラプスの実行 ※再定義
  #--------------------------------------------------------------------------
  def perform_collapse
    Sound.play_actor_collapse if $game_temp.in_battle and dead?
  end
  #--------------------------------------------------------------------------
  # ++ Battle Start Positioning
  #--------------------------------------------------------------------------
  def base_position
  total_members = $game_party.members.size  # 獲取隊伍總人數
  total_members = $game_party.members.size  # 獲取隊伍總人數
  normal_actor_count = 0  # 計算 self.id < 7 的角色數量
  summon_actor_index = 0  # 計算當前角色是第幾個 self.id >= 7 的角色

  # 先遍歷隊伍成員，統計 self.id < 7 的數量，並計算 self.id >= 7 的順序
  $game_party.members.each do |actor|
    if actor.id < 7
      normal_actor_count += 1
    elsif actor == self  # 確保當前角色取得正確的 summon_index
      break  # 當找到自己時，終止計算，確保這是目前第幾個 self.id >= 7 的角色
    else
      summon_actor_index += 1
    end
  end
  base = N01::ACTOR_POSITION[self.index]

  if self.id < 7
    # self.id < 7 的角色使用 N01::ACTOR_POSITION
    @base_position_x = base[0]
    @base_position_y = base[1]
  else
    # self.id >= 7 的角色按順序對應 N01::SUMMON_ACTOR_POSITION
    summon_index = summon_actor_index % N01::SUMMON_ACTOR_POSITION.size
    base2 = N01::SUMMON_ACTOR_POSITION[summon_index]
    
    @base_position_x = base2[0]
    @base_position_y = base2[1]
  end
    # バックアタック時はX軸を逆に
    @base_position_x = Graphics.width - base[0] if $back_attack && N01::BACK_ATTACK
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 X 座標の取得
  #--------------------------------------------------------------------------
  def position_x
    return 0 if self.index == nil
    return @base_position_x + @move_x
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 Y 座標の取得
  #--------------------------------------------------------------------------
  def position_y
    return 0 if self.index == nil
    return @base_position_y + @move_y + @jump
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 Z 座標の取得
  #--------------------------------------------------------------------------
  def position_z
    return 0 if self.index == nil
    return self.index + @base_position_y + @move_y + @move_z - @jump + 200
  end
end
#==============================================================================
# ■ Game_Enemy
#------------------------------------------------------------------------------
# 　エネミーを扱うクラスです。
#==============================================================================
class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :adj_speed        # 複数回行動の速度補正
  attr_accessor :act_time         # 行動数回
  #--------------------------------------------------------------------------
  # ● アクションスピードの決定 複数回行動用
  #--------------------------------------------------------------------------
  def make_action_speed2(adj)
    @adj_speed = self.action.speed if @adj_speed == nil
    @adj_speed = @adj_speed * adj / 100
  end
  #--------------------------------------------------------------------------
  # ● コラプスの実行 ※再定義
  #--------------------------------------------------------------------------
  def perform_collapse
    @force_action = ["N01collapse"] if $game_temp.in_battle and dead?
  end
  #--------------------------------------------------------------------------
  # ++ Base Screen Position (and bitmap height)
  #--------------------------------------------------------------------------
  def base_position
    return if self.index == nil
    # バトラー画像のサイズをチェックしY座標を修正
    bitmap = Bitmap.new("Graphics/Battlers/" + @battler_name) if !self.anime_on
    bitmap = Bitmap.new("Graphics/Characters/" + @battler_name) if self.anime_on && N01::WALK_ANIME
    bitmap = Bitmap.new("Graphics/Characters/" + @battler_name + "_1") if self.anime_on && !N01::WALK_ANIME
    height = bitmap.height
    @base_position_x = self.screen_x + self.position_plus[0]
    # 3.4a
    # Animated enemies
    if self.anime_on
      #height -= 40 if bitmap.height >= 150
      #@battler_name = "$boar"
      frame_height = height / N01::ANIME_KIND
      @base_position_y = self.screen_y + self.position_plus[1] - frame_height / 3 # 3.4a
      #@base_position_y += 20 if height >= 400
      ###
    # Default battlers
    else
      @base_position_y = self.screen_y + self.position_plus[1] - height / 3 # 3.4a
    end
    bitmap.dispose
    # バックアタック時はX軸を逆に
    if $back_attack && N01::BACK_ATTACK
      @base_position_x = Graphics.width - self.screen_x - self.position_plus[0] 
    end
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 X 座標の取得
  #--------------------------------------------------------------------------
  def position_x
    return @base_position_x - @move_x
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 Y 座標の取得
  #--------------------------------------------------------------------------
  def position_y
    return @base_position_y + @move_y + @jump
  end
  #--------------------------------------------------------------------------
  # ● バトル画面 Z 座標の取得
  #--------------------------------------------------------------------------
  def position_z
    return position_y + @move_z - @jump + 200
  end
end 
#==============================================================================
# ■ Sprite_Damage
#------------------------------------------------------------------------------
# 　ダメージ表示のスプライトです。
#==============================================================================
class Sprite_Damage < Sprite_Base
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :battler
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化 
  #--------------------------------------------------------------------------
  def initialize(viewport,battler = nil)
    super(viewport)
    @battler = battler
    @damage = 0
    @duration = 0
    @x = 0
    @y = 0
    @z_plus = 0
    @minus = false
    @num1 = Sprite.new(viewport)
    @num2 = Sprite.new(viewport)
    @num3 = Sprite.new(viewport)
    @num4 = Sprite.new(viewport)
    @num5 = Sprite.new(viewport)
    @num6 = Sprite.new(viewport)
    @num1.visible = false
    @num2.visible = false
    @num3.visible = false
    @num4.visible = false
    @num5.visible = false
    @num6.visible = false
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    force_damage
    move_damage(@num6, @pop_time) if @num6.visible
    move_damage(@num5, @pop_time - 2) if @num5.visible
    move_damage(@num4, @pop_time - 4) if @num4.visible
    move_damage(@num3, @pop_time - 6) if @num3.visible 
    move_damage(@num2, @pop_time - 8) if @num2.visible 
    move_damage(@num1, @pop_time - 10) if @num1.visible
    move_window if @window != nil
    @duration -= 1 if @duration > 0
  end
  #--------------------------------------------------------------------------
  # ● イベントでのダメージPOP
  #--------------------------------------------------------------------------
  def force_damage
    if @battler.force_damage != 0
      damage_pop(@battler.force_damage)
      @battler.hp -= @battler.force_damage
      @force_damage = true
      @battler.force_damage = 0
      $game_temp.status_window_refresh = true
    end
  end
  #--------------------------------------------------------------------------
  # ● 数値の動き
  #--------------------------------------------------------------------------
  def move_damage(num, min)
    case @duration
    when min-1..min
      num.x -= 1
      num.y -= 4
    when min-3..min-2
      num.x -= 1
      num.y -= 3
    when min-6..min-4
      num.y -= 2
    when min-14..min-7
      num.y += 2
    when min-17..min-15
      num.y -= 2
    when min-23..min-18
      num.y += 1
    when min-27..min-24
      num.y -= 1
    when min-30..min-28
      num.y += 1
    when min-33..min-31
      num.y -= 1
    when min-36..min-34
      num.y += 1
    end
    next_damage if @battler.double_damage && @duration == min-34
    num.opacity = 256 - (12 - @duration) * 32
    num.visible = false if @duration == 0
    if @force_damage && @duration == 0
      @force_damage = false
      @battler.perform_collapse 
    end 
  end 
  #--------------------------------------------------------------------------
  # ● 文字ウインドウの動き
  #--------------------------------------------------------------------------
  def move_window
    @window.x -= 6 if @window_time > 0 && @window.x > 0
    @window_time -= 1
    if @duration == 0
      @window.dispose
      @window = nil
    end
  end  
  #--------------------------------------------------------------------------
  # ● HPMP両方同時ダメージ
  #--------------------------------------------------------------------------
  def next_damage
    @battler.hp_damage = 0
    @battler.double_damage = false
    damage_pop
  end 
  #--------------------------------------------------------------------------
  # ● 文字POP
  #--------------------------------------------------------------------------
  def text_pop(num = nil)
    reset
    text = ""
    # POP位置微調整
    adjust = -16
    @x = battler.position_x
    @y = battler.position_y + adjust
    window2(text) if text != ""
    @pop_time = 120
    # ダメージがなければ数字のPOPをさせない
    return @duration = @pop_time
  end
    #--------------------------------------------------------------------------
  # ● 情報ウインドウ準備
  #--------------------------------------------------------------------------
  def window2(text)
    @window = Window_Damage.new(@x - 64, @y - 22)
    @window.pop_text(text)
    @window_time = 5
  end  
  #--------------------------------------------------------------------------
  # ● ダメージPOP準備 
  #--------------------------------------------------------------------------
  def damage_pop(num = nil)
    reset
    damage = battler.hp_damage
    # ステートの変化を抜き出す
    states = battler.added_states
    text = ""
    # MPダメージ用テキスト(HPMP両方同時ダメージは除く)
    if !@battler.double_damage && @battler.mp_damage != 0
      text = N01::POP_MP_DAM if battler.mp_damage > 0 
      text = N01::POP_MP_REC if battler.mp_damage < 0 
      damage = battler.mp_damage
    end
    # スリップダメージはMPダメージ以外文字を表示させない
    if num == nil
      text = N01::POP_DAMAGE0 if damage == 0 && states == [] && !battler.revival
      text = N01::POP_MISS if battler.missed && states == []
      text = N01::POP_EVA if battler.evaded 
      text = N01::POP_CRI if battler.critical
      text = "屬性克制!" if battler.weak
      $game_troop.screen.start_shake(7, 7, 20) if battler.weak#有用
      text = "屬性抵抗!" if battler.strong
      for state in states
        # POPなし設定のステートは表示させない
        unless state.extension.include?("NOPOP")
          text += " " if text != ""
          text += state.name
        end
      end
    else
      damage = num
    end
    # ダメージと回復を分ける
    @minus = false
    @minus = true if damage < 0
    damage = damage.abs
    # POP位置微調整
    adjust = -16 + 4
    adjust = 16 if $back_attack
    adjust = 0 if damage == 0
    @x = battler.position_x + adjust
    @y = battler.position_y
    window(text) if text != ""
    @pop_time = N01::NUM_DURATION
    # ダメージがなければ数字のPOPをさせない
    return @duration = @pop_time if damage == 0
    @num_time = -1
    damage_file(@num1, damage % 10, @pop_time - 7) if damage >= 0
    damage_file(@num2, (damage % 100)/10, @pop_time - 5) if damage >= 10
    damage_file(@num3, (damage % 1000)/100, @pop_time - 3) if damage >= 100
    damage_file(@num4, (damage % 10000)/1000, @pop_time - 1) if damage >= 1000
    damage_file(@num5, (damage % 100000)/10000, @pop_time + 1) if damage >= 10000
    damage_file(@num6, (damage % 1000000)/100000, @pop_time + 3) if damage >= 100000
  end
  #--------------------------------------------------------------------------
  # ● 情報ウインドウ準備
  #--------------------------------------------------------------------------
  def window(text)
    @window = Window_Damage.new(@x - 64, @y - 22)
    @window.pop_text(text)
    @window_time = 5
  end  
  #--------------------------------------------------------------------------
  # ● 数字画像準備
  #--------------------------------------------------------------------------
  def damage_file(num, cw, dur)
    num.visible = true
    # ファイル判別
    file = N01::DAMAGE_GRAPHICS
    file = N01::RECOVER_GRAPHICS if @minus
    file = N01::MP_DAMAGE_GRAPHICS if battler.mp_damage > 0 && !@battler.double_damage && N01::USE_MP_POP_GRAPHICS # v3.3b
    file = N01::MP_RECOVER_GRAPHICS if battler.mp_damage < 0 && !@battler.double_damage && N01::USE_MP_POP_GRAPHICS# v3.3b    
    # 数字
    num.bitmap = Cache.system(file)
    @num_time += 1
    sx = num.bitmap.width / 10
    num.src_rect.set(cw * sx, 0, sx, num.height)
    num.x = @x - (num.width + N01::NUM_INTERBAL) * @num_time
    num.y = @y
    num.z = 2000 - @num_time
    @duration = dur
    @window.x = num.x - @window.width + 64 if @window != nil && N01::NON_DAMAGE_WINDOW
    @window.x = num.x - @window.width + 26 if @window != nil && !N01::NON_DAMAGE_WINDOW
    @window.x = 0 if @window != nil && @window.x < 0
  end
  #--------------------------------------------------------------------------
  # ● ダメージリセット
  #--------------------------------------------------------------------------
  def reset
    @num6.visible = @num5.visible = @num4.visible = @num3.visible = @num2.visible = @num1.visible = false
    @window.dispose if @window != nil
    @window = nil
  end  
  #--------------------------------------------------------------------------
  # ● 開放
  #--------------------------------------------------------------------------
  def dispose
    super
    @num1.dispose
    @num2.dispose
    @num3.dispose
    @num4.dispose
    @num5.dispose
    @num6.dispose
    @window.dispose if @window != nil
  end  
end
#==============================================================================
# ■ Window_Damage
#------------------------------------------------------------------------------
#  Pop-up window that displays state names and hit confirmation effects.
#==============================================================================
class Window_Damage < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y, 160, 46)
    self.opacity = 0 if N01::NON_DAMAGE_WINDOW
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ内容の作成 
  #--------------------------------------------------------------------------
  def create_contents
    self.contents.dispose
    self.contents = Bitmap.new(width - 32, height - 32)
  end
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def pop_text(text, align = 1)
    self.contents.clear
    self.width = self.contents.text_size(text).width + 36
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.color = normal_color
    self.contents.font.bold = true
    self.contents.font.size = 17
    
    # 計算適合的文字背景範圍
    text_width = self.contents.text_size(text).width + 20
    text_height = 32

    # 畫半透明黑色背景
    self.contents.fill_rect(0, 0, text_width, text_height, Color.new(0, 0, 0, 150))
    # 繪製文字（置中）
    self.contents.draw_text(0,-8, width - 32, 32, text, align)
  end  
end  
#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 　セーブデータに含まれない、一時的なデータを扱うクラスです。
#==============================================================================
class Game_Temp
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :status_window_refresh    # ステータスウインドウのリフレッシュフラグ
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias initialize_n01 initialize
  def initialize
    initialize_n01
    @status_window_refresh = false
  end
end  
#==============================================================================
# ■ Game_Interpreter
#------------------------------------------------------------------------------
# 　イベントコマンドを実行するインタプリタです。
#==============================================================================
class Game_Interpreter
  #--------------------------------------------------------------------------
  # ● Change Actor HP -alias
  #--------------------------------------------------------------------------
  alias command_311_n01 command_311
  def command_311
    if $game_temp.in_battle
      value = operate_value(@params[1], @params[2], @params[3])
      iterate_actor_id(@params[0]) do |actor|
        next if actor.dead?
        if @params[4] == false and actor.hp + value <= 0
          actor.damage_num(actor.hp - 1) # If incapacitation is not allowed, make 1
        else
          actor.damage_num(-value)
        end
      end
      return true
    else
      command_311_n01
    end
  end
  #--------------------------------------------------------------------------
  # ● Change Enemy HP -rewrite
  #--------------------------------------------------------------------------
  def command_331
    value = operate_value(@params[1], @params[2], @params[3])
    iterate_enemy_index(@params[0]) do |enemy|
      if enemy.hp > 0
        if @params[4] == false and enemy.hp + value <= 0
          enemy.damage_num(enemy.hp - 1) # If incapacitation is not allowed, make 1
        else
          enemy.damage_num(-value)
        end
      end
    end
    return true
  end
end

#==============================================================================
# ■ Window_Help
#------------------------------------------------------------------------------
# 　スキルやアイテムの説明、アクターのステータスなどを表示するウィンドウです。
#==============================================================================

class Window_Help < Window_Base
  #--------------------------------------------------------------------------
  # ● テキスト設定
  #--------------------------------------------------------------------------
  def set_text_n01add(member)
    self.contents.clear
    return if member == nil || member.dead?
    self.contents.font.color = normal_color
    if !member.actor? && N01::ENEMY_NON_DISPLAY.include?(member.enemy_id)
      return self.contents.draw_text(4, 0, self.width - 40, WLH, member.name, 1)
    elsif member.actor? && !N01::ACTOR_DISPLAY
      return self.contents.draw_text(4, 0, self.width - 40, WLH, member.name, 1)
    end
    if N01::WORD_STATE_DISPLAY && N01::HP_DISPLAY
      self.contents.draw_text(0, 0, 180, WLH, member.name, 2)
      self.contents.font.size = 17
      draw_actor_hp(member, 182, -6, 120)
      draw_actor_mp(member, 182, 5, 120)
      text = "["
      for state in member.states
        next if N01::STATE_NON_DISPLAY.include?(state.id)
        text += " " if text != "["
        text += state.name
      end
      text += N01::WORD_NORMAL_STATE if text == "["
      text += "]"
      text = "" if text == "[]"
      self.contents.draw_text(315, 0, 195, WLH, text, 0)
    elsif N01::WORD_STATE_DISPLAY
      text = member.name + "  ["
      for state in member.states
        next if N01::STATE_NON_DISPLAY.include?(state.id)
        text += " " if text != member.name + "  ["
        text += state.name
      end
      text += N01::WORD_NORMAL_STATE if text == member.name + "  ["
      text += "]"
      text = "" if text == "[]"
      self.contents.draw_text(4, 0, self.width - 40, WLH, text, 1)
    elsif N01::HP_DISPLAY
      self.contents.draw_text(4, 0, 240, WLH, member.name, 1)
      draw_actor_hp(member, 262, 0, 120)
    end 
  end
end

#==============================================================================
# ■ Sprite_Battler
#------------------------------------------------------------------------------
#  This sprite is used to display battlers. It observes a instance of the
# Game_Battler class and automatically changes sprite conditions.
#==============================================================================
class Sprite_Battler < Sprite_Base
  #------------------------------------------------------------------------------
  # This method was taken from the ATB and moved to Sideview 2 to help
  # enable head and feet targeting.
  #------------------------------------------------------------------------------
  alias make_battler_hw_from_atb make_battler
  def make_battler
    make_battler_hw_from_atb
    
    @battler.graphics_width = @width
    @battler.graphics_height = @height
  end
end

#==============================================================================
# ■ Game_Party
#------------------------------------------------------------------------------
# 　パーティを扱うクラスです。
#==============================================================================
class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # ● アクターを加える
  #     actor_id : アクター ID
  #--------------------------------------------------------------------------
  alias add_actor_n01 add_actor
  def add_actor(actor_id)
    add_actor_n01(actor_id)
    $party_change = true if actor_id == 4 
  end
  #--------------------------------------------------------------------------
  # ● アクターを外す
  #     actor_id : アクター ID
  #--------------------------------------------------------------------------
  alias remove_actor_n01 remove_actor
  def remove_actor(actor_id)
    remove_actor_n01(actor_id)
    $party_change = true if actor_id == 4 
  end
end  
  


