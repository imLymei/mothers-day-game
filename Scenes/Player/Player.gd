class_name Player
extends CharacterBody2D


# Variaveis de Configuracao
const GRAVITY = 1500
const JUMP_FORCE = 1000
const SPEED = 400

# Variaveis de Logica
var screen_size: Vector2
var current_direction := 0
var is_touching := false
var touch_index := -1
var can_move := true
var state := "IDLE"

@onready var sprite: Node2D = %Sprite
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var animation_player: AnimationPlayer = %AnimationPlayer


# Codigo de Inicializacao
func _ready() -> void:
	var left_sprite := sprite.duplicate() as Node2D
	var left_collision_shape := collision_shape_2d.duplicate() as CollisionShape2D
	var right_sprite := sprite.duplicate() as Node2D
	var right_collision_shape := collision_shape_2d.duplicate() as CollisionShape2D
	
	screen_size = get_viewport_rect().size
	
	left_sprite.global_position.x = -screen_size.x 
	left_collision_shape.global_position.x = -screen_size.x
	right_sprite.global_position.x = screen_size.x 
	right_collision_shape.global_position.x = screen_size.x
	
	add_child(left_sprite)
	add_child(left_collision_shape)
	add_child(right_sprite)
	add_child(right_collision_shape)


# Codigo de Logica Por Quadro (para Movimentacoes)
func _physics_process(delta: float) -> void:
	handle_animations()
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		var last_collision := get_last_slide_collision()
		
		if last_collision:
			var collider = last_collision.get_collider()
		
			if collider is WeakPlatform:
				collider.disappear()
		
		if can_move: 
			velocity.y = -JUMP_FORCE
		
	if can_move:
		velocity.x = SPEED * current_direction
	else:
		velocity.x = lerp(velocity.x, 0.0, 12 * delta)
	
	move_and_slide()
	
	var screen_x_center = screen_size.x / 2
	
	if global_position.x <= -screen_x_center:
		global_position.x += screen_size.x
	elif global_position.x >= screen_x_center:
		global_position.x -= screen_size.x


# Codigo de Logica Para Inputs/Toques
func _input(event: InputEvent) -> void:
	var screen_x_center := screen_size.x / 2
	var screen_y_center := screen_size.y / 2
	
	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.position.y < screen_y_center:
			is_touching = false
			touch_index = -1
			current_direction = 0
			return
		
		if touch_event.pressed:
			is_touching = true
			touch_index = touch_event.index
			
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
		if drag_event.position.y < screen_y_center:
			is_touching = false
			touch_index = -1
			current_direction = 0
			return
		
		if is_touching and touch_index == drag_event.index:
			if drag_event.position.x < screen_x_center:
				current_direction = -1
			else:
				current_direction = 1
	elif not is_touching and touch_index == -1:
		current_direction = Input.get_axis("ui_left", "ui_right")


# Codigo de Logica Para Animacoes
func handle_animations():
	if velocity.y > 0:
		if state != "FALLING":
			state = "FALLING"
			animation_player.play("FALLING")
	elif velocity.y < 0:
		if state != "JUMPING":
			state = "JUMPING"
			animation_player.play("JUMPING")
	else:
		if state != "IDLE":
			state = "IDLE"
			animation_player.play("RESET")
