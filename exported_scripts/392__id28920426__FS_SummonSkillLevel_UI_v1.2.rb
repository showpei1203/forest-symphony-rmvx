#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SummonSkillLevel_UI v1.2
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_SummonSkillLevel_UI v1.2」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Window_SummonSkillJPStatus、Window_SummonLevelSkill、Window_EquipStat、Scene_SummonSkillLevel、Scene_Equip、Window_SummonSkillActorSelect、Scene_SummonSkillSelect
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：OPEN_KEY、TITLE_TEXT、HELP_TEXT、EMPTY_TEXT、JP_TEXT、LEVEL_TEXT、ALLOW_UNLEVEL、ENABLE_DEBUG_JP。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：Albert_SummonSkillLevel_UI；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ Albert_SummonSkillLevel_UI_v1_2_SummonSelector
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
#
# 【目的】
#   為「戰鬥後會暫時離隊的召喚物」提供專用技能升級 UI。
#
#   本腳本不新增任何新成長資源，也不修改原有技能等級規則。
#   它只重用既有的：
#
#     - Game_Actor#class_jp
#     - Game_Actor#lose_jp
#     - Game_Actor#skill_level
#     - Game_Actor#skill_level_up
#     - RPG::Skill#level_jp
#     - RPG::Skill#max_level
#     - Window_LevelData
#
# 【與進化系統的關係】
#   同一進化線若共用同一 Class ID：
#
#     妙蛙種子 Actor A ┐
#     妙蛙草   Actor B ├─ Class 100
#     妙蛙花   Actor C ┘
#
#   則 JP 會自然使用同一個 class_jp[100] 桶。
#
#   技能等級本身仍由既有 @skill_level[skill_id] 保存，
#   進化時由現有 Evolution 補丁負責複製。
#
# 【v1.2 新增】
#   新增召喚物選擇 Scene：Scene_SummonSkillSelect。
#   從 ArmorMapping 自動偵測玩家目前持有／已裝備的魂刻，
#   列出魂刻目前對應進化形態的 Actor 名稱、等級與 JP。
#
#   操作流程：
#     Scene_SummonSkillSelect
#       ↓ 選擇召喚物
#     Scene_SummonSkillLevel
#       ↓ B / ESC
#     回召喚物名稱選單
#       ↓ B / ESC
#     回 Scene_Map
#
#   事件腳本呼叫：
#     $scene = Scene_SummonSkillSelect.new
#
#   原有直接呼叫方式仍保留：
#     $scene = Scene_SummonSkillLevel.new(actor_id)
#
# 【v1.1 修正】
#   召喚物技能 UI 不再呼叫 sync_actor_database_data。
#   JP、技能等級、目前 Class ID 一律讀取目前存檔中的 $game_actors。
#
#   同時覆寫 Equip_SummonPage_Extension 的顯示同步：
#   只同步名稱／圖像，不再因為打開裝備頁而覆寫 @class_id。
#
#   這可避免舊存檔開啟 UI 時，@class_id 被資料庫同步成新值後，
#   改去讀取另一個 @class_jp[class_id] 桶而顯示 0 JP。
#
# 【重要】
#   本腳本不呼叫 actor.setup(actor_id)。
#   不 recover_all。
#   不重新建立 Game_Actor。
#   因此不會重置等級、EXP、JP、技能等級或其他持久進度。
#
# 【安裝位置】
#   請放在以下腳本之下、Main 之上：
#
#     - JP System / Job System Base
#     - Job System Skill Levels
#     - YEM Equipment Overhaul
#     - ArmorMapping
#     - Albert_SummonTemporaryBattle_v2_0
#     - Albert_YEM_Equip_SummonPage_Extension_v1_0
#
# 【裝備畫面入口】
#   在 YEM Equipment Overhaul 畫面中：
#
#     1. 游標停在已裝備的魂刻，或
#     2. 游標停在裝備候選清單中的魂刻
#
#   按 OPEN_KEY，即開啟該魂刻目前進化形態的技能升級 UI。
#
#   預設：Input::X
#
# 【事件腳本呼叫】
#
#   直接指定 Actor ID：
#     $scene = Scene_SummonSkillLevel.new(100)
#
#   依魂刻 Armor ID：
#     $scene = Scene_SummonSkillLevel.from_armor(500)
#
#==============================================================================

