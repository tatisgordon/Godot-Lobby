extends Node

@export var startView: Control
@export var serverView: ServerViewController
@export var clientView: Control
@export var userView: Control
@export var loadingPanel: LoadingPanel
@export var nameInput: LineEdit
@export var colorInput: ColorPickerButton
@export var mainMenuPanel: Panel

@export var targetIpLabel: LineEdit
@export var readyButton: Button
@export var startGameButton: Button
@export_file("*.tscn") var gameScene: String  #game scene to load when all players are loaded
var aLoader: AsyncResourceLoader

@onready var viewArray = [clientView, serverView, startView, userView, loadingPanel]


func _ready():
	readyButton.toggled.connect(onReadyButton)
	startGameButton.pressed.connect(OnStartGame)
	Lobby.player_connected.connect(onPlayerConnected)
	Lobby.all_players_loaded.connect(onAllPlayersLoaded)
	Lobby.server_disconnected.connect(server_disconnects)
	Lobby.player_disconnected.connect(onPlayerDisconnected)
	Lobby.connection_to_server_failed.connect(connectionFailed)
	Lobby.connection_to_server_initiated.connect(connectionInitiated)
	Lobby.connection_successful.connect(connectionSuccessful)
	Lobby.shared_data_updated.connect(onSharedDataUpdated)
	Lobby.setNetworkPlayerDataConcrete(NetworkPlayerDataConcrete.new())
	saveDataManager.loadSave() 
	loadingPanel.visible = false
	
	toStartView()


var _currentView: Container


func onSharedDataUpdated(peerId, data: Dictionary):
	if data.has("ready"):
		var status = data["ready"]
		serverView.onPlayerReady(peerId, status)


func connectionInitiated():
	messageController.showMessage("Connecting...", false, cancelConnection, "Cancel")


func connectionSuccessful():
	messageController.closeMessage()
	toServerView()


func cancelConnection():
	Lobby.closeConnection()


func transitToView(toView: Container):
	for view in viewArray:
		view.visible = false
	if _currentView:
		_currentView.visible = false
	_currentView = toView
	toView.visible = true


func _on_server_created(peer_id, player_info):
	toServerView()


func toStartView():
	transitToView(startView)


func createServer():
	Lobby.create_game()
	toServerView()


func connectionFailed():
	messageController.showMessage("Connection to Server Failed")


func toLoadingPanel():
	transitToView(loadingPanel)


func toServerView():
	transitToView(serverView)
	if multiplayer.is_server():
		serverView.toServerMode()
	else:
		serverView.toClientMode()


func toClientView():
	transitToView(clientView)


func toUserView():
	nameInput.text = Lobby.networkPlayerData.getPlayerName()
	colorInput.color = saveDataManager.saveData.color
	transitToView(userView)


func onPlayerConnected(peerId, playerInfo):
	serverView.addUserConnected(peerId, playerInfo)


func onJoinServerButton():
	if Lobby.join_game(targetIpLabel.text) != OK:
		messageController.showMessage("Unable to Join")


func saveData():
	saveDataManager.saveData.playerName = nameInput.text
	saveDataManager.saveData.color = colorInput.color
	saveDataManager.SetSaveData(saveDataManager.saveData)


#func onloadDataa(save):
#	nameInput.text = save.playerName


func _on_save_button_down():
	saveData()
	toStartView()


func onPlayerDisconnected(id):
	readyButton.button_pressed = false


func onCancelServerView():
	Lobby.closeConnection()
	toStartView()


func _on_cancel_button_down():
	toStartView()


func server_disconnects():
	serverView.removeAllUsers()
	readyButton.button_pressed = false
	toStartView()


func _on_server_button_down():
	createServer()


func OnStartGame():
	if multiplayer.is_server():
		Lobby.setNewConnection(false)
		toLoad.rpc()


func onReadyButton(state: bool):
	Lobby.networkPlayerData.getDataFetcher().setReady(state)


@rpc("authority", "call_local", "reliable")
func toLoad():
	toLoadingPanel()
	aLoader = AsyncResourceLoader.new(gameScene, onLoadDone)
	aLoader.loadAsync()


@rpc("authority", "call_local", "reliable")
func toGame():
	get_tree().change_scene_to_file(gameScene)


func onAllPlayersLoaded():
	if multiplayer.is_server():
		await get_tree().create_timer(3).timeout
		toGame.rpc()


func onLoadDone(err, r):
	assert(err == false)
	Lobby.finish_loaded.rpc()
