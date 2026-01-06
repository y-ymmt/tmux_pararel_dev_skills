# tmux-parallel-dev

tmuxを使用した並列組織化開発プラグイン for Claude Code

## 概要

このプラグインは、1つのClaude Code（マネージャー）が複数のClaude Codeインスタンス（開発者）を管理し、並列開発を実現します。tmuxのpane分割機能を活用して、複数の開発タスクを同時に進行させることができます。

```
ユーザー
   ↓ 指示・フィードバック
マネージャー（このClaude Code）
   ↓ タスクキュー管理・レビュー
┌──┴──┬──────┐
開発者1  開発者2  開発者N
(pane1)  (pane2)  (paneN)
```

## 特徴

- **並列開発**: 複数のClaude Codeインスタンスが同時に作業
- **タスクキュー管理**: 優先順位に基づいたタスク割り当て
- **マネージャー/開発者モデル**: 効率的な作業分担とレビュー
- **リアルタイム進捗**: tmuxの分割画面で進捗を可視化

## 前提条件

- tmuxがインストールされていること
- Claude Codeがインストールされていること
- tmux内でClaude Codeを起動していること

## インストール

Claude Codeのプラグインとしてインストール:

```bash
claude plugins add https://github.com/yourusername/tmux_pararel_dev_skills
```

## 使用方法

### 基本的な使い方

tmux内でClaude Codeを起動し、以下のコマンドを実行:

```
/parallel-dev --workers 3 --task "Webアプリケーションの実装"
```

### パラメータ

| パラメータ | 説明 | デフォルト |
|-----------|------|-----------|
| `--workers` | 開発者の人数 | 3 |
| `--task` | 実行するタスクの説明 | (必須) |

### スキルの自動起動

以下のキーワードを含む指示でもスキルが自動的に起動します:
- 「並列開発」
- 「チーム開発」
- 「parallel-dev」
- 「複数人で開発」
- 「開発者を使って」
- 「マネージャーとして」

## タスク管理

### タスク分割の原則

- **タスク数 ≠ 開発者数**: 作業を適切な粒度で分割
- **優先順位**: 高優先度タスクから順に実行
- **キュー方式**: 完了した開発者に次のタスクを自動割り当て

### タスクキューの例

```
=== タスクキュー ===
1. [優先度: 高] データベーススキーマの作成 → 開発者1に割り当て
2. [優先度: 高] API基盤の実装 → 開発者2に割り当て
3. [優先度: 中] 認証機能の実装 → 開発者3に割り当て
4. [優先度: 中] フロントエンド基盤 → 待機中
5. [優先度: 低] テスト作成 → 待機中
```

## 通信プロトコル

開発者からマネージャーへの報告形式:

| プレフィックス | 意味 |
|--------------|------|
| `::DEVN_DONE::` | タスク完了 |
| `::DEVN_QUESTION::` | 質問 |
| `::DEVN_ERROR::` | エラー発生 |
| `::DEVN_PROGRESS::` | 進捗報告 |

## ディレクトリ構造

```
tmux_pararel_dev_skills/
├── .claude-plugin/
│   ├── plugin.json          # プラグイン定義
│   └── marketplace.json     # マーケットプレイス情報
├── commands/
│   └── parallel-dev.md      # /parallel-devコマンド定義
├── skills/
│   └── tmux-parallel-dev/
│       ├── SKILL.md         # スキル定義
│       ├── references/
│       │   ├── communication-patterns.md
│       │   └── task-templates.md
│       └── scripts/
│           └── setup-session.sh
└── README.md
```

## 作者

ymmt
