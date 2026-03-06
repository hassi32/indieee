# CreativeFlow - macOSタスク管理アプリ

## プロジェクト概要
イラスト制作・開発などクリエイティブなタスクを視覚的に管理するmacOSデスクトップアプリ。

## 技術スタック
- **言語・フレームワーク**: Swift + SwiftUI
- **データ永続化**: GRDB.swift (SQLite)
- **対象OS**: macOS 14+

## 🎓 学習方針

**コードは自分で書いて学ぶスタイル:**
- Claudeは手順とコード例を提示
- 実装は自分で行う（手を動かして学ぶ）
- どこに何を書くかをステップバイステップで説明
- 分からないところは質問しながら進める
- 完成したらCLAUDE.mdに記録を残す

---

## データモデル

### TaskType (タスクの種類)
```swift
enum TaskType: Codable {
    case single                                    // 単一タスク
    case counter(current: Int, total: Int)        // カウンター型（例: 原稿30枚中5枚完了）
    case milestone(steps: [MilestoneStep])        // マイルストーン型（複数ステップ）
    case checklist(items: [SubTask])              // チェックリスト型
}

struct MilestoneStep: Codable, Identifiable {
    var id: UUID
    var name: String
    var isCompleted: Bool
}

struct SubTask: Codable, Identifiable {
    var id: UUID
    var title: String
    var isCompleted: Bool
}
```

### Priority (優先度)
```swift
enum Priority: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    case urgent = "urgent"
}
```

### Task (タスク)
```swift
struct Task: Identifiable, Codable {
    var id: UUID
    var title: String
    var type: TaskType
    var deadline: Date?
    var priority: Priority
    var tags: [String]
    var createdAt: Date
    var updatedAt: Date
    var isCompleted: Bool
}
```

### Project (プロジェクト)
```swift
struct Project: Identifiable, Codable {
    var id: UUID
    var name: String
    var color: String          // Hex色コード
    var icon: String           // SF Symbol名
    var tasks: [Task]
    var createdAt: Date
}
```

---

## アーキテクチャ設計

### ディレクトリ構成
```
CreativeFlow/
├── Models/
│   ├── Task.swift
│   ├── Project.swift
│   └── TaskType.swift
├── Views/
│   ├── ContentView.swift
│   ├── ProjectListView.swift
│   ├── TaskListView.swift
│   ├── TaskDetailView.swift
│   └── Components/
│       ├── TaskCard.swift
│       ├── PriorityBadge.swift
│       └── ProgressIndicator.swift
├── Database/
│   ├── DatabaseManager.swift
│   ├── TaskRepository.swift
│   └── ProjectRepository.swift
└── App/
    └── CreativeFlowApp.swift
```

### GRDB.swift データベース設計

#### テーブル定義

**projects テーブル**
```sql
CREATE TABLE projects (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    color TEXT NOT NULL,
    icon TEXT NOT NULL,
    created_at REAL NOT NULL
);
```

**tasks テーブル**
```sql
CREATE TABLE tasks (
    id TEXT PRIMARY KEY,
    project_id TEXT NOT NULL,
    title TEXT NOT NULL,
    type_raw TEXT NOT NULL,           -- TaskTypeをJSON化して保存
    deadline REAL,
    priority TEXT NOT NULL,
    tags TEXT NOT NULL,                -- JSON配列
    created_at REAL NOT NULL,
    updated_at REAL NOT NULL,
    is_completed INTEGER NOT NULL,
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
);
```

#### GRDB実装例

```swift
import GRDB

// DatabaseManagerシングルトン
class DatabaseManager {
    static let shared = DatabaseManager()
    private var dbQueue: DatabaseQueue!
    
    private init() {
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dbPath = appSupport.appendingPathComponent("CreativeFlow.sqlite").path
        
        dbQueue = try! DatabaseQueue(path: dbPath)
        try! migrator.migrate(dbQueue)
    }
    
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("v1") { db in
            try db.create(table: "projects") { t in
                t.column("id", .text).primaryKey()
                t.column("name", .text).notNull()
                t.column("color", .text).notNull()
                t.column("icon", .text).notNull()
                t.column("created_at", .real).notNull()
            }
            
            try db.create(table: "tasks") { t in
                t.column("id", .text).primaryKey()
                t.column("project_id", .text).notNull()
                    .references("projects", onDelete: .cascade)
                t.column("title", .text).notNull()
                t.column("type_raw", .text).notNull()
                t.column("deadline", .real)
                t.column("priority", .text).notNull()
                t.column("tags", .text).notNull()
                t.column("created_at", .real).notNull()
                t.column("updated_at", .real).notNull()
                t.column("is_completed", .integer).notNull()
            }
        }
        
        return migrator
    }
    
    func getQueue() -> DatabaseQueue {
        return dbQueue
    }
}
```

---

## UI/UX設計

### レイアウト
- **3カラムレイアウト** (NavigationSplitView使用)
  1. サイドバー: プロジェクト一覧
  2. リスト: 選択プロジェクトのタスク一覧
  3. 詳細: タスク詳細・編集画面

