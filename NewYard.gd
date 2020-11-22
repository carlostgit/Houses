extends TextureButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _move_image = false
var _mouse_inside =false

var _new_building_pack = load("res://NewBuilding.tscn")

var _new_building_scene:Node2D = null

var _world_node:Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	
	_new_building_scene = _new_building_pack.instance()
	_new_building_scene.set_texture(self.get_normal_texture())
	print(self.get_parent().get_parent().get_parent().get_path())
	_world_node = get_node("/root/World")
#	var world_node = self.get_parent().get_parent().get_parent()
	_world_node.call_deferred("add_child",_new_building_scene)
	_new_building_scene.set_position(Vector2(40,40))
	_new_building_scene.hide()
	_new_building_scene.connect("area_entered",self,"on_NewBuilding_area_entered")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_NewYard_pressed():
	if _move_image:
		set_new_building_mode(false)
	else: #false ==_move_image:	
		set_new_building_mode(true)

func _input(event):
	$Label.set_text(event.as_text())
#	print(event)
	if(_move_image):
		if event is InputEventMouseMotion:
#			El nodo _new_building_scene pertenece al nodo World, que está en otro CanvasLayer
#			Por estar en otro CanvasLayer, las coordenadas globales de este input no valen
#			Hay que convertir las coordenadas a las coordenadas del otro CanvasLayer
			var world_coord = _world_node.get_viewport_transform().affine_inverse()*event.position

			var local_coord = _world_node.get_global_transform().affine_inverse()*world_coord
			self._new_building_scene.set_position(local_coord)
#			Se puede hacer lo siguiente en vez de lo anterior:
			self._new_building_scene.set_global_position(world_coord)

#			$Label.set_text(String(event.position))
#			$Label2.set_text(String(self.get_viewport_transform().affine_inverse() * event.position))
#			$Label3.set_text(String(self.get_global_transform().affine_inverse()*(self.get_viewport_transform().affine_inverse() * event.position)))
#			$Label4.set_text(String(_world_node.get_viewport_transform().affine_inverse() * event.position))

		elif event is InputEventMouseButton:
			if event.is_pressed():
				
				if false == _mouse_inside:					
					set_new_building_mode(false)
					if false==self._new_building_scene.is_building_blocked():

						var yard:Node2D = load("res://Yard.tscn").instance()
						yard.set_name("Solar nuevo")
						_world_node.call_deferred("add_child", yard) #deferred pq _world está ocupado creando sus hijos
						yard.add_to_group("yards")					
						var world_coord = _world_node.get_viewport_transform().affine_inverse() * event.position
						yard.set_global_position(world_coord)

func set_new_building_mode(enabled_arg:bool):
	if enabled_arg:
		_move_image = true
		self._new_building_scene.set_modulate(Color(1,1,1,0.25))
		self._new_building_scene.show()
	else:
		_move_image = false
		self._new_building_scene.set_modulate(Color(1,1,1,1))
		self._new_building_scene.hide()

func _on_HUD_new_building_option():
	if _move_image:
		if false==_mouse_inside:
			set_new_building_mode(false)
	
func _on_NewYard_mouse_entered():
	_mouse_inside = true

func _on_NewYard_mouse_exited():
	_mouse_inside = false
	