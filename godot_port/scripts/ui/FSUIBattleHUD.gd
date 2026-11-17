extends HFlowContainer
class_name FSUIBattleHUD

# P536: Real battle stats drive both original source-image vitals and
# fallback progress bars. No source PNG is ever bundled in GitHub.
const ORIGINAL=preload("res://scripts/ui/FSUIOriginalVitals.gd")
var art:FSUIArtLibrary
var _records:Array=[]
var _count:int=-1

func set_art(provider:FSUIArtLibrary)->void:
    art=provider

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
        card.custom_minimum_size=Vector2(144,0)
        card.add_theme_constant_override("separation",2)
        add_child(card)
        var name_label:=Label.new()
        name_label.text=str(actor.get("name","?"))
        card.add_child(name_label)
        var original=ORIGINAL.new()
        var original_ok:bool=original.install_art(art)
        if original_ok:
            card.add_child(original)
        else:
            original.free()
            original=null
        var gauges:Dictionary={}
        var summary:Label=null
        if original_ok:
            summary=Label.new()
            summary.add_theme_font_size_override("font_size",11)
            card.add_child(summary)
        for metric in ["HP","MP","ATB"]:
            var label:=Label.new()
            if original_ok and metric!="ATB":
                label.visible=false
            card.add_child(label)
            var bar:=ProgressBar.new()
            bar.custom_minimum_size=Vector2(135,7)
            bar.show_percentage=false
            bar.min_value=0.0
            bar.max_value=100.0
            bar.value=0.0
            # Original source 135x40 already draws HP/MP/OD colour fills.
            # Hidden fallback bars retain true values for programmatic QA.
            if original_ok and metric!="ATB":
                bar.visible=false
            card.add_child(bar)
            gauges[metric]={"label":label,"bar":bar}
        _records.append({"name":name_label,"gauges":gauges,"original":original,"summary":summary})
    refresh(party)

func refresh(party:Array)->void:
    if _count!=party.size():
        bind_party(party)
        return
    for i in range(party.size()):
        var actor:Dictionary=party[i]
        var record:Dictionary=_records[i]
        var name_label:Label=record["name"]
        name_label.text=str(actor.get("name","?"))
        var original:FSUIOriginalVitals=record["original"]
        if original!=null:
            original.set_values(actor)
        var gauges:Dictionary=record["gauges"]
        for metric in ["HP","MP"]:
            var current:int=maxi(0,int(actor.get(metric.to_lower(),0)))
            var maximum:int=maxi(1,int(actor.get("max"+metric.to_lower(),1)))
            var datum:Dictionary=gauges[metric]
            var bar:ProgressBar=datum["bar"]
            bar.value=clampf(100.0*float(current)/float(maximum),0.0,100.0)
            var caption:Label=datum["label"]
            caption.text="%s %d/%d" % [metric,current,maximum]
        var summary:Label=record["summary"]
        if summary!=null:
            summary.text="HP %d/%d  MP %d/%d" % [
                int(actor.get("hp",0)),int(actor.get("maxhp",0)),
                int(actor.get("mp",0)),int(actor.get("maxmp",0))]
        var atb:Dictionary=gauges["ATB"]
        var count:int=clampi(int(actor.get("source_atb_count",0)),0,1000)
        var atb_bar:ProgressBar=atb["bar"]
        atb_bar.value=float(count)*0.1
        var atb_label:Label=atb["label"]
        atb_label.text="ACT 蓄力" if bool(actor.get("source_act_active",false)) else (
            "ATB 就緒" if bool(actor.get("source_at_active",false)) else (
            "ATB %d%%" % int(float(count)*0.1)))
