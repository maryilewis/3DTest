extends CharacterBody3D

const WALK_SPEED = 7.5
const RUN_SPEED = 15.0
const TURN_SPEED = 0.5
var speed = RUN_SPEED

const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$AnimationTree.active = true

func update_animations():
	var is_running = false
	var is_idle = false

	if velocity != Vector3.ZERO:
		is_running = true
	else:
		is_idle = true

	$AnimationTree["parameters/conditions/is_running"] = is_running
	$AnimationTree["parameters/conditions/is_idle"] = is_idle

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= 15 * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimationTree["parameters/conditions/is_jumping"] = true
	else:
		$AnimationTree["parameters/conditions/is_jumping"] = false
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var target_direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if target_direction:
		var direction = target_direction
		velocity.x = move_toward(velocity.x, direction.x * speed, TURN_SPEED)
		velocity.z = move_toward(velocity.z, direction.z * speed, TURN_SPEED)
		$CharacterArmature.look_at(global_position - velocity.normalized())
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	update_animations()
