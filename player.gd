extends KinematicBody2D

onready var sprite_node = get_node("Sprite")
onready var sprite1_node = get_node("Sprite1")
onready var sprite2_node = get_node("Sprite2")

var curr_character = 1
const MAX_CHARACTERS = 3
const MIN_CHARACTERS = 1

var input_direction = 0
var direction = 1

var speed = Vector2()
var velocity = Vector2()

const MAX_SPEED = 700
const ACCELERATION = 2600
const DECELERATION = 5000

const JUMP_FORCE = 1000
const GRAVITY = 2800
const MAX_FALL_SPEED = 1400

var jump_count = 0
const MAX_JUMP_COUNT = 1


func _ready():
	set_process(true)
	set_process_input(true)
	sprite_node = get_node("Sprite")


func _input(event):
	if event.is_action_pressed("change_character_right"):
		if curr_character != MAX_CHARACTERS:
			curr_character += 1
		else:
			curr_character = 1
		change_sprite(curr_character)
	if event.is_action_pressed("change_character_left"):
		if curr_character != MIN_CHARACTERS:
			curr_character -= 1
		else:
			curr_character = 3
		change_sprite(curr_character)
	if jump_count < MAX_JUMP_COUNT and event.is_action_pressed("jump"):
		speed.y = -JUMP_FORCE
		jump_count += 1

func change_sprite(num):
	if num == 1:
		get_node("Sprite").set_opacity(1)
		get_node("Sprite1").set_opacity(0)
		get_node("Sprite2").set_opacity(0)
	elif num == 2:
		get_node("Sprite").set_opacity(0)
		get_node("Sprite1").set_opacity(1)
		get_node("Sprite2").set_opacity(0)
	elif num == 3:
		get_node("Sprite").set_opacity(0)
		get_node("Sprite1").set_opacity(0)
		get_node("Sprite2").set_opacity(1)

func _process(delta):
	if input_direction:
		direction = input_direction
	
	if Input.is_action_pressed("move_left"):
		input_direction = -1
		sprite_node.set_flip_h(true)
		sprite1_node.set_flip_h(true)
		sprite2_node.set_flip_h(true)
	elif Input.is_action_pressed("move_right"):
		input_direction = 1
		sprite_node.set_flip_h(false)
		sprite1_node.set_flip_h(false)
		sprite2_node.set_flip_h(false)
	else:
		input_direction = 0

	if input_direction:
		speed.x = MAX_SPEED
	else:
		speed.x -= DECELERATION * delta
	speed.x = clamp(speed.x, 0, MAX_SPEED)
	
	speed.y += GRAVITY * delta
	if speed.y > MAX_FALL_SPEED:
		speed.y = MAX_FALL_SPEED
	
	velocity = Vector2(speed.x * delta * direction, speed.y * delta)
	var movement_remainder = move(velocity)
	
	if is_colliding():
		var normal = get_collision_normal()
		var final_movement = normal.slide(movement_remainder)
		speed = normal.slide(speed)
		move(final_movement)
		
		if normal == Vector2(0, -1):
			jump_count = 0
		elif normal == Vector2(1,0) or Vector2(-1,0):
			speed.y /= 2