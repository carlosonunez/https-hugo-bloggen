SHELL := /usr/bin/env bash
include include/make/load_first/*.mk
include include/make/**/*.mk
include include/make/*.mk

ifdef VERBOSE
$(info Verbose mode is on. Make will show all steps.)
else
.SILENT:
endif

.PHONY: all
all: lint unit integration deploy

.PHONY: test
test: lint unit integration

.PHONY: lint unit integration deploy

lint: lint_shell lint_terraform

unit: \
	terraform_init \
	setup_hugo_test_environment \
	run_bats_unit_tests \
	teardown_hugo_test_environment

integration: \
	terraform_init \
	terraform_apply \
	deploy_blog \
	run_bats_integration_tests \
	terraform_destroy

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

.PHONY: lint_shell lint_terraform

lint_shell: run_shellcheck

lint_terraform: \
	terraform_init \
	terraform_validate
