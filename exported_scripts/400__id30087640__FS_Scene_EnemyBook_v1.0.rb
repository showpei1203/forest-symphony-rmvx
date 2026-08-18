#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_Scene_EnemyBook v1.0
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_Scene_EnemyBook v1.0」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Sprite_FSEnemyBookBattler、Window_FSEnemyBookList、Window_FSEnemyBookInfo、Scene_EnemyBook、FS_ENEMY_BOOK
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：PAGE_MAX、TYPE_NAMES、ATTACK_TYPES、TYPE_CHART。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】登記 $imported：FS Scene EnemyBook、ExtraDropItem；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_Scene_EnemyBook v1.0
#------------------------------------------------------------------------------
# Forest Symphony / RPG Maker VX / RGSS2
#
# 以專案既有 KGC_EnemyGuide 與 Yanfly Bestiary 的「遭遇／擊破紀錄」為資料源，
# 製作與 FS_Scene_CharacterBook_v2_1 相同操作習慣的敵人魂譜。
#
# 操作：
#   上下：選擇敵人
#   左右：切換資訊頁
#   B：返回魂譜分類選單（若不是由分類選單進入，則返回地圖）
#
# 注意：
#   1. 本腳本不建立 Game_Enemy，因此查看圖鑑不會誤增遭遇次數。
#   2. 紀錄保存在 $game_system／$game_party，天然隨存檔槽隔離。
#   3. 敵人 Note 可加入 <enemy_book_hide> 隱藏該敵人。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Scene EnemyBook"] = 1.0

