#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_11_FieldWeather v1.3
# 【用途】Field Weather Runtime Authority；管理戰場 Field Weather 狀態、倍率與演出連動。
# 【主要機制】本專案 MasterSetup 會在後方覆寫／補齊正式資料；AutoSetup 各頁順序不可任意交換。
# 【主要影響】Game_Temp、Game_Battler、Spriteset_Battle、FS_FIELD_WEATHER
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：WEATHER_IDS、CONTEXT_WEATHER、MIN_RATE、MAX_RATE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】主要常數由 FS_MasterSetup 15 經 18 Apply 注入；Runtime 方法與 Scene/Battle Hook 保留在此。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁直接引用：Iconset。刪除／改名素材前必須反查其他腳本與 Data／事件是否共用。
# 【Setup 分類】RUNTIME AUTHORITY / FIELD WEATHER
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
# ■ FS_DB_AutoSetup_11_FieldWeather v1.3
#------------------------------------------------------------------------------
# 【安裝位置】
# Shanghai Simple Script - Field Effects、所有傷害／屬性／戰鬥補丁之下，
# 並放在 Main 的正上方附近。本腳本必須晚於 09、10。
#
# 【設計】
# - 保留上海 Field Effects 的單一場域與中央 Icon 顯示。
# - 修正移除場域時 create_field_effect 對 nil 取 icon_index 的錯誤。
# - 天候 State 153～158 不加入每名 battler 的一般 State 陣列，避免全員
#   同吃能力倍率、HUD 重複及狀態機制誤判。
# - 加入來源追蹤與優先權。原始天候 priority 20，不會被普通天候 10 覆蓋。
# - 天候只修正正值傷害；治療與 KGC 比例傷害不受影響。
#
# 【State Note】
# <field_weather>
# <field_priority:10>
# <field_damage 13:+25>
# <field_target_type_damage 9,flying:-25>
#
# 【Skill／Item Note】
# <field effect: 153>
# <remove field effect>
# <field_context_weather>  # Skill 320，由使用者／祭壇核心決定 153～155
#==============================================================================
$imported = {} if $imported == nil
$imported["FS DB AutoSetup Field Weather"] = 1.3

class Game_Temp
  attr_accessor :fs_field_effect_source
end

