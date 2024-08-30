extends CharacterBody2D

@export var speed = 300
@export var gravity = 30
@export var Max_fall = 2000

func _physics_process(delta):
	if !is_on_floor():
		velocity.y += gravity
		velocity.y = clamp(velocity.y, -Max_fall, Max_fall)
	
	var H_direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = speed*H_direction
	
	move_and_slide()
