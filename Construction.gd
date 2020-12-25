extends Panel

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _construction_option:Node = null

var _mouse_inside_option:bool = false

var _collision_detector_pack = load("res://CollisionDetector.tscn")
var _collision_detector:Node2D = null

var _world_node:Node = null
var _move_image = false

var _no_construction_rects:Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_collision_detector = _collision_detector_pack.instance()
	#_collision_detector.set_texture(self.get_normal_texture())
	
	_world_node = get_node("/root/World")

	_world_node.call_deferred("add_child",_collision_detector)
	_collision_detector.set_position(Vector2(40,40))
	_collision_detector.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func add_no_construction_rect(no_construction_rect_arg:Rect2):
	_no_construction_rects.append(no_construction_rect_arg)

func convert_screen_coordinates_to_world_local_coord(screen_coordinates:Vector2)->Vector2:
	var world_global_coord = _world_node.get_viewport_transform().affine_inverse()*screen_coordinates
	var local_coord = _world_node.get_global_transform().affine_inverse()*world_global_coord
	return local_coord

func convert_screen_coordinates_to_HUD_global_coord(screen_coordinates:Vector2)->Vector2:
	var world_global_coord = self.get_viewport_transform().affine_inverse()*screen_coordinates
	return world_global_coord

func convert_screen_coordinates_to_HUD_local_coord(screen_coordinates:Vector2)->Vector2:
	var world_global_coord = self.get_viewport_transform().affine_inverse()*screen_coordinates
	var local_coord = self.get_global_transform().affine_inverse()*world_global_coord
	return local_coord

func convert_screen_coordinates_to_world_global_coord(screen_coordinates:Vector2)->Vector2:
	var world_global_coord = _world_node.get_viewport_transform().affine_inverse()*screen_coordinates
	return world_global_coord

func is_screen_pos_in_no_construction_area(screen_position:Vector2)->bool:
	var HUD_global_coord = convert_screen_coordinates_to_HUD_global_coord(screen_position)
	var global_rect = get_global_rect()
	if self.get_global_rect().has_point(HUD_global_coord):
		return true
		
	for rect in _no_construction_rects:
		if rect.has_point(HUD_global_coord):
			return true
	
	return false
	
func _input(event):

	if(null!=_construction_option):
		if event is InputEventMouseMotion:

			
			var world_global_coord = convert_screen_coordinates_to_world_global_coord(event.position)
			self._collision_detector.set_global_position(world_global_coord)

			#var HUD_global_coord = convert_screen_coordinates_to_HUD_global_coord(event.position)
#			var HUD_local_coord = convert_screen_coordinates_to_HUD_local_coord(event.position)
			var mouse_in_construction_options_area:bool = is_screen_pos_in_no_construction_area(event.position)
			var old_modulate = _collision_detector.get_modulate()
			if mouse_in_construction_options_area:
				_collision_detector.hide()
			else:
				_collision_detector.show()

#			var world_2D_self:World2D = self.get_world_2d()
#			var world_2D_world:World2D = _world_node.get_world_2d()
			#Al parecer world_2D_self y world_2D_world son lo mismo
			#Por alguna razón que no entiendo, space_state.intersect_point no detecta colisiones en el CanvasLayer HUD
			#en internet hay otra persona que dice que tiene ese mismo problema
			#Parece que no se detectan colisiones en CanvasLayers distintos del que hay or defecto
			#Debería investigarlo más

		elif event is InputEventMouseButton:
			if event.is_pressed():
				var world_global_coord = convert_screen_coordinates_to_world_global_coord(event.position)
				self._collision_detector.set_global_position(world_global_coord)

				var mouse_in_construction_options_area:bool = is_screen_pos_in_no_construction_area(event.position)
				var old_modulate = _collision_detector.get_modulate()
				if mouse_in_construction_options_area:
					_collision_detector.hide()
				else:
					_collision_detector.show()
					
				#build_in_world_coord(_construction_option, self._collision_detector, world_coord)
				#call_deferred("build_in_world_coord", _construction_option, _collision_detector, world_coord)
#					call_deferred("prueba",world_coord)
				#Añado un retraso en la acción de construccion, porque métodos como set_position no son inmediatos
				yield(get_tree().create_timer(0.05), "timeout")
#					call_deferred("build_in_world_coord", _construction_option, _collision_detector, world_coord)
				build_in_world_coord(_construction_option, self._collision_detector, event.position)
#

#func prueba(world_coord):
#	print ("prueba")

func build_in_world_coord(_construction_option:Node, collision_detector:Node2D, screen_position:Vector2)->void:
	var mouse_in_construction_options_area:bool = is_screen_pos_in_no_construction_area(screen_position)
	var world_coord:Vector2 = _world_node.get_viewport_transform().affine_inverse() * screen_position
	if false==mouse_in_construction_options_area:

		if false==self._collision_detector.is_building_blocked():
			#var scriptName = _construction_option.get_script().get_path().get_file()
			#var world_coord = _world_node.get_viewport_transform().affine_inverse() * event.position
	
			#var world_global_coord = convert_GUI_coordinates_to_world_canvas(event.position)
			#self._collision_detector.set_global_position(world_global_coord)
			if _construction_option.has_method("add_object_to_world"):
				_construction_option.add_object_to_world(world_coord)
		else:
			if _construction_option.has_method("remove_object_from_world"):
				var areas_to_delete = _collision_detector.get_overlapping_areas()
				_construction_option.remove_object_from_world(areas_to_delete)
		

func new_selected_option(construction_option_arg:Node)->void:
	var old_construction_option:Node = _construction_option
	var new_construction_option:Node = construction_option_arg
	if (new_construction_option != old_construction_option):
		if old_construction_option:
			old_construction_option.set_modulate(Color(1,1,1,1))
		_construction_option = new_construction_option
		if new_construction_option:
			new_construction_option.set_modulate(Color(0.5,1,1,1))
			_collision_detector.set_texture(_construction_option.get_normal_texture())
			_collision_detector.show()



func _on_NewHouse_option_selected(option_node):
	new_selected_option(option_node)
	
func _on_NewFactory_option_selected(option_node):
	new_selected_option(option_node)

func _on_NewYard_option_selected(option_node):
	new_selected_option(option_node)

func _on_RemoveBuilding_option_selected(option_node):
	new_selected_option(option_node)

func _on_RemovePerson_option_selected(option_node):
	new_selected_option(option_node)

func _on_Cancel_option_selected(option_node):
	new_selected_option(option_node)
