#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Scene_Battle
# 【用途】VX 戰鬥場景核心，負責戰鬥開始、輸入、行動執行、訊息、結算與場景結束。
# 【主要機制】由 RGSS2 Scene 流程自動建立／更新；本專案後續 Menu／Battle／UI Patch 可能重開啟同類別。
# 【主要影響】Scene_Battle
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
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
# ** Scene_Battle
#------------------------------------------------------------------------------
#  這個類用來執行顯示作戰畫面的程式。
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * 程式開始
  #--------------------------------------------------------------------------
  def start
    super
    $game_temp.in_battle = true
    @spriteset = Spriteset_Battle.new
    @message_window = Window_BattleMessage.new
    @action_battlers = []
    create_info_viewport
  end
  #--------------------------------------------------------------------------
  # * 程式開始後的處理
  #--------------------------------------------------------------------------
  def post_start
    super
    process_battle_start
  end
  #--------------------------------------------------------------------------
  # * 程式終止
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_info_viewport
    @message_window.dispose
    @spriteset.dispose
    unless $scene.is_a?(Scene_Gameover)
      $scene = nil if $BTEST
    end
  end
  #--------------------------------------------------------------------------
  # * 基礎更新處理
  #     main : 呼叫主更新方法
  #--------------------------------------------------------------------------
  def update_basic(main = false)
    Graphics.update unless main     # 更新螢幕內容
    Input.update unless main        # 更新指令輸入資訊
    $game_system.update             # 更新計時器
    $game_troop.update              # 更新敵人隊伍資訊
    @spriteset.update               # 更新精靈物設
    @message_window.update          # 更新文本訊息視窗
  end
  #--------------------------------------------------------------------------
  # * 等待預定的時間
  #     duration : 等待時長（按幀數計算）
  #     no_fast  : 禁用快速播放畫面
  #    一種當場景畫面類更新內容顯示的過程的時候插入等待的方法。
  #    通常，顯示每一幀的時候都會呼叫一次畫面更新，
  #    不過在作戰時卻難以把握處理流程，所以這個方法被當作一種異常來使用。
  #--------------------------------------------------------------------------
  def wait(duration, no_fast = false)
    for i in 0...duration
      update_basic
      break if not no_fast and i >= duration / 2 and show_fast?
    end
  end
  #--------------------------------------------------------------------------
  # * 等待文本訊息顯示完畢
  #--------------------------------------------------------------------------
  def wait_for_message
    @message_window.update
    while $game_message.visible
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  # * 等待動畫播放顯示完畢
  #--------------------------------------------------------------------------
  def wait_for_animation
    while @spriteset.animation?
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  # * 快速播放畫面指令的判定
  #--------------------------------------------------------------------------
  def show_fast?
    return (Input.press?(Input::A) or Input.press?(Input::C))
  end
  #--------------------------------------------------------------------------
  # * 更新幀
  #--------------------------------------------------------------------------
  def update
    super
    update_basic(true)
    update_info_viewport                  # 更新資訊視口
    if $game_message.visible
      @info_viewport.visible = false
      @message_window.visible = true
    end
    unless $game_message.visible          # 除非正在顯示文本訊息
      return if judge_win_loss            # 判定作戰勝負結果
      update_scene_change
      if @target_enemy_window != nil
        update_target_enemy_selection     # 選擇目標敵人
      elsif @target_actor_window != nil
        update_target_actor_selection     # 選擇目標主角
      elsif @skill_window != nil
        update_skill_selection            # 選擇技能
      elsif @item_window != nil
        update_item_selection             # 選擇物品
      elsif @party_command_window.active
        update_party_command_selection    # 隊伍選單項目選擇
      elsif @actor_command_window.active
        update_actor_command_selection    # 主角行動選單項目選擇
      else
        process_battle_event              # 作戰事件處理
        process_action                    # 作戰行為
        process_battle_event              # 作戰事件處理
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 創建資訊顯示視口
  #--------------------------------------------------------------------------
  def create_info_viewport
    @info_viewport = Viewport.new(0, 288, 544, 128)
    @info_viewport.z = 100
    @status_window = Window_BattleStatus.new
    @party_command_window = Window_PartyCommand.new
    @actor_command_window = Window_ActorCommand.new
    #@actor_command_window.y = -50
    @status_window.viewport = @info_viewport
    @party_command_window.viewport = @info_viewport
    @actor_command_window.viewport = @info_viewport
    @status_window.x = 128
    @actor_command_window.x = 544
    @info_viewport.visible = false
  end
  #--------------------------------------------------------------------------
  # * 清除資訊顯示視口
  #--------------------------------------------------------------------------
  def dispose_info_viewport
    @status_window.dispose
    @party_command_window.dispose
    @actor_command_window.dispose
    @info_viewport.dispose
     for i in 0..4
      @sprites[i].dispose
    end
