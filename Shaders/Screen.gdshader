shader_type spatial;
render_mode unshaded;

uniform sampler2D	settings_tex : source_color;
uniform sampler2D	video_tex : source_color;
uniform vec2		size;
uniform float		settings;

uniform vec2		cursor;
uniform vec3		cursor_color;
uniform float		cursor_str;

vec2 scaleUV(vec2 iUV) {
	vec2 uv = iUV * size;
	// Get the minimum value between size.x and size.y
	float min_size = max(size.x, size.y);
	// Scale both dimensions so that the minimum will be 1.0
	if (min_size > 0.0) {
		uv /= min_size;
	}
	// Center the UV coordinates
	uv += (1.0 - (size / min_size)) / 2.0;
	// uv = clamp(uv, 0, 1);

	return uv;
}

float circle(vec2 position, float radius, float feather)
{
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}

float cursor_draw(vec2 iUV, vec2 pos)
{
	float inner = 1.5 - cursor_str * 0.8;
	float outer = 2.0 - cursor_str * 0.8;
	float feather = 0.5;
	float scaler = 0.005;
	return ( circle(iUV, inner*scaler, feather*scaler) - circle(iUV, outer*scaler, feather*scaler) ) * 0.5;
}

void fragment() {
	vec2 uv = scaleUV(UV);

	vec4 tex;
	if (settings > 0.001) {
		vec4 s = texture(settings_tex,	UV);
		vec4 v = texture(video_tex, 	UV);

		tex = mix(s * ( 1. - settings/4. ),  v,  1. - s.a);
	} else {
		tex = texture(video_tex, 	UV);
	}

	if (cursor_str > -0.01) {
		uv += cursor;
		tex.rgb = mix( tex.rgb, cursor_color, cursor_draw(uv, cursor) );
	}

	ALBEDO = tex.rgb;
	//float test = cursor_draw(uv, cursor);
	//ALBEDO = vec3(test, test, test);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
