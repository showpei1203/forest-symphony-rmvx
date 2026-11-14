extends RefCounted
class_name FSBossSummonRuntime

# FS #401 Runtime Boss provider + #440 MasterSetup15 data authority.
# Both START_SUMMONS and CORE_GROUPS source constants matched exactly.
# Only logical troop summons and the known fixed/growth stat formulas
# are implemented. ma_call_ally spatial placement/spriteset, full Phase
# State/weather, EXP/Gold reward hooks and summoning animations still
# require original VX runtime witnesses.
#
# All safe failures do NOT set a "summoned" flag and do NOT modify roster.
# Original #401 flags are intentionally per-battle.

const START_SUMMONS: Dictionary = {500: [[600, 2, 100]], 501: [[659, 2, 100]], 502: [[664, 2, 100]], 503: [[503, 2, 100]], 504: [[708, 2, 100]], 505: [[671, 2, 100]], 506: [[742, 1, 100]], 507: [[551, 2, 100]], 508: [[552, 1, 100]], 509: [[553, 2, 100]], 521: [[558, 2, 100]], 522: [[559, 2, 100]], 523: [[560, 2, 100]], 530: [[561, 2, 100]], 531: [[562, 1, 100], [563, 1, 100], [564, 1, 100], [565, 1, 100]], 540: [[551, 2, 100]], 541: [[552, 2, 100]], 542: [[553, 2, 100]], 543: [[554, 2, 100]], 544: [[555, 2, 100]], 545: [[556, 2, 100]], 546: [[557, 3, 100]], 548: [[558, 2, 100]], 549: [[559, 2, 100]], 550: [[560, 2, 100]]}
const CORE_GROUPS: Dictionary = {540: [551], 541: [552], 542: [553], 543: [554], 544: [555], 545: [556], 546: [557], 547: [558], 548: [558], 549: [559], 550: [560], 530: [561], 531: [562, 563, 564, 565], 520: [557]}
const MAX_ENEMIES: int = 8
const GROWTH_MP_SCALE: float = 2.2
const DEFAULT_ENEMY_HP_SCALE: float = 6.5

var flags: Dictionary = {}
var failures: Array[String] = []
var events: Array[Dictionary] = []
var rng: FSAIRandom = FSAIRandom.new()
var active: bool = false
# Phase/Weather source INTENTS are tracked separately; actual RPG State
# effects and global field damage remain explicitly unimplemented.
var phase_runtime: FSBossPhaseRuntime = FSBossPhaseRuntime.new()

static func _member(enemies: Array[Dictionary],id: int,alive_only: bool) -> Dictionary:
    for enemy in enemies:
        if int(enemy.get("id",0)) != id:
            continue
        if alive_only and int(enemy.get("hp",0)) <= 0:
            continue
        return enemy
    return {}

static func _count(enemies: Array[Dictionary],id: int) -> int:
    var amount: int = 0
    for enemy in enemies:
        if int(enemy.get("id",0)) == id:
            amount += 1
    return amount

static func _mode(enemy_id: int,record: Dictionary) -> String:
    var note: String = str(record.get("note","")).to_lower()
    if "<fs_fixed_enemy_stats>" in note:
        return "fixed"
    if "<fs_growth_enemy_stats>" in note or "<fs_growth_source>" in note:
        return "growth"
    return "growth" if enemy_id >= 590 and enemy_id <= 745 else "database"

static func _number_note(note: String,tag: String) -> Dictionary:
    var re := RegEx.new()
    if re.compile("(?i)<\\s*%s\\s*:\\s*([0-9]+(?:\\.[0-9]+)?)\\s*>" % tag) != OK:
        return {}
    var m: RegExMatch = re.search(note)
    return {"value":float(m.get_string(1))} if m != null else {}

