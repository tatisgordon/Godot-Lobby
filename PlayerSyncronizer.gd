
extends MultiplayerSynchronizer
class_name  PlayerSyncBuffer

@export var player:Sprite2D
@export var remote_pos:Vector2#synced variable
@export var propertyData:SyncDataCollection
var buffer:Dictionary={}



		
# Called when the node enters the scene tree for the first time.
func _ready():
	for dataKey in propertyData.data.keys():
		var property:PropertyData= propertyData.data[dataKey]
		if property.smothType == PropertyData.SmothType.INTERPOLATION:
			buffer[dataKey] = []

	synchronized.connect(_sync)
	#replication_config.property_list_changed
 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		if  multiplayer.is_server():
			pass#remote_pos = player.position
		if not multiplayer.is_server():
			if (buffer.size()>=2):
					var lastPos :Vector2= buffer[0]
					var bufferedPos:Vector2 = buffer[1]
					#player.position = lerp(bufferedPos,lastPos,0.5)
					player.position = player.position.lerp(lastPos,0.5)

func _sync():
	var rtt = multiplayer.multiplayer_peer.get_peer(1).get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME) # .get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
	#print('rtt',rtt)
	for property in  buffer.keys():
		buffer[property] 
#buffer.push_front(remote_pos)
#if buffer.size()>2:
#	buffer.resize(2)
#

  