#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：シーンクラス
# 【用途】保留的 Runtime 元件「シーンクラス」。
# 【主要機制】主要定義／擴充 Scene_Blacksmith；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Scene_Blacksmith
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：INFO_FLEX、CB_YN、CB_S_PT、CB_D_PT。核心方法除非已確認依賴鏈，不建議直接覆寫。
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
# ■ VX-RGSS2-17 鍛冶屋 [シーンクラス]             by Claimh
#==============================================================================

#==============================================================================
# ■ Scene_Blacksmith
#==============================================================================
class Scene_Blacksmith < Scene_Base
  include Blacksmith::MesCmd
  
  INFO_FLEX = false  # infoウィンドウ表示中にもアイテム選択可能とする
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background
    @help_window = Window_Help.new
    @help_window.opacity = 255
    @gold_window = Window_Gold.new(384, 56)
    @sys_window  = Window_BsSysCmd.new
    @mod_window  = Window_BsModCmd.new(@sys_window.sys)
    @ctg_window  = Window_BsCtg.new
    @list_window = Window_BsList.new(@sys_window.sys, @mod_window.mod)
    @sl_window   = Window_BsSList.new
    @pt_window   = Window_BsActors.new
    @sts_window  = Window_BsStatus.new(@sys_window.sys)
    @info_window = Window_BsItemInfo.new
    @yn_window   = Window_BsYesNo.new
    @mes_window  = Window_BsCaution.new
    #
    if @sys_window.fix?
      @sys_window.disable
      if @mod_window.fix?
        @mod_window.disable
        @list_window.enable
        @ctg_window.change(@mod_window.mod)
        if @ctg_window.fix? # sys/mod/ctg全て固定の場合はmodを表示
          @mod_window.visible = true
        end
      else
        @mod_window.sys = @sys_window.sys
        @mod_window.enable
      end
    else
      @mod_window.disable
    end
    #
    @sl_window.pt_window   = @pt_window
    @sl_window.sts_window  = @sts_window
    @sl_window.help_window = @help_window
    @list_window.pt_window   = @pt_window
    @list_window.sts_window  = @sts_window
    @list_window.help_window = @help_window
    delete_help
    #
    @equip = false
    @actor = nil
  end
  def delete_help
    @help_window.set_text("")
    @pt_window.item = @sts_window.item = nil
    @sts_window.mode_reset(@sys_window.sys)
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @help_window.dispose
    @gold_window.dispose
    @sys_window.dispose
    @mod_window.dispose
    @ctg_window.dispose
    @list_window.dispose
    @sl_window.dispose
    @pt_window.dispose
    @info_window.dispose
    @sts_window.dispose
    @yn_window.dispose
    @mes_window.dispose
  end
  #----------------------------------------------------------------------------
  # ● 予約処理実行
  #----------------------------------------------------------------------------
  CB_YN   = 0
  CB_S_PT = 1
  CB_D_PT = 2
  def callback(ptn)
    case ptn
    when CB_YN
      #@list_window.active = true
      #@yn_window.enable###
      execute
      #@yn_window.disable
    when CB_S_PT
      @pt_window.refresh(@elist)
      @pt_window.active = true
      @pt_window.index = @elist[0]
    when CB_D_PT
      @pt_window.index = -1
      @pt_window.active = false
    when M_E_D, M_E_C
      Sound.play_equip
      @mes_window.set_text(ptn, @actor)
      @actor = nil
    end
  end
  #----------------------------------------------------------------------------
  # ● フレーム更新
  #----------------------------------------------------------------------------
  def update
    if @mes_window.visible
      @mes_window.update
    elsif @info_window.visible
      update_info
    elsif @sys_window.active
      update_sys
    elsif @mod_window.active
      update_mod
    elsif @list_window.active
      update_list
    elsif @sl_window.active
      update_slist
    elsif @yn_window.active
      update_yesno
    elsif @pt_window.active
      update_party
    end
  end
  #----------------------------------------------------------------------------
  # ● フレーム更新 : @sys_window
  #----------------------------------------------------------------------------
  def update_sys
    @sys_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      if @sys_window.exit?
        $scene = Scene_Map.new
      elsif @mod_window.fix?
        @sts_window.mode_reset(@sys_window.sys)
        @list_window.change_t(@sys_window.sys * 2 + @mod_window.mod)
        @list_window.enable
        @ctg_window.change(@mod_window.mod)
        if @ctg_window.fix?
          @sys_window.active = false
        else
          @sys_window.disable
        end
      else
        @sys_window.disable
        @mod_window.sys = @sys_window.sys
        @mod_window.enable
      end
    end
  end
  #----------------------------------------------------------------------------
  # ● フレーム更新 : @mod_window
  #----------------------------------------------------------------------------
  def update_mod
    @mod_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      if @sys_window.fix?
        $scene = Scene_Map.new
      else
        @sys_window.enable
        @mod_window.disable
      end
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      if @mod_window.exit?
        $scene = Scene_Map.new
      else
        @ctg_window.change(@mod_window.mod)
        @sts_window.mode_reset(@sys_window.sys)
        @list_window.change_t(@sys_window.sys * 2 + @mod_window.mod, @ctg_window.index)
        @list_window.enable
        @list_window.update_help
        if @ctg_window.fix?
          @mod_window.active = false
        else
          @mod_window.disable
        end
      end
    end
  end
  #----------------------------------------------------------------------------
  # ● フレーム更新 : @list_window
  #----------------------------------------------------------------------------
  def update_list
    if Input.trigger?(Input::LEFT) and !@ctg_window.fix?
      Sound.play_cursor
      @ctg_window.shift_l
      @list_window.change_c(@ctg_window.index)
      return
    elsif Input.trigger?(Input::RIGHT) and !@ctg_window.fix?
      Sound.play_cursor
      @ctg_window.shift_r
      @list_window.change_c(@ctg_window.index)
      return
    elsif Input.trigger?(Input::X) and !@sts_window.fix?
      Sound.play_cursor
      @sts_window.change_mode
      return
    end
    
    @list_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      if @sys_window.fix? and @mod_window.fix?
        $scene = Scene_Map.new
      else
        @mod_window.fix? ? @sys_window.enable : @mod_window.enable
        @ctg_window.visible = false
        @list_window.disable
        delete_help
      end
    elsif Input.trigger?(Input::C)
      unless @list_window.enable?
        Sound.play_buzzer
        @mes_window.set_text(@list_window.data.message) unless @list_window.data.nil?
        return
      end
      Sound.play_decision
      @list_window.active = false
      if @list_window.sys_create?
        Blacksmith::SUCCESS_SE.play unless Blacksmith::SUCCESS_SE.nil?
        @mes_window.set_text(M_S_C, @list_window.data.obj)
        if @list_window.data.equippable_members.size == 0
          @equip = false
          execute
        else
          @mes_window.set_callback(CB_YN)###
        end
      else
        @sts_window.mode_reset(0)
        @sl_window.startup(@list_window.data)
      end
    elsif Input.trigger?(Input::Y)
      Sound.play_decision
      @info_window.visible = !@info_window.visible
      @info_window.item = @list_window.item
    end
  end
  #----------------------------------------------------------------------------
  # ● フレーム更新 : @sl_window
  #----------------------------------------------------------------------------
  def update_slist
    if Input.trigger?(Input::A)
      Sound.play_cursor
      @sts_window.change_mode
      return
    end

    @sl_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @list_window.enable
      @sl_window.disable
      @sts_window.mode_reset(@sys_window.sys)
      @list_window.update_help
    elsif Input.trigger?(Input::C)
      unless @sl_window.enable?
        Sound.play_buzzer
        @mes_window.set_text(@sl_window.data.message) unless @sl_window.data.nil?
        return
      end
      Blacksmith::SUCCESS_SE.play unless Blacksmith::SUCCESS_SE.nil?
      @mes_window.set_text(M_S_S, @sl_window.data.obj)
      @sl_window.active = false
      d = @list_window.data
      if d.num == 0 # 所持品ない == 装備品Only
        @elist = []
        for i in d.equip_actors # 強化したアイテムが装備できるメンバーを抽出
          @elist.push(i) if $game_party.members[i].equippable?(@sl_window.data.obj)
        end
        if @elist.size > 1  # 複数人が装備可能 → 選択
          @equip = true
          @mes_window.set_callback(CB_S_PT)
        elsif @elist.size == 1  # 一人しか装備できない → 装備交換
          @actor = $game_party.members[@elist[0]]
          @equip = true
          @mes_window.set_callback(M_E_C)
          execute(@actor)
        else # 誰も装備できない → 装備を外す
          @actor = $game_party.members[d.equip_actors[0]]
          @equip = false
          itm = @sl_window.data.obj
          @actor.change_equip(itm.is_a?(RPG::Weapon) ? 0 : (itm.kind+1), 0)
          @mes_window.set_callback(M_E_D)
          execute(@actor)
        end
      else # 所持品がある場合、装備中かどうかは無視
        if @sl_window.data.equippable_members.size == 0
          @equip = false
          execute
        else
          Sound.play_decision
          @mes_window.set_callback(CB_YN)###
          
        end
      end
    elsif Input.trigger?(Input::Y)
      Sound.play_decision
      @info_window.visible = !@info_window.visible
      @info_window.item = @sl_window.item
    end
  end
  #----------------------------------------------------------------------------
  # ● フレーム更新 : @info_window
  #----------------------------------------------------------------------------
  def update_info
    @info_window.item = @list_window.active ? @list_window.item : @sl_window.item
    if Input.trigger?(Input::B)
      Sound.play_cancel
      @info_window.visible = false
    elsif Input.trigger?(Input::C) or Input.trigger?(Input::Y)
      Sound.play_decision
      @info_window.visible = false
    elsif INFO_FLEX
      if @list_window.active
        @list_window.update
      elsif @sl_window.active
        @sl_window.update
      end
    end
  end
  #----------------------------------------------------------------------------
  # ● フレーム更新 : @yn_window
  #----------------------------------------------------------------------------
  def update_yesno
    @yn_window.update
    if Input.trigger?(Input::B)
      Sound.play_cancel
      execute
      @yn_window.disable
    elsif Input.trigger?(Input::C)
      Sound.play_decision
      if @yn_window.index == 0
        @equip = true
        @pt_window.active = true
        @pt_window.index = 0
      else
       execute
     end
      @yn_window.disable
    end
  end
  #----------------------------------------------------------------------------
  # ● フレーム更新 : @pt_window
  #----------------------------------------------------------------------------
  def update_party
    @pt_window.update
    if Input.trigger?(Input::B) and @list_window.data.num > 0
      Sound.play_cancel
      @equip = false
      execute(nil)
      @mes_window.set_text(M_O_I)
    elsif Input.trigger?(Input::C)
      unless @pt_window.enable?
        Sound.play_buzzer
        @mes_window.set_text(M_E_N)
        return
      end
      Sound.play_equip
      execute(@pt_window.actor)
      @mes_window.set_text(M_E_C, @pt_window.actor)
      @mes_window.set_callback(CB_D_PT)
    end
  end
  #----------------------------------------------------------------------------
  # ● 鍛治実行
  #----------------------------------------------------------------------------
  def execute(actor=nil)
    if @list_window.sys_create?
      @list_window.data.execute(@equip, actor)
    else
      @sl_window.data.execute(@equip, actor)
      @sl_window.disable
      @sts_window.mode_reset(@sys_window.sys)
    end
    @equip = false
    @list_window.enable
    @gold_window.refresh
    @list_window.diff_refresh
    @pt_window.refresh
    @sts_window.refresh
  end
end