$imported = {} if $imported == nil
$imported["Albert_SummonSkillLevel_UI"] = true

module ALBERT_SUMMON_SKILL_LEVEL_UI

  #--------------------------------------------------------------------------
  # ● 裝備畫面中開啟召喚物技能強化 UI 的按鍵
  #--------------------------------------------------------------------------
  OPEN_KEY = Input::X

  #--------------------------------------------------------------------------
  # ● UI 用語
  #--------------------------------------------------------------------------
  TITLE_TEXT      = "召喚物技能強化"
  HELP_TEXT       = "選擇技能並消耗該召喚物自己的 JP 進行強化。"
  EMPTY_TEXT      = "目前沒有可升級的技能。"
  JP_TEXT         = "JP"
  LEVEL_TEXT      = "Lv"

  #--------------------------------------------------------------------------
  # ● 是否允許技能降級
  #   本版刻意關閉，避免退款、負成本與額外平衡問題。
  #--------------------------------------------------------------------------
  ALLOW_UNLEVEL = false

  #--------------------------------------------------------------------------
  # ● 是否在測試模式開放 F8 增加 JP
  #--------------------------------------------------------------------------
  ENABLE_DEBUG_JP = true

  #--------------------------------------------------------------------------
  # ● 測試模式 F8 每次增加 JP
  #--------------------------------------------------------------------------
  DEBUG_JP_GAIN = 1000

  #--------------------------------------------------------------------------
  # ● 安全取得 ArmorMapping 對應 Actor ID
  #--------------------------------------------------------------------------
  def self.actor_id_from_armor(armor)
    return 0 if armor == nil
    return 0 unless armor.is_a?(RPG::Armor)
    return 0 unless defined?(ArmorMapping)
    return 0 unless ArmorMapping.respond_to?(:mapping)

    mapping = ArmorMapping.mapping
    return 0 if mapping == nil

    actor_id = mapping[armor.id]
    return 0 if actor_id == nil
    return actor_id.to_i
  end

  #--------------------------------------------------------------------------
  # ● 安全取得「目前存檔中的真正 Game_Actor」
  #--------------------------------------------------------------------------
  # 重要：
  #   這裡刻意不呼叫 sync_actor_database_data。
  #
  #   原因是該同步方法會把 @class_id 改成目前資料庫的 class_id。
  #   但 YEZ JP 系統把 JP 存在：
  #
  #     @class_jp[class_id]
  #
  #   若舊存檔中的召喚物曾使用另一個 class_id，開啟 UI 時先同步
  #   @class_id，便會改去讀另一個 JP 桶，看起來就會突然變成 0。
  #
  #   本 UI 的養成資料來源必須永遠是目前存檔中的 $game_actors。
  #--------------------------------------------------------------------------
  def self.actor(actor_id)
    actor_id = actor_id.to_i
    return nil if actor_id <= 0
    return nil if $game_actors == nil
    return $game_actors[actor_id]
  end

  #--------------------------------------------------------------------------
  # ● 取得這次 UI 應使用的 JP Class ID
  #--------------------------------------------------------------------------
  # 在 Scene 開啟瞬間鎖定目前存檔 Actor 的 class_id。
  # 之後所有顯示、判定、扣除、Debug 增加 JP 都使用同一個 ID，
  # 不再途中重新讀取資料庫 class_id。
  #--------------------------------------------------------------------------
  def self.jp_class_id(actor)
    return 0 if actor == nil

    current_id = actor.class_id.to_i
    return current_id unless actor.respond_to?(:class_jp)

    hash = actor.class_jp
    return current_id if hash[current_id].to_i > 0

    # 舊存檔若曾被其他顯示補丁改過 @class_id，
    # 但 JP 仍留在唯一的舊 Class 桶中，優先找回那個真正有 JP 的桶。
    nonzero_ids = []
    hash.each do |class_id, value|
      next if class_id == nil
      nonzero_ids << class_id.to_i if value.to_i > 0
    end
    nonzero_ids.uniq!

    return nonzero_ids[0] if nonzero_ids.size == 1
    return current_id
  end

end

#==============================================================================
# ■ Window_SummonSkillJPStatus
#------------------------------------------------------------------------------
# 顯示召喚物名稱、等級與目前 Class JP。
#==============================================================================

