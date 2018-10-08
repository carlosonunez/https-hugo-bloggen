#!/usr/bin/env make
define PROVIDER_AWS_USAGE
$@
Configures environment variables and Terraform configurations for AWS.

Required environment variables:

  AWS_REGION              The region to provision infrastructure into.

  AWS_ACCESS_KEY_ID       The IAM access key to use for AWS API calls.

  AWS_SECRET_ACCESS_KEY   The secret key to use for AWS_ACCESS_KEY_ID

Notes:

- The Terraform backend this provider configures uses the same region as the
one defined by AWS_REGION. You will need to modify this include if your
requirements differ.
endef
export PROVIDER_AWS_USAGE

ifeq ($(INFRASTRUCTURE_PROVIDER),aws)
ifndef AWS_ACCESS_KEY_ID
$(error Please provide an AWS access key to use with the \
	AWS_ACCESS_KEY_ID environment variable)
endif
ifndef AWS_SECRET_ACCESS_KEY
$(error Please provide an AWS secret key to use with the \
	AWS_SECRET_ACCESS_KEY environment variable)
endif
ifndef AWS_REGION
$(error Please define the AWS region to use with the \
	AWS_REGION environment variable)
endif
ifndef TERRAFORM_S3_BUCKET
$(error Please define the S3 bucket to use for storing state with the \
	TERRAFORM_S3_BUCKET environment variable)
endif
ifndef TERRAFORM_S3_KEY
	$(error Please use the TERRAFORM_S3_KEY environment variable to define the \
		AWS S3 key to store Terraform state inside of))
endif
endif

# Terraform backend definitions
define AWS_TERRAFORM_STATE_BACKEND_CONFIGURATION
bucket = "$(TERRAFORM_S3_BUCKET)"
key = "$(TERRAFORM_S3_KEY)"
region = "$(AWS_REGION)"
endef

# Terraform exports.
export TF_VAR_aws_access_key = $(AWS_ACCESS_KEY_ID)
export TF_VAR_aws_secret_key = $(AWS_SECRET_ACCESS_KEY)
export TF_VAR_aws_region = $(AWS_REGION)


.PHONY: provider_aws_usage
provider_aws_usage:
	@echo "$$PROVIDER_AWS_USAGE"
