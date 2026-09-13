extends SceneTree

var failures := 0


func _init() -> void:
	_test_piece_rotation()
	_test_lock_prediction()
	_test_rectangle_clear()
	_test_hold_rule()
	_test_seeded_queue()
	_test_wave_layouts()
	if failures == 0:
		print("All model tests passed.")
	quit(failures)


func _test_piece_rotation() -> void:
	for shape_id in PieceCatalog.SHAPES:
		var piece := PieceCatalog.create(shape_id)
		var original := piece.cells.duplicate()
		for _turn in 4:
			piece.rotate_right()
		_check(_same_cells(piece.cells, original), "%s does not return after four rotations" % shape_id)


func _test_lock_prediction() -> void:
	var board := Board.new(10, 20, 18)
	board.add_target_cells([Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(2, 3), Vector2i(4, 3)])
	var prediction := board.predict_lock([Vector2i.ZERO], Vector2i(3, 20))
	_check(prediction.locks, "monomino should lock against the target")
	_check(prediction.anchor == Vector2i(3, 3), "monomino lock anchor should be (3, 3)")
	var miss := board.predict_lock([Vector2i.ZERO], Vector2i(8, 20))
	_check(not miss.locks, "a shot without contact should leave the board")


func _test_rectangle_clear() -> void:
	var board := Board.new(10, 20, 18)
	board.add_target_cells([Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(2, 3), Vector2i(4, 3)])
	var locked := board.lock_piece([Vector2i.ZERO], Vector2i(3, 3))
	var matches := board.find_completed_rectangles(locked)
	_check(matches.size() == 3, "closing the frame should include the full and two contained rectangles")
	var cleared := board.clear_rectangles(matches)
	_check(cleared.cells.size() == 6, "rectangle union should clear six occupied cells")
	_check(cleared.target_count == 5, "only target cells should count toward quota")


func _test_hold_rule() -> void:
	var queue := PieceQueue.new(1234)
	_check(queue.use_hold(), "first hold should succeed")
	_check(not queue.use_hold(), "second hold before consumption should fail")
	queue.consume_current()
	_check(queue.use_hold(), "hold should reset after consumption")


func _test_seeded_queue() -> void:
	var first := PieceQueue.new(42)
	var second := PieceQueue.new(42)
	var first_ids: Array[StringName] = [first.current.shape_id]
	var second_ids: Array[StringName] = [second.current.shape_id]
	for index in 3:
		first_ids.append(first.next[index].shape_id)
		second_ids.append(second.next[index].shape_id)
	_check(first_ids == second_ids, "equal seeds should produce equal queues")


func _test_wave_layouts() -> void:
	for wave in range(1, WaveCatalog.WAVE_COUNT + 1):
		var board := Board.new(10, 20, 18)
		var cells := WaveCatalog.cells_for_wave(wave)
		_check(board.add_target_cells(cells), "wave %d cells should fit without overlap" % wave)
		_check(board.find_completed_rectangles(cells).is_empty(), "wave %d must not start with a complete rectangle" % wave)


func _same_cells(first: Array[Vector2i], second: Array[Vector2i]) -> bool:
	if first.size() != second.size():
		return false
	for cell in first:
		if cell not in second:
			return false
	return true


func _check(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error(message)
