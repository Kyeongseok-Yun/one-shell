extends CharacterBody2D # 이 스크립트가 Player의 물리 이동 기능을 사용하겠다는 뜻
@onready var sprite: Sprite2D = $Sprite2D
@onready var hud = get_tree().current_scene.get_node("UI/HUD")
@onready var shotgun_sound: AudioStreamPlayer2D = $ShotgunSound

## 카메라 쉐이크용 코드
@onready var camera: Camera2D = $Camera2D

@export var shake_strength: float = 2.0
@export var shake_duration: float = 0.08

# Pellet 장면을 미리 불러옴
const PELLET_SCENE = preload("res://scenes/Pellet.tscn")
const SHELL_SCENE = preload("res://scenes/Shell.tscn")

# 총구화염 코드
@onready var muzzle_flash: Sprite2D = $MuzzleFlash

@export var muzzle_distance: float = 55.0
@export var muzzle_flash_time: float = 0.05

# 플레이어 이동 속도
@export var speed: float = 250.0
@export var pellet_count: int = 5
@export var spread_angle: float = 25.0
@export var knockback_force: float = 250.0

# 대시 기능
@export var dash_distance: float = 140.0
@export var dash_cooldown: float = 0.7
var can_dash: bool = true
var map_margin: float = 40.0

# 한 번 맞은 뒤 다시 맞을 수 있기까지의 시간
@export var damage_cooldown: float = 0.8

# 현재 데미지를 받을 수 있는 상태인지
var can_take_damage: bool = true

# 플레이어 최대 체력
@export var max_health: int = 5
# 현재 체력
var health: int = 5
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
	if Input.is_action_just_pressed("dash") and can_dash:
		dash()
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
	hud.update_shell(ammo)
	shotgun_sound.play()
	screen_shake()
	# 플레이어 → 마우스 기본 발사 방향
	var base_direction = global_position.direction_to(get_global_mouse_position())
	show_muzzle_flash(base_direction)

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
		pellet.knockback_force = knockback_force

		# -spread_angle/2 ~ +spread_angle/2 범위로 각 Pellet의 각도 분산
		var angle_offset = deg_to_rad(
			-spread_angle / 2.0
			+ spread_angle * i / max(pellet_count - 1, 1)
		)

		pellet.direction = base_direction.rotated(angle_offset)

func reload_shell():
	ammo = 1
	hud.update_shell(ammo)

func take_damage(amount: int):
	# 무적시간 중이면 데미지 무시
	if not can_take_damage:
		return

	# 체력 감소
	health -= amount
	hud.update_hp(health)

	# 무적 상태 시작
	can_take_damage = false

	print("Player HP: ", health)

	# 체력이 0 이하라면 사망
	if health <= 0:
		die()
		return

	# 피격 깜빡임 시작
	flash_invincibility()

	# 무적시간 대기
	await get_tree().create_timer(damage_cooldown).timeout

	# 다시 피격 가능
	can_take_damage = true

	# 혹시 깜빡임 도중 꺼진 상태라면 다시 표시
	sprite.visible = true


func die():
	var main = get_tree().current_scene

	if main.has_method("game_over"):
		main.game_over()

func flash_invincibility():
	for i in 4:
		sprite.visible = false
		await get_tree().create_timer(0.1).timeout

		sprite.visible = true
		await get_tree().create_timer(0.1).timeout

func screen_shake():
	var elapsed := 0.0

	while elapsed < shake_duration:
		camera.offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

		await get_tree().process_frame
		elapsed += get_process_delta_time()

	camera.offset = Vector2.ZERO

func show_muzzle_flash(direction: Vector2):
	# 플레이어 중심에서 조준 방향으로 이동
	muzzle_flash.position = direction * muzzle_distance

	# 조준 방향에 맞춰 회전
	muzzle_flash.rotation = direction.angle()

	muzzle_flash.visible = true

	await get_tree().create_timer(muzzle_flash_time).timeout

	muzzle_flash.visible = false

#대시 함수
func dash():
	can_dash = false

	var dash_direction = global_position.direction_to(
		get_global_mouse_position()
	)

	var start_position = global_position
	var end_position = start_position + dash_direction * dash_distance

	# 맵 밖으로 못 나가게
	end_position.x = clamp(
		end_position.x,
		map_margin,
		5000.0 - map_margin
	)

	end_position.y = clamp(
		end_position.y,
		map_margin,
		5000.0 - map_margin
	)

	# 대시 경로에 잔상 5개 생성
	var afterimage_count = 5

	for i in range(afterimage_count):
		var ratio = float(i) / float(afterimage_count)
		var ghost_position = start_position.lerp(end_position, ratio)

		var alpha = 0.2 + ratio * 0.35

		create_afterimage(ghost_position, alpha)

	# 실제 플레이어 이동
	global_position = end_position

	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

#대시 이후 잔상
func create_afterimage(ghost_position: Vector2, alpha: float):
	var ghost = Sprite2D.new()

	ghost.texture = sprite.texture
	ghost.global_position = ghost_position
	ghost.rotation = sprite.rotation
	ghost.flip_h = sprite.flip_h
	ghost.flip_v = sprite.flip_v
	ghost.scale = sprite.scale

	ghost.modulate = Color(1, 1, 1, alpha)

	get_parent().add_child(ghost)

	var tween = get_tree().create_tween()

	tween.tween_property(
		ghost,
		"modulate:a",
		0.0,
		0.3
	)

	tween.tween_callback(ghost.queue_free)
