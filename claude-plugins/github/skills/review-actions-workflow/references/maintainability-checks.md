# 保守性・可読性チェック

GitHub Actionsワークフローの長期的な保守性と可読性を向上させるためのチェック項目を解説する。

## 1. ジョブ・ステップの命名規則

### ジョブ名の設計

```yaml
jobs:
  # 悪い例: 内容が分からない
  job1:
    runs-on: ubuntu-latest

  # 良い例: 役割が明確
  lint-and-format:
    name: Lint and Format Check
    runs-on: ubuntu-latest
```

### ステップ名の設計

```yaml
steps:
  # 悪い例: 名前なし
  - run: npm ci
  - run: npm test

  # 良い例: 何をしているか明確
  - name: Install dependencies
    run: npm ci

  - name: Run unit tests
    run: npm test
```

### 命名のガイドライン

| 要素 | 推奨形式 | 例 |
|-----|---------|---|
| ジョブID | kebab-case | `build-and-test` |
| ジョブ名 | 動詞 + 名詞 | `Build and Test Application` |
| ステップ名 | 動詞で開始 | `Install dependencies` |

### 検出パターン

```bash
# nameが未設定のステップを検出
grep -B1 '^\s*- run:' .github/workflows/*.yml | grep -v 'name:'
```

## 2. 環境変数の一元管理

### ワークフローレベルのenv

```yaml
name: CI

env:
  NODE_VERSION: '20'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
```

### ジョブレベルのenv

```yaml
jobs:
  test:
    env:
      CI: true
      DATABASE_URL: postgres://localhost:5432/test
    steps:
      - run: npm test
```

### マジックナンバー・マジックストリングの排除

```yaml
# 悪い例: ハードコード
steps:
  - uses: actions/setup-node@v4
    with:
      node-version: '20'
  - run: npm test -- --timeout 30000

# 良い例: 環境変数で管理
env:
  NODE_VERSION: '20'
  TEST_TIMEOUT: 30000

steps:
  - uses: actions/setup-node@v4
    with:
      node-version: ${{ env.NODE_VERSION }}
  - run: npm test -- --timeout ${{ env.TEST_TIMEOUT }}
```

### 検出パターン

```bash
# 同じ値が複数箇所で使われているかチェック
grep -ohE "node-version: '[0-9]+'" .github/workflows/*.yml | sort | uniq -c | sort -rn
```

## 3. ファイル分割の基準

### 分割すべきケース

1. **300行を超えるワークフロー**: 可読性が低下
2. **複数の独立した機能**: CI、CD、定期実行など
3. **再利用可能な処理**: Reusable Workflowsへの切り出し

### 分割パターン

```
.github/workflows/
├── ci.yml           # プルリクエスト時のチェック
├── cd.yml           # 本番デプロイ
├── scheduled.yml    # 定期実行タスク
├── release.yml      # リリース処理
└── reusable/
    ├── test.yml     # 再利用可能なテストワークフロー
    └── deploy.yml   # 再利用可能なデプロイワークフロー
```

### composite actionsへの切り出し

```
.github/
├── actions/
│   ├── setup-project/
│   │   └── action.yml    # プロジェクトセットアップ
│   └── notify-slack/
│       └── action.yml    # Slack通知
└── workflows/
    └── ci.yml
```

## 4. コメントとドキュメント

### ワークフローの説明

```yaml
# CI Workflow
#
# このワークフローはプルリクエストとmainブランチへのプッシュ時に実行され、
# 以下のチェックを行います：
# - コードフォーマット（Prettier）
# - リント（ESLint）
# - 型チェック（TypeScript）
# - 単体テスト（Jest）
#
# 環境変数:
# - NODE_VERSION: 使用するNode.jsバージョン

name: CI
```

### 複雑なステップの説明

```yaml
steps:
  # キャッシュキーにはpackage-lock.jsonのハッシュを使用
  # これにより依存関係が変わらない限りキャッシュが再利用される
  - uses: actions/cache@v4
    with:
      path: ~/.npm
      key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### 条件分岐の説明

```yaml
steps:
  # mainブランチへのマージ時のみデプロイを実行
  # PRのマージコミットでは github.event_name が 'push' になる
  - name: Deploy to production
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    run: ./deploy.sh
```

## 5. DRY原則の適用

### アンカーとエイリアス（YAML機能）

```yaml
# アンカー定義
x-common-setup: &common-setup
  - uses: actions/checkout@v4
  - uses: actions/setup-node@v4
    with:
      node-version: '20'
      cache: 'npm'
  - run: npm ci

jobs:
  lint:
    steps:
      *common-setup  # エイリアスで参照
      - run: npm run lint

  test:
    steps:
      *common-setup  # 同じセットアップを再利用
      - run: npm test
```

### Composite Actionsによる共通化

```yaml
# .github/actions/setup/action.yml
name: Setup
runs:
  using: composite
  steps:
    - uses: actions/checkout@v4
    - uses: actions/setup-node@v4
      with:
        node-version: '20'
        cache: 'npm'
    - run: npm ci
      shell: bash

# 使用側
steps:
  - uses: ./.github/actions/setup
  - run: npm run lint
