extends StaticBody3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		print("Player " + body.name + " damaged")
		body.damage_taken.emit(10.0)
