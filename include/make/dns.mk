#!/usr/bin/env make
DNS_RETRY_LIMIT_SECONDS ?= 60

.PHONY: wait_for_dns_to_catch_up wait_for_cloudfront_to_become_ready
wait_for_dns_to_catch_up:
	blog_url=$$($(DOCKER_COMPOSE_RUN_COMMAND) terraform output blog_url | tr -d '\r'); \
	for i in $$(seq 1 $(DNS_RETRY_LIMIT_SECONDS)); \
	do \
		if host $$blog_url &>/dev/null; \
		then \
			exit 0; \
		fi; \
		>&2 echo "WARNING: $$blog_url is not up yet. (Attempt $$i/$(DNS_RETRY_LIMIT_SECONDS))"; \
	done; \
	>&2 echo "ERROR: $$blog_url never came up."; \
	exit 1;

wait_for_cdn_to_become_ready:
	blog_url=$(DOCKER_COMPOSE_RUN_COMMAND) terraform output cdn_url | tr -d '\r'); \
	for i in $$(seq 1 $(DNS_RETRY_LIMIT_SECONDS)); \
	do \
		if nc -z $$blog_url 443 &>/dev/null; \
		then \
			exit 0; \
		fi; \
		>&2 echo "WARNING: $$blog_url is not up yet. (Attempt $$i/$(DNS_RETRY_LIMIT_SECONDS))"; \
	done; \
	>&2 echo "ERROR: $$blog_url never came up."; \
	exit 1;

