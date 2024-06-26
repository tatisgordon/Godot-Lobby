extends NetworkPlayerDataAbstracts
class_name NetworkPlayerDataConcrete
var _ready: bool = false
var saveManager: SaveDataManager


func _init():
	super._init()
	saveManager = saveDataManager


func updatePlayerNetworkData() -> bool:
	data = serializeData()
	playerName = data.name
	return playerName != null


func setReady(state: bool):
	_ready = state
	Lobby.broadcastPlayerData.rpc({"ready": _ready})


func serializeData() -> Dictionary:
	var save = saveManager.saveData
	return {"name": save.playerName, "color": save.color, "ready": _ready}
