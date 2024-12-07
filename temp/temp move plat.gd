extends CharacterBody2D

var balls = 100
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
	
	

func _physics_process(delta: float) -> void:
	if balls>=50:
		balls-=.1
		velocity.x+100
	else:
		balls-=.1 
		velocity.x-100
	if balls<=0: balls = 100
	move_and_slide()
