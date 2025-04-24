extends Node2D


const PLATFORM_SPACING = 300
const MOVING_PLATFORM_SPAWN_RATE = 0.1

var best_score = 0
var actual_score = 0
var last_platform_height = 0
var screen_size: Vector2

var is_game_running := true

var camera_bottom :
	get():
		return camera_2d.global_position.y + (screen_size.y / 2)

@export var static_platform_scene: PackedScene
@export var moving_platform_scene: PackedScene

@onready var camera_2d: Camera2D = %Camera2D
@onready var player: Player = %Player
@onready var score_label: Label = %ScoreLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var platforms: Node = %Platforms
@onready var death_area: Marker2D = %DeathArea

# UI
@onready var game_over_screen: CenterContainer = %GameOverScreen
@onready var new_high_score: VBoxContainer = %NewHighScore
@onready var new_high_score_label: Label = %NewHighScoreLabel


func _ready() -> void:
	screen_size = get_viewport_rect().size
	
	camera_2d.limit_bottom = 0
	
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
	
	if actual_score > best_score:
		best_score = actual_score
		high_score_label.text = "%d" % [best_score]
	
	if is_game_running and last_platform_height - abs(player.global_position.y) < screen_size.y:
		add_platform()


func generate_platforms():
	var height_goal = player.global_position.y + (screen_size.y * 1.5)
	
	while last_platform_height <= height_goal:
		add_platform()


func add_platform():
	last_platform_height += PLATFORM_SPACING
	var platform_type := randi_range(0, 1)
	var platform_scene := static_platform_scene if platform_type == 0 else moving_platform_scene
	
	var platform := platform_scene.instantiate()
	
	platform.global_position.y = -last_platform_height
	
	var random_position = randf_range(-1, 1) * ((screen_size.x / 2) + (platform.width / 2))
	platform.global_position.x = 0 + (random_position / 2)
	
	platforms.add_child(platform)


func die():
	game_over_screen.show()
	new_high_score.show()
	new_high_score_label.text = "%d" % [best_score]
	
	camera_2d.global_position.y = 0
	is_game_running = false
	player.can_move = false
	
	last_platform_height = 0
	
	for child in platforms.get_children():
		platforms.remove_child(child)
	


func restart():
	game_over_screen.hide()
	new_high_score.hide()
	
	actual_score = 0
	is_game_running = true
	player.can_move = true
	
	generate_platforms()


func _on_restart_button_pressed() -> void:
	restart()
