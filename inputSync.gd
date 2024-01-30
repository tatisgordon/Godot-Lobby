extends  Node
class_name  InputSync
const INPUT_CHANNEL=222
signal inputUpdated(movement:Vector2,senderId:int)
signal localInput(movement:Vector2)


func _ready():
	_state=INPUT_STATE.SEND_INPUT

enum INPUT_STATE  {SEND_INPUT,NOT_SEND_INPUT}
var _state:INPUT_STATE

func setInputState(state:INPUT_STATE):
	_state = state
func _input(event:InputEvent):
	
	if event is InputEventKey:
		#print('input',event.as_text_keycode())
 
		
		var horizontal = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		var vertical = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")


		var _movement_input = PackedFloat32Array([horizontal,vertical])

		if _state == INPUT_STATE.NOT_SEND_INPUT:
			return

		sendInputDate.rpc_id(1,_movement_input)
		localInput.emit(actionToMov(_movement_input))

@rpc("any_peer","call_local","reliable",INPUT_CHANNEL)
func sendInputDate(_movement:PackedFloat32Array):
	if multiplayer.is_server():
		
		var senderId = multiplayer.get_remote_sender_id()

		var mov = actionToMov(_movement)
		inputUpdated.emit(mov,senderId)

func actionToMov(_movement):
		
		return Vector2(_movement[0],_movement[1]*-1).normalized()
