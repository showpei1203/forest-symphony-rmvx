extends Control

const FS_DB = preload("res://scripts/FSDatabase.gd")
const FS_BATTLE = preload("res://scripts/FSBattle.gd")
const FS_MENU = preload("res://scripts/FSMenuModel.gd")
const STORY_SANDBOX = preload("res://scripts/story/FSStorySandbox.gd")
const PLAYABLE_SLICE = preload("res://scenes/story/FSPlayableSlice.tscn")
const A35_PRIVATE_GATE = preload("res://scripts/story/FSPrivateA35Gate.gd")
const UI_ART = preload("res://scripts/ui/FSUIArtLibrary.gd")
const LIVE_HUD = preload("res://scripts/ui/FSUIBattleHUD.gd")
const ACTOR01_PRESENTATION = preload("res://scripts/ui/FSBattleActor01Presenter.gd")
const ENEMY_STAGE = preload("res://scripts/ui/FSBattleOriginalEnemyStage.gd")
const SOURCE_SCAPES=preload("res://scripts/ui/FSOriginalBattleScapeStage.gd")
const SOURCE_COMMANDS=preload("res://scripts/ui/FSOriginalBattleCommandLayer.gd")
const STATUS_269=preload("res://scripts/ui/FSBattleSourceHUD269.gd")
const STATES_381=preload("res://scripts/ui/FSBattleSourceStateHUD381.gd")
const HELP_462=preload("res://scripts/ui/FSBattleSourceTargetHelp462.gd")
const SOURCE_MENU=preload("res://scripts/ui/FSOriginalMenuOverlay.gd")
const SOURCE_PAGES=preload("res://scripts/ui/FSOriginalMenuPage.gd")
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
var playable_slice: FSPlayableSlice
var a35_preview: Control
var ui_art: FSUIArtLibrary
var ui_hud: FSUIBattleHUD
var actor01_presentation: FSBattleActor01Presenter
var enemy_stage: FSBattleOriginalEnemyStage
var original_scape: FSOriginalBattleScapeStage
var original_commands: FSOriginalBattleCommandLayer
var source_skin_hud: FSBattleSourceHUD269
var source_state_hud: FSBattleSourceStateHUD381
var source_target_help: FSBattleSourceTargetHelp462
var source_menu_overlay:FSOriginalMenuOverlay
var source_page_overlay:FSOriginalMenuPage
var tab_bar:HBoxContainer
var developer_scroll:ScrollContainer
var battle_command_art:Dictionary={}
var battle_command_grid:GridContainer

func _ready() -> void:
    # Full-window Godot Control: without this the 45-degree actor and
    # original Battlers are rendered offscreen at a zero-width origin.
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    ui_art=UI_ART.new()
    _install_system_cjk_font()
    _build_shell()
    # Explicit synthetic/native QA fixture injection, never a fallback
    # for the actual FS boot-final DB authority. Ordinary gameplay still
    # requires db.load_all() and the private original VX witness below.
    if db != null and battle != null:
        menu_model = FS_MENU.new(db,battle)
        battle.changed.connect(_show_log)
        battle.finished.connect(_on_battle_finished)
        _show_battle()
        # Native real ACT screenshots must not claim "source awaiting
        # validation" as a broken app while synthetic QA is explicitly
        # running. Never mistake the fixture for complete FS DB parity.
        if not db.boot_final_verified:
            log_label.text="合成 QA 戰鬥：已接通原 VX 事件與 Godot ATB／ACT；不是原版 FS 正式數值或美術"
        return
    db = FS_DB.new()
    if not db.load_all():
        _add_button("遊玩 Godot 地圖→事件→ACT戰鬥→劇情切片（合成資料）", _open_playable_slice)
        _add_button("開啟 Godot 地圖／事件測試場（非原始 FS 地圖）", _open_story_sandbox)
        _offer_a35_private_preview()
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

