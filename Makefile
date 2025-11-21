CONTAINER_COMMAND = $(shell if [ -x "$(shell which docker)" ];then echo "docker" ; else echo "podman";fi)
TAG := $(or $(TAG),latest)
TAG_SIGNER := $(or $(TAG_SIGNER),signer)
IMAGE := $(or $(IMAGE),localhost/qtodo:$(TAG))
IMAGE_SIGNER := $(or $(IMAGE_SIGNER),localhost/qtodo-signer:$(TAG))
VERSION := $(or $(VERSION),1.0.0)
ARTIFACT := $(or $(ARTIFACT),qtodo-$(VERSION)-SNAPSHOT-runner.jar)
KUBECONFIG := $(or $(KUBECONFIG),$(HOME)/.kube/config)

export ROOT_DIR = $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BIN = $(ROOT_DIR)/target

UNAME_S := $(shell uname -s)
SELINUX_SUFFIX :=
ifeq ($(UNAME_S),Linux)
    SELINUX_SUFFIX := :Z
endif

.PHONY: build build-local sign-artifact build-image push clean
build: build-image $(BIN)
	$(CONTAINER_COMMAND) create --name qtodo-build-tmp $(IMAGE)
	$(CONTAINER_COMMAND) cp qtodo-build-tmp:/deployments/$(ARTIFACT) $(BIN)/$(ARTIFACT)
	$(CONTAINER_COMMAND) rm -f qtodo-build-tmp

build-local: clean
	mvn package -Dquarkus.package.jar.type=uber-jar

sign-artifact:
	$(CONTAINER_COMMAND) build -t $(IMAGE_SIGNER) -f Containerfile.signer
	$(CONTAINER_COMMAND) run --rm -v $(BIN):/signer$(SELINUX_SUFFIX) -v $(KUBECONFIG):/root/.kube/config$(SELINUX_SUFFIX) $(IMAGE_SIGNER) /signer/$(ARTIFACT)

build-image:
	$(CONTAINER_COMMAND) build -t $(IMAGE) -f Containerfile.build

push:
	$(CONTAINER_COMMAND) push $(IMAGE)

$(BIN):
	-mkdir -p $(BIN)

clean:
	rm -rf $(BIN)/*