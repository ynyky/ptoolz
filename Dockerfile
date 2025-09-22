# https://hub.docker.com/_/ruby/
FROM python:3.13.7-bookworm AS code

#change this if you want to force an apt-get update
ENV BASE_DATE=20250919-0840

# some ppl have their clocks screwed up
ADD config/apt_config /etc/apt/apt.conf.d/99ptoolz

RUN apt-get update -y && \
   apt-get upgrade -y && \
   apt-get install -y --fix-missing \
   bash-completion \
   build-essential \
   libyaml-dev \
   git-core \
   pkg-config \
   cmake \
   postgresql-client \
   redis-tools \
   curl \
   vim \
   g++ \
   libpq-dev \
   lsb-release \ 
   software-properties-common \
   apt-transport-https \
   ca-certificates \
   gnupg \
   gnupg2 \
   gnupg-agent \
   less \
   man-db \
   net-tools \
   dnsutils \
   telnet \
   sudo \
   yamllint \
   jq \
   zsh \
   plantuml\
   pandoc




ENV LANG=C.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=C.UTF-8


RUN useradd -ms /bin/bash -u 1000 -G sudo dev
RUN echo "%sudo	ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


# DOCKER CLI
ENV DOCKER_VERSION=27.0.3
# see: https://docs.docker.com/engine/install/debian/
RUN install -m 0755 -d /etc/apt/keyrings && \ 
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
    chmod a+r /etc/apt/keyrings/docker.asc && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt update -y && \
    apt install -y --fix-missing \
    docker-ce-cli=5:${DOCKER_VERSION}-1~debian.12~bookworm && \
    docker --version


# DOCKER_COMPOSE
ENV DOCKER_COMPOSE_VERSION=v2.30.3
RUN curl -fsSL "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m`" > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    docker-compose version

# HELM is a central part
ENV HELM_VERSION=3.15.2
RUN curl -fsSL "https://get.helm.sh/helm-v$HELM_VERSION-linux-amd64.tar.gz"  > /tmp/helm-linux.tar.gz && \
    cat /tmp/helm-linux.tar.gz | tar -xzv linux-amd64/helm -O > /usr/local/bin/helm && \
    chmod +x /usr/local/bin/helm && \
    rm /tmp/helm-linux.tar.gz
#    helm version

# KUBECTL
ENV KUBECTL_VERSION=1.23.1
RUN curl -fsSL "https://storage.googleapis.com/kubernetes-release/release/v$KUBECTL_VERSION/bin/linux/amd64/kubectl" > /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl
#    kubectl version

# K9S
ENV K9S_VERSION=0.32.5
RUN curl -fsSL "https://github.com/derailed/k9s/releases/download/v$K9S_VERSION/k9s_linux_amd64.deb"  > /tmp/k9s-linux.deb && \
    dpkg -i /tmp/k9s-linux.deb && \
    k9s version

# KIND
ENV KIND_VERSION=0.22.0
RUN  curl  -fsSL "https://github.com/kubernetes-sigs/kind/releases/download/v$KIND_VERSION/kind-linux-amd64" > /usr/local/bin/kind && \
     chmod +x /usr/local/bin/kind && \
     kind --version


#####         --------------- local / project specific part ----------------- #####

# aws cli v2
# RUN pip3 install awscli --upgrade #bad as we have no controll over the version and it's mostly 1.x.x
# see https://docs.aws.amazon.com/cli/latest/userguide/getting-started-version.html
ENV SETUP_AWS_CLI_VERSION=2.13.5
RUN curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-$SETUP_AWS_CLI_VERSION.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf aws && \
    rm -rf awscliv2.zip && \
    aws --version


# terraform
ENV TERRAFORM_VERSION=1.0.11
RUN curl -fsSL "https://apt.releases.hashicorp.com/gpg" | sudo apt-key add -
RUN apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
RUN apt update -y && apt install -y \
    terraform && \
    terraform --version

