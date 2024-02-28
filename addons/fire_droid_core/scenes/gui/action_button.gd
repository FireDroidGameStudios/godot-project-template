class_name ActionButton
extends Button


@export var parent_hud: ActionHUD = null

@export_group("Actions")
@export var action_on_pressed: String = "" ## Leave empty to ignore.
@export var action_on_release: String = ""  ## Leave empty to ignore.
@export var action_on_button_down: String = ""  ## Leave empty to ignore.
@export var action_on_button_up: String = ""  ## Leave empty to ignore.
@export var action_on_toggled_true: String = ""  ## Leave empty to ignore.
@export var action_on_toggled_false: String = ""  ## Leave empty to ignore.


func _ready() -> void:
	_connect_signals()


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _connect_signals() -> void:
	if not parent_hud:
		return
	button_down.connect(parent_hud.trigger_action.bind(action_on_button_down))
	button_up.connect(parent_hud.trigger_action.bind(action_on_button_up))
	pressed.connect(parent_hud.trigger_action.bind(action_on_pressed))


func _trigger_action_on_toggled(toggled_on: bool) -> void:
	if not parent_hud:
		return
	if toggled_on:
		if not action_on_toggled_true.is_empty():
			parent_hud.trigger_action(action_on_toggled_true)
	else:
		if not action_on_toggled_false.is_empty():
			parent_hud.trigger_action(action_on_toggled_false)
