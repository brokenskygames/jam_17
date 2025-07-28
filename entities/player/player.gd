extends CharacterBody2D


const SPEED = 800.0
const JUMP_VELOCITY = -700.0
const DRAG = 2
const INERTIA = 100
const ACCELERATION = 40

@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_tree : AnimationTree = sprite.get_node("AnimationTree")

var direction : Vector2 = Vector2.ZERO
var dir_facing : Vector2 = Vector2.ZERO
var fly_vel = 0


func _ready():
	# initial animation state
	animation_tree["parameters/conditions/is_idle"] = true
	animation_tree["parameters/conditions/is_running"] = false
	ProjectSettings.set_setting("physics/2d/default_gravity", -2000)
	dir_facing = Vector2 (1,0 )
	

func _physics_process(delta: float) -> void:
	
	
	print(velocity.x)
	update_animation_status()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta*1.6

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():		
		velocity.y = JUMP_VELOCITY
		fly_vel = velocity.x
		
	if is_on_floor():
		animation_tree["parameters/conditions/is_jumping"] = false
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if velocity.x < -0.1:
		$Sprite2D.flip_h = true
	elif velocity.x > 0.1:
		$Sprite2D.flip_h = false
	if direction and is_on_floor():
		velocity.x =  move_toward(velocity.x,direction * SPEED, ACCELERATION)
	elif(direction and not is_on_floor()):
		velocity.x = (fly_vel/DRAG)+150*direction
	else:
		velocity.x = move_toward(velocity.x, 0, INERTIA)

		

	move_and_slide()
	
	
func update_animation_status():
	
	# updating the animation tree state
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/is_idle"] = true
		animation_tree["parameters/conditions/is_running"] = false
		animation_tree["parameters/conditions/is_jumping"] = false
	elif(not is_on_floor()):
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
