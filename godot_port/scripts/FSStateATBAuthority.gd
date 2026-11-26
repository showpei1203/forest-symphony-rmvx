extends RefCounted
class_name FSStateATBAuthority

# Source #230 State defaults + #234 Tankentai Notetags Add-on, scoped
# static interpretation only. Explicit typed provider results override
# Note fallback. No State attachment or automatic game effects here.
static func resolve(state: Dictionary,expected_id: int) -> Dictionary:
    if expected_id <= 0 or int(state.get("id",0)) != expected_id:
        return {"ok":false,"reason":"State identity missing"}
    var has_note: bool = typeof(state.get("note",null)) == TYPE_STRING
    var explicit_negative: bool = state.has("atb_minus_damage")
    var explicit_damage: bool = state.has("atb_damage")
    if explicit_negative and typeof(state["atb_minus_damage"]) != TYPE_BOOL:
        return {"ok":false,"reason":"State lower-bound method is not Boolean"}
    if not has_note and not explicit_negative:
        return {"ok":false,"reason":"State lower-bound source missing"}
    var allow_negative: bool = true # #230 L389-391
    var damage_percent: int = 0 # #230 L380-383
    if has_note:
        var note: String = str(state["note"])
        # #234 L211-212 exact optional single whitespace and optional sign.
        # The first match is authoritative, as in the original Ruby =~.
        var lower := RegEx.new()
        var damage := RegEx.new()
        if lower.compile("(?i)<([-+])?(?:ATB\\s?MINUS\\s?DAMAGE|negative\\s?atb)>") != OK or (
                damage.compile("(?i)<ATB\\s?DAMAGE[:]?\\s*([-+]?[0-9]+)[%]?\\s*>") != OK):
            return {"ok":false,"reason":"State ATB regex unavailable"}
        var low_match: RegExMatch = lower.search(note)
        if low_match != null:
            allow_negative = low_match.get_string(1) != "-"
        var damage_match: RegExMatch = damage.search(note)
        if damage_match != null:
            var raw: String = damage_match.get_string(1)
            # Bounded candidate only; Ruby arbitrary-size integers are not
            # silently converted to overflowing GDScript int values.
            if raw.length() > 9:
                return {"ok":false,"reason":"State ATB damage outside scoped integer range"}
            damage_percent = int(raw)
    if explicit_negative:
        allow_negative = bool(state["atb_minus_damage"])
    if explicit_damage:
        var value: Variant = state["atb_damage"]
        if typeof(value) not in [TYPE_INT,TYPE_FLOAT] or (
                absf(float(value)) > 1000000.0) or (
                float(value) != float(int(value))):
            return {"ok":false,"reason":"State ATB damage not bounded integral"}
        damage_percent = int(value)
    if absi(damage_percent) > 1000000:
        return {"ok":false,"reason":"State ATB damage outside scoped range"}
    return {"ok":true,"allows_negative":allow_negative,
        "damage_known":has_note or explicit_damage,"damage_percent":damage_percent,
        "source":"explicit provider" if explicit_negative else "#230/#234 Note static"}
