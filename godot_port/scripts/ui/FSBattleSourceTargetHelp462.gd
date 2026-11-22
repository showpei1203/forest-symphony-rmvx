extends Control
class_name FSBattleSourceTargetHelp462

# Bounded, source-derived PORT of original FS Ruby #462
# Window_Help#set_text_n01add / fs_bthud_v10_redraw_target_header,
# and #381 Window_AlbertBattleStateDetail. The source HELP header is
# NAME + optional real verified CaptureRate, NOT permanent debug text.
# Original #462 SHOW_HELP_STATE_ICONS=false: #381 sprite owns those icons.
# Full original Window_AlbertBattleStateDetail dynamic anchor/extra gameplay
# rows and name/element icons are still HOLD until source authorities exist.
const SOURCE_SECTION:int=462
const STATE_SECTION:int=381
const CAPTURE_WIDTH:int=132
const NAME_FONT_SIZE:int=19
const NAME_MIN_FONT:int=13
const DETAIL_MIN_WIDTH:int=220
const DETAIL_MAX_WIDTH:int=520
const DETAIL_COMMAND_LEFT:int=16
const DETAIL_COMMAND_SAFE_RIGHT:int=410
const DETAIL_TOP_LIMIT:int=82
const DETAIL_ROW_HEIGHT:int=19
const DETAIL_MAX_STATE_ROWS:int=12
const DETAIL_MAX_INFO_ROWS:int=6
const SHOW_HELP_STATE_ICONS:bool=false
const SOURCE_NAME_SAFE_WIDTH:int=370
const SOURCE_HEADER_HEIGHT:int=34
const DETAIL_RENDER_Y:int=175 # dynamic bottom-safe layout for #462 when source enemy at y65..142
const OUTER_MARGIN:int=8
var source_db:FSDatabase
var active_target:Dictionary={}
var source_ready:bool=false
var target_is_enemy:bool=false
var header:Dictionary={}
var detail_lines:Array[String]=[]
var info_lines:Array[String]=[]
var source_warnings:Array[String]=[]
var detail_signature:String=""

func _ready()->void:
    name="FSOriginal462TargetHelpAnd381StatusDetail"
    mouse_filter=Control.MOUSE_FILTER_IGNORE
    texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    custom_minimum_size=Vector2(528,60)
    visible=false

static func layout_while_commanding()->Dictionary:
    # #462 lines 84-106, 397-421: detail must never trespass on
    # source Battle01..05 buttons at x410+ in command UI.
    return {"x":DETAIL_COMMAND_LEFT,"width":
        DETAIL_COMMAND_SAFE_RIGHT-DETAIL_COMMAND_LEFT,
        "top":DETAIL_TOP_LIMIT,"max_rows":DETAIL_MAX_INFO_ROWS}

static func safe_capture(target:Dictionary,is_enemy:bool)->Dictionary:
    # Original source only displays capture when BOTH Albert_CaptureRate::
    # HELP_SHOW and Game_Enemy#albert_current_capture_rate are available.
    # No guessing from HP or species!
    if not is_enemy or not bool(target.get(
            "albert_capture_help_verified",false)) or not target.has(
            "albert_current_capture_rate"):
        return {"visible":false,"label":"","rate":-1}
    var value:Variant=target["albert_current_capture_rate"]
    if not (value is int or value is float):
        return {"visible":false,"label":"","rate":-1}
    if float(value)<0.0 or float(value)>100.0:
        return {"visible":false,"label":"","rate":-1}
    var rounded:int=clampi(int(round(float(value))),0,100)
    return {"visible":true,"label":"擷取率：%d%%" % rounded,
        "rate":rounded}

static func source_header(target:Dictionary,is_enemy:bool)->Dictionary:
    if int(target.get("hp",0))<=0:
        return {"ok":false,"reason":"Target is not alive"}
    var name:String=str(target.get("name","")).strip_edges()
    if name.is_empty():
        return {"ok":false,"reason":"No original target name"}
    var capture:Dictionary=safe_capture(target,is_enemy)
    # Original #462 does not show State icons in Help; the icon
    # series remains in #381 battler HUD. Nonverified element icons
    # and captures are not invented.
    return {"ok":true,"name":name,"capture":capture,
        "show_state_icons":SHOW_HELP_STATE_ICONS}

func install(source:FSDatabase)->bool:
    clear_source()
    if source==null:
        return false
    source_db=source
    source_ready=true
    return true

func clear_source()->void:
    active_target.clear()
    source_warnings.clear()
    detail_lines.clear()
    info_lines.clear()
    detail_signature=""
    header.clear()
    visible=false
    source_ready=false
    source_db=null
    queue_redraw()

