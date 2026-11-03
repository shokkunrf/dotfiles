#!/bin/bash
#
# 書式とリントを確認する (CI でも使う)
#
# usage: test/lint.sh [--fix]
#   --fix  shfmt で書式を直す
#
# 必要なもの: shfmt, shellcheck, actionlint, jq
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

fix=false
[ "${1:-}" = --fix ] && fix=true

# このリポジトリのスクリプト (厳しく確認する)
scripts=(install.sh lib/*.sh test/*.sh)
# 配置するシェルの設定ファイル (警告以上を確認する)
dotfiles=(src/.bashrc src/.bash_profile src/.profile src/.shrc src/.xsession src/bin/*)
# 書式は .editorconfig に従う
formatted=("${scripts[@]}" "${dotfiles[@]}")

status=0
run() {
  echo "--- $*"
  "$@" || status=1
}

if $fix; then
  run shfmt -w "${formatted[@]}"
fi
run shfmt -d "${formatted[@]}"
run shellcheck -x "${scripts[@]}"
run shellcheck -x --severity=warning "${dotfiles[@]}"
run actionlint
for file in src/.config/karabiner/assets/*/*.json src/darwin/vscode/keybindings.json; do
  jq empty "$file" || {
    echo "invalid JSON: $file"
    status=1
  }
done

exit "$status"
