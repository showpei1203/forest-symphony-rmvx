extends SceneTree

# Forest Symphony original Phase28 FinalAuthority source-grade synthetic test.
# Read-only source lines ~202809 Type Chart and ~270615 Final Guard.
# This test does not assert real post-Apply original data availability.
const DB = preload("res://scripts/FSDatabase.gd")
const ELEMENTS = preload("res://scripts/FSElementFinalAuthority.gd")

func _initialize() -> void:
    call_deferred("_run")

func _check(ok: bool,reason: String) -> bool:
    if not ok:
        push_error("FS Phase28 element final authority FAIL: "+reason)
        quit(1)
        return false
    return true

func _db() -> FSDatabase:
    var db = DB.new()
    db.tables = {"states":[null,{"id":1,"element_set":[15]},
            {"id":2,"element_set":[13]}],
        "weapons":[null],
        "armors":[null,
            {"id":1,"element_set":[13],"invalid_element_set":[],
                "guard_element_set":[13],"weak_element_set":[13],
                "absorb_element_set":[13]},
            {"id":2,"element_set":[],"invalid_element_set":[13],
                "guard_element_set":[],"weak_element_set":[],
                "absorb_element_set":[]} ]}
    return db

func _target(primary: String,secondary: String="") -> Dictionary:
    var ranks: Dictionary = {}
    for id in ELEMENTS.ID_TO_TYPE.keys():
        ranks[str(id)] = 3
    return {"id":99,"name":"Source type fixture","actor":false,
        "hp":1000,"maxhp":1000,"states":[],"note":"","equipment":[],
        "fs_element_authority":{"verified":true,
            "primary":primary,"secondary":secondary,
            "ranks":ranks,"extra_notes_verified":true,
            "extra_notes":[]}}

func _rate(e: FSElementFinalAuthority,db: FSDatabase,
        target: Dictionary,ids: Array,expected: int,
        message: String) -> bool:
    var q: Dictionary = e.max_rate_for(db,target,ids)
    return _check(q.get("ok",false) and int(q.get("rate",-999))==expected,
        message+" expected %d found %s" % [expected,str(q)])

