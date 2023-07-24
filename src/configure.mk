include env.mk

# Files to be merged into $(CONFIG) to create final $(LINUX)/.config
MERGE_CONFIGS ?=
LINUX ?= linux

$(LINUX)/.config: .build/env/CONFIG $(CONFIG) .build/env/MERGE_CONFIGS $(MERGE_CONFIGS) .build/env/LINUX_GIT_CHECKOUT .build/$(LINUX).git_rev .build/$(LINUX).git_status
	KCONFIG_CONFIG=$(LINUX)/.config ./$(LINUX)/scripts/kconfig/merge_config.sh -m $(CONFIG) $(MERGE_CONFIGS)
	$(MAKE) -C $(LINUX) olddefconfig prepare savedefconfig
