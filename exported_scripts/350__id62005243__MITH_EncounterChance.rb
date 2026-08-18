#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：MITH_EncounterChance
# 【用途】保留的 Runtime 元件「MITH_EncounterChance」。
# 【主要機制】主要定義／擴充 Game_Player、RPG::Troop、Scene_Title；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Game_Player、RPG::Troop、Scene_Title
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 1 個 alias／方法包裝，載入順序具有語意。
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
# Custom Encounter Chance by Mithran
# This simple little script searches for a string tag in the name of the troop
# <n> where n is the encounter rate of the troop.  The default encounter rate is
# 10.  This script takes all the values of every troop in a map list and adds
# that amount of troops to the encounter list, then picks one at random.
# The script removes the string tag at title, in case you want to use the troop
# name for other purposes.
#
# EXAMPLE:
# If you had three troops on your map encounter list,
# Slime <20>
# Slime*2
# Gold Slime <1>
# You would have a 20/31 chance to encounter Slime, a 10/31 chance to encounter
# Slime*2 and a 1/31 chance to encounter Gold Slime.
#
# Place above all other custom scripts and below default scripts
#
# Encounter rates can be changed through the script command in events by using
# $data_troops[n].custom_encounter_chance = x
# Where n is the troop number and x is the encounter rate.
# The change is permanent until the game is exited (it does not save in savefile)
#
# An easier way to set different rates for different maps would be to copy the
# troops and change the name.


class Game_Player < Game_Character
  def make_encounter_troop_id
    encounter_list = $game_map.encounter_list.clone
    for area in $data_areas.values
      encounter_list += area.encounter_list if in_area?(area)
    end
    if encounter_list.empty?
      make_encounter_count
      return 0
    end
    real_encounter_list = []
    encounter_list.each { |value|
      chance = $data_troops[value].custom_encounter_chance
#      print chance.to_s + " " + $data_troops[value].name #~ Debugging
      for i in 1..chance
        real_encounter_list.push(value)
      end
    }
    return real_encounter_list[rand(real_encounter_list.size)]
  end
end

class RPG::Troop
  attr_accessor :custom_encounter_chance
  def custom_encounter_chance
    make_encounter_cache if @custom_encounter_chance == nil
    return @custom_encounter_chance
  end
  def make_encounter_cache
    @custom_encounter_chance = 10
    @name.gsub!(/<(\d+)>/, "")
    @custom_encounter_chance = $1.to_i unless $1 == nil
  end
end

class Scene_Title < Scene_Base
  alias load_database_mithran_encounterchance load_database
  def load_database
    load_database_mithran_encounterchance
    setup_encounter_chances
  end
  def setup_encounter_chances
    for troop in $data_troops.compact
      troop.make_encounter_cache
    end
  end
end