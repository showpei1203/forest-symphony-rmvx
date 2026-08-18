#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：FS_RegionShops_BlackMarket v1.1
# 【用途】Forest Symphony 專用 Runtime／資料腳本「FS_RegionShops_BlackMarket v1.1」。
# 【主要機制】屬目前正式專案功能的一部分；具體責任以本頁定義的類別、模組與方法，以及 LoadOrder Guide 為準。
# 【主要影響】Game_Temp、Game_Interpreter、FS_REGION_SHOPS、FS_BLACK_MARKET
# 【設定／可調參數】優先調整本頁明確的設定常數／設定區，例如：REGION_CONSUMABLES、NAMES、WORDS、WEAPON_TIERS、ARMOR_TIERS、ACCESSORY_TIERS、WEAPON_PRICES、ARMOR_PRICES。核心方法除非已確認依賴鏈，不建議直接覆寫。
# 【依賴／載入順序】登記 $imported：FS Region Shops Black Market；依 FS_Runtime_LoadOrder_Guide／Authority Map 維持目前已驗證位置。
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
# ■ FS_RegionShops_BlackMarket v1.1
#------------------------------------------------------------------------------
# RPG Maker VX / RGSS2 / Ruby 1.8
#
# 配合：
#   Window_ShopBuy FS v1.2
#   Scene_Shop FS v1.2
#   FS_EconomyCore v1.1
#
# 區域商店使用「單次商品自訂價格」，不修改 RPG::Item#price，
# 因此不會把某個村落的折扣永久污染到其他商店。
#==============================================================================

$imported = {} if $imported == nil
$imported["FS Region Shops Black Market"] = "1.1"

class Game_Temp
  attr_accessor :fs_shop_key
  attr_accessor :fs_shop_profile
end

