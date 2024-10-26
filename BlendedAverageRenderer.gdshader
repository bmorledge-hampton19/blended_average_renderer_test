shader_type canvas_item;

// Additive blending will result in average after properly weighting each object.
render_mode blend_add;

// Keeps track of how many objects will be rendered at a given pixel
uniform sampler2D densityMap;

// Used to convert density map to proportion of rendered color
uniform float maxRenderedObjects;

void fragment() {
	// Weight color based on density map and alpha value
	float proportion = texture(densityMap, SCREEN_UV).r*maxRenderedObjects;
	COLOR.rgb = COLOR.rgb/proportion*COLOR.a;
	
	// Force full alpha.
	// (Alpha values will be set using the premult alpha map in the main renderer)
	COLOR.a = 1.0;
}
