class_name StaticPlatform
extends StaticBody2D


var width := 100
var height := 10

@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var polygon_2d: Polygon2D = %Polygon2D


func _ready() -> void:
	generate_polygon()


func generate_polygon():
	if collision_shape_2d.shape:
		if collision_shape_2d.shape is RectangleShape2D:
			collision_shape_2d.shape.size = Vector2(width, height)
	
	polygon_2d.polygon = PackedVector2Array([
		Vector2(-width/2, -height/2),
		Vector2(width/2, -height/2),
		Vector2(width/2, height/2),
		Vector2(-width/2, height/2)
	])
