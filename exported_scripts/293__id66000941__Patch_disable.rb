#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：Patch disable
# 【用途】保留的 Runtime 元件「Patch disable」。
# 【主要機制】主要定義／擴充 Scene_Battle、N01；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Scene_Battle、N01
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
=begin
===============================================================================
Patch for enabling the disabling(?) of Input during animation
and stopping ATB gauge too.
(sorry about the lame title)
For Skill Activation system
by CrimsonSeas
===============================================================================
If you tried debugging the script as much as I do, you'll soon find out how
annoying it is when you have an animation that will get an activation process,
but because the animation took quite a long time another character took their turn
before the first character reach activation process. So you think you'll give the
next character his/her command, but in the process of doing so suddenly the
activation process came up! It's annoying as hell for me, so I tried making this
patch to disable all command input and ATB gauge as well.
This only works in conjunction with my Skill Activation script.
And it's not recommended to use this without ATB script, haven't tested it out
yet but I thought this won't work well there
================================================================================
HOW TO USE
================================================================================
When making the skill animation, input these 2 keyword that marks the start and
end of the disabling process. It's quite similar to how you apply "Activation"
"Cmd_Disable" starts the input disabling
"Cmd_Enable" stops the input disabling
"ATB_Disable" stops ATB gauge
"ATB_Enable" starts ATB gauge
This way you get more control over the disabling.
Don't to forget reenable or the game will stuck.
================================================================================
=end

module N01
  patch = {"Cmd_Disable" => ["script", "$cmd_disabled = true"],
            "Cmd_Enable" => ["script", "$cmd_disabled = false"],
            "ATB_Disable" =>["script", "$atb_disable = true"],
            "ATB_Enable"  =>["script", "$atb_disable = false"]}
  ANIME.merge!(patch)
end

class Scene_Battle
   def update_patched
    Graphics.update
    Input.update
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
    update_atb unless $atb_disabled
    # ターゲット更新
    update_target if @target_members != nil
    # コマンド入力フェイズ
    unless $cmd_disabled
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
  end
end