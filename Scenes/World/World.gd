extends Node2D


var best_score = 0
var screen_size: Vector2

@onready var camera_2d: Camera2D = %Camera2D


func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	camera_2d.global_position.y = -screen_size.y / 2

func _process(delta: float) -> void:
	pass
