
# CS「Github版のエディタをVSCodeでビルドする」

2025-08-19 23:45:45

- [CS「Github版のエディタをVSCodeでビルドする」](#csgithub版のエディタをvscodeでビルドする)
    - [参考文献](#参考文献)
    - [規約](#規約)
    - [雑多メモ](#雑多メモ)
    - [環境構築まとめ](#環境構築まとめ)


## 参考文献

- C++ プログラミングのチュートリアル
    - https://dev.epicgames.com/documentation/ja-jp/unreal-engine/unreal-engine-cpp-programming-tutorials
- プログラミング クイック スタート ガイド
    - https://dev.epicgames.com/documentation/ja-jp/unreal-engine/unreal-engine-cpp-quick-start
- [UE5の「Lyra Starter Game」を展開して、プロジェクトの中身を見てみよう](https://gamemakers.jp/ue5_challenge1_1_sample_project)
- VSCodeで編集する方法
    - 外部のUnrealBuildToolが必要
    - VSが必須
    - https://zenn.dev/posita33/books/ue5_starter_cpp_and_bp_001/viewer/chap_01_vscode_setup
    - Build Tools for Visual Studioはライセンスが必要

## 規約

- GPT「Visual Studio Community は評価版や体験版ではありません」
- Visual Studioの規約や申請方法
    - [規約](https://visualstudio.microsoft.com/ja/license-terms/vs2022-ga-community/)
    - v.    お客様のユーザーは、人数に制限なく、本ソフトウェアを使用して、オンラインまたは対面の教室によるトレーニングおよび**教育の一環**として、または学術研究を実施するために、お客様のアプリケーションを開発およびテストすることができます。
    - vii.  お客様がエンタープライズである場合、お客様の従業員および契約社員は本ソフトウェアを使用して、お客様のアプリケーションを開発またはテストすることはできません。ただし、上記で許可されている (i) オープンソース、(ii) Visual Studio の拡張機能、(iii) Windows オペレーティング システムのデバイス ドライバー、(iv) SQL Server の開発、および **(v) 教育目的の場合を除きます**
    - GPT「企業内で利益を生まない学習目的   可能」

## 雑多メモ

- Microsoft C++ Build Tools
- https://argonauts.hatenablog.jp/entry/2023/02/22/192420
- https://visualstudio.microsoft.com/ja/visual-cpp-build-tools/
-  VS ライセンスなしでも clang-cl と組み合わせてるなどして VSCode で合法的に利用することができます!
- https://qiita.com/syoyo/items/3b830194fbd119de5003
- https://visualstudio.microsoft.com/ja/license-terms/vs2022-ga-diagnosticbuildtools/
- ～およびビルドツール
- Visual Studio ライセンスを有しているか否かにかかわらず～C++ コンポーネントをコンパイルして構築することができます
- VSCodeのビルド対象にUE5 PJが表示されない
- https://zenn.dev/posita33/books/ue5_starter_cpp_and_bp_001/viewer/chap_01_vscode_setup
- [Tools] &gt; [Generate Visual Studio Code Project]
- LiveCodingがビルドファイル数上限に引っかかる
- tasks.jsonやエディタ上からの上限変更がうまくいかず
- 一時的にLiveCodingを無効化
- VSCodeでビルドするとWSLで実行される
- WSL拡張を一時的に無効化した
- デフォルトターミナルをcmdに変えた
- Client/Server ターゲットのビルドが必要な場合はソース版UE5をGithubから落とす必要あり
- インストール版は既にコンパイル済みのエディタ
- ソース版に関してライセンス確認
- Build toolsは大丈夫そう
- [EULAはランチャー版と大差ない印象](https://www.unrealengine.com/ja/eula-reference/unreal-ja)
- GPTもそう言ってた
- [社内規約にはGithub版への注記がなさそう](https://sqex.sharepoint.com/sites/project/middleware/mwmanage/SitePages/Unreal-Engine-5%E5%B0%8E%E5%85%A5%E3%81%AE%E6%B5%81%E3%82%8C.aspx?csf=1&web=1&share=EYmQRBKXQbhHgrXg9mC1sv0B_VzVAeGF5bHUQo9NIVsa7g&e=Tmj0c7&CID=2f44f2d7-fbb7-4b84-81f4-61aade5bb6e3)
- GithubのReadmeを読む
- Windows エクスプローラーでソースフォルダーを開き、Setup.bat を実行します
- GenerateProjectFiles.bat を実行してエンジンのプロジェクトファイルを作成します
- 新しい UE5.sln ファイルをダブルクリックして Visual Studio にプロジェクトをロードします
- ソリューション構成を「Development Editor」に、ソリューションプラットフォームを「Win64」に設定し、UE5 ターゲットを右クリックして「ビルド」を選択します
- Visual Studio からエディターを実行するには、スタートアップ プロジェクトを UE5 に設定し、F5 キーを押してデバッグを開始
- ソース版のインストール
- https://www.main-function.com/entry/2024/08/31/131957
- https://dev.epicgames.com/documentation/ja-jp/unreal-engine/downloading-source-code-in-unreal-engine
- VSCodeの場合 GenerateProjectFiles.bat -vscode とする必要あり
- 「5.「UE5.sln」ファイルをダブルクリックして～」をVSCodeでどう設定するか
- 自前で.vscodeディレクトリに以下の2ファイルの生成が必要（GPT）
- Ctrl+Shift+B → Build UE5 Editor (Win64 Development) を選択
- 「実行するビルドタスクがありません」といわれるが、PJを開き直すと復活する


```json:tasks.json
{
"version": "2.0.0",
"tasks": [
{
"label": "Build UE5 Editor (Win64 Development)",
"type": "shell",
"command": "${workspaceFolder}/Engine/Build/BatchFiles/Build.bat",
"args": [
"UnrealEditor",
"Win64",
"Development"
],
"options": {
"cwd": "${workspaceFolder}"
},
"problemMatcher": []
}
]
}
```

```json:launch.json
{
"version": "0.2.0",
"configurations": [
{
"name": "Launch UE5 Editor",
"type": "cppvsdbg",
"request": "launch",
"program": "${workspaceFolder}/Engine/Binaries/Win64/UnrealEditor.exe",
"args": [],
"stopAtEntry": false,
"cwd": "${workspaceFolder}",
"environment": [],
"console": "internalConsole"
}
]
}
```


Using Parallel executor to run 383 action(s)
------ Building 383 action(s) started ------
[1/383] Compile [x64] Module.AudioSynesthesiaCore.cpp
C:\Users\katanagi\Documents\UnrealEngine-5.4.4-release\Engine\Plugins\Runtime\AudioSynesthesia\Source\AudioSynesthesiaCore\Private\PeakPicker.cpp(17) : error C4756: 定数演算でオーバーフローを起こしました。
   while compiling Audio::FPeakPicker::FPeakPicker
[2/383] Compile [x64] Module.LiveLink.cpp
C:\Users\katanagi\Documents\UnrealEngine-5.4.4-release\Engine\Plugins\Animation\LiveLink\Source\LiveLink\Private\LiveLinkClient.cpp(1728) : error C4756: 定数演算でオーバーフローを起こしました。      
   while compiling FLiveLinkClient_Base_DEPRECATED::PushSubjectData
[3/383] Compile [x64] Module.RenderCore.2.cpp
C:\Users\katanagi\Documents\UnrealEngine-5.4.4-release\Engine\Source\Runtime\RenderCore\Private\RenderGraphPrivate.cpp(189) : error C4756: 定数演算でオーバーフローを起こしました。
   while compiling GetClobberValue
[4/383] Compile [x64] Module.PoseSearch.3.cpp
C:\Users\katanagi\Documents\UnrealEngine-5.4.4-release\Engine\Plugins\Animation\PoseSearch\Source\Runtime\Private\PoseSearchLibrary.cpp(134) : error C4756: 定数演算でオーバーフローを起こしました。   
   while compiling FMotionMatchingState::Reset
Total time in Parallel executor: 84.24 seconds
Total execution time: 99.20 seconds





```log:
LINK : fatal error LNK1181: 入力ファイル 'delayimp.lib' を開けません。
```

- https://forums.unrealengine.com/t/fatal-error-lnk1181-cannot-open-input-file-delayimp-lib-in-association-with-attempting-to-create-a-new-plugin-from-a-ue5-provided-template/560614/5
    - A possible solution is to install the MSVC v142 - VS 2019 C++ build tools package (v14.29-16.11)
    - arm版を入れちゃってた

- 
- setup.bat
- Engine\Build\BatchFiles\GenerateProjectFiles.bat C:\UnrealEngine\Engine\LyraStarterGame\LyraStarterGame.uproject -Game -VSCode
    - うまくいかない
- Engine\Build\BatchFiles\GenerateProjectFiles.bat -VSCode
    - これで十分
- ブラウズしてSample/Game/Lyra～/～.uprojectを指定


```log:lyra-warning
The following modules are missing or built with a different engine version:

  LyraGame
  LyraEditor
  CommonGame
  CommonLoadingScreen
  CommonStartupLoadingScreen
  GameSubtitles
  CommonUser
  AsyncMixin
  UIExtension
  LyraExtTool
  GameplayMessageRuntime
  GameplayMessageNodes
  GameSettings
  ModularGameplayActors
  PocketWorlds
  ShooterCoreRuntime
  ShooterTestsRuntime
  TopDownArenaRuntime

Would you like to rebuild them now?
```

- ボツ
    - バイナリはどれがいいか
        - エンジン起動中にはビルドできないと言われる
    - Engine\Build\BatchFiles\Build.bat LyraEditor Win64 Development -Project="C:\UnrealEngine\Engine\LyraStarterGame\LyraStarterGame.uproject" -Game
    - git clone https://github.com/EpicGames/LyraStarterGame.git C:\UnrealEngine\Engine\LyraStarterGame
    - git checkout 5.4
    - C:\UnrealEngine-5.4.4\Engine\Build\BatchFiles\GenerateProjectFiles.bat -project="C:\UnrealEngine\Engine\LyraStarterGame\LyraStarterGame.uproject" -game -engine -vscode
    - C:\UnrealEngine-5.4.4\Engine\Build\BatchFiles\Build.bat C:\UnrealEngine\Engine\LyraStarterGame\LyraStarterGame.uproject Win64 Development

    - Engine\Build\BatchFiles\GenerateProjectFiles.bat -project="C:\UnrealEngine\Engine\Lyra\Lyra.uproject" -game -engine -vscode
        - 余計な引数は不要かも
    - Engine\Build\BatchFiles\Build.bat Lyra Win64 Development "C:\UnrealEngine\Samples\Games\Lyra\Lyra.uproject"
    - "C:\UnrealEngine\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.dll" Lyra Win64 Development -Project="C:\UnrealEngine\Samples\Games\Lyra\Lyra.uproject"

```log
C:\UnrealEngine>Engine\Build\BatchFiles\Build.bat Lyra Win64 Development "C:\UnrealEngine\Samples\Games\Lyra\Lyra.uproject" Using bundled DotNet SDK version: 6.0.302 Running UnrealBuildTool: dotnet "..\..\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.dll" Lyra Win64 Development "C:\UnrealEngine\Samples\Games\Lyra\Lyra.uproject" Log file: C:\UnrealEngine\Engine\Programs\UnrealBuildTool\Log.txt Using 'git status' to determine working set for adaptive non-unity build (C:\UnrealEngine). Creating makefile for Lyra (no existing makefile) Total execution time: 1.72 seconds Couldn't find target rules file for target 'Lyra' in rules assembly 'UE5Rules, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null' Location: C:\UnrealEngine\Engine\Intermediate\Build\BuildRules\UE5Rules.dll
```

## 環境構築まとめ

- 公式のGithub版エンジンのビルド方法
    - https://dev.epicgames.com/documentation/ja-jp/unreal-engine/downloading-source-code-in-unreal-engine
    - 一部vscode用のオプションが必要（後述）
- git clone https://github.com/EpicGames/LyraStarterGame.git C:\UnrealEngine\LyraStarterGame
    - git checkout 5.4
    - Engineディレクトリと同じ階層にDL
        - https://qiita.com/EGJ-Daiki_Terauchi/items/b81eed48bbbe969b28a4
- BuildToolsInstallerからx64のMSVC 14.38- とWindowsSDK 10.0.22621.0 or newer を入れる
    - https://dev.epicgames.com/documentation/en-us/unreal-engine/setting-up-visual-studio-development-environment-for-cplusplus-projects-in-unreal-engine?utm_source=chatgpt.com
    - Windows10 SDKも入れると安定するかも
    - 演算オーバーフロー系のエラーか何かが出た時にInstallerから修復して直ったことあり
- dotnet6が無ければインストールが必要かも
    - dotnet --list-sdks
    - https://dotnet.microsoft.com/en-us/download/dotnet/6.0
    - PATHを通す
        - powershell
            - $env:DOTNET_ROOT="C:\Program Files\dotnet"
        - cmd
            - set DOTNET_ROOT=C:\Program Files\dotnet
- Ctrl+Shift+B → Build UE5 Editor (Win64 Development) 

- Setup.bat
- Engine\Build\BatchFiles\GenerateProjectFiles.bat -project="C:\UnrealEngine\LyraStarterGame\LyraStarterGame.uproject" -game -engine -vscode
- Engine\Build\BatchFiles\Build.bat LyraEditor Win64 Development "C:\UnrealEngine\LyraStarterGame\LyraStarterGame.uproject"
- ランチャーでブラウズしてSample/Game/Lyra～/～.uprojectを指定

- LyraEditor.Target.cs
    - エディタ実行用。
    - UnrealEditor.exe と一緒に起動し、エディタで Lyra を開発できるようにする。
    - 普段はこれをビルドすれば十分。
    - エディタでの実行だけでよければこれだけでCL,SV処理は実行できるっぽい

- LyraClient.Target.cs
    - ゲームクライアント実行用。
    - パッケージングして実行ファイルとして配布する場合に使う。

- LyraServer.Target.cs
    - スタンドアローンのゲームサーバー実行用。
    - マルチプレイで専用サーバーを立てたいときに必要。

- LyraGame.Target.cs
    - ゲーム本体実行用。
    - エディタではなく「実行専用アプリ」として動かす場合。

- LyraGameEOS.Target.cs / LyraServerEOS.Target.cs
    - Epic Online Services (EOS) 対応版。
    - Epic のオンライン機能（マッチメイキングやフレンドなど）を使うビルド。

- ホットリロードは切った方が都度都度のコマンドラインビルドがしやすそう
    - Live Coding を無効化する
        - Edit → Editor Preferences
        - General → Miscellaneous → Live Coding
        - Enable Live Coding のチェックを外す
        - エディタを再起動
        - なんかHot reloadもあったから切っておく
    - 