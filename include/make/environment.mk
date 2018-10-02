#!/usr/bin/env make

ifeq ($(ENVIRONMENT),)
$(warning An environment name was not provided; assuming local dev)
endif
ENVIRONMENT ?= local

EXAMPLE_ENVIRONMENT_FILE := $(PWD)/env.example
ENVIRONMENT_FILE := $(PWD)/env.$(ENVIRONMENT)

ifeq ("$(wildcard $(EXAMPLE_ENVIRONMENT_FILE))","")
$(error Missing example environment file: $(EXAMPLE_ENVIRONMENT_FILE))
endif

ifeq (,$(wildcard $(ENVIRONMENT_FILE)))
$(error Missing environment file: $(ENVIRONMENT_FILE))
endif

include $(ENVIRONMENT_FILE)
export $(shell sed 's/=.*//' $(ENVIRONMENT_FILE))

.PHONY: check_environment_variable_%
check_environment_variable_%: \
	ENVIRONMENT_VARIABLE_TO_CHECK = $(shell echo $@ | sed 's/^check_environment_variable_//')
check_environment_variable_%:
	if ! env | sort -u | grep -Eq "^$(ENVIRONMENT_VARIABLE_TO_CHECK)="; \
	then \
		>&2 echo "ERROR: Environment variable not defined: $(ENVIRONMENT_VARIABLE_TO_CHECK)"; \
		exit 1; \
	fi
