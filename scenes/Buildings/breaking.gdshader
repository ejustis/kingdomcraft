shader_type canvas_item;

uniform float health_percent;
uniform int min_pixels = 0;
uniform int max_pixels = 400;

void fragment()
{	
	float pixel_amount = clamp(300.0 * health_percent, float(min_pixels), float(max_pixels));
	
	vec2 grid_uv = round(UV * float(pixel_amount)) / float(pixel_amount);
	
	vec4 text = texture(TEXTURE, grid_uv);
	
	COLOR = text;
}
