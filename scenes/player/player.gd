extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity := 0.005
@export var max_pitch := deg_to_rad(89)
@export var min_pitch := deg_to_rad(-89)

@onready var camera_pivot: Node3D = $CameraPivot
@onready var inner_gimbal: Node3D = $CameraPivot/InnerGimbal

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (camera_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		camera_pivot.rotate_y(-event.relative.x * mouse_sensitivity)
		
		inner_gimbal.rotate_x(-event.relative.y * mouse_sensitivity)
		
		inner_gimbal.rotation.x = clamp(inner_gimbal.rotation.x, min_pitch, max_pitch)
