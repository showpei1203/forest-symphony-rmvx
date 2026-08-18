#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_EconomyDropSystem v1.1
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_EconomyDropSystem v1.1」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Troop、Game_Interpreter、FS_ECONOMY_DROP
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：SOUL_ARMOR_START、SOUL_COUNT、FRAGMENT_START、OVERRIDES、NOTE_TAG。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】登記 $imported：FS Economy Drop System；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
# 【呼叫方式／範例】<fs_fragment_drop:2,50,1>
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
# ■ FS_EconomyDropSystem v1.1
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8
#
# 【完整替換】
# 刪除「更多掉落物」與「Drop Options」，改用本頁。
# 放在 KGC_EnemyGuide、FS_SoulMark_Resonance_Expansion v2.1.0 之下，
# Main 之上。
#
# 【正式規則】
# - 可汲取魂刻的敵人：只掉落該魂刻的碎片 Item 600～665。
# - 初階／單階：70% 掉1枚。
# - 中階：必定1枚。
# - 最終階：必定1枚，另有50%再掉1枚。
# - 非魂刻敵人：保留資料庫原生 drop_item1／drop_item2。
# - 不再讀取舊 \drop[...] 或 <more items ...>。
#
# 敵人Note可覆寫：
#   <fs_fragment_drop:固定數,追加機率,追加數>
# 例：
#   <fs_fragment_drop:2,50,1>
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Economy Drop System"] = "1.1"

module FS_ECONOMY_DROP
  VERSION = "1.1"

  SOUL_ARMOR_START = 600
  SOUL_COUNT        = 66
  FRAGMENT_START    = 600

  # Enemy ID => [固定數, 追加機率%, 追加數]
  # Note設定優先於本表。
  OVERRIDES = {
  }

  NOTE_TAG = /<fs_fragment_drop\s*:\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*>/i

  def self.soul_armor_id(enemy_data)
    return 0 if enemy_data == nil
    if defined?(FS_SOULMARK_RESONANCE) &&
       FS_SOULMARK_RESONANCE.respond_to?(:enemy_soul_armor_id)
      return FS_SOULMARK_RESONANCE.enemy_soul_armor_id(enemy_data).to_i
    end
    if enemy_data.respond_to?(:note) &&
       enemy_data.note.to_s =~ /<\s*steal\s+A:(\d+)\s+\d+(?:[%％])?\s*>/i
      id = $1.to_i
      return id if id >= SOUL_ARMOR_START && id < SOUL_ARMOR_START + SOUL_COUNT
    end
    return 0
  end

  def self.soul_offset(armor_id)
    offset = armor_id.to_i - SOUL_ARMOR_START
    return -1 if offset < 0 || offset >= SOUL_COUNT
    return offset
  end

  def self.stage_info(enemy_id, armor_id)
    if defined?(FS_SOULMARK_RESONANCE) &&
       FS_SOULMARK_RESONANCE.respond_to?(:stage_info)
      return FS_SOULMARK_RESONANCE.stage_info(enemy_id.to_i, armor_id.to_i)
    end
    return [0, 1, armor_id.to_i]
  end

  def self.note_profile(enemy_data)
    return nil if enemy_data == nil || !enemy_data.respond_to?(:note)
    if enemy_data.note.to_s =~ NOTE_TAG
      return [$1.to_i, [$2.to_i, 100].min, $3.to_i]
    end
    return nil
  end

  def self.default_profile(enemy_id, armor_id)
    info = stage_info(enemy_id, armor_id)
    stage = info[0].to_i
    count = info[1].to_i

    # 單階與第一形態維持70%取得1枚。
    return [0, 70, 1] if count <= 1 || stage <= 0
    # 最終形態：固定1枚，50%追加1枚。
    return [1, 50, 1] if stage >= count - 1
    # 中間形態：固定1枚。
    return [1, 0, 0]
  end

  def self.profile(enemy_data)
    return nil if enemy_data == nil
    note = note_profile(enemy_data)
    return note if note != nil
    row = OVERRIDES[enemy_data.id.to_i]
    return row.clone if row.is_a?(Array)
    armor_id = soul_armor_id(enemy_data)
    return nil if armor_id <= 0
    return default_profile(enemy_data.id, armor_id)
  end

  def self.fragment_item(enemy_data)
    armor_id = soul_armor_id(enemy_data)
    offset = soul_offset(armor_id)
    return nil if offset < 0
    return $data_items[FRAGMENT_START + offset] rescue nil
  end

  def self.standard_drop_object(drop)
    return nil if drop == nil || drop.kind.to_i == 0
    return nil if drop.denominator.to_i <= 0
    return nil if rand(drop.denominator.to_i) != 0
    case drop.kind.to_i
    when 1 then return $data_items[drop.item_id]
    when 2 then return $data_weapons[drop.weapon_id]
    when 3 then return $data_armors[drop.armor_id]
    end
    return nil
  end

  def self.roll_fragment(enemy_data)
    item = fragment_item(enemy_data)
    return [] if item == nil
    row = profile(enemy_data)
    return [] if row == nil
    fixed = [row[0].to_i, 0].max
    chance = [[row[1].to_i, 0].max, 100].min
    bonus = [row[2].to_i, 0].max
    amount = fixed
    amount += bonus if bonus > 0 && rand(100) < chance
    result = []
    amount.times { result.push(item) }
    return result
  end

  def self.mark_fragment_discovered(enemy_data, fragment_item)
    return if enemy_data == nil || fragment_item == nil
    return unless defined?(KGC::Commands) &&
      KGC::Commands.respond_to?(:set_enemy_item_dropped)
    [enemy_data.drop_item1, enemy_data.drop_item2].each_with_index do |drop, index|
      next if drop == nil || drop.kind.to_i != 1
      next unless drop.item_id.to_i == fragment_item.id.to_i
      KGC::Commands.set_enemy_item_dropped(enemy_data.id, index)
    end
  end

  def self.append_friendly_drops(result, troop)
    return result if troop == nil || !troop.respond_to?(:friendlies)
    troop.friendlies.each do |member|
      next if member == nil || member.dead?
      drops = member.enemy.friendly_drops rescue []
      next unless drops.is_a?(Array)
      result.concat(drops.compact)
    end
    return result
  end
