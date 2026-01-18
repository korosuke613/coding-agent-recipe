# Conventional Commit 規約詳細

## Conventional Commit とは

Conventional Commit は、コミットメッセージに人間と機械が読める意味を持たせるための仕様です。この規約に従うことで：

1. **変更履歴の自動生成**: CHANGELOG を自動生成できる
2. **セマンティックバージョニング**: コミットから適切なバージョン番号を自動決定できる
3. **コミット履歴の検索性向上**: 特定の種類の変更を簡単に検索できる
4. **チーム内のコミュニケーション向上**: 変更の意図が明確になる

## 基本構造

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### 必須要素

- **type**: コミットの種類を示すプレフィックス
- **description**: 変更の簡潔な説明（命令形、現在形で記述）

### オプション要素

- **scope**: 変更の影響範囲（カッコで囲む）
- **body**: 変更の詳細な説明
- **footer**: Breaking Changes や Issue 参照など

## Type の種類

### 主要な Type

| Type | 説明 | バージョン影響 | 例 |
|------|------|----------------|-----|
| `feat` | 新機能の追加 | MINOR | ユーザー登録機能の追加 |
| `fix` | バグ修正 | PATCH | ログイン時のエラー修正 |
| `docs` | ドキュメントのみの変更 | - | README の更新 |
| `style` | コードの動作に影響しない変更 | - | フォーマット、セミコロンの追加 |
| `refactor` | バグ修正や機能追加を含まないコード変更 | - | 関数の分割、変数名変更 |
| `perf` | パフォーマンス改善 | PATCH | データベースクエリの最適化 |
| `test` | テストの追加や修正 | - | ユニットテストの追加 |
| `build` | ビルドシステムや外部依存関係の変更 | - | webpack 設定の更新 |
| `ci` | CI/CD 設定ファイルやスクリプトの変更 | - | GitHub Actions の追加 |
| `chore` | その他の変更 | - | .gitignore の更新 |
| `revert` | 以前のコミットの取り消し | - | Revert "feat: 新機能追加" |

### 詳細な Type 解説

#### feat (Feature)
新しい機能や振る舞いの追加。ユーザーに見える変更。

```
feat: ユーザープロフィール編集機能を追加
feat(auth): ソーシャルログイン機能を追加
feat!: APIのエンドポイントをv2に変更

BREAKING CHANGE: /api/users が /api/v2/users に変更されました
```

#### fix (Bug Fix)
既存の問題を修正。

```
fix: ログイン後のリダイレクトエラーを修正
fix(api): null値による500エラーを修正
fix: モバイル表示時のレイアウト崩れを修正
```

#### docs (Documentation)
コードに影響しないドキュメントの変更。

```
docs: READMEのインストール手順を更新
docs(api): APIエンドポイントのドキュメントを追加
docs: コントリビューションガイドラインを追加
```

#### style (Code Style)
コードの動作に影響しない変更（フォーマット、空白、セミコロンなど）。

```
style: Prettier でコードをフォーマット
style(components): インデントを統一
style: 末尾のセミコロンを追加
```

#### refactor (Code Refactoring)
バグ修正や機能追加を含まないコード変更。

```
refactor: ユーザー認証ロジックを関数に分割
refactor(utils): 重複コードを共通関数に統合
refactor: クラスベースからフック形式に変更
```

#### perf (Performance Improvements)
パフォーマンスを向上させるコード変更。

```
perf: 画像の遅延読み込みを実装
perf(database): クエリにインデックスを追加
perf: 仮想スクロールを実装して大量データの表示を高速化
```

#### test (Tests)
テストの追加、修正、またはテストコードのリファクタリング。

```
test: ユーザー登録フローのテストを追加
test(api): エラーハンドリングのテストケースを追加
test: E2Eテストのフレーキーテストを修正
```

#### build (Build System)
ビルドシステムや外部依存関係に影響する変更。

```
build: webpack 設定を v5 に更新
build(deps): axios を 1.3.0 に更新
build: production ビルドの最適化設定を追加
```

#### ci (Continuous Integration)
CI設定ファイルやスクリプトの変更。

```
ci: GitHub Actions のワークフローを追加
ci: テストカバレッジの閾値を80%に設定
ci(deploy): 自動デプロイスクリプトを追加
```

#### chore (Chores)
その他の変更（ビルドプロセス、ツール、ライブラリなど）。

```
chore: .gitignore を更新
chore(deps): 開発依存関係を更新
chore: ライセンスファイルを追加
```

## Scope の使用

Scope は変更の影響範囲を示します。プロジェクトによって異なりますが、一般的な例：

```
feat(auth): ログイン機能を追加
fix(ui): ボタンの配置を修正
docs(api): エンドポイントのドキュメントを更新
refactor(database): クエリビルダーを改善
test(e2e): チェックアウトフローのテストを追加
```

### Scope の例

- **機能モジュール**: `auth`, `user`, `payment`, `search`
- **レイヤー**: `api`, `ui`, `database`, `service`
- **コンポーネント**: `header`, `sidebar`, `modal`
- **ファイル/ディレクトリ**: `utils`, `config`, `types`

## Breaking Changes

互換性を破る変更には `!` を付けるか、フッターに `BREAKING CHANGE:` を記載します。

