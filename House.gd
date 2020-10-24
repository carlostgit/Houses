extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _rent:float = 0.0
var _worker:Node2D = null

var _minimum_rent:float = 0.0

var _world:Node2D = null

var _cycle:int = 0

var _name:String = "H"


#TODO
#Temporarily banned workers
#Hay que penalizar temporalmente a los trabajadores que abandonen la casa
#sin llevar mucho tiempo, para que no anden largándose y volviendo de forma intermitente
var _ban_time:int = 1 #cycles
var _banned_workers_with_cycle:Dictionary = {} #banned_worker:Node2D - cycle_when_banned:int

#Se mirara que inquilinos han abandonado la casa los últimos 5 ciclos
var _leaving_tenants_with_cycle:Array = [] #worker:Node2D
var _min_cycles_before_leaving_again:int = 1 

# Called when the node enters the scene tree for the first time.
func _ready():
	_world = get_node("../../World")
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_name(name_arg:String) -> void:
	_name = name_arg

func get_name() -> String:
	return _name

func get_rent() -> float:
	return _rent


func set_rent(rent_arg:float) -> void:
	_rent = rent_arg
	var rent_rounded:float = stepify(_rent, 0.01)
	$RentLabel.set_text(str(rent_rounded)+"$")

	
#func evict_worker() -> void:
#	#No sé si debería llamar a algún método de _tenant
#	if (_worker):
#		_worker.set_house(null)
#		if (_worker.get_factory()):
#			_worker.get_factory().set_worker(null)
#			_worker.set_factory(null)			
#
#	_worker = null
		

func set_worker(worker_arg:Node2D) -> void:
	_worker = worker_arg
#	if (null == _worker):
#		_rent = _minimum_rent
	
	
func get_worker() -> Node2D:
	return _worker


func get_position_for_worker() -> Vector2:
	var house_pos:Vector2 = self.get_position()
	var worker_separation:Vector2 = Vector2(-40,0)
	var worker_pos:Vector2 = house_pos+worker_separation
	return worker_pos


func get_house_width() -> int:
	return $HouseTexture.get_normal_texture().get_width()


func get_house_height() -> int:
	return $HouseTexture.get_normal_texture().get_height()


func update_labels() -> void:
	var rent:float = self.get_rent()
	var rent_rounded:float = stepify(rent, 0.01)
	$RentLabel.set_text(str(rent_rounded)+"$")

func increase_rent() -> void:
	if (get_worker()):
		var old_rent:float = get_rent()
		var step:float = 0.01
		var new_rent:float = old_rent + step
		var discretional_income:float = get_worker().calculate_discretional_income()
		
		if discretional_income > step:
			set_rent(new_rent)
			#Miro si con una subida de renta el inquilino se larga
			var factory:Node2D = get_worker().get_factory()
			var best_house_factory:Dictionary  = _world.find_best_house_factory_available(factory,get_worker())
			assert(best_house_factory.has("house"))
			var house:Node2D = best_house_factory.get("house")
#			assert(best_house_factory.has("factory"))
#			var factory:Node2D = best_house_factory.get("factory")
			if self != house:
				if get_worker().s_calculate_discretional_income(house,factory) - 0.1 > get_worker().s_calculate_discretional_income(self,factory):	
					set_rent(old_rent) #No le subo la renta para que no se largue


func update_rent() -> void:
#	subo renta mientras haya inquilino, y bajo cuando no lo haya
	if self.get_worker():
		increase_rent()
		negotiate_rent_discount()
	else:
		var new_rent = get_rent() - 0.1
		if new_rent >= _minimum_rent:
			set_rent(new_rent)


func leaving_house(worker:Node2D)-> void:
	var tenant_cycle:Dictionary = {worker : _cycle}
	_leaving_tenants_with_cycle.push_front(tenant_cycle)


func ban_worker(worker:Node2D) -> void:
	_banned_workers_with_cycle[worker] = _cycle


func is_worker_banned(worker_arg:Node2D) -> bool:
	if -1 != _banned_workers_with_cycle.keys().find(worker_arg):
		return true
	else:
		return false


func ban_workers() -> void:
	#var count:int = 0

	var index_of_leaving_tenants_to_erase:Array = []
	for index in _leaving_tenants_with_cycle.size():
		
		#var keys = tenant_with_cycle_dic.keys()
		var tenant:Node2D = _leaving_tenants_with_cycle[index].keys().front()
		var leaving_cycle:int = _leaving_tenants_with_cycle[index].values().front()
		if (_cycle - leaving_cycle) > self._min_cycles_before_leaving_again:
			index_of_leaving_tenants_to_erase.push_back(index)
	
	for index in index_of_leaving_tenants_to_erase:
		_leaving_tenants_with_cycle.remove(index)
		
	var tenants_in_recently_leaving:Array = []
	for tenant_with_cycle_dic in _leaving_tenants_with_cycle:
		var tenant:Node2D = tenant_with_cycle_dic.keys().front()
		var leaving_cycle:int = tenant_with_cycle_dic.values().front()
		if -1 == tenants_in_recently_leaving.find(tenant):
			tenants_in_recently_leaving.push_back(tenant)
		else:
			ban_worker(tenant)
		
	#unban workers
	var workers_to_unban:Array = []
	for worker in _banned_workers_with_cycle:
		var banned_time:int = _banned_workers_with_cycle[worker]
		if (_cycle-banned_time) > _ban_time:
			workers_to_unban.push_back(worker)
	
	for worker in workers_to_unban:
		_banned_workers_with_cycle.erase(worker)


func negotiate_rent_discount() -> void:
	#solo cuando todavía se tiene inquilino
	if _worker:
		var old_rent:float = _rent
		
		var best_house:Node2D = null
		while best_house != self and _rent > self._minimum_rent:	
			for asking_worker in _world.get_workers():
				var asking_worker_factory:Node2D = asking_worker.get_factory()
				var best_house_factory:Dictionary  = _world.find_best_house_factory_available(asking_worker_factory, asking_worker)
				best_house = best_house_factory.get("house") as Node2D
				if best_house and best_house == self:
					break
				
			if best_house != self:
				var discount_step:float = 0.01
					
				var new_rent:float = get_rent() - discount_step
				if new_rent < self._minimum_rent:
					new_rent = self._minimum_rent
				set_rent(new_rent)


func _on_TimerUpdateLabel_timeout():
	update_labels()
	

func _on_HouseTexture_pressed():
	increase_rent()	
#	pass # Replace with function body.

func _on_TimerAct_timeout():
	update_rent()
	ban_workers()
	_cycle += 1
#	pass # Replace with function body.
