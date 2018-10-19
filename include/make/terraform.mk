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
ENVIRONMENT: The name of the environment being provisioned.
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

define TERRAFORM_NOTES
- To reduce wait time during tests, a file called .terraform_is_initialized \
	is written to the current working directory to prevent 'terraform init' \
	from running multiple times. Remove this file to force re-initialization. \
	Here are some examples of when a reinitialization might be needed:

  * You have added variables to your environment dotfile or TERRAFORM_EXTRA_VARS.
  * You are using a new module in your Terraform configuration.
  * You need to update a module.

- You can specify a custom provider for storing Terraform remote state by \
  defining a Make variable called TERRAFORM_BACKEND_CONFIGURATION_(PROVIDER_NAME) \
  in include/make/providers/(PROVIDER_NAME).mk.

- terraform.tfvars is automatically generated from any TF_VAR_ environment \
  variables that you define in your environment dotfile (see env.example \
  for an example of this). If your Terraform provider requires additional \
  variables that are difficult/repetitive to expose in that dotfile, \
  create TERRAFORM_EXTRA_VARS_(PROVIDER_NAME) in include/make/providers/(PROVIDER_NAME).mk.
endef
define newline


endef

ifndef INFRASTRUCTURE_PROVIDER
$(error You need to define an INFRASTRUCTURE_PROVIDER at include/make/providers before using this include.)
endif
INFRASTRUCTURE_PROVIDER_UPCASE := $(shell echo $(INFRASTRUCTURE_PROVIDER) | \
	tr '[:lower:]' '[:upper:]')
ifndef ENVIRONMENT
$(error You need to define the environment being provisioned.)
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
export TERRAFORM_EXTRA_VARS

.PHONY: \
	terraform_validate \
	terraform_init \
	terraform_get \
	terraform_run \
	terraform_generate_variables \
	terraform_apply \
	terraform_plan \
	terraform_destroy

export TERRAFORM_EXTRA_VARS_$(INFRASTRUCTURE_PROVIDER_UPCASE)

terraform_generate_variables:
	# - First, turn all TF_VAR_ variables in our dotenv into proper Terraform variables.
	#   Ensure that any boolean values are *not* quoted so that they aren't mistaken for strings.
	# - Then, if our INFRASTRUCTURE_PROVIDER has any extra variables define in its Makefile,
	#   fetch them and include them in the Makefile.
	#   (This is handy for things like access and secret keys.)
	# - Next, ensure that any list variables are quoted properly so that Terraform can
	#   parse them correctly.
	# - Next, expose our environment as a variable.
	# - Finally, capture our backend block from our INFRASTRUCTURE_PROVIDER's Maekfile
	#   and write that to backend.tfvars.
	env | grep -E '^TF_VAR_' |  sed 's/^TF_VAR_\(.*\)=\(.*\)/\1 = "\2"/' > $(TERRAFORM_TFVARS_PATH) && \
	sed -i '' 's/= "(true|false)"/= \1/g' $(TERRAFORM_TFVARS_PATH) && \
	echo "$$TERRAFORM_EXTRA_VARS_$(INFRASTRUCTURE_PROVIDER_UPCASE)" >> $(TERRAFORM_TFVARS_PATH) && \
	sed -i '' 's/= "\(\[.*\]\)"/= \1/' $(TERRAFORM_TFVARS_PATH) &&  \
	echo "environment_name = \"$(ENVIRONMENT)\"" >> $(TERRAFORM_TFVARS_PATH) && \
	echo "$$TERRAFORM_BACKEND_FILE" > $(TERRAFORM_BACKEND_PATH);

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
	$(MAKE) terraform_run TERRAFORM_ACTION=plan TERRAFORM_ACTION_OPTIONS=-input=false

terraform_apply:
	$(MAKE) terraform_init && \
	$(MAKE) terraform_run TERRAFORM_ACTION=apply \
		TERRAFORM_ACTION_OPTIONS="-input=false -auto-approve $(TERRAFORM_ACTION_OPTIONS)"

terraform_destroy:
	$(MAKE) terraform_init && \
	$(MAKE) terraform_run TERRAFORM_ACTION=destroy \
		TERRAFORM_ACTION_OPTIONS="-input=false -auto-approve $(TERRAFORM_ACTION_OPTIONS)"

terraform_output:
	$(MAKE) check_environment_variable_VARIABLE_TO_GET && \
	$(MAKE) terraform_init && \
	$(MAKE) terraform_run TERRAFORM_ACTION=output \
		TERRAFORM_ACTION_OPTIONS="-json $(VARIABLE_TO_GET)"
		
