class_name PieceQueue
extends RefCounted

const BAG_SIZES := [1, 2, 2, 3, 3, 4, 4]

var current: Piece
var next: Array[Piece] = []
var held: Piece
var hold_used := false
var _bag: Array[int] = []
var _rng := RandomNumberGenerator.new()
var _recent_ids: Array[StringName] = []


func _init(seed_value: int = 0) -> void:
	_rng.seed = seed_value if seed_value != 0 else Time.get_ticks_usec()
	current = _draw_piece()
	while next.size() < 3:
		next.append(_draw_piece())


func consume_current() -> void:
	current = next.pop_front()
	next.append(_draw_piece())
	hold_used = false


func use_hold() -> bool:
	if hold_used:
		return false
	hold_used = true
	if held == null:
		held = current
		current = next.pop_front()
		next.append(_draw_piece())
	else:
		var swap := current
		current = held
		held = swap
	return true


func _draw_piece() -> Piece:
	if _bag.is_empty():
		_bag.assign(BAG_SIZES)
		_shuffle(_bag)
	var size: int = _bag.pop_back()
	var candidates := PieceCatalog.ids_for_size(size)
	var shape_id: StringName = candidates[_rng.randi_range(0, candidates.size() - 1)]
	if _recent_ids.size() >= 2 and _recent_ids[-1] == shape_id and _recent_ids[-2] == shape_id and candidates.size() > 1:
		var alternatives := candidates.filter(func(id: StringName) -> bool: return id != shape_id)
		shape_id = alternatives[_rng.randi_range(0, alternatives.size() - 1)]
	_recent_ids.append(shape_id)
	if _recent_ids.size() > 2:
		_recent_ids.pop_front()
	return PieceCatalog.create(shape_id)


func _shuffle(values: Array[int]) -> void:
	for index in range(values.size() - 1, 0, -1):
		var other := _rng.randi_range(0, index)
		var value := values[index]
		values[index] = values[other]
		values[other] = value
