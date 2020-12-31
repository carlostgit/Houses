extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _selected_node:Node = null

# Called when the node enters the scene tree for the first time.
func _ready():
	
	new_selected_node(null)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func new_selected_node(selected_node_arg:Node) -> void:
		var select_node_old:Node = _selected_node
		if select_node_old:
			select_node_old.set_modulate(Color(1,1,1,1))
		_selected_node = selected_node_arg
		if selected_node_arg:
			selected_node_arg.set_modulate(Color(1,1,0.5,1))
		hide_all_panels()
		if selected_node_arg != null:
			show_panel_for_node(selected_node_arg)			
			
func hide_all_panels():
	$FactoryEdition.hide()
	$YardEdition.hide()
	$HouseEdition.hide()
	
func show_panel_for_node(selected_node_arg:Node):
	if selected_node_arg.is_in_group("factories"):
		$FactoryEdition.show()
		$FactoryEdition/Name.set_text(selected_node_arg.get_name())
		$FactoryEdition/Salary.set_value(selected_node_arg.get_salary())
	elif selected_node_arg.is_in_group("yards"):
		$YardEdition.show()
		$YardEdition/Name.set_text(selected_node_arg.get_name())
		$YardEdition/LandCost.set_value(selected_node_arg.get_land_cost())
	elif selected_node_arg.is_in_group("houses"):
		$HouseEdition.show()
		$HouseEdition/Name.set_text(selected_node_arg.get_name())
		$HouseEdition/MinimumRent.set_value(selected_node_arg.get_minimum_rent())
		

#func _on_HSlider_value_changed(value):
#	var param_value:float = value
#	for node in self.get_children():
#		if node.is_in_group("factories"):
#			node.set_salary(value)



func _on_Salary_value_changed(value):
	var param_value:float = value
	if _selected_node != null:
		if _selected_node.is_in_group("factories"):
			_selected_node.set_salary(value)

func _on_Button_pressed():
	new_selected_node(null)
	



func _on_LandCost_value_changed(value):
	#chequeo que no se haya eliminado el Yard al transformase en casa
	if is_instance_valid(_selected_node):		
		var param_value:float = value
		if _selected_node != null:
			if _selected_node.is_in_group("yards"):
				_selected_node.set_land_cost(value)
	else:
		new_selected_node(null)

func _on_MinimumRent_value_changed(value):
	var param_value:float = value
	if _selected_node != null:
		if _selected_node.is_in_group("houses"):
			_selected_node.set_minimum_rent(value)

func node_deleted(node):
	if _selected_node==node:
		_selected_node = null
		new_selected_node(null)


func _on_MaximumRent_value_changed(value):
	var param_value:float = value
	if _selected_node != null:
		if _selected_node.is_in_group("houses"):
			_selected_node.set_maximum_rent(value)

