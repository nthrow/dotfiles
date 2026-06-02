# Makefile — stow these dotfiles into $HOME.
# Packages are auto-discovered: every non-hidden top-level directory here.

SHELL  := /bin/sh
REPO   := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
TARGET := $(HOME)
PACKAGES := $(notdir $(patsubst %/,%,$(wildcard $(REPO)/*/)))

# --no-folding keeps shared dirs (e.g. ~/.config/fish) as real directories of
# leaf symlinks, so multiple repos can stow into them without conflicts.
STOW := stow --no-folding --dir "$(REPO)" --target "$(TARGET)"

.PHONY: help stow restow unstow adopt sync push status

help:
	@echo "targets: stow restow unstow adopt sync push status"
	@echo "packages (auto-discovered): $(PACKAGES)"

stow:
	@for p in $(PACKAGES); do echo ">> stow $$p"; $(STOW) --verbose=1 $$p || exit 1; done

restow:
	@for p in $(PACKAGES); do echo ">> restow $$p"; $(STOW) --restow --verbose=1 $$p || exit 1; done

unstow:
	@for p in $(PACKAGES); do echo ">> unstow $$p"; $(STOW) --delete --verbose=1 $$p || exit 1; done

# --adopt MOVES pre-existing real files into the repo, then symlinks them back.
# It overwrites tracked files with the machine's current content — review after.
adopt:
	@for p in $(PACKAGES); do echo ">> adopt $$p"; $(STOW) --adopt --verbose=1 $$p || exit 1; done
	@echo "!! review now:  git -C $(REPO) diff"

sync:
	@git -C "$(REPO)" pull --ff-only && $(MAKE) --no-print-directory restow

push:
	@if [ -n "$$(git -C "$(REPO)" status --porcelain)" ]; then \
	  git -C "$(REPO)" add -A && \
	  git -C "$(REPO)" commit -m "sync $$(date -u +%FT%TZ)" && \
	  git -C "$(REPO)" push; \
	else echo "nothing to push (clean)"; fi

status:
	@git -C "$(REPO)" status --short --branch
	@for p in $(PACKAGES); do echo ">> $$p"; $(STOW) --no --verbose=2 $$p 2>&1 | sed 's/^/   /'; done
