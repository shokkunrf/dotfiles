#!/bin/bash

# peco
# https://qiita.com/ngyuki/items/94a7e638655d9910971b
set -eu

latest=$(
  curl -fsSI https://github.com/peco/peco/releases/latest |
    tr -d '\r' |
    awk -F'/' '/^Location:/{print $NF}'
)

: ${latest:?}

mkdir -p $HOME/bin

curl -fsSL "https://github.com/peco/peco/releases/download/${latest}/peco_linux_amd64.tar.gz" |
  tar -xz --to-stdout peco_linux_amd64/peco > $HOME/bin/peco

chmod +x $HOME/bin/peco

$HOME/bin/peco --version
