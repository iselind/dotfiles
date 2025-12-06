FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y \
    bash ca-certificates git openssh-client \
    build-essential make pkg-config \
    curl wget unzip tar \
    jq yq ripgrep fd-find \
    python3 python3-pip python3-venv \
    vim nodejs npm screen \
  && ln -s /usr/bin/fdfind /usr/local/bin/fd \
  && ln -s /usr/bin/python3 /usr/local/bin/python \
  && rm -rf /var/lib/apt/lists/*

# Use mounted HOME
ENV HOME=/home/devbox
ENV GOPATH=${HOME}/go
ENV PATH="${GOPATH}/bin:/usr/bin:/usr/local/bin"

WORKDIR ${HOME}
CMD ["/bin/bash"]