#    @ba.dispose
    @bf.dispose
    @bf2.dispose
    #@showd_window.dispose###
  end
  #--------------------------------------------------------------------------
  # * 更新資訊顯示視口內容
  #--------------------------------------------------------------------------
  def update_info_viewport
    @party_command_window.update
    @actor_command_window.update
    @status_window.update
    if @party_command_window.active and @info_viewport.ox > 0
      @info_viewport.ox -= 16
    elsif @actor_command_window.active and @info_viewport.ox < 128
      @info_viewport.ox += 16
    end
  end
  #--------------------------------------------------------------------------
  # * 作戰事件處理
  #--------------------------------------------------------------------------
  def process_battle_event
    loop do
      return if judge_win_loss
      return if $game_temp.next_scene != nil
      $game_troop.interpreter.update
      $game_troop.setup_battle_event
      wait_for_message
      process_action if $game_troop.forcing_battler != nil
      return unless $game_troop.interpreter.running?
      update_basic
    end
  end
  #--------------------------------------------------------------------------
  # * 判定作戰勝負結果
  #--------------------------------------------------------------------------
  def judge_win_loss
    if $game_temp.in_battle
      if $game_party.all_dead?
        process_defeat
        return true
      elsif $game_troop.all_dead?
        process_victory
        return true
      else
        return false
      end
    else
      return true
    end
  end
  #--------------------------------------------------------------------------
  # * 結束作戰
  #     result : 作戰結果 (0: 得勝, 1: 撤退, 2: 我方全滅)
  #--------------------------------------------------------------------------
  def battle_end(result)
    if result == 2 and not $game_troop.can_lose
      #@showd_window.dispose###
      call_gameover
    else
      $game_party.clear_actions
      $game_party.remove_states_battle
      #@showd_window.dispose###
      $game_troop.clear
      if $game_temp.battle_proc != nil
        $game_temp.battle_proc.call(result)
        $game_temp.battle_proc = nil
      end
      unless $BTEST
        $game_temp.map_bgm.play
        $game_temp.map_bgs.play
      end
   #     $game_switches[50] = false
   # @showd_window.dispose
      $scene = Scene_Map.new
      @message_window.clear
      Graphics.fadeout(30)
    end
    $game_temp.in_battle = false
  end
  #--------------------------------------------------------------------------
  # * 轉而接收下一個主角的指令輸入資訊
  #--------------------------------------------------------------------------
  def next_actor
    loop do
      if @actor_index == $game_party.members.size-1
        start_main
        return
      end
      @status_window.index = @actor_index += 1
      @active_battler = $game_party.members[@actor_index]
      if @active_battler.auto_battle
        @active_battler.make_action
        next
      end
      break if @active_battler.inputable?
    end
    start_actor_command_selection
  end
  #--------------------------------------------------------------------------
  # * 轉而接收上一個主角的指令輸入資訊
  #--------------------------------------------------------------------------
  def prior_actor
    loop do
      if @actor_index == 0
        start_party_command_selection
        return
      end
      @status_window.index = @actor_index -= 1
      @active_battler = $game_party.members[@actor_index]
      next if @active_battler.auto_battle
      break if @active_battler.inputable?
    end
    start_actor_command_selection
  end
  #--------------------------------------------------------------------------
  # * 開始接收隊伍選單命令項選擇指令輸入資訊
  #--------------------------------------------------------------------------
  def start_party_command_selection
    if $game_temp.in_battle
      @status_window.refresh
      @status_window.index = @actor_index = -1
      @active_battler = nil
      @info_viewport.visible = true
      @message_window.visible = false
      @party_command_window.active = true
      @party_command_window.index = 0
      @actor_command_window.active = false
      $game_party.clear_actions
      if $game_troop.surprise or not $game_party.inputable?
        start_main
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 更新隊伍選單命令項選擇指令輸入資訊
  #--------------------------------------------------------------------------
  def update_party_command_selection
    if Input.trigger?(Input::C)
      case @party_command_window.index
      when 0  # 作戰
        Sound.play_decision
        @status_window.index = @actor_index = -1
        next_actor
      when 1  # 撤退
        if $game_troop.can_escape == false
          Sound.play_buzzer
          return
        end
        Sound.play_decision
        process_escape
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 開始接收主角行動指令選擇的指令輸入資訊
  #--------------------------------------------------------------------------
  def start_actor_command_selection
    @party_command_window.active = false
    @actor_command_window.setup(@active_battler)
    @actor_command_window.active = true
    @actor_command_window.index = 0
  end
  #--------------------------------------------------------------------------
  # * 更新主角行動指令選擇的指令輸入資訊
  #--------------------------------------------------------------------------
  def update_actor_command_selection
    if Input.trigger?(Input::B)
      Sound.play_cancel
      prior_actor
    elsif Input.trigger?(Input::C)
      case @actor_command_window.index
      when 0  # 攻擊
        Sound.play_decision
        @active_battler.action.set_attack
        start_target_enemy_selection
      when 1  # 技能
        Sound.play_decision
        start_skill_selection
      when 2  # 防禦
        Sound.play_decision
        @active_battler.action.set_guard
        next_actor
      when 3  # 用品
        Sound.play_decision
        start_item_selection
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 開始接收選擇目標敵人的指令輸入資訊
  #--------------------------------------------------------------------------
  def start_target_enemy_selection
    @target_enemy_window = Window_TargetEnemy.new
    @target_enemy_window.y = @info_viewport.rect.y
    @info_viewport.rect.x += @target_enemy_window.width
    @info_viewport.ox += @target_enemy_window.width
    @actor_command_window.active = false
  end
  #--------------------------------------------------------------------------
  # * 停止接收選擇目標敵人的指令輸入資訊
  #--------------------------------------------------------------------------
  def end_target_enemy_selection
    @info_viewport.rect.x -= @target_enemy_window.width
    @info_viewport.ox -= @target_enemy_window.width
    @target_enemy_window.dispose
    @target_enemy_window = nil
    if @actor_command_window.index == 0
      @actor_command_window.active = true
    end
  end
  #--------------------------------------------------------------------------
  # * 更新目標敵人選擇的指令輸入資訊
  #--------------------------------------------------------------------------
  def update_target_enemy_selection
    @target_enemy_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_target_enemy_selection
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      @active_battler.action.target_index = @target_enemy_window.enemy.index
      end_target_enemy_selection
      end_skill_selection
      end_item_selection
      next_actor
    end
  end
  #--------------------------------------------------------------------------
  # * 開始接收選擇目標主角的指令輸入資訊
  #--------------------------------------------------------------------------
  def start_target_actor_selection
    @target_actor_window = Window_BattleStatus.new
    @target_actor_window.index = 0
    @target_actor_window.active = true
    @target_actor_window.y = @info_viewport.rect.y
    @info_viewport.rect.x += @target_actor_window.width
    @info_viewport.ox += @target_actor_window.width
    @actor_command_window.active = false
  end
  #--------------------------------------------------------------------------
  # * 停止接收選擇目標主角的指令輸入資訊
  #--------------------------------------------------------------------------
  def end_target_actor_selection
    @info_viewport.rect.x -= @target_actor_window.width
    @info_viewport.ox -= @target_actor_window.width
    @target_actor_window.dispose
    @target_actor_window = nil
  end
  #--------------------------------------------------------------------------
  # * 更新目標主角選擇的指令輸入資訊
  #--------------------------------------------------------------------------
  def update_target_actor_selection
    @target_actor_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_target_actor_selection
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      @active_battler.action.target_index = @target_actor_window.index
      end_target_actor_selection
      end_skill_selection
      end_item_selection
      next_actor
    end
  end
  #--------------------------------------------------------------------------
  # * 開始接收技能選擇的指令輸入資訊
  #--------------------------------------------------------------------------
  def start_skill_selection
    @help_window = Window_Help.new###
    @skill_window = Window_Skill.new(0, 56, 544, 232, @active_battler)
    @skill_window.help_window = @help_window
    @actor_command_window.active = false
  end
  #--------------------------------------------------------------------------
  # * 停止接收技能選擇的指令輸入資訊
  #--------------------------------------------------------------------------
  def end_skill_selection
    if @skill_window != nil
      @skill_window.dispose
      @skill_window = nil
      @help_windowx.dispose###
      @help_windowx = nil###
    end
    @actor_command_window.active = true
  end
  #--------------------------------------------------------------------------
  # * 更新技能選擇的指令輸入資訊
  #--------------------------------------------------------------------------
  def update_skill_selection
    @skill_window.active = true
    @skill_window.update
    @help_windowx.update###
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_skill_selection
    elsif Input.trigger?(Input::C)
      @skill = @skill_window.skill
      if @skill != nil
        @active_battler.last_skill_id = @skill.id
      end
      if @active_battler.skill_can_use?(@skill)
        Sound.play_decision
        determine_skill
      else
        Sound.play_buzzer
      end
    end
  end
  #--------------------------------------------------------------------------
  # * 確認技能此時是否可用
  #--------------------------------------------------------------------------
  def determine_skill
    @active_battler.action.set_skill(@skill.id)
    @skill_window.active = false
    if @skill.need_selection?
      if @skill.for_opponent?
        start_target_enemy_selection
      else
        start_target_actor_selection
      end
    else
      end_skill_selection
      next_actor
    end
  end
  #--------------------------------------------------------------------------
  # * 開始接收物品選擇的指令輸入資訊
  #--------------------------------------------------------------------------
  def start_item_selection
    @help_window = Window_Help.new
    @item_window = Window_Item.new(0, 56, 544, 232)
    @item_window.help_window = @help_window
    @actor_command_window.active = false
  end
  #--------------------------------------------------------------------------
  # * 停止接收物品選擇的指令輸入資訊
  #--------------------------------------------------------------------------
  def end_item_selection
    if @item_window != nil
      @item_window.dispose
      @item_window = nil
      @help_window.dispose
      @help_window = nil
    end
    @actor_command_window.active = true
  end
  #--------------------------------------------------------------------------
  # * 更新物品選擇的指令輸入資訊
  #--------------------------------------------------------------------------
  def update_item_selection
    @item_window.active = true
    @item_window.update
    @help_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      end_item_selection
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
  # * 確認物品此時是否可用
  #--------------------------------------------------------------------------
  def determine_item
    @active_battler.action.set_item(@item.id)
    @item_window.active = false
    if @item.need_selection?
      if @item.for_opponent?
        start_target_enemy_selection
      else
        start_target_actor_selection
      end
    else
      end_item_selection
      next_actor
    end
  end
  #--------------------------------------------------------------------------
  # * 作戰進程開始
  #--------------------------------------------------------------------------
  def process_battle_start
    @message_window.clear
    wait(10)
    for name in $game_troop.enemy_names
      text = sprintf(Vocab::Emerge, name)
      $game_message.texts.push(text)
    end
    if $game_troop.preemptive
      text = sprintf(Vocab::Preemptive, $game_party.name)
      $game_message.texts.push(text)
    elsif $game_troop.surprise
      text = sprintf(Vocab::Surprise, $game_party.name)
      $game_message.texts.push(text)
    end
    wait_for_message
    @message_window.clear
    make_escape_ratio
    process_battle_event
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # * 生成撤退比率
  #--------------------------------------------------------------------------
  def make_escape_ratio
    actors_agi = $game_party.average_agi
    enemies_agi = $game_troop.average_agi
    @escape_ratio = 150 - 100 * enemies_agi / actors_agi
  end
  #--------------------------------------------------------------------------
  # * 關於撤退的處理
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
    if success
      wait_for_message
      battle_end(1)
    else
      @escape_ratio += 10
      $game_message.texts.push('\.' + Vocab::EscapeFailure)
      wait_for_message
      $game_party.clear_actions
      start_main
    end
  end
  #--------------------------------------------------------------------------
  # * 關於作戰勝利的處理
  #--------------------------------------------------------------------------
  def process_victory
    @info_viewport.visible = false
    #@showd_window.visible = false
    $game_switches[50] = false
    @friend_window.dispose if @friend_window != nil#勝利
    @bitmap_name.dispose if @bitmap_name
    @message_window.visible = true
    RPG::BGM.stop
    $game_system.battle_end_me.play
    unless $BTEST
      $game_temp.map_bgm.play
      $game_temp.map_bgs.play
    end
