#autoload saveDataManager
extends Node
class_name SaveDataManager

const SAVE_PATH: String = "user://save"
var savePath
var saveData: SaveData
var _windwsId: WindowsInstanceId
signal onLoadData(data)


func _ready():
	_windwsId = WindowsInstanceId.new()

	var y = 0 if _windwsId._instance_num % 2 == 0 else 600
	#get_window().position = Vector2i(600 *  _windwsId._instance_num, y)
	get_window().position = Vector2i(600 * _windwsId._instance_num, y)

	savePath = SAVE_PATH + str(_windwsId._instance_num) + ".res"


#	assert(saveDataManager,'save datamanager autoload missing')


func SetSaveData(s: SaveData):
	saveData = s

	saveDataOnDisk()


func saveDataOnDisk():
	var result = ResourceSaver.save(saveData, savePath)


func createSave() -> SaveData:
	var save: SaveData = SaveData.new()
	save.playerName = "playerName"
	save.color = Color.WHITE
	var result = ResourceSaver.save(save, savePath)

	return save


func loadSave() -> SaveData:
	var save: SaveData = ResourceLoader.load(savePath)
	if save == null:
		save = createSave()

	assert(save != null)

	onLoadData.emit(save)
	saveData = save
	DisplayServer.window_set_title(save.playerName)
	return save
