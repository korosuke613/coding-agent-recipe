# GitHub Actions case関数

GitHub Actionsの式評価で利用可能な`case`関数について解説します。

## 概要

`case`関数は2026年1月に追加された新しい式関数です。条件に基づいて値を選択する際に使用し、従来の`&&`/`||`による三項演算子風の記述よりも意図が明確になります。

この機能は2020年に[actions/runner#409](https://github.com/actions/runner/issues/409)で提案された三項演算子/条件関数の追加リクエストに端を発しており、約6年越しで実現されました。

## 構文

```
case( pred1, val1, pred2, val2, ..., default )
```

SQLのCASE式に似た構文で、可変引数をサポートしています。

### パラメータ

| パラメータ | 説明 |
|-----------|------|
| `pred1, pred2, ...` | 評価する条件式（boolean） |
| `val1, val2, ...` | 対応する条件がtrueの場合に返す値 |
| `default` | すべての条件がfalseの場合に返す値 |

条件は順番に評価され、最初にtrueになった条件に対応する値が返されます。

## 使用例

### 単一条件（if-else相当）

```yaml
env:
  MODE: ${{ case(github.event_name == 'push', 'production', 'development') }}
```

### 複数条件（switch-case相当）

```yaml
env:
  MY_ENV_VAR: |-
    ${{ case(
      github.ref == 'refs/heads/main', 'production',
      github.ref == 'refs/heads/staging', 'staging',
      startsWith(github.ref, 'refs/heads/feature/'), 'development',
      'unknown'
    ) }}
```

### 環境変数の条件付き設定

```yaml
env:
  DEBUG_FLAG: ${{ case(inputs.debug == true, '--verbose', '') }}
```

### ネストしたcase（非推奨）

可変引数をサポートしているため、ネストは不要です。

```yaml
# ❌ 非推奨（読みにくい）
env:
  LEVEL: ${{ case(inputs.level == 'high', '3', case(inputs.level == 'medium', '2', '1')) }}

# ✅ 推奨（可変引数を使用）
env:
  LEVEL: ${{ case(inputs.level == 'high', '3', inputs.level == 'medium', '2', '1') }}
```

## 従来の条件分岐との比較

### 従来の方法（`&&`/`||`による三項演算子風）

```yaml
${{ inputs.comment_url && format('元のコメント: {0}', inputs.comment_url) || '' }}
```

**問題点:**
- `&&`/`||`の短絡評価を利用した暗黙的な条件分岐
- 意図がわかりにくい
- `true_value`がfalsy（空文字列、0、false）の場合に誤動作する可能性

### case関数を使用した方法

```yaml
${{ case(inputs.comment_url != '', format('元のコメント: {0}', inputs.comment_url), '') }}
```

**利点:**
- 条件分岐であることが明示的
- 可読性が高い
- falsy値でも正しく動作

### シェルスクリプト内の条件分岐

**従来の方法:**
```yaml
run: |
  FLAG=""
  if [ "${{ github.event_name }}" == "workflow_dispatch" ]; then
    FLAG="--some-option"
  fi
  some-command $FLAG
```

**case関数を使用した方法:**
```yaml
env:
  FLAG: ${{ case(github.event_name == 'workflow_dispatch', '--some-option', '') }}
run: |
  some-command $FLAG
```

## 適用範囲

`case`関数は以下の場所で使用できます：

- `env`（環境変数）
- `with`（アクションの入力）
- `run`内の式展開
- `name`（ステップ/ジョブ名）
- その他の式が評価されるすべての場所

## 制限事項

`case`関数は**値の選択**に使用するものであり、以下の用途には適しません：

### ステップ/ジョブの実行制御

`if`条件の代わりにはなりません。

```yaml
# ❌ できない
steps:
  - name: Only on push
    run: echo "push event"
    # case関数でステップの実行/非実行を制御することはできない

# ✅ 正しい方法
steps:
  - name: Only on push
    if: github.event_name == 'push'
    run: echo "push event"
```

### シェルコマンドが必要な処理

日付計算、ファイル存在確認、外部コマンドの結果を使った処理などには使用できません。

```yaml
# ❌ case関数ではできない
# - 日付の計算: $(date -u +%Y-%m-%d)
# - ファイル存在確認: [ -f "file.txt" ]
# - コマンド出力の使用: $(some-command)

# ✅ シェルスクリプトで処理
run: |
  if [ -f "config.json" ]; then
    USE_CONFIG="true"
  fi
```

## 参考リンク

- [GitHub Blog: Smarter editing, clearer debugging, and a new case function](https://github.blog/changelog/2026-01-29-github-actions-smarter-editing-clearer-debugging-and-a-new-case-function/)
- [GitHub Docs: Expressions](https://docs.github.com/en/actions/concepts/workflows-and-actions/expressions)
- [GitHub Docs: Evaluate expressions](https://docs.github.com/actions/reference/evaluate-expressions-in-workflows-and-actions)
- [actions/runner#409: Conditional operator or function for expression syntax](https://github.com/actions/runner/issues/409) - case関数追加の発端となった機能リクエスト
