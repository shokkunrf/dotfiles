# shellcheck shell=bash
#
# macOS の処理
#
#   os_deploy : macOS 用のリンクと defaults の設定
#   os_links  : リンクする一覧
#
# 呼び出し側で DOT_DIRECTORY を設定し、lib/common.sh と lib/user.sh を source しておく
# macOS 標準の bash 3.2 で動くように、配列は使わない

# macOS でリンクする dotfiles の一覧。書き方は lib/user.sh の cui_links と同じ
os_links() {
  cat <<'EOF'
darwin/vscode/settings.json|Library/Application Support/Code/User/settings.json
darwin/vscode/keybindings.json|Library/Application Support/Code/User/keybindings.json
EOF
}

# --- defaults -------------------------------------------------------------

deploy_defaults() {
  # Dock: 表示までの遅延を長くする
  defaults write com.apple.dock autohide -bool false
  defaults write com.apple.dock autohide-delay -float 10
  # タップでクリックを許可
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1
  # カーソルの移動速度を変更 (1-15)
  defaults write NSGlobalDomain com.apple.trackpad.scaling -float 15
  # Finder: 隠しファイル表示
  defaults write com.apple.finder AppleShowAllFile true
  # Finder: 拡張子表示
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # アルファベットの連続入力を有効にする
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  killall Dock >/dev/null 2>&1 || true
}

# --- 各ステップ -----------------------------------------------------------

os_deploy() {
  link_list os_links
  deploy_defaults
}
