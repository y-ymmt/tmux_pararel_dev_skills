# タスク指示テンプレート集

## 基本原則

1. 指示送信後は必ず別途Enterを送信
2. 報告方法を必ず含める
3. 完了条件を明確にする

## 初回タスク割り当てテンプレート

### 標準タスク

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "あなたは開発者${DEV_NUM}です。以下のタスクを実行してください。

【タスク】
$TASK_DESCRIPTION

【作業ディレクトリ】
$WORK_DIR

【対象ファイル】
$TARGET_FILES

【完了条件】
$COMPLETION_CRITERIA

【重要】作業が完了したら、必ず以下のコマンドを実行してマネージャーに報告してください:

tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: タスク概要'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter

質問やエラーがある場合も報告してください:

tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_QUESTION:: 質問内容'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

## 機能別テンプレート

### 新規機能実装

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "あなたは開発者${DEV_NUM}です。

【タスク】新機能の実装
$FEATURE_DESCRIPTION

【作業ディレクトリ】
$WORK_DIR

【作成するファイル】
$FILE_LIST

【技術要件】
$TECHNICAL_REQUIREMENTS

【完了条件】
- 機能が正常に動作すること
- コードがコンパイル/実行可能なこと

【報告方法】
完了したら以下を実行:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: $FEATURE_NAME 実装完了'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

### バグ修正

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "あなたは開発者${DEV_NUM}です。

【タスク】バグ修正
$BUG_DESCRIPTION

【再現手順】
$REPRODUCTION_STEPS

【期待動作】
$EXPECTED_BEHAVIOR

【関連ファイル】
$RELATED_FILES

【完了条件】
- バグが修正されていること
- 副作用がないこと

【報告方法】
完了したら:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: バグ修正完了'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

### テスト作成

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "あなたは開発者${DEV_NUM}です。

【タスク】テスト作成
$TEST_TARGET

【テストケース】
$TEST_CASES

【テストファイル】
$TEST_FILE_PATH

【完了条件】
- テストが全てパスすること
- カバレッジが十分であること

【報告方法】
完了したら:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: テスト作成完了 結果: X件パス'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

### リファクタリング

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "あなたは開発者${DEV_NUM}です。

【タスク】リファクタリング
$REFACTORING_TARGET

【目的】
$REFACTORING_PURPOSE

【制約】
- 既存の機能を壊さないこと
- APIの互換性を維持すること

【完了条件】
- リファクタリングが完了していること
- 既存テストがパスすること

【報告方法】
完了したら:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: リファクタリング完了'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

### API実装

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "あなたは開発者${DEV_NUM}です。

【タスク】APIエンドポイント実装
$METHOD $PATH

【機能】
$API_DESCRIPTION

【リクエスト】
$REQUEST_FORMAT

【レスポンス】
$RESPONSE_FORMAT

【完了条件】
- エンドポイントが正常に動作すること
- エラーハンドリングが適切であること

【報告方法】
完了したら:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: $METHOD $PATH 実装完了'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

## 次タスク割り当てテンプレート

### シンプル版

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "次のタスクです。

【タスク】
$NEXT_TASK_DESCRIPTION

【完了条件】
$COMPLETION_CRITERIA

【報告方法】
完了したら:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: タスク完了'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

## 修正依頼テンプレート

### 問題指摘と修正依頼

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "【修正依頼】

レビューの結果、以下の修正が必要です:

【問題1】
$ISSUE_1

【問題2】
$ISSUE_2

【修正方針】
$FIX_APPROACH

修正完了後、報告してください:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: 修正完了'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

## 質問への回答テンプレート

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "質問への回答です。

【回答】
$ANSWER

この方針で進めてください。完了したら報告をお願いします。"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

## エラー対応テンプレート

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "エラーへの対処方法です。

【対処方法】
$ERROR_SOLUTION

この方法で解決を試みてください。解決したら報告をお願いします。

tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: エラー解決'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

## 作業終了テンプレート

### 全タスク完了時

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "全タスクが完了しました。お疲れ様でした。

これで作業は終了です。"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter

# Claude Codeを終了
sleep 2
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "/exit"
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```
