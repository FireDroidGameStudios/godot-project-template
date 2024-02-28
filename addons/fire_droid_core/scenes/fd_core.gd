extends Node


signal scene_changed

const GodotLogoIntroScene = preload("res://addons/fire_droid_core/scenes/logo_intro/godot_logo_intro.tscn")
const FireDroidLogoIntroScene = preload("res://addons/fire_droid_core/scenes/logo_intro/fire_droid_logo_intro.tscn")
const TransitionScene = preload("res://addons/fire_droid_core/scenes/transitions/transition.tscn")

var transition_defaults: Dictionary = {
	"style_in": Transition.TransitionStyle.FADE,
	"trans_type_in": Tween.TRANS_LINEAR,
	"ease_type_in": Tween.EASE_IN,
	"duration_in": 1.2,
	"style_out": Transition.TransitionStyle.FADE,
	"trans_type_out": Tween.TRANS_LINEAR,
	"ease_type_out": Tween.EASE_OUT,
	"duration_out": 1.2,
	"fill_type": Transition.FillType.COLOR,
	"color_1": Color.BLACK,
	"color_2": Color.WHITE,
	"texture_1": null,
	"texture_2": null,
}

var _current_scene = null
var _permanent_nodes: Dictionary = {}

@onready var _permanent_fore_layer = get_node("PermanentForeLayer")
@onready var _temporary_layer = get_node("TemporaryLayer")
@onready var _permanent_back_layer = get_node("PermanentBackLayer")
@onready var _transition_layer = get_node("TransitionLayer")


func _init() -> void:
	# Permanent Back Layer
	var permanent_back_layer: Node = Node.new()
	permanent_back_layer.set_name("PermanentBackLayer")
	# Temporary Layer
	var temporary_layer: Node = Node.new()
	temporary_layer.set_name("TemporaryLayer")
	# Permanent Fore Layer
	var permanent_fore_layer: Node = Node.new()
	permanent_fore_layer.set_name("PermanentForeLayer")
	# Transition Layer
	var transition_layer: Node = Node.new()
	transition_layer.set_name("TransitionLayer")

	add_child(permanent_back_layer)
	add_child(temporary_layer)
	add_child(permanent_fore_layer)
	add_child(transition_layer)


func _ready() -> void:
	get_tree().current_scene.queue_free()	# Experimental
	get_tree().current_scene = self			# Experimental

	await change_scene_to(GodotLogoIntroScene.instantiate(), {"duration_out": 0.8})
	await _current_scene.finished

	await change_scene_to(FireDroidLogoIntroScene.instantiate())
	await _current_scene.finished


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


## Change current scene to [code]scene[/code], applying a transition. Default
## transition values can be overwritten by optional
## [code]override_transition_defaults[/code] values (as a [Dictionary]).
func change_scene_to(scene: Node, override_transition_defaults: Dictionary = {}) -> void:
	log_message("Changing scene to " + str(scene), "gray")
	var transition: Transition = _new_transition(override_transition_defaults)
	_transition_layer.add_child(transition)
	if _current_scene:
		await transition.play()
		clear_children(_temporary_layer)
	else:
		transition.set_forced_status(Transition.Status.OUT)
	_temporary_layer.add_child(scene)
	_current_scene = scene
	log_message("Changed scene to " + str(_current_scene), "gray")
	await transition.play()
	clear_children(_transition_layer)
	scene_changed.emit()


## Load a scene from [code]path[/code] and turn it the current scene, applying a transition.
func change_scene(path: String, override_transition_defaults: Dictionary = {}) -> void:
	if not path.is_valid_filename():
		return
	var packed_scene: PackedScene = load(path) as PackedScene
	await change_scene_to(packed_scene.instantiate(), override_transition_defaults)


## Clear all children of the given node.
func clear_children(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		child.queue_free()


## Update a property of the default transition values. Those values will be using
## every new transition (unless override dictionary is passed as argument of
## transition creation function call).
func set_transition_default_value(property: String, value) -> void:
	if property in transition_defaults.keys():
		transition_defaults[property] = value


## Log a message prefixed with a timestamp of current time of printed message.[br]
## Optional argument [code]color[/code] can be provided to change message color.
## Color values: [code]black[/code], [code]red[/code], [code]green[/code], [code]yellow[/code],
## [code]blue[/code], [code]magenta[/code], [code]pink[/code], [code]purple[/code],
## [code]cyan[/code], [code]white[/code], [code]orange[/code], [code]gray[/code]
func log_message(message: String, color: String = "white") -> void:
	var timestamp: String = Time.get_time_string_from_system()
	print_rich("[color=%s][%s]: %s[/color]" % [color, timestamp, message])


## Adds a new node as permanent. A permanent node is not deleted during scene changes,
## and can only be removed manually by calling [member remove_permanent_node].[br]
## If optional argument [code]overlap_current_scene[/code] value is [code]false[/code],
## the node will be added in the layer that is not overlapped by current scene.[br]
## If [code]id[/code] is already the id of a permanent node, the new node will not be
## added.[br]
## If [code]node[/code] has been added, [code]true[/code] is returned. Otherwise
## [code]false[/code] is returned.
func add_permanent_node(id: String, node: Node, overlap_current_scene: bool = true) -> bool:
	if _permanent_nodes.has(id):
		return false
	_permanent_nodes[id] = node
	if overlap_current_scene:
		_permanent_fore_layer.add_child(node)
	else:
		_permanent_back_layer.add_child(node)
	return true


## If there is a permanent node that matches [code]id[/code], the node is returned.
## Otherwise [code]null[code] is returned.
func get_permanent_node(id: String) -> Node:
	if not has_permanent_node(id):
		return null
	return _permanent_nodes[id]


## Return [code]true[/code] if any permanent node has the given id. Otherwise
## return [code]false[/code].
func has_permanent_node(id: String) -> bool:
	return (id in _permanent_nodes.keys())


## Remove a node from PermanentLayer, by the given id. If it doesn't exists,
## nothing is removed and [code]false[/code] is returned. If id exists,
## [code]true[/code] is returned.[br]
## Set [code]delete_node[/code] to [code]true[/code] to avoid node deletion.
func remove_permanent_node(id: String, delete_node: bool = true) -> bool:
	if not _permanent_nodes.has(id):
		return false
	if delete_node:
		_permanent_nodes[id].queue_free()
	_permanent_nodes.erase(id)
	return true


func _new_transition(override_defaults: Dictionary = {}) -> Transition:
	var transition: Transition = TransitionScene.instantiate()
	for property in transition_defaults.keys():
		transition.set(property, transition_defaults[property])
	for override in override_defaults:
		if override in transition_defaults.keys():
			transition.set(override, override_defaults[override])
	return transition

