#autoload saveDataManager
extends Node
class_name SaveDataManager

const SAVEPATH: String = "user://save"
var savePath
var saveData: SaveData
var _windwsId:WindowsIntanceId
signal onLoadData(data)

func _ready():
	print('readt')
	_windwsId= WindowsIntanceId.new()
	
	var y = 0 if _windwsId._instance_num % 2 == 0 else 600
	#get_window().position = Vector2i(600 *  _windwsId._instance_num, y)
	get_window(). position=Vector2i(600 * _windwsId._instance_num, y)

	savePath = SAVEPATH + str(_windwsId._instance_num) + ".res"
	print(savePath)
#	assert(saveDataManager,'save datamanager autoload missing')

func SetsaveData(s: SaveData):
	saveData = s
	print("tosave:", s.playerName)
	saveDataOnDisk()


func saveDataOnDisk():
	var result = ResourceSaver.save(saveData, savePath)
	print("save result", result)


func createSave() -> SaveData:
	print("create Save")
	var save: SaveData = SaveData.new()
	save.playerName = "newp1"
	var result = ResourceSaver.save(save, savePath)

	return save


func loadSave() -> SaveData:
	print(savePath)
	var save: SaveData = ResourceLoader.load(savePath)
	if save == null:
		print("save not found")
		save = createSave()

	assert(save != null)
	print("data Loaded:", save.playerName)

	onLoadData.emit(save)
	saveData = save
	DisplayServer.window_set_title(save.playerName)
	return save
