shader_type canvas_item;

uniform vec2 scroll_speed = vec2(0.1, 0.5);
uniform float rain_intensity : hint_range(0.0, 2.0) = 1.0;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    // 根据时间偏移 UV 坐标来实现滚动效果
    vec2 shifted_uv = UV + TIME * scroll_speed;
    
    // 使用 fract 确保 UV 在 0-1 之间循环，从而实现无缝滚动
    vec4 col = texture(TEXTURE, fract(shifted_uv));
    
    // 应用颜色加成和强度控制
    col *= tint_color;
    col.a *= rain_intensity;
    
    COLOR = col;
}
