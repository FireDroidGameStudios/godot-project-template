extends Node


signal started()
signal finished(has_failures: bool)
signal failed()
signal progress_changed(progress: float)


var default_retry_limit: int = 1
var default_cache_mode: ResourceLoader.CacheMode = (
	ResourceLoader.CacheMode.CACHE_MODE_REUSE
)

var abort_on_failure: bool = false
var batch_size: int = 10
var keep_unloaded_on_fail: bool = false
var _load_queue: Array[FDLoadRequest] = []
var _batches: Array[FDLoadBatch] = []
var _current_batch_index: int = 0
var _failure_paths: PackedStringArray = []
var _current_failure_index: int = 0
var _is_loading: bool = false


func _ready() -> void:
	set_process(false)
	set_physics_process(false)


func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	pass


func add_to_queue(
	path: String, type_hint: String = "", use_subthread: bool = true,
	retry_limit: int = default_retry_limit,
	cache_mode: ResourceLoader.CacheMode = default_cache_mode
) -> void:
	if _is_loading:
		FDCore.warning("Cannot add to load queue when loading is in progress.")
		return
	var request: FDLoadRequest = FDLoadRequest.new()
	request.path = path
	request.type_hint = type_hint
	request.use_subthread = use_subthread
	request.retry_limit = retry_limit
	request.cache_mode = cache_mode
	_load_queue.append(request)


func get_queue_paths() -> PackedStringArray:
	var queue_paths: PackedStringArray = []
	queue_paths.resize(_load_queue.size())
	for i: int in _load_queue.size():
		queue_paths[i] = _load_queue[i].path
	return queue_paths


func queue_remove_by_index(index: int) -> void:
	if _is_loading:
		FDCore.warning("Cannot remove from load queue when loading is in progress.")
		return
	_load_queue.remove_at(index)


func queue_remove_by_path(path: String) -> void:
	if _is_loading:
		FDCore.warning("Cannot remove from load queue when loading is in progress.")
		return
	var index: int = _find_request_index_by_path(path)
	if index < 0:
		return
	_load_queue.remove_at(index)


func clear_queue() -> void:
	if _is_loading:
		FDCore.warning("Cannot clear load queue when loading is in progress.")
		return
	for request: FDLoadRequest in _load_queue:
		request.queue_free()
	_load_queue.clear()


func start() -> void:
	if _is_loading:
		FDCore.warning("Cannot start loading when another loading is in progress.")
		return
	_clear_all_batches()
	_is_loading = true
	started.emit()
	if _load_queue.is_empty():
		finished.emit()
		_is_loading = false
		return
	var batches_count: int = ceil(float(_load_queue.size()) / float(batch_size))
	_batches.resize(batches_count)
	for i: int in _batches.size():
		_batches[i] = FDLoadBatch.new(i, _load_queue)
		_batches[i].finished.connect(_on_batch_finished)
		_batches[i].failed.connect(_on_batch_failed)
	_current_batch_index = 0
	_current_failure_index = 0
	_failure_paths.clear()
	add_child(_batches[0])
	await _batches[0].ready
	_batches[0].start_load()


func get_progress() -> float:
	if _load_queue.is_empty():
		return 1.0
	var total_sum: int = 0
	for batch: FDLoadBatch in _batches:
		total_sum += batch.get_progress_sum()
	return float(total_sum) / float(_load_queue.size())


func has_loaded(path: String) -> bool:
	return ResourceLoader.has_cached(path)


func get_loaded(
	path: String,
	type_hint: String = "", use_subthread: bool = true,
	retry_limit: int = default_retry_limit,
	cache_mode: ResourceLoader.CacheMode = default_cache_mode
) -> Resource:
	if ResourceLoader.has_cached(path):
		return ResourceLoader.load_threaded_get(path)
	var error: int = ResourceLoader.load_threaded_request(
		path, type_hint, use_subthread, cache_mode
	)
	if error:
		FDCore.warning("Failed to load resource at \"%s\"." % path)
		return null
	var loaded: Resource = await ResourceLoader.load_threaded_get(path)
	return loaded


func is_loading() -> bool:
	return _is_loading


func get_failure_paths() -> PackedStringArray:
	return _failure_paths


func _find_request_index_by_path(path: String) -> int:
	var index: int = 0
	for request: FDLoadRequest in _load_queue:
		if request.path == path:
			return index
		index += 1
	return -1


func _append_failure(path: String) -> void:
	_failure_paths[_current_failure_index] = path
	_current_failure_index += 1


func _abort_all_batches() -> void:
	for batch: FDLoadBatch in _batches:
		batch.abort()


func _clear_all_batches(free_requests: bool = false) -> void:
	if _is_loading:
		FDCore.warning("Cannot clear batches when loading is in progress.")
		return
	for batch: FDLoadBatch in _batches:
		batch.clear(free_requests)
		batch.queue_free()
	_batches.clear()


func _on_batch_finished() -> void:
	remove_child(_batches[_current_batch_index])
	_current_batch_index += 1
	if _current_batch_index >= _batches.size():
		finished.emit()
		_clear_all_batches(true)
		_load_queue.clear()
		_is_loading = false
		return
	add_child(_batches[_current_batch_index])
	await _batches[_current_batch_index].ready
	_batches[_current_batch_index].start_load()


func _on_batch_failed(_failure_batch: FDLoadBatch) -> void:
	var can_clear_requests: bool = (not keep_unloaded_on_fail)
	_failure_batch.clear(can_clear_requests)
	if abort_on_failure:
		_clear_all_batches(can_clear_requests)
		failed.emit()
		return


class FDLoadRequest extends Node:
	signal finished()
	signal failed()
	signal progress_changed(previous_progress: int, current_progress: int)


	var path: String = ""
	var type_hint: String = ""
	var use_subthread: bool = true
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
		for i: int in retry_limit:
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
	signal finished(batch: FDLoadBatch)
	signal failed(batch: FDLoadBatch)
	signal progress_sum_changed(progress_sum: int)


	var _requests: Array[FDLoadRequest] = []
	var _is_aborted: bool = false
	var _progress_sum: int = 0
	var _finished_count: int = 0


	func _init(batch_index: int, load_queue: Array[FDLoadRequest]) -> void:
		_requests = load_queue.slice(batch_index, FDLoad.batch_size)


	func _ready() -> void:
		set_process(false)
		set_physics_process(false)
		for request: FDLoadRequest in _requests:
			add_child(request)
			request.finished.connect(_on_request_finished)
			request.progress_changed.connect(_on_request_progress_changed)


	func abort() -> void:
		_is_aborted = true


	func clear(free_requests: bool = false) -> void:
		if free_requests:
			for request: FDLoadRequest in _requests:
				request.queue_free()
		_requests.clear()


	func get_progress_sum() -> int:
		return _progress_sum


	func start_load() -> void:
		if _is_aborted:
			return
		for request: FDLoadRequest in _requests:
			request.start_load()


	func has_finished() -> bool:
		return _finished_count == _requests.size()


	func _on_request_finished() -> void:
		_finished_count += 1
		if _finished_count == _requests.size():
			finished.emit(self)


	func _on_request_failed(request: FDLoadRequest) -> void:
		FDLoad._append_failure(request.path)
		if FDLoad.abort_on_failure:
			failed.emit(self)
			return


	func _on_request_progress_changed(
		previous_progress: float, current_progress: float
	) -> void:
		_progress_sum += current_progress - previous_progress
		progress_sum_changed.emit(_progress_sum)
