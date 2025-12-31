shader_type canvas_item;

uniform float speed : hint_range(0.0, 10.0) = 1.0;
uniform float force_white = 0.0;
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
    float alpha = step(0.5, fract(TIME * speed)) + force_white; // 0 or 1
    COLOR = texture(TEXTURE, UV) * modulate * alpha;
}
