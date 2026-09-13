class_name PieceCatalog
extends RefCounted

const SHAPES := {
	&"M1": [Vector2i(0, 0)],
	&"D2": [Vector2i(0, 0), Vector2i(1, 0)],
	&"I3": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)],
	&"L3": [Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)],
	&"I4": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)],
	&"O4": [Vector2i(0, -1), Vector2i(1, -1), Vector2i(0, 0), Vector2i(1, 0)],
	&"T4": [Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, -1)],
	&"L4": [Vector2i(0, -2), Vector2i(0, -1), Vector2i(0, 0), Vector2i(1, 0)],
	&"S4": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(-1, -1), Vector2i(0, -1)],
}

const BY_SIZE := {
	1: [&"M1"],
	2: [&"D2"],
	3: [&"I3", &"L3"],
	4: [&"I4", &"O4", &"T4", &"L4", &"S4"],
}


static func create(shape_id: StringName) -> Piece:
	var source: Array[Vector2i] = []
	for value in SHAPES[shape_id]:
		source.append(value)
	return Piece.new(shape_id, source)


static func ids_for_size(size: int) -> Array[StringName]:
	var result: Array[StringName] = []
	for shape_id in BY_SIZE[size]:
		result.append(shape_id)
	return result