# trivy
ENV TRIVY_VERSION=0.52.2
RUN curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.deb" -o "trivy_${TRIVY_VERSION}_Linux-64bit.deb" && dpkg -i "trivy_${TRIVY_VERSION}_Linux-64bit.deb"
RUN rm -rf "trivy_${TRIVY_VERSION}_Linux-64bit.deb"


# eksctrl
ENV EKSCTL_VERION=0.150.0
RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/v$EKSCTL_VERION/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
RUN mv /tmp/eksctl /usr/local/bin
#RUN eksctl version

# hcl2json (not yet)
# curl -fsSL https://github.com/tmccombs/hcl2json/releases/download/v0.3.4/hcl2json_linux_amd64 > /usr/local/bin/hcl2json && \

RUN curl -fsSL "https://dl.min.io/client/mc/release/linux-amd64/mc" > /usr/local/bin/mc && \
    chmod 755 /usr/local/bin/mc

ENV GLAB_VERSION=1.31.0
RUN curl --silent --location "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VERSION}/downloads/glab_${GLAB_VERSION}_Linux_x86_64.deb" > /tmp/glab.deb && \
    dpkg -i /tmp/glab.deb && \
    rm /tmp/glab.deb


# other tools (put on the end to avoid long rebuild)
RUN apt-get update -y && \
  apt-get install -y \
  ripgrep \
  tmux \
  iputils-ping \
  rsync \
  openjdk-17-jre-headless \
  gridsite-clients \
  zip \
  socat \
  default-mysql-client \
  iproute2 \
  uuid \
  qemu-kvm \
  qemu-system-x86 \
  qemu-utils \
  libvirt-daemon-system \
  tigervnc-standalone-server \
  libvirt-daemon-system \
  lftp

# PACKER
RUN curl -fsSL https://releases.hashicorp.com/packer/1.11.2/packer_1.11.2_linux_amd64.zip -o packer.zip \
    && unzip packer.zip \
    && mv packer /usr/bin/packer \
    && rm packer.zip \
    && chmod +x /usr/bin/packer

#OCI 
RUN echo "[global]\nbreak-system-packages = true" > /etc/pip.conf && \
    pip install oci-cli==3.64.1
#GO
ENV GO_VERSION=1.25.1

RUN curl --silent --location "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" \
    -o /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/home/dev/go
ENV PATH=$PATH:$GOPATH/bin

RUN go install github.com/x-motemen/gore/cmd/gore@latest
ENV GOCACHE=/tmp/.gocache


# Add user to use kernel feature
RUN usermod -aG kvm dev

ENV PTOOLZ_PATH=/home/dev/ptoolz
# prepare the dev env for local gem installations

# RUN mkdir $MINFRA_ROOT/shared && chmod 777 $MINFRA_ROOT/shared
# ENV MINFRA_GEM_HOME=$MINFRA_ROOT/shared/gems
# ENV PATH=$PATH:$MINFRA_GEM_HOME/bin

# ADD lib $MINFRA_PATH/lib
# ADD templates/on_prem_ccs $MINFRA_PATH
# ADD hiera/hiera_schema.yml $MINFRA_PATH/hiera
# ADD plugins $MINFRA_PATH/plugins
# ADD scripts/download_packages $MINFRA_PATH/scripts/download_packages


# from here we install into the shared path
# WORKDIR $MINFRA_PATH
# RUN cd plugins/ccs-docs && \
#     bundle install && \
#     bundle install && \
#     minfra plugin install

# ENV GEM_HOME=$MINFRA_GEM_HOME

#done
RUN chown -R dev:dev /home/dev

WORKDIR $PTOOLZ_PATH
RUN chown -R dev:dev ./
USER dev
#ENTRYPOINT [ "/bin/bash" ]

# ARG DEV_ENV_VERSION_ARG
# ENV MINFRA_DEV_ENV_VERSION=${DEV_ENV_VERSION_ARG}
