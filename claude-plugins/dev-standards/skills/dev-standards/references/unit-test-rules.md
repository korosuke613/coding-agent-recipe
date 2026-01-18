# ユニットテスト ルール詳細

## なぜユニットテストが必要なのか

ユニットテストは以下の重要な価値を提供します：

1. **バグの早期発見**: コードを書いた直後に不具合を検出できる
2. **リファクタリングの安全性**: 既存機能を壊さずにコードを改善できる
3. **設計の改善**: テストしやすいコードは良い設計になる傾向がある
4. **ドキュメントとしての役割**: テストコードは実際の使用例を示す生きたドキュメント
5. **開発速度の向上**: 自動テストにより手動確認が不要になる
6. **信頼性の向上**: 変更時の影響範囲が把握しやすく、安心してデプロイできる

## ユニットテストの定義

ユニットテストは以下の特徴を持つテストです：

### ✅ ユニットテストの条件

- **高速**: 数ミリ秒〜数秒で実行完了する
- **独立**: 他のテストに依存せず、単独で実行可能
- **反復可能**: 何度実行しても同じ結果が得られる
- **自己検証**: 自動的に成功/失敗を判定できる
- **タイムリー**: プロダクションコードと同時期に書かれる
- **外部依存なし**: データベース、ファイルシステム、ネットワーク、外部APIに依存しない

### ❌ ユニットテストではないもの

- データベースに接続するテスト → **統合テスト**
- 外部APIを呼び出すテスト → **統合テスト**
- 複数のモジュールを結合してテストするもの → **統合テスト**
- 実際のブラウザを起動するテスト → **E2Eテスト**
- ファイルシステムに読み書きするテスト → **統合テスト**（一部例外あり）

## ユニットテストと統合テストの違い

| 項目 | ユニットテスト | 統合テスト |
|------|---------------|-----------|
| **対象** | 単一の関数・クラス・モジュール | 複数のモジュールの連携 |
| **依存関係** | モック・スタブで置き換え | 実際の依存関係を使用 |
| **実行速度** | 高速（数ms〜数秒） | 低速（数秒〜数分） |
| **外部リソース** | 使用しない | 使用する（DB、API等） |
| **実行頻度** | 毎回のコミット前 | PRマージ前、デプロイ前 |
| **カバー範囲** | 個別ロジック | システム全体の動作 |

## テスト可能な設計

### 1. 依存性注入（Dependency Injection）

外部依存を引数やコンストラクタで受け取る設計にすることで、テスト時にモックを注入できます。

```typescript
// ❌ 悪い例: 依存関係が内部で作られる
class UserService {
  private api = new ApiClient();  // テスト時に置き換えられない

  async getUser(id: string) {
    return await this.api.get(`/users/${id}`);
  }
}

// ✅ 良い例: 依存性注入
class UserService {
  constructor(private api: ApiClient) {}  // テスト時にモックを注入可能

  async getUser(id: string) {
    return await this.api.get(`/users/${id}`);
  }
}

// テストコード
test('getUser should return user data', async () => {
  const mockApi = {
    get: jest.fn().mockResolvedValue({ id: '123', name: 'Test' })
  };
  const service = new UserService(mockApi as any);

  const user = await service.getUser('123');

  expect(user.name).toBe('Test');
});
```

### 2. Pure Function（純粋関数）

副作用を持たず、同じ入力に対して常に同じ出力を返す関数は、最もテストしやすいコードです。

```typescript
// ✅ 良い例: Pure Function
function calculateTax(price: number, rate: number): number {
  return price * rate;
}

test('calculateTax should return correct tax amount', () => {
  expect(calculateTax(1000, 0.1)).toBe(100);
  expect(calculateTax(2000, 0.08)).toBe(160);
});

// ❌ 悪い例: 副作用あり
let totalTax = 0;
function calculateTax(price: number, rate: number): number {
  totalTax += price * rate;  // 外部状態を変更（副作用）
  return totalTax;
}
```

### 3. 単一責任の原則（Single Responsibility Principle）

1つの関数・クラスは1つの責務のみを持つようにします。これによりテストが簡潔になります。

