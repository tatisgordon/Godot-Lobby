extends Node
class_name GameWorldMultiplayer  #this is concrete but should be generic

@export var playerScene: PackedScene
@export var spawnRoot: Node2D
@export var multplayerSync: MultiplayerSynchronizer
@export var positions: Array[Node2D]


func _ready():
	var i := 0
	for players_key in Lobby.players.keys():
		var isLocal = players_key == multiplayer.get_unique_id()
		var playerInfo: NetPlayerInfo = Lobby.players[players_key]
		var player: Node2D = playerScene.instantiate()
		player.name = str(players_key)
		player.position = positions[playerInfo.playerNumber].position
		#player.
		var multiplayerAvatar: MultiplayerAvatar = player.get_node("./MultiplayerAvatar")
		assert(multiplayerAvatar)
		multiplayerAvatar.setAvatarType(isLocal, multiplayer.is_server())
		multiplayerAvatar.name = str(players_key)
		multiplayerAvatar.setLabelName(playerInfo.name + str(playerInfo.playerNumber))
		spawnRoot.add_child(player)
		i += 1


# Called only on the server.
func start_game():
	pass
