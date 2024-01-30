extends MultiplayerSynchronizer
class_name PlayerSyncBufferVector2
signal updatedData(remoteVector: Vector2)
@export var remoteVector: Vector2  #synced variable
var _buffer: Array[BufferData] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	synchronized.connect(_sync)
	set_physics_process(true)
	#replication_config.property_list_changed


func setVector(v: Vector2):
	if multiplayer.is_server():
		remoteVector = v



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if multiplayer.is_server():
		pass

		#player.position = lerp(bufferedPos,lastPos,0.5)
	if not multiplayer.is_server():
		if _buffer.size() >= 2:
			var time = Time.get_ticks_msec() - 100
			while _buffer.size() > 2 and time > _buffer[1].timeStamp:
				_buffer.remove_at(0)
			var data0 = _buffer[0]
			var data1 = _buffer[1]

			var aproxTimeGoalTime = data1.timeStamp - data0.timeStamp
			var timeSinceLastUpdate = time - data0.timeStamp

			var lerptime = float(timeSinceLastUpdate) / float(aproxTimeGoalTime)

			remoteVector = lerp(data0.data, data1.data, lerptime)
			updatedData.emit(remoteVector)


func _sync():
	var rtt = multiplayer.multiplayer_peer.get_peer(1).get_statistic(
		ENetPacketPeer.PEER_ROUND_TRIP_TIME
	)

	var data = BufferData.new(remoteVector, Time.get_ticks_msec())
	_buffer.append(data)


class BufferData:
	func _init(d, t):
		data = d
		timeStamp = t

	var data: Vector2
	var timeStamp: int
