# shellcheck shell=bash
#
# OS 共通で、ユーザ領域だけを変更する処理 (sudo を一切使わない)
#
#   user_check   : wd のインストールが必要か調べる (何も表示しない)
#   user_install : wd を ~/.local/bin に入れる
#   user_deploy  : dotfiles のリンクと git の設定
#   cui_links    : リンクする dotfiles の一覧
#   link_list    : 一覧のとおりにリンクする (lib/debian.sh, lib/darwin.sh でも使う)
#
# 呼び出し側で DOT_DIRECTORY を設定し、lib/common.sh を source しておく
# macOS 標準の bash 3.2 でも動くように書くこと

SRC_DIRECTORY="$DOT_DIRECTORY/src"
BACKUP_DIRECTORY="$HOME/.dotfiles_backup/$(date +%Y%m%d%H%M%S)"

# リンクする dotfiles の一覧。1 行に 1 つ、「src 以下のパス[|ホーム以下のパス]」
cui_links() {
  cat <<'EOF'
bin
.bash_profile
.bashrc
.profile
.shrc
.vimrc
EOF
}

# --- wd -------------------------------------------------------------------

needs_wd() {
  ! command -v wd >/dev/null 2>&1 && [ ! -x "$HOME/.local/bin/wd" ]
}

install_wd() {
  log "wd を ~/.local/bin にインストールします"
  local tmp
  tmp="$(make_tmpdir)"
  download https://github.com/shokkunrf/wd/releases/latest/download/install.sh "$tmp/install.sh"
  mkdir -p "$HOME/.local/bin"
  WD_INSTALL_DIR="$HOME/.local/bin" sh "$tmp/install.sh"
  rm -rf "$tmp"
}

# --- リンク ---------------------------------------------------------------

# link <src 以下のパス> [ホーム以下のパス]
# 既存のファイルは BACKUP_DIRECTORY に退避してからリンクする
link() {
  local src="$SRC_DIRECTORY/$1"
  local rel="${2:-$1}"
  local dest="$HOME/$rel"

  [ -e "$src" ] || die "$src が存在しません"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    return 0
  fi

  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    mkdir -p "$(dirname "$BACKUP_DIRECTORY/$rel")"
    mv "$dest" "$BACKUP_DIRECTORY/$rel"
    log "退避   ~/$rel -> $BACKUP_DIRECTORY/$rel"
  fi
  ln -s "$src" "$dest"
  log "リンク ~/$rel"
}

# 一覧のとおりにリンクする: link_list <一覧を出力する関数>
link_list() {
  local line
  while IFS= read -r line; do
    link "${line%%|*}" "${line#*|}"
  done < <("$1")
}

# --- git ------------------------------------------------------------------

deploy_git() {
  if ! command -v git >/dev/null 2>&1; then
    warn "git が無いため git の設定をスキップします"
    return 0
  fi
  git config --global alias.st status
  git config --global alias.br branch
  git config --global alias.ch checkout
  git config --global alias.ad add
  git config --global alias.cm commit
  git config --global alias.cp cherry-pick
  git config --global core.editor vim
}

# --- 各ステップ -----------------------------------------------------------

user_check() {
  if needs_wd; then
    NEED_WD=true
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
  else
    NEED_WD=false
  fi
}

user_install() {
  if $NEED_WD; then
    install_wd
  fi
}

user_deploy() {
  deploy_git
  link_list cui_links
}
