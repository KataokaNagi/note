
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

## AI生成物の説明

```md:LyraProjectileBase.h
各行を初心者向けに分解する。

---

### `UCLASS(Abstract, BlueprintType, Blueprintable)`

* `UCLASS` は UE5 のマクロ。クラスを Unreal のリフレクションシステム（エディタやBlueprintで使える仕組み）に登録する。
* `Abstract` → 抽象クラス。直接インスタンス化できない。継承して使う。
* `BlueprintType` → Blueprint でこのクラスを型として扱える。
* `Blueprintable` → このクラスを元に Blueprint を作れる。

---

### `class LYRAGAME_API ALyraProjectileBase : public AActor, public IAbilitySystemInterface`

* `class` → C++ のクラス定義。
* `LYRAGAME_API` → DLL 出力用マクロ。モジュール外からこのクラスを使えるようにする。
* `ALyraProjectileBase` → クラス名。慣習として `A` で始まるのは `AActor` を継承したクラス。
* `: public AActor` → Unreal の基礎クラス `AActor` を継承。ゲーム世界に存在できるオブジェクトになる。
* `, public IAbilitySystemInterface` → ゲーム能力（GAS）用のインターフェイスを実装する。

---

### `{ GENERATED_BODY() }`

* `GENERATED_BODY()` → UE のコード生成マクロ。リフレクションやシリアライズ用のコードを自動で埋め込む。
* `{ }` はクラス本体の開始と終了。

---

### `public:`

* アクセス指定子。ここから下に書いたメンバは外部から呼び出せる。

---

### `ALyraProjectileBase(const FObjectInitializer& ObjectInitializer = FObjectInitializer::Get());`

* コンストラクタ。クラスが生成されるときに呼ばれる。
* `const FObjectInitializer&` は UE 独自の初期化ヘルパー。コンポーネントを安全に作成するために使う。
* `= FObjectInitializer::Get()` はデフォルト引数。呼び出し側が何も渡さなくても使える。

---

### `protected:`

* この指定子以降は派生クラスからはアクセスできるが、外部からはできない。

---

### `virtual void BeginPlay() override;`

* `BeginPlay()` は UE のライフサイクルイベント。
* Actor がワールドに登場した直後に1回呼ばれる。
* `virtual` は仮想関数。子クラスで上書きできる。
* `override` は親クラスの関数を上書きしていることを明示する。

---

### `virtual void EndPlay(const EEndPlayReason::Type EndPlayReason) override;`

* `EndPlay()` は Actor がゲーム世界から削除されるときに呼ばれる。
* 引数 `EndPlayReason` で削除理由（ゲーム終了、破壊、レベル遷移など）が分かる。
* こちらも `virtual` + `override` で上書き。

---

まとめると、このクラスは

* UE5 の `Actor` を基底にした抽象クラス。
* Blueprint から使えて拡張できる。
* GAS に対応。
* コンストラクタ、生成時、終了時の処理を定義できる。

順番に整理する。

---

### `LYRAGAME_API`

* Unreal ではモジュール単位で DLL を作る。
* `LYRAGAME_API` は「このクラスを外部モジュールから利用できるようにする」ためのエクスポート／インポートマクロ。
* モジュールごとに名前が違う（LyraGame モジュールなら `LYRAGAME_API`）。
* エディタや他モジュールからこのクラスを参照するときに必要。

---

### GAS (Gameplay Ability System)

* キャラクターのスキルやバフ／デバフを共通的に扱う仕組み。
* `IAbilitySystemInterface` を実装することで、この Actor に「AbilitySystemComponent」を持たせられる。
* これによりアビリティ（スキル）や GameplayEffect（状態異常・数値補正）を適用できる。

---

### `FObjectInitializer`

* Unreal 独自の初期化ヘルパー。
* コンストラクタで `CreateDefaultSubobject` を呼ぶときに必要。
* **常に書く必要はない**。コンポーネントを組み立てるクラスなら使うことが多いが、シンプルなクラスなら省略可能。
* UE5 ではだいぶ簡略化されていて、何も書かないコンストラクタも普通に使われる。

---

### `const EEndPlayReason::Type EndPlayReason`

* `EndPlayReason` は「読み取り専用」の意味で `const` が付いている。
* 関数内で変更する必要がないから、コンパイラに「この値は変えない」と宣言している。
* 実際に変更してしまうと終了理由があいまいになり、バグの原因になるので保護している。
* 引数が構造体や大きなデータ型なら「参照 + const」が一般的。これは安全かつ効率的。

---

要するに:

* `LYRAGAME_API` → モジュール外アクセス用マクロ
* GAS → スキルや効果システムを統合管理する仕組み
* `FObjectInitializer` → サブオブジェクト初期化に使う。必須ではない
* `const EndPlayReason` → 呼び出し元の値を勝手に変えないよう保証

---

「モジュール単位で DLL を作る」を分解する。

---

### 1. Unreal のビルドの基本

* UE5 ではプロジェクトやプラグインは **モジュール単位** で管理される。
* 各モジュールはコンパイルすると **ひとつの DLL（Windowsの場合）や dylib（Macの場合）** になる。
* ゲーム実行時は、必要な DLL をロードして使う。

---

### 2. `XXX_API` マクロの役割

* DLL に入っているクラスや関数を、他の DLL からも使えるようにするには「エクスポート」が必要。
* 逆に、外の DLL から読み込むときは「インポート」が必要。
* C++ ではこれを `__declspec(dllexport)` / `__declspec(dllimport)` で指定する。

例:

```cpp
// DLL を作る側
__declspec(dllexport) class MyClass { ... };

// DLL を使う側
__declspec(dllimport) class MyClass { ... };
```

* Unreal はモジュールごとに自動でこれを切り替える。
* そのために `LYRAGAME_API` というマクロを挟んでいる。

---

### 3. 具体例

LyraGame モジュールをビルドしたら → `LyraGame.dll` ができる。

```cpp
class LYRAGAME_API ALyraProjectileBase : public AActor { ... };
```

* このとき、LyraGame モジュールをコンパイルしているときは `LYRAGAME_API` = `__declspec(dllexport)`。
* 他のモジュール（例: LyraEditor.dll）から使うときは `LYRAGAME_API` = `__declspec(dllimport)`。

---

### 4. まとめ

* UE5 の「モジュール」は C++ プロジェクトのまとまり。
* モジュールごとに DLL が生成される。
* `XXX_API` マクロで DLL の境界を越えてクラスを使えるようにする。

この部分は「弾の内部データ（コンポーネントや状態管理の変数）」をまとめている。どんな機能を持つ弾かが分かる。

---

### **CollisionComponent**

```cpp
TObjectPtr<USphereComponent> CollisionComponent;
```

* 球状の当たり判定。
* 弾が他の Actor に当たったことを検知する。

---

### **MeshComponent**

```cpp
TObjectPtr<UStaticMeshComponent> MeshComponent;
```

* 見た目の 3D モデル。
* 弾の形状を表示するため。

---

### **MovementComponent**

```cpp
TObjectPtr<UProjectileMovementComponent> MovementComponent;
```

* 弾を自動で直進させたり、重力や反射を計算するコンポーネント。
* `InitialSpeed` や `bShouldBounce` などが設定できる。

---

### **AudioComponent**

```cpp
TObjectPtr<UAudioComponent> AudioComponent;
```

* 飛んでいる音や爆発音などを再生するため。

---

### **ParticleComponent**

```cpp
TObjectPtr<UParticleSystemComponent> ParticleComponent;
```

* 視覚効果（火花、煙、光など）を出すためのパーティクル。

---

### **DetonationTime**

```cpp
float DetonationTime = 3.0f;
```

* 自動爆発までの時間。
* 0 の場合は「自動爆発しない」。

---

### **bExplodeOnImpact**

```cpp
bool bExplodeOnImpact = false;
```

* 何かに当たった瞬間に爆発するかどうか。

---

### **bStickToSurfaces**

```cpp
bool bStickToSurfaces = false;
```

* 衝突時に「爆発せず表面にくっつく」かどうか。
* グレネード的な挙動。

---

### **EffectTags**

```cpp
FGameplayTagContainer EffectTags;
```

* この弾が与える効果をタグで管理。
* 例: 「火傷」「毒」「スタン」などを Gameplay Effect として適用。

---

### **DetonationTimerHandle**

```cpp
FTimerHandle DetonationTimerHandle;
```

* タイマー管理用。
* `DetonationTime` 秒後に `OnExplode()` を呼ぶために使う。

---

### **bHasExploded**

```cpp
bool bHasExploded = false;
```

* すでに爆発したかどうかを管理。
* 二重爆発を防ぐ。

---

### **HasExploded()**

```cpp
bool HasExploded() const { return bHasExploded; }
```

* 派生クラスが「もう爆発済みか？」を確認できるようにする。

---

### **InstigatorAbilitySystemComponent**

```cpp
TObjectPtr<UAbilitySystemComponent> InstigatorAbilitySystemComponent;
```

* 弾を撃った側の `AbilitySystemComponent` をキャッシュして保持。
* 爆発時に「誰が撃ったか」を判別して、効果やダメージの帰属先を決めるため。

---

まとめるとこの部分は、

* **弾そのものの構造（当たり判定・見た目・移動・音・パーティクル）**
* **爆発条件（時間経過・衝突・貼り付き）**
* **効果の種類（タグ）**
* **内部状態（爆発済みかどうか、撃った人の情報）**

を全部カプセル化している。
```


