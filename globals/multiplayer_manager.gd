extends Node

signal players_updated(player_data)

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20
const HOST_ID = 1

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players : Dictionary = {}
#var player_info = {"name": "Name"}

var players_loaded : int = 0

func _ready() -> void:
	# Preconfigure game.
	connect_signals_for_multiplayer()

func connect_signals_for_multiplayer() -> void:
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_client(ip, port):
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func create_server(port, host_data):
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer
	players[1] = host_data
	players_updated.emit(players)


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()
	if multiplayer.is_server(): players_updated.emit(players)


# When the server decides to start the game from a UI scene,
# do Lobby.load_game.rpc(filepath)
@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)


# Every peer will call this when they have loaded the game scene.
@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		"if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0"


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id, player_data):
	_register_player.rpc_id(id, player_data)


@rpc("any_peer", "reliable")
func _register_player(new_player_data):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_data
	if multiplayer.is_server(): players_updated.emit(players)


func _on_player_disconnected(id):
	players.erase(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	print("your id is ", peer_id)


func _on_connected_fail():
	remove_multiplayer_peer()


func _on_server_disconnected():
	remove_multiplayer_peer()
	players.clear()
