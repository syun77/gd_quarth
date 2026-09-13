# gd_quarth

『クォース』を基に、回転可能なポリオミノ弾、NEXT、HOLD、矩形消去、短いウェーブ制を組み合わせたGodot製パズルシューティングです。

## 起動

Godotで `gd_quarth/gd-quarth/project.godot` を開き、プロジェクトを実行してください。

## 操作

| 操作 | キー |
|---|---|
| 移動 | ← / → または A / D |
| 左回転 / 右回転 | Z / X |
| 発射 | Space |
| HOLD | C |
| ポーズ | Esc |

矩形の外周を閉じると、その内部を含む占有マスが消去されます。各ウェーブでターゲットの70%を消去すると次へ進み、全6ウェーブの突破でステージクリアです。

## モデルテスト

```sh
/Applications/Godot_mono.app/Contents/MacOS/Godot --headless --log-file /tmp/gd_quarth-tests.log --path gd_quarth/gd-quarth --script res://tests/model_test.gd
```
