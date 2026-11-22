extends Control
class_name FSOriginalBattleScapeStage

# Source #264 Spriteset_Battle parallax planes: z, opacity, additive fog,
# scrolling is 2*source_scroll/16 for each original 60Hz frame.
# Bridge and BlueSky not present in source graphics; no fake fallback.
const RULES=preload("res://scripts/ui/FSOriginalBattleScapeRules.gd")
const ORIGINAL_ART=preload("res://scripts/ui/FSOriginalBattleScapeArt.gd")
var art:FSOriginalBattleScapeArt
var planes:Array[Dictionary]=[]
var last_scape_ids:Array=[]
var unavailable_names:Array[String]=[]

func _ready()->void:
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    clip_contents=true
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    art=ORIGINAL_ART.new()
    visible=false

func clear_scape()->void:
    for child in get_children():
        remove_child(child)
        child.queue_free()
    planes.clear()
    last_scape_ids.clear()
    unavailable_names.clear()
    visible=false

func bind_source(world:FSGameState,troop_id:int,area_ids:Array=[])->int:
    if world==null or art==null or not art.has_source():
        clear_scape()
        return 0
    var selected:Array=RULES.resolve_ids(world.map_id,troop_id,
        world.variable(RULES.VARIABLE_ID),area_ids)
    var descriptions:Array=RULES.describe_ids(selected)
    if descriptions.size()!=selected.size():
        clear_scape()
        return 0
    var result:int=configure(descriptions,Callable(art,"texture_by_source_name"))
    if result>0:
        last_scape_ids=selected
    return result

func configure(description:Array,source_lookup:Callable)->int:
    clear_scape()
    if not source_lookup.is_valid() or description.is_empty():
        return 0
    var prepared:Array=[]
    for layer in description:
        if not layer is Dictionary:
            return 0
        var n:String=str(layer.get("name",""))
        var texture:Variant=source_lookup.call(n)
        if not texture is Texture2D:
            unavailable_names.append(n)
            return 0
        prepared.append({"source":layer,"texture":texture})
    for row in prepared:
        var attrs:Dictionary=row["source"]
        var tex:Texture2D=row["texture"]
        var node:=TextureRect.new()
        node.name="SourceScape_"+str(attrs.get("id",0))
        node.mouse_filter=Control.MOUSE_FILTER_IGNORE
        node.texture=tex
        node.texture_repeat=CanvasItem.TEXTURE_REPEAT_ENABLED
        node.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        node.stretch_mode=TextureRect.STRETCH_TILE
        node.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
        node.size=Vector2(544+tex.get_width(),416+tex.get_height())
        node.modulate=Color(1,1,1,float(attrs.get("opacity",255))/255.0)
        node.scale=Vector2(float(attrs.get("zoom_x",1.0)),float(attrs.get("zoom_y",1.0)))
        if int(attrs.get("blend",0))==1:
            var material:=CanvasItemMaterial.new()
            material.blend_mode=CanvasItemMaterial.BLEND_MODE_ADD
            node.material=material
        add_child(node)
        planes.append({"image":node,"source":attrs,"time":0.0})
    visible=not planes.is_empty()
    return planes.size()

func _process(delta:float)->void:
    if not visible or delta<=0.0:
        return
    for plane in planes:
        var layer:Dictionary=plane["source"]
        var image:TextureRect=plane["image"]
        plane["time"]=float(plane["time"])+delta
        var tex:Texture2D=image.texture
        if tex==null:continue
        var frames:float=float(plane["time"])*60.0
        var sx:float=float(layer.get("scroll_x",0))*frames/8.0
        var sy:float=float(layer.get("scroll_y",0))*frames/8.0
        image.position=Vector2(
            -fposmod(sx,maxf(1.0,float(tex.get_width()))),
            -fposmod(sy,maxf(1.0,float(tex.get_height()))))
