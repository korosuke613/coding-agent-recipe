# Pre-commit ルール詳細: コミット前にlint, format, testを実行

## なぜコミット前にlint, format, testを実行するのか

コミット前にコード品質チェックを実行することで、以下のメリットがあります：

1. **CI失敗の防止**: コミット後にCIで失敗することを防ぎ、開発効率を向上
2. **コード品質の担保**: 常に一定の品質基準を満たしたコードのみがリポジトリに入る
3. **レビューの効率化**: レビュアーがスタイルや軽微な問題を指摘する必要がなくなる
4. **早期のバグ発見**: コミット時点でバグを発見し、修正コストを最小化
5. **チーム全体の品質向上**: 自動化により、個人のスキルに依存せずに品質を保てる

## 推奨ツール

### 1. Husky + lint-staged（Node.js/JavaScript/TypeScript）

**Husky**: Git hooksを簡単に設定できるツール
**lint-staged**: ステージされたファイルのみに対してコマンドを実行するツール

#### インストール

```bash
npm install --save-dev husky lint-staged
```

#### 初期設定

```bash
# huskyの初期化
npx husky install

# package.jsonにprepareスクリプトを追加（他の開発者も自動的にhuskyを有効化）
npm pkg set scripts.prepare="husky install"

# pre-commitフックを作成
npx husky add .husky/pre-commit "npx lint-staged"
```

#### package.json設定例

```json
{
  "scripts": {
    "prepare": "husky install",
    "lint": "eslint .",
    "format": "prettier --write .",
    "test": "jest"
  },
  "devDependencies": {
    "husky": "8.0.3",
    "lint-staged": "15.2.0",
    "eslint": "8.57.0",
    "prettier": "3.2.5",
    "jest": "29.7.0"
  },
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": [
      "eslint --fix",
      "prettier --write",
      "jest --bail --findRelatedTests"
    ],
    "*.{json,md,css,scss}": [
      "prettier --write"
    ]
  }
}
```

#### .husky/pre-commitファイル

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
```

### 2. pre-commit（Python製、言語非依存）

**pre-commit**: Python製のGit hooksフレームワーク。多言語対応で、豊富なプラグインエコシステム

#### インストール

```bash
pip install pre-commit
# または
brew install pre-commit
```

#### 初期設定

```bash
# .pre-commit-config.yamlを作成後
pre-commit install
```

#### .pre-commit-config.yaml設定例

```yaml
repos:
  # 汎用的なチェック
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
      - id: check-json
      - id: check-merge-conflict

  # JavaScript/TypeScript用
  - repo: local
    hooks:
      - id: eslint
        name: ESLint
        entry: npm run lint
        language: system
        types: [javascript, typescript, jsx, tsx]
        pass_filenames: false

      - id: prettier
        name: Prettier
        entry: npm run format
        language: system
        types: [javascript, typescript, jsx, tsx, json, markdown, css]
        pass_filenames: false

      - id: jest
        name: Jest
        entry: npm test
        language: system
        pass_filenames: false
```

### 3. lefthook（Go製、高速）

**lefthook**: Go製の高速なGit hooksマネージャー

#### インストール

```bash
npm install --save-dev lefthook
# または
brew install lefthook
```

#### lefthook.yml設定例

```yaml
pre-commit:
  parallel: true
  commands:
    lint:
      glob: "*.{js,ts,jsx,tsx}"
      run: npx eslint --fix {staged_files}

    format:
      glob: "*.{js,ts,jsx,tsx,json,md,css}"
      run: npx prettier --write {staged_files}

    test:
      glob: "*.{js,ts,jsx,tsx}"
      run: npx jest --bail --findRelatedTests {staged_files}
