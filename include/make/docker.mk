#!/usr/bin/env make
HOST_PWD ?= $(shell pwd)
EXPANDED_DOCKER_COMPOSE_COMMAND := HOST_PWD=$(HOST_PWD) docker-compose -f docker-compose.yml $(shell for file in include/compose/*.yml; do echo "-f $$file"; done)
DOCKER_COMPOSE_COMMAND := $(EXPANDED_DOCKER_COMPOSE_COMMAND) --log-level CRITICAL
ifeq ($(SHOW_DOCKER_COMPOSE_LOGS),true)
DOCKER_COMPOSE_COMMAND := $(EXPANDED_DOCKER_COMPOSE_COMMAND) --log-level INFO
endif
ifeq ($(VERBOSE),true)
DOCKER_COMPOSE_COMMAND := $(EXPANDED_DOCKER_COMPOSE_COMMAND) --log-level INFO
endif
DOCKER_COMPOSE_RUN_COMMAND := $(DOCKER_COMPOSE_COMMAND) run --rm --user="$(shell id -u)"

.PHONY: get_docker_compose_command tear_down_dockerized_infrastructure

get_docker_compose_command:
	if [ -z "$(DOCKER_COMPOSE_COMMAND)" ]; \
	then \
		>&2 echo "ERROR: Docker Compose command not defined."; \
		exit 1; \
	fi; \
	if ! >/dev/null which docker-compose; \
	then \
		>&2 echo "ERROR: Docker Compose is not installed. Please install it."; \
		exit 1; \
	fi; \
	echo "$(DOCKER_COMPOSE_COMMAND)";

tear_down_dockerized_infrastructure:
	$(DOCKER_COMPOSE_COMMAND) down

