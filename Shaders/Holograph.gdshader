shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix, world_vertex_coords;

uniform vec3 color = vec3(0.0, 0.3, 1.0);
uniform vec3 cursor = vec3(-1, -1, -1);
uniform float cursor_str = -1;

varying vec3 coords;

void vertex()
{
  coords = VERTEX.xyz;
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

float circle(vec3 position, float radius, float feather)
{
	return smoothstep(radius, radius + feather, length(position - coords));
}

float cursor_draw(vec3 pos, float str)
{
	float inner = 1.4 - str * 0.8;
	float outer = 2.0 - str * 0.8;
	float feather = 0.6;
	float scaler = 0.008;
	return ( circle(pos, inner*scaler, feather*scaler) - circle(pos, outer*scaler, feather*scaler) ) * 0.5;
}

void fragment() {
    ALBEDO = color;
	
	float f = fresnel(3.0, NORMAL, VIEW);
	float e = f * 0.4;
	if ( f > 0.4 ) { e = 1.; }
	float c = cursor_draw(cursor, cursor_str) * 2.;
	if (cursor_str > -0.01) {
		ALPHA = max(e,c);
	} else {
		ALPHA = e;
	}
}

