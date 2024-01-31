TESTRUN_DATA ?= .raw

ALL_MAKEFILES := data.mk
RM := rm

# Don't remove intermediate files.
.SECONDARY:

.PHONY: all
all: plots

RAW_DIRS := $(filter %/, $(wildcard $(TESTRUN_DATA)/*/))
DATA_REAL := $(RAW_DIRS:$(TESTRUN_DATA)/%/=%)
# Real data names separated by +.
DATA_VIRT := 24-01-25_17-11_loxilb-wrk_r20-b20+24-01-29_14-50_loxilb-wrk_r20-b20-load-0.95-0.975
DATA := $(DATA_REAL) $(DATA_VIRT)
PLOTS := $(DATA:%=d-%)

.PHONY: plots
plots: $(PLOTS)

.PHONY: d-%
d-%: .tidy/%.tsv.gz
	$(MAKE) -f data.mk D=$*

# Hack: Use flock to limit concurrency.
.tidy/%.tsv.gz: $(TESTRUN_DATA)/%/suite-run.log | .tidy
	nice flock .tidy/all_cores.lock ./tidy.py --data $* 2>&1 | tee $@.log

define cat_tsv_targets # args: D

$(D)_parts = $$(subst +, ,$(D))
$(D)_tsvs = $$(patsubst %,.tidy/%.tsv.gz,$$($(D)_parts))

.tidy/$(D).tsv.gz: $$($(D)_tsvs) cat-tsv.py $(ALL_MAKEFILES) | .tidy
	nice ./cat-tsv.py --input $$($(D)_tsvs) --output $$@ 2>&1 | tee $$@.log

endef # cat_tsv_targets

$(foreach D,$(DATA_VIRT),$(eval $(cat_tsv_targets)))

.PHONY: clean
clean:
	$(RM) -rfd .tidy plots

.PHONY: install-deps
install-deps:
	sudo apt install r-base cups libcurl4-openssl-dev python3-seaborn python3-joblib python3-yaml libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev
	Rscript -e 'install.packages(c("tidyverse", "argparse", "scriptName", "tikzDevice", "gghighlight", "ggpubr", "broom", "plyr", "plotly"))' \
		|| echo "run 'R' interactively and call install.packages() manually to choose lib install path" && false

plots .tidy:
	mkdir -p $@
