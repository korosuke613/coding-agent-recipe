---
name: review-actions-workflow
description: GitHub Actionsワークフローをレビューし、セキュリティ、ベストプラクティス、パフォーマンス、保守性の観点から改善提案を行う。「ワークフローをレビューして」「GitHub Actionsをチェック」で起動。
allowed-tools: Read, Glob, Grep, AskUserQuestion, Bash(bash */check-workflow.sh *)
model: opus
context: fork
agent: Explore
---

# Review Actions Workflow

## 概要

GitHub Actionsワークフローファイル（`.github/workflows/*.yml`）をレビューし、以下の4つの観点から問題点を検出して改善提案を行うスキル。

## 実行方法

### 基本使用

```
ワークフローをレビューして
```

```
GitHub Actionsをチェック
```

### オプション

| オプション | 説明 | 例 |
|-----------|------|---|
| `--security` | セキュリティチェックのみ | `/review-actions-workflow --security` |
| `--performance` | パフォーマンスチェックのみ | `/review-actions-workflow --performance` |
| `--best-practices` | ベストプラクティスチェックのみ | `/review-actions-workflow --best-practices` |
| `--maintainability` | 保守性チェックのみ | `/review-actions-workflow --maintainability` |
| `--file <path>` | 特定のファイルのみレビュー | `/review-actions-workflow --file ci.yml` |
| `--fix` | 修正提案を詳細に表示 | `/review-actions-workflow --fix` |

### 使用例

```
# 全観点でレビュー
ワークフローをレビューして

# セキュリティのみチェック
GitHub Actionsのセキュリティをチェックして

# 特定ファイルのレビュー
ci.ymlをレビューして
```

## チェック観点

### 1. セキュリティ

セキュリティ上のリスクを検出し、対策を提案する。

| チェック項目 | 重要度 | 説明 |
|------------|--------|------|
| スクリプトインジェクション | 高 | ユーザー入力が安全に処理されているか |
| pull_request_target | 高 | フォークからのPRで安全に使用されているか |
| シークレット管理 | 高 | シークレットが安全に扱われているか |

> **Note:** SHA固定、@main/@master参照、permissions最小化はlinterでチェック可能なため、このスキルではチェックしません。詳細は[references/security-checks.md](references/security-checks.md)を参照してください。

詳細: [references/security-checks.md](references/security-checks.md)

### 2. ベストプラクティス

GitHub Actionsの効率的な使用パターンを確認する。

| チェック項目 | 説明 | 重要度 |
|------------|------|--------|
| キャッシュ活用 | setup-*のcacheオプション、actions/cacheの使用 | 中 |
| マトリックスビルド | 複数環境テストの効率化 | 低 |
| Reusable Workflows | ワークフローの再利用機会 | 中 |
| Composite Actions | 共通ステップの切り出し機会 | 低 |
| **case関数の活用** | **`&&`/`||`による三項演算子風記述のcase関数への置き換え** | **中** |
| **bashのif文簡素化** | **GitHub Actions式を使ったbashのif文をステップレベルif条件へ移動** | **中** |

> **⚠️ 重要:** case関数関連のチェックは必須です。以下の3パターンを必ず確認してください：
> 1. GitHub Actions式での`&&`/`||`使用
> 2. bashスクリプト内でGitHub Actions式（`${{ }}`）を使った条件分岐
> 3. bashスクリプト内の値分岐のみのif-else文

詳細: [references/best-practices.md](references/best-practices.md)、[references/technic-case-function.md](references/technic-case-function.md)

### 3. パフォーマンス

実行時間とリソース効率を最適化する。

| チェック項目 | 説明 |
|------------|------|
| 並列実行 | ジョブ間の依存関係最適化 |
| concurrency | 重複実行の制御 |
| timeout-minutes | 適切なタイムアウト設定 |
| checkout最適化 | fetch-depth、sparse-checkout |
| 不要なステップ | 削除可能なステップの特定 |

詳細: [references/performance-checks.md](references/performance-checks.md)

### 4. 保守性・可読性

長期的なメンテナンスを容易にする。

