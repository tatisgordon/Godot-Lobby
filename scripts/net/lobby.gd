extends Node
class_name looby_multiplayer
# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info: NetPlayerInfo)
signal player_disconnected(peer_id)
signal server_disconnected
signal server_created()
signal server_joined()
signal playerReady(peer_id)

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1"  # IPv4 localhost
const MAX_CONNECTIONS = 4

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}


var players_loaded = 0
var netPlayerInfoRPC: Dictionary


func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(server_disconnects)

func setNewConnection(accept:bool):
	multiplayer.multiplayer_peer.set_refuse_new_connections(not accept)
###SERVER CODE
func create_game():
	netPlayerInfoRPC = getPlayerNetworData()
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

	var _netPlayerInfo = NetPlayerInfo.new(netPlayerInfoRPC)
	players[1] = _netPlayerInfo  #set 1 as a server/host id

	player_connected.emit(1, _netPlayerInfo)
	server_created.emit()

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_peer_connected(id):
	#print('conected',id)
	_register_player.rpc_id(id, netPlayerInfoRPC)



func _on_peer_disconnected(id):

	player_disconnected.emit(id)
	players.erase(id)

###CLIENTCODE
func join_game(address = ""):
	netPlayerInfoRPC = getPlayerNetworData()
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null
@rpc("any_peer","call_local","reliable")
func playerReady():
	pass

# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("authority","call_local", "reliable")
func load_game(game_scene_path: PackedScene):
	get_tree().change_scene_to_packed(game_scene_path)
#	loadMainGame(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0



func addPlayer(peerId, playerInfoRPC):
	var _netPlayerInfo = NetPlayerInfo.new(playerInfoRPC)
	players[peerId] = _netPlayerInfo
	player_connected.emit(peerId, _netPlayerInfo)

@rpc("any_peer", "call_remote", "reliable")
func _register_player(new_player_infoRPC):
	assert(new_player_infoRPC)
	var new_player_id = multiplayer.get_remote_sender_id()
	addPlayer(new_player_id, new_player_infoRPC)
	if new_player_id == 1:
		server_joined.emit()

func _on_connected_ok():
	#pass
	var peer_id = multiplayer.get_unique_id()
	addPlayer(peer_id, netPlayerInfoRPC)
	print(globalData.saveData.playerName, 'joined')
	#server_joined.emit()





func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func server_disconnects():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()


func loadMainGame(scene: PackedScene):
	var loadedScene = load(scene.resource_path)
	var scene_instance = loadedScene.instance()
	scene_instance.set_name("level_1")
	add_sibling(scene_instance)

func getPlayerNetworData():
	var _name = globalData.saveData.playerName
	return {"name": _name}