#    display_exp_and_gold
#    display_drop_items
#    display_level_up
    display_result
    battle_end(0)
  end
  #--------------------------------------------------------------------------
  # * 顯示所獲得的經驗值和敵人掉落的資金
  #--------------------------------------------------------------------------
  def display_exp_and_gold
    exp = $game_troop.exp_total
    gold = $game_troop.gold_total
    $game_party.gain_gold(gold)
    text = sprintf(Vocab::Victory, $game_party.name)
    $game_message.texts.push('\|' + text)
    if exp > 0
      text = sprintf(Vocab::ObtainExp, exp)
      $game_message.texts.push('\.' + text)
    end
    if gold > 0
      text = sprintf(Vocab::ObtainGold, gold, Vocab::gold)
      $game_message.texts.push('\.' + text)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * 顯示所獲得的敵人掉落的物品
  #--------------------------------------------------------------------------
  def display_drop_items
    drop_items = $game_troop.make_drop_items
    for item in drop_items
      $game_party.gain_item(item, 1)
      text = sprintf(Vocab::ObtainItem, item.name)
      $game_message.texts.push(text)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * 顯示等級提升訊息
  #--------------------------------------------------------------------------
  def display_level_up
    exp = $game_troop.exp_total
    for actor in $game_party.existing_members
      last_level = actor.level
      last_skills = actor.skills
      actor.gain_exp(exp, true)
    end
    wait_for_message
  end
  #--------------------------------------------------------------------------
  # * 關於作戰失敗的處理
  #--------------------------------------------------------------------------
  def process_defeat
    @info_viewport.visible = false