module FS_REGION_SHOPS
  VERSION = "1.1"

  # 可在這裡補上你資料庫原有的消耗品。
  # 格式：[種類, ID, 自訂價格]
  # 種類：0 Item、1 Weapon、2 Armor
  REGION_CONSUMABLES = {
    :luka  => [],
    :camp  => [],
    :habel => [],
    :elf   => [],
    :city  => []
  }

  NAMES = {
    :luka  => "魯卡村商店",
    :camp  => "拓荒營地補給所",
    :habel => "哈貝爾鍛造市集",
    :elf   => "精靈村樹梢商店",
    :city  => "主城中央商會"
  }

  WORDS = {
    :luka  => "村民自製的基礎裝備與生活物資。",
    :camp  => "運輸不易，價格較高，但能在野外立即補充。",
    :habel => "金屬裝備與鍛造品齊全；完成鐵砧支線後增加高階貨品。",
    :elf   => "重視精神、自然與調律的高階裝備。",
    :city  => "正規市場可取得的最終階通用品。"
  }

  WEAPON_TIERS = [
    [100,105,110,115,120,125],
    [101,106,111,116,121,126],
    [102,107,112,117,122,127],
    [103,108,113,118,123,128],
    [104,109,114,119,124,129]
  ]

  ARMOR_TIERS = [
    [296,301,306,311],
    [297,302,307,312],
    [298,303,308,313],
    [299,304,309,314],
    [300,305,310,315]
  ]

  ACCESSORY_TIERS = [
    [316,319,322,325,328,331],
    [317,320,323,326,329,332],
    [318,321,324,327,330,333]
  ]

  WEAPON_PRICES    = [600, 2200, 5000, 11000, 27000]
  ARMOR_PRICES     = [500, 1800, 4200, 9000, 22000]
  ACCESSORY_PRICES = [900, 3500, 9500]

  def self.good(type, id, price)
    return [type.to_i, id.to_i, 1, [price.to_i, 0].max]
  end

  def self.add_tier(goods, type, ids, price, rate = 100)
    ids.each do |id|
      goods.push(good(type, id, price.to_i * rate.to_i / 100))
    end
  end

  def self.add_consumables(goods, key, rate = 100)
    rows = REGION_CONSUMABLES[key] || []
    rows.each do |row|
      next unless row.is_a?(Array) && row.size >= 3
      goods.push(good(row[0], row[1], row[2].to_i * rate.to_i / 100))
    end
  end

  def self.discount_rate(key)
    rate = 100
    if key == :luka && defined?(FS_ECONOMY) &&
       FS_ECONOMY.unlocked?(:luka_return_credit)
      rate -= 10
    end
    if key == :habel && defined?(FS_ECONOMY) &&
       FS_ECONOMY.unlocked?(:habel_forging)
      rate -= 10
    end
    return [rate, 50].max
  end

  def self.profile_goods(key)
    key = key.to_sym
    goods = []
    rate = discount_rate(key)

    case key
    when :luka
      add_tier(goods, 1, WEAPON_TIERS[0], WEAPON_PRICES[0], rate)
      add_tier(goods, 2, ARMOR_TIERS[0], ARMOR_PRICES[0], rate)
      add_tier(goods, 2, ACCESSORY_TIERS[0], ACCESSORY_PRICES[0], rate)
      add_consumables(goods, key, rate)
    when :camp
      # 同階補給但因運輸成本加價20%。
      camp_rate = 120
      add_tier(goods, 1, WEAPON_TIERS[0], WEAPON_PRICES[0], camp_rate)
      add_tier(goods, 2, ARMOR_TIERS[0], ARMOR_PRICES[0], camp_rate)
      add_consumables(goods, key, camp_rate)
    when :habel
      add_tier(goods, 1, WEAPON_TIERS[1], WEAPON_PRICES[1], rate)
      add_tier(goods, 2, ARMOR_TIERS[1], ARMOR_PRICES[1], rate)
      add_tier(goods, 2, ACCESSORY_TIERS[1], ACCESSORY_PRICES[1], rate)
      if defined?(FS_ECONOMY) && FS_ECONOMY.unlocked?(:habel_forging)
        add_tier(goods, 1, WEAPON_TIERS[2], WEAPON_PRICES[2], rate)
        add_tier(goods, 2, ARMOR_TIERS[2], ARMOR_PRICES[2], rate)
      end
      add_consumables(goods, key, rate)
    when :elf
      add_tier(goods, 1, WEAPON_TIERS[3], WEAPON_PRICES[3], rate)
      add_tier(goods, 2, ARMOR_TIERS[3], ARMOR_PRICES[3], rate)
      add_tier(goods, 2, ACCESSORY_TIERS[2], ACCESSORY_PRICES[2], rate)
      add_consumables(goods, key, rate)
    when :city
      add_tier(goods, 1, WEAPON_TIERS[4], WEAPON_PRICES[4], rate)
      add_tier(goods, 2, ARMOR_TIERS[4], ARMOR_PRICES[4], rate)
      add_tier(goods, 2, ACCESSORY_TIERS[2], ACCESSORY_PRICES[2], rate)
      add_consumables(goods, key, rate)
    end

    return goods
  end

  def self.normalize_extra_goods(extra_goods)
    result = []
    (extra_goods || []).each do |row|
      next unless row.is_a?(Array)
      if row.size >= 4
        result.push(row.clone)
      elsif row.size >= 3
        result.push(good(row[0], row[1], row[2]))
      end
    end
    return result
  end

  def self.open(key, extra_goods = [], purchase_only = false)
    key = key.to_sym
    goods = profile_goods(key) + normalize_extra_goods(extra_goods)
    return false if goods.empty?
    $game_temp.shop_goods = goods
    $game_temp.shop_purchase_only = purchase_only == true
    $game_temp.shop_name = NAMES[key].to_s if $game_temp.respond_to?(:shop_name=)
    $game_temp.shop_word = WORDS[key].to_s if $game_temp.respond_to?(:shop_word=)
    $game_temp.fs_shop_key = key
    $game_temp.fs_shop_profile = key
    $game_temp.next_scene = "shop"
    return true
  end
end

