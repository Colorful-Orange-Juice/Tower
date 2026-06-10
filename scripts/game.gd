extends Node3D # Or Node2D.

@onready var Lobby : Node = $Lobby
@onready var main_menu: Control = $MainMenu

func _ready():
	# Preconfigure game.
	Lobby.new_player.connect(fill_player_list)
	Lobby.player_loaded.rpc_id(1) # Tell the server that this peer has loaded.
	main_menu.button.pressed.connect(_on_create_client)
	main_menu.button_2.pressed.connect(_on_create_server)
	main_menu.start.pressed.connect(start_game)

# Called only on the server.
func start_game():
	# All peers are ready to receive RPCs in this scene.
	Lobby.load_game.rpc("res://scenes/tests/test1/test_scene.tscn")

func fill_player_list():
	for player in Lobby.players:
		main_menu.item_list.add_item("%s: %s" % [player, Lobby.players[player]], null, false)

func _on_create_client():
	print("client button pressed")
	# Create client.
	var peer = ENetMultiplayerPeer.new()
	var ip : String = Lobby.DEFAULT_SERVER_IP
	if main_menu.text_edit.text:
		ip = main_menu.text_edit.text
	var port : int = Lobby.PORT
	if main_menu.text_edit_2.text:
		port = int(main_menu.text_edit_2.text)
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

func _on_create_server():
	print("server button pressed")
	# Create server.
	var peer = ENetMultiplayerPeer.new()
	var port : int = Lobby.PORT
	if main_menu.text_edit_2.text:
		port = int(main_menu.text_edit_2.text)
	peer.create_server(port, Lobby.MAX_CONNECTIONS)
	multiplayer.multiplayer_peer = peer
	print("Players after server creation: ", Lobby.players)
