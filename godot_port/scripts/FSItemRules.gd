extends RefCounted
class_name FSItemRules

# Narrow, explicit stock RPG Maker VX Game_Battler#calc_hp/mp_recovery subset.
# Full FS 505-script effective overrides & MasterSetup apply_all NOT certified.
# Do not add new effects here unless both the final source method and test
# fixtures have been traced. Any unknown feature must fail BEFORE inventory loss.

static func preview(item: Dictionary, user: Dictionary, target: Dictionary,
        in_battle: bool) -> Dictionary:
    if item.is_empty():
        return _refuse("來源物品不存在")
    var id: int = int(item.get("id",0))
    if id <= 0:
        return _refuse("物品缺少有效原始 ID")
    var occasion: int = int(item.get("occasion",0))
    if occasion == 3 or (in_battle and occasion == 2) or (
            not in_battle and occasion == 1):
        return _refuse("物品在目前場景不可使用")
    # Only VX scope 7: one living friend. Multi-target, random, dead-friend,
    # enemy and non-target scopes require full target resolution in battle.
    if int(item.get("scope",-1)) != 7:
        return _refuse("物品目標範圍尚未完整轉譯")
    if not bool(target.get("actor",false)) or int(target.get("hp",0)) <= 0:
        return _refuse("只能指定存活的我方角色")
    if not str(item.get("note","")).strip_edges().is_empty():
        return _refuse("存在 FS 自訂 Note 標籤，需追查有效事件/效果")
    if not item.get("plus_state_set",[]).is_empty() or not item.get("minus_state_set",[]).is_empty():
        return _refuse("狀態增減尚未完整轉譯")
    if int(item.get("common_event_id",0)) != 0:
        return _refuse("公共事件效果尚未完整轉譯")
    if int(item.get("parameter_type",0)) != 0 or int(item.get("parameter_points",0)) != 0:
        return _refuse("永久參數強化尚未完整轉譯")
    if int(item.get("base_damage",0)) != 0 or bool(item.get("damage_to_mp",false)):
        return _refuse("物品傷害與 MP 直接傷害尚未完整轉譯")
    if bool(item.get("absorb_damage",false)) or bool(item.get("physical_attack",false)):
        return _refuse("吸收或物理技能效果尚未完整轉譯")
    if int(item.get("atk_f",0)) != 0 or int(item.get("spi_f",0)) != 0:
        return _refuse("物品能力倍率尚未完整轉譯")
    if int(item.get("variance",0)) != 0 or not item.get("element_set",[]).is_empty():
        return _refuse("隨機變動或屬性尚未完整轉譯")

    var max_hp: int = maxi(0,int(target.get("maxhp",0)))
    var max_mp: int = maxi(0,int(target.get("maxmp",0)))
    var old_hp: int = clampi(int(target.get("hp",0)),0,max_hp)
    var old_mp: int = clampi(int(target.get("mp",0)),0,max_mp)
    # Ruby integer division truncates toward negative infinity, but only
    # nonnegative recovery terms are allowed here and work identically.
    var hp_amount: int = (max_hp * int(item.get("hp_recovery_rate",0))) / 100
    hp_amount += int(item.get("hp_recovery",0))
    var mp_amount: int = (max_mp * int(item.get("mp_recovery_rate",0))) / 100
    mp_amount += int(item.get("mp_recovery",0))
    if hp_amount < 0 or mp_amount < 0:
        return _refuse("負數回復實際為特殊物品效果，暫不支援")
    if hp_amount == 0 and mp_amount == 0:
        return _refuse("物品沒有經核准的回復效果")
    if bool(user.get("pharmacology",false)):
        hp_amount *= 2
        mp_amount *= 2
    var new_hp: int = mini(max_hp,old_hp+hp_amount)
    var new_mp: int = mini(max_mp,old_mp+mp_amount)
    if new_hp == old_hp and new_mp == old_mp:
        return _refuse("目前 HP／MP 已滿，保護性不扣物品")
    return {"ok":true,"new_hp":new_hp,"new_mp":new_mp,
        "hp_gain":new_hp-old_hp,"mp_gain":new_mp-old_mp,
        "consumable":bool(item.get("consumable",true))}

static func _refuse(reason: String) -> Dictionary:
    return {"ok":false,"reason":reason}
