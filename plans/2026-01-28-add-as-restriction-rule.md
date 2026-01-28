# dev-standards TypeScript ルール拡張: 「as を極力使わない」

## 概要

dev-standards プラグインの TypeScript ルール（Rule #1）を拡張し、「極力 `as` を使わない」というルールを追加する。

## 推奨アプローチ: 既存の Rule #1 を拡張

**理由:**
- `any` 禁止と `as` 禁止は同じ「型安全性の確保」という目的を持つ
- `as any` は既に Rule #1 で検出対象になっており、`as Type` はその延長
- 独立したルールにすると重複が生じ、`--typescript` オプションで両方チェックできる利点を活かせる

## 修正対象ファイル

### 1. `claude-plugins/dev-standards/skills/dev-standards/SKILL.md`

変更内容:
- ルール名を「TypeScriptにおいてanyは使わない」→「TypeScriptにおいてanyとasは極力使わない」に変更
- description（3行目）に「as禁止」を追加
- チェック内容に `as Type` 検出を追加
- 修正提案に `satisfies` 演算子や型ガードの使用を追加
- 新オプション `--type-assertion` を追加
- レポート出力例に `as` 違反の例を追加
- 補足資料のリンクテキストを更新

### 2. `claude-plugins/dev-standards/skills/dev-standards/references/typescript-rules.md`

変更内容:
- タイトルを「any 禁止」→「any と as の使用制限」に変更
- 「なぜ as を極力使わないのか」セクションを追加
- `as` の検出パターン（Grep 用）を追加
- 許容されるケース（例外）セクションを追加
  - `as const` は推奨
  - テストコードでのモック作成は許容
  - DOM API での型絞り込みは条件付き許容
  - 外部ライブラリの型不備時は条件付き許容
- `as` の代替パターンセクションを追加
  - 型ガード関数
  - Zod などのバリデーションライブラリ
  - `satisfies` 演算子（TypeScript 4.9+）
  - ジェネリクス
  - オーバーロードシグネチャ
- ESLint ルール設定に `@typescript-eslint/consistent-type-assertions` を追加

## as が許容されるケース（例外）

| ケース | 許容度 | 条件 |
|--------|--------|------|
| `as const` | 推奨 | 常に許可 |
| テストコードでのモック | 許可 | `.test.ts`, `.spec.ts` ファイル内のみ |
| DOM API の型絞り込み | 条件付き | 型ガードが使えない場合のみ |
| 外部ライブラリの型不備 | 条件付き | コメントで理由を明記 |
| 型推論の限界 | 条件付き | コメントで理由を明記 |
| `as any` | 禁止 | 例外なし |
| ダブルアサーション | 禁止 | 例外なし（テストコード除く） |

## as を避けるべき理由

1. **型安全性の喪失**: コンパイラの型チェックを無視し、実行時エラーの原因となる
2. **リファクタリング耐性の低下**: 型が変更されても `as` 部分は自動的に検出されない
3. **潜在的なバグの隠蔽**: 型の不整合が見えにくくなる
4. **コードの意図が不明確**: なぜ型アサーションが必要なのかが分かりにくい

## 検出パターン（Grep 用）

```typescript
// 基本的な as Type の検出（as const を除外）
pattern: " as (?!const\\b)[A-Z][a-zA-Z]+"
glob: "*.ts,*.tsx"

// ダブルアサーションの検出
pattern: " as (unknown|any) as "

// テストファイルは除外
exclude: "*.test.ts, *.spec.ts, __tests__/**"
```

## 代替方法の提案

| 現在のパターン | 推奨される代替 |
|----------------|----------------|
| `response as User` | 型ガード関数 + `if` チェック |
| `JSON.parse(str) as Config` | Zod/io-ts などのバリデーションライブラリ |
| `obj as Config` | `satisfies` 演算子（TypeScript 4.9+） |
| `fetch().json() as T` | ジェネリクス関数 `fetchJson<T>()` |
| `value as unknown as T` | 型ガード + 段階的な型絞り込み |

## 実装順序

1. `typescript-rules.md` を更新（詳細リファレンス）
2. `SKILL.md` を更新（ルール定義、オプション、レポート例）

## 検証方法

1. `/dev-standards --typescript` を実行して、`as` 使用が検出されることを確認
2. `as const` が警告されないことを確認
3. レポート出力が正しいフォーマットで表示されることを確認
