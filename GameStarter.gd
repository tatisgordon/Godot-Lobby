extends Node
class_name GameWorldMultiplayer
 
@export var playerScene:PackedScene
@export var spawnRoot:Node2D
@export var multplayerSync:MultiplayerSynchronizer
func _ready():

		for players_key in  Lobby.players.keys():
			var playerInfo:NetPlayerInfo = Lobby.players[players_key]
			var player = playerScene.instantiate()
		
			player.name = str(players_key)
		#	player.set_multiplayer_authority(players_key)
		#multplayerSync.add_visibility_filter(
		
			spawnRoot.add_child(player)
		




# Called only on the server.
func start_game():
	pass