#!/usr/bin/env make
.PHONY: \
	deploy_blog_to_s3 \
	remove_hugo_blog_from_s3 

deploy_blog_to_s3:
	export S3_BUCKET=$$($(DOCKER_COMPOSE_COMMAND) run --rm terraform output blog_bucket_name | tr -d '\r'); \
	S3_BUCKET="$${S3_BUCKET?Please provide a S3 bucket.}" \
		$(DOCKER_COMPOSE_COMMAND) run --rm deploy-hugo-to-s3

remove_hugo_blog_from_s3:
	export S3_BUCKET=$$($(DOCKER_COMPOSE_COMMAND) run --rm terraform output blog_bucket_name | tr -d '\r'); \
	S3_BUCKET="$${S3_BUCKET?Please provide a S3 bucket.}" \
		$(DOCKER_COMPOSE_COMMAND) run --rm remove-hugo-from-s3

