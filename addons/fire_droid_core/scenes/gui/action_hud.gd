class_name ActionHUD
extends CanvasLayer


signal action_triggered(action_name: String, context: String)
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
const DefaultAutoshowDelay: float = 0.3
const DefaultAutohideDelay: float = 1.5

var _animation_state: _AnimationState = _AnimationState.IN
var _tween: Tween = null

## Context to distinguish actions by a specified context. Example: "main_screen", "game_menu" etc.
@export var action_context: String = ""

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
@export var hide_at_begin: bool = true ## Begin with hidden state
@export var enable_autoshow: bool = false ## Autoshow after [member autoshow_delay] seconds. Timer starts when the node is added to tree.
@export_range(0.0, 10.0, 0.01, "or_greater") var autoshow_delay: float = DefaultAutoshowDelay
@export var enable_autohide: bool = false ## Autohide after [member autohide_delay] seconds. Timer starts when shown (manually or by keypress).
@export_range(0.0, 10.0, 0.01, "or_greater") var autohide_delay: float = DefaultAutohideDelay
@export var enable_trigger_key: bool = true	## If enabled, [member key_trigger] key will play animation when pressed.
@export var trigger_key: Key = KEY_ESCAPE ## Key used to play animation (only if [member enable_trigger_key] is enabled).


func _ready() -> void:
	_set_initial_state()
	_set_initial_offset()
	_autoshow()
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if enable_trigger_key and event is InputEventKey:
		var is_just_pressed: bool = event.is_pressed() and not event.is_echo()
		if event.keycode == trigger_key and is_just_pressed:
			play_animation()


## Play the animation interpolating from current state (in or out) to next state.[br]
## If [param animated] is [code]false[/code], the animation will not be interpolated.[br]
## Interpolation of the animation is based on values of properties
## [member animation_in], [member duration_in], [member ease_in], [member transition_in],
## [member animation_out], [member duration_out], [member ease_out] and
## [member transition_out].[br]If [member enable_autohide] is [code]true[/code], hide
## animation will be played automatically after [member autohide_delay] seconds.
func play_animation(animated: bool = true) -> void:
	if enable_autohide:
		if autohide_delay > 0.0:
			if _animation_state == _AnimationState.IN:
				await _play_single_animation(animated)
			await get_tree().create_timer(autohide_delay).timeout
		elif _animation_state == _AnimationState.OUT:
			return
	else:
		await _play_single_animation(animated)


## Trigger action with the given name. Signal [signal action_triggered] can be
## connected to an external function. When callled, this method also calls
## [method FDCore.trigger_action]
func trigger_action(action_name: String) -> void:
	if action_name.is_empty():
		return
	action_triggered.emit(action_name, action_context)
	FDCore.trigger_action(action_name, action_context)


func _autoshow() -> void:
	if enable_autoshow and hide_at_begin:
		if autoshow_delay > 0.0:
			await get_tree().create_timer(autoshow_delay).timeout
		await _play_single_animation()


func _play_single_animation(animated: bool = true) -> void:
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
	if not hide_at_begin:
		offset = Vector2(0, 0)
		return
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


func _set_initial_state() -> void:
	if hide_at_begin:
		_animation_state = _AnimationState.IN
	else:
		_animation_state = _AnimationState.OUT


func _slide_animation(target: Vector2) -> void:
	var duration: float = 1.0
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	if _animation_state == _AnimationState.IN:
		_tween.set_ease(ease_in)
		_tween.set_trans(transition_in)
		duration = duration_in
	elif _animation_state == _AnimationState.OUT:
		_tween.set_ease(ease_out)
		_tween.set_trans(transition_out)
		duration = duration_out
	_tween.tween_property(self, "offset", target, duration)
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
