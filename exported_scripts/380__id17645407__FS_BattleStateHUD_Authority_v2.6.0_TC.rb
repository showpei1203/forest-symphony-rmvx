#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_BattleStateHUD_Authority v2.6.0 TC
# 【用途】Forest Symphony 戰鬥狀態 HUD 正式 Authority：管理狀態圖示、詳細資訊列、HUD Dirty Cache，以及 Phase 13 收斂後的額外資訊列組裝。
# 【主要機制】Core 仍負責 HUD Sprite／Detail Window／Manager；Phase 13 將 extra_info_rows 收斂為單一 Authority：破勢 0/x 隱藏直接寫回 break_rows，ActorProfile 只提供 clone_stability_rows，MarkedCommand 只提供 role_text，本頁在 Runtime 晚綁定讀取，不再讓兩者 alias extra_info_rows。
# 【主要影響】Game_Battler、Game_Enemy、Game_Actor、Window_BattleStatusIcons、Sprite_AlbertBattleStateHUD、Window_AlbertBattleStateDetail、AlbertBattleStateHUDManager
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ENABLE、VISIBLE_MODE、MAX_ICONS_PER_BATTLER、SHOW_OVERFLOW_COUNT、ICON_SIZE、ICON_SPACING、ICON_OPACITY、DRAW_ICON_BACKGROUND。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】HUD Core 必須先於 ActorProfile、MarkedCommand、BattleTargetUI 載入；Phase 13 起後三者不再需要包裝 extra_info_rows。本頁仍含 Scene_Battle／State Dirty Cache 等既有 alias，其他載入順序依 FS_Runtime_LoadOrder_Guide／Authority Map 維持。
# 【呼叫方式／範例】未在原文件找到可證實的獨立 Script Call 範例；此頁主要由引擎或其他腳本自動呼叫。
# 【相關素材】本頁直接引用：Iconset。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
# -*- coding: utf-8 -*-



#===============================================================================



# ■ FS_BattleStateHUD_Authority v2.6.0 TC



#-------------------------------------------------------------------------------



#  RPG Maker VX / RGSS2 / Ruby 1.8 相容



#  專案：Forest Symphony 森之交響曲
#
#-------------------------------------------------------------------------------
# 【v2.6.0 / Phase 13：extra_info_rows Authority 收斂】
#
#  ・破勢進度 0/x 的整列隱藏直接整合至 break_rows。
#  ・Clone 穩定度仍由 FS_ActorProfile 提供 clone_stability_rows，
#    但由本頁 Runtime 晚綁定呼叫，不再 alias extra_info_rows。
#  ・鳴刻職能仍由 FS_MARKED_COMMAND.role_text 提供，
#    但由本頁 Runtime 晚綁定呼叫，不再 alias extra_info_rows。
#  ・因此 extra_info_rows 從 Core→ActorProfile→Hotfix→MarkedCommand 四層，
#    收斂為本頁單一正式定義。
#



#-------------------------------------------------------------------------------



# 【這版的核心目的】



#



#  v1.2 在「Command Window 開啟」與「選擇敵我目標」時容易明顯 Lag。



#  主要原因不是單純畫圖，而是每一幀都重複做大量高成本工作：



#



#    1. Manager 每幀重新建立 Battler 陣列、Hash、keys.clone。



#    2. 每名 Battler 的 Sprite 每幀至少呼叫 visible_states 兩次。



#    3. visible_states 內每次都重新：



#         - 掃描所有 State



#         - 正則解析 State Note



#         - 排序



#         - 讀取 CSP 疊層



#    4. 選目標／Command Window 時，詳細視窗每幀重新跑：



#         - Help overflow 判定



#         - detail_states



#         - detail_signature



#         - Note 正則解析



#         - State 疊層／回合數掃描



#



#  在「3 人類 + 3 召喚物 + 最多 8 敵人」時，一幀可能對 14 名 Battler



#  重複做數十次狀態掃描。RGSS2 很誠實，它不會抱怨，只會用掉幀數。



#



#-------------------------------------------------------------------------------



# 【v2.0 最佳化】



#



#  1. State Note 解析結果永久快取，不再每幀跑 regex。



#  2. Battler 狀態 HUD 改成 dirty-version 機制：



#       add_state / remove_state / increase_stack / reset_stack 等真正變更時



#       才通知 HUD 重畫。



#  3. 保留低頻 fallback poll，避免特殊腳本直接改 @state_stack 時漏更新。



#  4. Battler 同步不再每幀執行，改為固定間隔。



#  5. 詳細視窗只有在：



#       - 選擇對象真的改變



#       - Battler 資料真的改變



#       - 低頻安全檢查到差異



#     才重新產生內容。



#  6. 每個 Battler 的 visible_states 只在需要刷新時算一次。



#  7. Manager 同一 Graphics.frame_count 最多更新一次。



#     就算舊 v1.2 不小心沒移除，也可減輕 alias 鏈雙重 update。



#



#-------------------------------------------------------------------------------



# 【v2.0 顯示內容】



#



#  除了原本的 State 圖示、疊層、剩餘回合、HUD 詳細文字外，



#  會自動讀取目前最新腳本中「不是 State，但玩家確實需要知道」的資訊：



#



#    ・Mana Shield 剩餘容量



#    ・Boss ATB 動態延遲抗性



#    ・艾薇 Cover 蓄痛值



#    ・泰勒 Break 進度／門檻／抗性／自然回復



#    ・Boss 動態異常抗性（只顯示已累積抗性的 State）



#    ・Robot Protocol 協議倒數與預設技能



#    ・目標優先級（若 > 0）



#



#  這些資訊不占戰場 State Icon 格，只在詳細視窗顯示。



#



#-------------------------------------------------------------------------------



# 【v2.5.1修正】
#
#  ・Detail Y優先讀取Tankentai正式座標base_position_y／position_y。
#  ・不再把找到Sprite_Battler視為動態Y的必要條件。
#  ・Detail以目標Y為中心定位，再限制於安全範圍。
#  ・每幀只比較定位Key，目標或正式Y改變時才重新定位。
#  ・預設使用base_position_y，不隨攻擊動畫上下晃動。
#  ・保留v2.4.1的疊層／回合顏色與Command動態z軸。
#
#-------------------------------------------------------------------------------
#
# 【重要安裝位置】



#



#  最推薦：



#



#    1. 刪除／停用舊 Albert_RMVX_BattleStateHUD_Core_v1_2_TC



#    2. 把本 v2.0 放在：



#



#       ATB_DynamicResistance



#       SummonChain3_v1_0



#       MechanicExpansion_AllInOne



#       Albert_RMVX_BattleStateHUD_Core_v2_0_Optimized_TC   ← 本腳本



#       全腳本導出工具



#       Main



#



#  也就是「所有最新戰鬥機制腳本之下、Main 之上」。



#



#  這樣做有一個額外好處：



#    ATB_DynamicResistance 內舊的 BattleStateHUD 相容區塊，在載入當時找不到



#    Window_AlbertBattleStateDetail，會自動跳過；本 v2.0 直接原生顯示 ATB 抗性，



#    避免舊整合重複改寫 refresh。



#



#-------------------------------------------------------------------------------



# 【State Note】



#



#   <hud_priority:100>        數字越高越優先



#   <hud_hide>                隱藏



#   <hide_battle_hud>         隱藏



#   <hud_show>                強制顯示



#   <show_battle_hud>         強制顯示



#   <hud_icon:123>            戰鬥 HUD 改用指定 Icon



#   <hud_name:劇毒>           詳細視窗改名



#   <hud_detail>              強制進入詳細視窗



#   <hud_detail_text:每層提高毒爆傷害20%>



#   <hud_show_turns>          單靠「剩餘回合」也可成為詳細顯示理由



#



#  繁中同義：



#   <HUD優先:100>



#   <HUD隱藏>



#   <HUD強制顯示>



#   <HUD圖示:123>



#   <HUD名稱:劇毒>



#   <HUD詳細>



#   <HUD詳細文字:每層提高毒爆傷害20%>



#   <HUD顯示回合>



#



#-------------------------------------------------------------------------------



# 【詳細視窗的新規則】



#



#  Help Window 負責「有什麼狀態」。



#  詳細視窗只負責「值得知道的細節」。



#



#  State 符合以下任一條件才進詳細視窗：



#    1. 疊層 > 1



#    2. 有 <hud_detail>



#    3. 有 <hud_detail_text:...>



#    4. Help Window 顯示不下的額外 State



#    5. 有 <hud_show_turns> 且剩餘回合 > 0



#



#  預設「剩餘回合 > 0」本身不再強制產生一列，避免普通 Buff 和上方 Help



#  Window 重複。若 State 已因其他理由進入詳細視窗，仍會順便顯示剩餘回合。



#



#===============================================================================







