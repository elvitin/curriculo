LATEX_IMAGE ?= latex
DOCKER ?= docker
PDFLATEX ?= pdflatex
DEFAULT_TEX_FILE := curriculo_padrao.tex
POSITIONAL_TEX_FILE := $(filter %.tex,$(MAKECMDGOALS))

ifneq ($(strip $(POSITIONAL_TEX_FILE)),)
ifneq ($(words $(POSITIONAL_TEX_FILE)),1)
$(error Informe apenas um arquivo .tex por execução: $(POSITIONAL_TEX_FILE))
endif
TEX_FILE := $(POSITIONAL_TEX_FILE)
else
TEX_FILE ?= $(DEFAULT_TEX_FILE)
endif

PDF_FILE ?= $(TEX_FILE:.tex=.pdf)
LATEX_BASENAME := $(basename $(TEX_FILE))

.PHONY: all help image pdf clean validate-tex validate-tex-file

all: pdf

help:
	@printf "Targets disponíveis:\n"
	@printf "  make                              Gera $(DEFAULT_TEX_FILE:.tex=.pdf) via Docker\n"
	@printf "  make pdf                          Gera $(DEFAULT_TEX_FILE:.tex=.pdf) via Docker\n"
	@printf "  make pdf arquivo.tex              Gera o PDF do .tex informado via Docker\n"
	@printf "  make pdf TEX_FILE=arquivo.tex     Gera o PDF do .tex informado via variável\n"
	@printf "  make image                        Cria a imagem Docker $(LATEX_IMAGE)\n"
	@printf "  make clean                        Remove artefatos do arquivo padrão\n"
	@printf "  make clean arquivo.tex            Remove artefatos do .tex informado\n"
	@printf "  make clean TEX_FILE=arquivo.tex   Remove artefatos do .tex via variável\n"

validate-tex:
	@if [ -z "$(TEX_FILE)" ]; then \
		printf "Erro: informe um arquivo .tex.\n"; \
		exit 1; \
	fi
	@case "$(TEX_FILE)" in \
		*.tex) ;; \
		*) printf "Erro: TEX_FILE deve terminar com .tex (recebido: $(TEX_FILE)).\n"; exit 1 ;; \
	esac

validate-tex-file: validate-tex
	@if [ ! -f "$(TEX_FILE)" ]; then \
		printf "Erro: arquivo não encontrado: $(TEX_FILE)\n"; \
		exit 1; \
	fi

image:
	$(DOCKER) build -t $(LATEX_IMAGE) .

pdf: validate-tex-file image
	$(DOCKER) run --rm -i -v "$$(pwd)":/data $(LATEX_IMAGE) $(PDFLATEX) -interaction=nonstopmode -halt-on-error $(TEX_FILE)
	$(DOCKER) run --rm -i -v "$$(pwd)":/data $(LATEX_IMAGE) $(PDFLATEX) -interaction=nonstopmode -halt-on-error $(TEX_FILE)

clean: validate-tex
	rm -f $(PDF_FILE) \
		$(LATEX_BASENAME).aux \
		$(LATEX_BASENAME).log \
		$(LATEX_BASENAME).out \
		$(LATEX_BASENAME).fdb_latexmk \
		$(LATEX_BASENAME).fls \
		$(LATEX_BASENAME).synctex.gz

%.tex:
	@: