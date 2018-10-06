#!/usr/bin/env make
define PROVIDER_AWS_USAGE
$@
Configures the AWS cloud provider.

Required environment variables:

  AWS_REGION              The region to provision infrastructure into.

  AWS_ACCESS_KEY_ID       The IAM access key to use for AWS API calls.

  AWS_SECRET_ACCESS_KEY   The secret key to use for AWS_ACCESS_KEY_ID
endef
export PROVIDER_AWS_USAGE

ifeq ($(INFRASTRUCTURE_PROVIDER),aws)
$(info Check)
ifndef AWS_ACCESS_KEY_ID
$(error Please provide an AWS access key to use)
endif
ifndef AWS_SECRET_ACCESS_KEY
$(error Please provide an AWS secret key to use)
endif
ifndef AWS_REGION
$(error Please define the AWS region to use)
endif
endif

# Terraform exports.
export TF_VAR_aws_access_key = $(AWS_ACCESS_KEY_ID)
export TF_VAR_aws_secret_key = $(AWS_SECRET_ACCESS_KEY)
export TF_VAR_aws_region = $(AWS_REGION)

.PHONY: provider_aws_usage
provider_aws_usage:
	@echo "$$PROVIDER_AWS_USAGE"
