class_name DefaultHUD
extends CanvasLayer


signal action_triggered(action_name: String)
signal animation_finished(state_is_out: bool)

enum AnimationStyle {
	NO_ANIMATION,
	SLIDE_TO_RIGHT,
	SLIDE_TO_LEFT,
	SLIDE_TO_UP,
	SLIDE_TO_BOTTOM,
}
enum _AnimationState { IN = 0, OUT = 1 }
const DefaultAnimationDuration: float = 1.2
const DefaultAutohideDelay: float = 1.5

var _animation_state: _AnimationState = _AnimationState.IN
var _tween: Tween = null

@export_group("Animation In")
@export var animation_in: AnimationStyle = AnimationStyle.NO_ANIMATION
@export_range(0.0, 10.0, 0.05, "or_greater") var duration_in: float = DefaultAnimationDuration
@export var ease_in: Tween.EaseType = Tween.EASE_OUT
@export var transition_in: Tween.TransitionType = Tween.TRANS_CUBIC

@export_group("Animation Out")
@export var animation_out: AnimationStyle = AnimationStyle.NO_ANIMATION
@export_range(0.0, 10.0, 0.05, "or_greater") var duration_out: float = DefaultAnimationDuration
@export var ease_out: Tween.EaseType = Tween.EASE_OUT
@export var transition_out: Tween.TransitionType = Tween.TRANS_CUBIC

@export_group("More Options")
@export var enable_autohide: bool = false
@export_range(0.0, 10.0, 0.01, "or_greater") var autohide_delay: float = DefaultAutohideDelay

func _ready() -> void:
	_set_initial_offset()
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


# Snippet for escape keypress
#func _input(event: InputEvent) -> void:
	#if event is InputEventKey:
		#var is_just_pressed: bool = event.is_pressed() and not event.is_echo()
		#if event.keycode == KEY_ESCAPE and is_just_pressed:
			#play_transition()


func play_transition(animated: bool = true) -> void:
	if enable_autohide:
		if autohide_delay > 0.0:
			if _animation_state == _AnimationState.IN:
				await _play_single_transition(animated)
			await get_tree().create_timer(autohide_delay).timeout
		elif _animation_state == _AnimationState.OUT:
			return
	else:
		await _play_single_transition(animated)


func trigger_action(action_name: String) -> void:
	if action_name.is_empty():
		return
	action_triggered.emit(action_name)


func _play_single_transition(animated: bool = true) -> void:
	var style: AnimationStyle = AnimationStyle.NO_ANIMATION
	if _animation_state == _AnimationState.IN:
		style = animation_in
	elif _animation_state == _AnimationState.OUT:
		style = animation_out
	if not animated:
		style = AnimationStyle.NO_ANIMATION
	match style:
		AnimationStyle.SLIDE_TO_RIGHT: _animation_slide_to_right()
		AnimationStyle.SLIDE_TO_LEFT: _animation_slide_to_left()
		AnimationStyle.SLIDE_TO_UP: _animation_slide_to_up()
		AnimationStyle.SLIDE_TO_BOTTOM: _animation_slide_to_bottom()
		_: _no_animation()
	await animation_finished


func _set_initial_offset() -> void:
	var hud_size: Vector2 = get_viewport().get_visible_rect().size
	match animation_in:
		AnimationStyle.SLIDE_TO_RIGHT:
			offset = Vector2(-hud_size.x, 0)
		AnimationStyle.SLIDE_TO_LEFT:
			offset = Vector2(hud_size.x, 0)
		AnimationStyle.SLIDE_TO_UP:
			offset = Vector2(0, hud_size.y)
		AnimationStyle.SLIDE_TO_BOTTOM:
			offset = Vector2(0, -hud_size.y)


func _slide_animation(target: Vector2) -> void:
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	if _animation_state == _AnimationState.IN:
		_tween.set_ease(ease_in)
		_tween.set_trans(transition_in)
	elif _animation_state == _AnimationState.OUT:
		_tween.set_ease(ease_out)
		_tween.set_trans(transition_out)
	_tween.tween_property(self, "offset", target, duration_in)
	_tween.finished.connect(_on_tween_finished)
	_tween.play()
	_toggle_animation_state()


func _no_animation() -> void:
	if _animation_state == _AnimationState.IN:
		offset = Vector2(0, 0)
	elif _animation_state == _AnimationState.OUT:
		var hud_size: Vector2 = get_viewport().get_visible_rect().size
		offset = -hud_size
	var state: bool = (_animation_state == _AnimationState.OUT)
	_toggle_animation_state()
	animation_finished.emit(state)


func _animation_slide_to_right() -> void:
	var hud_size: Vector2 = get_viewport().get_visible_rect().size
	var target: Vector2 = Vector2.ZERO
	if _animation_state == _AnimationState.OUT:
		target.x = hud_size.x
	if duration_in == 0.0:
		offset = target
	else:
		_slide_animation(target)


func _animation_slide_to_left() -> void:
	var hud_size: Vector2 = get_viewport().get_visible_rect().size
	var target: Vector2 = Vector2.ZERO
	if _animation_state == _AnimationState.OUT:
		target.x = -hud_size.x
	if duration_in == 0.0:
		offset = target
	else:
		_slide_animation(target)


func _animation_slide_to_up() -> void:
	var hud_size: Vector2 = get_viewport().get_visible_rect().size
	var target: Vector2 = Vector2.ZERO
	if _animation_state == _AnimationState.OUT:
		target.y = -hud_size.y
	if duration_in == 0.0:
		offset = target
	else:
		_slide_animation(target)


func _animation_slide_to_bottom() -> void:
	var hud_size: Vector2 = get_viewport().get_visible_rect().size
	var target: Vector2 = Vector2.ZERO
	if _animation_state == _AnimationState.OUT:
		target.y = hud_size.y
	if duration_in == 0.0:
		offset = target
	else:
		_slide_animation(target)


func _toggle_animation_state() -> void:
	if _animation_state == _AnimationState.IN:
		_animation_state = _AnimationState.OUT
	else:
		_animation_state = _AnimationState.IN


func _on_tween_finished() -> void:
	var state: bool = bool(not _animation_state == _AnimationState.OUT)
	animation_finished.emit(state)
