---
name: dev-standards
description: コミット前やPRレビュー時に開発ルール遵守をチェック。TypeScriptのany/as使用、CI設定、テスト、コミット規約などを検証し違反を報告。`/dev-standards`で明示的にチェック、`--fix`で自動修正。
---

# 開発ルール遵守チェックスキル

このスキルは、プロジェクトで重要な7つの開発ルールが適切に守られているかをチェックし、違反を発見・報告・修正します。

## 実行方法

### 基本的な使用方法

```
/dev-standards
```

プロジェクト全体の開発ルール遵守状況をチェックし、レポートを生成します。

### オプション

- `--fix` - 自動修正可能な違反を修正提案として表示
- `--typescript` - TypeScript関連のルール（any禁止、as制限）のみチェック
- `--type-assertion` - 型アサーション（as）の使用のみチェック
- `--ci` - CI/CD関連のルールのみチェック
- `--dependencies` - 依存関係管理のルールのみチェック
- `--commit` - コミット規約のルールのみチェック
- `--local-test` - ローカルテスト実行環境のルールのみチェック
- `--unit-test` - ユニットテスト関連のルールのみチェック
- `--pre-commit` - コミット前のlint/format/test実行に関するルールのみチェック
- 引数にファイルパスを指定 - 特定のファイルのみをチェック

### 使用例

```bash
# プロジェクト全体をチェック
/dev-standards

# TypeScriptファイルのanyとasをチェック
/dev-standards --typescript

# 型アサーション（as）の使用のみチェック
/dev-standards --type-assertion

# 自動修正提案を表示
/dev-standards --fix

# 特定のファイルをチェック
/dev-standards src/utils/api.ts
```

## チェックされる7つの開発ルール

### 1. TypeScriptにおいてanyとasは極力使わない

**目的**: 型安全性を確保し、バグを事前に防止する

**チェック内容**:
- `.ts`, `.tsx` ファイル内の `any` 使用を検出
- `any[]`, `Promise<any>`, `Record<string, any>` なども対象
- `// @ts-ignore`, `// @ts-expect-error` の使用も確認
- `as Type` による型アサーションを検出（`as const` は除外）
- ダブルアサーション（`as unknown as T`）を検出

**as が許容されるケース（例外）**:
- `as const` は常に許可（リテラル型への変換）
- テストコードでのモック（`.test.ts`, `.spec.ts` 内）
- DOM API の型絞り込み（条件付き、コメント必須）
- 外部ライブラリの型不備（条件付き、コメント必須）

**修正提案**:
- `unknown` への置き換え
- ジェネリクス型の使用
- 適切な型定義の作成
- 型ガードの使用
- `satisfies` 演算子の使用（TypeScript 4.9+）
- バリデーションライブラリ（Zod など）の使用

### 2. 必ずCIで品質チェックを行うようにする

**目的**: コード品質を自動的に担保し、チーム全体の開発効率を向上

**チェック内容**:
- `.github/workflows/` または `.gitlab-ci.yml` などのCI設定ファイルの存在確認
- CI設定内での品質チェック実行の確認（lint, test, type-check など）
- プルリクエスト/マージリクエストでの必須チェックの設定確認

**推奨される品質チェック**:
- リント（ESLint, Prettier など）
- テスト実行（Jest, Vitest など）
- 型チェック（TypeScript）
- ビルドの成功確認

### 3. デプロイ前にローカルで実行して動作確認できるようにする

**目的**: 本番環境への影響を最小限にし、デプロイの安全性を向上

**チェック内容**:
- `package.json` の `scripts` セクションでのローカル実行スクリプトの確認
  - `dev`, `start`, `serve` などの開発サーバー起動コマンド
  - `build` や `preview` などのビルド・プレビューコマンド
- Docker Compose や devcontainer などのローカル実行環境設定の確認
- README.md でのローカル実行手順の記載確認

**推奨される設定**:
- `npm run dev` または `yarn dev` でローカル開発サーバーを起動できる
- `npm run build && npm run preview` で本番ビルドをローカルで確認できる
- ドキュメントにローカル実行手順が明記されている

### 4. 原則としてconventional commitを採用する

**目的**: コミット履歴を整理し、変更履歴の理解とリリースノート生成を容易にする

**チェック内容**:
- 直近のコミットメッセージが Conventional Commit 形式に従っているか確認
- プレフィックス（`feat:`, `fix:`, `docs:`, `chore:` など）の使用確認
- コミットメッセージの構造確認（type, scope, description）

