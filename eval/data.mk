D ?= scratch
BENCHRUN_DATA = ../bench/.data

ALL_MAKEFILES=Makefile data.mk
RM=rm

# Don't remove intermediate files.
.SECONDARY:

.PHONY: all
all: plots/$(D).pdf

.tidy/$(D).tsv.gz: tidy.py $(BENCHRUN_DATA)/$(D) $(ALL_MAKEFILES)
	./tidy.py --data $(D) 2>&1 | tee $@.log

plots/$(D)/%/.plot.log: .tidy/$(D).tsv.gz plot-% plotlib.R $(ALL_MAKEFILES)
	$(RM) -rfd $(dir $@) && mkdir -p $(dir $@)
	./plot-$* --data $(D) --plot-path $(dir $@) 2>&1 | tee $@

plots/$(D)/%/0000.log.pdf: plots/$(D)/%/.plot.log $(ALL_MAKEFILES)
	PATH="/usr/sbin:$$PATH" cupsfilter $< > $@ 2> /dev/null

plots/$(D)/%.pdf: plots/$(D)/%/0000.log.pdf $(ALL_MAKEFILES)
	ulimit -n 8192 && pdfunite plots/$(D)/$*/*.pdf $@

plot_scripts := $(wildcard plot-*)
plot_script_names := $(patsubst plot-%,%,$(plot_scripts))
plot_script_pdfs := $(patsubst %,plots/$(D)/%.pdf,$(plot_script_names))

plots/$(D).pdf: $(plot_script_pdfs) $(ALL_MAKEFILES)
	pdfunite $(plot_script_pdfs) $@
