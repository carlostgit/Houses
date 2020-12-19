extends Node2D

class_name CWorld
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const house_resource = preload("res://House.tscn")

var _workers_array:Array = Array()
var _workers_without_house:Array = Array()
var _workers_with_house:Array = Array()

var _houses_array:Array = Array()
var _houses_without_worker:Array = Array()

var _factories_array:Array = Array()
var _yards_array:Array = Array()

var _cycle:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#pruebas:
	#var house_instance:Node = house_resource.instance()
	#self.add_child(house_instance)
	#get_houses()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	_cycle += 1
	
	_workers_array.clear()
	_houses_array.clear()	
	_factories_array.clear()
	_yards_array.clear()
	for node in self.get_children():
		#print(node.get_name())
		if (node.is_in_group("workers")):
			_workers_array.append(node)
		elif (node.is_in_group("houses")):
			_houses_array.append(node)
		elif (node.is_in_group("factories")):
			_factories_array.append(node)
		elif (node.is_in_group("yards")):
			_yards_array.append(node)
			

	_workers_without_house.clear()
	_workers_with_house.clear()
	for worker in _workers_array:
		if null == worker.get_house():
			_workers_without_house.append(worker)
		else:
			_workers_with_house.append(worker)

	_houses_without_worker.clear()
	for house in _houses_array:
		if house.get_worker() == null:
			_houses_without_worker.append(house)

	for factory in _factories_array:
		factory.next_state(_cycle)
	for house in _houses_array:
		house.next_state(_cycle)
	for yard in _yards_array:
		yard.next_state(_cycle)
	for worker in _workers_array:
		worker.next_state(_cycle)



	var default_position_origin:Vector2 = Vector2(20,20)
	var distance_between_workers:Vector2 = Vector2(0,100)
	var count = 0 
	for homeless in get_workers_without_house():
		var current_position:Vector2 = default_position_origin+distance_between_workers*count
		if (is_instance_valid(homeless)):
			homeless.set_position(current_position)
		count +=1	
	
#	for worker_with_house in _workers_with_house:
#		worker_with_house.move_to_house_position()

func get_houses() -> Array:
	return _houses_array
#	var return_array:Array = Array()
#	for node in self.get_children():
#		#print(node.get_name())
#		if (node.is_in_group("houses")):
#			return_array.append(node)
#			#print("esta")
#	return return_array


func get_factories() -> Array:
	return _factories_array
#	var return_array:Array = Array()
#	for node in self.get_children():
#		#print(node.get_name())
#		if (node.is_in_group("factories")):
#			return_array.append(node)
#			#print("esta")
#	return return_array


func get_workers() -> Array:
	
#	var start = OS.get_ticks_usec()
#
#	var return_array:Array = Array()
#
#	for node in self.get_children():
#		if (node.is_in_group("workers")):
#			return_array.append(node)
#
#
#
#	var end = OS.get_ticks_usec()
#	var get_workers_time = (end-start)/1000000.0
#	print("get_workers_time: "+str(get_workers_time))
#
#
#	print ("get_children().size(): " + str(self.get_children().size()))
#	return return_array

	print ("_workers_array.size(): " + str(_workers_array.size()))
	return _workers_array

func get_num_workers_without_house() -> int:
#	var count:int = 0
#	for worker in get_workers():
#		if null == worker.get_house():
#			count += 1
#	return count
	
	return _workers_without_house.size()

func get_workers_without_house() -> Array:
#	var workers_wo_house:Array = []
#	for worker in get_workers():
#		if null == worker.get_house():
#			workers_wo_house.append(worker)
#	return workers_wo_house
	return _workers_without_house

func get_available_houses(worker_arg) -> Array:
	var houses:Array = []
	for house in _houses_without_worker:
		if false == house.is_worker_banned(worker_arg):
			houses.push_back(house)
	if worker_arg:
		if worker_arg.get_house():
			houses.append(worker_arg.get_house())
	return houses	


func set_at_default_position(worker_arg:Node2D) -> void:
	var default_position_origin:Vector2 = Vector2(20,20)
	worker_arg.set_position(default_position_origin)
	
	
func get_factory_with_best_vacant_job() -> Node2D:
	var best_salary:float = 0.0
	var best_factory:Node2D = null
	for factory in get_factories():
		if (factory.has_worker() == false):
			if (factory.get_salary()>best_salary):
				best_salary = factory.get_salary()
				best_factory = factory
	return best_factory
	