module AlbertBattleStateHUD



  #--------------------------------------------------------------------------



  # ● 基本開關



  #--------------------------------------------------------------------------



  ENABLE = true



  VISIBLE_MODE = :always



  # :always / :command_only / :target_only







  MAX_ICONS_PER_BATTLER = 4



  SHOW_OVERFLOW_COUNT    = true



  ICON_SIZE              = 20



  ICON_SPACING           = 20



  # 0=完全透明，255=完全不透明。雙方戰場State Icon共用。
  ICON_OPACITY           = 180







  DRAW_ICON_BACKGROUND = true



  BACKGROUND_COLOR      = Color.new(0, 0, 0, 135)



  BORDER_COLOR          = Color.new(255, 255, 255, 45)







  ACTOR_OFFSET_X = -16



  ACTOR_OFFSET_Y = 20



  ENEMY_OFFSET_X = 45



  ENEMY_OFFSET_Y = 20



  Z_OFFSET       = 10

  #--------------------------------------------------------------------------
  # ● Command Window期間的我方狀態Icon圖層
  #--------------------------------------------------------------------------
  COMMAND_LAYER_ENABLED = true

  # Command中目前輸入角色：角色Sprite之上
  COMMAND_ACTIVE_Z_OFFSET = 10

  # Command中其他我方角色／召喚物：角色Sprite之下
  COMMAND_INACTIVE_ACTOR_Z_OFFSET = -1

  # 沒有Command Window時：所有角色Sprite之上
  NON_COMMAND_Z_OFFSET = 10







  HIDDEN_STATE_IDS = []



  HIDE_ZERO_ICON    = true



  STATE_PRIORITY    = {}







  SHOW_STACK_NUMBER  = true

  # 頭頂圖示預設只在2層以上顯示徽章。
  SHOW_STACK_BADGE_AT_ONE = false

  # Detail對可疊層State即使只有1層也顯示層數。
  DETAIL_SHOW_STACK_AT_ONE = true

  # Detail顯示目前層數與最大層數。
  DETAIL_SHOW_STACK_MAX = true



  STACK_FONT_SIZE     = 13



  STACK_TEXT_COLOR    = Color.new(255, 226, 72, 255)



  STACK_OUTLINE_COLOR = Color.new(0, 0, 0, 255)



  STACK_BADGE_COLOR   = Color.new(72, 48, 0, 225)



  STACK_BADGE_BORDER  = Color.new(255, 226, 72, 220)

  #--------------------------------------------------------------------------
  # ● 普通限時State的剩餘回合徽章
  #--------------------------------------------------------------------------
  SHOW_TIMED_STATE_TURNS_ON_ICON = true

  TURN_FONT_SIZE     = 13
  TURN_TEXT_COLOR    = Color.new(96, 232, 255, 255)
  TURN_BADGE_COLOR   = Color.new(0, 42, 72, 230)
  TURN_BADGE_BORDER  = Color.new(96, 232, 255, 220)

  # State 54～61不是CSP多層State，而是單層±20%能力狀態。
  # 強制顯示於Detail，但不改變實際max_stack。
  PARAMETER_STATE_DETAIL = {
    54 => "攻擊+20%",
    55 => "防禦+20%",
    56 => "精神+20%",
    57 => "敏捷+20%",
    58 => "攻擊-20%",
    59 => "防禦-20%",
    60 => "精神-20%",
    61 => "敏捷-20%"
  }







  #--------------------------------------------------------------------------



  # ● 效能設定



  #--------------------------------------------------------------------------



  # 每幾幀檢查隊伍成員是否增減。



  BATTLER_SYNC_INTERVAL = 10







  # 即使 dirty hook 沒抓到特殊腳本，仍每隔幾幀做一次低成本狀態簽章檢查。



  STATE_FALLBACK_POLL_INTERVAL = 30







  # 詳細視窗低頻安全檢查。



  DETAIL_FALLBACK_POLL_INTERVAL = 12







  #--------------------------------------------------------------------------



  # ● 詳細視窗



  #--------------------------------------------------------------------------



  ENABLE_TARGET_DETAIL = true



  DETAIL_MARGIN_X      = 8



  DETAIL_ACTOR_Y       = 56



  DETAIL_ENEMY_Y       = 56

  DETAIL_DYNAMIC_Y     = true

  # false：使用base_position_y，不跟隨攻擊動畫。
  # true ：使用position_y，跟隨移動與跳躍。
  DETAIL_FOLLOW_Y      = false

  DETAIL_CENTER_OFFSET_Y = 0
  DETAIL_TOP_LIMIT       = 82
  DETAIL_BOTTOM_MARGIN   = 8

