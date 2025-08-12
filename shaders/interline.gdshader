shader_type canvas_item;
uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap, repeat_disable;

void vertex() {

}

void fragment() {
	int shitfuck;
	if (int(TIME*60.0) % 2 == 0){
		shitfuck = int(VERTEX.y);
	}else{
		shitfuck = int(VERTEX.y) + 1;
	}
	if (shitfuck % 2 == 0){
		//COLOR = vec4(0.0, 0.0, 0.0, 1.0);
		COLOR = vec4(texture(screen_texture, SCREEN_UV).rgb * 0.1, 1.0) ;
	}else{
		COLOR = vec4(texture(screen_texture, SCREEN_UV).rgb, 1.0);
	}

}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
