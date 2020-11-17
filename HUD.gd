extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal new_building_option

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NewYard_pressed():
	emit_signal("new_building_option")
	#	todo. mejor, controlar  esto en NewBuilding.gd
#	pass # Replace with function body.


func _on_NewHouse_pressed():
	emit_signal("new_building_option")
#	todo. mejor, controlar  esto en NewBuilding.gd
#	pass # Replace with function body.
