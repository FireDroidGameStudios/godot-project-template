extends Node


var default_retry_limit: int = 1
var default_cache_mode: ResourceLoader.CacheMode = (
	ResourceLoader.CacheMode.CACHE_MODE_REUSE
)
var batch_size: int = 10


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func get_requests_count() -> int:
	return 0


class FDLoadRequest extends Node:
	signal finished()
	signal failed()
	signal progress_changed(previous_progress: int, current_progress: int)


	var path: String = ""
	var use_subthread: bool = true
	var type_hint: String = ""
	var retry_limit: int = FDLoad.default_retry_limit
	var cache_mode: ResourceLoader.CacheMode = FDLoad.default_cache_mode
	var _current_progress: int = 0
	var _progress_array: Array = [0.0]
	var _previous_progress: int = 0


	func _ready() -> void:
		set_process(false)
		set_physics_process(false)


	func _process(_delta: float) -> void:
		if not _previous_progress == _current_progress:
			progress_changed.emit(_previous_progress, _current_progress)
		if is_loaded():
			finished.emit()
			set_process(false)


	func get_progress() -> float:
		return _progress_array[0]


	func start_load() -> void:
		if path.is_empty():
			_progress_array[0] = 1.0
			_current_progress = 100
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
		_previous_progress = _current_progress
		var load_status: int = (
			ResourceLoader.load_threaded_get_status(path, _progress_array)
		)
		_current_progress = int(_progress_array[0] * 100)
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


class FDLoadBatch extends Node:
	signal finished()
	signal failed()
	signal progress_sum_changed(progress_sum: int)


	var _requests: Array[FDLoadRequest] = []
	var _is_aborted: bool = false
	var _has_started: bool = false
	var _progress_sum: int = 0
	var _finished_count: int = 0


	func _init(batch_index: int, load_queue: Array[FDLoadRequest]) -> void:
		_requests = load_queue.slice(batch_index, FDLoad.batch_size)


	func _ready() -> void:
		set_process(false)
		set_physics_process(false)
		for request in _requests:
			add_child(request)
			request.finished.connect(_on_request_finished)
			request.progress_changed.connect(_on_request_progress_changed)


	func abort() -> void:
		_is_aborted = true


	func get_progress_sum() -> int:
		return _progress_sum


	func start_load() -> void:
		if _is_aborted:
			return
		for request in _requests:
			request.start_load()


	func has_finished() -> bool:
		return _finished_count == _requests.size()


	func _on_request_finished() -> void:
		_finished_count += 1
		if _finished_count == _requests.size():
			finished.emit()


	func _on_request_progress_changed(
		previous_progress: float, current_progress: float
	) -> void:
		_progress_sum += current_progress - previous_progress
		progress_sum_changed.emit(_progress_sum)
