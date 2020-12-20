extends Node2D

class_name CWorker

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var _name:String = "a"

var _house:Node2D = null
var _factory:Node2D = null
var _world:Node2D = null

var _commuting_lines:Array = []

var _cycle:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_world = get_node("../../World")
#	print_tree()
#	get_parent().print_tree()
#	print("1")
#	print(get_path())
#	print(get_parent().get_path())
#	print("2")
#	print(get_parent().name)
	assert(_world.is_in_group("world"))
	assert(_world)
	
	_name = get_new_name()
	
		
	$NameLabel.set_text(_name)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_new_name():
	
	var new_name = "no name"
	
	var string_name_source:Array = []
	var string_alphabet = "abcdefghijklmnñopqrstuwxyz"
	
	for i in (string_alphabet.length()-1):
		string_name_source.append(string_alphabet.substr(i,1))
	
	if (_world):
		for name_of_list in string_name_source:
			var used_name:bool = false
			for child in _world.get_children():
				if (child.is_in_group("workers")):
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

func get_income() -> float:
	return s_get_income(_factory)


static func s_get_income(factory:Node2D) -> float:
	if factory:
		return factory.get_salary()
	else:
		return 0.0


func get_rent_expenses() -> float:
	return s_get_rent_expenses(_house)


static func s_get_rent_expenses(house:Node2D) -> float:
	if house:
		return house.get_rent()
	else:
		return 0.0


func get_commuting_expenses() -> float:
	#return CWorld2.s_get_commuting_expenses(_house,_factory)
	return _world.get_commuting_expenses(_house,_factory)
	


func calculate_discretional_income() -> float:
	#return s_calculate_discretional_income(_house, _factory)
	return calculate_discretional_income_for_house_and_factory(_house, _factory)
	
func calculate_discretional_income_for_house_and_factory(house:Node2D, factory:Node2D) -> float:
	var income:float = 0.0
	if factory:
		income = factory.get_salary()
	var rent_expenses:float = 0.0
	if house:
		rent_expenses = house.get_rent()
	
	#var commuting_expenses:float = CWorld2.s_get_commuting_expenses(house, factory)
	var commuting_expenses:float = 0.0
	if _world:
		commuting_expenses = _world.get_commuting_expenses(house, factory)
	var discretional_income = income - rent_expenses - commuting_expenses
	return discretional_income

#static func s_calculate_discretional_income(house:Node2D, factory:Node2D) -> float:
#	var income:float = s_get_income(factory)
#	var rent_expenses:float = s_get_rent_expenses(house)
#	#var commuting_expenses:float = CWorld2.s_get_commuting_expenses(house, factory)
#	var commuting_expenses:float = CWorld.s_get_commuting_expenses(house, factory)
#	var discretional_income = income - rent_expenses - commuting_expenses
#	return discretional_income


func set_house(house_arg:Node2D) -> void:
	#si estamos en otra casa, primero salimos
	if _house:
		_house.set_worker(null)
	#si en la nueva casa habia alguien, lo echamos
	if house_arg:
		if (null != house_arg.get_worker()):
			var old_worker = house_arg.get_worker()
			old_worker.kick_out()
		house_arg.set_worker(null)
	_house = house_arg
	if (_house):
		_house.set_worker(self)
	move_to_house_position()


func get_house() -> Node2D:
	return _house


func set_factory(factory_arg:Node2D) -> void:

	if factory_arg:
		#No está previsto que se pueda quitar el empleo a nadie
		var old_worker:Node2D = factory_arg.get_worker()
		if (old_worker and self != old_worker):
			old_worker.kick_out()#Se le echa también de la casa, para simplificar
		factory_arg.set_worker(self)
	if _factory:
		_factory.set_worker(null)
	_factory = factory_arg
	
func get_factory() -> Node2D:
	return _factory
	

func set_house_and_factory(house_arg:Node2D,factory_arg:Node2D) -> void:
	set_house(house_arg)
	set_factory(factory_arg)


func kick_out() -> void:
	if _house:
		if (_house.get_worker()):
			_house.set_worker(null)
		_house = null
		move_to_house_position()
	if _factory:
		if (_factory.get_worker()):
			_factory.set_worker(null)
		_factory = null

	
