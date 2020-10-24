extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _land_cost:float = 1.1

var _world:Node2D = null

var _estimated_payable_rent:float = 0.0

#var _house:Node2D = null
var _house:Node2D = preload("res://House.tscn").instance()

# Called when the node enters the scene tree for the first time.
func _ready():
	_world = get_node("../../World")
	_house.set_position(self.get_position())

#	_house.add_to_group("houses")
	_house.hide()
	_house.set_name("Casa tomasa")
	_world.call_deferred("add_child", _house) #deferred pq _world está ocupado creando sus hijos

func get_estimated_payable_rent() -> float:
	return _estimated_payable_rent

func set_estimated_payable_rent(estimated_payable_rent_arg:float) -> void:
	_estimated_payable_rent = estimated_payable_rent_arg


func get_house() -> Node2D:
	return self._house	

#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func calculate_min_rent() -> float:
	var other_costs:float = 0.0
	var total_cost:float = get_land_cost() + other_costs
	return total_cost

func get_land_cost() -> float:
	return _land_cost

func update_labels() -> void:
	var min_rent:float = self.calculate_min_rent()
	var min_rent_rounded:float = stepify(min_rent, 0.01)
	$MinRentLabel.set_text(str(min_rent_rounded)+"$")

	var land_cost:float = self.get_land_cost()
	var land_cost_rounded:float = stepify(land_cost, 0.01)
	$LandCostLabel.set_text(str(land_cost_rounded)+"$")

	var expected_rent:float = self.get_estimated_payable_rent()
	var expected_rent_rounded:float = stepify(expected_rent, 0.01)
	$ExpectedRentLabel.set_text(str(expected_rent_rounded)+"$")


func calculate_estimated_payable_rent() -> float:
#	assert(false) #tengo pendiente debugear este metodo
	#solo cuando todavía se tiene inquilino
	var estimated_payable_rent:float = 0.0
	
	var max_count:int = 1000
	var count:int = 0
	var best_house:Node2D = self.get_house()
	while best_house == self.get_house():
#		Tengo que cambiar esto:
#		self.get_house().set_rent(estimated_payable_rent)
		self.set_estimated_payable_rent(estimated_payable_rent)
#		En vez de set_rent, debería usar _estimated_payable_rent
#		Y cambiar _world.find_best_house_factory_available_with_prospective_house
#		para que lo use 
		for asking_worker in _world.get_workers():
			var asking_worker_factory:Node2D = asking_worker.get_factory()
			var best_house_factory:Dictionary  = _world.find_best_house_factory_available_with_prospective_house(asking_worker_factory, asking_worker, self)
			best_house = best_house_factory.get("house") as Node2D
			if best_house and best_house == self.get_house():
				break

		if best_house == self.get_house():
			estimated_payable_rent += 0.1

		count += 1
		if count > max_count:
			break

	return estimated_payable_rent

func adjust_estimated_payable_rent() -> float:
#	assert(false) #tengo pendiente debugear este metodo
	#solo cuando todavía se tiene inquilino
	var estimated_payable_rent:float = self.get_estimated_payable_rent()
	
	var max_count:int = 10
	var count:int = 0
	var best_house:Node2D = self.get_house()
#	while best_house == self.get_house():
	var num_increasing_steps:int = 0
	var num_decreasing_steps:int = 0
	while count < max_count:
#		Tengo que cambiar esto:
#		self.get_house().set_rent(estimated_payable_rent)
		self.set_estimated_payable_rent(estimated_payable_rent)
#		En vez de set_rent, debería usar _estimated_payable_rent
#		Y cambiar _world.find_best_house_factory_available_with_prospective_house
#		para que lo use 
		for asking_worker in _world.get_workers():
			var asking_worker_factory:Node2D = asking_worker.get_factory()
			var best_house_factory:Dictionary  = _world.find_best_house_factory_available_with_prospective_house(asking_worker_factory, asking_worker, self)
			best_house = best_house_factory.get("house") as Node2D
			if best_house and best_house == self.get_house():
				break

		if best_house == self.get_house():
			estimated_payable_rent += 0.1
			num_increasing_steps += 1
		else:
			estimated_payable_rent -= 0.1
			num_decreasing_steps += 1

		count += 1		
		
		if (num_increasing_steps>1 and num_decreasing_steps>=1):
			break
		if (num_increasing_steps>=1 and num_decreasing_steps>1):
			break 


	return estimated_payable_rent


func build_house() -> void:
	self._house.add_to_group("houses")
	self._house.show()
	self.queue_free()

func _on_TimerUpdateLabel_timeout():
#	self.calculate_estimated_payable_rent()
	self.adjust_estimated_payable_rent()
	update_labels()

func _on_YardTexture_pressed():
	build_house()
