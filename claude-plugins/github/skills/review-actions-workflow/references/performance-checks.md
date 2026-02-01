# パフォーマンスチェック

GitHub Actionsワークフローの実行時間短縮とリソース効率化のためのチェック項目を解説する。

## 1. キャッシュ戦略

### 効果的なキャッシュ対象

| 対象 | キャッシュ方法 | 効果 |
|-----|--------------|------|
| npm/yarn/pnpm | setup-node cache オプション | 高 |
| pip | setup-python cache オプション | 高 |
| Gradle/Maven | setup-java cache オプション | 高 |
| Docker レイヤー | docker/build-push-action cache-from/to | 高 |
| ビルド成果物 | actions/cache | 中〜高 |

### キャッシュヒット率の最適化

```yaml
# キャッシュキーの階層化
- uses: actions/cache@v4
  with:
    path: |
      ~/.npm
      node_modules
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}-${{ hashFiles('**/*.ts') }}
    restore-keys: |
      ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}-
      ${{ runner.os }}-node-
```

### 検出パターン

```bash
# キャッシュを使用していないワークフローを検出
grep -L 'cache' .github/workflows/*.yml

# setup-*でcacheオプションが未設定のものを検出
grep -B2 -A10 'actions/setup-' .github/workflows/*.yml | grep -v 'cache:'
```

## 2. 並列実行の最適化

### ジョブの並列化

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: npm run lint

  test:
    runs-on: ubuntu-latest
    steps:
      - run: npm test

  # lint, testは並列実行される
  build:
    needs: [lint, test]  # 両方完了後に実行
    runs-on: ubuntu-latest
```

### マトリックスの活用

```yaml
jobs:
  test:
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - run: npm test -- --shard=${{ matrix.shard }}/4
```

### 依存関係のDAG最適化

```yaml
jobs:
  # 独立したジョブは並列実行
  lint: ...
  typecheck: ...
  unit-test: ...

  # 依存関係を最小限に
  integration-test:
    needs: [unit-test]  # 本当に必要な依存のみ

  deploy:
    needs: [lint, typecheck, integration-test]
```

### 検出パターン

```bash
# 不要なneeds依存を検出（全ジョブに依存しているケース）
grep -A20 'needs:' .github/workflows/*.yml
```

## 3. concurrency設定

### 同一ブランチでの重複実行防止

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### PRでの重複実行防止

```yaml
concurrency:
  group: pr-${{ github.event.pull_request.number }}
  cancel-in-progress: true
```

### 本番デプロイでは重複を許可しない

```yaml
concurrency:
  group: deploy-production
  cancel-in-progress: false  # 実行中のデプロイはキャンセルしない
```

### グループ設計パターン

| シナリオ | group | cancel-in-progress |
|---------|-------|-------------------|
| PRビルド | `pr-${{ github.event.number }}` | `true` |
| ブランチCI | `${{ github.workflow }}-${{ github.ref }}` | `true` |
| 本番デプロイ | `deploy-production` | `false` |
| 定期実行 | `scheduled-${{ github.workflow }}` | `false` |

### 検出パターン

```bash
# concurrencyが未設定のワークフローを検出
grep -L 'concurrency:' .github/workflows/*.yml
```

## 4. timeout-minutes設定

### デフォルトタイムアウトの問題

デフォルトは360分（6時間）で、ハングした場合に無駄な実行時間が発生する。

### 適切なタイムアウト設定

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10

  test:
    runs-on: ubuntu-latest
    timeout-minutes: 30

  e2e:
    runs-on: ubuntu-latest
    timeout-minutes: 60
```

### ステップレベルのタイムアウト

```yaml
steps:
  - name: Run flaky test
    timeout-minutes: 5
    run: npm run test:e2e
```

### 推奨タイムアウト値

| ジョブタイプ | 推奨値 |
|------------|--------|
| lint/format | 5-10分 |
| 単体テスト | 10-30分 |
| E2Eテスト | 30-60分 |
| ビルド | 15-30分 |
| デプロイ | 15-30分 |

### 検出パターン

```bash
# timeout-minutesが未設定のジョブを検出
grep -B5 'runs-on:' .github/workflows/*.yml | grep -v 'timeout-minutes'
```

## 5. 不要なジョブ・ステップの特定

### checkout不要なケース

```yaml
# 悪い例: ファイルを使わないのにcheckout
steps:
  - uses: actions/checkout@v4  # 不要
  - run: echo "Hello"

# 良い例: 必要な場合のみcheckout
steps:
  - run: echo "Hello"  # リポジトリのファイルを使わない
```

### スパースチェックアウト

```yaml
- uses: actions/checkout@v4
  with:
    sparse-checkout: |
      src
      tests
    sparse-checkout-cone-mode: false
```

### フェッチ深度の制限

```yaml
- uses: actions/checkout@v4
  with:
    fetch-depth: 1  # 最新コミットのみ（タグ不要の場合）
```

### 検出パターン

```bash
# fetch-depthが未設定のcheckoutを検出
grep -A5 'actions/checkout@' .github/workflows/*.yml | grep -v 'fetch-depth'
```

## 6. ランナーの選択

### セルフホステッドランナーの検討

| GitHub-hosted | Self-hosted |
|--------------|-------------|
| 2コア/7GB RAM | カスタマイズ可能 |
| 実行時間課金 | 固定コスト |
| メンテナンス不要 | メンテナンス必要 |
| 毎回クリーン環境 | キャッシュを永続化可能 |

### larger runners（GitHub Team/Enterprise）

```yaml
jobs:
  build:
    runs-on: ubuntu-latest-8-cores  # より強力なランナー
```

## 7. アーティファクト最適化

### 圧縮の活用

```yaml
- uses: actions/upload-artifact@v4
  with:
    name: build
    path: dist/
    compression-level: 9  # 最大圧縮
```

### 保持期間の設定

```yaml
- uses: actions/upload-artifact@v4
  with:
    name: logs
    path: logs/
    retention-days: 5  # デフォルト90日を短縮
```

## チェックリスト

- [ ] 依存関係のキャッシュは有効化されているか
- [ ] 独立したジョブは並列実行されているか
- [ ] 不要なneeds依存はないか
- [ ] concurrencyで重複実行を制御しているか
- [ ] timeout-minutesは適切に設定されているか
- [ ] checkoutのfetch-depthは最適化されているか
- [ ] アーティファクトの保持期間は適切か
