extends TextureButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _move_image = false

#var _house_image = load("res://house.png")

var _new_building_pack = load("res://NewBuilding.tscn")

var _new_building_scene:Node2D = null

#var _texture_button:TextureButton = null

var _world_node:Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	_texture_button = TextureButton.new()
#	_texture_button.set_normal_texture(_house_image)
#	_texture_button.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
#	self.add_child(_texture_button)
#	self.get_parent().get_parent().get_parent().add_child(_texture_button)
#	_texture_button.set_position(Vector2(5,5))

	
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
#	print(_new_building_scene.get_tree())
#	var area_2D:Area2D = self._new_building_scene.get_node("Area2D")
#	var overlapping_areas:Array = area_2D.get_overlapping_areas()
#	if overlapping_areas.empty():
#		self._new_building_scene.set_modulate(Color(1,0.2,0.2,0.25))
#	else:
#		self._new_building_scene.set_modulate(Color(1,1,1,0.25))
#	todo

func _on_NewHouse_pressed():
	if false ==_move_image:
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
				if false==self._new_building_scene.is_building_blocked():
					
					var house:Node2D = load("res://House.tscn").instance()
					house.set_name("Casa nueva")
					_world_node.call_deferred("add_child", house) #deferred pq _world está ocupado creando sus hijos
					house.add_to_group("houses")					
					var world_coord = _world_node.get_viewport_transform().affine_inverse() * event.position
					house.set_global_position(world_coord)
					
					set_new_building_mode(false)

#func on_NewBuilding_area_entered(area) -> void:
#	print("area entered")
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
		set_new_building_mode(false)
		#	todo. mejor, controlar  esto en NewBuilding.gd