#!/bin/bash
#
# tmux並列開発セッションセットアップスクリプト
# 現在のtmuxセッション内でpaneを分割して開発者を追加
#
# 使用方法:
#   ./setup-session.sh [開発者数] [作業ディレクトリ]
#
# 前提条件:
#   - tmuxセッション内で実行すること
#
# 引数:
#   開発者数: デフォルト 3
#   作業ディレクトリ: デフォルト 現在のディレクトリ

set -e

# 引数の取得
NUM_WORKERS=${1:-3}
WORK_DIR=${2:-$(pwd)}

# tmuxセッション内で実行されているか確認
if [ -z "$TMUX" ]; then
    echo "Error: このスクリプトはtmuxセッション内で実行してください" >&2
    echo "" >&2
    echo "以下の手順で実行してください:" >&2
    echo "  1. tmux を起動: tmux" >&2
    echo "  2. このスクリプトを実行" >&2
    exit 1
fi

# claudeコマンドが存在するか確認
if ! command -v claude &> /dev/null; then
    echo "Error: claude command is not found" >&2
    exit 1
fi

# 作業ディレクトリが存在するか確認
if [ ! -d "$WORK_DIR" ]; then
    echo "Error: Working directory does not exist: $WORK_DIR" >&2
    exit 1
fi

# 現在のセッション情報を取得
SESSION_NAME=$(tmux display-message -p '#S')
WINDOW_NUM=$(tmux display-message -p '#I')
MANAGER_PANE=$(tmux display-message -p '#P')

echo "Setting up parallel development environment..." >&2
echo "Session: $SESSION_NAME, Window: $WINDOW_NUM, Manager Pane: $MANAGER_PANE" >&2

# 開発者用のpaneを作成
for i in $(seq 1 "$NUM_WORKERS"); do
    echo "Creating pane for developer $i..." >&2
    tmux split-window -h -c "$WORK_DIR"
    tmux select-layout -t "$SESSION_NAME:$WINDOW_NUM" tiled
done

# マネージャーのpaneに戻る
tmux select-pane -t "$SESSION_NAME:$WINDOW_NUM.$MANAGER_PANE"

# 少し待機してからClaude Codeを起動
sleep 1

# pane一覧を取得
PANES=$(tmux list-panes -t "$SESSION_NAME:$WINDOW_NUM" -F "#{pane_index}")

# 開発者pane（マネージャー以外）のリストを作成
DEV_PANES=""
for pane in $PANES; do
    if [ "$pane" != "$MANAGER_PANE" ]; then
        DEV_PANES="$DEV_PANES $pane"
        echo "Starting claude in pane $pane..." >&2
        tmux send-keys -t "$SESSION_NAME:$WINDOW_NUM.$pane" "claude" Enter
        sleep 0.5
    fi
done

# セッション情報を出力（JSON形式）
echo "{\"session\": \"$SESSION_NAME\", \"window\": \"$WINDOW_NUM\", \"manager_pane\": \"$MANAGER_PANE\", \"dev_panes\": [${DEV_PANES// /, }], \"workers\": $NUM_WORKERS, \"workdir\": \"$WORK_DIR\"}"

# 補足情報を標準エラー出力に出力
echo "" >&2
echo "=== Setup Complete ===" >&2
echo "Session: $SESSION_NAME" >&2
echo "Window: $WINDOW_NUM" >&2
echo "Manager Pane: $MANAGER_PANE" >&2
echo "Developer Panes:$DEV_PANES" >&2
echo "Workers: $NUM_WORKERS" >&2
echo "Working directory: $WORK_DIR" >&2
echo "" >&2
echo "Communication commands:" >&2
echo "  Send to dev pane N: tmux send-keys -t '$SESSION_NAME:$WINDOW_NUM.N' 'message' Enter" >&2
echo "  Read pane N: tmux capture-pane -t '$SESSION_NAME:$WINDOW_NUM.N' -p -S -50" >&2
