extends HBoxContainer
class_name UserConnectionLabel

@export var label: Label
@onready var disconnectedTexture: TextureRect = $DisconnectedTexture
@onready var connectedTexture: TextureRect = $ConnectedTexture


func setReady(state: bool):
	disconnectedTexture.visible = !state
	connectedTexture.visible = state
