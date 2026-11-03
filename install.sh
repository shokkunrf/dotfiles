#!/bin/bash
#
# 環境構築を行う (このリポジトリの唯一の入口)
#
#   [1/3] 確認         足りないパッケージを調べて表示する
#   [2/3] インストール 足りないものをインストールする (無ければスキップ)
#   [3/3] 設定の配置   dotfiles をリンクし、git / macOS の設定をする
#
# 処理は lib/ に、インストールするものの一覧は packages/ に、配置するファイルは src/ にある
#   lib/common.sh  OS に依存しない道具 (表示、sudo など)
#   lib/user.sh    OS 共通でユーザ領域だけを変更する処理 (wd、リンク、git の設定。sudo を使わない)
#   lib/debian.sh  Debian の処理 (apt / Docker / Chrome / VS Code、GUI 用のリンク)
#   lib/darwin.sh  macOS の処理 (Homebrew、macOS 用のリンク、defaults)
#
# usage: ./install.sh [--with-gui]
#
#   --with-gui     GUI 環境用のパッケージ・設定も入れる (Debian のみ)
#
# sudo は付けずに実行する。root 権限が必要な場合は、何かを表示する前に一度だけパスワードを聞く。
# 一度表示が始まったら、終了まで入力待ちで止まることはない。
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
      -h | --help)
        sed -n '2,/^set -euo/p' "$DOT_DIRECTORY/install.sh" | sed '$d; s/^# \{0,1\}//'
        exit 0
        ;;
      *) die "不明なオプションです: $1 (--help で使い方を表示)" ;;
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

  # [1/3] 確認 は何も表示せずに行い、root 権限が必要なら最初にパスワードを聞いてから表示する
  os_preflight
  os_check
  user_check
  if [ -n "$SUDO_REASON" ]; then
    require_sudo "$SUDO_REASON"
  fi

  step 1/3 "確認"
  printf '%s' "$REPORT"
  if [ "$INSTALL_COUNT" -eq 0 ]; then
    step 2/3 "インストール" "スキップ (すべてインストール済み)"
  else
    step 2/3 "インストール"
    os_install
    user_install
  fi

  step 3/3 "設定の配置"
  local before=$LINK_COUNT
  user_deploy
  os_deploy
  if [ "$LINK_COUNT" -eq "$before" ]; then
    log "すべて配置済み"
  fi

  summary "インストール $INSTALL_COUNT 件 / リンク $LINK_COUNT 件 / 退避 $BACKUP_COUNT 件"
  if [ $((INSTALL_COUNT + LINK_COUNT)) -gt 0 ]; then
    echo "設定を反映するにはシェルを再起動してください: exec \$SHELL -l"
  fi
}

main "$@"
