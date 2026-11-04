#!/bin/bash
#
# install.sh 実行後の環境を検証する (CI 用)
#
# usage: test/verify.sh [--with-gui] [--packages | --no-packages]
#   --no-packages  設定の配置だけを行った後 (コンテナ内や --no-packages) に使う。配置だけを確認する
#
# リンクの一覧とログインシェルは lib/ の定義を使う
set -euo pipefail

DOT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/common.sh
. "$DOT_DIRECTORY/lib/common.sh"

WITH_GUI=false
with_packages=true
for arg in "$@"; do
  case "$arg" in
    --with-gui) WITH_GUI=true ;;
    --packages) with_packages=true ;;
    --no-packages) with_packages=false ;;
    *) die "不明なオプションです: $arg" ;;
  esac
done

OS="$(detect_os)"
if [ "$OS" != unsupported ]; then
  # shellcheck source=lib/debian.sh
  . "$DOT_DIRECTORY/lib/$OS.sh"
fi
# shellcheck source=lib/user.sh
. "$DOT_DIRECTORY/lib/user.sh"

failures=0
pass() { printf '\033[32mok\033[0m   %s\n' "$*"; }
fail() {
  printf '\033[31mFAIL\033[0m %s\n' "$*"
  failures=$((failures + 1))
}

# 一覧のとおりにリンクされていること: check_links <一覧を出力する関数>
check_links() {
  local line src rel
  while IFS= read -r line; do
    src="$SRC_DIRECTORY/${line%%|*}"
    rel="${line#*|}"
    if [ -L "$HOME/$rel" ] && [ "$(readlink "$HOME/$rel")" = "$src" ]; then
      pass "link ~/$rel"
    else
      fail "link ~/$rel -> $src"
    fi
  done < <("$1")
}

# ログインシェルの PATH (~/.local/bin など) で探す
check_command() {
  # shellcheck disable=SC2016
  if bash -lc 'command -v "$1"' _ "$1" >/dev/null 2>&1; then
    pass "command $1"
  else
    fail "command $1"
  fi
}

check_git_config() {
  if [ "$(git config --global "$1" || true)" = "$2" ]; then
    pass "git config $1"
  else
    fail "git config $1 = $2"
  fi
}

# ログインシェルが bash (lib/ の target_shell) になっていること
check_login_shell_is_bash() {
  local current want
  current="$(current_login_shell)"
  want="$(target_shell)"
  if [ "$current" = "$want" ]; then
    pass "login shell $current"
  else
    fail "login shell $current (expected $want)"
  fi
}

# ログインシェルを起動し、設定ファイルがエラーを出さないことを確認する
check_shell_startup() {
  local shell="$1" errors
  # 端末が無いことによる警告は無視する
  errors="$(
    cd "$HOME" || exit 1
    "$shell" -lic '
      chpwd >/dev/null
      __git_ps1 >/dev/null
      type wds wda sd h lo >/dev/null
      la >/dev/null
    ' 2>&1 >/dev/null </dev/null |
      grep -v -e 'cannot set terminal process group' -e 'no job control in this shell' || true
  )"
  if [ -z "$errors" ]; then
    pass "$shell -l starts without errors"
  else
    fail "$shell -l printed errors:"
    printf '%s\n' "$errors" | sed 's/^/       /'
  fi
}

echo "--- 共通"
check_links cui_links
check_shell_startup bash
if $with_packages; then
  for cmd in git vim fzf jq curl wd; do
    check_command "$cmd"
  done
  check_git_config alias.st status
  check_git_config core.editor vim
  check_login_shell_is_bash
fi

case "$OS" in
  debian)
    echo "--- Debian"
    check_links os_links
    if $with_packages; then
      check_command wget
      check_command docker
      if ! is_root; then
        if grep -qx docker <<<"$(id -nG "$(id -un)" | tr ' ' '\n')"; then
          pass "$(id -un) is in docker group"
        else
          fail "$(id -un) is in docker group"
        fi
      fi
      if $WITH_GUI; then
        for cmd in xmonad xmobar qterminal dmenu feh xinput xmodmap notify-send dunst pactl brightnessctl code; do
          check_command "$cmd"
        done
        if supports_chrome; then
          check_command google-chrome
        fi
        if (cd "$HOME" && xmonad --recompile); then
          pass "xmonad --recompile"
        else
          fail "xmonad --recompile"
        fi
      fi
    fi
    ;;
  darwin)
    echo "--- macOS"
    check_links os_links
    if [ "$(defaults read com.apple.finder AppleShowAllFiles)" = 1 ]; then
      pass "defaults com.apple.finder AppleShowAllFiles"
    else
      fail "defaults com.apple.finder AppleShowAllFiles"
    fi
    if [ "$(defaults read com.apple.dock autohide)" = 1 ]; then
      pass "defaults com.apple.dock autohide"
    else
      fail "defaults com.apple.dock autohide"
    fi
    # macOS 標準の bash 3.2 でも読み込めること
    check_shell_startup /bin/bash
    if $with_packages; then
      check_command brew
    fi
    ;;
esac

echo
if [ "$failures" -gt 0 ]; then
  echo "$failures check(s) failed"
  exit 1
fi
echo "all checks passed"
