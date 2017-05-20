.PHONY: docker docker-build docker-push

NAME := eewbot

DOCKER ?= docker
DOCKER_REGISTRY := miyukki

docker: docker-build docker-push

docker-build: DOCKER_TAG ?= latest
docker-build:
	$(DOCKER) build -t $(DOCKER_REGISTRY)/$(NAME):$(DOCKER_TAG) .

docker-push: DOCKER_TAG ?= latest
docker-push: docker-build
	$(DOCKER) push $(DOCKER_REGISTRY)/$(NAME):$(DOCKER_TAG)


