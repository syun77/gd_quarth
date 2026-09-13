extends Node
# ================================================
# 共通ユーティリティクラス.
# ================================================
class_name Common

static var _layers:Dictionary[String, CanvasLayer] = {} # レイヤー管理用マップ.
static var _main:MainScene = null # Mainシーンの参照.

# ゲームの初期化.
static func init_game() -> void:
	# ゲームの初期化処理はここに記述.
	pass


# レイヤーの取得
static func get_layer(layer_name:String) -> CanvasLayer:
	if _layers.has(layer_name):
		return _layers[layer_name]
	return null

# レイヤーの登録.
static func register_layers(layers:Dictionary[String, CanvasLayer]) -> void:
	_layers = layers


# Mainシーンの参照を登録.
static func register_main(scene:MainScene) -> void:
	_main = scene

# Mainシーンの参照を取得.
static func get_main() -> MainScene:
	return _main

# ------------------------------------------------
# サウンドデータ.
# ------------------------------------------------
const MAX_SOUND = 8 # 同時に鳴らせる最大サウンド数.

# SEテーブル.
static var _snd_tbl = {
	"pi":    "res://assets/sounds/pi.wav",
	"ready": "res://assets/sounds/ready.wav",
	"place": "res://assets/sounds/place.wav",
	"break": "res://assets/sounds/break.wav",
	"build": "res://assets/sounds/build.wav",
	"destroy": "res://assets/sounds/destroy.wav",
	"hit": "res://assets/sounds/hit.wav",
	"laser": "res://assets/sounds/laser.wav",
	"start": "res://assets/sounds/start.wav",
	"upgrade": "res://assets/sounds/upgrade.wav",
}

static var _se_players:Array[AudioStreamPlayer]

static func setup_sounds(parent:Node) -> void:
	_se_players = []
	for i in range(MAX_SOUND):
		var player := AudioStreamPlayer.new()
		parent.add_child(player)
		_se_players.append(player)

# SEを再生.
static func play_se(se_name:String, id:int=0) -> void:
	if id < 0 or id >= MAX_SOUND:
		push_error("不正なサウンドID: " + str(id))
		return # 無効なIDは無視.
	
	if not se_name in _snd_tbl:
		push_error("不正なサウンド名: " + se_name)
		return # 無効なサウンド名は無視.
	
	var snd = _se_players[id]
	# サウンドファイルをロード.
	snd.stream = load(_snd_tbl[se_name])
	snd.play() # サウンドを再生.
