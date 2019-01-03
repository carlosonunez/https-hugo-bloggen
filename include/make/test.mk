#!/usr/bin/env make
export TEST_RESULTS_FILE ?= $(shell mktemp /tmp/test-results-XXXXXXXXX)
export TEST_TIMER_FILE ?= $(shell mktemp /tmp/test-timer-XXXXXXXXX)

.PHONY: start_%_tests end_%_tests

start_%_tests:
	test_type=$$(echo "$@" | sed 's/start_\(.*\)_tests/\U\1/'); \
	date +%s > $(TEST_TIMER_FILE); \
	>&2 printf "%-30s%s%30s\n" "$(DECORATOR)" "RUNNING $$test_type TESTS" "$(DECORATOR)"; \

end_%_tests:
	test_end_time=$$(date +%s); \
	test_type=$$(echo "$@" | sed 's/end_\(.*\)_tests/\U\1/'); \
	test_start_time=$$(cat $(TEST_TIMER_FILE)); \
	rm -f $(TEST_TIMER_FILE); \
	test_duration=$$(( $$test_end_time - $$test_start_time )); \
	test_output=$$(sed '$$d' $(TEST_RESULTS_FILE)); \
	test_result=$$(sed '$$!d' $(TEST_RESULTS_FILE)); \
	rm -f $(TEST_RESULTS_FILE); \
	rm -f $(TEST_TIMER_FILE); \
	echo "$$test_output"; \
	>&2 printf "%-20s%s%20s\n" "$(DECORATOR)" "$$test_type TESTS FINISHED IN APPROX. $$test_duration SECONDS" "$(DECORATOR)"; \
	exit "$$test_result"

