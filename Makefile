all: theory plugin tests
.PHONY: all

CoqMakefile: _CoqProject
	coq_makefile -f _CoqProject -o CoqMakefile

theory: CoqMakefile
	+@make -f CoqMakefile
.PHONY: theory

plugin: theory
	+make -C plugin
.PHONY: plugin

tests: theory plugin
	+make -C tests
.PHONY: plugin

clean: CoqMakefile
	+@make -f CoqMakefile clean
	rm -f CoqMakefile
	+@make -C plugin clean
	+@make -C tests clean
.PHONY: clean

install: CoqMakefile
	+@make -f CoqMakefile install
	+@make -C plugin install
.PHONY: install

uninstall: CoqMakefile
	+@make -f CoqMakefile uninstall
	+@make -C plugin uninstall
.PHONY: uninstall

# Forward most things to Coq makefile. Use 'force' to make this phony.
%: CoqMakefile force
	+@make -f CoqMakefile $@
force: ;
all: theory

# Do not forward these files
Makefile _CoqProject: ;
