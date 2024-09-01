extends CharacterBody2D

const CHAIN_PULL = 70
var chain_velocity := Vector2(0,0)

@export var speed = 80
@export var gravity = 980
var fallgravity = gravity*2
@export var Max_fall = 3000
var max_walk = 400
var jumpspd = 700

func get_grav(velocity: Vector2):
	if velocity.y <0:
		return gravity
	return fallgravity


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.get_button_index()==2:
		if event.pressed:
			# We clicked the mouse -> shoot()
			$Chain.shoot((get_global_mouse_position()-position)/(get_global_mouse_position()-position).length())
		else:
			# We released the mouse -> release()
			$Chain.release()
	

func _physics_process(delta):
	var walk = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) * speed
	velocity.y += get_grav(velocity)*delta
	velocity.y = clamp(velocity.y, -Max_fall, Max_fall)
	if (Input.is_action_just_released("ui_select")&&velocity.y<0):
		velocity.y /= 2
		
	if Input.is_action_just_pressed("ui_select")&&is_on_floor():
		velocity.y = -jumpspd
	#if Vector2(self.x,self.y).distance_to($Chain/Tip.location)>500:
	#	$Chain.hooked = false
	if ($Chain.hooked):
		
		"""
		var walkv = (Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")) * speed
		if(abs(velocity.y)<max_walk):
			velocity.y += walkv
		"""
		# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
	
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.85
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1.35
			
		"""
		if sign(chain_velocity.x) != sign(walk):
			# if we are trying to walk in a different
			# direction than the chain is pulling
			# reduce its pull
			chain_velocity.x *= 0.7
		"""
		
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity

	if(abs(velocity.x)<max_walk ):
		velocity.x += walk
	move_and_slide()
	velocity.y = clamp(velocity.y, -Max_fall, Max_fall)	# Make sure we are in our limits
	velocity.x = clamp(velocity.x, -Max_fall, Max_fall)
	var grounded = is_on_floor()
	if grounded:
		velocity.x *= .9	# Apply friction only on x (we are not moving on y anyway)
		if velocity.y >= 5:		# Keep the y-velocity small such that
			velocity.y = 5		# gravity doesn't make this number huge
	elif is_on_ceiling() and velocity.y <= -5:	# Same on ceilings
		velocity.y = -5
	if !grounded:
		velocity.x *= .98
		if velocity.y > 0:
			velocity.y *= .98




	
	
	
