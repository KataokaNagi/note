
# Create「blender-tutorial」

- 20251017

## 書き出してUnityに持っていく

- 背景
    - .blendファイルしかなくてUnityに持っていけない小物を買ってしまった

1. 書き出したいオブジェクトをヒエラルキーぽいところから選択
    1. ものによっては展開しないと選択したことにならないかも
2. File＞Export＞FBX
    1. Selected Objectsにチェック
    2. Object TypesをArmatureとMeshだけ選択
    3. Export
3. 上のTexturePaintタブをクリック（この操作が必要かはわからない）
    1. 左上のImage＞SaveAsでテクスチャを保存
4. Unityにテクスチャ、FBXの順でインポート
    1. FBXのMaterialのタブでExtractMaterial
    2. 吐き出したMaterialを好みのシェーダーに変える


## ワニでもわかるBlnder for VRChat

https://www.youtube.com/watch?v=Xg4AXYuzEqA&list=PLh2HlgtpWBpVI3GyRF-vBi-mqtG4ARJgc

- 第1回
    - セットアップ
        - テンキーが無い場合Preference＞Input＞EmulateNumpadにチェック
        - OrbitAroundSelectionにチェック
        - AutoのPersectiveを外す
        - ZoomToMousePositionにチェック
        - CtrlZで戻す回数を変える
            - Preference＞System＞UndoStepsを256くらいにする
    - カメラ
        - Shiftとホイール押し込み＋ドラッグで移動
    - 数字キー
        - １、３、７でXYZ視点
        - ５でパース切替え
            - 並行投影で進める
    - Modilingタブ
        - 左上をObjectModeにする（Tab）
        - Tで左のバーが見え隠れ TooloBox
            - G 移動 Grab
                - そのあとXYZ押せばその方向に
                - Shit＋XYZでそれ以外の方向に
            - R 回転 Rotate
            - S 拡縮 Scale
            - 押し出し
        - XでDelete（ハサミ）
        - 赤緑線の交差点のオレンジ丸にShift＋C
        - 球を出す
            - 上部のAdd＞Mesh＞Sphere
                - このときしかScale調整とかのウィンドウが左下に出ないので注意
        - Alt+辺クリックでループ選択
        - Grab時に他の頂点も引っ張りたい
            - 右上の乳首ボタンを押す
            - 乳首の右側
            - 右のグラフボタンでConnectOnly
            - ホイールで範囲を変えられる
                - 動いていないときは大体こいつが原因
        - 辺が
- 第2回
    - 頭はVRCでは0.4mほど？
    - １が正面
    - オブジェクトモードで右クリック＞ShadeAutoSmoothで滑らかに見える
    - E 押し出し Extension
    - スカートを閉じる
        - E S で拡縮方向に面が伸びる
        - M Merge To Center
        - F の面はりでもいいかも Fill
    - メッシュ分割
        - Ctrl＋Rでループカット
            - ホイールで分割数増減
    - GGで辺の上でGrabする
        - 縁取りとかに使う（ベベル）
    - 円柱を作る
        - CapFillTypeはNothing
    - 辺が見えない
        - 右上の丸4つの1番目でワイヤーフレーム表示する
        - 右の下矢印からBackground＞Customで背景色を変えられる
    - 3で真横から見る
    - 左右対称にミラーする
        - 右側のスパナ＞AddModifier＞ミラー
            - 対象軸が違う場合は変える
            - 編集し終わったら全て選択して適用する
            - オブジェクトモードでMirrorの上でCtrl+Aで適用できる
    - LでLink選択
    - 回転 RY-90
    - 手足と身体を結合
        - ObjectModeで全て選択
        - Ctrl+JでJoint（うまくいかない）
    - 原点を正す
        - 足に来るようにモデルをGrabする
        - 左上のObject＞SetOrigin＞OriginTo３DCursor
    - 右上からSphereからBodyとかに名前を変える