func move_to_house_position() -> void:
	if _house:
		self.set_position(_house.get_position_for_worker())
	else:
		self.set_position(Vector2(0,0))
		assert(_world)
		assert(_world.has_method("set_at_default_position"))
		_world.set_at_default_position(self)


func find_better_place() -> void:
	var current_discret_income:float = self.calculate_discretional_income()
	assert(_world)
	assert(_world.has_method("find_best_house_factory_available"))
	var house:Node2D = null
	var factory:Node2D = null
	#_world.set_at_default_position(self)
	var best_house_factory:Dictionary  = _world.find_best_house_factory_available(_factory, self)
	assert(best_house_factory.has("house"))
	house = best_house_factory.get("house")
	assert(best_house_factory.has("factory"))
	factory = best_house_factory.get("factory")
	#
	if house!=_house and house!=null and factory!=null:
		var new_discr_income = calculate_discretional_income_for_house_and_factory(house,factory)
		var param_rent_increase_to_evict = 0.1
		if (new_discr_income - param_rent_increase_to_evict > current_discret_income):
			var old_rent:float = house.get_rent()
			var new_rent:float = old_rent + param_rent_increase_to_evict

			if _house:
				_house.leaving_house(self)
				
			self.set_house(house)
			house.set_rent(new_rent)
			self.set_factory(factory)


func update_labels() -> void:
	
	var income:float = self.get_income()
	var income_rounded:float = stepify(income, 0.01)
	$IncomeLabel.set_text(str(income_rounded)+"$")
	
	var rent_expenses:float = self.get_rent_expenses()
	var rent_expenses_rounded:float = stepify(rent_expenses, 0.01)
	$RentExpLabel.set_text(str(rent_expenses_rounded)+"$")

	var commuting_expenses:float = self.get_commuting_expenses()
	var commuting_expenses_rounded:float = stepify(commuting_expenses, 0.01)
	$CommutingExpLabel.set_text(str(commuting_expenses_rounded)+"$")	

	var discr_income:float = self.calculate_discretional_income()
	var discr_income_rounded:float = stepify(discr_income, 0.01)
	$DiscretionalIncome.set_text(str(discr_income_rounded)+"$")

	#Pintar linea hasta el lugar de trabajo
	#Las pinto en la escena padre
	if _world:		
		for commuting_line in _commuting_lines:
			_world.remove_child(commuting_line)
		_commuting_lines.clear()

	if _house and _factory:
		
		var commuting_line:Line2D  = Line2D.new()
		commuting_line.set_width(1.0)
		commuting_line.set_default_color(Color(200.0/255.0,200.0/255.0,255.0/255.0))
		
		var house_width:float = _house.get_house_width()
		var house_width_vect:Vector2 = Vector2(house_width,0)
		commuting_line.add_point(_house.get_position() + house_width_vect)
		commuting_line.add_point(_factory.get_position())
		_commuting_lines.append(commuting_line)
		if _world:
			_world.add_child(commuting_line)


func _on_TimerUpdateLabels_timeout():
#	update_labels()
	pass
	
func _on_WorkerTexture_pressed():
	print("pressed")
	find_better_place()


func _on_TimerAct_timeout():
#	var start = OS.get_ticks_usec()
#	find_better_place()
#	var end = OS.get_ticks_usec()
#	var find_better_place_time = (end-start)/1000000.0
#	print("find_better_place_time: "+str(find_better_place_time))
	pass
	
#	pass # Replace with function body.


func _on_TimerActForHomeless_timeout():
#	if null == _house:
#		var start = OS.get_ticks_usec()
#		find_better_place()
#		var end = OS.get_ticks_usec()
#		var find_better_place_time = (end-start)/1000000.0
#		print("find_better_place_time: "+str(find_better_place_time))
	pass # Replace with function body.

func clear_before_removing():
	if _house:
		_house.set_worker(null)
		
	if _factory:
		_factory.set_worker(null)
		
	if _world:		
		for commuting_line in _commuting_lines:
			_world.remove_child(commuting_line)
		_commuting_lines.clear()

	
func can_be_removed():
	return true
	
func next_state(cycle_arg:int) -> void:
	update_labels()
	find_better_place()	
	if (_house):
		move_to_house_position()
		#Los que no tienen casa se ordenan en una cola en World.gd
