
# CS「ローカルLLM」

- 2025-08-20 23:55:53

## Local LLMモデル入門：基礎知識編 2025/07/06

https://zenn.dev/ignission/articles/366a9866215340

| モデル   | 開発元     | 特徴                     | サイズ展開             | ライセンス                                    | 日本語 |
|----------|------------|--------------------------|------------------------|-----------------------------------------------|--------|
| Llama    | Meta       | 最も人気 汎用性が高い    | 1B, 3B, 8B 13B, 70B    | 月間アクティブユーザー7億人まで               | ★☆☆☆☆ |
| Mistral  | Mistral AI | 効率重視 軽くて速い      | 7B, 8×7B (MoE)         | 完全オープン                                  | ★★☆☆☆ |
| Qwen     | Alibaba    | 多言語対応 日本語に強い  | 0.5B～72B              | Apache 2.0                                    | ★★★★★ |
| DeepSeek | DeepSeek   | コーディング特化 推論能力高い | 1.5B～67B          | MIT                                           | ★★★★☆ |
| Gemma    | Google     | 軽量・安全 初心者向け    | 2B, 7B, 9B             | 商用利用可能だが、Googleの利用規約に従う必要あり | ★★☆☆☆ |

- OS
    - Mac
        - ユニファイドメモリで大容量化可能
        - 低消費電力


- 量子化
    - VRAM/メモリに余裕あり	Q6_K〜Q8_0	品質を最大限維持
    - 一般的な環境	Q4_K_M〜Q5_K_M	バランスが良い
    - メモリが厳しい	Q3_K_S	動作を優先
    - とにかく動かしたい	Q2_K	品質は諦める

| 量子化レベル | ビット数 | 圧縮後サイズ | メモリ削減率 | 品質 | 用途・特徴 |
|--------------|---------|-------------|-------------|------|-----------|
| FP16         | 16ビット | 100%（基準） | 0%          | ★★★★★ | 元のモデル（圧縮なし） |
| Q8_0         | 8ビット  | 50%          | 50%削減      | ★★★★★ | ほぼ品質劣化なし |
| Q6_K         | 6ビット  | 37.5%        | 62.5%削減    | ★★★★☆ | 高品質維持 |
| Q5_K_M       | 5ビット  | 31.25%       | 68.75%削減   | ★★★★☆ | バランス重視 |
| Q4_K_M       | 4ビット  | 25%          | 75%削減      | ★★★☆☆ | 最も人気 |
| Q3_K_S       | 3ビット  | 18.75%       | 81.25%削減   | ★★☆☆☆ | 軽量版 |
| Q2_K         | 2ビット  | 12.5%        | 87.5%削減    | ★☆☆☆☆ | 品質は大幅低下 |


- ローカルLLMを動かす2つのツール
    - LM Studio
        - GUI
    - Ollama
        - CKI


## gpt-ossをLM Studioで動かしてみよう！【ローカルPCで動くAI】〜初心者向け〜 Python SDKで動かす方法も解説！ 2025/08/08

https://www.youtube.com/watch?v=cm140jJiwwc

- gpt-oss
    - チャット向け
    - メモリ16GBで動く
- 賢さ
    - grok > 03 > gemini > qwen > deepseek > gpt-oss > llama　


## ローカル LLM を使用して AI コーディングを試してみた 2025/07/16

https://zenn.dev/st_little/articles/tried-ai-coding-with-local-llm

- LM Studio
    - DiscoverでモデルをDL
    - Developer の Select a model to load から使用するモデルを選択します。
    - トグルボタンを ON にしてサーバーを起動し、Status が Running に
- VSCodeのCline
    - コマンドパレットから Cline: Add to Cline
    - API Configuration
        - API Provider: LM Studio を選択
        - Model ID: 使用するモデルを選択


## OllamaとClineを使用したローカルLLM開発環境の完全ガイド 2025年6月5日 12:07

https://note.com/hirokitakamura/n/n3d686bf4f536

- ハイエンド環境（16GB+ VRAM）：
    - `qwen2.5-coder:32b` - 最高のコーディングパフォーマンス
    - `deepseek-coder-v2:16b` - 複雑なタスクに優れる
- 日本語対応モデル
    - Llama-3-ELYZA-JP-8B - ELYZA社の日本語最適化モデル
    - Sarashina-2.2 3B - 軽量な日本語モデル
    - LLM-jp-3 7.2B - 日本の研究コミュニティモデル
    - Tanuki 8B - 日本語会話に特化

## 話題のAIエージェント！Clineについて解説してみた 2025/01/11

https://www.youtube.com/watch?v=Fd_UK0zhhAQ

- OpenRouter
    - 1課金で複数サービス使える


## 処理節約メモ

- プロンプト
    - LM Studio、RTX4090、i9-14900KF、qwen2.5-coder-32bを使っており、 Context Length 4096 GPU Offload 58 CPU Thread Pool Size 12 で設定しています。 Clineを利用したときに12491 tokensが必要だと言われてトークン数を16384くらいに増やしたいのですが、どう設定するのが適切でしょうか。
- Context Length
    - 16384
    - 