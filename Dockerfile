FROM ubuntu:20.10 as emacs
ENV DATE=20200609
ENV HOME=/root
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
&&  apt-get install -y \
    gnupg \
    curl \
    gcc \
    wget \
    zip unzip \
    git \
    git-flow \
    emacs

FROM emacs as font

ARG HACKGEN_VER=2.0.0

RUN mkdir -p ${HOME}/.local/share/fonts \
&&  cd ~/.local/share/fonts \
# &&  wget https://github.com/googlefonts/noto-emoji/raw/master/fonts/NotoColorEmoji.ttf -O NotoColorEmoji.ttf \
# &&  wget https://github.com/googlefonts/noto-emoji/raw/master/fonts/NotoEmoji-Regular.ttf -O NotoEmoji-Regular.ttf \
&&  wget https://github.com/yuru7/HackGen/releases/download/v${HACKGEN_VER}/HackGenNerd_v${HACKGEN_VER}.zip \
&&  unzip HackGenNerd_v${HACKGEN_VER}.zip \
&&  mv HackGenNerd_v${HACKGEN_VER}/*.ttf ~/.local/share/fonts \
&&  rm -rf HackGenNerd_v${HACKGEN_VER}*

FROM emacs as chrome
ENV CHROME_KEY="https://dl-ssl.google.com/linux/linux_signing_key.pub" \
    CHROME_REP="deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"

RUN wget -q -O - "${CHROME_KEY}" | apt-key add - \
&&  echo "${CHROME_REP}" >> /etc/apt/sources.list.d/google.list \
&&  apt-get update -y \
&&  apt-get install -y google-chrome-stable \
&&  google-chrome \
    --disable-gpu \
    --headless \
    --no-sandbox \
    https://example.org/

FROM emacs

MAINTAINER bundai223 <bundai223@gmail.com>

# tzdataのインストールでgitが入っているとinteractiveになってしまうのを抑制
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

COPY --from=font ${HOME}/.local/share/fonts ${HOME}/.local/share/fonts
RUN apt-get install -y \
    language-pack-ja-base language-pack-ja \
    python \
    rlwrap \
    silversearcher-ag \
    aspell \
    aspell-en \
    cmigemo \
    docker.io \
    make automake autoconf libreadline-dev libncurses-dev libssl-dev libyaml-dev libxslt-dev libffi-dev libtool unixodbc-dev zlib1g-dev bsdmainutils \
    build-essential libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev software-properties-common \
    fonts-symbola \
&&  curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose \
&&  chmod +x /usr/local/bin/docker-compose \
&&  rm -rf /tmp/* /var/lib/apt/lists/* \
&&  locale-gen ja_JP.UTF-8 \
&&  fc-cache -fv \
&&  git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d \
&&  git clone https://github.com/asdf-vm/asdf.git ~/.asdf \
&&  mkdir -p ~/.emacs.d/private/layers

SHELL ["/bin/bash", "-c"]

# install ruby
RUN source ~/.asdf/asdf.sh \
&&  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git \
&&  rm -f ~/.default-gems \
&&  echo 'bundler' >> ~/.default-gems \
&&  echo 'pry' >> ~/.default-gems \
&&  echo 'pry-doc' >> ~/.default-gems \
&&  echo 'solargraph' >> ~/.default-gems \
&&  echo 'rubocop' >> ~/.default-gems \
&&  echo 'ruby_parser' >> ~/.default-gems \
&&  echo 'seeing_is_believing' >> ~/.default-gems \
&&  echo 'ruby-debug-ide' >> ~/.default-gems \
&&  echo 'debase' >> ~/.default-gems \
&&  asdf install ruby latest \
&&  asdf global ruby $(asdf list ruby)

# install rust
RUN source ~/.asdf/asdf.sh \
&&  asdf plugin-add rust https://github.com/code-lever/asdf-rust.git \
&&  asdf install rust latest \
&&  asdf global rust $(asdf list rust)

# install golang
RUN source ~/.asdf/asdf.sh \
&&  asdf plugin-add golang https://github.com/kennyp/asdf-golang.git \
&&  asdf install golang latest \
&&  asdf global golang $(asdf list golang) \
&&  go get github.com/motemen/ghq \
&&  git clone https://github.com/sei40kr/spacemacs-ghq ~/.emacs.d/private/layers/ghq \
&&  asdf reshim golang

# install nodejs
RUN source ~/.asdf/asdf.sh \
&&  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git \
&&  bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring \
&&  rm -f ~/.default-npm-packages \
&&  echo 'bash-language-server' >> ~/.default-npm-packages \
&&  echo 'dockerfile-language-server-nodejs' >> ~/.default-npm-packages \
&&  echo 'vue-language-server' >> ~/.default-npm-packages \
&&  echo 'vscode-json-languageserver-bin' >> ~/.default-npm-packages \
&&  echo 'vscode-css-languageserver-bin' >> ~/.default-npm-packages \
&&  echo 'vscode-html-languageserver-bin' >> ~/.default-npm-packages \
&&  echo 'yaml-language-server' >> ~/.default-npm-packages \
&&  echo 'vim-language-server' >> ~/.default-npm-packages \
&&  echo 'eslint-plugin-vue' >> ~/.default-npm-packages \
&&  asdf install nodejs latest \
&&  asdf global nodejs $(asdf list nodejs)

WORKDIR /root/repos