```

## チェックすべき項目

### 1. Lint（コード規約チェック）

**目的**: コーディングスタイルの統一と潜在的な問題の早期発見

**推奨ツール**:
- **ESLint**: JavaScript/TypeScript用
- **Pylint/Flake8**: Python用
- **RuboCop**: Ruby用
- **golangci-lint**: Go用

**設定例**:
```json
// lint-staged設定
"*.{ts,tsx,js,jsx}": [
  "eslint --fix --max-warnings=0"
]
```

### 2. Format（コード整形）

**目的**: コードスタイルの自動統一

**推奨ツール**:
- **Prettier**: JavaScript/TypeScript/JSON/CSS/Markdown用
- **Black**: Python用
- **gofmt**: Go用
- **rustfmt**: Rust用

**設定例**:
```json
// lint-staged設定
"*.{ts,tsx,js,jsx,json,md,css}": [
  "prettier --write"
]
```

### 3. Test（テスト実行）

**目的**: コード変更による既存機能の破壊を防止

**推奨設定**:
- ✅ 変更されたファイルに関連するテストのみ実行（高速化）
- ✅ `--bail` オプションで最初の失敗で停止（高速化）
- ❌ 全テストを実行しない（pre-commitでは遅すぎる）
- ❌ E2Eテストや統合テストは実行しない（CIで実行）

**設定例**:
```json
// lint-staged設定（Jest）
"*.{ts,tsx,js,jsx}": [
  "jest --bail --findRelatedTests"
]
```

```bash
# Vitestの場合
vitest related --run
```

### 4. Type Check（型チェック）

**目的**: TypeScriptの型エラーを早期発見

**注意点**:
- `tsc --noEmit` は全ファイルをチェックするため遅い
- 変更されたファイルのみチェックするのは困難
- 型チェックはCIで実行し、pre-commitでは省略するのも一案

**設定例**:
```json
// package.json
"scripts": {
  "type-check": "tsc --noEmit"
}
```

```yaml
# .pre-commit-config.yaml
- repo: local
  hooks:
    - id: type-check
      name: TypeScript Type Check
      entry: npm run type-check
      language: system
      pass_filenames: false
      types: [typescript]
```

## ベストプラクティス

### 1. ステージされたファイルのみ処理

```json
// ✅ 良い例: lint-stagedでステージされたファイルのみ処理
"lint-staged": {
  "*.ts": ["eslint --fix", "prettier --write"]
}
```

```bash
# ❌ 悪い例: 全ファイルを処理（遅い）
eslint .
prettier --write .
```

### 2. 自動修正を有効化

```json
// ✅ 良い例: --fixで自動修正
"*.ts": ["eslint --fix", "prettier --write"]
```

```json
// ❌ 悪い例: エラーを報告するだけ（開発者が手動で修正）
"*.ts": ["eslint", "prettier --check"]
```

### 3. 並列実行で高速化

```yaml
# lefthook.yml
pre-commit:
  parallel: true  # ✅ 並列実行を有効化
  commands:
    lint:
      run: npx eslint --fix {staged_files}
    format:
      run: npx prettier --write {staged_files}
```

### 4. 適切なスコープ設定

```json
// ✅ 良い例: ファイルタイプごとに異なるコマンド
"lint-staged": {
  "*.{ts,tsx}": ["eslint --fix", "prettier --write", "jest --findRelatedTests"],
  "*.{js,jsx}": ["eslint --fix", "prettier --write"],
  "*.{json,md}": ["prettier --write"]
}
```

### 5. 重い処理はCIで実行

```yaml
# ✅ 良い例: pre-commitでは軽量なチェックのみ
# pre-commit: lint, format, unit tests（変更箇所のみ）
# CI: lint, format, 全テスト, E2Eテスト, カバレッジ, ビルド

# ❌ 悪い例: pre-commitで全テストやE2Eテストを実行
```

## よくある問題と解決策

### 問題1: pre-commitが遅い

**原因**: 全ファイルをチェックしている、重いテストを実行している

**解決策**:
- lint-stagedでステージされたファイルのみ処理
- テストは `--findRelatedTests` で関連テストのみ実行
- E2Eテストや統合テストはpre-commitから除外し、CIで実行

### 問題2: pre-commitをスキップしたい場合がある

**解決策**:
```bash
# 一時的にスキップ（緊急時のみ）
git commit --no-verify -m "fix: 緊急修正"

# または環境変数で制御
SKIP=eslint git commit -m "feat: 新機能追加"
```

**注意**: `--no-verify` の多用は品質低下につながるため、本当に必要な場合のみ使用

### 問題3: CI/CDパイプラインで失敗する

**原因**: pre-commitとCIでチェック内容が異なる

**解決策**:
- pre-commitとCIで同じツール・同じ設定を使用
- package.jsonのscriptsを共通化
- CIではより厳格なチェック（全テスト、カバレッジなど）を追加

### 問題4: チームメンバーがpre-commitを有効化していない

**原因**: huskyのインストールを忘れている

**解決策**:
```json
// package.json
{
  "scripts": {
    "prepare": "husky install"  // npm installで自動的に有効化
  }
}
```

または、CIでpre-commitチェックを実行して強制する

## Grep パターン

プロジェクトでpre-commit設定を検出するパターン：

### Husky検出

```bash
# .huskyディレクトリの存在確認
ls -la .husky/pre-commit

