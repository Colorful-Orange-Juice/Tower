extends Node3D

const PLAYER_SCENE = preload("res://scenes/player_attack/Player.tscn")
@onready var players_container = $Players
@onready var spawn_marker = $SpawnMarker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if (not multiplayer.is_server()):
		return
	
	spawn_player(1) # Spawn host
	
	for peer_id in multiplayer.get_peers():
		print("Spawning peer: ", peer_id)
		spawn_player(peer_id)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


##
## Spawns a player, assigning an id
##
func spawn_player(id : int) -> void:
	var player = PLAYER_SCENE.instantiate()
	
	player.name = str(id)
	player.set_multiplayer_authority(id)
	player.position = spawn_marker.global_position
	
	# Spawner will replicate this player to all clients automatically
	players_container.add_child(player)
	
	await get_tree().process_frame # Wait a frame before making rpc call
	
	# Tell the server and all clients to move the player
	#player.set_initial_position.rpc(spawn_marker.global_position)