class Window_SummonSkillJPStatus < Window_Base

  def initialize(actor, jp_class_id)
    super(0, 56, 544, 64)
    @actor = actor
    @jp_class_id = jp_class_id.to_i
    refresh
  end

  def refresh
    self.contents.clear
    return if @actor == nil

    jp = 0
    if @actor.respond_to?(:class_jp)
      jp = @actor.class_jp[@jp_class_id].to_i
    end

    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 52, WLH, "召喚")
    self.contents.font.color = normal_color
    self.contents.draw_text(58, 0, 150, WLH, @actor.name.to_s)

    self.contents.font.color = system_color
    self.contents.draw_text(214, 0, 28, WLH, ALBERT_SUMMON_SKILL_LEVEL_UI::LEVEL_TEXT)
    self.contents.font.color = normal_color
    self.contents.draw_text(244, 0, 54, WLH, @actor.level.to_s)

    self.contents.font.color = system_color
    self.contents.draw_text(320, 0, 42, WLH, ALBERT_SUMMON_SKILL_LEVEL_UI::JP_TEXT)
    self.contents.font.color = normal_color
    self.contents.draw_text(362, 0, 150, WLH, jp.to_s, 2)
  end

end

#==============================================================================
# ■ Window_SummonLevelSkill
#------------------------------------------------------------------------------
# 專用技能清單。
#
# 與原 Window_LevelSkill 最大差異：
#   不從 YEZ::JOB::CLASS_SKILLS_LIST 建清單，
#   而是直接讀取「目前召喚 Actor 真正持有的技能」。
#
# 這樣召喚物不必為了 UI 額外塞進一般職業技能學習表。
#==============================================================================

class Window_SummonLevelSkill < Window_LevelSkill

  #--------------------------------------------------------------------------
  # ● 重新建立技能清單
  #--------------------------------------------------------------------------
  def refresh(class_id = nil)
    @class_id = class_id == nil ? @actor.class_id : class_id
    @data = []

    skills = []

    if @actor.respond_to?(:learned_skills)
      skills.concat(@actor.learned_skills)
    end

    if @actor.respond_to?(:total_skills)
      skills.concat(@actor.total_skills)
    end

    skills.compact!
    skills.uniq!
    skills.sort! { |a, b| a.id <=> b.id }

    skills.each do |skill|
      next unless include?(skill)
      @data << skill
    end

    @item_max = @data.size
    self.index = 0 if self.index == nil || self.index < 0
    self.index = [self.index, @item_max - 1].min if @item_max > 0
    self.index = -1 if @item_max <= 0

    create_contents
    for i in 0...@item_max
      draw_item(i)
    end
  end

end

#==============================================================================
# ■ Window_EquipStat
#------------------------------------------------------------------------------
# Equip_SummonPage_Extension 相容修正：
#
# 原本 albert_sync_equip_summon_actor 會同步 @class_id。
# 但 @class_id 同時是 YEZ JP 系統讀取 @class_jp[class_id] 的 key。
# 因此單純打開裝備頁，就可能讓舊存檔改去讀另一個 JP 桶。
#
# 這裡改成只同步「顯示身分」：
#   - Actor ID
#   - 名稱
#   - 行走圖
#   - 臉圖
#
# 不同步：
#   - @class_id
#   - @class_jp
#   - @skill_level
#   - EXP / Level / Skills / Equips
#==============================================================================
if defined?(Window_EquipStat)
  class Window_EquipStat < Window_Base

    def albert_sync_equip_summon_actor(actor_id)
      actor_id = actor_id.to_i
      return nil if actor_id <= 0
      return nil if $game_actors == nil
      return nil if $data_actors == nil

      actor = $game_actors[actor_id]
      data  = $data_actors[actor_id]

      return nil if actor == nil
      return nil if data == nil

      actor.instance_variable_set(:@actor_id, actor_id)
      actor.instance_variable_set(:@name, data.name)
      actor.instance_variable_set(:@character_name, data.character_name)
      actor.instance_variable_set(:@character_index, data.character_index)
      actor.instance_variable_set(:@face_name, data.face_name)
      actor.instance_variable_set(:@face_index, data.face_index)

      # 故意不碰 @class_id。
      # JP UI 與目前存檔養成資料必須使用 Game_Actor 本身的 Class / JP 狀態。

      return actor
    end

  end
end

#==============================================================================
# ■ Scene_SummonSkillLevel
#------------------------------------------------------------------------------
# 召喚物專用技能升級畫面。
#==============================================================================

