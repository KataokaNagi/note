
# CS「Giyhub copilot CLI」

- 2026-01-03 17:41:52

## CLIのメリット、デメリット

- https://www.reddit.com/r/GithubCopilot/comments/1nspuvg/what_are_the_advantages_of_github_copilot_cli/?tl=ja
    - VS Codeを完全に使わずにPhpStormだけで済む
        - VS2022だとp4 editできるかが心配
    - 自動化
- hepを見た感想
    - compactが可能
    - clearを打つのが速いかも
    - /share [file|gist] [path] - セッションを Markdown ファイルまたは GitHub Gist として共有
- 文脈を理解した長いコード生成にたけている by ChatGPT & 会社の先輩
- 過去のセッションの閲覧や再開ができない
- Jira等に貼るためのコピペに時間がかかる
- github copilot chatのような生成ファイルごとの差分表示すぐにできない
    - VSCを使えばいい話かもしれない
- 良くも悪くも応答が淡々としている
- CLIが原因かわからないがCRLFではなくLFで出力されエラーの原因となった

## 導入 2026-01-03 17:41:58

https://github.com/github/copilot-cli?utm_source=web-landing-repo&utm_campaign=agentic-copilot-cli-launch-2025&locale=ja

- wsl
    - curl -fsSL https://gh.io/copilot-install | bash
- 環境変数でCICDとかに認証情報を付与できそう？

```sh
copilot
login
```

```log
  ❯ 1. GitHub.com
    2. GitHub Enterprise Cloud with data residency (*.ghe.com)
```
の2は企業向けプラン。

```log
 The system vault (keychain, keyring, password manager, etc.) is not available. You may need to install one.

 Would you like to store the token in the plain text config file instead?

 ❯ 1. Yes, I accept that risk.
   2. No, I will login each time I use Copilot
```
Windowsの資格認証マネージャー等が見当たらない。
平文保存でよい場合は１、共有PCなどでは２で毎回ログイン

ghコマンド
https://github.com/cli/cli#installation
https://github.com/cli/cli/blob/trunk/docs/install_linux.md#debian

```sh
sudo apt update
sudo apt install gh
```

## ショートカット

/help

```log:EN 
 ● Global shortcuts:
     @ - mention files, include contents in the current context
     Esc - cancel the current operation
     ! - Execute the command in your local shell without sending to Copilot
     Ctrl+c - cancel operation if thinking, clear input if present, or exit
     Ctrl+d - shutdown
     Ctrl+l - clear the screenv

   Expand timeline content shortcuts:
     Ctrl+o - expand all timeline/collapse timeline
     Ctrl+r - expand recent timeline/collapse timeline

   Motion shortcuts:
     Ctrl+a - move to the beginning of the line
     Ctrl+e - move to the end of the line
     Ctrl+h - delete previous character
     Ctrl+w - delete previous word
     Ctrl+u - delete from cursor to beginning of line
     Ctrl+k - delete from cursor to end of line
     Meta+←/→ - move cursor by word

   Use ↑↓ keys to navigate command history

   Respects instructions sourced from various locations:
     `.github/instructions/**/*.instructions.md` (in git root and cwd)
     `.github/copilot-instructions.md`
     `AGENTS.md` (in git root and cwd)
     `CLAUDE.md`
     `GEMINI.md`
     `$HOME/.copilot/copilot-instructions.md`
     Additional directories via `COPILOT_CUSTOM_INSTRUCTIONS_DIRS`

   To learn about what I can do:
     Ask me "What can you do?"
     Or visit: https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli

   Available commands:
     /add-dir <directory> - Add a directory to the allowed list for file access
     /agent - Browse and select from available agents (if any)
     /clear - Clear the conversation history
     /compact - Summarize conversation history to reduce context window usage
     /context - Show context window token usage and visualization
     /cwd [directory] - Change working directory or show current directory
     /delegate <prompt> - Delegate changes to remote repository with AI-generated PR
     /exit, /quit - Exit the CLI
     /share [file|gist] [path] - Share session to markdown file or GitHub gist
     /feedback - Provide feedback about the CLI
     /help - Show help for interactive commands
     /list-dirs - Display all allowed directories for file access
     /login - Log in to Copilot
     /logout - Log out of Copilot
     /mcp [show|add|edit|delete|disable|enable] [server-name] - Manage MCP server configuration
     /model [model] - Select AI model to use
     /reset-allowed-tools - Reset the list of allowed tools
     /session - Show information about the current CLI session
     /skills [list|info|add|remove|reload] [args...] - Manage skills for enhanced capabilities
     /terminal-setup - Configure terminal for multiline input support (Shift+Enter and Ctrl+Enter)
     /theme [show|set|list] [auto|dark|light] - View or configure terminal theme
     /usage - Display session usage metrics and statistics
     /user [show|list|switch] - Manage GitHub user list
```

