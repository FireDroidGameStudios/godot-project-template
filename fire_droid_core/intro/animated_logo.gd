class_name AnimatedLogo
extends Control


signal finished

@export var next_scene: String = ""
@export_enum(
	"Diamonds",
	"Circle",
	"Vertical Cut",
	"Horizontal Cut",
	"Fade",
	"Custom",
	"Reverse Circle",
	"Reverse Vertical Cut",
	"Reverse Horizontal Cut",
	"Reverse Diamonds",
) var transition_type: int = FDCore.TRANSITION_FADE
@export var autoplay: bool = true


func _ready() -> void:
	if autoplay:
		play()
	else:
		$StaticLogo.visible = true


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass


func play() -> void:
	$StaticLogo.visible = false
	$VideoPlayer.play()


func _on_video_player_finished() -> void:
	finished.emit()
	$StaticLogo.visible = true
	if not next_scene.is_empty():
		FDCore.change_to_scene(next_scene)
