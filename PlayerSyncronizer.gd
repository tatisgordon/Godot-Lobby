extends MultiplayerSynchronizer
class_name  PlayerSyncBuffer
@export var player:Sprite2D
@export var remote_pos:Vector2#synced variable

var buffer:Array[Vector2] =[]
# Called when the node enters the scene tree for the first time.
func _ready():
	synchronized.connect(_sync)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if  multiplayer.is_server():
		remote_pos = player.position
	if not multiplayer.is_server():
		if (buffer.size()>=2):
				var lastPos :Vector2= buffer[0]
				var bufferedPos:Vector2 = buffer[1]	
				#player.position = lerp(bufferedPos,lastPos,0.5)
				player.position = player.position.lerp(lastPos,0.5)

func _sync():
	var rtt = multiplayer.multiplayer_peer.get_peer(1).get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME) # .get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
	#print('rtt',rtt)
	buffer.push_front(remote_pos)
	if buffer.size()>2:
		buffer.resize(2)
