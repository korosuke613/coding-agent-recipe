# respond-to-pr-review スキル改善計画

## 問題

1. **スクリプトが使われない** - SKILL.mdでスクリプトを指示しても、Claudeが無視して直接 `gh api` を組み立てる
2. **パス参照が未検証** - `${CLAUDE_PLUGIN_ROOT}/scripts/` の参照が実際に動作するか不明
3. **スクリプトの使い勝手** - 5つのスクリプトを個別に呼び出すのは煩雑

## 推奨案: スクリプトをスキル内に移動 + 指示強化

### 変更1: ディレクトリ構造の変更

```
claude-plugins/github/
├── .claude-plugin/plugin.json
├── scripts/                          # 削除
└── skills/
    └── respond-to-pr-review/
        ├── SKILL.md
        ├── scripts/                  # 新規（移動先）
        │   ├── parse-pr-url.sh
        │   ├── get-review-comments.sh
        │   ├── reply-to-comment.sh
        │   ├── get-review-threads.sh
        │   └── resolve-threads.sh
        └── references/
            └── github-api-examples.md
```

### 変更2: SKILL.md の更新

**frontmatter:**
```yaml
allowed-tools: Bash(./scripts/*:*), Bash(gh pr view:*), Bash(git:*), Read, Edit, Glob, Grep
```

**本文に追加:**
- 「直接 `gh api` 実行禁止」のルールを明記
- スクリプト使用の理由を説明
- 禁止コマンド例を具体的に列挙

### 変更3: references/github-api-examples.md のパス更新

`${CLAUDE_PLUGIN_ROOT}/scripts/` → `./scripts/` に変更

## 対象ファイル

| ファイル | 操作 |
|----------|------|
| `claude-plugins/github/skills/respond-to-pr-review/SKILL.md` | 編集 |
| `claude-plugins/github/skills/respond-to-pr-review/references/github-api-examples.md` | 編集 |
| `claude-plugins/github/skills/respond-to-pr-review/scripts/` | 新規作成 |
| `claude-plugins/github/scripts/*.sh` （5ファイル） | 移動 |

## 検証方法

1. スキルをトリガーして、Claudeがスクリプトを使用するか確認
2. 各スクリプトが正しいパスで実行されるか確認
3. `gh api` が直接使用されないか確認
