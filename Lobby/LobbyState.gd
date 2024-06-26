extends Node
class_name LobbyStateManager
signal all_players_ready()#all players are ready wating for server to start 

var playersReadyCount :=  0


func _ready():
	Lobby.shared_data_updated.connect(onSharedDataUpdated)
	Lobby.connection_successful .connect(onConnected)
	Lobby.server_created .connect(onConnected)
func onConnected():
	
	call_deferred("setName")

func setName():
	chatBox.senderName=Lobby.networkPlayerData.getPlayerName()
func onSharedDataUpdated(peerId,data:Dictionary):
	if data.has("ready"):
		var status = data["ready"]
		if multiplayer.is_server():
			if status: 
				playersReadyCount += 1
			else :
				playersReadyCount-=1

			if playersReadyCount == Lobby.players.keys().size()-1:
				all_players_ready.emit()#emitted only to server