**Conventional Commit の形式**:
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**主な type**:
- `feat`: 新機能の追加
- `fix`: バグ修正
- `docs`: ドキュメントのみの変更
- `style`: コードの動作に影響しない変更（フォーマット、セミコロンなど）
- `refactor`: バグ修正や機能追加を含まないコード変更
- `perf`: パフォーマンス改善
- `test`: テストの追加や修正
- `chore`: ビルドプロセスやツールの変更

### 5. 依存ライブラリのバージョンは固定する

**目的**: 再現性を確保し、予期しないバージョンアップによる問題を防止

**チェック内容**:
- `package.json` での依存関係のバージョン指定方法の確認
  - `^` (キャレット) や `~` (チルダ) を使用していないか
  - 具体的なバージョン番号が指定されているか
- `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml` などのロックファイルの存在確認
- `Dockerfile` や他の設定ファイルでのバージョン固定確認

**推奨される設定**:
```json
{
  "dependencies": {
    "react": "18.2.0",      // ✅ 固定バージョン
    "vue": "^3.3.4"         // ❌ キャレットは非推奨
  }
}
```

### 6. 必ずユニットテストを追加すること

**目的**: テスト可能な設計を促進し、コード品質とメンテナンス性を担保する

**チェック内容**:
- プロダクションコードに対応するテストファイルの存在確認
  - `.test.ts`, `.spec.ts`, `.test.tsx`, `.spec.tsx` などの命名規則
  - テストファイルがプロダクションコードと同じディレクトリまたは `__tests__/` ディレクトリに配置されているか
- テストフレームワークの設定確認（Jest, Vitest, Mocha など）
- テストカバレッジ設定の確認
- ユニットテストの定義準拠（外部サービスやシステムに依存しないテストか）
  - ❌ データベース接続を必要とするテストはユニットテストとして扱わない
  - ❌ 外部APIを呼び出すテストはユニットテストとして扱わない
  - ❌ ファイルシステムへの実際の読み書きに依存するテストはユニットテストとして扱わない
  - ✅ モックやスタブを使用して依存関係を分離したテスト

**修正提案**:
- 不足しているテストファイルの追加（テストカバレッジの向上）
- テスト可能な設計への改善:
  - 依存性注入（DI）の活用により外部依存を分離
  - Pure Functionの使用で副作用を最小化
  - モック可能なインターフェースの設計
  - 責務の分離（Single Responsibility Principle）
- テストフレームワーク（Jest, Vitest など）とモックライブラリの設定
- 重い統合テストやE2Eテストは別ディレクトリ（`integration-tests/`, `e2e/` など）に分離

**推奨されるテスト構造**:
```
src/
  utils/
    api.ts               # プロダクションコード
    api.test.ts          # ユニットテスト（モック使用）
  components/
    Button.tsx
    Button.test.tsx      # ユニットテスト
integration-tests/       # 統合テスト（DB, 外部APIなど）
  api.integration.test.ts
e2e/                     # E2Eテスト
  user-flow.spec.ts
```

**ユニットテストの良い例**:
```typescript
// ✅ 依存性注入とモックを使用したユニットテスト
import { fetchUserData } from './api';
import { httpClient } from './httpClient';

jest.mock('./httpClient');

test('fetchUserData should return user data', async () => {
  // モックを設定
  (httpClient.get as jest.Mock).mockResolvedValue({ id: 1, name: 'Test' });

  const result = await fetchUserData(1);

  expect(result).toEqual({ id: 1, name: 'Test' });
});
```

**ユニットテストの悪い例**:
```typescript
// ❌ 実際のデータベースに接続（統合テスト）
test('should save user to database', async () => {
  const db = new Database('postgresql://...');  // 実際のDB接続
  await db.connect();

  const user = await saveUser({ name: 'Test' });

  expect(user.id).toBeDefined();
  await db.disconnect();
});

// ❌ 実際の外部APIを呼び出し（統合テスト）
test('should fetch data from real API', async () => {
  const response = await fetch('https://api.example.com/data');  // 実際のAPI呼び出し
  const data = await response.json();

  expect(data).toBeDefined();
});
```

### 7. コミット前にlint, format, testを実行

**目的**: コード品質を保ち、コミット後にCIで失敗することを防ぐ