```typescript
// ❌ 悪い例: 複数の責務を持つ
async function processUserRegistration(email: string, password: string) {
  // バリデーション
  if (!email.includes('@')) throw new Error('Invalid email');

  // パスワードハッシュ化
  const hashedPassword = await bcrypt.hash(password, 10);

  // データベース保存
  const db = new Database();
  await db.users.create({ email, password: hashedPassword });

  // メール送信
  const mailer = new Mailer();
  await mailer.send(email, 'Welcome!');
}

// ✅ 良い例: 責務を分離
function validateEmail(email: string): boolean {
  return email.includes('@');
}

async function hashPassword(password: string): Promise<string> {
  return bcrypt.hash(password, 10);
}

async function saveUser(userRepo: UserRepository, email: string, password: string) {
  return userRepo.create({ email, password });
}

async function sendWelcomeEmail(mailer: Mailer, email: string) {
  return mailer.send(email, 'Welcome!');
}

// 各関数を独立してテスト可能
test('validateEmail should return true for valid email', () => {
  expect(validateEmail('test@example.com')).toBe(true);
  expect(validateEmail('invalid')).toBe(false);
});
```

### 4. インターフェースの活用

具象クラスではなくインターフェースに依存することで、テスト時に簡単にモックを作成できます。

```typescript
// インターフェース定義
interface Logger {
  log(message: string): void;
  error(message: string): void;
}

// ✅ 良い例: インターフェースに依存
class OrderService {
  constructor(private logger: Logger) {}

  async createOrder(order: Order) {
    this.logger.log('Creating order...');
    // ビジネスロジック
    this.logger.log('Order created');
  }
}

// テストコード
test('createOrder should log messages', async () => {
  const mockLogger: Logger = {
    log: jest.fn(),
    error: jest.fn()
  };
  const service = new OrderService(mockLogger);

  await service.createOrder({ id: '123' });

  expect(mockLogger.log).toHaveBeenCalledWith('Creating order...');
});
```

## モックとスタブの使い方

### モック（Mock）

呼び出しの検証が目的。関数が正しく呼ばれたかを確認します。

```typescript
test('should call API with correct parameters', async () => {
  const mockApi = {
    post: jest.fn().mockResolvedValue({ success: true })
  };
  const service = new UserService(mockApi);

  await service.createUser({ name: 'Test', email: 'test@example.com' });

  // モックが正しい引数で呼ばれたか検証
  expect(mockApi.post).toHaveBeenCalledWith('/users', {
    name: 'Test',
    email: 'test@example.com'
  });
});
```

### スタブ（Stub）

戻り値の制御が目的。依存関係の動作を固定します。

```typescript
test('should handle API response correctly', async () => {
  const stubApi = {
    get: jest.fn().mockResolvedValue({
      id: '123',
      name: 'John Doe',
      email: 'john@example.com'
    })
  };
  const service = new UserService(stubApi);

  const user = await service.getUser('123');

  // スタブが返す値を使ってビジネスロジックが正しく動作するか検証
  expect(user.name).toBe('John Doe');
  expect(user.email).toBe('john@example.com');
});
```

### テストダブルのベストプラクティス

```typescript
// ✅ 良い例: テストごとにモックをリセット
beforeEach(() => {
  jest.clearAllMocks();
});

test('test 1', () => {
  const mock = jest.fn().mockReturnValue('result1');
  // テスト
});

test('test 2', () => {
  const mock = jest.fn().mockReturnValue('result2');
  // 前のテストの影響を受けない
});

// ✅ 良い例: 特定のシナリオをテスト
test('should handle API error', async () => {
  const mockApi = {
    get: jest.fn().mockRejectedValue(new Error('Network error'))
  };
  const service = new UserService(mockApi);

  await expect(service.getUser('123')).rejects.toThrow('Network error');
});
```

## テストカバレッジ

### カバレッジ設定の推奨

```json
// jest.config.js または vitest.config.ts
{
  "collectCoverage": true,
  "coverageReporters": ["text", "lcov", "html"],
  "coverageThresholds": {
    "global": {
      "branches": 80,
      "functions": 80,
      "lines": 80,
      "statements": 80
    }
  },
  "collectCoverageFrom": [
    "src/**/*.{ts,tsx}",
    "!src/**/*.test.{ts,tsx}",
    "!src/**/*.spec.{ts,tsx}",
    "!src/**/*.d.ts"
  ]
}
```