class Scene_SummonSkillLevel < Scene_Base

  #--------------------------------------------------------------------------
  # ● 依魂刻 Armor ID 建立 Scene
  #--------------------------------------------------------------------------
  def self.from_armor(armor_id)
    armor = $data_armors[armor_id]
    actor_id = ALBERT_SUMMON_SKILL_LEVEL_UI.actor_id_from_armor(armor)
    return nil if actor_id <= 0
    return Scene_SummonSkillLevel.new(actor_id)
  end

  #--------------------------------------------------------------------------
  # ● 初始化
  #
  # return_actor_index / return_equip_index：
  #   從 Scene_Equip 開啟時，用於返回原裝備角色與裝備欄位置。
  #
  # return_to_equip：
  #   true  -> B 鍵返回 Scene_Equip
  #   false -> B 鍵返回 Scene_Map
  #--------------------------------------------------------------------------
  def initialize(actor_id, return_actor_index = 0, return_equip_index = 0,
                 return_to_equip = false)
    @actor_id = actor_id.to_i
    @return_actor_index = return_actor_index.to_i
    @return_equip_index = return_equip_index.to_i
    @return_to_equip = return_to_equip
  end

  #--------------------------------------------------------------------------
  # ● 開始
  #--------------------------------------------------------------------------
  def start
    super
    create_menu_background

    @actor = ALBERT_SUMMON_SKILL_LEVEL_UI.actor(@actor_id)
    @jp_class_id = ALBERT_SUMMON_SKILL_LEVEL_UI.jp_class_id(@actor)

    create_help_window
    create_status_window
    create_skill_windows

    refresh_all
  end

  #--------------------------------------------------------------------------
  # ● 建立 Help Window
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.set_text(ALBERT_SUMMON_SKILL_LEVEL_UI::HELP_TEXT)
  end

  #--------------------------------------------------------------------------
  # ● 建立狀態視窗
  #--------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_SummonSkillJPStatus.new(@actor, @jp_class_id)
  end

  #--------------------------------------------------------------------------
  # ● 建立技能與詳細資料視窗
  #--------------------------------------------------------------------------
  def create_skill_windows
    @levelskill_window = Window_SummonLevelSkill.new(0, 120, @actor)
    @levelskill_window.active = true
    @levelskill_window.help_window = @help_window

    skill = @levelskill_window.skill
    @leveldata_window = Window_LevelData.new(
      274,
      120,
      skill,
      @actor,
      @jp_class_id
    )

    @last_levelskill_index = @levelskill_window.index
    update_help_text
  end

  #--------------------------------------------------------------------------
  # ● 終止
  #--------------------------------------------------------------------------
  def terminate
    super
    dispose_menu_background
    @help_window.dispose if @help_window != nil
    @status_window.dispose if @status_window != nil
    @levelskill_window.dispose if @levelskill_window != nil
    @leveldata_window.dispose if @leveldata_window != nil
  end

  #--------------------------------------------------------------------------
  # ● 更新
  #--------------------------------------------------------------------------
  def update
    super
    update_menu_background

    @help_window.update if @help_window != nil
    @status_window.update if @status_window != nil
    @levelskill_window.update if @levelskill_window != nil
    @leveldata_window.update if @leveldata_window != nil

    update_index_change

    if Input.trigger?(Input::B)
      Sound.play_cancel
      return_scene
      return
    end

    if ALBERT_SUMMON_SKILL_LEVEL_UI::ENABLE_DEBUG_JP &&
       $TEST && Input.trigger?(Input::F8)
      debug_gain_jp
      return
    end

    if Input.trigger?(Input::C)
      upgrade_current_skill
      return
    end
  end

  #--------------------------------------------------------------------------
  # ● 游標改變
  #--------------------------------------------------------------------------
  def update_index_change
    return if @levelskill_window == nil
    return if @last_levelskill_index == @levelskill_window.index

    @last_levelskill_index = @levelskill_window.index
    skill = @levelskill_window.skill
    @leveldata_window.refresh(skill, @jp_class_id)
    update_help_text
  end

  #--------------------------------------------------------------------------
  # ● Help Window 文字
  #--------------------------------------------------------------------------
  def update_help_text
    return if @help_window == nil

    skill = @levelskill_window == nil ? nil : @levelskill_window.skill

    if skill == nil
      @help_window.set_text(ALBERT_SUMMON_SKILL_LEVEL_UI::EMPTY_TEXT)
    else
      @help_window.set_text(skill.description.to_s)
    end
  end

  #--------------------------------------------------------------------------
  # ● 升級目前技能
  #--------------------------------------------------------------------------
  def upgrade_current_skill
    skill = @levelskill_window.skill

    if skill == nil || !@levelskill_window.enabled_skill?(skill)
      Sound.play_buzzer
      return
    end

    current_level = @actor.skill_level(skill)
    next_level = current_level + 1
    cost = skill.level_jp[next_level].to_i

    # 雙重安全檢查，避免資料缺漏或其他腳本改寫 enabled_skill? 後超扣 JP。
    if @actor.class_jp[@jp_class_id].to_i < cost
      Sound.play_buzzer
      return
    end

    if defined?(YEZ::JOB::LEVEL_UP_SOUND) &&
       YEZ::JOB::LEVEL_UP_SOUND.respond_to?(:play)
      YEZ::JOB::LEVEL_UP_SOUND.play
    else
      Sound.play_decision
    end

    @actor.skill_level_up(skill)
    @actor.lose_jp(cost, @jp_class_id)

    refresh_all(skill)
  end

  #--------------------------------------------------------------------------
  # ● 測試模式增加 JP
  #--------------------------------------------------------------------------
  def debug_gain_jp
    Sound.play_equip
    @actor.gain_jp(
      ALBERT_SUMMON_SKILL_LEVEL_UI::DEBUG_JP_GAIN,
      @jp_class_id
    )
    refresh_all
  end

  #--------------------------------------------------------------------------
  # ● 全部刷新
  #--------------------------------------------------------------------------
  def refresh_all(preferred_skill = nil)
    @status_window.refresh if @status_window != nil

    if @levelskill_window != nil
      old_index = @levelskill_window.index
      @levelskill_window.refresh(@jp_class_id)

      if preferred_skill != nil
        data = @levelskill_window.instance_variable_get(:@data)
        if data != nil
          new_index = data.index(preferred_skill)
          @levelskill_window.index = new_index unless new_index == nil
        end
      elsif @levelskill_window.item_max > 0
        @levelskill_window.index = [old_index, @levelskill_window.item_max - 1].min
      end
    end

    skill = @levelskill_window == nil ? nil : @levelskill_window.skill
    @leveldata_window.refresh(skill, @jp_class_id) if @leveldata_window != nil
    @last_levelskill_index = @levelskill_window.index if @levelskill_window != nil
    update_help_text
  end

  #--------------------------------------------------------------------------
  # ● 返回
  #--------------------------------------------------------------------------
  def return_scene
    if @return_to_equip
      $scene = Scene_Equip.new(@return_actor_index, @return_equip_index)
    else
      $scene = Scene_Map.new
    end
  end