| チェック項目 | 説明 | 重要度 |
|------------|------|--------|
| 命名規則 | ジョブ・ステップの明確な名前 | 中 |
| 環境変数管理 | マジックナンバーの排除 | 低 |
| ファイル分割 | 適切な粒度での分割 | 低 |
| コメント | 複雑な処理の説明 | 低 |
| DRY原則 | 重複の排除 | 中 |
| **条件式の可読性** | **`&&`/`||`による暗黙的条件分岐をcase関数で明示化** | **中** |
| **bashのif文簡素化** | **ステップレベルif条件への移動、case関数での値分岐簡素化** | **中** |

詳細: [references/maintainability-checks.md](references/maintainability-checks.md)、[references/technic-case-function.md](references/technic-case-function.md)

## レポート出力フォーマット

### サマリー

```
## ワークフローレビュー結果

### 対象ファイル
- .github/workflows/ci.yml
- .github/workflows/cd.yml

### サマリー
| 観点 | 問題数 | 重要度高 | 重要度中 | 重要度低 |
|------|--------|----------|----------|----------|
| セキュリティ | 3 | 2 | 1 | 0 |
| ベストプラクティス | 2 | 0 | 1 | 1 |
| パフォーマンス | 1 | 0 | 0 | 1 |
| 保守性 | 4 | 0 | 2 | 2 |
| **合計** | **10** | **2** | **4** | **4** |
```

### 詳細レポート

```
## 詳細

### セキュリティ

#### [高] スクリプトインジェクションのリスク (ci.yml:25)

**現状:**
```yaml
- run: echo "PR Title: ${{ github.event.pull_request.title }}"
```

**推奨:**
```yaml
- run: echo "PR Title: $PR_TITLE"
  env:
    PR_TITLE: ${{ github.event.pull_request.title }}
```

**理由:** ユーザー入力を直接シェルコマンドに展開すると、任意のコードが実行される可能性があります。環境変数経由で渡すことで安全に処理できます。

---
```

## 実装の流れ

### 必須チェック項目

以下の全てのチェックを**必ず実行**してください。各チェックで問題が見つからなくても「なし」として記録し、レポートに反映させること。

> **Note:** 各チェックは`check-workflow.sh`スクリプトで自動実行されます。スクリプトの詳細は本ファイルと同じディレクトリにあります。

---

### Step 1: ワークフローファイルの検出と読み込み

!`bash "${CLAUDE_PLUGIN_ROOT}/skills/review-actions-workflow/scripts/check-workflow.sh" --list-files`

各ファイルをReadツールで読み込み、YAML構造を解析する。

---

### Step 2: セキュリティチェック（3項目必須）

!`bash "${CLAUDE_PLUGIN_ROOT}/skills/review-actions-workflow/scripts/check-workflow.sh" --security`

**チェック内容：**
1. スクリプトインジェクションリスクを検出
2. シークレットを直接echoしているパターンを検出
3. pull_request_targetとhead.sha参照の危険な組み合わせを検出

---

### Step 3: ベストプラクティスチェック（5項目必須）

!`bash "${CLAUDE_PLUGIN_ROOT}/skills/review-actions-workflow/scripts/check-workflow.sh" --best-practices`

**チェック内容：**
1. cache未使用のsetup-*を検出
2. Reusable workflow使用状況
3. 【重要】GitHub Actions式での&&/||使用を検出（case関数への置き換え候補）
4. 【重要】bashでGitHub Actions式を使ったif文を検出（ステップレベルif条件への移動候補）
5. 【重要】bash内の複数行runスクリプトのif文を検出（case関数への置き換え候補）

---

### Step 4: パフォーマンスチェック（4項目必須）

!`bash "${CLAUDE_PLUGIN_ROOT}/skills/review-actions-workflow/scripts/check-workflow.sh" --performance`

**チェック内容：**
1. concurrency未設定を検出
2. timeout-minutes未設定のジョブを検出
3. checkout最適化の確認
4. キャッシュの保存/復元の対応確認

---

### Step 5: 保守性チェック（5項目必須）

!`bash "${CLAUDE_PLUGIN_ROOT}/skills/review-actions-workflow/scripts/check-workflow.sh" --maintainability`

**チェック内容：**
1. name未設定のステップを検出
2. ハードコードされたバージョンを検出
3. @main/@master参照を検出（linter推奨だが参考情報として記録）
4. 【重要】case関数で改善可能な条件式を検出
5. 【重要】bashスクリプト内の値分岐if-else文を検出

