#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SoulRepeatRecipe v1.1.2
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_SoulRepeatRecipe v1.1.2」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】RPG::Enemy、Game_Party、Game_Temp、Game_Interpreter、Scene_Battle、Albert_SoulRepeatRecipe
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SOUL_ARMOR_START、SOUL_COUNT、ECHO_ITEM_START、FRAGMENT_START、HEADGEAR_START、JOEY_ACTOR_ID、SHOW_RECIPE_MESSAGE、RECIPE_MESSAGE。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意；登記 $imported：AlbertSoulRepeatRecipe；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# -*- coding: utf-8 -*-
#==============================================================================
# ■ Albert_SoulRepeatRecipe v1.1.2-FS
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8
#
# 【完整替換】
# 刪除舊的 SoulRepeatRecipe v1.0，改用本頁。
# 直接取代原 SoulRepeatRecipe 分頁，保持原載入位置：
# KGC Steal、DynamicCaptureRate、魔劍工舖合成系統之下，
# FS_SoulMark_Resonance_Expansion v2.1.0 之前，Main 之上。
# 對 FS_SOULMARK_RESONANCE 的查詢只在戰鬥執行時發生，因此可安全後載入。
#
# 【正式規則】
# 1. 第一次成功汲取：取得完整魂刻 Armor 600～665。
# 2. 第二次起：改為取得對應殘響 Item 200～265。
# 3. 第一次成功時額外取得對應碎片×2。
# 4. 已完成《借來的名字》時，第一次再多取得碎片×1。
# 5. 重複汲取依形態額外取得碎片：初階1／中階2／最終3。
# 6. 首次成功自動解鎖對應 Armor 220～285「鳴刻冠」配方。
# 7. 一般首次汲取只放入背包，不變更玩家目前裝備。
# 8. 僅序章劇情可在戰鬥前呼叫 fs_auto_equip_next_soul，
#    讓「下一次首次汲取」的一枚完整魂刻自動裝入喬伊特殊欄。
# 9. 不處理舊存檔反查，不以目前持有物補登紀錄。
#
# 本腳本是唯一修改 Scene_Battle#display_steal_item 的經濟腳本。
#==============================================================================

$imported = {} if $imported == nil
$imported["AlbertSoulRepeatRecipe"] = "1.1.2-FS"

