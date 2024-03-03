extends Node2D


@onready var player = get_node("Actors/Player")
@onready var exit = get_node("Actors/Exit")


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	const bottom_limit: float = 700
	if player.position.y > bottom_limit:
		FDCore.trigger_action("fail", "level")


func _physics_process(delta: float) -> void:
	pass


func _on_exit_body_entered(body: Node2D) -> void:
	if body == player:
		FDCore.trigger_action("success", "level")
