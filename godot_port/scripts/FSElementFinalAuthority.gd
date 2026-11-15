extends RefCounted
class_name FSElementFinalAuthority

# Forest Symphony source #52-24 FS_ElementRate_FinalAuthority v2.0.
# Translated from original FS All_Scripts_Export.txt ~270598-270820 and
# FS_ELEMENT_TYPE_DATA ~202809-202900 (read-only original project).
# Final method authority covers Game_Actor/Enemy/Battler element_rate and
# elements_max_rate. SupportStateSkillRules runs later and can override
# recovery/Note state-only skills: those are deliberately outside this module.
#
# Production: OFF until post-FS_DB_AUTOSET 11 tables, type provider,
# KGC equipment / passive aliases and game runtime witness are proven.
# Synthetic native tests explicitly opt in and supply a source authority
# snapshot in target.fs_element_authority. NEVER invent source rank/type.
const ID_TO_TYPE: Dictionary = {
    4:"normal",5:"fighting",6:"flying",7:"poison",8:"ground",
    9:"rock",10:"bug",11:"ghost",12:"steel",13:"fire",14:"water",
    15:"grass",16:"electric",17:"psychic",18:"ice",19:"dragon",
    20:"dark",21:"fairy"
}
const CHART: Dictionary = {
    "normal":{"rock":0.5,"ghost":0.0,"steel":0.5},
    "fighting":{"normal":2.0,"ice":2.0,"rock":2.0,"dark":2.0,
        "steel":2.0,"poison":0.5,"flying":0.5,"psychic":0.5,
        "bug":0.5,"fairy":0.5,"ghost":0.0},
    "flying":{"fighting":2.0,"bug":2.0,"grass":2.0,
        "rock":0.5,"steel":0.5,"electric":0.5},
    "poison":{"grass":2.0,"fairy":2.0,"poison":0.5,
        "ground":0.5,"rock":0.5,"ghost":0.5,"steel":0.0},
    "ground":{"poison":2.0,"rock":2.0,"steel":2.0,"fire":2.0,
        "electric":2.0,"bug":0.5,"grass":0.5,"flying":0.0},
    "rock":{"flying":2.0,"bug":2.0,"fire":2.0,"ice":2.0,
        "fighting":0.5,"ground":0.5,"steel":0.5},
    "bug":{"grass":2.0,"psychic":2.0,"dark":2.0,
        "fighting":0.5,"flying":0.5,"poison":0.5,"ghost":0.5,
        "steel":0.5,"fire":0.5,"fairy":0.5},
    "ghost":{"ghost":2.0,"psychic":2.0,"dark":0.5,"normal":0.0},
    "steel":{"rock":2.0,"ice":2.0,"fairy":2.0,
        "steel":0.5,"fire":0.5,"water":0.5,"electric":0.5},
    "fire":{"bug":2.0,"steel":2.0,"grass":2.0,"ice":2.0,
        "rock":0.5,"fire":0.5,"water":0.5,"dragon":0.5},
    "water":{"ground":2.0,"rock":2.0,"fire":2.0,
        "water":0.5,"grass":0.5,"dragon":0.5},
    "grass":{"ground":2.0,"rock":2.0,"water":2.0,
        "flying":0.5,"poison":0.5,"bug":0.5,"steel":0.5,
        "fire":0.5,"grass":0.5,"dragon":0.5},
    "electric":{"flying":2.0,"water":2.0,"grass":0.5,
        "electric":0.5,"dragon":0.5,"ground":0.0},
    "psychic":{"fighting":2.0,"poison":2.0,
        "steel":0.5,"psychic":0.5,"dark":0.0},
    "ice":{"flying":2.0,"ground":2.0,"grass":2.0,
        "dragon":2.0,"steel":0.5,"fire":0.5,
        "water":0.5,"ice":0.5},
    "dragon":{"dragon":2.0,"steel":0.5,"fairy":0.0},
    "dark":{"ghost":2.0,"psychic":2.0,"fighting":0.5,
        "dark":0.5,"fairy":0.5},
    "fairy":{"fighting":2.0,"dragon":2.0,"dark":2.0,
        "poison":0.5,"steel":0.5,"fire":0.5}
}
const RANK_RATES: Array[int] = [0,200,150,100,50,0,-100]
const MIN_RATE: int = -100
const MAX_RATE: int = 250
var active: bool = false
var errors: Array[String] = []
var events: Array[Dictionary] = []

func _fail(reason: String) -> Dictionary:
    if not errors.has(reason):
        errors.append(reason)
    return {"ok":false,"reason":reason}

static func _contains(array: Variant,element_id: int) -> bool:
    if not (array is Array):
        return false
    for value in array:
        if int(value) == element_id:
            return true
    return false

