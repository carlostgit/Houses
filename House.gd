extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _rent:float = 0.0
var _worker:Node2D = null

var _minimum_rent:float = 0.0

var _world:Node2D = null

var _cycle:int = 0

#TODO
#Temporarily banned workers
#Hay que penalizar temporalmente a los trabajadores que abandonen la casa
#sin llevar mucho tiempo, para que no anden largándose y volviendo de forma intermitente


# Called when the node enters the scene tree for the first time.
func _ready():
	_world = get_node("../../World")
#	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
		var step:float = 0.1
		var new_rent:float = old_rent + step
		var discretional_income:float = get_worker().calculate_discretional_income()
		
		if discretional_income > step:
			set_rent(new_rent)
			#Miro si con una subida de renta el inquilino se larga
			var factory:Node2D = get_worker().get_factory()
			var best_house_factory:Dictionary  = _world.find_best_house_factory_available(factory)
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
	else:
		var new_rent = get_rent() - 0.1
		if new_rent >= _minimum_rent:
			set_rent(get_rent() - 0.1)


func _on_TimerUpdateLabel_timeout():
	update_labels()
	


func _on_HouseTexture_pressed():
	increase_rent()	
#	pass # Replace with function body.



func _on_TimerAct_timeout():
	update_rent()
	pass # Replace with function body.
