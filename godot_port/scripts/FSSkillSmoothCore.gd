extends RefCounted
class_name FSSkillSmoothCore

# Source-constrained positive direct-damage SKILL subset. Not 505-alias parity.
# Original source:
#   CustomDmgFormulaRD ~197335: YE::BATTLE::SKILL::ATK_F=2, ATK_D=1,
#   SPI_F=2, SPI_D=1, integer term arithmetic, CRIT_MOD=200/100;
#   RuntimeIntegration ~205453: AFTER original crit/variance/guard,
#   positive-damage legacy/smooth DEF ratio, truncated to Integer.
#   TargetFix DEF_CONST120. Original runtime Note source may override ALL
#   of this. Only explicitly authorized synthetic rows use this adapter.
#
# This path is intentionally OFF for production until the original
# post-FS_DB_AUTOSET runtime and full 505-script alias witness exist.
var active: bool = false
var errors: Array[String] = []
var events: Array[Dictionary] = []

func _fail(reason: String) -> Dictionary:
    if not errors.has(reason):
        errors.append(reason)
    return {"ok":false,"reason":reason}

static func _pen_from_note(note: String) -> Dictionary:
    var pen: int = 0
    var rx := RegEx.new()
    if rx.compile("(?i)<([^>]*)>") != OK:
        return {"ok":false}
    var valid := RegEx.new()
    if valid.compile("(?i)^pen_rate\\s*:\\s*(-?[0-9]+)$") != OK:
        return {"ok":false}
    for m in rx.search_all(note):
        var sub: String = m.get_string(1).strip_edges()
        var found: RegExMatch = valid.search(sub)
        if found == null:
            return {"ok":false}
        pen += int(found.get_string(1))
    # Plain text without executable tags is source-comment neutral.
    return {"ok":true,"pen":pen}

func quote(battle,user: Dictionary,target: Dictionary,
        skill: Dictionary) -> Dictionary:
    if not active:
        return {"ok":true,"enabled":false}
    if not battle.accuracy.active:
        return _fail("FS 平滑技能需來源命中／暴擊權威")
    if not bool(skill.get("fs_smooth_source_verified",false)) or not bool(
            user.get("fs_smooth_battler_verified",false)) or not bool(
            target.get("fs_smooth_battler_verified",false)):
        return _fail("技能或雙方角色尚無完整來源/別名權威")
    if bool(skill.get("fs_smooth_external_effects_pending",false)) or bool(
            target.get("fs_smooth_external_effects_pending",false)) or bool(
            user.get("fs_smooth_external_effects_pending",false)):
        return _fail("尚有未知技能／裝備／被動效果")
    if int(skill.get("base_damage",0)) <= 0 or int(
            skill.get("scope",0)) != 1:
        return _fail("此來源子集合只處理對敵方的單體正傷害技能")
    if not skill.get("plus_state_set",[]).is_empty() or not skill.get(
            "minus_state_set",[]).is_empty() or bool(
            skill.get("damage_to_mp",false)) or bool(
            skill.get("absorb_damage",false)):
        return _fail("技能還包含未移植的狀態／MP 吸收效果")
    for key in ["acdf","newatk_f","newspi_f","def_f","agi_f",
            "hp_hi","hp_lo","mp_hi","mp_lo","mul_variable",
            "div_variable","add_variable","sub_variable"]:
        if int(skill.get(key,0)) != 0:
            return _fail("技能存在尚未驗證的係數："+key)
    for key in ["mul_level","div_level","add_level","sub_level"]:
        if bool(skill.get(key,false)):
            return _fail("尚無來源等級倍率證據："+key)
    for key in ["atk","spi","def","agi"]:
        if not user.has(key) or not target.has(key):
            return _fail("無法取得技能傷害角色屬性："+key)
    if not skill.has("variance") or not (skill.get("element_set",null) is Array):
        return _fail("缺少原始技能 variance 或元素集合")
    if int(skill["variance"]) < 0 or int(skill["variance"]) > 100:
        return _fail("技能 variance 不在來源安全範圍")
    if not bool(target.get("fs_smooth_element_neutral_verified",false)):
        return _fail("技能原版屬性倍率未驗證，不能假定100%")
    var note_result: Dictionary = _pen_from_note(str(
        skill.get("note","")))
    if not bool(note_result.get("ok",false)):
        return _fail("技能 Note 有未移植的公式或追加效果")
    var pen: int = int(note_result["pen"])
    for actor in [user]:
        var notes: Variant = actor.get("fs_smooth_source_notes",[])
        if not (notes is Array):
            return _fail("裝備／被動 Note 權威型別不合法")
        for note_text in notes:
            var parsed: Dictionary = _pen_from_note(str(note_text))
            if not bool(parsed.get("ok",false)):
                return _fail("來源裝備／狀態存在尚未驗證的公式")
            pen += int(parsed["pen"])
    pen = clampi(pen,0,80)
    var attack: int = battle.boss_state_effects.stat(user,"atk")
    var spirit: int = battle.boss_state_effects.stat(user,"spi")
    var enemy_def: int = battle.boss_state_effects.stat(target,"def")
    var enemy_spi: int = battle.boss_state_effects.stat(target,"spi")
    var af: int = int(skill.get("atk_f",0))
    var sf: int = int(skill.get("spi_f",0))
    # Source YEM RD uses int terms for all coefficients, so enforce the
    # same truncation per term, unlike a one-shot floating sum.
    var raw: int = int(skill["base_damage"])
    raw += int(float(attack)*2.0*float(af)/100.0)
    raw += int(float(spirit)*2.0*float(sf)/100.0)
    var def_penalty: int = 0
    if not bool(skill.get("ignore_defense",false)):
        def_penalty += int(float(enemy_def)*float(af)/100.0)
        def_penalty += int(float(enemy_spi)*float(sf)/100.0)
    var legacy_damage: int = maxi(1,raw-def_penalty)
    var denominator: float = float(af+sf)
    # Source albert_bfrt_smooth_defense_ratio weights enemy DEF with
    # atk_f*ATK_D and target SPI with spi_f*SPI_D (both =1).
    var ratio: float = 1.0
    var smooth: float = float(legacy_damage)
    var legacy_core: float = float(legacy_damage)
    if not bool(skill.get("ignore_defense",false)) and denominator > 0.0:
        var raw_float: float = float(skill["base_damage"])+(
            float(attack)*2.0*float(af)+
            float(spirit)*2.0*float(sf))/100.0
        var penalty: float = (float(enemy_def)*float(af)+
            float(enemy_spi)*float(sf))/100.0
        legacy_core = maxf(1.0,raw_float-penalty)
        var effective_def: float = (float(enemy_def)*float(af)+
            float(enemy_spi)*float(sf))/denominator
        effective_def = maxf(0.0,effective_def*float(100-pen)/100.0)
        smooth = maxf(1.0,raw_float*120.0/(120.0+effective_def))
        ratio = smooth/legacy_core
    return {"ok":true,"enabled":true,"legacy":legacy_damage,
        "legacy_core":legacy_core,"smooth":smooth,
        "ratio":ratio,"pen":pen,"raw":raw,
        "def_penalty":def_penalty}

