class_name AsyncResourceLoader
var _resource:String
var _callback:Callable
var _thread:Thread
func _init(resource:String,c:Callable):
	#super._init()
	_resource= resource
	_thread = Thread.new()
	_callback = c

	
	
func loadAsync():
	assert( ResourceLoader.exists(_resource),'resource not found')
	ResourceLoader.load_threaded_request(_resource)

	_thread.start(checkStatus)
func checkStatus():

	seed(networkPlayerData.getPlayerName().hash())
	var r := randf_range(1,4)
	while true:
		
		#OS.delay_msec(r*1000)
		var res = ResourceLoader.load_threaded_get_status(_resource)
		#var failed = true if ThreadLoadStatus.THREAD_LOAD_FAILED or ThreadLoadStatus.THREAD_LOAD_FAILED else false
		match res :
			[ResourceLoader.THREAD_LOAD_FAILED,ResourceLoader.THREAD_LOAD_INVALID_RESOURCE]:
				_callback.call_deferred('failed',null)
				break
			ResourceLoader.THREAD_LOAD_LOADED:

				var resource = ResourceLoader.load_threaded_get(_resource)
				_callback.call_deferred(false,resource)
				break
		

			
func free():

	_thread.wait_to_finish()
	super.free()
