shader_type spatial;
render_mode unshaded, alpha_to_coverage;

uniform sampler2D	image_texture : source_color;
uniform vec2		size;

#include "res://Shaders/Border.gdshaderinc"
#include "res://Shaders/ScaleUV.gdshaderinc"

void fragment() {
	vec2 uv = scaleUV(UV, size, false);
	vec4 tex = texture(image_texture, uv);
	
	ALBEDO = mix( vec3(0.03), tex.rgb, tex.a );
	ADD_BEVEL(size, 0.2);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
