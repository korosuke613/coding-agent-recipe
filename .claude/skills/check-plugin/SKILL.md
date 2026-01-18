---
name: check-plugin
description: Claude Codeプラグインの陳腐化をチェックし、最新仕様との差異を報告する。Claude Code更新後のプラグイン互換性確認、定期的なメンテナンス、新規プラグイン作成後の検証に使用。引数で特定プラグインを指定可能（例：check-plugin git）。--fixフラグで自動修正も実行可能。
---

# Claude Code プラグイン陳腐化チェック

Claude Codeプラグインが最新仕様に準拠しているかをチェックし、問題点と修正提案を報告する。

## 実行方法

```
/check-plugin                    # 全プラグインをチェック
/check-plugin git                # 特定プラグインのみ
/check-plugin --fix              # 全プラグインをチェックして修正
/check-plugin git --fix          # 特定プラグインをチェックして修正
```

## チェック手順

### 1. 引数解析

`$ARGUMENTS`を解析して実行モードを決定：
- プラグイン名が指定されていれば対象を限定
- `--fix`フラグがあれば修正モードを有効化

### 2. 最新仕様の確認

WebSearchで以下を検索し、最新のClaude Code仕様を確認：
- "Claude Code plugins reference 2026"
- "Claude Code tools list 2026"
- "Claude Code hooks specification 2026"

**重要な確認項目：**
- 標準ツール名の最新リスト
- 非推奨・廃止されたツールやフィールド
- 新機能（outputStyles, skills等）

### 3. プラグイン構造の読み込み

`claude-plugins/`配下の各プラグインについて以下を読み込み：

#### plugin.json
- Readツールで`.claude-plugin/plugin.json`を読み込み
- 必須フィールド（name, description, version, author）を確認

#### commands（コマンド定義）
- Globで`commands/*.md`を検索
- 各ファイルをReadしてfrontmatterを解析
- `allowed-tools`と`description`フィールドを確認

#### agents（エージェント定義）
- Globで`agents/*.md`を検索
- 各ファイルをReadしてfrontmatterを解析
- `name`, `description`, `tools`フィールドを確認

#### hooks（フック定義）
- Readで`hooks/hooks.json`を読み込み（存在する場合）
- `matcher`パターンと使用ツール名を確認

### 4. チェック項目

#### plugin.json チェック
- [ ] 必須フィールドの存在確認：`name`, `description`, `version`, `author`
- [ ] バージョン形式の妥当性（セマンティックバージョニング）
- [ ] 新機能フィールドの活用可能性：`outputStyles`, `skills`, `mcpServers`, `lspServers`

#### commands チェック
- [ ] frontmatterに`allowed-tools`フィールドが存在するか
- [ ] `allowed-tools`に記載されたツール名が標準ツールリストに含まれるか
- [ ] `description`フィールドが存在し、適切に記述されているか

#### agents チェック
- [ ] frontmatterに`name`, `description`フィールドが存在するか
- [ ] `tools`フィールドに記載されたツール名が標準ツールリストに含まれるか
- [ ] 非標準フィールド（`color`等）が使用されていないか
- [ ] 不要なツール（MultiEdit, NotebookRead, TodoWrite等）が含まれていないか

#### hooks チェック
- [ ] `matcher`パターンに記載されたツール名が標準ツールリストに含まれるか
- [ ] フックイベント名が有効なイベント（PreToolUse, PostToolUse等）か
- [ ] フックタイプ（command, prompt, agent）が適切に使用されているか

### 5. 標準ツール名リスト（2026年1月時点）

**コアツール：**
- Read, Write, Edit, MultiEdit
- Bash（パターン指定可：`Bash(git:*)`）
- Glob, Grep, LS

**高度なツール：**
- Task, Skill
- WebFetch, WebSearch
- TodoRead, TodoWrite
- NotebookRead, NotebookEdit
- AskUserQuestion

**注意：**
- 最新仕様はWebSearchで確認すること
- ツール名は大文字小文字を区別する

### 6. 出力形式

チェック結果をコンソールに以下の形式で出力：

```
# プラグイン陳腐化チェックレポート

実行日時: YYYY-MM-DD HH:MM:SS
対象: [全プラグイン / プラグイン名]

## サマリー
- チェックしたプラグイン数: X
- 問題のあるプラグイン: Y件
- Critical: Z件
- Warning: W件

## 詳細

### [プラグイン名] (例: engineer)

#### Critical（必須修正）
- **問題**: agents/tdd-refactoring-coach.md に非標準フィールド`color`が使用されています
  **影響**: プラグインが正しく動作しない可能性
  **修正方法**: `color`フィールドを削除
  **ファイル**: claude-plugins/engineer/agents/tdd-refactoring-coach.md:3

#### Warning（推奨修正）
- **問題**: agents/tdd-refactoring-coach.md に不要なツール`TodoWrite`が含まれています
  **影響**: コンテキストウィンドウを無駄に消費
  **修正方法**: TDDコーチに不要な`TodoWrite`を`tools`から削除
  **ファイル**: claude-plugins/engineer/agents/tdd-refactoring-coach.md:4

#### Info（情報）
- **情報**: plugin.jsonで新機能`outputStyles`を活用できる可能性があります
  **メリット**: 日本語ユーザー向けの出力フォーマットをカスタマイズ可能
```

### 7. 修正モード（--fix）

`--fix`フラグが指定された場合：

1. レポートを出力
2. 各問題について修正内容を説明
3. **ユーザーに確認を求める**（AskUserQuestionツールを使用）
4. 承認されたらEditツールで修正を実行
5. 修正完了後、再度チェックを実行して検証

**修正の優先順位：**
- Critical: 自動修正を推奨（ユーザー承認後）
- Warning: 自動修正を提案（ユーザー判断）
- Info: 情報提供のみ（修正なし）

## 重要な注意事項

1. **最新仕様の確認**: 必ずWebSearchで最新仕様を確認すること
2. **日本語出力**: すべてのレポートは日本語で出力すること
3. **ファイルパスの明示**: 問題箇所は必ずファイルパスと行番号を含めること
4. **修正前の確認**: `--fix`モードでもユーザー確認を必須とすること
5. **CLAUDE.md参照**: プロジェクトの構造とルールは`@CLAUDE.md`を参照すること

## よくある問題パターン

### 1. agents の color フィールド
```yaml
# 問題
tools: Edit, Write
color: orange

# 修正後
tools: Edit, Write
```

### 2. 不要なツールの削除
```yaml
# 問題（TDDコーチの場合）
tools: Edit, MultiEdit, Write, TodoWrite, NotebookRead

# 修正後
tools: Edit, Write
```

### 3. hooks の MultiEdit
```json
// 問題があるかWebSearchで最新仕様を確認
"matcher": "Edit|MultiEdit|Write"

// MultiEditが非推奨の場合
"matcher": "Edit|Write"
```
