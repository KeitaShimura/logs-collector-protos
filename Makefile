# プロジェクトのディレクトリ設定
PROTO_DIR:=./proto
GO_DIR:=./go

# TAG の指定を必須にする関数
define __require_TAG
    @bash -c "if [ -z '${TAG}' ]; then \
        echo '[ERROR] TAG is not set!'; \
        echo 'Usage: make TAG=vx.y.z <target>'; \
        exit 1; \
    fi"
endef

# 仮想ターゲット（ファイルと無関係に実行するコマンド）
.PHONY: all fmt fmt-check lint lint-json build update-deps generate-go release-and-push clean

# すべての処理を実行
all: fmt-check lint build update-deps generate-go

# コードフォーマット
fmt:
	buf format -w

fmt-check:
	buf format --exit-code

# 静的解析（Lint）
lint:
	buf lint

lint-json:
	buf lint --error-format=json

# Protobuf のビルド
build:
	buf build

# 依存関係の更新
update-deps:
	buf mod update ${PROTO_DIR}

# Go のコード生成
generate-go: clean
	buf generate
	cd ${GO_DIR} && \
		[ -f go.mod ] || go mod init github.com/KeitaShimura/logs-collector-protos/go && \
		go mod tidy

# リリース処理（タグ作成 & プッシュ）
release-and-push: update-deps generate-go
	$(call __require_TAG)
	git diff --name-only --exit-code
	git diff --cached --exit-code
	git tag -a ${TAG} -m "Release ${TAG}"
	git tag -a go/${TAG} -m "Release go/${TAG}"
	git push --tags

# クリーンアップ
clean:
	rm -rf ${GO_DIR}