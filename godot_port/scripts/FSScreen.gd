extends Control

const FS_DB = preload("res://scripts/FSDatabase.gd")
const FS_BATTLE = preload("res://scripts/FSBattle.gd")
const FS_MENU = preload("res://scripts/FSMenuModel.gd")
const STORY_SANDBOX = preload("res://scripts/story/FSStorySandbox.gd")
var db: FSDatabase
var battle: FSBattle
var world: FSGameState
var menu_model: FSMenuModel
var formation_first: int = -1
var view_name: String = "MENU"
var body: VBoxContainer
var original_background: TextureRect
var title_label: Label
var status_label: Label
var log_label: Label
var actor_index: int = 0
var enemy_index: int = 0
var battle_command_buttons: Array[Button] = []
var selected_troop_id: int = 0
var story_sandbox: FSStorySandbox

func _ready() -> void:
    _build_shell()
    db = FS_DB.new()
    if not db.load_all():
        _add_button("開啟 Godot 地圖／事件測試場（非原始 FS 地圖）", _open_story_sandbox)
        title_label.text = "Forest Symphony｜原始資料未載入"
        status_label.text = "缺少啟動後 FS 正式資料與原 VX 權威證據。\n" + "\n".join(PackedStringArray(db.errors)) + "\n\n只匯入原始 RVData 不足以完成驗證；不使用假角色數值。"
        return
    world = FSGameState.new()
    var members: Array = db.system().get("party_members", [])
    for member_id in members:
        world.party_actor_ids.append(int(member_id))
    battle = FS_BATTLE.new(db, world)
    for member_id in world.party_actor_ids:
        battle.add_actor(int(member_id))
    menu_model = FS_MENU.new(db, battle)
    battle.changed.connect(_show_log)
    battle.finished.connect(_on_battle_finished)
    _show_menu()

func _build_shell() -> void:
    var back := ColorRect.new()
    back.color = Color(0.035, 0.065, 0.1)
    back.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(back)
    original_background = TextureRect.new()
    original_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    original_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    original_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    original_background.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
    original_background.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
    add_child(original_background)
    var layout := VBoxContainer.new()
    layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layout.add_theme_constant_override("separation", 7)
    add_child(layout)
    title_label = Label.new()
    title_label.text = "Forest Symphony / Godot P1 Candidate"
    title_label.add_theme_font_size_override("font_size", 20)
    layout.add_child(title_label)
    var tabs := HBoxContainer.new()
    layout.add_child(tabs)
    for tab in ["MENU", "BATTLE"]:
        var button := Button.new()
        button.text = tab
        button.pressed.connect(func() -> void: _change(tab))
        tabs.add_child(button)
    status_label = Label.new()
    layout.add_child(status_label)
    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    layout.add_child(scroll)
    body = VBoxContainer.new()
    body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 6)
    scroll.add_child(body)
    log_label = Label.new()
    log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    log_label.text = "狀態：來源資料等待驗證"
    layout.add_child(log_label)

func _process(delta: float) -> void:
    # The actual source Tankentai source-frame gauge now ticks in real gameplay
    # time. UI refresh does NOT execute actions or grant free player commands.
    if battle == null or not battle.active or view_name != "BATTLE":
        return
    battle.advance_atb(delta)
    _refresh_battle_status()
    _update_battle_command_buttons()

func _change(tab: String) -> void:
    view_name = tab
    if battle == null:
        return
    if view_name == "BATTLE":
        _show_battle()
    else:
        _show_menu()

func _clear_body() -> void:
    for n in body.get_children():
        body.remove_child(n)
        n.queue_free()

func _add_text(value: String) -> void:
    var label := Label.new()
    label.text = value
    body.add_child(label)

