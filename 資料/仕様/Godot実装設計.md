# `gd_quarth` Godot実装設計

## 1. 目的

本書は、`gd_quarthゲーム仕様.md` の初期プレイアブル版を Godot 4.7 で実装するための設計方針を定める。現在の `src/scenes/`、`src/objects/`、`src/utils/` 構成と `Array2D.gd`、`Common.gd` を出発点とする。

最優先の原則は、ゲームルールと表示・演出を分離することである。矩形判定、着弾予測、ウェーブ進行をシーンツリーに依存させず、同じ入力から常に同じ結果を返すモデルとして実装する。

## 2. 現状の扱い

- `Array2D.gd` は、盤面データを1次元の `Array[int]` で持つ基礎クラスとして利用する。
- `Array2D.gd` の範囲外取得は `-1`、範囲外書き込みは無視となる。`Board` の公開APIは事前に全座標を検証し、一部だけが書き込まれる状態を作らない。
- `Common.gd` は、オーディオや共通レイヤーなど、シーンを跨ぐ機能に限定する。盤面、スコア、ウェーブの状態は置かない。
- `Main.gd` はエントリポイントとして各コンポーネントを接続する。ルール自体は実装しない。
- `Main.tscn` には `Main.gd` が割り当てられており、ここをエントリポイントとする。
- `Common.gd` のSEテーブルが指す音声ファイルは現時点で存在しない。音声を追加するまで `setup_sounds()` / `play_se()` をゲーム起動の必須経路にしない。

## 3. 推奨フォルダ構成

```text
src/
├── scenes/
│   ├── Main.gd
│   ├── Main.tscn
│   ├── Game.gd
│   └── Game.tscn
├── model/
│   ├── Board.gd
│   ├── Cell.gd
│   ├── Piece.gd
│   ├── PieceCatalog.gd
│   ├── PieceQueue.gd
│   ├── RectangleMatch.gd
│   └── WaveState.gd
├── objects/
│   ├── BoardView.gd
│   ├── BoardView.tscn
│   ├── Launcher.gd
│   ├── Launcher.tscn
│   ├── ProjectileView.gd
│   ├── ProjectileView.tscn
│   ├── PiecePreview.gd
│   └── PiecePreview.tscn
├── ui/
│   ├── GameHud.gd
│   └── GameHud.tscn
└── utils/
    ├── Array2D.gd
    └── Common.gd
```

`model/` のクラスは `RefCounted` または静的メソッド中心とし、シーンツリー、`NodePath`、フレーム時間に依存しない。`objects/` はモデルの状態を描画する Node とする。

## 4. 責務分割

### `Main`

タイトル、ゲーム、リザルト等の大きなシーン遷移だけを担う。最初は `Game.tscn` を子に持つ構成でよいが、ルールを `Main.gd` へ直書きしない。

### `Game`

プレイ中のオーケストレーターとして、入力、モデル更新、表示更新の順序を管理する。状態は次の `enum` で明示する。

```gdscript
enum Phase {
	WAVE_INTRO,
	AIMING,
	PROJECTILE_FLYING,
	CLEAR_PREVIEW,
	WAVE_OUTRO,
	GAME_OVER,
}
```

発射可否や降下タイマーの停止は Phase から一意に決め、複数の `can_shoot` 系フラグを併用しない。

### `Board`

`Array2D` を所有する盤面モデル。座標は左上原点、右が `+x`、下が `+y` とする。初期値は幅10、高さ20、危険ラインは `y = 18` とする。

盤面値は `int` のビットフラグにせず、意味が排他的な `enum` で始める。

```gdscript
enum CellKind {
	EMPTY,
	TARGET,
	PLACED,
}
```

後でターゲット固有IDがスコアに必要になった場合は、種別とIDの2枚の `Array2D` に分ける。1個の整数へ複数の意味を圧縮しない。

主なAPI:

- `can_place(cells, anchor) -> bool`
- `lock_piece(cells, anchor, kind) -> Array[Vector2i]`
- `predict_lock(cells, launch_anchor) -> LockResult`
- `find_completed_rectangles(new_cells) -> Array[RectangleMatch]`
- `clear_cells(positions) -> ClearResult`
- `shift_down() -> bool`（危険ライン到達の有無を返す）

`predict_lock()` は実際の弾飛行と着弾ゴーストが共有する唯一の判定とする。表示用に別の簡略判定を書かない。

### `Piece` / `PieceCatalog`

`Piece` は形状ID、回転数、アンカーからの相対セル座標を持つ。表示 Node は持たない。回転は相対座標 `(x, y) -> (-y, x)` で行い、正規化せず形状ごとのアンカーを保持する。これにより HOLD 時の向きもそのまま保存できる。

`PieceCatalog` は9種類の基準形状とサイズ別候補を保持する。ゲームに直接埋め込まず、生成、NEXT、チュートリアルが同じ定義を参照する。

既存の `Player.tscn` は空の `Sprite2D` で責務が定まっていない。実装開始時に互換性を保たず `Launcher.tscn` へ置き換える。

### `PieceQueue`

7個バッグ、NEXT 3個、HOLD 1個、HOLDのターン内使用済み状態をまとめる。`RandomNumberGenerator` は外から seed を渡す。不具合再現と固定テストのため、暗黙のグローバル乱数は使わない。

### `BoardView`

盤面をセル単位で描画する。プロトタイプでは個別の各マスを独立 Node にせず、`_draw()` で1つの `Node2D` にまとめて描画する。消去演出やゴーストも同じ座標変換を使う。

