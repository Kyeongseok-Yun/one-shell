extends Node2D

# 배경 이미지
const GROUND_TEXTURE = preload("res://assets/sprites/background_icon.png")

# 맵 크기
@export var map_width: int = 5000
@export var map_height: int = 5000


func _ready():
	create_ground()


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
