# We need the .ONESHELL and .SHELLFLAGS variable, which requires Make 3.82 or
# later, so check for the undefine feature (also 3.82+) and exit if not found.
ifeq ($(filter undefine,$(value .FEATURES)),)
				$(error Unsupported version: $(MAKE_VERSION). Please use 3.82 or greater.)
endif

# Configure make and the shell environment
.DEFAULT_GOAL := help
SHELL := bash

# Simple ANSI colours
AC_RED := \033[0;31m
AC_GREEN := \033[0;32m
AC_YELLOW := \033[0;33m
AC_WHITE := \033[1;37m
AC_END := \033[0m

# This target processes this Makefile to automatically create a help message
# while allowing for the expansion of statically-set variable-based targets
.PHONY: help list
list: help
help: 
	@echo 'make [test] [clean] [build]'

.PHONY: build test clean
build:
	bash build-scripts/make_prod.sh
test:
	bash scripts/install.test.sh
	/usr/bin/lua test/localtest.lua
clean:
	bash build-scripts/make_clean.sh

# vim: ts=2:noet:
