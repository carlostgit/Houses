extends TextureButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _move_image = false

var _house_image = load("res://house.png")

var _new_building_pack = load("res://NewBuilding.tscn")

var _new_building_scene:Node2D = null

var _texture_button:TextureButton = null

var _world_node:Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	_texture_button = TextureButton.new()
	_texture_button.set_normal_texture(_house_image)
	_texture_button.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	self.add_child(_texture_button)
#	self.get_parent().get_parent().get_parent().add_child(_texture_button)
	_texture_button.set_position(Vector2(5,5))

	
	_new_building_scene = _new_building_pack.instance()
	print(self.get_parent().get_parent().get_parent().get_path())
	_world_node = get_node("/root/World")
#	var world_node = self.get_parent().get_parent().get_parent()
	_world_node.call_deferred("add_child",_new_building_scene)
	_new_building_scene.set_position(Vector2(40,40))
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
	build_if_possible()

func build_if_possible():
	if false==_move_image:
		_move_image = true
		self._texture_button.set_modulate(Color(1,1,1,0.25))
		self._new_building_scene.set_modulate(Color(1,1,1,0.25))
	else:
		_move_image = false
		self._texture_button.set_modulate(Color(1,1,1,1))
		self._new_building_scene.set_modulate(Color(1,1,1,1))

func _input(event):
	$Label.set_text(event.as_text())
#	print(event)
	if(_move_image):
		if event is InputEventMouseMotion:
#			self.set_global_position(event.position)
			self._texture_button.set_global_position(event.position)
			
#			self._new_building_scene.set_global_position(event.position)
#			var screen_coord = get_viewport_transform() * (get_global_transform() * event.position)
#			var world_coord = _world_node.get_global_transform().affine_inverse()*(_world_node.get_viewport_transform().affine_inverse().xform(event.position))
#			var world_coord = (_world_node.get_viewport_transform().affine_inverse().xform(event.position))
			var world_coord = _world_node.get_viewport_transform().affine_inverse() * event.position
			
#			var coord_1=_world_node.get_viewport_transform()*world_coord
#			var coord_2=_world_node.get_global_transform()*world_coord
#			var coord_3=_world_node.get_canvas_transform()*world_coord

#			self._new_building_scene.set_global_position(world_coord)
			var local_coord = _world_node.get_global_transform().affine_inverse()*world_coord
			self._new_building_scene.set_position(local_coord)
#			self._new_building_scene.set_position(local_coord)
		elif event is InputEventMouseButton:
			if event.is_pressed():
				if false==self._new_building_scene.is_building_blocked():
					print("build todo")
			
			
			

func on_NewBuilding_area_entered(area) -> void:
	print("area entered")