### カバレッジの注意点

- **100%を目指す必要はない**: 重要なビジネスロジックを優先
- **カバレッジは手段であり目的ではない**: 質の高いテストが重要
- **テストしにくいコードは設計を見直す**: カバレッジのためだけに無理にテストを書かない

## チェックパターン

### テストファイルの命名規則

ユニットテストファイルは以下の命名規則に従います：

- `*.test.ts` - TypeScript テストファイル
- `*.spec.ts` - TypeScript テストファイル（別名）
- `*.test.tsx` - React コンポーネントテストファイル
- `*.spec.tsx` - React コンポーネントテストファイル（別名）
- `__tests__/*.ts` - テスト専用ディレクトリ

### Glob パターン

テストファイルを検出するためのパターン：

```bash
**/*.test.ts
**/*.spec.ts
**/*.test.tsx
**/*.spec.tsx
**/__tests__/**/*.ts
**/__tests__/**/*.tsx
```

### 統合テストの検出パターン

以下のパターンを含むテストは統合テストとみなします：

```typescript
// データベース接続
new Database(
connectToDatabase(
createConnection(
mongoose.connect(
sequelize.sync(

// 外部API呼び出し（モックなし）
fetch('http
axios.get('http
request('http

// ファイルシステム操作
fs.readFile(
fs.writeFile(
fs.exists(
```

### Grep パターン

統合テストを検出するための正規表現パターン：

```bash
# データベース関連
new\s+Database\(|connectToDatabase\(|createConnection\(|mongoose\.connect\(

# HTTP通信（実際の通信）
fetch\(['"]https?://|axios\.(get|post|put|delete)\(['"]https?://

# ファイルシステム
fs\.(readFile|writeFile|exists)\(
```

## ディレクトリ構造の推奨

```
project-root/
├── src/
│   ├── utils/
│   │   ├── math.ts              # プロダクションコード
│   │   └── math.test.ts         # ユニットテスト（同じディレクトリ）
│   ├── services/
│   │   ├── UserService.ts
│   │   └── UserService.test.ts
│   └── components/
│       ├── Button.tsx
│       └── Button.test.tsx
├── integration-tests/           # 統合テスト専用ディレクトリ
│   ├── api/
│   │   └── users.integration.test.ts
│   └── database/
│       └── migrations.integration.test.ts
└── e2e/                         # E2Eテスト専用ディレクトリ
    └── user-flow.spec.ts
```

## 実装チェックリスト

### ✅ プロジェクトセットアップ

- [ ] テストフレームワーク（Jest, Vitest等）が設定されている
- [ ] テストコマンド（`npm test`）が動作する
- [ ] カバレッジ設定が有効になっている
- [ ] CI/CDでテストが自動実行される

### ✅ テストファイル

- [ ] すべてのプロダクションコードに対応するテストファイルが存在する
- [ ] テストファイルの命名規則が統一されている（`.test.ts` または `.spec.ts`）
- [ ] テストケースが適切に整理されている（`describe`, `test`/`it`）

### ✅ テストの品質

- [ ] 外部依存がモック・スタブで置き換えられている
- [ ] 各テストが独立して実行可能
- [ ] テストが高速（全体で数秒以内）
- [ ] テストケース名が明確で理解しやすい
- [ ] Arrange-Act-Assert パターンに従っている

### ✅ 設計

- [ ] 依存性注入が適切に使われている
- [ ] 関数・クラスが単一責任の原則に従っている
- [ ] Pure Function が活用されている
- [ ] インターフェースが適切に定義されている

## よくある間違いと修正方法

### ❌ 間違い 1: 実際のAPIを呼び出す

```typescript
// ❌ 悪い例
test('should fetch user data', async () => {
  const response = await fetch('https://api.example.com/users/1');
  const user = await response.json();
  expect(user.id).toBe(1);
});
```

**問題点**:
- ネットワークに依存し、遅く不安定
- 外部APIのダウン時にテストが失敗
- テストデータの管理が困難