module FS_FIELD_WEATHER
  WEATHER_IDS = [153,154,155,156,157,158]
  CONTEXT_WEATHER = {554=>153, 555=>154, 556=>155}
  MIN_RATE = 25
  MAX_RATE = 175

  def self.current_state
    return nil if $game_temp == nil
    return $game_temp.field_effect
  end

  def self.current_id
    state = current_state
    return state == nil ? 0 : state.id.to_i
  end

  def self.current_source
    return nil if $game_temp == nil
    return $game_temp.fs_field_effect_source
  end

  def self.weather_state?(state)
    return false if state == nil
    return WEATHER_IDS.include?(state.id.to_i) || state.note.to_s =~ /<field_weather>/i
  end

  def self.weather_id?(id)
    state = $data_states[id.to_i] rescue nil
    return weather_state?(state)
  end

  def self.field_data(state)
    return {:priority=>0, :damage=>{}, :target=>[]} if state == nil
    cache = state.instance_variable_get(:@fs_field_weather_data)
    return cache if cache.is_a?(Hash)
    data = {:priority=>0, :damage=>{}, :target=>[]}
    state.note.to_s.split(/[\r\n]+/).each do |line|
      case line
      when /<field_priority\s*:\s*(\d+)\s*>/i
        data[:priority] = $1.to_i
      when /<field_damage\s+(\d+)\s*:\s*([\+\-]?\d+)\s*>/i
        data[:damage][$1.to_i] = $2.to_i
      when /<field_target_type_damage\s+(\d+)\s*,\s*([a-z_]+)\s*:\s*([\+\-]?\d+)\s*>/i
        data[:target].push([$1.to_i, $2.to_s.downcase.to_sym, $3.to_i])
      end
    end
    state.instance_variable_set(:@fs_field_weather_data, data)
    return data
  end

  def self.priority(state)
    return field_data(state)[:priority].to_i
  end

  def self.set_field(state_or_id, source = nil, force = false)
    return false if $game_temp == nil
    state = state_or_id.is_a?(RPG::State) ? state_or_id : ($data_states[state_or_id.to_i] rescue nil)
    return false if state == nil
    old = current_state
    if old != nil && old.id == state.id
      $game_temp.fs_field_effect_source = source unless source == nil
      return true
    end
    return false if !force && old != nil && priority(old) > priority(state)
    $game_temp.field_effect = state
    $game_temp.fs_field_effect_source = source
    return true
  end

  def self.clear_field(force = false)
    return false if $game_temp == nil
    return false if !force && current_state != nil && priority(current_state) >= 20
    $game_temp.field_effect = nil
    $game_temp.fs_field_effect_source = nil
    return true
  end

  def self.source_alive?(source)
    return true if source == nil
    return false if source.respond_to?(:dead?) && source.dead?
    return false if source.respond_to?(:hidden) && source.hidden
    return true
  end

  def self.update_source
    clear_field(true) unless source_alive?(current_source)
  end

  def self.explicit_field_id(obj)
    return 0 if obj == nil
    return $1.to_i if obj.note.to_s =~ /<field[ _]effect\s*:\s*(\d+)\s*>/i
    return 0
  end

  def self.remove_field?(obj)
    return false if obj == nil
    return obj.note.to_s =~ /<remove[ _]field[ _]effect\s*>/i ? true : false
  end

  def self.context_weather_id(user)
    return 0 if user == nil || !user.respond_to?(:enemy_id)
    id = user.enemy_id.to_i
    return CONTEXT_WEATHER[id] if CONTEXT_WEATHER.has_key?(id)
    return 0 unless id == 510 && $game_troop != nil
    CONTEXT_WEATHER.keys.sort.each do |core_id|
      for member in ($game_troop.members || [])
        next if member == nil || member.enemy_id != core_id
        next if member.respond_to?(:dead?) && member.dead?
        return CONTEXT_WEATHER[core_id]
      end
    end
    return 0
  end

  def self.context_source(user, weather_id)
    return user if user == nil || !user.respond_to?(:enemy_id) || user.enemy_id.to_i != 510
    return user if $game_troop == nil
    core_id = CONTEXT_WEATHER.index(weather_id)
    return user if core_id == nil
    for member in ($game_troop.members || [])
      next if member == nil || member.enemy_id != core_id
      next if member.respond_to?(:dead?) && member.dead?
      return member
    end
    return user
  end

  def self.requested_field_id(user, obj)
    id = explicit_field_id(obj)
    return id if id > 0
    return context_weather_id(user) if obj != nil && obj.note.to_s =~ /<field_context_weather>/i
    return 0
  end

  def self.target_types(target)
    result = []
    [:primary_element, :secondary_element].each do |name|
      value = target.instance_variable_get(("@" + name.to_s).to_sym) rescue nil
      value = value.to_s.downcase.to_sym unless value == nil
      result.push(value) unless value == nil || result.include?(value)
    end
    return result
  end

  def self.element_delta(state, element_id, target)
    data = field_data(state)
    delta = data[:damage][element_id.to_i].to_i
    types = target_types(target)
    data[:target].each do |spec|
      delta += spec[2].to_i if spec[0].to_i == element_id.to_i && types.include?(spec[1])
    end
    return delta
  end

  def self.combined_delta(elements, target)
    state = current_state
    return 0 if state == nil || !weather_state?(state)
    list = (elements || []).compact.collect { |id| element_delta(state, id, target) }
    return 0 if list.empty?
    if list.all? { |n| n >= 0 }
      return list.max
    elsif list.all? { |n| n <= 0 }
      return list.min
    else
      return (list.inject(0) { |sum,n| sum+n }.to_f / list.size).round
    end
  end

  def self.apply_damage(target, elements, hp_damage, mp_damage)
    delta = combined_delta(elements, target)
    rate = [[100 + delta, MIN_RATE].max, MAX_RATE].min
    hp = hp_damage.to_i
    mp = mp_damage.to_i
    hp = (hp * rate / 100.0).round if hp > 0
    mp = (mp * rate / 100.0).round if mp > 0
    return [hp, mp]
  end
