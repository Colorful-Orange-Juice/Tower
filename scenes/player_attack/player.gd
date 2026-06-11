class_name Player
extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var mouse_sensitivity := 0.005
@export var max_pitch := deg_to_rad(89)
@export var min_pitch := deg_to_rad(-89)

@onready var camera_pivot: Node3D = $CameraPivot
@onready var inner_gimbal: Node3D = $CameraPivot/InnerGimbal
@onready var ray: RayCast3D = $CameraPivot/InnerGimbal/Ray
@onready var camera: Camera3D = $CameraPivot/InnerGimbal/PlayerCam

var health : float = 100.0

signal damage_taken(damage_amount)
signal player_death(id)

func _ready() -> void:
	damage_taken.connect(_on_damage_taken)
	player_death.connect(_on_player_death)
	camera.current = is_multiplayer_authority()


func _enter_tree() -> void:
	print("Player " + name + " entering scene!")
	set_multiplayer_authority(name.to_int())


func _process(_delta: float) -> void:
	var collider = ray.get_collider()
	if collider and collider.is_in_group("Interactable"):
		if Input.is_action_just_pressed("interact"):
			print("Interacted with ", collider)

func _physics_process(delta: float) -> void:
	# Checks if the instance owns this player
	if not is_multiplayer_authority():
		return
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector("move_l", "move_r", "move_f", "move_b")
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

@rpc("authority", "call_local", "reliable")
func set_initial_position(pos: Vector3) -> void:
	global_position = pos

func _on_damage_taken(damage_amt : float) -> void:
	health -= damage_amt
	if health <= 0:
		health = 0
		player_death.emit(name)

func _on_player_death(id) -> void:
	print("Player " + id + " died")
