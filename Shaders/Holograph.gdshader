shader_type spatial;
render_mode unshaded, cull_disabled, blend_mix;

uniform vec3 color = vec3(0.0, 0.3, 1.0);

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}

void fragment() {
    ALBEDO = color;
	
	float f = fresnel(3.0, NORMAL, VIEW);
	float e = f * 0.4;
	if ( f > 0.4 ) { e = 1.; }
    ALPHA = e;
}

