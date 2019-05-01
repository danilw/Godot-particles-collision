shader_type canvas_item;

uniform sampler2D sdf_map;

float map(vec2 p){
	vec2 ret=texture(sdf_map,p).xy;
	return ret.x-ret.y;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution )
{
	vec2 uv = fragCoord/iResolution.xy;
	float d=map(uv);
	vec3 col = vec3(1.0) - sign(d)*vec3(0.1,0.4,0.7);
	col *= 1.0 - exp(-4.0*abs(d));
	col *= 0.8 + 0.2*cos(200.0*d);
	col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.005,abs(d)) );
	//col=vec3(d);
	fragColor = vec4(col,1.0);
}

void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution,iResolution);
}