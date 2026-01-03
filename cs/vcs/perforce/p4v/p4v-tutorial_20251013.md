
# CS「p4v-tutorial_20251013」

- 2025-10-13 18:08:29

## Perforce Helix Core Beginner’s Guide

https://www.youtube.com/watch?v=jIQEjDiSe0g&list=PLH3pq2J85xsPYn71_yzzsZQKvalTW-duE

- 日時指定のロールバックもある
- オフライン作業を検知
    - ルートディレクトリなどでReconcile offline work
- RevertのときにDelete～をチェックすると新規追加ファイルも消える

## Why & How to Shelve Files in Perforce Helix Core — Perforce U

https://www.youtube.com/watch?v=12oImpkmF34

- デフォルト設定ではシェルブ後に作業ファイルが消える
- GPT
    - 通常アンシェルブするとサーバ上のシェルブは消えない
        - 削除したい場合は「Shelved Files」タブで右クリック → Delete Shelved Files

## GPTに質問

- 除外したい場合はルートとかに.p4ignore
    - 例：.git/
    - 例：*.tmp
- P4Vで別のPCの自ユーザのチェックアウトを解除することはできますか
    - はい、**管理権限（adminまたはsuper権限）**を持っていれば可能です。
- チェックアウト中にチェックアウト漏れがあったファイルをチェックアウトに含めたい
    - 「チェックアウト漏れ」のファイルを右クリック → [Check Out]。
    - イアログの「変更リスト」で、既に開いている 同じ pending changelist を選択。