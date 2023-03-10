# System under Test
T ?= qemu-debian
include targets/$(T).mk

# Where to persistenly store data on the target.
PROJ_NAME=oseval
TARGET_PREFIX ?= /srv/scratch/$(USER)/.$(PROJ_NAME)/$(shell hostname -s)
