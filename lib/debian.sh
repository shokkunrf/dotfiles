# shellcheck shell=bash
#
# Debian の処理
#
#   os_deploy : GUI 用のリンク
#   os_links  : リンクする一覧
#
# 呼び出し側で DOT_DIRECTORY と WITH_GUI を設定し、lib/common.sh と lib/user.sh を source しておく

# GUI 環境でリンクする dotfiles の一覧。書き方は lib/user.sh の cui_links と同じ
os_links() {
  if $WITH_GUI; then
    cat <<'EOF'
.config/qterminal.org
.Xmodmap
.xmonad
.xsession
EOF
  fi
}

# --- 各ステップ -----------------------------------------------------------

os_deploy() {
  link_list os_links
}
