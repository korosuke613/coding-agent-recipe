# スクリプト使用例

PRレビュー対応で使用するシェルスクリプトの詳細な使用例。

## 前提条件

すべてのスクリプトは以下を前提とする：
- `jq` がインストールされていること
- `gh` (GitHub CLI) がインストールされ、認証済みであること

## PR URLのパース

### 基本的な使用方法

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/parse-pr-url.sh "https://github.com/korosuke613/mynewshq/pull/4"
```

出力：
```json
{
  "owner": "korosuke613",
  "repo": "mynewshq",
  "pr_number": 4
}
```

### 様々なURLフォーマット

```bash
# HTTPSプレフィックス付き
${CLAUDE_PLUGIN_ROOT}/scripts/parse-pr-url.sh "https://github.com/owner/repo/pull/123"

# プレフィックスなし
${CLAUDE_PLUGIN_ROOT}/scripts/parse-pr-url.sh "github.com/owner/repo/pull/123"
```

### シェル変数への代入

```bash
# jqで各フィールドを抽出
pr_info=$(${CLAUDE_PLUGIN_ROOT}/scripts/parse-pr-url.sh "https://github.com/owner/repo/pull/123")
owner=$(echo "$pr_info" | jq -r '.owner')
repo=$(echo "$pr_info" | jq -r '.repo')
pr_number=$(echo "$pr_info" | jq -r '.pr_number')
```

## レビューコメントの取得

### 詳細なJSON形式

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/get-review-comments.sh korosuke613 mynewshq 4
```

出力例：
```json
{
  "id": 1234567890,
  "path": "scripts/create-discussion.ts",
  "line": 220,
  "original_line": 220,
  "body": "ラベル追加が失敗した場合のエラーハンドリングを追加してください",
  "user": "reviewer",
  "created_at": "2024-01-15T10:00:00Z",
  "in_reply_to_id": null
}
```

### サマリー形式

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/get-review-comments.sh korosuke613 mynewshq 4 --format=summary
```

出力例：
```
[1234567890] scripts/create-discussion.ts:220 - ラベル追加が失敗した場合のエラーハンドリングを追加してください...
[1234567891] scripts/create-discussion.ts:45 - この関数にユニットテストを追加してください...
```

## レビューコメントへの返信

### 基本的な返信

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/reply-to-comment.sh korosuke613 mynewshq 4 1234567890 "修正しました (13bf420)

try-catchでエラーハンドリングを追加し、ラベル追加が失敗してもDiscussion URLを正常に返すようにしました。"
```

### ヒアドキュメントを使った複数行の返信

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/reply-to-comment.sh korosuke613 mynewshq 4 1234567891 "$(cat <<'EOF'
この件は対応しません

**理由：**
- `addLabelsToDiscussion`は内部関数でAPIモックが必要
- `determineLabels`のロジックは既に十分テストされている
- このプロジェクトの規模では実装コストに対する効果が低い

呼び出し側でエラーハンドリングを追加したため、実用上の問題はありません。
EOF
)"
```

## レビュースレッドの取得

### 全スレッドを取得

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/get-review-threads.sh korosuke613 mynewshq 4
```

出力例：
```json
{
  "threadId": "PRRT_kwDOQ8GWfs5p4t_j",
  "isResolved": false,
  "isOutdated": false,
  "path": "scripts/create-discussion.ts",
  "line": 220,
  "commentId": 1234567890,
  "author": "reviewer",
  "body": "ラベル追加が失敗した場合のエラーハンドリングを追加してください"
}
```

### 未解決のスレッドのみ取得

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/get-review-threads.sh korosuke613 mynewshq 4 --unresolved-only
```

## スレッドのresolve

### 単一スレッドをresolve

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/resolve-threads.sh "PRRT_kwDOQ8GWfs5p4t_j"
```

### 複数スレッドを一括resolve

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/resolve-threads.sh \
  "PRRT_kwDOQ8GWfs5p4t_e" \
  "PRRT_kwDOQ8GWfs5p4t_h" \
  "PRRT_kwDOQ8GWfs5p4t_j"
```

出力例：
```
Resolved 3 thread(s) successfully.
{
  "thread0": {
    "thread": {
      "id": "PRRT_kwDOQ8GWfs5p4t_e",
      "isResolved": true
    }
  },
  "thread1": {
    "thread": {
      "id": "PRRT_kwDOQ8GWfs5p4t_h",
      "isResolved": true
    }
  },
  "thread2": {
    "thread": {
      "id": "PRRT_kwDOQ8GWfs5p4t_j",
      "isResolved": true
    }
  }
}
```

## 完全なワークフロー例

### 1. PR URLからリポジトリ情報を取得

```bash
pr_info=$(${CLAUDE_PLUGIN_ROOT}/scripts/parse-pr-url.sh "https://github.com/korosuke613/mynewshq/pull/4")
owner=$(echo "$pr_info" | jq -r '.owner')
repo=$(echo "$pr_info" | jq -r '.repo')
pr_number=$(echo "$pr_info" | jq -r '.pr_number')
```

### 2. レビューコメントを確認

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/get-review-comments.sh "$owner" "$repo" "$pr_number" --format=summary
```

### 3. コード修正（必要に応じて）

```bash
# 修正をコミット
git add scripts/create-discussion.ts
git commit -m "fix: エラーハンドリングを追加

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
git push origin feature-branch
```

### 4. 各コメントに返信

```bash
${CLAUDE_PLUGIN_ROOT}/scripts/reply-to-comment.sh "$owner" "$repo" "$pr_number" 1234567890 "修正しました (abc1234)"
${CLAUDE_PLUGIN_ROOT}/scripts/reply-to-comment.sh "$owner" "$repo" "$pr_number" 1234567891 "この件は対応しません。理由は..."
```

### 5. スレッドをresolve

```bash
# 未解決スレッドのIDを取得
thread_ids=$(${CLAUDE_PLUGIN_ROOT}/scripts/get-review-threads.sh "$owner" "$repo" "$pr_number" --unresolved-only | jq -r '.threadId')

# 一括resolve
${CLAUDE_PLUGIN_ROOT}/scripts/resolve-threads.sh $thread_ids
```

## トラブルシューティング

### jqが見つからない場合

```
Error: jq is required but not installed.
```

解決方法：
```bash
# macOS
brew install jq

# Ubuntu/Debian
sudo apt-get install jq
```

### GitHub CLIが認証されていない場合

```
Error: Failed to fetch review comments.
gh: Not logged in to github.com
```

解決方法：
```bash
gh auth login
```

### レビューコメントとPR会話コメントの違い

レビューコメントとPR会話コメントは異なるエンドポイントを使用する：

- **レビューコメント**: コードの特定行に付けられたコメント
  - `get-review-comments.sh` で取得
  - `reply-to-comment.sh` で返信

- **会話コメント**: PRの会話タブに投稿された一般的なコメント
  - `gh api /repos/{owner}/{repo}/issues/{pr_number}/comments` で取得
  - `gh api /repos/{owner}/{repo}/issues/{pr_number}/comments -f body="..."` で投稿
