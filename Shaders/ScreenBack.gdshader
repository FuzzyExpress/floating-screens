shader_type spatial;
render_mode unshaded;

uniform sampler2D	image_texture : source_color;
uniform vec2		size;

vec2 scaleUV(vec2 iUV) {
	vec2 uv = iUV * size;
	// Get the minimum value between size.x and size.y
	float min_size = min(size.x, size.y);
	// Scale both dimensions so that the minimum will be 1.0
	if (min_size > 0.0) {
		uv /= min_size;
	}
	// Center the UV coordinates
	uv += (1.0 - (size / min_size)) / 2.0;
	uv = clamp(uv, 0, 1);
	
	return uv;
}

void fragment() {
	vec2 uv = scaleUV(UV);
	vec4 tex = texture(image_texture, uv);
	
	ALBEDO = tex.rgb;
	ALPHA  = tex.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
