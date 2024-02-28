class_name Transition
extends Control


signal started
signal finished

enum Status {
	IN,
	OUT,
}
enum FillType {
	COLOR,
	TEXTURE,
}
enum TransitionStyle {
	FADE,
	#SLIDE_LEFT,
	#SLIDE_RIGHT,
	#SLIDE_UP,
	#SLIDE_DOWN,
	#CIRCLE,
	#DIAMONDS,
	#STRIPPED_LINES,
	#ROUND_SQUARES,
	#SCREENTONE,
	#SAW_LEFT,
	#SAW_RIGHT,
	#SAW_UP,
	#SAW_DOWN,
	#PIXEL_SORTING,
	#BURN,
	#SPIRAL,
	#PIXEL_DISSOLVE,
	#CROSSFADE_CIRCLE,
}

const _Shaders: Dictionary = {
	TransitionStyle.FADE: preload("res://addons/fire_droid_core/shaders/transition_shaders/fade.gdshader"),
}

@export_group("Transition In")
@export var style_in: TransitionStyle = TransitionStyle.FADE
@export var trans_type_in: Tween.TransitionType = Tween.TRANS_LINEAR
@export var ease_type_in: Tween.EaseType = Tween.EASE_IN
@export var duration_in: float = 1.2

@export_group("Transition Out")
@export var style_out: TransitionStyle = TransitionStyle.FADE
@export var trans_type_out: Tween.TransitionType = Tween.TRANS_LINEAR
@export var ease_type_out: Tween.EaseType = Tween.EASE_IN
@export var duration_out: float = 1.2

@export_group("Fill")
@export var fill_type: FillType = FillType.COLOR
@export_subgroup("Color")
@export var color_1: Color = Color.BLACK
@export var color_2: Color = Color.WHITE
@export_subgroup("Texture")
@export var texture_1: CompressedTexture2D = null
@export var texture_2: CompressedTexture2D = null

var _status: Status = Status.IN
var _tween: Tween = null
var _thereshold: float = 0.0

@onready var color_rect = get_node("ColorRect")


func _ready() -> void:
	update_values()


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func update_values() -> void:
	color_rect.material = ShaderMaterial.new()
	_update_shader_style()
	var use_texture: bool = (fill_type == FillType.TEXTURE)
	color_rect.material.set_shader_parameter("color_1", color_1)
	color_rect.material.set_shader_parameter("color_2", color_2)
	color_rect.material.set_shader_parameter("use_texture", use_texture)
	color_rect.material.set_shader_parameter("texture_1", texture_1)
	color_rect.material.set_shader_parameter("texture_2", texture_2)


## Play the transition.
func play() -> void:
	match _status:
		Status.IN:
			await _play_transition(
				ease_type_in, trans_type_in,
				duration_in, _thereshold, 1.0
			)
			finished.emit()
		Status.OUT:
			await _play_transition(
				ease_type_out, trans_type_out,
				duration_out, _thereshold, 0.0
			)
			finished.emit()


## Forces a new status, updating thereshold to maximum (if status is OUT) or
## minimum (if status is IN) value.
func set_forced_status(status: Status) -> void:
	_status = status
	match status:
		Status.IN:
			_set_transition_thereshold(0.0)
		Status.OUT:
			_set_transition_thereshold(1.0)


func _play_transition(
	ease: Tween.EaseType,
	trans: Tween.TransitionType,
	duration: float,
	initial_value: float,
	final_value: float
):
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.set_ease(ease)
	_tween.set_trans(trans)
	_tween.tween_method(_set_transition_thereshold, initial_value, final_value, duration)
	_tween.play()
	started.emit()
	await _tween.finished
	match _status:
		Status.IN:
			_status = Status.OUT
		Status.OUT:
			_status = Status.IN


func _update_shader_style() -> void:
	var style: TransitionStyle = style_in
	var trans_type: Tween.TransitionType = trans_type_in
	var ease_type: Tween.EaseType = ease_type_in
	if _status == Status.OUT:
		style = style_out
		trans_type = trans_type_out
		ease_type = ease_type_out
	var shader: Shader = _Shaders[style].duplicate()
	color_rect.material.shader = shader


func _set_transition_thereshold(thereshold: float) -> void:
	_thereshold = thereshold
	color_rect.material.set_shader_parameter("thereshold", _thereshold)

