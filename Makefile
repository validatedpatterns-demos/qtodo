CONTAINER_COMMAND = $(shell if [ -x "$(shell which docker)" ];then echo "docker" ; else echo "podman";fi)
TAG := $(or $(TAG),latest)
IMAGE := $(or $(IMAGE),localhost/qtodo:$(TAG))
VERSION := $(or $(VERSION),1.0.0)
ARTIFACT := $(or $(ARTIFACT),qtodo-$(VERSION)-SNAPSHOT-runner.jar)
SETTINGS := $(or $(SETTINGS),settings.xml)

.PHONY: build build-image build-custom-image clean
build:
	./mvnw -s $(SETTINGS) dependency:go-offline
	./mvnw -s $(SETTINGS) package -DskipTests -Dquarkus.package.jar.type=uber-jar

build-image:
	$(CONTAINER_COMMAND) build -t $(IMAGE) -f Containerfile.build --build-arg settings=$(SETTINGS)

build-image-binary:
	$(CONTAINER_COMMAND) build -t $(IMAGE) -f Containerfile --build-arg artifact=$(ARTIFACT) --build-arg version=$(VERSION)

clean:
	rm -rf target/*
