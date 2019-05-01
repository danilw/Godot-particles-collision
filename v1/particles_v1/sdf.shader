shader_type canvas_item;

//DO NOT USE THIS SHADER IN REAL TIME
//не используйте в реальном времени

uniform sampler2D polys_data; //массив данных полигонов
uniform int maxx; //максимальная ширина текстуры

//количество полигонов
int polys_n(){
	return int(texelFetch(polys_data,ivec2(0,0),0).x);
}

//количество точек в полигоне
int polys_nsz(int idx){
	idx+=1;
	ivec2 pos=ivec2(idx/4,0); // количество полигонов=макс ширина текстуры
	int px=idx-pos.x*4;
	if(px==0)return int(texelFetch(polys_data,pos,0).x);
	if(px==1)return int(texelFetch(polys_data,pos,0).y);
	if(px==2)return int(texelFetch(polys_data,pos,0).z);
	if(px==3)return int(texelFetch(polys_data,pos,0).w);
}

//эмулятор массива(возвращает vec2() точки полигона, Godot не разрешает массивы
vec2 gix(int poly_sx, int idx){
	vec2 ret=vec2(0.);
	int px=(poly_sx+idx*2)/4;
	ivec2 pos=ivec2(px-(px/maxx)*maxx,(px/maxx));
	px=(poly_sx+idx*2)-px*4; //Godot не поддерживает взятие данных из vec4 по индексу
	if(px==0)ret.x=texelFetch(polys_data,pos,0).x;
	if(px==1)ret.x=texelFetch(polys_data,pos,0).y;
	if(px==2)ret.x=texelFetch(polys_data,pos,0).z;
	if(px==3)ret.x=texelFetch(polys_data,pos,0).w;
	poly_sx+=1; //Godot не поддерживает индекс для присваивания ret[i]
	px=(poly_sx+idx*2)/4;
	pos=ivec2(px-(px/maxx)*maxx,(px/maxx));
	px=(poly_sx+idx*2)-px*4;
	if(px==0)ret.y=texelFetch(polys_data,pos,0).x;
	if(px==1)ret.y=texelFetch(polys_data,pos,0).y;
	if(px==2)ret.y=texelFetch(polys_data,pos,0).z;
	if(px==3)ret.y=texelFetch(polys_data,pos,0).w;
	return ret;
}

//в Godot нет функции bvec3 not(bvec3(...))
bvec3 notbv(bvec3 b){
	return bvec3(!b.x,!b.y,!b.z);
}

//http://www.iquilezles.org/www/articles/distfunctions2d/distfunctions2d.htm

float dot2( in vec2 v ) { return dot(v,v); }
float cross2d( in vec2 v0, in vec2 v1) { return v0.x*v1.y - v0.y*v1.x; }

float sdPoly(in vec2 p , int poly_sz, in int poly_sx)
{
	p.y=1.-p.y;
	float d = dot(p-gix(poly_sx,0),p-gix(poly_sx,0));
	float s = 1.0;
	int j=poly_sz-1;
	for( int i=0; i<poly_sz; i++ ){
		// distance
		vec2 e = gix(poly_sx,j) - gix(poly_sx,i);
		vec2 w =    p - gix(poly_sx,i);
		vec2 b = w - e*clamp( dot(w,e)/dot(e,e), 0.0, 1.0 );
		d = min( d, dot(b,b) );
		// winding number from http://geomalgorithms.com/a03-_inclusion.html
		bvec3 cond = bvec3( p.y>=gix(poly_sx,i).y, p.y<gix(poly_sx,j).y, e.x*w.y>e.y*w.x );
		if( all(cond) || all(notbv(cond)) ) s*=-1.0;  
		j=i;
    }
    
    return s*sqrt(d);
}

float map(vec2 p){
    float d = 1.;
	int polys=polys_n(); //количество полигонов
	int poly_sx=1+polys; //сдвиг в линейном массиве
    for(int i=0;i<polys;i++){
		int poly_sz=polys_nsz(i); //количество точек в текущем полигоне
		d=min(d,sdPoly(p,poly_sz,poly_sx));
		poly_sx+=2*poly_sz; //перевод линейного массива
	}
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord, in vec2 iResolution){
    vec2 uv = fragCoord/iResolution.y;
	float d=map(uv);
	//могу ошибаться, в Godot только 0-1 в значении фреймбуфера(viewport) (нет возможность выбрать GL_RGBA32F)
	//поэтому положительно сохранено в одном канале, отрицательное в другом
    vec4 col = vec4(d>0.?vec2(d,0.):vec2(0.,-d),0.,1.);
    fragColor = vec4(col);
}

void fragment(){
	vec2 iResolution=1./TEXTURE_PIXEL_SIZE;
	mainImage(COLOR,UV*iResolution,iResolution);
}
