shader_type particles;

uniform vec2 resolution;
uniform sampler2D texture_map;
uniform vec2 grav; //скорость падения(гравитация или ветер если x,y), реальное число пикселей за фрейм равно grav*DELTA
uniform int particle_size; //размер частицы
uniform bool jumpx; //прыгать или прилипать к поверхностям

float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

//sdf
float map(vec2 p){
	float ret=texture(texture_map,p).x;
	return 1.-ret;
}

//нормали
vec2 normal (vec2 p){
	float eps=1.0/resolution.y; //1x1
    float a=map(p+vec2(eps,0.0));
    float b=map(p-vec2(eps,0.0));
    float c=map(p+vec2(0.0,eps));
    float d=map(p-vec2(0.0,eps));
    if(vec4(a,b,c,d)==vec4(1.))return vec2(0.);
    if(vec4(a,b,c,d)==vec4(0.))return vec2(-10.);
	float dx=(a-b);
	float dy=(c-d);
	vec2 ret= normalize(vec2(dx,dy));
	return ret;
}

void vertex(){
	float size_obj=float(particle_size)/resolution.y;
	if(RESTART){
		TRANSFORM[3].xyz=vec3(resolution.x*rand(vec2(TIME,float(INDEX))),-10.,0.); //случайная позиция
		TRANSFORM[0].x=TRANSFORM[1].y=TRANSFORM[2].z=TRANSFORM[3].w=float(particle_size); //размер
	}
	float max_speed=(resolution.y/LIFETIME); //скорость при которой экран будет пройден по высоте за время анимации
	max_speed*=2.; //в 2 раза большее расстояние для учета падений по диагонали и замедлении при коллизии
	vec2 uv=(TRANSFORM[3].xy)/resolution.xy; //положение частицы на экране
	vec2 speed=VELOCITY.xy; //текущаа скорость
	speed*=0.99;
	if(!jumpx)speed*=map(uv+(speed/resolution)*DELTA);
	vec2 fads=speed;
	vec2 l=vec2(0.);
	bool fx=false;
	
	//лучшая нормаль из 2x2 квадрата
	for(float i=-2.;i<=2.;i++){
		for(float j=-2.;j<=2.;j++){
			vec2 nl=normal(uv+vec2(i/resolution.x,j/resolution.y));
			if(nl.x==-10.){fx=true;continue;}
			if(length(nl)>length(l))l=nl;
		}
	}
	float eads=0.;
	if(length(l)<=0.1){
		if((jumpx)&&(fx))eads=-max_speed*1.; //чтоб не проваливались
		fads+=grav;
		if(!jumpx)speed+=grav*map(uv+(speed/resolution)*DELTA);
	}
	else{
		if(jumpx){
			if(clamp(-fads.y,0.,1.)<=.5)fads.y=max_speed*0.1; //не застревали и отпрыгивали
			fads=reflect(vec3(fads,0.),vec3(l,0.)).xy*max_speed*0.1;
		}
	}
	if(jumpx)speed=fads;
	if(length(speed)>max_speed)
		speed=normalize(speed/(1./max_speed))*max_speed;
	speed.y+=eads;
	VELOCITY.xy=speed; //перемещение 
	if(speed==vec2(0.))
	COLOR=vec4(1.,0.0,0.0,1.);
	else
	COLOR=vec4(0.,0.85,0.5,1.);
}