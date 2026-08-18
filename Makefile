# ----- setting ------
SAMPLE_TARGET = kksymbols-sample
DOC_TARGET = kksymbols-doc
TEST_TARGETS = $(basename $(wildcard test*.tex))
RC     = .latexmkrc


# ----- main ------
.PHONY: clean distclean pvc zip doc test

# compile
doc:
	latexmk -r $(RC) $(DOC_TARGET).tex
	$(MAKE) clean

# compile
test:
	@set -e; for target in $(TEST_TARGETS); do \
		echo "==> $$target.tex"; \
		latexmk -r $(RC) $$target.tex; \
	done
	$(MAKE) clean

# cleaning except for PDF
clean:
	latexmk -c

# cleaning including PDF
distclean:
	latexmk -C

# compile on save
# pvc:
# 	latexmk -pvc -r $(RC) $(TARGET).tex

# ----- CTAN setting -----
PACKAGE = kksymbols
styFILENAME = KKsymbols
ZIP_DIR = $(PACKAGE)

# ----- zip generation -----
zip: distclean doc
	mkdir -p $(ZIP_DIR)
	cp $(styFILENAME).sty $(ZIP_DIR)
	cp $(styFILENAME).lua $(ZIP_DIR)
	cp README.md $(ZIP_DIR)
	cp LICENSE.md $(ZIP_DIR)
	cp $(PACKAGE)-doc.tex $(ZIP_DIR)
	cp $(PACKAGE)-doc.pdf $(ZIP_DIR)
	zip -r $(PACKAGE).zip $(ZIP_DIR) -x "*/.*" "*~"
	rm -rf $(ZIP_DIR)
