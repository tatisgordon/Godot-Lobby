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

		assert(
			_instance_num >= 0,
			"Unable to determine instance number. Seems like all TCP ports are in use"
		)
