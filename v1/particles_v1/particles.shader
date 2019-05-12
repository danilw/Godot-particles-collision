shader_type particles;

uniform vec2 resolution;
uniform sampler2D sdf_map;
uniform vec2 grav; //скорость падения(гравитация или ветер если x,y), реальное число пикселей за фрейм равно grav*DELTA
uniform int particle_size; //размер частицы

float rand(vec2 co){
	return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

//sdf
float map(vec2 p){
	vec2 ret=textureLod(sdf_map,p,0.).xy;
	return ret.x-ret.y;
	}

//нормали
vec2 normal (vec2 p){
	float eps=2.0/resolution.y; //2x2
	float dx=(map(p+vec2(eps,0.0))-map(p-vec2(eps,0.0)));
	float dy=(map(p+vec2(0.0,eps))-map(p-vec2(0.0,eps)));
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
	float sdf=map(uv); //sdf для положения
	vec2 norm=normal(uv); //normal для положения
	vec2 speed=VELOCITY.xy; //текущаа скорость
	speed*=0.99;
	vec2 ads = norm*max(size_obj-sdf,0.)*max_speed*(1000./float(particle_size)); //вектор движения
	speed+=ads;
	if(speed.y<0.){
		//при касании
		speed+=grav*1.; //если надо частици при касании высоко подпрыгивали, ставьте множитель меньше еденицы
        speed.y*=0.15; //если надо частици при касании подпрыгивали, удалите эту строку
		}
	else{
		speed+=grav;
	}
	//if ((length(speed) <= length(grav)) && (sdf <= size_obj))
    //    speed = vec2(0); //остановка когда скорость меньше гравитации(когда лежит на плоской поверхности)
	if(length(speed)>max_speed)
		speed=normalize(speed/(1./max_speed))*max_speed; //уменьшение до максимальной скорости, если не нужно то убрать
	VELOCITY.xy=speed; //перемещение 
	COLOR=vec4(1.);
}
