@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("FDCore", "res://addons/fire_droid_core/scenes/fd_core.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("FDCore")
