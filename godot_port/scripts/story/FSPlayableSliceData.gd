extends RefCounted
class_name FSPlayableSliceData

# Isolated, synthetic SOURCE-SHAPED records for a real executable
# event -> battle -> map vertical slice. NOT FS original post-Apply
# tables, not A35 Ground/PAR, not original character/monster art.
# Import the private, verified FS tables later WITHOUT touching
# the event interpreter / map-battle host.
const MAP_FOREST:int=999
const MAP_RUINS:int=1000
const WIDTH:int=17
const HEIGHT:int=13

static func _cmd(code:int,indent:int=0,params:Array=[])->Dictionary:
    return {"code":code,"indent":indent,"parameters":params}

static func _text(line:String)->Array:
    return [_cmd(101,0,["",0,0,2]),_cmd(401,0,[line])]

static func map_name(map_id:int)->String:
    match map_id:
        MAP_FOREST: return "測試森林"
        MAP_RUINS: return "測試遺跡"
        _: return ""

static func map_markers(map_id:int)->Dictionary:
    # Keys are tile coordinates, values are SOURCE event_id, not names.
    if map_id==MAP_FOREST:
        return {Vector2i(4,5):1,Vector2i(9,5):2,
            Vector2i(13,6):3}
    if map_id==MAP_RUINS:
        return {Vector2i(2,6):1,Vector2i(7,6):2}
    return {}

static func initial_state()->FSGameState:
    var world:=FSGameState.new()
    world.map_id=MAP_FOREST
    world.map_x=5
    world.map_y=5
    world.party_actor_ids.append(1)
    return world

static func database()->FSDatabase:
    var db:=FSDatabase.new()
    var values:Array=[]
    for i in range(100):
        values.append_array([120,50,25,8,7,12])
    db.tables={
        "actors":[null,{"id":1,"name":"測試劍士","class_id":1,
            "initial_level":5,"weapon_id":0,"armor1_id":0,
            "armor2_id":0,"armor3_id":0,"armor4_id":0,
            "parameters":{"xsize":6,"ysize":100,"data_int16":values}}],
        "classes":[null,{"id":1,"position":1,
            "weapon_set":[],"armor_set":[],"learnings":[]}],
        "enemies":[null,{"id":1,"name":"測試木靈",
            "maxhp":48,"maxmp":0,"atk":2,"def":1,
            "spi":2,"agi":5,"hit":95,"eva":0,
            "has_critical":false,"actions":[],
            "battler_name":"","note":""}],
        "troops":[null,{"id":1,"name":"測試林間遭遇",
            "members":[{"enemy_id":1,"hidden":false}],"pages":[]}],
        "skills":[null],"weapons":[null],"armors":[null],
        "items":[null,{"id":1,"name":"測試藥草",
            "description":"只驗證事件背包，不代表原版可使用道具"}],
        "states":[null],"system":{"party_members":[1],"test_troop_id":1}
    }
    # Strictly synthetic: db.boot_final_verified must NEVER be set.
    return db

static func event(map_id:int,event_id:int,world:FSGameState)->Array:
    if map_id==MAP_FOREST and event_id==1:
        if world.self_switch_on(map_id,event_id,"A"):
            return _text("箱子已打開，藥草不會重複領取。")+[_cmd(0)]
        return _text("你找到一株藥草。")+[
            _cmd(126,0,[1,0,0,1]),
            _cmd(123,0,["A",0]),
            _cmd(0)]
    if map_id==MAP_FOREST and event_id==2:
        if world.switch_on(10):
            return _text("木靈已被擊退，林道恢復安寧。")+[_cmd(0)]
        return _text("林道上的木靈擋住了去路。")+[
            _cmd(301,0,[0,1,false,true]),
            _cmd(601), # VX victory branch
            _cmd(121,1,[10,10,0]),
            _cmd(125,1,[0,0,50]),
        ]+_text("擊退木靈，獲得 50 G！")+[
            _cmd(602), # VX escape branch, kept for source semantics
        ]+_text("你從木靈身邊撤退。")+[
            _cmd(603), # VX can_lose defeat branch
            _cmd(121,1,[11,11,0]),
        ]+_text("這次失手了，可以重新挑戰。")+[
            _cmd(604),_cmd(0)]
    if map_id==MAP_FOREST and event_id==3:
        return [_cmd(201,0,[0,MAP_RUINS,3,6,2])]+_text(
            "你進入了遺跡。")+[_cmd(0)]
    if map_id==MAP_RUINS and event_id==1:
        return [_cmd(201,0,[0,MAP_FOREST,12,6,4])]+_text(
            "你回到了森林。")+[_cmd(0)]
    if map_id==MAP_RUINS and event_id==2:
        if not world.switch_on(10):
            return _text("守門人：先擊退森林中的木靈。")+[_cmd(0)]
        if world.self_switch_on(map_id,event_id,"B"):
            return _text("守門人：旅途順利，祝福已經交給你了。")+[_cmd(0)]
        return _text("守門人：你已通過第一個考驗。")+[
            _cmd(102,0,[["領取祝福","暫不領取"],0]),
            _cmd(402,0,[0,"領取祝福"]),
            _cmd(121,1,[20,20,0]),
            _cmd(123,1,["B",0]),
            _cmd(126,1,[1,0,0,1]),
        ]+_text("你取得另一株藥草，事件進度已記錄。")+[
            _cmd(402,0,[1,"暫不領取"]),
        ]+_text("守門人：準備好再來。")+[
            _cmd(404),_cmd(0)]
    return []
