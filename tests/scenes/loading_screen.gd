extends Control


const LOADING_TEXT_ANIMATION_DELAY: float = 0.25

var loading_text_step: int = 0
var progress_advance_speed: float = 1.0
var ending_progress_advance_speed: float = 10.0
var _previous_progress: float = 0.0
var _current_progress: float = 0.0
var _target_progress: float = 0.0


func _ready() -> void:
	%LabelLoadingText.set_text("Loading")
	$TimerLoadingTextChanger.start(LOADING_TEXT_ANIMATION_DELAY)
	FDLoad.add_to_queue("res://tests/scenes/fire_droid_logo_intro.tscn")
	FDLoad.add_to_queue("res://tests/scenes/godot_logo_intro.tscn")
	FDLoad.progress_changed.connect(_on_progress_changed)
	FDLoad.finished.connect(_on_loading_finished)
	await get_tree().create_timer(0.5).timeout
	FDLoad.start()

	#FDLoad.add_to_queue("res://tests/assets/fire-droid_logo_opening/fire-droid-logo-animated-audio.ogg")
	#_add_files_to_load_queue("res://tests/assets/fire-droid_logo_opening/frames/")
	#FDLoad.add_to_queue("res://tests/assets/godot_logo_opening/godot-logo-animated-audio.ogg")
	#_add_files_to_load_queue("res://tests/assets/godot_logo_opening/frames/")


func _process(delta: float) -> void:
	_previous_progress = _current_progress
	_current_progress = (
		lerp(_previous_progress, _target_progress, 0.05)
	)
	%LabelProgressValue.set_text(str(int(_current_progress * 100)) + "%")
	%ProgressBar.set_value(_current_progress * 100)


func _physics_process(_delta: float) -> void:
	pass


func _add_files_to_load_queue(root_dir_path: String) -> void:
	var dir: DirAccess = DirAccess.open(root_dir_path)
	var files: PackedStringArray = dir.get_files()
	for file_path: String in files:
		FDLoad.add_to_queue(file_path)


func _on_progress_changed(progress: float) -> void:
	#_previous_progress = _current_progress
	_target_progress = progress
	FDCore.log_message("Progress changed to %d" % (progress * 100) + '%')


func _on_loading_finished() -> void:
	FDCore.log_message("Loading has finished.")
	var next_scene: PackedScene = (
		await FDLoad.get_loaded("res://tests/scenes/fire_droid_logo_intro.tscn")
	)
	FDCore.change_scene_to(next_scene.instantiate())


func _on_timer_loading_text_changer_timeout() -> void:
	const TEXT_STEPS: PackedStringArray = [
		"Loading",
		"Loading.",
		"Loading..",
		"Loading...",
	]
	loading_text_step = (loading_text_step + 1) % TEXT_STEPS.size()
	%LabelLoadingText.set_text(TEXT_STEPS[loading_text_step])