func _install_system_cjk_font() -> void:
    # Godot's embedded default Latin font cannot render Chinese; the
    # native OpenGL QA screenshot exposed literal missing-glyph boxes.
    # Use installed OS Chinese fonts without bundling proprietary fonts.
    # The game still needs an approved packaged CJK font before release.
    var face := SystemFont.new()
    face.font_names = PackedStringArray([
        "Microsoft JhengHei","Noto Sans CJK TC",
        "PingFang TC","WenQuanYi Micro Hei"])
    var global_theme := Theme.new()
    global_theme.default_font = face
    global_theme.default_font_size = 12
    theme = global_theme

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
    # Original #264 BattleScape sits below HUD/ACT/actor/enemy planes.
    original_scape=SOURCE_SCAPES.new()
    original_scape.name="FSOriginalBattleScape264"
    add_child(original_scape)
    var layout := VBoxContainer.new()
    layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    layout.add_theme_constant_override("separation", 4)
    add_child(layout)
    title_label = Label.new()
    title_label.text = "Forest Symphony / Godot P1 Candidate"
    title_label.add_theme_font_size_override("font_size", 15)
    layout.add_child(title_label)
    var tabs := HBoxContainer.new()
    tab_bar=tabs
    layout.add_child(tabs)
    for tab in ["MENU", "BATTLE"]:
        var button := Button.new()
        button.text = tab
        button.pressed.connect(func() -> void: _change(tab))
        tabs.add_child(button)
    ui_hud=LIVE_HUD.new()
    ui_hud.name="FSOriginalArtBattleHUD"
    ui_hud.set_art(ui_art)
    ui_hud.visible=false
    layout.add_child(ui_hud)
    status_label = Label.new()
    # Real native OpenGL QA exposed horizontal clipping of Ivy charge
    # details at 544x416 original VX aspect. Never force users to read
    # an overflowing single line in the new Godot battle HUD.
    status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    layout.add_child(status_label)
    var scroll := ScrollContainer.new()
    developer_scroll=scroll
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    layout.add_child(scroll)
    body = VBoxContainer.new()
    body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 3)
    scroll.add_child(body)
    log_label = Label.new()
    log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    log_label.text = "狀態：來源資料等待驗證"
    layout.add_child(log_label)
    # Overlay only: never reduce legacy 544x416 2x2 command area.
    actor01_presentation=ACTOR01_PRESENTATION.new()
    add_child(actor01_presentation)
    enemy_stage=ENEMY_STAGE.new()
    enemy_stage.name="FSBattleStageOriginalEnemies"
    add_child(enemy_stage)
    source_skin_hud=STATUS_269.new()
    source_skin_hud.name="FSOriginal269BattleStatusSkin"
    add_child(source_skin_hud)
    # 381 is the real actor/enemy overlay; #462 help window disables its
    # own duplicated state icons by default.
    source_state_hud=STATES_381.new()
    add_child(source_state_hud)
    original_commands=SOURCE_COMMANDS.new()
    original_commands.name="FSOriginalBattleCommandOverlay232_268_312"
    original_commands.command_requested.connect(_source_battle_command)
    add_child(original_commands)
    source_menu_overlay=SOURCE_MENU.new()
    source_menu_overlay.name="FSOriginalMenu202"
    source_menu_overlay.visible=false
    source_menu_overlay.command_requested.connect(_source_menu_command)
    add_child(source_menu_overlay)
    source_page_overlay=SOURCE_PAGES.new()
    source_page_overlay.name="FSOriginalMenuPageP538B"
    source_page_overlay.visible=false
    source_page_overlay.return_requested.connect(_source_page_return)
    source_page_overlay.actor_requested.connect(_source_page_actor)
    source_page_overlay.item_requested.connect(_source_page_item)
    source_page_overlay.item_target_requested.connect(_source_page_item_target)
    source_page_overlay.slot_requested.connect(_show_equipment_candidates)
    source_page_overlay.equipment_selected.connect(_source_page_equipment_selected)
    source_page_overlay.formation_requested.connect(_formation_clicked)
    add_child(source_page_overlay)
    resized.connect(_layout_source_menu)
    _layout_source_menu()

func _process(delta: float) -> void:
    # The actual source Tankentai source-frame gauge now ticks in real gameplay
    # time. UI refresh does NOT execute actions or grant free player commands.
    if battle == null or not battle.active or view_name != "BATTLE":
        return
    battle.advance_atb(delta)
    _refresh_battle_status()
    if ui_hud!=null and ui_hud.visible:
        ui_hud.refresh(battle.party)
    if source_skin_hud!=null and source_skin_hud.visible:
        source_skin_hud.refresh(battle.party)
    if actor01_presentation!=null:
        actor01_presentation.sync_from_battle(battle)
    if enemy_stage!=null:
        enemy_stage.refresh(battle.enemies)
    _refresh_source_state_hud()
    if source_target_help!=null and is_instance_valid(
            source_target_help) and source_target_help.visible and (
            Engine.get_process_frames()%12==0):
        source_target_help.refresh_live()
    _update_battle_command_buttons()

# R8: Explicit private synthetic preview. Normal boot uses original enemy stage.
# Install only after the candidate proves it can bind. Never select by a real DB ID.
func configure_shj_fixture_candidate(frames: SpriteFrames) -> bool:
    if frames==null or db==null or db.boot_final_verified or battle==null or not battle.active or view_name!="BATTLE" or enemy_stage==null:
        return false
    if not battle.has_signal(&"target_outcome_resolved"):
        return false
    for clip in [&"idle",&"walk",&"attack"]:
        if not frames.has_animation(clip) or frames.get_frame_count(clip)<1:
            return false
    if frames.get_animation_loop(&"attack"):
        return false
    var candidate_script=load("res://scripts/ui/FSShjSharedFixtureEnemyStage.gd")
    if candidate_script==null:
        return false
    if enemy_stage.get_script()==candidate_script:
        return enemy_stage.approved_frames==frames and enemy_stage.fixture_battle==battle
    var previous:FSBattleOriginalEnemyStage=enemy_stage
    var candidate:FSBattleOriginalEnemyStage=candidate_script.new()
    add_child(candidate)
    if not candidate.configure_fixture(frames,battle):
        remove_child(candidate)
        candidate.queue_free()
        return false
    var index:int=previous.get_index()
    previous.name="RetiredPrivateFixtureStage"
    remove_child(previous)
    previous.queue_free()
    candidate.name="FSBattleStageOriginalEnemies"
    move_child(candidate,index)
    enemy_stage=candidate
    _refresh_source_state_hud()
    return true

func _refresh_source_state_hud()->void:
    if source_state_hud==null or not source_state_hud.source_enabled or (
            battle==null):
        return
    var actors:Dictionary={}
    # Only the genuine source actor01 rig has a physical Sprite2D anchor.
    # Do not invent anchors for other actors whose animations are ART HOLD.
    if actor01_presentation!=null and actor01_presentation.visible and (
            actor01_presentation.rig!=null):
        for index in range(battle.party.size()):
            if int(battle.party[index].get("id",0))==1:
                actors[index]=actor01_presentation.rig.global_position
    var enemies:Dictionary={}
    if enemy_stage!=null:
        for row in enemy_stage.enemy_views:
            var i:int=int(row.get("index",-1))
            var control:Control=row.get("image")
            if i>=0 and control!=null and control.visible:
                # Original #381 battler_y means the CHARACTER FEET position.
                # Using the displayed TextureRect centre covered monster faces.
                enemies[i]=FSBattleSourceStateHUD381.enemy_anchor_from_rect(
                    control.get_global_rect())
    source_state_hud.refresh(battle.party,battle.enemies,actors,enemies)

