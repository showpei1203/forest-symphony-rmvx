extends "res://render_stage8_oak.gd"
## Stage9: native 3D source tree, not flatten-then-recrop.
## A: stepped directional leaf shading. B: clustered color+underside shade.
## Same 32px tree source geometry and world-space Ground/PAR cut as Stage8.
var stage9_shader: Shader
var stage9_cache: Dictionary={}

func _get_crown_shader() -> Shader:
    if stage9_shader != null:
        return stage9_shader
    stage9_shader=Shader.new()
    stage9_shader.code="""
shader_type spatial;
render_mode unshaded, cull_disabled;
uniform vec4 tint : source_color=vec4(.50,.65,.36,1.);
uniform float cutoff=0.56;
uniform bool is_lower=false;
uniform int style=0;
uniform float material_seed=0.0;
varying float world_height;
varying vec3 world_point;
varying vec3 normal_world;
void vertex() {
    world_point=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
    world_height=world_point.y;
    normal_world=normalize(MODEL_NORMAL_MATRIX*NORMAL);
}
void fragment() {
    if (is_lower && world_height >= cutoff) discard;
    if (!is_lower && world_height < cutoff) discard;
    vec3 lightdir=normalize(vec3(-0.42,0.82,0.29));
    float facing=dot(normalize(normal_world),lightdir);
    float band=(facing>0.52 ? 0.94 : (facing>0.06 ? .77 : .59));
    if (style==1) {
        // Deterministic 3D patches, not blurry 2D downsample.
        float patch=sin(world_point.x*8.1+material_seed)*cos(world_point.z*8.6-material_seed*0.7);
        patch+=0.46*sin(world_point.y*6.2+world_point.z*4.1);
        band*=patch>0.40 ? 0.97 : (patch<-0.46 ? .69 : .85);
        // Lower canopy reaches more occluded foliage. Backlit silhouettes stay dark.
        if (world_height<1.65 && facing<0.20) band*=0.83;
    }
    ALBEDO=clamp(tint.rgb*band,vec3(0.),vec3(1.));
    ALPHA=1.;
}
"""
    return stage9_shader

func _build_crown_material(color:Color, lower:bool, style:int, seed:float) -> ShaderMaterial:
    var key:String="%s_%s_%d_%d" % [color.to_html(false),str(lower),style, int(seed*10)]
    if stage9_cache.has(key):
        return stage9_cache[key] as ShaderMaterial
    var mat:=ShaderMaterial.new()
    mat.shader=_get_crown_shader()
    mat.set_shader_parameter("tint",color)
    mat.set_shader_parameter("cutoff",0.56)
    mat.set_shader_parameter("is_lower",lower)
    mat.set_shader_parameter("style",style)
    mat.set_shader_parameter("material_seed",seed)
    stage9_cache[key]=mat
    return mat

func _set_native_clip(inst:Node3D, lower:bool,palette:String)->void:
    var mode:String=OS.get_environment("FS_STAGE9_STYLE")
    var style:int=1 if mode=="clusters" else 0
    var count:int=0
    var mesh_index:int=0
    for it in inst.find_children("*","MeshInstance3D",true,false):
        var node:=it as MeshInstance3D
        if node.mesh == null:
            continue
        var surf_num:int=node.mesh.get_surface_count()
        for i in range(surf_num):
            var original:Material=node.get_active_material(i)
            var color:Color=super._material_tint(original,"harmonized")
            var bark:bool=original.resource_name.to_lower().contains("bark")
            if not bark:
                # Palette anchored in forest colors, with source-space leaf groups.
                var wp:Vector3=node.global_transform.origin
                var leaf_hash:float=sin(wp.x*4.39+wp.y*1.7+wp.z*3.73+float(mesh_index)*.047)
                var palette_scale:float=0.90 if style==0 else (0.88 if leaf_hash<-.32 else (1.06 if leaf_hash>.42 else 0.94))
                color=Color(color.r*palette_scale*0.72,color.g*palette_scale*0.68,color.b*palette_scale*0.78,1.0)
            var seed:float=0.0 if bark else float(mesh_index%11)*.17
            node.set_surface_override_material(i,_build_crown_material(color,lower,style,seed))
            count+=1
            mesh_index+=1
    print("STAGE9_MESHES=",count," LOWER=",lower," STYLE=",mode," CACHE=",stage9_cache.size())