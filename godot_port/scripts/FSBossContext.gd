extends RefCounted
class_name FSBossContext

# Source authority: #401 FS_DB_AutoSetup_ContextEnemy/Game_Enemy
# and #440 FS_MasterSetup_15::BOSS_RUNTIME::CONTEXT_ACTIONS.
# Both published RGSS2 mappings were compared byte-for-byte on migration.
# This is the candidate dynamic ACTION REPLACEMENT only. Boss setup,
# summons, Weather, State/Phase updates and runtime skill effects remain
# unresolved and are intentionally not simulated here.

const CONTEXT_ACTIONS: Dictionary = {551 : {507 : [[1, 316, 7], [1, 317, 9]], 540 : [[1, 300, 7], [1, 302, 8]]}, 552 : {508 : [[1, 318, 7], [1, 319, 9]], 541 : [[1, 312, 8]]}, 553 : {509 : [[1, 306, 7], [1, 307, 8]], 542 : [[0, 0, 5], [1, 304, 8]]}, 554 : {510 : [[0, 0, 5], [1, 320, 8]], 543 : [[1, 406, 8]]}, 555 : {510 : [[0, 0, 5], [1, 320, 8]], 544 : [[1, 308, 7], [1, 408, 9]]}, 556 : {510 : [[0, 0, 5], [1, 320, 8]], 545 : [[0, 0, 5], [1, 410, 9]]}, 557 : {520 : [[1, 330, 8]], 546 : [[1, 413, 9]]}, 558 : {521 : [[1, 333, 7], [1, 334, 9]], 547 : [[1, 414, 9]], 548 : [[1, 404, 9]]}, 559 : {522 : [[1, 336, 9]], 549 : [[1, 408, 9]]}, 560 : {523 : [[1, 338, 8], [1, 339, 9]], 550 : [[1, 410, 9]]}, 561 : {530 : [[1, 350, 8]]}, 562 : {531 : [[0, 0, 5], [1, 353, 9]]}, 563 : {531 : [[1, 350, 8]]}, 564 : {531 : [[1, 355, 9]]}, 565 : {531 : [[1, 308, 7], [1, 352, 9]]}}

static func has_core(core_id: int) -> bool:
    return CONTEXT_ACTIONS.has(core_id)

static func resolve(core_id: int,battlers: Array[Dictionary]) -> Dictionary:
    var table: Dictionary = CONTEXT_ACTIONS.get(core_id,{})
    if table.is_empty():
        return {"matched":false}
    # Source #401 context_action_specs iterates boss keys in ascending
    # order and checks ALL troop.members, not just surviving enemies.
    var boss_ids: Array = table.keys()
    boss_ids.sort()
    for boss_id in boss_ids:
        var exists: bool = false
        for battler in battlers:
            if int(battler.get("id",0)) == int(boss_id):
                exists = true
                break
        if not exists:
            continue
        var actions: Array[Dictionary] = []
        for spec in table[boss_id]:
            # Source #401 FS_DB_AutoSetup_ContextEnemy.new:
            # kind/spec[0], basic=0, skill/spec[1], rating/spec[2],
            # condition_type/params=0, conditions_arrays=[].
            actions.append({
                "kind":int(spec[0]),"basic":0,"skill_id":int(spec[1]),
                "rating":int(spec[2]),"condition_type":0,
                "condition_param1":0,"condition_param2":0,
                "conditions_arrays":[]
            })
        return {"matched":true,"core_id":core_id,
            "boss_id":int(boss_id),"actions":actions}
    # Source #401 delegates to original candidate_actions_enemy when
    # none of its known encounter bosses exists.
    return {"matched":false}
