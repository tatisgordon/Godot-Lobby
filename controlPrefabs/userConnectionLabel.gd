extends HBoxContainer
class_name  UserConnectionLabel

@export var label:Label
@onready var textureRect:TextureRect=$TextureRect 

func setReady(state:bool):
	if state:
		textureRect.modulate=Color.GREEN
	else:
		textureRect.modulate=Color.WHITE
