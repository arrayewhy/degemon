shader_type canvas_item;

uniform float block_size = 64.0;
uniform float offset_x;

void fragment() {
    vec2 pixel_pos = UV / TEXTURE_PIXEL_SIZE;

    // Clear original source pixels
    COLOR = vec4(0.0);

	// Draw moved pixels into destination
	float curr_block = floor(pixel_pos.x / block_size);
	//vec2 dest_pixel = pixel_pos - vec2(offset_x, 0.0);
    vec2 dest_pixel = pixel_pos - vec2(offset_x * (curr_block + 1.0), 0.0);
	
	vec2 src_uv = dest_pixel * TEXTURE_PIXEL_SIZE;
    COLOR = texture(TEXTURE, src_uv);
	
    //if (dest_pixel.x >= block_size * 0.0 && dest_pixel.x < block_size * 1.0) {
        //vec2 src_uv = dest_pixel * TEXTURE_PIXEL_SIZE;
        //COLOR = texture(TEXTURE, src_uv);
    //}
	//if (dest_pixel.x >= block_size * 1.0 && dest_pixel.x < block_size * 2.0) {
        //vec2 src_uv = dest_pixel * TEXTURE_PIXEL_SIZE;
        //COLOR = texture(TEXTURE, src_uv);
    //}
}