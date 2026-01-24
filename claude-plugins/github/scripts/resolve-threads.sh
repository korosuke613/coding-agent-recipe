#!/bin/bash
#
# resolve-threads.sh - レビュースレッドを一括resolve（GraphQL）
#
# Usage: resolve-threads.sh <thread_id1> [<thread_id2> ...]
#
# Examples:
#   ./resolve-threads.sh "PRRT_kwDOQ8GWfs5p4t_j"
#   ./resolve-threads.sh "PRRT_kwDOQ8GWfs5p4t_e" "PRRT_kwDOQ8GWfs5p4t_h" "PRRT_kwDOQ8GWfs5p4t_j"
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
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <thread_id1> [<thread_id2> ...]" >&2
    echo "Example: $0 'PRRT_kwDOQ8GWfs5p4t_j'" >&2
    exit 1
fi

# GraphQL mutation を動的に構築
mutation="mutation {"
index=0

for thread_id in "$@"; do
    mutation+="
  thread${index}: resolveReviewThread(input: {threadId: \"${thread_id}\"}) {
    thread {
      id
      isResolved
    }
  }"
    ((index++))
done

mutation+="
}"

# GraphQL mutationを実行
response=$(gh api graphql -f query="$mutation" 2>&1) || {
    echo "Error: Failed to resolve threads." >&2
    echo "$response" >&2
    exit 1
}

# 結果を表示
echo "Resolved $# thread(s) successfully."
echo "$response" | jq '.data'
