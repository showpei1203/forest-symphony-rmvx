extends "res://tests/test_fs_ivy_cover_native_522.gd"

func _run() -> void:
    var b: FSBattle = _battle()
    if not _check(b.start(),"start"): return
    var ally: Dictionary=b.party[0]
    var ivy: Dictionary=b.party[1]
    var enemy: Dictionary=b.enemies[0]
    var events: Array[Dictionary]=[]
    b.target_outcome_resolved.connect(func(e: Dictionary): events.append(e))
    var note: Dictionary={"fs_ivy_guard_tag_verified":true,"note":"<ig:2,3,25>"}
    if not _check(bool(b.ivy_cover.activate_main_guard(b,ivy,note).get("ok",false)),"activate"): return
    _scripted_hit(b)
    if not _check(b.attack(enemy,ally)==58 and events.size()==1,"one redirected hit"): return
    var e: Dictionary=events[0]
    if not _check(e["selected_slot"]==0 and e["recipient_slot"]==1 and e["recipient_id"]==5 and e["redirected"] and e["hp_effect"]==58 and int(ally["hp"])==1000 and int(ivy["hp"])==942,"real recipient"): return
    b.accuracy.scripted_rolls=[95]
    b.attack(enemy,ally)
    if not _check(events.size()==2 and events[1]["result"]=="miss" and not events[1]["redirected"] and events[1]["recipient_slot"]==0,"miss does not redirect"): return
    print("FLOW_V4_COVER_OUTCOME_PASS cases=3")
    quit(0)
