extends MarginContainer
class_name  ServerViewController
@export var playerItemLabelPrefab:PackedScene
var userItemMapping:Dictionary={}
@onready var playeritemConatiner:Container=$ServerView/vContainer
@onready var startButton:Button=$ServerView/HBoxContainer/StartGame
@onready var readyButton:Button=$ServerView/HBoxContainer/Ready
@onready var cancelButton:Button=$ServerView/HBoxContainer/Cancel

func _ready():
	Lobby.player_ready.connect(onPlayerReady)
	Lobby.all_players_ready.connect(onAllPlayersReady)
	Lobby.player_disconnected.connect(onPlayerDisconected)
#	Lobby.server_disconnected.connect( onServerDisconnect)
	#Lobby.player_disconnected.connect(onPnlayerUnready)

	


func onAllPlayersReady():
	if multiplayer.is_server():
		startButton.set_deferred("disabled",false)
func onPlayerDisconected(peer_id):
	onPlayerReady(peer_id,false)
	removeUserConnected(peer_id)






func onPlayerReady(peer_id,status:bool):
	var itemPlayerControl:UserConnectionLabel= userItemMapping[peer_id]
	itemPlayerControl.setReady(status)
	if not status and multiplayer.is_server() :
		startButton.set_deferred("disabled",true)

func addUserConnected(userId,player:NetPlayerInfo):

	var newUserItem:UserConnectionLabel= playerItemLabelPrefab.instantiate()
	playeritemConatiner.add_child(newUserItem)
	newUserItem.label.text=player.name
	newUserItem.setReady(player.ready)
	userItemMapping[userId]=newUserItem

func removeUserConnected(userId):
	playeritemConatiner.remove_child( userItemMapping[userId])
	userItemMapping[userId].queue_free()
	userItemMapping.erase(userId)
func removeAllusers():
	for key in userItemMapping.keys() :
		removeUserConnected(key)
	userItemMapping.clear()
func toServerMode():
	startButton.visible=true
	readyButton.visible=false

func toClientMode():
	startButton.visible=false
	readyButton.visible=true

		
