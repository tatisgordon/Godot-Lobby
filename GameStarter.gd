extends Node
class_name GameWorldMultiplayerStarter

@export var playerScene: PackedScene
@export var spawnRoot: Node2D



func _ready():
	for players_key in Lobby.players.keys():
		var playerInfo: NetPlayerInfo = Lobby.players[players_key]
		var player = playerScene.instantiate()

		player.name = str(players_key)

		spawnRoot.add_child(player)


# Called only on the server.
func start_game():
	pass
