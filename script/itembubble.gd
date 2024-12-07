class_name item
extends CharacterBody2D

const my_scene: PackedScene = preload("res://scenes/itemBubble.tscn")

var Item:String = "pistol"
var items = ["none", "pistol","grenade", "sword"]
var speed = 100
var bod=null;

func spawnItem(itemType:String, pos:Vector2):
	var new_item: item =my_scene.instantiate()
	new_item.global_position = pos
	new_item.Item = itemType

func spawnItemRandom(pos:Vector2):
	var new_item: item =my_scene.instantiate()
	new_item.global_position = pos
	Item = items[(int)(randf()*items.length())]

func _on_area_2d_body_entered(body):
	if body.has_method("itemGet"):
		body.itemGet(Item)
		body.release()
		self.destroy()
	

func destroy():
	
	self.queue_free()
	

func _physics_process(delta: float) -> void:
	if $Area2D.has_overlapping_bodies():
		for obj in $Area2D.get_overlapping_bodies():
			if obj.get_parent().has_method("isHooked"):
				if obj.get_parent().isHooked():
					#$obj.set_remote_node(obj)
					velocity += to_local(obj.get_parent().get_parent().global_position).normalized() * speed
	else: 
		velocity = Vector2.ZERO
		#$obj.set_remote_node($obj)
	move_and_slide()