- 第3回
    - シーム（縫い目）をつける
        - 首などの境目をAlt選択
        - 編集モードで左上の辺＞シームをマーク
            - Ctrl＋Eでもいける
        - 水平方向のいい感じの切れ目
        - 背中の縦ライン
            - 頭と尻穴は除く
    - UV展開
        - UVEditingタブに変える
        - Aで全選択
        - 左上のUV＞展開
            - Angle Basedの方がTexToolsがききやすい（GPT）
    - UVの対応関係を整理する
        - Aで全選択してGで枠外に持っていく
        - L選択してHで消すなどしてどこに対応するか見る Hide
        - 左足や右足、左腕や右腕を合わせる
    - UVを長方形にする
        - GithubからTexToolsのzipを落とす
            - https://github.com/franMarz/TexTools-Blender/releases
        - Preference＞アドオン＞インストールからTexToolを入れる
        - L選択＞UV＞Rectify
            - 効かないときもありそう
            - 有償のZenUVかUVToolkitがよさそう
                - https://extensions.blender.org/add-ons/uv-toolkit/
            - 標準機能で面選択＞L選択＞アクティブ四角形面に追従 でもいいかも
    - ピンを打つ
        - A＞P で赤点がつく
        - 
    - TexturePaintタブでペイントしていく
        - UV上部の新規
            - 名称変更 tex_kabocha
            - かぼちゃぽい色にする
    - 右下のマテリアルタブ
        - 新規
        - 名称変更mat_kabocha
        - ベースカラーをの左ぽちからImageTexture
        - 画像としてさっきつくったテクスチャを選択
    - オブジェクトモードのプルダウンをクリックしてテクスチャペンとを選択
    - オブジェクトモードで右上のtex_pumpkin（テクスチャスロット）＞Mode＞Materialにする
    - 右側のスパナタブからカラーパレットが選べる
    - ブラシがもやっとしている場合
        - テクスチャ上部のタブをスクロールした右側、減衰（Faloff）をかくっとさせる
    - S スポイトして右のカラーパレットから色が取れる
    - 直線を引きたい
        - 左上のストローク＞ライン
    - 左上の画像＞保存
    - クリスタでUV編集する
        - https://cgbox.jp/2020/11/01/blender-texturepaint-illustration/
        - 左上のUV＞UV配置をエクスポート
    - 


- 雑Q&A
    - スケルトンみたいになった（ワイヤーフレーム）
        - 右上の球体を左から2番目
    - 辺が選択できない
        - 左上の辺モードをクリック
    - 隣接頂点を全て選択するのにはAltShiftクリックがよさそうｓ
    - 原点がズレた
        - Shift＋Sでカーソルをワールド原点へ
    - 円をUV展開すると半円2つになってしまう
        - 展開前の円が半円ごとに分離されているのでは？
            - 全選択 → メッシュ → クリーンアップ → 重複頂点を削除（Merge by Distance）
    - シームがないところで切れてUV展開されてしまう（首下の胸の横ライン）
        - Editモードで A 全選択 → M → By Distance を実行して重複頂点をマージ
        - Editモード → Shift + N で法線を外向きに再計算
        - Smooth by AngleなどのModifierを適用しておく
    - 右上の丸ボタンで薄くするといいかも
    - UVの線がみにくい
        - 編集 > プリファレンス > テーマ > UV/Image Editor ＞EdgeWdith
    - １，３，７の視点変更がきかなくなった
        - Preference＞Input＞テンキーを模倣
        - https://ytk-unityblog.sakura.ne.jp/316/blog/2023/02/19/
    - オブジェクト頂点を原点に置いたままオブジェクトを動かしたい
        - 編集モードで動かす
    - ベジエ曲線の2個目が追加できない
        - オブジェクトモードにする必要あり
    - ポリゴン数を確認したい
        - https://qiita.com/enumura1/items/1ad548e21b009884a12c
        - オブジェクトモードで右上の二重円＞Statistics
    - ポリゴン数を減らしたい
        - Altで辺を選択して右クリック＞DissolveEdges
    - リトポロジ
        - https://note.com/okara3d/n/n9dc7ae6c99fc
        - 面倒そうなので結合的なやつで対応する
    - Screw
        - 最初にScaleを0に潰すと変になる
        - オブジェクトモードで曲線を右クリックしてメッシュ化
        - プロパティのカメラとバツの間のボタンからApply
    - 点、辺、面モードのショートカット
        - PC上側の数字
    - 面の向きが逆
        - 右上のビューポートから面の向きを可視化できる
            - 青が表、赤が裏
        - Alt＋Nで面を反転
    - 分離したい
        - 


## 参考動画

- 【blender初心者】ミラーよくある失敗原因４選！
    - https://www.youtube.com/watch?v=1xFYA2nz-RY
    - ミラーとサブディビジョンサーフェスはこの順番に並べる
    - メッシュの数は偶数にすることで左右対称になる
- 【blender】シンプルな形で３次元トレースの練習（寸法は１ヵ所分かっていれば大丈夫！）
    - https://www.youtube.com/watch?v=uQWlLXd8mZY
- 皿とボウルのモデリング方法：初心者向けBlender 2.8モデリングチュートリアル
    - https://www.youtube.com/watch?v=vyZOZrtkzz8
    - PolyQuilt Retopology Tool
    - 

## 参考記事

- Blender単体で画像を3Dにモデリング
    - https://qiita.com/yt_kuboki/items/34bf5b461100eeffdafd

## 参考記事
- NormalMapOnline
    - https://cpetry.github.io/NormalMap-Online/
