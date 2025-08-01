---
description: プロジェクトのREADMEファイルを現在のコードベースに基づいて更新
mode: agent
---

プロジェクトのREADMEファイルを現在のコードベースに基づいて更新してください。

## 確認すべき情報
1. プロジェクト構造: `find . -type f -name "*.md" -o -name "*.json" -o -name "*.sh" | head -20`
2. 設定ファイルの確認: `.claude/`, `.github/`, `.devcontainer/` の内容
3. 現在のREADME.mdの内容と実際の構造の差異

## 更新対象
- **ディレクトリ構造図**: 実際のファイル・フォルダ構成を反映
- **機能一覧**: 利用可能なコマンド、エージェント、設定の最新化
- **使用方法**: 新しく追加された機能の説明
- **リンク**: 実在するファイルへの正確なリンク

## 留意事項
- 既存の形式とスタイルを維持
- 日本語での記載を継続
- マークダウン形式の適切な使用
- プロジェクトの目的（AIエージェント向けリソース集）を明確に

実際にREADME.mdファイルを更新してください。
