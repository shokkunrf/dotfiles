# shellcheck shell=bash
#
# Debian の処理
#
#   os_preflight : 実行できる環境か
#   os_check     : インストールが必要なものを調べる (何も表示せず、sudo も使わない)
#   os_install   : apt / Docker / Chrome / VS Code のうち、足りないものをインストール
#   os_deploy    : GUI 用のリンク
#   os_links     : リンクする一覧
#
# インストールするものの一覧は packages/apt-cui.txt と packages/apt-gui.txt
# 呼び出し側で DOT_DIRECTORY と WITH_GUI を設定し、lib/common.sh と lib/user.sh を source しておく

APT_CUI_LIST="$DOT_DIRECTORY/packages/apt-cui.txt"
APT_GUI_LIST="$DOT_DIRECTORY/packages/apt-gui.txt"

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

# --- apt ------------------------------------------------------------------

apt_install() {
  as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}

is_dpkg_installed() {
  [ "$(dpkg-query -W -f='${Status}' "$1" 2>/dev/null)" = 'install ok installed' ]
}

# 'a|b' のどれかがインストール済みか
is_apt_spec_installed() {
  local candidate
  for candidate in ${1//|/ }; do
    if is_dpkg_installed "$candidate"; then
      return 0
    fi
  done
  return 1
}

# 'a|b' をインストールできる最初のパッケージ名に置き換えてインストールする (apt-get update 後に呼ぶ)
apt_install_specs() {
  local packages=() spec candidate found
  for spec in "$@"; do
    found=''
    for candidate in ${spec//|/ }; do
      if apt-cache show "$candidate" >/dev/null 2>&1; then
        found="$candidate"
        break
      fi
    done
    [ -n "$found" ] || die "インストールできるパッケージがありません: $spec"
    packages+=("$found")
  done
  apt_install "${packages[@]}"
}

# --- apt 以外から入れるもの -----------------------------------------------
# supports_<名前>: この環境が対象か / needs_<名前>: インストールが必要か / install_<名前>

supports_docker() { true; }
needs_docker() {
  is_dpkg_installed docker-ce || return 0
  is_root && return 1
  # 追加した直後は、ログインし直すまで今のセッションに反映されないので、グループの設定を見る
  ! grep -qx docker <<<"$(id -nG "$(id -un)" | tr ' ' '\n')"
}

install_docker() {
  # https://docs.docker.com/engine/install/debian/#install-using-the-repository
  log "Docker をインストールします"
  local distro codename arch
  distro="$(. /etc/os-release && echo "$ID")"
  codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"
  arch="$(dpkg --print-architecture)"
  case "$distro" in
    debian | ubuntu) ;;
    *) die "Docker のリポジトリが $distro に対応していません" ;;
  esac
  [ -n "$codename" ] || die "/etc/os-release から VERSION_CODENAME を取得できません"

  if ! is_dpkg_installed docker-ce; then
    apt_install ca-certificates curl
    as_root install -m 0755 -d /etc/apt/keyrings
    as_root curl -fsSL --retry 3 "https://download.docker.com/linux/$distro/gpg" -o /etc/apt/keyrings/docker.asc
    as_root chmod a+r /etc/apt/keyrings/docker.asc
    echo "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/$distro $codename stable" |
      as_root tee /etc/apt/sources.list.d/docker.list >/dev/null
    as_root apt-get update
    apt_install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi

  if ! is_root; then
    as_root usermod -aG docker "$(id -un)"
    log "$(id -un) を docker グループに追加しました (反映には再ログインが必要です)"
  fi
}

supports_chrome() { [ "$(dpkg --print-architecture)" = amd64 ]; }
needs_chrome() { ! is_dpkg_installed google-chrome-stable; }

install_chrome() {
  log "Google Chrome をインストールします"
  local tmp
  tmp="$(make_tmpdir)"
  download https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb "$tmp/chrome.deb"
  apt_install "$tmp/chrome.deb"
  rm -rf "$tmp"
}

vscode_os() {
  case "$(dpkg --print-architecture)" in
    amd64) echo linux-deb-x64 ;;
    arm64) echo linux-deb-arm64 ;;
    armhf) echo linux-deb-armhf ;;
    *) return 1 ;;
  esac
}

supports_vscode() { vscode_os >/dev/null; }
needs_vscode() { ! is_dpkg_installed code; }

install_vscode() {
  log "VS Code をインストールします"
  local tmp
  tmp="$(make_tmpdir)"
  download "https://code.visualstudio.com/sha/download?build=stable&os=$(vscode_os)" "$tmp/code.deb"
  apt_install gpg "$tmp/code.deb"
  rm -rf "$tmp"
}

# --- 各ステップ -----------------------------------------------------------

os_preflight() { :; }

os_check() {
  local specs=() packages=(docker) spec package
  while IFS= read -r spec; do
    specs+=("$spec")
  done < <(
    read_list "$APT_CUI_LIST"
    if $WITH_GUI; then
      read_list "$APT_GUI_LIST"
    fi
  )
  if $WITH_GUI; then
    packages+=(chrome vscode)
  fi

  MISSING_APT=()
  for spec in "${specs[@]}"; do
    if ! is_apt_spec_installed "$spec"; then
      MISSING_APT+=("$spec")
    fi
  done

  MISSING_OTHERS=()
  for package in "${packages[@]}"; do
    if "supports_$package" && "needs_$package"; then
      MISSING_OTHERS+=("$package")
    fi
  done

  INSTALL_COUNT=$((INSTALL_COUNT + ${#MISSING_APT[@]} + ${#MISSING_OTHERS[@]}))
}

os_install() {
  local package
  # Chrome / VS Code の .deb の依存関係の解決にも使うので、apt で何か入れる場合は先に更新する
  if [ $((${#MISSING_APT[@]} + ${#MISSING_OTHERS[@]})) -gt 0 ]; then
    as_root apt-get update
  fi
  if [ ${#MISSING_APT[@]} -gt 0 ]; then
    log "apt パッケージをインストールします"
    apt_install_specs "${MISSING_APT[@]}"
  fi
  for package in ${MISSING_OTHERS[@]+"${MISSING_OTHERS[@]}"}; do
    "install_$package"
  done
}

os_deploy() {
  link_list os_links
}
