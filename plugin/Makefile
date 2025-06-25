all: plugin
.PHONY: all

RocqMakefile: _CoqProject
	rocq makefile -f _CoqProject -o RocqMakefile

plugin: RocqMakefile
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
