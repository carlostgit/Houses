extends TextureButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _move_image = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NewHouse_pressed():
	print("NewHouse_pressed()")
	if false==_move_image:
		_move_image = true
	else:
		_move_image = false
	pass # Replace with function body.

func _input(event):
	$LabelX.set_text(event.as_text())
	print(event)
	if(_move_image):
		if event is InputEventMouseMotion:
			self.set_global_position(event.position)
#	if _move_image:
#		self.set_position(
	