```
feat!: APIのレスポンス形式を変更

BREAKING CHANGE: すべてのAPIレスポンスが { data, meta } 形式になりました
```

または

```
feat(api)!: ユーザーエンドポイントをv2に移行
```

## Body の記述

Body には変更の動機や、変更前後の動作の違いを記述します。

```
feat: ダークモード機能を追加

ユーザーからの要望が多かったダークモードを実装しました。
ユーザーの設定は localStorage に保存され、次回訪問時も
設定が保持されます。

システムのテーマ設定も自動検出します。
```

## Footer の記述

Footer には Issue 参照や Breaking Changes を記載します。

```
fix: ログインエラーを修正

Closes #123
Fixes #456

fix: パフォーマンス問題を修正

Related to #789
See also: #890
```

## 良い例

### 日本語での例

```
feat: ユーザープロフィール編集機能を追加

ユーザーが自分のプロフィール情報（名前、メールアドレス、
アバター画像）を編集できる機能を実装しました。

Closes #45
```

```
fix(auth): トークン有効期限切れ時のリダイレクト処理を修正

トークンが期限切れの場合、適切にログインページに
リダイレクトするように修正しました。

Fixes #78
```

```
refactor: API クライアントを axios から fetch に移行

依存関係を減らすため、axios から標準の fetch API に
移行しました。機能的な変更はありません。
```

```
perf(list): 仮想スクロールを実装

大量のアイテムを表示する際のパフォーマンスを改善するため、
仮想スクロールを実装しました。これにより1万件以上の
アイテムでもスムーズにスクロールできます。
```

### 英語での例

```
feat(user): add user profile editing feature

Users can now edit their profile information including
name, email, and avatar image.

Closes #45
```

```
fix(auth): correct token expiration redirect

When token expires, properly redirect to login page
instead of showing an error message.

Fixes #78
```

## 悪い例

```
// ❌ type がない
updated README

// ❌ description が不明確
fix: bug fix

// ❌ 過去形
fixed: fixed the login bug

// ❌ 大文字で始まっている
feat: Add new feature

// ❌ ピリオドで終わっている
fix: fixed the bug.

// ❌ 複数の変更を含む
feat: add login, signup, and password reset

// ❌ 詳細すぎる
fix: fixed the bug in src/utils/auth.ts line 42 where the token was...
```

## Conventional Commit の検証

### Git hooks で検証

commitlint を使用して、コミットメッセージを自動検証できます。

```bash
# インストール
npm install --save-dev @commitlint/cli @commitlint/config-conventional

# .commitlintrc.json
{
  "extends": ["@commitlint/config-conventional"]
}

# husky でコミット時に検証
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'
```

### コミットメッセージのパターン

```regex
^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .{1,100}$
```

### 検証チェックリスト

- [ ] type が存在し、許可されたものか
- [ ] scope がある場合、カッコで囲まれているか
- [ ] description が小文字で始まっているか
- [ ] description が命令形、現在形か
- [ ] description がピリオドで終わっていないか
- [ ] description が空でないか
- [ ] 全体として意味が通るか

## チーム内での運用

### コミット前のチェック

1. **コミットの粒度を適切に**: 1つのコミットには1つの論理的な変更のみ
2. **テストが通ることを確認**: テストが失敗している状態でコミットしない
3. **コードレビューを意識**: レビューしやすいサイズのコミット
4. **issue を参照**: 関連する issue がある場合は footer で参照

### プルリクエストでの運用

複数のコミットがある場合、PR のタイトルも Conventional Commit 形式にすると、
squash merge 時に自動的に適切なコミットメッセージになります。

```
PR Title: feat: ユーザー認証機能の実装

Commits in PR:
- feat(auth): ログイン機能を追加
- feat(auth): ログアウト機能を追加
- test(auth): 認証フローのテストを追加
- docs(auth): 認証APIのドキュメントを追加
```

## ツールとの連携

### 自動生成される成果物

#### CHANGELOG.md

```markdown
# Changelog

## [1.2.0] - 2024-03-15

### Features
- ユーザープロフィール編集機能を追加 (#45)
- ダークモード機能を追加 (#67)

### Bug Fixes
- ログイン時のリダイレクトエラーを修正 (#78)
- モバイル表示のレイアウト崩れを修正 (#89)

### Performance Improvements
- 大量データ表示時の仮想スクロールを実装 (#90)
```

#### セマンティックバージョニング

- `feat`: MINOR バージョンを上げる (1.0.0 → 1.1.0)
- `fix`: PATCH バージョンを上げる (1.0.0 → 1.0.1)
- `BREAKING CHANGE`: MAJOR バージョンを上げる (1.0.0 → 2.0.0)

### 推奨ツール

- **commitlint**: コミットメッセージの検証
- **husky**: Git hooks の管理
- **standard-version**: バージョン管理と CHANGELOG 生成
- **semantic-release**: 自動的なバージョニングとリリース

## まとめ

- Conventional Commit は構造化されたコミットメッセージの仕様
- `<type>[scope]: <description>` の形式を基本とする
- 自動化ツールと組み合わせることで、変更履歴管理が効率化される
- チーム全体で統一することで、コミュニケーションが向上する
- 適切なツールを使用して、規約の遵守を自動化する
