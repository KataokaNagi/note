
# CS「Stable Diffusion Web UI」

- 2025-10-18 21:19:38


## 導入

https://github.com/AUTOMATIC1111/stable-diffusion-webui

https://weel.co.jp/media/stablediffusion-construction/

- pythonを固定する
    - https://qiita.com/landwarrior/items/1b5e0f9af5316a025fe0
    - 公式サイトのWindows installerからDL
        - https://www.python.org/downloads/release/python-3106/
    - Get-Command py | Select-Object Sourceのところにpy.iniでpython=3.10とする
        - C:\Windows\py.exe
        - https://qiita.com/rana_kualu/items/a2d34e223c90c63082ea
    - Set-Alias python "py -3.10"
    - py --listで確認
    - 一時的ならpy -3.10で変えられる
    - うまくいかないのでアンスコ

```sh
[defaults]
python=3.10
```

- git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git
- webui-user.bat を起動
- http://127.0.0.1:7860/ にアクセス


## 設定
https://weel.co.jp/media/innovator/stable-diffusion-web-ui/

stable diffusion web uiをRTX4090で動かすにあたって最適な設定を教えて
Web画面上でのRTX4090で最適な設定を教えて。
```md
以下は **Stable Diffusion WebUI（AUTOMATIC1111）上でのGUI設定**を、
**RTX 4090** 向けに最速かつ高品質になるよう最適化した構成。

---

## 🧠 基本設定（Stable Diffusion タブ）

| 項目                     | 推奨値                              | 理由                 |
| ---------------------- | -------------------------------- | ------------------ |
| **Sampler**            | DPM++ 2M Karras                  | 高速・安定・高画質。4090で最適。 |
| **Steps**              | 20〜30                            | これ以上は品質向上が鈍化。      |
| **CFG Scale**          | 7〜9                              | 過大にすると不自然になりやすい。   |
| **Width × Height**     | 1024×1024（SDXL） / 512×512（SD1.5） | 4090なら1024でも高速。    |
| **Batch count / size** | 1 / 4〜8                          | 並列生成でGPUを最大利用。     |
| **Restore faces**      | OFF                              | 品質が安定しないため必要時のみ。   |
| **Tiling**             | OFF                              | 通常用途では不要。          |
| **Highres fix**        | ON（2x, Latent）                   | 高解像度時にノイズ抑制と品質向上。  |

---

## ⚙️ Settings → Stable Diffusion

| 設定名                      | 推奨値                  | 解説          |
| ------------------------ | -------------------- | ----------- |
| **CLIP skip**            | 2（SD1.5系） / 1（SDXL系） | より自然な発色。    |
| **eta noise seed delta** | 31337                | 同一シード再現性向上。 |
| **VAE precision**        | FP32                 | 色崩れ・NaN防止。  |

---

## ⚡ Settings → Optimizations

| 設定項目                                        | 推奨設定                | 理由                |
| ------------------------------------------- | ------------------- | ----------------- |
| **xformers**                                | ✅ ON                | メモリ効率化と速度向上。      |
| **Use full precision for VAE**              | ✅ ON                | 安定性。              |
| **Upcast cross attention layer to float32** | ⛔ OFF               | 不要な負荷。            |
| **SDP attention**                           | ✅ ON（PyTorch 2.x環境） | 最新最速のattention処理。 |
| **Memory efficient attention**              | ✅ ON                | 大解像度時に安定。         |

---

## 🖼️ Highres Fix 設定例（高解像度画像用）

| 項目                     | 推奨値                               |
| ---------------------- | --------------------------------- |
| **Upscaler**           | Latent（または 4x-UltraSharp, ESRGAN） |
| **Upscale by**         | 2.0                               |
| **Hires steps**        | 10〜15                             |
| **Denoising strength** | 0.3〜0.4                           |

---

## 💽 その他推奨設定

* **Model hash caching**：ON（起動高速化）
* **Always save all generated images**：ON（再利用用）
* **Quick settings**に `Sampler`, `Steps`, `CFG`, `Hires.fix` を追加

---

## 🔧 実測目安（RTX4090 + SDXL）

| 解像度       | Batch | 速度                |
| --------- | ----- | ----------------- |
| 1024×1024 | 1     | 約2.8〜3.2秒/枚       |
| 1024×1024 | 4     | 約1.2〜1.5秒/枚（並列処理） |
```

## モデル

https://weel.co.jp/media/stable-diffusion-model

- アニメ調はWaifu Diffusionがよさそう

https://soroban.highreso.jp/article/article-040#651d3601d90c7102d4621e0a-74f77511ad4d6459d0edd167
https://odigo.jp/%E3%80%902023-8%E6%9C%80%E6%96%B0%E7%89%88%E3%80%91waifu-diffusion%E3%81%A8%E3%81%AF%EF%BC%9F%E4%BD%BF%E3%81%84%E6%96%B9%E3%81%BE%E3%81%A7%E5%BE%B9%E5%BA%95%E8%A7%A3%E8%AA%AC/

- .safetensorsか.ckptをDL
- [stable-diffusion-webui-forge]>[models]>[Stable-diffusion] に格納

https://huggingface.co/waifu-diffusion/wd-1-5-beta3/tree/main
https://note.com/nakaupic/n/n0033009e33e5

```md
| モデル名              | 特徴                 | 推奨用途                 |
| ----------------- | ------------------ | -------------------- |
| WD 1.5 Beta3 Base | トレーニング用ベースモデル      | 他モデルの微調整やLoRAのベースとして |
| WD 1.5 Radiance   | 明るく鮮やかな色彩と光沢感      | 華やかで目を引くビジュアル        |
| WD 1.5 Ink        | インクのような質感と深みのある色合い | 落ち着いた雰囲気やアート的表現      |
| WD 1.5 Mofu       | ふわふわとした質感と柔らかな色合い  | 可愛らしさや柔らかい印象         |
| WD 1.5 Illusion   | 幻想的で夢幻的な雰囲気        | 非現実的な美しさや幻想的表現       |
```