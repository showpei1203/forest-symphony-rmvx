@tool
extends RefCounted
class_name FSStoryCompiler

# A graphical script step compiles into a real VX EventCommand tuple:
# {"code": int, "indent": int, "parameters": Array}
# Original RVData can be adapted to this tuple without using our new authoring format.

const LABELS: Dictionary = {
    "dialogue":"顯示對話", "choice":"選項開始", "when_choice":"選項分支",
    "when_cancel":"取消選項分支", "end_choice":"選項結束",
    "if_switch":"條件：開關", "if_variable":"條件：變數",
    "else":"否則", "end_if":"條件結束",
    "switch":"控制開關", "variable":"控制變數", "self_switch":"控制獨立開關",
    "item":"取得／失去物品", "gold":"取得／失去金錢",
    "party_add":"角色入隊", "party_remove":"角色離隊",
    "wait":"等待幀", "transfer":"移動場所",
    "battle":"開始戰鬥", "when_win":"勝利", "when_escape":"逃跑", "when_lose":"戰敗",
    "end_battle":"戰鬥結束", "comment":"註解"
}
const OPS: Array[String] = [
    "dialogue", "choice", "when_choice", "when_cancel", "end_choice",
    "if_switch", "if_variable", "else", "end_if", "switch", "variable",
    "self_switch", "item", "gold", "party_add", "party_remove", "wait",
    "transfer", "battle", "when_win", "when_escape", "when_lose", "end_battle", "comment"
]

static func default_step(op: String) -> Dictionary:
    match op:
        "dialogue": return {"op":op, "text":"你好！", "face":"", "face_index":0, "background":0, "position":2}
        "choice": return {"op":op, "options":["好","不好"],"cancel_type":0}
        "when_choice": return {"op":op, "index":0}
        "when_cancel", "end_choice", "else", "end_if", "when_win", "when_escape", "when_lose", "end_battle":
            return {"op":op}
        "if_switch", "switch": return {"op":op, "id":1, "enabled":true}
        "if_variable": return {"op":op, "id":1, "compare":0, "value":0}
        "variable": return {"op":op, "id":1, "operation":0,"source":0,"value":1, "random_to":5}
        "self_switch": return {"op":op, "letter":"A", "enabled":true}
        "item": return {"op":op, "id":1, "amount":1}
        "gold": return {"op":op, "amount":100}
        "party_add", "party_remove": return {"op":op, "id":1}
        "wait": return {"op":op, "frames":30}
        "transfer": return {"op":op, "map_id":1, "x":0, "y":0, "direction":2}
        "battle": return {"op":op, "troop_id":1, "escape":true, "lose":false}
        "comment": return {"op":op, "text":"事件註解"}
        _: return {}

static func describe(step: Dictionary) -> String:
    var op: String = str(step.get("op",""))
    var label: String = str(LABELS.get(op, "未知指令 " + op))
    match op:
        "dialogue", "comment":
            var contents: String = str(step.get("text","")).replace("\n"," ⏎ ")
            return label + "： " + contents.substr(0,48)
        "choice":
            return label + "：" + "／".join(step.get("options",[]))
        "if_switch", "switch":
            return label + " #%d %s" % [int(step.get("id",0)), "ON" if bool(step.get("enabled",false)) else "OFF"]
        "variable", "if_variable":
            return label + " #%d" % int(step.get("id",0))
        "self_switch":
            return label + " " + str(step.get("letter","A"))
        "item", "party_add", "party_remove":
            return label + " #%d" % int(step.get("id",0))
        "gold":
            return label + " %d" % int(step.get("amount",0))
        "wait":
            return label + " %d" % int(step.get("frames",0))
        "transfer":
            return label + " Map %03d (%d,%d)" % [int(step.get("map_id",0)),int(step.get("x",0)),int(step.get("y",0))]
        "battle":
            return label + " Troop #%d" % int(step.get("troop_id",0))
        "when_choice":
            return label + " %d" % (int(step.get("index",0)) + 1)
    return label

