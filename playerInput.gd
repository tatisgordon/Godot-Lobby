extends Sprite2D
@export var speed:float = 10

func _process(delta):
    var mov:Vector2=  Input.get_vector("ui_left","ui_right","ui_up","ui_down")

    position+= mov*speed


func setColor(c:Color):
    modulate =c