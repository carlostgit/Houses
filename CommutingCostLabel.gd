extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var value =self.get_parent().get_value()
	var value_rounded:float = stepify(value, 0.01)
	set_text(str(value_rounded)+"$")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CommutingCost_value_changed(value):
	var value_rounded:float = stepify(value, 0.01)
	set_text(str(value_rounded)+"$")