end

#==============================================================================
# ■ Scene_Equip
#------------------------------------------------------------------------------
# 在 YEM Equipment Overhaul 中，按 OPEN_KEY 開啟目前魂刻對應召喚物的
# 技能強化 UI。
#==============================================================================

class Scene_Equip < Scene_Base

  alias albert_summon_skill_level_ui_update update unless $@

  def update
    albert_summon_skill_level_ui_update

    return unless Input.trigger?(ALBERT_SUMMON_SKILL_LEVEL_UI::OPEN_KEY)

    armor = albert_summon_skill_level_ui_current_armor
    actor_id = ALBERT_SUMMON_SKILL_LEVEL_UI.actor_id_from_armor(armor)

    if actor_id <= 0
      # 只有真的按了快捷鍵、但目前不是魂刻時才發出無效音。
      Sound.play_buzzer
      return
    end

    Sound.play_decision

    equip_index = 0
    if @equip_window != nil && @equip_window.respond_to?(:index)
      equip_index = @equip_window.index
    end

    actor_index = @actor_index == nil ? 0 : @actor_index

    $scene = Scene_SummonSkillLevel.new(
      actor_id,
      actor_index,
      equip_index,
      true
    )
  end

  #--------------------------------------------------------------------------
  # ● 取得目前游標指向的魂刻 Armor
  #--------------------------------------------------------------------------
  def albert_summon_skill_level_ui_current_armor
    # 優先讀裝備候選清單。
    if @item_window != nil && @item_window.active &&
       @item_window.respond_to?(:item)
      item = @item_window.item
      return item if item.is_a?(RPG::Armor)
    end

    # 其次讀已裝備欄位。
    if @equip_window != nil && @equip_window.active &&
       @equip_window.respond_to?(:item)
      item = @equip_window.item
      return item if item.is_a?(RPG::Armor)
    end

    return nil
  end

