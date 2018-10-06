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

Optional Environment Variables:

  TERRAFORM_CLI_OPTIONS       Options to provide to the Terraform binary.

  TERRAFORM_ACTION_OPTIONS    Options to provide to the Terraform action.
endef
export TERRAFORM_USAGE

.PHONY: \
	terraform_usage \
	terraform_validate

terraform_usage:
	@echo "$$TERRAFORM_USAGE"

terraform_validate:
	$(MAKE) terraform_run TERRAFORM_ACTION=validate

terraform_run:
	$(MAKE) check_environment_variable_TERRAFORM_ACTION && \
	$(MAKE) check_environment_variable_TERRAFORM_DOCKER_IMAGE && \
	$(MAKE) docker_run \
		DOCKER_IMAGE=$(TERRAFORM_DOCKER_IMAGE) \
		DOCKER_IMAGE_OPTIONS="$(TERRAFORM_CLI_OPTIONS) $(TERRAFORM_ACTION) $(TERRAFORM_ACTION_OPTIONS)"