func _change(tab: String) -> void:
    view_name = tab
    if battle == null:
        return
    if view_name == "BATTLE":
        _show_battle()
    else:
        _show_menu()

func _clear_body() -> void:
    # Source-compatible battle UI hides only the temporary debug chrome.
    # Any real target/skill/item submenu restores usable Godot controls.
    _restore_developer_shell()
    if source_menu_overlay!=null:
        source_menu_overlay.visible=false
    if source_page_overlay!=null:
        source_page_overlay.visible=false
    if status_label!=null and view_name!="BATTLE":
        status_label.visible=true
    if original_commands!=null:
        original_commands.visible=false
    # Source target help is a transient WINDOW, not a permanent enemy label.
    source_target_help=null
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
    # Only semantic ID-linked icons; unknown source atlas indices stay blank.
    # This is a private, SHA-gated original VX IconSet (24px atlas).
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
    # Direct source image inspection: 01 Attack, 02 Skill, 03 Defend,
    # 04 Item, 05 Escape. Escape is art only until source battle rule exists.
    var source_id:String=""
    match label:
        "普通攻擊（選擇敵人）":source_id="01"
        "技能":source_id="02"
        "防禦":source_id="03"
        "物品":source_id="04"
    if not source_id.is_empty() and ui_art!=null:
        var stem:String="Battle"+source_id
        var active:Texture2D=ui_art.texture("menu",stem+".png")
        var inactive:Texture2D=ui_art.texture("menu",stem+"a.png")
        if active!=null and inactive!=null and (
                Vector2i(active.get_size())==Vector2i(54,48)) and (
                Vector2i(inactive.get_size())==Vector2i(54,48)):
            battle_command_art[button.get_instance_id()]={
                "active":active,"inactive":inactive}
            button.icon=inactive if button.disabled else active
            button.expand_icon=false
            button.icon_alignment=HORIZONTAL_ALIGNMENT_LEFT
    button.pressed.connect(callback)
    button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    button.custom_minimum_size=Vector2(0,48)
    if battle_command_grid!=null and is_instance_valid(battle_command_grid):
        battle_command_grid.add_child(button)
    else:
        body.add_child(button)
    battle_command_buttons.append(button)

func _update_battle_command_buttons() -> void:
    var enabled: bool = _battle_actor_ready()
    var seal_flags:Array=[true,true,true,true]
    if battle!=null and db!=null and actor_index>=0 and (
            actor_index<battle.party.size()):
        # Original #312 reads RPG::State.note every frame, not cached booleans.
        var quote:Dictionary=FSOriginalActionSeal.flags(
            battle.party[actor_index],db)
        seal_flags=quote.get("blocked",[true,true,true,true])
    if original_commands!=null and original_commands.source_enabled:
        original_commands.refresh_state(enabled,seal_flags)
    # The fallback 2x2 Godot UI must follow the SAME source authority.
    var fallback_order:Array=[0,2,1,3] # Attack/Guard/Skill/Item
    for i in range(battle_command_buttons.size()):
        var button:Button=battle_command_buttons[i]
        if is_instance_valid(button):
            button.disabled = not enabled or (
                bool(seal_flags[fallback_order[i]]))
            var key:int=button.get_instance_id()
            if battle_command_art.has(key):
                var pair:Dictionary=battle_command_art[key]
                button.icon=pair["inactive"] if button.disabled else pair["active"]

func _layout_source_menu()->void:
    if source_menu_overlay==null:
        return
    # Original VX image is source-native 544x416, including at 1088x832.
    # Its real pixels stay at 1:1, aligned to centred original background.
    var offset:Vector2=(size-Vector2(544,416))*0.5
    source_menu_overlay.position=Vector2(maxf(0.0,offset.x),
        maxf(0.0,offset.y))
    source_menu_overlay.size=Vector2(544,416)
    if source_page_overlay!=null:
        source_page_overlay.position=source_menu_overlay.position
        source_page_overlay.size=Vector2(544,416)

func _source_menu_command(which:int)->void:
    # Original UI art order verified from all eight source Menu PNGs.
    # Quest/Save/System have no authoritative migrated runtime and never run.
    match which:
        0:_show_items()
        1:_show_status()
        2:_show_skills()
        3:_show_equipment()
        4:_show_formation()
        _:_show_log("原始 FS 任務／儲存／系統尚未通過來源相容驗證")

func _source_page_tabs(category:String)->void:
    # Original tabs are 60x20. Only the verified first functional tab is
    # active; additional source art is visible but never lies about a menu.
    var source_tabs:Dictionary={
        "status":["Status01.png","Status02.png"],
        "skills":["Skill01.png","Skill02.png","Skill03.png"],
        "items":["Item01.png","Item02.png","Item03.png"],
        "equipment":["Equip01.png","Equip02.png"]}
    if ui_art==null or not source_tabs.has(category):
        return
    var pictures:Array[Texture2D]=[]
    for file_name in source_tabs[category]:
        var image:Texture2D=ui_art.texture("menu",file_name)
        if image==null or Vector2i(image.get_size())!=Vector2i(60,20):
            return
        pictures.append(image)
    var strip:=HBoxContainer.new()
    strip.name="FSOriginal_"+category+"_tabs"
    strip.add_theme_constant_override("separation",8)
    body.add_child(strip)
    for i in range(pictures.size()):
        var panel:=TextureRect.new()
        panel.name="OriginalSourceTab_"+str(i)
        panel.texture=pictures[i]
        panel.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        panel.custom_minimum_size=Vector2(60,20)
        panel.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
        panel.stretch_mode=TextureRect.STRETCH_KEEP_CENTERED
        panel.modulate=Color.WHITE if i==0 else Color(0.5,0.5,0.5,0.7)
        panel.tooltip_text="已完成" if i==0 else "原版來源圖已保存，功能待移植"
        strip.add_child(panel)

