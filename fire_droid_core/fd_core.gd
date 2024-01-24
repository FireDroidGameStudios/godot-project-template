extends Node


#region TransitionTypes
enum {
	TRANSITION_DIAMONDS = 0,
	TRANSITION_CIRCLE = 1,
	TRANSITION_VCUT = 2,
	TRANSITION_HCUT = 3,
	TRANSITION_FADE = 4,
	TRANSITION_CUSTOM,
	TRANSITION_REV_CIRCLE,
	TRANSITION_REV_VCUT,
	TRANSITION_REV_HCUT,
	TRANSITION_REV_DIAMONDS,
}
#endregion
#region DefaultTextures
const _DefaultTexture = "res://addons/ez_transitions/images/black_texture.png"
const _DiamondsDefaultTexture = _DefaultTexture
const _CircleDefaultTexture = _DefaultTexture
const _VCutDefaultTexture = _DefaultTexture
const _HCutDefaultTexture = _DefaultTexture
const _FadeDefaultTexture = _DefaultTexture
#endregion
#region DefaultValues
const _DefaultValues: Dictionary = {
	TRANSITION_DIAMONDS: {
		"easing": { "in": Tween.EASE_IN, "out": Tween.EASE_OUT },
		"trans": { "in": Tween.TRANS_QUINT, "out": Tween.TRANS_QUINT },
		"timers": { "in": 1.6, "delay": 0.06, "out": 1.6 },
		"reverse": { "in": false, "out": true },
		"textures": { "in": _FadeDefaultTexture, "out": _FadeDefaultTexture },
		"types": { "in": TRANSITION_DIAMONDS, "out": TRANSITION_DIAMONDS }
	},
	TRANSITION_CIRCLE: {
		"easing": { "in": Tween.EASE_IN, "out": Tween.EASE_OUT },
		"trans": { "in": Tween.TRANS_SINE, "out": Tween.TRANS_SINE },
		"timers": { "in": 1.6, "delay": 0.2, "out": 1.6 },
		"reverse": { "in": false, "out": false },
		"textures": { "in": _CircleDefaultTexture, "out": _CircleDefaultTexture },
		"types": { "in": TRANSITION_CIRCLE, "out": TRANSITION_CIRCLE }
	},
	TRANSITION_VCUT: {
		"easing": { "in": Tween.EASE_IN_OUT, "out": Tween.EASE_IN_OUT },
		"trans": { "in": Tween.TRANS_CUBIC, "out": Tween.TRANS_CUBIC },
		"timers": { "in": 1.6, "delay": 0.2, "out": 1.6 },
		"reverse": { "in": false, "out": false },
		"textures": { "in": _VCutDefaultTexture, "out": _VCutDefaultTexture },
		"types": { "in": TRANSITION_VCUT, "out": TRANSITION_VCUT }
	},
	TRANSITION_HCUT: {
		"easing": { "in": Tween.EASE_IN_OUT, "out": Tween.EASE_IN_OUT },
		"trans": { "in": Tween.TRANS_CUBIC, "out": Tween.TRANS_CUBIC },
		"timers": { "in": 1.6, "delay": 0.2, "out": 1.6 },
		"reverse": { "in": false, "out": false },
		"textures": { "in": _VCutDefaultTexture, "out": _VCutDefaultTexture },
		"types": { "in": TRANSITION_HCUT, "out": TRANSITION_HCUT }
	},
	TRANSITION_FADE: {
		"easing": { "in": Tween.EASE_IN, "out": Tween.EASE_OUT },
		"trans": { "in": Tween.TRANS_CUBIC, "out": Tween.TRANS_CUBIC },
		"timers": { "in": 1.6, "delay": 0.1, "out": 1.6 },
		"reverse": { "in": true, "out": true },
		"textures": { "in": _FadeDefaultTexture, "out": _FadeDefaultTexture },
		"types": { "in": TRANSITION_FADE, "out": TRANSITION_FADE }
	},
	TRANSITION_REV_CIRCLE: {
		"easing": { "in": Tween.EASE_IN, "out": Tween.EASE_OUT },
		"trans": { "in": Tween.TRANS_SINE, "out": Tween.TRANS_SINE },
		"timers": { "in": 1.6, "delay": 0.2, "out": 1.6 },
		"reverse": { "in": true, "out": true },
		"textures": { "in": _CircleDefaultTexture, "out": _CircleDefaultTexture },
		"types": { "in": TRANSITION_CIRCLE, "out": TRANSITION_CIRCLE }
	},
	TRANSITION_REV_VCUT: {
		"easing": { "in": Tween.EASE_IN_OUT, "out": Tween.EASE_IN_OUT },
		"trans": { "in": Tween.TRANS_CUBIC, "out": Tween.TRANS_CUBIC },
		"timers": { "in": 1.6, "delay": 0.2, "out": 1.6 },
		"reverse": { "in": true, "out": true },
		"textures": { "in": _VCutDefaultTexture, "out": _VCutDefaultTexture },
		"types": { "in": TRANSITION_VCUT, "out": TRANSITION_VCUT }
	},
	TRANSITION_REV_HCUT: {
		"easing": { "in": Tween.EASE_IN_OUT, "out": Tween.EASE_IN_OUT },
		"trans": { "in": Tween.TRANS_CUBIC, "out": Tween.TRANS_CUBIC },
		"timers": { "in": 1.6, "delay": 0.2, "out": 1.6 },
		"reverse": { "in": true, "out": true },
		"textures": { "in": _VCutDefaultTexture, "out": _VCutDefaultTexture },
		"types": { "in": TRANSITION_HCUT, "out": TRANSITION_HCUT }
	},
	TRANSITION_REV_DIAMONDS: {
		"easing": { "in": Tween.EASE_IN, "out": Tween.EASE_OUT },
		"trans": { "in": Tween.TRANS_QUINT, "out": Tween.TRANS_QUINT },
		"timers": { "in": 1.6, "delay": 0.06, "out": 1.6 },
		"reverse": { "in": true, "out": false },
		"textures": { "in": _FadeDefaultTexture, "out": _FadeDefaultTexture },
		"types": { "in": TRANSITION_DIAMONDS, "out": TRANSITION_DIAMONDS }
	},
}
#endregion


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func change_to_scene(scene_path: String, transition_type: int = TRANSITION_FADE) -> void:
	var values: Dictionary = _DefaultValues.get(
		transition_type, _DefaultValues[TRANSITION_FADE]
	)
	_apply_transition_values(values)
	EzTransitions.change_scene(scene_path)


func change_to_packed_scene(scene: PackedScene, transition_type: int = TRANSITION_FADE) -> void:
	var values: Dictionary = _DefaultValues.get(
		transition_type, _DefaultValues[TRANSITION_FADE]
	)
	_apply_transition_values(values)
	EzTransitions.change_scene_packed(scene)


func _apply_transition_values(values: Dictionary) -> void:
	if values.is_empty():
		return
	EzTransitions.set_easing(values.easing.in, values.easing.out)
	EzTransitions.set_trans(values.trans.in, values.trans.out)
	EzTransitions.set_timers(values.timers.in, values.timers.delay, values.timers.out)
	EzTransitions.set_reverse(values.reverse.in, values.reverse.out)
	EzTransitions.set_textures(values.textures.in, values.textures.out)
	EzTransitions.set_types(values.types.in, values.types.out)
