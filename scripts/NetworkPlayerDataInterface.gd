extends RefCounted
class_name NetworkPlayerDataInterface

var playerName:String

var data:Dictionary={}
func _init():
	pass
#overload to return true
func loadPlayerNetWorkData()->bool:
	return false
