extends Control
class_name FSOriginalBattleCommandLayer

# Source #232 five 54x48 Sprite commands, #268 selected colours, #312 seal.
# Terminal x after source 65px slide: 410/411/422/443/469.
# Escape is source artwork, disabled until actual source escape is supported.
signal command_requested(source_index:int)
const POSITION_X=[410,411,422,443,469]
const POSITION_Y=[230,267,302,333,360]
var source_enabled:bool=false
var selected:int=0
var source_buttons:Array[TextureButton]=[]
var active_textures:Array[Texture2D]=[]
var dim_textures:Array[Texture2D]=[]
var command_ready:bool=false
var command_sealed:Array[bool]=[false,false,false,false,true]

func _ready()->void:
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    visible=false

func reset_visual()->void:
    for button in source_buttons:
        if is_instance_valid(button):
            remove_child(button)
            button.queue_free()
    source_buttons.clear()
    active_textures.clear()
    dim_textures.clear()
    source_enabled=false
    command_ready=false
    visible=false
    selected=0

func bind_original(art:FSUIArtLibrary)->bool:
    if art==null or not art.has_source():
        reset_visual()
        return false
    var bright:Array[Texture2D]=[]
    var dimmed:Array[Texture2D]=[]
    for i in range(5):
        var n:String="Battle%02d" % (i+1)
        var src_active:Texture2D=art.texture("menu",n+".png")
        var src_dim:Texture2D=art.texture("menu",n+"a.png")
        if src_active==null or src_dim==null or (
                Vector2i(src_active.get_size())!=Vector2i(54,48)) or (
                Vector2i(src_dim.get_size())!=Vector2i(54,48)):
            reset_visual()
            return false
        bright.append(src_active)
        dimmed.append(src_dim)
    return bind_textures(bright,dimmed)

func bind_textures(bright:Array[Texture2D],dimmed:Array[Texture2D])->bool:
    reset_visual()
    if bright.size()!=5 or dimmed.size()!=5:
        return false
    for i in range(5):
        if bright[i]==null or dimmed[i]==null or (
                bright[i].get_size()!=Vector2(54,48)) or (
                dimmed[i].get_size()!=Vector2(54,48)):
            reset_visual()
            return false
    active_textures=bright.duplicate()
    dim_textures=dimmed.duplicate()
    for i in range(5):
        var index:int=i
        var btn:=TextureButton.new()
        btn.name="SourceBattleCommand%02d" % (i+1)
        btn.position=Vector2(POSITION_X[i],POSITION_Y[i])
        btn.custom_minimum_size=Vector2(54,48)
        btn.size=Vector2(54,48)
        btn.texture_normal=dim_textures[i]
        btn.texture_disabled=dim_textures[i]
        btn.focus_mode=Control.FOCUS_NONE
        btn.mouse_filter=Control.MOUSE_FILTER_STOP
        btn.stretch_mode=TextureButton.STRETCH_KEEP
        btn.pressed.connect(func()->void:activate(index))
        add_child(btn)
        source_buttons.append(btn)
    source_enabled=true
    visible=true
    refresh_state(false)
    return true

func choose(index:int)->void:
    if not source_enabled or index<0 or index>=5:
        return
    selected=index
    refresh_state(command_ready,command_sealed)

func refresh_state(ready:bool,sealed:Array=[])->void:
    if not source_enabled:
        return
    command_ready=ready
    command_sealed=[false,false,false,false,true]
    for i in range(mini(4,sealed.size())):
        command_sealed[i]=bool(sealed[i])
    for i in range(source_buttons.size()):
        var btn:TextureButton=source_buttons[i]
        var allowed:bool=ready and not command_sealed[i]
        btn.disabled=not allowed
        btn.texture_normal=active_textures[i] if (
            i==selected and allowed) else dim_textures[i]
        btn.texture_hover=active_textures[i] if allowed else dim_textures[i]
        btn.texture_pressed=active_textures[i] if allowed else dim_textures[i]

func activate(index:int)->void:
    if not source_enabled or index<0 or index>=5:
        return
    choose(index)
    if not command_ready or command_sealed[index] or index==4:
        return
    command_requested.emit(index)

func _unhandled_key_input(event:InputEvent)->void:
    if not visible or not source_enabled or not event is InputEventKey:
        return
    var input:InputEventKey=event
    if not input.pressed or input.echo:
        return
    if input.keycode==KEY_UP:
        choose((selected+4)%5)
        accept_event()
    elif input.keycode==KEY_DOWN:
        choose((selected+1)%5)
        accept_event()
    elif input.keycode==KEY_ENTER or input.keycode==KEY_KP_ENTER or (
            input.keycode==KEY_SPACE):
        activate(selected)
        accept_event()
