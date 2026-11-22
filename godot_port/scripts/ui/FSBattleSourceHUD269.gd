extends Control
class_name FSBattleSourceHUD269

# Exact ORIGINAL Scripts.rvdata #269:
# Window_BattleStatus#set_xy 90-106; #269 draw_item 316-398;
# Sprite_strNumbers 589-655. This stage uses the REAL system PNGs,
# not a redesigned top-of-screen HFlowContainer. Extra actor ID>=7
# is not source-verified and must use the old fallback, never fake skin.
const SOURCE_SECTION:int=269
const BG_SIZE:Vector2i=Vector2i(135,40)
const BAR_SIZE:Vector2i=Vector2i(77,20)
const DIGIT_ATLAS_SIZE:Vector2i=Vector2i(120,48)
const PORTRAIT_SIZE:Vector2i=Vector2i(135,135)
const PORTRAITS:Dictionary={
    "喬伊":"HUD_喬伊.png","泰勒":"HUD_泰勒.png",
    "米亞":"HUD_米亞.png","艾卓":"HUD_艾卓.png",
    "艾薇":"HUD_艾薇.png","維娜":"HUD_維娜.png"}
var art:FSUIArtLibrary
var source_enabled:bool=false
var images:Dictionary={}
var actors:Array[Dictionary]=[]

static func source_base(index:int)->Vector2:
    # #269 @x=(index*139+40)+176, @y=3+342+26;
    # s[0] adds BTSKIN_B_XY(-179,-17)+BTSKIN_00XY(-28,+17).
    return Vector2(9.0+139.0*index,371.0)

static func source_portrait(index:int)->Vector2:
    # #269 s[16]: @x+12-219, @y-4+224-342.
    return Vector2(9.0+139.0*index,249.0)

static func source_gauge(index:int,kind:String)->Vector2:
    var x:float=52.0+139.0*index
    return Vector2(x,374.0 if kind=="hp" else 387.0)

static func source_number(index:int,kind:String)->Vector2:
    match kind:
        "hp":return Vector2(66.0+139.0*index,370.0)
        "mp":return Vector2(70.0+139.0*index,384.0)
        "od":return Vector2(74.0+139.0*index,397.0)
    return Vector2(-1000,-1000)

static func source_gauge_width(value:int,maximum:int)->int:
    if maximum<=0:return 0
    # #269 s[11]/s[12] rounds down with +1 for nonzero source values.
    return clampi(int(77.0*float(maxi(0,value))/float(maximum)+1.0),0,77)

func _ready()->void:
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    visible=false

func clear_source()->void:
    source_enabled=false
    actors.clear()
    images.clear()
    visible=false
    queue_redraw()

func install(provider:FSUIArtLibrary,party:Array)->bool:
    if provider==null or not provider.has_source() or (
            party.is_empty()) or party.size()>3:
        clear_source()
        return false
    var gathered:Dictionary={}
    var skins:Dictionary={
        "background":"Btskin_main.png","hp":"Btskin_hp.png",
        "mp":"Btskin_mp.png","numbers":"Btskin_n00.png",
        "od_numbers":"Btskin_n01.png"}
    for key in skins:
        var tex:Texture2D=provider.texture("system",skins[key])
        if tex==null:
            clear_source()
            return false
        gathered[key]=tex
    if Vector2i(gathered["background"].get_size())!=BG_SIZE or (
            Vector2i(gathered["hp"].get_size())!=BAR_SIZE) or (
            Vector2i(gathered["mp"].get_size())!=BAR_SIZE) or (
            Vector2i(gathered["numbers"].get_size())!=DIGIT_ATLAS_SIZE) or (
            Vector2i(gathered["od_numbers"].get_size())!=DIGIT_ATLAS_SIZE):
        clear_source()
        return false
    for actor in party:
        if not actor is Dictionary or int(actor.get("id",0))<1 or (
                int(actor.get("id",0))>=7):
            clear_source()
            return false
        var name:String=str(actor.get("name",""))
        if not PORTRAITS.has(name):
            clear_source()
            return false
        var portrait:Texture2D=provider.texture(
            "system",str(PORTRAITS[name]))
        if portrait==null or Vector2i(portrait.get_size())!=PORTRAIT_SIZE:
            clear_source()
            return false
        gathered[name]=portrait
    art=provider
    images=gathered
    source_enabled=true
    refresh(party)
    visible=true
    return true

func refresh(party:Array)->void:
    if not source_enabled:return
    if party.size()!=actors.size() and not actors.is_empty():
        clear_source()
        return
    actors.clear()
    for actor in party:
        if not actor is Dictionary or not images.has(str(actor.get("name",""))):
            clear_source()
            return
        actors.append(actor)
    queue_redraw()

func _draw_gauge(tex:Texture2D,pos:Vector2,value:int,maximum:int)->void:
    # Source Btskin_hp/mp are exactly 77x20, first 10px current-fill,
    # second 10px delayed/background gauge. The source #269 draws both.
    draw_texture_rect_region(tex,Rect2(pos,Vector2(77,10)),
        Rect2(0,10,77,10))
    var width:int=source_gauge_width(value,maximum)
    if width>0:
        draw_texture_rect_region(tex,Rect2(pos,Vector2(width,10)),
            Rect2(0,0,width,10))

func _draw_number(tex:Texture2D,value:int,at:Vector2)->void:
    var positive:int=clampi(value,0,9999)
    for digit in range(4):
        var divisor:int=int(pow(10,3-digit))
        var number:int=(positive/divisor)%10
        if number==0 and positive<divisor and digit<3:
            continue
        var row:int=0
        if tex==images.get("od_numbers"):
            if positive>=1000:row=2
            elif positive>250:row=1
        elif positive<=0:
            row=2
        # 120x48 = ten 12x16 glyphs per row, original Sprite_strNumber.
        draw_texture_rect_region(tex,
            Rect2(at+Vector2(digit*12,0),Vector2(12,16)),
            Rect2(number*12,row*16,12,16))

func _draw()->void:
    if not source_enabled:return
    for i in range(actors.size()):
        var actor:Dictionary=actors[i]
        var name:String=str(actor.get("name",""))
        draw_texture(images[name],source_portrait(i))
        draw_texture(images["background"],source_base(i))
        _draw_gauge(images["hp"],source_gauge(i,"hp"),
            int(actor.get("hp",0)),int(actor.get("maxhp",0)))
        _draw_gauge(images["mp"],source_gauge(i,"mp"),
            int(actor.get("mp",0)),int(actor.get("maxmp",0)))
        _draw_number(images["numbers"],int(actor.get("hp",0)),
            source_number(i,"hp"))
        _draw_number(images["numbers"],int(actor.get("mp",0)),
            source_number(i,"mp"))
        _draw_number(images["od_numbers"],int(actor.get("od",0)),
            source_number(i,"od"))
