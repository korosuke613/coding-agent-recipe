# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## ルール
- 日本語で回答すること

## プロジェクト概要

このリポジトリは Claude Code の便利プロンプトや便利カスタムコマンドを収集・管理するためのリポジトリです。

## アーキテクチャ

このリポジトリはClaude Codeの拡張機能を集めたリソース集です：

### ディレクトリ構造
```
.
├── .claude/            # 本リポジトリでアクティブなClaude Code設定
│   ├── agents/         # 使用中のエージェント設定
│   ├── commands/       # 使用中のコマンド設定
│   ├── hooks/          # 使用中のフック設定
│   └── settings.json   # アクティブな設定ファイル
├── .devcontainer/      # Development Container設定
│   ├── devcontainer.json     # VSCode devcontainer設定
│   ├── Dockerfile            # コンテナ環境定義
│   ├── init-firewall.sh      # セキュリティ制限スクリプト
│   └── .claude/settings.json # devcontainer用Claude設定
├── .github/            # GitHub設定
├── CLAUDE.md           # Claude Code用ガイダンス
├── README.md           # プロジェクト概要
└── LICENSE             # ライセンスファイル
```

### 利用可能なエージェント
`.claude/agents/` に格納されているエージェントは以下の通り：

- `code-reviewer` - コード品質、セキュリティ、保守性のレビューを行う

## カスタムスラッシュコマンド

このリポジトリでは以下のカスタムスラッシュコマンドが利用可能：

### `/create-branche`
現在の変更を元に新しいブランチを作成するコマンド
- 実装ファイル: `.claude/commands/create-branche.md`
- 機能: git status、git log、git branchの情報を参考にして適切なブランチ名でブランチを作成

### `/create-commit`
現在の変更を元に新しいコミットを作成するコマンド
- 実装ファイル: `.claude/commands/create-commit.md`
- 機能: git status、git log の情報を参考にしてコンベンショナルコミット形式でコミットを作成

### `/update-readme`
プロジェクトのREADMEファイルを現在のコードベースに基づいて更新するコマンド
- 実装ファイル: `.claude/commands/update-readme.md`
- 機能: プロジェクトの現在の構造を反映し、利用可能な機能やコマンドを正確に記載

## コミット規約

- コンベンショナルコミット形式を使用
- 日本語でコミットメッセージを記載
- `feat:`, `fix:`, `docs:`, `chore:` などのプレフィックスを使用

### コンベンショナルコミットの事例
- `feat: 新機能追加` - 新しい機能やコマンドの追加
- `fix: バグ修正` - 既存機能の不具合修正
- `docs: ドキュメント更新` - READMEやCLAUDE.mdの更新
- `chore: リポジトリ運営` - GitHub設定、CI/CD、依存関係更新など
- `refactor: リファクタリング` - 機能変更を伴わないコード改善
- `test: テスト関連` - テストの追加や修正

## 開発環境とセットアップ

### Development Container
`.devcontainer/` に完全なdevcontainer設定が含まれています：
- **Claude Code Sandbox環境** - ネットワーク制限付きの安全な開発環境
- **ファイアウォール設定** - GitHub、npm、Anthropic APIのみアクセス許可
- **Claude Code統合** - 事前設定済みの.claude/settings.json
- **Biome統合** - 自動フォーマットとリンティング

### セキュリティ制限
- `init-firewall.sh`によりネットワークアクセスが制限されます
- 許可されたドメイン：GitHub、npmjs.org、api.anthropic.com、sentry.io、statsig.com
- `.claude/hooks/block-file-edits.sh`により.github/workflows等の編集が制限されます

## 開発コマンド

このリポジトリはPure Git管理で、特別なビルドやテストコマンドはありません。

### よく使うコマンド
- `git status` - 変更状況の確認
- `git log --oneline` - コミット履歴の確認
- `git branch` - ブランチ一覧の確認
- `/create-branche` - 新しいブランチの作成（カスタムコマンド）
- `/create-commit` - コミットの作成（カスタムコマンド）
- `/update-readme` - READMEファイルの更新（カスタムコマンド）

## ファイル権限管理

### フック機能による制限
`.claude/hooks/block-file-edits.sh` が以下のファイルの編集を制限：
- `.github/workflows/` - GitHub Actionsワークフロー
- `.claude/hooks/` - フックスクリプト自体
- `.claude/settings.json` - Claude設定ファイル

### 権限設定例
`.devcontainer/.claude/settings.json`でdevcontainer環境の権限を管理：
- `Bash`, `WebFetch`, `WebSearch`を許可
- `curl`, `wget`, `git push`, `gh pr`等のコマンドを制限

## 開発フロー

1. 新機能やコマンドを追加する際は `/create-branche` でブランチを作成
2. 変更後は `/create-commit` でコミットを作成
3. コミットメッセージは日本語のコンベンショナルコミット形式で記載
4. セキュリティ制限により、承認されたドメインのみアクセス可能
