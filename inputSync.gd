extends  Node
class_name  InputSync
const INPUT_CHANNEL=222
signal inputUpdated(movement:Vector2,senderId:int)
signal localInput(movement:Vector2)


func _input(event:InputEvent):
	
	if event is InputEventKey:
		print('input',event.as_text_keycode())
		#var str_l= 1 if event.get_action_strength('ui_left')else 0
		#var str_r= 1 if event.is_action_pressed('ui_right') else 0
		#var str_u= 1 if event.is_action_pressed('ui_up')else 0
		#var str_d= 1 if event.is_action_pressed('ui_down')else 0
		
		var horizontal = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		var vertical = Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")


		var _movement_input = PackedFloat32Array([horizontal,vertical])
		sendInputDate.rpc_id(1,_movement_input)
		localInput.emit(actionToMov(_movement_input))

@rpc("any_peer","call_local","reliable",INPUT_CHANNEL)
func sendInputDate(_movement:PackedFloat32Array):
	if multiplayer.is_server():
		
		var senderId = multiplayer.get_remote_sender_id()

		var mov = actionToMov(_movement)
		print('mov',mov)
		inputUpdated.emit(mov,senderId)

func actionToMov(_movement):
		
		return Vector2(_movement[0],_movement[1]*-1).normalized()
