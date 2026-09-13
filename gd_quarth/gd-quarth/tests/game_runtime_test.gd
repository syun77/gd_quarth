extends SceneTree


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var game := preload("res://src/scenes/Game.tscn").instantiate()
	root.add_child(game)
	await create_timer(1.1).timeout
	if game.phase != Game.Phase.AIMING:
		push_error("Game did not enter the aiming phase.")
		quit(1)
		return
	game._update_view()
	print("Game aiming runtime test passed.")
	quit(0)
