extends RefCounted
class_name FSAnimationProfile

# Presentation-only action manifest. NO hardcoded 3-frame limit.
# Animations are independent of damage/ATB hit calculations.

const LEGACY_POSTFIXES: Array[String] = ["", "_1", "_2", "_3"]

static func legacy_kaduki(prefix: String, asset_folder: String = "res://assets/characters/",
        frame_duration_ms: int = 140) -> Dictionary:
    # Source 4 PNG sheets each 3×4. Cell dimensions derived from the loaded
    # image, never hardcoded to 32px; source includes 30px cell exceptions.
    var clips: Dictionary = {}
    for action_index in range(16):
        var sheet_index: int = int(action_index / 4)
        var row: int = action_index % 4
        var file: String = "%s%s%s.png" % [asset_folder,prefix,LEGACY_POSTFIXES[sheet_index]]
        var frames: Array = []
        for col in range(3):
            frames.append({
                "texture":file,
                "grid":{"columns":3,"rows":4,"column":col,"row":row},
                "duration_ms":maxi(1,frame_duration_ms)
            })
        clips["legacy_%02d" % action_index] = {
            "loop":true,
            "frames":frames
        }
    return {"schema":"fs-animation-v1","source":"legacy_kaduki","clips":clips}

static func sample_flexible() -> Dictionary:
    # Pure synthetic authoring fixture. Demonstrates clip-specific frame count:
    # actual frame images are intentionally NOT included in public repo.
    return {"schema":"fs-animation-v1","source":"new_godot",
        "clips":{
            "idle":{"loop":true,"frames":[{"texture":"res://assets/characters/actor_idle.png",
                "grid":{"columns":1,"rows":1,"column":0,"row":0},"duration_ms":400}]},
            "walk_down":{"loop":true,"frames":[
                {"texture":"res://assets/characters/actor_walk.png",
                "grid":{"columns":8,"rows":4,"column":i,"row":0},
                "duration_ms":80 if i%2 else 110} for i in range(8)]},
            "attack":{"loop":false,"frames":[
                {"texture":"res://assets/characters/actor_attack.png",
                "grid":{"columns":6,"rows":1,"column":i,"row":0},
                "duration_ms":60 if i < 3 else 120,
                "marker":"impact" if i==3 else ""} for i in range(6)]}
        }
    }

static func validate(profile: Dictionary) -> PackedStringArray:
    var errors := PackedStringArray()
    if str(profile.get("schema","")) != "fs-animation-v1":
        errors.append("動畫資料格式不支援")
        return errors
    var clips: Variant = profile.get("clips",{})
    if not clips is Dictionary or clips.is_empty():
        errors.append("動畫至少要有一個 clip")
        return errors
    for action_name in clips:
        var clip: Variant = clips[action_name]
        if not clip is Dictionary or not clip.get("frames",[]) is Array:
            errors.append("%s：動畫清單格式不正確" % str(action_name))
            continue
        var frames: Array = clip.get("frames",[])
        if frames.is_empty():
            errors.append("%s：動畫不得為空" % str(action_name))
        for index in frames.size():
            var frame: Variant = frames[index]
            if not frame is Dictionary:
                errors.append("%s[%d]：影格非 Dictionary" % [str(action_name),index])
                continue
            if int(frame.get("duration_ms",0)) < 1:
                errors.append("%s[%d]：每格須有正數毫秒" % [str(action_name),index])
            var source: Variant = frame.get("texture",null)
            if not (source is Texture2D or (source is String and not str(source).is_empty())):
                errors.append("%s[%d]：未指定貼圖來源" % [str(action_name),index])
            if frame.has("grid"):
                var grid: Dictionary = frame.get("grid",{})
                var columns: int = int(grid.get("columns",0))
                var rows: int = int(grid.get("rows",0))
                if columns < 1 or rows < 1 or int(grid.get("column",-1)) not in range(columns) or int(grid.get("row",-1)) not in range(rows):
                    errors.append("%s[%d]：圖集座標不合法" % [str(action_name),index])
            elif frame.has("rect"):
                var rect: Variant = frame["rect"]
                if not rect is Array or rect.size()!=4 or float(rect[2])<=0 or float(rect[3])<=0:
                    errors.append("%s[%d]：裁切矩形不合法" % [str(action_name),index])
    return errors
