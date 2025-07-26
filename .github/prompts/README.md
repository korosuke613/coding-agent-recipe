# GitHub Copilot Prompt Files

このディレクトリには、GitHub Copilot Chat向けのプロンプトファイル（`.prompt.md`）が格納されています。Claude Codeのカスタムスラッシュコマンドに相当する機能をGitHub Copilot環境で利用できます。

## 利用可能なプロンプトファイル

### 🌿 [create-branch.prompt.md](./create-branch.prompt.md)
- **目的**: 現在の変更を元に適切なブランチ名で新しいブランチを作成
- **Claude Code相当**: `/create-branch`コマンド
- **使用方法**: VS Code Chat画面で `/create-branch` と入力

### 📝 [create-commit.prompt.md](./create-commit.prompt.md)
- **目的**: 現在の変更を元にコンベンショナルコミット形式でコミット作成
- **Claude Code相当**: `/create-commit`コマンド
- **使用方法**: VS Code Chat画面で `/create-commit` と入力

### 📖 [update-readme.prompt.md](./update-readme.prompt.md)
- **目的**: プロジェクトのREADMEファイルを現在のコードベースに基づいて更新
- **Claude Code相当**: `/update-readme`コマンド
- **使用方法**: VS Code Chat画面で `/update-readme` と入力

## 使用方法

### 方法1: スラッシュコマンド（推奨）
1. **VS CodeでGitHub Copilot Chatを開く**
2. **チャット入力欄で `/プロンプト名` と入力**
   - 例: `/create-branch`, `/create-commit`, `/update-readme`
3. **Enterを押して実行**

### 方法2: Command Palette経由
1. **Ctrl+Shift+P (Cmd+Shift+P) でCommand Paletteを開く**
2. **"Chat: Run Prompt" を選択**
3. **使用したいプロンプトファイルを選択**

### 方法3: プロンプトファイル直接実行
1. **`.prompt.md`ファイルをVS Codeで開く**
2. **エディタタイトルの再生ボタンをクリック**

## プロンプトファイルの特徴

- **Front Matter**: `description`, `mode`などのメタデータを含む
- **直接実行可能**: コピー&ペースト不要
- **VS Code統合**: ネイティブなUI体験
- **変数サポート**: `${workspaceFolder}`, `${selection}`等の変数利用可能

## Claude Codeとの違い

| 機能 | Claude Code | GitHub Copilot |
|------|-------------|----------------|
| 実行方法 | `/コマンド名` | `/プロンプト名` |
| ファイル形式 | `.md` (yamlヘッダー) | `.prompt.md` (Front Matter) |
| 権限管理 | allowed-tools指定 | VS Code統合権限 |
| 統合性 | Claude専用 | VS Code/GitHub統合 |

両方とも同じ目的を達成できますが、GitHub Copilotはより統合された体験を提供します。
