extends Sprite2D
class_name TestPlayer
@export var speed: float = 10
var _movementInput: Vector2
@export var playerName: Label


func setName(_name: String):
	playerName.text = _name


func setColor(color: Color):
	modulate = color


func _input(event: InputEvent):
	if event is InputEventKey and name == str(multiplayer.get_unique_id()):
		var horizontal = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		var vertical = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		_movementInput = Vector2(horizontal, vertical).normalized()


func _process(delta):
	position += _movementInput * speed