func _add_button(text_value: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = text_value
    button.focus_mode = Control.FOCUS_ALL
    button.pressed.connect(callback)
    body.add_child(button)

func _battle_actor_ready() -> bool:
    if battle == null or not battle.active:
        return false
    return actor_index >= 0 and actor_index < battle.party.size() and (
        battle.ready_actors().has(actor_index)) and (
        not battle.has_actor_pending_action(actor_index))

func _add_battle_command(label: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = label
    button.focus_mode = Control.FOCUS_ALL
    button.disabled = not _battle_actor_ready()
    button.pressed.connect(callback)
    body.add_child(button)
    battle_command_buttons.append(button)

func _update_battle_command_buttons() -> void:
    var enabled: bool = _battle_actor_ready()
    for button in battle_command_buttons:
        if is_instance_valid(button):
            button.disabled = not enabled

func _set_original_background(file_name: String) -> void:
    # Only load source-exact pixels after private Drive image assembly.
    # Do not claim visual parity from a missing or approximate asset.
    var path: String = "res://assets/ui/system/" + file_name
    original_background.texture = load(path) as Texture2D if ResourceLoader.exists(path) else null

func _show_menu() -> void:
    view_name = "MENU"
    _set_original_background("MenuBack_a.png")
    _clear_body()
    title_label.text = "Forest Symphony / MENU"
    status_label.text = "角色 / 技能 / 物品 / 裝備 / 狀態 / 編隊（原始 UI 影像待私有素材導入）"
    _add_button("隊伍與狀態", _show_status)
    _add_button("已習得技能", _show_skills)
    _add_button("持有道具", _show_items)
    _add_button("裝備", _show_equipment)
    _add_button("編隊", _show_formation)
    _add_button("選擇原始敵方隊伍並進入 BATTLE", _show_troop_picker)
    _add_button("Godot 地圖／事件測試場（非原始 FS 地圖）", _open_story_sandbox)

func _actor_selector(on_select: Callable) -> void:
    # Clickable actor tabs for true party ID/level; MENU never shows all 800 skills.
    var selected_actor: int = actor_index
    for i in range(battle.party.size()):
        var index: int = i
        _add_button(("%s " % ("▶" if i == selected_actor else "　")) +
            str(battle.party[i].get("name","?")),
            func() -> void:
                actor_index = index
                on_select.call())

func _show_status() -> void:
    _set_original_background("MenuBack_status_a.png")
    _clear_body()
    title_label.text = "Forest Symphony / 角色狀態"
    for row in menu_model.party():
        _add_text("%s  Lv.%d  HP %d/%d  MP %d/%d" % [
            row["name"],row["level"],row["hp"],row["maxhp"],row["mp"],row["maxmp"]])
        _add_text("ATK %d DEF %d SPI %d AGI %d HIT %d EVA %d CRI %d" % [
            row["atk"],row["def"],row["spi"],row["agi"],row["hit"],row["eva"],row["cri"]])
    _add_button("返回選單", _show_menu)

func _show_skills() -> void:
    _set_original_background("MenuBack_skill.png")
    _clear_body()
    title_label.text = "Forest Symphony / 技能"
    _actor_selector(_show_skills)
    if actor_index < 0 or actor_index >= battle.party.size():
        return
    _add_text("目前角色已習得技能（依原 Class.learnings + 等級）")
    var rows: Array[Dictionary] = menu_model.known_skills(actor_index)
    if rows.is_empty():
        _add_text("目前沒有已學會的技能")
    for row in rows:
        var cost_text: String = str(row["mp_cost"]) if bool(row["cost_verified"]) else "未核對"
        _add_text("#%d %s｜MP %s｜%s" % [
            row["id"],row["name"],cost_text,row["description"]])
    _add_text("實際治療／狀態／自訂技能效果待完整 RGSS2 規則移植")
    _add_button("返回選單", _show_menu)

func _show_items() -> void:
    _set_original_background("MenuBack_item.png")
    _clear_body()
    title_label.text = "Forest Symphony / 物品"
    _add_text("背包：來源道具 ID + 名稱 + 持有數")
    var rows: Array[Dictionary] = menu_model.inventory_rows("item")
    if rows.is_empty():
        _add_text("尚無物品")
    for row in rows:
        var item_id: int = int(row["id"])
        _add_button("%s (#%d) ×%d｜%s" % [
            row["name"],row["id"],row["count"],row["description"]],
            func() -> void: _select_item_target(item_id,false))
    _add_text("只執行已核對的單體 HP／MP 回復；其他效果拒絕且不消耗")
    _add_button("返回選單", _show_menu)

func _show_equipment() -> void:
    _set_original_background("MenuBack_equip.png")
    _clear_body()
    title_label.text = "Forest Symphony / 裝備"
    _actor_selector(_show_equipment)
    if actor_index < 0 or actor_index >= battle.party.size():
        return
    for row in menu_model.equipment_rows(actor_index):
        var slot: int = int(row["slot"])
        _add_button("%s：%s%s" % [
            row["label"],row["name"],"（鎖定）" if row["locked"] else ""],
            func() -> void: _show_equipment_candidates(slot))
    _add_button("返回選單", _show_menu)

func _show_equipment_candidates(slot: int) -> void:
    _set_original_background("MenuBack_equip.png")
    _clear_body()
    title_label.text = "Forest Symphony / 選擇裝備"
    if actor_index < 0 or actor_index >= battle.party.size():
        return
    _add_text("%s：選擇有庫存且職業允許的裝備" % [
        str(battle.party[actor_index].get("name","?"))])
    var rows: Array[Dictionary] = menu_model.available_equipment(actor_index,slot)
    if rows.is_empty():
        _add_text("此欄位不可變更")
    for row in rows:
        var item_id: int = int(row["id"])
        _add_button("%s (#%d)" % [row["name"],item_id],
            func() -> void:
                if menu_model.change_equipment(actor_index,slot,item_id):
                    _show_equipment()
                else:
                    _show_log("裝備更換已拒絕：請檢查職業、欄位與庫存"))
    _add_button("返回裝備", _show_equipment)

func _show_formation() -> void:
    _set_original_background("MenuBack_party.png")
    _clear_body()
    title_label.text = "Forest Symphony / 編隊"
    _add_text("點選兩位角色交換順序。" if formation_first < 0 else
        "請選擇與 %s 交換的角色" % str(battle.party[formation_first].get("name","?")))
    for i in range(battle.party.size()):
        var index: int = i
        _add_button("%d. %s" % [i+1,battle.party[i].get("name","?")],
            func() -> void: _formation_clicked(index))
    _add_button("返回選單", _show_menu)

func _formation_clicked(index: int) -> void:
    if formation_first < 0:
        formation_first = index
    else:
        if menu_model.switch_formation(formation_first,index):
            formation_first = -1
        else:
            _show_log("交換編隊失敗")
    _show_formation()

func _open_story_sandbox() -> void:
    if story_sandbox != null:
        return
    if battle != null and battle.active:
        _show_log("戰鬥進行中，不能切換到地圖測試場")
        return
    story_sandbox = STORY_SANDBOX.new()
    story_sandbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(story_sandbox)
    var back := Button.new()
    back.name = "ReturnToFSMenu"
    back.text = "返回 FS 選單"
    back.position = Vector2(8,56)
    back.pressed.connect(_close_story_sandbox)
    story_sandbox.add_child(back)

func _close_story_sandbox() -> void:
    if story_sandbox == null:
        return
    story_sandbox.queue_free()
    story_sandbox = null
    if battle != null:
        _show_menu()

func _show_troop_picker() -> void:
    view_name = "MENU"
    _clear_body()
    title_label.text = "Forest Symphony / 原始敵方隊伍"
    if battle == null or db == null:
        return
    if battle.active:
        _add_text("戰鬥進行中，不可替換敵方隊伍。")
        _add_button("返回戰鬥", _show_battle)
        return
    var troops: Variant = db.tables.get("troops",[])
    if not (troops is Array):
        _add_text("原始 Troops 資料表不存在，無法開始戰鬥。")
        _add_button("返回 MENU", _show_menu)
        return
    var choices: int = 0
    for troop_id in range(1,troops.size()):
        var troop: Dictionary = db.record("troops",troop_id)
        if troop.is_empty():
            continue
        var names: Array[String] = []
        for member in troop.get("members",[]):
            if not (member is Dictionary) or bool(member.get("hidden",false)):
                continue
            var enemy: Dictionary = db.record("enemies",int(member.get("enemy_id",0)))
            if not enemy.is_empty():
                names.append(str(enemy.get("name","?")))
        if names.is_empty():
            continue
        choices += 1
        var id: int = troop_id
        _add_button("#%d %s｜%s" % [id,str(troop.get("name","Troop")),", ".join(PackedStringArray(names))],
            func() -> void: _start_selected_troop(id))
    if choices == 0:
        _add_text("沒有可用的原始敵方隊伍；請確認私人資料匯入。")
    _add_button("返回 MENU", _show_menu)

func _start_selected_troop(troop_id: int) -> void:
    if battle == null or battle.active:
        return
    selected_troop_id = troop_id
    battle.enemies.clear()
    _show_battle()

func _show_battle() -> void:
    view_name = "BATTLE"
    if battle == null:
        return
    # Actual battlefield layers are selected by the original BattleScape authority.
    # Blank source-exact MENU background rather than displaying an incorrect battle map.
    original_background.texture = null
    _clear_body()
    battle_command_buttons.clear()
    title_label.text = "Forest Symphony / BATTLE (P1)"
    if battle.enemies.is_empty():
        if selected_troop_id <= 0:
            _add_text("尚未選擇原始 Troop，請先選擇敵方隊伍。")
            _add_button("選擇隊伍", _show_troop_picker)
            return
        var troop: Dictionary = db.record("troops",selected_troop_id)
        if troop.is_empty():
            _add_text("Troop #%d 不存在；拒絕建立虛構敵方隊伍。" % selected_troop_id)
            _add_button("重新選擇隊伍", _show_troop_picker)
            return
        for member in troop.get("members",[]):
            if member is Dictionary and not bool(member.get("hidden",false)):
                battle.add_enemy(int(member.get("enemy_id",0)))
        if battle.enemies.is_empty():
            _add_text("Troop #%d 沒有可用的可見敵人。" % selected_troop_id)
            _add_button("重新選擇隊伍", _show_troop_picker)
            return
    if not battle.active:
        battle.start()
    # Source #230 defaults to Wait during active command/target selection.
    battle.source_atb_wait = false
    _refresh_battle_status()
    _add_text("ATB 就緒 → 選指令 → ACT 蓄力 → 執行 → 重置（敵方 AI／特殊行動仍待移植）")
    _actor_selector(_show_battle)
    _add_text("目前操作角色：" + str(battle.party[actor_index].get("name","?")) if actor_index >= 0 and actor_index < battle.party.size() else "尚無角色")
    _add_battle_command("普通攻擊（選擇敵人）", _player_attack)
    _add_battle_command("防禦", _player_guard)
    _add_battle_command("技能", _skill_action)
    _add_battle_command("物品", _item_action)
    _add_button("返回 MENU", _show_menu)
    _update_battle_command_buttons()

func _refresh_battle_status() -> void:
    if battle == null:
        return
    var all_lines: Array[String] = []
    for actor in battle.party:
        var gauge: String = _atb_status_fragment(actor)
        all_lines.append("%s HP:%s/%s MP:%s/%s OD:%s %s" % [
            actor.get("name","?"),actor.get("hp",0),actor.get("maxhp",0),
            actor.get("mp",0),actor.get("maxmp",0),actor.get("od",0),gauge])
    for enemy in battle.enemies:
        var enemy_line: String = "%s HP:%s/%s %s" % [
            enemy.get("name","?"),enemy.get("hp",0),enemy.get("maxhp",0),
            _atb_status_fragment(enemy)]
        var planned: Array = enemy.get("fs_phase_state_intents",[])
        if not planned.is_empty():
            enemy_line += " [State意圖:%s／效果未套用]" % str(planned)
        all_lines.append(enemy_line)
    # Original #404 weather is a GLOBAL Field, never a battler State.
    # Display an actually authorized source-subset separately from Boss
    # Phase STATE intentions, which still lack original effect parity.
    var actual_weather: FSFieldWeather = battle.field_weather
    var field_request: Dictionary = battle.boss_runtime.phase_runtime.weather_request
    if actual_weather.active and actual_weather.current_id > 0:
        all_lines.append("全域天氣 Field%d / Source%d（#404 限定元素倍率已套用；原版全 Alias 尚待核對）" % [
            actual_weather.current_id,int(actual_weather.current_source.get("id",0))])
        if not field_request.is_empty() and int(
                field_request.get("field_id",0)) != actual_weather.current_id:
            all_lines.append("Boss 天氣意圖 Field%d 尚未生效" % [
                int(field_request.get("field_id",0))])
    elif not field_request.is_empty():
        all_lines.append("天氣預定 Field%d / Boss%d（未實裝傷害效果）" % [
            int(field_request.get("field_id",0)),
            int(field_request.get("source_boss_id",0))])
    status_label.text = "\n".join(PackedStringArray(all_lines))

func _atb_status_fragment(battler: Dictionary) -> String:
    if not battle.source_atb_initialized:
        return "ATB:待開始"
    var count: int = int(battler.get("source_atb_count",0))
    var pct: int = clampi(int(count / 10.0),-100,100)
    if bool(battler.get("source_act_active",false)):
        return "ACT:完成"
    if not bool(battler.get("source_atb_count_up",true)) and not bool(
            battler.get("source_at_active",false)):
        var act_pct: int = clampi(int(int(battler.get("source_act_count",0)) / 10.0),0,100)
        return "ACT:%d%%" % act_pct
    if bool(battler.get("source_at_active",false)):
        return "ATB:就緒"
    return "ATB:%d%%" % pct

func _select_enemy_target(callback: Callable,skill_id: int = 0) -> void:
    battle.source_atb_wait = true
    _clear_body()
    title_label.text = "Forest Symphony / 選擇敵方目標"
    var allowed: Dictionary = FSTargetPriority.player_enemy_candidates(
        battle,skill_id)
    if not bool(allowed.get("ok",false)):
        _add_text("無法確認原版目標優先權：" + str(allowed.get("reason","")))
    else:
        for index in allowed.get("indices",[]):
            var target: Dictionary = battle.enemies[int(index)]
            _add_button("%s HP %d/%d" % [
                target.get("name","?"),target.get("hp",0),target.get("maxhp",0)],
                func() -> void: callback.call(target))
    _add_button("返回", _show_battle)

func _select_ally_target(callback: Callable) -> void:
    battle.source_atb_wait = true
    _clear_body()
    title_label.text = "Forest Symphony / 選擇我方目標"
    for index in range(battle.party.size()):
        var target: Dictionary = battle.party[index]
        _add_button("%s HP %d/%d" % [
            target.get("name","?"),target.get("hp",0),target.get("maxhp",0)],
            func() -> void: callback.call(target))
    _add_button("返回", _show_battle)

func _player_attack() -> void:
    if not _battle_actor_ready():
        _show_log("角色 ATB 尚未就緒，或正在 ACT 蓄力")
        return
    _select_enemy_target(_do_player_attack)

func _do_player_attack(target: Dictionary) -> void:
    if battle.active and actor_index >= 0 and actor_index < battle.party.size():
        var index: int = battle.enemies.find(target)
        if not battle.queue_actor_action(actor_index,"attack",index):
            _show_log("攻擊指令被拒絕：ATB 未就緒、已有指令或目標不合法")
    _show_battle()

func _player_guard() -> void:
    if not _battle_actor_ready():
        _show_log("防禦指令遭拒：ATB 尚未就緒")
        return
    if battle.queue_actor_action(actor_index,"guard"):
        _show_battle()
    else:
        _show_log("防禦指令未建立，未變更防禦姿態")

func _skill_action() -> void:
    if battle != null and battle.active:
        battle.source_atb_wait = true
    _clear_body()
    title_label.text = "Forest Symphony / 戰鬥技能"
    if actor_index < 0 or actor_index >= battle.party.size():
        return
    _add_text("目前角色：" + str(battle.party[actor_index].get("name","?")))
    _add_text("僅列出角色從原 Class.learnings 習得的技能")
    var rows: Array[Dictionary] = menu_model.known_skills(actor_index)
    if rows.is_empty():
        _add_text("角色未習得技能")
    for row in rows:
        var sid: int = int(row["id"])
        if bool(row["cost_verified"]):
            _add_button("%s MP:%d" % [row["name"],row["mp_cost"]],
                func() -> void: _select_skill_target(sid))
        else:
            _add_text("%s MP:未核對（%s）" % [row["name"],row["cost_warning"]])
    _add_button("返回", _show_battle)

func _select_skill_target(skill_id: int) -> void:
    if not battle.active:
        _show_log("尚未進入戰鬥")
        return
    var skill: Dictionary = db.record("skills",skill_id)
    var scope: int = int(skill.get("scope",0))
    if scope == 1:
        _select_enemy_target(func(target: Dictionary) -> void: _use_skill(skill_id,target),skill_id)
    elif scope == 7:
        _select_ally_target(func(target: Dictionary) -> void: _use_skill(skill_id,target))
    else:
        _show_log("此技能需多目標、隨機目標或特殊規則，尚未完成移植，不消耗 MP")

func _use_skill(skill_id: int, target: Dictionary) -> void:
    if battle.active and actor_index >= 0 and actor_index < battle.party.size():
        var scope: int = int(db.record("skills",skill_id).get("scope",0))
        var target_index: int = battle.enemies.find(target) if scope == 1 else (
            battle.party.find(target))
        if not battle.queue_actor_action(actor_index,"skill",target_index,skill_id):
            _show_log("技能未排入 ACT：ATB 未就緒、目標或技能成本無法驗證")
    _show_battle()

func _item_action() -> void:
    if battle != null and battle.active:
        battle.source_atb_wait = true
    _clear_body()
    title_label.text = "Forest Symphony / 戰鬥物品"
    _add_text("僅可執行源碼基礎規則已驗證的單體 HP／MP 回復")
    for row in menu_model.inventory_rows("item"):
        var item_id: int = int(row["id"])
        _add_button("%s ×%d" % [row["name"],row["count"]],
            func() -> void: _select_item_target(item_id,true))
    _add_button("返回戰鬥", _show_battle)

func _select_item_target(item_id: int, in_battle: bool) -> void:
    if in_battle and not battle.active:
        _show_log("戰鬥已結束，無法使用物品")
        return
    if in_battle:
        battle.source_atb_wait = true
    _clear_body()
    title_label.text = "Forest Symphony / 物品指定目標"
    var item: Dictionary = db.record("items",item_id)
    _add_text("%s：選擇我方角色" % str(item.get("name","未知物品")))
    for i in range(battle.party.size()):
        var target: Dictionary = battle.party[i]
        if int(target.get("hp",0)) <= 0:
            continue
        _add_button("%s HP:%d/%d MP:%d/%d" % [
            target.get("name","?"),target.get("hp",0),target.get("maxhp",0),
            target.get("mp",0),target.get("maxmp",0)],
            func() -> void: _use_item_from_ui(item_id,target,in_battle))
    if in_battle:
        _add_button("取消", _item_action)
    else:
        _add_button("取消", _show_items)

func _use_item_from_ui(item_id: int, target: Dictionary, in_battle: bool) -> void:
    if actor_index < 0 or actor_index >= battle.party.size():
        _show_log("角色不在隊伍中")
        return
    var result: bool = false
    if in_battle:
        result = battle.queue_actor_action(
            actor_index,"item",battle.party.find(target),item_id)
        _show_battle()
    else:
        # MENU items work without ATB and retain immediate use.
        result = battle.use_item(target,item_id,battle.party[actor_index],false)
        _show_items()
    if not result:
        _show_log("物品指令被拒，或效果未驗證；沒有消耗背包")


func _show_log(message: String) -> void:
    log_label.text = message

func _on_battle_finished(victory: bool) -> void:
    _show_log("戰鬥結束：" + ("勝利" if victory else "失敗"))
