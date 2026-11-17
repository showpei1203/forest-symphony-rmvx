extends HFlowContainer
class_name FSUIBattleHUD

# Actual FS GameState/FSBattle values drive display.
# Original source graphics, when SHA-gated, are decorative until frame
# slicing/parity is proved; ProgressBars always show TRUE live numbers.
var art:FSUIArtLibrary
var _records:Array=[]
var _count:int=-1

func set_art(provider:FSUIArtLibrary)->void:
    art=provider

func _decorative_texture(parent:Node,filename:String)->void:
    if art==null:
        return
    var image:Texture2D=art.texture("system",filename)
    if image==null:
        return
    var visual:=TextureRect.new()
    visual.texture=image
    visual.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    visual.stretch_mode=TextureRect.STRETCH_KEEP
    visual.custom_minimum_size=Vector2(image.get_width(),min(image.get_height(),40))
    parent.add_child(visual)

func _gauge_ornament(parent:Node,filename:String)->void:
    # Reuse source UI pixels at their verified resolution. This decoration
    # has NO gameplay authority: the adjacent ProgressBar is data-driven.
    if art==null:
        return
    var image:Texture2D=art.texture("system",filename)
    if image==null:
        return
    var view:=TextureRect.new()
    view.texture=image
    view.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
    view.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    view.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    view.custom_minimum_size=Vector2(54,21)
    parent.add_child(view)

func bind_party(party:Array)->void:
    if _count==party.size():
        refresh(party)
        return
    for child in get_children():
        remove_child(child)
        child.queue_free()
    _records.clear()
    _count=party.size()
    for actor in party:
        var card:=VBoxContainer.new()
        card.custom_minimum_size=Vector2(148,0)
        add_child(card)
        _decorative_texture(card,"Btskin_main.png")
        var name_label:=Label.new()
        name_label.text=str(actor.get("name","?"))
        card.add_child(name_label)
        var gauges:Dictionary={}
        for metric in ["HP","MP","ATB"]:
            var label:=Label.new()
            card.add_child(label)
            var gauge_row:=HBoxContainer.new()
            card.add_child(gauge_row)
            var source_file:String="GaugeHP.png" if metric=="HP" else (
                "GaugeMP.png" if metric=="MP" else "atb_bar_skin.png")
            _gauge_ornament(gauge_row,source_file)
            var bar:=ProgressBar.new()
            bar.custom_minimum_size=Vector2(78,8)
            bar.show_percentage=false
            bar.min_value=0.0
            bar.max_value=100.0
            bar.value=0.0
            gauge_row.add_child(bar)
            gauges[metric]={"label":label,"bar":bar}
        _records.append({"name":name_label,"gauges":gauges})
    refresh(party)

func refresh(party:Array)->void:
    if _count!=party.size():
        bind_party(party)
        return
    for i in range(party.size()):
        var actor:Dictionary=party[i]
        var record:Dictionary=_records[i]
        var label:Label=record["name"]
        label.text=str(actor.get("name","?"))
        var gauges:Dictionary=record["gauges"]
        for metric in ["HP","MP"]:
            var current:int=maxi(0,int(actor.get(metric.to_lower(),0)))
            var maximum:int=maxi(1,int(actor.get("max"+metric.to_lower(),1)))
            var datum:Dictionary=gauges[metric]
            var bar:ProgressBar=datum["bar"]
            bar.value=clampf(100.0*float(current)/float(maximum),0.0,100.0)
            var caption:Label=datum["label"]
            caption.text="%s %d/%d" % [metric,current,maximum]
        var atb:Dictionary=gauges["ATB"]
        var count:int=clampi(int(actor.get("source_atb_count",0)),0,1000)
        var atb_bar:ProgressBar=atb["bar"]
        atb_bar.value=float(count)*0.1
        var atb_label:Label=atb["label"]
        atb_label.text="ACT 蓄力" if bool(actor.get("source_act_active",false)) else (
            "ATB 就緒" if bool(actor.get("source_at_active",false)) else (
            "ATB %d%%" % int(float(count)*0.1)))
