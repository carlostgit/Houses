extends Camera2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var _x_max:float = 2000
var _x_min:float = 0
var _y_max:float = 1000
var _y_min:float = 0

var _move_right:bool = false
var _move_left:bool = false
var _move_up:bool = false
var _move_down:bool = false

var _zoom_level:int = 2
var _min_zoom_level:int = 1
var _max_zoom_level:int = 16


# Called when the node enters the scene tree for the first time.
func _ready():
	make_current()
	set_h_drag_enabled(false)
	set_v_drag_enabled(false)
	set_drag_margin(MARGIN_BOTTOM,0.0)
	set_drag_margin(MARGIN_LEFT,0.0)
	set_drag_margin(MARGIN_RIGHT,0.0)
	set_drag_margin(MARGIN_TOP,0.0)
	
	
#	self.set_limit(MARGIN_BOTTOM,1000)
#	self.set_limit(MARGIN_TOP,0)
#	self.set_limit(MARGIN_LEFT,0)
#	self.set_limit(MARGIN_RIGHT,2000)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var speed:float = delta*1000
	if Input.is_action_pressed("ui_right") or _move_right:
		if (self.get_position().x < self._x_max):
			self.move_local_x(speed)
		
	if Input.is_action_pressed("ui_left") or _move_left:
		if (self.get_position().x > self._x_min):
			self.move_local_x(-speed)
		
	if Input.is_action_pressed("ui_up") or _move_up:
		if (self.get_position().y > self._y_min):
			self.move_local_y(-speed)
		
	if Input.is_action_pressed("ui_down") or _move_down:
		if (self.get_position().y < self._y_max):
			self.move_local_y(speed)
		
		
	if Input.is_action_pressed("ui_page_down"):
		self.set_zoom(Vector2(0.5,0.5))
	if Input.is_action_pressed("ui_page_up"):
		self.set_zoom(Vector2(1,1))
	
	pass



func _on_ButtonLeft_button_down():
	_move_left = true
	pass # Replace with function body.


func _on_ButtonLeft_button_up():
	_move_left = false
	pass # Replace with function body.


func _on_ButtonUp_button_down():
	_move_up = true
	pass # Replace with function body.


func _on_ButtonUp_button_up():
	_move_up = false
	pass # Replace with function body.


func _on_ButtonDown_button_down():
	_move_down = true
	pass # Replace with function body.


func _on_ButtonDown_button_up():
	_move_down = false
	pass # Replace with function body.


func _on_ButtonRight_button_down():
	_move_right = true
	pass # Replace with function body.


func _on_ButtonRight_button_up():
	_move_right = false
	pass # Replace with function body.

func _on_ButtonZoomIn_pressed():
#	_zoom_level += 1
	_zoom_level *= 2
	if (_zoom_level > _max_zoom_level):
		_zoom_level = _max_zoom_level
	self.set_zoom(Vector2(2.0/_zoom_level,2.0/_zoom_level))
	pass # Replace with function body.

func _on_ButtonZoomOut_pressed():
#	_zoom_level -= 1
	_zoom_level /= 2
	if (_zoom_level < _min_zoom_level):
		_zoom_level = _min_zoom_level
	self.set_zoom(Vector2(2.0/_zoom_level,2.0/_zoom_level))
	pass # Replace with function body.
