shader_type spatial;
render_mode unshaded, alpha_to_coverage;

uniform sampler2D	settings_tex : source_color;
uniform sampler2D	video_tex : source_color;
uniform float		settings;
uniform vec2		size;
uniform float		scale = 0.2;

uniform vec2		cursor1;
uniform vec3		cursor_color1 : source_color;
uniform float		cursor_str1;

uniform vec2		cursor2;
uniform vec3		cursor_color2 : source_color;
uniform float		cursor_str2;

#include "res://Shaders/Border.gdshaderinc"
#include "res://Shaders/ScaleUV.gdshaderinc"


float circle(vec2 position, float radius, float feather)
{
	return smoothstep(radius, radius + feather, length(position - vec2(0.5)));
}

float cursor_draw(vec2 iUV, float str)
{
	float inner = 1.5 - str * 0.8;
	float outer = 2.0 - str * 0.8;
	float feather = 0.5;
	float scaler = 0.005;
	return ( circle(iUV, inner*scaler, feather*scaler) - circle(iUV, outer*scaler, feather*scaler) ) * 0.5;
}

void fragment() {
	vec2 uv = scaleUV(UV, size, true);

	vec4 tex;
	if (settings > 0.001) {
		vec4 s = texture(settings_tex,	UV);
		vec4 v = texture(video_tex, 	UV);

		tex = mix(s * ( 1. - settings/4. ),  v,  1. - s.a);
	} else {
		tex = texture(video_tex, 	UV);
	}

	
	if (cursor_str1 > -0.01) {
		vec2 uv1 = uv + cursor1;
		tex.rgb = mix( tex.rgb, cursor_color1, cursor_draw(uv1, cursor_str1) );
	}
	if (cursor_str2 > -0.01) {
		vec2 uv2 = uv + cursor2;
		tex.rgb = mix( tex.rgb, cursor_color2, cursor_draw(uv2, cursor_str2) );
	}

	ALBEDO = tex.rgb;
	ADD_BEVEL(size, 0.2);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
