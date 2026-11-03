#!/bin/bash
#
# 環境構築を行う
#
# usage: ./install.sh [--with-gui]
#   --with-gui  GUI 環境用のパッケージ・設定も入れる (Debian のみ)
#
# パッケージをインストールしてから、dotfiles を配置する
#
# 処理は lib/ に、インストールするものの一覧は packages/ に、配置するファイルは src/ にある
#   lib/common.sh  OS に依存しない道具
#   lib/user.sh    OS 共通でユーザ領域だけを変更する処理 (wd、リンク、git の設定)
#   lib/debian.sh  Debian の処理 (apt / Docker / Chrome / VS Code、GUI 用のリンク)
#   lib/darwin.sh  macOS の処理 (Homebrew、macOS 用のリンク、defaults)
set -euo pipefail

main() {
  local self_dir
  self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  run "$self_dir" "$@"
}

run() {
  DOT_DIRECTORY="$1"
  shift
  # shellcheck source=lib/common.sh
  . "$DOT_DIRECTORY/lib/common.sh"

  WITH_GUI=false
  while [ $# -gt 0 ]; do
    case "$1" in
      --with-gui) WITH_GUI=true ;;
      *) die "不明なオプションです: $1" ;;
    esac
    shift
  done

  if is_sudo; then
    die "sudo を付けずに実行してください"
  fi

  local os
  os="$(detect_os)"
  [ "$os" != unsupported ] || die "Debian 系 Linux と macOS のみ対応しています"
  # shellcheck source=lib/debian.sh
  . "$DOT_DIRECTORY/lib/$os.sh"
  # shellcheck source=lib/user.sh
  . "$DOT_DIRECTORY/lib/user.sh"

  os_preflight
  os_install
  user_install
  user_deploy
  os_deploy
}

main "$@"
