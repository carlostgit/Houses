extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal area_entered(area)

var _building_blocked:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var area_2D:Area2D = self.get_node("Area2D")
	var overlapping_areas:Array = area_2D.get_overlapping_areas()
	if overlapping_areas.empty():
		self._building_blocked = false
		self.set_modulate(Color(0.2,1,0.2,0.25))
	else:
		self._building_blocked = true
		self.set_modulate(Color(1,0.2,0.2,0.25))


func is_building_blocked() -> bool:
	return _building_blocked
	
func set_texture(texture_arg:Texture):
	$Sprite.set_texture(texture_arg)


func _on_Area2D_area_entered(area):
#	print("area entered in new b")
	emit_signal("area_entered",area)
	