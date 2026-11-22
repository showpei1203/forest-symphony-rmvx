extends RefCounted
class_name FSOriginalActionSeal

# Exact ORIGINAL Scripts.rvdata section #312 "行動封印" (lines 29-124,
# 166-215). Never trust precomputed actor["a_seal"] flags; Game_Battler
# derives flags live from RPG::State.note for ALL active states.
const SOURCE_SECTION:int=312
const SOURCE_NAMES:Array[String]=[
    "攻撃封印",       # exact JP Ruby string, NOT 繁體"攻擊封印"
    "スキル封印",
    "防御封印",
    "アイテム封印"
]
const KINDS:Array[String]=["attack","skill","guard","item"]

static func flags(battler:Dictionary,db:FSDatabase)->Dictionary:
    var denied:Array[bool]=[false,false,false,false]
    if db==null or not battler.has("states") or (
            not battler["states"] is Array):
        return {"ok":false,"blocked":[true,true,true,true],
            "reason":"original State authority missing"}
    var active:Array=battler["states"]
    for element in active:
        # FS Game_Battler stores State IDs; never turn malformed State
        # into unsealed permission, including unknown boot-final records.
        if not (element is int or element is float):
            return {"ok":false,"blocked":[true,true,true,true],
                "reason":"unrecognized original State entry"}
        var id:int=int(element)
        if id<=0:
            return {"ok":false,"blocked":[true,true,true,true],
                "reason":"invalid original State ID"}
        var record:Dictionary=db.record("states",id)
        if record.is_empty() or not record.has("note"):
            return {"ok":false,"blocked":[true,true,true,true],
                "reason":"unresolved original State%d note" % id}
        var note:String=str(record["note"])
        for n in range(4):
            denied[n]=denied[n] or note.contains(SOURCE_NAMES[n])
    return {"ok":true,"blocked":denied,"reason":""}

static func can_use(battler:Dictionary,db:FSDatabase,kind:String)->bool:
    var n:int=KINDS.find(kind)
    if n<0:return false
    var quote:Dictionary=flags(battler,db)
    return bool(quote.get("ok",false)) and not bool(
        quote.get("blocked",[true,true,true,true])[n])

static func all_commands_sealed(battler:Dictionary,db:FSDatabase)->bool:
    var quote:Dictionary=flags(battler,db)
    if not bool(quote.get("ok",false)):
        return true
    for blocked in quote["blocked"]:
        if not bool(blocked):
            return false
    return true
