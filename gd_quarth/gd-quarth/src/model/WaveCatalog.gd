class_name WaveCatalog
extends RefCounted

const WAVE_COUNT := 6


static func cells_for_wave(number: int) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	match number:
		1:
			_add_open_frame(result, 2, 2, 3)
			_add_open_frame(result, 6, 6, 3)
		2:
			_add_open_frame(result, 1, 2, 5)
			_add_open_frame(result, 5, 7, 4)
		3:
			_add_open_frame(result, 0, 3, 3)
			_add_open_frame(result, 4, 5, 5)
			_add_open_frame(result, 7, 10, 3)
		4:
			_add_open_frame(result, 1, 2, 4)
			_add_open_frame(result, 5, 4, 4)
			_add_open_frame(result, 2, 9, 6)
		5:
			_add_open_frame(result, 0, 4, 5)
			_add_open_frame(result, 5, 7, 5)
			_add_open_frame(result, 3, 11, 4)
		_:
			_add_open_frame(result, 0, 2, 10)
			_add_open_frame(result, 2, 6, 6)
			_add_open_frame(result, 3, 10, 4)
	return _unique(result)


static func descent_interval(number: int) -> float:
	return [9.0, 8.5, 8.0, 7.0, 6.0, 5.5][clampi(number - 1, 0, WAVE_COUNT - 1)]


static func _add_open_frame(output: Array[Vector2i], left: int, top: int, width: int) -> void:
	for x in range(left, left + width):
		output.append(Vector2i(x, top))
	output.append(Vector2i(left, top + 1))
	output.append(Vector2i(left + width - 1, top + 1))


static func _unique(values: Array[Vector2i]) -> Array[Vector2i]:
	var seen := {}
	var result: Array[Vector2i] = []
	for value in values:
		if not seen.has(value):
			seen[value] = true
			result.append(value)
	return result
