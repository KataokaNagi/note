
# CS「ue5_cpp_tutorial_20250909」

- 2025-09-09 17:17:04

## 参考文献

- UE4 の C++ プログラミング入門
    - https://dev.epicgames.com/documentation/ja-jp/unreal-engine/introduction-to-cplusplus-programming-in-ue4?application_version=4.27
- プログラミング クイック スタート ガイド
    - https://dev.epicgames.com/documentation/ja-jp/unreal-engine/unreal-engine-cpp-quick-start

## #pragma once

多重インクルード防止

## cppとhファイルとのincludeの使い分け

```md:GPT
必要性を整理します。

### 1. ヘッダーファイル (`.h`) に書く `#include`

* **そのクラスの宣言に必要なものだけ**を入れる。
  例:

  * 親クラス（`AActor`など）
  * メンバー変数に使う型（`USphereComponent* CollisionComp;` など）
  * UPROPERTY/UFUNCTION で参照される型（リフレクションに必要）

これらは `.h` に書かないとコンパイル時にクラスの定義がわからないのでエラーになる。

---

### 2. CPP ファイルに書く `#include`

* **実装で使うものだけ**を入れる。
  例:

  * 関数の中でだけ使う型（`UAudioComponent`、`UParticleSystemComponent`など）
  * 実際に関数呼び出しや生成をするために完全な型情報が必要なとき

---

### 3. 前方宣言で済む場合

* `.h` にすべて `#include` すると依存関係が肥大化する。
* ポインタや参照でしか使わない場合は `class UStaticMeshComponent;` のように前方宣言で済む。
* 実際の中身が必要になる場所（`.cpp` 側）で `#include` すればよい。

---

### まとめ

* `.h` → 宣言に必要な型（親クラス・メンバーに出てくる型）。
* `.cpp` → 実装に必要な型（関数内で使うだけの型）。
* ポインタや参照だけなら前方宣言を使い、依存を減らす。
```

## スマートポインタ

- https://tsubasamusu.com/unreal-smart-pointer/
    - UE のスマートポインタの場合は IsValid() で確認するのが一般的


```md:gpt
いい質問です！
「スマートポインタ（smart pointer）」は **C++ でメモリ管理を自動化するための仕組み** です。

---

### 🔹 普通のポインタとの違い

* **普通のポインタ (`T*`)**

  * `new` や `delete` を自分で書いてメモリを管理する必要がある。
  * `delete` を忘れると **メモリリーク** が起きる。
  * 間違って二重 `delete` するとクラッシュする。

* **スマートポインタ (`TSharedPtr<T>`, `TUniquePtr<T>` など)**

  * 「ポインタのように使えるけど、中で自動的にメモリを管理してくれるオブジェクト」。
  * 参照カウントや所有権を管理して、不要になったときに自動で `delete` される。

---

### 🔹 主な種類（UE5 / 標準C++）

1. **`std::unique_ptr<T>` / `TUniquePtr<T>`（UE版）**

   * 所有者が必ず1人だけ。スコープを抜けると自動で解放される。
   * 「このポインタの寿命はこのスコープだけ」と決まっているときに使う。

2. **`std::shared_ptr<T>` / `TSharedPtr<T>`（UE版）**

   * 複数の場所で共有できる。参照カウント方式。
   * 誰も使わなくなった瞬間にメモリ解放される。

3. **`std::weak_ptr<T>` / `TWeakPtr<T>`（UE版）**

   * `shared_ptr` の「弱い参照」。
   * 実体を保持せず「生きていればアクセスできる」。循環参照の回避に使う。

---

### 🔹 Unreal Engine に特有のもの

* **`TWeakObjectPtr<AActor>`**

  * `UObject` を安全に参照するための UE 独自スマートポインタ。
  * 参照先の `Actor` が `Destroy()` されたら自動的に無効化される。
  * 「GCに消される可能性のある UObject を安全に追跡する」のに便利。

* **`TStrongObjectPtr<UObject>`**

  * UE5 で追加された。GC されないよう「強い参照」を保持する。

---

### 🔹 まとめ

* **スマートポインタ = 自動でメモリ解放してくれる安全なポインタ**
* 普通のポインタより安全で、手動 `delete` を減らせる。
* C++ 標準と UE 独自のバリエーションがある。
```

## ディレクトリ構造

```md
| ディレクトリ                    | 特別な意味・用途                                 |
| ------------------------- | ---------------------------------------- |
| `Content/` 以下             | 全てのゲームアセットはここに置く。Content Browserに表示される。  |
| `Config/`                 | `.ini` ファイルが入る。UE5は起動時に自動で読み込み。          |
| `Source/`                 | C++ ソースコード用。`ProjectName/Source/` が標準。   |
| `Saved/`                  | 自動保存や一時ファイル。エディタが自動生成・管理。                |
| `Intermediate/`           | ビルドや生成された中間ファイル。通常直接触らない。                |
| `Plugins/`                | プラグイン用。UEはここを認識してロードする。                  |
| `Content/StarterContent/` | 特別扱いというわけではないが、マーケットやUE提供コンテンツが入る既定フォルダ。 |
```
1. Enhanced Input Mapping Context

Input Mapping Context は 「どの InputAction がどのキーに割り当てられているか」 を管理するアセットです。

手順：

Content Browser で Input Mapping Context アセット を開く。

中を見ると、各 InputAction と対応する Keys（例: W, Space, LeftMouseButton） が表形式で一覧表示されます。

例えば Jump → Space

Fire → LeftMouseButton

この画面で全部のアクションと割り当てキーを確認できます。

⚠️ 注意
Enhanced Input を使わず古い Input System（Project Settings → Input → Action Mappings）を使っている場合は、そちらの「Action Mappings」一覧に同様に表示されます。


## 面白い書き方

for (FConstPlayerControllerIterator Iterator = World->GetPlayerControllerIterator(); Iterator; ++Iterator)

