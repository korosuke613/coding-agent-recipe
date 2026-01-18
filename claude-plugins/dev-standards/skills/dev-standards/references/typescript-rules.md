# TypeScript ルール詳細: any 禁止

## なぜ any を使わないのか

`any` 型の使用は TypeScript の型システムを無効化し、以下の問題を引き起こします：

1. **型安全性の喪失**: コンパイル時の型チェックが機能せず、ランタイムエラーの原因となる
2. **IDE サポートの低下**: 自動補完やリファクタリング機能が効かなくなる
3. **保守性の低下**: コードの意図が不明確になり、他の開発者が理解しにくくなる
4. **バグの増加**: 型による保護がなくなり、予期しないバグが発生しやすくなる

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

Grep ツールを使用する場合：

```typescript
// pattern パラメータの例
"(: any\\b|: any\\[\\]|Promise<any>|Record<[^,]+, any>| as any|@ts-ignore|@ts-expect-error)"
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

### 6. 型アサーションは慎重に使用する

`as` を使う場合は、型を明示的に指定します。

```typescript
// ❌ 悪い例
const data = response as any;

// ✅ 良い例
interface ApiData {
  id: number;
  name: string;
}

const data = response as ApiData;

// さらに良い例：型ガードと組み合わせる
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

`eslint-plugin-typescript` を使用して any の使用を防止できます。

```json
{
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/no-unsafe-assignment": "error",
    "@typescript-eslint/no-unsafe-member-access": "error",
    "@typescript-eslint/no-unsafe-call": "error",
    "@typescript-eslint/no-unsafe-return": "error"
  }
}
```

## まとめ

- `any` は型安全性を失わせる最も危険なパターン
- `unknown` を使い、型ガードで安全に処理する
- ジェネリクスで型を引数として扱う
- 適切な型定義を作成し、型の恩恵を最大限に活用する
- ツール（ESLint, Zod など）を活用して、型安全なコードを維持する