func resolve(battle,user: Dictionary,target: Dictionary,
        skill: Dictionary,crit_chance: int) -> Dictionary:
    var q: Dictionary = quote(battle,user,target,skill)
    if not bool(q.get("ok",false)):
        return q
    var damage: int = int(q["legacy"])
    var critical: bool = false
    if damage > 0:
        # Source YEM::CRIT_SKILL first consumes a PROVISIONAL rand(100)
        # even if skill.has_critical is false. The later safe
        # common_critical overrides @critical: for has_critical=false it
        # returns false without an additional rand, but eligible critical
        # skills consume a SECOND d100 unless target prevents critical.
        var provisional: int = battle.accuracy._rand(100,
            "legacy_skill_critical_provisional")
        if provisional < 0:
            return _fail("YEM 技能首次暴擊抽籤越界")
        if bool(skill.get("has_critical",false)) and not bool(
                target.get("prevent_critical",false)):
            var final_roll: int = battle.accuracy._rand(100,
                "skill_critical_final")
            if final_roll < 0:
                return _fail("YEM 技能最終暴擊抽籤越界")
            critical = final_roll < crit_chance
        if critical:
            damage *= 2
    var varied: Dictionary = battle.accuracy.variance(damage,int(
        skill.get("variance",0)))
    if not bool(varied.get("ok",false)):
        return varied
    damage = int(varied["damage"])
    if damage > 0 and bool(target.get("guarding",false)):
        damage = int(damage/(4 if bool(
            target.get("super_guard",false)) else 2))
    # RuntimeIntegration wraps the already-generated positive skill
    # damage with Integer.to_i(smooth/legacy), not Ruby round.
    if damage > 0 and absf(float(q["ratio"])-1.0)>=0.0001:
        damage = maxi(1,int(float(damage)*float(q["ratio"])))
    events.append({"legacy":int(q["legacy"]),
        "ratio":float(q["ratio"]),"damage":damage,
        "critical":critical,"penetration":int(q["pen"])})
    return {"ok":true,"hp":damage,"critical":critical,
        "legacy":int(q["legacy"]),"smooth":float(q["smooth"]),
        "ratio":float(q["ratio"]),"pen":int(q["pen"])}
