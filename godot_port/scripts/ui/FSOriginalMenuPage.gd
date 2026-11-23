extends Control
class_name FSOriginalMenuPage

# P538B: source-locked MENU page presentation. Only the original art
# backgrounds, tab sprites, and portraits may be called "original".
# Runtime data and mutations are delegated to the existing FSMenuModel.
signal return_requested
signal actor_requested(index:int)
signal item_requested(item_id:int)
signal item_target_requested(item_id:int,party_index:int)
signal slot_requested(slot:int)
signal equipment_selected(slot:int,item_id:int)
signal formation_requested(index:int)

const PAGE_BACKGROUNDS={
    "status":"MenuBack_status_a.png",
    "skills":"MenuBack_skill.png",
    "items":"MenuBack_item.png",
    "item_targets":"MenuBack_item.png",
    "equipment":"MenuBack_equip.png",
    "equipment_candidates":"MenuBack_equip.png",
    "formation":"MenuBack_party.png"}
const PAGE_TABS={
    "status":["Status01.png","Status02.png"],
    "skills":["Skill01.png","Skill02.png","Skill03.png"],
    "items":["Item01.png","Item02.png","Item03.png"],
    "equipment":["Equip01.png","Equip02.png"],
    "equipment_candidates":["Equip01.png","Equip02.png"]}
const TITLES={
    "status":"角色狀態","skills":"技能","items":"物品",
    "item_targets":"選擇使用對象","equipment":"裝備",
    "equipment_candidates":"選擇裝備","formation":"隊伍編排"}
const PORTRAITS={
    "喬伊":"menu_喬伊.png","泰勒":"menu_泰勒.png",
    "米亞":"menu_米亞.png","艾卓":"menu_艾卓.png",
    "艾薇":"menu_艾薇.png","薇娜":"menu_薇娜.png"}
const SOURCE_SIZE:=Vector2i(544,416)
const TAB_SIZE:=Vector2i(60,20)

var source_ready:bool=false
var page_kind:String=""
var actor_index:int=0
var action_buttons:Array[Button]=[]
var actor_buttons:Array[Button]=[]
var source_tabs:Array[TextureButton]=[]
var displayed_portrait:TextureRect
var _art:FSUIArtLibrary
var _menu:FSMenuModel

func configure(provider:FSUIArtLibrary, model:FSMenuModel,
        category:String, selected_actor:int, first_formation:int=-1,
        subject_id:int=-1)->bool:
    source_ready=false
    if provider==null or model==null or not PAGE_BACKGROUNDS.has(category):
        return false
    var background:Texture2D=provider.texture(
        "system",str(PAGE_BACKGROUNDS[category]))
    if background==null or Vector2i(background.get_size())!=SOURCE_SIZE:
        return false
    var icons:Array[Texture2D]=[]
    for filename in PAGE_TABS.get(category,[]):
        var icon:Texture2D=provider.texture("menu",str(filename))
        if icon==null or Vector2i(icon.get_size())!=TAB_SIZE:
            return false
        icons.append(icon)
    for old in get_children():
        remove_child(old)
        old.queue_free()
    action_buttons.clear()
    actor_buttons.clear()
    source_tabs.clear()
    displayed_portrait=null
    _art=provider
    _menu=model
    actor_index=selected_actor
    page_kind=category
    size=Vector2(SOURCE_SIZE)
    custom_minimum_size=Vector2(SOURCE_SIZE)
    mouse_filter=Control.MOUSE_FILTER_PASS
    texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    _render(icons,first_formation,subject_id)
    source_ready=true
    return true

func _new_label(parent:Node,value:String,font_size:int=13)->Label:
    var label:=Label.new()
    label.text=value
    label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size",font_size)
    label.add_theme_color_override("font_color",Color(0.08,0.18,0.2))
    parent.add_child(label)
    return label

func _button(parent:Node,value:String,action:Callable,
        enabled:bool=true)->Button:
    var button:=Button.new()
    button.text=value
    button.alignment=HORIZONTAL_ALIGNMENT_LEFT
    button.focus_mode=Control.FOCUS_ALL
    button.disabled=not enabled
    button.custom_minimum_size=Vector2(0,27)
    button.add_theme_font_size_override("font_size",12)
    if enabled:
        button.pressed.connect(action)
    parent.add_child(button)
    action_buttons.append(button)
    return button