static func prepare_summoned(battle,enemy_id: int,scale: int) -> Dictionary:
    if scale <= 0 or scale > 1000:
        return {"ok":false,"reason":"召喚倍率無效"}
    var row: Dictionary = battle.db.record("enemies",enemy_id)
    if row.is_empty():
        return {"ok":false,"reason":"缺少正式敵人資料 #%d" % enemy_id}
    var mode: String = _mode(enemy_id,row)
    var battler: Dictionary = battle.db.enemy_stats(enemy_id)
    if battler.is_empty():
        return {"ok":false,"reason":"敵方有效能力值不存在"}
    var level: int = 1
    if mode == "growth":
        # #401 safe_level uses Game_Enemy.level, which may be overridden by
        # other RGSS2 sources. No original level witness -> FAIL CLOSED.
        if not bool(row.get("fs_runtime_level_verified",false)):
            return {"ok":false,"reason":"成長型敵人缺少原 VX 執行時等級證據"}
        level = clampi(int(row.get("fs_runtime_level",0)),1,60)
        if int(row.get("fs_runtime_level",0)) <= 0:
            return {"ok":false,"reason":"成長型敵人等級無效"}
    for stat in ["maxhp","maxmp","atk","def","spi","agi"]:
        var base: int = int(row.get(stat,0))
        if base < 0:
            return {"ok":false,"reason":"敵方能力值為負"}
        var value: int = base
        if mode == "growth":
            var intermediate: float = (2.0*base+31.0)*level/100.0+float(level)
            if stat == "maxhp":
                var note: Dictionary = _number_note(str(row.get("note","")),"fs_hp_scale")
                var multiplier: float = maxf(0.1,float(note.get("value",DEFAULT_ENEMY_HP_SCALE)))
                value = int((intermediate+10.0)*multiplier)
            elif stat == "maxmp":
                value = int((intermediate+10.0)*GROWTH_MP_SCALE)
            else:
                value = int(intermediate+5.0)
        var minimum: int = 0 if stat=="maxmp" else 1
        battler[stat] = maxi(minimum,int(value*scale/100.0))
    battler["level"] = level
    battler["hp"] = int(battler["maxhp"])
    battler["mp"] = int(battler["maxmp"])
    battler["od"] = 0
    battler["atb"] = 0.0
    battler["guarding"] = false
    battler["fs_boss_runtime_scale"] = scale
    battler["fs_boss_stat_mode"] = mode
    FSATBResistance.setup(battler)
    return {"ok":true,"battler":battler}

func _fail(reason: String) -> bool:
    if not failures.has(reason):
        failures.append(reason)
    return false

func _summon(battle,boss_id: int,enemy_id: int,desired: int,scale: int,
        category: String) -> bool:
    # Source #401 count() counts living + DEAD members and caps troop.size.
    var missing: int = maxi(0,desired-_count(battle.enemies,enemy_id))
    missing = mini(missing,MAX_ENEMIES-battle.enemies.size())
    if missing <= 0:
        return true
    var ready: Array[Dictionary] = []
    for i in range(missing):
        var draft: Dictionary = prepare_summoned(battle,enemy_id,scale)
        if not bool(draft.get("ok",false)):
            return _fail("Boss%d→Enemy%d：%s" % [
                boss_id,enemy_id,draft.get("reason","unknown")])
        ready.append(draft["battler"])
    # All records verified before appending anything, so an incomplete
    # original DB cannot leave half a summoning batch in the battle.
    for battler in ready:
        battle.enemies.append(battler)
        if battle.source_atb_initialized:
            FSTankentaiATBCore.initialize_summoned(
                battle.party,battle.enemies,battler,
                int(battle.source_atb_rolls_for_test.get(
                    "enemy:"+str(battle.enemies.size()-1),-1)))
        events.append({"category":category,"boss_id":boss_id,
            "enemy_id":enemy_id,"scale":scale,"count":1})
        battle.changed.emit("Boss%d 召喚 Enemy%d（%d%%）" % [
            boss_id,enemy_id,scale])
    return true