func get_factories_with_vacant_jobs() -> Array:
	var factories:Array = []
	for factory in get_factories():
		if (factory.has_worker() == false):
			factories.append(factory)
	return factories


static func s_get_commuting_expenses(house:Node2D, factory:Node2D) -> float:
	
	if house and factory:
		var path_vec:Vector2 = house.get_position()-factory.get_position()
		var distance:float = path_vec.length() - 50
		var expenses:float = distance/200
		if expenses < 0:
			expenses = 0
		
		return expenses
	else:
		return 0.0


func find_best_house_factory_available(current_factory_arg:Node2D, worker_arg:Node2D) -> Dictionary:
	var vacant_factories:Array = get_factories_with_vacant_jobs()
	
	var houses:Array = get_available_houses(worker_arg)
	var best_disposable_income:float = 0.0
	var best_house:Node2D = null
	var best_factory:Node2D = null
	var difference_with_second_best:float = 0.0
	
	if (current_factory_arg):
		vacant_factories.append(current_factory_arg)
	var available_factories:Array = vacant_factories

	var count_num_options:int = 0	
#	var ret_value:Dictionary = {"house": best_house,"factory":best_factory, "difference":difference_with_second_best, "num_options":count_num_options}
#	return ret_value

	

	for factory in available_factories:
		for house in houses:
			count_num_options += 1
			var commuting_cost:float = self.s_get_commuting_expenses(house,factory)
			var rent:float = house.get_rent()
			var salary:float = factory.get_salary()
			var disposable_income = salary-rent-commuting_cost
			if (disposable_income > best_disposable_income):
				difference_with_second_best = disposable_income - best_disposable_income
				best_disposable_income = disposable_income
				best_house = house
				best_factory = factory


	var ret_value:Dictionary = {"house": best_house,"factory":best_factory, "difference":difference_with_second_best, "num_options":count_num_options}
	return ret_value

func find_best_house_factory_available_with_prospective_house(current_factory_arg:Node2D, worker_arg:Node2D, yard_arg:Node2D) -> Dictionary:
	
	var vacant_factories:Array = get_factories_with_vacant_jobs()
	
	var houses:Array = get_available_houses(worker_arg)
	var best_disposable_income:float = 0.0
	var best_house:Node2D = null
	var best_factory:Node2D = null
	var difference_with_second_best:float = 0.0
	
	if yard_arg and yard_arg.get_house():
		var prospective_house_in_yard:Node2D = yard_arg.get_house()
		houses.append(prospective_house_in_yard)
		
	if (current_factory_arg):
		vacant_factories.append(current_factory_arg)

	var available_factories:Array = vacant_factories

	var count_num_options:int = 0	
#	var ret_value:Dictionary = {"house": best_house,"factory":best_factory, "difference":difference_with_second_best, "num_options":count_num_options}
#	return ret_value
	for factory in available_factories:
		for house in houses:
			count_num_options += 1
			var rent:float = 0.0

			if yard_arg.get_house() == house:
				rent = yard_arg.get_estimated_payable_rent()
			else:
				rent = house.get_rent()

			var commuting_cost:float = self.s_get_commuting_expenses(house,factory)
#			var rent:float = house.get_rent()
			var salary:float = factory.get_salary()
			var disposable_income = salary-rent-commuting_cost
			if (disposable_income > best_disposable_income):
				difference_with_second_best = disposable_income - best_disposable_income
				best_disposable_income = disposable_income
				best_house = house
				best_factory = factory

	#var ret_value:Dictionary = {"house": best_house,"factory":best_factory}
	var ret_value:Dictionary = {"house": best_house,"factory":best_factory, "difference":difference_with_second_best, "num_options":count_num_options}
	return ret_value
		

func _on_TimerShortHomeless_timeout():
#	var default_position_origin:Vector2 = Vector2(20,20)
#	var distance_between_workers:Vector2 = Vector2(0,100)
#	var count = 0 
#	for homeless in get_workers_without_house():
#		var current_position:Vector2 = default_position_origin+distance_between_workers*count
#		homeless.set_position(current_position)
#		count +=1
	pass

func _on_LandPrice_value_changed(value):
	var param_value:float = value
	for node in self.get_children():
		if node.is_in_group("yards"):
			node.set_land_cost(value)
	

func _on_MinimumRent_value_changed(value):
	var param_value:float = value
	for node in self.get_children():
		if node.is_in_group("houses"):
			node.set_minimum_rent(value)
	