func _restore_developer_shell()->void:
    if title_label!=null:
        title_label.visible=true
    if tab_bar!=null:
        tab_bar.visible=true
    if developer_scroll!=null:
        developer_scroll.visible=true
    if log_label!=null:
        log_label.visible=true

func _hide_developer_shell_for_original_battle()->void:
    # Original #232/#268 has Sprite commands, NOT Godot test tabs,
    # 'Return MENU' or a giant text selector across the battle arena.
    if title_label!=null:
        title_label.visible=false
    if tab_bar!=null:
        tab_bar.visible=false
    if developer_scroll!=null:
        developer_scroll.visible=false
    if log_label!=null:
        log_label.visible=false

func _present_source_page(category:String,subject_id:int=-1)->void:
    # UI only: FSMenuModel continues to own all data/mutations. Missing or
    # tampered original artwork leaves the existing functional fallback.
    if source_page_overlay==null or ui_art==null or menu_model==null:
        return
    if not source_page_overlay.configure(ui_art,menu_model,category,
            actor_index,formation_first,subject_id):
        return
    _set_original_background(str(
        FSOriginalMenuPage.PAGE_BACKGROUNDS[category]))
    _hide_developer_shell_for_original_battle()
    if status_label!=null:
        status_label.visible=false
    source_page_overlay.visible=true
    _layout_source_menu()

func _source_page_return()->void:
    if source_page_overlay!=null:
        match source_page_overlay.page_kind:
            "equipment_candidates":
                _show_equipment()
                return
            "item_targets":
                _show_items()
                return
    _show_menu()

func _source_page_actor(index:int)->void:
    if battle==null or index<0 or index>=battle.party.size():
        return
    actor_index=index
    match source_page_overlay.page_kind:
        "status":_show_status()
        "skills":_show_skills()
        "equipment":_show_equipment()
        "equipment_candidates":_show_equipment()
        _:_show_menu()

func _source_page_item(item_id:int)->void:
    if db==null or db.record("items",item_id).is_empty():
        return
    _present_source_page("item_targets",item_id)

func _source_page_item_target(item_id:int,index:int)->void:
    if battle==null or index<0 or index>=battle.party.size():
        return
    _use_item_from_ui(item_id,battle.party[index],false)

func _source_page_equipment_selected(slot:int,item_id:int)->void:
    if menu_model!=null and menu_model.change_equipment(
            actor_index,slot,item_id):
        _show_equipment()
    else:
        # Rebuild candidate page FIRST, otherwise configure() deletes
        # the old source-page feedback label and silences the refusal.
        _show_equipment_candidates(slot)
        _show_log("裝備更換遭來源合法性/背包檢查拒絕")

func _source_battle_command(index:int)->void:
    if not _battle_actor_ready():
        return
    # Revalidate the source State at dispatch, not only in hover/refresh.
    if index>=0 and index<4 and (db==null or not (
            FSOriginalActionSeal.can_use(
                battle.party[actor_index],db,
                FSOriginalActionSeal.KINDS[index]))):
        return
    # Source #268 order, wrapped by #312 command seal. Escape remains HOLD.
    match index:
        0:_player_attack()
        1:_skill_action()
        2:_player_guard()
        3:_item_action()
        4:_show_log("原版逃跑尚未完成 VX Event301 相容與來源驗證")

func _set_original_background(file_name: String) -> void:
    # Only load source-exact pixels after private Drive image assembly.
    # Do not claim visual parity from a missing or approximate asset.
    var path: String = "res://assets/ui/system/" + file_name
    original_background.texture = ui_art.texture("system",file_name) if ui_art!=null else null

func _show_menu() -> void:
    view_name = "MENU"
    status_label.visible=true
    if original_scape!=null:
        original_scape.clear_scape()
    if original_commands!=null:
        original_commands.visible=false
    if source_skin_hud!=null:
        source_skin_hud.clear_source()
    if source_state_hud!=null:
        source_state_hud.clear_source()
    if enemy_stage!=null:
        enemy_stage.clear_enemies()
    if actor01_presentation!=null:
        actor01_presentation.cancel_visual()
    if ui_hud!=null:
        ui_hud.visible=false
    _set_original_background("MenuBack_a.png")
    _clear_body()
    title_label.text = "Forest Symphony / MENU"
    if source_menu_overlay!=null and menu_model!=null and (
            source_menu_overlay.configure(ui_art,menu_model.party(),
                db!=null and db.boot_final_verified)):
        _set_original_background("MenuBack_b.png")
        source_menu_overlay.visible=true
        _layout_source_menu()
        title_label.visible=false
        tab_bar.visible=false
        status_label.visible=false
        developer_scroll.visible=false
        log_label.visible=false
        return
    status_label.text = "角色 / 技能 / 物品 / 裝備 / 狀態 / 編隊（原始 UI 尚未通過來源驗證）"
    _add_button("隊伍與狀態", _show_status)
    _add_button("已習得技能", _show_skills)
    _add_button("持有道具", _show_items)
    _add_button("裝備", _show_equipment)
    _add_button("編隊", _show_formation)
    _add_button("選擇原始敵方隊伍並進入 BATTLE", _show_troop_picker)
    _add_button("Godot 地圖→事件→戰鬥→存讀 可玩切片（合成資料）", _open_playable_slice)
    _add_button("Godot 地圖／事件測試場（非原始 FS 地圖）", _open_story_sandbox)
    _offer_a35_private_preview()


