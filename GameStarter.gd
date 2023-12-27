extends Node
class_name GameWorldMultiplayer
 

func _ready():
	#Lobby.finish_loaded.rpc()
	# Preconfigure game.

	pass#Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.


# Called only on the server.
func start_game():
	pass