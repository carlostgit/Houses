extends TextureButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#var _move_image = false
#var _mouse_inside =false
#
#var _collision_detector_pack = load("res://CollisionDetector.tscn")
#
#var _collision_detector:Node2D = null

var _world_node:Node = null

signal option_selected(option_node)

# Called when the node enters the scene tree for the first time.
func _ready():
	
#	_collision_detector = _collision_detector_pack.instance()
#	_collision_detector.set_texture(self.get_normal_texture())
	#print(self.get_parent().get_parent().get_parent().get_path())
	_world_node = get_node("/root/World")
##	var world_node = self.get_parent().get_parent().get_parent()
#	_world_node.call_deferred("add_child",_collision_detector)
#	_collision_detector.set_position(Vector2(40,40))
#	_collision_detector.hide()
#	#_collision_detector.connect("area_entered",self,"on_NewBuilding_area_entered")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func _on_NewHouse_pressed():
##	if _move_image:
##		set_new_building_mode(false)
##	else: #false ==_move_image:	
##		set_new_building_mode(true)
#
#	emit_signal("option_selected",self)

#func _input(event):
#	#$Label.set_text(event.as_text())
##	print(event)
#	if(_move_image):
#		if event is InputEventMouseMotion:
##			El nodo _collision_detector pertenece al nodo World, que está en otro CanvasLayer
##			Por estar en otro CanvasLayer, las coordenadas globales de este input no valen
##			Hay que convertir las coordenadas a las coordenadas del otro CanvasLayer
#			var world_coord = _world_node.get_viewport_transform().affine_inverse()*event.position
#
#			var local_coord = _world_node.get_global_transform().affine_inverse()*world_coord
#			self._collision_detector.set_position(local_coord)
##			Se puede hacer lo siguiente en vez de lo anterior:
#			self._collision_detector.set_global_position(world_coord)
#
##			$Label.set_text(String(event.position))
##			$Label2.set_text(String(self.get_viewport_transform().affine_inverse() * event.position))
##			$Label3.set_text(String(self.get_global_transform().affine_inverse()*(self.get_viewport_transform().affine_inverse() * event.position)))
##			$Label4.set_text(String(_world_node.get_viewport_transform().affine_inverse() * event.position))
#
#		elif event is InputEventMouseButton:
#			if event.is_pressed():
#
#				if false == _mouse_inside:					
#					set_new_building_mode(false)
#					if false==self._collision_detector.is_building_blocked():
#
#						var house:Node2D = load("res://House.tscn").instance()
#						#house.set_name("Casa nueva")
#						_world_node.call_deferred("add_child", house) #deferred pq _world está ocupado creando sus hijos
#						house.add_to_group("houses")					
#						var world_coord = _world_node.get_viewport_transform().affine_inverse() * event.position
#						house.set_global_position(world_coord)

func add_object_to_world(world_coord:Vector2) -> void:
	var house:Node2D = load("res://House.tscn").instance()
	#house.set_name("Casa nueva")
	_world_node.call_deferred("add_child", house) #deferred pq _world está ocupado creando sus hijos
	house.add_to_group("houses")					
	#var world_coord = _world_node.get_viewport_transform().affine_inverse() * event.position
	house.set_global_position(world_coord)

#func set_new_building_mode(enabled_arg:bool):
#	if enabled_arg:
#		_move_image = true
#		self._collision_detector.set_modulate(Color(1,1,1,0.25))
#		self._collision_detector.show()
#	else:
#		_move_image = false
#		self._collision_detector.set_modulate(Color(1,1,1,1))
#		self._collision_detector.hide()
#
#func _on_HUD_new_building_option():
#	if _move_image:
#		if false==_mouse_inside:
#			set_new_building_mode(false)
#
#func _on_NewHouse_mouse_entered():
#	_mouse_inside = true
#
#func _on_NewHouse_mouse_exited():
#	_mouse_inside = false
#

func _on_NewHouse_pressed():
	emit_signal("option_selected",self)