func _summon_specs(battle,boss_id: int,specs: Array,
        category: String) -> bool:
    # Preflight ALL additions in one Boss batch before flags are committed.
    # Missing records/modes refuse, but MAX_ENEMIES partial capacity is
    # source behavior (first spec gets first available slot).
    var virtual_counts: Dictionary = {}
    for enemy in battle.enemies:
        var eid: int = int(enemy.get("id",0))
        virtual_counts[eid] = int(virtual_counts.get(eid,0))+1
    var space_left: int = maxi(0,MAX_ENEMIES-battle.enemies.size())
    for spec in specs:
        var desired: int = int(spec[1])
        var enemy_id: int = int(spec[0])
        var slots: int = maxi(0,mini(desired-int(virtual_counts.get(enemy_id,0)),
            space_left))
        if slots > 0:
            var check: Dictionary = prepare_summoned(battle,enemy_id,int(spec[2]))
            if not bool(check.get("ok",false)):
                return _fail("Boss%d→Enemy%d：%s" % [
                    boss_id,enemy_id,check.get("reason","unknown")])
            virtual_counts[enemy_id] = int(virtual_counts.get(enemy_id,0))+slots
            space_left -= slots
    for spec in specs:
        if not _summon(battle,boss_id,int(spec[0]),
                int(spec[1]),int(spec[2]),category):
            return false
    return true

func tick(battle) -> int:
    if not active or not battle.active:
        return 0
    var before: int = battle.enemies.size()
    var boss_ids: Array = START_SUMMONS.keys()
    boss_ids.sort()
    for boss_id in boss_ids:
        var boss: Dictionary = _member(battle.enemies,int(boss_id),true)
        if boss.is_empty() or flags.has("start:%d" % int(boss_id)):
            continue
        if _summon_specs(battle,int(boss_id),START_SUMMONS[boss_id],"start"):
            flags["start:%d" % int(boss_id)] = true

    var altar: Dictionary = _member(battle.enemies,510,true)
    if not altar.is_empty() and not flags.has("altar:510"):
        # Source #401: randomly choose 554/555/556 with tag boss_altar_pick.
        var chosen: int = [554,555,556][rng.roll(3,"boss_altar_pick")]
        if _summon_specs(battle,510,[[chosen,1,100]],"altar"):
            flags["altar:510"] = chosen
    var elite: Dictionary = _member(battle.enemies,511,true)
    if not elite.is_empty() and not flags.has("elite_pair:511"):
        var pool: Array[int] = []
        for id in range(500,511):
            pool.append(id)
        var first: int = pool.pop_at(rng.roll(pool.size(),"boss_pair_first"))
        var second: int = pool.pop_at(rng.roll(pool.size(),"boss_pair_second"))
        if _summon_specs(battle,511,[[first,1,72],[second,1,72]],"elite_pair"):
            flags["elite_pair:511"] = [first,second]

    var boss520: Dictionary = _member(battle.enemies,520,true)
    if not boss520.is_empty() and not flags.has("threshold:520") and (
            int(boss520.get("hp",0))*100 <= int(boss520.get("maxhp",1))*70):
        if _summon_specs(battle,520,[[557,1,100]],"threshold"):
            flags["threshold:520"] = true
    var boss547: Dictionary = _member(battle.enemies,547,true)
    if not boss547.is_empty() and not flags.has("threshold:547") and (
            int(boss547.get("hp",0))*100 <= int(boss547.get("maxhp",1))*60):
        if _summon_specs(battle,547,[[558,2,100]],"threshold"):
            flags["threshold:547"] = true
    # Source #401 exact update order: initial -> threshold -> phase states
    # -> core exposure. Phase runtime emits only verified ID/field INTENTS,
    # never silently applies RPG State effects or weather damage.
    phase_runtime.tick(battle,flags)
    # Source #404 weather is a real global field, NOT a regular battler
    # State. Only activate this sourced subset when the explicit field
    # engine gate passes; Phase State 122..127 effects remain pending.
    if battle.field_weather.active:
        var request: Dictionary = phase_runtime.weather_request
        if not request.is_empty():
            var source: Dictionary = _member(battle.enemies,int(
                request.get("source_boss_id",0)),true)
            if not source.is_empty():
                if not battle.field_weather.set_field(battle.db,int(
                        request.get("field_id",0)),source,true):
                    _fail("Boss 場域天氣設定被來源驗證阻擋")
    return battle.enemies.size()-before
