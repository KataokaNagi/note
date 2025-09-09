
# CS「cline_unity_20250906」

- 2025-09-06 02:24:36

## 【UnityMCP】Claude Desktopを使ってコードを一切書かずに5時間でゲームを作った話 投稿日 2025年04月27日

- いすずさんの日本製Unity-mcp
    - https://github.com/isuzu-shiranui/UnityMCP/tree/v1.0.0
    - Unity2022以上のため不適

```md:unity-mcp比較 by gpt
以下、各 Unity-MCP 実装（zabaglione、CoplayDev、IvanMurzak）の評判を要点だけで報告します。

---
## CoplayDev / unity-mcp（Python 実装）

* GitHub で約 3.1k スター、402 フォークの人気度を保持。活発な採用傾向あり ([GitHub][1])。
* Reddit によると、**Unity-MCP の開発者が Coplay チームに参加して維持・改良が進んだ**との報告あり。ユーザへの週次フィーチャー数が 750 → 3,000 超へ向上したとされている ([Reddit][2])。

---

## zabaglione / Unity MCP Server（Node.js 実装）

* 機能が豊富。スクリプト、アセット、シーン、シェーダー、エディタ拡張、ビルド自動化などに対応 ([Glama – MCP Hosting Platform][3], [MCP.so][4])。
* Node.js 18.x 必須。Unity 2021.3＋対応 ([MCP.so][4], [Glama – MCP Hosting Platform][3])。
* Playbooks や MCP.so 等でもリストされているが、ユーザーの具体的な評価やレビュー情報は現時点では見当たらない。

---

## IvanMurzak の Unity-MCP（OpenUPM 実装）

* Unity と LLM を橋渡し。カスタムツールの定義にも対応。高度な柔軟性を掲げている ([GitHub][5])。
* Reddit ユーザーの報告：

  > "ive been using this for the past week. its great!" ([Reddit][6])
* マテリアル修正の例：

  * バージョン 0.6.2 で「LLM が Unity プロジェクト内の資産やコンポーネントの何千ものプロパティを認識・編集できるようになった」 ([Reddit][7])。

---

### 評判比較表（要点まとめ）

| 実装名                    | 評判・特徴概要                                                        |
| ---------------------- | -------------------------------------------------------------- |
| **CoplayDev/python**   | 活発なコミュニティ・開発速度上昇。GitHub 人気高([GitHub][1], [Reddit][2])。         |
| **zabaglione/node.js** | 機能充実。ただし、ユーザーからの評価投稿は現状不明。                                     |
| **IvanMurzak**         | 有用性ありとするユーザー報告あり。詳細な Asset/Component 編集向け機能も改善傾向([Reddit][6])。 |

```

- CoplayDev / unity-mcpを一旦採用
    - https://github.com/CoplayDev/unity-mcp
    - Unity2021対応とあるがv1.0.0でも使えなかった
        - Clineにコード修正させたら通った
        - lib64のアクセス権限についてエラーが出たが、WSLでなくWindows環境で構築させたら通った
- zabaglioneのMCP
    - https://github.com/zabaglione/mcp-server-unity
    - Claude製とのことで信頼性は不明
    - 2019+で使えそう
    - スター5件で見る人は少なそう
- IvanMurzak の Unity-MCP
    - https://github.com/IvanMurzak/Unity-MCP
    - 2022以降のサポートになってた
- mpc modelcontextprotocol/server-filesystem
    - https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem
    - cline_mcp_settings.jsonのフォーマットが合わない
        - 公式doc
            - https://docs.cline.bot/mcp/configuring-mcp-servers
        - 他の記事
            - https://zenn.dev/tmitsuoka0423/books/mcp-handson-guide/viewer/how-to-use-mcp-servers
            - argsは配列、他はオブジェクト
        - issue
            - https://github.com/cline/cline/issues/2459
        - clineに任せたらファイル再生成、文字コード変更、権限付与で解消した
    - clineのMCPのマーケットプレイスからインストールできた

```log:
次のMCPを導入して
https://github.com/CoplayDev/unity-mcp
↓
https://github.com/CoplayDev/unity-mcp.git?path=/UnityMcpBridge 
をパッケージマネージャを導入したときの以下のエラーを修正し、Unity2021で動くようにできますか。

Library\PackageCache\com.coplaydev.unity-mcp@741b4f7671\Editor\Tools\ManageGameObject.cs(1293,25): error CS0246: The type or namespace name 'FindObjectsInactive' could not be found (are you missing a using directive or an assembly reference?)

Library\PackageCache\com.coplaydev.unity-mcp@741b4f7671\Editor\Tools\ManageGameObject.cs(1294,31): error CS0103: The name 'FindObjectsInactive' does not exist in the current context

Library\PackageCache\com.coplaydev.unity-mcp@741b4f7671\Editor\Tools\ManageGameObject.cs(1295,31): error CS0103: The name 'FindObjectsInactive' does not exist in the current context

Library\PackageCache\com.coplaydev.unity-mcp@741b4f7671\Editor\Tools\ManageGameObject.cs(1302,41): error CS0117: 'Object' does not contain a definition for 'FindObjectsByType'

Library\PackageCache\com.coplaydev.unity-mcp@741b4f7671\Editor\Tools\ManageGameObject.cs(1305,37): error CS0103: The name 'FindObjectsSortMode' does not exist in the current context

なお、メモリーバンクの記録にv1.0.0でも動作しなかったとの記載がありますが、今回求めているのは最新版のコードの修正によって動作可能かを知ることです。
不可能な場合は理由を教えてください。
↓
ClineのManage MCP Serversの項目のうち
CoplayDev/unity-mcpの欄で
MCP error -32000: Connection closed
と表示されます。
↓
Cline側のManage MCP Serversで以下のエラーが出ています。
Using CPython 3.13.7 interpreter at: C:\Python313\python.exe error: failed to remove file `C:\Users\nagi\Documents\git\color-puzzle\ColorPuzzle\Library\PackageCache\com.coplaydev.unity-mcp@741b4f7671\UnityMcpServer~\src\.venv\lib64`: アクセスが拒否されました。 (os error 5) MCP error -32000: Connection closed
```
