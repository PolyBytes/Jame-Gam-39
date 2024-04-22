shader_type canvas_item;

uniform float percentage : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	COLOR = texture(TEXTURE, UV);
	
	if(UV.x > percentage)
	{
		COLOR.a = 0.0;
	}
}