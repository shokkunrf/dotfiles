#!/bin/bash
#
# 環境構築を行う (このリポジトリの唯一の入口)
#
#   [1/3] 確認         足りないパッケージとログインシェルを調べて表示する
#   [2/3] インストール 足りないものをインストールし、ログインシェルを bash にする (無ければスキップ)
#   [3/3] 設定の配置   dotfiles をリンクし、git / macOS の設定をする
#
# 処理は lib/ に、インストールするものの一覧は packages/ に、配置するファイルは src/ にある
#   lib/common.sh  OS に依存しない道具 (表示、sudo、ログインシェルなど)
#   lib/user.sh    OS 共通でユーザ領域だけを変更する処理 (wd、リンク、git の設定。sudo を使わない)
#   lib/debian.sh  Debian の処理 (apt / Docker / Chrome / VS Code、GUI 用のリンク)
#   lib/darwin.sh  macOS の処理 (Homebrew、macOS 用のリンク、defaults)
#
# リポジトリ内から実行:
#   ./install.sh [--with-gui] [--packages | --no-packages]
#
#   --with-gui     GUI 環境用のパッケージ・設定も入れる (Debian のみ)
#   --packages     [1/3] [2/3] を行う (コンテナ外では指定しなくても行う)
#   --no-packages  [1/3] [2/3] を行わず、設定の配置だけ行う (sudo を一切使わない)
#
# devcontainer / Codespaces などのコンテナ内では、引数を渡せないため自動で --no-packages になる
# (パッケージはコンテナのイメージや devcontainer の Features で用意する)
#
# リポジトリを取得せずに実行 (DOTFILES_DIR に clone してから実行する):
#   curl -fsSL https://raw.githubusercontent.com/shokkunrf/dotfiles/HEAD/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/shokkunrf/dotfiles/HEAD/install.sh | bash -s -- --with-gui
#
# 環境変数:
#   DOTFILES_DIR     clone 先           (default: ~/.dotfiles)
#   DOTFILES_REPO    clone する URL     (default: https://github.com/shokkunrf/dotfiles.git)
#   DOTFILES_BRANCH  clone するブランチ (default: リポジトリのデフォルトブランチ)
#
# sudo は付けずに実行する。root 権限が必要な場合は、何かを表示する前に一度だけパスワードを聞く。
# 一度表示が始まったら、終了まで入力待ちで止まることはない。
#
# パイプ経由で実行されても途中で標準入力を読まれないよう、全体を関数にしてから最後に呼び出す
set -euo pipefail

main() {
  local self_dir=""
  if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    self_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  fi

  if [ -z "$self_dir" ] || [ ! -f "$self_dir/lib/common.sh" ]; then
    bootstrap "$@"
    exec "$DOTFILES_DIR/install.sh" "$@"
  fi
  run "$self_dir" "$@"
}

# --- リポジトリ内から実行した場合 ---------------------------------------------

run() {
  DOT_DIRECTORY="$1"
  shift
  # shellcheck source=lib/common.sh
  . "$DOT_DIRECTORY/lib/common.sh"

  WITH_GUI=false
  local packages=auto with_packages skip_reason
  while [ $# -gt 0 ]; do
    case "$1" in
      --with-gui) WITH_GUI=true ;;
      --packages) packages=true ;;
      --no-packages) packages=false ;;
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

  case "$packages" in
    true) with_packages=true ;;
    false)
      with_packages=false
      skip_reason="--no-packages"
      ;;
    auto)
      if is_container; then
        with_packages=false
        skip_reason="コンテナ内のため。インストールする場合は --packages"
      else
        with_packages=true
      fi
      ;;
  esac

  local os
  os="$(detect_os)"
  if [ "$os" != unsupported ]; then
    # shellcheck source=lib/debian.sh
    . "$DOT_DIRECTORY/lib/$os.sh"
  elif $with_packages; then
    die "パッケージのインストールは Debian 系 Linux と macOS のみ対応しています (--no-packages なら設定の配置だけ行えます)"
  fi
  # shellcheck source=lib/user.sh
  . "$DOT_DIRECTORY/lib/user.sh"

  # [1/3] 確認 は何も表示せずに行い、root 権限が必要なら最初にパスワードを聞いてから表示する
  if $with_packages; then
    os_preflight
    os_check
    user_check
    check_login_shell
    if [ -n "$SUDO_REASON" ]; then
      require_sudo "$SUDO_REASON"
    fi

    step 1/3 "確認"
    printf '%s' "$REPORT"
    if [ $((INSTALL_COUNT + SETTING_COUNT)) -eq 0 ]; then
      step 2/3 "インストール" "スキップ (すべてインストール済み)"
    else
      step 2/3 "インストール"
      os_install
      user_install
      # macOS は Homebrew の bash を使うので、インストールの後に変更する
      if $NEED_SHELL; then
        change_login_shell
      fi
    fi
  else
    step 1/3 "確認" "スキップ ($skip_reason)"
    step 2/3 "インストール" "スキップ ($skip_reason)"
  fi

  step 3/3 "設定の配置"
  local before=$((LINK_COUNT + SETTING_COUNT))
  user_deploy
  if [ "$os" != unsupported ]; then
    os_deploy
  fi
  if [ $((LINK_COUNT + SETTING_COUNT)) -eq "$before" ]; then
    log "すべて配置済み"
  fi

  summary "インストール $INSTALL_COUNT 件 / リンク $LINK_COUNT 件 / 退避 $BACKUP_COUNT 件 / 設定変更 $SETTING_COUNT 件"
  if ${NEED_SHELL:-false}; then
    echo "ログインシェルを変更したので、ログインし直してください"
  elif [ $((INSTALL_COUNT + LINK_COUNT + SETTING_COUNT)) -gt 0 ]; then
    echo "設定を反映するにはシェルを再起動してください: exec \$SHELL -l"
  fi
}

