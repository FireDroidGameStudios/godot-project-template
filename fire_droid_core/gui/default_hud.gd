extends CanvasLayer


signal button_pressed(action_name: String)
signal animation_finished(state_is_out: bool)

enum AnimationStyle {
	NO_ANIMATION,
	SLIDE_TO_RIGHT,
	SLIDE_TO_LEFT,
	SLIDE_TO_UP,
	SLIDE_TO_BOTTOM,
	FADE,
}
enum _AnimationState { IN = 0, OUT = 1 }
const DefaultAnimationDuration: float = 1.2

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


func _ready() -> void:
	play_transition(false)
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func play_transition(animated: bool = true) -> void:
	var style: AnimationStyle = AnimationStyle.NO_ANIMATION
	if _animation_state == _AnimationState.IN:
		style = animation_in
	elif _animation_state == _AnimationState.OUT:
		style = animation_out
	match style:
		AnimationStyle.SLIDE_TO_RIGHT: _animation_slide_to_right(animated)
		AnimationStyle.SLIDE_TO_LEFT: _animation_slide_to_left(animated)
		AnimationStyle.SLIDE_TO_UP: _animation_slide_to_up(animated)
		AnimationStyle.SLIDE_TO_BOTTOM: _animation_slide_to_bottom(animated)


func _slide_animation(target: Vector2) -> void:
	print("Sliding to target ", target)
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	if _animation_state == _AnimationState.IN:
		_tween.set_ease(ease_in)
		_tween.set_trans(transition_in)
	_tween.tween_property(self, "offset", target, duration_in)
	_tween.finished.connect(_on_tween_finished)
	_tween.play()
	_toggle_animation_state()


func _animation_slide_to_right(animated: bool) -> void:
	var hud_size: Vector2 = get_viewport().get_visible_rect().size
	var target: Vector2 = Vector2.ZERO
	if _animation_state == _AnimationState.OUT:
		target.x = -hud_size.x
	if not animated or duration_in == 0.0:
		offset = target
	else:
		_slide_animation(target)


func _animation_slide_to_left(animated: bool) -> void:
	var hud_size: Vector2 = get_viewport().get_visible_rect().size
	var target: Vector2 = Vector2.ZERO
	if _animation_state == _AnimationState.OUT:
		target.x = hud_size.x
	if not animated or duration_in == 0.0:
		offset = target
	else:
		_slide_animation(target)


func _animation_slide_to_up(animated: bool) -> void:
	var hud_size: Vector2 = get_viewport().get_visible_rect().size
	var target: Vector2 = Vector2.ZERO
	if _animation_state == _AnimationState.OUT:
		target.y = hud_size.y
	if not animated or duration_in == 0.0:
		offset = target
	else:
		_slide_animation(target)


func _animation_slide_to_bottom(animated: bool) -> void:
	var hud_size: Vector2 = get_viewport().get_visible_rect().size
	var target: Vector2 = Vector2.ZERO
	if _animation_state == _AnimationState.OUT:
		target.y = -hud_size.y
	if not animated or duration_in == 0.0:
		offset = target
	else:
		_slide_animation(target)


func _toggle_animation_state() -> void:
	if _animation_state == _AnimationState.IN:
		_AnimationState.OUT
	else:
		_AnimationState.IN


func _on_button_pressed(action_name: String) -> void:
	button_pressed.emit(action_name)


func _on_tween_finished() -> void:
	var state: bool = not bool(_animation_state)
	animation_finished.emit(state)
