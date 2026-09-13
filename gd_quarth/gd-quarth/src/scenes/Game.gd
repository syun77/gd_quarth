class_name Game
extends Node2D

enum Phase { WAVE_INTRO, AIMING, PROJECTILE_FLYING, CLEAR_PREVIEW, WAVE_OUTRO, GAME_OVER }

const CLEAR_PREVIEW_TIME := 0.55
const WAVE_TRANSITION_TIME := 1.0
const PROJECTILE_STEP_TIME := 0.035
const MOVE_REPEAT_DELAY := 0.22
const MOVE_REPEAT_INTERVAL := 0.075

var board := Board.new()
var piece_queue := PieceQueue.new()
var phase := Phase.WAVE_INTRO
var wave := 1
var score := 0
var launcher_x := 5
var initial_target_count := 0
var cleared_targets := 0
var required_targets := 0
var descent_left := 8.0
var phase_left := WAVE_TRANSITION_TIME
var pending_matches: Array[RectangleMatch] = []
var projectile_path: Array[Vector2i] = []
var projectile_path_index := 0
var projectile_step_left := 0.0
var projectile_piece: Piece
var projectile_locks := false
var move_repeat_left := 0.0
var move_repeat_direction := 0

@onready var board_view: BoardView = $BoardView
@onready var status_label: Label = $HUD/Status
@onready var message_label: Label = $HUD/Message
@onready var hold_preview: PiecePreview = $HUD/HoldPreview
@onready var next_previews: Array[PiecePreview] = [$HUD/Next1, $HUD/Next2, $HUD/Next3]


func _ready() -> void:
	board_view.board = board
	_start_wave()


func _process(delta: float) -> void:
	if get_tree().paused:
		return
	match phase:
		Phase.WAVE_INTRO, Phase.CLEAR_PREVIEW, Phase.WAVE_OUTRO:
			phase_left -= delta
			if phase_left <= 0.0:
				_finish_timed_phase()
		Phase.AIMING:
			_update_movement(delta)
			_tick_descent(delta)
		Phase.PROJECTILE_FLYING:
			_tick_descent(delta)
			if phase != Phase.PROJECTILE_FLYING:
				_update_view()
				return
			_update_projectile(delta)
	_update_view()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		message_label.text = "PAUSED" if get_tree().paused else ""
		return
	if phase == Phase.GAME_OVER and event.is_action_pressed("shoot"):
		_restart_game()
		return
	if phase != Phase.AIMING:
		return
	if event.is_action_pressed("rotate_left"):
		_try_rotate(false)
	elif event.is_action_pressed("rotate_right"):
		_try_rotate(true)
	elif event.is_action_pressed("hold"):
		if piece_queue.use_hold():
			_fit_launcher_to_piece()
	elif event.is_action_pressed("shoot"):
		_shoot()


func _start_wave() -> void:
	board.clear()
	var targets := WaveCatalog.cells_for_wave(wave)
	board.add_target_cells(targets)
	initial_target_count = targets.size()
	required_targets = ceili(initial_target_count * 0.7)
	cleared_targets = 0
	descent_left = WaveCatalog.descent_interval(wave)
	phase = Phase.WAVE_INTRO
	phase_left = WAVE_TRANSITION_TIME
	message_label.text = "WAVE %d" % wave
	_fit_launcher_to_piece()


func _finish_timed_phase() -> void:
	match phase:
		Phase.WAVE_INTRO:
			phase = Phase.AIMING
			message_label.text = ""
		Phase.CLEAR_PREVIEW:
			_resolve_clear()
		Phase.WAVE_OUTRO:
			if wave >= WaveCatalog.WAVE_COUNT:
				phase = Phase.GAME_OVER
				message_label.text = "STAGE CLEAR  •  SPACE TO RESTART"
			else:
				wave += 1
				_start_wave()


func _shoot() -> void:
	var launch_anchor := _launch_anchor()
	var prediction := board.predict_lock(piece_queue.current.cells, launch_anchor)
	projectile_piece = piece_queue.current.duplicate_piece()
	projectile_path.assign(prediction.path)
	projectile_locks = prediction.locks
	projectile_path_index = 0
	projectile_step_left = PROJECTILE_STEP_TIME
	phase = Phase.PROJECTILE_FLYING
	board_view.ghost_cells.clear()


