shader_type spatial;
render_mode unshaded, world_vertex_coords;

uniform bool rainbow = true;

uniform sampler2D	frame_texture	: source_color;

varying vec3 coords;
void vertex() {  coords = VERTEX.xyz; }
#include "res://Shaders/HSV.gdshaderinc"
#include "res://Shaders/Remap.gdshaderinc"


void fragment() {
	vec4 tex = texture(frame_texture, UV);
	if (rainbow) {
		vec3 hsv = rgb2hsv(tex.rgb);
		vec3 image = tex.rgb;
		
		float liner = coords.x + coords.y + coords.z;
		vec3 rgbImage = hsv2rgb(vec3( mod(liner / 1.9 - TIME/6., 1.), mix(hsv.y, 1., 0.85), hsv.z));
		
		ALBEDO = mix( tex.rgb, rgbImage, clamp(remap( 0, .1, 1, 0, hsv.x ), 0, 1) );
	} else {
		ALBEDO = tex.rgb;
	}
	ALPHA  = tex.a;
}