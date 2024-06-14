extends NetworkPlayerDataInterface
class_name NetworkPlayerDataConcrete
var saveManager:SaveDataManager
func _init():
	super._init()
	saveManager = saveDataManager

func loadPlayerNetWorkData()->bool:
		var save = saveManager.loadSave()
		var data = {}#n	o data xD save.data  
		playerName=save.playerName
		return playerName != null
	