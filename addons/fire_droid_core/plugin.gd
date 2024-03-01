@tool
extends EditorPlugin


const SettingsRoot: String = "fd_core/"


func _enter_tree() -> void:
	add_autoload_singleton("FDCore", "res://addons/fire_droid_core/scenes/fd_core.gd")
	_update_custom_settings()


func _exit_tree() -> void:
	remove_autoload_singleton("FDCore")


func _update_custom_settings() -> void:
	# Format -> "setting_name": "default_value"
	const custom_settings: Array[Dictionary] = [
		{
			"name": "fd_core/project_manager",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_FILE,
			"hint_string": "*.gd",
		}
	]
	for setting in custom_settings:
		var setting_name: String = setting.get("name")
		if not ProjectSettings.has_setting(setting_name):
			ProjectSettings.set_setting(setting_name, "")
			ProjectSettings.add_property_info(setting)
			ProjectSettings.set_initial_value(setting_name, "")
