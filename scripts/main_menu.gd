class_name MainMenu
extends Control

@onready var ip_text: TextEdit = $IPText
@onready var port_text: TextEdit = $PortText
@onready var name_text: TextEdit = $NameText

@onready var join_button: Button = $JoinButton
@onready var host_button: Button = $HostButton
@onready var start_button: Button = $StartButton

@onready var connected_players: ItemList = $ConnectedPlayers

func show_connection_info():
	start_button.visible = false
	connected_players.visible = false

func show_ready_menu(is_server : bool = false):
	if is_server:
		start_button.visible = true
	connected_players.visible = true
	join_button.visible = false
	host_button.visible = false
	ip_text.visible = false
	port_text.visible = false
	name_text.visible = false
	$IPLabel.visible = false
	$PortLabel.visible = false
	$NameLabel.visible = false
