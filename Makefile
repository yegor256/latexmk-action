# SPDX-FileCopyrightText: Copyright (c) 2021-2026 Yegor Bugayenko
# SPDX-License-Identifier: MIT

.SHELLFLAGS := -e -o pipefail -c
.ONESHELL:
SHELL := bash
.PHONY: all clean test

all: test

test:
	docker build . -t latexmk-action
	docker run --rm -v "$$(pwd):/w" -e HOME -e INPUT_PACKAGES=xcolor latexmk-action
	docker rmi latexmk-action

clean:
	rm -f *.dvi *.pdf *.fls *.aux *.fdb_latexmk *.log