モデル座標とローカル座標の変換は次の2関数に集約する。

- `cell_to_local(cell: Vector2i) -> Vector2`
- `local_to_cell(position: Vector2) -> Vector2i`

## 5. 着弾判定

弾はモデル上では1マスずつ上へ進め、表示だけを Tween で補間する。発射中の判定に `_physics_process()` の微小移動や `Area2D` の接触を使わない。

1. 発射アンカーから弾の全セルを求める。
2. 次の座標 `anchor + Vector2i.UP` を試す。
3. 次の座標でいずれかが占有セルと重なるなら、現在地点の全セルが盤面内かつ空きで、既存ブロックと辺接触している場合のみ固定する。
4. 全セルが上端より外へ出たら失敗弾として消費する。
5. それ以外は上へ1マス進める。

弾が盤面下部から入る間だけは盤外座標を許容する。ただし、固定位置は全セルが盤面内でなければならない。

## 6. 矩形検出

10×20盤面では全軸平行矩形候補が `C(10,2) × C(20,2) = 8,550` 個であるため、初期版は全候補を調べても十分軽い。まず正しさと決定性を優先する。

各候補 `(left, top, right, bottom)` に対して、次の順で絞り込む。

1. `width >= 2` かつ `height >= 2` を満たす。
2. 新規固定セルの少なくとも1個が外周上にある。
3. 四辺の全セルが `EMPTY` 以外である。

成立矩形を `RectangleMatch` として返し、消去は全矩形の面積の和集合に対して1回だけ行う。スコア用の「同時完成数」は重複を除かず `RectangleMatch` 数、「消去マス数」は和集合の占有セル数とする。

後で計測して問題がある場合のみ、新規固定セルを含む行・列から候補辺を生成する方式へ最適化する。

## 7. ゲーム進行の順序

1. `AIMING`: 移動、回転、HOLD、発射を受け付ける。
2. 発射時に `predict_lock()` の結果を確定し、`PROJECTILE_FLYING` へ移る。
3. 弾表示を確定経路に沿って補間する。飛行中に盤面が降下する仕様のため、降下が起きたら予測経路を現在弾位置から再計算する。
4. 固定したら矩形を検出する。未成立なら次弾を供給し `AIMING` へ戻る。
5. 成立時は `CLEAR_PREVIEW` で降下を停め、予告後に同時消去する。
6. スコアとノルマを更新し、ノルマ未達なら `AIMING`、達成なら `WAVE_OUTRO` へ移る。
7. `WAVE_OUTRO` で盤面をリセットし、HOLD/NEXTを維持して次ウェーブへ進む。

モデル更新を Tween の `finished` に分散させず、`Game` の各フェーズ完了メソッドへ戻す。Tween は表示の完了通知だけを担う。

## 8. 入力

`project.godot` に次の InputMap アクションを定義する。

- `move_left`
- `move_right`
- `rotate_left`
- `rotate_right`
- `shoot`
- `hold`
- `pause`

キーの物理名を `Launcher.gd` で直接調べない。左右移動のリピートは OS のキーリピートに依存せず、初回遅延と反復間隔を `Launcher` 側で管理する。

## 9. テスト方針

初期版はテスト用アドオンを必須にせず、`tests/` 下のヘッドレス実行可能な GDScript でモデルを検証する。Godotのバージョンを固定した後、必要なら GUT 等の導入を判断する。

最低限、次を自動化する。

- 9形状の4回回転後が元の相対座標に戻る。
- 壁際回転のキックが最小移動になる。
- 最初の接触直前で剛体のまま固定する。
- 接触なしの弾が上端で消費される。
- 外周が閉じ、新規セルを外周に含む矩形だけが成立する。
- 複数矩形の和集合が重複消去されない。
- ターゲットマスと追加マスがノルマへ別々に集計される。
- HOLDを1回使用すると弾消費まで再使用できない。
- 同じ seed で同じバッグが生成される。
- 降下により危険ラインに入った時点でゲームオーバーになる。

## 10. 実装マイルストーン

### M1: 盤面ルールの縦切り

- `Board`、`Cell`、`Piece`、`PieceCatalog` を実装する。
- 固定配置と1マス弾を使い、発射、固定、矩形消去をデバッグ表示で確認する。
- この段階で矩形判定の自動テストを固める。

### M2: 操作とポリオミノ

- 9形状、左右回転、ウォールキック、着弾ゴーストを実装する。
- 表示とモデルが同じ座標変換と予測関数を使うことを確認する。

### M3: 弾順とゲーム進行

- 7個バッグ、NEXT 3個、HOLD、スコア、降下、ゲームオーバーを実装する。
- Phase ごとの入力可否とタイマー停止を検証する。

### M4: ウェーブと計測

- 固定3ウェーブ、70%ノルマ、入れ替えを実装する。
- 発射回数、HOLD使用数、消去マス数、同時矩形数、初回入力までの時間を内部ログへ記録する。
- 検証済みランダム配置は固定配置のループが完成してから追加する。

## 11. 仕様上の要確認点

実装に入る前に次の1点だけを固定する。

- 「可視縦20行」に「下部2行のプレイヤー領域」が含まれるか。本設計では、盤面データを10×20、危険ラインを `y = 18`、砲台自体は盤面外とする。これなら「危険ラインへ到達」と「弾の盤面下方からの進入」を単純に扱える。
