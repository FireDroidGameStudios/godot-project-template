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


## This is an overridable function. Use this to do any call when an action is
## received from hud or core. [code]action[/code] is the action received.
## [codeblock]
## func _on_action_received(action: String) -> void:
##     match action:
##	        "play": FDCore.change_scene_to("res://scenes/start_scren.gd")
##	        "load": SaveSystem.load_game()
##	        "quit": get_tree().quit()
## [/codeblock]
func _on_action_received(action: String) -> void:
	pass
