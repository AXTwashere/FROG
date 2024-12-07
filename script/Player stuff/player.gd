extends CharacterBody2D
class_name player

const CHAIN_PULL = 55
var chain_velocity := Vector2(0,0)
var xAxisRL = Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
var yAxisUD = Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

@export var speed = 80
@export var gravity = 980
var fallgravity = gravity*2
var Max_fall = 5000
var max_walk = 500

var jumpspd = 700
var jump = false

var dash = true
var dashtime = 1
var dashtimemax = 1
var dashSpd= 600
var dashsp = 1
var dashdelay = 1
var chain
func _ready() -> void:
	chain = $Chain

var shootvec = Vector2(0,0)
var mouse = false
var deadzone = 0

@export var playerId = 1
var maxhp = 3
var hp = maxhp 

var ammo = 100000
var ammo2 = 0
var reloadTimer:float = -.1
var reloading = false
var uses = 1
var uses2 =0
var items = { #name, max ammo, uses, *dmg , *speed, reload time, knockback
	"none":["none",0,0,0,0], "pistol": ["pistol",5,2,1,1,1,1],
	 "grenade": ["grenade",1,1,2,1,0,3], "sword":["sword",0,1,3,1,0,-1]
}
var item1 = items["pistol"]
var item2 = items["none"]


func _process(delta):
	xAxisRL = Input.get_joy_axis(playerId-1, JOY_AXIS_RIGHT_X)
	yAxisUD = Input.get_joy_axis(playerId-1, JOY_AXIS_RIGHT_Y)
	controlerTounge()

	reloadTimer-=delta
	if reloading and reloadTimer<=0:
		reloading = false
		ammo = item1[1]
	if item1!=items["none"]:
		if ammo<=0 and !reloading:
			reloadWeap()
		if uses<=0:
				item1 = items["none"]
				if item2 !=items["none"]: switchWeap()
	if Input.is_action_just_pressed("P%s_left_trigger" % [playerId]):
		if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:
			mouse = false
			if item1[0] == "pistol":
				if ammo>0:
					shootWeap()
					knockbackWeap()
					ammo-=1
			if item1[0] == "grenade":
				pass
			if item1[0] == "sword":
				pass
	if Input.is_action_just_pressed("P%s_left_bumper" % [playerId]): switchWeap()

func itemGet(Nitem: String):
	if item1 == items["none"]:
		item1 = items[Nitem]
		ammo = item1[1]
		uses = item1[2]
	elif item2 == items["none"]:
		item2 = items[Nitem]
		ammo2 = item2[1]
		uses2 = item2[2]

func shootWeap():
	$bullet.dmg_change(item1[3])
	get_tree().get_root().add_child($bullet.shoot(Vector2(0,0).angle_to_point(Vector2(xAxisRL,yAxisUD)),item1[4],playerId))

func knockbackWeap():
	velocity = -(Vector2(xAxisRL,yAxisUD).normalized()*item1[6]*500) + velocity/(3*item1[6])
	
func switchWeap():
	if item2 != items["none"]:
		reloading = false
		var temp = item1
		item1 = item2
		item2 = item1
		temp = ammo
		ammo = ammo2
		ammo2 = temp
		temp = uses
		uses = uses2
		uses2 = temp

func reloadWeap():
	uses-=1
	if uses>0:
		reloadTimer = item1[5]
		reloading = true

func hit():
	hp-=1
	if hp<=0: die()

func die():
	self.queue_free()

func get_grav(velocity: Vector2):
	if velocity.y <0:
		return gravity
	return fallgravity

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.get_button_index()==2:
		if event.pressed:
			mouse = true
			chain.shoot((get_global_mouse_position()-position))
		else:chain.release()


func controlerTounge():
	#controller aiming and shooting
	if abs(xAxisRL) > deadzone || abs(yAxisUD) > deadzone:
		mouse = false
		if Input.is_action_just_pressed("P%s_right_trigger" % [playerId]):
			mouse = false
			chain.shoot(Vector2(xAxisRL, yAxisUD))
	else:chain.flying = false
	if Input.is_action_just_released("P%s_right_trigger" % [playerId]): chain.release()
	
	if mouse: chain.ok(get_global_mouse_position()-position)
	else: 
		chain.ok (Vector2(xAxisRL, yAxisUD))


func _physics_process(delta):
	var walk = (Input.get_action_strength("P%s_right" % [playerId]) - Input.get_action_strength("P%s_left" % [playerId])) * speed
	var updown = (Input.get_action_strength("P%s_up" % [playerId]) - Input.get_action_strength("P%s_down" % [playerId]))
	if !dash:
		velocity.y += get_grav(velocity)*delta
	
	velocity.y = clamp(velocity.y, -Max_fall, Max_fall)
	if (Input.is_action_just_released("P%s_jump" % [playerId])&&velocity.y<0&&!dash):
		velocity.y /= 2
		
	if Input.is_action_just_pressed("P%s_jump" % [playerId])&&is_on_floor():
		velocity.y = -jumpspd
		jump = true
	else: jump = false
	
	if Input.is_action_just_released("P%s_jump"% [playerId]) and dash:
		dashtime-=.2
	if !is_on_floor() and Input.is_action_just_pressed("P%s_jump"% [playerId]) and dashtime>0 and !jump:
		dash = true
	var dashx =Input.get_action_strength("P%s_right"% [playerId]) - Input.get_action_strength("P%s_left"% [playerId])
	var dashy = Input.get_action_strength("P%s_down"% [playerId]) - Input.get_action_strength("P%s_up"% [playerId])
	if Input.is_action_pressed("P%s_jump"% [playerId])&&dash and dashtime>0 and(dashx!=0 or dashy!=0):
		dashsp+=.025
		dashtime-=.07
		chain.hooked = false
		velocity = Vector2(dashx,dashy).normalized()*dashSpd*dashsp
		jump = false
	else: 
		dash = false
		dashsp = 1
	
	
	if (chain.hooked):
		chain_velocity = to_local(chain.tip).normalized() * CHAIN_PULL
		if sign(updown)!=0 and sign(updown)==sign(chain_velocity.y):
			chain_velocity.y *= 0.55
		elif(sign(updown)!=sign(chain_velocity.y)): chain_velocity.y*=1.55
		if sign(chain_velocity.x) != sign(walk) and sign(walk)!=0:
			chain_velocity.x *= 0.55
		elif(sign(walk)!=sign(chain_velocity.x)): chain_velocity.x*=1.55
	else:
		chain_velocity = Vector2(0,0)
		if(abs(velocity.x + walk)<max_walk):
			velocity.x += walk
	velocity += chain_velocity
		
	move_and_slide()
	
	velocity.y = clamp(velocity.y, -Max_fall, Max_fall)	# Make sure we are in our limits
	velocity.x = clamp(velocity.x, -Max_fall, Max_fall)
	
	
	var grounded = is_on_floor()
	if grounded:
		dash = false
		dashtime = dashtimemax
		velocity.x *= .9	# Apply friction only on x (we are not moving on y anyway)
		#if velocity.y >= 5:		# Keep the y-velocity small such that
		#	velocity.y = 5		# gravity doesn't make this number huge
	elif is_on_ceiling() and velocity.y <= -5:	# Same on ceilings
		velocity.y = -5
	
	if !grounded:
		velocity.x *= .998
		if velocity.y > 0:
			velocity.y *= .998

func release():
	chain.hooked = false;



	
	
	
