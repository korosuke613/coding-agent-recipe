# GitHub API使用例

PRレビュー対応で使用するGitHub APIコマンドの詳細な使用例。

## レビューコメントの取得

### 基本的な取得

```bash
gh api /repos/korosuke613/mynewshq/pulls/4/comments
```

### フォーマットして取得

```bash
gh api /repos/korosuke613/mynewshq/pulls/4/comments | jq '.[] | {id, path, line, body}'
```

### 特定の行のコメントを抽出

```bash
gh api /repos/korosuke613/mynewshq/pulls/4/comments | jq '.[] | select(.path == "scripts/create-discussion.ts" and .line == 220)'
```

## レビューコメントへの返信

### 基本的な返信

```bash
gh api /repos/{owner}/{repo}/pulls/{pr_number}/comments \
  -X POST \
  -f body="✅ 修正しました (13bf420)

try-catchでエラーハンドリングを追加し、ラベル追加が失敗してもDiscussion URLを正常に返すようにしました。" \
  -F in_reply_to={comment_id}
```

### 複数行の返信（ヒアドキュメント使用）

```bash
gh api /repos/{owner}/{repo}/pulls/{pr_number}/comments \
  -X POST \
  -f body="$(cat <<'EOF'
この件は対応しません

**理由：**
- \`addLabelsToDiscussion\`は内部関数でAPIモックが必要
- \`determineLabels\`のロジックは既に十分テストされている
- このプロジェクトの規模では実装コストに対する効果が低い

呼び出し側でエラーハンドリングを追加したため、実用上の問題はありません。
EOF
)" \
  -F in_reply_to={comment_id}
```

## レビュースレッドの取得とresolve

### スレッドIDの取得

```bash
gh api graphql -f query='
query {
  repository(owner: "korosuke613", name: "mynewshq") {
    pullRequest(number: 4) {
      reviewThreads(first: 10) {
        nodes {
          id
          isResolved
          comments(first: 1) {
            nodes {
              databaseId
              body
            }
          }
        }
      }
    }
  }
}' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | {threadId: .id, isResolved: .isResolved, commentId: .comments.nodes[0].databaseId, body: .comments.nodes[0].body[0:80]}'
```

### 単一スレッドのresolve

```bash
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "PRRT_kwDOQ8GWfs5p4t_j"}) {
    thread {
      isResolved
    }
  }
}'
```

### 複数スレッドの一括resolve

```bash
gh api graphql -f query='
mutation {
  thread1: resolveReviewThread(input: {threadId: "PRRT_kwDOQ8GWfs5p4t_e"}) {
    thread { isResolved }
  }
  thread2: resolveReviewThread(input: {threadId: "PRRT_kwDOQ8GWfs5p4t_h"}) {
    thread { isResolved }
  }
  thread3: resolveReviewThread(input: {threadId: "PRRT_kwDOQ8GWfs5p4t_j"}) {
    thread { isResolved }
  }
}'
```

### resolve状態の確認

```bash
gh api graphql -f query='
query {
  repository(owner: "korosuke613", name: "mynewshq") {
    pullRequest(number: 4) {
      reviewThreads(first: 10) {
        nodes {
          isResolved
          comments(first: 1) {
            nodes {
              body
            }
          }
        }
      }
    }
  }
}' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | {isResolved: .isResolved, body: .comments.nodes[0].body[0:60]}'
```

## PRの情報取得

### PR全体の情報

```bash
gh pr view 4
```

### PR with comments

```bash
gh pr view 4 --comments
```

### PR reviews

```bash
gh api /repos/korosuke613/mynewshq/pulls/4/reviews | jq '.[] | {author: .user.login, state: .state, body: .body}'
```

## トラブルシューティング

### コメントIDが見つからない場合

レビューコメントとPR conversationコメントは別のエンドポイント：
- レビューコメント: `/repos/{owner}/{repo}/pulls/{pr_number}/comments`
- 会話コメント: `/repos/{owner}/{repo}/issues/{pr_number}/comments`

### GraphQL schemaの確認

```bash
gh api graphql --paginate -f query='
query {
  __type(name: "PullRequestReviewThread") {
    fields {
      name
      type {
        name
        kind
      }
    }
  }
}'
```
