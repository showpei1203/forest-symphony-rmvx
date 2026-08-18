#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：AutoSetup_10_RuntimeSupport
# 【用途】Setup Runtime Support Provider；提供裝備 Alias、Steal Skill、特殊 Armor Range 等執行期相容功能。
# 【主要機制】本專案 MasterSetup 會在後方覆寫／補齊正式資料；AutoSetup 各頁順序不可任意交換。
# 【主要影響】RPG::Armor、Scene_Title、Game_Actor、Scene_Map、FS_DB_RUNTIME_SUPPORT
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：STEAL_SKILL_ID、JOEY_ACTOR_ID、SPECIAL_ALIASES、HEADGEAR_ARMOR_RANGE、SPECIAL_ARMOR_RANGES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】設定常數最終由 FS_MasterSetup 15 注入；install_equip_aliases 仍於本頁載入時建立必要方法相容。
# 【呼叫方式／範例】本頁屬啟動時依載入順序自動建立／套用資料，不需要事件 Script Call。
# 【相關素材】本頁未發現可靜態確認的固定字串素材；仍可能透過資料庫、事件、變數或其他模組間接取得素材。
# 【Setup 分類】RUNTIME PROVIDER / SUPPORT
# 【英文說明中文化】本頁頂部已用繁體中文整理／翻譯原說明中與維護直接相關的用途、機制、設定、順序、呼叫與範例；下方原文保留作作者授權、完整細節與歷史查核依據。
# 【來源／授權】若下方有原作者署名、Credits、License 或網址，必須保留；本中文維護說明不取代原授權。
#------------------------------------------------------------------------------
# 維護規則：
# 1. 本說明必須位於腳本開頭；功能、設定、依賴或公開 API 改變時同步更新。
# 2. 範例只記錄原文件、既有事件或程式碼能證實的入口；沒有入口就明寫自動執行。
# 3. 原作者署名、授權與原始說明保留在下方；中文化不代表取得原作權。
# 4. Alias／Compatibility／Authority Chain 搬動前，先查 LoadOrder Guide／Authority Map。
#==============================================================================
#--------------------------------------------------
#==============================================================================

# ■ FS_DB_AutoSetup_10_RuntimeSupport v1.3.7

#------------------------------------------------------------------------------

# 放在 KGC Steal、YEM Equipment Overhaul、安全補丁等相關腳本之下，Main 之上。

#==============================================================================

$imported = {} if $imported == nil

$imported["FS DB AutoSetup Runtime Support"] = "1.3.7"



module FS_DB_RUNTIME_SUPPORT

  STEAL_SKILL_ID = 82

  JOEY_ACTOR_ID = 1

  SPECIAL_ALIASES = [:special, :name, :other]



  def self.install_equip_aliases

    return unless defined?(YEM)

    return unless defined?(YEM::EQUIP)

    return unless YEM::EQUIP.const_defined?("TYPE_RULES")

    rules = YEM::EQUIP::TYPE_RULES

    rules[:special] = ["特殊", 5, true, true] unless rules.has_key?(:special)

    rules[:other] = ["特殊", 5, true, true] unless rules.has_key?(:other)

  end

end

FS_DB_RUNTIME_SUPPORT.install_equip_aliases



#==============================================================================

# ■ YEM Equipment Overhaul：Armor 類型解析修正

#------------------------------------------------------------------------------

# 原碼在設定 @kind 後立刻 break，導致 @equip_type 的設定永遠不會執行。

# 此外「飾品」同時有 kind 4 與 6，直接取第一筆會受 Ruby 1.8 Hash 順序影響。

# 本版優先保留資料庫目前 kind；若不符合，再採第一個同名規則。

#==============================================================================

if defined?(YEM) && defined?(YEM::EQUIP) &&

   YEM::EQUIP.const_defined?("TYPE_RULES") &&

   defined?(RPG::Armor)



  class RPG::Armor < RPG::BaseItem

    def yem_cache_armour_eo

      rules = YEM::EQUIP::TYPE_RULES

      @equip_type = @kind



      # 先依目前 kind 取得顯示名稱。

      rules.each do |key, rule|

        next unless rule.is_a?(Array)

        next unless rule[1] == @kind

        @equip_type = rule[0].to_s.upcase

        break

      end



      self.note.to_s.split(/[\r\n]+/).each do |line|

        next unless line =~ YEM::REGEXP::BASEITEM::EQUIP_TYPE

        phrase = $1.to_s.strip



        matches = []

        rules.each do |key, rule|

          next unless rule.is_a?(Array)

          next unless rule[0].to_s.upcase == phrase.upcase

          matches.push([key, rule])

        end

        next if matches.empty?



        chosen = matches.find { |pair| pair[1][1] == @kind }

        chosen = matches[0] if chosen == nil

        @kind = chosen[1][1]

        @equip_type = chosen[1][0].to_s.upcase

      end

    end

  end

