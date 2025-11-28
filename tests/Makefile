all: tests process-extraction-examples
.PHONY: all

RocqMakefile: _CoqProject
	rocq makefile -f _CoqProject -o RocqMakefile

tests: RocqMakefile
	+@make -f RocqMakefile
.PHONY: plugin

clean: RocqMakefile
	+@make -f RocqMakefile clean
	rm -f RocqMakefile
.PHONY: clean

install: RocqMakefile
	+@make -f RocqMakefile install
.PHONY: install

uninstall: RocqMakefile
	+@make -f RocqMakefile uninstall
.PHONY: uninstall

# Forward most things to Rocq makefile. Use 'force' to make this phony.
%: RocqMakefile force
	+@make -f RocqMakefile $@
force: ;

# Do not forward these files
Makefile _CoqProject: ;

process-extraction-examples: tests
	./process-extraction-examples.sh
.PHONY: process-extraction-examples

RUST_DIR=./extracted-code/

test-extraction: clean-compiled-extraction
	$(foreach dir, $(wildcard $(RUST_DIR)/*-extracted), cd $(dir) && cargo run && cd ../../;)

clean-compiled-extraction:
	$(foreach dir, $(wildcard $(RUST_DIR)/*-extracted), rm -f -r $(dir)/target;)
.PHONY: clean-compiled-extraction

clean-extraction-out-files:
	rm -f $(RUST_DIR)/*.rs.out

clean-extraction-sources:
	find $(RUST_DIR) -name 'main.rs' -delete
.PHONY:clean-extraction-sources

clean-extraction-examples: clean-compiled-extraction clean-extraction-out-files clean-extraction-sources
	rm ./thories/*.vo # to force recompilation of examples (a bit ad-hoc though)
.PHONY: clean-compiled-extraction clean-extraction-out-files clean-extraction-sources
