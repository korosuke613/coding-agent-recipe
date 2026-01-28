# TypeScript ルール詳細: any と as の使用制限

## なぜ any を使わないのか

`any` 型の使用は TypeScript の型システムを無効化し、以下の問題を引き起こします：

1. **型安全性の喪失**: コンパイル時の型チェックが機能せず、ランタイムエラーの原因となる
2. **IDE サポートの低下**: 自動補完やリファクタリング機能が効かなくなる
3. **保守性の低下**: コードの意図が不明確になり、他の開発者が理解しにくくなる
4. **バグの増加**: 型による保護がなくなり、予期しないバグが発生しやすくなる

## なぜ as を極力使わないのか

`as` による型アサーションは、コンパイラの型チェックを無視して強制的に型を指定する機能であり、以下の問題を引き起こします：

1. **型安全性の喪失**: コンパイラの型チェックを無視し、実行時エラーの原因となる
2. **リファクタリング耐性の低下**: 型が変更されても `as` 部分は自動的に検出されない
3. **潜在的なバグの隠蔽**: 型の不整合が見えにくくなる
4. **コードの意図が不明確**: なぜ型アサーションが必要なのかが分かりにくい

### as が許容されるケース（例外）

| ケース | 許容度 | 条件 |
|--------|--------|------|
| `as const` | 推奨 | 常に許可（リテラル型への変換） |
| テストコードでのモック | 許可 | `.test.ts`, `.spec.ts` ファイル内のみ |
| DOM API の型絞り込み | 条件付き | 型ガードが使えない場合のみ |
| 外部ライブラリの型不備 | 条件付き | コメントで理由を明記 |
| 型推論の限界 | 条件付き | コメントで理由を明記 |
| `as any` | 禁止 | 例外なし |
| ダブルアサーション (`as unknown as T`) | 禁止 | 例外なし（テストコード除く） |

## any を検出するパターン

### 基本的な any の使用

```typescript
// ❌ 悪い例
const data: any = fetchData();
function process(input: any): any {
  return input;
}
let value: any;
```

### 複合型での any

```typescript
// ❌ 悪い例
const items: any[] = [];
const promise: Promise<any> = fetch('/api');
const record: Record<string, any> = {};
const map: Map<string, any> = new Map();
const callback: (data: any) => void = () => {};
```

### 型アサーションと型ガード

```typescript
// ❌ 悪い例
const data = response as any;
// @ts-ignore
const value = obj.property;
// @ts-expect-error
const result = dangerousOperation();
```

## as を検出するパターン

### 基本的な as Type の使用

```typescript
// ❌ 悪い例
const user = response as User;
const data = JSON.parse(str) as Config;
const element = document.getElementById('app') as HTMLDivElement;
```

### ダブルアサーション

```typescript
// ❌ 特に危険な例
const data = response as unknown as User;
const value = obj as any as SpecificType;
```

### 許容される as の使用

```typescript
// ✅ as const は推奨
const colors = ['red', 'green', 'blue'] as const;
const config = { mode: 'production' } as const;

// ✅ テストコードでのモック（.test.ts, .spec.ts 内）
const mockService = {
  fetch: jest.fn()
} as unknown as ApiService;

// ⚠️ DOM API（条件付き許容）
// 型ガードが使えない場合のみ、コメントで理由を明記
const element = document.getElementById('app') as HTMLDivElement; // getElementById は null を返す可能性がある

// ⚠️ 外部ライブラリの型不備（条件付き許容）
// FIXME: ライブラリの型定義が不完全なため一時的に as を使用
const result = externalLib.call() as ExpectedType;
```

## Grep パターン

以下のパターンで any の使用を検出できます：

```bash
# 基本的な any の検出
grep -r ": any\b" --include="*.ts" --include="*.tsx"

# any[] の検出
grep -r ": any\[\]" --include="*.ts" --include="*.tsx"

# Promise<any> の検出
grep -r "Promise<any>" --include="*.ts" --include="*.tsx"

# Record<string, any> の検出
grep -r "Record<[^,]+, any>" --include="*.ts" --include="*.tsx"

# as any の検出
grep -r " as any" --include="*.ts" --include="*.tsx"

# @ts-ignore と @ts-expect-error の検出
grep -r "@ts-ignore\|@ts-expect-error" --include="*.ts" --include="*.tsx"
```

以下のパターンで as Type の使用を検出できます：

```bash
# 基本的な as Type の検出（as const を除外）
grep -r " as [A-Z][a-zA-Z]*" --include="*.ts" --include="*.tsx" | grep -v " as const"

# ダブルアサーションの検出
grep -r " as unknown as \| as any as " --include="*.ts" --include="*.tsx"

# テストファイルを除外して as を検出
grep -r " as [A-Z][a-zA-Z]*" --include="*.ts" --include="*.tsx" | grep -v ".test.ts\|.spec.ts\|__tests__"
```

Grep ツールを使用する場合：

