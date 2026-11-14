extends RefCounted
class_name FSAIRandom

# Source #210 FS_AI_DeterministicRandom v1.0.
# Production draws Godot random values; deterministic LCG is explicitly
# enabled only in isolated synthetic tests, not by default in FS gameplay.
const MODULUS_MASK: int = 0x7fffffff
const TRACE_LIMIT: int = 2000
var deterministic_test: bool = false
var state: int = 12345
var count: int = 0
var trace: Array[Dictionary] = []

func enable_test(seed: int = 12345) -> void:
    deterministic_test = true
    state = seed & MODULUS_MASK
    if state == 0:
        state = 1
    count = 0
    trace.clear()

func disable_test() -> void:
    deterministic_test = false
    count = 0
    trace.clear()

func roll(maximum: int,tag: String) -> int:
    if maximum <= 0:
        push_error("FS_AI_RANDOM requires max > 0")
        return -1
    var value: int
    if deterministic_test:
        state = (1103515245 * state + 12345) & MODULUS_MASK
        value = state % maximum
        count += 1
        trace.append({"count":count,"tag":tag,"maximum":maximum,"value":value})
        if trace.size() > TRACE_LIMIT:
            trace.pop_front()
    else:
        value = randi_range(0,maximum-1)
    return value