module FS_ENEMY_BOOK
  PAGE_MAX = 4

  TYPE_NAMES = {
    :normal=>"一般", :fighting=>"格鬥", :flying=>"飛行", :poison=>"毒",
    :ground=>"地面", :rock=>"岩石", :bug=>"蟲", :ghost=>"幽靈",
    :steel=>"鋼", :fire=>"火", :water=>"水", :grass=>"草",
    :electric=>"電", :psychic=>"超能力", :ice=>"冰", :dragon=>"龍",
    :dark=>"惡", :fairy=>"妖精"
  }

  ATTACK_TYPES = [
    :normal, :fighting, :flying, :poison, :ground, :rock, :bug, :ghost,
    :steel, :fire, :water, :grass, :electric, :psychic, :ice, :dragon,
    :dark, :fairy
  ]

  TYPE_CHART = {
    :normal   => {:rock=>0.5, :ghost=>0.0, :steel=>0.5},
    :fighting => {:normal=>2.0, :flying=>0.5, :poison=>0.5, :rock=>2.0,
                  :bug=>0.5, :ghost=>0.0, :steel=>2.0, :psychic=>0.5,
                  :ice=>2.0, :dark=>2.0, :fairy=>0.5},
    :flying   => {:fighting=>2.0, :flying=>0.5, :rock=>0.5, :bug=>2.0,
                  :steel=>0.5, :grass=>2.0, :electric=>0.5},
    :poison   => {:poison=>0.5, :ground=>0.5, :rock=>0.5, :ghost=>0.5,
                  :steel=>0.0, :grass=>2.0, :fairy=>2.0},
    :ground   => {:flying=>0.0, :poison=>2.0, :rock=>2.0, :bug=>0.5,
                  :steel=>2.0, :fire=>2.0, :grass=>0.5, :electric=>2.0},
    :rock     => {:fighting=>0.5, :flying=>2.0, :ground=>0.5, :bug=>2.0,
                  :steel=>0.5, :fire=>2.0, :ice=>2.0},
    :bug      => {:fighting=>0.5, :flying=>0.5, :poison=>0.5, :ghost=>0.5,
                  :steel=>0.5, :fire=>0.5, :grass=>2.0, :psychic=>2.0,
                  :dark=>2.0, :fairy=>0.5},
    :ghost    => {:normal=>0.0, :ghost=>2.0, :psychic=>2.0, :dark=>0.5},
    :steel    => {:rock=>2.0, :steel=>0.5, :fire=>0.5, :water=>0.5,
                  :ice=>2.0, :fairy=>2.0},
    :fire     => {:rock=>0.5, :bug=>2.0, :steel=>2.0, :fire=>0.5,
                  :water=>0.5, :grass=>2.0, :ice=>2.0, :dragon=>0.5,
                  :fairy=>2.0},
    :water    => {:ground=>2.0, :rock=>2.0, :fire=>2.0, :water=>0.5,
                  :grass=>0.5, :dragon=>0.5},
    :grass    => {:flying=>0.5, :poison=>0.5, :ground=>2.0, :rock=>2.0,
                  :bug=>0.5, :steel=>0.5, :fire=>0.5, :water=>2.0,
                  :grass=>0.5, :dragon=>0.5},
    :electric => {:flying=>2.0, :ground=>0.0, :water=>2.0, :grass=>0.5,
                  :electric=>0.5, :dragon=>0.5},
    :psychic  => {:fighting=>2.0, :poison=>2.0, :steel=>0.5,
                  :psychic=>0.5, :dark=>0.0},
    :ice      => {:flying=>2.0, :ground=>2.0, :steel=>0.5, :fire=>0.5,
                  :water=>0.5, :grass=>2.0, :ice=>0.5, :dragon=>2.0},
    :dragon   => {:steel=>0.5, :dragon=>2.0, :fairy=>0.0},
    :dark     => {:fighting=>0.5, :ghost=>2.0, :psychic=>2.0,
                  :dark=>0.5, :fairy=>0.5},
    :fairy    => {:fighting=>2.0, :poison=>0.5, :steel=>0.5, :fire=>0.5,
                  :dragon=>2.0, :dark=>2.0}
  }

  def self.hidden_enemy_ids
    result = []
    if defined?(KGC::EnemyGuide::HIDDEN_ENEMY_LIST)
      result += KGC::EnemyGuide::HIDDEN_ENEMY_LIST
    end
    return result
  rescue
    return []
  end

  def self.enemy_ids
    result = []
    return result if $data_enemies == nil
    for id in 1...$data_enemies.size
      enemy = $data_enemies[id]
      next if enemy == nil || enemy.name.to_s.empty?
      next if hidden_enemy_ids.include?(id)
      next if enemy.note.to_s =~ /<enemy_book_hide>/i
      result << id
    end
    return result
  end

  def self.encountered?(enemy_id)
    if defined?(KGC::Commands) && KGC::Commands.respond_to?(:enemy_encountered?)
      return true if KGC::Commands.enemy_encountered?(enemy_id)
    end
    if $game_party != nil && $game_party.respond_to?(:monsters_encounter)
      count = $game_party.monsters_encounter[enemy_id]
      return true if count != nil && count.to_i > 0
    end
    return false
  rescue
    return false
  end

  def self.defeated?(enemy_id)
    if defined?(KGC::Commands) && KGC::Commands.respond_to?(:enemy_defeated?)
      return true if KGC::Commands.enemy_defeated?(enemy_id)
    end
    if $game_party != nil && $game_party.respond_to?(:monsters_defeated)
      return true if $game_party.monsters_defeated[enemy_id].to_i > 0
    end
    if $game_system != nil && $game_system.respond_to?(:defeat_count)
      return true if $game_system.defeat_count(enemy_id).to_i > 0
    end
    return false
  rescue
    return false
  end

  def self.encounter_count(enemy_id)
    value = 0
    if $game_party != nil && $game_party.respond_to?(:monsters_encounter)
      value = $game_party.monsters_encounter[enemy_id].to_i
    end
    value = 1 if value <= 0 && encountered?(enemy_id)
    return value
  rescue
    return encountered?(enemy_id) ? 1 : 0
  end

  def self.defeat_count(enemy_id)
    if $game_party != nil && $game_party.respond_to?(:monsters_defeated)
      value = $game_party.monsters_defeated[enemy_id].to_i
      return value if value > 0
    end
    if $game_system != nil && $game_system.respond_to?(:defeat_count)
      value = $game_system.defeat_count(enemy_id).to_i
      return value if value > 0
    end
    return defeated?(enemy_id) ? 1 : 0
  rescue
    return defeated?(enemy_id) ? 1 : 0
  end

  def self.types(enemy_id)
    if defined?(ElementalSettings::ENEMY_ELEMENT_TABLE)
      values = ElementalSettings::ENEMY_ELEMENT_TABLE[enemy_id]
      return values if values != nil
    end
    return [:normal, nil]
  rescue
    return [:normal, nil]
  end

  def self.type_text(enemy_id)
    values = types(enemy_id).compact
    names = values.collect { |type| TYPE_NAMES[type] || type.to_s }
    return names.empty? ? "一般" : names.join("／")
  end

  def self.type_chart
    if defined?(FS_ELEMENT_FINAL) &&
       FS_ELEMENT_FINAL.const_defined?(:CHART)
      return FS_ELEMENT_FINAL::CHART
    end
    return TYPE_CHART
  end

  def self.effectiveness(attack_type, enemy_id)
    value = 1.0
    for defend_type in types(enemy_id).compact
      table = type_chart[attack_type] || {}
      value *= (table[defend_type] || 1.0)
    end
    return value
  end

  def self.weaknesses(enemy_id)
    ATTACK_TYPES.find_all { |type| effectiveness(type, enemy_id) > 1.0 }
  end

  def self.resistances(enemy_id)
    ATTACK_TYPES.find_all { |type| effectiveness(type, enemy_id) < 1.0 }
  end

  def self.type_list_text(types)
    return "無" if types == nil || types.empty?
    return types.collect { |type| TYPE_NAMES[type] || type.to_s }.join("、")
  end

  def self.skill_ids(enemy)
    result = []
    return result if enemy == nil || !enemy.respond_to?(:actions)
    enemy.actions.each do |action|
      next if action == nil || action.kind != 1
      result << action.skill_id unless result.include?(action.skill_id)
    end
    return result
  end

  def self.drop_entries(enemy)
    return [] if enemy == nil
    result = [enemy.drop_item1, enemy.drop_item2]
    if $imported && $imported["ExtraDropItem"] && enemy.respond_to?(:extra_drop_items)
      result += enemy.extra_drop_items
    end
    return result.find_all { |drop| drop != nil && drop.kind.to_i > 0 }
  end

  def self.drop_object(drop)
    return nil if drop == nil
    case drop.kind
    when 1
      return $data_items[drop.item_id]
    when 2
      return $data_weapons[drop.weapon_id]
    when 3
      return $data_armors[drop.armor_id]
    end
    return nil
  end

  def self.drop_known?(enemy_id, index)
    if defined?(KGC::Commands) && KGC::Commands.respond_to?(:enemy_item_dropped?)
      return true if KGC::Commands.enemy_item_dropped?(enemy_id, index)
    end
    if $game_party != nil && $game_party.respond_to?(:scan_drops)
      return true if $game_party.scan_drops.include?(enemy_id)
    end
    return false
  rescue
    return false
  end

  def self.description(enemy)
    return "" if enemy == nil
    if enemy.respond_to?(:enemy_guide_description)
      text = enemy.enemy_guide_description.to_s
      return text unless text.empty?
    end
    if enemy.note.to_s =~ /<enemy_book_info>(.*?)<\/enemy_book_info>/im
      return $1.to_s.strip
    end
    return ""
  end
