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

# #381 lines 429-531 + 579-628: read the original actor's live
# state-stack and remaining-turn tables, never invent an expiry time.
const PARAMETER_STATE_DETAIL:Dictionary={
    54:"攻擊+20%",55:"防禦+20%",56:"精神+20%",57:"敏捷+20%",
    58:"攻擊-20%",59:"防禦-20%",60:"精神-20%",61:"敏捷-20%"}

static func source_max_stack(state:Dictionary)->int:
    var source_note:String=str(state.get("note",""))
    var matcher:=RegEx.new()
    if matcher.compile("(?i)<\\s*(?:MAX_STACK|max stack)\\s*(\\d+)\\s*>")==OK:
        var found:RegExMatch=matcher.search(source_note)
        if found!=null:
            return maxi(1,int(found.get_string(1)))
    return maxi(1,int(state.get("max_stack",1)))

static func _source_table_count(battler:Dictionary,field:String,id:int,
        fallback:int)->int:
    var table:Variant=battler.get(field,null)
    if table is Dictionary:
        if table.has(id):return int(table[id])
        if table.has(str(id)):return int(table[str(id)])
    elif table is Array:
        if id<table.size():return int(table[id])
    return fallback

static func source_stack(battler:Dictionary,state:Dictionary)->int:
    var id:int=int(state.get("id",0))
    if id<=0 or not (id in battler.get("states",[])):
        return 0
    # Source #381 state_stack = MAX of all verified stack providers,
    # falling back to one when no state-stack provider is present.
    var a:int=_source_table_count(battler,"state_stack",id,1)
    var b:int=_source_table_count(battler,"fs_state_stack",id,1)
    return maxi(1,maxi(a,b))

static func source_turns(battler:Dictionary,state:Dictionary)->int:
    var id:int=int(state.get("id",0))
    if id<=0 or not (id in battler.get("states",[])):
        return 0
    return maxi(0,_source_table_count(battler,"state_turns",id,0))

static func source_detail(battler:Dictionary,state:Dictionary)->Dictionary:
    var meta:Dictionary=source_metadata(state)
    if meta.is_empty():return {}
    var maximum:int=source_max_stack(state)
    var stack:int=source_stack(battler,state)
    var turns:int=source_turns(battler,state)
    var note:String=str(state.get("note",""))
    var custom:String=_tag_value(note,"(?:hud_detail_text|HUD詳細文字)")
    var force_detail:bool=_tag(note,"(?:hud_detail|HUD詳細)")
    var show_turns:bool=_tag(note,"(?:hud_show_turns|HUD顯示回合)")
    var parts:Array[String]=[]
    if not str(meta["name"]).is_empty():
        parts.append(str(meta["name"]))
    var sid:int=int(meta["id"])
    if PARAMETER_STATE_DETAIL.has(sid):
        parts.append(str(PARAMETER_STATE_DETAIL[sid]))
    if maximum>1 or stack>1:
        parts.append("層數%d/%d" % [stack,maximum] if maximum>1 else (
            "層數%d" % stack))
    if turns>0:
        parts.append("剩%d回合" % turns)
    if not custom.is_empty():
        parts.append(custom)
    var qualified:bool=maximum>1 or stack>1 or turns>0 or (
        force_detail or not custom.is_empty() or
        PARAMETER_STATE_DETAIL.has(sid))
    return {"id":sid,"icon":int(meta["icon"]),"name":str(meta["name"]),
        "max_stack":maximum,"stack":stack,"turns":turns,
        "show_turns":show_turns,"qualified":qualified,
        "text":"｜".join(PackedStringArray(parts))}

static func detail_rows(battler:Dictionary,source_db:FSDatabase,
        max_rows:int=12)->Dictionary:
    var visible:Dictionary=visible_states(battler,source_db)
    if not bool(visible.get("ok",false)):
        return {"ok":false,"rows":[],"reason":str(visible.get("reason",""))}
    var rows:Array[Dictionary]=[]
    for state in visible["states"]:
        var record:Dictionary=source_db.record("states",int(state["id"]))
        var detail:Dictionary=source_detail(battler,record)
        if bool(detail.get("qualified",false)):
            rows.append(detail)
        if rows.size()>=max_rows:break
    return {"ok":true,"rows":rows,"reason":""}

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

static func enemy_anchor_from_rect(bounds:Rect2)->Vector2:
    # RGSS2 battler screen_y/position_y is the feet baseline, not the
    # centre of a displayed sprite. Convert our TextureRect accordingly.
    return Vector2(bounds.get_center().x,bounds.end.y)

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
                var actual:Dictionary=db.record("states",int(state["id"]))
                var extra:Dictionary=source_detail(unit,actual)
                entries.append({"position":origin+Vector2(j*ICON_SPACING,0),
                    "icon":index,"state_id":state["id"],
                    "stack":int(extra.get("stack",1)),
                    "max_stack":int(extra.get("max_stack",1)),
                    "turns":int(extra.get("turns",0)),
                    "auto_release_prob":int(actual.get("auto_release_prob",0)),
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
            var stack:int=int(entry.get("stack",1))
            var maximum:int=int(entry.get("max_stack",1))
            var turns:int=int(entry.get("turns",0))
            var badge_value:int=0
            var badge_color:Color=Color(1,226.0/255.0,72.0/255.0)
            var badge_back:Color=Color(72.0/255.0,48.0/255.0,0,225.0/255.0)
            # Source #381 lines 1255-1272: stack dominates timed turns.
            if maximum>1 and stack>1:
                badge_value=stack
            elif maximum<=1 and turns>0 and (
                    int(entry.get("auto_release_prob",0))>0):
                badge_value=turns
                badge_color=Color(96.0/255.0,232.0/255.0,1)
                badge_back=Color(0,42.0/255.0,72.0/255.0,230.0/255.0)
            if badge_value>0:
                var badge_rect:=Rect2(pos+Vector2(7,6),Vector2(13,14))
                draw_rect(badge_rect,badge_back)
                var badge_font:Font=get_theme_default_font()
                if badge_font!=null:
                    draw_string(badge_font,pos+Vector2(7,17),
                        str(badge_value),HORIZONTAL_ALIGNMENT_CENTER,
                        13,13,badge_color)
        else:
            var count:int=int(entry.get("overflow",0))
            var font:Font=get_theme_default_font()
            if font!=null:
                draw_string(font,pos+Vector2(1,15),"+"+str(count),
                    HORIZONTAL_ALIGNMENT_CENTER,ICON_SIZE,11,
                    Color(1,1,1))
