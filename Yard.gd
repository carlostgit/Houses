extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var _land_cost:float = 2.0

var _min_profit_rate:float = 0.20 #*100=percentage

var _world:Node2D = null

var _estimated_payable_rent:float = 0.0

var _last_estimated_payable_rents:Array

#var _house:Node2D = null
var _house:Node2D = preload("res://House.tscn").instance()

var _name:String = ""

export var _country:String = "France"

var _best_worker_for_yard:Dictionary

signal sig_node_selected(node)
signal sig_node_deleted(node)

# Called when the node enters the scene tree for the first time.
func _ready():
	_world = get_node("../../World")
	_house.set_position(self.get_position())

#	_house.add_to_group("houses")

	_name = get_new_name()

	_house.hide()
	_house.set_name(_name)	
	_world.call_deferred("add_child", _house) #deferred pq _world está ocupado creando sus hijos


	_house.set_country(_country)
	if _country == "France":
		$france_flag.show()
	else:
		$france_flag.hide()


	self.connect("sig_node_selected", _world, "on_sig_node_selected")
	self.connect("sig_node_deleted", _world, "on_sig_node_deleted")
	#self.connect("tree_exited", _world, "on_sig_node_deleted3")

#	probar estas conecsiones. comprobar si se está sacando el yard del tree al liberarlo

func set_country(country_arg:String):
	_country = country_arg
	_house.set_country(country_arg)
	if _country == "France":
		$france_flag.show()
	else:
		$france_flag.hide()

func get_country()->String:
	return _country

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

func get_building_cost() -> float:
	var other_costs:float = 0.0
	var total_cost:float = get_land_cost() + other_costs
	return total_cost

func get_land_cost() -> float:
	return _land_cost

func update_labels() -> void:
	var building_cost:float = self.get_building_cost()
	var building_cost_rounded:float = stepify(building_cost, 0.01)
	$BuildingCostLabel.set_text(str(building_cost_rounded)+"$")

	var land_cost:float = self.get_land_cost()
	var land_cost_rounded:float = stepify(land_cost, 0.01)
	$LandCostLabel.set_text(str(land_cost_rounded)+"$")

	var expected_rent:float = self.get_estimated_payable_rent()
	var expected_rent_rounded:float = stepify(expected_rent, 0.01)
	$ExpectedRentLabel.set_text(str(expected_rent_rounded)+"$")

	$NameLabel.set_text(get_name())

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
	
#	emit_signal("sig_node_deleted",self)
	
	self.queue_free()
	
	

func _on_TimerUpdateLabel_timeout():
#	update_labels()
	pass
	
func _on_YardTexture_pressed():
#	build_house()
	
	emit_signal("sig_node_selected",self)

	
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


func calculate_best_candidate_to_move_to_prospective_house() -> Dictionary:
	var best_worker:Node = null
	var best_improvement = 0
	for asking_worker in _world.get_workers():
		var worker_yard_info:Dictionary = asking_worker.get_precalculated_worker_info_for_prospective_house(self)
		var disposable_income_for_yard:float = worker_yard_info.get("disposable_income")
		var current_disposable_income:float = asking_worker.calculate_discretional_income()
		var improvement:float = disposable_income_for_yard - current_disposable_income
		if best_worker == null or improvement>best_improvement:
			best_worker = asking_worker
			best_improvement = improvement
			
	#improvement es la mejora que tendría el worker si se moviera al yard
	_best_worker_for_yard = {"worker":best_worker,"improvement":best_improvement}
	return _best_worker_for_yard

func get_precalculated_best_candidate_to_move_to_prospective_house() -> Dictionary:
	return _best_worker_for_yard

func adjust_estimated_payable_rent_using_precalculated_best_candidate_info() -> void:
	var improvement:float = _best_worker_for_yard.get("improvement")
	var estimated_payable_rent:float = self.get_estimated_payable_rent()
	var step:float = 0.1
	if improvement >= 0 + step:
		self.set_estimated_payable_rent(estimated_payable_rent + step)
	elif improvement <= 0- step:
		self.set_estimated_payable_rent(estimated_payable_rent - step)
		
func next_state(cycle_arg:int) -> void:
	
	#precalculo cosas
	for asking_worker in _world.get_workers():
		asking_worker.calculate_worker_info_for_prospective_house(self)
	calculate_best_candidate_to_move_to_prospective_house()
	
	#
	
	#self.adjust_estimated_payable_rent()
	#Cambio lo anterior por lo siguiente, para intentar mejorar el rendimiento
	self.adjust_estimated_payable_rent_using_precalculated_best_candidate_info()
	
	_last_estimated_payable_rents.push_back(self.get_estimated_payable_rent())
	var min_profit:float = self.get_building_cost()*_min_profit_rate
	if (self.get_estimated_payable_rent() > min_profit + self.get_building_cost()):
		if (self.get_estimated_payable_rent() > min_profit + get_recent_average_estimated_payable_rent()):
			build_house()
	
	update_labels()

func _on_Yard_tree_exiting():
	
	emit_signal("sig_node_deleted",self)
	