end

#==============================================================================

#==============================================================================
# ■ Albert Summon Skill Level UI v1.2 - Selector Extension
#------------------------------------------------------------------------------
# 追加「召喚物名稱選單」與返回流程。
#==============================================================================

module ALBERT_SUMMON_SKILL_LEVEL_UI

  #--------------------------------------------------------------------------
  # ● 選擇畫面用語
  #--------------------------------------------------------------------------
  SELECT_TITLE_TEXT = "選擇召喚物"
  SELECT_HELP_TEXT  = "選擇要強化技能的召喚物。"
  NO_SUMMON_TEXT    = "目前沒有可用的召喚魂刻。"

  #--------------------------------------------------------------------------
  # ● 是否只列出玩家目前真正持有的魂刻
  #
  # true：
  #   只列出背包中持有，或目前已被任一隊伍成員裝備的魂刻。
  #
  # false：
  #   ArmorMapping 中所有已登記魂刻全部列出，不管玩家是否取得。
  #--------------------------------------------------------------------------
  SHOW_ONLY_OWNED_SUMMONS = true

  #--------------------------------------------------------------------------
  # ● 顯示名稱
  #
  # 只讀 $data_actors 的最新名稱，不修改 Game_Actor 的養成資料。
  # 這可避免舊存檔保留舊名稱，同時不碰 @class_id / JP / Skill Level。
  #--------------------------------------------------------------------------
  def self.display_actor_name(actor_id)
    actor_id = actor_id.to_i

    if $data_actors != nil
      data = $data_actors[actor_id]
      if data != nil && data.name != nil && data.name.to_s != ""
        return data.name.to_s
      end
    end

    actor = self.actor(actor_id)
    return actor.name.to_s if actor != nil
    return "Actor #{actor_id}"
  end

  #--------------------------------------------------------------------------
  # ● 取得所有可能持有裝備的隊伍成員
  #
  # KGC Large Party 等腳本可能提供 all_members；優先使用。
  # 沒有則退回 members。
  #--------------------------------------------------------------------------
  def self.party_actor_candidates
    result = []
    return result if $game_party == nil

    if $game_party.respond_to?(:all_members)
      begin
        result.concat($game_party.all_members)
      rescue
      end
    end

    if result.empty? && $game_party.respond_to?(:members)
      begin
        result.concat($game_party.members)
      rescue
      end
    end

    result.compact!
    result.uniq!
    return result
  end

  #--------------------------------------------------------------------------
  # ● 魂刻是否目前被任一隊伍成員裝備
  #--------------------------------------------------------------------------
  def self.summon_armor_equipped?(armor)
    return false if armor == nil

    party_actor_candidates.each do |actor|
      next if actor == nil
      next unless actor.respond_to?(:equips)

      begin
        actor.equips.compact.each do |equip|
          next unless equip.is_a?(RPG::Armor)
          return true if equip.id == armor.id
        end
      rescue
      end
    end

    return false
  end

  #--------------------------------------------------------------------------
  # ● 玩家是否持有該魂刻
  #
  # 背包數量 > 0，或目前已被裝備，都視為持有。
  #--------------------------------------------------------------------------
  def self.summon_armor_owned?(armor)
    return false if armor == nil
    return true unless SHOW_ONLY_OWNED_SUMMONS
    return false if $game_party == nil

    if $game_party.respond_to?(:item_number)
      begin
        return true if $game_party.item_number(armor).to_i > 0
      rescue
      end
    end

    if $game_party.respond_to?(:armors)
      begin
        return true if $game_party.armors.include?(armor)
      rescue
      end
    end

    return true if summon_armor_equipped?(armor)
    return false
  end

  #--------------------------------------------------------------------------
  # ● 建立目前可選的召喚物清單
  #
  # 每筆資料：
  #   [armor_id, actor_id]
  #
  # actor_id 每次都重新從 ArmorMapping 讀取，因此進化後會自動取得
  # 同一魂刻現在映射的新 Actor ID。
  #--------------------------------------------------------------------------
  def self.summon_entries
    result = []
    return result unless defined?(ArmorMapping)
    return result unless ArmorMapping.respond_to?(:mapping)
    return result if $data_armors == nil

    mapping = ArmorMapping.mapping
    return result if mapping == nil

    ids = mapping.keys.collect { |id| id.to_i }.sort

    ids.each do |armor_id|
      next if armor_id <= 0

      armor = $data_armors[armor_id]
      next if armor == nil
      next unless summon_armor_owned?(armor)

      actor_id = mapping[armor_id].to_i
      next if actor_id <= 0

      actor = self.actor(actor_id)
      next if actor == nil

      result << [armor_id, actor_id]
    end

    return result
  end

