extends "res://tests/test_fs_battle_accuracy_205.gd"

func _run() -> void:
    var b: FSBattle = _battle()
    b.add_enemy(1)
    if not _check(b.start(),"outcome battle start"): return
    var hero: Dictionary = b.party[0]
    var e0: Dictionary = b.enemies[0]
    var e1: Dictionary = b.enemies[1]
    var events: Array[Dictionary] = []
    var order: Array[String] = []
    b.target_outcome_resolved.connect(func(e: Dictionary):
        events.append(e)
        order.append("outcome"))
    b.finished.connect(func(_victory: bool): order.append("finished"))
    b.accuracy.scripted_rolls = [95]
    if not _check(b.attack_preflight(hero,e0) and events.is_empty(),"preflight silent"): return
    b.attack(hero,e0)
    if not _check(events.size()==1 and events[0]["result"]=="miss" and events[0]["serial"]==1 and events[0].is_read_only(),"miss snapshot"): return
    b.changed.emit("refresh")
    if not _check(events.size()==1,"refresh silent"): return
    b.accuracy.scripted_rolls=[0,0]
    b.attack(hero,e1)
    if not _check(events.size()==2 and events[1]["result"]=="evade" and events[1]["recipient_slot"]==1 and events[1]["recipient_id"]==events[0]["recipient_id"],"duplicate enemy ID slot identity"): return
    b.accuracy.scripted_rolls=[0,99,99,0,9]
    if not _check(b.attack(hero,e0)==180 and events.size()==3 and events[2]["hp_effect"]==180,"hit after commit"): return
    b.accuracy.scripted_rolls=[100]
    b.attack(hero,e0)
    if not _check(events.size()==3,"invalid RNG silent"): return
    b.accuracy.scripted_rolls=[50]
    if not _check(b.use_skill(hero,e0,1) and events.size()==4 and events[3]["result"]=="miss" and int(hero["mp"])==90,"skill miss paid once"): return
    b.accuracy.scripted_rolls=[0,0]
    if not _check(b.use_skill(hero,e1,2) and events.size()==5 and events[4]["result"]=="evade" and int(hero["mp"])==78,"skill evade paid once"): return
    b.accuracy.scripted_rolls=[49,0]
    if not _check(b.use_skill(hero,e1,1) and events.size()==6 and events[5]["hp_effect"]==100 and events[5]["skill_id"]==1,"skill hit"): return
    if not _check(not b.use_skill(hero,e0,999) and events.size()==6,"rejected skill silent"): return
    e0["hp"]=0
    e1["hp"]=1
    b.accuracy.scripted_rolls=[0,99,99,0,9]
    b.attack(hero,e1)
    if not _check(events.size()==7 and not events[6]["recipient_alive"] and order.slice(-2)==["outcome","finished"],"lethal event precedes battle finish"): return
    for i in range(events.size()):
        if not _check(events[i]["serial"]==i+1,"monotonic serial"): return
    print("FLOW_V4_OUTCOME_PASS cases=11 events=7")
    quit(0)
