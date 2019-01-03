#!/usr/bin/env make

.PHONY: terraform_% generate_terraform_vars
terraform_%:
	action=$$(echo "$@" | sed 's/terraform_//'); \
	$(DOCKER_COMPOSE_COMMAND) run --rm terraform $$action

generate_terraform_vars_for_unit_tests:
	$(DOCKER_COMPOSE_COMMAND) run --rm generate-terraform-unit-test-tfvars && \
	$(DOCKER_COMPOSE_COMMAND) run --rm generate-terraform-unit-test-backend

generate_terraform_vars:
	$(DOCKER_COMPOSE_COMMAND) run --rm generate-terraform-tfvars && \
	$(DOCKER_COMPOSE_COMMAND) run --rm generate-terraform-backend && \
	$(DOCKER_COMPOSE_COMMAND) run --rm generate-terraform-backend-vars

.PHONY: \
	set_up_infrastructure \
	tear_down_infrastructure

set_up_infrastructure: generate_terraform_vars terraform_init terraform_apply

tear_down_infrastructure: terraform_destroy

