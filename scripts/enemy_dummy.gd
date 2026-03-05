extends StaticBody2D

@export var max_hp := 6

@onready var hp_label: Label = $HPLabel

var hp := 0


func _ready() -> void:
	hp = max_hp
	_refresh_label()


func take_hit(damage: int) -> void:
	hp -= max(damage, 0)
	_refresh_label()
	if hp <= 0:
		queue_free()


func _refresh_label() -> void:
	hp_label.text = "Dummy HP: %d" % hp
