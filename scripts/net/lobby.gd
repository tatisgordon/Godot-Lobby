extends Node
class_name looby_multiplayer
# Autoload named Lobby

# These signals can be connected to by a UI lobby scene or the game scene.
signal player_connected(peer_id, player_info: NetPlayerInfo)
signal player_disconnected(peer_id)
signal server_disconnected
signal server_created()
signal server_joined()
signal player_ready(peer_id,status:bool)#a player is ready
signal player_loaded(peer_id)# a player loaded the main game
signal all_players_loaded()#all players loaded
signal all_players_ready()#all players are ready wating for server to start

const PORT = 8000
const DEFAULT_SERVER_IP = "127.0.0.1"  # IPv4 localhost
const MAX_CONNECTIONS = 4

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var playersReadyCount=0
var players = {}
class PlayersLoaded:
	var loaded:=0
	var loadedPlayers:Dictionary={}

	func addPlayer(peer_id):
		loaded =loaded+1
		loadedPlayers[peer_id] = true

	func removePlayer(peer_id):
		loaded =loaded-1
		loadedPlayers.erase(peer_id)



var players_loaded_current = PlayersLoaded.new()
 


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
	#var upnp = UPNP.new()

	#var disc= upnp.discover()
	#print('ip:',upnp.query_external_address())	

	var netPlayerInfoRPC = getPlayerNetworData()
	var peer = ENetMultiplayerPeer.new()
	#peer.get_packet_peer()
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
	var netPlayerInfoRPC = getPlayerNetworData()
	_register_player.rpc_id(id, netPlayerInfoRPC)
	if multiplayer.is_server() and not id == 1:#sync data 
		pass



func _on_peer_disconnected(id):

	player_disconnected.emit(id)
	players.erase(id)

###CLIENTCODE
func join_game(address = ""):
	var netPlayerInfoRPC = getPlayerNetworData()
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT+1)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

@rpc("any_peer","call_local","reliable")
func setPlayerReadyRPC(status:bool):
	var peer_id =multiplayer.get_remote_sender_id()
	players[peer_id].ready=status
	player_ready.emit(peer_id,status)
	if multiplayer.is_server():
		if status: 
			playersReadyCount += 1 
		else :
			playersReadyCount-=1

		if playersReadyCount == players.keys().size()-1:
			all_players_ready.emit()#emited only to server
	
func setPlayerReady(status:bool):
	setPlayerReadyRPC.rpc(status)




 
# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func finish_loaded():
	var peer_id = multiplayer.get_remote_sender_id()
	assert(not peer_id==0)
	print('per:',peer_id)
	players_loaded_current.addPlayer(peer_id)
	player_loaded.emit(peer_id)

	if players_loaded_current.loaded == players.size():		
		allPlayerLoaded.rpc_id(1)
			

func closeConnection():
	multiplayer.multiplayer_peer.close()

func addPlayer(peerId, playerInfoRPC):
	var _netPlayerInfo = NetPlayerInfo.new(playerInfoRPC)
	players[peerId] = _netPlayerInfo
	player_connected.emit(peerId, _netPlayerInfo)
	#call_deferred("setPlayerReady",

@rpc("any_peer", "call_remote", "reliable")
func _register_player(new_player_infoRPC):
	assert(new_player_infoRPC)
	var new_player_id = multiplayer.get_remote_sender_id()
	addPlayer(new_player_id, new_player_infoRPC)
	if new_player_id == 1:
		server_joined.emit()

func _on_connected_ok():
	var netPlayerInfoRPC = getPlayerNetworData()
	getPlayerNetworData()
	var peer_id = multiplayer.get_unique_id()
	addPlayer(peer_id, netPlayerInfoRPC)

	#server_joined.emit()





func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func server_disconnects():
	multiplayer.multiplayer_peer = null

	players.clear()
	playersReadyCount=0
	players_loaded_current=PlayersLoaded.new()
	server_disconnected.emit()


 
@rpc("any_peer","call_local","reliable")
func allPlayerLoaded():
	if multiplayer.is_server():
		all_players_loaded.emit()




func getPlayerNetworData():
	var _name = globalData.saveData.playerName
	var _readyStatus =false
	if multiplayer.has_multiplayer_peer():
		var _id = multiplayer.get_unique_id()
		if players.has(_id):
			_readyStatus= players[_id].ready

	return {"name": _name,"ready":_readyStatus}
