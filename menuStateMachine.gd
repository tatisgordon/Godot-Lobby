extends Node

@export var startView: Control
@export var serverView: ServerViewController
@export var clientView: Control
@export var userView: Control
@export var loadingPanel: LoadingPanel
@export var nameInput: LineEdit
@export var mainMenuPanel: Panel

@export var targetIpLabel: LineEdit
@export var readyButton: Button
@export var startGameButton: Button
@export_file("*.tscn") var gameScene: String
var aLoader: AsyncResourceLoader

@onready var viewArray = [
 clientView
, serverView
, startView
, userView
, loadingPanel
]



func _ready():

	toStartView()
	readyButton.toggled.connect(onReadyButton)
	startGameButton.pressed.connect(OnStartGame)
	Lobby.player_connected.connect(onPlayerConnected)
	Lobby.all_players_loaded.connect(onAllPlayersLoaded)
	Lobby.server_disconnected.connect(server_disconnects)
	#Lobby.player_disconnected.connect(onPlayerDisconnected)
	globalData.onLoadData.connect(onloadDataa)
	globalData.loadSave()
	loadingPanel.visible = false
	#print(ResourceLoader.has_cached(gameScene))


var _currentView:Container
func transitToView(toView:Container):
	print('transit start')
	for view in viewArray :		
		view.visible = false
	if _currentView:
		_currentView.visible=false
	_currentView=toView
	toView.visible=true
	print('transit finish')

		
func _on_server_created(peer_id, player_info):
	toServerView()



func toStartView():
	transitToView(startView)
	

func createServer():

	Lobby.create_game()
	toServerView()
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
	nameInput.text = globalData.saveData.playerName
	transitToView(userView)

func onPlayerConnected(peerId, playerInfo: NetPlayerInfo):
	serverView.addUserConnected(peerId, playerInfo)

func onjoinServerButton():
	Lobby.join_game(targetIpLabel.text)
	toServerView()

func saveData():
	var save: SaveData = globalData.saveData
	assert(save)
	save.playerName = nameInput.text
	globalData.SetsaveData(save)

func onloadDataa(save):
	nameInput.text = save.playerName

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
	toStartView()

func _on_server_button_down():
	createServer()
func OnStartGame():
	if multiplayer.is_server():
		Lobby.setNewConnection(false)
		toLoad.rpc()

func onReadyButton(state: bool):
	Lobby.setPlayerReady(state)


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
		toGame.rpc()

func onLoadDone(err, r):
	assert(err == false)
	Lobby.finish_loaded.rpc()
	#aLoader.call_deferred("free")
