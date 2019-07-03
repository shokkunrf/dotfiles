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

mkdir -p $HOME/_bin

curl -fsSL "https://github.com/peco/peco/releases/download/${latest}/peco_linux_amd64.tar.gz" |
  tar -xz --to-stdout peco_linux_amd64/peco > $HOME/_bin/peco

chmod +x $HOME/_bin/peco

# anyenv
git clone https://github.com/anyenv/anyenv ~/.anyenv
anyenv install --init


# docker-compose
latest=$(
  curl -fsSI https://github.com/docker/compose/releases/latest |
    tr -d '\r' |
    awk -F'/' '/^Location:/{print $NF}'
)

: ${latest:?}

curl -L "https://github.com/docker/compose/releases/download/${latest}/docker-compose-$(uname -s)-$(uname -m)" -o ~/_bin/docker-compose

chmod +x ~/_bin/docker-compose
