extends SceneTree

func _initialize() -> void:
    var scr := load("res://cottage_prefab.gd") as GDScript
    var house := scr.new() as Node3D
    house.name="FS_Elf_Cottage"
    root.add_child(house)
    house.build()
    for child in house.get_children():
        child.owner=house
    var pack := PackedScene.new()
    var err := pack.pack(house)
    var save_err:Error = ERR_INVALID_DATA
    if err == OK:
        save_err = ResourceSaver.save(pack,"res://FS_Elf_Cottage.tscn")
    print("PREFAB_PACK ",err," SAVE ",save_err," NODES=",house.get_child_count())
    quit(0 if err==OK and save_err==OK else 3)