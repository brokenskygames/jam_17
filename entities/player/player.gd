extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -700.0
const DRAG = 2
const INERTIA = 100
const ACCELERATION = 40

@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_tree : AnimationTree = sprite.get_node("AnimationTree")

var direction : Vector2 = Vector2.ZERO
var dir_facing : Vector2 = Vector2.ZERO
var fly_vel = 0
var is_jumping = false
var moving_to_area = false
var area_position = Vector2.ZERO
var can_move = true


func _ready():
	# initial animation state
	animation_tree["parameters/conditions/is_idle"] = true
	animation_tree["parameters/conditions/is_running"] = false
	ProjectSettings.set_setting("physics/2d/default_gravity", -2000)
	dir_facing = Vector2 (1,0 )
	
	

func _physics_process(delta: float) -> void:
	
	if moving_to_area and not can_move:
		var direction = (area_position - global_position)
		if direction.length() < 2:
			velocity = Vector2.ZERO
			$Camera2D.shake(5.0)
			#moving_to_area = false
		else:
			velocity = direction.normalized() * SPEED
		move_and_slide()
	else:	
		update_animation_status()	
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta*1.6
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():		
			is_jumping = true
			velocity.y = JUMP_VELOCITY
			fly_vel = velocity.x
			
		if is_on_floor():			
			animation_tree["parameters/conditions/is_jumping"] = false
		if velocity.y == 0:
			is_jumping = false	
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction := Input.get_axis("ui_left", "ui_right")
		if velocity.x < -0.1:
			$Sprite2D.flip_h = true
		elif velocity.x > 0.1:
			$Sprite2D.flip_h = false
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		#if direction and is_on_floor():
			#velocity.x =  move_toward(velocity.x,direction * SPEED, ACCELERATION)
		#elif(direction and not is_on_floor()):
			#velocity.x = (fly_vel/DRAG)+150*direction
		#else:
			#velocity.x = move_toward(velocity.x, 0, INERTIA)
		move_and_slide()
	
	
func update_animation_status():
	
	# updating the animation tree state
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_running"] = false
		animation_tree["parameters/conditions/is_jumping"] = false
	elif(is_jumping):
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_running"] = false
		animation_tree["parameters/conditions/is_jumping"] = true
	elif(!velocity.x == 0 and is_on_floor()):
		animation_tree["parameters/conditions/is_idle"] = false
		animation_tree["parameters/conditions/is_running"] = true
		animation_tree["parameters/conditions/is_jumping"] = false
	if(direction != Vector2.ZERO):
		animation_tree["parameters/idle/blend_position"] = 	direction
		animation_tree["parameters/move/blend_position"] = 	direction
		
		
func move_to_center(position: Vector2):
	print("Player to area")
	area_position = position
	moving_to_area = true
	
func disable_movement():
	can_move = false
	print("Player can't move again!")

func on_sequence_success():
	can_move = true
	print("Player can move again!")
