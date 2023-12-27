extends Node
class_name GlobalData
const SAVEPATH:String = "user://save"
var savePath
var saveData:SaveData
signal onLoadData(data)
var _instance_num := -1
var _instance_socket: TCPServer 
func _init():
	super._init()
	if OS.is_debug_build():
		_instance_socket = TCPServer.new()
		for n in range(0,4):
			if _instance_socket.listen(5000 + n) == OK:
				_instance_num = n
				break

		assert(_instance_num >= 0, "Unable to determine instance number. Seems like all TCP ports are in use")	
			
		savePath= SAVEPATH+str(_instance_num)+'.res'

func SetsaveData(s:SaveData):
	saveData=s
	print('tosave:',s.playerName)
	saveDataOnDisk()

func saveDataOnDisk():
	var result =ResourceSaver.save(saveData,savePath)
	print('save result',result)
func createSave()->SaveData:
	print('create Save')
	var save:SaveData = SaveData.new()
	save.playerName='newp1'
	var result= ResourceSaver.save(save,savePath)
	
	return save
	
func loadSave()->SaveData:
	var save:SaveData= ResourceLoader.load(savePath)
	if save == null:
		print('save not found')
		save = createSave()
		
	assert(save != null)
	print('data Loaded:',save.playerName)
	
	onLoadData.emit(save)
	saveData = save
	DisplayServer.window_set_title( save.playerName)
	return save
	
	
