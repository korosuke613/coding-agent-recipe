# respond-to-pr-review スキルの名前・description改善プラン

## 概要
`respond-to-pr-review` スキルの名前とdescriptionを改善する。

## 変更内容

| 項目 | 変更前 | 変更後 |
|------|--------|--------|
| **name** | `respond-to-pr-review` | `pr-respond` |
| **description** | GitHub Pull Requestのレビューコメントに効率的に対応するスキル。「レビュー対応して」... | PRにレビューコメントが付いたら呼び出す。レビュー対応、返信作成、スレッドresolveまで一貫してサポート。「レビュー対応して」「PRレビューに返信」で起動。 |

## 修正対象ファイル

### 1. ディレクトリ名変更
- `claude-plugins/github/skills/respond-to-pr-review/` → `claude-plugins/github/skills/pr-respond/`

### 2. SKILL.md (claude-plugins/github/skills/pr-respond/SKILL.md)
- frontmatterの `name` を `pr-respond` に変更
- frontmatterの `description` を新しい文言に変更
- 本文の見出し「# Respond to PR Review」を「# PR Respond」に変更

### 3. CLAUDE.md
- 「利用可能なスキル」セクションのスキル名・説明を更新
- ディレクトリパスの参照を更新

## 実装手順

1. プランファイルの名前を変更
2. ディレクトリ名を `respond-to-pr-review` から `pr-respond` に変更（git mv）
3. SKILL.md の frontmatter を更新（name, description）
4. SKILL.md の本文見出しを更新
5. CLAUDE.md のスキル説明セクションを更新

## 検証方法

1. `git status` で変更対象ファイルを確認
2. `ls claude-plugins/github/skills/` でディレクトリ名が正しく変更されたか確認
3. SKILL.md の frontmatter が正しいYAML形式かを目視確認
4. CLAUDE.md の記述が新しいスキル名・パスと整合しているか確認
