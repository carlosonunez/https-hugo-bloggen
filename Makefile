MAKEFLAGS += "--silent"
SHELL := /usr/bin/env bash
include include/make/*.mk

.PHONY: all
all: lint unit integration deploy

.PHONY: test
test: lint unit integration

.PHONY: lint unit integration deploy

lint:
	# In progress!

unit: run_bats_unit_tests
integration: run_bats_integration_tests

deploy:
	# In progress!
