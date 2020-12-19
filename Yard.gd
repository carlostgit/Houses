extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _land_cost:float = 2.0

var _world:Node2D = null

var _estimated_payable_rent:float = 0.0

var _last_estimated_payable_rents:Array

#var _house:Node2D = null
var _house:Node2D = preload("res://House.tscn").instance()

var _name:String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	_world = get_node("../../World")
	_house.set_position(self.get_position())

#	_house.add_to_group("houses")

	_name = get_new_name()

	_house.hide()
	_house.set_name(_name)	
	_world.call_deferred("add_child", _house) #deferred pq _world está ocupado creando sus hijos

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
				if (child.is_in_group("houses")):
					if name_of_list==child.get_name():
						used_name = true
				elif(child.is_in_group("yards")):
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


func get_name():
	return _name

func get_recent_average_estimated_payable_rent() -> float:
#	sum last rents
	var copy_last_estimated:Array = _last_estimated_payable_rents.duplicate()
	copy_last_estimated.invert()
	
	var max_num_of_rents:int = 5
	var num_of_rents_to_check:int = min(max_num_of_rents,_last_estimated_payable_rents.size())
	var sum_of_last_rents:int = 0
	for i in range(num_of_rents_to_check):
		var rent:float = copy_last_estimated.pop_front()
		sum_of_last_rents += copy_last_estimated[i]
	
	var average_rent:float = sum_of_last_rents/num_of_rents_to_check
	
	return average_rent

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

func get_min_rent() -> float:
	var other_costs:float = 0.0
	var total_cost:float = get_land_cost() + other_costs
	return total_cost

func get_land_cost() -> float:
	return _land_cost

func update_labels() -> void:
	var min_rent:float = self.get_min_rent()
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

	#print ("Yard count: " + str(count))
	
	return estimated_payable_rent

func adjust_estimated_payable_rent() -> float:
#	assert(false) #tengo pendiente debugear este metodo
	#solo cuando todavía se tiene inquilino
	var estimated_payable_rent:float = self.get_estimated_payable_rent()
	
	var max_count:int = 3
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
	
	#print ("Yard count: " + str(count))
	return estimated_payable_rent

func build_house() -> void:
	self._house.add_to_group("houses")
	self._house.show()
	self.queue_free()

func _on_TimerUpdateLabel_timeout():
#	update_labels()
	pass
	
func _on_YardTexture_pressed():
#	build_house()
	pass
	
func _on_TimerBuildHouse_timeout():
	#	self.calculate_estimated_payable_rent()
#
#	var start = OS.get_ticks_usec()
#	self.adjust_estimated_payable_rent()
#	var end = OS.get_ticks_usec()
#	var adjust_estimated_payable_rent_time = (end-start)/1000000.0
#	print("adjust_estimated_payable_rent_time: "+str(adjust_estimated_payable_rent_time))
#
#	_last_estimated_payable_rents.push_back(self.get_estimated_payable_rent())
#
#
#	var min_profit:float = 1.0
#
#	if (self.get_estimated_payable_rent() > min_profit + self.get_min_rent()):
#		if (self.get_estimated_payable_rent() > min_profit + get_recent_average_estimated_payable_rent()):
#			build_house()
	pass
	
func set_land_cost(land_cost_arg:float):
	self._land_cost = land_cost_arg

func set_name(name_arg:String) -> void:
	_name = name_arg
	
func clear_before_removing():
	pass
	
func can_be_demolished():
	return true
	
func next_state(cycle_arg:int) -> void:
	
	self.adjust_estimated_payable_rent()
	_last_estimated_payable_rents.push_back(self.get_estimated_payable_rent())
	var min_profit:float = 1.0
	if (self.get_estimated_payable_rent() > min_profit + self.get_min_rent()):
		if (self.get_estimated_payable_rent() > min_profit + get_recent_average_estimated_payable_rent()):
			build_house()
	
	update_labels()