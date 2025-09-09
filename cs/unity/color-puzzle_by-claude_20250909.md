
# CS「color-puzzle_by-claude」

- 2025-09-09 23:17:16

## unity-mcpの導入

```md:.venvディレクトリのvenvの実行方法を教えて。 lsすると以下があります。 CACHEDIR.TAG Lib Scripts pyvenv.cfg
cd .\unity-mcp\server\

# PowerShell の場合
.\.venv\Scripts\Activate.ps1

# コマンドプロンプトの場合
.\.venv\Scripts\activate.bat

python server.py
```

- 公式doc
    - https://docs.anthropic.com/ja/docs/claude-code/mcp#json%E8%A8%AD%E5%AE%9A%E3%81%8B%E3%82%89mcp%E3%82%B5%E3%83%BC%E3%83%90%E3%83%BC%E3%82%92%E8%BF%BD%E5%8A%A0
    - !claude mcp add shared-server --scope project /path/to/server で適当な.mcp.jsonを生成
    - .mcp.jsonを編集
    - /exitかCtrl zで新しいClaudeに接続する
    - claude mcp list
- 参考
    - https://zenn.dev/karaage0703/articles/3bd2957807f311
    - https://zenn.dev/karaage0703/articles/42f7b0655a6af8
- 接続できない場合は claude --debugで詳細ログが確認可能
- powershellでclaudeコマンドを実行しないとfilesystemに接続できないので注意

```json:.mcp.json
{
  "mcpServers": {
    "github.com/modelcontextprotocol/servers/tree/main/src/filesystem": {
      "autoApprove": [],
      "disabled": true,
      "timeout": 60,
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "C:/Users/nagi/Documents/git/color-puzzle/ColorPuzzle"
      ]
    },
    "unity-mcp": {
      "autoApprove": [],
      "disabled": true,
      "timeout": 60,
      "type": "stdio",
      "command": "cmd.exe",
      "args": [
        "/c",
        "cd",
        "/d",
        "C:\\Users\\nagi\\Documents\\git\\color-puzzle\\ColorPuzzle\\unity-mcp\\server",
        "&&",
        "uv",
        "run",
        "server.py"
      ]
    }
  }
}
```



## 踏んだカラータイルを消す

```log
プレイヤーが色を取得した際に、プレイヤー直下のパネルの色がスタート地点にあるような真っ白なタイルになってほしい。 

以下のファイルが参考になるかと思います。
@/Assets\Scripts\Managers\PlayerManager.cs
@/Assets\Scripts\Managers\ColorTilemapManager.cs @/Assets\Scripts\Managers\TilemapManager.cs
@/Assets\Scripts\FieldObjects\ColorTilemap.cs
@/Assets\Scripts\FieldObjects\ExtendedTilemap.cs

必要に応じて @/Assets\Scenes\Kataoka\ColorPuzzleBase.unity にある @/Assets\Prefabs\WorkSpaces\ColorPuzzleSample.prefab を編集して。

必要に応じてUnity-MCPを利用して。
```
