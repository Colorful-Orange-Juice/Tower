extends Node3D # Or Node2D.

@onready var main_menu: Control = $MainMenu

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}
#var player_info = {"name": "Name"}

var players_loaded = 0

func _ready():
	# Preconfigure game.
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	main_menu.join_button.pressed.connect(_on_create_client)
	main_menu.host_button.pressed.connect(_on_create_server)
	main_menu.start_button.pressed.connect(start_game)

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	load_game.rpc("res://scenes/tests/test1/test_scene.tscn")

func _on_create_client():
	print("client button pressed")
	if main_menu.name_text.text == "": return
	# Create client.
	var peer = ENetMultiplayerPeer.new()
	var ip : String = DEFAULT_SERVER_IP
	if main_menu.ip_text.text:
		ip = main_menu.ip_text.text
	var port : int = PORT
	if main_menu.port_text.text:
		port = int(main_menu.port_text.text)
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func _on_create_server():
	print("server button pressed")
	if main_menu.name_text.text == "": return
	players[1] = {"name": main_menu.name_text.text}
	# Create server.
	var peer = ENetMultiplayerPeer.new()
	var port : int = PORT
	if main_menu.port_text.text:
		port = int(main_menu.text_edit_2.text)
	peer.create_server(port, MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	players.clear()


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
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0


# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	_register_player.rpc_id(id, {"name": main_menu.name_text.text})


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	if multiplayer.is_server(): _send_player_data.rpc_id(1, players)

@rpc("call_local")
func _send_player_data(player_list):
	main_menu.connected_players.clear()
	for id in player_list:
		main_menu.connected_players.add_item("%s: %s" % [id, player_list[id]["name"]], null, false)


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
