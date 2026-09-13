class_name Board
extends RefCounted

enum CellKind { EMPTY, TARGET, PLACED }

var width: int
var height: int
var danger_y: int
var _cells: Array2D


func _init(board_width := 10, board_height := 20, danger_line := 18) -> void:
	width = board_width
	height = board_height
	danger_y = danger_line
	_cells = Array2D.new(width, height, CellKind.EMPTY)


func clear() -> void:
	_cells.clear()


func is_inside(cell: Vector2i) -> bool:
	return _cells.is_valid_pos(cell)


func get_cell(cell: Vector2i) -> int:
	return _cells.getv_pos(cell)


func is_occupied(cell: Vector2i) -> bool:
	return is_inside(cell) and get_cell(cell) != CellKind.EMPTY


func occupied_cells() -> Array[Vector2i]:
	return _cells.find_if(func(_x: int, _y: int, value: int) -> bool: return value != CellKind.EMPTY)


func cells_of_kind(kind: CellKind) -> Array[Vector2i]:
	return _cells.find(kind)


func can_place(relative_cells: Array[Vector2i], anchor: Vector2i) -> bool:
	for cell in relative_cells:
		var position := anchor + cell
		if not is_inside(position) or is_occupied(position):
			return false
	return true


func lock_piece(relative_cells: Array[Vector2i], anchor: Vector2i, kind: CellKind = CellKind.PLACED) -> Array[Vector2i]:
	if not can_place(relative_cells, anchor):
		return []
	var locked: Array[Vector2i] = []
	for cell in relative_cells:
		var position := anchor + cell
		_cells.setv_pos(position, kind)
		locked.append(position)
	return locked


func add_target_cells(positions: Array[Vector2i]) -> bool:
	for position in positions:
		if not is_inside(position) or is_occupied(position):
			return false
	for position in positions:
		_cells.setv_pos(position, CellKind.TARGET)
	return true


func has_adjacent_occupied(positions: Array[Vector2i]) -> bool:
	for position in positions:
		for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var neighbor: Vector2i = position + direction
			if neighbor not in positions and is_occupied(neighbor):
				return true
	return false


func predict_lock(relative_cells: Array[Vector2i], launch_anchor: Vector2i) -> Dictionary:
	var anchor := launch_anchor
	var path: Array[Vector2i] = [anchor]
	while true:
		var next_anchor := anchor + Vector2i.UP
		var next_cells := _absolute_cells(relative_cells, next_anchor)
		var all_above := true
		var collides := false
		for position in next_cells:
			if position.y >= 0:
				all_above = false
			if is_occupied(position):
				collides = true
		if collides:
			var positions := _absolute_cells(relative_cells, anchor)
			var valid := true
			for position in positions:
				if not is_inside(position) or is_occupied(position):
					valid = false
					break
			return {"locks": valid and has_adjacent_occupied(positions), "anchor": anchor, "path": path}
		if all_above:
			return {"locks": false, "anchor": next_anchor, "path": path}
		anchor = next_anchor
		path.append(anchor)
	return {"locks": false, "anchor": anchor, "path": path}


func find_completed_rectangles(new_cells: Array[Vector2i]) -> Array[RectangleMatch]:
	var matches: Array[RectangleMatch] = []
	for top in range(height - 1):
		for bottom in range(top + 1, height):
			for left in range(width - 1):
				for right in range(left + 1, width):
					var match := RectangleMatch.new(Rect2i(left, top, right - left + 1, bottom - top + 1))
					var includes_new := false
					for cell in new_cells:
						if match.contains_on_border(cell):
							includes_new = true
							break
					if includes_new and _border_is_filled(left, top, right, bottom):
						matches.append(match)
	return matches


func clear_rectangles(matches: Array[RectangleMatch]) -> Dictionary:
	var unique := {}
	for match in matches:
		for position in match.area_cells():
			unique[position] = true
	var cleared: Array[Vector2i] = []
	var target_count := 0
	for position: Vector2i in unique:
		var kind := get_cell(position)
		if kind == CellKind.EMPTY:
			continue
		if kind == CellKind.TARGET:
			target_count += 1
		_cells.setv_pos(position, CellKind.EMPTY)
		cleared.append(position)
	return {"cells": cleared, "target_count": target_count}


func shift_down() -> bool:
	for y in range(height - 1, 0, -1):
		for x in width:
			_cells.setv(x, y, _cells.getv(x, y - 1))
	for x in width:
		_cells.setv(x, 0, CellKind.EMPTY)
	for position in occupied_cells():
		if position.y >= danger_y:
			return true
	return false


func _absolute_cells(relative_cells: Array[Vector2i], anchor: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in relative_cells:
		result.append(anchor + cell)
	return result


func _border_is_filled(left: int, top: int, right: int, bottom: int) -> bool:
	for x in range(left, right + 1):
		if not is_occupied(Vector2i(x, top)) or not is_occupied(Vector2i(x, bottom)):
			return false
	for y in range(top + 1, bottom):
		if not is_occupied(Vector2i(left, y)) or not is_occupied(Vector2i(right, y)):
			return false
	return true
