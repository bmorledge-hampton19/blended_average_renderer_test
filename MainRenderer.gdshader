shader_type canvas_item;

render_mode blend_premul_alpha;

// Back-buffer copy for canvas group
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// Premult alpha channel to overlay
uniform sampler2D premultAlphaMap;

void fragment() {
	
		
	// Necessary for rendering CanvasGroup
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}
	COLOR *= c;

	// Set alpha using premult alpha map
	COLOR.a = texture(premultAlphaMap, SCREEN_UV).a;
}