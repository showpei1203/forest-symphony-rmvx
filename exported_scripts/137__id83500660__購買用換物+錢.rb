#==============================================================================
# 【Forest Symphony｜繁體中文維護說明】
#------------------------------------------------------------------------------
# 腳本：購買用換物+錢
# 【用途】保留的 Runtime 元件「購買用換物+錢」。
# 【主要機制】主要定義／擴充 Window_ElaboratedShop、Window_ElaboratedShopReq、Scene_ElaboratedShop、ElaboratedEquipmentShop；下方原始說明與程式碼保留作細節依據。
# 【主要影響】Window_ElaboratedShop、Window_ElaboratedShopReq、Scene_ElaboratedShop、ElaboratedEquipmentShop
# 【設定／可調參數】本頁若沒有獨立 Configuration 區，表示主要行為由程式流程／資料庫／事件或其他 Authority 控制；不要只因名稱直覺修改核心方法。
# 【依賴／載入順序】保持目前已驗證的相對順序；搬動前先反查 class reopen／alias／事件入口。
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
# ** Elaborated Equipment Shop
#------------------------------------------------------------------------------
#  Autore: The Sleeping Leonhart
#  Versione: 1.0
#  Data di rilascio: 23/9/2008
#------------------------------------------------------------------------------
#  Descrizione:
#	Questo script permette di comprare le armi pagando con monete e con oggetti.
#------------------------------------------------------------------------------
#  Versioni:
#	1.0 (23/9/2008): Versione Base.
#------------------------------------------------------------------------------
#  Istruzioni:
#	Per chiamare lo shop usate il comando script degli eventi ed inserite:
#	  goods=[];w=$data_weapons;a = $data_armors
#	  goods.push(w[n])
#	  goods.push(a[n])
#	  $scene = Scene_ElaboratedShop.new(goods)
#
#	goods.push(w[n]) aggiunge l'arma con id n allo shop.
#	goods.push(a[n]) aggiunge l'armatura con id n allo shop.
#	Il costo dell'arma/armatura è lo stesso impostato attraverso il database.
#	Per personalizzare lo script andate nella sezione Configurazione.
#==============================================================================

#==============================================================================
#  Configurazione
#==============================================================================
module ElaboratedEquipmentShop
  #=========================================================================
  #  WeaponIngredient: Imposta gli ingredienti per comprare le armi.
  #-------------------------------------------------------------------------
  #  Sintassi:
  #	WeaponIngredient[wId1] = [{iId => n, ...}, {wId2 => n, ...}, {aId2 => n, ...}]
  #  Parametri:
  #	wId1: id dell'arma da comprare
  #	iId: id degli oggetti richiesti per comprare l'arma
  #	wId2: id delle armi richieste per comprare l'arma
  #	aId: id delle armature richieste per comprare l'arma
  #	n: quantità dell'oggetto richiesta
  #=========================================================================
  WeaponIngredient = {}
  WeaponIngredient[3] = [{2 => 2, 3 => 4},{},{}]
  WeaponIngredient.default = [{},{},{}]
  #=========================================================================
  #  ArmorIngredient: Imposta gli ingredienti per comprare le armature.
  #-------------------------------------------------------------------------
  #  Sintassi:
  #	ArmorIngredient[aId1] = [{iId => n, ...}, {wId => n, ...}, {aId2 => n, ...}]
  #  Parametri:
  #	aId1: id dell'armatura da comprare
  #	iId: id degli oggetti richiesti per comprare l'armatura
  #	wId: id delle armi richieste per comprare l'armatura
  #	aId2: id delle armature richieste per comprare l'armatura
  #	n: quantità dell'oggetto richiesta
  #=========================================================================
  ArmorIngredient = {}
  ArmorIngredient[4] = [{3 => 4},{3 => 1},{}]
  ArmorIngredient.default = [{},{},{}]
end

class Window_ElaboratedShop < Window_Selectable
  #--------------------------------------------------------------------------
  # ● initialize
  #--------------------------------------------------------------------------
  def initialize(shop_goods)
	super(0, 112, 304, 152)
	@shop_goods = shop_goods
	refresh
	self.index = 0
  end
  #--------------------------------------------------------------------------
  # ● item
  #--------------------------------------------------------------------------
  def item
	return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # ● refresh
  #--------------------------------------------------------------------------
  def refresh
	@data = []
	for item in @shop_goods
	  if item != nil
		@data.push(item)
	  end
	end
	@item_max = @data.size
	create_contents
	for i in 0...@item_max
	  draw_item(i)
	end
  end
  #--------------------------------------------------------------------------
  # ● draw item
  #--------------------------------------------------------------------------
  def draw_item(index)
	item = @data[index]
	requirement = true
	type = [$data_items, $data_weapons, $data_armors]
	case item
	when RPG::Weapon
	  req = ElaboratedEquipmentShop::WeaponIngredient
	when RPG::Armor
	  req = ElaboratedEquipmentShop::ArmorIngredient
	end
	for i in 0...3
	  for id in req[item.id][i].keys
		if $game_party.item_number(type[i][id]) < req[item.id][i][id]
		  requirement = false
		  break
		end
	  end
	end
	number = $game_party.item_number(item)
	enabled = (item.price <= $game_party.gold and number < 99 and requirement)
	rect = item_rect(index)
	self.contents.clear_rect(rect)
	draw_item_name(item, rect.x, rect.y, enabled)
	rect.width -= 4
	self.contents.draw_text(rect, item.price, 2)
  end
  #--------------------------------------------------------------------------
  # ● update help
  #--------------------------------------------------------------------------
  def update_help
	@help_window.set_text(item == nil ? "" : item.description)
  end
end

