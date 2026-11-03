# shellcheck shell=bash
#
# macOS の処理
#
#   os_preflight : 実行できる環境か
#   os_check     : インストールが必要なものを調べる (何も表示せず、sudo も使わない)
#   os_install   : Homebrew と Brewfile のうち、足りないものをインストール
#   os_deploy    : macOS 用のリンクと defaults の設定
#   os_links     : リンクする一覧
#
# インストールするものの一覧は packages/Brewfile
# 呼び出し側で DOT_DIRECTORY を設定し、lib/common.sh と lib/user.sh を source しておく
# macOS 標準の bash 3.2 で動くように、配列は使わない

BREWFILE="$DOT_DIRECTORY/packages/Brewfile"

# macOS でリンクする dotfiles の一覧。書き方は lib/user.sh の cui_links と同じ
os_links() {
  cat <<'EOF'
darwin/vscode/settings.json|Library/Application Support/Code/User/settings.json
darwin/vscode/keybindings.json|Library/Application Support/Code/User/keybindings.json
.config/karabiner/assets
EOF
}

# --- Homebrew -------------------------------------------------------------

# PATH に brew が無ければ既知のインストール先から読み込む
load_homebrew() {
  command -v brew >/dev/null 2>&1 && return 0
  local brew
  for brew in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [ -x "$brew" ]; then
      eval "$("$brew" shellenv)"
      return 0
    fi
  done
  return 1
}

install_homebrew() {
  log "Homebrew をインストールします"
  local tmp
  tmp="$(make_tmpdir)"
  download https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh "$tmp/install.sh"
  NONINTERACTIVE=1 /bin/bash "$tmp/install.sh"
  rm -rf "$tmp"
  load_homebrew || die "Homebrew のインストールに失敗しました"
}

# Brewfile の brew / cask の名前を 1 行ずつ出力する: brewfile_entries <brew|cask>
brewfile_entries() {
  awk -F'"' -v kind="$1 " '$1 == kind { print $2 }' "$BREWFILE"
}

# --- defaults -------------------------------------------------------------

deploy_defaults() {
  # Dock: 自動的に隠し、表示までの遅延を長くする (実質的に非表示)
  defaults write com.apple.dock autohide -bool true
  defaults write com.apple.dock autohide-delay -float 10
  # タップでクリックを許可
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1
  defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
  defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  # カーソルの移動速度を変更 (1-15)
  defaults write NSGlobalDomain com.apple.trackpad.scaling -float 15
  # Finder: 隠しファイル表示
  defaults write com.apple.finder AppleShowAllFiles -bool true
  # Finder: 拡張子表示
  defaults write NSGlobalDomain AppleShowAllExtensions -bool true
  # アルファベットの連続入力を有効にする
  defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

  killall Dock Finder >/dev/null 2>&1 || true
}

# --- 各ステップ -----------------------------------------------------------

os_preflight() {
  if is_root; then
    die "macOS では sudo を付けずに実行してください (Homebrew は root では動きません)"
  fi
}

os_check() {
  local installed_formulae='' installed_casks='' name
  if load_homebrew; then
    NEED_HOMEBREW=false
    installed_formulae="$(brew list --formula -1 2>/dev/null || true)"
    installed_casks="$(brew list --cask -1 2>/dev/null || true)"
  else
    NEED_HOMEBREW=true
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
  fi

  MISSING_FORMULAE=''
  while read -r name; do
    if ! grep -qxF "$name" <<<"$installed_formulae"; then
      MISSING_FORMULAE="$MISSING_FORMULAE $name"
    fi
  done < <(brewfile_entries brew)

  # HOMEBREW_BUNDLE_CASK_SKIP で除外したものは数えない
  MISSING_CASKS=''
  while read -r name; do
    case " ${HOMEBREW_BUNDLE_CASK_SKIP:-} " in
      *" $name "*) continue ;;
    esac
    if ! grep -qxF "$name" <<<"$installed_casks"; then
      MISSING_CASKS="$MISSING_CASKS $name"
    fi
  done < <(brewfile_entries cask)

  INSTALL_COUNT=$((INSTALL_COUNT + $(count_words "$MISSING_FORMULAE$MISSING_CASKS")))
}

os_install() {
  if $NEED_HOMEBREW; then
    install_homebrew
  fi
  if [ -n "$MISSING_FORMULAE$MISSING_CASKS" ]; then
    log "Homebrew のパッケージをインストールします"
    # 足りないもの以外は変えないよう、インストール済みのものは更新しない
    brew bundle --file="$BREWFILE" --no-upgrade
  fi
}

os_deploy() {
  link_list os_links
  deploy_defaults
}
