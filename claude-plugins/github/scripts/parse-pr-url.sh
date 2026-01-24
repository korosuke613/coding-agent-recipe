#!/bin/bash
#
# parse-pr-url.sh - PR URLからowner/repo/pr_numberを抽出
#
# Usage: parse-pr-url.sh <url>
# Output: JSON形式で {"owner": "...", "repo": "...", "pr_number": 123}
#
# Examples:
#   ./parse-pr-url.sh "https://github.com/korosuke613/test/pull/1"
#   ./parse-pr-url.sh "github.com/owner/repo/pull/42"
#

set -euo pipefail

# 依存関係チェック
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed." >&2
    exit 1
fi

# 引数チェック
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <pr_url>" >&2
    echo "Example: $0 'https://github.com/owner/repo/pull/123'" >&2
    exit 1
fi

url="$1"

# URLからowner/repo/pr_numberを抽出
# パターン: github.com/{owner}/{repo}/pull/{number}
if [[ "$url" =~ github\.com/([^/]+)/([^/]+)/pull/([0-9]+) ]]; then
    owner="${BASH_REMATCH[1]}"
    repo="${BASH_REMATCH[2]}"
    pr_number="${BASH_REMATCH[3]}"

    # JSON形式で出力
    jq -n \
        --arg owner "$owner" \
        --arg repo "$repo" \
        --argjson pr_number "$pr_number" \
        '{owner: $owner, repo: $repo, pr_number: $pr_number}'
else
    echo "Error: Invalid PR URL format." >&2
    echo "Expected format: https://github.com/{owner}/{repo}/pull/{number}" >&2
    exit 1
fi
