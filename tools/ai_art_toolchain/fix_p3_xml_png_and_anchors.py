from pathlib import Path
R=Path(r"E:\GameAssetToolLab_20261023\TOOLCHAIN_PILOT_20261025")
P=R/"outputs/P3_R3_G2_NATIVE_GODOT_XML_PLAYER_20261026/pmd_xml_player.gd"
s=P.read_text(encoding="utf-8")
a='''func image_or_null(path: String) -> Image:
    var img: Image = Image.load_from_file(path)
    return img'''
b='''func image_or_null(path: String) -> Image:
    var file_bytes: PackedByteArray=FileAccess.get_file_as_bytes(path)
    if file_bytes.size()==0:
        return null
    var img:=Image.new()
    if img.load_png_from_buffer(file_bytes)!=OK:
        return null
    return img'''
assert a in s
s=s.replace(a,b)
s=s.replace('''            sprite.region_rect = Rect2(0,0,fw,fh)''','''            sprite.region_rect = Rect2(0,0,fw,fh)
            sprite.set_meta("cell_width",fw)
            sprite.set_meta("cell_height",fh)
            sprite.set_meta("frame_count",nf)''')
a2='''            var imw:int=sprite.texture.get_width()
            var imh:int=sprite.texture.get_height()
            var cellh:int=0
            var cellw:int=0
            for item in actual:
                if imw==item["cell"].x*item["frames"] and imh%item["cell"].y==0:
                    cellw=item["cell"].x
                    cellh=item["cell"].y
                    break
            if cellw==0:
                issues.append("RENDER_CELL_NOT_FOUND")
                continue
            sprite.region_rect=Rect2((f % int(imw/cellw))*cellw,2*cellh,cellw,cellh)'''
b2='''            var cellw:int=int(sprite.get_meta("cell_width"))
            var cellh:int=int(sprite.get_meta("cell_height"))
            var total:int=int(sprite.get_meta("frame_count"))
            sprite.region_rect=Rect2((f % total)*cellw,2*cellh,cellw,cellh)'''
assert a2 in s
s=s.replace(a2,b2)
P.write_text(s,encoding="utf-8")
print("P3 native GDScript: PNG bytes decode not export-warning prone; per-action frame anchors explicit.")
