MAKEFLAGS += --silent
SHELL := /usr/bin/env bash

.PHONY: all
all: lint unit integration deploy

.PHONY: test
test: lint unit integration

.PHONY: lint unit integration deploy

lint:
	# In progress!

unit:
	# In progress!

integration:
	# In progress!

deploy:
	# In progress!
