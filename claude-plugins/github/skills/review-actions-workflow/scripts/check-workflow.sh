#!/bin/bash
#
# GitHub Actionsワークフローチェックスクリプト
# Usage: bash check-workflow.sh {--list-files|--security|--best-practices|--performance|--maintainability|--case-function|--all}
#

set -e

# ワークフローディレクトリ
WORKFLOWS_DIR=".github/workflows"

# ファイル一覧を取得
list_files() {
    echo "=== ワークフローファイル一覧 ==="
    find "$WORKFLOWS_DIR" -name "*.yml" -o -name "*.yaml" 2>/dev/null || echo "No workflow files found"
}

# セキュリティチェック
check_security() {
    echo "=== セキュリティチェック（3項目） ==="

    echo "1. スクリプトインジェクション検出:"
    grep -nE 'run:.*\$\{\{[^}]*github\.event\.' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "✓ なし"

    echo ""
    echo "2. シークレット直接echo検出:"
    grep -nE 'echo.*\$\{\{\s*secrets\.' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "✓ なし"

    echo ""
    echo "3. pull_request_target危険パターン検出:"
    grep -l 'pull_request_target' "$WORKFLOWS_DIR"/*.yml 2>/dev/null | xargs grep -l 'head\.sha' 2>/dev/null || echo "✓ なし"
}

# ベストプラクティスチェック
check_best_practices() {
    echo "=== ベストプラクティスチェック（5項目） ==="

    echo "1. cache未使用検出:"
    grep -A10 'actions/setup-node@' "$WORKFLOWS_DIR"/*.yml 2>/dev/null | grep -v 'cache:' || echo "✓ 全てcache設定済み"

    echo ""
    echo "2. reusable workflow確認:"
    grep -n 'workflow_call' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "✓ reusable workflow未使用"

    echo ""
    echo "3. 【重要】GitHub Actions式での&&/||検出:"
    grep -nE '\$\{\{[^}]*(\&\&|\|\|)[^}]*\}\}' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "✓ なし"

    echo ""
    echo "4. 【重要】bashでActions式を使ったif文検出:"
    grep -nE 'if \[\[.*\$\{\{.*\}\}.*\]\]' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "✓ なし"

    echo ""
    echo "5. 【重要】bash内の値分岐if-else検出:"
    awk '/run: \|/{flag=1; next} flag && /^[^ ]/{flag=0} flag && /if \[/' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "✓ なし"
}

# パフォーマンスチェック
check_performance() {
    echo "=== パフォーマンスチェック（4項目） ==="

    echo "1. concurrency未設定検出:"
    grep -L 'concurrency:' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "✓ 全てconcurrency設定済み"

    echo ""
    echo "2. timeout-minutes未設定検出:"
    grep -B5 'runs-on:' "$WORKFLOWS_DIR"/*.yml 2>/dev/null | grep -v 'timeout-minutes' | grep 'runs-on' || echo "✓ 全てtimeout設定済み"

    echo ""
    echo "3. checkout最適化確認:"
    grep -A3 'actions/checkout@' "$WORKFLOWS_DIR"/*.yml 2>/dev/null | grep -E '(fetch-depth|sparse-checkout)' || echo "⚠ checkout最適化の余地あり"

    echo ""
    echo "4. キャッシュの保存/復元確認:"
    echo "  cache/restore使用箇所:"
    grep -n 'actions/cache/restore@' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "    なし"
    echo "  cache/save使用箇所:"
    grep -n 'actions/cache/save@' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "    なし"
}

# 保守性チェック
check_maintainability() {
    echo "=== 保守性チェック（5項目） ==="

    echo "1. name未設定ステップ検出:"
    awk '/- (run|uses):/{if(prev !~ /name:/){print FILENAME":"NR":"$0}} {prev=$0}' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "✓ 全てname設定済み"

    echo ""
    echo "2. ハードコードバージョン検出:"
    grep -ohE "(node-version|python-version|ruby-version): '[0-9]+'" "$WORKFLOWS_DIR"/*.yml 2>/dev/null | sort | uniq -c || echo "✓ なし"

    echo ""
    echo "3. @main/@master参照検出（参考情報）:"
    grep -nE 'uses:.*@(main|master)' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "✓ なし"

    echo ""
    echo "4. 【重要】case関数改善可能な条件式検出:"
    grep -nE '\$\{\{[^}]*(\&\&|\|\|)[^}]*\}\}' "$WORKFLOWS_DIR"/*.yml 2>/dev/null || echo "✓ なし"

    echo ""
    echo "5. 【重要】bash値分岐if-else詳細確認:"
    grep -A8 'run: |' "$WORKFLOWS_DIR"/*.yml 2>/dev/null | grep -B2 -A6 'if \[' | head -20 || echo "✓ なし"
}

# case関数適用可能性の詳細確認（最重要）
check_case_function() {
    echo "=== case関数適用可能性の詳細確認（最重要） ==="
    echo ""

    echo "【パターン1】GitHub Actions式での三項演算子風記述:"
    echo "  改善例: \${{ condition && 'value1' || 'value2' }} → case関数で明示的に"
    local pattern1_found=false
    if grep -nE '\$\{\{[^}]*(\&\&|\|\|)[^}]*\}\}' "$WORKFLOWS_DIR"/*.yml 2>/dev/null; then
        pattern1_found=true
    else
        echo "  なし"
    fi

    echo ""
    echo "【パターン2】bash内でActions式を使った分岐:"
    echo "  改善例: if [[ \"\${{ var }}\" == \"value\" ]] → ステップレベルif条件へ"
    local pattern2_found=false
    if grep -nE 'if \[\[.*\$\{\{.*\}\}.*\]\]' "$WORKFLOWS_DIR"/*.yml 2>/dev/null; then
        pattern2_found=true
    else
        echo "  なし"
    fi

    echo ""
    echo "【パターン3】bash内の値分岐if-else:"
    echo "  改善例: if-elif-else → case関数で簡潔に"
    local pattern3_found=false
    for file in "$WORKFLOWS_DIR"/*.yml "$WORKFLOWS_DIR"/*.yaml; do
        [ -f "$file" ] || continue
        echo "  --- $file ---"
        if awk '/run: \|/{flag=1; line=NR; next}
                 flag && /^[^ ]/{flag=0}
                 flag && /if \[/{print "    "line":"$0; for(i=0;i<3;i++){getline; print "    "(line+i+1)":"$0}}' "$file" 2>/dev/null | head -20; then
            pattern3_found=true
        else
            echo "    なし"
        fi
    done

    echo ""
    echo "=== 検出サマリー ==="
    echo "  パターン1（Actions式&&/||）: $([ "$pattern1_found" = true ] && echo "検出あり ⚠" || echo "なし ✓")"
    echo "  パターン2（bash内Actions式if）: $([ "$pattern2_found" = true ] && echo "検出あり ⚠" || echo "なし ✓")"
    echo "  パターン3（bash値分岐if-else）: $([ "$pattern3_found" = true ] && echo "検出あり ⚠" || echo "なし ✓")"
}

# 全チェック実行
check_all() {
    list_files
    echo ""
    echo "==============================================="
    echo ""
    check_security
    echo ""
    echo "==============================================="
    echo ""
    check_best_practices
    echo ""
    echo "==============================================="
    echo ""
    check_performance
    echo ""
    echo "==============================================="
    echo ""
    check_maintainability
    echo ""
    echo "==============================================="
    echo ""
    check_case_function
}

# メイン処理
case "${1:-}" in
    --list-files)
        list_files
        ;;
    --security)
        check_security
        ;;
    --best-practices)
        check_best_practices
        ;;
    --performance)
        check_performance
        ;;
    --maintainability)
        check_maintainability
        ;;
    --case-function)
        check_case_function
        ;;
    --all)
        check_all
        ;;
    *)
        echo "Usage: $0 {--list-files|--security|--best-practices|--performance|--maintainability|--case-function|--all}"
        echo ""
        echo "Options:"
        echo "  --list-files        ワークフローファイル一覧を表示"
        echo "  --security          セキュリティチェック（3項目）"
        echo "  --best-practices    ベストプラクティスチェック（5項目）"
        echo "  --performance       パフォーマンスチェック（4項目）"
        echo "  --maintainability   保守性チェック（5項目）"
        echo "  --case-function     case関数適用可能性の詳細確認（最重要）"
        echo "  --all               全チェックを実行"
        exit 1
        ;;
esac
