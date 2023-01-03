suite_pys := $(wildcard *.suite.py)
suite_py_yamls := $(patsubst %.suite.py,.%.yaml,$(suite_pys))

suite_defs := $(wildcard *.suite.yaml)
suite_def_yamls := $(patsubst %.suite.yaml,.%.yaml,$(suite_defs))

.PHONY: all
all: $(suite_def_yamls) $(suite_py_yamls)

.%.yaml: %.suite.py
	./$< > $@

.%.yaml: %.suite.yaml
	ln -s $< $@

.PHONY: install-deps
install-deps:
	pip install pyyaml etaprogress
