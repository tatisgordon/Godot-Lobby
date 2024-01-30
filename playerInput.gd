extends Sprite2D
class_name TestPlayer
@export var speed: float = 10
@onready var key = multiplayer.get_unique_id()
var _movementInput: Vector2
@onready var syncBuffer: PlayerSyncBufferVector2 = $PlayerSyncBuffer2


func _ready():
	if name == str(1):
		modulate = Color.RED
	else:
		modulate = Color.YELLOW
	if not multiplayer.is_server():
		syncBuffer.updatedData.connect(onUpdatePositionNetworkPosition)


func onUpdatePositionNetworkPosition(netWPosition: Vector2):
		#position = netWPosition
		var dis =  position.distance_to(netWPosition)
		print ('dis>>',dis)
		
		#if Vector2 networkPlayerData.dis
		pass


#local autority code
func _process(delta):
	position += _movementInput * speed
	if multiplayer.is_server():
		syncBuffer.setVector(position)
	


#server input processing
func incomingInput(movement, senderId):
	if name == str(senderId):
		_movementInput = movement


func localInput(_movement: Vector2):
	if name == str(multiplayer.get_unique_id()) and not multiplayer.is_server():
		print('local',name)
		_movementInput= _movement
		#position=Vector2.ZERO



func setColor(c: Color):
	modulate = c