end

class Game_Battler
  unless method_defined?(:fs_field_weather_states)
    alias fs_field_weather_states states
    def states
      result = fs_field_weather_states
      field = FS_FIELD_WEATHER.current_state
      if field != nil && FS_FIELD_WEATHER.weather_state?(field)
        result = result.clone
        result.delete(field)
      end
      return result
    end
  end

  unless method_defined?(:fs_field_weather_make_attack_damage_value)
    alias fs_field_weather_make_attack_damage_value make_attack_damage_value
    def make_attack_damage_value(attacker)
      fs_field_weather_make_attack_damage_value(attacker)
      elements = attacker.respond_to?(:element_set) ? attacker.element_set : []
      values = FS_FIELD_WEATHER.apply_damage(self, elements, @hp_damage, @mp_damage)
      @hp_damage, @mp_damage = values[0], values[1]
    end
  end

  unless method_defined?(:fs_field_weather_make_obj_damage_value)
    alias fs_field_weather_make_obj_damage_value make_obj_damage_value
    def make_obj_damage_value(user, obj)
      fs_field_weather_make_obj_damage_value(user, obj)
      return if obj != nil && obj.respond_to?(:rate_damage?) && obj.rate_damage?
      elements = obj != nil && obj.respond_to?(:element_set) ? obj.element_set : []
      values = FS_FIELD_WEATHER.apply_damage(self, elements, @hp_damage, @mp_damage)
      @hp_damage, @mp_damage = values[0], values[1]
    end
  end

  unless method_defined?(:fs_field_weather_skill_effect)
    alias fs_field_weather_skill_effect skill_effect
    def skill_effect(user, skill)
      old_state = FS_FIELD_WEATHER.current_state
      old_source = FS_FIELD_WEATHER.current_source
      fs_field_weather_skill_effect(user, skill)
      return unless $scene.is_a?(Scene_Battle)
      if FS_FIELD_WEATHER.remove_field?(skill)
        FS_FIELD_WEATHER.clear_field(false)
        return
      end
      requested = FS_FIELD_WEATHER.requested_field_id(user, skill)
      if requested > 0
        $game_temp.field_effect = old_state
        $game_temp.fs_field_effect_source = old_source
        source = FS_FIELD_WEATHER.context_source(user, requested)
        FS_FIELD_WEATHER.set_field(requested, source, false)
      end
    end
  end

  unless method_defined?(:fs_field_weather_item_effect)
    alias fs_field_weather_item_effect item_effect
    def item_effect(user, item)
      old_state = FS_FIELD_WEATHER.current_state
      old_source = FS_FIELD_WEATHER.current_source
      fs_field_weather_item_effect(user, item)
      return unless $scene.is_a?(Scene_Battle)
      if FS_FIELD_WEATHER.remove_field?(item)
        FS_FIELD_WEATHER.clear_field(false)
        return
      end
      requested = FS_FIELD_WEATHER.requested_field_id(user, item)
      if requested > 0
        $game_temp.field_effect = old_state
        $game_temp.fs_field_effect_source = old_source
        source = FS_FIELD_WEATHER.context_source(user, requested)
        FS_FIELD_WEATHER.set_field(requested, source, false)
      end
    end
  end

  unless method_defined?(:fs_field_weather_skill_can_use)
    alias fs_field_weather_skill_can_use skill_can_use?
    def skill_can_use?(skill)
      result = fs_field_weather_skill_can_use(skill)
      return false unless result
      return result if $game_temp == nil || !$game_temp.in_battle
      requested = FS_FIELD_WEATHER.requested_field_id(self, skill)
      return result unless requested > 0 && FS_FIELD_WEATHER.weather_id?(requested)
      FS_FIELD_WEATHER.update_source
      current = FS_FIELD_WEATHER.current_state
      return false if current != nil && current.id.to_i == requested
      return false if current != nil && FS_FIELD_WEATHER.priority(current) > FS_FIELD_WEATHER.priority($data_states[requested])
      return result
    end
  end
