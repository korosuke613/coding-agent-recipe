# ベストプラクティス

GitHub Actionsワークフローの効率的な設計と運用のためのベストプラクティスを解説する。

## 1. キャッシュ活用

### actions/cacheの基本

```yaml
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-node-
```

### setup-*アクションの組み込みキャッシュ

多くのsetupアクションは`cache`オプションを提供している。

```yaml
# Node.js
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'  # または 'yarn', 'pnpm'

# Python
- uses: actions/setup-python@v5
  with:
    python-version: '3.12'
    cache: 'pip'

# Go
- uses: actions/setup-go@v5
  with:
    go-version: '1.22'
    cache: true

# Java (Gradle/Maven)
- uses: actions/setup-java@v4
  with:
    java-version: '21'
    distribution: 'temurin'
    cache: 'gradle'  # または 'maven'
```

### キャッシュキー設計

```yaml
# 良い例: ロックファイルのハッシュを使用
key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

# フォールバックキーの設定
restore-keys: |
  ${{ runner.os }}-node-
```

### 検出パターン

```bash
# setup-*アクションでcacheオプションが未使用のものを検出
grep -A5 'actions/setup-node@' .github/workflows/*.yml | grep -v 'cache:'
grep -A5 'actions/setup-python@' .github/workflows/*.yml | grep -v 'cache:'
```

## 2. マトリックスビルド

### 基本パターン

```yaml
jobs:
  test:
    strategy:
      matrix:
        node-version: [18, 20, 22]
        os: [ubuntu-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
```

### include/excludeの活用

```yaml
strategy:
  matrix:
    os: [ubuntu-latest, windows-latest]
    node: [18, 20]
    include:
      # 特定の組み合わせに設定を追加
      - os: ubuntu-latest
        node: 20
        coverage: true
    exclude:
      # 特定の組み合わせを除外
      - os: windows-latest
        node: 18
```

### fail-fast制御

```yaml
strategy:
  fail-fast: false  # 1つが失敗しても他を継続
  matrix:
    node-version: [18, 20, 22]
```

### マトリックス活用の検討ポイント

| シナリオ | 推奨 |
|---------|------|
| 複数Node.jsバージョンのテスト | マトリックス使用 |
| 複数OSでのテスト | マトリックス使用 |
| E2Eテストの分割実行 | マトリックス使用 |
| 単一環境での単純なビルド | マトリックス不要 |

## 3. Reusable Workflows

### 定義方法

```yaml
# .github/workflows/reusable-test.yml
name: Reusable Test Workflow

on:
  workflow_call:
    inputs:
      node-version:
        required: true
        type: string
    secrets:
      NPM_TOKEN:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
      - run: npm ci
      - run: npm test
```

### 呼び出し方法

```yaml
jobs:
  call-test:
    uses: ./.github/workflows/reusable-test.yml
    with:
      node-version: '20'
    secrets:
      NPM_TOKEN: ${{ secrets.NPM_TOKEN }}
```

### 外部リポジトリからの呼び出し

```yaml
jobs:
  call-external:
    uses: owner/repo/.github/workflows/reusable.yml@v1
    with:
      some-input: 'value'
```

## 4. Composite Actions

### 定義方法

```yaml
# .github/actions/setup-project/action.yml
name: 'Setup Project'
description: 'Setup Node.js and install dependencies'

inputs:
  node-version:
    description: 'Node.js version'
    required: false
    default: '20'

runs:
  using: 'composite'
  steps:
    - uses: actions/setup-node@v4
      with:
        node-version: ${{ inputs.node-version }}
        cache: 'npm'

    - run: npm ci
      shell: bash
```

### 使用方法

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: ./.github/actions/setup-project
    with:
      node-version: '22'
```

## 5. Reusable Workflows vs Composite Actions

| 観点 | Reusable Workflows | Composite Actions |
|------|-------------------|-------------------|
| 定義場所 | `.github/workflows/` | `.github/actions/` または別リポジトリ |
| 呼び出し方 | `uses: owner/repo/.github/workflows/xxx.yml@ref` | `uses: ./path/to/action` または `uses: owner/repo@ref` |
| ジョブ定義 | 可能（複数ジョブを含められる） | 不可（ステップのみ） |
| secrets渡し | 明示的に定義が必要 | 親ジョブのsecretsを継承 |
| 出力 | `outputs`を定義可能 | `outputs`を定義可能 |
| 適用場面 | 完全なCI/CDパイプライン | 共通セットアップ処理 |

### 選択指針

- **Reusable Workflows**: 複数のジョブを含む完全なワークフローを再利用したい場合
- **Composite Actions**: 単一ジョブ内の共通ステップをまとめたい場合

## 6. 条件分岐と早期終了

### パスフィルタリング

```yaml
on:
  push:
    paths:
      - 'src/**'
      - 'package.json'
    paths-ignore:
      - '**.md'
      - 'docs/**'
```

### ジョブレベルの条件

```yaml
jobs:
  deploy:
    if: github.ref == 'refs/heads/main'
```

### ステップレベルの条件

```yaml
steps:
  - name: Deploy to production
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
```

## チェックリスト

- [ ] setup-*アクションのcacheオプションは有効化されているか
- [ ] 複数バージョン/環境のテストにマトリックスを活用しているか
- [ ] 重複するワークフローはReusable Workflowsで共通化できないか
- [ ] 重複するセットアップ処理はComposite Actionsで共通化できないか
- [ ] パスフィルタリングで不要な実行を避けているか
