FROM ubuntu:20.10 as emacs

RUN apt-get update -y \
&&  apt-get install -y \
    gnupg \
    curl \
    gcc \
    wget \
    emacs

FROM emacs

MAINTAINER bundai223 <bundai223@gmail.com>

# tzdataのインストールでgitが入っているとinteractiveになってしまうのを抑制
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

ENV CHROME_KEY="https://dl-ssl.google.com/linux/linux_signing_key.pub" \
    CHROME_REP="deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"

RUN apt-get install -y \
    language-pack-ja-base language-pack-ja \
    python \
    rlwrap \
    silversearcher-ag \
    aspell \
    aspell-en \
    cmigemo \
    git \
    git-flow \
    zip unzip \
    make automake autoconf libreadline-dev libncurses-dev libssl-dev libyaml-dev libxslt-dev libffi-dev libtool unixodbc-dev zlib1g-dev bsdmainutils \
&&  wget -q -O - "${CHROME_KEY}" | apt-key add - \
&&  echo "${CHROME_REP}" >> /etc/apt/sources.list.d/google.list \
&&  apt-get update -y \
&&  apt-get install -y google-chrome-stable \
&&  rm -rf /tmp/* /var/lib/apt/lists/* \
&&  google-chrome \
    --disable-gpu \
    --headless \
    --no-sandbox \
    https://example.org/ \
&&  locale-gen ja_JP.UTF-8 \
&&  mkdir -p ~/.fonts \
&&  cd ~/.fonts \
&&  wget https://github.com/yuru7/HackGen/releases/download/v1.4.1/HackGen_v1.4.1.zip \
&&  unzip HackGen_v1.4.1.zip \
&&  mv HackGen_v1.4.1/*.ttf ~/.fonts \
&&  rm -rf HackGen_v1.4.1* \
&&  fc-cache -fv \
&&  git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d \
&&  git clone https://github.com/asdf-vm/asdf.git ~/.asdf

SHELL ["/bin/bash", "-c"]

# install ruby
RUN source ~/.asdf/asdf.sh \
&&  asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git \
&&  rm -f ~/.default-gems \
&&  echo 'bundler' >> ~/.default-gems \
&&  echo 'pry' >> ~/.default-gems \
&&  echo 'solargraph' >> ~/.default-gems \
&&  echo 'rubocop' >> ~/.default-gems \
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
&&  asdf global golang $(asdf list golang)

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
