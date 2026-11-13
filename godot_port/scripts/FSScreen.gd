extends Control

const FS_DB = preload("res://scripts/FSDatabase.gd")
const FS_BATTLE = preload("res://scripts/FSBattle.gd")
var db: FSDatabase
var battle: FSBattle
var view_name: String = "MENU"
var body: VBoxContainer
var original_background: TextureRect
var title_label: Label
var status_label: Label
var log_label: Label
var actor_index: int = 0
var enemy_index: int = 0

func _ready() -> void:
    _build_shell()
    db = FS_DB.new()
    if not db.load_all():
        title_label.text = "Forest Symphony｜原始資料未載入"
        status_label.text = "尚未匯入 RVData 轉換後的 JSON。\n" + "\n".join(PackedStringArray(db.errors)) + "\n\n這是正式移植保護機制，不使用假角色數值。"
        return
    battle = FS_BATTLE.new(db)
    var members: Array = db.system().get("party_members", [])
    for member_id in members:
        battle.add_actor(int(member_id))
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

func _set_original_background(file_name: String) -> void:
    # Only load source-exact pixels after private Drive image assembly.
    # Do not claim visual parity from a missing or approximate asset.
    var path: String = "res://assets/ui/system/" + file_name
    original_background.texture = load(path) as Texture2D if ResourceLoader.exists(path) else null

func _show_menu() -> void:
    _set_original_background("MenuBack_a.png")
    _clear_body()
    title_label.text = "Forest Symphony / MENU"
    status_label.text = "角色 / 技能 / 物品 / 裝備 / 狀態"
    _add_button("隊伍與狀態", _show_status)
    _add_button("技能列表", _show_skills)
    _add_button("道具列表", _show_items)
    _add_button("裝備列表", _show_equipment)
    _add_button("進入 BATTLE", _show_battle)

func _show_status() -> void:
    _set_original_background("MenuBack_status_a.png")
    _clear_body()
    for actor in battle.party:
        _add_text("%s  Lv.%d  HP %d/%d  MP %d/%d" % [actor.get("name","?"), actor.get("level",0), actor.get("hp",0), actor.get("maxhp",0), actor.get("mp",0), actor.get("maxmp",0)])
        _add_text("ATK %d  DEF %d  SPI %d  AGI %d" % [actor.get("atk",0),actor.get("def",0),actor.get("spi",0),actor.get("agi",0)])
    _add_button("返回選單", _show_menu)

func _show_skills() -> void:
    _set_original_background("MenuBack_skill.png")
    _clear_body()
    _add_text("來源技能資料（完整學習、消耗、限制、被動效果尚待轉譯）")
    var items: Variant = db.tables.get("skills", [])
    if items is Array:
        var shown: int = 0
        for item in items:
            if item is Dictionary and not item.is_empty():
                _add_text("#%d %s / MP:%d" % [int(item.get("id",0)), item.get("name",""), int(item.get("mp_cost",0))])
                shown += 1
                if shown >= 30:
                    break
    _add_button("返回選單", _show_menu)

func _show_items() -> void:
    _set_original_background("MenuBack_item.png")
    _clear_body()
    _add_text("背包（道具消耗尚待原版規則核對）")
    for k in battle.inventory:
        _add_text("%s ×%d" % [k, int(battle.inventory[k])])
    _add_button("返回選單", _show_menu)

func _show_equipment() -> void:
    _set_original_background("MenuBack_equip.png")
    _clear_body()
    for actor in battle.party:
        _add_text("%s 裝備 IDs: %s" % [actor.get("name","?"), str(actor.get("equipment",[]))])
    _add_button("返回選單", _show_menu)

func _show_battle() -> void:
    if battle == null:
        return
    # Actual battlefield layers are selected by the original BattleScape authority.
    # Blank source-exact MENU background rather than displaying an incorrect battle map.
    original_background.texture = null
    _clear_body()
    title_label.text = "Forest Symphony / BATTLE (P1)"
    if battle.enemies.is_empty():
        var troop_id: int = int(db.system().get("test_troop_id", 0))
        var troop: Dictionary = db.record("troops", troop_id)
        if troop.is_empty():
            var troops: Variant = db.tables.get("troops", [])
            if troops is Array:
                for idx in range(1, troops.size()):
                    troop = db.record("troops", idx)
                    if not troop.is_empty() and not troop.get("members", []).is_empty():
                        break
        for member in troop.get("members", []):
            if member is Dictionary and not bool(member.get("hidden", false)):
                battle.add_enemy(int(member.get("enemy_id", 0)))
    if not battle.active:
        battle.start()
    _refresh_battle_status()
    _add_button("普通攻擊", _player_attack)
    _add_button("防禦", _player_guard)
    _add_button("技能", _skill_action)
    _add_button("物品", _item_action)
    _add_button("返回 MENU", _show_menu)

func _refresh_battle_status() -> void:
    if battle == null:
        return
    var all_lines: Array[String] = []
    for actor in battle.party:
        all_lines.append("%s HP:%s/%s MP:%s/%s OD:%s" % [actor.get("name","?"),actor.get("hp",0),actor.get("maxhp",0),actor.get("mp",0),actor.get("maxmp",0),actor.get("od",0)])
    for enemy in battle.enemies:
        all_lines.append("%s HP:%s/%s" % [enemy.get("name","?"),enemy.get("hp",0),enemy.get("maxhp",0)])
    status_label.text = "\n".join(PackedStringArray(all_lines))

func _player_attack() -> void:
    if battle.party.is_empty() or battle.enemies.is_empty() or not battle.active:
        return
    battle.attack(battle.party[0], battle.enemies[0])
    _refresh_battle_status()

func _player_guard() -> void:
    if battle.party.is_empty():
        return
    battle.party[0]["guarding"] = true
    _show_log("防禦姿態（P1，待原版時序核對）")

func _skill_action() -> void:
    _clear_body()
    _add_text("先選擇技能；僅基本 HP 技能公式已移植候選")
    var source: Variant = db.tables.get("skills", [])
    if source is Array:
        var shown: int = 0
        for row in source:
            if row is Dictionary and not row.is_empty() and int(row.get("base_damage",0)) != 0:
                var sid: int = int(row.get("id",0))
                _add_button("%s MP:%d" % [row.get("name","?"), int(row.get("mp_cost",0))],
                    func() -> void: _use_skill(sid))
                shown += 1
                if shown >= 10:
                    break
    _add_button("返回", _show_battle)

func _use_skill(skill_id: int) -> void:
    if battle.active and not battle.party.is_empty() and not battle.enemies.is_empty():
        battle.use_skill(battle.party[0], battle.enemies[0], skill_id)
    _show_battle()

func _item_action() -> void:
    _clear_body()
    _add_text("物品效果原始解析尚未通過，故不會錯誤消耗物品。")
    _add_button("返回", _show_battle)

func _show_log(message: String) -> void:
    log_label.text = message

func _on_battle_finished(victory: bool) -> void:
    _show_log("戰鬥結束：" + ("勝利" if victory else "失敗"))
