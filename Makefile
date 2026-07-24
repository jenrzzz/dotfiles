# Makefile — thin wrappers around bootstrap.sh / stow for the common chores.
# The bootstrap script is the source of truth; these are just shortcuts.
#
#   make            # list targets
#   make bootstrap  # full install: OS packages + stow + secrets
#   make stow       # (re)stow every package, no package install
#   make core       # stow just the portable core
#   make unstow     # remove all stowed symlinks
#   make secrets    # stow + sync per-host secrets via dot-secrets
#   make packages   # install OS packages only (brew bundle / apt / dnf)

SHELL   := /bin/bash
REPO    := $(CURDIR)
UNAME   := $(shell uname -s)

PACKAGES := shell git tmux nvim cli scripts mutt secrets
ifeq ($(UNAME),Darwin)
PACKAGES += launchd
endif

.DEFAULT_GOAL := help

.PHONY: help bootstrap stow core unstow secrets packages services

help:
	@echo "dotfiles — make targets:"
	@echo "  bootstrap   full install: OS packages + stow + secrets"
	@echo "  stow        (re)stow every package (no package install)"
	@echo "  core        stow just the portable core"
	@echo "  unstow      remove all stowed symlinks"
	@echo "  secrets     stow + sync per-host secrets (dot-secrets)"
	@echo "  packages    install OS packages only (brew bundle / apt / dnf)"
	@echo "  services    (macOS) install text services into ~/Library/Services"

bootstrap:
	./bootstrap.sh --yes --with-secrets

stow:
	./bootstrap.sh --yes --no-install

core:
	./bootstrap.sh --yes --no-install --only-core

secrets:
	./bootstrap.sh --yes --no-install --with-secrets

unstow:
	stow --dir "$(REPO)" --target "$(HOME)" --delete $(PACKAGES)

packages:
ifeq ($(UNAME),Darwin)
	brew bundle --file="$(REPO)/Brewfile"
else
	@echo "Installing Linux packages from packages.txt…"
	@if command -v apt-get >/dev/null; then \
		sudo apt-get update -qq && sudo apt-get install -y $$(grep -vE '^\s*#|^\s*$$' packages.txt); \
	elif command -v dnf >/dev/null; then \
		sudo dnf install -y $$(grep -vE '^\s*#|^\s*$$' packages.txt); \
	else echo "no apt/dnf found"; fi
endif

# macOS text services (Quick Actions). Installed as real files, not stowed —
# sandboxed apps can't follow a symlink out to the repo. See services/README.md.
services:
ifeq ($(UNAME),Darwin)
	python3 "$(REPO)/services/build.py"
else
	@echo "services: macOS only; skipping"
endif
