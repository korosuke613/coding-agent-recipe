# coding-agent-recipe

Claude Code の便利プロンプトや便利カスタムコマンドを収集・管理するリポジトリです。

## ⚙️ 便利設定

```
.
├── .claude/            # 本リポジトリでアクティブなClaude Code設定
│   ├── agents/         # 使用中のエージェント設定
│   ├── commands/       # 使用中のコマンド設定
│   ├── hooks/          # 使用中のフック設定
│   └── settings.json   # アクティブな設定ファイル
├── .devcontainer/      # Development Container設定
├── .github/            # GitHub設定
├── CLAUDE.md           # Claude Code用ガイダンス
├── README.md           # プロジェクト概要
└── LICENSE             # ライセンスファイル
```

### 📦 Development containers

[`.devcontainer/`](/.devcontainer/) に格納されている [Development containers](https://docs.anthropic.com/en/docs/claude-code/devcontainer) の設定ファイル：

- **[`devcontainer.json`](/.devcontainer/devcontainer.json)** - devcontainer の設定
- **[`Dockerfile`](/.devcontainer/Dockerfile)** - devcontainer の Dockerfile
- **[`init-firewall.sh`](/.devcontainer/init-firewall.sh)** - devcontainer 起動時に実行されるファイアウォール設定スクリプト
- **`.claude`** - devcontainer 用の Claude Code 設定ディレクトリ
  - **[`.claude/settings.json`](/.devcontainer/.claude/settings.json)** - devcontainer 用の Claude Code 設定ファイル

### 🤖 Sub Agents

[`.claude/agents/`](/.claude/agents/) に格納されている [Sub agent](https://docs.anthropic.com/en/docs/claude-code/sub-agents) のマークダウンファイル：

- **[`code-reviewer.md`](/.claude/agents/code-reviewer.md)** - コード品質、セキュリティ、保守性のレビューを行う
- **[`debugger.md`](/.claude/agents/debugger.md)** - エラーやテストの失敗に対するデバッグを行う  
- **[`tdd-refactoring-coach.md`](/.claude/agents/tdd-refactoring-coach.md)** - TDD（テスト駆動開発）とリファクタリングの指導を行う

### ⚡ Custom slash commands

[`.claude/commands/`](/.claude/commands/) に格納されている [Custom slash commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands) のマークダウンファイル：

- **[`/create-branche`](/.claude/commands/create-branche.md)** - 現在の変更を元に適切なブランチ名で新しいブランチを作成
- **[`/create-commit`](/.claude/commands/create-commit.md)** - 現在の変更を元にコンベンショナルコミット形式でコミットを作成
- **[`/update-readme`](/.claude/commands/update-readme.md)** - プロジェクトのREADMEファイルを現在のコードベースに基づいて更新

### 🛠️ Hooks

[`.claude/hooks/`](/.claude/hooks/) に格納されている [Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) のスクリプト：

- **[`block-file-edits.sh`](/.claude/hooks/block-file-edits.sh)** - 特定のファイルの編集を制限するフック

設定ファイルは [`.claude/settings.json`](/.claude/settings.json) にあります。