**チェック内容**:
- pre-commitフック（`.husky/pre-commit`, `.git/hooks/pre-commit` など）の存在確認
- package.jsonでのpre-commitツール設定確認（husky, lint-staged など）
- pre-commitで実行されるスクリプトの確認
  - リント実行（eslint, prettier など）
  - フォーマット実行（prettier --write など）
  - テスト実行（jest, vitest など）
- lint-stagedの設定確認（ステージされたファイルのみ処理）

**推奨される設定**:

**huskyとlint-stagedを使用した例**:
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
    "*.{ts,tsx,js,jsx}": [
      "eslint --fix",
      "prettier --write",
      "jest --bail --findRelatedTests"
    ],
    "*.{json,md,css}": [
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

**pre-commit（Python）を使用した例**:
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
  - repo: local
    hooks:
      - id: eslint
        name: eslint
        entry: npm run lint
        language: system
        types: [javascript, typescript]
      - id: prettier
        name: prettier
        entry: npm run format
        language: system
        types: [javascript, typescript, json, markdown]
      - id: test
        name: test
        entry: npm test
        language: system
        pass_filenames: false
```

**修正提案**:
- huskyとlint-stagedのインストールと設定追加
- pre-commitフックスクリプトの作成
- package.jsonへのprepareスクリプト追加
- lint-staged設定でステージされたファイルのみを処理するように設定
- 高速化のため、テストは変更されたファイルに関連するもののみ実行（`--findRelatedTests`）

**ベストプラクティス**:
- ✅ lint-stagedでステージされたファイルのみ処理（高速化）
- ✅ テストは関連ファイルのみ実行（`--findRelatedTests`, `--bail`で高速化）
- ✅ formatは自動修正（`--fix`, `--write`）を有効化
- ✅ pre-commitが失敗した場合はコミットを中止
- ❌ pre-commitで全ファイルをチェックしない（遅すぎる）
- ❌ pre-commitで重い統合テストやE2Eテストを実行しない（CIで実行）

## レポート出力フォーマット

チェック実行後、以下の形式でレポートを出力します：

```markdown
# 開発ルール遵守チェックレポート

## チェック結果サマリー
- ✅ 合格: 4項目
- ⚠️ 警告: 1項目
- ❌ 不合格: 2項目

## 詳細

### ❌ 1. TypeScriptにおいてanyとasは極力使わない
**ステータス**: 不合格
**違反箇所**: 5件

#### any の使用
- `src/utils/api.ts:15` - `any` の使用を検出
- `src/components/Form.tsx:42` - `Record<string, any>` の使用を検出
- `src/hooks/useData.ts:8` - `Promise<any>` の使用を検出

#### as の使用
- `src/services/auth.ts:23` - `as User` の使用を検出
- `src/utils/parser.ts:31` - `as unknown as Config` のダブルアサーションを検出

**修正提案**:
- `src/utils/api.ts:15` - `unknown` または適切な型定義を使用してください
- `src/components/Form.tsx:42` - `Record<string, FormValue>` のような具体的な型を使用してください
- `src/hooks/useData.ts:8` - 戻り値の型を明示的に定義してください
- `src/services/auth.ts:23` - 型ガード関数を作成し、`if` チェックで型を絞り込んでください
- `src/utils/parser.ts:31` - Zod などのバリデーションライブラリを使用するか、`satisfies` 演算子を検討してください

### ✅ 2. 必ずCIで品質チェックを行うようにする
**ステータス**: 合格
- `.github/workflows/ci.yml` が存在し、lint, test, type-check が設定されています

### ⚠️ 3. デプロイ前にローカルで実行して動作確認できるようにする
**ステータス**: 警告
- `package.json` に `dev` スクリプトは存在しますが、README.md にローカル実行手順の記載がありません

**推奨事項**:
- README.md にローカル実行手順を追加してください

### ✅ 4. 原則としてconventional commitを採用する
**ステータス**: 合格
- 直近10件のコミットがすべて Conventional Commit 形式に従っています

### ✅ 5. 依存ライブラリのバージョンは固定する
**ステータス**: 合格
- `package.json` で全ての依存関係が固定バージョンで指定されています
- `package-lock.json` が存在します

### ❌ 6. 必ずユニットテストを追加すること
**ステータス**: 不合格
**違反箇所**: 5件

- `src/utils/api.ts` - 対応するテストファイルが存在しません
- `src/utils/validation.ts` - 対応するテストファイルが存在しません
- `src/components/Form.tsx` - 対応するテストファイルが存在しません
- `src/hooks/useData.ts` - テストが統合テストになっています（実際のAPIを呼び出し）
- テストカバレッジの設定がありません

**修正提案**:
- 各プロダクションコードに対応するテストファイルを追加してください
  - `src/utils/api.test.ts`, `src/utils/validation.test.ts`, `src/components/Form.test.tsx` など
- 外部依存を持つコードはモックを使用したユニットテストに変更してください
- テストフレームワーク（Jest, Vitest など）のカバレッジ設定を追加してください
- 統合テストは `integration-tests/` ディレクトリに移動してください

### ❌ 7. コミット前にlint, format, testを実行
**ステータス**: 不合格
**問題点**: pre-commitフックが設定されていません

**不足している設定**:
- huskyまたはpre-commitツールがインストールされていません
- `.husky/pre-commit` または `.git/hooks/pre-commit` が存在しません
- `package.json` に lint-staged の設定がありません

**修正提案**:
- huskyとlint-stagedをインストール: `npm install --save-dev husky lint-staged`
- huskyを初期化: `npx husky install`
- pre-commitフックを作成: `npx husky add .husky/pre-commit "npx lint-staged"`
- `package.json` に lint-staged 設定を追加:
  ```json
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": [
      "eslint --fix",
      "prettier --write",
      "jest --bail --findRelatedTests"
    ]
  }
  ```
```

## 自動修正モード (`--fix`)

`--fix` オプションを指定すると、自動修正可能な違反について具体的な修正内容を提案します。

**自動修正可能な項目**:

1. **TypeScriptのany・as使用**
   - 文脈に応じて `unknown`、ジェネリクス、適切な型定義への置き換えを提案
   - `as Type` は型ガード関数、`satisfies` 演算子、バリデーションライブラリへの置き換えを提案

2. **依存関係のバージョン固定**
   - `^` や `~` を削除した固定バージョンへの変更を提案

3. **CI設定の追加**
   - 基本的なCI設定ファイルのテンプレートを提案

4. **pre-commit設定の追加**
   - huskyとlint-stagedのインストールコマンドを提案
   - `.husky/pre-commit` スクリプトの作成を提案
   - `package.json` への lint-staged 設定追加を提案

**自動修正の実行例**:

```bash
/dev-standards --fix
```

修正提案を確認後、ユーザーの承認を得てから実際の修正を適用します。

## 実装の流れ

1. **プロジェクト構造の分析**
   - `package.json`, `tsconfig.json`, `.github/workflows/`, `README.md` などの存在確認
   - プロジェクトタイプの判定（Node.js, TypeScript, フレームワークなど）

2. **各ルールのチェック実行**
   - ファイル検索（Glob）とコンテンツ検索（Grep）を使用
   - 設定ファイルの読み込みと解析（Read）
   - Git履歴の確認（Bash + git log）

3. **結果の集約とレポート生成**
   - 各ルールのチェック結果を統合
   - 優先度に基づいた並び替え
   - マークダウン形式でのレポート作成

4. **修正提案の生成（`--fix`時）**
   - 自動修正可能な項目の抽出
   - 具体的な修正内容の生成
   - ユーザーへの確認と適用

## 補足資料

より詳細なルールとベストプラクティスについては、以下のリファレンスを参照してください：

- [TypeScript ルール詳細（any・as使用制限）](./references/typescript-rules.md)
- [Conventional Commit 規約詳細](./references/commit-conventions.md)
- [ユニットテスト ルール詳細](./references/unit-test-rules.md)
- [Pre-commit フック設定詳細](./references/pre-commit-rules.md)

## 使用タイミング

このスキルは以下のタイミングで使用することを推奨します：

1. **コード作成・編集後**: 新しいコードが開発ルールに準拠しているか確認
2. **コミット前**: コミットメッセージとコード変更の両方をチェック
3. **プルリクエスト作成前**: レビュー前に全体的な品質を確認
4. **定期的なプロジェクトレビュー**: プロジェクト全体の健全性を定期的にチェック
5. **新メンバーのオンボーディング**: 開発ルールの教育と実践

## 注意事項

- このスキルはルール違反を検出しますが、最終的な判断はプロジェクトの状況に応じて行ってください
- プロジェクト固有のルールや例外がある場合は、適宜調整してください
- 自動修正は提案であり、実際の適用前にレビューすることを推奨します
