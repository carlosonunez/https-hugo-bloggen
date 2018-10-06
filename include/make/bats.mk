#!/usr/bin/env make
define BATS_USAGE
/include/make/bats.mk
Targets for running Bats tests.

Targets:

  run_bats_(TEST_TYPE)_tests     Runs BATS tests within a given folder called
	                               TEST_TYPE.
																 (e.g. 'unit', 'integration')

Environment Variables

  BATS_DOCKER_IMAGE              The Docker image to use; must contain bats.
endef
export BATS_DOCKER_IMAGE

.PHONY: bats_usage
bats_usage:
	@echo "$$BATS_DOCKER_IMAGE"

.PHONY: run_bats_%_tests
run_bats_%_tests: \
	TESTS_DIRECTORY = tests/$(shell echo $@ | sed 's/run_bats_\(.*\)_tests/\1/g')
run_bats_%_tests: check_environment_variable_BATS_DOCKER_IMAGE
run_bats_%_tests:
	if [ ! -d "$(PWD)/$(TESTS_DIRECTORY)" ]; \
	then \
		>&2 echo "ERROR: Tests directory not found at $(PWD)/$(TESTS_DIRECTORY)"; \
		exit 1; \
	fi; \
	type_of_tests=$$(basename $(TESTS_DIRECTORY)); \
	>&2 echo "INFO: Running $$type_of_tests tests from $(PWD)/$(TESTS_DIRECTORY)"; \
	$(MAKE) docker_run \
		DOCKER_IMAGE=$(BATS_DOCKER_IMAGE) \
		DOCKER_IMAGE_OPTIONS=$(TESTS_DIRECTORY)
