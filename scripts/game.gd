extends Node3D # Or Node2D.

@onready var main_menu: MainMenu = $MainMenu

const PORT = 7000
const DEFAULT_SERVER_IP = "127.0.0.1" # IPv4 localhost
const MAX_CONNECTIONS = 20
const HOST_ID = 1

func _ready() -> void:
	main_menu.join_button.pressed.connect(_on_create_client)
	main_menu.host_button.pressed.connect(_on_create_server)
	main_menu.start_button.pressed.connect(start_game)
	main_menu.show_connection_info()
	MultiplayerManager.players_updated.connect(_on_players_updated)

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	MultiplayerManager.load_game.rpc("res://scenes/tests/test1_attack/test_scene.tscn")

func _on_create_client():
	print("client button pressed")
	if main_menu.name_text.text == "": 
		main_menu.display_error("Please enter a name")
		return
	var ip : String = DEFAULT_SERVER_IP
	if main_menu.ip_text.text:
		ip = main_menu.ip_text.text
	var port : int = PORT
	if main_menu.port_text.text:
		port = int(main_menu.port_text.text)
	MultiplayerManager.create_client(ip, port)
	main_menu.show_ready_menu()
	MultiplayerManager.player_loaded.rpc_id(HOST_ID)

func _on_create_server():
	print("server button pressed")
	if main_menu.name_text.text == "": 
		main_menu.display_error("Please enter a name")
		return
	var port : int = PORT
	if main_menu.port_text.text:
		port = int(main_menu.text_edit_2.text)
	MultiplayerManager.create_server(port, {"name": main_menu.name_text.text})
	main_menu.show_ready_menu(true)
	MultiplayerManager.player_loaded.rpc_id(HOST_ID)

func _on_players_updated(players):
	main_menu.connected_players.clear()
	for id in players:
		main_menu.connected_players.add_item("%s: %s" % [id, players[id]["name"]], null, false)
