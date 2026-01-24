#!/bin/bash
#
# get-review-comments.sh - PRのレビューコメント一覧を取得
#
# Usage: get-review-comments.sh <owner> <repo> <pr_number> [--format=json|summary]
#
# Options:
#   --format=json     完全なJSON出力（デフォルト）
#   --format=summary  簡潔なサマリー形式
#
# Examples:
#   ./get-review-comments.sh korosuke613 test 1
#   ./get-review-comments.sh korosuke613 test 1 --format=summary
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
    echo "Usage: $0 <owner> <repo> <pr_number> [--format=json|summary]" >&2
    exit 1
fi

owner="$1"
repo="$2"
pr_number="$3"
format="json"

# オプション解析
if [[ $# -ge 4 ]]; then
    case "$4" in
        --format=json)
            format="json"
            ;;
        --format=summary)
            format="summary"
            ;;
        *)
            echo "Error: Unknown option '$4'" >&2
            echo "Valid options: --format=json, --format=summary" >&2
            exit 1
            ;;
    esac
fi

# GitHub APIでレビューコメントを取得
response=$(gh api "/repos/${owner}/${repo}/pulls/${pr_number}/comments" 2>&1) || {
    echo "Error: Failed to fetch review comments." >&2
    echo "$response" >&2
    exit 1
}

# 出力形式に応じて処理
case "$format" in
    json)
        echo "$response" | jq '.[] | {
            id: .id,
            path: .path,
            line: .line,
            original_line: .original_line,
            body: .body,
            user: .user.login,
            created_at: .created_at,
            in_reply_to_id: .in_reply_to_id
        }'
        ;;
    summary)
        echo "$response" | jq -r '.[] | "[\(.id)] \(.path):\(.line // .original_line // "file") - \(.body | split("\n")[0] | .[0:60])..."'
        ;;
esac
