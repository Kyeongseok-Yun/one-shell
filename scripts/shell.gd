extends Area2D

func _on_body_entered(body):
	# Player가 닿았고 ammo 변수를 가지고 있으면 재장전
	if body.has_method("reload_shell"):
		body.reload_shell()
		queue_free()
