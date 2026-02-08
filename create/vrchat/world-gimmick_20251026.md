
# create「world-gimmick_20251026」

- 2025-10-26 12:21:29

## ピックアップ

- ワールド固定
    - RigitBodyのIsKinematicをオン
- 持ったら持ちっぱなしにしたい
    - AutoHoldをYes
    - https://note.com/watahumi_mina/n/na7370d0dab29
- 回転させたい
    - AllowManipulationWhenEqquipedをオン
    - 多分Unity上ではテストできない

## ケーキを取り分けて皿に設置するギミック


- 設計
    - フォークを持つ
    - フォークのコライダーとケーキのコライダーが衝突している状態を検知する
        - フォークをUSEするとケーキが欠けたオブジェクトに変わり、フォークにケーキが生成されて刺さる
    - フォークをUSEするとケーキを離すことができる
    - ケーキは皿の近くで離すと吸い付く
- VRChat ワールドギミック 100サンプル集 の参考になりそうなギミック
    - https://tommyudonfactory.booth.pm/items/5461131
    - 22 オブジェクトがエリアに侵入したことを検知する
    - 34 オブジェクトをアクティブ化/非アクティブ化する
    - 35 コンポーネントをアクティブ化/非アクティブ化する
    - 51 Pickup オブジェクトを片付ける
    - 59 Pickup オブジェクトを呼び出す
    - 60 オブジェクトを指定した位置にはめ込む
    - 61 効果音を鳴らす


## U#入門

- doc
    - https://creators.vrchat.com/economy/sdk/udon-documentation/
- 別PJからU#を移したときにエラーが出る
    - U#のMissingに元のC#を入れてリコンパイル