# --- リポジトリを取得せずに実行した場合 ---------------------------------------
# 既に clone 済みなら何も表示せずにそれを使う

bootstrap() {
  DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
  DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/shokkunrf/dotfiles.git}"
  DOTFILES_BRANCH="${DOTFILES_BRANCH:-}"

  if [ -f "$DOTFILES_DIR/install.sh" ]; then
    return 0
  fi

  # 初回 (clone が必要) は、パッケージのインストールや git の導入に root 権限を使うので、
  # 何かを表示する前にパスワードを聞いておく (clone 後の install.sh では聞き直さない)
  local with_packages=true arg
  if [ -n "${CODESPACES:-}" ] || [ -n "${REMOTE_CONTAINERS:-}" ] ||
    [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    with_packages=false
  fi
  for arg in "$@"; do
    case "$arg" in
      --packages) with_packages=true ;;
      --no-packages) with_packages=false ;;
    esac
  done
  if $with_packages || ! has_git; then
    sudo_once "初回セットアップ"
  fi

  if ! has_git; then
    install_git
  fi
  printf 'clone: %s (%s) -> %s\n' "$DOTFILES_REPO" "${DOTFILES_BRANCH:-デフォルトブランチ}" "$DOTFILES_DIR"
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  if [ -n "$DOTFILES_BRANCH" ]; then
    GIT_TERMINAL_PROMPT=0 git clone -q --branch "$DOTFILES_BRANCH" "$DOTFILES_REPO" "$DOTFILES_DIR"
  else
    GIT_TERMINAL_PROMPT=0 git clone -q "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
}

has_git() {
  case "$(uname -s)" in
    # macOS の /usr/bin/git は Command Line Tools が無いとインストールのダイアログを出すだけ
    Darwin) xcode-select -p >/dev/null 2>&1 ;;
    *) command -v git >/dev/null 2>&1 ;;
  esac
}

install_git() {
  case "$(uname -s)" in
    Darwin)
      # Command Line Tools は Homebrew のインストーラが非対話で入れてくれる
      echo "Command Line Tools を入れるため、Homebrew をインストールします"
      local tmp
      tmp="$(mktemp -d)"
      curl -fsSL --retry 3 -o "$tmp/install.sh" https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh ||
        bootstrap_error "Homebrew のインストーラを取得できませんでした"
      NONINTERACTIVE=1 /bin/bash "$tmp/install.sh"
      rm -rf "$tmp"
      ;;
    *)
      command -v apt-get >/dev/null 2>&1 || bootstrap_error "git をインストールしてから再実行してください"
      echo "git をインストールします"
      # 他の apt (自動更新など) が実行中なら終わるまで待つ (lib/debian.sh の apt_update / apt_install と同じ)
      local output attempt=1
      while ! output="$(as_root env LC_ALL=C apt-get update -q 2>&1)"; do
        if ! grep -q 'Could not get lock' <<<"$output" || [ "$attempt" -ge 20 ]; then
          printf '%s\n' "$output" >&2
          bootstrap_error "apt-get update に失敗しました"
        fi
        echo "他の apt が実行中のため、終わるのを待っています ($attempt/20)"
        attempt=$((attempt + 1))
        sleep 15
      done
      as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y -q -o DPkg::Lock::Timeout=300 git ca-certificates
      ;;
  esac
  has_git || bootstrap_error "git をインストールできませんでした"
}

# パスワードが必要ならここで一度だけ聞き、終了まで認証を維持する
# (Command Line Tools のインストールなど時間のかかる処理の途中で切れないように。clone 後の install.sh にも引き継ぐ)
sudo_once() {
  if [ "$(id -u)" -eq 0 ]; then
    return 0
  fi
  command -v sudo >/dev/null 2>&1 || bootstrap_error "$1に管理者権限が必要ですが、sudo が見つかりません"
  if ! sudo -n true 2>/dev/null; then
    sudo -v -p "$1に管理者権限が必要です。[sudo] %u のパスワード: " || bootstrap_error "sudo の認証に失敗しました"
  fi
  (while kill -0 "$$" 2>/dev/null; do
    sudo -n true
    sleep 50
  done) >/dev/null 2>&1 &
}

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  else
    sudo -n "$@"
  fi
}

bootstrap_error() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

main "$@"