---

### Step 6: case関数適用可能性の詳細確認（必須・最重要）

!`bash "${CLAUDE_PLUGIN_ROOT}/skills/review-actions-workflow/scripts/check-workflow.sh" --case-function`

**⚠️ このステップは特に重要です。必ず実行してください。**

case関数は以下の3つのパターンで改善効果があります：

#### パターン1: GitHub Actions式での三項演算子風記述

```yaml
# 改善前
run: echo ${{ github.event_name == 'push' && 'production' || 'staging' }}

# 改善後（case関数で明示的に）
run: echo ${{ github.event_name == 'push' && 'production' || github.event_name == 'pull_request' && 'staging' || 'development' }}
```

#### パターン2: bashスクリプト内でGitHub Actions式を使った分岐

```yaml
# 改善前
run: |
  if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
    echo "production"
  else
    echo "staging"
  fi

# 改善後（ステップレベルif + case関数）
```

#### パターン3: 値の分岐だけのif-else文

```yaml
# 改善前
run: |
  if [[ "$ENV" == "production" ]]; then
    URL="https://example.com"
  elif [[ "$ENV" == "staging" ]]; then
    URL="https://staging.example.com"
  else
    URL="https://dev.example.com"
  fi

# 改善後（case関数）
```

**この検出結果を基に、case関数での改善提案を必ずレポートに含めること。**

---

### Step 7: レポート生成

検出された全ての項目（問題なしも含む）をサマリーと詳細レポートにまとめる。

## 参考資料

- [references/security-checks.md](references/security-checks.md) - セキュリティチェックの詳細
- [references/best-practices.md](references/best-practices.md) - ベストプラクティスの詳細
- [references/performance-checks.md](references/performance-checks.md) - パフォーマンスチェックの詳細
- [references/maintainability-checks.md](references/maintainability-checks.md) - 保守性チェックの詳細
- [references/technic-case-function.md](references/technic-case-function.md) - case関数の活用方法

## 使用タイミング

- 新しいワークフローファイルを作成した後
- ワークフローの修正・更新時
- 定期的なセキュリティ監査
- CI/CDパイプラインのパフォーマンス改善時
- チームへのワークフロー引き継ぎ前

## 注意事項

- このスキルはワークフローファイルの静的解析を行います
- 実行時の動作やパフォーマンスは実測が必要です
- セキュリティの問題は特に優先して対応してください
- 修正提案は参考情報であり、プロジェクトの要件に合わせて判断してください

## チェック漏れ防止のための注意事項

### 必須実行チェックリスト

レビュー時に以下の全項目を実行したことを確認してください：

#### セキュリティチェック（3項目）
- [ ] スクリプトインジェクション検出
- [ ] シークレット直接echo検出
- [ ] pull_request_target危険パターン検出

#### ベストプラクティスチェック（5項目）
- [ ] cache未使用検出
- [ ] reusable workflow確認
- [ ] **【重要】GitHub Actions式での&&/||検出**
- [ ] **【重要】bashでActions式を使ったif文検出**
- [ ] **【重要】bash内の値分岐if-else検出**

#### パフォーマンスチェック（4項目）
- [ ] concurrency未設定検出
- [ ] timeout-minutes未設定検出
- [ ] checkout最適化確認
- [ ] キャッシュ保存/復元対応確認

#### 保守性チェック（5項目）
- [ ] name未設定ステップ検出
- [ ] ハードコードバージョン検出
- [ ] @main/@master参照検出
- [ ] **【重要】case関数改善可能な条件式検出**
- [ ] **【重要】bash値分岐if-else詳細確認**

### 特に注意: case関数関連チェック

case関数関連のチェックは**3箇所**で実施する必要があります：

1. **ベストプラクティスチェック（Step 3）** - 項目3, 4, 5
2. **保守性チェック（Step 5）** - 項目4, 5
3. **case関数適用可能性の詳細確認（Step 6）** ← **これが最重要**

**Step 6を必ず実行し、3つのパターン全てを確認してください。**

### チェック実行時の注意

- 各コマンドの実行結果は、問題が見つからなくても「なし」または「✓」として記録する
- Step 6のcase関数チェックは省略禁止
- レポートには全てのチェック項目の結果を含める（問題なしも含む）