func _icon_last_button(table_name:String,record_id:int)->void:
    # The actual original database icon_index, never guessed from menu order.
    if ui_art==null or db==null:
        return
    var record:Dictionary=db.record(table_name,record_id)
    if not record.has("icon_index"):
        return
    var graphic:Texture2D=ui_art.icon(int(record["icon_index"]))
    if graphic==null:
        return
    if body.get_child_count()>0 and body.get_child(
            body.get_child_count()-1) is Button:
        var button:Button=body.get_child(body.get_child_count()-1)
        button.icon=graphic
        button.expand_icon=false

func _show_actor_portrait(index:int)->void:
    if ui_art==null or battle==null or index<0 or index>=battle.party.size():
        return
    var actor_name:String=str(battle.party[index].get("name",""))
    # Explicit mapping from the original six FS portrait filenames.
    # Do not match random demo actors or forge a portrait in their place.
    var allowed:Dictionary={
        "喬伊":"menu_喬伊.png", "泰勒":"menu_泰勒.png",
        "米亞":"menu_米亞.png", "艾卓":"menu_艾卓.png",
        "艾薇":"menu_艾薇.png", "薇娜":"menu_薇娜.png"}
    if not allowed.has(actor_name):
        return
    var portrait:Texture2D=ui_art.texture("menu",str(allowed[actor_name]))
    if portrait==null:
        return
    var frame:=TextureRect.new()
    frame.name="FSOriginalPortrait_"+str(index)
    frame.texture=portrait
    frame.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    frame.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    frame.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    frame.custom_minimum_size=Vector2(126,156)
    frame.size_flags_horizontal=Control.SIZE_SHRINK_BEGIN
    body.add_child(frame)

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
    if ui_hud!=null:
        ui_hud.visible=false
    _set_original_background("MenuBack_status_a.png")
    _clear_body()
    title_label.text = "Forest Symphony / 角色狀態"
    _source_page_tabs("status")
    status_label.text="角色資料以當前 FSDatabase／FSBattle 為準，原圖另依來源 SHA 驗證"
    _actor_selector(_show_status)
    if battle==null or menu_model==null or (
            actor_index<0 or actor_index>=battle.party.size()):
        _add_button("返回選單",_show_menu)
        return
    var row_holder:=HBoxContainer.new()
    row_holder.add_theme_constant_override("separation",10)
    body.add_child(row_holder)
    var image_name:String=str(battle.party[actor_index].get("name",""))
    var portraits:Dictionary={
        "喬伊":"menu_喬伊.png","泰勒":"menu_泰勒.png","米亞":"menu_米亞.png",
        "艾卓":"menu_艾卓.png","艾薇":"menu_艾薇.png","薇娜":"menu_薇娜.png"}
    if ui_art!=null and portraits.has(image_name):
        var image:Texture2D=ui_art.texture("menu",str(portraits[image_name]))
        if image!=null:
            var portrait:=TextureRect.new()
            portrait.name="FSOriginalPortrait_"+str(actor_index)
            portrait.texture=image
            portrait.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
            portrait.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
            portrait.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
            portrait.custom_minimum_size=Vector2(112,140)
            row_holder.add_child(portrait)
    var text_column:=VBoxContainer.new()
    text_column.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    row_holder.add_child(text_column)
    var source_rows:Array=menu_model.party()
    if actor_index<source_rows.size():
        var stats:Dictionary=source_rows[actor_index]
        for text_line in [
            "%s  Lv.%d" % [stats.get("name","?"),stats.get("level",0)],
            "HP %d/%d  MP %d/%d" % [stats.get("hp",0),stats.get("maxhp",0),
                stats.get("mp",0),stats.get("maxmp",0)],
            "ATK %d  DEF %d  SPI %d" % [stats.get("atk",0),
                stats.get("def",0),stats.get("spi",0)],
            "AGI %d  HIT %d  EVA %d  CRI %d" % [
                stats.get("agi",0),stats.get("hit",0),
                stats.get("eva",0),stats.get("cri",0)]]:
            var caption:=Label.new()
            caption.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
            caption.text=text_line
            text_column.add_child(caption)
    _add_button("返回選單", _show_menu)
    _present_source_page("status")

func _show_skills() -> void:
    if ui_hud!=null:
        ui_hud.visible=false
    _set_original_background("MenuBack_skill.png")
    _clear_body()
    title_label.text = "Forest Symphony / 技能"
    _source_page_tabs("skills")
    _actor_selector(_show_skills)
    if actor_index < 0 or actor_index >= battle.party.size():
        return
    _show_actor_portrait(actor_index)
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
    _present_source_page("skills")

func _show_items() -> void:
    if ui_hud!=null:
        ui_hud.visible=false
    _set_original_background("MenuBack_item.png")
    _clear_body()
    title_label.text = "Forest Symphony / 物品"
    _source_page_tabs("items")
    _add_text("背包：來源道具 ID + 名稱 + 持有數")
    var rows: Array[Dictionary] = menu_model.inventory_rows("item")
    if rows.is_empty():
        _add_text("尚無物品")
    for row in rows:
        var item_id: int = int(row["id"])
        _add_button("%s (#%d) ×%d｜%s" % [
            row["name"],row["id"],row["count"],row["description"]],
            func() -> void: _select_item_target(item_id,false))
        _icon_last_button("items",item_id)
    _add_text("只執行已核對的單體 HP／MP 回復；其他效果拒絕且不消耗")
    _add_button("返回選單", _show_menu)
    _present_source_page("items")