```

## 6. エラーハンドリング

### continue-on-errorの適切な使用

```yaml
steps:
  # 失敗してもワークフロー全体は継続
  - name: Run optional check
    continue-on-error: true
    run: npm run optional-check

  # 結果を後で参照可能
  - name: Check result
    if: steps.optional-check.outcome == 'failure'
    run: echo "Optional check failed, but continuing..."
```

### ステップの出力を活用

```yaml
steps:
  - name: Check for changes
    id: changes
    run: |
      if git diff --quiet; then
        echo "changed=false" >> $GITHUB_OUTPUT
      else
        echo "changed=true" >> $GITHUB_OUTPUT
      fi

  - name: Build
    if: steps.changes.outputs.changed == 'true'
    run: npm run build
```

## 7. バージョン管理

### アクションのバージョン表記

```yaml
# 悪い例: メジャーバージョンのみ
- uses: actions/checkout@v4

# 良い例: SHA固定 + バージョンコメント
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11 # v4.1.1
```

### Renovate/Dependabotの活用

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: "github-actions"
    directory: "/"
    schedule:
      interval: "weekly"
    groups:
      github-actions:
        patterns:
          - "*"
```

## 8. bashのif文簡素化

### ステップレベルif条件への移動

bashスクリプト内でGitHub Actions式を使った条件分岐を行っている場合、ステップの`if`条件に移動することで簡潔になります。

```yaml
# 悪い例: bashのif文で条件分岐
- name: Add label to PR
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    if [[ "${{ github.event_name }}" == "pull_request" ]]; then
      gh pr edit ${{ github.event.number }} --add-label 'needs-review'
    else
      echo "Skipping label update (not a pull request)"
    fi

# 良い例: ステップレベルif条件を使用
- name: Add label to PR
  if: github.event_name == 'pull_request'
  env:
    GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
  run: |
    gh pr edit ${{ github.event.number }} --add-label 'needs-review'
```

**メリット:**
- bashのif文が不要
- GitHub Actionsのネイティブな条件分岐で意図が明確
- ステップがスキップされた理由がUIで確認しやすい

### case関数で値分岐を簡素化

bashのif-else文が単純に値を分岐させているだけの場合、case関数を使用します。

```yaml
# 悪い例: bashのif-elseで値を分岐
- name: Visual regression testing
  run: |
    if [[ -z "${{ steps.changed-files.outputs.contents_all_changed }}" ]]; then
      pnpm run vrt:regression --grep="update dependencies"
    else
      pnpm run vrt:regression --grep="add contents"
    fi

# 良い例: case関数で値を選択
- name: Visual regression testing
  run: |
    pnpm run vrt:regression --grep="${{
      case(
        steps.changed-files.outputs.contents_all_changed != '',
        'add contents',
        'update dependencies'
      )
    }}"
```

**メリット:**
- コマンド引数の値選択が一目で分かる
- if-else文のネストが減り可読性向上
- コメントなしでも意図が明確

### 複数条件での環境変数設定

```yaml
# 悪い例: bashのif-elif-elseで環境変数を設定
- name: Select environment
  run: |
    if [[ "${{ github.ref }}" == "refs/heads/main" ]]; then
      ENV="production"
    elif [[ "${{ github.ref }}" == "refs/heads/staging" ]]; then
      ENV="staging"
    else
      ENV="development"
    fi
    deploy.sh --env $ENV

# 良い例: case関数で環境変数を設定
- name: Select environment
  env:
    DEPLOY_ENV: ${{
      case(
        github.ref == 'refs/heads/main', 'production',
        github.ref == 'refs/heads/staging', 'staging',
        'development'
      )
    }}
  run: |
    deploy.sh --env $DEPLOY_ENV
```

### 検出パターン

```bash
# GitHub Actions式を使ったbashのif文を検出
grep -nE 'if \[\[.*\$\{\{.*\}\}.*\]\];' .github/workflows/*.yml

# 値分岐だけのif-else文を検出（要目視確認）
grep -A5 'run: |' .github/workflows/*.yml | grep -E '(if \[\[|else|fi)'
```

### 適用基準

以下の場合はbashのif文簡素化を検討してください：

1. **条件がGitHub Actions式のみ** - ステップレベルif条件へ移動
2. **値の選択のみを行うif-else** - case関数を使用
3. **環境変数の設定のみを行うif-elif-else** - case関数とenv:で管理

以下の場合はbashのif文を維持してください：

1. **シェルコマンドの結果を使う条件分岐** - `[ -f file.txt ]`, `$(command)`など
2. **複数のコマンドを実行する条件分岐** - 単なる値選択ではない
3. **動的な計算が必要** - `date`コマンド、算術演算など

## チェックリスト

- [ ] すべてのジョブに明確な名前（name）が設定されているか
- [ ] すべてのステップに名前（name）が設定されているか
- [ ] 環境変数はワークフロー/ジョブレベルで一元管理されているか
- [ ] マジックナンバー・マジックストリングは排除されているか
- [ ] 300行を超えるワークフローは分割を検討したか
- [ ] 複雑な処理にはコメントが付いているか
- [ ] 重複するステップはComposite Actionsで共通化されているか
- [ ] アクションのバージョンはSHA固定されているか
- [ ] GitHub Actions式を使ったbashのif文はステップレベルif条件に移動できないか
- [ ] 値分岐だけのbashのif-elseはcase関数で簡素化できないか
