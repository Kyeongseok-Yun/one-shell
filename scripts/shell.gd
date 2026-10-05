extends Area2D

@onready var reload_sound: AudioStreamPlayer2D = $ReloadSound

func _on_body_entered(body):
	# Player가 닿았고 ammo 변수를 가지고 있으면 재장전
	if body.has_method("reload_shell"):
		body.reload_shell()

		# 중복 습득 방지
		monitoring = false
		$Sprite2D.visible = false
		$CollisionShape2D.disabled = true

		reload_sound.play()
		await reload_sound.finished

		queue_free()
