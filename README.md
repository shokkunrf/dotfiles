# dotfiles

[![CI](https://github.com/shokkunrf/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/shokkunrf/dotfiles/actions/workflows/ci.yml)

Debian と macOS の環境構築用 dotfiles。入口は `install.sh` だけで、次の 3 つの環境で使える。

| 環境 | 行うこと |
| --- | --- |
| devcontainer / Codespaces | 設定の配置だけ (自動で判定する) |
| CLI のホスト (Debian) | CUI のパッケージ・Docker・wd のインストール、ログインシェルを bash に、設定の配置 |
| デスクトップのホスト (Debian + xmonad / macOS) | 上に加えて GUI のパッケージ・アプリと、GUI・macOS 用の設定 |

`sudo` は付けずに実行する。root 権限が必要な場合は、最初に一度だけパスワードを聞く。何度実行しても同じ結果になる。

## 使い方

### devcontainer / Codespaces

VS Code の `settings.json` に設定すると、コンテナを作るたびに `install.sh` が引数なしで実行される。

```json
"dotfiles.repository": "shokkunrf/dotfiles",
"dotfiles.targetPath": "~/dotfiles",
"dotfiles.installCommand": "install.sh"
```

Codespaces の場合は <https://github.com/settings/codespaces> で「Automatically install dotfiles」をオンにし、このリポジトリを選ぶ。

- コンテナ内 (`$CODESPACES`、`$REMOTE_CONTAINERS`、`/.dockerenv`、`/run/.containerenv` で判定) では設定の配置だけを行い、sudo は使わない
- fzf などのツールは、プロジェクトの `devcontainer.json` の Features かイメージで用意する

### CLI のホスト (Debian)

```sh
curl -fsSL https://raw.githubusercontent.com/shokkunrf/dotfiles/HEAD/install.sh | bash   # 初回 (~/.dotfiles に clone して実行)
cd ~/.dotfiles && git pull && ./install.sh                                                # 更新
```

- Debian のインストール時に root のパスワードを設定した場合は sudo が無いので、先に `su -c 'apt-get install -y sudo && usermod -aG sudo ユーザ名'` を実行してログインし直す
- `curl` が無い場合は `wget -qO-` に置き換える
- パッケージを入れられない環境では `./install.sh --no-packages` で設定の配置だけ行える

### デスクトップのホスト

```sh
# Debian (xmonad)
curl -fsSL https://raw.githubusercontent.com/shokkunrf/dotfiles/HEAD/install.sh | bash -s -- --with-gui   # 初回
cd ~/.dotfiles && git pull && ./install.sh --with-gui                                                    # 更新

# macOS
curl -fsSL https://raw.githubusercontent.com/shokkunrf/dotfiles/HEAD/install.sh | bash   # 初回
cd ~/.dotfiles && git pull && ./install.sh                                                # 更新
```

- Debian: ログインし直し、ディスプレイマネージャで既定のセッションを選ぶか `startx` を実行すると、`.xsession` から xmonad が起動する
- macOS: ログインし直すとシェルと Dock などの設定が反映される。Karabiner-Elements などは初回起動時に「システム設定」で権限を許可する
- macOS: 手動で入れたアプリと同じものは Homebrew の管理に取り込む。バージョンが違うなどでインストールできなかった場合も設定の配置は行い、最後にエラーを表示する

### オプション・環境変数

| オプション | 説明 |
| --- | --- |
| `--with-gui` | GUI 環境用のパッケージ・設定も入れる (Debian のみ) |
| `--packages` | パッケージのインストールを行う (コンテナ外では指定しなくても行う) |
| `--no-packages` | 設定の配置だけ行う (sudo を一切使わない。コンテナ内では指定しなくてもこうなる) |

ワンライナーで使う環境変数:

| 環境変数 | 既定値 | 説明 |
| --- | --- | --- |
| `DOTFILES_DIR` | `~/.dotfiles` | clone 先 (既に存在する場合はそれを使う) |
| `DOTFILES_REPO` | `https://github.com/shokkunrf/dotfiles.git` | clone する URL |
| `DOTFILES_BRANCH` | (デフォルトブランチ) | clone するブランチ。別のブランチを試す場合は URL の `HEAD` もブランチ名にする |

## 実行の流れ

毎回同じ 3 ステップを表示し、何をして何をスキップしたかと、最後に件数のまとめを表示する。何度実行しても同じ結果になる。

| ステップ | 内容 |
| --- | --- |
| [1/3] 確認 | 足りないパッケージとログインシェルを調べる (何も変更しない) |
| [2/3] インストール | 足りないものだけインストールし (インストール済みのものは更新しない)、ログインシェルを bash にする (Debian: `/bin/bash`、macOS: Homebrew の bash) |
| [3/3] 設定の配置 | `src/` 以下をホームディレクトリにリンクし、git と macOS の `defaults` を設定する。既存のファイルは `~/.dotfiles_backup/<日時>/` に退避する |

初回:

```
パッケージ 9 件のインストール・ログインシェルの変更に管理者権限が必要です。[sudo] user のパスワード:
[1/3] 確認
    apt      9 件中 8 件が未インストール (vim fzf jq ...)
    docker   未インストール
    wd       未インストール
    shell    /bin/sh -> /bin/bash に変更
[2/3] インストール
    ...
[3/3] 設定の配置
    退避   ~/.bashrc -> ~/.dotfiles_backup/20261103120000/.bashrc
    リンク ~/.bashrc
    ...
完了 インストール 10 件 / リンク 6 件 / 退避 2 件 / 設定変更 8 件
ログインシェルを変更したので、ログインし直してください
```

2 回目以降 (すべて済んでいる場合) は sudo を使わない:

```
[1/3] 確認
    apt      9 件すべてインストール済み
    docker   インストール済み
    wd       インストール済み
    shell    /bin/bash
[2/3] インストール  スキップ (すべてインストール済み)
[3/3] 設定の配置
    すべて配置済み
完了 インストール 0 件 / リンク 0 件 / 退避 0 件 / 設定変更 0 件
```

### sudo について

- root 権限が必要なもの (apt / Docker / Chrome / VS Code / Homebrew 本体 / cask / ログインシェルの変更) がある場合だけ、**何かを表示する前に一度だけ**パスワードを聞く。表示が始まった後は終了まで入力待ちにならない
- すべて済んでいれば sudo は使わない。コンテナ内と `--no-packages` では sudo には一切触れない
- ワンライナーの初回 (clone が必要な時) は、clone の前にパスワードを聞く
- パスワードが必要なのに端末が無い場合は、待たずにエラーで終了する
- apt の設定ファイル確認・git の認証などの対話も起きないようにしている。他の apt (自動更新など) が実行中なら終わるまで待つ

## 構成

| パス | 責務 |
| --- | --- |
| `install.sh` | 唯一の入口。引数の解析、初回の clone、3 ステップの進行とまとめの表示 |
| `lib/common.sh` | OS に依存しない道具 (表示、sudo、確認結果の集計、ログインシェルの変更) |
| `lib/user.sh` | OS 共通でユーザ領域だけを変更する処理 (wd、リンクと退避、git の設定)。sudo を使わない |
| `lib/debian.sh` | Debian の処理 (apt / Docker / Chrome / VS Code、GUI 用のリンク) |
| `lib/darwin.sh` | macOS の処理 (Homebrew、macOS 用のリンク、`defaults`) |
| `packages/` | インストールするものの一覧 (`apt-cui.txt`、`apt-gui.txt`、`Brewfile`) |
| `src/` | ホームディレクトリに配置するファイル |
| `test/verify.sh` | インストール後の検証 (CI で使用。リンクの一覧などは `lib/` の定義を使う) |
| `test/lint.sh` | 書式 (shfmt、設定は `.editorconfig`) とリント (shellcheck、actionlint、JSON) の確認。`--fix` で書式を直す |

- パッケージを追加・削除する場合は `packages/` の一覧だけを編集する
- 配置するファイルを追加する場合は `src/` に置き、`lib/user.sh` (共通) か `lib/debian.sh` / `lib/darwin.sh` (OS 固有) の一覧に追加する
- `lib/debian.sh` と `lib/darwin.sh` は同じ関数 (`os_check` / `os_install` / `os_deploy` など) を持ち、`install.sh` は OS に合わせて片方だけを読み込む

## CI

GitHub Actions (`.github/workflows/ci.yml`) で以下を確認している。

- `test/lint.sh` (書式とリント)
- Debian 12 / 13 のコンテナで `install.sh` (CUI / GUI / root でのパイプ実行 / devcontainer / `--no-packages`) を 2 回実行し、`test/verify.sh` で検証
  - devcontainer は sudo の無いユーザで引数なしで実行し、コンテナと判定されて配置だけ行うことを確認する
  - 2 回目は sudo の権限を外して実行し、sudo を使わずに変更 0 件で完了することを確認する
  - ログインシェルが bash に変わること、xmonad の設定がコンパイルできること、シェルの起動時にエラーが出ないことも確認する
- macOS で `install.sh` を 2 回実行し (2 回目は変更 0 件であることを確認)、`test/verify.sh` で検証 (Brewfile の cask は存在確認のみ)
