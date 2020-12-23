extends TextureButton

# Declare member variables here. Examples:
# var a = 2
# var b = "text"



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NewWorker_pressed():
	
	var worker:Node2D = load("res://Worker.tscn").instance()
	worker.set_name("Currante novato")
	var world_node = get_node("/root/World")
	world_node.call_deferred("add_child", worker) #deferred pq _world está ocupado creando sus hijos
	worker.add_to_group("workers")					
	#var world_coord = _world_node.get_viewport_transform().affine_inverse() * event.position
	#factory.set_global_position(world_coord)

