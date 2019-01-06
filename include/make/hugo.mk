#!/usr/bin/env make
.PHONY: \
	run_hugo_%_tests \
	run_hugo_%_tests_with_timeout \
	version_hugo_index_and_error_files \
	remove_generated_static_content
	
run_hugo_%_tests:
	tests_to_run=$$(echo "$@" | sed 's/run_hugo_\([a-zA-Z]\+\)_tests/\1/'); \
	if [ "$$tests_to_run" == "production" ]; \
	then \
		export CDN_URL=$$($(DOCKER_COMPOSE_RUN_COMMAND) terraform output cdn_url | tr -d $$'\r'); \
	fi; \
	tests_to_run_upcase=$$(echo "$$tests_to_run" | tr a-z A-Z); \
	$(DOCKER_COMPOSE_RUN_COMMAND) "hugo-$$tests_to_run-tests" | tee $(TEST_RESULTS_FILE); \
	test_result=$$?; \
	echo "$$test_result" > $(TEST_RESULTS_FILE); \
	exit "$$test_result";

run_hugo_%_tests_with_timeout:
	tests_to_run=$$(echo "$@" | sed 's/run_hugo_\([a-zA-Z]\+\)_tests.*/\1/'); \
	for attempt in $$(seq 1 $(TEST_TIMEOUT_IN_SECONDS)); \
	do \
		>&2 echo "INFO: Attempt $$attempt out of $(TEST_TIMEOUT_IN_SECONDS)"; \
		$(MAKE) run_hugo_$${tests_to_run}_tests && exit 0; \
		sleep 1;  \
	done; \
	>&2 echo "ERROR: Production site never came up."; \
	exit 1;

version_hugo_index_and_error_files:
	export S3_BUCKET=$$($(DOCKER_COMPOSE_RUN_COMMAND) terraform output blog_bucket_name | tr -d $$'\r' | sed 's/index_html_file = //'); \
	export INDEX_HTML_FILE=$$($(DOCKER_COMPOSE_RUN_COMMAND) terraform output index_html_name | tr -d $$'\r' | sed 's/index_html_file = //'); \
	export ERROR_HTML_FILE=$$($(DOCKER_COMPOSE_RUN_COMMAND) terraform output error_html_name | tr -d $$'\r' | sed 's/error_html_file = //'); \
	>&2 echo "Bucket: $$S3_BUCKET , Index: $$INDEX_HTML_FILE"; \
	$(DOCKER_COMPOSE_RUN_COMMAND) generate-hugo-configs && \
	$(DOCKER_COMPOSE_RUN_COMMAND) fetch-hugo-theme && \
	$(DOCKER_COMPOSE_RUN_COMMAND) hugo-generate-static-files && \
	if [ ! -f site/public/index.html ] || [ ! -f site/public/404.html ]; \
	then \
		>&2 echo "ERROR: Site was not properly generated."; \
		exit 1; \
	fi; \
	mv site/public/index.html "site/public/$$INDEX_HTML_FILE" && \
	mv site/public/404.html "site/public/$$ERROR_HTML_FILE"

remove_generated_static_content:
	ls -la . ; \
	ls -la site; \
	rm -rf site/

