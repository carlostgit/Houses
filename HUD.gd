extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var global_rect:Rect2 = $NavigationPanel.get_global_rect()
	$Construction.add_no_construction_rect(global_rect)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


