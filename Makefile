include .env

SHELL := /bin/bash
PROJECT_DIRECTORY := $(shell pwd)
PROJECT_NAME := plexflix

define DOCKER_COMPOSE_ARGS
	--log-level ERROR \
	--project-directory $(PROJECT_DIRECTORY) \
	--project-name $(PROJECT_NAME)
endef

get_service_health = $$(docker inspect --format {{.State.Health.Status}} $(1))

wait_until_service_healthy = { \
	echo "Waiting for $(1) to be healthy"; \
  until [[ $(call get_service_health,$(1)) != starting ]]; \
		do sleep 1; \
  done; \
	if [[ $(call get_service_health,$(1)) != healthy ]]; \
    then echo "$(1) failed health check"; \
		exit 1; \
  fi; \
}

help: ## usage
	@cat Makefile | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## build docker images
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		build \
			--force-rm \
			--parallel \
			--pull

clean: ## remove plexflix images & containers
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		down \
			--remove-orphans \
			--rmi all \
			--volumes

down: ## stop collection
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		down \
			--remove-orphans \
			--volumes

fuse-shared-mount: ## make shared fuse mount
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		run \
			--name fuse-shared-mount \
			--rm \
			-e MOUNT_DIR=$(dir) \
			fuse-shared-mount

logs: ## view the logs of one or more running services
ifndef file
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		logs \
			--follow \
			$(service)
else
	@echo "logging output to $(file)";
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		logs \
			--follow \
			$(service) > $(file)
endif

mount-health: ## check mount health
	@echo "plexdrive: $(call get_service_health,plexdrive)"

plexdrive-setup: ## create plexdrive configuration files
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		run \
			plexdrive \
				plexdrive_setup

up: ## start collection
	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans \
			plexdrive

	@$(call wait_until_service_healthy,plexdrive)

	@docker-compose ${DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans \
			plex

.PHONY: \
	help \
	build \
	clean \
	down \
	fuse-shared-mount \
	logs \
	mount-health \
	plexdrive-setup \
	up
