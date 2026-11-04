# shellcheck shell=bash
#
# macOS の処理
#
#   os_preflight : 実行できる環境か (何かを表示する前に呼ぶ)
#   os_check     : [1/3] 確認         Homebrew と Brewfile
#   os_install   : [2/3] インストール (root 権限が必要なものがあれば事前に require_sudo が必要)
#   os_deploy    : [3/3] 設定の配置   macOS 用のリンクと defaults の設定
#   os_links     : リンクする一覧 (test/verify.sh でも使う)
#   target_shell / current_login_shell : ログインシェル (lib/common.sh で使う)
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

# Homebrew の場所 (インストール済みなら brew に聞く。Homebrew の新規インストールは Apple Silicon のみ対応)
homebrew_prefix() {
  if command -v brew >/dev/null 2>&1; then
    brew --prefix
  else
    echo /opt/homebrew
  fi
}

# macOS 標準の /bin/bash は 3.2 と古いため、Homebrew の bash (Brewfile で入れる) を使う
target_shell() { echo "$(homebrew_prefix)/bin/bash"; }
current_login_shell() { dscl . -read "/Users/$(id -un)" UserShell | awk '{ print $2 }'; }

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

# 値が違う場合だけ設定する: ensure_default <読み出した時の値> [-currentHost] <domain> <key> <型> <値>
# 変更したドメインを DEFAULTS_CHANGED に記録する (反映のためにアプリを再起動する)
DEFAULTS_CHANGED=''
ensure_default() {
  local expected="$1" host=''
  shift
  if [ "$1" = -currentHost ]; then
    host=-currentHost
    shift
  fi
  local domain="$1" key="$2" type="$3" value="$4"
  # shellcheck disable=SC2086
  if [ "$(defaults $host read "$domain" "$key" 2>/dev/null || true)" = "$expected" ]; then
    return 0
  fi
  # shellcheck disable=SC2086
  defaults $host write "$domain" "$key" "$type" "$value"
  log "設定   $domain $key = $value"
  SETTING_COUNT=$((SETTING_COUNT + 1))
  DEFAULTS_CHANGED="$DEFAULTS_CHANGED $domain"
}

deploy_defaults() {
  # Dock: 自動的に隠し、表示までの遅延を長くする (実質的に非表示)
  ensure_default 1 com.apple.dock autohide -bool true
  ensure_default 10 com.apple.dock autohide-delay -float 10
  # タップでクリックを許可
  ensure_default 1 com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1
  ensure_default 1 com.apple.AppleMultitouchTrackpad Clicking -int 1
  ensure_default 1 -currentHost NSGlobalDomain com.apple.mouse.tapBehavior -int 1
  # カーソルの移動速度を変更 (1-15)
  ensure_default 15 NSGlobalDomain com.apple.trackpad.scaling -float 15
  # Finder: 隠しファイル表示
  ensure_default 1 com.apple.finder AppleShowAllFiles -bool true
  # Finder: 拡張子表示
  ensure_default 1 NSGlobalDomain AppleShowAllExtensions -bool true
  # アルファベットの連続入力を有効にする
  ensure_default 0 NSGlobalDomain ApplePressAndHoldEnabled -bool false

  case "$DEFAULTS_CHANGED" in
    *com.apple.dock*) killall Dock >/dev/null 2>&1 || true ;;
  esac
  case "$DEFAULTS_CHANGED" in
    *com.apple.finder* | *NSGlobalDomain*) killall Finder >/dev/null 2>&1 || true ;;
  esac
}

# --- 各ステップ -----------------------------------------------------------

os_preflight() {
  if is_root; then
    die "macOS では sudo を付けずに実行してください (Homebrew は root では動きません)"
  fi
}

os_check() {
  local installed_formulae='' installed_casks='' name total skipped=0 note=''
  if load_homebrew; then
    NEED_HOMEBREW=false
    report homebrew "インストール済み"
    installed_formulae="$(brew list --formula -1 2>/dev/null || true)"
    installed_casks="$(brew list --cask -1 2>/dev/null || true)"
  else
    NEED_HOMEBREW=true
    INSTALL_COUNT=$((INSTALL_COUNT + 1))
    report homebrew "未インストール"
    add_sudo_reason "Homebrew のインストール"
  fi

  MISSING_FORMULAE=''
  total=0
  while read -r name; do
    total=$((total + 1))
    if ! grep -qxF "$name" <<<"$installed_formulae"; then
      MISSING_FORMULAE="$MISSING_FORMULAE $name"
    fi
  done < <(brewfile_entries brew)
  if [ -z "$MISSING_FORMULAE" ]; then
    report brew "$total 件すべてインストール済み"
  else
    report brew "$total 件中 $(count_words "$MISSING_FORMULAE") 件が未インストール (${MISSING_FORMULAE# })"
  fi

  # HOMEBREW_BUNDLE_CASK_SKIP で除外したものは数えない
  MISSING_CASKS=''
  total=0
  while read -r name; do
    case " ${HOMEBREW_BUNDLE_CASK_SKIP:-} " in
      *" $name "*)
        skipped=$((skipped + 1))
        continue
        ;;
    esac
    total=$((total + 1))
    if ! grep -qxF "$name" <<<"$installed_casks"; then
      MISSING_CASKS="$MISSING_CASKS $name"
    fi
  done < <(brewfile_entries cask)
  if [ "$skipped" -gt 0 ]; then
    note=" (HOMEBREW_BUNDLE_CASK_SKIP で $skipped 件除外)"
  fi
  if [ -z "$MISSING_CASKS" ]; then
    report cask "$total 件すべてインストール済み$note"
  else
    report cask "$total 件中 $(count_words "$MISSING_CASKS") 件が未インストール (${MISSING_CASKS# })$note"
  fi

  INSTALL_COUNT=$((INSTALL_COUNT + $(count_words "$MISSING_FORMULAE$MISSING_CASKS")))
  # cask は pkg 形式のものがあり root 権限が必要
  if ! $NEED_HOMEBREW && [ -n "$MISSING_CASKS" ]; then
    add_sudo_reason "アプリ $(count_words "$MISSING_CASKS") 件のインストール"
  fi
}

os_install() {
  if $NEED_HOMEBREW; then
    install_homebrew
  fi
  if [ -n "$MISSING_FORMULAE$MISSING_CASKS" ]; then
    log "Homebrew のパッケージをインストールします"
    # 足りないもの以外は変えないよう、インストール済みのものは更新しない
    # 手動で入れたアプリとバージョンが違う場合などは失敗するが、設定の配置は続ける
    if ! brew bundle --file="$BREWFILE" --no-upgrade; then
      warn "Homebrew のパッケージの一部をインストールできませんでした (上のエラーを確認してください)"
      # shellcheck disable=SC2034 # install.sh で使う
      INSTALL_FAILED=true
    fi
  fi
}

os_deploy() {
  link_list os_links
  deploy_defaults
}
