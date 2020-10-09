extends Node2D

class_name CWorld
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const house_resource = preload("res://House.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	#pruebas:
	#var house_instance:Node = house_resource.instance()
	#self.add_child(house_instance)
	#get_houses()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func get_houses() -> Array:
	var return_array:Array = Array()
	for node in self.get_children():
		#print(node.get_name())
		if (node.is_in_group("houses")):
			return_array.append(node)
			#print("esta")
	return return_array


func get_factories() -> Array:
	var return_array:Array = Array()
	for node in self.get_children():
		#print(node.get_name())
		if (node.is_in_group("factories")):
			return_array.append(node)
			#print("esta")
	return return_array


func get_workers() -> Array:
	var return_array:Array = Array()
	for node in self.get_children():
		#print(node.get_name())
		if (node.is_in_group("workers")):
			return_array.append(node)
			#print("esta")
	return return_array


func get_num_workers_without_house() -> int:
	var count:int = 0
	for worker in get_workers():
		if null == worker.get_house():
			count += 1
	return count


func get_workers_without_house() -> Array:
	var workers_wo_house:Array = []
	for worker in get_workers():
		if null == worker.get_house():
			workers_wo_house.append(worker)
	return workers_wo_house


func set_at_default_position(worker_arg:Node2D) -> void:
	var default_position_origin:Vector2 = Vector2(20,20)
	worker_arg.set_position(default_position_origin)
	
#	var distance_between_workers:Vector2 = Vector2(0,45)	
#	var default_position_origin:Vector2 = Vector2(20,20)
#	var num_workers_without_house:int =  get_workers_without_house().size()
#	var position_for_next_worker = default_position_origin+distance_between_workers*num_workers_without_house	
#	worker_arg.set_position(position_for_next_worker)

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
		var distance:float = path_vec.length()
		var expenses:float = distance/200
		return expenses
	else:
		return 0.0


func find_best_house_factory_available(current_factory_arg:Node2D) -> Dictionary:
	var vacant_factories:Array = get_factories_with_vacant_jobs()
	
	var houses:Array = get_houses()
	var best_disposable_income:float = 0.0
	var best_house:Node2D = null
	var best_factory:Node2D = null
	
	if (current_factory_arg):
		vacant_factories.append(current_factory_arg)
	var available_factories:Array = vacant_factories
	
	for factory in available_factories:
		for house in houses:
			var commuting_cost:float = self.s_get_commuting_expenses(house,factory)
			var rent:float = house.get_rent()
			var salary:float = factory.get_salary()
			var disposable_income = salary-rent-commuting_cost
			if (disposable_income > best_disposable_income):
				best_disposable_income = disposable_income
				best_house = house
				best_factory = factory

	var ret_value:Dictionary = {"house": best_house,"factory":best_factory}
	return ret_value

func _on_TimerShortHomeless_timeout():
	var default_position_origin:Vector2 = Vector2(20,20)
	var distance_between_workers:Vector2 = Vector2(0,100)
	var count = 0 
	for homeless in get_workers_without_house():
		var current_position:Vector2 = default_position_origin+distance_between_workers*count
		homeless.set_position(current_position)
		count +=1


#	var distance_between_workers:Vector2 = Vector2(0,45)	
#	var default_position_origin:Vector2 = Vector2(20,20)
#	var num_workers_without_house:int =  get_workers_without_house().size()
#	var position_for_next_worker = default_position_origin+distance_between_workers*num_workers_without_house	
#	worker_arg.set_position(position_for_next_worker)

	pass # Replace with function body.
