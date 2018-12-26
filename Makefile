MAKEFLAGS += --silent
SHELL := /usr/bin/env bash
EXAMPLE_ENVIRONMENT_FILE := $(PWD)/env.example
ENVIRONMENT_FILE := $(PWD)/.env

ifeq ("$(wildcard $(EXAMPLE_ENVIRONMENT_FILE))","")
$(error Missing example environment file: $(EXAMPLE_ENVIRONMENT_FILE))
endif

ifeq (,$(wildcard $(ENVIRONMENT_FILE)))
$(error Missing environment file: $(ENVIRONMENT_FILE))
endif

include $(ENVIRONMENT_FILE)
export $(shell sed 's/=.*//' $(ENVIRONMENT_FILE))
ifeq ($(ENVIRONMENT),)
$(error Please provide an environment name)
endif

.PHONY: all
all: lint unit integration deploy

.PHONY: test
test: unit integration

.PHONY: unit integration deploy

unit: \
	terraform_validate \
	run_hugo_unit_tests \
	unit_teardown

integration: \
	integration_setup \
	run_hugo_integration_tests \
	integration_teardown

.PHONY: deploy deploy_infrastructure deploy_blog

deploy: deploy_infrastructure deploy_blog

deploy_infrastructure: terraform_apply

deploy_blog:
	bucket_path=$$(VARIABLE_TO_GET=blog_url make terraform_output); \
	if [ -z "$$bucket_path" ]; \
	then \
		>&2 echo "ERROR: No AWS S3 bucket to deploy to was found."; \
		exit 1; \
	fi; \
	$(MAKE) generate_hugo_static_files && \
	BUCKET_TO_DEPLOY_TO="$$bucket_path" $(MAKE) deploy_hugo_static_files

.PHONY: destroy

destroy: terraform_destroy

.PHONY: unit_setup integration_setup

unit_setup:
	rm -rf site/

integration_setup: terraform_init terraform_apply deploy_blog

.PHONY: unit_teardown integration_teardown

unit_teardown:
	docker-compose down

integration_teardown:
	terraform_destroy && docker-compose down

.PHONY: run_hugo_%_tests
run_hugo_%_tests:
	tests_to_run=$$(echo "$@" | sed 's/run_hugo_\([a-zA-Z]\+\)_tests/\1/'); \
	$(MAKE) $${tests_to_run}_setup; \
	HUGO_VERSION="$(HUGO_VERSION)" docker-compose run --rm "hugo-$$tests_to_run-tests"; \
	test_status=$$?; \
	$(MAKE) $${tests_to_run}_teardown; \
	exit $$test_status

.PHONY: terraform_%
terraform_%:
	action=$$(echo "$@" | sed 's/terraform_//'); \
	docker-compose up "terraform-$$action"
