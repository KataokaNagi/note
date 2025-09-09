
# CS「Claude」

- 2025-08-19 23:51:52

## 環境構築

- サインアップ
    - https://docs.anthropic.com/
    - Proでないとインタラクティブに編集できなさそう
- nodeを入れる
    - https://nodejs.org/ja
    - KP41になったのでnvmからnodeを入れ直すといいかも
        - C:\Users\nagi\AppData\Local\nvm\v22.18.0 を削除
- nvm install 22.18.0
    - nvm use 22.18.0
    - node -v
- npm install -g @anthropic-ai/claude-code
    - claude --version
    - npm list -g @anthropic-ai/claude-code
- VSCodeでClaude Code for VSCodeを入れる

## Youtube「最新AIエージェント！AnthropicのClaude Codeが凄かったので解説してみた」 2025/06/01

https://www.youtube.com/watch?v=tHoJAwrs1q

- ＠で対象ファイルを選択可能
- /cleanや/compactで履歴リセット
    - トークン節約になる
- 推奨手順
    - 1. まずはこのコードベースを理解してください と書く
        - /init でもできそう
    - 2. 設計
        - think, think hard, think harder, ultrathinkを付与するとよい
    - 3. 実装
    - 4. MCPでSSを撮って改善させていく
- テスト駆動開発も可能
- コマンド
    - https://docs.anthropic.com/ja/docs/claude-code/cli-reference

## 公式doc 2025-08-24 02:06:05

- 一般的なワークフロー
    - https://docs.anthropic.com/ja/docs/claude-code/common-workflows
- プロンプトライブラリ
    - https://docs.anthropic.com/ja/resources/prompt-library/library
    - あまりぱっとしない

## インストール

- NodeJSを入れる
    - https://nodejs.org/ja/about/previous-releases
    - v22がActiveLTS

```log
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
source ~/.bashrc
nvm install 22
nvm use 22
```

- doc
    - https://docs.anthropic.com/ja/docs/claude-code/setup

```log
npm install -g @anthropic-ai/claude-code
```

## /help

使用モード:
• REPL: claude (対話型セッション)
• 非対話型: claude -p 「質問内容」

すべてのコマンドラインオプションを確認するには claude -h を実行してください

 主な操作:
 • コードベースに関する質問 > foo.py の動作を教えてください
 • ファイル編集 > bar.ts を...に更新
 • エラー修正 > cargo build
 • コマンド実行 > /help
 • bash コマンド実行 > !ls

 対話モードコマンド:
  /add-dir - 新しい作業ディレクトリを追加
  /agents - エージェント設定を管理
  /bashes - バックグラウンドタスクの一覧表示と管理
  /clear - 会話履歴を消去しコンテキストを解放
  /compact - 会話履歴を消去するが要約をコンテキストに保持。オプション: /compact [要約指示]
  /config - 設定パネルを開く
  /context - 現在のコンテキスト使用状況を色分けグリッドで可視化
  /cost - 現在のセッションの総コストと所要時間を表示
  /doctor - Claude Codeのインストールと設定を診断・検証
  /exit - REPLを終了
  /export - 現在の会話をファイルまたはクリップボードにエクスポート
  /feedback - Claude Codeに関するフィードバックを送信
  /help - ヘルプと利用可能なコマンドを表示
  /hooks - ツールイベント用フック設定を管理
  /ide - IDE統合を管理しステータスを表示
  /init - コードベースドキュメント付き新規CLAUDE.mdファイルを初期化
  /install-github-app - リポジトリ用にClaude GitHub Actionsを設定
  /login - Anthropicアカウントでサインイン
  /logout - Anthropicアカウントからサインアウト
  /mcp - MCPサーバーを管理
  /memory - Claudeメモリファイルを編集
  /migrate-installer - グローバルnpmインストールからローカルインストールへ移行
  /model - Claude CodeのAIモデルを設定
  /output-style - 出力スタイルを直接または選択メニューから設定
  /output-style:new - カスタム出力スタイルを作成
  /permissions - ツール許可ルールの許可/拒否を管理
  /pr-comments - GitHubプルリクエストのコメントを取得
  /release-notes - リリースノートを表示
  /resume - 会話を再開
  /review - プルリクエストをレビュー
  /security-review - 現在のブランチで保留中の変更に対するセキュリティレビューを完了
  /status - バージョン、モデル、アカウント、API接続状態、ツールステータスを含むClaude Codeの状態を表示
  /statusline - Claude CodeのステータスラインUIを設定
  /todos - 現在のToDo項目を一覧表示
  /upgrade - より高いレート制限と追加のOpus機能のためMaxにアップグレード
  /vim - Vimモードと通常編集モードを切り替え

詳細はこちら: https://docs.anthropic.com/s/claude-code


## claude -h

