# shellcheck shell=bash
# ここで定義する変数 (INSTALL_COUNT など) は install.sh や lib/*.sh から使うため、未使用の警告は出さない
# shellcheck disable=SC2034
#
# OS に依存しない道具 (表示、sudo、ダウンロード、OS の判定) と、
# [1/3] 確認 の結果を集めるための変数
#
# macOS 標準の bash 3.2 でも動くように書くこと (連想配列や ${var,,} などは使わない)

# --- 表示 -----------------------------------------------------------------

log() { printf '    %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() {
  printf '\033[1;31merror:\033[0m %s\n' "$*" >&2
  exit 1
}

# 手順の見出し: step <番号> <名前> [補足]
STEP_PRINTED=false
step() {
  $STEP_PRINTED && echo
  STEP_PRINTED=true
  printf '\033[1;34m[%s]\033[0m \033[1m%s\033[0m%s\n' "$1" "$2" "${3:+  $3}"
}

# 確認結果の 1 行: item <名前> <状態>
item() { printf '    %-8s %s\n' "$1" "$2"; }

# 最後の結果表示: summary <内容>
summary() { printf '\n\033[1;32m完了\033[0m %s\n' "$*"; }

# --- 確認の結果 -------------------------------------------------------------
# *_check は何も表示せず、sudo も使わずに、以下に結果を入れる

REPORT=''       # [1/3] 確認 で表示する内容 (report で追加する)
INSTALL_COUNT=0 # [2/3] でインストールする件数
SETTING_COUNT=0 # 変更する設定の件数 (git、defaults)
LINK_COUNT=0    # [3/3] で作ったリンクの件数
BACKUP_COUNT=0  # [3/3] で退避したファイルの件数
SUDO_REASON=''  # root 権限が必要な理由 (不要なら空)

report() { REPORT="$REPORT$(item "$1" "$2")"$'\n'; }

add_sudo_reason() {
  if [ -z "$SUDO_REASON" ]; then
    SUDO_REASON="$1"
  else
    SUDO_REASON="$SUDO_REASON・$1"
  fi
}

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

# root 権限が必要な場合に、何かを表示する前に呼ぶ: require_sudo <理由>
# パスワードはここで一度だけ聞き、スクリプトが終わるまで認証を維持する (途中で入力待ちにしない)
SUDO_READY=false
require_sudo() {
  if is_root || $SUDO_READY; then
    return 0
  fi
  command -v sudo >/dev/null 2>&1 ||
    die "$1に管理者権限が必要ですが、sudo が見つかりません。root で実行するか、--no-packages を付けてください"
  if ! sudo -n true 2>/dev/null; then
    sudo -v -p "$1に管理者権限が必要です。[sudo] %u のパスワード: " ||
      die "sudo の認証に失敗しました"
  fi
  (while kill -0 "$$" 2>/dev/null; do
    sudo -n true
    sleep 50
  done) >/dev/null 2>&1 &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
  SUDO_READY=true
}

# root 権限でコマンドを実行する (root なら直接、そうでなければ sudo 経由)
# 事前に require_sudo を呼んでおくこと。途中でパスワード入力待ちにならないよう -n を付ける
as_root() {
  if is_root; then
    "$@"
  else
    sudo -n "$@"
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
