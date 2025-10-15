shader_type spatial;
render_mode unshaded;

uniform sampler2D	frame_texture	: source_color;

void fragment() {
	vec4 tex = texture(frame_texture, UV);	
	ALBEDO = tex.rgb;
	ALPHA  = tex.a;
}