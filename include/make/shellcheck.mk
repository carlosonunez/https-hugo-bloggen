#!/usr/bin/env make
SHELLCHECK_SUMMARY := Run Dockerized shellcheck in Make.
SHELLCHECK_TARGETS := run_shellcheck: Run shellcheck against all shell \
	scripts in repository.
SHELLCHECK_OPTIONAL_ENV_VARS := \
	SHELLCHECK_DOCKER_IMAGE: The Docker image to use (Default: $(SHELLCHECK_DOCKER_IMAGE))

.PHONY: run_shellcheck
run_shellcheck:
	$(MAKE) check_environment_variable_SHELLCHECK_DOCKER_IMAGE && \
	$(MAKE) docker_run \
		DOCKER_IMAGE=$(SHELLCHECK_DOCKER_IMAGE) \
		DOCKER_IMAGE_OPTIONS=$$(find . \( -name *.sh -o -name *.bash \))
