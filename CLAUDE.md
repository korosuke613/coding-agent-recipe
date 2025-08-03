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
│   ├── Dockerfile            # コンテナ環境定義（Squidプロキシ対応）
│   ├── init-firewall.sh      # Squidベースファイアウォールスクリプト
│   ├── squid.conf            # Squidプロキシ設定ファイル
│   ├── SQUID_README.md       # Squidシステムドキュメント
│   └── .claude/settings.json # devcontainer用Claude設定
├── .github/            # GitHub設定
│   ├── prompts/        # GitHub Copilot Chat向けプロンプトファイル
│   └── copilot-instructions.md  # GitHub Copilot向けガイダンス
├── CLAUDE.md           # Claude Code用ガイダンス
├── README.md           # プロジェクト概要
└── LICENSE             # ライセンスファイル
```

### 利用可能なエージェント
`.claude/agents/` に格納されているエージェントは以下の通り：

- `code-reviewer` - コード品質、セキュリティ、保守性のレビューを行う
- `debugger` - エラーやテストの失敗に対するデバッグを行う  
- `tdd-refactoring-coach` - TDD（テスト駆動開発）とリファクタリングの指導を行う

## カスタムスラッシュコマンド

このリポジトリでは以下のカスタムスラッシュコマンドが利用可能：

### `/create-branch`
現在の変更を元に新しいブランチを作成するコマンド
- 実装ファイル: `.claude/commands/create-branch.md`
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
- **Claude Code Sandbox環境** - Squidプロキシベースのネットワーク制限付き安全環境
- **Squidプロキシファイアウォール** - ワイルドカードドメイン対応の詳細アクセス制御
- **Claude Code統合** - 事前設定済みの.claude/settings.json
- **VS Code拡張機能** - GitHub Copilot、日本語パック、GitHub Actions統合

### Squidベースファイアウォールシステム
- `init-firewall.sh` - Squidプロキシサーバー起動とファイアウォール設定
- `squid.conf` - ドメインベースアクセス制御設定（ワイルドカード対応）
- `SQUID_README.md` - Squidシステムの詳細ドキュメントとデバッグ方法
- 許可ドメイン：GitHub、VS Code、npmjs.org、api.anthropic.com、CDN等
- 詳細アクセスログとリアルタイム監視機能

### セキュリティ制限
- `.claude/hooks/block-file-edits.sh`により以下ファイルの編集が制限：
  - `.github/workflows/` - GitHub Actionsワークフロー
  - `.claude/hooks/` - フックスクリプト自体
  - `.claude/settings.json` - Claude設定ファイル

## 開発コマンド

このリポジトリはPure Git管理で、特別なビルドやテストコマンドはありません。

### よく使うコマンド
- `git status` - 変更状況の確認
- `git log --oneline` - コミット履歴の確認
- `git branch` - ブランチ一覧の確認
- `/create-branch` - 新しいブランチの作成（カスタムコマンド）
- `/create-commit` - コミットの作成（カスタムコマンド）
- `/update-readme` - READMEファイルの更新（カスタムコマンド）

## ファイル権限管理とマルチプラットフォーム対応

### devcontainer権限設定
`.devcontainer/.claude/settings.json`でdevcontainer環境の権限を管理：
- 許可ツール：`Bash`, `WebFetch`, `WebSearch`
- 禁止コマンド：`curl`, `wget`, `git push`, `gh pr`等

### デスクトップ通知システム
`.claude/hooks/`に格納されたフック機能：
- `notify-finish.sh` - Claude Codeタスク完了時の通知
- `notify-require.sh` - Claude Codeからの通知受信

### GitHub Copilot連携
`.github/copilot-instructions.md`によるプロジェクト理解とClaude Code互換機能の提供

## 開発フロー

1. 新機能やコマンドを追加する際は `/create-branch` でブランチを作成
2. 変更後は `/create-commit` でコミットを作成
3. コミットメッセージは日本語のコンベンショナルコミット形式で記載
4. READMEや設定の更新が必要な場合は `/update-readme` を実行
5. Squidプロキシファイアウォールにより、承認されたドメインのみアクセス可能

## 重要な制約と注意事項

- このリポジトリはPure Git管理（ビルドやテストコマンドなし）
- Claude Code環境ではファイル編集権限がフックにより制限される
- devcontainer環境ではSquidプロキシによりネットワークアクセスが制限される
- 全ての応答とコミットメッセージは日本語で記載する
- Squidファイアウォールの詳細な設定やデバッグは `SQUID_README.md` を参照