```typescript
// ✅ 良い例
test('should fetch user data', async () => {
  const mockFetch = jest.fn().mockResolvedValue({
    json: () => Promise.resolve({ id: 1, name: 'Test User' })
  });
  global.fetch = mockFetch as any;

  const user = await fetchUserData(1);

  expect(user.id).toBe(1);
  expect(mockFetch).toHaveBeenCalledWith('https://api.example.com/users/1');
});
```

### ❌ 間違い 2: データベースに接続する

```typescript
// ❌ 悪い例
test('should save user to database', async () => {
  const db = new Database('postgresql://localhost/test');
  await db.connect();

  const user = await db.users.create({ name: 'Test', email: 'test@example.com' });

  expect(user.id).toBeDefined();
  await db.disconnect();
});
```

**問題点**:
- 実際のDBが必要で環境依存
- テスト実行が遅い
- テストデータのクリーンアップが必要

```typescript
// ✅ 良い例
test('should save user to database', async () => {
  const mockRepository = {
    create: jest.fn().mockResolvedValue({ id: '123', name: 'Test', email: 'test@example.com' })
  };

  const user = await saveUser(mockRepository, { name: 'Test', email: 'test@example.com' });

  expect(user.id).toBe('123');
  expect(mockRepository.create).toHaveBeenCalledWith({
    name: 'Test',
    email: 'test@example.com'
  });
});
```

### ❌ 間違い 3: 複数の機能を1つのテストで検証

```typescript
// ❌ 悪い例
test('user registration flow', async () => {
  const email = 'test@example.com';
  const password = 'password123';

  // バリデーション
  expect(validateEmail(email)).toBe(true);

  // パスワードハッシュ化
  const hashed = await hashPassword(password);
  expect(hashed).not.toBe(password);

  // ユーザー作成
  const user = await createUser({ email, password: hashed });
  expect(user.id).toBeDefined();
});
```

**問題点**:
- どこで失敗したか分かりにくい
- 一部の機能が壊れると全体が失敗
- メンテナンスが困難

```typescript
// ✅ 良い例
describe('User Registration', () => {
  test('validateEmail should accept valid email', () => {
    expect(validateEmail('test@example.com')).toBe(true);
  });

  test('validateEmail should reject invalid email', () => {
    expect(validateEmail('invalid')).toBe(false);
  });

  test('hashPassword should return different value', async () => {
    const password = 'password123';
    const hashed = await hashPassword(password);
    expect(hashed).not.toBe(password);
  });

  test('createUser should create user with hashed password', async () => {
    const mockRepo = { create: jest.fn().mockResolvedValue({ id: '123' }) };
    const user = await createUser(mockRepo, {
      email: 'test@example.com',
      password: 'hashed'
    });
    expect(user.id).toBe('123');
  });
});
```

## 推奨ツール

### テストフレームワーク

- **Jest**: 最も人気のあるJavaScriptテストフレームワーク
- **Vitest**: Vite環境に最適化された高速テストフレームワーク
- **Mocha + Chai**: 柔軟な設定が可能な老舗フレームワーク

### モックライブラリ

- **Jest Mock**: Jestに組み込まれたモック機能
- **Sinon.js**: 汎用的なスパイ・スタブ・モックライブラリ
- **MSW (Mock Service Worker)**: HTTPリクエストをモックするライブラリ

### カバレッジツール

- **Istanbul (c8)**: コードカバレッジ測定ツール
- **Codecov**: カバレッジレポートの可視化サービス
- **Coveralls**: カバレッジトレンドの追跡サービス

## まとめ

ユニットテストを効果的に実装するための要点：

1. **外部依存を排除**: データベース、API、ファイルシステムに依存しない
2. **テスト可能な設計**: 依存性注入、Pure Function、単一責任の原則
3. **モックを活用**: 外部依存をモック・スタブで置き換える
4. **高速実行**: 全テストが数秒で完了するように保つ
5. **独立性**: 各テストが他のテストに依存しない
6. **統合テストとの分離**: ユニットテストと統合テストは別ディレクトリに配置

ユニットテストは開発のスピードと品質を同時に向上させる強力なツールです。適切に実装することで、自信を持ってコードをリファクタリングし、新機能を追加できるようになります。