### カラーテーマ
- システムカラーに対応 (Light/Dark Mode)
- プロジェクトごとにアクセントカラーをカスタマイズ可能

### 視覚的要素
- SF Symbolsを活用したアイコン表示
- 優先度に応じた色分け:
  - Urgent: 赤 (`.red`)
  - High: オレンジ (`.orange`)
  - Medium: 黄 (`.yellow`)
  - Low: グレー (`.gray`)

---

## 実装フェーズ

### Phase 1: 基礎構築
- [x] プロジェクト初期設定
- [ ] データモデル定義
- [ ] GRDB.swiftセットアップ
- [ ] DatabaseManager実装

### Phase 2: コアUI
- [ ] NavigationSplitView基本レイアウト
- [ ] プロジェクト一覧表示
- [ ] タスク一覧表示
- [ ] タスク追加・削除機能

### Phase 3: タスクタイプ実装
- [ ] 単一タスク
- [ ] カウンタータスク (進捗表示)
- [ ] マイルストーンタスク
- [ ] チェックリストタスク

### Phase 4: 高度な機能
- [ ] タグフィルタリング
- [ ] 検索機能
- [ ] 締切リマインダー
- [ ] データエクスポート (JSON/CSV)

### Phase 5: 最適化
- [ ] パフォーマンスチューニング
- [ ] アニメーション追加
- [ ] キーボードショートカット
- [ ] アクセシビリティ対応

---

## 開発ガイドライン

### コーディング規約
- Swift API Design Guidelinesに準拠
- SwiftLintを使用したコード品質管理
- 非同期処理はSwift Concurrency (async/await)を使用

### GRDB使用のベストプラクティス
```swift
// 読み取り操作
let projects = try dbQueue.read { db in
    try Project.fetchAll(db)
}

// 書き込み操作
try dbQueue.write { db in
    try project.insert(db)
}

// ObservableObject + Combine連携例
class ProjectStore: ObservableObject {
    @Published var projects: [Project] = []
    
    func loadProjects() {
        projects = try! DatabaseManager.shared.getQueue().read { db in
            try Project.fetchAll(db)
        }
    }
}
```

### テスト戦略
- Swift Testingフレームワークを使用
- インメモリデータベースでのユニットテスト
- UI自動テスト (XCTest UIを活用)

---

