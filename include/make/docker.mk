#!/usr/bin/env make
EXPANDED_DOCKER_COMPOSE_COMMAND := docker-compose -f docker-compose.yml $(shell for file in include/compose/*.yml; do echo "-f $$file"; done)
ifneq ($(VERBOSE),true)
DOCKER_COMPOSE_COMMAND := 2>/dev/null $(EXPANDED_DOCKER_COMPOSE_COMMAND) --log-level CRITICAL
else
DOCKER_COMPOSE_COMMAND := $(EXPANDED_DOCKER_COMPOSE_COMMAND) --log-level INFO
endif

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

