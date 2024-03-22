#autoload
extends Node
class_name NetworkPlayerData

func setDataFetcher(_d: NetworkPlayerDataInterface):
	_dataFetcher = _d


var _dataFetcher: NetworkPlayerDataInterface


func getPlayerName():
	assert(_dataFetcher)
	return _dataFetcher.playerName


func loadFetchData():
	assert(_dataFetcher)
	var result = _dataFetcher.loadPlayerNetWorkData()
	assert(result, "Error could load Player Data")