func _render(tabs:Array[Texture2D],first_formation:int,
        subject_id:int)->void:
    var header:=HBoxContainer.new()
    header.position=Vector2(145,49)
    header.size=Vector2(356,26)
    add_child(header)
    _new_label(header,"Forest Symphony　"+str(TITLES[page_kind]),16)
    var back:=_button(header,"返回",func()->void:return_requested.emit())
    back.size_flags_horizontal=Control.SIZE_SHRINK_END
    var strip:=HBoxContainer.new()
    strip.name="FSOriginalPageTabs"
    strip.position=Vector2(144,82)
    strip.add_theme_constant_override("separation",8)
    add_child(strip)
    for i in range(tabs.size()):
        var picture:=TextureButton.new()
        picture.name="OriginalSourceTab_"+str(i)
        picture.texture_normal=tabs[i]
        picture.texture_disabled=tabs[i]
        picture.ignore_texture_size=true
        picture.stretch_mode=TextureButton.STRETCH_KEEP_CENTERED
        picture.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        picture.custom_minimum_size=Vector2(TAB_SIZE)
        picture.disabled=i!=0
        picture.tooltip_text="來源頁籤：已移植目前主頁" if i==0 else (
            "原始素材已驗證；其他來源子功能尚未核准")
        strip.add_child(picture)
        source_tabs.append(picture)
    if not page_kind in ["items","item_targets","formation"]:
        _actor_nav()
    var panel:=PanelContainer.new()
    panel.name="FSOriginalPageFunctionalWindow"
    panel.position=Vector2(144,119)
    panel.size=Vector2(355,247)
    var style:=StyleBoxFlat.new()
    style.bg_color=Color(0.95,0.98,0.97,0.78)
    style.set_content_margin_all(6)
    panel.add_theme_stylebox_override("panel",style)
    add_child(panel)
    var scroll:=ScrollContainer.new()
    scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    panel.add_child(scroll)
    var list:=VBoxContainer.new()
    list.name="FSOriginalPageRows"
    list.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    list.add_theme_constant_override("separation",3)
    scroll.add_child(list)
    match page_kind:
        "status":_status(list)
        "skills":_skills(list)
        "items":_items(list)
        "item_targets":_item_targets(list,subject_id)
        "equipment":_equipment(list)
        "equipment_candidates":_equipment_candidates(list,subject_id)
        "formation":_formation(list,first_formation)
    if not _menu.db.boot_final_verified:
        var gate:=_new_label(self,"QA 資料尚非原版啟動後完整驗證資料",10)
        gate.position=Vector2(145,379)
        gate.size=Vector2(350,19)

func _actor_nav()->void:
    var party:Array[Dictionary]=_menu.party()
    if actor_index>=0 and actor_index<party.size():
        var name:String=str(party[actor_index].get("name",""))
        if PORTRAITS.has(name):
            var tex:Texture2D=_art.texture("menu",str(PORTRAITS[name]))
            if tex!=null:
                displayed_portrait=TextureRect.new()
                displayed_portrait.name="FSOriginalPortrait_"+str(actor_index)
                displayed_portrait.texture=tex
                displayed_portrait.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
                displayed_portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
                displayed_portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
                displayed_portrait.position=Vector2(16,93)
                displayed_portrait.size=Vector2(113,142)
                add_child(displayed_portrait)
    var nav:=VBoxContainer.new()
    nav.position=Vector2(21,247)
    nav.size=Vector2(110,122)
    add_child(nav)
    for i in range(mini(party.size(),4)):
        var selected:int=i
        var name:String=str(party[i].get("name","?"))
        var button:=_button(nav,("▶ " if i==actor_index else "　")+name,
            func()->void:actor_requested.emit(selected))
        button.custom_minimum_size=Vector2(107,22)
        actor_buttons.append(button)