func select(target:Dictionary,is_enemy:bool)->bool:
    active_target.clear()
    detail_lines.clear()
    info_lines.clear()
    detail_signature=""
    source_warnings.clear()
    header.clear()
    if not source_ready or source_db==null:
        visible=false
        return false
    header=source_header(target,is_enemy)
    if not bool(header.get("ok",false)):
        visible=false
        return false
    active_target=target
    target_is_enemy=is_enemy
    # #381 original line 1617 draws ExtraInfoRows BEFORE state details.
    # Never invent values for a missing ManaShield/Robot/Break provider.
    var extras:Dictionary=FSOriginalBattleInfo381.extra_info_rows(
        target,source_db)
    if not bool(extras.get("ok",false)):
        source_warnings.append(str(extras.get("reason","")))
    else:
        for row in extras["rows"]:
            if detail_lines.size()>=DETAIL_MAX_INFO_ROWS:
                break
            var rendered:String=str(row.get("label",""))+"　"+str(
                row.get("value",""))
            info_lines.append(rendered)
            detail_lines.append(rendered)
    var quote:Dictionary=FSBattleSourceStateHUD381.detail_rows(
        target,source_db,DETAIL_MAX_STATE_ROWS)
    if not bool(quote.get("ok",false)):
        # The original battle data has not been validated. Refuse to draw
        # fabricated state detail, but keep name/help from the real target.
        source_warnings.append(str(quote.get("reason","")))
    else:
        for record in quote["rows"]:
            if detail_lines.size()>=DETAIL_MAX_INFO_ROWS:
                break
            detail_lines.append(str(record.get("text","")))
    # The source Ruby #381 polls quick signatures (states/stacks/turns)
    # and all extra info rows; updates must track REAL provider changes.
    detail_signature=JSON.stringify([header,info_lines,detail_lines])
    # Control is embedded in the selection list; reserve genuine source
    # target-help space without overlapping the original battler artwork.
    custom_minimum_size=Vector2(528,float(
        maxi(189,DETAIL_RENDER_Y+8+detail_lines.size()*DETAIL_ROW_HEIGHT)))
    visible=true
    queue_redraw()
    return true

func refresh_live()->bool:
    if not source_ready or not visible or active_target.is_empty():
        return false
    var previous:String=detail_signature
    var previous_warnings:Array[String]=source_warnings.duplicate()
    # Select performs a read-only source quote; no ATB, ACT or MP side effect.
    var target:Dictionary=active_target
    var is_enemy:bool=target_is_enemy
    select(target,is_enemy)
    return detail_signature!=previous or source_warnings!=previous_warnings

func _draw()->void:
    if not visible or not bool(header.get("ok",false)):
        return
    var area_width:float=maxf(528.0,size.x)
    var background:=Color(0,0,0,0.82)
    draw_rect(Rect2(Vector2(OUTER_MARGIN,3),
        Vector2(area_width-OUTER_MARGIN*2,SOURCE_HEADER_HEIGHT)),
        background)
    var font:Font=get_theme_default_font()
    if font==null:
        return
    var capture:Dictionary=header["capture"]
    var capture_width:float=0.0
    if bool(capture.get("visible",false)):
        capture_width=float(CAPTURE_WIDTH)
        draw_rect(Rect2(Vector2(OUTER_MARGIN+2,5),
            Vector2(capture_width-6,28)),Color(0,0,0,150.0/255.0))
        draw_string(font,Vector2(OUTER_MARGIN+5,25),
            str(capture["label"]),HORIZONTAL_ALIGNMENT_LEFT,
            capture_width-9,14,Color(0.95,0.86,0.55))
    var name_start:float=capture_width+OUTER_MARGIN+6.0
    var name_width:float=minf(area_width-name_start-OUTER_MARGIN,
        float(SOURCE_NAME_SAFE_WIDTH))
    if name_width>14:
        draw_string(font,Vector2(name_start,26),str(header["name"]),
            HORIZONTAL_ALIGNMENT_CENTER,name_width,NAME_FONT_SIZE,
            Color(1,1,1))
    # #381 state-detail panel; source #462 command-safe width is x16..410.
    if detail_lines.is_empty():
        return
    var left:float=float(DETAIL_COMMAND_LEFT)
    var width:float=minf(float(
        DETAIL_COMMAND_SAFE_RIGHT-DETAIL_COMMAND_LEFT),area_width-left-12.0)
    var rows:int=mini(detail_lines.size(),DETAIL_MAX_INFO_ROWS)
    var height:float=8.0+float(rows*DETAIL_ROW_HEIGHT)
    draw_rect(Rect2(Vector2(left,float(DETAIL_RENDER_Y)),Vector2(width,height)),
        Color(0,0,0,176.0/255.0))
    draw_rect(Rect2(Vector2(left,float(DETAIL_RENDER_Y)),Vector2(width,height)),
        Color(1,1,1,72.0/255.0),false,1.0)
    for i in range(rows):
        draw_string(font,Vector2(left+8,float(DETAIL_RENDER_Y+17+i*DETAIL_ROW_HEIGHT)),
            detail_lines[i],HORIZONTAL_ALIGNMENT_LEFT,width-16.0,
            14,Color(0.93,0.96,1.0))
