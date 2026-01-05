---
name: tmux-parallel-dev
description: このスキルは、ユーザーが「並列開発」「チーム開発」「parallel-dev」「複数人で開発」「開発者を使って」「マネージャーとして」と言った場合、または /parallel-dev コマンドを実行した場合に使用される。tmuxを使用して複数のClaude Codeインスタンスを管理し、並列組織化開発を実現する。
version: 1.1.0
---

# tmux並列組織化開発スキル

## 概要

このスキルは、マネージャー（現在のClaude Code）が複数の開発者（別のClaude Codeインスタンス）を管理し、並列開発を実現するためのガイドを提供する。

**前提条件**: ユーザーがtmux内でClaude Codeを起動していること。

## 組織構造

```
ユーザー
   ↓ 指示・フィードバック
マネージャー（このClaude Code）
   ↓ タスクキュー管理・レビュー
┌──┴──┬──────┐
開発者1  開発者2  開発者N
(pane1)  (pane2)  (paneN)
```

## タスク管理の考え方

### タスク分割の原則

- **タスク数 ≠ 開発者数**: 開発者数に関係なく、作業を適切な粒度で分割する
- **優先順位**: 全タスクに優先順位をつけ、優先度の高いものから実行
- **キュー方式**: 開発者が完了したら、次の待機タスクを割り当てる

### タスクキューの例

```
タスクキュー:
1. [優先度: 高] データベーススキーマの作成 → 開発者1に割り当て
2. [優先度: 高] API基盤の実装 → 開発者2に割り当て
3. [優先度: 中] 認証機能の実装 → 開発者3に割り当て
4. [優先度: 中] フロントエンド基盤 → 待機中（完了した開発者に割り当て）
5. [優先度: 低] テスト作成 → 待機中
6. [優先度: 低] ドキュメント作成 → 待機中
```

## セットアップ手順

### 0. 前提確認

```bash
if [ -n "$TMUX" ]; then
  echo "OK: tmux内で実行中"
else
  echo "エラー: tmux内で実行してください"
fi
```

### 1. 現在のセッション情報を取得

```bash
SESSION_NAME=$(tmux display-message -p '#S')
WINDOW_NUM=$(tmux display-message -p '#I')
MANAGER_PANE=$(tmux display-message -p '#P')
WORK_DIR=$(pwd)
```

### 2. 開発者用paneを作成

```bash
for i in $(seq 1 $NUM_WORKERS); do
  tmux split-window -h -c "$WORK_DIR"
  tmux select-layout -t "$SESSION_NAME:$WINDOW_NUM" tiled
done
tmux select-pane -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE"
```

### 3. 各開発者paneでClaude Codeを起動

```bash
PANES=$(tmux list-panes -t "$SESSION_NAME:$WINDOW_NUM" -F "#{pane_index}")
for pane in $PANES; do
  if [ "$pane" != "$MANAGER_PANE" ]; then
    tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$pane" "claude" Enter
    sleep 2
  fi
done
```

## 通信プロトコル

### マネージャーから開発者への指示送信

**重要**: 指示を送った後、必ず別途Enterを送信してClaude Codeを実行させる。

```bash
# ステップ1: 指示内容を送信
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "指示内容"

# ステップ2: Enterを送信してClaude Codeを実行
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

### 指示テンプレート

```bash
# 指示内容を送信
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" "あなたは開発者${DEV_NUM}です。以下のタスクを実行してください。

【タスク】
$TASK_DESCRIPTION

【作業ディレクトリ】
$WORK_DIR

【完了条件】
$COMPLETION_CRITERIA

【重要】作業が完了したら、必ず以下のコマンドを実行してマネージャーに報告してください:

tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE '::DEV${DEV_NUM}_DONE:: $TASK_SUMMARY'
tmux send-keys -t $SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE Enter"

# Enterを送信してClaude Codeを実行
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

### 開発者からマネージャーへの報告

開発者は作業完了時に以下を実行してマネージャーに報告:

```bash
# 完了報告を送信
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE" "::DEV${N}_DONE:: タスク完了の概要"
tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE" Enter
```

報告形式:
- `::DEVN_DONE:: 内容` - タスク完了
- `::DEVN_QUESTION:: 内容` - 質問
- `::DEVN_ERROR:: 内容` - エラー発生
- `::DEVN_PROGRESS:: 内容` - 進捗報告

## マネージャーの動作フロー

### 1. 初期タスク割り当て

タスクを優先順位でソートし、開発者数分だけ初期割り当てを行う:

```
開発者1 ← タスク1（最優先）
開発者2 ← タスク2
開発者3 ← タスク3
タスク4, 5, 6... → 待機キュー
```

### 2. 完了報告の待機（重要）

**マネージャーはsleepせず、開発者からの報告を待つ。**

開発者が完了報告を送信すると、マネージャーのClaude Codeの入力欄に報告が届く。
マネージャーはその報告を確認し、次のアクションを取る。

### 3. 完了報告を受けたら

1. 報告内容を確認
2. 成果物をレビュー（必要に応じてファイルを確認）
3. 問題があれば修正指示を送信
4. OKなら、待機キューから次のタスクを割り当て

### 4. 次のタスク割り当て

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

tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" Enter
```

## タスクキュー管理

### キューの状態管理

マネージャーは以下を常に把握する:

```
=== タスク状況 ===
[完了] タスク1: DBスキーマ作成（開発者1）
[実行中] タスク2: API実装（開発者2）
[実行中] タスク3: 認証機能（開発者3）
[待機] タスク4: フロントエンド基盤
[待機] タスク5: テスト作成
[待機] タスク6: ドキュメント
```

### 依存関係の考慮

タスクに依存関係がある場合:
- 依存元タスクが完了するまで、依存先タスクは待機キューに残す
- 依存元が完了したら、依存先を割り当て可能状態にする

## pane状態確認コマンド

```bash
# 全paneの一覧
tmux list-panes -t "$SESSION_NAME:$WINDOW_NUM" -F "#{pane_index}: #{pane_current_command}"

# 特定paneの出力を取得（最新50行）
tmux capture-pane -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" -p -S -50
```

## セッション終了

全タスク完了後:

```bash
for pane in $DEV_PANES; do
  tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$pane" "/exit"
  tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$pane" Enter
  sleep 1
  tmux kill-pane -t "$SESSION_NAME:$WINDOW_NUM.$pane"
done
```

## エラーハンドリング

### 開発者からエラー報告を受けた場合

1. エラー内容を分析
2. 解決策を開発者に指示
3. 解決不能な場合はタスクを別の開発者に再割り当て

### 開発者が長時間応答しない場合

paneの状態を確認し、必要に応じて催促または再指示:

```bash
tmux capture-pane -t "$SESSION_NAME:$WINDOW_NUM.$DEV_PANE" -p -S -50
```

## 追加リソース

- **`references/communication-patterns.md`** - 通信パターンの詳細
- **`references/task-templates.md`** - タスク指示テンプレート集
