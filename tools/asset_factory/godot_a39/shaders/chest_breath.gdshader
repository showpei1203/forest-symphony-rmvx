shader_type canvas_item;
render_mode unshaded;

// FS A39: exact source RGB/alpha, local native-pixel chest and shoulder movement ONLY.
// The entire head (y < 34) and leg/boot region (y >= 43) are immutable.
// Pixel sampler returns an EXISTING source pixel with unchanged alpha.
uniform float breath_phase : hint_range(0.0, 1.0, 0.01) = 0.0;
const vec2 SOURCE_SIZE = vec2(64.0, 64.0);

void fragment() {
    vec2 p = floor(UV * SOURCE_SIZE);
    vec4 base = texture(TEXTURE, UV);
    vec2 sample_px = p;
    float level = 0.0;
    if (breath_phase >= 0.23) { level = 1.0; }
    if (breath_phase >= 0.50) { level = 2.0; }
    if (breath_phase >= 0.78) { level = 3.0; }

    bool chest = p.x >= 32.0 && p.x <= 39.0 && p.y >= 36.0 && p.y <= 41.0;
    bool shoulder_left = p.x >= 25.0 && p.x <= 30.0 && p.y >= 34.0 && p.y <= 36.0;
    bool shoulder_right = p.x >= 39.0 && p.x <= 42.0 && p.y >= 34.0 && p.y <= 36.0;
    if (chest && level > 0.0) {
        // Stretch breastplate by one native pixel along both sides, without moving the limbs.
        if (p.y >= 37.0 && p.y <= 39.0) {
            sample_px.x += (p.x < 36.0 ? 1.0 : -1.0);
        }
        if (level >= 2.0 && p.y >= 39.0) {
            sample_px.y -= 1.0;
        }
        if (level >= 3.0 && p.y >= 38.0 && p.x >= 34.0 && p.x <= 37.0) {
            sample_px.y = min(sample_px.y + 1.0, 41.0);
        }
    } else if ((shoulder_left || shoulder_right) && level >= 2.0) {
        sample_px.y += 1.0;
    }
    if (sample_px != p) {
        vec4 pulled = texture(TEXTURE, (sample_px + vec2(0.5)) / SOURCE_SIZE);
        // Alpha-mask lock: no transparent holes, no altered silhouette, no repaint.
        if (base.a > 0.99 && pulled.a > 0.99) {
            COLOR = vec4(pulled.rgb, base.a);
        } else {
            COLOR = base;
        }
    } else {
        COLOR = base;
    }
}
