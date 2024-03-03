extends FDProjectManager


func _init() -> void:
	set_initial_scene("res://tests/scenes/main_menu.tscn")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _on_action_triggered(action: String, context: String = "") -> void:
	match context:
		"main_screen": _main_screen_handler(action)
		"mode_selection": _mode_selection_handler(action)
		"level": _level_handler(action)
		"success_screen": _success_screen_handler(action)
		"fail_screen": _fail_screen_handler(action)


func _main_screen_handler(action: String) -> void:
	match action:
		"play": FDCore.change_scene("res://tests/scenes/mode_selection.tscn")
		"quit": get_tree().quit()


func _mode_selection_handler(action: String) -> void:
	match action:
		"easy": FDCore.change_scene("res://tests/scenes/levels/level_easy.tscn")
		"normal": FDCore.change_scene("res://tests/scenes/levels/level_normal.tscn")
		"hard": FDCore.change_scene("res://tests/scenes/levels/level_hard.tscn")


func _level_handler(action: String) -> void:
	match action:
		"success": FDCore.change_scene("res://tests/scenes/success_screen.tscn")
		"fail": FDCore.change_scene("res://tests/scenes/fail_screen.tscn")


func _success_screen_handler(action: String) -> void:
	match action:
		"return": FDCore.change_scene("res://tests/scenes/main_menu.tscn")
		"quit": get_tree().quit()


func _fail_screen_handler(action: String) -> void:
	match action:
		"return": FDCore.change_scene("res://tests/scenes/main_menu.tscn")
		"quit": get_tree().quit()
