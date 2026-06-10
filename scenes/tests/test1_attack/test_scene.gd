extends Node3D

const PLAYER_SCENE = preload("res://scenes/player_attack/Player.tscn")
@onready var players_container = $Players
@onready var spawn_marker = $SpawnMarker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	
	# Spawn a player for the server owner
	if multiplayer.is_server():
		spawn_player(1);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


##
## Spawns a character for the incoming client
##
func _on_player_connected(id : int) -> void:
	spawn_player(id)

##
## Spawns a player, assigning an id
##
func spawn_player(id : int) -> void:
	var player = PLAYER_SCENE.instantiate()
	
	player.name = str(id)
	player.set_multiplayer_authority(id)
	
	# Spawner will replicate this player to all clients automatically
	players_container.add_child(player)
	
	# Tell the server and all clients to move the player
	player.set_initial_position(spawn_marker.global_position)
