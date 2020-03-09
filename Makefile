include .env

SHELL := /bin/bash
PLEXFLIX_DOCKER_COMPOSE_COMMON_FILE := docker-compose.common.yml
PLEXFLIX_DOCKER_COMPOSE_HELPERS_FILE := docker-compose.helpers.yml
PLEXFLIX_DOCKER_COMPOSE_PLEX_FILE := ./plex/docker-compose.plex.yml
PLEXFLIX_DOCKER_COMPOSE_PLEXDRIVE_FILE := ./plexdrive/docker-compose.plexdrive.yml
PLEXFLIX_PROJECT_DIRECTORY := $(shell pwd)
PLEXFLIX_PROJECT_NAME := $(if $(PLEXFLIX_PROJECT_NAME),$(PLEXFLIX_PROJECT_NAME),plexflix)

define PLEXFLIX_DOCKER_COMPOSE_ARGS
	--file ${PLEXFLIX_DOCKER_COMPOSE_COMMON_FILE} \
	--file ${PLEXFLIX_DOCKER_COMPOSE_HELPERS_FILE} \
	--file ${PLEXFLIX_DOCKER_COMPOSE_PLEX_FILE} \
	--file ${PLEXFLIX_DOCKER_COMPOSE_PLEXDRIVE_FILE} \
	--log-level ERROR \
	--project-directory $(PLEXFLIX_PROJECT_DIRECTORY) \
	--project-name $(PLEXFLIX_PROJECT_NAME)
endef

get_service_health = $$(docker inspect --format {{.State.Health.Status}} $(PLEXFLIX_PROJECT_NAME)-$(1))

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

build: ## build plexflix images
ifndef service
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		build \
			--force-rm \
			--pull;
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		pull \
			--ignore-pull-failures;
else
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		build \
			--force-rm \
			$(service)
endif

clean: ## remove plexflix images & containers
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		down \
			--remove-orphans \
			--rmi all \
			--volumes

down: ## bring plexflix down
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		down \
			--remove-orphans \
			--volumes

exec: ## run a command against a running service
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		exec \
			$(service) \
				$(cmd)

fuse-shared-mount: ## make shared fuse mount
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		run \
			-e MOUNT_DIR=$(dir) \
			fuse-shared-mount

logs: ## view the logs of one or more running services
ifndef file
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		logs \
			--follow \
			$(service)
else
	@echo "logging output to $(file)";
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		logs \
			--follow \
			$(service) > $(file)
endif

mount-health: ## check mount health
	@echo "Plexdrive: $(call get_service_health,plexdrive)";
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		run \
			list

plexdrive-setup: ## create plexdrive configuration files
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		run \
			plexdrive \
				plexdrive_setup

restart: ## restart a service
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
	restart \
		$(service)

stop: ## stop a service
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
	stop \
		$(service)

up: ## bring plexflix up
ifndef service
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans \
			plexdrive

	@$(call wait_until_service_healthy,plexdrive)

	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans \
			plex
else
	@docker-compose ${PLEXFLIX_DOCKER_COMPOSE_ARGS} \
		up \
			--detach \
			--remove-orphans \
			$(service)
endif

.PHONY: \
	help \
	build \
	clean \
	down \
	exec \
	fuse-shared-mount \
	logs \
	mount-health \
	plexdrive-setup \
	restart \
	stop \
	up
