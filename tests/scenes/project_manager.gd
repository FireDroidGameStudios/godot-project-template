extends FDProjectManager


func _init() -> void:
	initial_scene = preload("res://tests/scenes/loading_screen.tscn")


func _on_action_triggered(action: StringName, context: StringName = &"") -> void:
	pass
