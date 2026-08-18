#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_SoulTerminologyNormalization v1.0
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_SoulTerminologyNormalization v1.0」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Scene_Title、Game_Interpreter、FS_SOUL_TERMINOLOGY、FS_SOULMARK_RESONANCE
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：ITEM_RANGES、ARMOR_RANGES、WEAPON_RANGES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】含 3 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Soul Terminology Normalization；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_SoulTerminologyNormalization v1.0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8.1
#
# 將魂刻相關物件說明中的寶可夢進化階段名稱，統一改成專案譜系名。
# 例：
#   妙蛙種子系／妙蛙種子／妙蛙草／妙蛙花 → 草蛙
#
# 處理範圍：
#   Item  200～265  殘響
#   Item  600～665  碎片
#   Item  800～814  特別殘響與專屬材料
#   Armor 220～285  鳴刻冠
#   Armor 600～665  完整魂刻
#   Weapon 266～275 五名角色專屬殘響武器
#
# 只改description，不修改敵人名稱、資料庫ID、Note或戰鬥判定。
#
# 放置位置：
#   FS_EquipmentCombo_OpeningSkillFix v1.0之下，Main之前。
#==============================================================================
$imported = {} if $imported == nil
$imported["FS Soul Terminology Normalization"] = "1.0"

module FS_SOUL_TERMINOLOGY
  VERSION = "1.0"

  ITEM_RANGES = [200..265, 600..665, 800..814]
  ARMOR_RANGES = [220..285, 600..665]
  WEAPON_RANGES = [266..275]

  def self.base_names
    result = []
    return result unless defined?(FS_SOULMARK_RESONANCE)
    return result unless FS_SOULMARK_RESONANCE.const_defined?("SOUL_ARTS")
    FS_SOULMARK_RESONANCE::SOUL_ARTS.each do |row|
      result.push(row[:base].to_s)
    end
    return result
  end

  def self.build_replacements
    pairs = {}
    bases = base_names

    if defined?(FS_SOULMARK_RESONANCE) &&
       FS_SOULMARK_RESONANCE.const_defined?("SOUL_ARTS")
      FS_SOULMARK_RESONANCE::SOUL_ARTS.each do |row|
        base = row[:base].to_s
        species = row[:species].to_s
        next if base.empty?
        unless species.empty?
          pairs[species] = base
          root = species.sub(/系$/, "")
          pairs[root] = base unless root.empty?
        end
      end
    end

    if defined?(FS_ECONOMY_DROP) && $data_enemies != nil
      $data_enemies.each do |enemy|
        next if enemy == nil
        armor_id = FS_ECONOMY_DROP.soul_armor_id(enemy) rescue 0
        offset = armor_id.to_i - 600
        next if offset < 0 || offset >= bases.size
        base = bases[offset].to_s
        name = enemy.name.to_s
        next if base.empty? || name.empty?
        pairs[name] = base
        pairs[name + "系"] = base
      end
    end

    @replacement_pairs = pairs.keys.sort do |a, b|
      b.size == a.size ? (a <=> b) : (b.size <=> a.size)
    end.collect { |key| [key, pairs[key]] }
    return @replacement_pairs
  end

  def self.replacement_pairs
    return @replacement_pairs if @replacement_pairs != nil
    return build_replacements
  end

  def self.normalize_text(text)
    result = text.to_s.dup
    replacement_pairs.each do |pair|
      old_text = pair[0]
      new_text = pair[1]
      next if old_text.empty? || old_text == new_text
      result.gsub!(old_text, new_text)
    end
    return result
  end

  def self.normalize_object(object)
    return false if object == nil
    return false unless object.respond_to?(:description)
    original = object.description.to_s
    normalized = normalize_text(original)
    return false if normalized == original
    object.description = normalized
    return true
  end

  def self.apply_range(table, range)
    count = 0
    return count if table == nil
    range.each do |id|
      object = table[id] rescue nil
      count += 1 if normalize_object(object)
    end
    return count
  end

  def self.apply
    @replacement_pairs = nil
    build_replacements
    count = 0
    ITEM_RANGES.each { |range| count += apply_range($data_items, range) }
    ARMOR_RANGES.each { |range| count += apply_range($data_armors, range) }
    WEAPON_RANGES.each { |range| count += apply_range($data_weapons, range) }
    @last_change_count = count
    return count
  end

  def self.last_change_count
    return @last_change_count.to_i
  end

  def self.write_report
    apply
    file = File.open("FS_Soul_Terminology_Report.txt", "wb")
    file.write("FS Soul Terminology Normalization v#{VERSION}\r\n")
    file.write("Changed descriptions: #{last_change_count}\r\n")
    replacement_pairs.each do |pair|
      file.write("#{pair[0]} => #{pair[1]}\r\n")
    end
    file.close
    return true
  rescue
    return false
  end
end

# 魂刻資料重新套用時，立刻再統一描述。
if defined?(FS_SOULMARK_RESONANCE) &&
   FS_SOULMARK_RESONANCE.respond_to?(:apply)
  module FS_SOULMARK_RESONANCE
    class << self
      unless method_defined?(:fs_soul_term_apply_base)
        alias fs_soul_term_apply_base apply
      end

      def apply
        result = fs_soul_term_apply_base
        FS_SOUL_TERMINOLOGY.apply
        return result
      end
    end
  end
end

# 所有資料庫載入與MasterSetup完成後，再做一次最終統一。
class Scene_Title < Scene_Base
  unless method_defined?(:fs_soul_term_load_database_base)
    alias fs_soul_term_load_database_base load_database
  end

  def load_database
    fs_soul_term_load_database_base
    FS_SOUL_TERMINOLOGY.apply
  end

  if method_defined?(:load_bt_database)
    unless method_defined?(:fs_soul_term_load_bt_database_base)
      alias fs_soul_term_load_bt_database_base load_bt_database
    end

    def load_bt_database
      fs_soul_term_load_bt_database_base
      FS_SOUL_TERMINOLOGY.apply
    end
  end
end

class Game_Interpreter
  def fs_soul_terminology_refresh
    count = FS_SOUL_TERMINOLOGY.apply
    $game_message.texts.push("魂刻相關說明已統一，修正#{count}筆。") if
      $game_message != nil
    return count
  end

  def fs_soul_terminology_report
    result = FS_SOUL_TERMINOLOGY.write_report
    text = result ? "魂刻名稱統一報告已輸出。" : "魂刻名稱統一報告輸出失敗。"
    $game_message.texts.push(text) if $game_message != nil
    return result
  end
end
