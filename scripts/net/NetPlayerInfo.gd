class_name NetPlayerInfo

func _init(playerInfo:Dictionary):
    self.name = playerInfo.name
    self.ready=playerInfo.ready

var name:String
var color:Color
var ready:bool