end

class Sprite_FSEnemyBookBattler < Sprite
  def initialize(viewport = nil)
    super(viewport)
    @enemy_id = 0
  end

  def enemy_id=(enemy_id)
    enemy_id = enemy_id.to_i
    return if @enemy_id == enemy_id
    @enemy_id = enemy_id
    refresh_bitmap
  end

  def refresh_bitmap
    self.bitmap = nil
    self.visible = false
    return if @enemy_id <= 0
    enemy = $data_enemies[@enemy_id]
    return if enemy == nil || enemy.battler_name.to_s.empty?
    bmp = Cache.battler(enemy.battler_name, enemy.battler_hue)
    self.bitmap = bmp
    max_w = 128.0
    max_h = 128.0
    scale = [max_w / bmp.width, max_h / bmp.height, 1.0].min
    self.zoom_x = scale
    self.zoom_y = scale
    self.ox = bmp.width / 2
    self.oy = bmp.height
    self.visible = true
  rescue
    self.bitmap = nil
    self.visible = false
  end

  def dispose
    self.bitmap = nil
    super unless disposed?
  end
end

class Window_FSEnemyBookList < Window_Selectable
  attr_reader :data

  def initialize
    super(0, 0, 180, 416)
    @data = FS_ENEMY_BOOK.enemy_ids
    @item_max = @data.size
    self.index = @item_max > 0 ? 0 : -1
    refresh
  end

  def refresh
    self.contents.dispose if self.contents && !self.contents.disposed?
    height_needed = [height - 32, [@item_max, 1].max * WLH].max
    self.contents = Bitmap.new(width - 32, height_needed)
    @data.each_with_index do |enemy_id, i|
      enemy = $data_enemies[enemy_id]
      known = FS_ENEMY_BOOK.encountered?(enemy_id)
      self.contents.font.color = known ? normal_color : disabled_color
      name = known ? enemy.name.to_s : "????"
      self.contents.draw_text(item_rect(i), sprintf("%03d %s", enemy_id, name))
    end
  end

  def enemy_id
    return nil if self.index == nil || self.index < 0
    return @data[self.index]
  end
