extends Node
class_name NetworkPlayerData

@export var dataFetcher:NetworkPlayerDataInterface
func _ready():
	pass#	assert(dataFetcher)


var _dataFetcher: NetworkPlayerDataInterface

func getPlayerName():
	assert(dataFetcher)
	return _dataFetcher.playerName


func loadFetchData():
	assert(dataFetcher)
	var result = _dataFetcher.loadPlayerNetWorkData()
	assert(result, "Error could load Player Data")