func _update_projectile(delta: float) -> void:
	projectile_step_left -= delta
	if projectile_step_left > 0.0:
		return
	projectile_step_left += PROJECTILE_STEP_TIME
	projectile_path_index += 1
	if projectile_path_index < projectile_path.size():
		return
	if projectile_locks:
		var locked := board.lock_piece(projectile_piece.cells, projectile_path[-1])
		pending_matches = board.find_completed_rectangles(locked)
	else:
		pending_matches.clear()
	piece_queue.consume_current()
	_fit_launcher_to_piece()
	if pending_matches.is_empty():
		phase = Phase.AIMING
	else:
		phase = Phase.CLEAR_PREVIEW
		phase_left = CLEAR_PREVIEW_TIME


func _resolve_clear() -> void:
	var result := board.clear_rectangles(pending_matches)
	var cleared_count: int = result.cells.size()
	var target_count: int = result.target_count
	cleared_targets += target_count
	score += cleared_count * 10 * pending_matches.size()
	pending_matches.clear()
	if cleared_targets >= required_targets:
		var over_clear := cleared_targets - required_targets
		score += over_clear * 25
		phase = Phase.WAVE_OUTRO
		phase_left = WAVE_TRANSITION_TIME
		message_label.text = "WAVE CLEAR"
	else:
		phase = Phase.AIMING


func _tick_descent(delta: float) -> void:
	descent_left -= delta
	if descent_left > 0.0:
		return
	descent_left += WaveCatalog.descent_interval(wave)
	if board.shift_down():
		phase = Phase.GAME_OVER
		message_label.text = "GAME OVER  •  SPACE TO RESTART"
	elif phase == Phase.PROJECTILE_FLYING:
		var current_anchor := projectile_path[mini(projectile_path_index, projectile_path.size() - 1)]
		var prediction := board.predict_lock(projectile_piece.cells, current_anchor)
		projectile_path.assign(prediction.path)
		projectile_path_index = 0
		projectile_locks = prediction.locks


func _try_rotate(clockwise: bool) -> void:
	var rotated := piece_queue.current.rotated(clockwise)
	var bounds := rotated.bounds()
	var minimum_x := -bounds.position.x
	var maximum_x := board.width - bounds.end.x
	var kicked_x := clampi(launcher_x, minimum_x, maximum_x)
	if minimum_x <= maximum_x:
		piece_queue.current = rotated
		launcher_x = kicked_x


func _update_movement(delta: float) -> void:
	var direction := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	if direction == 0:
		move_repeat_direction = 0
		return
	if direction != move_repeat_direction:
		move_repeat_direction = direction
		_move_launcher(direction)
		move_repeat_left = MOVE_REPEAT_DELAY
		return
	move_repeat_left -= delta
	if move_repeat_left <= 0.0:
		_move_launcher(direction)
		move_repeat_left += MOVE_REPEAT_INTERVAL


func _move_launcher(direction: int) -> void:
	var bounds := piece_queue.current.bounds()
	launcher_x = clampi(launcher_x + direction, -bounds.position.x, board.width - bounds.end.x)


func _fit_launcher_to_piece() -> void:
	var bounds := piece_queue.current.bounds()
	launcher_x = clampi(launcher_x, -bounds.position.x, board.width - bounds.end.x)


func _launch_anchor() -> Vector2i:
	return Vector2i(launcher_x, board.height - piece_queue.current.bounds().position.y)


func _restart_game() -> void:
	wave = 1
	score = 0
	piece_queue = PieceQueue.new()
	launcher_x = 5
	_start_wave()


func _update_view() -> void:
	board_view.clear_cells.clear()
	for match in pending_matches:
		for position in match.area_cells():
			if position not in board_view.clear_cells:
				board_view.clear_cells.append(position)
	board_view.projectile_cells.clear()
	board_view.launcher_cells.clear()
	if phase == Phase.PROJECTILE_FLYING and not projectile_path.is_empty():
		var index := mini(projectile_path_index, projectile_path.size() - 1)
		board_view.projectile_cells.assign(projectile_piece.absolute_cells(projectile_path[index]))
	else:
		board_view.launcher_cells.assign(piece_queue.current.absolute_cells(_launch_anchor()))
	if phase == Phase.AIMING:
		var prediction := board.predict_lock(piece_queue.current.cells, _launch_anchor())
		board_view.ghost_cells.clear()
		if prediction.locks:
			board_view.ghost_cells.assign(piece_queue.current.absolute_cells(prediction.anchor))
		board_view.ghost_warning = descent_left < 1.0
	else:
		board_view.ghost_cells.clear()
	board_view.queue_redraw()
	status_label.text = "WAVE %d/%d    TARGET %d/%d    SCORE %06d    DROP %.1fs" % [wave, WaveCatalog.WAVE_COUNT, cleared_targets, required_targets, score, maxf(descent_left, 0.0)]
	hold_preview.set_piece(piece_queue.held)
	for index in next_previews.size():
		next_previews[index].set_piece(piece_queue.next[index])
