TESTRUN_DATA ?= ../.raw

RAW_DIRS=$(filter %/, $(wildcard $(TESTRUN_DATA)/*/))
RAW_NAMES=$(RAW_DIRS:$(TESTRUN_DATA)/%/=%)
TARGZ_FILES=$(addsuffix .tar.gz,$(RAW_NAMES))

ifeq (,$(shell which pigz))
	GZIP=gzip
else
	GZIP=pigz
endif

.PHONY: all
all: $(TARGZ_FILES)

# https://github.com/L1L1/cardpeek/pull/97
TARFLAGS_REPRO=--sort=name --mtime @1 --clamp-mtime --format=gnu --owner=0 --group=0

%.tar.gz: $(TESTRUN_DATA)/%/suite-run.log
	tar -c $(TARFLAGS_REPRO) --directory $(dir $<) . \
		| $(GZIP) --to-stdout --best --no-name > $@

$(TESTRUN_DATA)/%: %.tar.gz
	mkdir -p $@
	tar xf $< --directory=$@

.PHONY: install-deps
install-deps:
	sudo apt install pigz