```md:LyraProjectileBase.cpp
順に説明する。

```cpp
ALyraProjectileBase::ALyraProjectileBase(const FObjectInitializer& ObjectInitializer)
: Super(ObjectInitializer)
```

* `ALyraProjectileBase` のコンストラクタ定義。
* `Super(ObjectInitializer)` は親クラス（`AActor`など）のコンストラクタ呼び出し。

```cpp
PrimaryActorTick.bCanEverTick = true;
```

* `Tick` 関数を毎フレーム呼べるようにするフラグ。
* trueにすると `Tick(float DeltaTime)` が動く。

```cpp
CollisionComponent = CreateDefaultSubobject<USphereComponent>(TEXT("CollisionComponent"));
```

* 球状のコリジョン（当たり判定）コンポーネントを生成。
* `TEXT("CollisionComponent")` はエディタ内での名前。

```cpp
CollisionComponent->SetSphereRadius(5.0f);
```

* コリジョンの半径を 5 ユニットに設定。

```cpp
CollisionComponent->SetCollisionEnabled(ECollisionEnabled::QueryAndPhysics);
```

* 衝突判定を「物理＋クエリ（ヒット検出）」の両方で有効化。

```cpp
CollisionComponent->SetCollisionResponseToAllChannels(ECR_Block);
```

* 全てのオブジェクトとの衝突に「ブロック」で応答するよう設定。

```cpp
CollisionComponent->SetCollisionResponseToChannel(ECC_Pawn, ECR_Ignore);
```

* `Pawn`（キャラクターなど）に対しては衝突を無視。

```cpp
CollisionComponent->SetCollisionResponseToChannel(ECC_WorldStatic, ECR_Block);
CollisionComponent->SetCollisionResponseToChannel(ECC_WorldDynamic, ECR_Block);
```

* `WorldStatic`（壁や地面など動かないもの）、`WorldDynamic`（動くオブジェクト）に対してはブロック。

```cpp
RootComponent = CollisionComponent;
```

* このアクターの「ルートコンポーネント」をコリジョンに設定。
* つまり、このアクターの位置や回転の基準がコリジョンになる。

---

要点: **弾のようなアクターに「球形コリジョン」を持たせて、動く物・動かない物には当たるが、Pawnは無視する設定をしているコンストラクタ**。


それぞれ解説する。

```cpp
// Create mesh component
MeshComponent = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("MeshComponent"));
MeshComponent->SetupAttachment(RootComponent);
MeshComponent->SetCollisionEnabled(ECollisionEnabled::NoCollision);
```

* 弾の**見た目用メッシュ**を作成。
* `RootComponent`（= CollisionComponent）にアタッチ。
* 見た目だけなので衝突判定は無効化。

```cpp
// Create movement component
MovementComponent = CreateDefaultSubobject<UProjectileMovementComponent>(TEXT("MovementComponent"));
MovementComponent->UpdatedComponent = CollisionComponent;
MovementComponent->InitialSpeed = 1200.0f;
MovementComponent->MaxSpeed = 1200.0f;
MovementComponent->bRotationFollowsVelocity = true;
MovementComponent->bShouldBounce = true;
MovementComponent->Bounciness = 0.3f;
MovementComponent->ProjectileGravityScale = 1.0f;
```

* **弾の移動制御用コンポーネント**。
* `UpdatedComponent = CollisionComponent` → 移動の基準をコリジョンにする。
* `InitialSpeed` / `MaxSpeed` → 発射直後と最大速度を 1200 に設定。
* `bRotationFollowsVelocity = true` → 移動方向にモデルが自動回転する。
* `bShouldBounce = true` → 壁などに当たると跳ね返る。
* `Bounciness = 0.3f` → 反射の強さ（30%の反発力）。
* `ProjectileGravityScale = 1.0f` → 通常の重力を受ける。

```cpp
// Create audio component
AudioComponent = CreateDefaultSubobject<UAudioComponent>(TEXT("AudioComponent"));
AudioComponent->SetupAttachment(RootComponent);
```

* 音再生用コンポーネント。
* ルートにアタッチされるので弾と一緒に動く。

```cpp
// Create particle component
ParticleComponent = CreateDefaultSubobject<UParticleSystemComponent>(TEXT("ParticleComponent"));
ParticleComponent->SetupAttachment(RootComponent);
```

* パーティクル再生用コンポーネント（軌跡や煙など）。
* ルートにアタッチ。

```cpp
// Bind hit event
CollisionComponent->OnComponentHit.AddDynamic(this, &ALyraProjectileBase::OnHit);
```

* コリジョンが何かに当たった時に `OnHit` 関数を呼ぶよう登録。
* `&ALyraProjectileBase::OnHit` → 自作のヒット処理関数。

```cpp
// Set default values
DetonationTime = 3.0f;
bExplodeOnImpact = false;
bStickToSurfaces = false;
bHasExploded = false;
```

* プロジェクタイルの**カスタム変数の初期化**。

  * `DetonationTime = 3.0f` → 3秒後に爆発。
  * `bExplodeOnImpact` → 衝突即爆発するかどうか。
  * `bStickToSurfaces` → 壁にくっつくかどうか。
  * `bHasExploded` → すでに爆発したかどうか。

```cpp
// Set lifespan
SetLifeSpan(10.0f);
```

* アクターの寿命を10秒に設定。
* 10秒経過すると自動的に破棄される。

---

まとめると：
このコードは「弾丸アクター」の\*\*見た目（Mesh）、移動（ProjectileMovement）、音（Audio）、エフェクト（Particle）\*\*を揃え、**当たり判定を設定**し、**爆発の条件や寿命**を初期化している。

→ これで「撃たれたら飛んで、跳ね返って、当たったら処理する弾」が完成する。


コードの各部分を説明する。

---

```cpp
void ALyraProjectileBase::BeginPlay()
{
    Super::BeginPlay();
```

* アクターがゲーム開始時、またはスポーン時に呼ばれる初期化処理。
* `Super::BeginPlay()` で親クラスの処理も実行。

```cpp
// Cache instigator's ability system component
if (GetInstigator())
{
    if (ALyraCharacter *LyraCharacter = Cast<ALyraCharacter>(GetInstigator()))
    {
        InstigatorAbilitySystemComponent = LyraCharacter->GetAbilitySystemComponent();
    }
}
```

* `GetInstigator()` → この弾を撃った「元のアクター」を取得。
* `Cast<ALyraCharacter>` → その発射者が `ALyraCharacter` 型ならキャスト。
* 成功すれば、そのキャラの **AbilitySystemComponent** をキャッシュして保持。
* 目的：後で「誰が撃った弾か」を能力システムで参照できるようにする。

```cpp
// Start detonation timer if configured
if (DetonationTime > 0.0f)
{
    GetWorld()->GetTimerManager().SetTimer(
        DetonationTimerHandle,
        this,
        &ALyraProjectileBase::OnExplode,
        DetonationTime,
        false);
}
```

* `DetonationTime` が正なら、爆発タイマーを開始。
* `SetTimer` で `DetonationTime` 秒後に `OnExplode()` を呼ぶよう設定。
* `false` → 1回だけ実行。

---

```cpp
void ALyraProjectileBase::EndPlay(const EEndPlayReason::Type EndPlayReason)
{
    // Clean up timers
    if (GetWorld())
    {
        GetWorld()->GetTimerManager().ClearTimer(DetonationTimerHandle);
    }

    Super::EndPlay(EndPlayReason);
}
```

* アクターが削除されるときの処理。
* タイマーをクリアして、不要なコールバックを残さないようにする。
* 最後に親クラスの処理も呼ぶ。

---

```cpp
void ALyraProjectileBase::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}
```

* 毎フレーム呼ばれる処理。
* ここでは親クラスの `Tick` を呼んでいるだけ。
* 将来的にカスタム処理を追加できる場所。

---

```cpp
UAbilitySystemComponent *ALyraProjectileBase::GetAbilitySystemComponent() const
{
    return InstigatorAbilitySystemComponent;
}
```

* この弾の「発射者の能力システム」を返す関数。
* Gameplay Ability System と連携するための実装。
* 例えばダメージや効果適用のときに使う。

---

まとめると：
この部分は **弾のライフサイクル管理**（開始・終了・毎フレーム更新）、**発射者の能力システムを保持する仕組み**、**爆発タイマーの起動と破棄**を実装している。

---

次の処理が `OnHit` と `OnExplode` になるはず。そこまで説明が必要？

はい、`ALyraCharacter *LyraCharacter` は **ポインタ** です。
順を追って説明します。

---

### 1. 行の処理の流れ

```cpp
if (ALyraCharacter *LyraCharacter = Cast<ALyraCharacter>(GetInstigator()))
```

1. `GetInstigator()`

   * 弾を撃ったアクターを返す。戻り値の型は `APawn*`（ポインタ）。

2. `Cast<ALyraCharacter>(...)`

   * `APawn*` を安全に `ALyraCharacter*` に変換。
   * 成功すれば `ALyraCharacter*` を返し、失敗すれば `nullptr` を返す。

3. `ALyraCharacter *LyraCharacter = ...`

   * 変換が成功すれば `LyraCharacter` にそのポインタを代入。

4. `if (...)`

   * `LyraCharacter` が `nullptr` でなければ true。
   * つまり「発射者が LyraCharacter のときだけ中身の処理をする」。

---

### 2. ポインタが使われている理由

UE5（C++）では多くのオブジェクトは **ヒープ領域に動的に生成**される。
このときオブジェクトそのものではなく「参照先アドレス（ポインタ）」を扱う。

例:

```cpp
ALyraCharacter* Ptr = new ALyraCharacter(); // 動的生成
```

* メモリ上に `ALyraCharacter` が作られ、`Ptr` はその場所を指す。
* Unreal では `new` の代わりに `SpawnActor` や `CreateDefaultSubobject` が内部で使われており、それらはポインタを返す。

---

### 3. Unreal Engine でポインタを使う場面

* **アクターやコンポーネントの参照**
  → `AActor*`, `UStaticMeshComponent*` など。
* **Spawn 系関数の戻り値**
  → `GetWorld()->SpawnActor<>()` は `AActor*` を返す。
* **キャスト結果**
  → `Cast<>()` は成功時に `ポインタ`、失敗時に `nullptr` を返す。
* **AbilitySystemComponent のようなサブシステム**
  → 他のオブジェクトから参照できるようにポインタで持つ。

---

### 4. `UAbilitySystemComponent *ALyraProjectileBase::GetAbilitySystemComponent() const`

* 戻り値が `UAbilitySystemComponent*`。
* これは「実体を返す」のではなく「その場所を指すポインタを返す」。
* ポインタで返すことで「存在しなければ `nullptr`」「存在すれば同じインスタンスを共有」という挙動になる。
* 値をコピーするのではなく、同じオブジェクトを参照できるのが重要。

---

### まとめ

* `*LyraCharacter` は **キャスト成功したら入るポインタ変数**。
* UE5 ではアクターやコンポーネントは動的生成されるのでポインタで扱うのが基本。
* ポインタを返すことで「存在しないときは `nullptr` 」「存在する場合は同じオブジェクトを参照」という扱いができる。

このコードは **「フラッシュバンを投げるアビリティ」** を Unreal Engine 5 の Gameplay Ability System (GAS) で実装しているもの。CPP初心者向けに要素ごとに分解して説明する。

---

### コンストラクタ部分

```cpp
ULyraGameplayAbility_ThrowFlashbang::ULyraGameplayAbility_ThrowFlashbang(const FObjectInitializer &ObjectInitializer)
    : Super(ObjectInitializer)
{
```

* **コンストラクタ**。クラスを生成するときに一度だけ呼ばれる初期化処理。
* `: Super(ObjectInitializer)` は親クラス (`UGameplayAbility`) のコンストラクタを呼んでいる。

---

#### Ability関連の設定

```cpp
    InstancingPolicy = EGameplayAbilityInstancingPolicy::InstancedPerActor;
```

* アビリティのインスタンス化ポリシーを設定。
* `InstancedPerActor` → 各キャラクターごとにアビリティのインスタンスを持つ。

```cpp
    ReplicationPolicy = EGameplayAbilityReplicationPolicy::ReplicateNo;
```

* アビリティがネットワークでどう同期されるか。
* `ReplicateNo` → このアビリティは複製しない（サーバーには送らない）。

```cpp
    NetExecutionPolicy = EGameplayAbilityNetExecutionPolicy::LocalPredicted;
```

* アビリティをどこで実行するか。
* `LocalPredicted` → クライアント側で予測的に動作させる。

---

#### 投げる動作のパラメータ

```cpp
    BaseThrowSpeed = 1000.0f;
    MaxThrowSpeed = 1500.0f;
    MinThrowAngle = -10.0f;
    MaxThrowAngle = 45.0f;
    SpawnOffset = FVector(100.0f, 0.0f, 0.0f);
    CooldownDuration = 8.0f;
    MaxFlashbangCount = 2;
```

* 投げる速度や角度の範囲、弾の出現位置オフセット、クールダウン秒数、所持できる最大フラッシュバン数を決めている。

---

#### タグ設定

```cpp
    const FLyraGameplayTags &GameplayTags = FLyraGameplayTags::Get();
    AbilityTags.AddTag(FGameplayTag::RequestGameplayTag(TEXT("Ability.Flashbang.Throw")));
    ActivationOwnedTags.AddTag(FGameplayTag::RequestGameplayTag(TEXT("Status.Throwing")));
```

* **アビリティに付くタグ**。識別や条件チェックに使う。
* `Ability.Flashbang.Throw` → フラッシュバンを投げるアビリティであることを示す。
* `Status.Throwing` → 投げている最中の状態。

```cpp
    ActivationBlockedTags.AddTag(GameplayTags.Ability_ActivateFail_IsDead);
    ActivationBlockedTags.AddTag(GameplayTags.Ability_ActivateFail_Cooldown);
```

* これらのタグがキャラに付いているとアビリティが発動できない。

  * 死んでいる (`IsDead`)
  * クールダウン中 (`Cooldown`)

---

### ActivateAbility

```cpp
void ULyraGameplayAbility_ThrowFlashbang::ActivateAbility(...)
```

* 実際にアビリティが使われた時に呼ばれる関数。

---

#### アビリティ発動チェック

```cpp
    if (!CommitAbility(Handle, ActorInfo, ActivationInfo))
    {
        EndAbility(..., true, true);
        return;
    }
```

* **コストやクールダウンの消費処理**。失敗したら即終了。

```cpp
    if (!HasFlashbangAvailable())
    {
        EndAbility(..., true, true);
        return;
    }
```

* **フラッシュバンを所持しているか確認**。無ければ終了。

---

#### アニメーション再生

```cpp
    if (ThrowMontage)
    {
        if (ALyraCharacter *LyraCharacter = GetLyraCharacterFromActorInfo())
        {
            if (USkeletalMeshComponent *Mesh = LyraCharacter->GetMesh())
            {
                if (UAnimInstance *AnimInstance = Mesh->GetAnimInstance())
                {
                    AnimInstance->Montage_Play(ThrowMontage);
                }
            }
        }
    }
```

* 投げ動作のアニメーション (`ThrowMontage`) が設定されていれば再生する。
* キャラ → メッシュ → アニメーションインスタンスと順番に辿って呼び出している。

---

#### フラッシュバン生成の遅延処理

```cpp
    FTimerHandle TimerHandle;
    GetWorld()->GetTimerManager().SetTimer(
        TimerHandle,
        this,
        &ULyraGameplayAbility_ThrowFlashbang::SpawnFlashbang,
        0.3f,
        false);
```

* 0.3秒後に `SpawnFlashbang()` を呼ぶ。
* 投げモーションに合わせるためにディレイをかけている。

---

#### 親クラス処理呼び出し

```cpp
    Super::ActivateAbility(Handle, ActorInfo, ActivationInfo, TriggerEventData);
```

* 親クラスの `ActivateAbility` を実行。標準的な初期処理を保証。

---

### まとめ

* **コンストラクタ**: アビリティの基本設定（投げ速度、角度、タグ、制約条件など）。
* **ActivateAbility**: アビリティ発動時の処理（チェック、アニメ再生、タイマーで弾を生成）。
* **GAS的ポイント**: タグ管理で発動可否や状態を制御、`CommitAbility` でリソース消費を処理、`Timer` でアニメと同期。

順番に回答する。

---

### 1. `ReplicationPolicy = ReplicateNo` の理由

* **アビリティ自体はサーバーにレプリケートしない設定**。
* 理由: アビリティ本体の細かい状態は同期不要。重要なのは「結果」(投げたこと・弾の生成) のみ。
* 例えばフラッシュバンなら、投擲したという情報をサーバーに送り、サーバーが「フラッシュバンのアクターをスポーン」→ そのアクターをクライアントにレプリケートする。
* よって **「アビリティの発動そのもの」ではなく「投げられたオブジェクト」や「効果結果」だけがネットワーク同期される**。

---

### 2. 投擲時の情報のみサーバ送信？

* その通り。
* クライアントは「投げたい」という入力を予測実行 (`LocalPredicted`)。
* サーバーに送るのは「投擲イベント」と「パラメータ」(角度や速度)。
* サーバーが正と判断したらフラッシュバンアクターをスポーンして全員に通知する。
* こうすることで **アニメ再生などはローカル処理、実際の投擲結果はサーバで決定** となる。

---

### 3. `ActivationOwnedTags` とは

* **アビリティを発動している間だけキャラクターに付与されるタグ**。
* 例: このコードでは `Status.Throwing` を付与。
* 他のシステムは「投げ中かどうか」をこのタグで判定できる。
* アビリティ終了時にタグは自動で消える。

---

### 4. `RequestGameplayTag()` とは

* 文字列で指定したタグを「ゲーム内で一意の `FGameplayTag` オブジェクト」に変換する関数。
* タグは「文字列ID」ではなく「軽量なオブジェクト」として扱われるため、`RequestGameplayTag(TEXT("Ability.Flashbang.Throw"))` のように一度変換して使う。
* 要するに「文字列からタグを取得してキャッシュする」関数。

---

### 5. `TEXT()` とは

* UE/C++ のマクロ。
* `"文字列リテラル"` を **ワイド文字列 (`L"..."`)** に変換する。
* Unreal は国際化対応のため文字列は `FString` や `FText` でワイド文字を基本にしている。
* `"ABC"` だとただの `const char*`。
* `TEXT("ABC")` だと `const wchar_t*` になり、`FString` と相性が良い。

---

### 6. `GetWorld()->GetTimerManager().SetTimer()` の役割

* **指定時間後に関数を呼ぶ仕組み**。
* Unity で言えば `StartCoroutine(Delay())` + `yield return new WaitForSeconds(x)` とほぼ同じ立ち位置。
* ただし UE の Timer は「タイマー管理システム」に登録されるので、コルーチンのように関数が途中で止まるわけではない。
* 指定時間経過したら「関数を呼び出す」だけ。
* 連続実行やループも可能（引数に `true` を渡すと繰り返し呼ばれる）。

---

要点まとめると:

* **ReplicateNo** → アビリティ内部は同期不要、結果だけ同期。
* **ActivationOwnedTags** → アビリティ実行中にキャラへ付与される一時的タグ。
* **RequestGameplayTag()** → 文字列IDからタグオブジェクトを取得。
* **TEXT()** → 文字列をワイド文字列リテラルにするマクロ。
* **SetTimer()** → コルーチンの Wait 的な「遅延呼び出し」仕組み。

コードを2つに分けて説明する。

---

## `EndAbility`

```cpp
void ULyraGameplayAbility_ThrowFlashbang::EndAbility(
    const FGameplayAbilitySpecHandle Handle,
    const FGameplayAbilityActorInfo *ActorInfo,
    const FGameplayAbilityActivationInfo ActivationInfo,
    bool bReplicateEndAbility,
    bool bWasCancelled)
```

### 処理の流れ

1. **アニメーションの後片付け**

   ```cpp
   if (ThrowMontage)
   {
       if (ALyraCharacter *LyraCharacter = GetLyraCharacterFromActorInfo())
       {
           if (USkeletalMeshComponent *Mesh = LyraCharacter->GetMesh())
           {
               if (UAnimInstance *AnimInstance = Mesh->GetAnimInstance())
               {
                   if (AnimInstance->Montage_IsPlaying(ThrowMontage))
                   {
                       AnimInstance->Montage_Stop(0.2f, ThrowMontage);
                   }
               }
           }
       }
   }
   ```

   * `ThrowMontage` が設定されていて、実際に再生中なら停止する。
   * `Montage_Stop(0.2f, ThrowMontage)` → 0.2秒かけてアニメーションをフェードアウト。

2. **親クラスの `EndAbility` 呼び出し**

   ```cpp
   Super::EndAbility(...);
   ```

   * タグの解除や内部のクリーンアップを処理。
   * これを呼ばないと `ActivationOwnedTags` が消えず、キャラに「投げ中」の状態が残ってしまう。

---

## `CanActivateAbility`

```cpp
bool ULyraGameplayAbility_ThrowFlashbang::CanActivateAbility(
    const FGameplayAbilitySpecHandle Handle,
    const FGameplayAbilityActorInfo *ActorInfo,
    const FGameplayTagContainer *SourceTags,
    const FGameplayTagContainer *TargetTags,
    OUT FGameplayTagContainer *OptionalRelevantTags) const
```

### 処理の流れ

1. **親クラスでの共通チェック**

   ```cpp
   if (!Super::CanActivateAbility(...))
   {
       return false;
   }
   ```

   * クールダウン中か、ブロックタグが付いていないか、スタン状態かなどを確認。
   * 失敗なら発動不可。

2. **フラッシュバン所持確認**

   ```cpp
   return HasFlashbangAvailable();
   ```

   * 所持数が0なら発動できない。

---

## まとめ

* **EndAbility**

  * アニメーション停止やタイマー解放などを行い、最後に `Super::EndAbility` でタグや内部処理を確実に片付ける。

* **CanActivateAbility**

  * 共通の発動条件チェックに加え、このアビリティ固有の条件（フラッシュバン所持）を確認する。


この関数は **実際にフラッシュバンをワールドにスポーンさせる処理**。順を追って説明する。

---

## `SpawnFlashbang`

```cpp
void ULyraGameplayAbility_ThrowFlashbang::SpawnFlashbang()
```

### 1. 前提チェック

```cpp
if (!FlashbangProjectileClass)
{
    UE_LOG(LogTemp, Warning, TEXT("FlashbangProjectileClass is not set!"));
    return;
}
```

* 投擲用の弾（Projectile）のクラスが設定されていなければ警告を出して終了。

```cpp
ALyraCharacter *LyraCharacter = GetLyraCharacterFromActorInfo();
if (!LyraCharacter)
{
    return;
}
```

* アビリティを使ったキャラを取得。存在しなければ終了。

```cpp
UWorld *World = GetWorld();
if (!World)
{
    return;
}
```

* ワールド（ゲームの世界）が取得できなければ終了。

---

### 2. 生成位置と速度を計算

```cpp
FVector SpawnLocation = GetProjectileSpawnLocation();
FVector ThrowVelocity = CalculateThrowVelocity();
```

* 弾が出る位置（キャラの前方や手元など）と、投げる速度ベクトルを計算。
* `GetProjectileSpawnLocation()` と `CalculateThrowVelocity()` は別で実装されている補助関数。

---

### 3. スポーンパラメータを設定

```cpp
FActorSpawnParameters SpawnParams;
SpawnParams.Owner = LyraCharacter;
SpawnParams.Instigator = LyraCharacter;
SpawnParams.SpawnCollisionHandlingOverride = ESpawnActorCollisionHandlingMethod::AdjustIfPossibleButDontSpawnIfColliding;
```

* **Owner** → この弾を誰が所有しているか。
* **Instigator** → この弾を「発射したキャラ」。ダメージ処理や当たり判定で使われる。
* **SpawnCollisionHandlingOverride** → もし出現場所が壁などと被っていたら「動かせるならずらす、無理なら出現しない」。

---

### 4. フラッシュバンのスポーン

```cpp
CurrentFlashbang = World->SpawnActor<ALyraFlashbangProjectile>(
    FlashbangProjectileClass,
    SpawnLocation,
    ThrowVelocity.Rotation(),
    SpawnParams);
```

* ワールドに **フラッシュバンのアクター** を生成する。
* 回転は投げる方向ベクトルから算出。

---

### 5. 初期速度を設定

```cpp
if (CurrentFlashbang)
{
    if (UProjectileMovementComponent *MovementComp = CurrentFlashbang->FindComponentByClass<UProjectileMovementComponent>())
    {
        MovementComp->Velocity = ThrowVelocity;
    }

    ConsumeFlashbang();
}
```

* 生成に成功したら `UProjectileMovementComponent` を探して初速を設定。
* 所持しているフラッシュバンを1つ消費する。

---

### 6. アビリティ終了

```cpp
EndAbility(GetCurrentAbilitySpecHandle(), GetCurrentActorInfo(), GetCurrentActivationInfo(), true, false);
```

* 投擲が終わったのでアビリティを終了。
* `ActivationOwnedTags`（投げ中状態）もここで解除される。

---

## まとめ

* **チェック**: Projectileクラス、キャラ、ワールドが存在するか。
* **計算**: 出現位置と速度を算出。
* **スポーン**: Projectileをワールドに生成し、初速を与える。
* **後処理**: 所持数を減らし、アビリティを終了。

違う。

```cpp
if (!FlashbangProjectileClass)
```

がやっているのは **「投げる弾のクラス参照がセットされているかどうかの確認」**。

---

### 詳細

* `FlashbangProjectileClass` は `TSubclassOf<ALyraFlashbangProjectile>` 型（＝クラスの参照）。
* これは「どのクラスをスポーンするか」を指定する変数で、通常は **Blueprint か DefaultObject 設定**で指定される。
* `nullptr` の場合は「まだ何も設定されていない」という意味になる。

---

### シングルトンとの違い

* シングルトンは「プログラム中に唯一のインスタンスを持つ仕組み」。
* ここでチェックしているのは「その唯一のインスタンスがあるか」ではなく、**スポーン用に参照しているクラスそのものが存在するか**。

---

### まとめ

`if (!FlashbangProjectileClass)` は

* **スポーンするクラスが未設定かどうかを確認**している。
* シングルトンとは無関係。


```cpp
FVector ULyraGameplayAbility_ThrowFlashbang::CalculateThrowVelocity() const
```

この最後の `const` は **「このメンバ関数はクラスのメンバ変数を書き換えない」** ことを示しています。

---

### 具体的にいうと

* `ULyraGameplayAbility_ThrowFlashbang` はクラスです。
* `CalculateThrowVelocity()` はそのメンバ関数。
* 関数の末尾に `const` を付けると、その関数の中では **インスタンスのメンバ変数を変更できなくなる** というルールが適用されます。

例：

```cpp
class Example {
    int Value;

public:
    int GetValue() const { return Value; }   // OK: 読み取り専用
    void SetValue(int v) { Value = v; }      // OK: 書き換える関数は const なし
};
```

* `GetValue()` は `const` なので `Value` を変更できません。
* `SetValue()` は `const` がないので書き換えできます。

---

### 今回の場合

`CalculateThrowVelocity()` は「投擲ベクトルを計算するだけ」の関数で、
キャラクターやアビリティの内部状態を変更する必要がありません。

なので `const` を付けておくことで

* 間違ってメンバ変数を書き換えてしまうのをコンパイル時に防ぐ
* 「この関数は純粋に計算用だよ」とコードを読む人に伝える

といったメリットがあります。

---

🔹まとめ
この `const` は **「この関数はオブジェクトの状態を変えない」** という宣言。
つまり **読み取り専用関数**であることを保証しています。


でも UE5(C++) の

```cpp
FVector ULyraGameplayAbility_ThrowFlashbang::CalculateThrowVelocity() const
```

の **最後の `const`** は、PHP の **`static` メソッド** とは全然別のものです。

---

### PHP の `static` メソッド

* クラスに属するけど、**インスタンスに依存しない関数**。
* `self::methodName()` みたいに呼べる。
* インスタンスのプロパティ `$this->property` は使えない。

例：

```php
class Example {
    public static function hello() {
        return "Hello!";
    }
}
echo Example::hello(); // インスタンス作らずに呼べる
```

---

### C++ の メンバ関数末尾 `const`

* これは「**このインスタンスのメンバ変数を書き換えない**」という宣言。
* インスタンスに属する関数である点は普通のメソッドと同じ。
* `this` は普通に使えるし、読み取りはできる。

例：

```cpp
class Example {
    int Value = 42;

public:
    int GetValue() const { return Value; }   // OK: 読み取り専用
    void SetValue(int v) { Value = v; }      // OK: 書き換え可
};
```

---

### C++ の `static` メソッド

実は C++ にも **PHP の static に近いもの**があります。

```cpp
class Example {
public:
    static int Add(int a, int b) {
        return a + b;
    }
};

int result = Example::Add(2, 3); // インスタンス不要
```

こちらは PHP の `static` とほぼ同じで、`this` を持たず、メンバ変数を直接扱えません。

---

✅ まとめ

* PHPの `static` → **インスタンス不要**で呼べる。
* C++の 関数末尾 `const` → **インスタンス必要**だが「状態を変えない」と保証。
* C++の `static` → PHPの `static` と同じ。


いいですね！ではこのコードの流れを初心者向けに解説しますね。
ここは「フラッシュバンをどこから出すか」「まだ残りがあるか」「使ったらどう減らすか」という処理部分です。

---

## 1. `GetProjectileSpawnLocation() const`

```cpp
FVector ULyraGameplayAbility_ThrowFlashbang::GetProjectileSpawnLocation() const
```

### 役割

フラッシュバンの **出現位置（Spawn Location）** を計算する関数。

### 処理の流れ

1. **キャラクター取得**

   ```cpp
   ALyraCharacter *LyraCharacter = GetLyraCharacterFromActorInfo();
   if (!LyraCharacter) return FVector::ZeroVector;
   ```

   → キャラが取得できなければ `(0,0,0)` を返して終了。

2. **キャラの位置から開始**

   ```cpp
   FVector SpawnLocation = LyraCharacter->GetActorLocation();
   ```

   → 足元の座標を基準にする。

3. **高さをプラス**

   ```cpp
   SpawnLocation.Z += 150.0f;
   ```

   → 肩や手の高さくらいに調整。

4. **前・横・上方向のオフセットを追加**

   ```cpp
   FVector ForwardOffset = LyraCharacter->GetActorForwardVector() * SpawnOffset.X;
   FVector RightOffset   = LyraCharacter->GetActorRightVector()  * SpawnOffset.Y;
   FVector UpOffset      = LyraCharacter->GetActorUpVector()     * SpawnOffset.Z;
   ```

   → キャラの向きに応じて前・横・上下にずらす。

5. **合計して返す**

   ```cpp
   return SpawnLocation + ForwardOffset + RightOffset + UpOffset;
   ```

   → 最終的に「キャラの手元から投げられる」ような位置になる。

---

## 2. `HasFlashbangAvailable() const`

```cpp
bool ULyraGameplayAbility_ThrowFlashbang::HasFlashbangAvailable() const
```

### 役割

「まだフラッシュバンが残っているか」をチェックする。

### 今の実装

```cpp
return GetCurrentFlashbangCount() > 0;
```

* `GetCurrentFlashbangCount()` が **1個以上**なら `true`。
* 実際には **インベントリシステムと連携する予定**。
* 今はテスト用に「常にある」としている。

---

## 3. `ConsumeFlashbang()`

```cpp
void ULyraGameplayAbility_ThrowFlashbang::ConsumeFlashbang()
```

### 役割

フラッシュバンを 1個消費する。

### 今の実装

```cpp
UE_LOG(LogTemp, Log, TEXT("Consumed one flashbang"));
```

* 本来ならインベントリから「残り数を減らす」。
* まだ未実装なので **ログを出すだけ**。

---

## 4. `GetCurrentFlashbangCount() const`

```cpp
int32 ULyraGameplayAbility_ThrowFlashbang::GetCurrentFlashbangCount() const
```

### 役割

「現在のフラッシュバン所持数」を返す。

### 今の実装

```cpp
return MaxFlashbangCount;
```

* 本来は「インベントリから実際の所持数を返す」。
* まだ未実装なので **最大数そのまま返す（常に残ってる状態）**。

---

## まとめ

* `GetProjectileSpawnLocation()` → 投げる位置を計算（キャラの前・肩の高さから）。
* `HasFlashbangAvailable()` → 残りがあるかチェック（今は常にある）。
* `ConsumeFlashbang()` → 投げたら1個減らす（今はログだけ）。
* `GetCurrentFlashbangCount()` → 所持数を返す（今は最大値そのまま）。

---

💡 今は「テスト用のダミー実装」だけど、最終的には **インベントリシステム（持ち物管理）と連携**して「本当に残りがあるか」「ちゃんと減ったか」を確認するように作り変えるイメージです。

if (!LyraCharacter) return FVector::ZeroVector; で例外を投げずにゼロベクターを返しているのはなぜでしょうか。 ゼロベクターが思わぬ不具合に繋がったりしないでしょうか。

理由は2つあります。

---

### 1. **ゲームコードでは例外をほぼ使わない**

* UE5のC++は**リアルタイム処理**が前提。例外（`throw`）はコストが高く、制御が飛ぶと処理落ちやクラッシュにつながりやすい。
* Unrealの設計方針として「例外を投げず、ヌルチェックやフォールバックで処理を止めない」スタイルを取る。
* なので「キャラがいないなら安全な値を返す」方が一般的。

---

### 2. **ゼロベクターが「処理できなかった」の明示的なサイン**

* `FVector::ZeroVector` は「失敗した」「結果なし」という**無害なダミー値**としてよく使われる。
* 例えば今回の `SpawnFlashbang()` 側ではこうなっている：

  ```cpp
  FVector SpawnLocation = GetProjectileSpawnLocation();
  FVector ThrowVelocity = CalculateThrowVelocity();
  World->SpawnActor(..., SpawnLocation, ThrowVelocity.Rotation(), ...);
  ```

  * キャラがいなければ `(0,0,0)` に生成しようとするが、その前に **LyraCharacterがNULLなら処理を中断するチェック**があるので、実際には問題が広がらない。

---

### 3. **不具合のリスク**

* 確かに「ゼロベクターをそのまま使うと原点にオブジェクトが湧く」などの不具合になり得る。
* ただしUEの慣習では「呼び出し元がヌルチェックをする」か「戻り値が明らかにおかしければスキップする」設計が基本。
* このコードも `if (!LyraCharacter) return;` などを多用しているので、ゼロベクターが本当に使われる前に処理が止まる。

---

### まとめ

* UE5は例外を使わず「安全なデフォルト値で返す」のが標準。
* `FVector::ZeroVector` は「処理できなかった印」として便利。
* 呼び出し側で追加のチェックをしているので、不具合が広がらない設計になっている。

---

👉 もし自作プロジェクトで「原点にオブジェクトが湧くと困る」なら、`ensureMsgf(LyraCharacter, TEXT("LyraCharacter is null"));` で警告を出した上で `return FVector::ZeroVector;` のようにするのが安全策です。

このコードは **UE5 の C++ でフラッシュバン弾（閃光手榴弾）の挙動を定義しているクラス** の一部です。初心者向けに要素を分解します。

---

### クラス宣言部

```cpp
ALyraFlashbangProjectile::ALyraFlashbangProjectile(const FObjectInitializer &ObjectInitializer)
    : Super(ObjectInitializer)
```

* **ALyraFlashbangProjectile** … このクラスの名前。
* **Super(ObjectInitializer)** … 親クラス（おそらく `ALyraProjectileBase`）のコンストラクタを呼んで初期化。
  UE のクラスは継承が多いので、必ず親の初期化をする。

---

### コンストラクタ内の設定

```cpp
// Set default values specific to flashbang
DetonationTime = 2.5f;
bExplodeOnImpact = false;
bStickToSurfaces = false;
```

* **DetonationTime = 2.5f;** → 2.5秒後に爆発する。
* **bExplodeOnImpact = false;** → ぶつかってもすぐ爆発しない。
* **bStickToSurfaces = false;** → 壁などにくっつかない。

```cpp
// Initialize effect parameters
EffectParams.FlashDuration = 3.0f;
EffectParams.DeafDuration = 5.0f;
EffectParams.MaxViewAngle = 90.0f;
EffectParams.MaxEffectDistance = 0.0f;
```

* **EffectParams.FlashDuration = 3.0f;** → 目がくらむ効果は3秒続く。
* **EffectParams.DeafDuration = 5.0f;** → 耳が聞こえにくくなる効果は5秒続く。
* **MaxViewAngle = 90.0f;** → 視野角90度以内なら効果がある。
* **MaxEffectDistance = 0.0f;** → 距離制限なし（0は無限扱い）。

```cpp
// Initialize gameplay tags (these will be set in BeginPlay from the tag system)
FlashbangTag = FGameplayTag();
BlindTag = FGameplayTag();
DeafTag = FGameplayTag();
```

* **GameplayTag** は UE のタグシステム。
  `"Ability.Flashbang"` や `"Status.Blind"` のような文字列で識別する。
* ここではまだ空で初期化している（後で設定）。

---

### BeginPlay 関数

```cpp
void ALyraFlashbangProjectile::BeginPlay()
{
    Super::BeginPlay();
```

* **BeginPlay** は UE のライフサイクル関数。
  ゲーム内でオブジェクトが「実際に出現」したときに呼ばれる。

```cpp
// Initialize gameplay tags
const FLyraGameplayTags &GameplayTags = FLyraGameplayTags::Get();
```

* **FLyraGameplayTags::Get()** … プロジェクト内で定義済みのタグ一覧を取得。

```cpp
FlashbangTag = FGameplayTag::RequestGameplayTag(TEXT("Ability.Flashbang"));
BlindTag = FGameplayTag::RequestGameplayTag(TEXT("Status.Blind"));
DeafTag = FGameplayTag::RequestGameplayTag(TEXT("Status.Deaf"));
```

* `"Ability.Flashbang"` → フラッシュバンに関するタグ。
* `"Status.Blind"` → 目が見えない状態のタグ。
* `"Status.Deaf"` → 耳が聞こえない状態のタグ。
* **RequestGameplayTag** を呼ぶことで、文字列から実際のタグオブジェクトを取得する。

---

### まとめ

* このクラスは **フラッシュバン弾の基本パラメータ** を定義。
* コンストラクタで数値的な初期値（爆発までの時間や効果時間）を設定。
* `BeginPlay` で **ゲームプレイタグシステムに登録されたタグ** を取得。
* 後で「プレイヤーに盲目・耳鳴り効果を与える」処理を行うときに、これらのタグを使って状態を付与する。

---

要するに：
**「2.5秒後に爆発して、3秒間目くらまし、5秒間耳が遠くなる効果を与えるフラッシュバン弾」** を表すクラスです。

GameplayTagをコンストラクタで初期化しているのはなぜですか。 なぜ後入れなのでしょうか。

理由は2点あります。

---

### 1. GameplayTag の仕組み

`FGameplayTag` はただのラッパーで、中身の実体（`FGameplayTagManager` が管理するテーブル）は **ゲーム開始時に初期化される**。
そのため **コンストラクタの時点ではまだタグシステムが準備できていない可能性がある**。

```cpp
FlashbangTag = FGameplayTag(); // 空のタグで初期化
```

としておくのは、未定義のまま放置して使うとクラッシュするから。

---

### 2. UE のライフサイクル

* **コンストラクタ** … C++レベルでオブジェクトが作られる瞬間。まだエンジンのシステム（タグマネージャーなど）は完全に動いていない。
* **BeginPlay** … アクターがワールドにスポーンして、すべてのサブシステムが稼働している状態。ここならタグを正しく問い合わせられる。

だから

* コンストラクタでは「空のタグを用意」
* BeginPlay で「実際のタグを取得してセット」

という2段階の流れになる。

---

### まとめ

**後入れなのは、UEのタグシステムがコンストラクタの時点ではまだ使えないから。**
そのため安全にするためにコンストラクタで「空タグを入れておき」、ゲーム開始後（`BeginPlay`）に実体を代入している。

分解して説明します。

---

## `OnExplode` 関数

フラッシュバン弾が「爆発したとき」に呼ばれる処理です。

```cpp
if (HasExploded())
{
    return;
}
```

* **HasExploded()** … すでに爆発済みなら二重処理しないで抜ける。

---

```cpp
// Apply flashbang effects to visible players first
ApplyFlashbangEffects();
```

* 爆発したときに **効果（目くらまし・耳鳴り）を与える処理** を先に実行。

---

```cpp
// Call parent implementation after applying effects
Super::OnExplode();
```

* 親クラスの爆発処理を呼ぶ（ダメージ処理や共通の後処理などが入っている）。

---

```cpp
// Play explosion sound
if (ExplosionSound && AudioComponent)
{
    AudioComponent->SetSound(ExplosionSound);
    AudioComponent->Play();
}
```

* サウンドを設定して再生。
* **ExplosionSound** … 再生する効果音（アセット）
* **AudioComponent** … 実際に音を鳴らすコンポーネント

---

```cpp
// Spawn explosion particle effect
if (ExplosionParticleEffect)
{
    UGameplayStatics::SpawnEmitterAtLocation(
        GetWorld(),
        ExplosionParticleEffect,
        GetActorLocation(),
        GetActorRotation());
}
```

* 爆発の見た目（パーティクル）をスポーンさせる。
* **UGameplayStatics::SpawnEmitterAtLocation** … 指定座標にエフェクトを出す便利関数。

---

```cpp
// Delay destruction to allow effects to play
FTimerHandle DestroyTimerHandle;
GetWorld()->GetTimerManager().SetTimer(
    DestroyTimerHandle,
    [this]()
    {
        Destroy();
    },
    1.0f, // Wait 1 second before destroying
    false);
```

* 爆発直後にすぐ消すとエフェクトや音が途中で切れる。
* なので **1秒後に Destroy() で削除** している。
* `SetTimer` にラムダ式 `[this](){ Destroy(); }` を渡しているのがポイント。

---

## `ApplyFlashbangEffects` 関数

実際にプレイヤーに「フラッシュバンの効果」を与える処理。

```cpp
// Get all player characters in the level
TArray<ALyraCharacter *> PlayerCharacters = GetAllPlayerCharacters();
```

* **GetAllPlayerCharacters()** … このマップに存在する全プレイヤーキャラを配列で取得。

---

```cpp
for (ALyraCharacter *Player : PlayerCharacters)
{
    if (Player && CanPlayerSeeFlashbang(Player))
    {
        ApplyEffectToPlayer(Player);
    }
}
```

* プレイヤーが有効か確認 (`Player != nullptr`)。
* さらに **CanPlayerSeeFlashbang(Player)** → 「そのプレイヤーから爆発が見えるか」を判定。
* 見える場合だけ **ApplyEffectToPlayer(Player)** で効果（目が見えない・耳が遠い）を付与。

---

## 全体の流れ

1. まだ爆発していなければ処理開始。
2. 爆発地点が見えるプレイヤーに「目くらまし・耳鳴り効果」を付与。
3. 親クラスの爆発処理を呼ぶ。
4. 爆発音を再生。
5. 爆発エフェクトを表示。
6. 1秒後に自分自身を消して後始末。

---

つまりこのコードは
**「フラッシュバンが爆発 → 見えるプレイヤーだけ効果を受ける → 爆発演出（音・パーティクル） → 1秒後に消滅」**
という一連の流れを実装しています。

このコードは **プレイヤーがフラッシュバンの爆発を視認できるかどうかを判定する関数** です。順に説明します。

---

## 関数ヘッダ

```cpp
bool ALyraFlashbangProjectile::CanPlayerSeeFlashbang(ALyraCharacter *Player) const
```

* プレイヤーキャラクターを引数に取り、**見えるなら true、見えないなら false** を返す。
* `const` … この関数内ではメンバ変数を書き換えないことを保証。

---

## 無効チェック

```cpp
if (!Player)
{
    return false;
}
```

* Player が nullptr（存在しない）なら見えない。

```cpp
// Skip the instigator (player who threw the flashbang)
if (Player == GetInstigator())
{
    return false;
}
```

* フラッシュバンを投げた本人には効果を与えない。

---

## 位置情報の取得

```cpp
const FVector PlayerLocation = Player->GetActorLocation();
const FVector FlashbangLocation = GetActorLocation();
```

* プレイヤーの座標とフラッシュバンの座標を取得。

---

## 距離判定

```cpp
if (EffectParams.MaxEffectDistance > 0.0f)
{
    float Distance = FVector::Dist(PlayerLocation, FlashbangLocation);
    if (Distance > EffectParams.MaxEffectDistance)
    {
        return false;
    }
}
```

* **MaxEffectDistance** が設定されている場合に距離チェック。
* 遠すぎると効果なし。

---

## 視角判定

```cpp
float ViewAngle = CalculateViewAngleToFlashbang(Player);
if (ViewAngle > EffectParams.MaxViewAngle)
{
    return false;
}
```

* **CalculateViewAngleToFlashbang** … プレイヤーの向きとフラッシュバンの角度を計算。
* 視界外（MaxViewAngle 以上）なら効果なし。

---

## 視線判定（Line of Sight）

```cpp
FVector TraceStart = PlayerLocation + FVector(0, 0, 50); // Add height offset for eye level
FVector TraceEnd = FlashbangLocation;

return TraceLine(TraceStart, TraceEnd);
```

* プレイヤーの目の高さからフラッシュバンまで **直線で障害物があるか** をチェック。
* **TraceLine** が true を返す場合、障害物なしで見える。
* false の場合は壁やオブジェクトで遮られているので効果なし。

---

## 全体の流れまとめ

1. Player が存在しない場合や投げた本人なら無効。
2. 設定された距離を超えていたら無効。
3. プレイヤーの向きから見えなければ無効。
4. 壁などで遮られていたら無効。
5. 上記すべてをクリアした場合だけ **true（見える）**。

---

要するに、この関数は **「誰がフラッシュバン効果を受けるか」を物理的・角度的に正確に判定するフィルター** です。


このコードは **フラッシュバンを見たプレイヤーに実際のステータス効果を付与する処理** です。順に解説します。

---

## 入口チェック

```cpp
if (!Player)
{
    return;
}

UAbilitySystemComponent *ASC = Player->GetAbilitySystemComponent();
if (!ASC)
{
    return;
}
```

* **Player が存在しない場合** → 何もしない。
* **AbilitySystemComponent (ASC)** がない場合 → 効果を付与できないので何もしない。

  * ASC は **Gameplay Ability System (GAS)** を使うときの中心コンポーネント。

---

## 1. 目くらまし効果（FlashBlindEffect）

```cpp
if (FlashBlindEffect)
{
    FGameplayEffectContextHandle ContextHandle = ASC->MakeEffectContext();
    ContextHandle.AddSourceObject(this);
```

* **EffectContext** を作成 → 効果が「どこから来たのか」を持たせる（ここではフラッシュバン）。

```cpp
    FGameplayEffectSpecHandle SpecHandle = ASC->MakeOutgoingSpec(
        FlashBlindEffect,
        1.0f, // Level
        ContextHandle);
```

* **MakeOutgoingSpec** → 効果（GameplayEffect）の設計図を作る。
* `FlashBlindEffect` → 目くらまし用に定義された GameplayEffect アセット。
* `1.0f` → レベル（強さ）。

```cpp
    if (SpecHandle.IsValid())
    {
        SpecHandle.Data->SetDuration(EffectParams.FlashDuration, false);
        ASC->ApplyGameplayEffectSpecToSelf(*SpecHandle.Data);
    }
}
```

* **Duration を設定** → `EffectParams.FlashDuration` 秒（= 3.0秒）。
* **ApplyGameplayEffectSpecToSelf** → プレイヤー自身にこの効果を適用。

---

## 2. 聴覚障害効果（HearingImpairmentEffect）

```cpp
if (HearingImpairmentEffect)
{
    FGameplayEffectContextHandle ContextHandle = ASC->MakeEffectContext();
    ContextHandle.AddSourceObject(this);

    FGameplayEffectSpecHandle SpecHandle = ASC->MakeOutgoingSpec(
        HearingImpairmentEffect,
        1.0f,
        ContextHandle);
```

* こちらは「耳が遠くなる効果」の GameplayEffect を作成。

```cpp
    if (SpecHandle.IsValid())
    {
        SpecHandle.Data->SetDuration(EffectParams.DeafDuration, false);
        ASC->ApplyGameplayEffectSpecToSelf(*SpecHandle.Data);
    }
}
```

* **Duration を設定** → `EffectParams.DeafDuration` 秒（= 5.0秒）。
* プレイヤーに適用。

---

## 全体の流れ

1. プレイヤーが GAS に対応しているか確認。
2. **FlashBlindEffect** を作り、3秒の「目くらまし効果」を付与。
3. **HearingImpairmentEffect** を作り、5秒の「耳が遠い効果」を付与。

---

## ポイント

* **GameplayEffect アセット** (`FlashBlindEffect` や `HearingImpairmentEffect`) に実際の効果内容（スクリーンを白くする、音を小さくするなど）が記述されている。
* この C++ 側では「誰に、どのくらいの時間、どの効果を適用するか」だけを制御。
* **GAS を使う場合、C++ は効果のトリガー担当、実際の処理は GameplayEffect アセット側** という分担になる。

---

要するに：
**「フラッシュバンを見たプレイヤーに、3秒の目くらまし効果と5秒の聴覚障害効果を与える」** 関数です。


このコードは **フラッシュバンを見たプレイヤーに実際のステータス効果を付与する処理** です。順に解説します。

---

## 入口チェック

```cpp
if (!Player)
{
    return;
}

UAbilitySystemComponent *ASC = Player->GetAbilitySystemComponent();
if (!ASC)
{
    return;
}
```

* **Player が存在しない場合** → 何もしない。
* **AbilitySystemComponent (ASC)** がない場合 → 効果を付与できないので何もしない。

  * ASC は **Gameplay Ability System (GAS)** を使うときの中心コンポーネント。

---

## 1. 目くらまし効果（FlashBlindEffect）

```cpp
if (FlashBlindEffect)
{
    FGameplayEffectContextHandle ContextHandle = ASC->MakeEffectContext();
    ContextHandle.AddSourceObject(this);
```

* **EffectContext** を作成 → 効果が「どこから来たのか」を持たせる（ここではフラッシュバン）。

```cpp
    FGameplayEffectSpecHandle SpecHandle = ASC->MakeOutgoingSpec(
        FlashBlindEffect,
        1.0f, // Level
        ContextHandle);
```

* **MakeOutgoingSpec** → 効果（GameplayEffect）の設計図を作る。
* `FlashBlindEffect` → 目くらまし用に定義された GameplayEffect アセット。
* `1.0f` → レベル（強さ）。

```cpp
    if (SpecHandle.IsValid())
    {
        SpecHandle.Data->SetDuration(EffectParams.FlashDuration, false);
        ASC->ApplyGameplayEffectSpecToSelf(*SpecHandle.Data);
    }
}
```

* **Duration を設定** → `EffectParams.FlashDuration` 秒（= 3.0秒）。
* **ApplyGameplayEffectSpecToSelf** → プレイヤー自身にこの効果を適用。

---

## 2. 聴覚障害効果（HearingImpairmentEffect）

```cpp
if (HearingImpairmentEffect)
{
    FGameplayEffectContextHandle ContextHandle = ASC->MakeEffectContext();
    ContextHandle.AddSourceObject(this);

    FGameplayEffectSpecHandle SpecHandle = ASC->MakeOutgoingSpec(
        HearingImpairmentEffect,
        1.0f,
        ContextHandle);
```

* こちらは「耳が遠くなる効果」の GameplayEffect を作成。

```cpp
    if (SpecHandle.IsValid())
    {
        SpecHandle.Data->SetDuration(EffectParams.DeafDuration, false);
        ASC->ApplyGameplayEffectSpecToSelf(*SpecHandle.Data);
    }
}
```

* **Duration を設定** → `EffectParams.DeafDuration` 秒（= 5.0秒）。
* プレイヤーに適用。

---

## 全体の流れ

1. プレイヤーが GAS に対応しているか確認。
2. **FlashBlindEffect** を作り、3秒の「目くらまし効果」を付与。
3. **HearingImpairmentEffect** を作り、5秒の「耳が遠い効果」を付与。

---

## ポイント

* **GameplayEffect アセット** (`FlashBlindEffect` や `HearingImpairmentEffect`) に実際の効果内容（スクリーンを白くする、音を小さくするなど）が記述されている。
* この C++ 側では「誰に、どのくらいの時間、どの効果を適用するか」だけを制御。
* **GAS を使う場合、C++ は効果のトリガー担当、実際の処理は GameplayEffect アセット側** という分担になる。

---

要するに：
**「フラッシュバンを見たプレイヤーに、3秒の目くらまし効果と5秒の聴覚障害効果を与える」** 関数です。


いいですね！この部分は「プレイヤーを探す処理」と「フラッシュバンが見えるかどうかの視線判定処理」を書いています。
CPP初心者向けに噛み砕いて説明しますね。

---

## 🔹 `GetAllPlayerCharacters`

```cpp
TArray<ALyraCharacter *> ALyraFlashbangProjectile::GetAllPlayerCharacters() const
{
    TArray<ALyraCharacter *> PlayerCharacters;

    if (UWorld *World = GetWorld())
    {
        for (FConstPlayerControllerIterator Iterator = World->GetPlayerControllerIterator(); Iterator; ++Iterator)
        {
            if (APlayerController *PC = Iterator->Get())
            {
                if (ALyraCharacter *LyraCharacter = Cast<ALyraCharacter>(PC->GetPawn()))
                {
                    PlayerCharacters.Add(LyraCharacter);
                }
            }
        }
    }

    return PlayerCharacters;
}
```

### 何をしているか

* 今のゲームワールド (`UWorld`) から、**全てのプレイヤーを探してリストにする処理**。
* `World->GetPlayerControllerIterator()` で「プレイヤーを操作している `PlayerController`」を1人ずつ取ってくる。
* そのコントローラが操作しているキャラ (`GetPawn()`) を `ALyraCharacter` にキャスト。

  * 成功すれば「プレイヤーが操作しているキャラクター」なので `PlayerCharacters` に追加。
* 最後に全プレイヤーキャラの配列 (`TArray`) を返す。

👉 簡単にいうと：**「このマップにいるプレイヤーキャラクター全員を集める関数」**。

---

## 🔹 `TraceLine`

```cpp
bool ALyraFlashbangProjectile::TraceLine(const FVector &Start, const FVector &End) const
{
    if (!GetWorld())
    {
        return false;
    }

    FHitResult HitResult;
    FCollisionQueryParams QueryParams;
    QueryParams.AddIgnoredActor(this);
    QueryParams.bTraceComplex = true;

    // Trace for world static objects that would block line of sight
    bool bHit = GetWorld()->LineTraceSingleByChannel(
        HitResult,
        Start,
        End,
        ECC_WorldStatic,
        QueryParams);

    // If we hit something, line of sight is blocked
    return !bHit;
}
```

### 何をしているか

* これは **レイキャスト（Raycast）処理**、つまり「2点の間に遮蔽物があるかどうか」を調べる関数。
* `LineTraceSingleByChannel`
  → 「Start から End まで直線を引いて、何かにぶつかるかチェック」するUE標準機能。
* `ECC_WorldStatic`
  → 壁や床など「動かないオブジェクト」にだけ当たり判定を行う。
* `QueryParams.AddIgnoredActor(this);`
  → 自分自身（フラッシュバンのアクター）は無視。
* `return !bHit;`
  → もし遮蔽物に当たったら「見えない (false)」、
  何もなければ「見える (true)」を返す。

👉 簡単にいうと：**「プレイヤーの目からフラッシュバンまでの間に壁があるかどうかを調べる関数」**。

---

## 🔹 この2つの関数が果たす役割

* `GetAllPlayerCharacters` → 誰にフラッシュバンが影響するか調べるため、全プレイヤーを集める。
* `TraceLine` → そのプレイヤーからフラッシュバンが「実際に見えるか」判定する。

つまり **「フラッシュバンの効果範囲内で、かつ視線が通っているプレイヤーに効果を与える」** ために使われています。


以下を実装してもらいましたが次にUE5で必要な実装には何がありますか。\
  @LyraStarterGame\Source\LyraGame\Weapons\LyraProjectileBase.cpp \
  @LyraStarterGame\Source\LyraGame\Weapons\LyraFlashbangProjectile.cpp \
  @LyraStarterGame\Source\LyraGame\Weapons\LyraGameplayAbility_ThrowFlashbang.cpp \
  日本語で教えて。
  ⎿  Read LyraStarterGame\Source\LyraGame\Weapons\LyraProjectileBase.cpp (164 lines)
  ⎿  Read LyraStarterGame\Source\LyraGame\Weapons\LyraFlashbangProjectile.cpp (271 lines)
  ⎿  Read LyraStarterGame\Source\LyraGame\Weapons\LyraGameplayAbility_ThrowFlashbang.cpp (241 lines)     

● 既存のコードを確認しました。フラッシュバン機能をUE5で完全に動作させるために、以下の実装が必要です：    

● 必要な実装一覧：

  1. ヘッダーファイルの作成・更新

  - LyraFlashbangProjectile.h
  - LyraGameplayAbility_ThrowFlashbang.h
  - LyraProjectileBase.h の更新（HasExploded関数の追加）

  2. ゲームプレイエフェクト（GE）の作成

  - FlashBlindEffect - 視覚障害エフェクト
  - HearingImpairmentEffect - 聴覚障害エフェクト

  3. ゲームプレイタグの定義

  - LyraGameplayTags.cpp/h への追加：
    - Ability.Flashbang
    - Status.Blind
    - Status.Deaf

  4. ブループリントクラスの作成

  - BP_FlashbangProjectile - フラッシュバン弾体のブループリント
  - BP_ThrowFlashbangAbility - 投擲アビリティのブループリント

  5. アニメーションモンタージュの設定

  - フラッシュバン投擲用のアニメーション
  - ThrowMontageプロパティの設定

  6. 入力バインディングの設定

  - Input Action for flashbang throw
  - Input Mapping Context への追加

  7. UIエフェクトの実装

  - 画面フラッシュエフェクト用のWidget
  - 視覚・聴覚障害時のUIフィードバック

  8. ビルド設定の更新

  - LyraGame.Build.cs への依存関係追加
  - モジュール設定の確認

`StaticClass()` は Unreal Engine (UE4/UE5) の **UClass 型を取得するための関数** です。C++ の文脈で簡単に言うと、**ある UObject 派生クラスの「クラス自体」を表すオブジェクト** を返します。

具体的に言うと：

```cpp
FlashBlindEffect = ULyraGameplayEffect_FlashBlind::StaticClass();
HearingImpairmentEffect = ULyraGameplayEffect_HearingImpairment::StaticClass();
```

* `ULyraGameplayEffect_FlashBlind` や `ULyraGameplayEffect_HearingImpairment` は `UObject` か `UGameplayEffect` の派生クラス。
* `StaticClass()` はそのクラスの **UClass オブジェクト** を返す。
* `FlashBlindEffect` と `HearingImpairmentEffect` が UClass 型の変数であれば、**「この変数にこのクラスを指す情報をセットした」** ことになります。

### なぜ使うか？

Unreal Engine ではゲームプレイ中にオブジェクトを動的に生成したり、クラス情報を参照することがあります。
例えば：

```cpp
GetWorld()->SpawnActor<AActor>(SomeActorClass);
```

この `SomeActorClass` は UClass\* 型で渡す必要があります。`StaticClass()` を使うとそのクラスのポインタを取得できるので、動的生成やエフェクト適用に使えるわけです。

---

まとめると：

* `StaticClass()` → **「この C++ クラスの UClass オブジェクトを返す」**
* C++ では `ULyraGameplayEffect_FlashBlind*` のインスタンスがまだなくても、**クラス情報だけを扱える**。
* UE の反射システム（Blueprint や GameplayEffect 適用など）でよく使われる。

いい質問です。結論から言うと、**`StaticClass()` が返すのはシングルトンのような「クラス情報」オブジェクトですが、実体（インスタンス）は生成されません**。

順を追って説明します：

---

### 1. `StaticClass()` の中身

`ULyraGameplayEffect_FlashBlind::StaticClass()` を呼ぶと、UE の内部で **UClass オブジェクトが返される** だけです。

* `UClass` は **そのクラスの「型情報」** を保持する UObject。
* これにはクラスの名前、親クラス、プロパティ、関数などが格納されています。
* 実際のゲームプレイ用のインスタンス（`ULyraGameplayEffect_FlashBlind` のオブジェクト）はここではまだ生成されません。

UE のソースコードを見ると、だいたいこんな流れです（簡略化）：

```cpp
static UClass* ptr = nullptr;
if (!ptr)
{
    ptr = ConstructUClass(...); // UClass を生成してキャッシュ
}
return ptr;
```

つまり **UClass オブジェクト自体はシングルトン** のように 1 つだけ作られます。

---

### 2. 実体はコンストラクタで作られる？

いいえ。`StaticClass()` は **インスタンスは作らない** です。

例えば：

```cpp
FlashBlindEffect = ULyraGameplayEffect_FlashBlind::StaticClass();
```

これだけでは `ULyraGameplayEffect_FlashBlind` のオブジェクトは存在しません。
もしインスタンスが欲しければ、`NewObject` や `SpawnActor` を使います：

```cpp
ULyraGameplayEffect_FlashBlind* EffectInstance = NewObject<ULyraGameplayEffect_FlashBlind>();
```

これで初めてコンストラクタが呼ばれて実体が生成されます。

---

### 3. まとめ

* **StaticClass() = クラス情報のシングルトン**
* **インスタンスは生成されない**
* 実体を作るには `NewObject` / `SpawnActor` / `ConstructObject` を使う

わかりました。初心者向けに、1つずつ丁寧に解説します。このコードは **Unreal Engine 5（UE5）** で「フラッシュバンによる目くらまし効果」を作るための **Gameplay Effect** の定義です。順に見ていきましょう。

---

### 1. インクルード部分

```cpp
#include "LyraGameplayEffect_FlashBlind.h"
#include "LyraGameplayTags.h"
#include "GameplayEffect.h"
#include "GameplayEffectComponents/TargetTagsGameplayEffectComponent.h"
```

* `LyraGameplayEffect_FlashBlind.h`：このCPPの対応するヘッダーファイル。
* `LyraGameplayTags.h`：状態を識別するタグ（Blindなど）を使うため。
* `GameplayEffect.h`：Gameplay Effectの基本クラスが入っている。
* `TargetTagsGameplayEffectComponent.h`：ターゲットにタグを付与するコンポーネント。

---

### 2. コンストラクタ

```cpp
ULyraGameplayEffect_FlashBlind::ULyraGameplayEffect_FlashBlind()
```

* この関数は **クラスのコンストラクタ** です。
* インスタンスが生成されたときに初期値を設定します。

---

### 3. 効果の期間（Duration）

```cpp
DurationPolicy = EGameplayEffectDurationType::HasDuration;
DurationMagnitude = FScalableFloat(3.0f);
```

* `DurationPolicy` は **この効果が一時的か永続的か** を決めます。

  * `HasDuration` → 一定時間だけ効果が続く。
* `DurationMagnitude` は **持続時間** を秒で設定。

  * ここでは 3 秒間、フラッシュバン効果が続きます。

---

### 4. 効果の重ね掛け（Stacking）

```cpp
StackingType = EGameplayEffectStackingType::AggregateByTarget;
StackLimitCount = 5;
StackDurationRefreshPolicy = EGameplayEffectStackingDurationPolicy::RefreshOnSuccessfulApplication;
StackPeriodResetPolicy = EGameplayEffectStackingPeriodPolicy::ResetOnSuccessfulApplication;
```

* `StackingType`：同じターゲットに複数の効果を重ねる方法。

  * `AggregateByTarget` → 同じターゲットにはスタック可能。
* `StackLimitCount`：最大スタック数。ここでは 5 回。
* `StackDurationRefreshPolicy`：新しい効果が適用されたときの期間の扱い。

  * `RefreshOnSuccessfulApplication` → 効果が再適用されたら期間をリセット。
* `StackPeriodResetPolicy`：周期的効果のリセット方針。

  * 今回は周期効果はないが、設定として残っています。

---

### 5. タグの付与

```cpp
UTargetTagsGameplayEffectComponent* TargetTagsComponent = CreateDefaultSubobject<UTargetTagsGameplayEffectComponent>(TEXT("TargetTagsComponent"));
FInheritedTagContainer TagContainer;
TagContainer.Added.AddTag(LyraGameplayTags::Status_Blind);
TargetTagsComponent->SetAndApplyTargetTagChanges(TagContainer);
```

* **Gameplay Tags** は状態管理のために使います。

  * 例：`Status_Blind` → プレイヤーが目くらまし状態であること。
* `TargetTagsComponent` を作り、ターゲットにタグを追加して効果を適用。
* これにより、他のシステム（UIやAIなど）が「目くらまし状態」として認識できます。

---

### 6. 効果の周期（Period）

```cpp
Period = FScalableFloat(0.0f);
bExecutePeriodicEffectOnApplication = false;
```

* `Period`：周期的に効果を発動する場合の間隔。

  * ここでは 0 にして、周期発動なし。
* `bExecutePeriodicEffectOnApplication`：

  * 効果を適用した瞬間に周期効果を発動するかどうか。
  * 今回は false。

---

### まとめ

* このクラスは **フラッシュバンによる目くらまし効果** を定義しています。
* 効果は **3秒間持続** し、**最大5回までスタック** 可能。
* ターゲットには **目くらまし状態タグ** が付与されます。
* 周期的な処理はなし、他の効果で解除可能。

---

💡 **初心者向けポイント**

1. `FScalableFloat` は「値をスケーラブルにできる浮動小数点型」です。UE5のGameplay Effectでよく使います。
2. `CreateDefaultSubobject` は **コンポーネントを作るときのUEの標準的な書き方** です。
3. タグ管理は **ステータスや条件を他のシステムに伝える便利な方法** です。

では一つずつ順番に詳しく説明します。UE5のGameplay Effectを理解する上で重要なポイントです。

---

### 1. **周期的効果（Periodic Effect）とは**

```cpp
Period = FScalableFloat(0.0f);
```

* **周期的効果** は、ある間隔ごとに何かを繰り返す効果のことです。
* 例：

  * 毒ダメージ：毎秒10ダメージ
  * 回復効果：3秒ごとにHPを50回復
* `Period` が 0 の場合は **周期的発動なし** で、効果は1回だけ適用されます。
* `bExecutePeriodicEffectOnApplication` を `true` にすると、効果が適用された瞬間にも周期処理が1回発生します。

💡 **まとめ**：周期的効果 = 時間ごとに繰り返される効果。今回のフラッシュバンは一度だけなので0秒。

---

### 2. **StackLimitCountを超えたらどうなるか**

```cpp
StackLimitCount = 5;
```

* **StackLimitCount** は、同じターゲットに何回まで同じ効果を重ねられるかの上限です。
* 例：

  * StackLimitCount = 5
  * 6回目のフラッシュバンが当たった場合は **6回目は無視される** または **上限の5スタックで置き換え** されます（設定によって挙動が変わる場合もあります）。
* `StackDurationRefreshPolicy = RefreshOnSuccessfulApplication` の場合：

  * 上限に達していても **スタック期間はリセット** されます。
  * つまり、追加で効果は増えないけど、既存のスタックの持続時間は延長されるイメージです。

💡 **ポイント**：スタック上限は「強さを増やす上限」で、期間はリフレッシュされる場合がある。

---

### 3. **値をスケーラブルにできる浮動小数点型（FScalableFloat）とは**

```cpp
DurationMagnitude = FScalableFloat(3.0f);
```

* UE5ではGameplay Effectの数値を **簡単に調整可能にする** ために `FScalableFloat` を使います。
* 特徴：

  1. 単純な値（ここでは3秒）を持てる
  2. **スケーリング** 可能

     * 例えば、プレイヤーのレベルやゲーム難易度によって自動で変えることができる
  3. **データ駆動** で設計しやすい

     * CSVやDataTableで数値を管理し、コードを直さずに調整可能

💡 **イメージ**：普通の `float` は固定値、`FScalableFloat` は「条件によって増減できるfloat」と思えばOK。

順番に正確に説明します。質問のイメージは少し誤解があるので整理します。

---

### 1. **3秒のフラッシュバンを5回同時にくらった場合の挙動**

* `DurationMagnitude = 3.0f`
* `StackLimitCount = 5`
* `StackDurationRefreshPolicy = RefreshOnSuccessfulApplication`

これらの設定だと：

| 回数    | 効果時間（秒） | コメント                        |
| ----- | ------- | --------------------------- |
| 1回目   | 3       | 初めて効果が適用                    |
| 2回目   | 3       | スタック2、持続時間リセット（合計3秒から再スタート） |
| 3回目   | 3       | スタック3、持続時間リセット              |
| 4回目   | 3       | スタック4、持続時間リセット              |
| 5回目   | 3       | スタック5（上限）、持続時間リセット          |
| 6回目以降 | -       | スタック上限なので増えない。ただし期間はリセットされる |

✅ ポイント：

* **5回分の効果時間が足し算されて15秒になるわけではない**
* 最大スタック数は5なので、「強さ」は5倍になっても、期間は **最後に適用された瞬間からカウント**
* つまり、**目くらましは最大5スタックの強さで3秒間持続**
* 追加のフラッシュバンは期間をリセットするだけで、単純に時間が足されるわけではありません。

💡 イメージ：スタック = 効果の「強さ」、Duration = 効果が続く「時間」。強さは増えるが時間はリセット。

---

### 2. **FScalableFloatのスケールを変えた場合**

* `FScalableFloat` は **1つの値を定義する型** です。
* 例：`DurationMagnitude = FScalableFloat(3.0f);`

💡 注意：

* この `FScalableFloat` のインスタンスのスケールを変えても、**同じクラスの他のインスタンスには影響しません**

* 「FScalableFloatで定義されたすべての値が変わる」わけではない

* つまり、個別のインスタンスごとにスケールを変えられるイメージです。

* スケールの利点は「レベルや状況に応じて値を動的に調整できる」という点です。

---

まとめると：

1. 5回同時にくらっても **時間は延びない** → 強さが最大5スタックになる
2. `FScalableFloat` は個別インスタンスごとにスケール可能 → 他の値は影響を受けない

はい、`FScalableFloat` は **UE5上（エディタ）とコードの両方で値を設定・調整可能** です。具体例で説明します。

---

## 1. **コード上での設定・調整例**

```cpp
// 基本的なFScalableFloatの設定
DurationMagnitude = FScalableFloat(3.0f); // 3秒固定
```

* 単純に固定値を持たせたい場合はこれだけでOKです。

### レベルや倍率で調整する例

```cpp
// 基本値 3秒、レベルに応じてスケールを変える
FScalableFloat ScalableDuration;
ScalableDuration.BaseValue = 3.0f;          // 基本値
ScalableDuration.LevelScalable = 0.5f;      // 例えばレベル1増えるごとに0.5秒加算
DurationMagnitude = ScalableDuration;
```

* `LevelScalable` の値を変えることで、対象のレベルに応じて自動的に値が変化します。

---

## 2. **UE5エディタ上での調整**

* `FScalableFloat` は **Blueprint や DataTable でも編集可能**。
* 手順：

  1. `Gameplay Effect` を選択
  2. プロパティパネルで `DurationMagnitude` を見つける
  3. Base Value（基本値）を3.0に設定
  4. 必要なら `Curve` や `Scalable Float` を指定して動的に調整可能

     * 例：プレイヤーのレベルに応じて増減

💡 重要：

* **コードで設定した場合** はその値が初期値になる
* **エディタで変更した場合** はコンストラクタの値を上書きして適用される
* つまり、どちらでも調整可能ですが **最終的にはエディタの設定が優先される場合が多い** です。

---

### 3. **応用例：フラッシュバン時間をプレイヤーレベルで変える**

```cpp
// Base 3秒、レベルごとに0.5秒加算
DurationMagnitude.BaseValue = 3.0f;
DurationMagnitude.LevelScalable = 0.5f;

// プレイヤーレベル3なら
float EffectiveDuration = DurationMagnitude.GetValueAtLevel(3); 
// 結果: 3 + 0.5 * 3 = 4.5秒
```

* `GetValueAtLevel(Level)` を使うと、現在のレベルに応じた値を取得できます。
* これをGameplay Effectの実行時に使えば、レベル依存の効果時間を簡単に作れます。

---

💡 **まとめ**

* `FScalableFloat` は **固定値にも、動的スケーリング値にも対応**
* **コード上** と **UE5エディタ上** の両方で設定可能
* レベルや状況に応じた柔軟な数値設計ができる

なるほど、UE5 の **Enhanced Input** 系の Input Action で「Consume Input」を探しているけど見当たらない、ということですね。
これは、従来の **旧 Input システム** と **Enhanced Input** で挙動や設定項目が変わっているためです。

---

### 1️⃣ 旧 Input システムの「Consume Input」

* 従来の `InputAction`（旧 `Input` 系の Blueprint や C++）では、`Consume Input` というチェックがあり、
  **「この入力を使ったら他のアクションに伝播させない」** という意味でした。

---

### 2️⃣ Enhanced Input ではどうなるか

* **Enhanced Input** の `InputAction` には、直接「Consume Input」という項目はありません。
* 代わりに、**入力の優先度とマッピングコンテキストの設定**で制御します。

#### 主な関連項目

1. **Consume lower priority enhanced input mappings**

   * これをチェックすると、**この InputAction が処理された場合、より低い優先度のマッピングには入力が伝わらなくなる**。
   * 旧 `Consume Input` と似た役割です。
2. **Cosumes action and axis mappings**

   * デジタル/アナログ問わず、このアクションや軸マッピングが消費されます。
   * `true` にすると、同じフレーム内で他のアクションに伝播しません。

---

### 3️⃣ 結論

Enhanced Input では **「Consume Input」項目はなく、代わりに**：

```text
・Consume lower priority enhanced input mappings
・Cosumes action and axis mappings
```

を使います。
フラッシュバンのような単発アクションなら、両方チェックしておくと旧仕様の `Consume Input = true` と同じ動作になります。

---

💡 **補足**

* デジタル入力（押した瞬間だけ）なら、`Value Type: Digital` で OK。
* アナログや連打系は、`Cosumes action and axis mappings` のみで十分な場合もあります。

`Content/Input/InputData_Hero.uasset` が何をするファイルかを理解するには、まずUE5での「InputData」系アセットの一般的な役割を押さえる必要があります。順に整理します。

---

### 1. `uasset` ファイルとは

* `.uasset` は **Unreal Engine のアセットファイル** です。
* 中身は「テクスチャ」「メッシュ」「アニメーション」「ブループリント」「Data Asset」など **UE5が認識できるデータ形式** です。
* 拡張子だけでは「何のデータか」は分かりませんが、Content Browser 上でダブルクリックすると UE5 で開けます。

---

### 2. `InputData_*` の名前から推測できること

* 名前が `InputData_Hero` なので、**Hero（プレイヤーキャラクター）用の入力設定データ** です。
* UE5 では「Enhanced Input」というシステムを使う場合、入力に関する設定を `Data Asset` として保存することがあります。
  例：

  * どのボタンがどの InputAction に対応するか
  * デフォルトの入力マッピング
  * デバイスごとの優先度

---

### 3. UE5 内での典型的な使い方

* `Input Mapping Context` や `Input Action` と組み合わせて使われることが多いです。
* Hero 用のアクターやキャラクターが、**初期化時にこの InputData を読み込んで、操作可能な状態にする**、という流れになります。
* 例えば：

  ```text
  InputData_Hero.uasset
  ├─ MoveForward → W / UpArrow
  ├─ MoveRight   → A / LeftArrow
  ├─ Jump        → SpaceBar
  ├─ Fire        → LeftMouseButton
  ```

  みたいなマッピングがアセット内に入っていることがあります。

---

### 4. 確認方法

1. UE5 の **Content Browser** で `InputData_Hero.uasset` を探す
2. ダブルクリックして開く
3. `Details` パネルを見ると、どの Input Action と紐付いているか確認できる

---

💡 **まとめ**
`Content/Input/InputData_Hero.uasset` は、基本的に **Heroキャラクター用の入力マッピング設定をまとめたデータアセット** です。
「何のボタンがどの操作に対応するか」を保持していて、ゲーム起動時やキャラクター生成時に読み込まれます。


> 諸々設定しましたが、設定したFを押してもフラッシュバンが出ません。

● フラッシュバンが動作しない問題を段階的にトラブルシューティングしましょう。

● フラッシュバン動作問題の段階的トラブルシューティング

  ステップ1: 最も重要 - Ability Setの設定確認

  フラッシュバンアビリティがキャラクターに付与されているかを確認します。

● Bash(find "C:\UnrealEngine\LyraStarterGame\Content" -name "*AbilitySet*" | head -10)
  ⎿  C:\UnrealEngine\LyraStarterGame\Content/Weapons/Projectile/DA_AbilitySet_Flashbang.uasset
     C:\UnrealEngine\LyraStarterGame\Content/Weapons/Tests/ShootingTarget_AbilitySet.uasset

● 既にFlashbang用のAbility Setが存在します！これが重要です。

  1.1 DA_AbilitySet_Flashbangの確認

  Unreal Editorで以下を確認してください：

  1. DA_AbilitySet_Flashbang を開く
  2. Granted Gameplay Abilities セクションに以下があるか確認：
    - Ability: BP_ThrowFlashbangAbility
    - Input Tag: InputTag.ThrowFlashbang

  1.2 キャラクターにAbility Setを追加

  現在のLyraキャラクターにAbility Setが設定されているか確認：

  1. B_Hero_ShooterMannequin (またはプレイヤーキャラクター) を開く
  2. Class Defaults → Pawn Data または Hero Component
  3. Ability Sets に DA_AbilitySet_Flashbang が追加されているか確認

  ---
  ステップ2: 入力バインディングの詳細確認

  2.1 Input Actionの確認

  1. IA_ThrowFlashbang を開く
  2. Value Type: Digital (Bool) になっているか
  3. Consume Input: True になっているか

  2.2 Input Mapping Contextの確認

  1. IMC_Default を開く
  2. Mappings セクションで以下を確認：
    - Action: IA_ThrowFlashbang
    - Key: F
    - Triggers: Pressed

  2.3 InputData_Heroの確認

  1. InputData_Hero を開く
  2. Native Input Actions に以下のエントリがあるか：
    - Input Action: IA_ThrowFlashbang
    - Input Tag: InputTag.ThrowFlashbang

  ---
  ステップ3: ログ出力でデバッグ

  3.1 アビリティのデバッグログを追加

  LyraGameplayAbility_ThrowFlashbang.cpp にログを追加：

● Update(LyraStarterGame\Source\LyraGame\Weapons\LyraGameplayAbility_ThrowFlashbang.cpp)
  ⎿  Updated LyraStarterGame\Source\LyraGame\Weapons\LyraGameplayAbility_ThrowFlashbang.cpp with 5 additions
       40    
       41    void ULyraGameplayAbility_ThrowFlashbang::ActivateAbility(const FGameplayAbilitySpecHandle 
            Handle, const FGameplayAbilityActorInfo *ActorInfo, const FGameplayAbilityActivationInfo 
            ActivationInfo, const FGameplayEventData *TriggerEventData)
       42    {
       43 +      UE_LOG(LogTemp, Warning, TEXT("ThrowFlashbang: ActivateAbility called!"));
       44 +      
       45        if (!CommitAbility(Handle, ActorInfo, ActivationInfo))
       46        {
       47 +          UE_LOG(LogTemp, Warning, TEXT("ThrowFlashbang: CommitAbility failed!"));
       48            EndAbility(Handle, ActorInfo, ActivationInfo, true, true);
       49            return;
       50        }
       51 +      
       52 +      UE_LOG(LogTemp, Warning, TEXT("ThrowFlashbang: Ability activated successfully!"));
       53
       54        // Check if we have flashbangs available
       55        if (!HasFlashbangAvailable())

● Update(LyraStarterGame\Source\LyraGame\Weapons\LyraGameplayAbility_ThrowFlashbang.cpp)
  ⎿  Updated LyraStarterGame\Source\LyraGame\Weapons\LyraGameplayAbility_ThrowFlashbang.cpp with 3 additions
       54        // Check if we have flashbangs available
       55        if (!HasFlashbangAvailable())
       56        {
       57 +          UE_LOG(LogTemp, Warning, TEXT("ThrowFlashbang: No flashbangs available!"));
       58            EndAbility(Handle, ActorInfo, ActivationInfo, true, true);
       59            return;
       60        }
       61 +      
       62 +      UE_LOG(LogTemp, Warning, TEXT("ThrowFlashbang: Flashbangs available, continuing..."));
       63
       64        // Play throw animation if available
       65        if (ThrowMontage)

● ---
  ステップ4: 最も簡単な確認方法

  4.1 シンプルなテスト用アビリティを作成

  一時的に、非常にシンプルなテスト用アビリティを作ってFキーの動作を確認：

  1. Content Browser → Blueprint Class → LyraGameplayAbility
  2. 名前: BP_TestFlashbang
  3. Event Graph で Activate Ability に Print String を接続
  4. 文字列: "Flashbang Test Activated!"

  4.2 DA_AbilitySet_Flashbangでテスト

  1. DA_AbilitySet_Flashbang を開く
  2. 一時的に BP_ThrowFlashbangAbility を BP_TestFlashbang に変更
  3. ゲームを実行してFキーを押す
  4. "Flashbang Test Activated!" が表示されるか確認

  ---
  ステップ5: 最も確実な確認手順

  5.1 Lyraのコンソールコマンドでデバッグ

  ゲーム実行中に以下のコンソールコマンドを実行：

  showdebug abilitysystem

  これでアビリティシステムの状態が表示されます。

  5.2 手動でアビリティを発動

  コンソールで以下を実行してアビリティを直接発動：

  ActivateAbility Ability.Flashbang.Throw

  ---
  ステップ6: 必須チェックリスト

  ✅ 確認項目:

  1. プロジェクトがコンパイル済み - C++変更後にビルドしたか？
  2. BP_ThrowFlashbangAbility作成済み - ブループリントクラスを作成したか？
  3. DA_AbilitySet_Flashbang設定済み - アビリティセットにアビリティを追加したか？
  4. キャラクターにAbilitySet追加済み - プレイヤーキャラクターにアビリティセットを追加したか？
  5. InputData_Hero設定済み - 入力データアセットに追加したか？
  6. IMC_Default設定済み - 入力マッピングコンテキストに追加したか？

  ---
  最も可能性の高い原因:

  1. Ability Set がキャラクターに設定されていない (90%の可能性)
  2. InputData_Hero の設定が不完全 (5%の可能性)
  3. BP_ThrowFlashbangAbility の設定ミス (3%の可能性)
  4. ビルドされていない (2%の可能性)

  まず DA_AbilitySet_Flashbang
  がプレイヤーキャラクターに正しく設定されているかを確認してください。これが最も重要です。

● どの確認項目から始めますか？最も重要なのは DA_AbilitySet_Flashbang
  がキャラクターに正しく設定されているかの確認です。

> B_Hero_ShooterMannequinにPawn Data、Hero Component、Ability Setsの項目が存在しない

● B_Hero_ShooterMannequinにこれらの項目が存在しないということは、Lyraの構造を理解してアビリティを正しく設定す
  る必要があります。

  Lyraのアビリティシステム構造の確認

  ステップ1: Lyraの正しいキャラクター設定を確認

● Bash(find "C:\UnrealEngine\LyraStarterGame\Content" -name "*Hero*" -name "*.uasset" | head -10)
  ⎿  C:\UnrealEngine\LyraStarterGame\Content/Characters/Heroes/Abilities/GA_Hero_Death.uasset
     C:\UnrealEngine\LyraStarterGame\Content/Characters/Heroes/Abilities/GA_Hero_Heal.uasset
     C:\UnrealEngine\LyraStarterGame\Content/Characters/Heroes/Abilities/GA_Hero_Jump.uasset
     … +5 lines (ctrl+r to expand)

● Bash(find "C:\UnrealEngine\LyraStarterGame\Content" -name "*PawnData*" | head -5)
  ⎿  C:\UnrealEngine\LyraStarterGame\Content/Characters/Heroes/EmptyPawnData
     C:\UnrealEngine\LyraStarterGame\Content/Characters/Heroes/EmptyPawnData/DefaultPawnData_EmptyPawn.uasset     
     C:\UnrealEngine\LyraStarterGame\Content/Characters/Heroes/SimplePawnData
     … +2 lines (ctrl+r to expand)

● ステップ2: 正しいPawnDataを確認

● Bash(find "C:\UnrealEngine\LyraStarterGame\Content" -name "*Mannequin*" -name "*PawnData*")
  ⎿  (No content)

● Bash(find "C:\UnrealEngine\LyraStarterGame\Content" -name "*Shooter*" -name "*PawnData*")
  ⎿  (No content)

● 問題の原因: Lyraのアビリティシステム構造の理解

  B_Hero_ShooterMannequinはメッシュとアニメーションのみのアセットで、アビリティシステムは別の場所で管理されて
  います。

  ステップ3: 正しいアビリティ設定場所を特定

  3.1 Experience Definition を確認

● Bash(find "C:\UnrealEngine\LyraStarterGame\Content" -name "*Experience*" -name "*.uasset" | head -5)
  ⎿  C:\UnrealEngine\LyraStarterGame\Content/System/DefaultEditorMap/B_ExperienceList3D.uasset
     C:\UnrealEngine\LyraStarterGame\Content/System/DefaultEditorMap/B_TeleportToUserFacingExperience.uasset      
     C:\UnrealEngine\LyraStarterGame\Content/System/Experiences/B_LyraDefaultExperience.uasset
     … +2 lines (ctrl+r to expand)

● 3.2 デフォルトエクスペリエンスを確認

  B_LyraDefaultExperience がメインのゲーム設定です。

  ステップ4: 正しいアビリティ設定方法

  Lyraでは以下の順序でアビリティが設定されます：

  1. Experience Definition → 2. Pawn Data → 3. Ability Sets

  4.1 SimplePawnData を確認

  1. Content/Characters/Heroes/SimplePawnData/SimplePawnData.uasset を開く
  2. Ability Sets セクションを確認
  3. ここに DA_AbilitySet_Flashbang を追加する必要があります

  4.2 正しい設定手順

  エディタで以下を実行：

  1. SimplePawnData を開く
  2. Details パネル → Ability Sets セクション
  3. "+" ボタンをクリック
  4. DA_AbilitySet_Flashbang を選択して追加

  ---
  ステップ5: 代替方法 - GameFeatureを使用

  Lyraでは Game Feature システムも使用できます。

  5.1 GameFeature用のAbilitySetを作成

● Bash(find "C:\UnrealEngine\LyraStarterGame\Content" -name "*GameFeature*" -type d | head -3)
  ⎿  (No content)

● 5.2 最もシンプルな方法: 直接ExperienceDefinitionに追加

  1. B_LyraDefaultExperience を開く
  2. Default Pawn Data を確認
  3. そのPawn Dataに DA_AbilitySet_Flashbang を追加

  ---
  ステップ6: 即座に動作確認できる方法

  6.1 テスト用の簡単な設定

  最も確実な方法：

  1. Content/Characters/Heroes/SimplePawnData/SimplePawnData.uasset を開く
  2. Ability Sets に DA_AbilitySet_Flashbang を追加
  3. B_LyraDefaultExperience で Default Pawn Data が SimplePawnData を参照していることを確認

  6.2 コンソールコマンドでテスト

  ゲーム実行中に以下を実行してアビリティを強制的に付与：

  GiveAbility Ability.Flashbang.Throw

  ---
  ステップ7: デバッグ用のログ確認

  ゲーム実行時に Output Log で以下を確認：

  1. "ThrowFlashbang: ActivateAbility called!" が表示されるか
  2. 表示されない場合 → アビリティが付与されていない
  3. 表示される場合 → アビリティは動作している（他の問題）

  ---
  最も可能性の高い解決方法:

  即座に試すべき手順:

  1. SimplePawnData.uasset を開く
  2. Ability Sets セクションに DA_AbilitySet_Flashbang を追加
  3. Save してゲームを再実行
  4. Fキーを押してログを確認

  これで動作しない場合は、B_LyraDefaultExperience の Default Pawn Data 設定を確認してください。



これは UE5 で「ゲーム実行中にコンソールコマンドを使ってアビリティを付与する」手順ですね。手順は以下の通りです。

---

### 1. ゲームをプレイモードで起動

* UE5 エディタでレベルを開く
* 「Play」ボタンでゲームを実行（PIE: Play In Editor）します

---

### 2. コンソールを開く

* **PC の場合**: `~`（チルダキー）を押す

  * 日本語キーボードだと `半角/全角` キーや `F12` になることもあります
* UE5 のコンソールが画面下部に出ます

---

### 3. コマンドを入力

コンソールで以下を入力して Enter:

```
GiveAbility Ability.Flashbang.Throw
```

* `GiveAbility` は Lyra や GAS 系アセットで使えるコマンドで、指定したアビリティをプレイヤーに付与します
* `Ability.Flashbang.Throw` がアビリティ名（InputTag に対応している場合もある）

---

### 4. 効果を確認

* 入力後、ゲーム内でフラッシュバンを使えるようになっているはずです
* 正常に付与されない場合は、アビリティ名が正しいか確認してください（Content Browser 内の AbilitySet の中の名前）

---

💡 **補足**

* PIE ではなく「Standalone Game」で実行する場合も同じコマンドで使えます
* コマンドが効かない場合は、`Enable Cheats` コマンドを先に実行してチートを有効化する必要があります

UE5で **Output Log** を確認する方法はいくつかあります。手順は以下の通りです：

---

### **方法 1: メニューバーから開く**

1. UE5 エディタの上部メニューバーで **Window** をクリック。
2. **Developer Tools** を選択。
3. **Output Log** をクリック。

これで **Output Log ウィンドウ** が開きます。
必要に応じて **ドッキング** して常に表示させることも可能です。

---

### **方法 2: コマンドで開く**

* UE5 の \*\*Ctrl + Shift + `**（バッククオート）でコンソールを開き、  
  `Log\` と入力すると Output Log が表示される場合があります。

---

### **ポイント**

* **Output Log** にはビルドエラー、警告、`UE_LOG` マクロで出力されたログが全て表示されます。
* **フィルタ** を使って特定のカテゴリ（例: Blueprint, Gameplay）だけ表示することも可能です。


Fは効いています。
EnhanceInputは既存のGranadeでは機能していますがFでは機能しません。