static func _rank(ranks: Dictionary,element_id: int) -> int:
    var key: String = str(element_id)
    if ranks.has(key):
        return int(ranks[key])
    if ranks.has(element_id):
        return int(ranks[element_id])
    return -1

static func _extra_note_rate(notes: Array,element_id: int) -> Dictionary:
    # FS_BATTLE_V22 sums ALL ele_weak and ele_res notetags and supports
    # <ele_weak 13:50> and <ele_weak[13]:50> syntaxes.
    var rx := RegEx.new()
    if rx.compile("(?i)<(ele_weak|ele_res)(?:\\s+([0-9]+)|\\[([0-9]+)\\])\\s*:\\s*(-?[0-9]+)\\s*>") != OK:
        return {"ok":false}
    var adjustment: int = 0
    for data in notes:
        var note: String = str(data)
        for m in rx.search_all(note):
            var number: String = m.get_string(2)
            if number.is_empty():
                number = m.get_string(3)
            if int(number) != element_id:
                continue
            var polarity: int = 1 if m.get_string(1).to_lower()=="ele_weak" else -1
            adjustment += polarity*int(m.get_string(4))
    return {"ok":true,"adjustment":adjustment}

func rate_for(db: FSDatabase,target: Dictionary,element_id: int) -> Dictionary:
    if not active:
        return {"ok":true,"enabled":false,"rate":100}
    # Unknown source element ID bypasses the chart by original Ruby law,
    # without touching rank/extra notes.
    if not ID_TO_TYPE.has(element_id):
        return {"ok":true,"enabled":true,"rate":100,"symbol":""}
    var source: Variant = target.get("fs_element_authority",null)
    if not (source is Dictionary) or not bool(source.get("verified",false)):
        return _fail("雙屬性／Rank／裝備／State 的原版最終來源證明缺失")
    if not bool(source.get("extra_notes_verified",false)):
        return _fail("目標被動及裝備元素抗弱 Note 仍未驗證")
    var primary: String = str(source.get("primary","")).to_lower()
    var secondary: String = str(source.get("secondary","")).to_lower()
    if not CHART.has(primary) or (
            not secondary.is_empty() and not CHART.has(secondary)):
        return _fail("目標 primary/secondary_element 未有權威種類")
    var ranks: Variant = source.get("ranks",null)
    if not (ranks is Dictionary):
        return _fail("目標資料庫 Element Rank 欄位未驗證")
    var rank: int = _rank(ranks,element_id)
    if rank < 0 or rank >= RANK_RATES.size():
        return _fail("目標 Element%d 原始 rank 不存在／越界" % element_id)
    var notes: Variant = source.get("extra_notes",null)
    if not (notes is Array):
        return _fail("裝備／被動元素抗弱 Note 鏈缺失")
    var attack: String = str(ID_TO_TYPE[element_id])
    var factors: Dictionary = CHART[attack]
    var multiplier: float = float(factors.get(primary,1.0))
    if not secondary.is_empty():
        multiplier *= float(factors.get(secondary,1.0))
    var type_rate: float = multiplier*100.0
    var database_rate: int = int(RANK_RATES[rank])
    var state_rate: int = 100
    var states: Variant = target.get("states",null)
    if not (states is Array):
        return _fail("真實 RPG State 列表缺失")
    for value in states:
        var state: Dictionary = db.record("states",int(value))
        if state.is_empty() or not state.has("element_set") or not (
                state["element_set"] is Array):
            return _fail("State%d 元素守備集合尚未驗證" % int(value))
        if _contains(state["element_set"],element_id):
            state_rate = int(state_rate/2)
    var result: float = type_rate*float(database_rate)/100.0
    result = result*float(state_rate)/100.0
    var is_actor: bool = bool(target.get("actor",false))
    if is_actor:
        if not bool(source.get("equipment_verified",false)):
            return _fail("Actor Armor element_set / KGC Element Options 未核對")
        var resistance: Variant = source.get("element_resistance",null)
        if not (resistance is Dictionary):
            return _fail("Actor KGC element_resistance 缺失")
        var resistance_key: String = str(element_id)
        if not resistance.has(resistance_key) and not resistance.has(element_id):
            return _fail("Actor KGC element_resistance 缺少元素%d" % element_id)
        var equipment: Variant = target.get("equipment",null)
        if not (equipment is Array):
            return _fail("Actor 裝備表不是有效陣列")
        var armors: Array[Dictionary] = []
        var kgc_equips: Array[Dictionary] = []
        for index in range(equipment.size()):
            var kind: String = db.equip_kind(target,index)
            var item_id: int = int(equipment[index])
            if item_id <= 0:
                continue
            if kind != "weapons" and kind != "armors":
                return _fail("未知裝備槽影響元素倍率")
            var item: Dictionary = db.record(kind,item_id)
            if item.is_empty():
                return _fail("裝備%d來源記錄缺失" % item_id)
            for field in ["invalid_element_set","guard_element_set",
                    "weak_element_set","absorb_element_set"]:
                if not item.has(field) or not (item[field] is Array):
                    return _fail("KGC 裝備%d 選項 %s 尚未驗證" % [item_id,field])
            kgc_equips.append(item)
            if kind == "armors":
                if not item.has("element_set") or not (
                        item["element_set"] is Array):
                    return _fail("防具%d 原生 element_set 尚未驗證" % item_id)
                armors.append(item)
        # Original VX native Armor#element_set halves the DB rank for
        # EACH matching armor, BEFORE state and KGC equipment options.
        # Both are multiplicative under 0/negative rates; Integer floors.
        var native_rank: int = database_rate
        for item in armors:
            if _contains(item["element_set"],element_id):
                native_rank = int(native_rank/2)
        result = type_rate*float(native_rank)/100.0
        result = result*float(state_rate)/100.0
        var resistance_rate: int = int(resistance.get(
            resistance_key,resistance.get(element_id,100)))
        # Original KGC result.to_i before multiplying resistance.
        var guarded: int = int(result)*resistance_rate/100
        var absorb: bool = guarded < 0
        guarded = absi(guarded)
        # Original FS KGC implementation loops battler.equips.compact,
        # including WEAPONS. Only the stock VX Armor#element_set halves
        # the database Rank; KGC invalid/guard/weak/absorb uses ALL equips.
        for item in kgc_equips:
            if _contains(item["invalid_element_set"],element_id):
                guarded = 0
                break
            if _contains(item["guard_element_set"],element_id):
                guarded = int(guarded/2)
            if _contains(item["weak_element_set"],element_id):
                guarded = int(guarded*3/2)
            if _contains(item["absorb_element_set"],element_id):
                absorb = true
        result = float(-guarded if absorb else guarded)
    var base: int = clampi(int(result),MIN_RATE,MAX_RATE)
    return {"ok":true,"enabled":true,"rate":base,"symbol":attack,
        "type_rate":type_rate,"database_rate":database_rate,
        "state_rate":state_rate,"primary":primary,"secondary":secondary}

