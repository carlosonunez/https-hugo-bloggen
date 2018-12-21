#!/usr/bin/env make
TERRAFORM_SUMMARY := Module for running Terraform actions through Make via Docker Compose.

define TERRAFORM_NOTES
- You can do whatever you can do with Terraform through this module by calling \
	terraform_(action), \
	where (action) is the desired Terraform command.

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

.PHONY: terraform_output terraform_%

terraform_output:
	VARIABLE_TO_GET="$(VARIABLE_TO_GET)" docker-compose run terraform-output

terraform_%:
	action=$$(echo "$@" | sed 's/terraform_//'); \
	docker-compose run "terraform-$$action"
