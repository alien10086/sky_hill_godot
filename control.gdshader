shader_type canvas_item;

// ======================================================
// -------------------- Pixelate 像素化 --------------------
// ======================================================
//group: Pixelation
uniform bool use_pixelate = false;
uniform float pixel_size : hint_range(1.0, 32.0) = 4.0;

// ======================================================
// ---------------------- Outline 描边 --------------------
// ======================================================
//group: Outline
uniform bool use_outline = false;
uniform float outline_size : hint_range(0.0, 8.0) = 1.0;
uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);

// ======================================================
// ------------------- Palettizer 霓虹调色板 --------------
// ======================================================
//group: Palettizer
uniform bool use_palettizer = false;
uniform sampler2D palette_tex : source_color;

// ======================================================
// -------------------- Glitch 故障特效 -------------------
// ======================================================
//group: Glitch
uniform bool use_glitch = false;
uniform float glitch_amount : hint_range(0.0, 1.0) = 0.15;
uniform float glitch_speed = 2.0;

// ======================================================
// --------------------- CRT（色差+扫描线+曲面）-----------
// ======================================================
//group: CRT
uniform bool use_crt = false;
uniform float crt_distort = 0.1;
uniform float scanline_strength : hint_range(0.0, 2.0) = 1.0;
uniform float chroma_offset : hint_range(0.0, 5.0) = 1.0;

// ======================================================
// ------------------- Film Grain 胶片颗粒 ----------------
// ======================================================
//group: FilmGrain
uniform bool use_grain = false;
uniform float grain_amount : hint_range(0.0, 1.0) = 0.1;

// ======================================================
// --------------------- Bloom 简易发光 --------------------
// ======================================================
//group: Bloom
uniform bool use_bloom = false;
uniform float bloom_strength : hint_range(0.0, 2.0) = 0.5;
uniform float bloom_threshold : hint_range(0.0, 1.0) = 0.7;

// ======================================================
// ---------------- Color Correction 色彩调整 -------------
// ======================================================
//group: ColorCorrection
uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;


// ======================= 工具函数 =======================

// CRT 曲率模拟（UV 扭曲）
vec2 crt_curve(vec2 uv, float amount) {
    uv = uv * 2.0 - 1.0;
    uv *= 1.0 + amount * (uv.x * uv.x + uv.y * uv.y);
    return uv * 0.5 + 0.5;
}

// 获取亮度
float luminance(vec3 c) {
    return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

// 调色板量化
vec3 palette_map(vec3 color) {
    float l = luminance(color);
    return texture(palette_tex, vec2(l, 0.0)).rgb;
}


// ======================= 主渲染 =========================

void fragment() {

    vec2 uv = UV;
    vec4 col = texture(TEXTURE, uv);

    // ======================================================
    // 1. 像素化 Pixelation
    // ======================================================
    if (use_pixelate) {
        vec2 tex_size = vec2(textureSize(TEXTURE, 0));
        uv = floor(uv * tex_size / pixel_size) * pixel_size / tex_size;
        col = texture(TEXTURE, uv);
    }

    // ======================================================
    // 2. 描边 Outline
    // ======================================================
    if (use_outline) {
    float edge = 0.0;
    //vec2 t = vec2(1.0) / vec2(textureSize(TEXTURE,0).x, textureSize(TEXTURE,0).y);
	//vec2 t = vec2(1.0) / vec2(textureSize(TEXTURE,0).x, textureSize(TEXTURE,0).y);
	ivec2 texSize = textureSize(TEXTURE,0);
	vec2 t = vec2(1.0 / float(texSize.x), 1.0 / float(texSize.y));


    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec4 s = texture(TEXTURE, uv + vec2(float(x), float(y)) * t * outline_size);
            if (s.a < 0.1) edge = 1.0;
        }
    }

    if (edge > 0.5) {
        col = outline_color; // 直接赋值，不要 return
    }
}

    // ======================================================
    // 3. 调色板 Palettizer（霓虹风）
    // ======================================================
    if (use_palettizer) {
        col.rgb = palette_map(col.rgb);
    }

    // ======================================================
    // 4. Glitch 故障
    // ======================================================
    if (use_glitch) {
        float time = TIME * glitch_speed;
        float offset = sin(time * 10.0 + uv.y * 40.0) * glitch_amount;
        uv.x += offset * 0.02;
        col = texture(TEXTURE, uv);
    }

    // ======================================================
    // 5. CRT 效果（色差+扫描线+曲率）
    // ======================================================
    if (use_crt) {
        // 5.1 CRT 曲率
        uv = crt_curve(uv, crt_distort);

        // 5.2 色差偏移
        float chroma = chroma_offset * 0.002;
        float r = texture(TEXTURE, uv + vec2(chroma, 0.0)).r;
        float g = texture(TEXTURE, uv).g;
        float b = texture(TEXTURE, uv - vec2(chroma, 0.0)).b;
        col = vec4(r, g, b, 1.0);

        // 5.3 扫描线
        float scan = sin(uv.y * 1000.0) * scanline_strength * 0.1;
        col.rgb -= scan;
    }

    // ======================================================
    // 6. Film Grain（胶片颗粒）
    // ======================================================
    if (use_grain) {
        float n = fract(sin(dot(uv, vec2(12.9898,78.233)) + TIME) * 43758.5453);
        col.rgb += (n - 0.5) * grain_amount;
    }

    // ======================================================
    // 7. 简易 Bloom（基于阈值的发光）
    // ======================================================
    if (use_bloom) {
        float bright = max(max(col.r, col.g), col.b);
        if (bright > bloom_threshold) {
            col.rgb += col.rgb * bloom_strength;
        }
    }

    // ======================================================
    // 8. 色彩调整（亮度/对比度/饱和度）
    // ======================================================
    col.rgb *= brightness;
    col.rgb = (col.rgb - 0.5) * contrast + 0.5;

    float l = luminance(col.rgb);
    col.rgb = mix(vec3(l), col.rgb, saturation);

    COLOR = col;
}
