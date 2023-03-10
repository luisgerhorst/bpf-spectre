suite_pys := $(wildcard *.suite.py)
suite_py_yamls := $(patsubst %.suite.py,.build/%.yaml,$(suite_pys))

suite_defs := $(wildcard *.suite.yaml)
suite_def_yamls := $(patsubst %.suite.yaml,.build/%.yaml,$(suite_defs))

.PHONY: all
all: $(suite_def_yamls) $(suite_py_yamls)

.build:
	mkdir -p $@

.build/%.yaml: .FORCE | .build
	./$*.suite.py > $@ || rm -f $@

PHONY: .FORCE
.FORCE:

# .PHONY: .build/%.yaml
# .build/%.yaml: %.suite.yaml | .build
# 	ln -s $< $@

.PHONY: install-deps
install-deps:
	pip install pyyaml etaprogress
	sudo apt-get install trash-cli
