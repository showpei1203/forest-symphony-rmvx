extends SceneTree
# P539B native complete SOURCE BATTLE scene: #232/#268/#312 & #264.
# Uses synthetic Texture2D fixture; real original 7 parallax + ten source
# command images are staged ONLY in owner-private Godot GPU QA.
const RULES=preload("res://scripts/ui/FSOriginalBattleScapeRules.gd")
const COMMANDS=preload("res://scripts/ui/FSOriginalBattleCommandLayer.gd")
const SCAPES=preload("res://scripts/ui/FSOriginalBattleScapeStage.gd")
const SCAPE_ART=preload("res://scripts/ui/FSOriginalBattleScapeArt.gd")
var executed:Array[int]=[]

func _initialize()->void:
    call_deferred("_run")

func _check(ok:bool,message:String)->bool:
    if not ok:
        push_error("P539B original complete BATTLE integration: "+message)
        quit(1)
        return false
    return true

func _on_action(n:int)->void:
    executed.append(n)

func source_tex(_name:String)->Texture2D:
    var image:=Image.create(64,64,false,Image.FORMAT_RGBA8)
    image.fill(Color(0.2,0.4,0.6,1))
    return ImageTexture.create_from_image(image)

func command_tex()->Texture2D:
    var image:=Image.create(54,48,false,Image.FORMAT_RGBA8)
    image.fill(Color(0.5,0.1,0.2,1))
    return ImageTexture.create_from_image(image)

func _run()->void:
    if not _check(RULES.resolve_ids(1,36,0)==[15,3],
            "troop 36 Ruby Hash duplicate MUST take later [15,3]"):return
    if not _check(RULES.resolve_ids(12,99,2,[1])==[1],
            "unknown positive troop uses source Ruby default [1]"):return
    if not _check(RULES.resolve_ids(12,0,2,[])==[14,3],
            "explicit empty variable 2 falls back to map 12"):return
    if not _check(RULES.resolve_ids(12,0,2,[1])==[1],
            "area source override precedes source map"):return
    if not _check(RULES.resolve_ids(12,0,1,[1])==[1],
            "nonempty variable source overrides area"):return
    if not _check(RULES.resolve_ids(33,0,2,[])==[15,3],
            "map source 33 must choose 15+3"):return
    var order:Array=RULES.describe_ids([1,3])
    if not _check(order.size()==2 and str(order[0]["name"])=="ffog" and (
            str(order[1]["name"])=="new_back00"),
            "BattleScape must sort additive fog z49 BEFORE backdrop z51"):return
    if not _check(RULES.describe_ids([1234]).is_empty(),
            "unknown original BattleScape should fail closed"):return
    var stage=SCAPES.new()
    root.add_child(stage)
    var ar:SCAPE_ART=SCAPE_ART.new()
    if not _check(not ar.has_source() and ar.texture_by_source_name("Bridge")==null,
            "public CI must never contain private BattleScape originals"):return
    if not _check(stage.configure(order,Callable(self,"source_tex"))==2 and (
            stage.planes.size()==2 and stage.visible),
            "source two-layer BattleScape native Control not built"):return
    stage._process(1.0/60.0)
    var pos_x:float=stage.planes[0]["image"].position.x
    if not _check(absf(pos_x+1.625)<0.05,
            "source #264 original fog velocity scroll_x 13/8 per frame"):return
    stage.clear_scape()
    if not _check(stage.planes.is_empty() and not stage.visible,
            "original Scene Battle backdrop must reset between transitions"):return
    var commands=COMMANDS.new()
    root.add_child(commands)
    commands.command_requested.connect(_on_action)
    var bright:Array[Texture2D]=[]
    var dimmed:Array[Texture2D]=[]
    for i in range(5):
        bright.append(command_tex())
        dimmed.append(command_tex())
    if not _check(commands.bind_textures(bright,dimmed) and (
            commands.source_buttons.size()==5),
            "all five original Battle01-05 vertical source sprites required"):return
    for i in range(5):
        var button:TextureButton=commands.source_buttons[i]
        if not _check(button.position==Vector2(
                COMMANDS.POSITION_X[i],COMMANDS.POSITION_Y[i]) and (
                Rect2(Vector2.ZERO,Vector2(544,416)).encloses(button.get_rect())),
                "original source command geometry cropped at 544x416"):return
    commands.refresh_state(true,[true,false,false,false])
    commands.activate(0)
    commands.activate(1)
    commands.activate(4)
    if not _check(executed==[1] and commands.source_buttons[4].disabled and (
            commands.source_buttons[0].disabled),
            "#312 attack-seal + unsupported Escape must never submit action"):return
    commands.choose(2)
    if not _check(commands.selected==2 and (
            commands.source_buttons[2].texture_normal==bright[2]),
            "#268 source selection colour not controlled by selected index"):return
    commands.refresh_state(false)
    commands.activate(2)
    if not _check(executed==[1] and (
            commands.source_buttons[2].disabled),
            "ATB-not-ready must refuse actual source command"):return
    print("P539B source #232/#268/#312 five vertical commands, seal, ATB, Escape HOLD; #264 original troop/variable/area/map, additive fog scroll native Godot 4.7.2 PASS (synthetic images)")
    quit(0)
