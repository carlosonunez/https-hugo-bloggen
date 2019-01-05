DECORATOR := **************
SHELL := /usr/bin/env bash -o pipefail
COMMIT_SHA := $(shell git rev-parse HEAD | head -c8)
PRODUCTION_TIMEOUT_SECONDS ?= 300
VERBOSE ?= false
ifneq ($(VERBOSE),true)
MAKEFLAGS += --silent
endif
include include/make/*.mk

.PHONY: test
test: unit integration 
.PHONY: unit integration deploy destroy

unit: \
	start_unit_tests \
	unit_setup \
	terraform_validate \
	run_hugo_unit_tests \
	unit_teardown \
	end_unit_tests

integration: \
	start_integration_tests \
	integration_setup \
	run_hugo_integration_tests \
	integration_teardown \
	end_integration_tests

deploy: \
	get_production_env_vars_from_s3 \
	set_up_infrastructure \
	version_hugo_index_and_error_files \
	deploy_hugo_blog_to_s3 \
	wait_for_dns_to_catch_up \
	run_production_tests

destroy:
	if [ -z "$(ENVIRONMENT_NAME)" ]; \
	then \
		>&2 echo "ERROR: Please use the ENVIRONMENT_NAME environment variable to \
provide the name of the environment to tear down."; \
		exit 1; \
	fi; \
	env_name_lcase=$$(echo $(ENVIRONMENT_NAME) | tr A-Z a-z); \
	$(MAKE) get_$${env_name_lcase}_env_vars_from_s3 \
		initialize_terraform \
		remove_hugo_blog_from_s3 \
		tear_down_infrastructure

.PHONY: run_production_tests

run_production_tests:
	$(MAKE) start_production_tests && \
	for attempt in $$(seq 1 $(PRODUCTION_TIMEOUT_SECONDS)); \
	do \
		>&2 echo "INFO: Attempt $$attempt out of $(PRODUCTION_TIMEOUT_SECONDS)"; \
		if $(MAKE) run_hugo_production_tests; \
		then \
			$(MAKE) end_production_tests; \
			exit 0; \
		fi; \
		sleep 1;  \
	done; \
	>&2 echo "ERROR: Production site never came up."; \
	$(MAKE) end_production_tests; \
	exit 1;

.PHONY: unit_setup integration_setup

unit_setup: \
	get_test_env_vars_locally \
	generate_terraform_vars_for_unit_tests \
	terraform_init \
	remove_generated_static_content

integration_setup:  \
	get_integration_env_vars_from_s3 \
	set_up_infrastructure \
	version_hugo_index_and_error_files \
	deploy_hugo_blog_to_s3 \
	wait_for_dns_to_catch_up

.PHONY: unit_teardown integration_teardown

unit_teardown:  tear_down_dockerized_infrastructure

integration_teardown:  \
	remove_hugo_blog_from_s3 \
	tear_down_infrastructure \
	tear_down_dockerized_infrastructure \
	remove_generated_static_content

