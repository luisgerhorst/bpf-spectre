# System under Test
T ?= qemu-debian
include targets/$(T).mk

TARGET_PREFIX ?= /srv/scratch/$(USER)/.oseval/$(shell hostname)