module Albert_SoulRepeatRecipe
  VERSION = "1.1.2-FS"

  SOUL_ARMOR_START = 600
  SOUL_COUNT        = 66
  ECHO_ITEM_START   = 200
  FRAGMENT_START    = 600
  HEADGEAR_START    = 220


  JOEY_ACTOR_ID = 1

  # 自動裝備不是全域規則。
  # 只有事件先呼叫 fs_auto_equip_next_soul 時，下一次「首次汲取」才會執行。
  def self.request_auto_equip_next_soul
    return false if $game_temp == nil
    $game_temp.albert_auto_equip_next_soul = true
    return true
  end

  def self.cancel_auto_equip_next_soul
    return false if $game_temp == nil
    $game_temp.albert_auto_equip_next_soul = false
    return true
  end

  def self.consume_auto_equip_next_soul
    return false if $game_temp == nil
    requested = ($game_temp.albert_auto_equip_next_soul == true)
    $game_temp.albert_auto_equip_next_soul = false
    return requested
  end

  # 找出 YEM Equipment Overhaul 中 kind=5 的特殊裝備欄。
  # 不硬寫 slot 7，避免角色日後調整裝備欄順序時把魂刻塞進奇怪位置。
  def self.special_equip_slot(actor)
    return -1 if actor == nil || !actor.respond_to?(:equip_type)
    types = actor.equip_type
    return -1 unless types.is_a?(Array)
    types.each_with_index do |type, index|
      if defined?(YEM) && defined?(YEM::EQUIP) &&
         YEM::EQUIP.const_defined?("TYPE_RULES")
        rule = YEM::EQUIP::TYPE_RULES[type]
        return index + 1 if rule.is_a?(Array) && rule[1].to_i == 5
      end
      return index + 1 if [:special, :name, :other].include?(type)
    end
    return -1
  end

  def self.auto_equip_first_soul(armor_id)
    # 一旦遇到下一次首次汲取，就消耗一次性請求。
    # 即使欄位設定異常，也不把請求遺留到後續其他魂刻，避免突然換裝。
    return false unless consume_auto_equip_next_soul
    return false if $game_actors == nil || $game_party == nil
    actor = $game_actors[JOEY_ACTOR_ID] rescue nil
    armor = $data_armors[armor_id.to_i] rescue nil
    return false if actor == nil || armor == nil
    slot = special_equip_slot(actor)
    return false if slot < 1
    return false unless actor.respond_to?(:change_equip)
    # KGC Steal 原流程已先把魂刻放入隊伍，因此這裡使用正式 change_equip。
    # 此行只會在序章事件明確要求時執行。
    actor.change_equip(slot, armor)
    equipped = actor.equips[slot] rescue nil
    return equipped == armor
  end

  SHOW_RECIPE_MESSAGE = true
  RECIPE_MESSAGE      = "解鎖合成配方：%s"
  RECIPE_MESSAGE_WAIT = 60

  REPEAT_TAG = /<capture_repeat\s+([IWA])\s*:\s*(\d+)\s*>/i
  RECIPE_TAG = /<capture_recipe\s+([IWA])\s*:\s*(\d+)\s*>/i

  def self.kind_from_letter(letter)
    case letter.to_s.upcase
    when "I"
      return RPG::Enemy::StealObject::KIND_ITEM
    when "W"
      return RPG::Enemy::StealObject::KIND_WEAPON
    when "A"
      return RPG::Enemy::StealObject::KIND_ARMOR
    end
    return 0
  end

  def self.synthesis_kind_from_letter(letter)
    case letter.to_s.upcase
    when "I" then return 0
    when "W" then return 1
    when "A" then return 2
    end
    return -1
  end

  def self.steal_database_object(kind, id)
    id = id.to_i
    return nil if id <= 0
    case kind
    when RPG::Enemy::StealObject::KIND_ITEM
      return $data_items[id]
    when RPG::Enemy::StealObject::KIND_WEAPON
      return $data_weapons[id]
    when RPG::Enemy::StealObject::KIND_ARMOR
      return $data_armors[id]
    end
    return nil
  end

  def self.synthesis_database_object(kind, id)
    id = id.to_i
    return nil if id <= 0
    case kind
    when 0 then return $data_items[id]
    when 1 then return $data_weapons[id]
    when 2 then return $data_armors[id]
    end
    return nil
  end

  def self.build_steal_object(kind, id)
    return nil if steal_database_object(kind, id) == nil
    sobj = RPG::Enemy::StealObject.new
    sobj.kind = kind
    case kind
    when RPG::Enemy::StealObject::KIND_ITEM
      sobj.item_id = id.to_i
    when RPG::Enemy::StealObject::KIND_WEAPON
      sobj.weapon_id = id.to_i
    when RPG::Enemy::StealObject::KIND_ARMOR
      sobj.armor_id = id.to_i
    else
      return nil
    end
    return sobj
  end

  def self.capture_soul?(sobj)
    return false if sobj == nil
    if defined?(Albert_CaptureRate) &&
       Albert_CaptureRate.respond_to?(:capture_object?)
      return Albert_CaptureRate.capture_object?(sobj)
    end
    return false unless sobj.kind == RPG::Enemy::StealObject::KIND_ARMOR
    id = sobj.armor_id.to_i
    return id >= SOUL_ARMOR_START && id < SOUL_ARMOR_START + SOUL_COUNT
  end

  def self.soul_offset(armor_id)
    offset = armor_id.to_i - SOUL_ARMOR_START
    return -1 if offset < 0 || offset >= SOUL_COUNT
    return offset
  end

  def self.default_repeat_data(armor_id)
    offset = soul_offset(armor_id)
    return nil if offset < 0
    return [RPG::Enemy::StealObject::KIND_ITEM, ECHO_ITEM_START + offset]
  end

  def self.headgear_recipe(armor_id)
    offset = soul_offset(armor_id)
    return nil if offset < 0
    return [2, HEADGEAR_START + offset]
  end

  def self.fragment_amount(enemy_id, armor_id, first_capture)
    if first_capture
      amount = 2
      if defined?(FS_ECONOMY) && FS_ECONOMY.respond_to?(:unlocked?) &&
         FS_ECONOMY.unlocked?(:new_name_blessing)
        amount += 1
      end
      return amount
    end

    if defined?(FS_SOULMARK_RESONANCE) &&
       FS_SOULMARK_RESONANCE.respond_to?(:stage_info)
      info = FS_SOULMARK_RESONANCE.stage_info(enemy_id.to_i, armor_id.to_i)
      stage = info[0].to_i
      count = info[1].to_i
      return 1 if count <= 1 || stage <= 0
      return 3 if stage >= count - 1
      return 2
    end
    return 1
  end
