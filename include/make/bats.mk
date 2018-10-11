#!/usr/bin/env make
BATS_SUMMARY := Targets for running tests with Bash Automated Testing System
BATS_REQUIRED_ENV_VARS := BATS_DOCKER_IMAGE: The Docker image containing BATS to use.
define BATS_TARGETS
run_bats_<TEST_TYPE>_tests: Runs a test suite within tests/TEST_TYPE.
endef

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
