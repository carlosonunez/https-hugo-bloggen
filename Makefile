SHELL := /usr/bin/env bash
COMMIT_SHA ?= $(shell git rev-parse HEAD | head -c8)
VERBOSE ?= false
INTEGRATION_TEST_TIMEOUT_IN_SECONDS := 150
PRODUCTION_TEST_TIMEOUT_IN_SECONDS := 300
SHOW_DOCKER_COMPOSE_LOGS ?= true

ifneq (,$(wildcard ./.env))
	include .env
	export
endif

ifneq ($(VERBOSE),true)
MAKEFLAGS += --silent
endif
include include/make/*.mk

.PHONY: test
test: unit integration 

.PHONY: unit integration deploy destroy clean

clean:
	rm -rf /tmp/test-*

unit: \
	start_unit_tests \
	unit_setup \
	terraform_validate \
	run_hugo_unit_tests \
	unit_teardown \
	end_unit_tests

integration: TEST_TIMEOUT_IN_SECONDS = $(INTEGRATION_TEST_TIMEOUT_IN_SECONDS)
integration: \
	start_integration_tests \
	integration_setup \
	run_hugo_integration_tests_with_timeout \
	integration_teardown \
	end_integration_tests

deploy: \
	test_commit_sha_or_exit \
	set_up_infrastructure \
	version_hugo_index_and_error_files \
	deploy_hugo_blog_to_s3 \
	wait_for_dns_to_catch_up \
	run_production_tests

test_commit_sha_or_exit:
	if [ -z "$(COMMIT_SHA)" ]; \
	then \
		>&2 echo "ERROR: Please provide a commit SHA through the COMMIT_SHA \
environment variable."; \
		exit 1; \
	fi
	>&2 echo "=======> Deploying blog $(HUGO_BASE_URL) with version \
$(COMMIT_SHA) using theme: $(HUGO_THEME_REPO_URL)]"

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

run_production_tests: TEST_TIMEOUT_IN_SECONDS = $(PRODUCTION_TEST_TIMEOUT_IN_SECONDS)
run_production_tests: \
	start_production_tests \
	run_hugo_production_tests_with_timeout \
	end_production_tests

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

