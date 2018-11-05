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

lint_shell: run_shellcheck

lint_terraform: terraform_init terraform_validate

unit: terraform_init run_bats_unit_tests
integration: terraform_init run_bats_integration_tests

.PHONY: deploy deploy_infrastructure deploy_site

deploy:
	# In progress!

deploy_infrastructure: terraform_apply

.PHONY: destroy destroy_infrastructure

destroy:
	# In progress

destroy_infrastructure: terraform_destroy
