extends Node2D


const PLATFORM_SPACING = 300
const MOVING_PLATFORM_SPAWN_RATE = 0.1
const GOAL_PLATFORMS_DISTANCE = 100

var actual_score = 0
var last_platform_height = 0
var screen_size: Vector2

var is_game_running := true
var total_platforms := 0
var goal_platform: GoalPlatform

var goal_score:
	get():
		return (GOAL_PLATFORMS_DISTANCE + 1) * PLATFORM_SPACING
var camera_bottom :
	get():
		return camera_2d.global_position.y + (screen_size.y / 2)

@export var static_platform_scene: PackedScene
@export var moving_platform_scene: PackedScene
@export var weak_platform_scene: PackedScene
@export var goal_platform_scene: PackedScene

@onready var camera_2d: Camera2D = %Camera2D
@onready var player: Player = %Player
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var platforms: Node = %Platforms
@onready var death_area: Marker2D = %DeathArea
@onready var child: Node2D = %Child

# UI
@onready var win_screen: CenterContainer = %WinScreen
@onready var game_over_screen: CenterContainer = %GameOverScreen
@onready var final_score_label: Label = %FinalScoreLabel


func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	camera_2d.limit_bottom = 0
	
	high_score_label.text = "/ %d" % [goal_score]
	
	generate_platforms()


func _process(delta: float) -> void:
	death_area.global_position.y = camera_bottom
	
	if player.global_position.y > death_area.global_position.y:
		die()
	
	if sign(player.global_position.y) == - 1 and abs(player.global_position.y) > actual_score:
		actual_score = abs(player.global_position.y)
		camera_2d.global_position.y = -actual_score
		score_label.text = "%d" % [actual_score]
		
		for platform: Node2D in platforms.get_children():
			if platform.global_position.y > camera_bottom + PLATFORM_SPACING:
				platforms.remove_child(platform)
	
	if is_game_running and last_platform_height - abs(player.global_position.y) < screen_size.y:
		add_platform()


func _physics_process(delta: float) -> void:
	child.global_position = child.global_position.lerp(
		Vector2(
			child.global_position.x,
			camera_2d.global_position.y - (
				(1 - (min(actual_score, goal_score) / goal_score)) * (screen_size.y / 2.5)
			)
		),
		0.1
	)


func generate_platforms() -> void:
	var height_goal = player.global_position.y + (screen_size.y * 1.5)
	
	while last_platform_height <= height_goal:
		add_platform()


func add_platform() -> void:
	if total_platforms > GOAL_PLATFORMS_DISTANCE:
		return
	
	last_platform_height += PLATFORM_SPACING
	
	if total_platforms == GOAL_PLATFORMS_DISTANCE:
		total_platforms += 1
		
		goal_platform = goal_platform_scene.instantiate() as GoalPlatform
		
		goal_platform.global_position.y = -last_platform_height
		goal_platform.goal_reached.connect(_on_goal_reached)
		platforms.add_child(goal_platform)
		return
		
	total_platforms += 1
	
	var platform := get_random_platform()
	
	platform.global_position.y = -last_platform_height
	
	var random_position = randf_range(-1, 1) * ((screen_size.x / 2) + (platform.width / 2))
	platform.global_position.x = 0 + (random_position / 2)
	
	platforms.add_child(platform)


func get_random_platform() -> StaticBody2D:
	var platform_type := randi_range(0, 2)
	
	match platform_type:
		0:
			return static_platform_scene.instantiate()
		1:
			return moving_platform_scene.instantiate()
		_: 
			return weak_platform_scene.instantiate()
	


func die() -> void:
	game_over_screen.show()
	
	final_score_label.text = "%d" % [actual_score]
	total_platforms = 0
	
	camera_2d.global_position.y = 0
	camera_2d.position_smoothing_speed = 10
	is_game_running = false
	player.can_move = false
	
	last_platform_height = 0
	
	for child in platforms.get_children():
		platforms.remove_child(child)
	
	


func restart() -> void:
	game_over_screen.hide()
	win_screen.hide()
	camera_2d.position_smoothing_speed = 5
	camera_2d.limit_smoothed = false
	
	actual_score = 0
	is_game_running = true
	player.can_move = true
	player.global_position = Vector2(0, -10)
	
	generate_platforms()


func _on_restart_button_pressed() -> void:
	restart()


func _on_goal_reached() -> void:
	player.can_move = false
	camera_2d.limit_smoothed = true
	camera_2d.limit_bottom = goal_platform.global_position.y
	win_screen.show()


func _on_play_again_button_pressed() -> void:
	total_platforms = 0
	
	camera_2d.limit_bottom = 0
	camera_2d.global_position.y = 0
	camera_2d.position_smoothing_speed = 10
	is_game_running = false
	player.can_move = false
	
	last_platform_height = 0
	
	for child in platforms.get_children():
		platforms.remove_child(child)
	restart()
