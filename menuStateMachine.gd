extends Node

@export var startView:Control
@export var serverView:ServerViewController
@export var clientView:Control
@export var userView:Control

@export var nameInput:LineEdit

@export var targetIpLabel:LineEdit
func _ready():

	toStartView()
	
	Lobby.player_connected.connect(onPlayerConnected)
	Lobby.server_disconnected.connect(server_disconnects)
	Lobby.player_disconnected.connect(onPlayerDisconnected)
	globalData.onLoadData.connect(onloadDataa)
	globalData.loadSave()
	


func _on_server_created(peer_id, player_info):
	toServerView()

func toStartView():
	startView.visible=true
	serverView.visible=false
	clientView.visible=false
	userView.visible=false
func createServer():
	startView.visible=false
	serverView.visible=true
	clientView.visible=false
	userView.visible=false
	Lobby.create_game()
func toServerView():	
	startView.visible=false
	serverView.visible=true
	clientView.visible=false
	userView.visible=false
	if not multiplayer.is_server():
		serverView.toClientMode()
func toClientView():
	clientView.visible=true
	serverView.visible=false
	startView.visible=false
	userView.visible=false
func toUserView():
	nameInput.text=globalData.saveData.playerName

	userView.visible=true
	startView.visible=false
	serverView.visible=false
	clientView.visible=false
func onPlayerConnected(peerId,playerInfo:NetPlayerInfo):
	if multiplayer.is_server():
		pass#print('playerConected'+ playerInfo.name)
		
	print('on conected	',globalData.saveData.playerName,' to-> ',playerInfo.name)
	serverView.addUserConnected(peerId,playerInfo)

func onjoinServerButton():
	Lobby.join_game(targetIpLabel.text)
	toServerView()

func saveData():
	var save:SaveData =globalData.saveData
	assert(save)
	save.playerName = nameInput.text
	globalData.SetsaveData(save)

func onloadDataa(save):
	nameInput.text=save.playerName

func _on_save_button_down():
	saveData()
	toStartView()

func onPlayerDisconnected(id):
	serverView.removeUserConnected(id)

func onCancelServerView():
	Lobby.closeConnection()
	toStartView()

func _on_cancel_button_down():
	toStartView()

func server_disconnects():
	#Lobby.server_disconnects()
	serverView.removeAllusers()
func _on_server_button_down():
	createServer()
func OnStartGame():
	Lobby.setNewConnection(false)
func onReadyButton():
	
