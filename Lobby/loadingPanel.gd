extends Container
class_name LoadingPanel

@onready var listPanel: Container = $loading/PlayerList


func _ready():
	Lobby.player_loaded.connect(onPlayerLoaded)


func onPlayerLoaded(peer_id):
	var player = Lobby.players[peer_id]
	assert(player, "player must exists")
	addPlayerToList(player)


func addPlayerToList(player):
	var label = Label.new()
	label.text = player.name
	listPanel.add_child(label)


func cleanList():
	var labels = listPanel.get_children()
	for label in labels:
		label.queue_free()
