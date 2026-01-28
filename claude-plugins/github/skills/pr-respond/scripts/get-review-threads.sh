#!/bin/bash
#
# get-review-threads.sh - PRのレビュースレッドID・状態を取得（GraphQL）
#
# Usage: get-review-threads.sh <owner> <repo> <pr_number> [--unresolved-only]
#
# Options:
#   --unresolved-only  未解決のスレッドのみ出力
#
# Examples:
#   ./get-review-threads.sh korosuke613 test 1
#   ./get-review-threads.sh korosuke613 test 1 --unresolved-only
#

set -euo pipefail

# 依存関係チェック
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed." >&2
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is required but not installed." >&2
    exit 1
fi

# 引数チェック
if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <owner> <repo> <pr_number> [--unresolved-only]" >&2
    exit 1
fi

owner="$1"
repo="$2"
pr_number="$3"
unresolved_only=false

# オプション解析
if [[ $# -ge 4 && "$4" == "--unresolved-only" ]]; then
    unresolved_only=true
fi

# GraphQLクエリを実行
query='
query($owner: String!, $repo: String!, $pr_number: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr_number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          comments(first: 1) {
            nodes {
              databaseId
              body
              author {
                login
              }
            }
          }
        }
      }
    }
  }
}
'

response=$(gh api graphql \
    -F owner="$owner" \
    -F repo="$repo" \
    -F pr_number="$pr_number" \
    -f query="$query" 2>&1) || {
    echo "Error: Failed to fetch review threads." >&2
    echo "$response" >&2
    exit 1
}

# 結果を整形して出力
if [[ "$unresolved_only" == "true" ]]; then
    echo "$response" | jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | {
        threadId: .id,
        isResolved: .isResolved,
        isOutdated: .isOutdated,
        path: .path,
        line: .line,
        commentId: .comments.nodes[0].databaseId,
        author: .comments.nodes[0].author.login,
        body: .comments.nodes[0].body[0:100]
    }'
else
    echo "$response" | jq '.data.repository.pullRequest.reviewThreads.nodes[] | {
        threadId: .id,
        isResolved: .isResolved,
        isOutdated: .isOutdated,
        path: .path,
        line: .line,
        commentId: .comments.nodes[0].databaseId,
        author: .comments.nodes[0].author.login,
        body: .comments.nodes[0].body[0:100]
    }'
fi
