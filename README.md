# coding-agent-recipe

Claude Code や GitHub Copilot 向けの便利なプラグイン、カスタムコマンド、エージェント、フックを収集・管理するリポジトリです。

このリポジトリは **Claude Code プラグインシステム** として、4つのプラグインとして配布されています：
- **git** - Git操作コマンド（ブランチ作成、コミット作成）
- **doc** - ドキュメント更新コマンド（README更新）
- **engineer** - エンジニアリング支援エージェント（コードレビュー、デバッグ、TDD）
- **security** - セキュリティフック（ファイル編集制限）

## ディレクトリ構造

```
.
├── .claude/                      # プラグイン利用側の設定
│   └── settings.json             # アクティブな設定ファイル
├── .claude-plugin/               # マーケットプレイス定義
│   └── marketplace.json          # マーケットプレイス定義ファイル
├── claude-plugins/               # プラグイン配布用ディレクトリ
│   ├── git/                      # Gitプラグイン
│   │   ├── .claude-plugin/plugin.json
│   │   └── commands/
│   │       ├── create-branch.md
│   │       └── create-commit.md
│   ├── doc/                      # ドキュメントプラグイン
│   │   ├── .claude-plugin/plugin.json
│   │   └── commands/
│   │       └── update-readme.md
│   ├── engineer/                 # エンジニアリングプラグイン
│   │   ├── .claude-plugin/plugin.json
│   │   └── agents/
│   │       ├── code-reviewer.md
│   │       ├── debugger.md
│   │       └── tdd-refactoring-coach.md
│   └── security/                 # セキュリティプラグイン
│       ├── .claude-plugin/plugin.json
│       └── hooks/
│           ├── hooks.json
│           └── block-file-edits.sh
├── .github/                      # GitHub設定
│   ├── prompts/                  # GitHub Copilot Chat向けプロンプト
│   └── copilot-instructions.md   # GitHub Copilot向けガイダンス
├── .devcontainer/                # Development Container設定
│   ├── devcontainer.json         # VSCode devcontainer設定
│   ├── Dockerfile                # コンテナ環境定義（Squidプロキシ対応）
│   ├── init-firewall.sh          # Squidプロキシ起動スクリプト
│   ├── squid.conf                # Squidプロキシ設定ファイル
│   ├── SQUID_README.md           # Squidシステムドキュメント
│   └── .claude/settings.json     # devcontainer用Claude設定
├── CLAUDE.md                     # Claude Code用ガイダンス
├── README.md                     # プロジェクト概要
└── LICENSE                       # ライセンスファイル
```

## Claude Code

### 🔌 プラグインのインストール方法

このリポジトリは4つのClaude Code Pluginとして配布されています。以下の手順でインストールできます：

#### 1. マーケットプレイスを追加

```bash
/plugin marketplace add korosuke613/coding-agent-recipe
```

#### 2. プラグインをインストール

用途に応じて必要なプラグインをインストールしてください：

```bash
# Git操作コマンド（ブランチ作成、コミット作成）
/plugin install git@korosuke613

# ドキュメント更新コマンド（README更新）
/plugin install doc@korosuke613

# エンジニアリング支援エージェント（コードレビュー、デバッグ、TDD）
/plugin install engineer@korosuke613

# セキュリティフック（ファイル編集制限）
/plugin install security@korosuke613

# すべてインストール
/plugin install git@korosuke613 doc@korosuke613 engineer@korosuke613 security@korosuke613
```

#### 3. インストール確認

```bash
/help
```

### 📦 提供されるプラグイン

各プラグインが提供する機能の詳細：

#### `git` プラグイン
カスタムスラッシュコマンドによるGit操作：
- **[`/create-branch`](claude-plugins/git/commands/create-branch.md)** - 現在の変更を元に適切なブランチ名で新しいブランチを作成
- **[`/create-commit`](claude-plugins/git/commands/create-commit.md)** - 現在の変更を元にコンベンショナルコミット形式でコミットを作成

#### `doc` プラグイン
ドキュメント更新コマンド：
- **[`/update-readme`](claude-plugins/doc/commands/update-readme.md)** - プロジェクトのREADMEファイルを現在のコードベースに基づいて更新

#### `engineer` プラグイン
エンジニアリング支援エージェント：
- **[`@code-reviewer`](claude-plugins/engineer/agents/code-reviewer.md)** - コード品質、セキュリティ、保守性のレビューを行う
- **[`@debugger`](claude-plugins/engineer/agents/debugger.md)** - エラーやテストの失敗に対するデバッグを行う
- **[`@tdd-refactoring-coach`](claude-plugins/engineer/agents/tdd-refactoring-coach.md)** - TDD（テスト駆動開発）とリファクタリングの指導を行う

#### `security` プラグイン
セキュリティフック：
- **[`block-file-edits.sh`](claude-plugins/security/hooks/block-file-edits.sh)** - `.github/workflows/`、`.claude/hooks/`、`.claude/settings.json` の編集を制限

### 📦 Development containers

[`.devcontainer/`](.devcontainer/) に格納されている [Development containers](https://docs.anthropic.com/en/docs/claude-code/devcontainer) の設定：

- **[`devcontainer.json`](.devcontainer/devcontainer.json)** - VSCode devcontainer の設定
- **[`Dockerfile`](.devcontainer/Dockerfile)** - コンテナ環境定義（Squidプロキシ対応）
- **[`init-firewall.sh`](.devcontainer/init-firewall.sh)** - Squidプロキシサーバー起動スクリプト
- **[`squid.conf`](.devcontainer/squid.conf)** - ドメインベースアクセス制御設定（ワイルドカード対応）
- **[`SQUID_README.md`](.devcontainer/SQUID_README.md)** - Squidシステムの詳細ドキュメント
- **[`.claude/settings.json`](.devcontainer/.claude/settings.json)** - devcontainer 用の Claude Code 設定ファイル（権限制限付き）

devcontainer により、Squidプロキシベースのセキュアなネットワーク環境でClaude Codeを実行できます。

## GitHub Copilot

### 🤖 Prompt Files

[`.github/prompts/`](.github/prompts/) に格納されているGitHub Copilot Chat向けプロンプトファイル（`.prompt.md`）：

- **[`create-branch.prompt.md`](.github/prompts/create-branch.prompt.md)** - 適切なブランチ名で新しいブランチを作成（`/create-branch`相当）
- **[`create-commit.prompt.md`](.github/prompts/create-commit.prompt.md)** - コンベンショナルコミット形式でコミット作成（`/create-commit`相当）
- **[`update-readme.prompt.md`](.github/prompts/update-readme.prompt.md)** - READMEファイルの自動更新（`/update-readme`相当）

VS Code Chatで `/create-branch`, `/create-commit`, `/update-readme` と入力して使用できます。使用方法の詳細は [`.github/prompts/README.md`](.github/prompts/README.md) を参照してください。
