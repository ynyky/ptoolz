FROM python:3.13.7-bookworm AS code

# Set locale
ENV LANG=C.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=C.UTF-8 \
    PTOOLZ_PATH=/home/dev/ptoolz \
    GOPATH=/home/dev/go \
    GOCACHE=/tmp/.gocache

ENV PATH=$PATH:/usr/local/go/bin:/home/dev/go/bin


# Set base date for caching (if you want to force apt update)
ENV BASE_DATE=20250919-0840

# Some ppl have their clocks screwed up
ADD config/apt_config /etc/apt/apt.conf.d/99ptoolz

# Install system dependencies
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends --fix-missing \
    bash-completion build-essential libyaml-dev git-core pkg-config cmake \
    postgresql-client redis-tools curl vim g++ libpq-dev lsb-release \
    software-properties-common apt-transport-https ca-certificates \
    gnupg gnupg2 gnupg-agent less man-db net-tools dnsutils telnet sudo \
    yamllint jq zsh plantuml pandoc ripgrep tmux iputils-ping rsync \
    openjdk-17-jre-headless gridsite-clients zip socat default-mysql-client \
    iproute2 uuid qemu-kvm qemu-system-x86 qemu-utils libvirt-daemon-system \
    tigervnc-standalone-server lftp unzip && \
    rm -rf /var/lib/apt/lists/*

# Create dev user
RUN useradd -ms /bin/bash -u 1000 -G sudo dev && \
    echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ----------------- CLI Tools ----------------- #
# Docker CLI
ENV DOCKER_VERSION=29.2.1
RUN install -d -m 0755 /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list && \
    apt-get update && apt-get install -y docker-ce-cli=5:${DOCKER_VERSION}-1~debian.12~bookworm && \
    docker --version

# Docker Compose
ENV DOCKER_COMPOSE_VERSION=v5.0.2
RUN curl -fsSL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose

# Helm
ENV HELM_VERSION=4.1.1
RUN curl -fsSL "https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz" -o /tmp/helm.tar.gz && \
    tar -xzvf /tmp/helm.tar.gz -C /tmp linux-amd64/helm && \
    mv /tmp/linux-amd64/helm /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm -rf /tmp/helm.tar.gz /tmp/linux-amd64

# Kubectl
ENV KUBECTL_VERSION=1.35.0
RUN curl -fsSL "https://dl.k8s.io/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl" -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl
# K9s
ENV K9S_VERSION=0.50.18
RUN curl -fsSL "https://github.com/derailed/k9s/releases/download/v$K9S_VERSION/k9s_linux_amd64.deb" -o /tmp/k9s.deb && \
    dpkg -i /tmp/k9s.deb && rm /tmp/k9s.deb

# Kind
ENV KIND_VERSION=0.31.0
RUN curl -fsSL "https://github.com/kubernetes-sigs/kind/releases/download/v$KIND_VERSION/kind-linux-amd64" -o /usr/local/bin/kind && chmod +x /usr/local/bin/kind

# AWS CLI v2
ENV AWS_CLI_VERSION=2.33.20
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-$AWS_CLI_VERSION.zip" -o awscliv2.zip && \
    unzip awscliv2.zip && ./aws/install && rm -rf aws awscliv2.zip

# Terraform
ENV TERRAFORM_VERSION=1.14.5
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update && apt-get install -y terraform

# Trivy
ENV TRIVY_VERSION=0.69.1
RUN curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.deb" -o trivy.deb && \
    dpkg -i trivy.deb && rm trivy.deb

# Eksctl
ENV EKSCTL_VERSION=0.222.0
RUN curl -fsSL "https://github.com/weaveworks/eksctl/releases/download/v$EKSCTL_VERSION/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin/

# MinIO client
RUN curl -fsSL "https://dl.min.io/client/mc/release/linux-amd64/mc" -o /usr/local/bin/mc && chmod +x /usr/local/bin/mc

# GLAB
ENV GLAB_VERSION=1.31.0
RUN curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_Linux_x86_64.deb" -o /tmp/glab.deb && \
    dpkg -i /tmp/glab.deb && rm /tmp/glab.deb

# Packer
RUN curl -fsSL https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip -o packer.zip && \
    unzip packer.zip && mv packer /usr/bin/packer && chmod +x /usr/bin/packer && rm packer.zip

# OCI CLI
RUN echo "[global]\nbreak-system-packages = true" > /etc/pip.conf && pip install oci-cli==3.64.1

# Go
ENV GO_VERSION=1.26.0
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && rm /tmp/go.tar.gz

# Go tools
RUN go install github.com/x-motemen/gore/cmd/gore@latest && \
    go install golang.org/x/tools/gopls@latest

# Add dev user to KVM group
RUN usermod -aG kvm dev
ADD requirements/python-requirements.txt /tmp/python-requirements.txt
RUN pip install -r /tmp/python-requirements.txt

# neovim
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
RUN rm -rf /opt/nvim-linux-x86_64
RUN tar -C /opt -xzf nvim-linux-x86_64.tar.gz
RUN mkdir -p /opt/nvim-config/lazy
RUN git clone https://github.com/folke/lazy.nvim.git \
  /opt/nvim-config/lazy/lazy.nvim
RUN chown -R dev:dev /opt/nvim-config
# Set working directory
RUN mkdir -p $PTOOLZ_PATH && chown -R dev:dev $PTOOLZ_PATH
USER dev
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/go/bin:$GOPATH/bin:/opt/nvim-linux-x86_64/bin:$PATH
WORKDIR $PTOOLZ_PATH
