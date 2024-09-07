extends CharacterBody2D

const CHAIN_PULL = 70
var chain_velocity := Vector2(0,0)

@export var speed = 80
@export var gravity = 980
var fallgravity = gravity*2
var Max_fall = 5000
var max_walk = 500
var jumpspd = 700
var dash = true
var dashSpd= 800
var dashtimer = 0
var dashtimermax=.8
var shootvec = Vector2(0,0)
var mouse = false
var jump = false
var deadzone = 0

const STATUS_IDLE: int = 0
const STATUS_WALK: int = 1
const STATUS_TOUNGE: int = 2
const STATUS_DASH: int = 3
const STATUS_DIE: int = 4
var action_status: int = STATUS_IDLE
var action_animation: Array = [
	"idle", "walk", "tounge","dash", "die"
]

const LOOK_upLeft: int = 0
const LOOK_up: int = 1
const LOOK_upRight: int = 2
const LOOK_left: int = 3
const LOOK_mid: int = 4
const LOOK_right: int = 5
const LOOK_downLeft: int = 6
const LOOK_down: int = 7
const LOOK_downRight: int = 8
var look_status: int = LOOK_right


func get_grav(velocity: Vector2):
	if velocity.y <0:
		return gravity
	return fallgravity

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.get_button_index()==2:
		
		if event.pressed:
			# We clicked the mouse -> shoot()
			mouse = true
			$Chain.shoot((get_global_mouse_position()-position))
			
		else:
			# We released the mouse -> release()
			$Chain.release()
	#dash

	
	
	
func _process(delta):
	var xAxisRL = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var yAxisUD = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:
		mouse = false
		if Input.is_action_just_pressed("righttrigger"):
			
			mouse = false
			$Chain.shoot(Vector2(xAxisRL, yAxisUD))
		if Input.is_action_just_released("righttrigger"): $Chain.release()
	else:$Chain.release()
	
	if mouse: $Chain.ok(get_global_mouse_position()-position)
	else: 
		$Chain.ok (Vector2(xAxisRL, yAxisUD))
		
	
	
	"""
	shootvec.x = (Input.get_action_strength("right_stickright") - Input.get_action_strength("right_stickleft"))
	shootvec.y = (Input.get_action_strength("right_stickdown") - Input.get_action_strength("right_stickup"))
	if mouse: $Chain.ok(get_global_mouse_position()-position)
	
	if shootvec.length() > 0 && !mouse:  # If there's some input from the stick
		shootvec = shootvec.normalized()  # Normalize and scale it by tipmax
		mouse = false
		$Chain.ok(shootvec)
	
	if Input.is_action_pressed("righttrigger"):
		mouse = false
		$Chain.shoot(shootvec)
		
	elif !mouse: $Chain.release()
	"""
	
	
	#if Input.is_action_pressed("rightclick"):
	#	$Chain.shoot((get_global_mouse_position()-position))
	
	#else:
		# We released the mouse -> release()
	#	$Chain.release()
	

func _physics_process(delta):
	
	var walk = (Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")) * speed
	dashtimer-= .1
	if dashtimer<0:
		velocity.y += get_grav(velocity)*delta
	
	velocity.y = clamp(velocity.y, -Max_fall, Max_fall)
	if (Input.is_action_just_released("ui_select")&&velocity.y<0&&jump):
		velocity.y /= 2
		
	if Input.is_action_just_pressed("ui_select")&&is_on_floor():
		velocity.y = -jumpspd
		jump = true
		
	if !is_on_floor() and Input.is_action_just_pressed("ui_select") and dash:
		var dashx =Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		var dashy = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		if dashx!=0 or dashy!=0:
			dash = false 
			dashtimer = dashtimermax
			$Chain.release()
			velocity = Vector2(dashx,dashy).normalized()*dashSpd
			jump = false
		
	if ($Chain.hooked):
		
		#var walkv = (Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")) * speed
		#if(abs(velocity.y)<max_walk):
		#	velocity.y += walkv
		
		chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
	
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.85
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1.35
			
		
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity

	if(abs(velocity.x + walk)<max_walk):
		velocity.x += walk
		if $Chain.tip_loc.length()>$Chain.tipmax+70:
			$Chain.release()
		
	move_and_slide()
	
	velocity.y = clamp(velocity.y, -Max_fall, Max_fall)	# Make sure we are in our limits
	velocity.x = clamp(velocity.x, -Max_fall, Max_fall)
	
	
	var grounded = is_on_floor()
	if grounded:
		dash = true
		velocity.x *= .9	# Apply friction only on x (we are not moving on y anyway)
		#if velocity.y >= 5:		# Keep the y-velocity small such that
		#	velocity.y = 5		# gravity doesn't make this number huge
	elif is_on_ceiling() and velocity.y <= -5:	# Same on ceilings
		velocity.y = -5
	
	if !grounded:
		velocity.x *= .998
		if velocity.y > 0:
			velocity.y *= .998
	



	
	
	
