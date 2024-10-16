class_name FDLoadingScreen
extends Control


signal finished(has_failures: bool, aborted: bool)


func _enter_tree() -> void:
	FDLoad.started.connect(_on_started)
	FDLoad.finished.connect(_on_finished)
	FDLoad.failed.connect(_on_failed)
	FDLoad.progress_changed.connect(_on_progress_changed)


func _exit_tree() -> void:
	FDLoad.started.disconnect(_on_started)
	FDLoad.finished.disconnect(_on_finished)
	FDLoad.failed.disconnect(_on_failed)
	FDLoad.progress_changed.disconnect(_on_progress_changed)


func _on_started() -> void:
	pass


func _on_finished(has_failures: bool) -> void:
	pass


func _on_failed() -> void:
	pass


func _on_progress_changed(progress: float) -> void:
	pass