DETAIL_WIDTH         = 340



  DETAIL_HEIGHT        = 148



  DETAIL_Z             = 500



  DETAIL_MAX_STATES    = 12



  DETAIL_MAX_INFO_ROWS = 6







  DETAIL_BG_COLOR      = Color.new(0, 0, 0, 176)



  DETAIL_BG_BORDER     = Color.new(255, 255, 255, 72)



  DETAIL_CORNER_RADIUS = 10



  DETAIL_TEXT_SIZE     = 16



  DETAIL_LINE_HEIGHT   = 19



  DETAIL_SEPARATOR     = "｜"







  HELP_STATE_ICON_LIMIT_FALLBACK = 8







  # false：一般 State 只因為還有剩餘回合，不會重複出現在詳細視窗。



  # true ：維持舊 v1.2 行為，只要剩餘回合 > 0 就顯示。



  DETAIL_TURNS_ALONE_QUALIFIES = true







  #--------------------------------------------------------------------------



  # ● 非 State 的戰鬥資訊列



  #--------------------------------------------------------------------------



  SHOW_MANA_SHIELD_INFO          = true



  SHOW_ATB_DYNAMIC_RESIST_INFO   = true



  SHOW_IVY_STORED_COVER_INFO     = true



  SHOW_BREAK_INFO                = true



  SHOW_STATE_DYNAMIC_RESIST_INFO = true



  SHOW_ROBOT_PROTOCOL_INFO       = true



  SHOW_TARGET_PRIORITY_INFO      = true







  #--------------------------------------------------------------------------



  # ● 內部快取



  #--------------------------------------------------------------------------



  @state_meta_cache = {}







  def self.clear_cache



    @state_meta_cache = {}



  end







  def self.note(obj)



    return "" if obj == nil



    return "" unless obj.respond_to?(:note)



    return "" if obj.note == nil



    return obj.note.to_s



  end







  def self.state_meta(state)



    return nil if state == nil



    @state_meta_cache = {} if @state_meta_cache == nil



    cached = @state_meta_cache[state.id]



    return cached if cached != nil







    text = note(state)







    force_show = false



    force_show = true if text =~ /<\s*(?:show_battle_hud|hud_show)\s*>/i



    force_show = true if text =~ /<\s*(?:HUD強制顯示|HUD顯示)\s*>/i







    hidden = false



    hidden = true if HIDDEN_STATE_IDS.include?(state.id)



    hidden = true if text =~ /<\s*(?:hide_battle_hud|hud_hide)\s*>/i



    hidden = true if text =~ /<\s*HUD隱藏\s*>/i



    hidden = false if force_show







    priority = nil



    if text =~ /<\s*hud_priority\s*:\s*(-?\d+)\s*>/i



      priority = $1.to_i



    elsif text =~ /<\s*HUD優先\s*:\s*(-?\d+)\s*>/i



      priority = $1.to_i



    elsif STATE_PRIORITY.include?(state.id)



      priority = STATE_PRIORITY[state.id]



    elsif state.respond_to?(:priority)



      priority = state.priority



    else



      priority = 0



    end







    icon = state.respond_to?(:icon_index) ? state.icon_index.to_i : 0



    if text =~ /<\s*hud_icon\s*:\s*(\d+)\s*>/i



      icon = $1.to_i



    elsif text =~ /<\s*HUD圖示\s*:\s*(\d+)\s*>/i



      icon = $1.to_i



    end







    name = state.respond_to?(:name) ? state.name.to_s : ""



    if text =~ /<\s*hud_name\s*:\s*([^>]+)>/i



      name = $1.to_s.strip



    elsif text =~ /<\s*HUD名稱\s*:\s*([^>]+)>/i



      name = $1.to_s.strip



    end







    detail = false



    detail = true if text =~ /<\s*hud_detail\s*>/i



    detail = true if text =~ /<\s*HUD詳細\s*>/i







    detail_text = ""



    if text =~ /<\s*hud_detail_text\s*:\s*([^>]+)>/i



      detail_text = $1.to_s.strip



    elsif text =~ /<\s*HUD詳細文字\s*:\s*([^>]+)>/i



      detail_text = $1.to_s.strip



    end







    show_turns = false



    show_turns = true if text =~ /<\s*hud_show_turns\s*>/i



    show_turns = true if text =~ /<\s*HUD顯示回合\s*>/i







    hidden = true if HIDE_ZERO_ICON && icon <= 0 && !force_show







    meta = {



      :force_show  => force_show,



      :hidden      => hidden,



      :priority    => priority.to_i,



      :icon        => icon.to_i,



      :name        => name,



      :detail      => detail,



      :detail_text => detail_text,



      :show_turns  => show_turns



    }



    @state_meta_cache[state.id] = meta



    return meta



  end







  #--------------------------------------------------------------------------



  # ● 保留舊 API，給其他補丁呼叫



  #--------------------------------------------------------------------------



  def self.force_show?(state)



    meta = state_meta(state)



    return meta != nil && meta[:force_show]



  end







  def self.hidden?(state)



    meta = state_meta(state)



    return true if meta == nil



    return meta[:hidden]



  end







  def self.hud_priority(state)



    meta = state_meta(state)



    return -999999 if meta == nil



    return meta[:priority]



  end







  def self.hud_icon(state)



    meta = state_meta(state)



    return 0 if meta == nil



    return meta[:icon]



  end







  def self.hud_name(state)



    meta = state_meta(state)



    return "" if meta == nil



    return meta[:name]



  end







  def self.hud_detail?(state)



    meta = state_meta(state)



    return false if meta == nil



    return meta[:detail]



  end







  def self.hud_detail_text(state)



    meta = state_meta(state)



    return "" if meta == nil



    return meta[:detail_text]



  end







  def self.hud_show_turns?(state)



    meta = state_meta(state)



    return false if meta == nil



    return meta[:show_turns]



  end







  #--------------------------------------------------------------------------



  # ● CSP 疊層



  #--------------------------------------------------------------------------



  def self.state_max_stack(state)

    return 1 if state == nil

    # AutoSetup會在載入標題時覆寫Note。
    # 直接解析最新Note，不能先相信YEZ CSP可能過期的@max_stack。
    text = state.respond_to?(:note) ? state.note.to_s : ""

    if text =~ /<\s*(?:MAX_STACK|max stack)\s*(\d+)\s*>/i

      note_value = [$1.to_i, 1].max

      # 同步CSP實際上限。真正的完整重建由StateStackSlipBridge v2.9處理。
      begin
        cached = state.instance_variable_get(:@max_stack)
        if cached == nil || cached.to_i != note_value
          state.instance_variable_set(:@max_stack, note_value)
        end
      rescue
      end

      return note_value
    end

    if state.respond_to?(:max_stack)

      begin

        value = state.max_stack.to_i

        return [value, 1].max

      rescue

      end

    end

    return 1

  end



  def self.state_stack(battler, state)

    return 0 if battler == nil || state == nil

    # 先觸發最新Note的max_stack同步，避免CSP仍使用舊快取。
    begin
      state_max_stack(state)
    rescue
    end

    state_id = state.respond_to?(:id) ? state.id.to_i : state.to_i

    return 0 if state_id <= 0

    if battler.respond_to?(:state?)

      begin

        return 0 unless battler.state?(state_id)

      rescue

      end

    end

    values = []

    if battler.respond_to?(:stack)

      begin

        values.push(battler.stack(state).to_i)

      rescue

      end

      begin

        values.push(battler.stack(state_id).to_i)

      rescue

      end

    end

    if battler.respond_to?(:albert_mx_state_stack_count)

      begin

        values.push(battler.albert_mx_state_stack_count(state_id).to_i)

      rescue

      end

    end

    begin

      table = battler.instance_variable_get(:@state_stack)

      if table.is_a?(Hash) && table.include?(state_id)

        values.push(table[state_id].to_i)

      end

    rescue

    end

    value = values.empty? ? 1 : values.max

    return [value.to_i, 1].max

  end



  def self.parameter_state?(state)

    return false if state == nil

    return PARAMETER_STATE_DETAIL.include?(state.id.to_i)

  end







  def self.parameter_state_detail(state)

    return "" unless parameter_state?(state)

    return PARAMETER_STATE_DETAIL[state.id.to_i].to_s

  end







  def self.state_turns_left(battler, state)

    return 0 if battler == nil || state == nil

    state_id = state.respond_to?(:id) ? state.id.to_i : state.to_i

    return 0 if state_id <= 0

    begin

      if battler.respond_to?(:state_turns)

        table = battler.state_turns

        if table.is_a?(Hash) || table.is_a?(Array)

          value = table[state_id]

          return [value.to_i, 0].max unless value == nil

        end

      end

    rescue

    end

    begin

      table = battler.instance_variable_get(:@state_turns)

      if table.is_a?(Hash) || table.is_a?(Array)

        value = table[state_id]

        return [value.to_i, 0].max unless value == nil

      end

    rescue

    end

    return 0

  end



  def self.visible_states(battler)



    result = []



    return result if battler == nil







    battler.states.each do |state|



      next if state == nil



      next if hidden?(state)



      result << state



    end







    result.sort! do |a, b|



      pa = hud_priority(a)



      pb = hud_priority(b)



      if pa == pb



        a.id <=> b.id



      else



        pb <=> pa



      end



    end



    return result



  end







  def self.help_state_icon_limit



    if defined?(N01) && N01.const_defined?(:NB_ICONES)



      return [N01::NB_ICONES.to_i, 1].max



    end



    return HELP_STATE_ICON_LIMIT_FALLBACK



  end







  def self.help_overflow_state_ids(battler)



    return [] if battler == nil



    shown = []



    battler.states.each do |state|



      next if state == nil



      if state.respond_to?(:extension)



        begin



          next if state.extension.include?("HIDEICON")



        rescue



        end



      end



      shown << state.id



    end



    limit = help_state_icon_limit



    return [] if shown.size <= limit



    return shown[limit, shown.size - limit] || []



  end







  def self.detail_states(battler)



    result = []



    return result if battler == nil







    overflow_ids = help_overflow_state_ids(battler)



    visible_states(battler).each do |state|



      stack  = state_stack(battler, state)



      turns  = state_turns_left(battler, state)



      custom = hud_detail_text(state)







      qualifies = false

      max_stack = state_max_stack(state)

      qualifies = true if stack > 1

      qualifies = true if max_stack > 1

      qualifies = true if parameter_state?(state)

      qualifies = true if hud_detail?(state)



      qualifies = true unless custom == ""



      qualifies = true if overflow_ids.include?(state.id)



      qualifies = true if turns > 0 && (



        DETAIL_TURNS_ALONE_QUALIFIES || hud_show_turns?(state)



      )







      result << state if qualifies



    end



    return result



  end







  def self.detail_text(battler, state)



    return "" if battler == nil || state == nil



    parts = []



    name   = hud_name(state)



    stack  = state_stack(battler, state)



    turns  = state_turns_left(battler, state)



    custom = hud_detail_text(state)







    max_stack = state_max_stack(state)

    base = name

    parts << base unless base == ""

    parameter_text = parameter_state_detail(state)

    parts << parameter_text unless parameter_text == ""

    show_stack = stack > 1

    if DETAIL_SHOW_STACK_AT_ONE && max_stack > 1

      show_stack = true

    end

    if show_stack

      if DETAIL_SHOW_STACK_MAX && max_stack > 1

        parts << "層數#{stack}/#{max_stack}"

      else

        parts << "層數#{stack}"

      end

    end

    parts << "剩#{turns}回合" if turns > 0

    parts << custom unless custom == ""

    return parts.join(DETAIL_SEPARATOR)



  end







  #--------------------------------------------------------------------------



  # ● 快速狀態簽章，不做 Note regex / sort



  #--------------------------------------------------------------------------



  def self.quick_state_signature(battler)



    return "" if battler == nil



    values = []



    battler.states.each do |state|



      next if state == nil



      values << state.id



      values << state_stack(battler, state)



      values << state_turns_left(battler, state)



    end



    return values.join(":")



  end







  #--------------------------------------------------------------------------



  # ● HUD 可見性



  #--------------------------------------------------------------------------



  def self.hud_visible?(scene)



    return false unless ENABLE



    return false if scene == nil



    case VISIBLE_MODE



    when :command_only



      win = scene.instance_variable_get(:@actor_command_window)



      return win != nil && win.active



    when :target_only



      return defined?($in_target) && $in_target



    else



      return true



    end



  end







  #--------------------------------------------------------------------------



  # ● 取得資料庫 Note



  #--------------------------------------------------------------------------



  def self.battler_note(battler)



    return "" if battler == nil



    if battler.is_a?(Game_Enemy)



      return note(battler.enemy)



    elsif battler.is_a?(Game_Actor)



      return note(battler.actor)



    end



    return ""



  end







  def self.note_number(text, key, default_value = nil)



    if text =~ /<\s*#{key}\s*:\s*(-?\d+(?:\.\d+)?)\s*>/i



      return $1.to_f



    end



    return default_value



  end







  #--------------------------------------------------------------------------



  # ● 詳細資訊：Mana Shield



  #--------------------------------------------------------------------------



  def self.mana_shield_rows(battler)



    rows = []



    return rows unless SHOW_MANA_SHIELD_INFO



    return rows if battler == nil



    return rows unless battler.respond_to?(:albert_mana_shield_remaining)







    battler.states.each do |state|



      next if state == nil



      next unless state.respond_to?(:albert_mana_shield_data)



      data = state.albert_mana_shield_data



      next if data == nil



      begin



        remain = battler.albert_mana_shield_remaining(state.id).to_i



        next if remain <= 0



        name = hud_name(state)



        label = name == "" ? "Mana Shield" : name



        rows << [label, "剩餘#{remain}"]



      rescue



      end



    end



    return rows



  end







  #--------------------------------------------------------------------------



  # ● 詳細資訊：ATB 動態抗性



  #--------------------------------------------------------------------------



  def self.atb_resist_rows(battler)



    rows = []



    return rows unless SHOW_ATB_DYNAMIC_RESIST_INFO



    return rows if battler == nil



    return rows unless battler.respond_to?(:albert_atb_dynamic_resist?)



    return rows unless battler.albert_atb_dynamic_resist?







    begin



      level = battler.albert_atb_resist_level



      max   = battler.albert_atb_resist_max



      rate  = battler.albert_atb_resist_rate



      floor = battler.albert_atb_resist_floor_percent



      rows << ["ATB延遲抗性", "Lv#{level}/#{max}　承受#{rate}%　下限#{floor}%"]



    rescue



    end



    return rows



  end







  #--------------------------------------------------------------------------



  # ● 詳細資訊：艾薇 Cover 蓄痛



  #--------------------------------------------------------------------------



  def self.cover_store_rows(battler)



    rows = []



    return rows unless SHOW_IVY_STORED_COVER_INFO



    return rows if battler == nil



    return rows unless battler.respond_to?(:albert_mx_stored_cover_damage)



    return rows unless battler.respond_to?(:albert_cc_ivy?) && battler.albert_cc_ivy?







    begin



      value = battler.albert_mx_stored_cover_damage.to_i



      cap_text = ""



      if battler.respond_to?(:albert_mx_cover_store_cap_percent)



        cap = (battler.maxhp.to_f * battler.albert_mx_cover_store_cap_percent / 100.0).to_i



        cap_text = " / #{cap}" if cap > 0



      end



      rows << ["蓄痛", "#{value}#{cap_text}"]



    rescue



    end



    return rows



  end







  #--------------------------------------------------------------------------



  # ● 詳細資訊：Break



  #--------------------------------------------------------------------------



  def self.break_rows(battler)



    rows = []



    return rows unless SHOW_BREAK_INFO



    return rows unless battler.is_a?(Game_Enemy)







    text = battler_note(battler)



    progress_id = 0



    if defined?(ALBERT_CHARACTER_CORE) &&



       ALBERT_CHARACTER_CORE.const_defined?(:BREAK_PROGRESS_STATE_ID)



      progress_id = ALBERT_CHARACTER_CORE::BREAK_PROGRESS_STATE_ID.to_i



    end







    current = 0



    if progress_id > 0 && battler.state?(progress_id)



      current = state_stack(battler, $data_states[progress_id])



    end







    threshold = note_number(text, "break_threshold", nil)



    resist    = note_number(text, "break_resist", nil)



    immune    = (text =~ /<\s*break_immune\s*>/i) ? true : false



    recover   = battler.respond_to?(:albert_mx_break_recover_amount) ?



                battler.albert_mx_break_recover_amount.to_i : 0







    return rows if current <= 0 && threshold == nil && resist == nil && !immune && recover <= 0

    # Phase 13：整合原 BreakZeroHide Hotfix。
    # 舊 Hotfix 會在資訊列含「破勢」且出現「進度0/x」時刪除整列；
    # break_rows 只有 threshold 存在時才會產生 0/x，因此在來源端直接返回即可。
    return rows if current <= 0 && threshold != nil

    parts = []



    if threshold != nil



      parts << "進度#{current}/#{threshold.to_i}"



    elsif current > 0



      parts << "進度#{current}"



    end







    if immune



      parts << "免疫"



    elsif resist != nil



      parts << "抗性#{resist.to_i}%"



    end



    parts << "行動後-#{recover}" if recover > 0







    rows << ["破勢", parts.join("　")]



    return rows



  end







  #--------------------------------------------------------------------------



  # ● 詳細資訊：Boss 動態異常抗性



  #--------------------------------------------------------------------------



  def self.dynamic_state_resist_rows(battler)



    rows = []



    return rows unless SHOW_STATE_DYNAMIC_RESIST_INFO



    return rows unless battler.is_a?(Game_Enemy)



    return rows unless battler.respond_to?(:albert_mx_state_dynamic_resist?)



    return rows unless battler.albert_mx_state_dynamic_resist?







    table = battler.instance_variable_get(:@albert_mx_state_resist_levels)



    return rows unless table.is_a?(Hash)







    parts = []



    table.keys.sort.each do |state_id|



      level = table[state_id].to_i



      next if level <= 0



      state = $data_states[state_id]



      next if state == nil



      begin



        rate = battler.albert_mx_state_resist_rate(state_id).to_i



        parts << "#{state.name}#{rate}%"



      rescue



      end



    end







    rows << ["異常抗性", parts.join("　")] unless parts.empty?



    return rows



  end







  #--------------------------------------------------------------------------



  # ● 詳細資訊：Robot Protocol



  #--------------------------------------------------------------------------



  def self.robot_protocol_rows(battler)



    rows = []



    return rows unless SHOW_ROBOT_PROTOCOL_INFO



    return rows unless battler.is_a?(Game_Actor)



    return rows unless battler.respond_to?(:albert_robot?) && battler.albert_robot?



    return rows unless battler.respond_to?(:albert_mx_robot_protocol_data)







    begin



      data = battler.albert_mx_robot_protocol_data



      return rows if data == nil



      default_skill_id = data[0].to_i



      interval         = [data[1].to_i, 1].max



      conditionals     = data[2] || []



      count = battler.instance_variable_get(:@albert_mx_robot_protocol_count).to_i



      mod = count % interval



      remain = mod == 0 ? interval : interval - mod







      parts = ["#{remain}次行動後"]



      if default_skill_id > 0 && $data_skills[default_skill_id] != nil



        parts << $data_skills[default_skill_id].name



      end



      parts << "條件#{conditionals.size}組" if conditionals.size > 0



      rows << ["協議", parts.join("　")]



    rescue



    end



    return rows



  end







  #--------------------------------------------------------------------------



  # ● 詳細資訊：目標優先級



  #--------------------------------------------------------------------------



  def self.target_priority_rows(battler)



    rows = []



    return rows unless SHOW_TARGET_PRIORITY_INFO



    return rows unless battler.respond_to?(:albert_target_priority)



    begin



      value = battler.albert_target_priority.to_i



      rows << ["目標優先", value.to_s] if value > 0



    rescue



    end



    return rows



  end







  #--------------------------------------------------------------------------



  # ● 所有額外資訊列



  #--------------------------------------------------------------------------



  def self.extra_info_rows(battler)

    rows = []

    rows.concat(mana_shield_rows(battler))
    rows.concat(atb_resist_rows(battler))
    rows.concat(cover_store_rows(battler))
    rows.concat(break_rows(battler))
    rows.concat(dynamic_state_resist_rows(battler))
    rows.concat(robot_protocol_rows(battler))
    rows.concat(target_priority_rows(battler))

    # Phase 13：ActorProfile 改為資料提供者，不再包裝 extra_info_rows。
    # ActorProfile 雖後載入，但實際戰鬥開始時方法已建立，可安全晚綁定。
    if respond_to?(:clone_stability_rows)
      clone_rows = clone_stability_rows(battler)
      rows.concat(clone_rows) if clone_rows.is_a?(Array)
    end

    # Phase 13：MarkedCommand 改為資料提供者，不再包裝 extra_info_rows。
    if defined?(FS_MARKED_COMMAND) && FS_MARKED_COMMAND.respond_to?(:role_text)
      text = FS_MARKED_COMMAND.role_text(battler)
      unless text.to_s.empty?
        exists = false
        for row in rows
          if row != nil && row[0].to_s == "職能"
            exists = true
            break
          end
        end
        rows.push(["職能", text]) unless exists
      end
    end

    return rows

  end



