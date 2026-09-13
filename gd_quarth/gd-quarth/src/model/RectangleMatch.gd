class_name RectangleMatch
extends RefCounted

var rect: Rect2i


func _init(value: Rect2i) -> void:
	rect = value


func contains_on_border(cell: Vector2i) -> bool:
	var right := rect.end.x - 1
	var bottom := rect.end.y - 1
	return rect.has_point(cell) and (cell.x == rect.position.x or cell.x == right or cell.y == rect.position.y or cell.y == bottom)


func area_cells() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			result.append(Vector2i(x, y))
	return result
