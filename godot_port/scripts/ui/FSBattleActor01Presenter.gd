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
# Presentation identity is scoped to a battle instance and ACT serial.
# Never use an animation as gameplay damage or force-execution authority.
var _bound_battle:WeakRef
var _visual_serial:int=-1
var _visual_subject:Dictionary={}


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
    # P539D owner visual correction: the earlier A52 45-degree portrait
    # faces the WRONG horizontal side in the battle composition.
    # Mirror the COMPLETE Body/Weapon/FX rig as ONE assembly, around its
    # fixed cell centre. Not a 180-degree upside-down sprite rotation.
    # The source atlases stay byte-exact; visual orientation only.
    rig.scale=Vector2(-1.0,1.0)
    add_child(rig)
    rig.contact_reached.connect(_on_visual_contact)
    rig.motion_finished.connect(_on_visual_finished)
    private_source_ready=load_private_attack()
    visible=false

func _on_visual_contact(time_sec:float,frame:int)->void:
    contact_count+=1
    visual_contact.emit(time_sec,frame)
    # No HP, MP, action_queue or hitstop mutation here. Presentation only.

func _on_visual_finished(_motion:String)->void:
    # An accepted original animation may finish; never leave F11 frozen.
    visible=false
    _visual_serial=-1
    _visual_subject={}

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

func _visual_still_authorized(battle:FSBattle)->bool:
    if _visual_serial<0:
        return true
    var found:bool=false
    for subject in battle.party:
        if is_same(subject,_visual_subject) and int(subject.get("hp",0))>0:
            found=true
            break
    if not found:
        return false
    for record in battle.action_queue.pending.values():
        if record is Dictionary and int(record.get("serial",-1))==_visual_serial:
            var index:int=int(record.get("actor_index",-1))
            return index>=0 and index<battle.party.size() and (
                is_same(battle.party[index],_visual_subject)) and str(record.get("kind",""))=="attack"
    # A successful normal ACT may finish its presentation; an interrupted,
    # refused or force-replaced ACT has no successful matching receipt.
    for receipt in battle.action_queue.completed:
        if int(receipt.get("serial",-1))==_visual_serial:
            return str(receipt.get("kind",""))=="attack" and bool(receipt.get("success",false))
    return false

func sync_from_battle(battle:FSBattle)->void:
    if _bound_battle==null or not is_same(_bound_battle.get_ref(),battle):
        cancel_visual()
        last_attack_serial=-1
        _bound_battle=weakref(battle) if battle!=null else null
    if battle==null or not battle.active or not private_source_ready:
        cancel_visual()
        return
    if not _visual_still_authorized(battle):
        cancel_visual()
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
        if int(battle.party[index].get("hp",0))<=0:
            cancel_visual()
            return
        if last_attack_serial==serial:
            return
        cancel_visual()
        last_attack_serial=serial
        _visual_serial=serial
        _visual_subject=battle.party[index]
        visible=true
        if rig.start_motion("attack"):
            visual_attack_count+=1
        else:
            cancel_visual()
        return

func cancel_visual()->void:
    if rig!=null:
        rig.cancel()
    visible=false
    _visual_serial=-1
    _visual_subject={}
