shader_type canvas_item;

// 顶部灯带亮度
uniform float top_light_strength : hint_range(0.0, 2.0) = 0.9;
// 灯带向下影响范围
uniform float light_height : hint_range(0.0, 1.0) = 0.33;

// 门缝高光强度
uniform float seam_highlight : hint_range(0.0, 1.0) = 0.35;

// 金属反射程度
uniform float metal_reflect : hint_range(0.0, 1.0) = 0.18;

// 金属拉丝强度（适度即可）
uniform float brush_strength : hint_range(0.0, 1.0) = 0.08;

float hash(vec2 p){
    return fract(sin(dot(p, vec2(27.619, 57.583))) * 43758.5453);
}

float brushed_noise(vec2 uv){
    float n = hash(vec2(uv.y * 55.0, 0.0));
    return n * 2.0 - 1.0;
}

void fragment() {
    vec4 base = texture(TEXTURE, UV);


    // -------------------------------------------------
    // 1) 上方灯光向下扩散（现实电梯灯带）
    // -------------------------------------------------
    float top_light = smoothstep(light_height, 0.0, UV.y);
    top_light = pow(top_light, 1.4);

    base.rgb += top_light * top_light_strength;


    // -------------------------------------------------
    // 2) 环境反射（上亮下暗）
    // -------------------------------------------------
    float reflect_top = smoothstep(0.3, 0.0, UV.y);   // 天花板亮光
    float reflect_bottom = smoothstep(0.3, 1.0, UV.y); // 地板暗光

    vec3 reflect_color = vec3(0.65) * reflect_top + vec3(0.15) * reflect_bottom;

    base.rgb += reflect_color * metal_reflect;


    // -------------------------------------------------
    // 3) 门缝高光（你的纹理中间是缝）
    // -------------------------------------------------
    float seam = abs(UV.x - 0.5);  // 距离中线
    float seam_high = smoothstep(0.12, 0.0, seam);  // 中间区域亮
    seam_high = pow(seam_high, 2.2);

    base.rgb += seam_high * seam_highlight;


    // -------------------------------------------------
    // 4) 拉丝金属噪声（垂直方向）
    // -------------------------------------------------
    float brushed = brushed_noise(UV);
    base.rgb += brushed * brush_strength;


    COLOR = base;
}