end







#===============================================================================



# ■ Game_Battler：HUD Dirty Version



#===============================================================================



class Game_Battler



  def albert_bshud_dirty_version



    @albert_bshud_dirty_version = 0 if @albert_bshud_dirty_version == nil



    return @albert_bshud_dirty_version



  end







  def albert_bshud_touch!



    @albert_bshud_dirty_version = albert_bshud_dirty_version + 1



  end







  unless method_defined?(:albert_bshud_v2_old_add_state)



    alias albert_bshud_v2_old_add_state add_state



  end



  def add_state(*args)



    result = albert_bshud_v2_old_add_state(*args)



    albert_bshud_touch!



    return result



  end







  unless method_defined?(:albert_bshud_v2_old_remove_state)



    alias albert_bshud_v2_old_remove_state remove_state



  end



  def remove_state(*args)



    result = albert_bshud_v2_old_remove_state(*args)



    albert_bshud_touch!



    return result



  end







  if method_defined?(:increase_stack) &&



     !method_defined?(:albert_bshud_v2_old_increase_stack)



    alias albert_bshud_v2_old_increase_stack increase_stack



    def increase_stack(*args)



      result = albert_bshud_v2_old_increase_stack(*args)



      albert_bshud_touch!



      return result



    end



  end







  if method_defined?(:reset_stack) &&



     !method_defined?(:albert_bshud_v2_old_reset_stack)



    alias albert_bshud_v2_old_reset_stack reset_stack



    def reset_stack(*args)



      result = albert_bshud_v2_old_reset_stack(*args)



      albert_bshud_touch!



      return result



    end



  end







  if method_defined?(:remove_states_auto) &&



     !method_defined?(:albert_bshud_v2_old_remove_states_auto)



    alias albert_bshud_v2_old_remove_states_auto remove_states_auto



    def remove_states_auto(*args)



      result = albert_bshud_v2_old_remove_states_auto(*args)



      albert_bshud_touch!



      return result



    end



  end







  if method_defined?(:albert_mx_reduce_state_stack) &&



     !method_defined?(:albert_bshud_v2_old_mx_reduce_state_stack)



    alias albert_bshud_v2_old_mx_reduce_state_stack albert_mx_reduce_state_stack



    def albert_mx_reduce_state_stack(*args)



      result = albert_bshud_v2_old_mx_reduce_state_stack(*args)



      albert_bshud_touch! if result.to_i != 0



      return result



    end



  end







  if method_defined?(:albert_mx_add_stored_cover_damage) &&



     !method_defined?(:albert_bshud_v2_old_add_stored_cover_damage)



    alias albert_bshud_v2_old_add_stored_cover_damage albert_mx_add_stored_cover_damage



    def albert_mx_add_stored_cover_damage(*args)



      result = albert_bshud_v2_old_add_stored_cover_damage(*args)



      albert_bshud_touch! if result.to_i != 0



      return result



    end



  end







  if method_defined?(:albert_mx_clear_stored_cover_damage) &&



     !method_defined?(:albert_bshud_v2_old_clear_stored_cover_damage)



    alias albert_bshud_v2_old_clear_stored_cover_damage albert_mx_clear_stored_cover_damage



    def albert_mx_clear_stored_cover_damage(*args)



      result = albert_bshud_v2_old_clear_stored_cover_damage(*args)



      albert_bshud_touch!



      return result



    end



  end