#    $game_switches[50] = false
#    @showd_window.dispose
    @message_window.visible = true
    text = sprintf(Vocab::Defeat, $game_party.name)
    $game_message.texts.push(text)
    wait_for_message
    battle_end(2)
  end
  #--------------------------------------------------------------------------
  # * 執行畫面切換
  #--------------------------------------------------------------------------
  def update_scene_change
    #@showd_window.dispose
    case $game_temp.next_scene
    
    when "map"
      #@showd_window.dispose
      call_map
    when "gameover"
      #@showd_window.dispose
      call_gameover
    when "title"
      #@showd_window.dispose
      call_title
    else
      $game_temp.next_scene = nil
    end
  end
  #--------------------------------------------------------------------------
  # * 切換至地圖場景畫面
  #--------------------------------------------------------------------------
  def call_map
    $game_temp.next_scene = nil
    battle_end(1)
  end
  #--------------------------------------------------------------------------
  # * 切換至GAMEOVER畫面
  #--------------------------------------------------------------------------
  def call_gameover
    $game_temp.next_scene = nil
    $scene = Scene_Gameover.new
    @message_window.clear
  end
  #--------------------------------------------------------------------------
  # * 切換至標題畫面
  #--------------------------------------------------------------------------
  def call_title
    $game_temp.next_scene = nil
    $scene = Scene_Title.new
    @message_window.clear
    Graphics.fadeout(60)
  end
  #--------------------------------------------------------------------------
  # * 開始執行作戰程式
  #--------------------------------------------------------------------------
  def start_main
    $game_troop.increase_turn
    @info_viewport.visible = false
    @info_viewport.ox = 0
    @message_window.visible = true
    @party_command_window.active = false
    @actor_command_window.active = false
    @status_window.index = @actor_index = -1
    @active_battler = nil
    @message_window.clear
    $game_troop.make_actions
    make_action_orders
    wait(20)
  end
  #--------------------------------------------------------------------------
  # * 創建行為指令
  #--------------------------------------------------------------------------
  def make_action_orders
    @action_battlers = []
    unless $game_troop.surprise
      @action_battlers += $game_party.members
    end
    unless $game_troop.preemptive
      @action_battlers += $game_troop.members
    end
    for battler in @action_battlers
      battler.action.make_speed
    end
    @action_battlers.sort! do |a,b|
      b.action.speed - a.action.speed
    end
  end
  #--------------------------------------------------------------------------
  # * 作戰行為處理
  #--------------------------------------------------------------------------
  def process_action
    return if judge_win_loss
    return if $game_temp.next_scene != nil
    set_next_active_battler
    if @active_battler == nil
      turn_end
      return
    end
    @message_window.clear
    wait(5)
    @active_battler.white_flash = true
    unless @active_battler.action.forcing
      @active_battler.action.prepare
    end
    if @active_battler.action.valid?
      execute_action
    end
    unless @active_battler.action.forcing
      @message_window.clear
      remove_states_auto
      display_current_state
    end
    @active_battler.white_flash = false
    @message_window.clear
  end
  #--------------------------------------------------------------------------
  # * 執行作戰行為
  #--------------------------------------------------------------------------
  def execute_action
    case @active_battler.action.kind
    when 0  # 本能
      case @active_battler.action.basic
      when 0  # 攻擊
        execute_action_attack
      when 1  # 防禦
        execute_action_guard
      when 2  # 撤退
        execute_action_escape
      when 3  # 等待
        execute_action_wait
      end
    when 1  # 技能
       execute_action_skill
    when 2  # 物品
      execute_action_item
    end
  end
  #--------------------------------------------------------------------------
  # * 回合結束
  #--------------------------------------------------------------------------
  def turn_end
    $game_troop.turn_ending = true
    $game_party.slip_damage_effect
    $game_troop.slip_damage_effect
    $game_party.do_auto_recovery
    $game_troop.preemptive = false
    $game_troop.surprise = false
    process_battle_event
    $game_troop.turn_ending = false
    start_party_command_selection
  end
  #--------------------------------------------------------------------------
  # * 安排下一個參戰者的行動
  #    當[強行下達指令……]這條事件指令正在執行的時候，將這個被下達指令的參戰
  #    者從這個調度清單中除名。否則從這個調度清單的頂端讀取並調度行動。
  #    如果調度清單中的參戰者不在場（比如說目標敵人被掛掉而留下了空的編號，或
  #    者我方有主角在[隊伍人事調動]這個事件指令的影響下離開了戰場，或者更多類
  #    似的情況），則直接跳過。
  #--------------------------------------------------------------------------
  def set_next_active_battler
    loop do
      if $game_troop.forcing_battler != nil
        @active_battler = $game_troop.forcing_battler
        @action_battlers.delete(@active_battler)
        $game_troop.forcing_battler = nil
      else
        @active_battler = @action_battlers.shift
      end
      return if @active_battler == nil
      return if @active_battler.index != nil
    end
  end
  #--------------------------------------------------------------------------
  # * 自動解除狀態
  #--------------------------------------------------------------------------
  def remove_states_auto
    last_st = @active_battler.states
    @active_battler.remove_states_auto
    if @active_battler.states != last_st
      wait(5)
      display_state_changes(@active_battler)
      wait(30)
      @message_window.clear
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示當前狀態資訊
  #--------------------------------------------------------------------------
  def display_current_state
    state_text = @active_battler.most_important_state_text
    unless state_text.empty?
      wait(5)
      text = @active_battler.name + state_text
      @message_window.add_instant_text(text)
      wait(45)
      @message_window.clear
    end
  end
  #--------------------------------------------------------------------------
  # * 執行戰鬥行為：攻擊
  #--------------------------------------------------------------------------
  def execute_action_attack
    text = sprintf(Vocab::DoAttack, @active_battler.name)
    @message_window.add_instant_text(text)
    targets = @active_battler.action.make_targets
    display_attack_animation(targets)
    wait(20)
    for target in targets
      target.attack_effect(@active_battler)
      display_action_effects(target)
    end
  end
  #--------------------------------------------------------------------------
  # * 執行戰鬥行為：防禦
  #--------------------------------------------------------------------------
  def execute_action_guard
    text = sprintf(Vocab::DoGuard, @active_battler.name)
    @message_window.add_instant_text(text)
    wait(45)
  end
  #--------------------------------------------------------------------------
  # * 執行戰鬥行為：撤退
  #--------------------------------------------------------------------------
  def execute_action_escape
    text = sprintf(Vocab::DoEscape, @active_battler.name)
    @message_window.add_instant_text(text)
    @active_battler.escape
    Sound.play_escape
    wait(45)
  end
  #--------------------------------------------------------------------------
  # * 執行戰鬥行為：等待
  #--------------------------------------------------------------------------
  def execute_action_wait
    text = sprintf(Vocab::DoWait, @active_battler.name)
    @message_window.add_instant_text(text)
    wait(45)
  end
  #--------------------------------------------------------------------------
  # * 執行戰鬥行為：使用技能
  #--------------------------------------------------------------------------
  def execute_action_skill
    skill = @active_battler.action.skill
    text = @active_battler.name + skill.message1
    @message_window.add_instant_text(text)
    unless skill.message2.empty?
      wait(10)
      @message_window.add_instant_text(skill.message2)
    end
    targets = @active_battler.action.make_targets
    display_animation(targets, skill.animation_id)
    @active_battler.mp -= @active_battler.calc_mp_cost(skill)
    $game_temp.common_event_id = skill.common_event_id
    for target in targets
      target.skill_effect(@active_battler, skill)
      display_action_effects(target, skill)
    end
  end
  #--------------------------------------------------------------------------
  # * 執行戰鬥行為：使用物品
  #--------------------------------------------------------------------------
  def execute_action_item
    item = @active_battler.action.item
    text = sprintf(Vocab::UseItem, @active_battler.name, item.name)
    @message_window.add_instant_text(text)
    targets = @active_battler.action.make_targets
    display_animation(targets, item.animation_id)
    $game_party.consume_item(item)
    $game_temp.common_event_id = item.common_event_id
    for target in targets
      target.item_effect(@active_battler, item)
      display_action_effects(target, item)
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示動畫
  #     targets      : 顯示位置
  #     animation_id : 動畫編號（如果為-1則播放普通攻擊動畫）
  #--------------------------------------------------------------------------
  def display_animation(targets, animation_id)
    if animation_id < 0
      display_attack_animation(targets)
    else
      display_normal_animation(targets, animation_id)
    end
    wait(20)
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # * 顯示攻擊動畫
  #     targets : 顯示位置
  #    如果是敵人，只播放[敵人攻擊]聲效，然後等待一陣子。
  #    如果是主角則同時考慮到貳刀流主角的情況（左手動畫水準翻轉顯示）
  #--------------------------------------------------------------------------
  def display_attack_animation(targets)
    if @active_battler.is_a?(Game_Enemy)
      Sound.play_enemy_attack
      wait(15, true)
    else
      aid1 = @active_battler.atk_animation_id
      aid2 = @active_battler.atk_animation_id2
      display_normal_animation(targets, aid1, false)
      display_normal_animation(targets, aid2, true)
    end
    wait_for_animation
  end
  #--------------------------------------------------------------------------
  # * 顯示普通動畫
  #     targets      : 顯示位置
  #     animation_id : 動畫編號
  #     mirror       : 水準翻轉
  #--------------------------------------------------------------------------
  def display_normal_animation(targets, animation_id, mirror = false)
    animation = $data_animations[animation_id]
    if animation != nil
      to_screen = (animation.position == 3)       # 動畫顯示基準位置為全螢幕？
      for target in targets.uniq
        target.animation_id = animation_id
        target.animation_mirror = mirror
        wait(20, true) unless to_screen           # 如果是單體動畫，等待
      end
      wait(20, true) if to_screen                 # 如果是全體動畫，等待
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示行動結果
  #     target : 目標參戰者
  #     obj    : 技能或物品
  #--------------------------------------------------------------------------
  def display_action_effects(target, obj = nil)
    unless target.skipped
      line_number = @message_window.line_number
      wait(5)
      display_critical(target, obj)
      display_damage(target, obj)
      display_state_changes(target, obj)
      if line_number == @message_window.line_number
        display_failure(target, obj) unless target.states_active?
      end
      if line_number != @message_window.line_number
        wait(30)
      end
      @message_window.back_to(line_number)
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示會心一擊資訊
  #     target : 目標參戰者
  #     obj    : 技能或物品
  #--------------------------------------------------------------------------
  def display_critical(target, obj = nil)
    if target.critical
      if target.actor?
        text = Vocab::CriticalToActor
      else
        text = Vocab::CriticalToEnemy
      end
      @message_window.add_instant_text(text)
      wait(20)
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示傷害資訊
  #     target : 目標參戰者
  #     obj    : 技能或物品
  #--------------------------------------------------------------------------
  def display_damage(target, obj = nil)
    if target.missed
      display_miss(target, obj)
    elsif target.evaded
      display_evasion(target, obj)
    else
      display_hp_damage(target, obj)
      display_mp_damage(target, obj)
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示落空資訊
  #     target : 目標參戰者
  #     obj    : 技能或物品
  #--------------------------------------------------------------------------
  def display_miss(target, obj = nil)
    if obj == nil or obj.physical_attack
      if target.actor?
        text = sprintf(Vocab::ActorNoHit, target.name)
      else
        text = sprintf(Vocab::EnemyNoHit, target.name)
      end
      Sound.play_miss
    else
      text = sprintf(Vocab::ActionFailure, target.name)
    end
    @message_window.add_instant_text(text)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * 顯示撤退資訊
  #     target : 目標參戰者
  #     obj    : 技能或物品
  #--------------------------------------------------------------------------
  def display_evasion(target, obj = nil)
    if target.actor?
      text = sprintf(Vocab::ActorEvasion, target.name)
    else
      text = sprintf(Vocab::EnemyEvasion, target.name)
    end
    Sound.play_evasion
    @message_window.add_instant_text(text)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * 顯示HP傷害資訊
  #     target : 目標參戰者
  #     obj    : 技能或物品
  #--------------------------------------------------------------------------
  def display_hp_damage(target, obj = nil)
    if target.hp_damage == 0                # 無HP傷害
      return if obj != nil and obj.damage_to_mp
      return if obj != nil and obj.base_damage == 0
      fmt = target.actor? ? Vocab::ActorNoDamage : Vocab::EnemyNoDamage
      text = sprintf(fmt, target.name)
    elsif target.absorbed                   # HP被汲取
      fmt = target.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      text = sprintf(fmt, target.name, Vocab::hp, target.hp_damage)
    elsif target.hp_damage > 0              # HP傷害
      if target.actor?
        text = sprintf(Vocab::ActorDamage, target.name, target.hp_damage)
        Sound.play_actor_damage
        $game_troop.screen.start_shake(5, 5, 10)
      else
        text = sprintf(Vocab::EnemyDamage, target.name, target.hp_damage)
        Sound.play_enemy_damage
        target.blink = true
      end
    else                                    # HP恢復
      fmt = target.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      text = sprintf(fmt, target.name, Vocab::hp, -target.hp_damage)
      Sound.play_recovery
    end
    @message_window.add_instant_text(text)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * 顯示MP傷害資訊
  #     target : 目標參戰者
  #     obj    : 技能或物品
  #--------------------------------------------------------------------------
  def display_mp_damage(target, obj = nil)
    return if target.dead?
    return if target.mp_damage == 0
    if target.absorbed                      # MP被汲取
      fmt = target.actor? ? Vocab::ActorDrain : Vocab::EnemyDrain
      text = sprintf(fmt, target.name, Vocab::mp, target.mp_damage)
    elsif target.mp_damage > 0              # MP傷害
      fmt = target.actor? ? Vocab::ActorLoss : Vocab::EnemyLoss
      text = sprintf(fmt, target.name, Vocab::mp, target.mp_damage)
    else                                    # MP恢復
      fmt = target.actor? ? Vocab::ActorRecovery : Vocab::EnemyRecovery
      text = sprintf(fmt, target.name, Vocab::mp, -target.mp_damage)
      Sound.play_recovery
    end
    @message_window.add_instant_text(text)
    wait(30)
  end
  #--------------------------------------------------------------------------
  # * 顯示狀態改變的資訊
  #     target : 目標參戰者
  #     obj    : 技能或物品
  #--------------------------------------------------------------------------
  def display_state_changes(target, obj = nil)
    return if target.missed or target.evaded
    return unless target.states_active?
    if @message_window.line_number < 4
      @message_window.add_instant_text("")
    end
    display_added_states(target, obj)
    display_removed_states(target, obj)
    display_remained_states(target, obj)
    if @message_window.last_instant_text.empty?
      @message_window.back_one
    else
      wait(10)
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示被附加的狀態的訊息
  #     target : 目標參戰者
  #     obj    : 技能或物品
  #--------------------------------------------------------------------------
  def display_added_states(target, obj = nil)
    for state in target.added_states
      if target.actor?
        next if state.message1.empty?
        text = target.name + state.message1
      else
        next if state.message2.empty?
        text = target.name + state.message2
      end
      if state.id == 1                      # 瀕死？
        target.perform_collapse
      end
      @message_window.replace_instant_text(text)
      wait(20)
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示被解除的狀態的訊息
  #     target : 目標參戰者
  #     obj    : 技能或物品
  #--------------------------------------------------------------------------
  def display_removed_states(target, obj = nil)
    for state in target.removed_states
      next if state.message4.empty?
      text = target.name + state.message4
      @message_window.replace_instant_text(text)
      wait(20)
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示持續存在的狀態的訊息
  #     target : 目標參戰者
  #     obj    : 技能或物品
  #    用於催眠某個睡眠狀態的參戰者等情況。
  #--------------------------------------------------------------------------
  def display_remained_states(target, obj = nil)
    for state in target.remained_states
      next if state.message3.empty?
      text = target.name + state.message3
      @message_window.replace_instant_text(text)
      wait(20)
    end
  end
  #--------------------------------------------------------------------------
  # * 顯示失敗訊息
  #     target : 目標參戰者（主角）
  #     obj    : 技能或物品
  #--------------------------------------------------------------------------
  def display_failure(target, obj)
    text = sprintf(Vocab::ActionFailure, target.name)
    @message_window.add_instant_text(text)
    wait(20)
  end
end
