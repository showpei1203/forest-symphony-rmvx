#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_ShopStatusDetail v1.0
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_ShopStatusDetail v1.0」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Window_ShopStatus
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】含 2 個 alias／方法包裝，載入順序具有語意；登記 $imported：FS Shop Status Detail；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_ShopStatusDetail v1.0
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8
#
# 放置位置：
#   KGC Large Party、YEM Equipment Overhaul、物品飄動等商店相關腳本之下，
#   Scene_Shop FS v1.2 之前，Main 之上。
#
# 功能：
#   1. 保留目前商店右側的角色能力比較頁。
#   2. 武器／防具按 Input::X 切換「特殊效果」頁。
#   3. 顯示實際買價、區域原價差異、黑市剩餘庫存。
#   4. 鳴刻冠顯示搭配魂刻、鍛造與調律。
#   5. Weapon 266～275 顯示對應角色、特別殘響、鍛造與調律。
#
# 本腳本不重寫YEM的能力差值計算，只包住最終refresh。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Shop Status Detail"] = "1.0"

class Window_ShopStatus < Window_Base
  attr_reader :fs_detail_page

  unless method_defined?(:fs_shop_detail_base_refresh)
    alias fs_shop_detail_base_refresh refresh
  end

  unless method_defined?(:fs_shop_detail_base_item_set)
    alias fs_shop_detail_base_item_set item=
  end

  def fs_shop_buy_window=(window)
    @fs_shop_buy_window = window
    refresh
  end

  def item=(new_item)
    @fs_detail_page = 0 if @item != new_item
    fs_shop_detail_base_item_set(new_item)
  end

  def fs_detail_available?
    return false if @item == nil
    return @item.is_a?(RPG::Weapon) || @item.is_a?(RPG::Armor)
  end

  def fs_toggle_detail_page
    return false unless fs_detail_available?
    @fs_detail_page = (@fs_detail_page.to_i == 0 ? 1 : 0)
    self.oy = 0
    refresh
    return true
  end

  def refresh
    @fs_detail_page = 0 if @fs_detail_page == nil
    if @fs_detail_page.to_i == 0
      fs_shop_detail_base_refresh
      fs_draw_shop_context
    else
      fs_refresh_detail_page
    end
  end

  def fs_black_market?
    return false unless $game_temp.respond_to?(:fs_shop_key)
    return $game_temp.fs_shop_key == :black_market
  end

  def fs_current_stock
    return 99 if @fs_shop_buy_window == nil
    return @fs_shop_buy_window.remaining_stock
  rescue
    return 99
  end

  def fs_current_price
    return @item == nil ? 0 : @item.price.to_i if @fs_shop_buy_window == nil
    return @fs_shop_buy_window.current_price.to_i
  rescue
    return @item == nil ? 0 : @item.price.to_i
  end

  def fs_base_price
    return @item == nil ? 0 : @item.price.to_i if @fs_shop_buy_window == nil
    return @fs_shop_buy_window.base_price.to_i
  rescue
    return @item == nil ? 0 : @item.price.to_i
  end

  def fs_draw_shop_context
    return if @item == nil || self.contents == nil
    self.contents.font.size = 14
    self.contents.font.color = system_color
    if fs_black_market?
      self.contents.draw_text(205, 0, 72, WLH, "庫存")
      self.contents.font.color = normal_color
      self.contents.draw_text(252, 0, 42, WLH, fs_current_stock.to_i, 2)
    end
    if fs_detail_available?
      self.contents.font.color = system_color
      self.contents.font.size = 16
      self.contents.draw_text(282, 0, 52, WLH, "按下A查看效果", 2)
    end
    self.contents.font.color = normal_color
    self.contents.font.size = 16
  end

  def fs_refresh_detail_page
    self.contents.clear
    return if @item == nil
    self.contents.font.size = 16
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 120, WLH, Vocab::Possession)
    self.contents.font.color = normal_color
    self.contents.draw_text(104, 0, 40, WLH,
      $game_party.item_number(@item), 2)

    if fs_black_market?
      self.contents.font.color = system_color
      self.contents.draw_text(160, 0, 70, WLH, "庫存")
      self.contents.font.color = normal_color
      self.contents.draw_text(220, 0, 38, WLH, fs_current_stock.to_i, 2)
    end
    self.contents.font.color = system_color
    self.contents.draw_text(266, 0, 68, WLH, "按下A查看數值", 2)

    y = WLH
    draw_item_name(@item, 4, y, true)
    y += WLH

    y = fs_draw_price_line(y)
    y = fs_draw_description(y)
    y = fs_draw_special_lines(y)
    self.contents.font.color = normal_color
    self.contents.font.size = 16
  end

  def fs_draw_price_line(y)
    now = fs_current_price
    base = fs_base_price
    self.contents.font.color = system_color
    self.contents.draw_text(4, y, 58, WLH, "買價")
    self.contents.font.color = normal_color
    if base > 0 && now != base
      text = now.to_s + "G（原價" + base.to_s + "G）"
    else
      text = now.to_s + "G"
    end
    self.contents.draw_text(62, y, 270, WLH, text)
    return y + WLH
  end

  def fs_draw_description(y)
    text = @item.description.to_s.gsub("\r", " ").gsub("\n", " ")
    return y if text.empty?
    lines = fs_description_lines(text, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(4, y, 74, WLH, "效果")
    self.contents.font.color = normal_color
    lines.each_with_index do |line, index|
      x = index == 0 ? 62 : 4
      width = index == 0 ? 270 : 328
      self.contents.draw_text(x, y, width, WLH, line)
      y += WLH
    end
    return y
  end

  def fs_description_lines(text, max_lines)
    result = []
    remain = text.to_s.dup
    separators = ["。", "；", "！", "？", "，", "、"]
    while !remain.empty? && result.size < max_lines
      limit = result.empty? ? 270 : 328
      if self.contents.text_size(remain).width <= limit
        result.push(remain)
        remain = ""
        break
      end
      cut = 0
      separators.each do |mark|
        pos = remain.index(mark)
        next if pos == nil
        candidate = remain[0, pos + mark.size]
        if self.contents.text_size(candidate).width <= limit
          cut = pos + mark.size if pos + mark.size > cut
        end
      end
      if cut <= 0
        # 找不到安全標點時交給draw_text裁切，不以byte切中文字。
        result.push(remain)
        remain = ""
      else
        result.push(remain[0, cut])
        remain = remain[cut, remain.size - cut].to_s
      end
    end
    return result
  end

  def fs_draw_special_lines(y)
    lines = []
    if @item.is_a?(RPG::Armor) && defined?(FS_ECONOMY) &&
       FS_ECONOMY.valid_headgear_id?(@item.id)
      offset = FS_ECONOMY.offset_from_headgear(@item.id)
      soul = $data_armors[FS_ECONOMY::SOUL_ARMOR_START + offset] rescue nil
      lines.push("搭配魂刻：" + soul.name.to_s) if soul != nil
      level = FS_ECONOMY.headgear_level(@item.id)
      branch = FS_ECONOMY.headgear_tuning(@item.id)
      lines.push("鍛造：+" + level.to_s + "（原有能力每級+2）")
      lines.push("調律：" + fs_tuning_text(branch))
    elsif @item.is_a?(RPG::Weapon) && defined?(FS_ECONOMY) &&
          FS_ECONOMY.valid_special_weapon_id?(@item.id)
      actor_id = FS_ECONOMY::SPECIAL_WEAPON_ACTOR[@item.id] rescue 0
      actor = $data_actors[actor_id] rescue nil
      lines.push("專屬角色：" + actor.name.to_s) if actor != nil
      core_id = FS_ECONOMY.special_core_item_id(@item.id)
      core = $data_items[core_id] rescue nil
      lines.push("特別殘響：" + core.name.to_s) if core != nil
      level = FS_ECONOMY.special_weapon_level(@item.id)
      branch = FS_ECONOMY.special_weapon_tuning(@item.id)
      lines.push("鍛造：+" + level.to_s + "（原有能力每級+2）")
      lines.push("調律：" + fs_tuning_text(branch))
    end

    lines.each do |line|
      break if y > self.contents.height - WLH
      self.contents.font.color = normal_color
      self.contents.draw_text(4, y, 328, WLH, line)
      y += WLH
    end
    return y
  end

  def fs_tuning_text(branch)
    return "未調律" if branch == nil
    if defined?(FS_ECONOMY) && FS_ECONOMY::TUNING_NAMES.has_key?(branch)
      name = FS_ECONOMY::TUNING_NAMES[branch]
    else
      name = branch.to_s
    end
    if branch == :force
      return name.to_s + "（攻擊／敏捷+3）"
    elsif branch == :harmony
      return name.to_s + "（防禦／意志+3）"
    end
    return name.to_s
  end
end