end







#===============================================================================



# ■ Game_Enemy：非 State 資訊變更時通知 HUD



#===============================================================================



class Game_Enemy < Game_Battler



  if method_defined?(:albert_atb_resist_add) &&



     !method_defined?(:albert_bshud_v2_old_atb_resist_add)



    alias albert_bshud_v2_old_atb_resist_add albert_atb_resist_add



    def albert_atb_resist_add(*args)



      result = albert_bshud_v2_old_atb_resist_add(*args)



      albert_bshud_touch!



      return result



    end



  end







  if method_defined?(:albert_atb_resist_recover_after_action) &&



     !method_defined?(:albert_bshud_v2_old_atb_resist_recover)



    alias albert_bshud_v2_old_atb_resist_recover albert_atb_resist_recover_after_action



    def albert_atb_resist_recover_after_action(*args)



      result = albert_bshud_v2_old_atb_resist_recover(*args)



      albert_bshud_touch!



      return result



    end



  end







  if method_defined?(:albert_mx_add_state_resist_level) &&



     !method_defined?(:albert_bshud_v2_old_add_state_resist_level)



    alias albert_bshud_v2_old_add_state_resist_level albert_mx_add_state_resist_level



    def albert_mx_add_state_resist_level(*args)



      result = albert_bshud_v2_old_add_state_resist_level(*args)



      albert_bshud_touch! if result.to_i != 0



      return result



    end



  end







  if method_defined?(:albert_mx_recover_state_resist_after_action) &&



     !method_defined?(:albert_bshud_v2_old_recover_state_resist)



    alias albert_bshud_v2_old_recover_state_resist albert_mx_recover_state_resist_after_action



    def albert_mx_recover_state_resist_after_action(*args)



      result = albert_bshud_v2_old_recover_state_resist(*args)



      albert_bshud_touch! if result.to_i != 0



      return result



    end



  end







  if method_defined?(:albert_mx_recover_break_after_action) &&



     !method_defined?(:albert_bshud_v2_old_recover_break)



    alias albert_bshud_v2_old_recover_break albert_mx_recover_break_after_action



    def albert_mx_recover_break_after_action(*args)



      result = albert_bshud_v2_old_recover_break(*args)



      albert_bshud_touch! if result.to_i != 0



      return result



    end



  end



end







#===============================================================================



# ■ Game_Actor：Robot Protocol 倒數變更時通知 HUD



#===============================================================================



class Game_Actor < Game_Battler



  if method_defined?(:albert_mx_try_robot_protocol) &&



     !method_defined?(:albert_bshud_v2_old_try_robot_protocol)



    alias albert_bshud_v2_old_try_robot_protocol albert_mx_try_robot_protocol



    def albert_mx_try_robot_protocol(*args)



      before = instance_variable_get(:@albert_mx_robot_protocol_count).to_i



      result = albert_bshud_v2_old_try_robot_protocol(*args)



      after = instance_variable_get(:@albert_mx_robot_protocol_count).to_i



      albert_bshud_touch! if before != after



      return result



    end



  end



end







#===============================================================================



# ■ 舊 Window_BattleStatusIcons 改成低成本透明空殼



#===============================================================================



class Window_BattleStatusIcons < Window_Base



  def initialize



    super(0, 0, 64, 64)



    self.opacity = 0



    self.contents_opacity = 0



    self.visible = false



  end







  def refresh



    # 故意留空。舊 Scene_Battle 仍可安全呼叫，但不再重畫全畫面 Bitmap。



  end







  def draw_status_icons



    # 故意留空。



  end



end







#===============================================================================



# ■ Sprite_AlbertBattleStateHUD



#===============================================================================



