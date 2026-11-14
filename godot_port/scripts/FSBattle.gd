extends RefCounted
class_name FSBattle

# Candidate baseline only. For exact FS parity, trace RGSS2 last-wins aliases and tags.
signal changed(message: String)
signal finished(victory: bool)

var db: FSDatabase
var party: Array[Dictionary] = []
var enemies: Array[Dictionary] = []
var inventory: Dictionary = {}  # keys "item:<id>" / "weapon:<id>" / "armor:<id>"
var world: FSGameState
var active: bool = false
var pending_actor: int = -1

func _init(database: FSDatabase, shared_world: FSGameState = null) -> void:
    db = database
    world = shared_world
    if world != null:
        # One shared inventory is mandatory for event reward + MENU + BATTLE parity.
        inventory = world.inventory

func add_actor(actor_id: int) -> bool:
    var battler: Dictionary = db.apply_equipment(db.actor_stats(actor_id))
    if battler.is_empty():
        return false
    battler["hp"] = max(1, int(battler.get("maxhp", 1)))
    battler["mp"] = max(0, int(battler.get("maxmp", 0)))
    battler["od"] = 0
    battler["atb"] = 0.0
    battler["guarding"] = false
    party.append(battler)
    return true

func add_enemy(enemy_id: int) -> bool:
    var battler: Dictionary = db.enemy_stats(enemy_id)
    if battler.is_empty():
        return false
    battler["hp"] = max(1, int(battler.get("maxhp", 1)))
    battler["mp"] = max(0, int(battler.get("maxmp", 0)))
    battler["od"] = 0
    battler["atb"] = 0.0
    battler["guarding"] = false
    enemies.append(battler)
    return true

func start() -> bool:
    active = not party.is_empty() and not enemies.is_empty()
    changed.emit("進入戰鬥" if active else "未選擇有效隊伍／敵人")
    return active

func attack(attacker: Dictionary, target: Dictionary) -> int:
    # RPG Maker VX unmodified baseline: max(0, ATK*4 - DEF*2).
    # Element, variance, hit/evade, guard, critical, Cover and custom authority NOT PORTED.
    var raw_damage: int = maxi(0, int(attacker.get("atk", 0)) * 4 - int(target.get("def", 0)) * 2)
    var damage: int = raw_damage / 2 if bool(target.get("guarding", false)) else raw_damage
    target["hp"] = maxi(0, int(target.get("hp", 0)) - damage)
    changed.emit("%s 攻擊 %s：%d 傷害" % [attacker.get("name", "?"), target.get("name", "?"), damage])
    _check_end()
    return damage

func use_skill(user: Dictionary, target: Dictionary, skill_id: int) -> bool:
    var skill := db.record("skills", skill_id)
    if skill.is_empty():
        changed.emit("找不到技能 ID %d" % skill_id)
        return false
    var mp_cost: int = int(skill.get("mp_cost", 0))
    if int(user.get("mp", 0)) < mp_cost:
        changed.emit("MP 不足")
        return false
    user["mp"] = int(user["mp"]) - mp_cost
    var val: int = int(skill.get("base_damage", 0))
    if val > 0:
        val += int(user.get("atk", 0)) * 4 * int(skill.get("atk_f", 0)) / 100
        val += int(user.get("spi", 0)) * 2 * int(skill.get("spi_f", 0)) / 100
        if not bool(skill.get("ignore_defense", false)):
            val -= int(target.get("def", 0)) * 2 * int(skill.get("atk_f", 0)) / 100
            val -= int(target.get("spi", 0)) * int(skill.get("spi_f", 0)) / 100
        val = maxi(0, val)
    target["hp"] = clampi(int(target.get("hp", 0)) - val, 0, maxi(1, int(target.get("maxhp", 1))))
    changed.emit("%s 使用 %s：HP 變化 %d" % [user.get("name", "?"), skill.get("name", "?"), -val])
    _check_end()
    return true

func use_item(target: Dictionary, item_id: int) -> bool:
    var key: String = "item:%d" % item_id
    var count: int = int(inventory.get(key, 0))
    var item := db.record("items", item_id)
    if count <= 0 or item.is_empty():
        changed.emit("沒有該物品")
        return false
    # Item effects/consumability/target scope vary by game tags; require trace.
    # Fails closed instead of applying a made-up healing formula.
    changed.emit("物品效果待 RGSS2 核對，未消耗物品：" + str(item.get("name", "?")))
    return false

