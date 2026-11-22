extends RefCounted
class_name FSOriginalBattleScapeRules

# Byte-audited source: FS Scripts.rvdata section 264, original script's
# map/area/variable(1000)/troop alias chain. This class is the ONE authority
# for source BattleScape selection, not per-scene guessed backgrounds.
const SOURCE_SECTION:int=264
const VARIABLE_ID:int=1000
const DEFAULT_MAP:Array=[1,3]
const SOURCE_MAP:Dictionary={1:[1,3],2:[1],6:[1],12:[14,3],
    14:[1],23:[1],33:[15,3],38:[15,3],39:[15,3]}
const SOURCE_AREA:Dictionary={1:[1],2:[1]}
const SOURCE_VARIABLE:Dictionary={1:[1],2:[],3:[]}
# Source has duplicate troop 36: Ruby Hash's later [15,3] wins.
const SOURCE_TROOP:Dictionary={3:[1],11:[14,3],12:[14,3],
    29:[15,3],30:[15,3],31:[15,3],32:[15,3],33:[15,3],
    34:[15,3],36:[15,3],40:[15,3],41:[15,3],42:[15,3],
    43:[15,3],44:[15,3],45:[15,3],46:[15,3],48:[15,3],
    49:[15,3],50:[15,3],51:[15,3],52:[15,3],53:[15,3],
    54:[15,3],56:[15,3]}
# Ruby's TROOP_BATTLE_SCAPES.default = [1] means ALL positive troop IDs
# without an explicit mapping choose [1] before any variable/map fallback.
const SCAPES:Dictionary={
 1:{"name":"new_back00","z":51,"scroll_x":0,"scroll_y":0,
     "zoom_x":1.0,"zoom_y":1.0,"blend":0,"opacity":255},
 2:{"name":"temp1","z":52,"scroll_x":0,"scroll_y":0,
     "zoom_x":1.0,"zoom_y":1.0,"blend":0,"opacity":255},
 3:{"name":"ffog","z":49,"scroll_x":13,"scroll_y":0,
     "zoom_x":1.0,"zoom_y":1.0,"blend":1,"opacity":250},
 4:{"name":"Bridge","z":50,"scroll_x":0,"scroll_y":0,
     "zoom_x":0.85,"zoom_y":1.3,"blend":0,"opacity":255},
 5:{"name":"BlueSky","z":0,"scroll_x":2,"scroll_y":0,
     "zoom_x":1.0,"zoom_y":1.0,"blend":0,"opacity":255},
 6:{"name":"new_back00","z":60,"scroll_x":0,"scroll_y":0,
     "zoom_x":1.0,"zoom_y":1.0,"blend":0,"opacity":255},
 14:{"name":"new_back01","z":51,"scroll_x":0,"scroll_y":0,
     "zoom_x":1.0,"zoom_y":1.0,"blend":0,"opacity":255},
 15:{"name":"new_back02","z":51,"scroll_x":0,"scroll_y":0,
     "zoom_x":1.0,"zoom_y":1.0,"blend":0,"opacity":255},
 16:{"name":"back02","z":50,"scroll_x":0,"scroll_y":0,
     "zoom_x":1.0,"zoom_y":1.0,"blend":0,"opacity":255},
 31:{"name":"back08","z":50,"scroll_x":0,"scroll_y":0,
     "zoom_x":1.0,"zoom_y":1.0,"blend":0,"opacity":255}
}

static func resolve_ids(map_id:int,troop_id:int,variable_1000:int=0,
        area_ids:Array=[])->Array:
    if troop_id>0:
        # #264 final Game_Map#battle_scapes wrapper, source Ruby default.
        return SOURCE_TROOP.get(troop_id,[1]).duplicate()
    # #264 VARIABLE_BATTLE_SCAPES.default=[1], except explicit 2/3 []
    var variable_set:Array=SOURCE_VARIABLE.get(variable_1000,[1])
    if not variable_set.is_empty():
        return variable_set.duplicate()
    for area_id in area_ids:
        var from_area:Array=SOURCE_AREA.get(int(area_id),[])
        if not from_area.is_empty():
            return from_area.duplicate()
    return SOURCE_MAP.get(map_id,DEFAULT_MAP).duplicate()

static func describe_ids(ids:Array)->Array:
    var entries:Array=[]
    for id in ids:
        var n:int=int(id)
        if not SCAPES.has(n):
            return [] # Fail closed: never invent a source original background.
        var source:Dictionary=SCAPES[n].duplicate(true)
        source["id"]=n
        entries.append(source)
    entries.sort_custom(func(a:Dictionary,b:Dictionary)->bool:
        return int(a["z"])<int(b["z"]))
    return entries