end



module FS_DB_RUNTIME_SUPPORT

  HEADGEAR_ARMOR_RANGE = (220..285)
  SPECIAL_ARMOR_RANGES = [(286..295), (600..665)]

  # Armor 220～285：正式的頭部裝備「鳴刻冠」。
  # Armor 286～295、600～665：特殊／魂刻欄。
  # 只校正 kind 與顯示分類，不改能力、名稱、Note 或 Combo。
  def self.normalize_special_armors
    return unless defined?($data_armors) && $data_armors.is_a?(Array)

    HEADGEAR_ARMOR_RANGE.each do |id|
      armor = $data_armors[id]
      next unless armor.is_a?(RPG::Armor)
      armor.kind = 1
      armor.equip_type = "頭部" if armor.respond_to?(:equip_type=)
      armor.yem_cache_armour_eo if armor.respond_to?(:yem_cache_armour_eo)
    end

    SPECIAL_ARMOR_RANGES.each do |range|
      range.each do |id|
        armor = $data_armors[id]
        next unless armor.is_a?(RPG::Armor)
        armor.kind = 5
        armor.equip_type = "特殊" if armor.respond_to?(:equip_type=)
        armor.yem_cache_armour_eo if armor.respond_to?(:yem_cache_armour_eo)
      end
    end
  end



  def self.finalize_database_compatibility

    install_equip_aliases

    normalize_special_armors

  end

end



# RuntimeSupport 位於 YEM 與其他資料庫快取腳本之下。

# 讓本方法在所有既有 load_database 鏈完成後最後執行。

class Scene_Title < Scene_Base

  unless method_defined?(:fs_db_runtime_support_load_database_v133)

    alias fs_db_runtime_support_load_database_v133 load_database

    def load_database

      fs_db_runtime_support_load_database_v133

      FS_DB_RUNTIME_SUPPORT.finalize_database_compatibility

    end

  end



  unless method_defined?(:fs_db_runtime_support_load_bt_database_v133)

    alias fs_db_runtime_support_load_bt_database_v133 load_bt_database

    def load_bt_database

      fs_db_runtime_support_load_bt_database_v133

      FS_DB_RUNTIME_SUPPORT.finalize_database_compatibility

    end

  end

end



class Game_Actor < Game_Battler

  unless method_defined?(:fs_db_runtime_setup)

    alias fs_db_runtime_setup setup

    def setup(actor_id)

      fs_db_runtime_setup(actor_id)

      learn_skill(FS_DB_RUNTIME_SUPPORT::STEAL_SKILL_ID) if actor_id == FS_DB_RUNTIME_SUPPORT::JOEY_ACTOR_ID

    end

  end



  def fs_special_equip_type

    FS_DB_RUNTIME_SUPPORT.install_equip_aliases

    if defined?(ALBERT_YEM_EQUIP_SAFE)

      return :special if ALBERT_YEM_EQUIP_SAFE.valid_type?(:special)

      return :name if ALBERT_YEM_EQUIP_SAFE.valid_type?(:name)

      return :other if ALBERT_YEM_EQUIP_SAFE.valid_type?(:other)

    end

    return :name

  end



  def fs_special_slot_count

    return 0 unless respond_to?(:equip_type)

    n = 0

    list = equip_type

    list = [] unless list.is_a?(Array)

    list.each { |type| n += 1 if FS_DB_RUNTIME_SUPPORT::SPECIAL_ALIASES.include?(type) }

    return n

  end



  def fs_set_special_slots(number)

    return unless respond_to?(:equip_type) && respond_to?(:equip_type=)

    target = [[number.to_i, 0].max, 3].min

    list = equip_type

    list = [] unless list.is_a?(Array)

    list = list.clone

    list.delete_if { |type| FS_DB_RUNTIME_SUPPORT::SPECIAL_ALIASES.include?(type) }

    special = fs_special_equip_type

    target.times { list.push(special) }

    self.equip_type = list

  end



  def fs_add_special_slot

    fs_set_special_slots(fs_special_slot_count + 1)

  end

end



class Scene_Map < Scene_Base

  unless method_defined?(:fs_db_runtime_scene_map_start)

    alias fs_db_runtime_scene_map_start start

    def start

      fs_db_runtime_scene_map_start

      actor = $game_actors[FS_DB_RUNTIME_SUPPORT::JOEY_ACTOR_ID] rescue nil

      skill = $data_skills[FS_DB_RUNTIME_SUPPORT::STEAL_SKILL_ID] rescue nil

      if actor != nil && skill != nil && !actor.skill_learn?(skill)

        actor.learn_skill(FS_DB_RUNTIME_SUPPORT::STEAL_SKILL_ID)

      end

    end

  end

end



