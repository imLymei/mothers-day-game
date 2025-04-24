class_name GoalPlatform
extends Node2D


signal goal_reached

@onready var static_plataform: StaticPlatform = %StaticPlataform
@onready var goal_collision_shape: CollisionShape2D = $GoalArea/GoalCollisionShape
@onready var confetti_particles_right: CPUParticles2D = %ConfettiParticlesRight
@onready var confetti_particles_left: CPUParticles2D = %ConfettiParticlesLeft


func _ready() -> void:
	var screen_size = get_viewport_rect().size
	static_plataform.width = screen_size.x
	static_plataform.generate_polygon()
	if goal_collision_shape.shape is RectangleShape2D:
		goal_collision_shape.shape.size.x = screen_size.x


func _on_goal_area_body_entered(body: Node2D) -> void:
	goal_reached.emit()
	confetti_particles_left.emitting = true
	confetti_particles_right.emitting = true
