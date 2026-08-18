#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_EconomyAudit v1.0
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_EconomyAudit v1.0」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Interpreter、FS_ECONOMY_AUDIT
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】登記 $imported：FS Economy Audit、IEX_Rand_Drop、FS Resonance Headgear Kind Rename；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_EconomyAudit v1.0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2
# 事件指令：fs_econ_write_audit
# 產生：FS_Economy_Audit_Report.txt
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Economy Audit"] = "1.0"

module FS_ECONOMY_AUDIT
  VERSION = "1.0"

  def self.name_of(obj)
    return "(nil)" if obj == nil
    return obj.name.to_s
  rescue
    return "(error)"
  end

  def self.recipe(kind, id)
    return nil unless defined?(Sword) && Sword.const_defined?(:Sword4_Synthesize)
    return Sword::Sword4_Synthesize[kind][id] rescue nil
  end

  def self.lines
    result = []
    result.push("FS Economy Audit v#{VERSION}")
    result.push("Generated: #{Time.now}")
    result.push("=" * 78)
    result.push("")

    result.push("[A] Runtime modules")
    result.push("FS_SOULMARK_RESONANCE: #{defined?(FS_SOULMARK_RESONANCE) ? 'YES' : 'NO'}")
    result.push("Albert_SoulRepeatRecipe: #{defined?(Albert_SoulRepeatRecipe) ? 'YES' : 'NO'}")
    result.push("FS_ECONOMY: #{defined?(FS_ECONOMY) ? 'YES' : 'NO'}")
    result.push("FS_ECONOMY_DROP: #{defined?(FS_ECONOMY_DROP) ? 'YES' : 'NO'}")
    result.push("FS_REGION_SHOPS: #{defined?(FS_REGION_SHOPS) ? 'YES' : 'NO'}")
    result.push("FS_BLACK_MARKET: #{defined?(FS_BLACK_MARKET) ? 'YES' : 'NO'}")
    result.push("")

    result.push("[B] 66 soul lines")
    66.times do |offset|
      soul_id = 600 + offset
      echo_id = 200 + offset
      fragment_id = 600 + offset
      head_id = 220 + offset
      soul = $data_armors[soul_id] rescue nil
      echo = $data_items[echo_id] rescue nil
      fragment = $data_items[fragment_id] rescue nil
      head = $data_armors[head_id] rescue nil
      row = recipe(2, head_id)
      kind = head == nil ? -1 : head.kind.to_i
      result.push(sprintf(
        "%02d Soul A%03d %-18s | Echo I%03d %-18s | Frag I%03d %-18s",
        offset, soul_id, name_of(soul)[0,18], echo_id, name_of(echo)[0,18],
        fragment_id, name_of(fragment)[0,18]
      ))
      result.push(sprintf(
        "   Head A%03d kind=%d %-24s recipe=%s",
        head_id, kind, name_of(head)[0,24], row.inspect
      ))
    end
    result.push("")

    result.push("[C] Obsolete Joey Weapon 200-265")
    old_recipe_ids = []
    66.times do |offset|
      old_recipe_ids.push(200 + offset) if recipe(1, 200 + offset) != nil
    end
    result.push("Remaining old weapon recipes: #{old_recipe_ids.inspect}")
    result.push("")

    result.push("[D] Other five characters' soul-related weapons")
    (266..275).each do |id|
      weapon = $data_weapons[id] rescue nil
      result.push("W#{id} #{name_of(weapon)} recipe=#{recipe(1,id).inspect}")
    end
    result.push("")

    result.push("[E] Soul-enemy fragment table")
    mapped = 0
    missing_fragment = []
    if $data_enemies != nil
      for enemy_id in 1...$data_enemies.size
        enemy = $data_enemies[enemy_id]
        next if enemy == nil
        armor_id = FS_ECONOMY_DROP.soul_armor_id(enemy) rescue 0
        next if armor_id <= 0
        mapped += 1
        offset = armor_id - 600
        item = $data_items[600 + offset] rescue nil
        profile = FS_ECONOMY_DROP.profile(enemy) rescue nil
        missing_fragment.push(enemy_id) if item == nil
        result.push("E#{enemy_id} #{enemy.name} -> A#{armor_id} / I#{600+offset} #{name_of(item)} / #{profile.inspect}")
      end
    end
    result.push("Mapped enemies: #{mapped}")
    result.push("Missing fragment objects: #{missing_fragment.inspect}")
    result.push("")

    result.push("[F] Service flags")
    if defined?(FS_ECONOMY)
      FS_ECONOMY::SERVICE_KEYS.each do |key|
        result.push("#{key}: #{FS_ECONOMY.unlocked?(key)}")
      end
      result.push("Chapter: #{FS_ECONOMY.chapter}")
      result.push("Craft credit: #{FS_ECONOMY.data[:craft_credit]}")
    end
    result.push("")

    result.push("[G] Risk flags still loaded")
    result.push("IEX More Drops: #{($imported['IEX_Rand_Drop'] rescue nil).inspect}")
    result.push("Drop Options extra_drops method: #{RPG::Enemy.method_defined?(:extra_drops)}")
    result.push("Price_Edit module: #{defined?(Price_Edit) ? 'YES' : 'NO'}")
    result.push("quotation_percent method: #{RPG::Item.method_defined?(:quotation_percent)}")
    result.push("FS Resonance Headgear old patch: #{($imported['FS Resonance Headgear Kind Rename'] rescue nil).inspect}")
    result.push("")
    result.push("END")
    return result
  end

  def self.write
    File.open("FS_Economy_Audit_Report.txt", "wb") do |file|
      lines.each { |line| file.write(line.to_s + "\r\n") }
    end
    return true
  rescue
    return false
  end
end

class Game_Interpreter
  def fs_econ_write_audit
    result = FS_ECONOMY_AUDIT.write
    $game_message.texts.push(result ? "經濟稽核報告已輸出。" : "經濟稽核報告輸出失敗。") if
      $game_message != nil
    return result
  end
end
