extends FDProjectManager


func _init() -> void:
	initial_scene = preload("res://addons/fire_droid_core/main.tscn")


func _on_action_triggered(action: StringName, context: StringName = &"") -> void:
	pass
