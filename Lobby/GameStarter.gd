extends Node
class_name GameWorldMultiplayerStarter

@export var playerScene: PackedScene
@export var spawnRoot: Node2D


func _ready():
	for players_key in Lobby.players.keys():#loop each player to instance them
		var playerInfo = Lobby.players[players_key]
		var player: TestPlayer = playerScene.instantiate()
		player.name = str(players_key)


		player.setName(playerInfo.name)
		player.setColor(playerInfo.color)
		player.set_multiplayer_authority(players_key) 
		spawnRoot.add_child(player)


# Called only on the server.
func start_game():
	pass
