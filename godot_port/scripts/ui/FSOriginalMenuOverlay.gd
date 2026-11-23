extends Control
class_name FSOriginalMenuOverlay

# P538A original 50x20 menu art from owner-only 202-image VX archive.
# This UI is only installed when all 8 source images + MenuBack_b are
# SHA-verified. Gameplay still lives in FSScreen/FSMenuModel, not this view.
# Source art: Menu01 Item, 02 Status, 03 Skill, 04 Equip, 05 Party,
# 06 Quest, 07 Save, 08 System. Last three are intentionally not wired.
signal command_requested(source_index:int)

const ICON_NAMES=["Menu01.png","Menu02.png","Menu03.png","Menu04.png",
                  "Menu05.png","Menu06.png","Menu07.png","Menu08.png"]
const LABELS=["物品","狀態","技能","裝備","隊伍","任務","儲存","系統"]
const SUPPORTED=[true,true,true,true,true,false,false,false]
const ART_SIZE:=Vector2i(50,20)
const PANEL_SIZE:=Vector2i(544,416)
var source_ready:bool=false
var command_buttons:Array[TextureButton]=[]
var summary:Label

func configure(provider:FSUIArtLibrary,party_rows:Array,
        boot_verified:bool)->bool:
    if not source_ready:
        if provider==null or provider.texture("system","MenuBack_b.png")==null:
            return false
        var sprites:Array[Texture2D]=[]
        for filename in ICON_NAMES:
            var icon:Texture2D=provider.texture("menu",filename)
            if icon==null or Vector2i(icon.get_size())!=ART_SIZE:
                return false
            sprites.append(icon)
        _install(sprites)
    _refresh_summary(party_rows,boot_verified)
    return source_ready

func _install(sprites:Array[Texture2D])->void:
    if sprites.size()!=8:
        return
    custom_minimum_size=Vector2(PANEL_SIZE)
    size=Vector2(PANEL_SIZE)
    mouse_filter=Control.MOUSE_FILTER_PASS
    texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    var label:=Label.new()
    label.text="原始 FS 選單"
    label.position=Vector2(147,62)
    label.add_theme_color_override("font_color",Color(0.06,0.19,0.2))
    add_child(label)
    for i in range(8):
        var index:int=i
        var button:=TextureButton.new()
        button.name="FSOriginalMenu"+str(i+1).pad_zeros(2)
        button.texture_normal=sprites[i]
        button.texture_disabled=sprites[i]
        button.ignore_texture_size=true
        button.stretch_mode=TextureButton.STRETCH_KEEP_CENTERED
        button.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
        button.custom_minimum_size=Vector2(65,30)
        button.size=Vector2(65,30)
        button.position=Vector2(145+(i%4)*83,100+int(i/4)*44)
        button.disabled=not bool(SUPPORTED[i])
        button.modulate=Color(0.53,0.53,0.53,0.8) if button.disabled else Color.WHITE
        button.tooltip_text=LABELS[i]+(
            "：原版功能尚未移植，不可操作" if button.disabled else "：開啟")
        button.focus_mode=Control.FOCUS_ALL
        if not button.disabled:
            button.pressed.connect(func()->void: command_requested.emit(index))
        add_child(button)
        command_buttons.append(button)
    summary=Label.new()
    summary.position=Vector2(148,222)
    summary.size=Vector2(330,145)
    summary.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    summary.add_theme_color_override("font_color",Color(0.04,0.18,0.19))
    summary.add_theme_font_size_override("font_size",13)
    add_child(summary)
    source_ready=true

func _refresh_summary(party_rows:Array,boot_verified:bool)->void:
    if summary==null:
        return
    var lines:Array[String]=[]
    lines.append("隊伍概況")
    if not boot_verified:
        lines.append("資料未通過原版啟動後驗證：僅供移植測試")
    for i in range(mini(party_rows.size(),4)):
        var row:Dictionary=party_rows[i]
        lines.append("%s  Lv.%d  HP %d/%d  MP %d/%d" % [
            row.get("name","?"),row.get("level",0),row.get("hp",0),
            row.get("maxhp",0),row.get("mp",0),row.get("maxmp",0)])
    lines.append("任務／儲存／系統尚待原版事件相容")
    summary.text="\n".join(PackedStringArray(lines))
