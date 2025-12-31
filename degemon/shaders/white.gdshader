shader_type canvas_item;
varying vec4 modulate;

void vertex() {
	modulate = COLOR;
}

void fragment() {
	COLOR = vec4(1.0, 1.0, 1.0, 1.0) * modulate;
}