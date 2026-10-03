extends CharacterBody2D # 이 스크립트가 Player의 물리 이동 기능을 사용하겠다는 뜻
@onready var sprite: Sprite2D = $Sprite2D

# Pellet 장면을 미리 불러옴
const PELLET_SCENE = preload("res://scenes/Pellet.tscn")
const SHELL_SCENE = preload("res://scenes/Shell.tscn")


# 플레이어 이동 속도
@export var speed: float = 250.0
@export var pellet_count: int = 5
@export var spread_angle: float = 25.0

# 현재 장전된 탄약 수
var ammo: int = 1

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
	# 플레이어가 맵 밖으로 나가지 못하도록 제한
	global_position.x = clamp(global_position.x, 0.0, 5000.0)
	global_position.y = clamp(global_position.y, 0.0, 5000.0)
	
	
	## 마우스 위치를 바라보도록 회전
	#look_at(get_global_mouse_position())
	
	# 플레이어 → 마우스 방향의 각도 계산
	var aim_angle = global_position.angle_to_point(get_global_mouse_position())

	# 캐릭터 이미지만 마우스 방향으로 회전
	sprite.rotation = aim_angle

	# 마우스가 왼쪽 영역에 있으면 이미지가 거꾸로 뒤집히는 것을 보정
	sprite.flip_v = abs(aim_angle) > PI / 2
	
	# 마우스 왼쪽 버튼을 눌렀을 때 발사
	if Input.is_action_just_pressed("shoot") and ammo > 0:
		shoot()

# 여기부터는 _physics_process() 밖
func shoot():
	# 발사했으므로 탄약 소모
	ammo = 0

	# 플레이어 → 마우스 기본 발사 방향
	var base_direction = global_position.direction_to(get_global_mouse_position())

	# -------------------------
	# Shell 생성
	# -------------------------
	var shell = SHELL_SCENE.instantiate()
	get_parent().add_child(shell)

	# Shell이 떨어질 거리: 180 ~ 240px
	var shell_distance = randf_range(180.0, 240.0)

	# 발사 방향 기준 각도 오차: -10° ~ +10°
	var shell_angle = deg_to_rad(randf_range(-10.0, 10.0))

	# Shell이 떨어질 방향
	var shell_direction = base_direction.rotated(shell_angle)

	# 최종 Shell 위치
	shell.global_position = global_position + shell_direction * shell_distance

	# -------------------------
	# Pellet 발사
	# -------------------------
	for i in pellet_count:
		var pellet = PELLET_SCENE.instantiate()
		get_parent().add_child(pellet)

		pellet.global_position = global_position

		# -spread_angle/2 ~ +spread_angle/2 범위로 각 Pellet의 각도 분산
		var angle_offset = deg_to_rad(
			-spread_angle / 2.0
			+ spread_angle * i / max(pellet_count - 1, 1)
		)

		pellet.direction = base_direction.rotated(angle_offset)

func reload_shell():
	ammo = 1
