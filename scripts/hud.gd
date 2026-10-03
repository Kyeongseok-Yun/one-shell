extends Control

@onready var hp_label: Label = $HpLabel
@onready var shell_label: Label = $ShellLabel
@onready var kills_label: Label = $KillsLabel
@onready var time_label: Label = $TimeLabel

func update_hp(current_hp: int):
	hp_label.text = "HP       " + "♥".repeat(current_hp)

func update_shell(ammo: int):
	if ammo > 0:
		shell_label.text = "SHELL    READY"
	else:
		shell_label.text = "SHELL    EMPTY"

func update_kills(kills: int):
	kills_label.text = "KILLS    " + str(kills)

func update_time(seconds: float):
	var total_seconds = int(seconds)
	var minutes = total_seconds / 60
	var secs = total_seconds % 60

	time_label.text = "TIME     %02d:%02d" % [minutes, secs]
