
# CS「unity-mcp-setup_by-claude_20250925」

- 2025-09-25 00:15:02


## youtube-mcp

https://zenn.dev/takna/articles/mcp-server-tutorial-03-youtube#%E2%9C%A8-youtube-mcp%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC

1. pourshell  winget install yt-dlp
2. ClaudeCodeを開いている場合は再起動
3. MCPサーバー @anaisbetts/mcp-youtube をインストールして
4. /clear

```log: fix warning
以下の警告が出ています\
  [Contains warnings] User config (available in all your projects)
  Location: C:\Users\nagi\.claude.json
   └ [Warning] [filesystem] mcpServers.filesystem: Windows requires 'cmd /c' wrapper to execute npx

│ Edit file                                                                                                                       │
│ ╭─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────╮ │
│ │ ..\..\..\..\..\.claude.json                                                                                                 │ │
│ │                                                                                                                             │ │
│ │   575      "mcpServers": {                                                                                                  │ │
│ │   576        "filesystem": {                                                                                                │ │
│ │   577          "type": "stdio",                                                                                             │ │
│ │   578 -        "command": "npx",                                                                                            │ │
│ │   578 +        "command": "cmd",                                                                                            │ │
│ │   579          "args": [                                                                                                    │ │
│ │   580 +          "/c",                                                                                                      │ │
│ │   581 +          "npx",                                                                                                     │ │
│ │   582            "-y",                                                                                                      │ │
│ │   583            "@modelcontextprotocol/server-filesystem"                                                                  │ │
│ │   584          ], 
```

## @modelcontextprotocol/server-filesystem

https://qiita.com/iineineno03k/items/d718874c87d3f57fd4c2

1. !claude mcp add filesystem --scope user -- npx -y @modelcontextprotocol/server-filesystem
2. !claude mcp list


## CoplayDev/unity-mcp 

https://github.com/CoplayDev/unity-mcp

1. Unity の Package Manager を使って “Add package from git URL… で以下を追加
    1. https://github.com/CoplayDev/unity-mcp.git?path=/UnityMcpBridge
    2. Window＞MCP for Unityを起動
    3. SetupやらStartやらひ必要に応じて押下
2. MCPサーバー https://github.com/CoplayDev/unity-mcp をインストールして
3. !claude mcp list
    1. もし古いのが残ってたら「古い unity-mcp エントリは削除して」
4. /clear

```log
● Bash(claude mcp --help)
  ⎿  Usage: claude mcp [options] [command]

     Configure and manage MCP servers
     … +15 lines (ctrl+o to expand)

● Bash(claude mcp add unity-mcp https://github.com/CoplayDev/unity-mcp)
  ⎿ Added stdio MCP server unity-mcp with command: https://github.com/CoplayDev/unity-mcp  to local config
    File modified: C:\Users\nagi\.claude.json [project: C:\Users\nagi\Documents\git\vrc\Worlds\VRChatGrandAutumnSportsFestival
    2025]\

● Unity MCP サーバーがインストールされました。設定は ~/.claude.json に保存されています。
```

## /init

- 
