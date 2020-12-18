extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var _salary:float = 3.0
var _worker:Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
	
	