extends PanelContainer
class_name chatBoxController
const CONTAINER_MIN_SIZE= 25
const CONTAINER_MAX_SIZE= 150
const DISCONECTED_TEXT_TITLE='Disconected from Server'
const CONNECTED_TEXT_="%s Connected"

@export var inputText:LineEdit
@export var richText:RichTextLabel
@export var minimuzeButton:Button
@export var title:Label

func _ready():
	inputText.text_submitted.connect(onTextSubmited)
	minimuzeButton.disabled= true
	append_chat_line_system("Hello world!")
	minimuzeButton.toggled.connect(onMinimizeToggled)
	onMinimizeToggled(false)
	Lobby.server_created.connect(_on_peer_connected)
	Lobby.server_joined.connect(_on_peer_connected)
	Lobby.server_disconnected.connect(server_disconnects)
	Lobby.player_disconnected.connect(onPlayerDisconnected)
	Lobby.player_connected.connect(onPlayerConnected)

	
	

func onPlayerConnected(id,info:NetPlayerInfo):
	sendTextSystem(CONNECTED_TEXT_ % info.name)
func _on_peer_connected():

	minimuzeButton.disabled=false

	title.text = "Connected to: %s"% Lobby.players[1].name
	#minimuzeButton.emit_signal("pressed")
func onMinimizeToggled(status:bool):

	inputText.visible = status
	richText.visible= status
	#var _toSize = CONTAINER_MAX_SIZE if status else CONTAINER_MIN_SIZE

	#size.y = _toSize
	#set_anchors_preset(PRESET_BOTTOM_RIGHT,false)
	#reset_size()
	
	#await get_tree().create_timer(2).timeout
	#call_deferred("set_anchors_preset",PRESET_BOTTOM_LEFT,true)




func onTextSubmited(_string):

	inputText.clear()
	sendText.rpc(globalData.saveData.playerName,_string)

@rpc("any_peer","call_local","reliable")
func sendText(user,_string):
	append_chat_line_escaped(user,_string)

@rpc("authority","call_local","reliable")
func sendTextSystem(_string):
	append_chat_line_system(_string)

# Returns escaped BBCode that won't be parsed by RichTextLabel as tags.
func escape_bbcode(bbcode_text):
	# We only need to replace opening brackets to prevent tags from being parsed.
	return bbcode_text.replace("[", "[lb]")


# Appends the user's message as-is, without escaping. This is dangerous!
func append_chat_line_system( message):
	richText.append_text("[b][color=red]%s:[/color][/b] %s\n" % ['System', message])


# Appends the user's message with escaping.
# Remember to escape both the player name and message contents.
func append_chat_line_escaped(username, message):
	richText.append_text("[b]%s[/b]: %s\n" % [escape_bbcode(username), escape_bbcode(message)])
func onPlayerDisconnected(id):
	var _name = Lobby.players[id].name
	sendTextSystem('%s disconncted'% _name)
func server_disconnects():
	title.text=DISCONECTED_TEXT_TITLE
	onMinimizeToggled(false)
	minimuzeButton.disabled=true
