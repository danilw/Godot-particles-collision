shader_type canvas_item;

uniform sampler2D texture_map;

float map(vec2 p){
	float ret=texture(texture_map,p).x;
	return ret;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution )
{
	vec2 uv = fragCoord/iResolution.xy;
	float d=map(uv);
	fragColor = vec4(vec3(d),1.0);
	fragColor = vec4(vec3(map(uv)),1.0);
}

void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution,iResolution);
}