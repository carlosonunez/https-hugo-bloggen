DECORATOR := **************
SHELL := /usr/bin/env bash
COMMIT_SHA := $(shell git rev-parse HEAD | head -c8)
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

production_tests: \
	start_production_tests \
	run_hugo_integration_tests \
	end_production_tests

deploy: \
	get_production_env_vars_from_s3 \
	set_up_infrastructure \
	version_index_and_error_files \
	deploy_blog_to_s3 \
	wait_for_dns_to_catch_up \
	production_tests

destroy: \
	remove_hugo_blog_from_s3 \
	generate_terraform_vars \
	terraform_init \
	terraform_destroy

.PHONY: unit_setup integration_setup

unit_setup: \
	get_test_env_vars_locally \
	generate_terraform_vars_for_unit_tests \
	terraform_init \
	remove_generated_static_content

integration_setup:  \
	get_integration_env_vars_from_s3 \
	set_up_infrastructure \
	version_index_and_error_files \
	deploy_blog_to_s3 \
	wait_for_dns_to_catch_up

.PHONY: unit_teardown integration_teardown

unit_teardown:  tear_down_dockerized_infrastructure

integration_teardown:  \
	remove_hugo_blog_from_s3 \
	tear_down_infrastructure \
	tear_down_dockerized_infrastructure \
	remove_generated_static_content

