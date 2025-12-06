FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y \
    bash ca-certificates git openssh-client \
    build-essential make pkg-config \
    curl wget unzip tar \
    jq yq ripgrep fd-find adduser \
    python3 python3-pip python3-venv \
    python3-mypy python3-flake8 python3-autopep8 python3-isort \
    vim nodejs npm screen \
    golang-go shellcheck \
  && ln -s /usr/bin/fdfind /usr/local/bin/fd \
  && ln -s /usr/bin/python3 /usr/local/bin/python \
  && rm -rf /var/lib/apt/lists/*

ENV HOME=/home/ubuntu
ENV GOPATH=${HOME}/go
ENV PATH="${GOPATH}/bin:/usr/bin:/usr/local/bin"

# Install some global developer tools that are easier to place in /usr/local
RUN npm install -g diagnostic-languageserver
RUN curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh \
  | sh -s -- -b /usr/local/bin latest
RUN GOPATH=/usr/local /usr/bin/env PATH="$PATH" go install golang.org/x/tools/cmd/goimports@latest

# Copy defaults into /etc/skel so the init script can populate a new volume
COPY vim /etc/skel/.vim
COPY screenrc /etc/skel/.screenrc

# Add init script to populate the home volume on first run
COPY docker/init-devbox.sh /usr/local/bin/init-devbox
RUN chmod +x /usr/local/bin/init-devbox

USER ubuntu
WORKDIR ${HOME}
CMD ["/bin/bash"]
