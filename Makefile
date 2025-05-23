all: theory plugin tests
.PHONY: all

CoqMakefile: _CoqProject
	coq_makefile -f _CoqProject -o CoqMakefile

theory: CoqMakefile
	+@make -f CoqMakefile
.PHONY: theory

plugin: theory configure-extr
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
	rm -rf docs
	rm -f plugin/theories/ExtrRustUncheckedArith.v
	rm -f plugin/theories/ExtrRustCheckedArith.v
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

html: all
	rm -rf docs
	mkdir docs
	coqdoc --html --interpolate --parse-comments \
		--with-header extra/header.html --with-footer extra/footer.html \
		--toc \
		--external https://metacoq.github.io/html MetaCoq \
		-R theories RustExtraction \
		-R tests/theories RustExtraction.Test \
		-R plugin/theories RustExtraction \
		-d docs `find . -type f \( -wholename "*theories/*" -o -wholename "*test/*" \) -name "*.v" ! -wholename "./_opam/*"`
	cp extra/resources/coqdocjs/*.js docs
	cp extra/resources/coqdocjs/*.css docs
	cp extra/resources/toc/*.js docs
	cp extra/resources/toc/*.css docs
.PHONY: html