# package.jsonでの設定確認
grep -E "\"(husky|lint-staged)\"" package.json

# prepareスクリプトの確認
grep -E "\"prepare\".*\"husky install\"" package.json
```

### lint-staged設定検出

```bash
# package.jsonでのlint-staged設定
grep -A 10 "\"lint-staged\"" package.json

# 独立した設定ファイル
cat .lintstagedrc.json
cat .lintstagedrc.js
```

### pre-commit（Python）検出

```bash
# .pre-commit-config.yamlの存在確認
ls -la .pre-commit-config.yaml

# インストール確認
grep -r "pre-commit install" .git/hooks/pre-commit
```

### lefthook検出

```bash
# lefthook.ymlの存在確認
ls -la lefthook.yml

# package.jsonでの設定
grep -E "\"lefthook\"" package.json
```

## チェック実装ガイド

### 1. pre-commit設定の存在確認

```typescript
// 擬似コード
function checkPreCommitSetup(): CheckResult {
  const checks = {
    hasHusky: fileExists('.husky/pre-commit'),
    hasPreCommit: fileExists('.pre-commit-config.yaml'),
    hasLefthook: fileExists('lefthook.yml'),
    hasLintStaged: hasLintStagedConfig(),
  };

  if (!checks.hasHusky && !checks.hasPreCommit && !checks.hasLefthook) {
    return {
      status: 'fail',
      message: 'pre-commitツールが設定されていません',
    };
  }

  return { status: 'pass' };
}
```

### 2. lint-staged設定の確認

```typescript
function checkLintStagedConfig(): CheckResult {
  const config = readLintStagedConfig();

  const hasLint = config.some(cmd => /eslint|lint/.test(cmd));
  const hasFormat = config.some(cmd => /prettier|format/.test(cmd));
  const hasTest = config.some(cmd => /jest|vitest|test/.test(cmd));

  if (!hasLint) {
    return { status: 'warn', message: 'Lintチェックが設定されていません' };
  }
  if (!hasFormat) {
    return { status: 'warn', message: 'フォーマットチェックが設定されていません' };
  }
  if (!hasTest) {
    return { status: 'warn', message: 'テスト実行が設定されていません' };
  }

  return { status: 'pass' };
}
```

### 3. 自動修正提案の生成

```typescript
function generateFixSuggestions(): string[] {
  return [
    'npm install --save-dev husky lint-staged',
    'npx husky install',
    'npx husky add .husky/pre-commit "npx lint-staged"',
    'npm pkg set scripts.prepare="husky install"',
    // package.jsonにlint-staged設定を追加するコード
  ];
}
```

## 推奨される設定テンプレート

### 最小構成（シンプルなプロジェクト）

```json
// package.json
{
  "scripts": {
    "prepare": "husky install"
  },
  "devDependencies": {
    "husky": "8.0.3",
    "lint-staged": "15.2.0"
  },
  "lint-staged": {
    "*.{js,ts,jsx,tsx}": ["eslint --fix", "prettier --write"]
  }
}
```

### 推奨構成（本格的なプロジェクト）

```json
// package.json
{
  "scripts": {
    "prepare": "husky install",
    "lint": "eslint .",
    "format": "prettier --write .",
    "test": "jest",
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "husky": "8.0.3",
    "lint-staged": "15.2.0",
    "eslint": "8.57.0",
    "prettier": "3.2.5",
    "jest": "29.7.0",
    "typescript": "5.3.3"
  },
  "lint-staged": {
    "*.{ts,tsx}": [
      "eslint --fix --max-warnings=0",
      "prettier --write",
      "jest --bail --findRelatedTests --passWithNoTests"
    ],
    "*.{js,jsx}": [
      "eslint --fix --max-warnings=0",
      "prettier --write"
    ],
    "*.{json,md,css,scss}": [
      "prettier --write"
    ]
  }
}
```

```bash
# .husky/pre-commit
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

npx lint-staged
```

## まとめ

コミット前にlint, format, testを自動実行することで：

1. ✅ コード品質が自動的に担保される
2. ✅ CIの失敗を事前に防止できる
3. ✅ レビュープロセスが効率化される
4. ✅ チーム全体の開発効率が向上する

**重要な原則**:
- ステージされたファイルのみ処理（高速化）
- 自動修正を有効化（開発者の負担軽減）
- 重い処理はCIで実行（pre-commitは高速に保つ）
- チーム全員が自動的に有効化される仕組みを構築（`prepare` スクリプト）
