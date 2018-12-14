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
	run_bats_integration_tests \
	terraform_destroy

.PHONY: deploy deploy_infrastructure deploy_site

deploy: deploy_infrastructure deploy_blog

deploy_infrastructure: terraform_apply

deploy_blog: generate_static_files deploy_static_files

.PHONY: destroy

destroy: terraform_destroy

.PHONY: lint_shell lint_terraform

lint_shell: run_shellcheck

lint_terraform: \
	terraform_init \
	terraform_validate

