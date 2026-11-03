# shellcheck shell=bash
#
# OS 共通で、ユーザ領域だけを変更する処理 (sudo を一切使わない)
#
#   user_check   : [1/3] 確認         wd
#   user_install : [2/3] インストール wd を ~/.local/bin に入れる
#   user_deploy  : [3/3] 設定の配置   dotfiles のリンクと git の設定
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
    BACKUP_COUNT=$((BACKUP_COUNT + 1))
  fi
  ln -s "$src" "$dest"
  log "リンク ~/$rel"
  LINK_COUNT=$((LINK_COUNT + 1))
}

# 一覧のとおりにリンクする: link_list <一覧を出力する関数>
link_list() {
  local line
  while IFS= read -r line; do
    link "${line%%|*}" "${line#*|}"
  done < <("$1")
}

# --- git ------------------------------------------------------------------

# 値が違う場合だけ設定する: ensure_git_config <key> <value>
ensure_git_config() {
  if [ "$(git config --global "$1" || true)" != "$2" ]; then
    git config --global "$1" "$2"
    log "設定   git $1 = $2"
    SETTING_COUNT=$((SETTING_COUNT + 1))
  fi
}

deploy_git() {
  if ! command -v git >/dev/null 2>&1; then
    warn "git が無いため git の設定をスキップします"
    return 0
  fi
  ensure_git_config alias.st status
  ensure_git_config alias.br branch
  ensure_git_config alias.ch checkout
  ensure_git_config alias.ad add
  ensure_git_config alias.cm commit
  ensure_git_config alias.cp cherry-pick
  ensure_git_config core.editor vim
}

# --- 各ステップ -----------------------------------------------------------

user_check() {
  if needs_wd; then
    NEED_WD=true
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
    report wd "未インストール"
  else
    NEED_WD=false
    report wd "インストール済み"
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