end

#==============================================================================
# ■ Game_Troop：唯一掉落入口
#==============================================================================
class Game_Troop < Game_Unit
  def make_drop_items
    result = []

    for enemy in dead_members
      next if enemy == nil || enemy.hidden
      enemy_data = enemy.enemy
      next if enemy_data == nil

      armor_id = FS_ECONOMY_DROP.soul_armor_id(enemy_data)
      if armor_id > 0
        # 魂刻敵人只使用統一碎片表，避免資料庫掉落與Note掉落重複。
        fragments = FS_ECONOMY_DROP.roll_fragment(enemy_data)
        result.concat(fragments)
        FS_ECONOMY_DROP.mark_fragment_discovered(enemy_data, fragments[0]) unless
          fragments.empty?
        next
      end

      # 人類、機器人、複製物等非魂刻敵人保留原生兩格掉落。
      [enemy.drop_item1, enemy.drop_item2].each_with_index do |drop, index|
        item = FS_ECONOMY_DROP.standard_drop_object(drop)
        next if item == nil
        result.push(item)
        if defined?(KGC::Commands) &&
           KGC::Commands.respond_to?(:set_enemy_item_dropped)
          KGC::Commands.set_enemy_item_dropped(enemy_data.id, index)
        end
      end
    end

    FS_ECONOMY_DROP.append_friendly_drops(result, self)
    return result
  end
end

#==============================================================================
# ■ Game_Interpreter：簡易查詢
#==============================================================================
class Game_Interpreter
  def fs_drop_profile(enemy_id)
    enemy = $data_enemies[enemy_id.to_i] rescue nil
    return nil if enemy == nil
    return FS_ECONOMY_DROP.profile(enemy)
  end
end