func _show_equipment() -> void:
    if ui_hud!=null:
        ui_hud.visible=false
    _set_original_background("MenuBack_equip.png")
    _clear_body()
    title_label.text = "Forest Symphony / 裝備"
    _source_page_tabs("equipment")
    _actor_selector(_show_equipment)
    if actor_index < 0 or actor_index >= battle.party.size():
        return
    _show_actor_portrait(actor_index)
    for row in menu_model.equipment_rows(actor_index):
        var slot: int = int(row["slot"])
        _add_button("%s：%s%s" % [
            row["label"],row["name"],"（鎖定）" if row["locked"] else ""],
            func() -> void: _show_equipment_candidates(slot))
    _add_button("返回選單", _show_menu)
    _present_source_page("equipment")

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
    _present_source_page("equipment_candidates",slot)

func _show_formation() -> void:
    if ui_hud!=null:
        ui_hud.visible=false
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
    _present_source_page("formation")

func _formation_clicked(index: int) -> void:
    if formation_first < 0:
        formation_first = index
    else:
        if menu_model.switch_formation(formation_first,index):
            formation_first = -1
        else:
            _show_log("交換編隊失敗")
    _show_formation()


func _offer_a35_private_preview() -> void:
    # Only visible when original owner-only scene can actually load.
    # No synthetic fallback and no claimed FS Story/ACT integration.
    var gate:Dictionary=A35_PRIVATE_GATE.inspect()
    if bool(gate.get("ok",false)):
        _add_button("A35 苔光村真實森林預覽（ART HOLD，尚未接事件）",
            _open_a35_private_preview)

func _open_a35_private_preview() -> void:
    if a35_preview!=null or playable_slice!=null or story_sandbox!=null:
        return
    if battle!=null and battle.active:
        _show_log("戰鬥進行中不可切換地圖")
        return
    var gate:Dictionary=A35_PRIVATE_GATE.inspect()
    if not bool(gate.get("ok",false)):
        _show_log(str(gate.get("reason","私人森林地圖拒絕載入")))
        return
    a35_preview=Control.new()
    a35_preview.name="PrivateA35VillagePreview_ART_HOLD"
    a35_preview.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(a35_preview)
    var container:=SubViewportContainer.new()
    container.name="A35NativeViewportContainer"
    container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    container.stretch=true
    a35_preview.add_child(container)
    var view:=SubViewport.new()
    view.name="A35NativeViewport"
    view.size=Vector2i(1280,928)
    view.render_target_update_mode=SubViewport.UPDATE_ALWAYS
    container.add_child(view)
    var packed:PackedScene=gate["scene"]
    view.add_child(packed.instantiate())
    var back:=Button.new()
    back.name="ReturnFromA35Preview"
    back.text="返回 FS｜A35 真素材預覽，非正式劇情移植"
    back.position=Vector2(8,8)
    back.pressed.connect(_close_a35_private_preview)
    a35_preview.add_child(back)

func _close_a35_private_preview() -> void:
    if a35_preview==null:
        return
    a35_preview.queue_free()
    a35_preview=null
    if battle!=null:
        _show_menu()

func _open_playable_slice() -> void:
    if playable_slice != null:
        return
    if battle != null and battle.active:
        _show_log("已進入原始戰鬥，不允許覆蓋其他戰鬥進度")
        return
    playable_slice=PLAYABLE_SLICE.instantiate()
    playable_slice.name="LivePlayableSlice"
    playable_slice.set_anchors_and_offsets_preset(
        Control.PRESET_FULL_RECT)
    playable_slice.exit_requested.connect(_close_playable_slice)
    add_child(playable_slice)

func _close_playable_slice() -> void:
    if playable_slice==null:
        return
    if playable_slice.story.runner.active or (
            playable_slice.battle_overlay!=null):
        return
    playable_slice.queue_free()
    playable_slice=null
    if battle!=null and db!=null:
        _show_menu()

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
    # The original gauges already show live HP/MP/ATB. The long debug
    # report is retained in status_label.text, but must not displace
    # the original 2x2 ACT buttons beneath the 544x416 viewport.
    status_label.visible=false
    if battle == null:
        return
    # Actual battlefield layers are selected by the original BattleScape authority.
    # Blank source-exact MENU background rather than displaying an incorrect battle map.
    original_background.texture = null
    if original_scape!=null:
        # True #264: troop mapping wins before variable 1000, area and map.
        # The source ZIP is private; no fabricated BattleScape backdrop.
        original_scape.bind_source(world,selected_troop_id)
    _clear_body()
    battle_command_grid=null
    battle_command_buttons.clear()
    battle_command_art.clear()
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
    if enemy_stage!=null:
        enemy_stage.bind_real(battle)
    # Source #230 defaults to Wait during active command/target selection.
    battle.source_atb_wait = false
    if ui_hud!=null:
        ui_hud.visible=true
        ui_hud.bind_party(battle.party)
    if source_state_hud!=null:
        source_state_hud.install(ui_art,db)
        _refresh_source_state_hud()
    if source_skin_hud!=null and source_skin_hud.install(ui_art,battle.party):
        # #269 exact source bottom-status coordinates and source sprites
        # replace candidate top Godot HFlow, never render both at once.
        if ui_hud!=null:
            ui_hud.visible=false
    _refresh_battle_status()
    # No developer banner across original enemy source portrait.
    _actor_selector(_show_battle)
    _add_text("目前操作角色：" + str(battle.party[actor_index].get("name","?")) if actor_index >= 0 and actor_index < battle.party.size() else "尚無角色")
    # 2x2 original 54x48 source PNG buttons, preserving four true Godot ACT commands.
    battle_command_grid=GridContainer.new()
    battle_command_grid.name="FSOriginalBattleCommands"
    battle_command_grid.columns=2
    battle_command_grid.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    battle_command_grid.add_theme_constant_override("h_separation",4)
    battle_command_grid.add_theme_constant_override("v_separation",3)
    body.add_child(battle_command_grid)
    _add_battle_command("普通攻擊（選擇敵人）", _player_attack)
    _add_battle_command("防禦", _player_guard)
    _add_battle_command("技能", _skill_action)
    _add_battle_command("物品", _item_action)
    _add_button("返回 MENU", _show_menu)
    if original_commands!=null and original_commands.bind_original(ui_art):
        # Source owns FIVE staggered, vertical Battle01..05 sprites.
        # Hide the candidate 2x2 input and development-only text overlays.
        battle_command_grid.visible=false
        _hide_developer_shell_for_original_battle()
    _update_battle_command_buttons()

