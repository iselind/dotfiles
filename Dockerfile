FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y \
    bash ca-certificates git openssh-client \
    build-essential make pkg-config \
    curl wget unzip tar \
    jq yq ripgrep fd-find adduser \
    python3 python3-pip python3-venv \
    vim nodejs npm screen \
  && ln -s /usr/bin/fdfind /usr/local/bin/fd \
  && ln -s /usr/bin/python3 /usr/local/bin/python \
  && rm -rf /var/lib/apt/lists/*

# Create a non-root devbox user (UID/GID 1000) and prepare skel
ENV HOME=/home/devbox
ENV GOPATH=${HOME}/go
ENV PATH="${GOPATH}/bin:/usr/bin:/usr/local/bin"

RUN adduser --uid 1000 --disabled-password --gecos "" devbox || true

# Copy defaults into /etc/skel so the init script can populate a new volume
COPY vim /etc/skel/.vim
COPY screenrc /etc/skel/.screenrc

# Add init script to populate the home volume on first run
COPY docker/init-devbox.sh /usr/local/bin/init-devbox
RUN chmod +x /usr/local/bin/init-devbox

WORKDIR ${HOME}
CMD ["/bin/bash"]
