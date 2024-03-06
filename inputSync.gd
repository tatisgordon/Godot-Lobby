extends Node
class_name InputSync
const INPUT_CHANNEL = 222
signal inputUpdated(movement: Vector2,actions:Array, senderId: int)
signal localInput(movement: Vector2,actions:Array)


func _ready():
	_state = INPUT_STATE.SEND_INPUT


enum INPUT_STATE { SEND_INPUT, NOT_SEND_INPUT }
var _state: INPUT_STATE


func setInputState(state: INPUT_STATE):
	_state = state


func _input(event: InputEvent):
	if _state == INPUT_STATE.NOT_SEND_INPUT:
		return

	
	if event is InputEventKey:
		var horizontal = (
			Input.get_action_strength("x_axis_n") - Input.get_action_strength("x_axis_p")
		)
		var vertical = Input.get_action_strength("y_axis_n") - Input.get_action_strength("y_axis_p")

		var _movement_input = PackedFloat32Array([horizontal, vertical])
		var actions = PackedByteArray([
			Input.is_action_just_pressed('interact') == true,
			
		])

		var array= actions.to_int32_array()

		sendInputDate.rpc_id(1, _movement_input,array)
		localInput.emit(actionToMov(_movement_input),array)



@rpc("any_peer", "call_local", "reliable", INPUT_CHANNEL)
func sendInputDate(_movement: PackedFloat32Array,actions:PackedByteArray):
	if multiplayer.is_server():
		var senderId = multiplayer.get_remote_sender_id()
		var array= actions.to_int32_array()
		var mov = actionToMov(_movement)
		inputUpdated.emit(mov, senderId,array)


func actionToMov(_movement)->Vector2:
	return Vector2(_movement[0], _movement[1] * -1).normalized()
func actionToActions(actions:PackedByteArray):
	var arr = actions.to_float32_array()
	var res = []

	if arr[0] == 1 :
		res.append('interact')
	return res
	