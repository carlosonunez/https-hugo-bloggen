#!/usr/bin/env make
TERRAFORM_SUMMARY := Module for running Terraform actions through Make.
define TERRAFORM_TARGETS
terraform_usage: Displays this help message.
terraform_plan: Calculates and displays a Terraform plan.
terraform_validate: Validates Terraform configuration throughout the codebase.
terraform_apply: Applies a Terraform plan.
terraform_destroy: Destroys a Terraform plan.
terraform_output: Displays any defined "outputs".
endef
define TERRAFORM_REQUIRED_ENV_VARS
TERRAFORM_DOCKER_IMAGE: The Docker image to use for running Terraform.
INFRASTRUCTURE_PROVIDER: The provider to provision infrastructure onto. \
	(A subdirectory for it must exist within \$$INFRASTRUCTURE_DIRECTORY.)
endef

define TERRAFORM_OPTIONAL_ENV_VARS
TERRAFORM_CLI_OPTIONS: Options to provide to the Terraform binary.
TERRAFORM_ACTION_OPTIONS: Options to provide to the Terraform action.
INFRASTRUCTURE_DIRECTORY: Directory containing Terraform code. \
	(Default: $(INFRASTRUCTURE_DIRECTORY))
endef

ifndef INFRASTRUCTURE_PROVIDER
$(error You need to define an INFRASTRUCTURE_PROVIDER at include/make/providers before using this include.)
endif

INFRASTRUCTURE_DIRECTORY ?= $(PWD)/infrastructure/$(INFRASTRUCTURE_PROVIDER)
TERRAFORM_BACKEND_PATH := $(INFRASTRUCTURE_DIRECTORY)/backend.tfvars
TERRAFORM_TFVARS_PATH := $(INFRASTRUCTURE_DIRECTORY)/terraform.tfvars
TERRAFORM_BACKEND_PATH_RELATIVE_TO_DOCKER := backend.tfvars
TERRAFORM_TFVARS_PATH_RELATIVE_TO_DOCKER := terraform.tfvars

BACKEND_PROVIDER ?= $(shell echo $(INFRASTRUCTURE_PROVIDER) | tr '[:lower:]' '[:upper:]')
ifndef TERRAFORM_BACKEND_CONFIGURATION_$(BACKEND_PROVIDER)
$(error You asked to use the '$(BACKEND_PROVIDER)' backend \
	but forgot to define TERRAFORM_BACKEND_CONFIGURATION_$(BACKEND_PROVIDER). \
	Consider defining this in \
	$(PWD)/include/make/providers/$(shell echo $(BACKEND_PROVIDER) | tr '[:upper:]' '[:lower:]').mk)
endif
define TERRAFORM_BACKEND_FILE
terraform {
	$(TERRAFORM_BACKEND_CONFIGURATION_$(BACKEND_PROVIDER))
}
endef
export TERRAFORM_BACKEND_FILE

.PHONY: \
	terraform_validate \
	terraform_init \
	terraform_get \
	terraform_run \
	terraform_generate_variables \
	terraform_apply \
	terraform_plan \
	terraform_destroy

terraform_generate_variables:
	env | \
		grep -E '^TF_VAR_' | sed 's/^TF_VAR_\(.*\)=\(.*\)/\1 = "\2"/' > $(TERRAFORM_TFVARS_PATH); \
	echo "$$TERRAFORM_BACKEND_FILE" > $(TERRAFORM_BACKEND_PATH); \

terraform_validate:
	$(MAKE) terraform_init && $(MAKE) terraform_run TERRAFORM_ACTION=validate

terraform_init:
	if [ ! -f .terraform_is_initialized ]; \
	then \
		$(MAKE) terraform_generate_variables && \
		$(MAKE) terraform_run TERRAFORM_ACTION=init \
			TERRAFORM_ACTION_OPTIONS="-backend-config='$(TERRAFORM_BACKEND_PATH_RELATIVE_TO_DOCKER)'" && \
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

terraform_plan:
	$(MAKE) terraform_init && \
	$(MAKE) terraform_run TERRAFORM_ACTION=plan

terraform_apply:
	$(MAKE) terraform_init && \
	$(MAKE) terraform_run TERRAFORM_ACTION=apply \
		TERRAFORM_ACTION_OPTIONS="-auto-approve $(TERRAFORM_ACTION_OPTIONS)"

terraform_destroy:
	$(MAKE) terraform_init && \
	$(MAKE) terraform_run TERRAFORM_ACTION=destroy \
		TERRAFORM_ACTION_OPTIONS="-auto-approve $(TERRAFORM_ACTION_OPTIONS)"
