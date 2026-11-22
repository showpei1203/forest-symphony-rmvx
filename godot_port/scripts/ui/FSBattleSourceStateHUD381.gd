extends Control
class_name FSBattleSourceStateHUD381

# Original FS Scripts.rvdata section #381, AlbertBattleStateHUD.
# True literal constants and rules from lines 177-212, 311-373,
# 534-552, 1077-1099, 1147-1161, 1219-1290.
# Section #462 sets SHOW_HELP_STATE_ICONS=false: do not invent a second
# set of state icons in target help! This draws BATTILER badges only.
const SOURCE_SECTION:int=381
const SOURCE_HELP_SECTION:int=462
const MAX_ICONS:int=4
const ICON_SIZE:int=20
const ICON_SPACING:int=20
const ICON_OPACITY:int=180
const ACTOR_OFFSET:Vector2=Vector2(-16,20)
const ENEMY_OFFSET:Vector2=Vector2(45,20)
const ICON_SOURCE_CELL:int=24
const ICON_SOURCE_COLUMNS:int=16
var db:FSDatabase
var iconset:Texture2D
var source_enabled:bool=false
var entries:Array[Dictionary]=[]
var errors:Array[String]=[]

static func _tag(note:String,pattern:String)->bool:
    var rx:=RegEx.new()
    if rx.compile("(?i)<\\s*"+pattern+"\\s*>")!=OK:
        return false
    return rx.search(note)!=null

static func _tag_value(note:String,pattern:String)->String:
    var rx:=RegEx.new()
    if rx.compile("(?i)<\\s*"+pattern+"\\s*:\\s*([^>]+)>")!=OK:
        return ""
    var match_result:RegExMatch=rx.search(note)
    return match_result.get_string(1).strip_edges() if match_result!=null else ""

static func source_metadata(state:Dictionary)->Dictionary:
    var id:int=int(state.get("id",0))
    if id<=0 or not state.has("note"):return {}
    var note:String=str(state["note"])
    var force:bool=_tag(note,"(?:show_battle_hud|hud_show|HUD強制顯示|HUD顯示)")
    var hidden:bool=_tag(note,"(?:hide_battle_hud|hud_hide|HUD隱藏)")
    var icon:int=int(state.get("icon_index",0))
    var icon_tag:String=_tag_value(note,"(?:hud_icon|HUD圖示)")
    if icon_tag.is_valid_int():
        icon=int(icon_tag)
    var priority:int=int(state.get("priority",0))
    var priority_tag:String=_tag_value(note,"(?:hud_priority|HUD優先)")
    if priority_tag.is_valid_int():
        priority=int(priority_tag)
    var label:String=str(state.get("name",""))
    var name_tag:String=_tag_value(note,"(?:hud_name|HUD名稱)")
    if not name_tag.is_empty():label=name_tag
    return {"id":id,"icon":icon,"priority":priority,"name":label,
        "force_show":force,"hidden":(hidden and not force) or (icon<=0 and not force)}

static func visible_states(battler:Dictionary,source_db:FSDatabase)->Dictionary:
    if source_db==null or not (battler.get("states",null) is Array):
        return {"ok":false,"reason":"battler states missing","states":[]}
    var found:Array[Dictionary]=[]
    for state_id in battler["states"]:
        if not (state_id is int or state_id is float) or int(state_id)<=0:
            return {"ok":false,"reason":"bad state ID","states":[]}
        var record:Dictionary=source_db.record("states",int(state_id))
        var metadata:Dictionary=source_metadata(record)
        if metadata.is_empty():
            return {"ok":false,"reason":"missing original State.note","states":[]}
        if not bool(metadata["hidden"]):
            found.append(metadata)
    found.sort_custom(func(a:Dictionary,b:Dictionary)->bool:
        if int(a["priority"])==int(b["priority"]):
            return int(a["id"])<int(b["id"])
        return int(a["priority"])>int(b["priority"]))
    return {"ok":true,"reason":"","states":found}

static func visible_slots(states:Array)->Dictionary:
    var shown:Array=[]
    var overflow:int=0
    if states.size()>MAX_ICONS:
        # Exact #381 uses max_slots - 1 icon badges then an overflow badge.
        overflow=states.size()-MAX_ICONS+1
        shown=states.slice(0,MAX_ICONS-1)
    else:
        shown=states.slice(0,MAX_ICONS)
    return {"shown":shown,"overflow":overflow}

