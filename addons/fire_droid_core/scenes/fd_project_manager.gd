class_name FDProjectManager
extends Node


# A Project Manager must inherit from this class.

## FDCore will auto change to this scene after logo intros animation.
var initial_scene: PackedScene = null


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


## This method can handle actions triggered by FDCore or an ActionHUD.
## [param action] is the action received, [param context] is an optional
## argument that can be used to distinguish actions with same name.[br][br]
## To change how this function handles actions, override [method _on_action_triggered].
func on_action_triggered(action: String, context: String = "") -> void:
	_on_action_triggered(action, context)


## Load a scene located at [param path] and assign it to [member initial_scene].
## If [param path] is not valid path to a scene, [memeber initial_scene]
## receives [code]null[/code] as value.
func set_initial_scene(path: String) -> void:
	initial_scene = load(path)


## This is an overridable method.[br][br]
## This method can be used to handle actions triggered by FDCore or an ActionHUD.
## [param action] is the action received, [param context] is an optional
## argument that can be used to distinguish actions with same name.
## [codeblock]
## func _on_action_triggered(action: String, context: String = "") -> void:
##     match context:
##          "main_screen": _main_screen_handler(action)
##          "level": _level_handler(action)
##
## func _main_screen_handler(action: String) -> void:
##     match action:
##         "play": FDCore.change_scene_to("res://scenes/first_level.gd")
##         "load": SaveSystem.load_game()
##         "quit": get_tree().quit() # Same action, different context
##
## func _level_handler(action: String) -> void:
##     match action:
##         "pause": level.pause()
##         "unpause": level.unpause()
##         "quit": FDCore.change_scene_to("res://scenes/main_screen.gd") # Same action, different context
## [/codeblock]
func _on_action_triggered(action: String, context: String = "") -> void:
	pass
