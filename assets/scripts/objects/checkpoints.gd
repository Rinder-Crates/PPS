extends Node2D

@export var checkpoint_id: int = 0

func _ready():
	$Area2D.connect("body_entered", _on_area_entered)

func _on_area_entered(body):
	if body.is_in_group("player"):
		body.set_checkpoint(global_position)
