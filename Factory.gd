extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var _salary:float = 3.0
var _worker:Node2D = null

var _name:String = ""

var _world:Node2D = null

signal sig_factory_selected(node)

# Called when the node enters the scene tree for the first time.
func _ready():
	_world = get_node("../../World")
#	pass # Replace with function body.
	if (_name==""):
		_name = get_new_name()

	self.connect("sig_factory_selected", _world, "on_sig_factory_selected")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_new_name():
	
	var new_name = "no name"
	
	var string_name_source:Array = []
	var string_alphabet = "ABCDEFGHIJKLMNÑOPQRSTUWXYZ"
	
	for i in (string_alphabet.length()-1):
		string_name_source.append(string_alphabet.substr(i,1))
	
	if (_world):
		for name_of_list in string_name_source:
			var used_name:bool = false
			for child in _world.get_children():
				if (child.is_in_group("factories")):
					if name_of_list==child.get_name():
						used_name = true
			
				else:
					continue
				if used_name:
					break
				else:
					continue
			if used_name:
				continue
				
			new_name = name_of_list
			break
			
	return new_name	


func set_name(name_arg:String)-> void:
	_name = name_arg

func get_name()-> String:
	return _name

func get_salary() -> float:
	return _salary
	
func set_salary(salary_arg:float) -> void:
	_salary = salary_arg
	
	
func set_worker(worker_arg:Node2D) -> void:
	if worker_arg:
		worker_arg.set_factory(null) #se abandona la anterior fabrica
	_worker = worker_arg
	

func has_worker() -> bool:
	if (null == _worker):
		return false
	else:
		return true


func get_worker() -> Node2D:
	return _worker


func update_labels() -> void:
	var salary:float = self.get_salary()
	var salary_rounded:float = stepify(salary, 0.01)
	$SalaryLabel.set_text(str(salary_rounded)+"$")
	$NameLabel.set_text(_name)

func _on_TimerUpdateLabel_timeout():
	#update_labels()
	pass

func clear_before_removing():
	if _worker:
		_worker.set_factory(null)
	_worker = null

func can_be_demolished():
	return true
	
func next_state(cycle_arg:int) -> void:
	update_labels()
	
	

func _on_FactoryTexture_gui_input(event):
	
	if event is InputEventMouseButton:
		emit_signal("sig_factory_selected",self)
