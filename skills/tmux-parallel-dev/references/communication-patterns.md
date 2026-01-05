# 通信パターン詳細

## 基本原則

1. **send-keys + Enter**: 指示を送った後、必ず別途Enterを送信
2. **報告待ち**: マネージャーはsleepせず、開発者からの報告を待つ
3. **非同期通信**: 開発者は完了次第、マネージャーに報告

## マネージャー → 開発者 通信パターン

### 基本形式

```bash
# ステップ1: 指示内容を送信
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "指示内容"

# ステップ2: Enterを送信してClaude Codeを実行
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

### 初回タスク割り当て

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "あなたは開発者${DEV_NUM}です。以下のタスクを実行してください。

【タスク】
$TASK_DESCRIPTION

【作業ディレクトリ】
$WORK_DIR

【完了条件】
$COMPLETION_CRITERIA

【重要】作業が完了したら、必ず以下のコマンドを実行してマネージャーに報告してください:

tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: タスク完了の概要'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

### 次タスク割り当て（完了報告を受けた後）

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "次のタスクです。

【タスク】
$NEXT_TASK_DESCRIPTION

【完了条件】
$COMPLETION_CRITERIA

【報告方法】
完了したら以下を実行:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: タスク完了'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

### 修正依頼

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "【修正依頼】

レビューの結果、以下の修正が必要です:

$ISSUE_DESCRIPTION

修正完了後、報告してください:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: 修正完了'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

### 催促・状況確認

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "進捗を報告してください。

報告方法:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_PROGRESS:: 現在の状況'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

## 開発者 → マネージャー 報告パターン

### 完了報告

開発者が実行するコマンド:

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE" "::DEV${N}_DONE:: ユーザー認証機能を実装完了。src/auth.tsを作成し、JWTベースの認証を実装。テスト5件追加、全てパス。"
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE" Enter
```

### 質問

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE" "::DEV${N}_QUESTION:: データベーススキーマについて確認。usersテーブルにrole列を追加する想定でよいか？"
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE" Enter
```

### エラー報告

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE" "::DEV${N}_ERROR:: TypeScriptコンパイルエラー発生。TS2339: Property 'userId' does not exist on type 'Request'。対処方法を指示ください。"
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE" Enter
```

### 進捗報告

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE" "::DEV${N}_PROGRESS:: 50%完了。APIエンドポイント3/6実装済み。残り: ユーザー削除、ロール変更、パスワードリセット。"
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE" Enter
```

## マネージャーの待機パターン

### 基本フロー

```
1. 開発者にタスクを割り当て（send-keys + Enter）
2. マネージャーは何もせず入力待ち状態になる
3. 開発者が完了報告を送信
4. マネージャーの入力欄に報告が届く
5. 報告を確認してレビュー
6. 問題なければ次のタスクを割り当て
```

### 複数開発者からの報告処理

報告は届いた順に処理:

```
::DEV1_DONE:: APIエンドポイント実装完了
  → 開発者1の成果をレビュー
  → 問題なければ開発者1に次のタスクを割り当て

::DEV3_DONE:: テスト作成完了
  → 開発者3の成果をレビュー
  → 問題なければ開発者3に次のタスクを割り当て

::DEV2_QUESTION:: 認証方式について質問
  → 開発者2に回答を送信
```

## pane状態確認

### 特定paneの出力確認

```bash
tmux capture-pane -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" -p -S -50
```

### 全paneの状態一覧

```bash
tmux list-panes -t "$SESSION_NAME:$WINDOW_NUM" -F "pane #{pane_index}: #{pane_current_command}"
```

## タスクキュー管理パターン

### 初期割り当て

```
タスクキュー（優先度順）:
1. [高] タスクA → 開発者1に割り当て
2. [高] タスクB → 開発者2に割り当て
3. [高] タスクC → 開発者3に割り当て
4. [中] タスクD → 待機
5. [中] タスクE → 待機
6. [低] タスクF → 待機
```

### 完了後の再割り当て

```
開発者1が完了報告
  ↓
待機キューから次のタスクを取得（タスクD）
  ↓
開発者1にタスクDを割り当て
  ↓
キュー更新:
  4. [中] タスクD → 開発者1に割り当て（実行中）
  5. [中] タスクE → 待機
  6. [低] タスクF → 待機
```

### 依存関係の処理

```
タスクBがタスクAに依存している場合:

1. タスクAを開発者1に割り当て
2. タスクBは待機（依存未解決）
3. 開発者1がタスクA完了を報告
4. タスクBの依存が解決
5. タスクBを空いている開発者に割り当て
```
