PROTO_DIR:=./proto
GO_DIR:=./go

define __require_TAG
    @bash -c "if [ '${TAG}' = '' ]; then echo 'TAG is not defined; you must specify TAG like $$ make TAG=vx.y.z task'; exit 1; fi"
endef

.PHONY: fmt fmt-check lint lint-json build gen-go doc

fmt:
	buf format -w

fmt-check:
	buf format --exit-code

lint:
	buf lint

lint-json:
	buf lint --error-format=json

build:
	buf build

deps:
	buf mod update ${PROTO_DIR}

gen-go: distclean
	buf generate
	cd ${GO_DIR} && \
		go mod init github.com/KeitaShimura/logs-collector-protos/go && \
		go mod tidy

release: deps gen-go
	$(call __require_TAG)
	git diff --name-only --exit-code
	git tag -a ${TAG} -m "Release ${TAG}"
	git tag -a go/${TAG} -m "Release go/${TAG}"
	git push --tags

distclean:
	rm -rf ${GO_DIR}
