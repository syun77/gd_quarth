class_name BoardView
extends Node2D

const CELL_SIZE := 32.0
const BOARD_SIZE := Vector2(320.0, 640.0)

var board: Board
var ghost_cells: Array[Vector2i] = []
var clear_cells: Array[Vector2i] = []
var projectile_cells: Array[Vector2i] = []
var launcher_cells: Array[Vector2i] = []
var projectile_offset := Vector2.ZERO
var ghost_warning := false


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, BOARD_SIZE), Color("101828"), true)
	for y in 21:
		var line_y := y * CELL_SIZE
		draw_line(Vector2(0, line_y), Vector2(BOARD_SIZE.x, line_y), Color("24354c"), 1.0)
	for x in 11:
		var line_x := x * CELL_SIZE
		draw_line(Vector2(line_x, 0), Vector2(line_x, BOARD_SIZE.y), Color("24354c"), 1.0)
	if board == null:
		return
	for cell in board.occupied_cells():
		_draw_cell(cell, Color("e5b567") if board.get_cell(cell) == Board.CellKind.TARGET else Color("73daca"), false)
	for cell in ghost_cells:
		_draw_cell(cell, Color("ff6b6b", 0.42) if ghost_warning else Color("a8dadc", 0.34), true)
	for cell in clear_cells:
		_draw_cell(cell, Color("fff3b0", 0.62), true)
	for cell in projectile_cells:
		_draw_cell(cell, Color("73daca"), false, projectile_offset)
	for cell in launcher_cells:
		_draw_cell(cell, Color("8be9fd"), false)
	draw_line(Vector2(0, board.danger_y * CELL_SIZE), Vector2(BOARD_SIZE.x, board.danger_y * CELL_SIZE), Color("ff5d73"), 3.0)
	var launcher_center := Vector2(BOARD_SIZE.x * 0.5, BOARD_SIZE.y + 32.0)
	draw_colored_polygon(PackedVector2Array([launcher_center + Vector2(-18, 20), launcher_center + Vector2(18, 20), launcher_center + Vector2(0, -12)]), Color("8be9fd"))


func cell_to_local(cell: Vector2i) -> Vector2:
	return Vector2(cell) * CELL_SIZE


func _draw_cell(cell: Vector2i, color: Color, outline: bool, offset := Vector2.ZERO) -> void:
	var rect := Rect2(cell_to_local(cell) + Vector2(2, 2) + offset, Vector2.ONE * (CELL_SIZE - 4.0))
	if outline:
		draw_rect(rect, color, false, 3.0)
	else:
		draw_rect(rect, color, true)
		draw_rect(rect.grow(-4.0), color.darkened(0.24), false, 2.0)
