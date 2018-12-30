ifneq ($(VERBOSE),true)
MAKEFLAGS += --silent
endif
SHELL := /usr/bin/env bash
DOTENV_S3_BUCKET ?= $(shell cat .env_info)

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
	unit_setup \
	terraform_validate \
	run_hugo_unit_tests \
	unit_teardown

integration: \
	integration_setup \
	run_hugo_integration_tests \
	integration_teardown

.PHONY: unit_setup integration_setup remove_generated_static_content

unit_setup: _remove_generated_static_content

integration_setup: _get_integration_env_vars_from_s3 _set_up_remote_environment _deploy_blog_to_s3

.PHONY: unit_teardown integration_teardown

unit_teardown: _tear_down_local_environment

integration_teardown: _remove_hugo_blog_from_s3 \
	_tear_down_remote_environment \
	_tear_down_local_environment \
	_remove_generated_static_content

.PHONY: run_hugo_%_tests
run_hugo_%_tests:
	@tests_to_run=$$(echo "$@" | sed 's/run_hugo_\([a-zA-Z]\+\)_tests/\1/'); \
	$(MAKE) $${tests_to_run}_setup; \
	docker-compose --log-level ERROR run --rm "hugo-$$tests_to_run-tests"; \
	test_status=$$?; \
	$(MAKE) $${tests_to_run}_teardown; \
	exit $$test_status

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
	docker-compose --log-level ERROR down

.PHONY: terraform_% generate_terraform_vars
terraform_%:
	action=$$(echo "$@" | sed 's/terraform_//'); \
	docker-compose --log-level ERROR run --rm terraform $$action

generate_terraform_vars:
	docker-compose --log-level ERROR run --rm generate-terraform-tfvars && \
	docker-compose --log-level ERROR run --rm generate-terraform-backend-vars

.PHONY: _deploy_blog_to_s3 _remove_hugo_blog_from_s3 _get_%_env_vars_from_s3 _upload_%_env_vars_to_s3
_deploy_blog_to_s3:
	export S3_BUCKET=$$(docker-compose --log-level ERROR run --rm terraform output blog_bucket_name | tr -d '\r'); \
	docker-compose run --rm hugo && \
		S3_BUCKET="$${S3_BUCKET?Please provide a S3 bucket.}" docker-compose \
			--log-level ERROR \
			run --rm \
			deploy-hugo-to-s3

_remove_hugo_blog_from_s3:
	export S3_BUCKET=$$(docker-compose --log-level ERROR run --rm terraform output blog_bucket_name | tr -d '\r'); \
	S3_BUCKET="$${S3_BUCKET?Please provide a S3 bucket.}" \
		docker-compose --log-level ERROR run --rm remove-hugo-from-s3

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
	ENVIRONMENT_NAME=$$environment_name S3_BUCKET=$$s3_bucket \
		docker-compose --log-level ERROR run --rm "$$verb-dotenv-file-$$direction-s3"

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
	ENVIRONMENT_NAME=$$environment_name S3_BUCKET=$$s3_bucket \
		docker-compose --log-level ERROR run --rm "$$verb-dotenv-file-$$direction-s3"