class Sprite_AlbertBattleStateHUD < Sprite



  attr_reader :battler
  attr_accessor :battler_sprite
  attr_accessor :command_active
  attr_accessor :commander







  def initialize(viewport, battler, battler_sprite = nil)



    super(viewport)



    @battler = battler
    @battler_sprite = battler_sprite
    @command_active = false
    @commander = nil



    @slot_count = [AlbertBattleStateHUD::MAX_ICONS_PER_BATTLER, 1].max



    @bitmap_width = @slot_count * AlbertBattleStateHUD::ICON_SPACING



    @bitmap_height = AlbertBattleStateHUD::ICON_SIZE



    self.bitmap = Bitmap.new(@bitmap_width, @bitmap_height)



    self.opacity = AlbertBattleStateHUD::ICON_OPACITY







    @cached_states = []



    @has_visible_states = false



    @last_dirty_version = -1



    @last_quick_signature = nil



    @poll_offset = battler.object_id % [AlbertBattleStateHUD::STATE_FALLBACK_POLL_INTERVAL, 1].max







    refresh_state_cache



    update_position



    update_visibility



  end







  def dispose



    if self.bitmap != nil && !self.bitmap.disposed?



      self.bitmap.dispose



    end



    super



  end







  def update



    super



    return if @battler == nil







    update_position







    dirty = @battler.respond_to?(:albert_bshud_dirty_version) ?



            @battler.albert_bshud_dirty_version : 0







    if dirty != @last_dirty_version



      refresh_state_cache



    else



      interval = [AlbertBattleStateHUD::STATE_FALLBACK_POLL_INTERVAL, 1].max



      if Graphics.frame_count % interval == @poll_offset



        signature = AlbertBattleStateHUD.quick_state_signature(@battler)



        if signature != @last_quick_signature



          refresh_state_cache



        end



      end



    end







    update_visibility



  end







  def update_visibility



    should_show = false



    if @battler != nil && @battler.exist? && @has_visible_states



      should_show = AlbertBattleStateHUD.hud_visible?($scene)



    end



    self.visible = should_show if self.visible != should_show



  end







  def refresh_state_cache



    @cached_states = AlbertBattleStateHUD.visible_states(@battler)



    @has_visible_states = !@cached_states.empty?



    @last_dirty_version = @battler.respond_to?(:albert_bshud_dirty_version) ?



                          @battler.albert_bshud_dirty_version : 0



    @last_quick_signature = AlbertBattleStateHUD.quick_state_signature(@battler)



    redraw



  end







  def update_position



    bx = battler_x



    by = battler_y







    if @battler.is_a?(Game_Enemy)



      self.x = bx + AlbertBattleStateHUD::ENEMY_OFFSET_X



      self.y = by + AlbertBattleStateHUD::ENEMY_OFFSET_Y



      self.ox = @bitmap_width



      self.oy = @bitmap_height



    else



      self.x = bx + AlbertBattleStateHUD::ACTOR_OFFSET_X



      self.y = by + AlbertBattleStateHUD::ACTOR_OFFSET_Y



      self.ox = 0



      self.oy = @bitmap_height



    end







    update_layer_z(by)



  end



  #--------------------------------------------------------------------------
  # ● 依真正Sprite_Battler調整圖層
  #--------------------------------------------------------------------------
  def update_layer_z(fallback_y)
    base_z = nil

    if fs_bshud_valid_battler_sprite?
      base_z = @battler_sprite.z
      if self.viewport != @battler_sprite.viewport
        self.viewport = @battler_sprite.viewport
      end
    elsif @battler.respond_to?(:position_z)
      base_z = @battler.position_z
    else
      base_z = fallback_y
    end

    # 非Command期間，雙方全部位於角色圖上方。
    offset = AlbertBattleStateHUD::NON_COMMAND_Z_OFFSET

    if AlbertBattleStateHUD::COMMAND_LAYER_ENABLED &&
       @command_active

      # Command期間只調整我方。敵方仍維持上層。
      if @battler != nil && @battler.actor?
        if @commander != nil && @battler.equal?(@commander)
          offset = AlbertBattleStateHUD::COMMAND_ACTIVE_Z_OFFSET
        else
          offset =
            AlbertBattleStateHUD::COMMAND_INACTIVE_ACTOR_Z_OFFSET
        end
      else
        offset = AlbertBattleStateHUD::COMMAND_ACTIVE_Z_OFFSET
      end
    end

    self.z = base_z + offset
  end



  def fs_bshud_valid_battler_sprite?
    return false if @battler_sprite == nil
    return false if @battler_sprite.disposed?
    return false unless @battler_sprite.respond_to?(:battler)
    return false unless @battler_sprite.battler.equal?(@battler)
    return true
  rescue
    return false
  end








  def battler_x



    return @battler.position_x if @battler.respond_to?(:position_x)



    return @battler.screen_x if @battler.respond_to?(:screen_x)



    return 0



  end







  def battler_y



    return @battler.position_y if @battler.respond_to?(:position_y)



    return @battler.screen_y if @battler.respond_to?(:screen_y)



    return 0



  end







  def redraw



    self.bitmap.clear



    states = @cached_states



    return if states == nil || states.empty?







    max_slots = AlbertBattleStateHUD::MAX_ICONS_PER_BATTLER



    overflow = [states.size - max_slots + 1, 0].max







    draw_states = []



    if AlbertBattleStateHUD::SHOW_OVERFLOW_COUNT && states.size > max_slots



      count = [max_slots - 1, 0].max



      for i in 0...count



        draw_states << states[i]



      end



    else



      count = [states.size, max_slots].min



      for i in 0...count



        draw_states << states[i]



      end



    end







    draw_states.each_with_index do |state, index|



      draw_state_slot(state, index)



    end







    if AlbertBattleStateHUD::SHOW_OVERFLOW_COUNT && states.size > max_slots



      draw_overflow_slot(max_slots - 1, overflow)



    end



  end







  def draw_state_slot(state, index)



    x = index * AlbertBattleStateHUD::ICON_SPACING



    y = 0



    size = AlbertBattleStateHUD::ICON_SIZE



    draw_slot_background(x, y, size)



    draw_scaled_icon(AlbertBattleStateHUD.hud_icon(state), x, y, size)







    stack = AlbertBattleStateHUD.state_stack(@battler, state)

    max_stack = AlbertBattleStateHUD.state_max_stack(state)

    turns = AlbertBattleStateHUD.state_turns_left(
      @battler, state)



    show_stack_badge = stack > 1

    if AlbertBattleStateHUD::SHOW_STACK_BADGE_AT_ONE &&
       max_stack > 1

      show_stack_badge = stack > 0

    end

    if AlbertBattleStateHUD::SHOW_STACK_NUMBER &&
       max_stack > 1 &&
       show_stack_badge

      draw_state_badge(
        x, y, size, stack, :stack)

    elsif AlbertBattleStateHUD::SHOW_TIMED_STATE_TURNS_ON_ICON &&
          max_stack <= 1 &&
          turns > 0 &&
          state.respond_to?(:auto_release_prob) &&
          state.auto_release_prob.to_i > 0

      draw_state_badge(
        x, y, size, turns, :turn)

    end



  end







  def draw_slot_background(x, y, size)



    return unless AlbertBattleStateHUD::DRAW_ICON_BACKGROUND



    self.bitmap.fill_rect(x, y, size, size, AlbertBattleStateHUD::BORDER_COLOR)



    self.bitmap.fill_rect(x + 1, y + 1, size - 2, size - 2,



      AlbertBattleStateHUD::BACKGROUND_COLOR)



  end







  def draw_scaled_icon(icon_index, x, y, size)



    return if icon_index == nil || icon_index <= 0



    iconset = Cache.system("Iconset")



    sx = icon_index % 16 * 24



    sy = icon_index / 16 * 24



    src = Rect.new(sx, sy, 24, 24)



    dst = Rect.new(x, y, size, size)



    self.bitmap.stretch_blt(dst, iconset, src, 255)



  end







  def draw_state_badge(x, y, size, value, kind = :stack)



    text = value.to_i.to_s



    old_size   = self.bitmap.font.size



    old_bold   = self.bitmap.font.bold



    old_shadow = self.bitmap.font.shadow



    old_color  = self.bitmap.font.color







    font_size = if kind == :turn
                  AlbertBattleStateHUD::TURN_FONT_SIZE
                else
                  AlbertBattleStateHUD::STACK_FONT_SIZE
                end

    text_color = if kind == :turn
                   AlbertBattleStateHUD::TURN_TEXT_COLOR
                 else
                   AlbertBattleStateHUD::STACK_TEXT_COLOR
                 end

    badge_color = if kind == :turn
                    AlbertBattleStateHUD::TURN_BADGE_COLOR
                  else
                    AlbertBattleStateHUD::STACK_BADGE_COLOR
                  end

    badge_border = if kind == :turn
                     AlbertBattleStateHUD::TURN_BADGE_BORDER
                   else
                     AlbertBattleStateHUD::STACK_BADGE_BORDER
                   end



    self.bitmap.font.size = font_size



    self.bitmap.font.bold = true



    self.bitmap.font.shadow = false







    text_w = self.bitmap.text_size(text).width



    min_badge_width = kind == :turn ? 13 : 12

    badge_w = [text_w + 6, min_badge_width].max



    badge_h = kind == :turn ? 13 : 12



    bx = x + size - badge_w - 1



    by = y + size - badge_h - 1







    if self.bitmap.respond_to?(:fill_rounded_rect)



      self.bitmap.fill_rounded_rect(



        Rect.new(bx - 1, by - 1, badge_w + 2, badge_h + 2),



        badge_border, 4)



      self.bitmap.fill_rounded_rect(



        Rect.new(bx, by, badge_w, badge_h),



        badge_color, 4)



    else



      self.bitmap.fill_rect(bx - 1, by - 1, badge_w + 2, badge_h + 2,



        badge_border)



      self.bitmap.fill_rect(bx, by, badge_w, badge_h,



        badge_color)



    end







    tx = bx - 1



    ty = by - 1



    tw = badge_w + 1



    th = badge_h + 1







    self.bitmap.font.color = AlbertBattleStateHUD::STACK_OUTLINE_COLOR



    self.bitmap.draw_text(tx - 1, ty, tw, th, text, 2)



    self.bitmap.draw_text(tx + 1, ty, tw, th, text, 2)



    self.bitmap.draw_text(tx, ty - 1, tw, th, text, 2)



    self.bitmap.draw_text(tx, ty + 1, tw, th, text, 2)



    self.bitmap.font.color = text_color



    self.bitmap.draw_text(tx, ty, tw, th, text, 2)







    self.bitmap.font.size = old_size



    self.bitmap.font.bold = old_bold



    self.bitmap.font.shadow = old_shadow



    self.bitmap.font.color = old_color



  end







  def draw_overflow_slot(index, overflow)



    return if index < 0



    x = index * AlbertBattleStateHUD::ICON_SPACING



    y = 0



    size = AlbertBattleStateHUD::ICON_SIZE



    draw_slot_background(x, y, size)







    old_size = self.bitmap.font.size



    old_bold = self.bitmap.font.bold



    old_color = self.bitmap.font.color



    self.bitmap.font.size = 12



    self.bitmap.font.bold = true



    self.bitmap.font.color = Color.new(255, 255, 255, 255)



    self.bitmap.draw_text(x, y, size, size, "+#{overflow}", 1)



    self.bitmap.font.size = old_size



    self.bitmap.font.bold = old_bold



    self.bitmap.font.color = old_color



  end



end







#===============================================================================



