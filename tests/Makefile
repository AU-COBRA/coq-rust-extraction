all: tests process-extraction-examples
.PHONY: all

CoqMakefile: _CoqProject
	coq_makefile -f _CoqProject -o CoqMakefile

tests: CoqMakefile
	+@make -f CoqMakefile
.PHONY: plugin

clean: CoqMakefile
	+@make -f CoqMakefile clean
	rm -f CoqMakefile
.PHONY: clean

install: CoqMakefile
	+@make -f CoqMakefile install
.PHONY: install

uninstall: CoqMakefile
	+@make -f CoqMakefile uninstall
.PHONY: uninstall

# Forward most things to Coq makefile. Use 'force' to make this phony.
%: CoqMakefile force
	+@make -f CoqMakefile $@
force: ;

# Do not forward these files
Makefile _CoqProject: ;

process-extraction-examples: tests
	./process-extraction-examples.sh
.PHONY: process-extraction-examples

RUST_DIR=./extracted-code/

test-extraction: clean-compiled
	$(foreach dir, $(wildcard $(RUST_DIR)/*-extracted), cd $(dir) && cargo run && cd ../../;)

clean-compiled:
	$(foreach dir, $(wildcard $(RUST_DIR)/*-extracted), rm -f -r $(dir)/target;)
.PHONY: clean-compiled

clean-extraction-out-files:
	rm -f $(RUST_DIR)/*.rs.out

clean-extraction-sources:
	find $(RUST_DIR) -name 'main.rs' -delete
.PHONY:clean-extraction-sources

clean-extraction-examples: clean-compiled clean-extraction-out-files clean-extraction-sources
	rm ./thories/*.vo # to force recompilation of examples (a bit ad-hoc though)
.PHONY: clean-compiled clean-extraction-out-files clean-extraction-sources
