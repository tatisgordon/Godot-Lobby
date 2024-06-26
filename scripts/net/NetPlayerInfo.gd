class_name NetPlayerInfo

func _init(playerInfo:Dictionary):
	self.name = playerInfo.name
	self.ready=playerInfo.ready
	self.data = playerInfo

var name:String
var ready:bool
var data:Dictionary