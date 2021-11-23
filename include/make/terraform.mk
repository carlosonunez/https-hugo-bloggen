#!/usr/bin/env make
AWS_SESSION_NAME ?= bloggen-$(COMMIT_SHA)-$(shell date +%s)

.PHONY: terraform_% generate_terraform_vars
terraform_%:
	>&2 echo "INFO: Logging into AWS; hang on."
	aws_session=$$($(DOCKER_COMPOSE_RUN_COMMAND) -T obtain-aws-session-credentials); \
	if test -z "$$aws_session"; \
	then >&2 echo "ERROR: Unable to receive creds from AWS with AK/SK provided." && exit 1; \
	fi; \
	export AWS_ACCESS_KEY_ID=$$( echo "$$aws_session" | jq -r '.Credentials.AccessKeyId' ); \
	export AWS_SECRET_ACCESS_KEY=$$( echo "$$aws_session" | jq -r '.Credentials.SecretAccessKey'); \
	export AWS_SESSION_TOKEN=$$( echo "$$aws_session" | jq -r '.Credentials.SessionToken' ); \
	action=$$(echo "$@" | sed 's/terraform_//'); \
	$(DOCKER_COMPOSE_RUN_COMMAND) terraform $$action

generate_terraform_vars_for_unit_tests:
	>&2 echo "INFO: Logging into AWS; hang on."
	aws_session=$$($(DOCKER_COMPOSE_RUN_COMMAND) -T obtain-aws-session-credentials); \
	if test -z "$$aws_session"; \
	then >&2 echo "ERROR: Unable to receive creds from AWS with AK/SK provided." && exit 1; \
	fi; \
	export AWS_ACCESS_KEY_ID=$$( echo "$$aws_session" | jq -r '.Credentials.AccessKeyId' ); \
	export AWS_SECRET_ACCESS_KEY=$$( echo "$$aws_session" | jq -r '.Credentials.SecretAccessKey'); \
	export AWS_SESSION_TOKEN=$$( echo "$$aws_session" | jq -r '.Credentials.SessionToken' ); \
	$(DOCKER_COMPOSE_RUN_COMMAND) generate-terraform-unit-test-tfvars && \
	$(DOCKER_COMPOSE_RUN_COMMAND) generate-terraform-unit-test-backend

generate_terraform_vars:
	>&2 echo "INFO: Logging into AWS; hang on."
	aws_session=$$($(DOCKER_COMPOSE_RUN_COMMAND) -T obtain-aws-session-credentials); \
	if test -z "$$aws_session"; \
	then >&2 echo "ERROR: Unable to receive creds from AWS with AK/SK provided." && exit 1; \
	fi; \
	export AWS_ACCESS_KEY_ID=$$( echo "$$aws_session" | jq -r '.Credentials.AccessKeyId' ); \
	export AWS_SECRET_ACCESS_KEY=$$( echo "$$aws_session" | jq -r '.Credentials.SecretAccessKey'); \
	export AWS_SESSION_TOKEN=$$( echo "$$aws_session" | jq -r '.Credentials.SessionToken' ); \
	$(DOCKER_COMPOSE_RUN_COMMAND) generate-terraform-tfvars && \
	$(DOCKER_COMPOSE_RUN_COMMAND) generate-terraform-backend && \
	$(DOCKER_COMPOSE_RUN_COMMAND) generate-terraform-backend-vars

.PHONY: \
	initialize_terraform \
	set_up_infrastructure \
	tear_down_infrastructure

initialize_terraform: generate_terraform_vars terraform_init

set_up_infrastructure: initialize_terraform terraform_apply

tear_down_infrastructure: initialize_terraform terraform_destroy