## 参考資料
- [GRDB.swift公式ドキュメント](https://github.com/groue/GRDB.swift)
- [SwiftUI Navigation](https://developer.apple.com/documentation/swiftui/navigation)
- [Human Interface Guidelines - macOS](https://developer.apple.com/design/human-interface-guidelines/macos)

---

## メモ・TODO
- 現在はSwiftDataを使用しているが、GRDBに移行予定
- Item.swiftは削除してTask/Projectモデルに置き換える
- macOS専用機能（メニューバー統合、Spotlight連携）も検討
---

## 🚀 開発進捗記録

### 2026/03/06 - Session 1

#### ✅ 完了した作業

**Step 1-3: 基本的なmacOS UIの実装**
- NavigationSplitViewで2カラムレイアウトを実装
- 左サイドバー: アイテム一覧表示
- 右側詳細: 選択したアイテムの詳細表示
- ツールバーに追加・削除ボタンを実装
- 選択状態の管理（`@State private var selectedItem: Item?`）

**Step 4: メニューバーコマンドの実装**
- `indieeeApp.swift`に`.commands`修飾子を追加
- File メニューに以下を追加:
  - "New Item" (Command + N)
  - "Delete Selected Item" (Command + Delete)
- NotificationCenterを使った通知システムの実装
- ContentViewで通知を受け取る処理を追加

#### ⚠️ 現在のエラー

**エラー内容:**
```
error: Invalid redeclaration of 'addNewItem'
error: Invalid redeclaration of 'deleteSelectedItem'
```

**原因:**
`Notification.Name`のextensionが`indieeeApp.swift`と`ContentView.swift`の両方で定義されている

**解決方法:**
ContentView.swiftの最後にある以下のコードを削除する:
```swift
// MARK: - Notification Names
extension Notification.Name {
    static let addNewItem = Notification.Name("addNewItem")
    static let deleteSelectedItem = Notification.Name("deleteSelectedItem")
}
```

この定義は`indieeeApp.swift`にのみ残す（すでに定義済み）

#### 📂 変更されたファイル

1. **ContentView.swift**
   - 2カラムレイアウトに変更
   - 選択状態の管理を追加
   - ツールバーボタンを追加
   - `.onReceive`で通知を受け取る処理を追加
   - 詳細画面に`.padding()`を追加

2. **indieeeApp.swift**
   - `.commands`修飾子を追加
   - `CommandGroup`でメニュー項目を追加
   - `Notification.Name`のextensionを追加

#### 🎯 次回やること

**Step 5: ウィンドウのカスタマイズ**
- ウィンドウタイトルの設定
- デフォルトウィンドウサイズの設定
- 最小サイズの制限

**Step 6: さらなる機能強化**
- Settings画面の追加（Command + ,）
- About画面の追加
- Helpメニューの追加

#### 📚 学んだこと

**macOSアプリの特徴:**
- NavigationSplitViewで複数カラムレイアウト
- メニューバーへのコマンド追加
- キーボードショートカット
- NotificationCenterでのアプリ内通信

**SwiftUIの重要な概念:**
- `.commands`修飾子でメニュー項目を追加
- `CommandGroup`でメニューの位置を指定
- `.keyboardShortcut()`でショートカットを設定
- `.onReceive()`で通知を購読
- `NotificationCenter.default.publisher()`でCombine連携

#### 💡 コーディングパターン

**メニューコマンドとViewの連携:**
```swift
// App側: 通知を送信
Button("New Item") {
    NotificationCenter.default.post(name: .addNewItem, object: nil)
}

// View側: 通知を受信
.onReceive(NotificationCenter.default.publisher(for: .addNewItem)) { _ in
    addItem()
}
```

#### 🔗 Gitコミット履歴
- 1st commit: macOS風の2カラムレイアウトを実装
- 2nd commit: メニューバーコマンドとキーボードショートカットを追加

---
### 2026/03/06 - Session 2

#### ✅ 完了した作業

**エラー修正:**
- ContentView.swiftから重複していた`Notification.Name`のextensionを削除
- コンパイルエラーを解消
- アプリの動作確認完了

#### ✅ Step 5: ウィンドウのカスタマイズ (完了)

**5-1. ウィンドウタイトルの設定**
- ContentView.swiftに`.navigationTitle("indieee")`を追加
- ウィンドウタイトルが表示されるように

**5-2. デフォルトウィンドウサイズの設定**
- indieeeApp.swiftに`.defaultSize(width: 800, height: 600)`を追加
- アプリ起動時のウィンドウサイズを800x600に設定

**5-3. ウィンドウリサイズの制限**
- `.windowResizability(.contentSize)`を追加
- ウィンドウのリサイズ動作を制御

#### ✅ Step 6: Settings画面の追加 (完了)

**新規ファイル: SettingsView.swift**
- TabViewで2つのタブを実装:
  - General: 完了アイテム表示切替、デフォルト優先度、バージョン情報
  - Appearance: アクセントカラー選択（5色）
- `@AppStorage`で設定を永続化
- Form + Sectionでマネらしいレイアウト
**indieeeApp.swiftの変更:**
- `Settings { SettingsView() }`を追加
- Command + , で自動的にSettings画面が開くように

#### 📚 学んだこと

**macOS Settingsの実装:**
- `Settings` Sceneを使うと自動的にCommand + ,で開ける
- メニューバーに「Settings...」が自動追加される
- TabViewでタブ切り替えUI

**SwiftUIの便利機能:**
- `@AppStorage`: UserDefaultsを簡単に扱える
- `Form` + `Section`: macOSらしい設定画面レイアウト
- `.formStyle(.grouped)`: グループ化されたフォームスタイル

#### 💡 今回使ったSwiftUIコンポーネント

```swift
// Settings画面の追加
Settings {
    SettingsView()
}

// 永続化された設定値
@AppStorage("accentColor") private var accentColor: String = "blue"

// タブUI
TabView {
    generalView.tabItem { Label("General", systemImage: "gear") }
    appearanceView.tabItem { Label("Appearance", systemImage: "paintbrush") }
}

// macOSらしいフォーム
Form {
    Section("Items") {
        Toggle("Show completed items", isOn: $showCompletedItems)
        Picker("Default priority:", selection: $defaultPriority) { ... }
    }
}
.formStyle(.grouped)
```

#### 🎯 次のステップ候補

**実践的な機能追加:**
- アイテムにタイトル機能を追加
- アイテムの編集機能
- タグ・カテゴリ機能
- 検索・フィルタリング機能

**見た目の改善:**
- カスタムアイコンの追加
- アニメーション効果
- カラーテーマの反映

#### 🔗 Gitコミット履歴
- 1st commit: macOS風の2カラムレイアウトを実装
- 2nd commit: ウィンドウのカスタマイズとエラー修正
- 3rd commit: Settings画面の追加 ✅

---

## 📊 開発統計
- **総コミット数**: 3回
- **実装した画面**: ContentView, SettingsView
- **実装した機能**: アイテム追加・削除、メニューコマンド、Settings画面

---

## 🎯 次回の候補

### 初級: UIのカスタマイズ
1. **Settings画面で選んだカラーを反映**
   - @AppStorageで保存したアクセントカラーを使う
   - ボタンやアイコンの色を変更

2. **アイコンと色の変更**
   - ツールバーアイコンの色を変える
   - サイドバーの背景色を調整
### 中級: 機能の追加
3. **アイテムにタイトル機能を追加**
   - Itemモデルにtitleプロパティを追加
   - TextFieldで入力できるように
   - 一覧にタイトルを表示

4. **アイテムの編集機能**
   - 編集モードの実装
   - タイトル・タイムスタンプの変更

### 上級: 高度な機能
5. **タグ・カテゴリ機能**
   - タグモデルの作成
   - フィルタリング機能

6. **検索機能**
   - 検索バーの追加
   - リアルタイム検索

---