# ■ Window_AlbertBattleStateDetail



#===============================================================================



class Window_AlbertBattleStateDetail < Window_Base



  attr_reader :battler
  attr_reader :battler_sprite

def initialize



    super(0, 0,



      AlbertBattleStateHUD::DETAIL_WIDTH,



      AlbertBattleStateHUD::DETAIL_HEIGHT)



    self.z = AlbertBattleStateHUD::DETAIL_Z



    self.opacity = 0



    self.back_opacity = 0



    self.visible = false







    @battler = nil
    @battler_sprite = nil

@target_side = :left



    @last_dirty_version = -1



    @last_payload_signature = nil



    @last_poll_frame = -999999

    @last_detail_placement_key = nil







    create_background_sprite



    update_placement



  end







  def dispose



    if @background_sprite != nil && !@background_sprite.disposed?



      if @background_sprite.bitmap != nil && !@background_sprite.bitmap.disposed?



        @background_sprite.bitmap.dispose



      end



      @background_sprite.dispose



    end



    super



  end







  def create_background_sprite



    @background_sprite = Sprite.new



    @background_sprite.z = self.z - 1



    bmp = Bitmap.new(self.width, self.height)



    border = Rect.new(0, 0, self.width, self.height)



    inner  = Rect.new(2, 2, self.width - 4, self.height - 4)







    if bmp.respond_to?(:fill_rounded_rect)



      bmp.fill_rounded_rect(border,



        AlbertBattleStateHUD::DETAIL_BG_BORDER,



        AlbertBattleStateHUD::DETAIL_CORNER_RADIUS)



      bmp.fill_rounded_rect(inner,



        AlbertBattleStateHUD::DETAIL_BG_COLOR,



        AlbertBattleStateHUD::DETAIL_CORNER_RADIUS)



    else



      bmp.fill_rect(border, AlbertBattleStateHUD::DETAIL_BG_BORDER)



      bmp.fill_rect(inner, AlbertBattleStateHUD::DETAIL_BG_COLOR)



    end







    @background_sprite.bitmap = bmp



    sync_background_sprite



  end







  def battler=(battler)
    return if @battler.equal?(battler)
    @battler = battler
    @last_detail_placement_key = nil
    @last_dirty_version = -1
    @last_payload_signature = nil
    update_placement
    force_refresh
  end

  def battler_sprite=(sprite)
    return if @battler_sprite.equal?(sprite)
    @battler_sprite = sprite
    @last_detail_placement_key = nil
    update_placement_if_needed
  end







  def target_side=(side)



    side = (side == :right ? :right : :left)



    return if @target_side == side



    @target_side = side

    @last_detail_placement_key = nil
    update_placement_if_needed



  end







  def detail_target_screen_y

    battler = @battler

    if battler != nil

      if !AlbertBattleStateHUD::DETAIL_FOLLOW_Y &&
         battler.respond_to?(:base_position_y)

        begin
          value = battler.base_position_y.to_i
          return value if value != 0
        rescue
        end

      end

      if battler.respond_to?(:position_y)

        begin
          value = battler.position_y.to_i
          return value if value != 0
        rescue
        end

      end

    end

    sprite = @battler_sprite

    if sprite != nil &&
       (!sprite.respond_to?(:disposed?) || !sprite.disposed?) &&
       sprite.respond_to?(:y)

      begin
        value = sprite.y.to_i
        return value if value != 0
      rescue
      end

    end

    if battler != nil && battler.respond_to?(:screen_y)

      begin
        return battler.screen_y.to_i
      rescue
      end

    end

    return nil

  rescue

    return nil

  end







  def dynamic_detail_y(default_y)

    return default_y unless
      AlbertBattleStateHUD::DETAIL_DYNAMIC_Y

    target_y = detail_target_screen_y
    return default_y if target_y == nil

    top_limit = AlbertBattleStateHUD::DETAIL_TOP_LIMIT
    bottom_limit =
      Graphics.height -
      AlbertBattleStateHUD::DETAIL_BOTTOM_MARGIN

    candidate =
      target_y -
      self.height / 2 +
      AlbertBattleStateHUD::DETAIL_CENTER_OFFSET_Y

    max_y = [bottom_limit - self.height, top_limit].max

    candidate = top_limit if candidate < top_limit
    candidate = max_y if candidate > max_y

    return candidate

  end







  def detail_placement_key

    target_id = @battler == nil ? 0 : @battler.object_id

    return [
      target_id,
      @target_side,
      detail_target_screen_y,
      self.width,
      self.height
    ]

  end







  def update_placement_if_needed

    key = detail_placement_key
    return if @last_detail_placement_key == key

    @last_detail_placement_key = key
    update_placement

  end







  def update_placement
    margin = AlbertBattleStateHUD::DETAIL_MARGIN_X
    default_y = AlbertBattleStateHUD::DETAIL_ACTOR_Y
    if @target_side == :right
      self.x = Graphics.width - self.width - margin
      default_y = AlbertBattleStateHUD::DETAIL_ENEMY_Y
    else
      self.x = margin
      default_y = AlbertBattleStateHUD::DETAIL_ACTOR_Y
    end
    self.y = dynamic_detail_y(default_y)
    sync_background_sprite
  end







  def sync_background_sprite



    return if @background_sprite == nil || @background_sprite.disposed?



    @background_sprite.x = self.x



    @background_sprite.y = self.y



    @background_sprite.z = self.z - 1



    @background_sprite.visible = self.visible



  end







  def update

    super

    update_placement_if_needed
    sync_background_sprite
    return if @battler == nil







    dirty = @battler.respond_to?(:albert_bshud_dirty_version) ?



            @battler.albert_bshud_dirty_version : 0







    if dirty != @last_dirty_version



      force_refresh



      return



    end







    interval = [AlbertBattleStateHUD::DETAIL_FALLBACK_POLL_INTERVAL, 1].max



    if Graphics.frame_count - @last_poll_frame >= interval



      force_refresh(false)



    end



  end







  def force_refresh(force_draw = true)



    @last_poll_frame = Graphics.frame_count







    unless AlbertBattleStateHUD::ENABLE_TARGET_DETAIL && @battler != nil



      self.visible = false



      sync_background_sprite



      return



    end







    states = AlbertBattleStateHUD.detail_states(@battler)



    info_rows = AlbertBattleStateHUD.extra_info_rows(@battler)







    payload_signature = make_payload_signature(states, info_rows)



    dirty = @battler.respond_to?(:albert_bshud_dirty_version) ?



            @battler.albert_bshud_dirty_version : 0







    if states.empty? && info_rows.empty?



      self.visible = false



      @last_payload_signature = payload_signature



      @last_dirty_version = dirty



      sync_background_sprite



      return



    end







    self.visible = true



    sync_background_sprite







    if force_draw || payload_signature != @last_payload_signature



      @last_payload_signature = payload_signature



      redraw(states, info_rows)



    end







    @last_dirty_version = dirty



  end







  def make_payload_signature(states, info_rows)



    values = [@battler.object_id, @target_side]



    states.each do |state|



      values << state.id



      values << AlbertBattleStateHUD.state_stack(@battler, state)



      values << AlbertBattleStateHUD.state_turns_left(@battler, state)



      values << AlbertBattleStateHUD.hud_name(state)



      values << AlbertBattleStateHUD.hud_detail_text(state)



    end



    info_rows.each do |row|



      values << row[0]



      values << row[1]



    end



    return values.join(":")



  end







  def redraw(states, info_rows)



    self.contents.clear







    old_size  = self.contents.font.size



    old_bold  = self.contents.font.bold



    old_color = self.contents.font.color







    self.contents.font.size = AlbertBattleStateHUD::DETAIL_TEXT_SIZE



    self.contents.font.bold = false



    self.contents.font.color = normal_color







    y = 0



    line_h = AlbertBattleStateHUD::DETAIL_LINE_HEIGHT



    bottom_limit = self.contents.height - line_h



    info_drawn = 0







    #-----------------------------------------------------------------------



    # 1. 非 State 的重要機制資訊



    #-----------------------------------------------------------------------



    info_rows.each do |row|



      break if info_drawn >= AlbertBattleStateHUD::DETAIL_MAX_INFO_ROWS



      break if y > bottom_limit







      label = row[0].to_s



      value = row[1].to_s



      label_w = self.contents.text_size(label).width + 8



      label_w = 110 if label_w > 110







      self.contents.font.color = system_color



      self.contents.draw_text(0, y, label_w, line_h, label, 0)



      self.contents.font.color = normal_color



      self.contents.draw_text(label_w, y,



        self.contents.width - label_w, line_h, value, 0)







      y += line_h



      info_drawn += 1



    end







    #-----------------------------------------------------------------------



    # 2. State 詳細資訊，允許同列多個



    #-----------------------------------------------------------------------



    x = 0



    state_drawn = 0







    states.each do |state|



      break if state_drawn >= AlbertBattleStateHUD::DETAIL_MAX_STATES



      break if y > bottom_limit







      text = AlbertBattleStateHUD.detail_text(@battler, state)



      next if text == ""







      icon_index = AlbertBattleStateHUD.hud_icon(state)



      icon_w = icon_index > 0 ? 20 : 0



      text_w = self.contents.text_size(text).width + 8



      unit_w = icon_w + text_w







      if x > 0 && x + unit_w > self.contents.width



        x = 0



        y += line_h



      end



      break if y > bottom_limit







      if icon_index > 0



        draw_icon(icon_index, x, y - 2)



        x += 20



      end







      draw_w = [text_w, self.contents.width - x].min



      self.contents.draw_text(x, y, draw_w, line_h, text, 0)



      x += draw_w



      state_drawn += 1



    end







    total_hidden = 0



    total_hidden += info_rows.size - info_drawn if info_rows.size > info_drawn



    total_hidden += states.size - state_drawn if states.size > state_drawn



    if total_hidden > 0 && y <= bottom_limit



      if x > 0 && x + 48 > self.contents.width



        x = 0



        y += line_h



      end



      self.contents.draw_text(x, y, 48, line_h, "+#{total_hidden}", 0) if y <= bottom_limit



    end







    self.contents.font.size = old_size



    self.contents.font.bold = old_bold



    self.contents.font.color = old_color



  end



