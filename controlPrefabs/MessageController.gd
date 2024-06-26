extends CanvasLayer
class_name MessageController
@export var label: Label
@export var acceptButton: Button
@export var animation: AnimationPlayer


func showMessage(message: String, hideButton = false, onAccept: Callable = closeMessage, text: String = "Accept"):
	for connections in acceptButton.pressed.get_connections():
		acceptButton.pressed.disconnect(connections.callable)
	acceptButton.pressed.connect(onAccept)
	label.text = message
	acceptButton.text = text
	acceptButton.visible = not hideButton

	animation.play("start")


func closeMessage():
	animation.play("start", -1, -1, true)
