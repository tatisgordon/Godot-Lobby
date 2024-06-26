#abstract object to handle player data to be shared with peers must be extended 
class_name NetworkPlayerDataAbstracts
extends Node

var playerName: String

var data: Dictionary = {}


func _init():
	pass


# update the data
func updatePlayerNetworkData() -> bool:
	return false

#return the data 
func serializeData() -> Dictionary:
	assert(false, "should overload this method")
	return {}
