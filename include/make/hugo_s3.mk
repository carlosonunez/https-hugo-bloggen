#!/usr/bin/env make
BLOG_BUCKET_NAME_TERRAFORM_OUTPUT_VAR=blog_bucket_name

.PHONY: deploy_blog_to_s3 remove_hugo_blog_from_s3 

deploy_hugo_blog_to_s3: _do_hugo_s3_action_deploy

remove_hugo_blog_from_s3: _do_hugo_s3_action_remove

.PHONY: _get_blog_s3_bucket_from_terraform _do_hugo_s3_action_%

_get_blog_s3_bucket_from_terraform:
	>&2 echo "INFO: Logging into AWS; hang on."
	aws_session=$$($(DOCKER_COMPOSE_RUN_COMMAND) -T obtain-aws-session-credentials); \
	if test -z "$$aws_session"; \
	then >&2 echo "ERROR: Unable to receive creds from AWS with AK/SK provided." && exit 1; \
	fi; \
	export AWS_ACCESS_KEY_ID=$$( echo "$$aws_session" | jq -r '.Credentials.AccessKeyId' ); \
	export AWS_SECRET_ACCESS_KEY=$$( echo "$$aws_session" | jq -r '.Credentials.SecretAccessKey'); \
	export AWS_SESSION_TOKEN=$$( echo "$$aws_session" | jq -r '.Credentials.SessionToken' ); \
	$(DOCKER_COMPOSE_RUN_COMMAND) terraform output $(BLOG_BUCKET_NAME_TERRAFORM_OUTPUT_VAR) | \
		tr -d $$'\r'

_do_hugo_s3_action_%:
	>&2 echo "INFO: Logging into AWS; hang on."
	aws_session=$$($(DOCKER_COMPOSE_RUN_COMMAND) -T obtain-aws-session-credentials); \
	if test -z "$$aws_session"; \
	then >&2 echo "ERROR: Unable to receive creds from AWS with AK/SK provided." && exit 1; \
	fi; \
	export AWS_ACCESS_KEY_ID=$$( echo "$$aws_session" | jq -r '.Credentials.AccessKeyId' ); \
	export AWS_SECRET_ACCESS_KEY=$$( echo "$$aws_session" | jq -r '.Credentials.SecretAccessKey'); \
	export AWS_SESSION_TOKEN=$$( echo "$$aws_session" | jq -r '.Credentials.SessionToken' ); \
	if ! s3_bucket=$$($(MAKE) _get_blog_s3_bucket_from_terraform); \
	then \
		>&2 echo "ERROR: The S3 bucket for your blog was not found. Either there is \
no infrastructure in this environment, or you did not define the \
'$(BLOG_BUCKET_NAME_TERRAFORM_OUTPUT_VAR)' Terraform output in your \
Terraform configuration."; \
		exit 1; \
	fi; \
	action=$$(echo "$@" | sed 's/_do_hugo_s3_action_//' | tr '_' '-'); \
	case "$$action" in \
	deploy) \
		S3_BUCKET="$$s3_bucket" $(DOCKER_COMPOSE_RUN_COMMAND) deploy-hugo-blog-to-s3 >/dev/null; \
		;; \
	remove) \
		S3_BUCKET="$$s3_bucket" $(DOCKER_COMPOSE_RUN_COMMAND) remove-hugo-blog-from-s3 >/dev/null; \
		;; \
	*) \
		>&2 echo "ERROR: Invalid Hugo S3 action: $$action"; \
		exit 1; \
		;; \
	esac;

