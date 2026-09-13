class_name Piece
extends RefCounted

var shape_id: StringName
var rotation := 0
var cells: Array[Vector2i] = []


func _init(id: StringName, base_cells: Array[Vector2i], turns := 0) -> void:
	shape_id = id
	cells.assign(base_cells)
	for _turn in range(posmod(turns, 4)):
		rotate_right()


func duplicate_piece() -> Piece:
	return Piece.new(shape_id, cells, 0)


func rotate_right() -> void:
	for index in cells.size():
		var cell := cells[index]
		cells[index] = Vector2i(-cell.y, cell.x)
	rotation = posmod(rotation + 1, 4)


func rotate_left() -> void:
	for index in cells.size():
		var cell := cells[index]
		cells[index] = Vector2i(cell.y, -cell.x)
	rotation = posmod(rotation - 1, 4)


func rotated(clockwise: bool) -> Piece:
	var result := duplicate_piece()
	result.rotation = rotation
	if clockwise:
		result.rotate_right()
	else:
		result.rotate_left()
	return result


func bounds() -> Rect2i:
	var min_pos := cells[0]
	var max_pos := cells[0]
	for cell in cells:
		min_pos = Vector2i(min(min_pos.x, cell.x), min(min_pos.y, cell.y))
		max_pos = Vector2i(max(max_pos.x, cell.x), max(max_pos.y, cell.y))
	return Rect2i(min_pos, max_pos - min_pos + Vector2i.ONE)


func absolute_cells(anchor: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for cell in cells:
		result.append(anchor + cell)
	return result
