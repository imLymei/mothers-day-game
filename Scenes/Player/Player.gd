extends CharacterBody2D


const GRAVITY = 900
const JUMP_FORCE = 600
const SPEED = 400

var screen_size: Vector2
var current_direction := 0

var is_touching := false
var touch_index := -1  # To track which finger is being used

@onready var sprite: Sprite2D = %Sprite


func _ready() -> void:
	var left_sprite := sprite.duplicate() as Sprite2D
	var right_sprite := sprite.duplicate() as Sprite2D
	
	screen_size = get_viewport_rect().size
	
	left_sprite.global_position.x = -screen_size.x
	right_sprite.global_position.x = screen_size.x
	
	add_child(left_sprite)
	add_child(right_sprite)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else: velocity.y = -JUMP_FORCE
	
	velocity.x = SPEED * current_direction
	
	move_and_slide()
	
	var screen_x_center = screen_size.x / 2
	
	if global_position.x <= -screen_x_center:
		global_position.x += screen_size.x
	elif global_position.x >= screen_x_center:
		global_position.x -= screen_size.x


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		
		if touch_event.pressed:
			is_touching = true
			touch_index = touch_event.index
			
			var screen_x_center := screen_size.x / 2
			if touch_event.position.x < screen_x_center:
				current_direction = -1
			else:
				current_direction = 1
		elif touch_index == touch_event.index:
			is_touching = false
			touch_index = -1
			current_direction = 0
	
	elif event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag
		
		if is_touching and touch_index == drag_event.index:
			var screen_x_center := screen_size.x / 2
			if drag_event.position.x < screen_x_center:
				current_direction = -1
			else:
				current_direction = 1
