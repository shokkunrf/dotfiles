#!/bin/bash
#
# 環境構築を行う
#
# usage: ./install.sh [--with-gui]
#   --with-gui  GUI 環境用のパッケージ・設定も入れる (Debian のみ)
#
# 足りないパッケージをインストールしてから、dotfiles を配置する
#
# sudo は付けずに実行する。root 権限が必要な場合は、何かを表示する前に一度だけパスワードを聞く。
# 一度表示が始まったら、終了まで入力待ちで止まることはない。
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
    die "sudo を付けずに実行してください (root 権限が必要な場合は最初にパスワードを聞きます)"
  fi

  local os
  os="$(detect_os)"
  [ "$os" != unsupported ] || die "Debian 系 Linux と macOS のみ対応しています"
  # shellcheck source=lib/debian.sh
  . "$DOT_DIRECTORY/lib/$os.sh"
  # shellcheck source=lib/user.sh
  . "$DOT_DIRECTORY/lib/user.sh"

  os_preflight
  # 確認は何も表示せずに行い、root 権限が必要なら最初にパスワードを聞く
  os_check
  user_check
  if [ -n "$SUDO_REASON" ]; then
    require_sudo "$SUDO_REASON"
  fi

  if [ "$INSTALL_COUNT" -eq 0 ]; then
    log "必要なパッケージはすべてインストール済みです"
  else
    os_install
    user_install
  fi
  user_deploy
  os_deploy
}

main "$@"
