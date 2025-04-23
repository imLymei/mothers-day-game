extends StaticBody2D


var width := 200

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D


func _ready() -> void:
	if collision_shape_2d.shape:
		if collision_shape_2d.shape is RectangleShape2D:
			collision_shape_2d.shape.size = Vector2(width, 20)
