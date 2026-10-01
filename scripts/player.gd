extends CharacterBody2D # 이 스크립트가 Player의 물리 이동 기능을 사용하겠다는 뜻


# 플레이어 이동 속도
@export var speed: float = 250.0

func _physics_process(delta):
	# WASD 입력을 하나의 방향 벡터로 변환
	var direction = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	# 입력 방향에 이동속도를 곱해서 velocity 계산
	velocity = direction * speed

	# CharacterBody2D 실제 이동
	move_and_slide()
	
	# 마우스 위치를 바라보도록 회전
	look_at(get_global_mouse_position())