func equip(actor_index: int, slot: int, item_id: int) -> bool:
    # Source: Game_Actor.change_equip and equippable? (base authority).
    # Class weapon_set/armor_set, item.kind, dual-wield, and two_handed are
    # enforced; later FS custom slot overrides remain a separate parity gate.
    if actor_index < 0 or actor_index >= party.size():
        return false
    var actor: Dictionary = party[actor_index]
    if not db.can_equip(actor,slot,item_id):
        changed.emit("職業／裝備欄位限制，或角色裝備固定")
        return false
    var kind: String = db.equip_kind(actor,slot)
    var item: Dictionary = db.record(kind,item_id)
    var slots: Array = actor.get("equipment",[]).duplicate()
    if slots.size() != 5:
        return false
    var old_id: int = int(slots[slot])
    if item_id == old_id:
        return true

    var new_key: String = ("weapon:" if kind == "weapons" else "armor:") + str(item_id)
    if item_id > 0 and int(inventory.get(new_key,0)) < 1:
        changed.emit("背包中沒有指定裝備")
        return false
    # Compute a full atomic swap before changing ANY inventory or actor stat.
    var next_slots: Array = slots.duplicate()
    next_slots[slot] = item_id
    # Source Game_Actor.two_hands_legal?: if first hand is two-handed,
    # the second must be empty; if second weapon is two-handed, first empty.
    var main: Dictionary = db.record("weapons",int(next_slots[0]))
    var second: Dictionary = db.record(
        "weapons" if bool(actor.get("two_swords_style",false)) else "armors",
        int(next_slots[1]))
    if int(next_slots[0]) > 0 and bool(main.get("two_handed",false)) and int(next_slots[1]) > 0:
        next_slots[1 if slot == 0 else 0] = 0
    elif bool(actor.get("two_swords_style",false)) and int(next_slots[1]) > 0 and bool(second.get("two_handed",false)) and int(next_slots[0]) > 0:
        next_slots[0 if slot == 1 else 1] = 0

    var changes: Dictionary = {}
    for i in range(5):
        if int(slots[i]) == int(next_slots[i]):
            continue
        var slot_kind: String = db.equip_kind(actor,i)
        var key_old: String = ("weapon:" if slot_kind == "weapons" else "armor:") + str(slots[i])
        var key_new: String = ("weapon:" if slot_kind == "weapons" else "armor:") + str(next_slots[i])
        if int(slots[i]) > 0:
            changes[key_old] = int(changes.get(key_old,0)) + 1
        if int(next_slots[i]) > 0:
            changes[key_new] = int(changes.get(key_new,0)) - 1
    for key in changes:
        if int(inventory.get(key,0)) + int(changes[key]) < 0:
            changed.emit("裝備交換後背包數量不足：" + str(key))
            return false
    # All checks passed: perform the transaction in one step.
    for key in changes:
        inventory[key] = int(inventory.get(key,0)) + int(changes[key])
    actor["equipment"] = next_slots
    var restored: Dictionary = db.actor_stats(int(actor["id"]),int(actor["level"]))
    restored["equipment"] = next_slots.duplicate()
    restored = db.apply_equipment(restored)
    for stat in ["maxhp","maxmp","atk","def","spi","agi","hit","eva","cri"]:
        actor[stat] = restored[stat]
    actor["hp"] = mini(int(actor["hp"]),int(actor["maxhp"]))
    actor["mp"] = mini(int(actor["mp"]),int(actor["maxmp"]))
    changed.emit("%s 裝備欄位 %d 已更新" % [actor.get("name","?"),slot])
    return true

func advance_atb(delta: float) -> void:
    if not active:
        return
    # PLACEHOLDER: real FS ATB (1.2c)-0627 formula MUST supersede this.
    for battler in party + enemies:
        if int(battler["hp"]) <= 0:
            continue
        battler["atb"] = minf(1.0, float(battler.get("atb", 0.0)) + delta * (0.08 + float(battler.get("agi", 1)) / 800.0))

func ready_actors() -> Array[int]:
    var out: Array[int] = []
    for i in range(party.size()):
        if int(party[i]["hp"]) > 0 and float(party[i].get("atb", 0.0)) >= 1.0:
            out.append(i)
    return out

func ready_enemies() -> Array[int]:
    var out: Array[int] = []
    for i in range(enemies.size()):
        if int(enemies[i]["hp"]) > 0 and float(enemies[i].get("atb", 0.0)) >= 1.0:
            out.append(i)
    return out

func _check_end() -> void:
    if not active:
        return
    var allies_alive: bool = party.any(func(x: Dictionary) -> bool: return int(x.get("hp", 0)) > 0)
    var enemies_alive: bool = enemies.any(func(x: Dictionary) -> bool: return int(x.get("hp", 0)) > 0)
    if not allies_alive or not enemies_alive:
        active = false
        finished.emit(enemies_alive == false)
