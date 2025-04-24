class_name MovingPlatform
extends AnimatableBody2D


var width := 200
var height := 20

var velocity := 5
var velocity_margin := randf_range(0,1)
var direction = -1 if randi_range(0, 1) == 1 else 1

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var polygon_2d: Polygon2D = %Polygon2D


func _ready() -> void:
	if collision_shape_2d.shape:
		if collision_shape_2d.shape is RectangleShape2D:
			collision_shape_2d.shape.size = Vector2(width, height)
	
	polygon_2d.polygon = PackedVector2Array([
		Vector2(-width/2, -height/2),
		Vector2(width/2, -height/2),
		Vector2(width/2, height/2),
		Vector2(-width/2, height/2)
	])


func _physics_process(delta: float) -> void:
	var scree_size := get_viewport_rect().size
	var screen_limit = ((scree_size.x/2) - (width/2))
	
	if global_position.x <= 0 - screen_limit:
		direction = 1
	if global_position.x >= screen_limit:
		direction = -1
	
	move_and_collide(Vector2((velocity-velocity_margin) * direction, 0))
