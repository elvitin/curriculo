LATEX_IMAGE ?= latex
DOCKER ?= docker
PDFLATEX ?= pdflatex
TEX_FILE ?= curriculo_padrao.tex
PDF_FILE ?= $(TEX_FILE:.tex=.pdf)
LATEX_BASENAME := $(basename $(TEX_FILE))

.PHONY: all help image pdf clean

all: pdf

help:
	@printf "Targets disponíveis:\n"
	@printf "  make        Gera $(PDF_FILE) via Docker\n"
	@printf "  make pdf    Gera $(PDF_FILE) via Docker\n"
	@printf "  make image  Cria a imagem Docker $(LATEX_IMAGE)\n"
	@printf "  make clean  Remove artefatos gerados pelo LaTeX\n"

image:
	$(DOCKER) build -t $(LATEX_IMAGE) .

pdf: image
	$(DOCKER) run --rm -i -v "$$(pwd)":/data $(LATEX_IMAGE) $(PDFLATEX) -interaction=nonstopmode -halt-on-error $(TEX_FILE)
	$(DOCKER) run --rm -i -v "$$(pwd)":/data $(LATEX_IMAGE) $(PDFLATEX) -interaction=nonstopmode -halt-on-error $(TEX_FILE)

clean:
	rm -f $(PDF_FILE) \
		$(LATEX_BASENAME).aux \
		$(LATEX_BASENAME).log \
		$(LATEX_BASENAME).out \
		$(LATEX_BASENAME).fdb_latexmk \
		$(LATEX_BASENAME).fls \
		$(LATEX_BASENAME).synctex.gz