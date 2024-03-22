extends MultiplayerSynchronizer
class_name PlayerSyncBufferVector2
signal updatedData(remoteVector: Vector2)
@export var remoteVector: Vector2  #synced variable
var _buffer: Array[BufferData] = []
var useBuffer :=false
const EXPECTED_LATENCY=300 #const the higher the lag increase but its more stable


# Called when the node enters the scene tree for the first time.
func _ready():
	synchronized.connect(_sync)
	set_physics_process(true)
	#useBuffer=multiplayer.is
	#replication_config.property_list_changed


func setVector(v: Vector2):
	if multiplayer.is_server():
		remoteVector = v


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not useBuffer:
		return
	if multiplayer.is_server():
		pass#return

		#player.position = lerp(bufferedPos,lastPos,0.5)
	else:
		if _buffer.size() >= 2:
			var time = Time.get_ticks_msec() - EXPECTED_LATENCY#
			while _buffer.size() > 2 and time > _buffer[1].timeStamp:
				_buffer.remove_at(0)
			var data0 = _buffer[0]
			var data1 = _buffer[1]

			var aproxTimeGoalTime = data1.timeStamp - data0.timeStamp
			var timeSinceLastUpdate = time - data0.timeStamp

			var lerptime = float(timeSinceLastUpdate) / float(aproxTimeGoalTime)

			var bufferedRemoteVector = lerp(data0.data, data1.data, lerptime)
			updatedData.emit(bufferedRemoteVector)


func _sync():
	var rtt = multiplayer.multiplayer_peer.get_peer(1).get_statistic(
		ENetPacketPeer.PEER_ROUND_TRIP_TIME
	)
	if not useBuffer:
		updatedData.emit(remoteVector)
		return
	var data = BufferData.new(remoteVector, Time.get_ticks_msec())
	_buffer.append(data)


class BufferData:
	func _init(d, t):
		data = d
		timeStamp = t

	var data: Vector2
	var timeStamp: int
