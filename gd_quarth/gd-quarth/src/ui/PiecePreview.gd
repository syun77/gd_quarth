class_name PiecePreview
extends Control

var piece: Piece
var tint := Color("73daca")


func set_piece(value: Piece) -> void:
	piece = value
	queue_redraw()


func _draw() -> void:
	if piece == null:
		return
	var bounds := piece.bounds()
	var scale_size := 15.0
	var content_size := Vector2(bounds.size) * scale_size
	var origin := (size - content_size) * 0.5 - Vector2(bounds.position) * scale_size
	for cell in piece.cells:
		var rect := Rect2(origin + Vector2(cell) * scale_size + Vector2.ONE, Vector2.ONE * (scale_size - 2.0))
		draw_rect(rect, tint, true)
		draw_rect(rect, tint.lightened(0.25), false, 1.0)
