extends Node
class_name  ChatAnimationComponent


@export var animationPlayer:AnimationPlayer

func _ready():
	animationPlayer.play('RESET')
	animationPlayer.animation_finished.connect(onAnimationFinish)
func onAnimationFinish(anim_name):
	if not anim_name  =='RESET':
		pass
func playNotificationAnmiation():
	if not animationPlayer.is_playing():
		animationPlayer.play('notification_message',-1,2)
func playReset():
	animationPlayer.play('RESET')

		
		