end

#==============================================================================
# ■ RPG::Enemy
#==============================================================================
class RPG::Enemy
  def albert_capture_repeat_data
    return @albert_capture_repeat_data if @albert_capture_repeat_loaded
    @albert_capture_repeat_loaded = true
    @albert_capture_repeat_data = nil
    self.note.to_s.each_line do |line|
      next unless line =~ Albert_SoulRepeatRecipe::REPEAT_TAG
      kind = Albert_SoulRepeatRecipe.kind_from_letter($1)
      id = $2.to_i
      next if kind <= 0 || id <= 0
      @albert_capture_repeat_data = [kind, id]
      break
    end
    return @albert_capture_repeat_data
  end

  def albert_capture_recipe_data
    return @albert_capture_recipe_data if @albert_capture_recipe_loaded
    @albert_capture_recipe_loaded = true
    @albert_capture_recipe_data = []
    self.note.to_s.each_line do |line|
      next unless line =~ Albert_SoulRepeatRecipe::RECIPE_TAG
      kind = Albert_SoulRepeatRecipe.synthesis_kind_from_letter($1)
      id = $2.to_i
      next if kind < 0 || id <= 0

      # 舊制 Weapon 200～265 直接正規化為 Armor 220～285。
      if kind == 1 && id >= 200 && id < 266
        kind = 2
        id = 220 + (id - 200)
      end

      data = [kind, id]
      @albert_capture_recipe_data.push(data) unless
        @albert_capture_recipe_data.include?(data)
    end
    return @albert_capture_recipe_data
  end
end

#==============================================================================
# ■ Game_Party
#==============================================================================
class Game_Party < Game_Unit
  def albert_captured_soul_armors
    @albert_captured_soul_armors = {} if @albert_captured_soul_armors == nil
    return @albert_captured_soul_armors
  end

  # 新版不從持有物或裝備反查。新遊戲的紀錄只由成功汲取建立。
  def albert_soul_captured?(armor_id)
    armor_id = armor_id.to_i
    return false if armor_id <= 0
    return albert_captured_soul_armors[armor_id] == true
  end

  def albert_mark_soul_captured(armor_id)
    armor_id = armor_id.to_i
    return false if armor_id <= 0
    albert_captured_soul_armors[armor_id] = true
    return true
  end

  def albert_unlock_sword_recipe(kind, id)
    kind = kind.to_i
    id = id.to_i
    return nil if kind < 0 || kind > 2 || id <= 0
    return nil unless respond_to?(:sword_synthesize)
    return nil unless defined?(Sword) && Sword.const_defined?(:Sword4_Synthesize)

    recipe_table = Sword::Sword4_Synthesize
    return nil if recipe_table == nil || recipe_table[kind] == nil
    return nil if recipe_table[kind][id] == nil

    learned = sword_synthesize
    return nil if learned == nil
    learned[kind] = [] if learned[kind] == nil
    learned[kind].push(nil) while learned[kind].size <= id
    return nil if learned[kind][id] == true

    learned[kind][id] = true
    return Albert_SoulRepeatRecipe.synthesis_database_object(kind, id)
  end
end

#==============================================================================
# ■ Game_Temp
#------------------------------------------------------------------------------
# 序章專用的一次性自動裝備請求，不寫入存檔。
#==============================================================================
class Game_Temp
  attr_accessor :albert_auto_equip_next_soul
end

#==============================================================================
# ■ Game_Interpreter
#==============================================================================
class Game_Interpreter
  # 在序章強制汲取戰鬥開始前呼叫。
  # 只影響下一次「首次汲取」，之後立刻恢復一般規則。
  def fs_auto_equip_next_soul
    return Albert_SoulRepeatRecipe.request_auto_equip_next_soul
  end

  # 戰鬥取消或劇情分支中止時可主動清除。
  def fs_cancel_auto_equip_next_soul
    return Albert_SoulRepeatRecipe.cancel_auto_equip_next_soul
  end
end