```typescript
// any 検出用 pattern パラメータの例
"(: any\\b|: any\\[\\]|Promise<any>|Record<[^,]+, any>| as any|@ts-ignore|@ts-expect-error)"

// as Type 検出用 pattern パラメータの例（as const を除外）
" as (?!const\\b)[A-Z][a-zA-Z]+"

// ダブルアサーション検出用 pattern パラメータの例
" as (unknown|any) as "
```

## any の代替パターン

### 1. unknown を使用する

`unknown` は型安全な「不明な型」で、使用前に型のチェックが必要です。

```typescript
// ✅ 良い例
function processData(data: unknown) {
  // 型ガードで安全に使用
  if (typeof data === 'string') {
    console.log(data.toUpperCase());
  } else if (typeof data === 'object' && data !== null) {
    console.log(Object.keys(data));
  }
}

// API レスポンスの処理
async function fetchData(): Promise<unknown> {
  const response = await fetch('/api/data');
  return response.json();
}

const data = await fetchData();
// 型ガードで検証してから使用
if (isValidData(data)) {
  console.log(data.name); // ここでは型が確定している
}
```

### 2. ジェネリクスを使用する

型を引数として受け取ることで、型安全性を保ちながら柔軟な実装が可能です。

```typescript
// ✅ 良い例
function identity<T>(value: T): T {
  return value;
}

function processArray<T>(items: T[]): T[] {
  return items.map(item => item);
}

// API レスポンス処理
async function fetchApi<T>(url: string): Promise<T> {
  const response = await fetch(url);
  return response.json() as T;
}

interface User {
  id: number;
  name: string;
}

const user = await fetchApi<User>('/api/user');
console.log(user.name); // 型安全
```

### 3. 適切な型定義を作成する

複雑なデータ構造には明示的な型定義を作成します。

```typescript
// ✅ 良い例
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}

interface UserData {
  id: number;
  name: string;
  email: string;
  roles: string[];
}

async function fetchUser(id: number): Promise<ApiResponse<UserData>> {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}

// オブジェクトのキーと値の型を明示
interface FormValues {
  username: string;
  email: string;
  age: number;
}

const formData: FormValues = {
  username: 'john',
  email: 'john@example.com',
  age: 30
};
```

### 4. 型ガードを使用する

ランタイムで型を確認し、型安全な処理を行います。

```typescript
// ✅ 良い例
interface Dog {
  type: 'dog';
  bark: () => void;
}

interface Cat {
  type: 'cat';
  meow: () => void;
}

type Animal = Dog | Cat;

// 型ガード関数
function isDog(animal: Animal): animal is Dog {
  return animal.type === 'dog';
}

function makeSound(animal: Animal) {
  if (isDog(animal)) {
    animal.bark(); // Dog として扱える
  } else {
    animal.meow(); // Cat として扱える
  }
}

// instanceof を使った型ガード
function processValue(value: unknown) {
  if (value instanceof Date) {
    console.log(value.toISOString());
  } else if (value instanceof Error) {
    console.error(value.message);
  }
}
```

### 5. ユーティリティ型を活用する

TypeScript 組み込みのユーティリティ型を使用します。

```typescript
// ✅ 良い例
interface User {
  id: number;
  name: string;
  email: string;
  password: string;
}

// 一部のプロパティのみ
type UserProfile = Pick<User, 'id' | 'name' | 'email'>;

// 一部のプロパティを除外
type SafeUser = Omit<User, 'password'>;

// すべてのプロパティをオプショナルに
type PartialUser = Partial<User>;

// すべてのプロパティを読み取り専用に
type ReadonlyUser = Readonly<User>;

// オブジェクトの型を動的に定義
type UserRecord = Record<string, User>;
```

### 6. 型アサーション（as）は極力使用しない

`as` を使わずに型安全性を確保する方法を優先します。

#### 代替パターン一覧

| 現在のパターン | 推奨される代替 |
|----------------|----------------|
| `response as User` | 型ガード関数 + `if` チェック |
| `JSON.parse(str) as Config` | Zod/io-ts などのバリデーションライブラリ |
| `obj as Config` | `satisfies` 演算子（TypeScript 4.9+） |
| `fetch().json() as T` | ジェネリクス関数 `fetchJson<T>()` |
| `value as unknown as T` | 型ガード + 段階的な型絞り込み |

#### 型ガード関数で置き換える

```typescript
// ❌ 悪い例
const data = response as ApiData;

// ✅ 良い例：型ガードで安全に型を絞り込む
interface ApiData {
  id: number;
  name: string;
}

function isApiData(value: unknown): value is ApiData {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value &&
    typeof (value as ApiData).id === 'number' &&
    typeof (value as ApiData).name === 'string'
  );
}

const response: unknown = await fetch('/api').then(r => r.json());
if (isApiData(response)) {
  console.log(response.name); // 型安全
}
```

#### satisfies 演算子を使用する（TypeScript 4.9+）

