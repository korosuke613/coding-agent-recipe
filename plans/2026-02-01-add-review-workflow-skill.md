# GitHub Actions レビュースキル追加計画

## 概要

GitHubプラグインに新しいスキル `review-actions-workflow` を追加する。
ワークフローファイル(.github/workflows/*.yml)をセキュリティ、ベストプラクティス、パフォーマンス、保守性の4観点でレビューし、改善提案を行う。

## スキル仕様

- **スキル名**: `review-actions-workflow`
- **トリガーフレーズ**: 「ワークフローをレビューして」「GitHub Actionsをチェック」
- **allowed-tools**: `Read, Glob, Grep`
- **context**: `fork`（独立したサブエージェントとして実行）
- **agent**: `Explore`（読み取り専用ツールに最適化されたエージェント）
- **スクリプト**: 不要（SKILL.md + referencesのみ）

## チェック観点

### 1. セキュリティ
- third-partyアクションのSHA固定確認
- `@main`/`@master`参照の検出・警告
- permissions設定の最小化確認
- スクリプトインジェクション対策
- pull_request_targetの安全性

### 2. ベストプラクティス
- キャッシュ活用（actions/cache、setup-*のcacheオプション）
- マトリックスビルドの活用
- reusable workflows / composite actionsの活用機会検出
- case関数の活用（`&&`/`||`による三項演算子風記述の置き換え）

### 3. パフォーマンス
- 並列実行の最適化
- concurrency設定の確認
- timeout-minutes設定の確認
- 不要なジョブ・ステップの特定

### 4. 保守性・可読性
- ジョブ・ステップの命名規則
- env:セクションでの環境変数一元管理
- ファイル分割の提案
- 条件式の可読性（`&&`/`||`による暗黙的条件分岐をcase関数で明示化）

## 作成するファイル

### ディレクトリ構造
```
claude-plugins/github/skills/review-actions-workflow/
├── SKILL.md
└── references/
    ├── security-checks.md
    ├── best-practices.md
    ├── performance-checks.md
    ├── maintainability-checks.md
    └── technic-case-function.md
```

### 1. SKILL.md
- フロントマター（name, description, allowed-tools, context, agent）
- 実行方法（基本使用、オプション、使用例）
- 4つのチェック観点の概要
- レポート出力フォーマット
- 実装の流れ
- 参考資料へのリンク
- 使用タイミング・注意事項

### 2. references/security-checks.md
- third-partyアクションのリスクと対策
- SHA固定の重要性と方法
- permissions最小化ガイド
- スクリプトインジェクション対策
- Grepパターン例

### 3. references/best-practices.md
- キャッシュ活用の詳細
- マトリックスビルドの設計パターン
- reusable workflows vs composite actionsの使い分け

### 4. references/performance-checks.md
- キャッシュ戦略
- 並列実行の最適化
- concurrency設定の設計
- timeout-minutes設定ガイド

### 5. references/maintainability-checks.md
- 命名規則ガイド
- 環境変数管理
- ファイル分割基準

### 6. references/technic-case-function.md
- case関数の概要と構文
- 使用例（単一条件、複数条件）
- 従来の`&&`/`||`との比較
- 適用範囲と制限事項

## 更新するファイル

### 1. claude-plugins/github/.claude-plugin/plugin.json
- version: 1.0.0 → 1.1.0
- description: ワークフローレビュー機能の追記
- keywords: "actions", "security" を追加

### 2. CLAUDE.md
- 「利用可能なスキル」セクションに`review-actions-workflow`を追加

## 実装順序

1. `claude-plugins/github/skills/review-actions-workflow/references/` ディレクトリ作成
2. references配下の5ファイル作成
3. SKILL.md作成
4. plugin.json更新
5. CLAUDE.md更新

## 検証方法

1. スキルのトリガーテスト
   - 「ワークフローをレビューして」で起動するか確認
2. 実際のワークフローファイルでレビュー実行
   - 本リポジトリの `.github/workflows/` があれば使用
   - なければサンプルワークフローで確認
3. レポート出力フォーマットの確認

## 実装状況

### 完了した作業

1. ✅ `claude-plugins/github/skills/review-actions-workflow/references/` ディレクトリ作成
2. ✅ references配下の5ファイル作成
   - ✅ security-checks.md
   - ✅ best-practices.md
   - ✅ performance-checks.md
   - ✅ maintainability-checks.md
   - ✅ technic-case-function.md
3. ✅ SKILL.md作成（詳細なチェック項目とフロー記載）
4. ⏳ plugin.json更新（未確認）
5. ⏳ CLAUDE.md更新（未確認）
6. ✅ bashスクリプト追加（check-workflow.sh）

### 検証結果

- ✅ スキルのトリガーテスト: `/review-actions-workflow` で正常に起動
- ⚠️ ワークフローファイルでのレビュー実行:
  - 本リポジトリには `.github/workflows/` ディレクトリが存在しない
  - ワークフローファイルが見つからない場合の適切なメッセージを表示することを確認
- ℹ️ 実際のワークフローを持つリポジトリでの検証が必要

### 今後のアクション

1. plugin.jsonのバージョン更新確認
2. CLAUDE.mdへのスキル追加確認
3. 実際のワークフローファイルを持つリポジトリでの動作検証
4. /check-plugin スキルでプラグイン仕様との整合性確認
