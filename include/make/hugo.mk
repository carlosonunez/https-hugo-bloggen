#!/usr/bin/env make
.PHONY: \
	run_hugo_%_tests \
	version_hugo_index_and_error_files \
	remove_generated_static_content
	
run_hugo_%_tests:
	tests_to_run=$$(echo "$@" | sed 's/run_hugo_\([a-zA-Z]\+\)_tests/\1/'); \
	if [ "$$tests_to_run" == "production" ]; \
	then \
		export CDN_URL=$$($(DOCKER_COMPOSE_COMMAND) run --rm terraform output cdn_url | tr -d $$'\r'); \
	fi; \
	tests_to_run_upcase=$$(echo "$$tests_to_run" | tr a-z A-Z); \
	$(DOCKER_COMPOSE_COMMAND) run --rm "hugo-$$tests_to_run-tests" > $(TEST_RESULTS_FILE); \
	echo "$$?" >> $(TEST_RESULTS_FILE)

version_hugo_index_and_error_files:
	terraform_output=$$($(DOCKER_COMPOSE_COMMAND) run --rm terraform output | tr -d $$'\r'); \
	export S3_BUCKET=$$(echo "$$terraform_output" | grep -r blog_bucket_name | sed 's/.*blog_bucket_name = //'); \
	export INDEX_HTML_FILE=$$(echo "$$terraform_output" | grep -r index_html_name| sed 's/.*index_html_name = //'); \
	export ERROR_HTML_FILE=$$(echo "$$terraform_output" | grep -r error_html_name| sed 's/.*error_html_name = //'); \
	$(DOCKER_COMPOSE_COMMAND) run --rm generate-hugo-configs && \
	$(DOCKER_COMPOSE_COMMAND) run --rm fetch-hugo-theme && \
	$(DOCKER_COMPOSE_COMMAND) run --rm hugo-generate-static-files && \
	if [ ! -f site/public/index.html ] || [ ! -f site/public/404.html ]; \
	then \
		>&2 echo "ERROR: Site was not properly generated."; \
		exit 1; \
	fi; \
	mv site/public/index.html "site/public/$$INDEX_HTML_FILE" && \
	mv site/public/404.html "site/public/$$ERROR_HTML_FILE"

remove_generated_static_content:
	rm -rf site/