```md:JP
**● グローバルショートカット:**

* `@` - ファイルをメンションし、内容を現在のコンテキストに含める
* `Esc` - 現在の操作をキャンセル
* `!` - Copilot に送信せず、ローカルシェルでコマンドを実行
* `Ctrl+C` - 思考中の操作をキャンセル／入力があればクリア／終了
* `Ctrl+D` - シャットダウン
* `Ctrl+L` - 画面をクリア

**タイムライン内容の展開ショートカット:**

* `Ctrl+O` - タイムラインをすべて展開／折りたたみ
* `Ctrl+R` - 最近のタイムラインを展開／折りたたみ

**カーソル操作ショートカット:**

* `Ctrl+A` - 行の先頭へ移動
* `Ctrl+E` - 行の末尾へ移動
* `Ctrl+H` - 直前の文字を削除
* `Ctrl+W` - 直前の単語を削除
* `Ctrl+U` - カーソル位置から行頭まで削除
* `Ctrl+K` - カーソル位置から行末まで削除
* `Meta + ← / →` - 単語単位でカーソル移動

**↑↓ キーでコマンド履歴を移動可能**

**以下の場所から読み込まれる指示を尊重します:**

* `.github/instructions/**/*.instructions.md`（git ルートおよびカレントディレクトリ）
* `.github/copilot-instructions.md`
* `AGENTS.md`（git ルートおよびカレントディレクトリ）
* `CLAUDE.md`
* `GEMINI.md`
* `$HOME/.copilot/copilot-instructions.md`
* `COPILOT_CUSTOM_INSTRUCTIONS_DIRS` で指定された追加ディレクトリ

**できることを知りたい場合:**

* 「What can you do?」と質問する
* または以下を参照:
  [https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-copilot-cli)

**利用可能なコマンド:**

* `/add-dir <directory>` - ファイルアクセス許可リストにディレクトリを追加
* `/agent` - 利用可能なエージェントを閲覧・選択
* `/clear` - 会話履歴をクリア
* `/compact` - コンテキスト使用量削減のため会話履歴を要約
* `/context` - コンテキストウィンドウのトークン使用量と可視化を表示
* `/cwd [directory]` - 作業ディレクトリを変更／現在のディレクトリを表示
* `/delegate <prompt>` - AI 生成の PR としてリモートリポジトリへ変更を委任
* `/exit`, `/quit` - CLI を終了
* `/share [file|gist] [path]` - セッションを Markdown ファイルまたは GitHub Gist として共有
* `/feedback` - CLI に関するフィードバックを送信
* `/help` - 対話コマンドのヘルプを表示
* `/list-dirs` - ファイルアクセスが許可されている全ディレクトリを表示
* `/login` - Copilot にログイン
* `/logout` - Copilot からログアウト
* `/mcp [show|add|edit|delete|disable|enable] [server-name]` - MCP サーバー設定の管理
* `/model [model]` - 使用する AI モデルを選択
* `/reset-allowed-tools` - 許可済みツール一覧をリセット
* `/session` - 現在の CLI セッション情報を表示
* `/skills [list|info|add|remove|reload] [args...]` - 機能拡張用スキルの管理
* `/terminal-setup` - 複数行入力（Shift+Enter / Ctrl+Enter）対応のためターミナルを設定
* `/theme [show|set|list] [auto|dark|light]` - ターミナルテーマの表示／設定
* `/usage` - セッションの使用量メトリクスと統計を表示
* `/user [show|list|switch]` - GitHub ユーザー一覧の管理
```