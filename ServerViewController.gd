extends MarginContainer
class_name  ServerViewController
@export var playerItemLabelPrefab:PackedScene
var userItemMapping:Dictionary={}
@onready var playeritemConatiner:Container=$ServerView/vContainer
@onready var startButton:Button=$ServerView/HBoxContainer/StartGame

func addUserConnected(userId,player:NetPlayerInfo):

	var newUserItem:UserConnectionLabel= playerItemLabelPrefab.instantiate()

	playeritemConatiner.add_child(newUserItem)

	newUserItem.label.text=player.name


	userItemMapping[userId]=newUserItem
func removeUserConnected(userId):
	playeritemConatiner.remove_child( userItemMapping[userId])
	userItemMapping[userId].queue_free()
	userItemMapping.erase(userId)
func removeAllusers():
	for key in userItemMapping.keys() :
		removeUserConnected(key)
	userItemMapping.clear()
func toClientMode():
	startButton.visible=false
		
