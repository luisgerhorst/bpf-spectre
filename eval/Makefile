BENCHRUN_DATA ?= ../bench/data

ALL_MAKEFILES = Makefile data.mk
RM=rm

# Don't remove intermediate files.
.SECONDARY:

.PHONY: all
all: plots

RAW_DIRS=$(filter %/, $(wildcard $(BENCHRUN_DATA)/*/))
PLOTS=$(RAW_DIRS:$(BENCHRUN_DATA)/%/=plots-%)

.PHONY: plots
plots: $(PLOTS)

.PHONY: plots-%
plots-%:
	$(MAKE) -f data.mk D=$*

.PHONY: clean
clean:
	$(RM) -rfd .tidy plots

.PHONY: install-deps
install-deps:
	pip3 install pyyaml seaborn
	Rscript -e 'install.packages(c("tidyverse", "argparse", "scriptName", "tikzDevice", "gghighlight", "ggpubr", "broom", "plyr"))'

.PHONY: sudo-install-deps
sudo-install-deps:
	sudo apt install r-base cups
