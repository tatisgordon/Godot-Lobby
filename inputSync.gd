extends Node
class_name InputSync
const INPUT_CHANNEL = 222
signal inputUpdated(movement: Vector2, actions: BitFlags, senderId: int)
signal localInput(movement: Vector2, actions: BitFlags)


func _ready():
	_state = INPUT_STATE.SEND_INPUT


enum INPUT_STATE { SEND_INPUT, NOT_SEND_INPUT }
var _state: INPUT_STATE


func setInputState(state: INPUT_STATE):
	_state = state


func _process(delta):
#	if event is InputEventKey:
	var horizontal = Input.get_action_strength("x_axis_p") - Input.get_action_strength("x_axis_n")

	var vertical = Input.get_action_strength("y_axis_n") - Input.get_action_strength("y_axis_p")
	var interact = int(Input.is_action_just_pressed("interact"))
	var action_1 = int(Input.is_action_just_pressed("action_1"))
	var action_2 = int(Input.is_action_just_pressed("action_2"))


	var _movement_input = PackedFloat32Array([horizontal, vertical])

	var bitmask = BitFlags.new()

	bitmask.set_bit(0, interact)
	bitmask.set_bit(1, action_1)
	bitmask.set_bit(2, action_2)

	if _state == INPUT_STATE.NOT_SEND_INPUT:
		return
	sendInputDate.rpc_id(1, _movement_input, bitmask.state)
	localInput.emit(actionToMov(_movement_input), bitmask)


@rpc("any_peer", "call_local", "reliable", INPUT_CHANNEL)
func sendInputDate(_movement: PackedFloat32Array, _actions: int):
	if multiplayer.is_server():

		var senderId = multiplayer.get_remote_sender_id()

		var mov = actionToMov(_movement)
		var flags = BitFlags.new()
		flags.state = _actions
		

		inputUpdated.emit(mov, flags, senderId)


func actionToMov(_movement):
	return Vector2(_movement[0], _movement[1] * -1).normalized()
