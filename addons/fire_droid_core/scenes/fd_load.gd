extends Node


var abort_on_failure: bool = false


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


class FDLoadRequest extends Node:
	signal finished()
	signal failed()


	var path: String = ""
	var use_subthread: bool = true
	var cache_mode: ResourceLoader.CacheMode = (
		ResourceLoader.CacheMode.CACHE_MODE_REUSE
	)
	var type_hint: String = ""
	var retry_limit: int = 1
	var _progress: Array = [0.0]


	func _ready() -> void:
		set_process(false)
		set_physics_process(false)


	func _process(_delta: float) -> void:
		if is_loaded():
			finished.emit()
			set_process(false)


	func get_progress() -> float:
		return _progress[0]


	func start_load() -> void:
		if path.is_empty():
			_progress[0] = 1.0
			finished.emit()
			return
		elif is_loaded():
			finished.emit()
			return
		if _request_load():
			return
		elif FDLoad.abort_on_failure:
			failed.emit()
			return
		for i in retry_limit:
			if _request_load():
				return
		failed.emit()


	func is_loaded() -> bool:
		var load_status: int = (
			ResourceLoader.load_threaded_get_status(path, _progress)
		)
		return (
			load_status == ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED
		)


	func _request_load() -> bool:
		var error: int = ResourceLoader.load_threaded_request(
			path, type_hint, use_subthread, cache_mode
		)
		if not error:
			set_process(true)
			return true
		return false
