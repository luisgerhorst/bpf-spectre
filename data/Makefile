TESTRUN_DATA ?= .raw

ALL_MAKEFILES = Makefile data.mk
RM=rm

# Don't remove intermediate files.
.SECONDARY:

.PHONY: all
all: plots

RAW_DIRS=$(filter %/, $(wildcard $(TESTRUN_DATA)/*/))
DATA_EXTRA=23-03-21_bsel-refactor+scratch 23-03-24_20-00_bpftool+scratch
DATA=$(RAW_DIRS:$(TESTRUN_DATA)/%/=%) $(DATA_EXTRA)
PLOTS=$(DATA:%=plots-%)

.PHONY: plots
plots: $(PLOTS)

# Hack: Use flock to limit concurrency.
.tidy/%.tsv.gz: tidy.py $(TESTRUN_DATA)/%/suite-run.log $(ALL_MAKEFILES) | .tidy
	nice flock .tidy/$<.lock ./tidy.py --data $* 2>&1 | tee $@.log

define gen_cat_tsv_rule
# Input: D

d_parts=$(subst +, ,$(D))
d_tsvs=$(d_parts:%=.tidy/%.tsv.gz)

ifneq ($(D),$(d_parts))
.tidy/$(D).tsv.gz: $(d_tsvs) cat-tsv.py $(ALL_MAKEFILES) | .tidy
	nice ./cat-tsv.py --input $(d_tsvs) --output $@ 2>&1 | tee $@.log
endif

endef # gen_cat_tsv_rule

$(foreach D,$(DATA),$(gen_cat_tsv_rule))

.PHONY: plots-%
plots-%: .tidy/%.tsv.gz
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
