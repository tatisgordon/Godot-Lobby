class_name LobbyMultiplayer
extends Node

# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal connection_to_server_failed
signal connection_to_server_initiated
signal connection_successful
signal server_created
signal server_joined
signal player_ready(peer_id, status: bool)  #a player is ready
signal player_loaded(peer_id)  # a player loaded the main game
signal all_players_loaded  #all players loaded1

signal shared_data_updated(peer_id, data)  #when players data have been updated,only the updated data shows up

const PORT = 9001
const DEFAULT_SERVER_IP = "127.0.0.1"  # IPv4 localhost
const MAX_CONNECTIONS = 4

var players: Dictionary = {}
var networkPlayerData: NetworkPlayerData = NetworkPlayerData.new()  #manage access to current players shared data

var players_loaded_current = PlayersLoaded.new()  #


func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(server_disconnects)


func setNewConnection(accept: bool):
	multiplayer.multiplayer_peer.set_refuse_new_connections(not accept)


###SERVER CODE
func create_game():
	var peer = ENetMultiplayerPeer.new()

	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error != OK:
		return error

	multiplayer.multiplayer_peer = peer
	var netPlayerInfoRPC = getPlayerNetworkData()
	addPlayer(1, netPlayerInfoRPC)

	server_created.emit()


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_peer_connected(id):
	var netPlayerInfoRPC = getPlayerNetworkData()
	_register_player.rpc_id(id, netPlayerInfoRPC)


func _on_peer_disconnected(id):
	player_disconnected.emit(id)
	players.erase(id)


#CLIENT CODE
func join_game(address = "localhost"):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()

	var error = peer.create_client(address, PORT)
	if error:
		return error

	multiplayer.multiplayer_peer = peer
	connection_to_server_initiated.emit()
	return OK


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null


@rpc("any_peer", "call_local", "reliable")
func broadcastPlayerData(updatedPlayerData):  #call this when a sharedData property has changed
	var peer_id = multiplayer.get_remote_sender_id()
	var playerData: Dictionary = players[peer_id]
	playerData.merge(updatedPlayerData, true)
	players[peer_id] = playerData
	shared_data_updated.emit(peer_id, updatedPlayerData)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func finish_loaded():
	var peer_id = multiplayer.get_remote_sender_id()
	assert(not peer_id == 0)

	players_loaded_current.addPlayer(peer_id)
	player_loaded.emit(peer_id)

	if players_loaded_current.loaded == players.size():
		allPlayerLoaded.rpc_id(MultiplayerPeer.TARGET_PEER_SERVER)


func addPlayer(peerId, playerInfoRPC):
	var _netPlayerInfo = NetPlayerInfo.new(playerInfoRPC)
	players[peerId] = playerInfoRPC
	player_connected.emit(peerId, _netPlayerInfo)
	#call_deferred("setPlayerReady",


@rpc("any_peer", "call_remote", "reliable")
func _register_player(new_player_infoRPC):
	assert(new_player_infoRPC)
	var new_player_id = multiplayer.get_remote_sender_id()
	addPlayer(new_player_id, new_player_infoRPC)
	if new_player_id == MultiplayerPeer.TARGET_PEER_SERVER:
		server_joined.emit()


func _on_connected_ok():
	networkPlayerData.updateNetworkData()
	var netPlayerInfoRPC = getPlayerNetworkData()

	var peer_id = multiplayer.get_unique_id()
	addPlayer(peer_id, netPlayerInfoRPC)
	connection_successful.emit()


func closeConnection():
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()


func setNetworkPlayerDataConcrete(c: NetworkPlayerDataAbstracts):
	networkPlayerData.setDataFetcher(c)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	connection_to_server_failed.emit()


func server_disconnects():
	multiplayer.multiplayer_peer = null
	players.clear()

	players_loaded_current = PlayersLoaded.new()
	server_disconnected.emit()


@rpc("any_peer", "call_local", "reliable")
func allPlayerLoaded():
	if multiplayer.is_server():
		all_players_loaded.emit()


func getPlayerNetworkData():
	var data = networkPlayerData.getPlayerData()

	return data