end

class Window_FSEnemyBookInfo < Window_Base
  attr_reader :page

  def initialize
    super(180, 0, 364, 416)
    @enemy_id = nil
    @page = 0
  end

  def enemy_id=(enemy_id)
    @enemy_id = enemy_id
    @page = 0
    refresh
  end

  def next_page
    @page = (@page + 1) % FS_ENEMY_BOOK::PAGE_MAX
    refresh
  end

  def prev_page
    @page = (@page + FS_ENEMY_BOOK::PAGE_MAX - 1) % FS_ENEMY_BOOK::PAGE_MAX
    refresh
  end

  def refresh
    contents.clear
    return if @enemy_id == nil
    enemy = $data_enemies[@enemy_id]
    return if enemy == nil
    known = FS_ENEMY_BOOK.encountered?(@enemy_id)
    defeated = FS_ENEMY_BOOK.defeated?(@enemy_id)

    contents.font.size = 20
    contents.font.color = text_color(known ? 1 : 7)
    title = known ? enemy.name.to_s : "未知敵人"
    contents.draw_text(0, 0, contents.width, WLH, title)

    contents.font.size = 16
    contents.font.color = normal_color
    contents.draw_text(0, 24, contents.width, WLH,
      known ? FS_ENEMY_BOOK.type_text(@enemy_id) : "屬性：????")
    contents.draw_text(0, 48, contents.width, WLH,
      "Page #{@page + 1}/#{FS_ENEMY_BOOK::PAGE_MAX}", 2)

    unless known
      contents.font.color = disabled_color
      contents.draw_text(0, 104, contents.width, WLH,
        "尚未遭遇，資料無法解析。", 1)
      return
    end

    case @page
    when 0
      draw_overview(enemy, defeated)
    when 1
      draw_skills(enemy, defeated)
    when 2
      draw_affinities(enemy, defeated)
    when 3
      draw_records(enemy, defeated)
    end
  end

  def draw_overview(enemy, defeated)
    y = 82
    contents.draw_text(0, y, 170, WLH,
      "遭遇：#{FS_ENEMY_BOOK.encounter_count(@enemy_id)}")
    contents.draw_text(170, y, 150, WLH,
      "擊破：#{FS_ENEMY_BOOK.defeat_count(@enemy_id)}")
    y += 34
    values = [
      ["HP", enemy.maxhp], ["MP", enemy.maxmp],
      ["ATK", enemy.atk], ["DEF", enemy.def],
      ["SPI", enemy.spi], ["AGI", enemy.agi]
    ]
    values.each_with_index do |pair, i|
      x = (i % 2) * 150
      yy = y + (i / 2) * 24
      contents.font.color = defeated ? normal_color : disabled_color
      contents.draw_text(x, yy, 70, WLH, pair[0])
      contents.draw_text(x + 55, yy, 80, WLH,
        defeated ? pair[1].to_s : "???", 2)
    end
    contents.font.color = normal_color
    contents.draw_text(0, y + 84, contents.width, WLH,
      defeated ? "基準能力；實戰數值可能受等級／機制修正" :
                 "擊破後解鎖基準能力資料")
  end

  def draw_skills(enemy, defeated)
    y = 82
    unless defeated
      contents.font.color = disabled_color
      contents.draw_text(0, y, contents.width, WLH,
        "擊破後解鎖技能紀錄。", 1)
      return
    end
    ids = FS_ENEMY_BOOK.skill_ids(enemy)
    if ids.empty?
      contents.draw_text(0, y, contents.width, WLH, "無技能紀錄。", 1)
      return
    end
    ids[0, 9].each do |skill_id|
      skill = $data_skills[skill_id]
      next if skill == nil
      contents.font.color = normal_color
      contents.draw_text(0, y, contents.width, WLH,
        sprintf("%03d  %s", skill_id, skill.name))
      y += 30
    end
  end

  def draw_affinities(enemy, defeated)
    y = 82
    unless defeated
      contents.font.color = disabled_color
      contents.draw_text(0, y, contents.width, WLH,
        "擊破後解鎖屬性相性。", 1)
      return
    end
    weak = FS_ENEMY_BOOK.weaknesses(@enemy_id)
    resist = FS_ENEMY_BOOK.resistances(@enemy_id)
    contents.font.color = text_color(2)
    contents.draw_text(0, y, contents.width, WLH, "弱點")
    contents.font.color = normal_color
    contents.draw_text(16, y + 28, contents.width - 16, WLH,
      FS_ENEMY_BOOK.type_list_text(weak))
    contents.font.color = text_color(3)
    contents.draw_text(0, y + 72, contents.width, WLH, "抗性／無效")
    contents.font.color = normal_color
    contents.draw_text(16, y + 100, contents.width - 16, WLH,
      FS_ENEMY_BOOK.type_list_text(resist))
  end

  def draw_records(enemy, defeated)
    y = 82
    drops = FS_ENEMY_BOOK.drop_entries(enemy)
    contents.font.color = text_color(2)
    contents.draw_text(0, y, contents.width, WLH, "掉落紀錄")
    y += 28
    if drops.empty?
      contents.font.color = normal_color
      contents.draw_text(16, y, contents.width - 16, WLH, "無")
      y += 28
    else
      drops[0, 3].each_with_index do |drop, index|
        obj = FS_ENEMY_BOOK.drop_object(drop)
        known = FS_ENEMY_BOOK.drop_known?(@enemy_id, index)
        contents.font.color = known ? normal_color : disabled_color
        name = known && obj != nil ? obj.name.to_s : "????"
        contents.draw_text(16, y, contents.width - 16, WLH, name)
        y += 26
      end
    end
    contents.font.color = text_color(1)
    contents.draw_text(0, y + 4, contents.width, WLH, "觀測筆記")
    y += 32
    contents.font.size = 14
    contents.font.color = defeated ? normal_color : disabled_color
    text = defeated ? FS_ENEMY_BOOK.description(enemy) : "擊破後解鎖觀測筆記。"
    text = "尚無觀測筆記。" if text.to_s.empty?
    text.to_s.split(/[\r\n]+/).each do |line|
      contents.draw_text(8, y, contents.width - 8, 22, line.to_s)
      y += 22
      break if y > contents.height - 22
    end
    contents.font.size = 16
  end