static func source_top_left(anchor:Vector2,is_enemy:bool)->Vector2:
    # Original actor sprite: self.x = bx-16, self.ox=0,
    # self.y = by+20, self.oy=20.
    # Enemy sprite: self.x=bx+45, self.ox=80,
    # self.y=by+20, self.oy=20.
    return anchor+Vector2(-35,0) if is_enemy else anchor+Vector2(-16,0)

func _ready()->void:
    name="FSOriginal381StateBadgeOverlay"
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    modulate.a=float(ICON_OPACITY)/255.0
    visible=false

func install(art:FSUIArtLibrary,source_db:FSDatabase)->bool:
    clear_source()
    if art==null or not art.has_source() or source_db==null:return false
    var texture:Texture2D=art.texture("system","iconset.png")
    if texture==null or texture.get_width()!=384 or (
            texture.get_height()<24):
        return false
    iconset=texture
    db=source_db
    source_enabled=true
    return true

func clear_source()->void:
    entries.clear()
    errors.clear()
    iconset=null
    db=null
    source_enabled=false
    visible=false
    queue_redraw()

func refresh(party:Array,enemies:Array,actor_anchors:Dictionary,
        enemy_anchors:Dictionary)->int:
    entries.clear()
    errors.clear()
    if not source_enabled or iconset==null or db==null:
        visible=false
        return 0
    for group in [{"units":party,"anchors":actor_anchors,"enemy":false},
            {"units":enemies,"anchors":enemy_anchors,"enemy":true}]:
        var units:Array=group["units"]
        var anchors:Dictionary=group["anchors"]
        for i in range(units.size()):
            var unit:Dictionary=units[i]
            if int(unit.get("hp",0))<=0 or not anchors.has(i):
                continue
            var quote:Dictionary=visible_states(unit,db)
            if not bool(quote["ok"]):
                errors.append(str(quote["reason"]))
                continue
            var slots:Dictionary=visible_slots(quote["states"])
            var origin:Vector2=source_top_left(
                anchors[i],bool(group["enemy"]))
            for j in range(slots["shown"].size()):
                var state:Dictionary=slots["shown"][j]
                var index:int=int(state["icon"])
                if index<0 or index>=int(
                        float(iconset.get_height()/ICON_SOURCE_CELL)*16.0):
                    errors.append("unverified icon atlas index for State "+str(
                        state["id"]))
                    continue
                entries.append({"position":origin+Vector2(j*ICON_SPACING,0),
                    "icon":index,"state_id":state["id"],
                    "kind":"enemy" if bool(group["enemy"]) else "actor"})
            if int(slots["overflow"])>0:
                entries.append({"position":origin+Vector2((MAX_ICONS-1)*
                        ICON_SPACING,0),"overflow":int(slots["overflow"]),
                    "kind":"enemy" if bool(group["enemy"]) else "actor"})
    visible=not entries.is_empty()
    queue_redraw()
    return entries.size()

func _draw()->void:
    if not source_enabled or iconset==null or entries.is_empty():return
    for entry in entries:
        var pos:Vector2=entry["position"]
        # Original: border white alpha45, black background alpha135.
        draw_rect(Rect2(pos,Vector2(ICON_SIZE,ICON_SIZE)),
            Color(1,1,1,45.0/255.0))
        draw_rect(Rect2(pos+Vector2.ONE,
                Vector2(ICON_SIZE-2,ICON_SIZE-2)),
                Color(0,0,0,135.0/255.0))
        if entry.has("icon") and int(entry["icon"])>0:
            var icon:int=int(entry["icon"])
            draw_texture_rect_region(iconset,
                Rect2(pos,Vector2(ICON_SIZE,ICON_SIZE)),
                Rect2((icon%ICON_SOURCE_COLUMNS)*ICON_SOURCE_CELL,
                    int(icon/ICON_SOURCE_COLUMNS)*ICON_SOURCE_CELL,
                    ICON_SOURCE_CELL,ICON_SOURCE_CELL))
        else:
            var count:int=int(entry.get("overflow",0))
            var font:Font=get_theme_default_font()
            if font!=null:
                draw_string(font,pos+Vector2(1,15),"+"+str(count),
                    HORIZONTAL_ALIGNMENT_CENTER,ICON_SIZE,11,
                    Color(1,1,1))
