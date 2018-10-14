#!/usr/bin/env make
AWS_SUMMARY := Configure Make (and Terraform, if applicable) to use AWS.
define AWS_REQUIRED_ENV_VARS
AWS_REGION: The AWS region to use (ex. us-east-1, eu-west-2)
AWS_ACCESS_KEY_ID: The access key to use for AWS API calls.
AWS_SECRET_ACCESS_KEY: The secret key to use for AWS API calls.
endef

ifndef AWS_ACCESS_KEY_ID
$(error Please provide an AWS access key to use)
endif
ifndef AWS_SECRET_ACCESS_KEY
$(error Please provide an AWS secret key to use)
endif
ifndef AWS_REGION
$(error Please define the AWS region to use)
endif
ifndef TERRAFORM_STATE_S3_BUCKET_NAME
$(error Please define a S3 bucket to store Terraform state within)
endif
ifndef TERRAFORM_STATE_S3_BUCKET_KEY
$(error Please define a key within TERRAFORM_STATE_S3_BUCKET_NAME to store Terraform state within)
endif

# Use the S3 backend
define TERRAFORM_BACKEND_CONFIGURATION_AWS
backend "s3" {
	bucket = "$(TERRAFORM_STATE_S3_BUCKET_NAME)"
	key = "$(TERRAFORM_STATE_S3_BUCKET_KEY)"
	region = "$(AWS_REGION)"
}
endef

define TERRAFORM_EXTRA_VARS_AWS
aws_access_key = "$(AWS_ACCESS_KEY_ID)"
aws_secret_access_key = "$(AWS_SECRET_ACCESS_KEY)"
aws_region = "$(AWS_REGION)"
hugo_base_url = "$(HUGO_BASE_URL)"
endef
