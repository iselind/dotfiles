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
    golang-go ccls shellcheck astyle clang \
  && ln -s /usr/bin/fdfind /usr/local/bin/fd \
  && ln -s /usr/bin/python3 /usr/local/bin/python \
  && rm -rf /var/lib/apt/lists/*



# Create a non-root devbox user (UID/GID 1000) and prepare skel
ENV HOME=/home/devbox
ENV GOPATH=${HOME}/go
ENV PATH="${GOPATH}/bin:/usr/bin:/usr/local/bin"

# Install some global developer tools that are easier to place in /usr/local
RUN npm install -g diagnostic-languageserver \
  && curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b /usr/local/bin latest || true \
  && GOPATH=/usr/local /usr/bin/env PATH="$PATH" go install golang.org/x/tools/cmd/goimports@latest || true

# Copy defaults into /etc/skel so the init script can populate a new volume
COPY vim /etc/skel/.vim
COPY screenrc /etc/skel/.screenrc

# Provide compatibility for configs that use an absolute host path (/home/patrik)
# by creating a lightweight symlink so tools referencing /home/patrik/.vim work
# inside the container too.
RUN mkdir -p /home/patrik \
  && ln -s /etc/skel/.vim /home/patrik/.vim || true

# Add init script to populate the home volume on first run
COPY docker/init-devbox.sh /usr/local/bin/init-devbox
RUN chmod +x /usr/local/bin/init-devbox

USER ubuntu
WORKDIR ${HOME}
CMD ["/bin/bash"]
