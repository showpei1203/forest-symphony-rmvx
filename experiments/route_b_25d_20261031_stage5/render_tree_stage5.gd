extends "res://render_terrain_stage4.gd"
# FS Route B Stage5: True source-owned bottom tree contact in GROUND (layer 4).
# Native upper branches and crowns remain PAR (layer 2).
const CONTACT_LAYER := 4
const CUT_WORLD_Y := 0.56
const CLIP_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled;
uniform vec4 tint : source_color = vec4(1.0);
uniform float cutoff = 0.8;
uniform bool show_lower = true;
varying float pos_world_y;
void vertex() {
    pos_world_y=(MODEL_MATRIX*vec4(VERTEX,1.0)).y;
}
void fragment() {
    if (show_lower && pos_world_y >= cutoff) discard;
    if (!show_lower && pos_world_y < cutoff) discard;
    ALBEDO=tint.rgb;
    ALPHA=1.0;
}
"""
var clip_program: Shader

func _set_tree_source_clip(inst: Node3D, is_lower: bool) -> void:
    if clip_program == null:
        clip_program = Shader.new()
        clip_program.code = CLIP_SHADER
    for child in inst.find_children("*","MeshInstance3D",true,false):
        var mesh_node:MeshInstance3D=child as MeshInstance3D
        if mesh_node.mesh == null:
            continue
        for surf in range(mesh_node.mesh.get_surface_count()):
            var mat:Material=mesh_node.get_active_material(surf)
            var tint:Color=Color("#80a966")
            if mat is StandardMaterial3D:
                tint=(mat as StandardMaterial3D).albedo_color
            var shader_mat:=ShaderMaterial.new()
            shader_mat.shader=clip_program
            shader_mat.set_shader_parameter("tint",tint)
            shader_mat.set_shader_parameter("cutoff",CUT_WORLD_Y)
            shader_mat.set_shader_parameter("show_lower",is_lower)
            mesh_node.set_surface_override_material(surf,shader_mat)

func _tree(x:float,z:float,height:float,variant:int=0)->void:
    # No extra fake stump: two identical GLB source instances, clipped in real 3D at one world height.
    # Thus tree bark is continuous and no crown/branch image is retro-cut.
    var name: String="tree-detailed" if variant==1 else "tree-oak"
    var h:float=height*1.40
    var rot:float=0.18 if variant==0 else -0.35
    var pos:=Vector3(x,0,z)
    var base:Node3D=_import_model(name,pos,h,CONTACT_LAYER,rot)
    var upper:Node3D=_import_model(name,pos,h,OBJECT_LAYER,rot)
    if base != null:
        _set_tree_source_clip(base,true)
    if upper != null:
        _set_tree_source_clip(upper,false)