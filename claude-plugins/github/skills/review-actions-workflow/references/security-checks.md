# セキュリティチェック

GitHub Actionsワークフローにおけるセキュリティリスクと対策を詳細に解説する。

## 1. Third-partyアクションのリスクと対策

### リスク

Third-partyアクションは外部の開発者が管理するコードを実行するため、以下のリスクがある：

- **サプライチェーン攻撃**: アクションのリポジトリが侵害され、悪意のあるコードが挿入される
- **バージョン変更による動作変更**: `@v1`などのメジャーバージョンタグは上書き可能で、意図しない変更が適用される
- **リポジトリ削除・移動**: アクションが削除されるとワークフローが失敗する

### 対策: SHA固定（Pin to commit hash）

```yaml
# 悪い例: タグ参照
- uses: actions/checkout@v4

# 良い例: SHA固定
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

### SHA固定の確認方法

```bash
# GitHubでタグに対応するSHAを確認
gh api repos/actions/checkout/git/refs/tags/v4.1.1 --jq '.object.sha'
```

### Grepパターン

```bash
# タグ参照を検出（@v, @main, @master）
grep -E 'uses:\s+\w+/\w+@(v[0-9]+|main|master)' .github/workflows/*.yml
```

## 2. @main/@master参照の危険性

### 問題点

- `@main`や`@master`はブランチの最新コミットを常に参照
- アクションの破壊的変更が即座に反映される
- 悪意のあるコードが挿入された場合、即座に影響を受ける

### 検出パターン

```bash
# @main/@master/@HEAD参照を検出
grep -E 'uses:\s+[^@]+@(main|master|HEAD)' .github/workflows/*.yml
```

### 推奨対応

1. 特定バージョンのタグに変更
2. さらにそのタグのSHAに固定

## 3. permissions設定の最小化

### デフォルトのリスク

デフォルトでは、ワークフローに`contents: write`などの広い権限が付与される場合がある。

### 最小権限の原則

```yaml
# ワークフローレベルでデフォルト権限を最小化
permissions:
  contents: read

jobs:
  build:
    # ジョブに必要な権限のみ追加
    permissions:
      contents: read
      issues: write
```

### 主要なpermissionスコープ

| スコープ | 説明 | 最小化ポイント |
|---------|------|---------------|
| `contents` | リポジトリコンテンツ | 読み取りのみなら`read`に |
| `packages` | パッケージ操作 | 必要な場合のみ付与 |
| `issues` | Issue操作 | コメント投稿時のみ`write` |
| `pull-requests` | PR操作 | レビュー投稿時のみ`write` |
| `actions` | ワークフロー操作 | 通常は不要 |

### 検出パターン

```bash
# permissionsが未設定のワークフローを検出
grep -L 'permissions:' .github/workflows/*.yml
```

## 4. スクリプトインジェクション対策

### リスク

ユーザー入力（PRタイトル、ブランチ名、コミットメッセージ等）を直接シェルコマンドに埋め込むと、任意のコードが実行される。

### 危険なパターン

```yaml
# 危険: 直接展開
- run: echo "PR Title: ${{ github.event.pull_request.title }}"

# 危険: 直接展開（Issue body）
- run: |
    echo "${{ github.event.issue.body }}"
```

### 安全なパターン

```yaml
# 安全: 環境変数経由
- run: echo "PR Title: $PR_TITLE"
  env:
    PR_TITLE: ${{ github.event.pull_request.title }}

# 安全: 入力のバリデーション
- run: |
    if [[ ! "$PR_TITLE" =~ ^[a-zA-Z0-9\ \-\_]+$ ]]; then
      echo "Invalid PR title"
      exit 1
    fi
  env:
    PR_TITLE: ${{ github.event.pull_request.title }}
```

### インジェクションリスクのある式

| 式 | リスク |
|---|-------|
| `github.event.pull_request.title` | 高 |
| `github.event.pull_request.body` | 高 |
| `github.event.issue.title` | 高 |
| `github.event.issue.body` | 高 |
| `github.event.comment.body` | 高 |
| `github.head_ref` | 中 |
| `github.event.commits[*].message` | 中 |

### 検出パターン

```bash
# runブロック内での直接式展開を検出
grep -E 'run:.*\$\{\{\s*(github\.event\.(pull_request|issue|comment)\.(title|body)|github\.head_ref)' .github/workflows/*.yml
```

## 5. pull_request_targetの安全性

### リスク

`pull_request_target`はフォークからのPRでもベースリポジトリの権限でシークレットにアクセスできる。

### 危険なパターン

```yaml
# 危険: フォークのコードをチェックアウトして実行
on: pull_request_target

jobs:
  build:
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.sha }} # フォークのコード！
      - run: npm install && npm run build  # 悪意のあるコードが実行される可能性
```

### 安全なパターン

```yaml
# パターン1: ベースブランチのコードのみ使用
on: pull_request_target

jobs:
  label:
    steps:
      - uses: actions/checkout@v4  # refを指定しない = ベースブランチ
      - run: ./safe-script.sh  # 信頼できるコードのみ

# パターン2: 分離されたジョブで実行
on: pull_request_target

jobs:
  # 信頼できるコードのみのジョブ
  safe-job:
    steps:
      - uses: actions/labeler@v4

  # フォークのコードを実行するジョブ（シークレットなし）
  untrusted-job:
    needs: safe-job
    environment: untrusted  # シークレットを含まない環境
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ github.event.pull_request.head.sha }}
```

### 検出パターン

```bash
# pull_request_targetとhead.sha参照の組み合わせを検出
grep -l 'pull_request_target' .github/workflows/*.yml | xargs grep -l 'head\.sha'
```

## 6. シークレット管理

### ベストプラクティス

- シークレットはログに出力しない
- 必要最小限のジョブ・ステップにのみシークレットを渡す
- Environment secretsを使用して環境ごとに分離

### 検出パターン

```bash
# シークレットを直接echoしているパターンを検出
grep -E 'echo.*\$\{\{\s*secrets\.' .github/workflows/*.yml
```

## チェックリスト

- [ ] Third-partyアクションはSHA固定されているか
- [ ] `@main`/`@master`参照がないか
- [ ] `permissions`が最小限に設定されているか
- [ ] ユーザー入力が環境変数経由で渡されているか
- [ ] `pull_request_target`が安全に使用されているか
- [ ] シークレットが不用意にログ出力されていないか
