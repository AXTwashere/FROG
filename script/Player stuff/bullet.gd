class_name bullet
extends CharacterBody2D

const my_scene: PackedScene = preload("res://scenes/Player stuff/bullet.tscn")

const basedmg = 3
const basespd = 1100

var direction: Vector2
var speed:float = 400
var player:int
var dmg = basedmg
var dir
var shot = false

func shoot(rot:float, sp:float, pl:int):
	var new_bullet: bullet =my_scene.instantiate()
	new_bullet.global_position = global_position
	new_bullet.speed = sp*basespd
	new_bullet.dir = rot
	new_bullet.global_rotation = rot
	new_bullet.player = pl
	new_bullet.shot = true
	new_bullet.z_index = z_index-1
	return new_bullet
	

func _physics_process(delta: float) -> void:
	if shot: 
		velocity = Vector2(0,speed).rotated(dir-(PI/2))
		move_and_slide()
		if is_on_wall() or is_on_ceiling() or is_on_floor():
			destroy()

func _on_area_2d_body_entered(body):
	if shot:
		if body.has_method("hit"):
			if body.playerId != player:
				body.hit()
				self.destroy()
		
	
func dmg_change_def():
	dmg = basedmg
func dmg_change(dm:float):
	dmg = dm*basedmg

func destroy():
	self.queue_free()
