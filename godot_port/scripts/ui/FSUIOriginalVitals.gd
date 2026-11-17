extends Control
class_name FSUIOriginalVitals

# P536: Reconstruct source Btskin_main 135x40 with source-only HP/MP/OD
# horizontal fill strips, NOT whole 120x48 sprite-sheet ornaments.
# Exact original pixel atlas layout was inspected from private, hash-pinned
# FS_GODOT_UI_ORIGINAL_PRIVATE_20261118.zip. All gameplay values are read-only.
const BG_SIZE:=Vector2i(135,40)
const STRIP_ATLAS_SIZE:=Vector2i(120,48)
const STRIP_RECT:=Rect2(0,42,72,6)
const FILL_X:float=47.0
const HP_Y:float=7.0
const MP_Y:float=19.0
const OD_Y:float=31.0

var source_bg:Texture2D
var source_hp:Texture2D
var source_mp:Texture2D
var source_od:Texture2D
var hp_rate:float=0.0
var mp_rate:float=0.0
var od_rate:float=0.0

static func fill_width(rate:float)->int:
    # Full 72px fill at 100%; zero pixels at 0%; no imaginary image resize.
    if is_nan(rate) or is_inf(rate):
        return 0
    return clampi(int(round(clampf(rate,0.0,1.0)*72.0)),0,72)

static func fill_source_region(rate:float)->Rect2:
    var width:int=fill_width(rate)
    return Rect2(STRIP_RECT.position,Vector2(float(width),STRIP_RECT.size.y))

func install_art(provider:FSUIArtLibrary)->bool:
    if provider==null:
        return false
    source_bg=provider.texture("system","Btskin_main.png")
    source_hp=provider.texture("system","GaugeHP.png")
    source_mp=provider.texture("system","GaugeMP.png")
    source_od=provider.texture("system","GaugeOD.png")
    if source_bg==null or source_hp==null or source_mp==null or source_od==null:
        return false
    if Vector2i(source_bg.get_size())!=BG_SIZE:
        return false
    for tex in [source_hp,source_mp,source_od]:
        if Vector2i(tex.get_size())!=STRIP_ATLAS_SIZE:
            return false
    custom_minimum_size=Vector2(BG_SIZE)
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    queue_redraw()
    return true

func set_values(actor:Dictionary)->void:
    hp_rate=_ratio(actor.get("hp",0),actor.get("maxhp",0))
    mp_rate=_ratio(actor.get("mp",0),actor.get("maxmp",0))
    # OD cap is not a universal FS constant; only use source-known max.
    # Unknown OD maximum means NO filled gauge, rather than fabricate 100.
    od_rate=_ratio(actor.get("od",0),actor.get("od_max",0))
    queue_redraw()

static func _ratio(value:Variant,maximum:Variant)->float:
    var den:float=float(maximum)
    if not is_finite(den) or den<=0.0:
        return 0.0
    return clampf(float(value)/den,0.0,1.0)

func _source_fill(texture:Texture2D,where_y:float,rate:float)->void:
    var part:Rect2=fill_source_region(rate)
    if texture==null or part.size.x<=0.0:
        return
    var destination:=Rect2(Vector2(FILL_X,where_y),part.size)
    draw_texture_rect_region(texture,destination,part)

func _draw()->void:
    if source_bg==null:
        return
    draw_texture(source_bg,Vector2.ZERO)
    _source_fill(source_hp,HP_Y,hp_rate)
    _source_fill(source_mp,MP_Y,mp_rate)
    _source_fill(source_od,OD_Y,od_rate)