func _run() -> void:
    var db: FSDatabase = _db()
    var e = ELEMENTS.new()
    e.active = true
    if not _check(e.CHART.size()==18 and e.ID_TO_TYPE.size()==18,
            "all source 18 types ported, not subset or inferred chart"): return
    var water_ground: Dictionary = _target("water","ground")
    if not _rate(e,db,water_ground,[15],250,
            "Grass vs Water/Ground 4x clamps to 250%"): return
    if not _rate(e,db,water_ground,[16],0,
            "Electric vs Water/Ground immunized by Ground 0x"): return
    if not _rate(e,db,water_ground,[13],50,
            "Fire vs Water/Ground 0.5x"): return
    if not _rate(e,db,water_ground,[13,15],125,
            "FS product Fire50% * Grass250% => 125%"): return
    if not _rate(e,db,water_ground,[13,15,13],125,
            "multielement duplicate entries consumed ONCE"): return
    if not _rate(e,db,water_ground,[],100,
            "empty element_set original returns neutral100"): return
    if not _rate(e,db,water_ground,[1],100,
            "undefined source element ID bypasses chart and ranks"): return
    if not _rate(e,db,water_ground,[16,15],0,
            "immunity stays zero in multiproduct"): return
    if not _rate(e,db,water_ground,[16],0,
            "zero survives separate multiple rate calls"): return
    var double_weak: Dictionary = _target("dragon","flying")
    if not _rate(e,db,double_weak,[18],250,
            "Ice vs Dragon/Flying 4x capped 250"): return
    var immunity: Dictionary = _target("fairy")
    if not _rate(e,db,immunity,[19],0,
            "Dragon vs Fairy immunity"): return
    var ghost: Dictionary = _target("ghost")
    if not _rate(e,db,ghost,[4],0,
            "Normal vs Ghost immunity"): return
    var rank: Dictionary = _target("fire")
    rank["fs_element_authority"]["ranks"]["14"] = 1
    if not _rate(e,db,rank,[14],250,
            "Water vs Fire doubles, Rank1 doubles, final clamp250"): return
    rank["fs_element_authority"]["ranks"]["14"] = 6
    if not _rate(e,db,rank,[14],-100,
            "Rank6 absorbs from source RANK_RATE[-100]"): return
    var absorbed: Dictionary = e.preview_damage(db,rank,[14],87)
    if not _check(absorbed.get("ok",false) and int(absorbed["hp"])==-87,
            "source negative damage heals rather than becoming zero"): return

    # State defense multiplicative half: 4x Grass vs water/ground
    # clamps only AFTER 100% DB rank and State50%, yielding 200%.
    water_ground["states"] = [1]
    if not _rate(e,db,water_ground,[15],200,
            "original State element_set halves before final cap"): return
    water_ground["states"] = []

    # Target's final ele_weak/ele_res Note aliases, including repeated
    # tags and square bracket syntax, run after rate_for per element.
    var extras: Dictionary = _target("water")
    extras["fs_element_authority"]["extra_notes"] = [
        "<ele_weak 13:50><ele_weak[13]:25>", "<ele_res 13:10>",
        "<ele_res[13]:5>"]
    if not _rate(e,db,extras,[13],110,
            "Fire50 + weak50 + weak25 - res10 - res5 =>110"): return
    if not _rate(e,db,extras,[13,13],110,
            "duplicated element ID cannot double-apply passive Note"): return

    # ACTOR KGC sequence: native Armor halves rank100→50,
    # type Fire->Grass 200x, resistance150%, guard halves,
    # weak scales 3/2, absorb flips sign. All integer stages matter.
    var actor: Dictionary = _target("grass")
    actor["actor"] = true
    actor["equipment"] = [0,1,0,0,0]
    actor["fs_element_authority"]["equipment_verified"] = true
    actor["fs_element_authority"]["element_resistance"] = {"13":150}
    if not _rate(e,db,actor,[13],-55,
            "Armor native half + KGC resist/guard/weak/absorb: -55%"): return
    actor["equipment"] = [0,1,2,0,0]
    if not _rate(e,db,actor,[13],0,
            "KGC invalid_element_set overrides absorption to zero"): return
    actor["equipment"] = [0,1,0,0,0]
    actor["fs_element_authority"]["element_resistance"] = {"13":100}
    if not _rate(e,db,actor,[13],-37,
            "KGC source integer guard/weak stages with rate100"): return

    # Fail-closed evidence gates. A blocked quote is pure: no RNG, HP
    # or MP mutations and no default-element guesses.
    var invalid: Dictionary = _target("grass")
    invalid["fs_element_authority"].erase("ranks")
    if not _check(not bool(e.max_rate_for(db,invalid,[13]).get("ok",false)),
            "missing class/enemy element ranks cannot be replaced by100"): return
    invalid = _target("grass")
    invalid["fs_element_authority"]["primary"] = "invented"
    if not _check(not bool(e.max_rate_for(db,invalid,[13]).get("ok",false)),
            "unknown source type cannot be invented"): return
    invalid = _target("grass")
    invalid["states"] = [55]
    if not _check(not bool(e.max_rate_for(db,invalid,[13]).get("ok",false)),
            "unverified RPG State element_set blocks instead of ignoring"): return
    invalid = _target("grass")
    invalid["actor"] = true
    invalid["equipment"] = [0,1,0,0,0]
    if not _check(not bool(e.max_rate_for(db,invalid,[13]).get("ok",false)),
            "missing KGC equipment resistance is not declared neutral"): return

    print("FS final element 18-chart, dual types, 6 rank rates, states, KGC armor, duplicate multi, Note extra, immunity and absorption PASS")
    quit(0)