#==============================================================================
# ■ Scene_Battle
#==============================================================================
class Scene_Battle < Scene_Base
  unless method_defined?(:albert_srr_fs_display_steal_item)
    alias albert_srr_fs_display_steal_item display_steal_item
  end

  def albert_srr_show_recipe_unlock(items)
    return unless Albert_SoulRepeatRecipe::SHOW_RECIPE_MESSAGE
    return if items == nil || items.empty?
    names = []
    items.each do |item|
      next if item == nil
      names.push(item.name.to_s)
    end
    return if names.empty?
    text = sprintf(Albert_SoulRepeatRecipe::RECIPE_MESSAGE, names.join("、"))
    if defined?(KGC::Steal::USING_SIDEVIEW) &&
       KGC::Steal::USING_SIDEVIEW && defined?(Steal_Window)
      @steal_window = Steal_Window.new(text)
      @steal_window.visible = true
      wait(Albert_SoulRepeatRecipe::RECIPE_MESSAGE_WAIT)
      @steal_window.dispose
    elsif @message_window != nil &&
          @message_window.respond_to?(:add_instant_text)
      @message_window.add_instant_text(text)
      wait(24)
    end
  end

  def albert_srr_show_bonus(item, amount, first_capture)
    return if item == nil || amount.to_i <= 0
    return if @message_window == nil ||
              !@message_window.respond_to?(:add_instant_text)
    prefix = first_capture ? "首次汲取補給：" : "重複汲取補給："
    @message_window.add_instant_text(
      prefix + item.name.to_s + "×" + amount.to_i.to_s
    )
    wait(20)
  end

  def albert_srr_show_auto_equip(item)
    return if item == nil
    text = "已自動裝備：" + item.name.to_s
    if defined?(KGC::Steal::USING_SIDEVIEW) &&
       KGC::Steal::USING_SIDEVIEW && defined?(Steal_Window)
      @steal_window = Steal_Window.new(text)
      @steal_window.visible = true
      wait(40)
      @steal_window.dispose
    elsif @message_window != nil &&
          @message_window.respond_to?(:add_instant_text)
      @message_window.add_instant_text(text)
      wait(20)
    end
  end

  def display_steal_item(target, obj)
    original_sobj = target.respond_to?(:stolen_object) ? target.stolen_object : nil

    unless target.is_a?(Game_Enemy) &&
           Albert_SoulRepeatRecipe.capture_soul?(original_sobj)
      albert_srr_fs_display_steal_item(target, obj)
      return
    end

    armor_id = original_sobj.armor_id.to_i
    offset = Albert_SoulRepeatRecipe.soul_offset(armor_id)
    if offset < 0
      albert_srr_fs_display_steal_item(target, obj)
      return
    end

    first_capture = !$game_party.albert_soul_captured?(armor_id)
    actual_sobj = original_sobj

    unless first_capture
      repeat_data = target.enemy.albert_capture_repeat_data
      repeat_data = Albert_SoulRepeatRecipe.default_repeat_data(armor_id) if
        repeat_data == nil
      if repeat_data != nil
        replacement = Albert_SoulRepeatRecipe.build_steal_object(
          repeat_data[0], repeat_data[1]
        )
        actual_sobj = replacement if replacement != nil
      end
    end

    begin
      target.stolen_object = actual_sobj
      albert_srr_fs_display_steal_item(target, obj)
    ensure
      target.stolen_object = original_sobj
    end

    if first_capture
      soul_armor = $data_armors[armor_id] rescue nil
      equipped = Albert_SoulRepeatRecipe.auto_equip_first_soul(armor_id)
      albert_srr_show_auto_equip(soul_armor) if equipped
    end

    $game_party.albert_mark_soul_captured(armor_id)

    # 固定解鎖對應鳴刻冠，再處理敵人Note中的額外配方。
    recipes = []
    base_recipe = Albert_SoulRepeatRecipe.headgear_recipe(armor_id)
    recipes.push(base_recipe) if base_recipe != nil
    target.enemy.albert_capture_recipe_data.each do |recipe|
      recipes.push(recipe) unless recipes.include?(recipe)
    end

    unlocked_items = []
    recipes.each do |recipe|
      item = $game_party.albert_unlock_sword_recipe(recipe[0], recipe[1])
      unlocked_items.push(item) if item != nil
    end

    fragment_id = Albert_SoulRepeatRecipe::FRAGMENT_START + offset
    fragment = $data_items[fragment_id] rescue nil
    amount = Albert_SoulRepeatRecipe.fragment_amount(
      target.enemy_id, armor_id, first_capture
    )
    if fragment != nil && amount > 0
      $game_party.gain_item(fragment, amount)
      albert_srr_show_bonus(fragment, amount, first_capture)
    end

    albert_srr_show_recipe_unlock(unlocked_items)
  end
end
