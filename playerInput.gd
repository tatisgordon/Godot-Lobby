extends Sprite2D
@export var speed:float = 10
@onready var key = multiplayer.get_unique_id()
var _movementInput:Vector2
func _ready():
	if multiplayer.is_server() and name == str(multiplayer.get_unique_id()):
		modulate=Color.RED 

#local autority code
func _process(delta):
		#position=  position.lerp( _movementInput*speed,0.5)
		position+=   _movementInput*speed
#server input processing
func incomingInput(movement,senderId):
	if name == str(senderId):
		_movementInput= movement 
func localInput(_movement:Vector2):
	if name == str(multiplayer.get_unique_id()):
		_movementInput= _movement 
	#pass
func setColor(c:Color):
	modulate =c
