# logs-collector-protos

## 概要

`logs-collector-protos` は、ログ収集システムに関する **gRPC API スキーマ** を管理するリポジトリです。
このリポジトリでは、`Protocol Buffers (protobuf)` を用いた **API 定義** を作成し、**gRPC クライアント・サーバーコードを自動生成** します。

---

## 特徴

**gRPC API スキーマの統一**

- `proto/logs/v1/` に `.proto` ファイルを配置
- API 仕様の統一とバージョン管理 (`v1`, `v2` など)

**Go 用の gRPC クライアント/サーバーコードを自動生成**

- `buf` を使用し、Go コード (`.pb.go`) を `go/logs/v1/` に出力
- `make generate-go` 実行時、Go モジュールの初期化・依存解決（`go mod init`/`go mod tidy`）も自動で行われます

**CI/CD を導入**

- **プルリクエスト作成時**に `.proto` ファイルの Lint チェック・フォーマットチェックを [GitHub Actions](.github/workflows/ci.yaml) で自動実行
- **`v*`タグを push** すると [GitHub Release](.github/workflows/release.yaml) が自動作成されます

**Makefile でビルド・リリースを自動化**

このリポジトリでは、`Makefile` を使用して gRPC のコード生成、フォーマット、Lint チェック、リリース処理などを **簡単に実行できる** ようにしています。

### **Makefile のコマンド一覧**

#### 基本コマンド

| コマンド           | 説明                                                                                                     |
| ------------------ | -------------------------------------------------------------------------------------------------------- |
| `make all`         | `fmt-check`, `lint`, `build`, `update-deps`, `generate-go` を順番に実行                                  |
| `make fmt`         | `.proto` ファイルのフォーマットを `buf format` を使って適用                                              |
| `make fmt-check`   | `.proto` のフォーマットをチェック (`--exit-code` 付き)                                                   |
| `make lint`        | `.proto` の Lint チェック (`buf lint` を実行)                                                            |
| `make lint-json`   | `.proto` の Lint チェック結果を JSON 形式で出力                                                          |
| `make build`       | `.proto` の構文チェック (`buf build`)                                                                    |
| `make update-deps` | `buf mod update` を実行し、依存関係を更新                                                                |
| `make generate-go` | `.proto` から gRPC の Go コードを自動生成 (`buf generate` 実行)。Go モジュール初期化・依存解決も自動実行 |
| `make clean`       | `go/` ディレクトリを削除（リセット）                                                                     |

#### リリース関連コマンド

| コマンド                           | 説明                                                                      |
| ---------------------------------- | ------------------------------------------------------------------------- |
| `make release-and-push TAG=v1.0.0` | 指定したタグ (`TAG`) で GitHub にリリース (`git tag` & `git push --tags`) |

---

## ディレクトリ構成

```sh
logs-collector-protos/
├── .github/workflows/      # CI/CD 設定
│   ├── ci.yaml             # Lint チェックワークフロー
│   ├── release.yaml        # GitHub タグリリースワークフロー
├── go/                     # 自動生成された gRPC クライアント・サーバーコード
│   ├── logs/v1/            # v1 API の gRPC コード
│   │   ├── models.pb.go
│   │   ├── service.pb.go
│   │   ├── service_grpc.pb.go
│   ├── go.mod              # Go モジュール管理
│   ├── go.sum              # 依存関係のロックファイル
├── proto/                  # Proto 定義
│   ├── logs/v1/            # v1 API の定義
│   │   ├── models.proto      # ログのエンティティ
│   │   ├── service.proto   # ログ収集APIの gRPC サービス定義
│   ├── buf.yaml            # Lint / Breaking Change ルール
│   ├── buf.lock            # 依存管理
├── buf.gen.yaml            # gRPC コード生成設定
├── buf.work.yaml           # BSR (Buf Schema Registry) の設定
├── Makefile                # 自動化スクリプト
├── README.md               # 本ファイル
```

## 環境セットアップ

### **依存パッケージ**

- [Go](https://go.dev/) (>=1.24)
- [Protocol Buffers](https://protobuf.dev/) (>=3.21)
- [Buf CLI](https://buf.build/) (>=1.11)

### **ローカルセットアップ**

#### **Buf をインストール**

```sh
# Homebrew
brew install bufbuild/buf/buf
```
