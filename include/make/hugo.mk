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
  cp site/public/index.html "site/public/$$INDEX_HTML_FILE" && \
	cp site/public/404.html "site/public/$$ERROR_HTML_FILE"

ifdef TRAVIS
remove_generated_static_content:
	docker run -v "$$PWD:/work" -w /work --entrypoint sh alpine -c "rm -rf site"
else
remove_generated_static_content:
	rm -rf site/
endif

.PHONY: create_site_folder_so_travis_works

# For some reason, the 'hugo' Docker service gets a permission denied error when
# trying to create the 'site' folder at the root of this repository, even after
# running the Docker Compose service as the 'travis' user (using the
# '--user "$(id -u)"' option). This works fine on my Mac, even without setting
# the --user option explictliy, and, unfortunately, the Docker service
# does not work on OS X (likely due to issues with nesting VMs).
#
# This seems to be unique to Hugo, as the Docker Compose services that retrieve
# my environment dotfile Compose services are able to download and write the
# .env to this directory.
#
# There are two ways I can fix this: explicitly setting the user in the
# 'hugo' Dockerfile using a build argument, or manually creating and permissioning
# the directory in advance. The former option requires shoehorning even more
# stuff into our auto-generated Compose command, so I like the latter approach
# instead.
ifdef TRAVIS
create_site_folder_so_travis_works:
	mkdir site && chown -R "$$USER" site
else
create_site_folder_so_travis_works:
	>&2 echo "WARNING: Not running in Travis; skipping."
endif
