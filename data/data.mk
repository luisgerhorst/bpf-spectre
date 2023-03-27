D ?= scratch
TESTRUN_DATA ?= .raw

ALL_MAKEFILES=data.mk
RM=rm

# Don't remove intermediate files.
.SECONDARY:

.PHONY: all
all: plots/$(D).pdf

.tidy/%.tsv.gz: tidy.py $(TESTRUN_DATA)/%/suite-run.log $(ALL_MAKEFILES) | .tidy
	nice ./tidy.py --data $* 2>&1 | tee $@.log

d_parts=$(subst +, ,$(D))
d_tsvs=$(d_parts:%=.tidy/%.tsv.gz)

ifneq ($(D),$(d_parts))
.tidy/$(D).tsv.gz: $(d_tsvs) cat-tsv.py $(ALL_MAKEFILES) | .tidy
	nice ./cat-tsv.py --input $(d_tsvs) --output $@ 2>&1 | tee $@.log
endif

plots/$(D)/%/.plot.log: .tidy/$(D).tsv.gz plot-% plotlib.R $(ALL_MAKEFILES) | plots
	$(RM) -rfd $(dir $@) && mkdir -p $(dir $@)
	echo "PLOT $* LOG START" > $@
	nice ./plot-$* --data $(D) --plot-path $(dir $@) 2>&1 | tee -a $@
	echo "PLOT $* LOG END" >> $@

plots/$(D)/%/0000.log.pdf: plots/$(D)/%/.plot.log $(ALL_MAKEFILES) | plots
	PATH="/usr/sbin:$$PATH" cupsfilter $< > $@ 2> /dev/null

plots/$(D)/%.pdf: plots/$(D)/%/0000.log.pdf $(ALL_MAKEFILES) | plots
	ulimit -n 8192 && pdfunite plots/$(D)/$*/*.pdf $@

plot_scripts := $(wildcard plot-*)
plot_script_names := $(patsubst plot-%,%,$(plot_scripts))
plot_script_pdfs := $(patsubst %,plots/$(D)/%.pdf,$(plot_script_names))

plots/$(D).pdf: $(plot_script_pdfs) $(ALL_MAKEFILES) | plots
	pdfunite $(plot_script_pdfs) $@

plots .tidy:
	mkdir -p $@
