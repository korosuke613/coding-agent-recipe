# coding-agent-recipe

様々なAIコーディングエージェント（Claude Code、GitHub Copilot等）向けの便利なプロンプト、カスタムコマンド、設定を収集・管理するリポジトリです。

```
.
├── .claude/            # Claude Code設定
│   ├── agents/         # 使用中のエージェント設定
│   ├── commands/       # 使用中のカスタムスラッシュコマンド設定
│   ├── hooks/          # 使用中のフック設定（通知、ファイル編集制限等）
│   └── settings.json   # アクティブな設定ファイル
├── .github/            # GitHub Copilot設定とGitHub設定
│   ├── prompts/        # GitHub Copilot Chat向けプロンプトファイル
│   └── copilot-instructions.md  # GitHub Copilot向けガイダンス
├── .devcontainer/      # Development Container設定
│   ├── .claude/        # devcontainer用Claude Code設定
│   ├── devcontainer.json     # VSCode devcontainer設定
│   ├── Dockerfile            # コンテナ環境定義
│   └── init-firewall.sh      # セキュリティ制限スクリプト
├── CLAUDE.md           # Claude Code専用ガイダンス
├── README.md           # プロジェクト概要
└── LICENSE             # ライセンスファイル
```

## Claude Code

### 📦 Development containers

[`.devcontainer/`](/.devcontainer/) に格納されている [Development containers](https://docs.anthropic.com/en/docs/claude-code/devcontainer) の設定ファイル：

- **[`devcontainer.json`](/.devcontainer/devcontainer.json)** - devcontainer の設定
- **[`Dockerfile`](/.devcontainer/Dockerfile)** - devcontainer の Dockerfile
- **[`init-firewall.sh`](/.devcontainer/init-firewall.sh)** - devcontainer 起動時に実行されるセキュリティ制限スクリプト
- **`.claude/`** - devcontainer 用の Claude Code 設定ディレクトリ
  - **[`.claude/settings.json`](/.devcontainer/.claude/settings.json)** - devcontainer 用の Claude Code 設定ファイル（権限制限付き）

### 🤖 Sub Agents

[`.claude/agents/`](/.claude/agents/) に格納されている [Sub agent](https://docs.anthropic.com/en/docs/claude-code/sub-agents) のマークダウンファイル：

- **[`code-reviewer.md`](/.claude/agents/code-reviewer.md)** - コード品質、セキュリティ、保守性のレビューを行う
- **[`debugger.md`](/.claude/agents/debugger.md)** - エラーやテストの失敗に対するデバッグを行う  
- **[`tdd-refactoring-coach.md`](/.claude/agents/tdd-refactoring-coach.md)** - TDD（テスト駆動開発）とリファクタリングの指導を行う

### ⚡ Custom slash commands

[`.claude/commands/`](/.claude/commands/) に格納されている [Custom slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands) のマークダウンファイル：

- **[`/create-branch`](/.claude/commands/create-branch.md)** - 現在の変更を元に適切なブランチ名で新しいブランチを作成
- **[`/create-commit`](/.claude/commands/create-commit.md)** - 現在の変更を元にコンベンショナルコミット形式でコミットを作成
- **[`/update-readme`](/.claude/commands/update-readme.md)** - プロジェクトのREADMEファイルを現在のコードベースに基づいて更新

### 🛠️ Hooks

[`.claude/hooks/`](/.claude/hooks/) に格納されている [Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) のスクリプト：

- **[`block-file-edits.sh`](/.claude/hooks/block-file-edits.sh)** - 特定のファイルの編集を制限するフック
- **[`notify-finish.sh`](/.claude/hooks/notify-finish.sh)** - Claude Codeのタスク完了時にデスクトップ通知を送信するフック
- **[`notify-require.sh`](/.claude/hooks/notify-require.sh)** - Claude Codeからの通知を受信してデスクトップ通知を送信するフック

設定ファイルは [`.claude/settings.json`](/.claude/settings.json) にあります。

## GitHub Copilot

### 🤖 Prompt Files

[`.github/prompts/`](/.github/prompts/) に格納されているGitHub Copilot Chat向けプロンプトファイル（`.prompt.md`）：

- **[`create-branch.prompt.md`](/.github/prompts/create-branch.prompt.md)** - 適切なブランチ名で新しいブランチを作成（`/create-branch`相当）
- **[`create-commit.prompt.md`](/.github/prompts/create-commit.prompt.md)** - コンベンショナルコミット形式でコミット作成（`/create-commit`相当）
- **[`update-readme.prompt.md`](/.github/prompts/update-readme.prompt.md)** - READMEファイルの自動更新（`/update-readme`相当）

VS Code Chatで `/create-branch`, `/create-commit`, `/update-readme` と入力して使用できます。使用方法の詳細は [`.github/prompts/README.md`](/.github/prompts/README.md) を参照してください。
