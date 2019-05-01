extends Sprite

var poly_data_texture
var maxx = 2048 #максимальна ширина текстуры

#функция сохранет координаты полигонов в текстуру(линейный массив)
func gen_img(polys):
	var img = Image.new()
	var buf = StreamPeerBuffer.new()
	var byte_array = PoolByteArray()
	buf.put_float(polys.size())
	for a in range(polys.size()):
		buf.put_float(polys[a].size())
	var esz = 0
	for poly in polys:
		for point in poly:
			buf.put_float(point[0])
			buf.put_float(point[1])
			esz+=2
	
	var cursz=(1+polys.size()+esz)/4
	var eval=(1+polys.size()+esz)-cursz*4
	for a in range(eval):
		buf.put_float(0)
	if(eval>0):
		cursz+=1
	var tx = min(cursz,maxx)
	var ty = 1+int(cursz/maxx)
	if(ty>1):
		for a in range(4*(maxx-(cursz-int(cursz/maxx)*maxx))):
			buf.put_float(0)
	byte_array.append_array(buf.get_data_array())
	img.create_from_data(tx, ty, false, Image.FORMAT_RGBAF, byte_array)
	return img

func gen_poly_arr():
	poly_data_texture = ImageTexture.new()
	var polys=[]
	var res=get_tree().get_root().size
	var poly_node=get_node("../../poly")
	for a in range(poly_node.get_child_count()):
		var pos=poly_node.get_child(a).position
		var poly=poly_node.get_child(a).polygon
		for b in range(poly.size()):
			poly[b]=(poly[b]+pos)/res.y
		polys.append(poly)
	poly_data_texture.create_from_image(gen_img(polys), 0)
	self.material.set("shader_param/polys_data",poly_data_texture)
	self.material.set("shader_param/maxx",maxx)
	

func _ready():
	gen_poly_arr()

