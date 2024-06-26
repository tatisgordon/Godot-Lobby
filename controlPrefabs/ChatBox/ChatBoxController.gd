extends Node
class_name ChatBoxController
const CONTAINER_MIN_SIZE = 25
const CONTAINER_MAX_SIZE = 150
const DISCONNECTED_TEXT_TITLE = "Disconnected from Server"
const CONNECTED_TEXT_ = "%s Connected"

@export var inputText: LineEdit
@export var richText: RichTextLabel
@export var minimizeButton: Button
@export var title: Label

@export var chatAnimationComp: ChatAnimationComponent

var isCollapsed: bool
var senderName: String = "no name Set"  # set the Senders Names


func _ready():
	inputText.text_submitted.connect(onTextSubmitted)
	minimizeButton.disabled = true
	append_chat_line_system("Hello world!")
	minimizeButton.toggled.connect(onMinimizeToggled)
	onMinimizeToggled(false)
	Lobby.server_created.connect(onConnectedToServer)
	Lobby.server_joined.connect(onConnectedToServer)
	Lobby.server_disconnected.connect(server_disconnects)
	Lobby.player_disconnected.connect(onPlayerDisconnected)
	Lobby.player_connected.connect(onPlayerConnected)


func onPlayerConnected(id, info):
	sendTextSystem(CONNECTED_TEXT_ % info.name)


func onConnectedToServer():
	minimizeButton.disabled = false
	title.text = "Connected to: %s" % Lobby.players[1].name


func onMinimizeToggled(status: bool):
	inputText.visible = status
	richText.visible = status
	isCollapsed = not status
	if status:
		chatAnimationComp.playReset()


func onTextSubmitted(_string: String):
	if _string.length() <= 0:
		return
	inputText.clear()
	sendText.rpc(senderName, _string)


func notification_message():
	chatAnimationComp.playNotificationAnimation()


@rpc("any_peer", "call_local", "reliable")
func sendText(user, _string):
	if not multiplayer.get_remote_sender_id() == multiplayer.get_unique_id():
		if isCollapsed:
			notification_message()
	append_chat_line_escaped(user, _string)


@rpc("authority", "call_local", "reliable")
func sendTextSystem(_string):
	append_chat_line_system(_string)


# Returns escaped BBCode that won't be parsed by RichTextLabel as tags.
func escape_bbcode(bbcode_text):
	# We only need to replace opening brackets to prevent tags from being parsed.
	return bbcode_text.replace("[", "[lb]")


# Appends the user's message as-is, without escaping. This is dangerous!
func append_chat_line_system(message):
	richText.append_text("[b][color=red]%s:[/color][/b] %s\n" % ["System", message])


# Appends the user's message with escaping.
# Remember to escape both the player name and message contents.
func append_chat_line_escaped(username, message):
	richText.append_text("[b]%s[/b]: %s\n" % [escape_bbcode(username), escape_bbcode(message)])


func onPlayerDisconnected(id):
	var _name = Lobby.players[id].name
	sendTextSystem("%s disconnected" % _name)


func server_disconnects():
	title.text = DISCONNECTED_TEXT_TITLE
	minimizeButton.button_pressed = false
	onMinimizeToggled(false)
	minimizeButton.disabled = true
