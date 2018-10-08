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

  BACKEND_PROVIDER            The backend provider to use for managing
                              remote state. Defaults to INFRASTRUCTURE_PROVIDER.
                              This is useful if you want to use a non-cloud
                              based backend like Consul. Note that you
                              will still need to create a Makefile include
                              at include/make/BACKEND_PROVIDER.mk and define
                              (BACKEND_PROVIDER)_TERRAFORM_STATE_BACKEND_CONFIGURATION
                              there.
                              (Default: $(BACKEND_PROVIDER))

Notes:

- Every provider Make include *must* define a TERRAFORM_$${PROVIDER}_STATE_BACKEND_CONFIGURATION
  Make variable containing options for that provider's backend.
endef
export TERRAFORM_USAGE

ifndef INFRASTRUCTURE_PROVIDER
$(error Please define an infrastructure provider for Terraform to use)
endif

INFRASTRUCTURE_PROVIDER_UPCASE := \
	$(shell echo $(INFRASTRUCTURE_PROVIDER) | tr '[:lower:]' '[:upper:]')
BACKEND_PROVIDER ?= $(INFRASTRUCTURE_PROVIDER_UPCASE)

ifndef $(BACKEND_PROVIDER)_TERRAFORM_STATE_BACKEND_CONFIGURATION
$(error This Make include uses remote backends for managing Terraform state \
	by default. Please define your backend with the \
	$(BACKEND_PROVIDER)_TERRAFORM_STATE_BACKEND_CONFIGURATION \
	Make variable in: include/make/$(shell echo $(BACKEND_PROVIDER) | tr '[:upper:]' '[:lower:]').mk)
endif
export $(BACKEND_PROVIDER)_TERRAFORM_STATE_BACKEND_CONFIGURATION

INFRASTRUCTURE_DIRECTORY ?= '$(PWD)/infrastructure/$(INFRASTRUCTURE_PROVIDER)'
BACKEND_TFVARS_LOCATION := $(INFRASTRUCTURE_DIRECTORY)/backend.tfvars
TERRAFORM_TFVARS_LOCATION := $(INFRASTRUCTURE_DIRECTORY)/terraform.tfvars

.PHONY: \
	terraform_usage \
	terraform_validate \
	terraform_init \
	terraform_get \
	terraform_run \
	terraform_generate_variables

terraform_generate_backend:
	@echo "$$$(BACKEND_PROVIDER)_TERRAFORM_STATE_BACKEND_CONFIGURATION" > $(BACKEND_TFVARS_LOCATION)

terraform_generate_variables:
	env | \
		grep -E '^TF_VAR_' | \
		sed 's/^TF_VAR_\(.*\)=\(.*\)/\1 = "\2"/' > $(TERRAFORM_TFVARS_LOCATION)

terraform_usage:
	@echo "$$TERRAFORM_USAGE"

terraform_validate:
	$(MAKE) terraform_init && $(MAKE) terraform_run TERRAFORM_ACTION=validate

terraform_init:
	if [ ! -f .terraform_is_initialized ]; \
	then \
		$(MAKE) terraform_generate_backend && \
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
