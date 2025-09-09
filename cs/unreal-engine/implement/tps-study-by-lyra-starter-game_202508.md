
# CS「LyraStarterGameによるTPSの学習」

- 2025-08-19 23:49:27

## フラッシュバンの追加

### 既存のグレネードの仕様確認

- 既存のtestモードでQを使えば投擲が可能
- LyraStarterGameで再生時に実行するゲームモードを固定する設定
    - Edit > Project Settings > Maps & Modes → Default Modes の GameMode Override でB_LyraGameModeから変更する
    - 既存レベル
        - 陣取り
        - フロントエンド（SELECTメニュー）
            - クイックプレイ
            - ゲームスタート
            - 対戦相手検索
        - レベル選択
        - ボンバーマン（マルチ）
        - ボンバーマン
        - 射撃練習場
        - テスト
- ワールド設定
- レベルを開き、Window > World Settings → GameMode Override に指定。このレベルを再生するときにだけ有効。
- 実装場所
    - 射撃練習場はL_ShooterPref
    - B_Grenade.uasset
        - ブループリントで実装されていそう
        - BPグループ
            - Pre stream grenade explosion
            - Prevent Pawn / Grenade from blocking one another
            - Setup VFX Trail with custom colors
            - Set Timers
            - Re-Enabling Pawn / Grenade Collision, allow Velocity to drive Rotation
            - Detonate Grenade
                - Fire gameplay cue for VFX, audio etc, hide Mesh and disable Projectile movement
                - On the server, capture all pawns in detonation radius
                - Only continue detonation checks if there were valid pawns in radius
                - Make effect context for the grenade damage gameplay effect, with throwing player as instigator
                - Iterate through all pawns in radius
                - set up our ignore actors list to contain every pawn in radius but the one we're cheking against
                - wait until NS_Trail completes before destroying grenade actor
                - Use weapon capsule trace to check for valid hit on current pawn target while ignoreing other pwans in radius so they dont block the hit
                - Apply grenade damage gameplay effect to applicable targets
            - Hit Event - trigger audio always, explode if hit Enemy Pawn
            - Teleport Grenade - conserve velocity brefore deactivating movement, teleport, then multiply the exit point forward vector by conserved velocity (clitely tamped down) to get new directional velocity and apply