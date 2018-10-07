#!/usr/bin/env make
define TERRAFORM_USAGE
include/make/terraform.mk
Interface for running Terraform actions.

Targets:

	terraform_usage             Displays this help message.

  terraform_plan              Calculates and displays a Terraform plan.

  terraform_validate          Validates Terraform configuration throughout
                              the codebase.

  terraform_apply             Applies a Terraform plan.

  terraform_destroy           Destroys a Terraform plan.

  terraform_output            Displays any defined "outputs".

Required Environment Variables:

  TERRAFORM_DOCKER_IMAGE      The Docker image to use for running Terraform.

  INFRASTRUCTURE_PROVIDER     The provider to provision infrastructure onto.
                              (A subdirectory for it must exist within
                               $$INFRASTRUCTURE_DIRECTORY.)

Optional Environment Variables:

  TERRAFORM_CLI_OPTIONS       Options to provide to the Terraform binary.

  TERRAFORM_ACTION_OPTIONS    Options to provide to the Terraform action.

  INFRASTRUCTURE_DIRECTORY    Directory containing Terraform code.
                              (Default: $(INFRASTRUCTURE_DIRECTORY))

endef
export TERRAFORM_USAGE

INFRASTRUCTURE_DIRECTORY ?= '$(PWD)/infrastructure/$(INFRASTRUCTURE_PROVIDER)'

.PHONY: \
	terraform_usage \
	terraform_validate \
	terraform_init \
	terraform_get \
	terraform_run \
	terraform_generate_variables

terraform_generate_variables:
	env | \
		grep -E '^TF_VAR_' | \
		sed 's/^TF_VAR_\(.*\)=\(.*\)/\1 = "\2"/' > infrastructure/$(INFRASTRUCTURE_PROVIDER)/terraform.tfvars

terraform_usage:
	@echo "$$TERRAFORM_USAGE"

terraform_validate:
	$(MAKE) terraform_init && $(MAKE) terraform_run TERRAFORM_ACTION=validate

terraform_init:
	if [ ! -f .terraform_is_initialized ]; \
	then \
		$(MAKE) terraform_run TERRAFORM_ACTION=init && \
		$(MAKE) terraform_generate_variables && \
		touch .terraform_is_initialized; \
	fi

terraform_get:
	$(MAKE) terraform_run TERRAFORM_ACTION=get

terraform_run:
	$(MAKE) check_environment_variable_TERRAFORM_ACTION && \
	$(MAKE) check_environment_variable_TERRAFORM_DOCKER_IMAGE && \
	$(MAKE) check_environment_variable_INFRASTRUCTURE_PROVIDER && \
	$(MAKE) docker_run \
		PWD_TO_USE=$(INFRASTRUCTURE_DIRECTORY) \
		DOCKER_IMAGE=$(TERRAFORM_DOCKER_IMAGE) \
		DOCKER_IMAGE_OPTIONS="$(TERRAFORM_CLI_OPTIONS) $(TERRAFORM_ACTION) $(TERRAFORM_ACTION_OPTIONS)"
