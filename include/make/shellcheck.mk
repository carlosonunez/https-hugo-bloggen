#!/usr/bin/env make
define SHELLCHECK_USAGE
include/make/shellcheck.mk
Interface for running shellcheck actions.

Targets:

  run_shellcheck               Performs a shellcheck run against any file
                               that ends in *.sh or *.bash.

  shellcheck_usage             Displays this help message.

Optional Environment Variables:

  SHELLCHECK_DOCKER_IMAGE      The shellcheck Docker image to use.
endef
export SHELLCHECK_USAGE

shellcheck_usage:
	@echo "$$SHELLCHECK_USAGE"
.PHONY: run_shellcheck
run_shellcheck:
	$(MAKE) check_environment_variable_SHELLCHECK_DOCKER_IMAGE && \
	$(MAKE) docker_run \
		DOCKER_IMAGE=$(SHELLCHECK_DOCKER_IMAGE) \
		DOCKER_IMAGE_OPTIONS=$$(find . \( -name *.sh -o -name *.bash \))
