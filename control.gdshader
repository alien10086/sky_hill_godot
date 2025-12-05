shader_type canvas_item;

//
// === Main Switches ===
//
uniform bool USE_PIXELATE = true;
uniform bool USE_OUTLINE  = false;
uniform bool USE_QUANTIZE = false;
uniform bool USE_CRT      = false;

//
// === Pixelation ===
//
uniform float pixel_size : hint_range(1.0, 64.0) = 6.0;

//
// === Outline ===
//
uniform float outline_thickness : hint_range(0.5, 4.0) = 1.0;
uniform vec4 outline_color : source_color = vec4(0,0,0,1);

//
// === Color Quantize ===
//
uniform int color_steps : hint_range(2, 64) = 8;

//
// === CRT Effect ===
//
uniform float scanline_strength : hint_range(0.0, 1.0) = 0.6;
uniform float distortion_strength : hint_range(0.0, 0.4) = 0.1;
uniform float crt_brightness = 1.2;

vec3 rgb_quantize(vec3 c, int steps) {
    return floor(c * float(steps)) / float(steps);
}

vec2 barrel_distortion(vec2 uv, float strength) {
    vec2 cc = uv - 0.5;
    float dist = dot(cc, cc);
    return uv + cc * dist * strength;
}

void fragment() {
    vec2 uv = UV;
    vec4 col;

    // ========================
    //  1. Pixelation
    // ========================
    //vec2 tex_size = textureSize(TEXTURE, 0);
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
    if (USE_PIXELATE) {
        uv = floor(uv * tex_size / pixel_size) * pixel_size / tex_size;
    }

    col = texture(TEXTURE, uv);

    // ========================
    //  2. Outline (edge detect)
    // ========================
    if (USE_OUTLINE) {
        float px = outline_thickness / tex_size.x;
        float py = outline_thickness / tex_size.y;

        // Sobel edge detect
        vec4 s00 = texture(TEXTURE, uv + vec2(-px, -py));
        vec4 s01 = texture(TEXTURE, uv + vec2( 0.0, -py));
        vec4 s02 = texture(TEXTURE, uv + vec2( px, -py));
        vec4 s10 = texture(TEXTURE, uv + vec2(-px,  0.0));
        vec4 s12 = texture(TEXTURE, uv + vec2( px,  0.0));
        vec4 s20 = texture(TEXTURE, uv + vec2(-px,  py));
        vec4 s21 = texture(TEXTURE, uv + vec2( 0.0,  py));
        vec4 s22 = texture(TEXTURE, uv + vec2( px,  py));

        float edge =
            length(s02.rgb - s00.rgb) +
            length(s12.rgb - s10.rgb) +
            length(s21.rgb - s01.rgb) +
            length(s22.rgb - s20.rgb);

        if (edge > 0.4) {   // threshold
            col = outline_color;
        }
    }

    // ========================
    //  3. Color Quantization
    // ========================
    if (USE_QUANTIZE) {
        col.rgb = rgb_quantize(col.rgb, color_steps);
    }

    // ========================
    //  4. CRT Effect
    // ========================
    //if (USE_CRT) {
        //// slight barrel distortion
        //vec2 crt_uv = barrel_distortion(UV, distortion_strength);
        //col = texture(TEXTURE, crt_uv) * crt_brightness;
//
        //// scanlines
        //float scan = sin(UV.y * 1200.0) * scanline_strength;
        //col.rgb -= scan * 0.1;
    //}
	if (USE_CRT) {
    // 1. CRT 曲面扭曲影响 UV
    vec2 crt_uv = barrel_distortion(UV, distortion_strength);

    // 2. 再对已经处理过的 col 做扫描线 / 亮度处理（不重新采样纹理）
    float scan = sin(crt_uv.y * 1200.0) * scanline_strength;
    col.rgb *= crt_brightness;
    col.rgb -= scan * 0.1;
	}

    COLOR = col;
}