end







#===============================================================================



# ■ AlbertBattleStateHUDManager



#===============================================================================



class AlbertBattleStateHUDManager

  def initialize(scene)
    @scene = scene
    @spriteset = fs_bshud_spriteset
    @viewport = fs_bshud_battle_viewport
    @owns_viewport = false

    if @viewport == nil
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 0
      @owns_viewport = true
    end

    @sprites = {}
    @selected_target = nil
    @detail_window = nil
    @last_sync_frame = -999999
    @last_update_frame = -1

    if AlbertBattleStateHUD::ENABLE_TARGET_DETAIL
      @detail_window = Window_AlbertBattleStateDetail.new
    end

    sync_battlers(true)
  end

  def dispose
    @sprites.each_value do |sprite|
      sprite.dispose unless sprite.disposed?
    end
    @sprites.clear

    if @detail_window != nil && !@detail_window.disposed?
      @detail_window.dispose
    end

    if @owns_viewport && @viewport != nil && !@viewport.disposed?
      @viewport.dispose
    end
  end

  def selected_target=(target)
    return if @selected_target.equal?(target)
    @selected_target = target

    if @detail_window != nil
      if target != nil && target.is_a?(Game_Enemy)
        @detail_window.target_side = :right
      else
        @detail_window.target_side = :left
      end
      @detail_window.battler_sprite =
        fs_bshud_sprite_for_battler(target)
      @detail_window.battler = target
    end
  end

  def update
    return if @last_update_frame == Graphics.frame_count
    @last_update_frame = Graphics.frame_count

    sync_battlers(false)

    command_active = fs_bshud_command_active?
    commander = fs_bshud_commander

    @sprites.each_value do |sprite|
      sprite.command_active = command_active
      sprite.commander = commander
      sprite.update
    end

    @detail_window.update if @detail_window != nil
  end

  def sync_battlers(force = false)
    interval = [AlbertBattleStateHUD::BATTLER_SYNC_INTERVAL, 1].max

    unless force
      return if Graphics.frame_count - @last_sync_frame < interval
    end

    @last_sync_frame = Graphics.frame_count
    @spriteset = fs_bshud_spriteset if @spriteset == nil

    battlers = []
    battlers.concat($game_party.members) if $game_party != nil
    battlers.concat($game_troop.members) if $game_troop != nil

    current_keys = {}

    battlers.each do |battler|
      next if battler == nil
      key = battler.object_id
      current_keys[key] = true
      battler_sprite = fs_bshud_sprite_for_battler(battler)

      unless @sprites.include?(key)
        viewport = @viewport
        if battler_sprite != nil &&
           battler_sprite.respond_to?(:viewport) &&
           battler_sprite.viewport != nil
          viewport = battler_sprite.viewport
        end
        @sprites[key] = Sprite_AlbertBattleStateHUD.new(
          viewport, battler, battler_sprite)
      else
        @sprites[key].battler_sprite = battler_sprite
      end
    end

    @sprites.keys.clone.each do |key|
      next if current_keys[key]
      sprite = @sprites.delete(key)
      sprite.dispose if sprite != nil && !sprite.disposed?
    end

    if @detail_window != nil && @selected_target != nil
      @detail_window.battler_sprite =
        fs_bshud_sprite_for_battler(@selected_target)
    end
  end

  def fs_bshud_spriteset
    return nil if @scene == nil
    return @scene.instance_variable_get(:@spriteset)
  rescue
    return nil
  end

  def fs_bshud_battle_viewport
    spriteset = fs_bshud_spriteset
    return nil if spriteset == nil
    return spriteset.instance_variable_get(:@viewport1)
  rescue
    return nil
  end

  # 只在BATTLER_SYNC_INTERVAL時掃描，不在每幀全隊搜尋。
  def fs_bshud_sprite_for_battler(battler)
    return nil if battler == nil
    spriteset = @spriteset
    return nil if spriteset == nil

    groups = []
    begin
      groups.push(spriteset.instance_variable_get(:@actor_sprites))
    rescue
    end
    begin
      groups.push(spriteset.instance_variable_get(:@enemy_sprites))
    rescue
    end

    for group in groups
      next unless group.is_a?(Array)
      for sprite in group
        next if sprite == nil
        next if sprite.respond_to?(:disposed?) && sprite.disposed?
        next unless sprite.respond_to?(:battler)
        return sprite if sprite.battler.equal?(battler)
      end
    end

    return nil
  rescue
    return nil
  end

  def fs_bshud_command_active?
    return false unless AlbertBattleStateHUD::COMMAND_LAYER_ENABLED
    return false if @scene == nil

    window =
      @scene.instance_variable_get(:@actor_command_window)
    return false if window == nil
    return false unless window.active

    # 有些商店式／戰鬥補丁會讓Window存在但隱藏。
    # 只有真正顯示且接收輸入時才視為Command期間。
    if window.respond_to?(:visible)
      return false unless window.visible
    end

    return false if fs_bshud_commander == nil
    return true
  rescue
    return false
  end

  def fs_bshud_commander
    return nil if @scene == nil
    return @scene.instance_variable_get(:@commander)
  rescue
    return nil
  end
end



#===============================================================================



# ■ Scene_Battle



#===============================================================================



class Scene_Battle < Scene_Base



  unless method_defined?(:albert_bshud_v2_old_start)



    alias albert_bshud_v2_old_start start



  end



  def start



    albert_bshud_v2_old_start







    # 若舊 v1.2 不慎還在 alias 鏈裡，先清掉舊 manager，再建立 v2。



    if @albert_battle_state_hud != nil



      begin



        @albert_battle_state_hud.dispose



      rescue



      end



    end



    @albert_battle_state_hud = AlbertBattleStateHUDManager.new(self)



  end







  unless method_defined?(:albert_bshud_v2_old_update)



    alias albert_bshud_v2_old_update update



  end



  def update



    albert_bshud_v2_old_update



    if @albert_battle_state_hud != nil



      @albert_battle_state_hud.selected_target = albert_bshud_v2_selected_target



      @albert_battle_state_hud.update



    end



  end







  unless method_defined?(:albert_bshud_v2_old_terminate)



    alias albert_bshud_v2_old_terminate terminate



  end



  def terminate



    if @albert_battle_state_hud != nil



      begin



        @albert_battle_state_hud.dispose



      rescue



      end



      @albert_battle_state_hud = nil



    end



    albert_bshud_v2_old_terminate



  end







  #--------------------------------------------------------------------------



  # ● 取得目前真正需要顯示詳細資訊的對象



  #--------------------------------------------------------------------------



  def albert_bshud_v2_selected_target



    # Tankentai / ATB 選擇敵我目標



    if defined?($in_target) && $in_target



      if @target_members != nil && @index != nil



        return @target_members[@index]



      end



    end







    # 其他敵方目標 Window



    if @target_enemy_window != nil &&



       !@target_enemy_window.disposed? &&



       @target_enemy_window.active



      return @target_enemy_window.enemy if @target_enemy_window.respond_to?(:enemy)



    end







    # 其他我方目標 Window



    if @target_actor_window != nil &&



       !@target_actor_window.disposed? &&



       @target_actor_window.active



      index = @target_actor_window.index



      return $game_party.members[index] if index != nil && index >= 0



    end







    # ATB 滿，角色正在 Command Window 等待玩家操作



    if @actor_command_window != nil &&



       !@actor_command_window.disposed? &&



       @actor_command_window.active







      in_target = (defined?($in_target) && $in_target)



      in_select = (defined?($in_select) && $in_select)



      unless in_target || in_select



        return @commander if @commander != nil



      end



    end







    return nil



  end



end