func max_rate_for(db: FSDatabase,target: Dictionary,
        element_set: Variant) -> Dictionary:
    if not active:
        return {"ok":true,"enabled":false,"rate":100}
    if not (element_set is Array):
        return _fail("攻擊元素集合不是原始陣列")
    if element_set.is_empty():
        return {"ok":true,"enabled":true,"rate":100,"elements":[]}
    var source: Variant = target.get("fs_element_authority",null)
    if not (source is Dictionary) or not bool(source.get("verified",false)):
        return _fail("元素來源權威資料缺失")
    if not bool(source.get("extra_notes_verified",false)) or not (
            source.get("extra_notes",null) is Array):
        return _fail("原版額外元素弱／抗性來源未驗證")
    var used: Array[int] = []
    var result: float = 100.0
    var steps: Array[Dictionary] = []
    for value in element_set:
        var id: int = int(value)
        if used.has(id):
            continue
        used.append(id)
        var one: Dictionary = rate_for(db,target,id)
        if not bool(one.get("ok",false)):
            return one
        var extra: Dictionary = _extra_note_rate(
            source["extra_notes"],id)
        if not bool(extra.get("ok",false)):
            return _fail("元素被動額外倍率解析失敗")
        var adjusted: int = clampi(int(one["rate"])+int(
            extra["adjustment"]),MIN_RATE,MAX_RATE)
        steps.append({"id":id,"base":int(one["rate"]),
            "extra":int(extra["adjustment"]),"adjusted":adjusted})
        result = result*float(adjusted)/100.0
    var final_rate: int = clampi(int(result),MIN_RATE,MAX_RATE)
    events.append({"target_id":int(target.get("id",0)),
        "rate":final_rate,"elements":used.duplicate(),
        "steps":steps.duplicate(true)})
    return {"ok":true,"enabled":true,"rate":final_rate,
        "elements":used,"steps":steps}

func preview_damage(db: FSDatabase,target: Dictionary,
        element_set: Variant,hp_damage: int) -> Dictionary:
    var quote: Dictionary = max_rate_for(db,target,element_set)
    if not bool(quote.get("ok",false)):
        return quote
    # RGSS2 damage *= rate (Integer) then damage /= 100 (Integer /).
    # Ruby negative Integer division floors rather than truncating to0.
    var value: int = floori(float(hp_damage)*float(
        int(quote.get("rate",100)))/100.0)
    return {"ok":true,"hp":value,"rate":int(quote.get("rate",100)),
        "enabled":active}
