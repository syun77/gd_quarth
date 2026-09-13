extends Node2D
# ================================================
# メインシーン.
# ================================================
class_name MainScene

const GAME_SCENE := preload("res://src/scenes/Game.tscn")


func _ready() -> void:
	Common.register_main(self)
	add_child(GAME_SCENE.instantiate())