static func _append(output: Array, code: int, indent: int, params: Array = []) -> void:
    output.append({"code":code,"indent":indent,"parameters":params})

static func _error(errors: Array, at: int, reason: String) -> void:
    errors.append("指令 %d：%s" % [at + 1,reason])

static func compile_page(page: Dictionary) -> Dictionary:
    var errors: Array = []
    var result: Array = []
    var stack: Array = [] # [{kind, has_else, seen:[indexes]}]
    var steps: Array = page.get("steps", [])
    for n in steps.size():
        if not steps[n] is Dictionary:
            _error(errors,n,"不是有效的事件指令")
            continue
        var step: Dictionary = steps[n]
        var op: String = str(step.get("op",""))
        var depth: int = stack.size()
        var top: Dictionary = stack.back() if not stack.is_empty() else {}
        var id: int = int(step.get("id",0))
        match op:
            "dialogue":
                var lines: PackedStringArray = str(step.get("text","")).split("\n",true)
                var offset: int = 0
                while offset < lines.size():
                    _append(result,101,depth,[
                        str(step.get("face","")),int(step.get("face_index",0)),
                        int(step.get("background",0)),int(step.get("position",2))])
                    for j in range(offset,mini(offset+4,lines.size())):
                        _append(result,401,depth,[lines[j]])
                    offset += 4
            "comment":
                var comments: PackedStringArray = str(step.get("text","")).split("\n",true)
                for i in comments.size():
                    _append(result,108 if i==0 else 408,depth,[comments[i]])
            "switch":
                if id <= 0:
                    _error(errors,n,"開關 ID 必須大於 0")
                else:
                    _append(result,121,depth,[id,id,0 if bool(step.get("enabled",true)) else 1])
            "self_switch":
                var letter: String = str(step.get("letter","A"))
                if not letter in ["A","B","C","D"]:
                    _error(errors,n,"獨立開關必須是 A/B/C/D")
                else:
                    _append(result,123,depth,[letter,0 if bool(step.get("enabled",true)) else 1])
            "variable":
                var operation: int = int(step.get("operation",0))
                var source: int = int(step.get("source",0))
                var value: int = int(step.get("value",0))
                var top_limit: int = int(step.get("random_to",0))
                if id <= 0 or operation < 0 or operation > 5 or source < 0 or source > 2:
                    _error(errors,n,"變數 ID／運算／來源不合法")
                elif source == 1 and value < 1:
                    _error(errors,n,"作為來源的變數 ID 必須大於 0")
                elif source == 2 and value > top_limit:
                    _error(errors,n,"亂數下限大於上限")
                else:
                    var params: Array = [id,id,operation,source,value]
                    if source == 2:
                        params.append(top_limit)
                    _append(result,122,depth,params)
            "if_switch":
                if id <= 0:
                    _error(errors,n,"條件開關 ID 不合法")
                else:
                    _append(result,111,depth,[0,id,0 if bool(step.get("enabled",true)) else 1])
                    stack.append({"kind":"if","has_else":false})
            "if_variable":
                var compare: int = int(step.get("compare",0))
                if id <= 0 or compare < 0 or compare > 5:
                    _error(errors,n,"條件變數參數不合法")
                else:
                    _append(result,111,depth,[1,id,0,int(step.get("value",0)),compare])
                    stack.append({"kind":"if","has_else":false})
            "else":
                if top.get("kind","") != "if" or bool(top.get("has_else",false)):
                    _error(errors,n,"否則必須位於尚未使用 else 的 if 區塊")
                else:
                    _append(result,411,depth-1)
                    stack[-1]["has_else"] = true
            "end_if":
                if top.get("kind","") != "if":
                    _error(errors,n,"條件結束缺少 if 開始")
                else:
                    stack.pop_back()
                    _append(result,412,depth-1)
            "choice":
                var options: Array = step.get("options",[])
                var cancel: int = int(step.get("cancel_type",0))
                if options.is_empty() or options.size() > 4 or cancel < 0 or cancel > 5:
                    _error(errors,n,"VX 選項必須 1 至 4 個，取消行為 0 至 5")
                elif cancel > options.size() and cancel != 5:
                    _error(errors,n,"取消時選項索引超出範圍")
                else:
                    _append(result,102,depth,[options,cancel])
                    stack.append({"kind":"choice","options":options,"seen":[],"cancel":cancel})
            "when_choice":
                var which: int = int(step.get("index",0))
                if top.get("kind","") != "choice":
                    _error(errors,n,"選項分支不在選項區塊內")
                elif which < 0 or which >= (top.get("options",[]) as Array).size() or which in top.get("seen",[]):
                    _error(errors,n,"選項分支索引重複或超出範圍")
                else:
                    stack[-1]["seen"].append(which)
                    var title: String = str(top["options"][which])
                    _append(result,402,depth-1,[which,title])
            "when_cancel":
                if top.get("kind","") != "choice" or int(top.get("cancel",0)) != 5 or bool(top.get("seen_cancel",false)):
                    _error(errors,n,"必須先設定選項的取消分支（cancel_type 5）")
                else:
                    stack[-1]["seen_cancel"] = true
                    _append(result,403,depth-1)
            "end_choice":
                if top.get("kind","") != "choice":
                    _error(errors,n,"選項結束缺少選項開始")
                elif (top.get("seen",[]) as Array).size() != (top.get("options",[]) as Array).size():
                    _error(errors,n,"每個選項都需要獨立的選項分支")
                elif int(top.get("cancel",0)) == 5 and not bool(top.get("seen_cancel",false)):
                    _error(errors,n,"缺少取消選項分支")
                else:
                    stack.pop_back()
                    _append(result,404,depth-1)
            "wait":
                if int(step.get("frames",0)) < 0:
                    _error(errors,n,"等待幀不可小於 0")
                else:
                    _append(result,230,depth,[int(step.get("frames",0))])
            "transfer":
                var dest: int = int(step.get("map_id",0))
                if dest < 1:
                    _error(errors,n,"目的地 Map ID 不合法")
                else:
                    _append(result,201,depth,[0,dest,int(step.get("x",0)),int(step.get("y",0)),int(step.get("direction",2))])
            "battle":
                var troop: int = int(step.get("troop_id",0))
                if troop < 1:
                    _error(errors,n,"敵隊 Troop ID 不合法")
                else:
                    _append(result,301,depth,[0,troop,bool(step.get("escape",true)),bool(step.get("lose",false))])
                    stack.append({"kind":"battle","seen":[]})
            "when_win","when_escape","when_lose":
                var key: int = {"when_win":601,"when_escape":602,"when_lose":603}[op]
                if top.get("kind","") != "battle" or key in top.get("seen",[]):
                    _error(errors,n,"戰鬥結果分支必須置於 battle 內且不可重複")
                else:
                    stack[-1]["seen"].append(key)
                    _append(result,key,depth-1)
            "end_battle":
                if top.get("kind","") != "battle" or not 601 in top.get("seen",[]):
                    _error(errors,n,"戰鬥必須具備勝利分支")
                else:
                    stack.pop_back()
                    _append(result,604,depth-1)
            "item":
                var amount: int = int(step.get("amount",0))
                if id <= 0:
                    _error(errors,n,"物品 ID 必須大於 0")
                else:
                    _append(result,126,depth,[id,0 if amount >= 0 else 1,0,absi(amount)])
            "gold":
                var amount: int = int(step.get("amount",0))
                _append(result,125,depth,[0 if amount >= 0 else 1,0,absi(amount)])
            "party_add","party_remove":
                if id <= 0:
                    _error(errors,n,"角色 ID 必須大於 0")
                else:
                    _append(result,129,depth,[id,0 if op=="party_add" else 1,0])
            _:
                _error(errors,n,"尚未允許的指令類型：" + op)
    if not stack.is_empty():
        errors.append("事件區塊尚未關閉：%s" % str(stack.back().get("kind","")))
    if not errors.is_empty():
        return {"ok":false,"errors":errors,"commands":[]}
    _append(result,0,0)
    return {"ok":true,"errors":[],"commands":result}
