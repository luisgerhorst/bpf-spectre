# System under Test
T ?= faui49easy5
include targets/$(T).mk

# Where to persistenly store data on the target.
PROJ_NAME=oseval
TARGET_PREFIX ?= /srv/scratch/$(USER)/.$(PROJ_NAME)/$(shell hostname -s)
LINUX_GIT_CHECKOUT ?= HEAD-dirty
MERGE_CONFIGS ?=

# Be careful, does not affect the target scripts.
export PATH := /usr/lib/llvm-16/bin:$(PATH)
