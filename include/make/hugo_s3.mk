#!/usr/bin/env make
BLOG_BUCKET_NAME_TERRAFORM_OUTPUT_VAR=blog_bucket_name

.PHONY: deploy_blog_to_s3 remove_hugo_blog_from_s3 

deploy_hugo_blog_to_s3: _do_hugo_s3_action_deploy

remove_hugo_blog_from_s3: _do_hugo_s3_action_remove

.PHONY: _get_blog_s3_bucket_from_terraform _do_hugo_s3_action_%

_get_blog_s3_bucket_from_terraform:
	@$(DOCKER_COMPOSE_COMMAND) run --rm terraform output $(BLOG_BUCKET_NAME_TERRAFORM_OUTPUT_VAR) | \
		tr -d $$'\r'

_do_hugo_s3_action_%:
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
		S3_BUCKET="$$s3_bucket" $(DOCKER_COMPOSE_COMMAND) run --rm deploy-hugo-blog-to-s3 >/dev/null; \
		;; \
	remove) \
		S3_BUCKET="$$s3_bucket" $(DOCKER_COMPOSE_COMMAND) run --rm remove-hugo-blog-from-s3 >/dev/null; \
		;; \
	*) \
		>&2 echo "ERROR: Invalid Hugo S3 action: $$action"; \
		exit 1; \
		;; \
	esac;

