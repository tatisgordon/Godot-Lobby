extends  Node
#Abstrac class must be Extended
class_name NetworkPlayerDataInterface

var playerName:String

var data:Dictionary={}
func _init():
	pass
#overload to return true
func loadPlayerNetWorkData():
	return false
