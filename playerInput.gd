extends Node
class_name MultiplayerAvatar
enum AVATAR_TYPE { LOCAL_AVATAR, REMOTE_AVATAR, SERVER_AVATAR }

@export var clientPrediction := false
@export var localAvatar: CharacterBody2D
@export var labelName: Label
@export var animationSync: AnimationSync
@onready var key = multiplayer.get_unique_id()

@export var nodesToRemoveFromRemoteAvatar: Array[Node]

@export var syncBuffer: PlayerSyncBufferVector2
var avatarType: AVATAR_TYPE
 

func removeRemoteNodes():
	for x in nodesToRemoveFromRemoteAvatar:
		x.queue_free()


func setLabelName(_str):
	labelName.text = _str
	if avatarType == AVATAR_TYPE.LOCAL_AVATAR:
		labelName.modulate = Color.RED


func setAvatarType(isLocal, isServer: bool):
	var _result: AVATAR_TYPE
	if isLocal:
		_result = AVATAR_TYPE.LOCAL_AVATAR
	else:
		_result = AVATAR_TYPE.REMOTE_AVATAR
		syncBuffer.useBuffer = true

		avatarType = _result
		if not isServer and avatarType== AVATAR_TYPE.REMOTE_AVATAR:
			animationSync.removeAnimationTracks()
			removeRemoteNodes()


func _ready():
	assert(animationSync)
	if not multiplayer.is_server():
		syncBuffer.updatedData.connect(onUpdatePositionNetworkPosition)


func onUpdatePositionNetworkPosition(netWPosition: Vector2):
	var dis = localAvatar.position.distance_to(netWPosition)
	if avatarType == AVATAR_TYPE.LOCAL_AVATAR and dis > 10:
		localAvatar.position = netWPosition
	if avatarType == AVATAR_TYPE.REMOTE_AVATAR:
		localAvatar.position = netWPosition


#local autority code
func _process(delta):
	if multiplayer.is_server():
		syncBuffer.setVector(localAvatar.position)