end

#==============================================================================
# ■ Window_SummonSkillActorSelect
#------------------------------------------------------------------------------
# 列出目前已取得魂刻所對應的「現在進化形態」。
# 顯示：名稱 / Lv / JP
#==============================================================================

class Window_SummonSkillActorSelect < Window_Selectable

  attr_reader :data

  def initialize(index = 0)
    super(0, 56, 544, 360)
    @data = []
    refresh

    if @item_max > 0
      self.index = [[index.to_i, 0].max, @item_max - 1].min
    else
      self.index = -1
    end

    self.active = true
  end

  #--------------------------------------------------------------------------
  # ● 目前項目
  #--------------------------------------------------------------------------
  def entry
    return nil if @data == nil
    return nil if self.index == nil || self.index < 0
    return @data[self.index]
  end

  def armor_id
    item = entry
    return 0 if item == nil
    return item[0].to_i
  end

  def actor_id
    item = entry
    return 0 if item == nil
    return item[1].to_i
  end

  def actor
    return ALBERT_SUMMON_SKILL_LEVEL_UI.actor(actor_id)
  end

  #--------------------------------------------------------------------------
  # ● 更新資料
  #--------------------------------------------------------------------------
  def refresh
    old_actor_id = actor_id

    @data = ALBERT_SUMMON_SKILL_LEVEL_UI.summon_entries
    @item_max = @data.size

    create_contents
    self.contents.clear

    if @item_max <= 0
      self.contents.font.color = normal_color
      self.contents.draw_text(
        8,
        0,
        self.contents.width - 16,
        WLH,
        ALBERT_SUMMON_SKILL_LEVEL_UI::NO_SUMMON_TEXT,
        1
      )
      self.index = -1
      return
    end

    for i in 0...@item_max
      draw_item(i)
    end

    if old_actor_id > 0
      new_index = nil
      @data.each_with_index do |entry, i|
        if entry[1].to_i == old_actor_id
          new_index = i
          break
        end
      end
      self.index = new_index unless new_index == nil
    end

    self.index = 0 if self.index == nil || self.index < 0
    self.index = [self.index, @item_max - 1].min
  end

  #--------------------------------------------------------------------------
  # ● 畫一列
  #--------------------------------------------------------------------------
  def draw_item(index)
    entry = @data[index]
    return if entry == nil

    actor_id = entry[1].to_i
    actor = ALBERT_SUMMON_SKILL_LEVEL_UI.actor(actor_id)
    return if actor == nil

    rect = item_rect(index)
    self.contents.clear_rect(rect)

    name = ALBERT_SUMMON_SKILL_LEVEL_UI.display_actor_name(actor_id)
    jp_class_id = ALBERT_SUMMON_SKILL_LEVEL_UI.jp_class_id(actor)
    jp = 0
    jp = actor.class_jp[jp_class_id].to_i if actor.respond_to?(:class_jp)

    self.contents.font.color = normal_color
    self.contents.draw_text(rect.x + 4, rect.y, 230, WLH, name)

    self.contents.font.color = system_color
    self.contents.draw_text(rect.x + 248, rect.y, 28, WLH, "Lv")
    self.contents.font.color = normal_color
    self.contents.draw_text(rect.x + 278, rect.y, 48, WLH, actor.level.to_i.to_s, 2)

    self.contents.font.color = system_color
    self.contents.draw_text(rect.x + 356, rect.y, 32, WLH, "JP")
    self.contents.font.color = normal_color
    self.contents.draw_text(rect.x + 390, rect.y, 100, WLH, jp.to_s, 2)
  end

end

