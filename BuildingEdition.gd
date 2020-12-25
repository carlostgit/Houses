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
	
func show_panel_for_node(selected_node_arg:Node):
	if selected_node_arg.is_in_group("factories"):
		$FactoryEdition.show()
		$FactoryEdition/Name.set_text(selected_node_arg.get_name())
		$FactoryEdition/Salary.set_value(selected_node_arg.get_salary())
		

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
