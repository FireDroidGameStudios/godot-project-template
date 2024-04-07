extends FDProjectManager


var _is_player_movement_enabled: bool = true


func _init() -> void:
	initial_scene = preload("res://tests/scenes/main_menu.tscn")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func disable_player_movement() -> void:
	_is_player_movement_enabled = false


func enable_player_movement() -> void:
	_is_player_movement_enabled = true


func is_player_movement_enabled() -> bool:
	return _is_player_movement_enabled


func _on_action_triggered(action: String, context: String = "") -> void:
	match context:
		"main_screen": _main_screen_handler(action)
		"mode_selection": _mode_selection_handler(action)
		"level": _level_handler(action)
		"success_screen": _success_screen_handler(action)
		"fail_screen": _fail_screen_handler(action)


func _main_screen_handler(action: String) -> void:
	FDCore.cscall("play_animation", [true], true) # Hide menu
	#FDCore.get_current_scene().play_animation() # Another way to hide menu
	match action:
		"play": FDCore.change_scene("res://tests/scenes/mode_selection.tscn")
		"quit": get_tree().quit()


func _mode_selection_handler(action: String) -> void:
	enable_player_movement()
	FDCore.cscall("play_animation", [true], true) # Hide menu
	#FDCore.get_current_scene().play_animation() # Another way to hide menu
	match action:
		"easy": FDCore.change_scene("res://tests/scenes/levels/level_easy.tscn")
		"normal": FDCore.change_scene("res://tests/scenes/levels/level_normal.tscn")
		"hard": FDCore.change_scene("res://tests/scenes/levels/level_hard.tscn")


func _level_handler(action: String) -> void:
	disable_player_movement()
	match action:
		"success": FDCore.change_scene("res://tests/scenes/success_screen.tscn")
		"fail": FDCore.change_scene("res://tests/scenes/fail_screen.tscn")


func _success_screen_handler(action: String) -> void:
	FDCore.cscall("play_animation", [true], true) # Hide menu
	#FDCore.get_current_scene().play_animation() # Another way to hide menu
	match action:
		"return": FDCore.change_scene("res://tests/scenes/main_menu.tscn")
		"quit": get_tree().quit()


func _fail_screen_handler(action: String) -> void:
	FDCore.cscall("play_animation", [true], true) # Hide menu
	#FDCore.get_current_scene().play_animation() # Another way to hide menu
	match action:
		"return": FDCore.change_scene("res://tests/scenes/main_menu.tscn")
		"quit": get_tree().quit()

