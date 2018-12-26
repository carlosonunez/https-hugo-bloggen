ifneq ($(VERBOSE),true)
MAKEFLAGS += --silent
endif
SHELL := /usr/bin/env bash

.PHONY: create_env
create_env:
	sed 's/ #.*$$//; /^#/d; /^$$/d' env.example > .env;

.PHONY: all
all: lint unit integration stage deploy

.PHONY: test
test: unit integration

.PHONY: unit integration stage deploy

unit: \
	unit_setup \
	terraform_validate \
	run_hugo_unit_tests \
	unit_teardown

integration: \
	integration_setup \
	run_hugo_integration_tests \
	integration_teardown

stage: set_up_remote_environment

deploy:
	export S3_BUCKET=$$(docker-compose run --rm terraform output blog_url); \
	S3_BUCKET_TO_DEPLOY_TO="$${S3_BUCKET?Please provide a S3 bucket.}" \
		docker-compose run --rm deploy-hugo

.PHONY: unit_setup integration_setup remove_generated_static_content

unit_setup: _remove_generated_static_content

integration_setup: _set_up_remote_environment deploy

.PHONY: unit_teardown integration_teardown

unit_teardown: _tear_down_local_environment

integration_teardown: _tear_down_remote_environment _tear_down_local_environment

.PHONY: run_hugo_%_tests
run_hugo_%_tests:
	tests_to_run=$$(echo "$@" | sed 's/run_hugo_\([a-zA-Z]\+\)_tests/\1/'); \
	$(MAKE) $${tests_to_run}_setup; \
	docker-compose run --rm "hugo-$$tests_to_run-tests"; \
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

_set_up_remote_environment: terraform_init terraform_apply

_tear_down_remote_environment: terraform_destroy

_tear_down_local_environment:
	docker-compose down

.PHONY: terraform_%
terraform_%:
	action=$$(echo "$@" | sed 's/terraform_//'); \
	docker-compose run --rm terraform $$action
