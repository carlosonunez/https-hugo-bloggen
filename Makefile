ifneq ($(VERBOSE),true)
MAKEFLAGS += --silent
endif
SHELL := /usr/bin/env bash
DOTENV_S3_BUCKET ?= $(shell cat .env_info)
DNS_RETRY_LIMIT_SECONDS ?= 60
TEST_RESULTS_FILE := $(shell mktemp /tmp/test-results-XXXXXXXXX)
TEST_TIMER_FILE := $(shell mktemp /tmp/test-timer-XXXXXXXXX)

.PHONY: \
  create_env \
  get_integration_env \
  get_production_env \
  update_test_env \
  update_integration_env \
  update_production_env

create_env:
	sed 's/ #.*$$//; /^#/d; /^$$/d' env.example > .env;

get_integration_env: _get_integration_env_vars_from_s3
get_production_env: _get_production_env_vars_from_s3
update_integration_env: _upload_integration_env_vars_to_s3
update_production_env: _upload_production_env_vars_to_s3

.PHONY: test
test: unit integration

.PHONY: unit integration

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

.PHONY: start_%_tests end_%_tests

start_%_tests:
	test_type=$$(echo "$@" | sed 's/start_\(.*\)_tests/\U\1/'); \
	date +%s > $(TEST_TIMER_FILE); \
	>&2 printf "%-30s%s%30s\n" "---" "RUNNING $$test_type TESTS" "---"; \

end_%_tests:
	test_end_time=$$(date +%s); \
	test_type=$$(echo "$@" | sed 's/end_\(.*\)_tests/\U\1/'); \
	test_start_time=$$(cat $(TEST_TIMER_FILE)); \
	rm -f $(TEST_TIMER_FILE); \
	test_duration=$$(( $$test_end_time - $$test_start_time )); \
	test_output=$$(sed '$$d' $(TEST_RESULTS_FILE)); \
	test_result=$$(sed '$$!d' $(TEST_RESULTS_FILE)); \
	rm -f $(TEST_RESULTS_FILE); \
	echo "$$test_output"; \
	>&2 printf "%-20s%s%20s\n" "---" "$$test_type TESTS FINISHED IN APPROX. $$test_duration SECONDS" "---"; \
	exit "$$test_result"

.PHONY: unit_setup integration_setup remove_generated_static_content

unit_setup:  _remove_generated_static_content

integration_setup:  \
	_get_integration_env_vars_from_s3 \
	_set_up_remote_environment \
	_deploy_blog_to_s3 \
	_wait_for_dns_to_catch_up

.PHONY: unit_teardown integration_teardown

unit_teardown:  _tear_down_local_environment

integration_teardown:  \
	_remove_hugo_blog_from_s3 \
	_tear_down_remote_environment \
	_tear_down_local_environment \
	_remove_generated_static_content

.PHONY: run_hugo_%_tests
run_hugo_%_tests:
	-tests_to_run=$$(echo "$@" | sed 's/run_hugo_\([a-zA-Z]\+\)_tests/\1/'); \
	tests_to_run_upcase=$$(echo "$$tests_to_run" | tr a-z A-Z); \
	2>/dev/null docker-compose --log-level ERROR run --rm "hugo-$$tests_to_run-tests" > $(TEST_RESULTS_FILE); \
	echo "$$?" >> $(TEST_RESULTS_FILE)

.PHONY: \
	_remove_generated_static_content \
	_set_up_remote_environment \
	_tear_down_local_environment \
	_tear_down_remote_environment

_remove_generated_static_content:
	rm -rf site/

_set_up_remote_environment: generate_terraform_vars terraform_init terraform_apply

_tear_down_remote_environment: terraform_destroy

_tear_down_local_environment:
	2>/dev/null docker-compose --log-level ERROR down

.PHONY: terraform_% generate_terraform_vars
terraform_%:
	action=$$(echo "$@" | sed 's/terraform_//'); \
	2>/dev/null docker-compose --log-level ERROR run --rm terraform $$action

generate_terraform_vars:
	2>/dev/null docker-compose --log-level ERROR run --rm generate-terraform-tfvars && \
	2>/dev/null docker-compose --log-level ERROR run --rm generate-terraform-backend-vars

.PHONY: _deploy_blog_to_s3 _remove_hugo_blog_from_s3 _get_%_env_vars_from_s3 _upload_%_env_vars_to_s3
_deploy_blog_to_s3:
	export S3_BUCKET=$$(2>/dev/null docker-compose --log-level ERROR run --rm terraform output blog_bucket_name | tr -d '\r'); \
	2>/dev/null docker-compose run --rm hugo && \
		S3_BUCKET="$${S3_BUCKET?Please provide a S3 bucket.}" 2>/dev/null docker-compose \
			--log-level ERROR \
			run --rm \
			deploy-hugo-to-s3

_remove_hugo_blog_from_s3:
	export S3_BUCKET=$$(2>/dev/null docker-compose --log-level ERROR run --rm terraform output blog_bucket_name | tr -d '\r'); \
	S3_BUCKET="$${S3_BUCKET?Please provide a S3 bucket.}" \
		2>/dev/null docker-compose --log-level ERROR run --rm remove-hugo-from-s3

_get_%_env_vars_from_s3:
	touch .env && \
	s3_bucket=$(DOTENV_S3_BUCKET); \
	verb=$$(echo "$@" | cut -f2 -d _); \
	environment_name=$$(echo "$@" | cut -f3 -d _); \
	direction=$$(echo "$@" | cut -f6 -d _); \
	if ! test $$environment_name || ! test $$s3_bucket; \
	then \
		>&2 echo "Usage: DOTENV_S3_BUCKET=$$s3_bucket make $(MAKECMDGOALS)"; \
		exit 1; \
	fi; \
	>&2 echo "INFO: Fetching environment vars for [$$environment_name] from S3"; \
	ENVIRONMENT_NAME=$$environment_name S3_BUCKET=$$s3_bucket \
		2>/dev/null docker-compose --log-level ERROR run --rm "$$verb-dotenv-file-$$direction-s3"

_upload_%_env_vars_to_s3:
	s3_bucket=$(DOTENV_S3_BUCKET); \
	verb=$$(echo "$@" | cut -f2 -d _); \
	environment_name=$$(echo "$@" | cut -f3 -d _); \
	direction=$$(echo "$@" | cut -f6 -d _); \
	if ! test $$environment_name || ! test $$s3_bucket; \
	then \
		>&2 echo "Usage: DOTENV_S3_BUCKET=$$s3_bucket make $(MAKECMDGOALS)"; \
		exit 1; \
	fi; \
	>&2 echo "INFO: Updating environment vars for [$$environment_name] from S3"; \
	ENVIRONMENT_NAME=$$environment_name S3_BUCKET=$$s3_bucket \
		2>/dev/null docker-compose --log-level ERROR run --rm "$$verb-dotenv-file-$$direction-s3"

.PHONY: _wait_for_dns_to_catch_up 
_wait_for_dns_to_catch_up:
	blog_url=$$(2>/dev/null docker-compose --log-level ERROR run --rm terraform output blog_url | tr -d '\r'); \
	for i in $$(seq 1 $(DNS_RETRY_LIMIT_SECONDS)); \
	do \
		if host $$blog_url &>/dev/null; \
		then \
			exit 0; \
		fi; \
		>&2 echo "WARNING: $$blog_url is not up yet. (Attempt $$i/$(DNS_RETRY_LIMIT_SECONDS))"; \
	done; \
	>&2 echo "ERROR: $$blog_url never came up."; \
	exit 1;
