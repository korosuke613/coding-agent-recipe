# Copilot Instructions for coding-agent-recipe

このリポジトリは様々なAIコーディングエージェント（Claude Code、GitHub Copilot等）向けの便利なプロンプト、カスタムコマンド、設定を収集・管理するリソース集です。**日本語で回答してください。**

## アーキテクチャとディレクトリ構造

- `.claude/` - Claude Code設定（agents, commands, hooks, settings.json）
- `.github/` - GitHub Copilot設定（copilot-instructions.md等）とGitHub設定
- `.devcontainer/` - Development Container設定とセキュリティ制限
- `CLAUDE.md` - Claude Code専用ガイダンス
- `README.md` - プロジェクト概要と利用方法

## セキュリティ制限とフック

### ファイル編集制限
`.claude/hooks/block-file-edits.sh`により以下のファイルの編集がブロックされます：
- `.github/workflows/*` - GitHub Actionsワークフロー
- `.claude/hooks/*` - フック設定ファイル
- `.claude/settings.json` - Claude設定ファイル

これらのファイルを変更する場合は、差分をテキストで提示してください。

### devcontainer権限設定
`.devcontainer/.claude/settings.json`でネットワークとコマンドが制限されています：
- 許可: `Bash`, `WebFetch`, `WebSearch`
- 禁止: `curl`, `wget`, `git push`, `gh pr`系コマンド
- ネットワーク制限: GitHub、npm、Anthropic API等のみアクセス可能

## マルチプラットフォーム対応

### Claude Code固有機能
- **カスタムスラッシュコマンド**（`.claude/commands/`内）：
  - `/create-branche` - git status/logを参考に適切なブランチ名で新ブランチ作成
  - `/create-commit` - 変更内容からコンベンショナルコミット形式でコミット作成
  - `/update-readme` - プロジェクト構造に基づきREADMEを自動更新

- **サブエージェント**（`.claude/agents/`内）：
  - `code-reviewer` - コード品質、セキュリティ、保守性レビュー
  - `debugger` - エラーやテスト失敗のデバッグ支援
  - `tdd-refactoring-coach` - TDD（テスト駆動開発）とリファクタリング指導

### GitHub Copilot対応
- このファイル（`.github/copilot-instructions.md`）によるプロジェクト理解の促進
- VS Code拡張機能やGitHub Copilot Chatでの活用

## コミット規約

**コンベンショナルコミット形式**を日本語で使用：
- `feat: 新機能やコマンドの追加`
- `fix: 既存機能の不具合修正`
- `docs: READMEやCLAUDE.mdの更新`
- `chore: GitHub設定やCI/CD関連`

## 開発フロー

1. `/create-branche`でブランチ作成
2. 機能やコマンドを実装・更新
3. `/create-commit`でコミット作成
4. READMEや設定の更新が必要な場合は`/update-readme`を実行

## 重要な制約

- このリポジトリはPure Git管理（ビルドやテストコマンドなし）
- Claude Code環境ではファイル編集権限がフックにより制限
- devcontainer環境ではネットワークとコマンドが制限される
- 全ての応答とコミットメッセージは日本語で記載