class Window_ElaboratedShopReq < Window_Base
  #--------------------------------------------------------------------------
  # ● initialize
  #--------------------------------------------------------------------------
  def initialize(item)
	super(0, 264, 304, 152)
	@item = nil
	refresh(item)
  end
  #--------------------------------------------------------------------------
  # ● refresh
  #--------------------------------------------------------------------------
  def refresh(item)
	self.contents.clear
	self.contents.font.color = system_color
	self.contents.draw_text(0, 0, 150, 24, "Richiede:")
	index = 0
	type = [$data_items, $data_weapons, $data_armors]
	case item
	when RPG::Weapon
	  req = ElaboratedEquipmentShop::WeaponIngredient
	when RPG::Armor
	  req = ElaboratedEquipmentShop::ArmorIngredient
	end
	for i in 0...3
	  for id in req[item.id][i].keys
		self.contents.font.color = normal_color
		self.contents.font.color = Color.new(128,128,128) if $game_party.item_number(type[i][id]) < req[item.id][i][id]
		x = index / 4 * 152
		y = index % 4 * 24
		self.contents.draw_text(x, y + 24, 144, 24, type[i][id].name + " x " + req[item.id][i][id].to_s)
		index += 1
	  end
	end
  end
  #--------------------------------------------------------------------------
  # ● item
  #--------------------------------------------------------------------------
  def item=(item)
	if @item != item
	  @item = item
	  refresh(item)
	end
  end
end
################################################################################
class Scene_ElaboratedShop < Scene_Base
  def initialize(goods)
	@goods = goods
  end
  #--------------------------------------------------------------------------
  # ● start
  #--------------------------------------------------------------------------
  def start
	super
	create_menu_background
	create_command_window
	@help_window = Window_Help.new
  @help_window.opacity = 255
	@gold_window = Window_Gold.new(384, 56)
	@dummy_window = Window_Base.new(0, 112, 544, 304)
	@buy_window = Window_ElaboratedShop.new(@goods)
	@buy_window.active = false
	@buy_window.visible = false
	@buy_window.help_window = @help_window
	@req_window = Window_ElaboratedShopReq.new(@buy_window.item)
	@req_window.visible = false
	@status_window = Window_ShopStatus.new(304, 112)
	@status_window.visible = false
  end
  #--------------------------------------------------------------------------
  # ● terminate
  #--------------------------------------------------------------------------
  def terminate
	super
	dispose_menu_background
	dispose_command_window
	@help_window.dispose
	@gold_window.dispose
	@dummy_window.dispose
	@buy_window.dispose
	@req_window.dispose
	@status_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● update
  #--------------------------------------------------------------------------
  def update
	super
	update_menu_background
	@help_window.update
	@command_window.update
	@gold_window.update
	@dummy_window.update
	@buy_window.update
	@req_window.update
	@status_window.update
	if @command_window.active
	  update_command_selection
	elsif @buy_window.active
	  update_buy_selection
	end
  end
  #--------------------------------------------------------------------------
  # ● create_command_window
  #--------------------------------------------------------------------------
  def create_command_window
	s1 = Vocab::ShopBuy
	s2 = Vocab::ShopCancel
	@command_window = Window_Command.new(384, [s1, s2], 2)
	@command_window.y = 56
  end
  #--------------------------------------------------------------------------
  # ● dispose_command_window
  #--------------------------------------------------------------------------
  def dispose_command_window
	@command_window.dispose
  end
  #--------------------------------------------------------------------------
  # ● update_command_selection
  #--------------------------------------------------------------------------
  def update_command_selection
	if Input.trigger?(Input::B)
	  Sound.play_cancel
	  $scene = Scene_Map.new
	elsif Input.trigger?(Input::C)
	  case @command_window.index
	  when 0  # 購入する
		Sound.play_decision
		@command_window.active = false
		@dummy_window.visible = false
		@buy_window.active = true
		@buy_window.visible = true
		@req_window.visible = true
		@buy_window.refresh
		@status_window.visible = true
	  when 1
		Sound.play_decision
		$scene = Scene_Map.new
	  end
	end
  end
  #--------------------------------------------------------------------------
  # ● update_buy_selection
  #--------------------------------------------------------------------------
  def update_buy_selection
	@req_window.item = @buy_window.item
	@status_window.item = @buy_window.item
	if Input.trigger?(Input::B)
	  Sound.play_cancel
	  @command_window.active = true
	  @dummy_window.visible = true
	  @buy_window.active = false
	  @buy_window.visible = false
	  @status_window.visible = false
	  @req_window.visible = false
	  @status_window.item = nil
	  @help_window.set_text("")
	  return
	end
	if Input.trigger?(Input::C)
	  @item = @buy_window.item
	  number = $game_party.item_number(@item)
	  requirement = true
	  type = [$data_items, $data_weapons, $data_armors]
	  case @item
	  when RPG::Weapon
		req = ElaboratedEquipmentShop::WeaponIngredient
	  when RPG::Armor
		req = ElaboratedEquipmentShop::ArmorIngredient
	  end
	  for i in 0...3
		for id in req[@item.id][i].keys
		  if $game_party.item_number(type[i][id]) < req[@item.id][i][id]
			requirement = false
			break
		  end
		end
	  end
	  if @item == nil or @item.price > $game_party.gold or number == 99 or requirement == false
		Sound.play_buzzer
	  else
		Sound.play_decision
		$game_party.gain_item(@item, 1)
		for i in 0...3
		  for id in req[@item.id][i].keys
			$game_party.lose_item(type[i][id], req[@item.id][i][id])
		  end
		end
		$game_party.lose_gold(@item.price)
		@buy_window.refresh
		@req_window.refresh(@buy_window.item)
		@status_window.refresh
		@gold_window.refresh
	  end
	end
  end
end