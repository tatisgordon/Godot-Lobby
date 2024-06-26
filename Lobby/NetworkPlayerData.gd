extends Node
class_name NetworkPlayerData
var _dataFetcher: NetworkPlayerDataAbstracts



func setDataFetcher(_d: NetworkPlayerDataAbstracts):
	_dataFetcher = _d


func getDataFetcher():
	return _dataFetcher


func updateNetworkData():
	_dataFetcher.updatePlayerNetworkData()


func getPlayerName():
	return _dataFetcher.serializeData().name


func getPlayerData():
	return _dataFetcher.serializeData()