end

class Spriteset_Battle
  unless method_defined?(:fs_field_weather_initialize)
    alias fs_field_weather_initialize initialize
    def initialize
      $game_temp.fs_field_effect_source = nil if $game_temp != nil
      fs_field_weather_initialize
    end
  end

  unless method_defined?(:fs_field_weather_dispose)
    alias fs_field_weather_dispose dispose
    def dispose
      fs_field_weather_dispose
      $game_temp.fs_field_effect_source = nil if $game_temp != nil
    end
  end

  def update_field_effects
    FS_FIELD_WEATHER.update_source if defined?(FS_FIELD_WEATHER)
    current = ($game_temp == nil ? nil : $game_temp.field_effect)
    if @field_effect != current
      current == nil ? dispose_field_effect : create_field_effect
    end
    pulse_field_effect if @field_effect != nil && @field_effect_sprite != nil && @pulse_effect_sprite != nil
  end

  def create_field_effect
    dispose_field_effect
    current = ($game_temp == nil ? nil : $game_temp.field_effect)
    return if current == nil
    battle_engine_melody_update_states if respond_to?(:battle_engine_melody_update_states)
    @field_effect = current
    bitmap = Cache.system("Iconset")
    icon_index = current.icon_index.to_i
    rect = Rect.new(icon_index % 16 * 24, icon_index / 16 * 24, 24, 24)
    opacity = SSS::FIELD_EFFECT_OPACITY
    @field_effect_sprite = Sprite_Base.new(@viewport3)
    @field_effect_sprite.bitmap = Bitmap.new(24,24)
    @field_effect_sprite.bitmap.blt(0,0,bitmap,rect,opacity)
    @field_effect_sprite.ox = 12; @field_effect_sprite.oy = 12
    @field_effect_sprite.x = SSS::FIELD_EFFECT_X; @field_effect_sprite.y = SSS::FIELD_EFFECT_Y
    @field_effect_sprite.zoom_x = 2.0; @field_effect_sprite.zoom_y = 2.0
    @pulse_effect_sprite = Sprite_Base.new(@viewport3)
    @pulse_effect_sprite.bitmap = Bitmap.new(24,24)
    @pulse_effect_sprite.bitmap.blt(0,0,bitmap,rect,opacity)
    @pulse_effect_sprite.ox = 12; @pulse_effect_sprite.oy = 12
    @pulse_effect_sprite.x = SSS::FIELD_EFFECT_X; @pulse_effect_sprite.y = SSS::FIELD_EFFECT_Y
    @pulse_effect_sprite.z = @field_effect_sprite.z + 1
    @pulse_effect_sprite.zoom_x = 2.0; @pulse_effect_sprite.zoom_y = 2.0
  end

  def fs_field_weather_dispose_sprite(sprite)
    return if sprite == nil
    bitmap = sprite.bitmap rescue nil
    sprite.dispose unless sprite.disposed?
    bitmap.dispose if bitmap != nil && !bitmap.disposed?
  end

  def dispose_field_effect
    fs_field_weather_dispose_sprite(@field_effect_sprite)
    fs_field_weather_dispose_sprite(@pulse_effect_sprite)
    @field_effect_sprite = nil
    @pulse_effect_sprite = nil
    @field_effect = ($game_temp == nil ? nil : $game_temp.field_effect)
    battle_engine_melody_update_states if respond_to?(:battle_engine_melody_update_states)
  end

  def pulse_field_effect
    return if @field_effect_sprite == nil || @pulse_effect_sprite == nil
    @pulse_effect_sprite.zoom_x += 0.1
    @pulse_effect_sprite.zoom_y += 0.1
    @pulse_effect_sprite.opacity -= SSS::FIELD_EFFECT_VANISH
    if @pulse_effect_sprite.zoom_x > 8.0
      @pulse_effect_sprite.opacity = SSS::FIELD_EFFECT_OPACITY
      @pulse_effect_sprite.zoom_x = 2.0
      @pulse_effect_sprite.zoom_y = 2.0
    end
    @field_effect_sprite.update
    @pulse_effect_sprite.update
  end
end
