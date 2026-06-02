#!/usr/bin/env sh
# bootstrap.sh — install dependencies and stow these dotfiles into $HOME.
# Idempotent. Packages are auto-discovered: every directory beside this script.
#
#   ./bootstrap.sh             install deps, then stow every package
#   ./bootstrap.sh --no-deps   skip dependency install (just stow)
#   ./bootstrap.sh --adopt     stow --adopt (absorb pre-existing real files)
set -eu

HERE="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
DO_DEPS=1; ADOPT=""
for a in "$@"; do
	case "$a" in
		--no-deps) DO_DEPS=0 ;;
		--adopt)   ADOPT="--adopt" ;;
		-h|--help) sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
		*) echo "unknown arg: $a" >&2; exit 2 ;;
	esac
done

log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mWARN:\033[0m %s\n' "$*" >&2; }

# Privilege escalation: none if root, else doas or sudo.
if   [ "$(id -u)" -eq 0 ];            then SUDO=
elif command -v doas >/dev/null 2>&1; then SUDO=doas
elif command -v sudo >/dev/null 2>&1; then SUDO=sudo
else SUDO=; warn "not root and no doas/sudo — dependency install may fail"; fi

# musl libc has no upstream prebuilt for lua-language-server, so install it from
# the system package manager there (mason fetches the rest itself).
is_musl() { for f in /lib/ld-musl-*; do [ -e "$f" ] && return 0; done; return 1; }

install_deps() {
	log "installing dependencies"
	if   command -v apk >/dev/null 2>&1; then
		set -- stow git tmux ripgrep fd shellcheck nodejs npm go py3-pip build-base unzip curl
		is_musl && set -- "$@" lua-language-server
		$SUDO apk add "$@"
	elif command -v apt-get >/dev/null 2>&1; then
		$SUDO apt-get update
		$SUDO apt-get install -y stow git tmux ripgrep fd-find shellcheck nodejs npm golang-go python3-pip build-essential unzip curl
	elif command -v dnf >/dev/null 2>&1; then
		$SUDO dnf install -y stow git tmux ripgrep fd-find ShellCheck nodejs npm golang python3-pip make gcc unzip curl
	elif command -v pacman >/dev/null 2>&1; then
		$SUDO pacman -S --needed --noconfirm stow git tmux ripgrep fd shellcheck nodejs npm go python-pip base-devel unzip curl
	elif command -v brew >/dev/null 2>&1; then
		brew install stow git tmux ripgrep fd shellcheck node go
	else
		warn "no supported package manager found — install the dependencies manually"
	fi
}

[ "$DO_DEPS" -eq 1 ] && install_deps
command -v stow >/dev/null 2>&1 || { echo "stow is required" >&2; exit 1; }

if command -v nvim >/dev/null 2>&1; then
	v=$(nvim --version | sed -n '1s/^NVIM v//p'); maj=${v%%.*}; rest=${v#*.}; min=${rest%%.*}
	if [ "${maj:-0}" -eq 0 ] && [ "${min:-0}" -lt 11 ]; then
		warn "neovim $v is < 0.11 — the editor config needs 0.11+"
	fi
else
	warn "neovim not found — install neovim >= 0.11 for the editor config"
fi

# Stow every package (= every non-hidden directory here). No hardcoded names.
cd "$HERE"
for pkg in */; do
	pkg=${pkg%/}
	case "$pkg" in .*) continue ;; esac
	log "stow $pkg"
	# shellcheck disable=SC2086
	stow --no-folding $ADOPT --target "$HOME" "$pkg"
done

# Native editor plugins can't load from a noexec $HOME.
if command -v findmnt >/dev/null 2>&1 && findmnt -no OPTIONS --target "$HOME" 2>/dev/null | grep -q noexec; then
	warn "\$HOME is mounted noexec — set NVIM_EXEC_DIR to a writable exec path so Neovim's native plugins can load."
fi

log "done."
