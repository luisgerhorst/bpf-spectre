BENCHRUN_DATA ?= .raw

ALL_MAKEFILES = Makefile data.mk
RM=rm

# Don't remove intermediate files.
.SECONDARY:

.PHONY: all
all: plots

RAW_DIRS=$(filter %/, $(wildcard $(TESTRUN_DATA)/*/))
PLOTS=$(RAW_DIRS:$(TESTRUN_DATA)/%/=plots-%)

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
	sudo apt install r-base cups libcurl4-openssl-dev
	pip3 install pyyaml seaborn joblib
	Rscript -e 'install.packages(c("tidyverse", "argparse", "scriptName", "tikzDevice", "gghighlight", "ggpubr", "broom", "plyr", "plotly"))' \
		|| echo "run 'R' interactively and call install.packages() manually to choose lib install path" && false
