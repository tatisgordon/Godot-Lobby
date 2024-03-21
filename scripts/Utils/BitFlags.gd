extends RefCounted
class_name BitFlags
var state: int = 0


func set_bit(position: int, bit: int) -> void:
	# Ensure the bit is either 0 or 1
	bit = 1 if bit != 0 else 0
	# Clear the bit at the specified position
	state = state & ~(1 << position)
	# Set the bit at the specified position to the provided value
	state = state | (bit << position)


func get_bit(position: int) -> int:
	# Retrieve the bit at the specified position
	return (state >> position) & 1


func _to_string():
	var _str = ""
	for i in range(0, 7):
		_str = _str + str((get_bit(i)))
	return _str
