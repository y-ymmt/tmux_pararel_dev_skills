---
name: parallel-dev
description: tmuxを使用して複数の開発者を並列に管理し、チーム開発を実現するコマンド
arguments:
  - name: workers
    description: 開発者の人数（デフォルト: 3）
    required: false
  - name: task
    description: 実行するタスクの説明
    required: true
---

# 並列組織化開発の開始

あなたはマネージャーです。ユーザーから以下の指示を受けました:

- **開発者数**: $ARGUMENTS.workers（指定がない場合は3人）
- **タスク**: $ARGUMENTS.task

## フェーズ0: 前提確認

tmuxセッション内で実行されているか確認:

```bash
if [ -n "$TMUX" ]; then
  echo "OK: tmux内で実行中"
else
  echo "ERROR: tmux外で実行されています"
fi
```

**tmux外の場合は中止し、以下を案内:**
```
このコマンドはtmux内で実行する必要があります。
1. tmux を起動: tmux
2. Claude Code を起動: claude
3. /parallel-dev コマンドを再実行
```

## フェーズ1: 環境セットアップ

### 1.1 現在のセッション情報を取得

```bash
SESSION_NAME=$(tmux display-message -p '#S')
WINDOW_NUM=$(tmux display-message -p '#I')
MANAGER_PANE=$(tmux display-message -p '#P')
WORK_DIR=$(pwd)
```

### 1.2 開発者paneを作成

```bash
NUM_WORKERS=${開発者数}

for i in $(seq 1 $NUM_WORKERS); do
  tmux split-window -h -c "$WORK_DIR"
  tmux select-layout -t "$SESSION_NAME:$WINDOW_NUM" tiled
done

tmux select-pane -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE"
```

### 1.3 各開発者paneでClaude Codeを起動

```bash
PANES=$(tmux list-panes -t "$SESSION_NAME:$WINDOW_NUM" -F "#{pane_index}")

for pane in $PANES; do
  if [ "$pane" != "$MANAGER_PANE" ]; then
    tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$pane" "claude" Enter
    sleep 2
  fi
done
```

### 1.4 セッション情報を記録

- セッション名: `$SESSION_NAME`
- ウィンドウ番号: `$WINDOW_NUM`
- マネージャーpane: `$MANAGER_PANE`
- 開発者pane: マネージャー以外の全pane

## フェーズ2: タスク分析と分割

**重要: タスク数 ≠ 開発者数**

ユーザーのタスクを分析し、**作業に適した粒度**でサブタスクに分割:

1. タスクの全体像を把握
2. 適切な粒度でサブタスクに分割（開発者数に縛られない）
3. 各サブタスクに優先順位をつける
4. 依存関係を考慮してタスクキューを作成

### タスクキューの例

```
=== タスクキュー ===
1. [優先度: 高] タスクA → 開発者1に割り当て
2. [優先度: 高] タスクB → 開発者2に割り当て
3. [優先度: 高] タスクC → 開発者3に割り当て
4. [優先度: 中] タスクD → 待機（完了した開発者に割り当て）
5. [優先度: 中] タスクE → 待機
6. [優先度: 低] タスクF → 待機
```

## フェーズ3: 初期タスク割り当て

各開発者に優先度の高いタスクから順に割り当てる。

**重要**: 指示を送った後、必ず別途Enterを送信してClaude Codeを実行させる。

```bash
# ステップ1: 指示内容を送信
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

# ステップ2: Enterを送信してClaude Codeを実行
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

## フェーズ4: 完了報告の待機とレビュー

### 4.1 報告の待機（重要）

**マネージャーはsleepせず、開発者からの報告を待つ。**

開発者が完了すると、以下の形式でマネージャーの入力欄に報告が届く:
- `::DEVN_DONE:: 内容` - タスク完了
- `::DEVN_QUESTION:: 内容` - 質問
- `::DEVN_ERROR:: 内容` - エラー発生

### 4.2 完了報告を受けたら

1. 報告内容を確認
2. 成果物をレビュー（必要に応じてファイルを確認）
3. 問題があれば修正指示を送信
4. OKなら、待機キューから次のタスクを割り当て

### 4.3 次のタスク割り当て

```bash
# 完了した開発者に次のタスクを割り当て
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "次のタスクです。

【タスク】
$NEXT_TASK_DESCRIPTION

【完了条件】
$COMPLETION_CRITERIA

【報告方法】
完了したら以下を実行:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: タスク完了'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

# Enterを送信
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

### 4.4 修正指示（問題があった場合）

```bash
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "【修正依頼】
$ISSUE_DESCRIPTION

修正完了後、再度報告してください:
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: 修正完了'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

## フェーズ5: 完了と報告

全タスクが完了したら:

1. 成果物を統合（必要に応じて）
2. ユーザーに完了報告
3. 開発者paneをクリーンアップ

```bash
for pane in $DEV_PANES; do
  tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$pane" "/exit"
  tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$pane" Enter
  sleep 1
  tmux kill-pane -t "$SESSION_NAME:$WINDOW_NUM.$pane"
done
```

## タスク状況の管理

常に以下を把握する:

```
=== タスク状況 ===
[完了] タスク1: 内容（開発者1）
[実行中] タスク2: 内容（開発者2）
[実行中] タスク3: 内容（開発者3）
[待機] タスク4: 内容
[待機] タスク5: 内容
```

## 重要な注意事項

- **タスク分割は柔軟に**: 開発者数に縛られず、適切な粒度で分割
- **優先順位**: 高優先度タスクから順に割り当て
- **キュー方式**: 完了した開発者に次のタスクを割り当て
- **send-keys + Enter**: 指示送信後は必ず別途Enterを送信
- **報告待ち**: sleepではなく、開発者からの報告を待つ
- **リアルタイム表示**: ユーザーの画面でpane分割が見える