func _status(list:VBoxContainer)->void:
    var party:Array[Dictionary]=_menu.party()
    if actor_index<0 or actor_index>=party.size():
        _new_label(list,"隊伍資料不可用")
        return
    var actor:Dictionary=party[actor_index]
    for line in [
        "%s　Lv.%d" % [actor.get("name","?"),actor.get("level",0)],
        "HP %d/%d　MP %d/%d" % [actor.get("hp",0),actor.get("maxhp",0),
            actor.get("mp",0),actor.get("maxmp",0)],
        "ATK %d　DEF %d　SPI %d" % [actor.get("atk",0),
            actor.get("def",0),actor.get("spi",0)],
        "AGI %d　HIT %d　EVA %d　CRI %d" % [actor.get("agi",0),
            actor.get("hit",0),actor.get("eva",0),actor.get("cri",0)]]:
        _new_label(list,str(line))

func _skills(list:VBoxContainer)->void:
    var rows:Array[Dictionary]=_menu.known_skills(actor_index)
    if rows.is_empty():
        _new_label(list,"目前沒有已習得的技能")
    for row in rows:
        var quote:String=str(row.get("mp_cost",0)) if (
            bool(row.get("cost_verified",false))) else "未驗證"
        _new_label(list,"%s　MP %s" % [row.get("name",""),quote])
        if not str(row.get("description","")).is_empty():
            _new_label(list,"  "+str(row["description"]),11)
    _new_label(list,"未完成原始技能效果的項目不可在選單施放",11)

func _items(list:VBoxContainer)->void:
    var rows:Array[Dictionary]=_menu.inventory_rows("item")
    if rows.is_empty():
        _new_label(list,"目前沒有持有道具")
    for row in rows:
        var item_id:int=int(row.get("id",0))
        var button:=_button(list,"%s　×%d" % [
            row.get("name",""),row.get("count",0)],
            func()->void:item_requested.emit(item_id))
        var icon:Texture2D=_art.icon(int(row.get("icon_index",0)))
        if icon!=null:
            button.icon=icon
            button.expand_icon=false
        button.tooltip_text=str(row.get("description",""))
    _new_label(list,"僅來源已驗證的回復型道具可消耗",11)

func _item_targets(list:VBoxContainer,item_id:int)->void:
    if item_id<1:
        _new_label(list,"無效的來源道具")
        return
    var name:String=str(_menu.db.record("items",item_id).get("name",""))
    _new_label(list,name+"：選擇對象")
    var party:Array[Dictionary]=_menu.party()
    for i in range(party.size()):
        if int(party[i].get("hp",0))<=0:
            continue
        var target:int=i
        _button(list,"%s　HP %d/%d" % [party[i].get("name","?"),
            party[i].get("hp",0),party[i].get("maxhp",0)],
            func()->void:item_target_requested.emit(item_id,target))

func _equipment(list:VBoxContainer)->void:
    var rows:Array[Dictionary]=_menu.equipment_rows(actor_index)
    if rows.is_empty():
        _new_label(list,"裝備欄位不可用")
    for row in rows:
        var slot:int=int(row.get("slot",-1))
        var locked:bool=bool(row.get("locked",false))
        _button(list,"%s：%s%s" % [row.get("label",""),
            row.get("name",""),"（鎖定）" if locked else ""],
            func()->void:slot_requested.emit(slot),not locked)

func _equipment_candidates(list:VBoxContainer,slot:int)->void:
    if slot<0:
        _new_label(list,"裝備欄位不可用")
        return
    var rows:Array[Dictionary]=_menu.available_equipment(actor_index,slot)
    if rows.is_empty():
        _new_label(list,"沒有可更換的裝備")
    for row in rows:
        var item_id:int=int(row.get("id",0))
        _button(list,str(row.get("name",""))+"　#"+str(item_id),
            func()->void:equipment_selected.emit(slot,item_id))

func _formation(list:VBoxContainer,first:int)->void:
    var party:Array[Dictionary]=_menu.party()
    _new_label(list,"點選兩名隊員交換順序" if first<0 else (
        "已選取："+str(party[first].get("name","")) if first<party.size() else
        "已選取角色不存在"))
    for i in range(party.size()):
        var pos:int=i
        _button(list,"%d.　%s" % [i+1,party[i].get("name","?")],
            func()->void:formation_requested.emit(pos))
