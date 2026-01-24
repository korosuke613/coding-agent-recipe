#!/bin/bash
#
# reply-to-comment.sh - レビューコメントに返信を投稿
#
# Usage: reply-to-comment.sh <owner> <repo> <pr_number> <comment_id> "<body>"
#
# Examples:
#   ./reply-to-comment.sh korosuke613 test 1 123456 "修正しました"
#   ./reply-to-comment.sh korosuke613 test 1 123456 "$(cat reply.md)"
#

set -euo pipefail

# 依存関係チェック
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is required but not installed." >&2
    exit 1
fi

# 引数チェック
if [[ $# -ne 5 ]]; then
    echo "Usage: $0 <owner> <repo> <pr_number> <comment_id> <body>" >&2
    echo "Example: $0 korosuke613 test 1 123456 '修正しました'" >&2
    exit 1
fi

owner="$1"
repo="$2"
pr_number="$3"
comment_id="$4"
body="$5"

# 空のbodyチェック
if [[ -z "$body" ]]; then
    echo "Error: Reply body cannot be empty." >&2
    exit 1
fi

# GitHub APIで返信を投稿
response=$(gh api "/repos/${owner}/${repo}/pulls/comments/${comment_id}/replies" \
    -X POST \
    -f body="$body" 2>&1) || {
    echo "Error: Failed to post reply." >&2
    echo "$response" >&2
    exit 1
}

echo "Reply posted successfully."
echo "$response" | jq '{id: .id, body: .body[0:100], created_at: .created_at}'
