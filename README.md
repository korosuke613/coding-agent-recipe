# coding-agent-recipe

様々なAIコーディングエージェント（Claude Code、GitHub Copilot等）向けの便利なプロンプト、カスタムコマンド、設定を収集・管理するリポジトリです。

## ⚙️ 便利設定

```
.
├── .claude/            # Claude Code設定
│   ├── agents/         # 使用中のエージェント設定
│   ├── commands/       # 使用中のコマンド設定
│   ├── hooks/          # 使用中のフック設定
│   └── settings.json   # アクティブな設定ファイル
├── .github/            # GitHub Copilot設定とGitHub設定
│   └── copilot-instructions.md  # GitHub Copilot向けガイダンス
├── .devcontainer/      # Development Container設定
├── CLAUDE.md           # Claude Code専用ガイダンス
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

- **[`/create-branch`](/.claude/commands/create-branch.md)** - 現在の変更を元に適切なブランチ名で新しいブランチを作成
- **[`/create-commit`](/.claude/commands/create-commit.md)** - 現在の変更を元にコンベンショナルコミット形式でコミットを作成
- **[`/update-readme`](/.claude/commands/update-readme.md)** - プロジェクトのREADMEファイルを現在のコードベースに基づいて更新

### 🛠️ Hooks

[`.claude/hooks/`](/.claude/hooks/) に格納されている [Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) のスクリプト：

- **[`block-file-edits.sh`](/.claude/hooks/block-file-edits.sh)** - 特定のファイルの編集を制限するフック

設定ファイルは [`.claude/settings.json`](/.claude/settings.json) にあります。

### 🤖 GitHub Copilot Prompt Files

[`.github/prompts/`](/.github/prompts/) に格納されているGitHub Copilot Chat向けプロンプトファイル（`.prompt.md`）：

- **[`create-branch.prompt.md`](/.github/prompts/create-branch.prompt.md)** - 適切なブランチ名で新しいブランチを作成（`/create-branch`相当）
- **[`create-commit.prompt.md`](/.github/prompts/create-commit.prompt.md)** - コンベンショナルコミット形式でコミット作成（`/create-commit`相当）
- **[`update-readme.prompt.md`](/.github/prompts/update-readme.prompt.md)** - READMEファイルの自動更新（`/update-readme`相当）

VS Code Chatで `/create-branch`, `/create-commit`, `/update-readme` と入力して使用できます。使用方法の詳細は [`.github/prompts/README.md`](/.github/prompts/README.md) を参照してください。

## 🤝 マルチプラットフォーム対応

このリポジトリは複数のAIコーディングエージェントに対応しています：

### 🔵 Claude Code
- **カスタムスラッシュコマンド**: `.claude/commands/`
- **サブエージェント**: `.claude/agents/`
- **フック機能**: `.claude/hooks/`
- **設定ファイル**: `.claude/settings.json`

### 🟣 GitHub Copilot
- **プロジェクトガイダンス**: `.github/copilot-instructions.md`
- **プロンプトファイル**: `.github/prompts/` - Claude Codeコマンド相当の機能（`.prompt.md`形式）
- **VS Code統合**: スラッシュコマンド（`/create-branch`等）での直接実行
- **今後追加予定**: VS Code スニペット集
