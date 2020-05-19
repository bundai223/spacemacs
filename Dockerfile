FROM ubuntu:20.10
MAINTAINER bundai223 <bundai223@gmail.com>

ARG UID=1000
ARG UHOME=/home/emacs

# tzdataのインストールでgitが入っているとinteractiveになってしまうのを抑制
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo

ENV CHROME_KEY="https://dl-ssl.google.com/linux/linux_signing_key.pub" \
    CHROME_REP="deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"

USER root
RUN apt-get update -y \
    && apt-get install -y \
    gnupg \
    curl \
    gcc \
    python \
    rlwrap \
    silversearcher-ag \
    wget \
    cmigemo \
    git \
    emacs \
    && wget -q -O - "${CHROME_KEY}" | apt-key add - \
    && echo "${CHROME_REP}" >> /etc/apt/sources.list.d/google.list \
    && apt-get update -y \
    && apt-get install -y google-chrome-stable \
    && rm -rf /tmp/* /var/lib/apt/lists/* \
    && google-chrome \
    --disable-gpu \
    --headless \
    --no-sandbox \
    https://example.org/

USER $UID
RUN git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d
