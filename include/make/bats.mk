#!/usr/bin/env make

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
	docker run --tty \
		--rm \
		--env-file $(ENVIRONMENT_FILE) \
		--volume /var/run/docker.sock:/var/run/docker.sock \
		--volume $$(which docker):/usr/bin/docker \
		--volume $(PWD):/work \
		--workdir /work \
		$(BATS_DOCKER_IMAGE) $(TESTS_DIRECTORY)