func _refresh_battle_status() -> void:
    if battle == null:
        return
    var all_lines: Array[String] = []
    # Name only the subset that is actually enabled. Source 505-alias
    # parity is not automatically implied by a green synthetic CI.
    if battle.normal_core.active:
        all_lines.append("普攻：FS舊核心→平滑防禦（來源限定）")
    if battle.skill_core.active:
        all_lines.append("技能：YEM RD→平滑防禦（來源限定）")
    if battle.element_rates.active:
        all_lines.append("元素：FS Phase28 十八屬性＋雙屬性倍率（來源限定）")
    if battle.ivy_cover.active:
        all_lines.append("護衛：Ivy Actor05 / 主動、映體與致死保命（來源限定；未完成全505覆寫）")
    for actor in battle.party:
        var gauge: String = _atb_status_fragment(actor)
        all_lines.append("%s HP:%s/%s MP:%s/%s OD:%s %s" % [
            actor.get("name","?"),actor.get("hp",0),actor.get("maxhp",0),
            actor.get("mp",0),actor.get("maxmp",0),actor.get("od",0),gauge])
        if battle.accuracy.active and all_lines.size()>0:
            all_lines[all_lines.size()-1] += _combat_result_text(actor)
        if battle.ivy_cover.active and int(actor.get("id",0))==5:
            # A separate native status row fits both original 4:3 game
            # layout and TV 16:9 layout, without hiding OD/HP numbers.
            all_lines.append("  艾薇護衛：%d 次｜持續 %d 行動｜減傷 %d%%" % [
                int(actor.get("fs_ivy_guard_charges",0)),
                int(actor.get("fs_ivy_guard_actions_left",0)),
                int(actor.get("fs_ivy_guard_reduce",0))])
            if bool(actor.get("fs_ivy_fatal_used",false)):
                all_lines.append("  替身承擔：本場致死保命已使用（技能146）")
        if battle.ivy_furnace.active and int(
                actor.get("id",0))==5 and bool(actor.get("actor",false)):
            if bool(actor.get("fs_ivy_furnace_state_authority_pending",false)):
                all_lines.append("  痛苦熔爐：狀態期限來源不完整（停止自動結算）")
            elif 85 in actor.get("states",[]):
                var turns:Dictionary=actor.get(
                    "fs_ivy_furnace_state_turns",{})
                all_lines.append("  痛苦熔爐：State85｜倒數 %d｜State100：來源限定" % int(
                    turns.get("85",-1)))
            elif 100 in actor.get("states",[]):
                all_lines.append("  痛苦熔爐：State85 已解除｜State100 仍在（來源限定）")
        if battle.ivy_od_defense.active and int(
                actor.get("id",0))==5 and bool(actor.get("actor",false)):
            # Pure read-only ComboCore quote for the actual OD gauge,
            # not synthetic HUD math or a claimed full 505 alias port.
            var defense:Dictionary=battle.ivy_od_defense.quote(
                battle,actor,100)
            if bool(defense.get("ok",false)) and bool(
                    defense.get("applicable",false)):
                all_lines.append("  怒意不熄：OD %.1f%%｜傷害減免 %.2f%%（來源限定）" % [
                    float(defense["od_rate"]),
                    float(defense["reduction"])])
            elif not bool(defense.get("ok",false)):
                all_lines.append("  怒意不熄：來源不完整／未套用減傷")
        if (battle.ivy_pain.active or battle.ivy_revenge.active) and int(
                actor.get("id",0))==5:
            all_lines.append("  蓄痛：%d（原版實際 HP 損失／來源限定）" % int(
                actor.get("fs_ivy_stored_pain",0)))
            if battle.ivy_revenge.active and not battle.ivy_revenge.events.is_empty():
                var last_revenge: Dictionary=battle.ivy_revenge.events[-1]
                if bool(last_revenge.get("success",false)):
                    all_lines.append("  復仇重擊：快照 %d／追加傷害 %d／已消耗 %d" % [
                        int(last_revenge.get("snapshot",0)),
                        int(last_revenge.get("extra",0)),
                        int(last_revenge.get("consumed",0))])
                else:
                    all_lines.append("  復仇重擊：未命中／蓄痛未消耗")
        if battle.ivy_cover.active and str(
                actor.get("fs_clone_role",""))=="ivy":
            all_lines.append("  映體護衛：%s" % (
                "本次已用／自己行動後重置" if bool(
                actor.get("fs_ivy_clone_guard_used",false)) else "可以緊急護衛"))
    for enemy in battle.enemies:
        var enemy_line: String = "%s HP:%s/%s %s" % [
            enemy.get("name","?"),enemy.get("hp",0),enemy.get("maxhp",0),
            _atb_status_fragment(enemy)]
        if battle.accuracy.active:
            enemy_line += _combat_result_text(enemy)
        var planned: Array = enemy.get("fs_phase_state_intents",[])
        if not planned.is_empty():
            if battle.boss_state_effects.active and not bool(
                    enemy.get("fs_boss_phase_effects_pending",true)):
                enemy_line += " [已生效Boss State:%s／完整Alias待核對]" % str(
                    enemy.get("states",[]))
            else:
                enemy_line += " [State意圖:%s／效果未套用]" % str(planned)
        if enemy.get("fs_applied_boss_states",[]).has(77):
            enemy_line += " [MP護盾剩餘:%d／原版60%%吸收]" % int(
                enemy.get("fs_boss_shield_remaining",0))
        if bool(enemy.get("fs_law_active",false)):
            var cfg: Dictionary = FSBossLawCycle.configuration(enemy)
            enemy_line += " [四律:第%d律／有效行動 %d/%d（效果待移植）]" % [
                int(enemy.get("fs_law_index",0))+1,
                int(enemy.get("fs_law_action_count",0)),
                int(cfg.get("interval",1))]
        elif bool(enemy.get("fs_law_cycle_authority_pending",false)):
            enemy_line += " [四律:原始 Note／State 未驗證]"
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