module FS_BLACK_MARKET
  VERSION = "1.0"
  ECHO_STOCK        = 1
  FRAGMENT_STOCK    = 5
  SPECIAL_CORE_STOCK = 1

  def self.data
    return nil unless defined?(FS_ECONOMY)
    return FS_ECONOMY.data
  end

  def self.good_key(good)
    return "invalid" if good == nil
    return good[0].to_i.to_s + ":" + good[1].to_i.to_s
  end

  def self.stock_for_good(good)
    return 0 if good == nil || good[0].to_i != 0
    id = good[1].to_i
    return ECHO_STOCK if id >= 200 && id <= 265
    return FRAGMENT_STOCK if id >= 600 && id <= 665
    return SPECIAL_CORE_STOCK if id >= 800 && id <= 804
    return 0
  end

  def self.purchased(good)
    d = data
    return 0 if d == nil
    table = d[:black_market_purchases]
    table = {} unless table.is_a?(Hash)
    d[:black_market_purchases] = table
    return table[good_key(good)].to_i
  end

  def self.remaining_for_good(good)
    return [stock_for_good(good) - purchased(good), 0].max
  end

  def self.record_purchase(good, amount)
    d = data
    return false if d == nil || good == nil
    key = good_key(good)
    d[:black_market_purchases][key] = purchased(good) + amount.to_i
    return true
  end

  def self.echo_price(offset)
    tier = offset.to_i / 15
    return 2500 + tier * 1500
  end

  def self.fragment_price(offset)
    tier = offset.to_i / 15
    return 650 + tier * 250
  end

  def self.special_core_price(actor_id)
    return 9000 + (actor_id.to_i - 2) * 750
  end

  def self.actor_available?(actor_id)
    return false if $game_party == nil || $game_actors == nil
    actor = $game_actors[actor_id.to_i] rescue nil
    return false if actor == nil
    members = $game_party.respond_to?(:all_members) ?
      $game_party.all_members : $game_party.members
    return members.include?(actor)
  end

  def self.goods
    result = []
    return result unless defined?(FS_ECONOMY)
    FS_ECONOMY::SOUL_COUNT.times do |offset|
      next unless FS_ECONOMY.captured_offset?(offset)
      result.push([0, FS_ECONOMY.echo_item_id(offset), 1, echo_price(offset)])
      result.push([0, FS_ECONOMY.fragment_item_id(offset), 1, fragment_price(offset)])
    end
    # 黑市是角色殘響武器的非法補充來源。只列出已加入隊伍的五名角色，
    # 每章各限購一枚；記憶重構分支則由合法服務提供替代來源。
    (2..6).each do |actor_id|
      next unless actor_available?(actor_id)
      result.push([0, 798 + actor_id, 1, special_core_price(actor_id)])
    end
    return result
  end

  def self.open
    return :locked unless defined?(FS_ECONOMY) &&
      FS_ECONOMY.unlocked?(:black_market_access)
    rows = goods
    return :empty if rows.empty?
    $game_temp.shop_goods = rows
    $game_temp.shop_purchase_only = true
    $game_temp.shop_name = "無名名冊交易" if $game_temp.respond_to?(:shop_name=)
    $game_temp.shop_word = "販售已收錄譜系的殘響、碎片與角色特別殘響；庫存每章重置。" if
      $game_temp.respond_to?(:shop_word=)
    $game_temp.fs_shop_key = :black_market
    $game_temp.fs_shop_profile = :black_market
    $game_temp.next_scene = "shop"
    return :success
  end
end

class Game_Interpreter
  def fs_open_region_shop(key, extra_goods = [], purchase_only = false)
    return FS_REGION_SHOPS.open(key, extra_goods, purchase_only)
  end

  def fs_open_black_market
    result = FS_BLACK_MARKET.open
    if result == :locked
      $game_message.texts.push("你沒有進入黑市的名冊權限。") if $game_message != nil
    elsif result == :empty
      $game_message.texts.push("目前沒有已收錄譜系可供交易。") if $game_message != nil
    end
    return result
  end
end