#==============================================================================
# ■ Scene_SummonSkillSelect
#------------------------------------------------------------------------------
# 流程：
#   地圖 / 事件
#     ↓
#   Scene_SummonSkillSelect
#     ↓ C
#   Scene_SummonSkillLevel
#     ↓ B
#   Scene_SummonSkillSelect
#     ↓ B
#   Scene_Map
#==============================================================================

class Scene_SummonSkillSelect < Scene_Base

  def initialize(index = 0)
    @return_index = index.to_i
  end

  def start
    super
    create_menu_background

    @help_window = Window_Help.new
    @help_window.set_text(ALBERT_SUMMON_SKILL_LEVEL_UI::SELECT_HELP_TEXT)

    @select_window = Window_SummonSkillActorSelect.new(@return_index)
  end

  def terminate
    super
    dispose_menu_background
    @help_window.dispose if @help_window != nil
    @select_window.dispose if @select_window != nil
  end

  def update
    super
    update_menu_background

    @help_window.update if @help_window != nil
    @select_window.update if @select_window != nil

    if Input.trigger?(Input::B)
      Sound.play_cancel
      $scene = Scene_Map.new
      return
    end

    if Input.trigger?(Input::C)
      open_current_summon
      return
    end
  end

  def open_current_summon
    if @select_window == nil || @select_window.item_max <= 0
      Sound.play_buzzer
      return
    end

    actor_id = @select_window.actor_id
    if actor_id <= 0
      Sound.play_buzzer
      return
    end

    Sound.play_decision

    $scene = Scene_SummonSkillLevel.new(
      actor_id,
      0,
      0,
      false,
      @select_window.index
    )
  end

end

#==============================================================================
# ■ Window_SummonSkillJPStatus
#------------------------------------------------------------------------------
# v1.2：名稱顯示改讀 $data_actors 最新名稱，但不修改 Game_Actor。
#==============================================================================

class Window_SummonSkillJPStatus < Window_Base

  def refresh
    self.contents.clear
    return if @actor == nil

    jp = 0
    if @actor.respond_to?(:class_jp)
      jp = @actor.class_jp[@jp_class_id].to_i
    end

    actor_name = ALBERT_SUMMON_SKILL_LEVEL_UI.display_actor_name(@actor.id)

    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 52, WLH, "召喚")
    self.contents.font.color = normal_color
    self.contents.draw_text(58, 0, 150, WLH, actor_name)

    self.contents.font.color = system_color
    self.contents.draw_text(214, 0, 28, WLH, ALBERT_SUMMON_SKILL_LEVEL_UI::LEVEL_TEXT)
    self.contents.font.color = normal_color
    self.contents.draw_text(244, 0, 54, WLH, @actor.level.to_s)

    self.contents.font.color = system_color
    self.contents.draw_text(320, 0, 42, WLH, ALBERT_SUMMON_SKILL_LEVEL_UI::JP_TEXT)
    self.contents.font.color = normal_color
    self.contents.draw_text(362, 0, 150, WLH, jp.to_s, 2)
  end

end

#==============================================================================
# ■ Scene_SummonSkillLevel
#------------------------------------------------------------------------------
# v1.2：追加 return_select_index。
# 從召喚物選擇畫面進入時，B 返回原選擇位置。
#==============================================================================

class Scene_SummonSkillLevel < Scene_Base

  #--------------------------------------------------------------------------
  # ● 初始化
  #
  # 第 5 參數 return_select_index：
  #   nil  -> 維持舊行為，返回 Equip 或 Map。
  #   數字 -> 返回 Scene_SummonSkillSelect，並恢復原游標位置。
  #--------------------------------------------------------------------------
  def initialize(actor_id, return_actor_index = 0, return_equip_index = 0,
                 return_to_equip = false, return_select_index = nil)
    @actor_id = actor_id.to_i
    @return_actor_index = return_actor_index.to_i
    @return_equip_index = return_equip_index.to_i
    @return_to_equip = return_to_equip
    @return_select_index = return_select_index
  end

  #--------------------------------------------------------------------------
  # ● 返回
  #--------------------------------------------------------------------------
  def return_scene
    if @return_select_index != nil
      $scene = Scene_SummonSkillSelect.new(@return_select_index)
    elsif @return_to_equip
      $scene = Scene_Equip.new(@return_actor_index, @return_equip_index)
    else
      $scene = Scene_Map.new
    end
  end

end

#==============================================================================
# ■ END
#==============================================================================