end

class Scene_EnemyBook < Scene_Base
  def start
    super
    @list_window = Window_FSEnemyBookList.new
    @info_window = Window_FSEnemyBookInfo.new
    @battler_sprite = Sprite_FSEnemyBookBattler.new
    @battler_sprite.x = 485
    @battler_sprite.y = 188
    @battler_sprite.z = 300
    refresh_enemy
  end

  def terminate
    super
    @list_window.dispose if @list_window
    @info_window.dispose if @info_window
    @battler_sprite.dispose if @battler_sprite
  end

  def update
    super
    @list_window.update
    if @last_index != @list_window.index
      refresh_enemy
    end
    if Input.trigger?(Input::RIGHT)
      Sound.play_cursor
      @info_window.next_page
    elsif Input.trigger?(Input::LEFT)
      Sound.play_cursor
      @info_window.prev_page
    elsif Input.trigger?(Input::B)
      Sound.play_cancel
      if defined?(Scene_SoulBookSelect) && $game_temp != nil &&
         $game_temp.respond_to?(:fs_soulbook_from_ring) &&
         $game_temp.fs_soulbook_from_ring
        $scene = Scene_SoulBookSelect.new
      else
        $scene = Scene_Map.new
      end
    end
  end

  def refresh_enemy
    @last_index = @list_window.index
    enemy_id = @list_window.enemy_id
    @info_window.enemy_id = enemy_id
    @battler_sprite.enemy_id =
      (enemy_id != nil && FS_ENEMY_BOOK.encountered?(enemy_id)) ? enemy_id : 0
  end
end
