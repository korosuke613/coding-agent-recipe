---
name: respond-to-pr-review
description: GitHub Pull RequestのレビューコメントにClaude Code風に効率的に対応するスキル。レビュー内容の確認、各コメントへの返信作成、スレッドのresolve処理を一貫したワークフローで実行。PRレビュー対応、レビューコメント返信、レビュー指摘への対応時に使用。
---

# Respond to PR Review

## 概要

GitHub Pull Requestのレビューコメントに対して、適切な判断と返信を行い、スレッドをresolveするまでの一連のワークフローをサポートするスキル。

## ワークフロー

### Step 1: レビューコメントの取得と確認

PRのレビューコメントをGitHub CLIで取得し、内容を確認する。

```bash
# PRのレビューコメント一覧を取得
gh api /repos/{owner}/{repo}/pulls/{pr_number}/comments | jq '.[] | {id, path, line, body}'
```

各コメントについて以下を確認：
- コメントID
- 対象ファイルと行番号
- 指摘内容

### Step 2: 対応判断

各レビューコメントについて、対応するかどうかを判断する。

#### 対応すべきコメント

- **明確なバグや問題点の指摘** → 修正してコミット
- **セキュリティ上の懸念** → 必ず対応
- **具体的な改善提案（suggestion付き）** → 基本的に採用

#### 対応を検討すべきコメント

以下の基準で判断：

**テストカバレッジの指摘**
- 内部関数でAPIモックが必要 → 費用対効果が低い、対応しない
- 既存のロジックが十分テストされている → 対応不要の可能性
- プロジェクト規模が小さい → 過剰品質になる可能性

**エラーハンドリングの指摘**
- 関数内部と呼び出し側の両方で指摘 → 重複を避け、呼び出し側のみ対応
- すでに別の箇所で対応済み → 対応済みであることを説明

#### 判断の原則

1. **重複を避ける**: 同じエラーハンドリングを複数箇所に追加しない
2. **費用対効果**: テストの実装コストと効果を天秤にかける
3. **実用性優先**: 理想論より実用上の問題解決を優先

### Step 3: 必要に応じてコードを修正

対応が必要なコメントについて、コードを修正してコミットする。

```bash
# 修正をコミット
git add <modified_files>
git commit -m "fix: <コミットメッセージ>

<修正内容の説明>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# リモートにpush
git push origin <branch_name>
```

### Step 4: 各コメントに返信

すべてのレビューコメントに対して、返信を作成する。**すべてのコメントに返信することが重要**。

#### 返信パターン

**対応済みの場合:**
```markdown
✅ 修正しました (<commit_hash>)

<具体的な修正内容の説明>
```

**対応しない場合:**
```markdown
この件は対応しません

**理由：**
- <理由1>
- <理由2>

<補足説明>
```

**間接的に対応済みの場合:**
```markdown
✅ 対応済み (<commit_hash>)

コメント#X の修正で、<具体的な対応内容>。これにより<問題が解決した理由>。
```

#### 返信の実行

```bash
# 各コメントに返信（コメントIDを使用）
gh api /repos/{owner}/{repo}/pulls/comments/{comment_id}/replies -X POST -f body="<返信内容>"
```

### Step 5: レビュースレッドをresolve

すべてのコメントに返信したら、レビュースレッドをresolve状態にする。

```bash
# まずスレッドIDを取得
gh api graphql -f query='
query {
  repository(owner: "{owner}", name: "{repo}") {
    pullRequest(number: {pr_number}) {
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

# 各スレッドをresolve
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "<thread_id>"}) {
    thread { isResolved }
  }
}'
```

複数スレッドを一度にresolveする場合:

```bash
gh api graphql -f query='
mutation {
  thread1: resolveReviewThread(input: {threadId: "<thread_id_1>"}) {
    thread { isResolved }
  }
  thread2: resolveReviewThread(input: {threadId: "<thread_id_2>"}) {
    thread { isResolved }
  }
  thread3: resolveReviewThread(input: {threadId: "<thread_id_3>"}) {
    thread { isResolved }
  }
}'
```

## ベストプラクティス

### 返信の品質

- **具体的に**: 何を修正したか、なぜ対応しないかを明確に
- **コミットハッシュを含める**: 修正内容を追跡可能にする
- **敬意を持って**: 対応しない場合も丁寧に理由を説明

### 効率的な対応

1. **一度に全コメントを確認**: 重複や関連性を把握
2. **関連コメントをまとめて対応**: 同じ修正で複数の指摘に対応できる場合
3. **返信とresolveを同時に**: 返信後すぐにresolveすることで漏れを防ぐ

### 判断の透明性

- 対応しない理由は具体的に説明
- プロジェクトの規模や状況を考慮
- 実用上の問題がないことを明確に

## 参考資料

詳細なGitHub API使用例は [references/github-api-examples.md](references/github-api-examples.md) を参照してください。
