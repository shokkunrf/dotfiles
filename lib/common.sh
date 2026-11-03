# shellcheck shell=bash
# ここで定義する変数 (INSTALL_COUNT など) は install.sh や lib/*.sh から使うため、未使用の警告は出さない
# shellcheck disable=SC2034
#
# OS に依存しない道具 (表示、OS の判定、権限、ダウンロード) と、確認の結果を集めるための変数
#
# macOS 標準の bash 3.2 でも動くように書くこと (連想配列や ${var,,} などは使わない)

# --- 表示 -----------------------------------------------------------------

log() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

# --- 確認の結果 -------------------------------------------------------------
# *_check は何も表示せず、sudo も使わずに、以下に結果を入れる

INSTALL_COUNT=0 # インストールする件数

# 単語の数: count_words <文字列>
count_words() {
  # shellcheck disable=SC2086
  set -- $1
  echo $#
}

# --- OS -------------------------------------------------------------------

# 実行中の OS を判定する: debian | darwin | unsupported
detect_os() {
  case "$(uname -s)" in
    Darwin)
      echo darwin
      ;;
    Linux)
      if [ -r /etc/debian_version ] && command -v apt-get >/dev/null 2>&1; then
        echo debian
      else
        echo unsupported
      fi
      ;;
    *)
      echo unsupported
      ;;
  esac
}

# --- 権限 -----------------------------------------------------------------

is_root() { [ "$(id -u)" -eq 0 ]; }

# sudo 経由で実行されているか (sudo ./install.sh のような誤用の検出に使う)
is_sudo() { is_root && [ -n "${SUDO_USER:-}" ]; }

# root 権限でコマンドを実行する (root なら直接、そうでなければ sudo 経由)
as_root() {
  if is_root; then
    "$@"
  else
    sudo "$@"
  fi
}

# --- ファイル -------------------------------------------------------------

# download <url> <dest>
download() {
  curl -fsSL --retry 3 -o "$2" "$1"
}

# root の apt などからも読める一時ディレクトリを作る
make_tmpdir() {
  local tmp
  tmp="$(mktemp -d)"
  chmod 755 "$tmp"
  echo "$tmp"
}

# 一覧ファイルを読む (# 以降と空行を除き、1 行に 1 つ出力する): read_list <file>
read_list() {
  sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^[[:space:]]*$/d' "$1"
}
