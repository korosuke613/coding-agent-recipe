---
name: review-actions-workflow
description: GitHub Actionsワークフローをレビューし、セキュリティ、ベストプラクティス、パフォーマンス、保守性の観点から改善提案を行う。「ワークフローをレビューして」「GitHub Actionsをチェック」で起動。
allowed-tools: Read, Glob, Grep
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
| SHA固定 | 高 | Third-partyアクションがコミットハッシュで固定されているか |
| @main/@master参照 | 高 | 不安定なブランチ参照がないか |
| permissions最小化 | 高 | 必要最小限の権限設定か |
| スクリプトインジェクション | 高 | ユーザー入力が安全に処理されているか |
| pull_request_target | 高 | フォークからのPRで安全に使用されているか |

詳細: [references/security-checks.md](references/security-checks.md)

### 2. ベストプラクティス

GitHub Actionsの効率的な使用パターンを確認する。

| チェック項目 | 説明 |
|------------|------|
| キャッシュ活用 | setup-*のcacheオプション、actions/cacheの使用 |
| マトリックスビルド | 複数環境テストの効率化 |
| Reusable Workflows | ワークフローの再利用機会 |
| Composite Actions | 共通ステップの切り出し機会 |
| case関数の活用 | `&&`/`||`による三項演算子風記述のcase関数への置き換え |

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

| チェック項目 | 説明 |
|------------|------|
| 命名規則 | ジョブ・ステップの明確な名前 |
| 環境変数管理 | マジックナンバーの排除 |
| ファイル分割 | 適切な粒度での分割 |
| コメント | 複雑な処理の説明 |
| DRY原則 | 重複の排除 |
| 条件式の可読性 | `&&`/`||`による暗黙的条件分岐をcase関数で明示化 |

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

#### [高] SHA固定されていないアクション (ci.yml:15)

**現状:**
```yaml
- uses: actions/checkout@v4
```

**推奨:**
```yaml
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

**理由:** Third-partyアクションはSHA固定することで、サプライチェーン攻撃のリスクを軽減できます。

---
```

## 実装の流れ

### Step 1: ワークフローファイルの検出

```bash
# ワークフローファイル一覧
ls .github/workflows/*.yml 2>/dev/null || echo "No workflow files found"
```

### Step 2: 各ファイルの読み込みと解析

各ワークフローファイルを読み込み、YAML構造を解析する。

### Step 3: セキュリティチェック

```bash
# SHA固定されていないアクションを検出
grep -nE 'uses:\s+\w+/\w+@(v[0-9]+|main|master)' .github/workflows/*.yml

# permissions未設定を検出
grep -L 'permissions:' .github/workflows/*.yml

# スクリプトインジェクションリスクを検出
grep -nE 'run:.*\$\{\{\s*github\.event\.' .github/workflows/*.yml
```

### Step 4: ベストプラクティスチェック

```bash
# cache未使用のsetup-*を検出
grep -A10 'actions/setup-node@' .github/workflows/*.yml | grep -v 'cache:'

# Reusable workflow使用状況
grep 'workflow_call' .github/workflows/*.yml

# &&/||による三項演算子風の記述を検出（case関数への置き換え候補）
grep -nE '\$\{\{.*&&.*\|\|.*\}\}' .github/workflows/*.yml
```

### Step 5: パフォーマンスチェック

```bash
# concurrency未設定を検出
grep -L 'concurrency:' .github/workflows/*.yml

# timeout-minutes未設定を検出
grep -B5 'runs-on:' .github/workflows/*.yml | grep -v 'timeout-minutes'
```

### Step 6: 保守性チェック

```bash
# name未設定のステップを検出
grep -B1 '^\s*- run:' .github/workflows/*.yml | grep -v 'name:'

# ハードコードされたバージョンを検出
grep -ohE "node-version: '[0-9]+'" .github/workflows/*.yml | sort | uniq -c

# &&/||による暗黙的条件分岐を検出（case関数で可読性向上の余地）
grep -nE '\$\{\{[^}]*\s+&&\s+[^}]*\s+\|\|\s+[^}]*\}\}' .github/workflows/*.yml
```

### Step 7: レポート生成

検出された問題をサマリーと詳細レポートにまとめて出力する。

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
