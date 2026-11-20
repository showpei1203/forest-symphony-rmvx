extends Control
class_name FSBattleOriginalEnemyStage

# P537C: read-only source Battler display. No hitboxes, no damage authority,
# no guessed BattleScape backdrop. Live party/target logic stays in FSBattle.
const ART=preload("res://scripts/ui/FSOriginalBattlerArt.gd")
var art:FSOriginalBattlerArt
var enemy_views:Array[Dictionary]=[]
var _layout:HBoxContainer
var _signature:String=""

func _ready()->void:
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    art=ART.new()
    set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
    offset_left=-318.0
    offset_right=-116.0
    offset_top=91.0
    offset_bottom=192.0
    clip_contents=true
    _layout=HBoxContainer.new()
    _layout.name="FSSourceEnemySprites"
    _layout.mouse_filter=Control.MOUSE_FILTER_IGNORE
    _layout.add_theme_constant_override("separation",2)
    _layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(_layout)
    visible=false

func clear_enemies()->void:
    if _layout==null:
        return
    for child in _layout.get_children():
        _layout.remove_child(child)
        child.queue_free()
    enemy_views.clear()
    _signature=""
    visible=false

func rebuild(enemies:Array,lookup:Callable)->int:
    # This injectable pure visual callback is used ONLY by native fixture tests;
    # production always calls art.texture_for_enemy below.
    clear_enemies()
    if not lookup.is_valid():
        return 0
    for i in range(enemies.size()):
        var enemy:Dictionary=enemies[i]
        var source:Variant=lookup.call(enemy)
        if not source is Texture2D:
            continue
        var t:Texture2D=source
        if t.get_width()<1 or t.get_height()<1:
            continue
        var holder:=VBoxContainer.new()
        holder.name="OriginalEnemy_%d" % i
        holder.custom_minimum_size=Vector2(64,100)
        holder.add_theme_constant_override("separation",1)
        holder.mouse_filter=Control.MOUSE_FILTER_IGNORE
        _layout.add_child(holder)
        var image:=TextureRect.new()
        image.name="SourceBattlerImage"
        image.texture=t
        image.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        image.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
        image.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
        image.custom_minimum_size=Vector2(64,78)
        image.mouse_filter=Control.MOUSE_FILTER_IGNORE
        holder.add_child(image)
        var caption:=Label.new()
        caption.name="SourceBattlerName"
        caption.text=str(enemy.get("name","?"))
        caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
        caption.add_theme_font_size_override("font_size",10)
        holder.add_child(caption)
        enemy_views.append({"index":i,"view":holder,"caption":caption,
            "image":image,"source_name":str(enemy.get("battler_name",""))})
    visible=not enemy_views.is_empty()
    refresh(enemies)
    return enemy_views.size()

func bind_real(battle:FSBattle)->int:
    if battle==null or not battle.active or art==null or not art.has_source():
        clear_enemies()
        return 0
    # Reject unsupported source hue. No arbitrary palette approximations.
    return rebuild(battle.enemies,func(enemy:Dictionary)->Texture2D:
        return art.texture_for_enemy(enemy))

func refresh(enemies:Array)->void:
    var count:int=0
    for row in enemy_views:
        var i:int=row["index"]
        if i<0 or i>=enemies.size():
            continue
        var live:Dictionary=enemies[i]
        var v:Control=row["view"]
        v.visible=int(live.get("hp",0))>0
        if v.visible:
            count+=1
        var caption:Label=row["caption"]
        caption.text=str(live.get("name","?"))
    visible=count>0
