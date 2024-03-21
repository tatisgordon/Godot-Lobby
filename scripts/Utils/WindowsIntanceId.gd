
class_name WindowsIntanceId
var _instance_num := -1
var _instance_socket: TCPServer


func _init():
	#super._init()

	if OS.is_debug_build():
		_instance_socket = TCPServer.new()
		for n in range(0, 4):
			if _instance_socket.listen(5000 + n) == OK:
				_instance_num = n
				break
	var y = 0 if _instance_num % 2 == 0 else 600
	DisplayServer.window_set_size(Vector2i(600, 600))
#	DisplayServer.window_set_position(Vector2i(600 * _instance_num, y),DisplayServer.MAIN_WINDOW_ID)
	
	#Window.position=Vector2i(600 * _instance_num, y)
	
	

	assert(
		_instance_num >= 0,
		"Unable to determine instance number. Seems like all TCP ports are in use"
	)
