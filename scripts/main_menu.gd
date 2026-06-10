extends Control

@onready var ip_text: TextEdit = $IPText
@onready var port_text: TextEdit = $PortText
@onready var name_text: TextEdit = $NameText

@onready var join_button: Button = $JoinButton
@onready var host_button: Button = $HostButton
@onready var start_button: Button = $StartButton

@onready var connected_players: ItemList = $ConnectedPlayers
