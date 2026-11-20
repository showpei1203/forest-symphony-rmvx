extends Control
class_name FSBattleActor01Presenter

# P537B: optional 45-degree A52 12-frame Body/Weapon/FX animation.
# VISUAL ONLY; actual Battle ACT costs/damage, hit timing, and decisions
# remain owned by FSBattle/FSActionQueue. NO local user:// writes.
# Source from T-A SHA pinned 072db87eaa415691a5a9cfbb71b699ae7974404d.
signal visual_contact(time_sec:float,frame:int)
const RIG=preload("res://scripts/animation/FSTAActorMotionRig.gd")
const SOURCE:Dictionary={
    "attack_body.png":"a10ea14eddd3173c48a87a31227a6a017ba8092713f6d56f95cc5d82a46fd12f",
    "attack_weapon.png":"6d274e0b1c410d1427059abe5cd4e72ae1a75a0bd43a28fc7664afe68c4a560b",
    "attack_fx.png":"46f02a3c06958a380e8333e86929a69cea7cfd6c7eec55fe616de0b6d9bec73c"}
const PATH:String="res://assets/ta_actor01/"
var rig:FSTAActorMotionRig
var private_source_ready:bool=false
var last_attack_serial:int=-1
var visual_attack_count:int=0
var contact_count:int=0

func _ready()->void:
    name="FSActor01A52BattlePresentation"
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    anchor_left=1.0
    anchor_right=1.0
    offset_left=-108.0
    offset_right=-8.0
    offset_top=72.0
    offset_bottom=168.0
    rig=RIG.new()
    rig.name="TAActor01ThreeLayers"
    rig.position=Vector2(50,48)
    add_child(rig)
    rig.contact_reached.connect(_on_visual_contact)
    private_source_ready=load_private_attack()
    visible=false

func _on_visual_contact(time_sec:float,frame:int)->void:
    contact_count+=1
    visual_contact.emit(time_sec,frame)
    # No HP, MP, action_queue or hitstop mutation here. Presentation only.

func load_private_attack()->bool:
    var actual:Array[Texture2D]=[]
    for key in ["attack_body.png","attack_weapon.png","attack_fx.png"]:
        var path:String=PATH+key
        if not FileAccess.file_exists(path) or not ResourceLoader.exists(path):
            return false
        if FileAccess.get_sha256(path)!=str(SOURCE[key]):
            return false
        var t:Texture2D=load(path) as Texture2D
        if t==null or Vector2i(t.get_size())!=Vector2i(256,192):
            return false
        actual.append(t)
    if not rig.configure_attack_only(actual[0],actual[1],actual[2]):
        return false
    return true

func sync_from_battle(battle:FSBattle)->void:
    if battle==null or not battle.active:
        visible=false
        if rig!=null:
            rig.cancel()
        return
    if not private_source_ready:
        visible=false
        return
    for record in battle.action_queue.pending.values():
        if not record is Dictionary or str(record.get("kind",""))!="attack":
            continue
        var index:int=int(record.get("actor_index",-1))
        var serial:int=int(record.get("serial",-1))
        if index<0 or index>=battle.party.size() or serial<0:
            continue
        # Actor ID 1 ONLY; not first party slot if formation changes.
        if int(battle.party[index].get("id",0))!=1:
            continue
        if last_attack_serial==serial:
            return
        last_attack_serial=serial
        visible=true
        if rig.start_motion("attack"):
            visual_attack_count+=1
        return

func cancel_visual()->void:
    if rig!=null:
        rig.cancel()
    visible=false