```typescript
// ❌ 悪い例
const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000
} as Config;

// ✅ 良い例：satisfies で型チェックしつつリテラル型を保持
interface Config {
  apiUrl: string;
  timeout: number;
}

const config = {
  apiUrl: 'https://api.example.com',
  timeout: 5000
} satisfies Config;

// satisfies の利点：型チェックされつつ、リテラル型が保持される
config.apiUrl; // 型は 'https://api.example.com'（リテラル型）
```

#### バリデーションライブラリを使用する

```typescript
// ❌ 悪い例
const data = JSON.parse(str) as Config;

// ✅ 良い例：Zod でランタイム検証
import { z } from 'zod';

const ConfigSchema = z.object({
  apiUrl: z.string().url(),
  timeout: z.number().positive()
});

type Config = z.infer<typeof ConfigSchema>;

const data = ConfigSchema.parse(JSON.parse(str)); // 実行時にも型チェック
```

#### ジェネリクス関数を使用する

```typescript
// ❌ 悪い例
const user = await fetch('/api/user').then(r => r.json()) as User;

// ✅ 良い例：型安全な fetch ヘルパー関数
async function fetchJson<T>(
  url: string,
  validator: (data: unknown) => data is T
): Promise<T> {
  const response = await fetch(url);
  const data: unknown = await response.json();
  if (!validator(data)) {
    throw new Error('Invalid data format');
  }
  return data;
}

const user = await fetchJson('/api/user', isUser);
```

## 特殊なケース

### サードパーティライブラリの型がない場合

型定義ファイルを作成します。

```typescript
// types/external-library.d.ts
declare module 'external-library' {
  export interface Config {
    apiKey: string;
    timeout: number;
  }

  export function initialize(config: Config): void;
  export function fetchData(url: string): Promise<unknown>;
}
```

### 動的な JSON データの処理

Zod や io-ts などのランタイム型検証ライブラリを使用します。

```typescript
// ✅ 良い例（Zod を使用）
import { z } from 'zod';

const UserSchema = z.object({
  id: z.number(),
  name: z.string(),
  email: z.string().email(),
  roles: z.array(z.string())
});

type User = z.infer<typeof UserSchema>;

async function fetchUser(id: number): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  const data: unknown = await response.json();

  // ランタイムで型を検証
  return UserSchema.parse(data);
}
```

### イベントハンドラーの型

適切なイベント型を使用します。

```typescript
// ❌ 悪い例
function handleClick(event: any) {
  console.log(event.target.value);
}

// ✅ 良い例
function handleClick(event: React.MouseEvent<HTMLButtonElement>) {
  console.log(event.currentTarget.value);
}

function handleInputChange(event: React.ChangeEvent<HTMLInputElement>) {
  console.log(event.target.value);
}

function handleFormSubmit(event: React.FormEvent<HTMLFormElement>) {
  event.preventDefault();
  // フォーム処理
}
```

## 段階的な移行戦略

既存のコードベースで any を削減する場合：

1. **新規コードでは any を使わない**: まず新しく書くコードから徹底する
2. **型定義から始める**: インターフェースや型エイリアスを定義する
3. **境界から内側へ**: API の入出力など、境界部分から型を厳密にする
4. **小さな単位で修正**: ファイル単位、関数単位で少しずつ修正する
5. **テストを活用**: 型変更後の動作をテストで確認する

## ESLint ルール

`@typescript-eslint` を使用して any と as の使用を防止できます。

```json
{
  "rules": {
    // any 禁止ルール
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unsafe-assignment": "error",
    "@typescript-eslint/no-unsafe-member-access": "error",
    "@typescript-eslint/no-unsafe-call": "error",
    "@typescript-eslint/no-unsafe-return": "error",

    // as 使用制限ルール
    "@typescript-eslint/consistent-type-assertions": [
      "error",
      {
        "assertionStyle": "never"
      }
    ]
  }
}
```

### consistent-type-assertions ルールのオプション

`as` を完全に禁止せず、段階的に導入する場合：

```json
{
  "rules": {
    "@typescript-eslint/consistent-type-assertions": [
      "error",
      {
        "assertionStyle": "as",
        "objectLiteralTypeAssertions": "never"
      }
    ]
  }
}
```

テストファイルでは `as` を許可する場合（.eslintrc.js）：

```javascript
module.exports = {
  overrides: [
    {
      files: ['**/*.test.ts', '**/*.spec.ts', '**/__tests__/**/*.ts'],
      rules: {
        '@typescript-eslint/consistent-type-assertions': 'off'
      }
    }
  ]
};
```

## まとめ

- `any` は型安全性を失わせる最も危険なパターン
- `as` はコンパイラの型チェックを無視するため、極力使用を避ける
- `unknown` を使い、型ガードで安全に処理する
- `satisfies` 演算子で型チェックしつつリテラル型を保持する
- ジェネリクスで型を引数として扱う
- 適切な型定義を作成し、型の恩恵を最大限に活用する
- バリデーションライブラリ（Zod など）でランタイム検証を行う
- ツール（ESLint, Zod など）を活用して、型安全なコードを維持する
- `as const` は推奨、テストコードでの `as` は許容
