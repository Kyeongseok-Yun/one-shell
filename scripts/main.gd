extends Node2D

# 배경 이미지
const GROUND_TEXTURE = preload("res://assets/sprites/background_icon.png")
const ENEMY_SCENE = preload("res://scenes/Enemy.tscn")
# 맵 크기
@export var map_width: int = 5000
@export var map_height: int = 5000

# 현재 킬 수
var kills: int = 0

# 생존 시간
var survival_time: float = 0.0

# HUD 참조
@onready var hud = $UI/HUD

@onready var game_over_panel = $UI/GameOverPanel
@onready var game_over_kills_label = $UI/GameOverPanel/VBoxContainer/KillsLabel
@onready var game_over_time_label = $UI/GameOverPanel/VBoxContainer/TimeLabel


func _ready():
	create_ground()
	var player = get_tree().get_first_node_in_group("player")

	hud.update_hp(player.health)
	hud.update_shell(player.ammo)
	hud.update_kills(kills)
	hud.update_time(survival_time)


func create_ground():
	var tile_width = GROUND_TEXTURE.get_width()
	var tile_height = GROUND_TEXTURE.get_height()

	# 5000px을 전부 덮기 위해 필요한 타일 개수
	var columns = int(ceil(float(map_width) / tile_width))
	var rows = int(ceil(float(map_height) / tile_height))

	for y in range(rows):
		for x in range(columns):
			var ground_tile = Sprite2D.new()

			ground_tile.texture = GROUND_TEXTURE

			# Sprite 중심이 아니라 좌측 상단을 좌표 기준점으로 사용
			ground_tile.centered = false

			ground_tile.position = Vector2(
				x * tile_width,
				y * tile_height
			)

			$Ground.add_child(ground_tile)


func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

# 적 생성 함수
func spawn_enemy():
	var enemy = ENEMY_SCENE.instantiate()

	add_child(enemy)

	var player = get_tree().get_first_node_in_group("player")

	if player == null:
		return

	var spawn_distance = 700.0
	var random_angle = randf_range(0.0, TAU)

	var spawn_direction = Vector2.RIGHT.rotated(random_angle)

	var spawn_position = (
		player.global_position
		+ spawn_direction * spawn_distance
	)

	# 5000 x 5000 맵 밖으로 나가지 않도록 제한
	spawn_position.x = clamp(
		spawn_position.x,
		50.0,
		map_width - 50.0
	)

	spawn_position.y = clamp(
		spawn_position.y,
		50.0,
		map_height - 50.0
	)

	enemy.global_position = spawn_position

func _process(delta):
	survival_time += delta
	hud.update_time(survival_time)

func add_kill():
	kills += 1
	hud.update_kills(kills)

func game_over():
	# 게임 정지
	get_tree().paused = true

	# Game Over UI 표시
	game_over_panel.visible = true

	# 최종 킬 수 표시
	game_over_kills_label.text = "KILLS    " + str(kills)

	# 최종 생존 시간 표시
	var total_seconds = int(survival_time)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60

	game_over_time_label.text = "SURVIVAL    %02d:%02d" % [minutes, seconds]


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