func _combat_result_text(battler: Dictionary) -> String:
    # Result belongs to the TARGET battler and is recorded only when
    # the source accuracy subset genuinely resolves an ACT.
    match str(battler.get("fs_last_action_result","")):
        "miss":
            return " [上次受擊:落空]"
        "evade":
            return " [上次受擊:迴避]"
        "hit":
            return (" [上次受擊:暴擊]" if bool(battler.get(
                "fs_last_action_critical",false)) else " [上次受擊:命中]")
    return ""

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

func _source_target_selection_shell()->void:
    # Real original #462 has no permanent Godot developer title/tab/log.
    # Keep only the functional target-choice ScrollContainer, not the
    # old prototype chrome. Synthetic public CI keeps its fallback shell.
    if ui_art==null or not ui_art.has_source():
        return
    title_label.visible=false
    tab_bar.visible=false
    status_label.visible=false
    log_label.visible=false
    developer_scroll.visible=true

func _source_target_button_layout()->void:
    if body.get_child_count()<=0:
        return
    var choice:Control=body.get_child(body.get_child_count()-1)
    choice.size_flags_horizontal=Control.SIZE_SHRINK_END
    choice.custom_minimum_size=Vector2(160,25)

func _install_source_target_help()->void:
    if db==null or body==null:
        return
    source_target_help=HELP_462.new()
    source_target_help.name="FSOriginal462SelectionHelp"
    body.add_child(source_target_help)
    source_target_help.install(db)

func _preview_source_target(target:Dictionary,is_enemy:bool)->void:
    if source_target_help==null or not is_instance_valid(source_target_help):
        return
    # Existing FSTargetPriority remains the authority for legal choices.
    # Read-only #462 help is never allowed to enqueue an ACT action.
    source_target_help.select(target,is_enemy)

func _select_enemy_target(callback: Callable,skill_id: int = 0) -> void:
    battle.source_atb_wait = true
    _clear_body()
    title_label.text = "Forest Symphony / 選擇敵方目標"
    _install_source_target_help()
    _source_target_selection_shell()
    var allowed: Dictionary = FSTargetPriority.player_enemy_candidates(
        battle,skill_id)
    if not bool(allowed.get("ok",false)):
        _add_text("無法確認原版目標優先權：" + str(allowed.get("reason","")))
    else:
        var first:bool=true
        for index in allowed.get("indices",[]):
            var target: Dictionary = battle.enemies[int(index)]
            if first:
                _preview_source_target(target,true)
                first=false
            _add_button("%s HP %d/%d" % [
                target.get("name","?"),target.get("hp",0),target.get("maxhp",0)],
                func() -> void: callback.call(target))
            var button:Button=body.get_child(body.get_child_count()-1)
            button.mouse_entered.connect(
                func()->void:_preview_source_target(target,true))
            _source_target_button_layout()
    _add_button("返回", _show_battle)
    _source_target_button_layout()

func _select_ally_target(callback: Callable) -> void:
    battle.source_atb_wait = true
    _clear_body()
    title_label.text = "Forest Symphony / 選擇我方目標"
    _install_source_target_help()
    _source_target_selection_shell()
    for index in range(battle.party.size()):
        var target: Dictionary = battle.party[index]
        if source_target_help!=null and source_target_help.active_target.is_empty():
            _preview_source_target(target,false)
        _add_button("%s HP %d/%d" % [
            target.get("name","?"),target.get("hp",0),target.get("maxhp",0)],
            func() -> void: callback.call(target))
        var button:Button=body.get_child(body.get_child_count()-1)
        button.mouse_entered.connect(
            func()->void:_preview_source_target(target,false))
        _source_target_button_layout()
    _add_button("返回", _show_battle)
    _source_target_button_layout()

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
    if actor01_presentation!=null:
        actor01_presentation.sync_from_battle(battle)

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
    elif scope==11 and skill_id==141 and battle.ivy_cover.active and bool(
            skill.get("fs_ivy_guard_tag_verified",false)):
        # Self-targeting Ivy source-only skill, not arbitrary AoE/state.
        _use_skill(skill_id,battle.party[actor_index])
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
    # P538C source page hides the developer log; denied equipment or
    # unverified item usage must be visible to the player, not silent.
    if source_page_overlay!=null and source_page_overlay.visible:
        source_page_overlay.show_feedback(message)

func _on_battle_finished(victory: bool) -> void:
    _show_log("戰鬥結束：" + ("勝利" if victory else "失敗"))
