extends RefCounted
class_name PlayersLoaded
var loaded := 0
var loadedPlayers: Dictionary = {}


func addPlayer(peer_id):
	loaded = loaded + 1
	loadedPlayers[peer_id] = true


func removePlayer(peer_id):
	loaded = loaded - 1
	loadedPlayers.erase(peer_id)
